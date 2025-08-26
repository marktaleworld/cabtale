import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/maintainance_mode/maintainance_screen.dart';
import 'package:ride_sharing_user_app/features/onboard/screens/onboarding_screen.dart';
import 'package:ride_sharing_user_app/features/trip/controllers/trip_controller.dart';
import 'package:ride_sharing_user_app/helper/firebase_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/auth/screens/sign_in_screen.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/access_location_screen.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/profile/screens/edit_profile_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:app_links/app_links.dart';
import 'package:video_player/video_player.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  StreamSubscription? _sub;

  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _videoDone = false;
  bool _routeRequested = false;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    Get.find<ConfigController>().initSharedData();
    _checkConnectivity();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.asset('assets/animation/cabtale_splash.mp4');
    try {
      await _videoCtrl!.initialize();
      _videoCtrl!.setLooping(false);
      setState(() => _videoReady = true);
      _videoCtrl!.play();

      _videoCtrl!.addListener(() {
        if (_videoCtrl!.value.isInitialized &&
            !_videoCtrl!.value.isPlaying &&
            (_videoCtrl!.value.position >= _videoCtrl!.value.duration)) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });

      Future.delayed(const Duration(seconds: 7), () {
        if (!_videoDone) {
          _videoDone = true;
          _tryNavigateAfterVideo();
        }
      });
    } catch (_) {
      _videoDone = true;
      _tryNavigateAfterVideo();
    }
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _onConnectivityChanged?.cancel();
    _sub?.cancel();
    super.dispose();
  }

  void _checkConnectivity() {
    bool isFirst = true;
    _onConnectivityChanged = Connectivity().onConnectivityChanged.listen((result) {
      final isConnected = result.contains(ConnectivityResult.wifi) || result.contains(ConnectivityResult.mobile);
      if (!isFirst || !isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6),
          content: Text(isConnected ? 'connected'.tr : 'no_connection'.tr, textAlign: TextAlign.center),
        ));
        if (isConnected) _handleIncomingLinks();
      } else {
        _handleIncomingLinks();
      }
      isFirst = false;
    });
  }

  void _handleIncomingLinks() {
    Get.find<TripController>().getRideCancellationReasonList();
    Get.find<TripController>().getParcelCancellationReasonList();
    FirebaseHelper().subscribeFirebaseTopic();

    Get.find<ConfigController>().getConfigData().then((_) async {
      final Uri? initial = await _appLinks.getInitialLink();
      if (initial != null) {
        _handleUri(initial);
      } else {
        _route();
        if (GetPlatform.isIOS) {
          _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
            if (uri != null) _handleUri(uri);
          });
        }
      }
    });
  }

  void _handleUri(Uri uri) {
    final phone = uri.queryParameters['phone'];
    final pass = uri.queryParameters['password'];
    final code = uri.queryParameters['country_code'];

    if (Get.find<AuthController>().getUserToken().isNotEmpty) {
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if (Get.find<ProfileController>().profileModel?.data?.phone == '+${code!.trim()}$phone') {
            _route();
          } else {
            Get.find<AuthController>().externalLogin('+${code!.trim()}', phone!, pass!);
            _route();
          }
        }
      });
    } else {
      Get.find<AuthController>().externalLogin('+${code!.trim()}', phone!, pass!);
      _route();
    }
  }

  void _route() {
    _routeRequested = true;
    _tryNavigateAfterVideo();
  }

  void _tryNavigateAfterVideo() {
    if (_hasNavigated || !_routeRequested || !_videoDone) return;
    _hasNavigated = true;

    if (Get.find<AuthController>().getUserToken().isNotEmpty) {
      PusherHelper.initilizePusher();
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      if (Get.find<AuthController>().isLoggedIn()) {
        _forLoginUserRoute();
      } else {
        _forNotLoginUserRoute();
      }
    });
  }

  void _forNotLoginUserRoute() {
    final cfg = Get.find<ConfigController>().config;
    if (cfg?.maintenanceMode != null &&
        cfg!.maintenanceMode!.maintenanceStatus == 1 &&
        cfg.maintenanceMode!.selectedMaintenanceSystem!.userApp == 1) {
      Get.offAll(() => const MaintenanceScreen());
    } else if (Get.find<ConfigController>().showIntro()) {
      Get.offAll(() => const OnBoardingScreen());
    } else {
      Get.offAll(() => const SignInScreen());
    }
  }

  void _forLoginUserRoute() {
    final loc = Get.find<LocationController>().getUserAddress();
    if (loc != null && loc.address != null && loc.address!.isNotEmpty) {
      Get.find<ProfileController>().getProfileInfo().then((value) {
        if (value.statusCode == 200) {
          Get.find<AuthController>().updateToken();
          if (value.body['data']['is_profile_verified'] == 1) {
            Get.find<AuthController>().remainingFindingRideTime();
            Get.offAll(() => const DashboardScreen());
          } else {
            Get.offAll(() => const EditProfileScreen(fromLogin: true));
          }
        }
      });
    } else {
      Get.offAll(() => const AccessLocationScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = Get.isDarkMode ? const Color(0xFF000000) : Theme.of(context).primaryColorDark;
    return Scaffold(
      body: Container(
        color: bg,
        width: double.infinity,
        height: double.infinity,
        child: _videoReady && _videoCtrl != null
            ? FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoCtrl!.value.size.width,
                  height: _videoCtrl!.value.size.height,
                  child: VideoPlayer(_videoCtrl!),
                ),
              )
            : const SizedBox.expand(),
      ),
    );
  }
}
