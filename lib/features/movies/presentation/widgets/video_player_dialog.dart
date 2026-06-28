import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/video_entity.dart';

class VideoPlayerDialog extends StatefulWidget {
  final VideoEntity video;

  const VideoPlayerDialog({
    super.key,
    required this.video,
  });

  @override
  State<VideoPlayerDialog> createState() => _VideoPlayerDialogState();
}

class _VideoPlayerDialogState extends State<VideoPlayerDialog> {
  late final YoutubePlayerController _controller;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.key,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        loop: false,
      ),
    );
  }

  Future<void> _openInExternalPlayer() async {
    final url = widget.video.youtubeUrl;
    if (url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(Responsive.spacing(context, 16)),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(Responsive.spacing(context, 16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(Responsive.spacing(context, 16)),
              decoration: BoxDecoration(
                color: AppTheme.cardColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Responsive.spacing(context, 16)),
                  topRight: Radius.circular(Responsive.spacing(context, 16)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.video.name,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: Responsive.fontSize(context, 16),
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: Responsive.spacing(context, 4)),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Responsive.spacing(context, 8),
                            vertical: Responsive.spacing(context, 4),
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.video.type.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Responsive.fontSize(context, 10),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Video Player
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _hasError
                  ? Container(
                      color: Colors.black,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: Responsive.fontSize(context, 48),
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Responsive.spacing(context, 16),
                            ),
                            child: Text(
                              _errorMessage ?? 'Video unavailable',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: Responsive.fontSize(context, 14),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(height: Responsive.spacing(context, 16)),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Fallback: Open in YouTube app/browser
                              Navigator.of(context).pop();
                              _openInExternalPlayer();
                            },
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open in YouTube'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: true,
                        ),
                        // Show error button overlay if needed
                        if (_hasError)
                          Positioned.fill(
                            child: Container(
                              color: Colors.black54,
                              child: Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _openInExternalPlayer();
                                  },
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open in YouTube'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

