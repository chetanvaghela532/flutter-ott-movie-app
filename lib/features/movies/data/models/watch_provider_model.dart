import '../../domain/entities/watch_provider_entity.dart';

class WatchProviderModel extends WatchProviderEntity {
  const WatchProviderModel({
    required super.providerId,
    required super.providerName,
    super.logoPath,
    super.displayPriority,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json) {
    return WatchProviderModel(
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      logoPath: json['logo_path'] as String?,
      displayPriority: json['display_priority'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'provider_id': providerId,
      'provider_name': providerName,
      'logo_path': logoPath,
      'display_priority': displayPriority,
    };
  }
}

