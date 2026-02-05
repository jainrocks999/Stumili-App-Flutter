import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stumili/core/secure_storage.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/custom_button.dart';
import 'package:stumili/services/reminder_scheduler.dart';

class ReminderModal extends StatefulWidget {
  final Map<String, dynamic>? selectedReminder;

  const ReminderModal({super.key, this.selectedReminder});

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  int repeat = 7;
  String startTime = "09:00";
  String endTime = "09:30";

  List<Map<String, dynamic>> categories = [];
  Map<String, dynamic>? selectedCategory;
  bool loadingCategories = false;

  final days = const [
    {"id": "mon", "label": "M"},
    {"id": "tue", "label": "T"},
    {"id": "wed", "label": "W"},
    {"id": "thu", "label": "T"},
    {"id": "fri", "label": "F"},
    {"id": "sat", "label": "S"},
    {"id": "sun", "label": "S"},
  ];

  final Set<String> selectedDays = {};

  @override
  void initState() {
    super.initState();

    // Load reminder data (edit mode)
    if (widget.selectedReminder != null) {
      final r = widget.selectedReminder!;
      repeat = int.tryParse(r['repeat'].toString()) ?? 7;

      startTime = _extractTime(r['start_at']);
      endTime = _extractTime(r['end_at']);

      for (final d in days) {
        if (r[d['id']] == 1) {
          selectedDays.add(d['id'] as String);
        }
      }
    }

    fetchCategories().then((_) async {
      final cid = widget.selectedReminder?['playlist_id'];
      if (cid == null) return;

      final found = categories.where(
        (c) => c['id'].toString() == cid.toString(),
      );
      if (found.isNotEmpty) {
        setState(() => selectedCategory = found.first);
      } else {
        await fetchCategoryDetailAndSet(cid);
      }
    });
  }

  Future<void> fetchCategoryDetailAndSet(dynamic categoryId) async {
    try {
      final userId = await SecureStore.getUserId();

      final res = await ApiService.getRequest(
        "/categoryDetail",
        queryParameters: {"user_id": userId, "category_id": categoryId},
      );

      final data = res.data?['data'];
      if (data == null) return;

      // ✅ normalize to your UI shape (so UI same keys use kare)
      final normalized = {
        "id": data["id"],
        "categories_name": data["categories_name"],
        // pick best image url
        "caetgory_images":
            (data["categories_image"] is List &&
                data["categories_image"].isNotEmpty)
            ? (data["categories_image"][0]["original_url"] ??
                  data["categories_image"][0]["url"] ??
                  data["categories_image"][0]["thumbnail"] ??
                  "")
            : "",
        "is_favorite": data["is_favorite"] == true, // agar backend bheje to
      };

      if (!mounted) return;
      setState(() => selectedCategory = normalized);
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load category detail");
    }
  }

  Future<void> fetchCategories() async {
    try {
      setState(() => loadingCategories = true);

      final userId = await SecureStore.getUserId();
      final response = await ApiService.getRequest(
        '/categories',
        queryParameters: {'user_id': userId},
      );

      final list = List<Map<String, dynamic>>.from(response.data['data'] ?? []);

      setState(() {
        categories = list;
        // If not selected yet, keep null (user will pick)
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to load categories");
    } finally {
      if (mounted) setState(() => loadingCategories = false);
    }
  }

  String _extractTime(String? value) {
    if (value == null) return "09:00";
    // expected: "YYYY-MM-DD HH:mm:ss"
    final parts = value.split(' ');
    if (parts.length < 2) return "09:00";
    final t = parts[1];
    if (t.length < 5) return "09:00";
    return t.substring(0, 5);
  }

  void _updateTime(bool isStart, bool inc) {
    final parts = (isStart ? startTime : endTime)
        .split(':')
        .map(int.parse)
        .toList();
    int h = parts[0], m = parts[1];

    m += inc ? 30 : -30;
    if (m >= 60) {
      m = 0;
      h = (h + 1) % 24;
    }
    if (m < 0) {
      m = 30;
      h = (h - 1 + 24) % 24;
    }

    final val =
        "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";

    setState(() {
      if (isStart) {
        startTime = val;
        // auto endTime = start + 30 min
        final endM = (m + 30) % 60;
        final endH = (m + 30 >= 60) ? (h + 1) % 24 : h;
        endTime =
            "${endH.toString().padLeft(2, '0')}:${endM.toString().padLeft(2, '0')}";
      } else {
        endTime = val;
      }
    });
  }

  // ---------------- CATEGORY PICKER MODAL ----------------

  void _openCategoryPicker() async {
    if (loadingCategories) return;

    if (categories.isEmpty) {
      Fluttertoast.showToast(msg: "No categories found");
      return;
    }

    final picked = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141414),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return _CategoryPickerSheet(
          items: categories,
          selectedId: selectedCategory?['id']?.toString(),
        );
      },
    );

