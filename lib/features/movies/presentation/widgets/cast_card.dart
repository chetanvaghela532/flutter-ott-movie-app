import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/cast_entity.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class CastCard extends StatelessWidget {
  final CastEntity cast;

  const CastCard({
    super.key,
    required this.cast,
  });

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.width(context, 25);
    final cardHeight = cardWidth;
    final borderRadius = cardWidth / 2;
    final margin = Responsive.spacing(context, 12);
    final spacing = Responsive.spacing(context, 8);
    final nameFontSize = Responsive.fontSize(context, 12);
    final characterFontSize = Responsive.fontSize(context, 11);
    final iconSize = Responsive.fontSize(context, 40);

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: margin),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: CachedNetworkImage(
              imageUrl: cast.profileUrl,
              width: cardWidth,
              height: cardHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: cardWidth,
                height: cardHeight,
                color: AppTheme.cardColor,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: Responsive.spacing(context, 2),
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: cardWidth,
                height: cardHeight,
                color: AppTheme.cardColor,
                child: Icon(
                  Icons.person,
                  color: AppTheme.textSecondary,
                  size: iconSize,
                ),
              ),
            ),
          ),
          SizedBox(height: spacing),
          Text(
            cast.name,
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: nameFontSize,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (cast.character != null) ...[
            SizedBox(height: Responsive.spacing(context, 4)),
            Text(
              cast.character!,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: characterFontSize,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

