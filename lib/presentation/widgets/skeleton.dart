import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';
import 'motion.dart';

/// Marcadores de posición con pulso suave mientras carga el contenido.
class SkeletonList extends StatefulWidget {
  final int count;
  const SkeletonList({super.key, this.count = 4});

  @override
  State<SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<SkeletonList> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100));
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (!Motion.reduced(context)) _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Cargando contenido',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final bar = Color.lerp(
              colors.surfaceContainerHighest.withValues(alpha: 0.55),
              colors.surfaceContainerHighest,
              _c.value,
            )!;
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.md, AppSpace.gutter, AppSpace.xl),
              itemCount: widget.count,
              itemBuilder: (context, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _bar(bar, 0.55, 16),
                    const SizedBox(height: 12),
                    _bar(bar, 1, 12),
                    const SizedBox(height: 8),
                    _bar(bar, 0.8, 12),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _bar(Color color, double factor, double height) => FractionallySizedBox(
        widthFactor: factor,
        alignment: Alignment.centerLeft,
        child: Container(height: height, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
      );
}
