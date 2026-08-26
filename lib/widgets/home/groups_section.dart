import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stumili/ads/banner_ad.dart';
import 'package:stumili/widgets/home/horizontal.dart';

class GroupsSection extends StatelessWidget {
  final List groups;
  final bool loading;
  final Function(dynamic item) onPress;

  const GroupsSection({
    super.key,
    required this.groups,
    required this.loading,
    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    final filteredGroups = groups.where((item) {
      final categories = item['categories'];
      return categories != null && categories.isNotEmpty;
    }).toList();
    return Column(
      children: List.generate(filteredGroups.length, (index) {
        final item = filteredGroups[index];
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
              // const SizedBox(height: 24),
              if (index % 3 == 0)
                BannerAdSection(
                  height:
                      MediaQuery.of(context).size.width *
                      (Platform.isIOS ? 0.15 : 0.15),
                ),
                SizedBox(height: 15)
            ],

            // /// ✅ PROMO CARDS AT INDEX == 1
            // if (index == 1) const PromoRow(),
          ],
        );
      }),
    );
  }
}
