import 'package:flutter/material.dart';

class NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool selected;

  const NavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : const Color(0xFFF6F7FB),
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
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
