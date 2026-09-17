import 'package:flutter/material.dart';

/// Kinetic Kids logo for headers — same art as the Android launcher.
class KineticLogoKids extends StatelessWidget {
  final double size;
  final Color? color;

  const KineticLogoKids({super.key, this.size = 28, this.color});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset(
        'assets/icons/app_icon.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// App header: logo + Kinetic brand (no subtitle).
class AppHeaderKids extends StatelessWidget {
  final List<Widget>? actions;
  final Widget? leading;

  const AppHeaderKids({
    super.key,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 4),
        const KineticLogoKids(size: 28),
        const SizedBox(width: 12),
        Text(
          'Kinetic',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
