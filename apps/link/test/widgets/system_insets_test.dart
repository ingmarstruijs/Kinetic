import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:link/widgets/system_insets.dart';

void main() {
  testWidgets('pads with viewPadding when padding is also set', (tester) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(bottom: 48),
          viewPadding: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            inset = bottomSystemInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(inset, 48);
  });

  testWidgets('pads with viewPadding when padding.bottom is 0 (edge-to-edge)', (
    tester,
  ) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.only(bottom: 48),
        ),
        child: Builder(
          builder: (context) {
            inset = bottomSystemInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(inset, 48);
  });

  testWidgets('prefers keyboard when larger than system bottom', (tester) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.only(bottom: 48),
          viewInsets: EdgeInsets.only(bottom: 300),
        ),
        child: Builder(
          builder: (context) {
            inset = bottomSystemInset(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    expect(inset, 300);
  });
}
