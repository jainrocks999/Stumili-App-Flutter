import 'package:flutter/material.dart';

class AffirmationMenuModal extends StatefulWidget {
  final List<Map<String, dynamic>> affirmations;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onSelect;

  const AffirmationMenuModal({
    super.key,
    required this.affirmations,
    required this.onClose,
    required this.onSelect,
  });

  @override
  State<AffirmationMenuModal> createState() => _AffirmationMenuModalState();
}

class _AffirmationMenuModalState extends State<AffirmationMenuModal> {
  late List<Map<String, dynamic>> _list;

  @override
  void initState() {
    super.initState();
    // Local copy for UI updates
    _list = List<Map<String, dynamic>>.from(widget.affirmations);
  }

  void _onSelectAffirmation(Map<String, dynamic> item) {
    widget.onSelect(item);

    // remove from modal list after select
    setState(() {
      _list.removeWhere((e) => e['id'] == item['id']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .9,
      decoration: const BoxDecoration(
        color: Color(0xFF191919),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // 🔹 drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Select Affirmation",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// LIST
          Expanded(
            child: _list.isEmpty
                ? const Center(
                    child: Text(
                      "No affirmations left",
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    itemCount: _list.length,
                    itemBuilder: (_, i) {
                      final item = _list[i];
                      final text = item['affirmation_text'].toString();
final displayText = text.length > 60 ? '${text.substring(0, 60)}...' : text;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A4949),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                               displayText,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  _onSelectAffirmation(item),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          /// BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB72658),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: widget.onClose,
              child: const Text(
                "Done",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
