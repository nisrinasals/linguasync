import 'package:flutter/material.dart';
import '../theme/japandi_theme.dart';

class QuizOptionButton extends StatelessWidget {
  final String label;
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;

  const QuizOptionButton({
    super.key,
    required this.label,
    required this.text,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? JC.primarySfc : JC.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? JC.primary : JC.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                // Label circle
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isSelected ? JC.primary : JC.bgMuted,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : JC.inkMd,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? JC.primaryDk : JC.ink,
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
