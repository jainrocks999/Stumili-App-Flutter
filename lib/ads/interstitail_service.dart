import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:stumili/core/ads_unitkey.dart';

class InterstitailService {
  InterstitialAd? _interstitialAd;
  bool _isLoading = false;
  VoidCallback? _pendingCallback;

  void loadAd() {
    if (_isLoading || _interstitialAd != null) {
      return;
    }

    _isLoading = true;

    InterstitialAd.load(
      adUnitId: Platform.isIOS
          ? AdsUnitKey.interstitalAdIdTest
          : AdsUnitKey.interstitalAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _isLoading = false;
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _interstitialAd = null;

              final callback = _pendingCallback;
              _pendingCallback = null;

              loadAd();
              callback?.call();
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              debugPrint('Interstitial: failed to show: $err');
              ad.dispose();
              _interstitialAd = null;
              final callback = _pendingCallback;
              _pendingCallback = null;

              loadAd();
              callback?.call();
            },
          );

          if (_pendingCallback != null) {
            final callback = _pendingCallback;
            _pendingCallback = null;

            _showLoadedAd(callback);
          }
        },
        onAdFailedToLoad: (err) {
          _isLoading = false;
          _interstitialAd = null;
          debugPrint('Interstitial failed to load: $err');

          final callback = _pendingCallback;
          _pendingCallback = null;
          callback?.call();
        },
      ),
    );
  }

  void showAd({VoidCallback? onAdDismissed}) {
    if (_interstitialAd != null) {
      _showLoadedAd(onAdDismissed);
      return;
    }
    _pendingCallback = onAdDismissed;
    loadAd();
  }

  void _showLoadedAd(VoidCallback? callback) {
    final ad = _interstitialAd;

    if (ad == null) {
      callback?.call();
      return;
    }
    _interstitialAd = null;
    _pendingCallback = callback;
    ad.show();
  }

  void dispose() {
    _pendingCallback = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
  }
}
