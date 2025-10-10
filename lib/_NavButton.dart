import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final Gradient? gradient;
  final Color? color;

  const NavButton({
    required this.icon,
    required this.label,
    required this.selected,
    this.gradient,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = selected
        ? (color ?? Colors.white)
        : const Color(0xFF9A9AB0);
    final Color textColor = selected
        ? (color ?? Colors.white)
        : const Color(0xFF9A9AB0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: selected ? gradient : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.transparent : const Color(0xFFF6F7FB),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
