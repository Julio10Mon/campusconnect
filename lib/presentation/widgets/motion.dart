import 'package:flutter/material.dart';

/// Kit de movimiento de CampusConnect.
///
/// Criterio: el movimiento comunica jerarquía (entrada escalonada) y respuesta
/// (pulsación), nunca decora. Todo respeta "reducir animaciones" del sistema.
class Motion {
  Motion._();

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Curve curve = Curves.easeOutCubic;

  /// Retraso escalonado: tope de 8 elementos para que listas largas no tarden.
  static Duration stagger(int index, {int stepMs = 55, int maxItems = 8}) =>
      Duration(milliseconds: stepMs * (index < maxItems ? index : maxItems));

  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Aparece con un leve desplazamiento vertical y fundido.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;

  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero, this.offsetY = 14});

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.base);
  late final Animation<double> _t = CurvedAnimation(parent: _c, curve: Motion.curve);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (Motion.reduced(context)) {
      _c.value = 1;
    } else if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(offset: Offset(0, (1 - _t.value) * widget.offsetY), child: child),
      ),
    );
  }
}

/// Escala suavemente al presionar (respuesta táctil). No bloquea el onTap del hijo.
class PressableScale extends StatefulWidget {
  final Widget child;
  final double pressedScale;

  const PressableScale({super.key, required this.child, this.pressedScale = 0.975});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v && mounted) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _set(true),
      onPointerUp: (_) => _set(false),
      onPointerCancel: (_) => _set(false),
      child: AnimatedScale(
        scale: _down && !Motion.reduced(context) ? widget.pressedScale : 1,
        duration: Motion.fast,
        curve: Motion.curve,
        child: widget.child,
      ),
    );
  }
}

/// Número que cuenta desde 0 hasta [value] al aparecer y al cambiar.
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;

  const CountUp({super.key, required this.value, this.style});

  @override
  Widget build(BuildContext context) {
    if (Motion.reduced(context)) return Text('$value', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: Motion.slow,
      curve: Motion.curve,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// Funde y desliza ligeramente su contenido cada vez que cambia [token].
/// Conserva el estado del hijo (a diferencia de AnimatedSwitcher con otra clave).
class FadeOnChange extends StatefulWidget {
  final Object token;
  final Widget child;

  const FadeOnChange({super.key, required this.token, required this.child});

  @override
  State<FadeOnChange> createState() => _FadeOnChangeState();
}

class _FadeOnChangeState extends State<FadeOnChange> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: Motion.base, value: 1);

  @override
  void didUpdateWidget(covariant FadeOnChange old) {
    super.didUpdateWidget(old);
    if (old.token != widget.token && !Motion.reduced(context)) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(parent: _c, curve: Motion.curve);
    return FadeTransition(
      opacity: t,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(t),
        child: widget.child,
      ),
    );
  }
}
