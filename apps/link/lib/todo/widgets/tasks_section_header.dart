import 'package:flutter/material.dart';

/// Shared chrome for Suggestions / Kids (and similar) sections on Tasks.
class TasksSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;
  final bool expanded;
  final VoidCallback onToggle;
  final String? subtitle;
  final Widget? trailing;

  const TasksSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.expanded,
    required this.onToggle,
    this.count,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      if (count != null) ...[
                        const SizedBox(width: 8),
                        _SectionCountBadge(count: count!),
                      ],
                    ],
                  ),
                  if (subtitle != null && expanded) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: scheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCountBadge extends StatelessWidget {
  final int count;
  const _SectionCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE53935),
        shape: BoxShape.circle,
      ),
      child: Text(
        count > 9 ? '9+' : '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
