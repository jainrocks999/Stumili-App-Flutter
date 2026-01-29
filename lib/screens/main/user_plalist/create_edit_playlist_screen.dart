import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/custom_button.dart';

class SavePlaylistScreen extends StatefulWidget {
  final bool isEdit;
  final Map<String, dynamic>? editedItem;
  final List<int> selectedIds;

  const SavePlaylistScreen({
    super.key,
    required this.isEdit,
    this.editedItem,
    required this.selectedIds,
  });

  @override
  State<SavePlaylistScreen> createState() => _SavePlaylistScreenState();
}

class _SavePlaylistScreenState extends State<SavePlaylistScreen> {
  final TextEditingController playlistController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  bool loading = false;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.editedItem != null) {
      playlistController.text = widget.editedItem!['title'] ?? '';
      descriptionController.text = widget.editedItem!['description'] ?? '';
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  bool validateForm() {
    if (playlistController.text.trim().isEmpty) {
      showError("Playlist name is required");
      return false;
    }

    if (!widget.isEdit && widget.selectedIds.isEmpty) {
      showError("Please select at least one affirmation");
      return false;
    }

    return true;
  }

  Future<void> handleSubmit() async {
    if (!validateForm()) return;
    setState(() => loading = true);

    try {
      final userId = await SecureStore.getUserId();
      final payload = {
        "title": playlistController.text.trim(),
        "description": descriptionController.text.trim(),
        "user_id": userId,
      };

     late final Response playlistResponse;

      if (!widget.isEdit) {
        playlistResponse = await ApiService.postRequest(
          "/createPlayList",
          body: payload,
        );
      } else {
        payload["playlist_id"] = widget.editedItem!['id'].toString();
        playlistResponse = await ApiService.postRequest(
          "/updatePlayList",
          body: payload,
        );
      }

      if (!mounted) return;

      final int playlistId = playlistResponse.data['data']['id'];
      final selectedIds = widget.selectedIds;

      if (selectedIds.isNotEmpty&&!widget.isEdit) {
        await ApiService.postRequest(
          "/createPlayListItem",
          body: {"playlist_id": playlistId.toString(), "affirmation_text_id": selectedIds},
          contentType: "application/json",
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar( const SnackBar(
          content: Text("Playlist created successfully"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/main-tabs",
        (route) => false,
        arguments: 1,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint("plaslisirtiititit$e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF191919),
      appBar: AppBar(
        backgroundColor: const Color(0xFF191919),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Save your Playlist",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Image Picker
                  GestureDetector(
                    onTap: pickImage,
                    child: Container(
                      height: 220,
                      width: 220,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB72658),
                        borderRadius: BorderRadius.circular(20),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.upload,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Upload File",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Inputs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "My Playlist",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: playlistController,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("Name"),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Add Description",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: inputDecoration("Description"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: CustomButton(
                      title: widget.isEdit ? "Update" : "Create",
                      height: 50,

                      onPress: handleSubmit,
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF4A4949),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
