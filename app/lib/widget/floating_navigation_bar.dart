import 'package:flutter/material.dart';

const _itemWidth = 84.0;
const _itemHeight = 54.0;
const _animationDuration = Duration(milliseconds: 300);

class FloatingNavigationDestination {
  final IconData icon;
  final String label;

  const FloatingNavigationDestination({
    required this.icon,
    required this.label,
  });
}

/// A modern pill-shaped floating navigation bar inspired by FlClash / iOS 18 design.
class FloatingNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<FloatingNavigationDestination> destinations;

  const FloatingNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final barBackground = isDark
        ? const Color(0xFF1E1F24)
        : Colors.white;

    final indicatorColor = isDark
        ? colorScheme.primary.withAlpha(50)
        : colorScheme.primary.withAlpha(28);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 14),
        child: Center(
          heightFactor: 1,
          child: Material(
            color: barBackground,
            elevation: 4,
            shadowColor: Colors.black.withAlpha(isDark ? 80 : 35),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: BorderSide(
                color: isDark ? Colors.white.withAlpha(20) : Colors.black.withAlpha(12),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Animated sliding pill indicator
                  AnimatedPositioned(
                    duration: _animationDuration,
                    curve: Curves.easeOutCubic,
                    left: selectedIndex * _itemWidth,
                    top: 0,
                    bottom: 0,
                    width: _itemWidth,
                    child: Container(
                      decoration: ShapeDecoration(
                        shape: const StadiumBorder(),
                        color: indicatorColor,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        _FloatingNavigationItem(
                          destination: destinations[i],
                          selected: i == selectedIndex,
                          onTap: () => onDestinationSelected(i),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingNavigationItem extends StatelessWidget {
  final FloatingNavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  const _FloatingNavigationItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant.withAlpha(190);

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: SizedBox(
          width: _itemWidth,
          height: _itemHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                duration: _animationDuration,
                curve: Curves.easeOutBack,
                scale: selected ? 1.1 : 1.0,
                child: TweenAnimationBuilder<Color?>(
                  duration: _animationDuration,
                  tween: ColorTween(end: selected ? activeColor : inactiveColor),
                  builder: (context, color, _) => Icon(
                    destination.icon,
                    size: 22,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: _animationDuration,
                curve: Curves.easeInOut,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? activeColor : inactiveColor,
                  letterSpacing: 0.1,
                ),
                child: Text(
                  destination.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
