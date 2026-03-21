import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final double? height;
  final double? width;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final titleCardStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceVariant,
    );
    final textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    );

    return SizedBox(
      height: height,
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: titleCardStyle),
              const SizedBox(height: 8),
              Text(value, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
