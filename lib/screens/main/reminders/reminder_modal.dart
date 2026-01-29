import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stumili/core/secure_storage.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/custom_button.dart';

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
  }

  String _extractTime(String? value) {
    if (value == null) return "09:00";
    final t = value.split(' ')[1];
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
        endTime =
            "${h.toString().padLeft(2, '0')}:${((m + 30) % 60).toString().padLeft(2, '0')}";
      } else {
        endTime = val;
      }
    });
  }

  Future<void> _submit() async {
    if (selectedDays.isEmpty) {
      Fluttertoast.showToast(msg: "Please select any day");
      return;
    }

    final userId = await SecureStore.getUserId();
    final date = DateTime.now().toIso8601String().split('T')[0];

    final body = {
      "user_id": userId,
      "repeat": repeat,
      "start_at": "$date $startTime:00",
      "end_at": "$date $endTime:00",
      "r_status": 1,
      "reminder_id": widget.selectedReminder?['id'] ?? 0,
      for (final d in days) d['id']!: selectedDays.contains(d['id']) ? 1 : 0,
    };

    await ApiService.postRequest("/createReminder", body: body);

    Fluttertoast.showToast(
      msg: widget.selectedReminder == null
          ? "Reminder Created!"
          : "Reminder Updated!",
    );
    if (!mounted) {
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          const SizedBox(height: 16),
          Container(
            // color: Colors.black,
            padding: EdgeInsets.all(48),
            margin: EdgeInsets.fromLTRB(15, 10, 10, 15),
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
                      setState(() => repeat = repeat > 0 ? repeat - 1 : 30);
                    }, size: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "$repeat X",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    _circleButton(Icons.add, () {
                      setState(() => repeat = repeat < 30 ? repeat + 1 : 0);
                    }, size: 15),
                  ],
                ),
                SizedBox(height: 4),
                Center(
                  child: Text(
                    "How May",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Divider(color: Color(0xFF333333)),
          _timeRow(
            "Start at",
            startTime,
            () => _updateTime(true, false),
            () => _updateTime(true, true),
          ),
          const Divider(color: Color(0xFF333333)),
          _timeRow(
            "Finish at",
            endTime,
            () => _updateTime(false, false),
            () => _updateTime(false, true),
          ),
          const Divider(color: Color(0xFF333333)),
          const SizedBox(height: 15),

          Column(
            children: [
              Center(
                child: Text(
                  "Reapet",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 10,
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
            ],
          ),

          const Spacer(),

          /// Submit
          Padding(
            padding: const EdgeInsets.all(30),
            child: CustomButton(
              title: "Create",
              height: 50,
              width: 250,
              onPress: _submit,
            ),
          ),
        ],
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
        child: Icon(
          icon,
          size: radius, // icon auto scale
          color: const Color(0xFFB72658),
        ),
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
                child: Text(time, style: const TextStyle(color: Colors.white)),
              ),
              _circleButton(Icons.add, plus, size: 18),
            ],
          ),
        ],
      ),
    );
  }
}
