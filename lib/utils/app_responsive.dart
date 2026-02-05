import 'package:flutter/material.dart';

class AppResponsive {
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
