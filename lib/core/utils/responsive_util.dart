import 'package:flutter/material.dart';

class ResponsiveUtil {
  static const double tabletBreakpoint = 600.0;
  static const double maxContentWidth = 600.0;
  static const double maxProfileContentWidth = 800.0;

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static int getCrossAxisCount(BuildContext context, {int mobile = 2, int tablet = 4}) {
    return isTablet(context) ? tablet : mobile;
  }

  /// Wraps a widget in a constrained box centered on the screen.
  /// Ideal for forms and single-column lists on tablets.
  static Widget buildConstrained(BuildContext context, Widget child, {double? maxWidth}) {
    if (!isTablet(context)) return child;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? maxContentWidth),
        child: child,
      ),
    );
  }
}
