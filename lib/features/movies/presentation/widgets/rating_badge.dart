import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class RatingBadge extends StatelessWidget {
  final double rating;

  const RatingBadge({
    super.key,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.spacing(context, 6);
    final borderRadius = Responsive.spacing(context, 6);
    final iconSize = Responsive.fontSize(context, 14);
    final fontSize = Responsive.fontSize(context, 12);
    final spacing = Responsive.spacing(context, 4);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: Responsive.spacing(context, 4),
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            color: Colors.amber,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

