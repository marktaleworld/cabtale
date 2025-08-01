 import 'package:flutter/material.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';

ThemeData lightTheme({Color color = AppConstants.lightPrimary}) => ThemeData(
  fontFamily: AppConstants.fontFamily,
  primaryColor: color,
  primaryColorDark: const Color(0xFF09331E),
  disabledColor: const Color(0xFFBABFC4),
  dialogBackgroundColor: const Color(0xFFF5F2E5),
  scaffoldBackgroundColor: const Color(0xFF08351F),
  shadowColor: Colors.black.withOpacity(0.03),
  textTheme:  const TextTheme(
    bodyMedium: TextStyle(color: Color(0xff1D2D2B)),
    bodySmall: TextStyle(color: Color(0xff6B7675)),
    bodyLarge: TextStyle(color: Color(0xff48615E)),
    titleMedium: TextStyle(color: Color(0xff1D2D2B)),
  ),

  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  ),

  brightness: Brightness.light,
  hintColor: const Color(0xFF9F9F9F),
  cardColor: const Color(0xFFF5F2E5),
  colorScheme: const ColorScheme.light(
      primary: Color(0xFF1C1C1C),
      //  secondary: Color(0xFF008C7B),
      error: Color(0xFFFF6767),
      surface: Color(0xFFF5F2E5),
      tertiary: Color(0xFF1B5939),
      tertiaryContainer: Color(0xFFC98B3E),
      secondaryContainer: Color(0xFFEE6464),
      onTertiary: Color(0xFFD9D9D9),
      onSecondary: Color(0xFF00FEE1),
      onSecondaryContainer: Color(0xFFA8C5C1),
      onTertiaryContainer: Color(0xFF425956),
      outline: Color(0xFF8CFFF1),
      onPrimaryContainer: Color(0xFFDEFFFB),
      primaryContainer: Color(0xFFFFA800),
      onErrorContainer: Color(0xFFFFE6AD),
      onPrimary: Color(0xFF14B19E),
      surfaceTint: Color(0xFF1B5939),
      errorContainer: Color(0xFFF6F6F6),
      inverseSurface: Color(0xFF0148AF),
      surfaceContainer: Color(0xFF0094FF),
      secondaryFixedDim: Color(0xff808080),
  ),
  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: color)),
);
