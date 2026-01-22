import 'package:flutter/material.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/screens/main/user_plalist/edit_selected_affrimations.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/custom_button.dart';

class SelectAffirmationScreen extends StatefulWidget {
  const SelectAffirmationScreen({super.key});

  @override
  State<SelectAffirmationScreen> createState() =>
      _SelectAffirmationScreenState();
}

class _SelectAffirmationScreenState extends State<SelectAffirmationScreen> {
  bool loading = false;
  List<Map<String, dynamic>> affirmations = [];
  List<int> selectedIds = [];

  @override
  void initState() {
    super.initState();
    fetchAffirmations();
  }

  Future<void> fetchAffirmations() async {
    setState(() => loading = true);

    final userId = await SecureStore.getUserId();
    final response = await ApiService.getRequest(
      "/affirmation",
      queryParameters: {"user_id": userId},
    );
    final data = response.data["data"];
    setState(() {
      affirmations = List<Map<String, dynamic>>.from(data);
    });
    setState(() => loading = false);
  }

  void handleSelected(int id) {
    setState(() {
      selectedIds.contains(id) ? selectedIds.remove(id) : selectedIds.add(id);
    });
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
          'Create Your Playlist',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: affirmations.length,
                    itemBuilder: (context, index) {
                      final item = affirmations[index];
                      final int id = item['id'];

                      return Container(
                        height: 65,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4949),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['affirmation_text'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                selectedIds.contains(id)
                                    ? Icons.remove_circle_outline
                                    : Icons.add_circle_outline,
                                color: selectedIds.contains(id)
                                    ? Colors.red
                                    : Colors.white,
                              ),
                              onPressed: () => handleSelected(id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Button
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,

                    child: CustomButton(
                      title: "Added Affirmations ${selectedIds.length}",
                      height: 50,
                      onPress: () {
                        final List<int> idsToSend = List.from(selectedIds);
                        setState(() {
                          selectedIds.clear();
                        });

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreatePlaylistScreen(
                              affirmations: affirmations,
                              selectedIds: idsToSend,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
