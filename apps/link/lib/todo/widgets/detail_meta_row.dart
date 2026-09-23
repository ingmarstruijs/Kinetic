import 'package:flutter/material.dart';

/// A tappable information/action row in task and note detail sheets.
class DetailMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color? color;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? titleWidget;
  final bool leadingCheckbox;
  final bool checked;
  final ValueChanged<bool>? onCheckChanged;

  const DetailMetaRow({
    super.key,
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
    this.trailing,
    this.titleWidget,
    this.leadingCheckbox = false,
    this.checked = false,
    this.onCheckChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveColor = active
        ? (color ?? scheme.primary)
        : scheme.onSurfaceVariant;

    if (leadingCheckbox) {
      return ListTile(
        dense: true,
        leading: GestureDetector(
          onTap: () => onCheckChanged?.call(!checked),
          child: Icon(
            checked ? Icons.check_box : Icons.check_box_outline_blank,
            size: 20,
            color: effectiveColor,
          ),
        ),
        title:
            titleWidget ??
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: effectiveColor),
            ),
        trailing: trailing,
        onTap: checked ? onTap : () => onCheckChanged?.call(true),
      );
    }

    return ListTile(
      dense: true,
      leading: Icon(icon, size: 20, color: effectiveColor),
      title:
          titleWidget ??
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: effectiveColor),
          ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
