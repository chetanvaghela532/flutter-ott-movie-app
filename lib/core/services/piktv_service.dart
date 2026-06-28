import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_assets.dart';
import '../../models/piktv_models.dart';
import 'config_service.dart';

class PikTvService {
  static final PikTvService _instance = PikTvService._internal();
  factory PikTvService() => _instance;
  PikTvService._internal();

  PikTvData? _cachedData;
  Future<PikTvData>? _loadingFuture;

  // Method to force refresh data
  Future<PikTvData> refreshData() {
    _cachedData = null;
    _loadingFuture = null;
    return getPikTvData();
  }

  Future<PikTvData> getPikTvData() {
    if (_cachedData != null) {
      return Future.value(_cachedData);
    }

    // If a request is already in progress, return that future
    if (_loadingFuture != null) {
      return _loadingFuture!;
    }

    _loadingFuture = _fetchData();
    return _loadingFuture!;
  }

  Future<PikTvData> _fetchData() async {
    try {
      bool loadedFromUrl = false;
      PikTvData? data;

      // Try loading from dynamic URL first if available
      if (ConfigService().hasConfig && ConfigService().mainUrl.isNotEmpty) {
        try {
          final dio = Dio();
          if (kDebugMode) {
            debugPrint('PikTvService: Loading movies from: ${ConfigService().mainUrl}');
          }
          final response = await dio.get(ConfigService().mainUrl);
          
          if (response.statusCode == 200) {
            final jsonData = response.data;
            final Map<String, dynamic> mapData = jsonData is String 
                ? json.decode(jsonData) 
                : jsonData;

            if (kDebugMode) {
              debugPrint('jsonData === >>> ${jsonData}');
            }

            data = PikTvData.fromJson(mapData);

            if (kDebugMode) {
              debugPrint('data === >>> $data');
            }
            loadedFromUrl = true;
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('PikTvService: Failed to load from mainUrl: $e');
          }
          // Fall through to assets loading
        }
      }

      if (!loadedFromUrl) {
        // Try loading from assets
        if (kDebugMode) {
          debugPrint('PikTvService: Loading movies from assets');
        }
        final String jsonString = await rootBundle.loadString(
          AppAssets.piktvMovies,
        );
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        data = PikTvData.fromJson(jsonData);
      }

      if (data != null) {
        _cachedData = data;
        return data;
      } else {
        throw Exception('Failed to load PikTv data');
      }
    } catch (e) {
      // Reset future so we can try again
      _loadingFuture = null;
      throw e;
    }
  }
}
