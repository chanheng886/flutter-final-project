import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CircleIconButton extends StatelessWidget {
  const new({super.key, required this.icon, required this.onTap});

  final FaIconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Center(child: FaIcon(icon, size: 18)),
      ),
    );
  }
}
