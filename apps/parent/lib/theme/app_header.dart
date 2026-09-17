import 'package:flutter/material.dart';

import '../main.dart';
import 'app_themes.dart';

/// Kinetic Link logo for headers — same art as the Android launcher.
///
/// Light (default) keeps the original blue asset. Calm/Night tint with
/// [ColorScheme.primary] so the white "K" stays light ([BlendMode.color]).
class KineticLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const KineticLogo({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/icons/app_icon.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
    );

    final tint =
        color ??
        (themeNotifier.value == AppTheme.light
            ? null
            : Theme.of(context).colorScheme.primary);

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: tint == null
          ? image
          : ColorFiltered(
              colorFilter: ColorFilter.mode(tint, BlendMode.color),
              child: image,
            ),
    );
  }
}

/// Logo + title row for use as an [AppBar.title].
class AppHeader extends StatelessWidget {
  final String title;
  final bool centerTitle;
  final List<Widget>? actions;
  final Widget? leading;

  const AppHeader({
    super.key,
    required this.title,
    this.centerTitle = false,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: centerTitle ? MainAxisSize.min : MainAxisSize.max,
      children: [
        KineticLogo(size: 28),
        const SizedBox(width: 10),
        Flexible(
          child: Text(title, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
