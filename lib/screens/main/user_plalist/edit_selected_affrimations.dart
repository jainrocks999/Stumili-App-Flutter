import 'package:flutter/material.dart';
import 'package:stumili/screens/main/user_plalist/create_edit_playlist_screen.dart';
import 'package:stumili/widgets/custom_button.dart';

class CreatePlaylistScreen extends StatefulWidget {
  final List<Map<String, dynamic>> affirmations;
  final List<int> selectedIds;

  const CreatePlaylistScreen({
    super.key,
    required this.affirmations,
    required this.selectedIds,
  });

  @override
  State<CreatePlaylistScreen> createState() => _CreatePlaylistScreenState();
}

class _CreatePlaylistScreenState extends State<CreatePlaylistScreen> {
  late List<int> selected;

  @override
  void initState() {
    super.initState();
    selected = List.from(widget.selectedIds);
  }

  List<Map<String, dynamic>> filterSelected() {
    return widget.affirmations
        .where((item) => selected.contains(item['id']))
        .toList();
  }

  void deselectItem(int id) {
    setState(() {
      selected.remove(id);
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
          'Edit List of Affirmation',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 16),
              itemCount: filterSelected().length,
              itemBuilder: (context, index) {
                final item = filterSelected()[index];

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
                          selected.contains(item['id'])
                              ? Icons.remove_circle_outline
                              : Icons.add_circle_outline,
                          color: selected.contains(item['id'])
                              ? Colors.red
                              : Colors.white,
                          size: 26,
                        ),
                        onPressed: () => deselectItem(item['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Button
          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.6,

              child: CustomButton(
                title: "Next",
                onPress: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SavePlaylistScreen(
                        isEdit: false,
                        selectedIds: selected,
                      ),
                    ),
                  );
                },
                height: 50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
