import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularProgressContainer extends StatefulWidget {
  const CircularProgressContainer({
    super.key,
    this.whiteLoader = false,
    this.size = 40,
  });

  final bool whiteLoader;
  final double size;

  @override
  State<CircularProgressContainer> createState() =>
      _CircularProgressContainerState();
}

class _CircularProgressContainerState extends State<CircularProgressContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;

  /// The PI constant.
  static const double pi2 = 3.1415926535897932 * 2;
  static const String loader = 'assets/images/loadder.svg';

  @override
  void initState() {
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.whiteLoader ? Colors.white : Theme.of(context).primaryColor;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (_, __) => Transform.rotate(
              angle: (_rotationController.value * 6) * pi2,
              child: SvgPicture.asset(
                loader,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
