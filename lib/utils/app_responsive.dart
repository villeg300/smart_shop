import 'package:flutter/material.dart';

class AppResponsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopWideBreakpoint = 1400;

  static double screenWidth(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.sizeOf(context).height;
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = screenWidth(context);
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= tabletBreakpoint;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = screenWidth(context);
    if (width >= desktopWideBreakpoint) {
      return 1280;
    }
    if (width >= tabletBreakpoint) {
      return 1120;
    }
    if (width >= mobileBreakpoint) {
      return 900;
    }
    return double.infinity;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final width = screenWidth(context);
    final horizontal = width >= tabletBreakpoint
        ? 32.0
        : width >= mobileBreakpoint
            ? 24.0
            : 16.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 16);
  }

  static double sectionSpacing(BuildContext context) {
    return isMobile(context) ? 16 : 24;
  }

  static double itemSpacing(BuildContext context) {
    return isMobile(context) ? 12 : 16;
  }

  static int gridCrossAxisCount(BuildContext context) {
    final width = screenWidth(context);
    if (width >= desktopWideBreakpoint) {
      return 5;
    }
    if (width >= tabletBreakpoint) {
      return 4;
    }
    if (width >= mobileBreakpoint) {
      return 3;
    }
    return 2;
  }

  static double gridSpacing(BuildContext context) {
    return isMobile(context) ? 12 : 16;
  }

  static double authMaxWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= 900) {
      return 520;
    }
    if (width >= 600) {
      return 480;
    }
    return double.infinity;
  }

  static EdgeInsets authPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 600 ? 32.0 : 24.0;
    return EdgeInsets.fromLTRB(horizontal, 24, horizontal, 24);
  }

  static Widget authBody({
    required BuildContext context,
    required Widget child,
  }) {
    final maxWidth = authMaxWidth(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
