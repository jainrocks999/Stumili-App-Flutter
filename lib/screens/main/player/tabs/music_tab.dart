// =============================
// lib/screens/main/player/tabs/music_tab.dart
// =============================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../player_controller.dart';

class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<PlayerController>();

    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'Background Music',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),

        // Categories
        SizedBox(
          height: 60,
          child: c.bgLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: c.bgCategories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (_, i) {
                    final cat = c.bgCategories[i];
                    final active = c.selectedBgCategoryId == cat.id;

                    return GestureDetector(
                      onTap: () => c.selectBgCategory(cat.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFD485D1) : const Color(0xFFDEDEDE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            cat.name,
                            style: TextStyle(color: active ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        const SizedBox(height: 10),

        // Sounds grid
        Expanded(
          child: c.bgLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: c.bgSounds.length,
                  itemBuilder: (_, i) {
                    final s = c.bgSounds[i];
                    return GestureDetector(
                      onTap: () => c.playBgSound(s),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                s.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.white10,
                                  child: const Center(
                                    child: Icon(Icons.music_note, color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            s.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Volume panel
        Container(
          height: 110,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF4A4949),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 14),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Background Volume',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Slider(
                value: c.bgVolume,
                min: 0,
                max: 1,
                onChanged: c.setBgVolume,
                activeColor: Colors.white,
                inactiveColor: Colors.white24,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
