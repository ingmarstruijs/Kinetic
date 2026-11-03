import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Bottom inset for modal sheets and sticky footers.
///
/// [showModalBottomSheet] with `useSafeArea: true` wraps content in
/// `SafeArea(bottom: false)`, so the sheet still draws under the system
/// navigation bar. Pad with the larger of keyboard ([MediaQuery.viewInsets])
/// and system bottom ([MediaQuery.viewPadding] / [MediaQuery.padding]).
double bottomSystemInset(BuildContext context) {
  final data = MediaQuery.of(context);
  final systemBottom = math.max(data.viewPadding.bottom, data.padding.bottom);
  return math.max(data.viewInsets.bottom, systemBottom);
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
