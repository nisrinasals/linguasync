import 'package:flutter/material.dart';
import '../../data/models/language_model.dart';
import '../theme/japandi_theme.dart';

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
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: JC.primarySfc,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.translate, color: JC.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language.name,
                  style: JT.titleMd,
                ),
              ),
              if (language.isEnrolled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: JC.primarySfc,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: JC.primaryLt),
                  ),
                  child: const Text(
                    'Diikuti',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: JC.primary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            language.description,
            style: JT.bodySm,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor:
                      language.isEnrolled ? JC.bgMuted : JC.primary,
                  foregroundColor:
                      language.isEnrolled ? JC.inkLt : Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: language.isEnrolled ? null : onButtonPressed,
                child: Text(
                  language.isEnrolled ? 'Telah Diikuti' : buttonText!,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: onTap != null
          ? InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: cardContent,
            )
          : cardContent,
    );
  }
}
