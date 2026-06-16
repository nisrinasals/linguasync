import 'package:flutter/material.dart';
import '../../data/models/language_model.dart';

class LanguageCard extends StatelessWidget {
  final LanguageModel language;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final VoidCallback? onTap;

  const LanguageCard({
    super.key,
    required this.language,
    this.buttonText,
    this.onButtonPressed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            language.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            language.description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: language.isEnrolled
                      ? Colors.grey[400]
                      : const Color(0xFF2C3E50),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: language.isEnrolled ? null : onButtonPressed,
                child: Text(
                  language.isEnrolled ? 'Telah Diikuti' : buttonText!,
                  style: TextStyle(
                    color: language.isEnrolled ? Colors.grey[200] : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: cardContent,
            )
          : cardContent,
    );
  }
}

