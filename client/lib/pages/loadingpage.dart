import 'package:client/utils/colortheme.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.lock_open, size: 175),
            SizedBox(height: 60),
            BouncingDotAnimation(),
          ],
        ),
      ),
    );
  }
}

class BouncingDotAnimation extends StatefulWidget {
  const BouncingDotAnimation({super.key, this.numberOfDots = 3});

  final int numberOfDots;

  @override
  State<BouncingDotAnimation> createState() => _BouncingDotAnimationState();
}

class _BouncingDotAnimationState extends State<BouncingDotAnimation>
    with TickerProviderStateMixin {
  late List _animationControllers;
  final List<Animation> _animations = [];
  int animationDuration = 400;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initAnimation() {
    _animationControllers = List.generate(
      widget.numberOfDots,
      (index) {
        return AnimationController(
            vsync: this, duration: Duration(milliseconds: animationDuration));
      },
    ).toList();
    for (int i = 0; i < widget.numberOfDots; i++) {
      _animations.add(
          Tween<double>(begin: 0, end: -20).animate(_animationControllers[i]));
    }
    for (int i = 0; i < widget.numberOfDots; i++) {
      _animationControllers[i].addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationControllers[i].reverse();
          if (i != widget.numberOfDots - 1) {
            _animationControllers[i + 1].forward();
          }
        }
        if (i == widget.numberOfDots - 1 &&
            status == AnimationStatus.dismissed) {
          _animationControllers[0].forward();
        }
      });
    }
    _animationControllers.first.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.numberOfDots, (index) {
        return AnimatedBuilder(
          animation: _animationControllers[index],
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(2.5),
              child: Transform.translate(
                offset: Offset(0, _animations[index].value),
                child: const DotWidget(),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}

class DotWidget extends StatelessWidget {
  const DotWidget({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: ColorTheme.text,
      ),
      height: 8,
      width: 8,
    );
  }
}
