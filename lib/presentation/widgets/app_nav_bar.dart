import 'package:flutter/material.dart';
import 'motion.dart';

class AppNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  const AppNavItem({required this.icon, required this.selectedIcon, required this.label});
}

/// Barra inferior con un indicador en forma de píldora que se desliza hacia la
/// pestaña activa. Respeta "reducir animaciones" del sistema.
class AppNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<AppNavItem> items;

  const AppNavBar({super.key, required this.selectedIndex, required this.onSelected, required this.items});

  static const double _height = 64;
  static const double _pillWidth = 60;
  static const double _pillHeight = 32;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final duration = Motion.reduced(context) ? Duration.zero : Motion.base;

    return Material(
      color: colors.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: colors.outline))),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: _height,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cellWidth = constraints.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      top: 8,
                      left: selectedIndex * cellWidth + (cellWidth - _pillWidth) / 2,
                      width: _pillWidth,
                      height: _pillHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(_pillHeight / 2),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            child: Semantics(
                              button: true,
                              selected: i == selectedIndex,
                              label: items[i].label,
                              child: ExcludeSemantics(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => onSelected(i),
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: _pillHeight,
                                          child: Center(
                                            child: AnimatedSwitcher(
                                              duration: duration,
                                              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                                              child: Icon(
                                                i == selectedIndex ? items[i].selectedIcon : items[i].icon,
                                                key: ValueKey('${items[i].label}-${i == selectedIndex}'),
                                                size: 24,
                                                color: i == selectedIndex ? colors.primary : colors.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        AnimatedDefaultTextStyle(
                                          duration: duration,
                                          style: (text.labelSmall ?? const TextStyle()).copyWith(
                                            fontSize: 11.5,
                                            fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w500,
                                            color: i == selectedIndex ? colors.primary : colors.onSurfaceVariant,
                                          ),
                                          child: Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
