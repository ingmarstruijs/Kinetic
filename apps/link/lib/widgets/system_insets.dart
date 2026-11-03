import 'package:flutter/widgets.dart';

/// Bottom inset for modal sheets and sticky footers.
///
/// Combines the keyboard ([MediaQuery.viewInsets]) with any system navigation
/// bar not already reflected in [MediaQuery.padding] (typical on Android
/// edge-to-edge with 3-button navigation, where padding.bottom is 0).
double bottomSystemInset(BuildContext context) {
  final data = MediaQuery.of(context);
  final uncovered = data.viewPadding.bottom - data.padding.bottom;
  return data.viewInsets.bottom + (uncovered > 0 ? uncovered : 0.0);
}

/// Pads [child] so bottom actions clear the system navigation bar.
class BottomSystemInset extends StatelessWidget {
  const BottomSystemInset({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSystemInset(context)),
      child: child,
    );
  }
}
