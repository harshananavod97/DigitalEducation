import 'package:flutter/material.dart';

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    final h = size.height;
    final w = size.width;
    p
      ..moveTo(0, h * 0.1)
      ..quadraticBezierTo(w * 0.5, -h * 0.1, w, h * 0.1)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
