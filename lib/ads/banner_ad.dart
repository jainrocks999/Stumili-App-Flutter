import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stumili/core/ads_unitkey.dart';

class BannerAdSection extends StatefulWidget {
  final double? height;
  const BannerAdSection({super.key, this.height});

  @override
  State<BannerAdSection> createState() => _BannerAdSectionState();
}

class _BannerAdSectionState extends State<BannerAdSection> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _loadBannerAd(double width) async {
    if (_bannerAd != null) return;
    final adSize =
        await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
          Orientation.portrait,
          width.truncate(),
        );

    if (adSize == null) {
      debugPrint('Failed to get adaptive banner size');
      return;
    }

    final banner = BannerAd(
      adUnitId: Platform.isIOS
          ? AdsUnitKey.bannerAdIdTest
          : AdsUnitKey.bannerAdId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;

          setState(() {
            _bannerAd = ad as BannerAd;
            _isLoaded = true;
          });

          debugPrint('Banner loaded: ${adSize.width}x${adSize.height}');
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();

          debugPrint('Banner ad failed: $error');
        },
      ),
    );

    await banner.load();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width <= 0) {
          return const SizedBox.shrink();
        }

        if (_bannerAd == null && !_isLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _loadBannerAd(width);
            }
          });
        }

        if (!_isLoaded || _bannerAd == null) {
          return const SizedBox.shrink();
        }

        return widget.height == null
            ? SizedBox.shrink()
            : SizedBox(
                height: widget.height,
                child: SizedBox(
                  width: width,
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              );
      },
    );
  }
}
