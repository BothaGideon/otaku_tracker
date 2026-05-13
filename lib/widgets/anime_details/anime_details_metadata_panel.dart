import 'package:flutter/material.dart';
import 'package:otaku_tracker/services/anime_details/anime_details_view_service.dart';

class AnimeDetailsMetadataPanel extends StatelessWidget {
  final List<AnimeDetailsMetadataRowData> rows;
  final Color? labelColor;
  final Color? valueColor;

  const AnimeDetailsMetadataPanel({
    super.key,
    required this.rows,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: rows
              .map(
                (row) => AnimeDetailsLabelValueText(
                  label: row.label,
                  value: row.value,
                  labelColor: labelColor,
                  valueColor: valueColor,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AnimeDetailsLabelValueText extends StatelessWidget {
  final String label;
  final String value;
  final Color? labelColor;
  final Color? valueColor;

  const AnimeDetailsLabelValueText({
    super.key,
    required this.label,
    required this.value,
    this.labelColor,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        textAlign: TextAlign.start,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: valueColor,
              ),
          children: [
            TextSpan(
              text: '$label: ',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: labelColor,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
