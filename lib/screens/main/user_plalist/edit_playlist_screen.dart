import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/screens/main/user_plalist/affirmation_menu.dart';
import 'package:weather_app/services/api_service.dart';

class EditPlaylistScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final List affirmations;

  const EditPlaylistScreen({
    super.key,
    required this.item,
    required this.affirmations,
  });

  @override
  State<EditPlaylistScreen> createState() => _EditPlaylistScreenState();
}

class _EditPlaylistScreenState extends State<EditPlaylistScreen> {
  List<Map<String, dynamic>> selected = [];
  List<Map<String, dynamic>> allAffirmations = [];
  bool loading = false;
  bool showModal = false;

  @override
  void initState() {
    super.initState();
    selected = List<Map<String, dynamic>>.from(widget.affirmations);
  }

  /* ---------------------------- FETCH AFFIRMATIONS --------------------------- */

  Future<void> fetchAffirmations() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      if (token == null || userId == null) {
        Fluttertoast.showToast(msg: "User not authenticated");
        return;
      }

      final res = await ApiService.getRequest(
        "/affirmation",
        queryParameters: {"user_id": userId},
      );

      if (res.data == null || res.data['status'] != true) {
        Fluttertoast.showToast(msg: "Failed to fetch affirmations");
        return;
      }

      final List data = List.from(res.data['data'] ?? []);

      allAffirmations = data
          .where((a) => !selected.any((s) => s['id'] == a['id']))
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;

      openAffirmationModal();
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");

      Fluttertoast.showToast(
        msg: e.response?.data?['message'] ?? "Network error",
      );
    } catch (e) {
      debugPrint("fetchAffirmations error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> openAffirmationModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF191919),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return AffirmationMenuModal(
          affirmations: allAffirmations,
          onSelect: (item) {
            toggleAffirmation(item); // selected list me add
            Navigator.pop(context); // modal close
          },
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void toggleAffirmation(Map<String, dynamic> item) {
    final index = selected.indexWhere((e) => e['id'] == item['id']);

    setState(() {
      if (index == -1) {
        selected.add(item);
      } else {
        selected.removeAt(index);
      }
    });
  }

  Future<void> updatePlaylist() async {
    if (loading) return;

    setState(() => loading = true);

    try {
      final token = await SecureStore.getToken();
      final userId = await SecureStore.getUserId();

      final Map<String, dynamic> payload = {
        "user_id": userId,
        "playlist_id": widget.item['id'],
      };

      for (int i = 0; i < selected.length; i++) {
        payload["affirmation_text_id[$i]"] = selected[i]['id'];
      }
      await ApiService.postWithToken(
        "/deletePlayListItem",
        token: token,
        body: payload,
      );

      Fluttertoast.showToast(msg: "Playlist Updated");
      if (!mounted) {
        return;
      }
      Navigator.pop(context);
    } catch (e) {
      debugPrint("errrrrr$e");
      Fluttertoast.showToast(
        msg: "Error",
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    } finally {
      setState(() => loading = false);
    }
  }

  /* ----------------------------------- UI ----------------------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191919),
        title: const Text("Edit Playlist"),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              /// Playlist Card
              _playlistCard(),

              /// Add More
              _addMoreButton(),

              /// Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Added Affirmations",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      selected.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              /// Selected List
              Expanded(child: _selectedList()),
            ],
          ),

          /// Update Button
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB72658),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                ),
                onPressed: updatePlaylist,
                child: const Text("Update Playlist"),
              ),
            ),
          ),

          if (loading)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
        ],
      ),

      /// MODAL
    );
  }

  Widget _playlistCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A4949),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.queue_music, color: Color(0xFFB72658)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.item['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 16),
                  SizedBox(width: 6),
                  Text(
                    "Edit Name and info",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addMoreButton() {
    return GestureDetector(
      onTap: fetchAffirmations,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFFDEBA3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Add More Affirmations",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.add),
          ],
        ),
      ),
    );
  }

  Widget _selectedList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: selected.length,
      itemBuilder: (_, i) {
        final item = selected[i];
        String text = item['affirmation_text'].toString();
        String displayText = text.length > 40 ? text.substring(0, 40) : text;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4A4949),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  displayText,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => toggleAffirmation(item),
              ),
            ],
          ),
        );
      },
    );
  }
}
