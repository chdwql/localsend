import 'package:flutter/material.dart';

/// A modern grouped card container inspired by FlClash / iOS 18 design.
/// Wraps multiple list items into a single rounded island with dividers.
class FlClashGroupedCard extends StatelessWidget {
  final String? title;
  final Widget? trailingTitle;
  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  const FlClashGroupedCard({
    required this.children,
    this.title,
    this.trailingTitle,
    this.padding = EdgeInsets.zero,
    this.margin = const EdgeInsets.only(bottom: 18),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1F24) : Colors.white;
    final borderColor = isDark ? Colors.white.withAlpha(18) : Colors.black.withAlpha(10);
    final dividerColor = isDark ? Colors.white.withAlpha(15) : Colors.black.withAlpha(12);

    final content = Material(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 52,
                  endIndent: 16,
                  color: dividerColor,
                ),
            ],
          ],
        ),
      ),
    );

    if (title == null) {
      return Padding(
        padding: margin,
        child: content,
      );
    }

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white.withAlpha(210) : const Color(0xFF333336),
                    letterSpacing: -0.2,
                  ),
                ),
                if (trailingTitle != null) trailingTitle!,
              ],
            ),
          ),
          content,
        ],
      ),
    );
  }
}

/// A standard list item inside [FlClashGroupedCard].
class FlClashTile extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const FlClashTile({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (leading != null) ...[
              IconTheme(
                data: IconThemeData(
                  size: 22,
                  color: isDark ? Colors.white.withAlpha(220) : const Color(0xFF2C2D30),
                ),
                child: leading!,
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : const Color(0xFF1E1F22),
                      letterSpacing: -0.2,
                    ),
                    child: title,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    DefaultTextStyle(
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white.withAlpha(140) : const Color(0xFF6B7280),
                        height: 1.25,
                      ),
                      child: subtitle!,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
