import '../../domain/entities/video_entity.dart';

class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.key,
    required super.name,
    required super.site,
    required super.type,
    required super.size,
    super.official,
    super.publishedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      official: json['official'] as bool?,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'type': type,
      'size': size,
      'official': official,
      'published_at': publishedAt,
    };
  }
}

