import 'package:equatable/equatable.dart';

class VideoEntity extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;
  final bool? official;
  final String? publishedAt;

  const VideoEntity({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    required this.size,
    this.official,
    this.publishedAt,
  });

  String get youtubeUrl {
    if (site.toLowerCase() == 'youtube') {
      return 'https://www.youtube.com/watch?v=$key';
    }
    return '';
  }

  String get youtubeThumbnail {
    if (site.toLowerCase() == 'youtube') {
      return 'https://img.youtube.com/vi/$key/maxresdefault.jpg';
    }
    return '';
  }

  bool get isTrailer => type.toLowerCase() == 'trailer';
  bool get isTeaser => type.toLowerCase() == 'teaser';
  bool get isClip => type.toLowerCase() == 'clip';
  bool get isFeaturette => type.toLowerCase() == 'featurette';
  bool get isBehindTheScenes => type.toLowerCase() == 'behind the scenes';

  @override
  List<Object?> get props => [id, key, name, site, type, size, official, publishedAt];
}

