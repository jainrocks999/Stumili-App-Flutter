import 'package:flutter/material.dart';
import 'package:stumili/widgets/home/horizontal.dart';

class GroupsSection extends StatelessWidget {
  final List groups;
  final bool loading;
    final Function(dynamic item) onPress;

  const GroupsSection({
    super.key,
    required this.groups,
    required this.loading,
    required this.onPress
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(groups.length, (index) {
        final item = groups[index];
        final List categories = item['categories'] ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

   
           if (categories.isNotEmpty) ...[
             
           

          
              HorizontalSection(
                heading: item['group_name'],
                data: item['categories'],
                onPress: (category) {
                  onPress(category);
                },
             
              ),
              const SizedBox(height: 24),
            ],

            // /// ✅ PROMO CARDS AT INDEX == 1
            // if (index == 1) const PromoRow(),
          ],
        );
      }),
    );
  }
}
