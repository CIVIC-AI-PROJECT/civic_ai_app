import 'dart:math' as math;

import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 640;
  static const double tabletBreakpoint = 1024;
  static const double maxContentWidth = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.sizeOf(context).width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= tabletBreakpoint;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint) {
      return math.min(40, width * 0.06);
    }
    if (width >= mobileBreakpoint) {
      return 24;
    }
    return 16;
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final gutter = horizontalPadding(context) * 2;
    return math.min(maxContentWidth, width - gutter);
  }
}
