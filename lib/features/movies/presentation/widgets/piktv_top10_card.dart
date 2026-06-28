import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';

class PikTvTop10Card extends StatelessWidget {
  final int rank;
  final String posterUrl;
  final VoidCallback onTap;
  final double? width;

  const PikTvTop10Card({
    super.key,
    required this.rank,
    required this.posterUrl,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    // Determine dimensions based on screen size or provided width
    // Standard card width is usually around 35% of screen width for mobile
    final totalWidth = width ?? Responsive.width(context, 45); // Slightly wider for number + poster
    final posterWidth = totalWidth * 0.75;
    final cardHeight = posterWidth * 1.5; // Standard poster aspect ratio
    final borderRadius = Responsive.spacing(context, 12);
    
    // Number styling
    final numberFontSize = cardHeight * 0.85; // Slightly smaller to fit better
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: totalWidth,
        margin: EdgeInsets.only(right: Responsive.spacing(context, 16)),
        height: cardHeight,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
             // The Number (Rendered first to be behind)
            Positioned(
              left: 0,
              bottom: -Responsive.spacing(context, 10), // Reduced offset
              child: Stack(
                children: [
                  // Outline
                  Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: numberFontSize,
                      fontWeight: FontWeight.w900,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = AppTheme.textSecondary,
                      height: 1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  // Fill
                  Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: numberFontSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.black, // Dark fill to contrast with white outline if needed, or transparent if strictly outline
                      height: 1,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
            
            // The Poster (Rendered second to be in front, offset to the right)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: posterWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: CachedNetworkImage(
                  imageUrl: posterUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppTheme.cardColor,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: Responsive.spacing(context, 2),
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.cardColor,
                    child: Icon(
                      Icons.movie_outlined,
                      color: AppTheme.textSecondary,
                      size: Responsive.fontSize(context, 32),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
