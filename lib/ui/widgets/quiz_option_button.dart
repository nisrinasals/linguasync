import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected
                ? const Color(0xFF2C3E50)
                : Colors.white,
            side: BorderSide(
              color: isSelected ? const Color(0xFF2C3E50) : Colors.grey[400]!,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          onPressed: onPressed,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2C3E50)
                        : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