    if (picked != null) {
      setState(() => selectedCategory = picked);
    }
  }

  Widget _selectedCategoryCard() {
    if (selectedCategory == null) {
      return GestureDetector(
        onTap: _openCategoryPicker,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF333333)),
          ),
          child: Row(
            children: const [
              Icon(Icons.category, color: Colors.white70),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Pick a category",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              Icon(Icons.keyboard_arrow_up, color: Colors.white70),
            ],
          ),
        ),
      );
    }

    final img = selectedCategory?['caetgory_images']?.toString();
    final name = selectedCategory?['categories_name']?.toString() ?? "Category";
    final fav = selectedCategory?['is_favorite'] == true;

    return GestureDetector(
      onTap: _openCategoryPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFB72658)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: (img != null && img.isNotEmpty)
                  ? Image.network(
                      img,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        color: const Color(0xFF222222),
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    )
                  : Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      color: const Color(0xFF222222),
                      child: const Icon(Icons.image, color: Colors.white70),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (fav) const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_up, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------

  Future<void> _submit() async {
    if (selectedDays.isEmpty) {
      Fluttertoast.showToast(msg: "Please select any day");
      return;
    }

    if (selectedCategory == null) {
      Fluttertoast.showToast(msg: "Please select a category");
      return;
    }

    final userId = await SecureStore.getUserId();
    final date = DateTime.now().toIso8601String().split('T')[0];

    // API reminder_id: create = 0, update = existing id
    final apiReminderId = widget.selectedReminder?['id'] ?? 0;

    final body = {
      "user_id": userId,
      "repeat": repeat,
      "start_at": "$date $startTime:00",
      "end_at": "$date $endTime:00",
      "playlist_id": selectedCategory!['id'], // ✅ send selected category
      "r_status": 1,
      "reminder_id": apiReminderId,
      for (final d in days) d['id']!: selectedDays.contains(d['id']) ? 1 : 0,
    };

    final response = await ApiService.postRequest(
      "/createReminder",
      body: body,
    );

    // get id from response
    final createdId =
        response.data?['data']?['id'] ?? response.data?['id'] ?? apiReminderId;

    if (createdId == 0 || createdId == null) {
      Fluttertoast.showToast(msg: "Saved, but ID missing for scheduling");
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    final int notifBaseId = int.parse(createdId.toString()) % 2147483647;

    try {
      await ReminderScheduler.cancelReminder(
        reminderId: notifBaseId,
        daysCount: 7,
        frequency: repeat,
      );

      await ReminderScheduler.scheduleReminder(
        reminderId: notifBaseId,
        title:
            selectedCategory!['categories_name'] ??
            "Affirmation", // ✅ dynamic title
        body: "Time for your affirmation",
        days: selectedDays.toList(),
        startTime: startTime,
        endTime: endTime,
        frequency: repeat,
        categoryId: int.parse(selectedCategory!['id'].toString()),
      );
    } catch (e) {
      debugPrint("NOTI ERROR: $e");
    }

    Fluttertoast.showToast(
      msg: widget.selectedReminder == null
          ? "Reminder Created!"
          : "Reminder Updated!",
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  // ---------------- UI ----------------

  @override
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.selectedReminder != null;
    final h = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        // ✅ keyboard open hone pe bhi overlap nahi hoga
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          height: h * 0.9,
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF191919),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Text(
                "Affirmations",
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const Divider(color: Color(0xFF333333)),

              // ✅ Body scrollable
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // Repeat box
                      Container(
                        padding: const EdgeInsets.all(48),
                        margin: const EdgeInsets.fromLTRB(15, 10, 10, 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _circleButton(Icons.remove, () {
                                  setState(
                                    () => repeat = repeat > 0 ? repeat - 1 : 30,
                                  );
                                }, size: 15),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Text(
                                    "$repeat X",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                                _circleButton(Icons.add, () {
                                  setState(
                                    () => repeat = repeat < 30 ? repeat + 1 : 0,
                                  );
                                }, size: 15),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Center(
                              child: Text(
                                "How May",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),
                      const Divider(color: Color(0xFF333333)),

                      // Start time
                      _timeRow(
                        "Start at",
                        startTime,
                        () => _updateTime(true, false),
                        () => _updateTime(true, true),
                      ),
                      const Divider(color: Color(0xFF333333)),

                      // End time
                      _timeRow(
                        "Finish at",
                        endTime,
                        () => _updateTime(false, false),
                        () => _updateTime(false, true),
                      ),

                      const Divider(color: Color(0xFF333333)),
                      const SizedBox(height: 12),

                      // Category section
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Category",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (loadingCategories)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        _selectedCategoryCard(),

                      const SizedBox(height: 14),
                      const Divider(color: Color(0xFF333333)),

                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Repeat",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: days.map((d) {
                          final active = selectedDays.contains(d['id']);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                active
                                    ? selectedDays.remove(d['id'])
                                    : selectedDays.add(d['id']!);
                              });
                            },
                            child: CircleAvatar(
                              radius: 22,
                              backgroundColor: active
                                  ? const Color(0xFFB72658)
                                  : Colors.white,
                              child: Text(
                                d['label']!,
                                style: TextStyle(
                                  color: active
                                      ? Colors.white
                                      : const Color(0xFFB72658),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // ✅ bottom button ke liye extra space so last items hide na ho
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),

              // ✅ fixed button (scroll se bahar)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                child: CustomButton(
                  title: isEdit ? "Update" : "Create",
                  height: 50,
                  width: 250,
                  onPress: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap, {double? size}) {
    final radius = size ?? 22;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.white,
        child: Icon(icon, size: radius, color: const Color(0xFFB72658)),
      ),
    );
  }

  Widget _timeRow(
    String label,
    String time,
    VoidCallback minus,
    VoidCallback plus,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Row(
            children: [
              _circleButton(Icons.remove, minus, size: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  time,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              _circleButton(Icons.add, plus, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------- CATEGORY PICKER SHEET W/ SEARCH --------------------

class _CategoryPickerSheet extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String? selectedId;

  const _CategoryPickerSheet({required this.items, required this.selectedId});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final TextEditingController _search = TextEditingController();
  late List<Map<String, dynamic>> filtered;

  @override
  void initState() {
    super.initState();
    filtered = List<Map<String, dynamic>>.from(widget.items);
    _search.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _search.removeListener(_applyFilter);
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        filtered = List<Map<String, dynamic>>.from(widget.items);
      } else {
        filtered = widget.items.where((e) {
          final name = (e['categories_name'] ?? '').toString().toLowerCase();
          return name.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFF333333),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Pick Category",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search category...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black,
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              _search.clear();
                              _applyFilter();
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF333333)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFB72658)),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: Color(0xFF2A2A2A), height: 1),

              // List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: Color(0xFF2A2A2A), height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    final id = item['id']?.toString();
                    final selected = id != null && id == widget.selectedId;

                    final image = item['caetgory_images']?.toString();
                    final name = item['categories_name']?.toString() ?? '';
                    final isFav = item['is_favorite'] == true;

                    return InkWell(
                      onTap: () => Navigator.pop(context, item),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF1F0A12)
                              : Colors.black,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFB72658)
                                : const Color(0xFF2A2A2A),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: (image != null && image.isNotEmpty)
                                  ? Image.network(
                                      image,
                                      width: 46,
                                      height: 46,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 46,
                                        height: 46,
                                        alignment: Alignment.center,
                                        color: const Color(0xFF222222),
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white70,
                                          size: 18,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 46,
                                      height: 46,
                                      alignment: Alignment.center,
                                      color: const Color(0xFF222222),
                                      child: const Icon(
                                        Icons.image,
                                        color: Colors.white70,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (isFav)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: Icon(Icons.favorite, color: Colors.red),
                              ),
                            Icon(
                              selected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: selected
                                  ? const Color(0xFFB72658)
                                  : Colors.white38,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
