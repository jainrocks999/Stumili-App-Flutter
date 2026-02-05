import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stumili/core/app_colors.dart';
import 'package:stumili/core/fonts.dart';
import 'package:stumili/core/secure_storage.dart';
import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/main/player/mini_player_bar.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/home/groups_section.dart';
import 'package:stumili/widgets/home/header.dart';
import 'package:stumili/widgets/home/horizontal.dart';
import 'package:stumili/widgets/home/search_modal.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LastSessionModel> lastSessions = [];
  List popularPlayList = [];
  List groups = [];
  List categories = [];
  int _apiCallCount = 0;
  bool loading = false;
  bool showSearch = false;
  void startApi() {
    _apiCallCount++;
    if (!loading) {
      setState(() => loading = true);
    }
  }

  void endApi() {
    _apiCallCount--;
    if (_apiCallCount <= 0) {
      _apiCallCount = 0;
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    loadLastSessions();
    looadJustForYou();
    looadGroups();
    loadCategories();
  }

  void looadJustForYou() async {
    startApi();
    final userId = await SecureStore.getUserId();
    try {
      final response = await ApiService.getRequest(
        '/playList/populerPlayList',
        queryParameters: {'user_id': userId},
      );
      final data = response.data['data'];
      setState(() {
        popularPlayList = data;
      });
    } finally {
      endApi();
    }
  }

  void looadGroups() async {
    startApi();
    final userId = await SecureStore.getUserId();
    try {
      final response = await ApiService.getRequest(
        '/groups',
        queryParameters: {'user_id': userId},
      );
      final data = response.data['data'];
      setState(() {
        groups = data;
      });
    } finally {
      endApi();
    }
  }

  void loadCategories() async {
    startApi();
    final userId = await SecureStore.getUserId();
    try {
      final response = await ApiService.getRequest(
        '/categories',
        queryParameters: {'user_id': userId},
      );
      final data = response.data['data'];
      debugPrint("thtititi$data");
      setState(() {
        categories = data;
      });
    } finally {
      endApi();
    }
  }

  void loadLastSessions() async {
    try {
      startApi();
      final userId = await SecureStore.getUserId();
      if (userId != null) {
        final data = await fetchLastSessions(userId); // user_id here
        setState(() {
          lastSessions = data;
        });
      }
    } finally {
      endApi();
    }
  }

  void _onSearchPress() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => SearchModal(
        visible: true,
        onClose: () => Navigator.pop(context),
        onCategories: (data) => affirmationByCategory(data),
      ),
    );
  }

  void showLoader(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void hideLoader(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void affirmationByCategory(dynamic item) async {
    final userId = await SecureStore.getUserId();
    final token = await SecureStore.getToken();
    if (!mounted) {
      return;
    }
    showLoader(context);
    try {
      final response = await ApiService.getRequest(
        "/categoryByAffermation",
        queryParameters: {
          "user_id": userId,
          "token": token,
          "category_id": item["id"],
        },
      );
      final data = response.data['data'];
      if (!mounted) return;
      hideLoader(context);
        if (data == null || (data is List && data.isEmpty)) {
      Fluttertoast.showToast(
        msg: "Affirmation not available in this category",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
      Navigator.pushNamed(
        context,
        AppRoutes.playlistdailts,
        arguments: {"affirmation": data, "category": item},
      );
    } catch (err) {
      hideLoader(context);
      debugPrint("fetching affrimation erroor $err");
    } finally {
      // hideLoader(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: MiniPlayerBar(
        onTapOpenPlayer: () {
          Navigator.pushNamed(context, AppRoutes.player);
        },
      ),
      body: SafeArea(
        child: Column(
          children: [
            Header(onPressSearch: _onSearchPress),

            /// BODY (Scrollable)
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        /// 🔹 HEADING
                        const Text(
                          'Last Sessions',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: AppFonts.medium,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// 🔹 GRID SECTION
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lastSessions.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 2.5,
                              ),
                          itemBuilder: (context, index) {
                            final item = lastSessions[index];
                            return GestureDetector(
                              onTap: () {
                                final originalData = item.originalData;
                                affirmationByCategory(originalData);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4A4949),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        item.image,
                                        height: 60,
                                        width: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item.categoryName,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.white,
                                          fontFamily: AppFonts.medium,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 24),

                        HorizontalSection(
                          heading: "Rocommended For You",
                          data: popularPlayList,
                          onPress: affirmationByCategory,
                        ),

                        HorizontalSection(
                          heading: "Popular Playlist",
                          data: categories,
                          onPress: affirmationByCategory,
                        ),
                        const SizedBox(height: 24),
                        GroupsSection(
                          groups: groups,
                          loading: loading,
                          onPress: affirmationByCategory,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class LastSessionModel {
  final String id;
  final String categoryName;
  final String image; // random image for UI
  final String imgTitle; // random title for UI
  final Map<String, dynamic> originalData; // original API item

  LastSessionModel({
    required this.id,
    required this.categoryName,
    required this.image,
    required this.imgTitle,
    required this.originalData,
  });

  factory LastSessionModel.fromJson(
    Map<String, dynamic> json,
    String image,
    String imgTitle,
  ) {
    return LastSessionModel(
      id: json['id'].toString(),
      categoryName: json['categories_name'],
      image: image,
      imgTitle: imgTitle,
      originalData: json, // 🔹 store original API item
    );
  }
}

Future<List<LastSessionModel>> fetchLastSessions(String userId) async {
  final response = await ApiService.getRequest(
    '/playList/LastSession',
    queryParameters: {'user_id': userId},
  );

  final List data = response.data['data'];
  final random = Random();

  return data.map((item) {
    final randomImg = imgList[random.nextInt(imgList.length)];

    return LastSessionModel.fromJson(
      item,
      randomImg['image']!,
      randomImg['title']!,
    );
  }).toList();
}

const List<Map<String, String>> imgList = [
  {
    'image': 'assets/profilepic/profile1.jpg',
    'title': 'Control Stress and Anxiety',
  },
  {'image': 'assets/profilepic/profile2.jpg', 'title': 'Be a Better Friend'},
  {'image': 'assets/profilepic/profile3.jpg', 'title': 'Liked affirmations'},
  {'image': 'assets/profilepic/profile4.jpg', 'title': 'Billionaire Mindset'},
  {'image': 'assets/profilepic/profile5.jpg', 'title': 'Manifest Wealth'},
  {
    'image': 'assets/profilepic/profile6.jpg',
    'title': 'Awaken Your Money Power',
  },
];
