import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AppConstants {
  static const String appName = 'MovieBox';
  static String tmdbApiKey = '';

  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const String tmdbBackdropBaseUrl = 'https://image.tmdb.org/t/p/w780';

  static Future<void> loadApiKey() async {
    String contents;
    try {
      contents = await rootBundle.loadString('assets/config/api.env');
    } on FlutterError {
      contents = await rootBundle.loadString('assets/config/api.env.example');
    }

    for (final line in contents.split('\n')) {
      final parts = line.trim().split('=');
      if (parts.length >= 2 && parts.first.trim() == 'TMDB_API_KEY') {
        tmdbApiKey = parts.skip(1).join('=').trim();
        break;
      }
    }
  }
}
