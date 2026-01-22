import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/widgets/auth/auth_background.dart';


class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  // ---------------- ACTIONS ----------------

  Future<void> _shareApp() async {
    await Share.share(
      'Check out the Innertune app! Download it now: '
      'https://play.google.com/store/apps/details?id=com.stumili',
    );
  }

  Future<void> _rateApp() async {
    final marketUri =
        Uri.parse('market://details?id=com.stumili');
    final webUri =
        Uri.parse('https://play.google.com/store/apps/details?id=com.stumili');

    if (await canLaunchUrl(marketUri)) {
      await launchUrl(marketUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: "Could not open link");
    }
  }

  Future<void> _logout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SecureStore.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (_) => false,
        );
      }
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      
      body: AuthBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle("Follow us"),
            _socialRow(),
        
            const SizedBox(height: 20),
            _settingTile(
              title: "Create reminders",
              icon: Icons.notifications,
              onTap: () => Navigator.pushNamed(context, 'reminder'),
            ),
            _settingTile(
              title: "Share Innertune app",
              icon: Icons.share,
              onTap: _shareApp,
            ),
            _settingTile(
              title: "Rate Innertune on Play Store",
              icon: Icons.star,
              onTap: _rateApp,
            ),
        
            const SizedBox(height: 30),
            _sectionTitle("Account"),
        
            _settingTile(
              title: "Manage subscription",
              icon: Icons.subscriptions,
              onTap: () => _openUrl(
                'https://play.google.com/store/account/subscriptions',
              ),
            ),
            _settingTile(
              title: "Sign out",
              icon: Icons.logout,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- REUSABLE WIDGETS ----------------

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _settingTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF4A4949),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Icon(icon, color: Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }

 Widget _socialRow() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(0, 4, 60, 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      
      children: [
        _socialIcon(
          imagePath: 'assets/social_logo/instagram.png',
          onTap: () => _openUrl('https://www.instagram.com/'),
        ),
        _socialIcon(
          imagePath: 'assets/social_logo/facebook.png',
          onTap: () => _openUrl('https://www.facebook.com/'),
          iconColor: Color(0xFF1877F2)
        ),
        _socialIcon(
          imagePath: 'assets/social_logo/social-media.png',
          onTap: () => _openUrl('https://www.twitter.com/'),
           iconColor: Color(0xFFB72658)
        ),
        _socialIcon(
          imagePath: 'assets/social_logo/youtube.png',
          onTap: () => _openUrl('https://www.youtube.com/'),
        ),
      ],
    ),
  );
}


Widget _socialIcon({
  required String imagePath,
  required VoidCallback onTap,
  Color? iconColor, // 👈 optional
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        // color: Color(0xFF4A4949),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(8),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        color: iconColor, // 👈 null hua to no tint
        colorBlendMode:
            iconColor != null ? BlendMode.srcIn : null,
      ),
    ),
  );
}

}
