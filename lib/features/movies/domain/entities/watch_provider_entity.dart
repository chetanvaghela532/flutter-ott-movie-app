import 'package:equatable/equatable.dart';

class WatchProviderEntity extends Equatable {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final int? displayPriority;

  const WatchProviderEntity({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    this.displayPriority,
  });

  String get logoUrl {
    if (logoPath == null || logoPath!.isEmpty) return '';
    return 'https://image.tmdb.org/t/p/original$logoPath';
  }

  @override
  List<Object?> get props => [providerId, providerName, logoPath, displayPriority];
}

