import 'dart:math';
import 'package:flutter/material.dart';

class AnimalEffect {
  static void show(BuildContext context, Offset globalPosition) {
    final overlay = Overlay.of(context);
    final effects = [
      _FireworkOverlay.new,
      _SpiralOverlay.new,
    ];

    final effectBuilder = effects[Random().nextInt(effects.length)];

    final entry = OverlayEntry(
      builder: (_) => effectBuilder(globalPosition: globalPosition),
    );

    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 1), () => entry.remove());
  }
}

// ==================== DANH SÁCH ẢNH ====================
final List<String> imageList = [
  'assets/pet.gif',
  'assets/3dDoge.gif',
];

// ==================== FIREWORK EFFECT ====================
class _FireworkOverlay extends StatelessWidget {
  final Offset globalPosition;
  static const int particleCount = 8;

  const _FireworkOverlay({required this.globalPosition});

  @override
  Widget build(BuildContext context) {
    final renderBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalPosition);

    return Positioned.fill(
      child: Stack(
        children: List.generate(
          particleCount,
              (i) => _AnimatedAnimalParticle(
            startPosition: localPos,
            angle: (2 * pi / particleCount) * i,
          ),
        ),
      ),
    );
  }
}

class _AnimatedAnimalParticle extends StatefulWidget {
  final Offset startPosition;
  final double angle;

  const _AnimatedAnimalParticle({
    required this.startPosition,
    required this.angle,
  });

  @override
  State<_AnimatedAnimalParticle> createState() => _AnimatedAnimalParticleState();
}

class _AnimatedAnimalParticleState extends State<_AnimatedAnimalParticle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _moveX;
  late final Animation<double> _moveY;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _opacity;

  late final String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = imageList[Random().nextInt(imageList.length)];

    final distance = 80.0;
    final dx = cos(widget.angle) * distance;
    final dy = sin(widget.angle) * distance;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _moveX = Tween<double>(begin: 0, end: dx).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _moveY = Tween<double>(begin: 0, end: dy).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _scale = Tween<double>(begin: 1.0, end: 0.5).animate(_controller);
    _rotation = Tween<double>(begin: 0.0, end: 2 * pi).animate(_controller);
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: widget.startPosition.dx + _moveX.value,
          top: widget.startPosition.dy + _moveY.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Image.asset(
                  selectedImage,
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== SPIRAL EFFECT ====================
class _SpiralOverlay extends StatelessWidget {
  final Offset globalPosition;
  const _SpiralOverlay({required this.globalPosition});

  @override
  Widget build(BuildContext context) {
    final renderBox = Overlay.of(context).context.findRenderObject() as RenderBox;
    final localPos = renderBox.globalToLocal(globalPosition);

    return Positioned.fill(
      child: _SpiralEffect(position: localPos),
    );
  }
}

class _SpiralEffect extends StatefulWidget {
  final Offset position;
  const _SpiralEffect({required this.position});

  @override
  State<_SpiralEffect> createState() => _SpiralEffectState();
}

class _SpiralEffectState extends State<_SpiralEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _radius;
  late final Animation<double> _angle;
  late final Animation<double> _opacity;

  late final String selectedImage;

  @override
  void initState() {
    super.initState();
    selectedImage = imageList[Random().nextInt(imageList.length)];

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _radius = Tween<double>(begin: 0, end: 80).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _angle = Tween<double>(begin: 0, end: 6 * pi).animate(_controller);
    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dx = cos(_angle.value) * _radius.value;
    final dy = sin(_angle.value) * _radius.value;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          left: widget.position.dx + dx,
          top: widget.position.dy + dy,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.rotate(
              angle: _angle.value,
              child: Image.asset(
                selectedImage,
                width: 32,
                height: 32,
              ),
            ),
          ),
        );
      },
    );
  }
}
