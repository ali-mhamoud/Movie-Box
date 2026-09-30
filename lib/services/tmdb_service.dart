import 'dart:convert';

import 'package:http/http.dart' as http;

import '../app_constants.dart';
import '../models/movie.dart';

class TmdbException implements Exception {
  final String message;
  const TmdbException(this.message);

  @override
  String toString() => message;
}

class TmdbService {
  final http.Client _client;

  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Movie>> getPopular() => getMovies('/movie/popular');
  Future<List<Movie>> getTopRated() => getMovies('/movie/top_rated');
  Future<List<Movie>> getNowPlaying() => getMovies('/movie/now_playing');
  Future<List<Movie>> getUpcoming() => getMovies('/movie/upcoming');
  Future<List<Movie>> getTrending() => getMovies('/trending/movie/week');

  Future<List<Movie>> getMovies(String endpoint) async {
    _checkApiKey();

    final uri = Uri.parse(
      '${AppConstants.tmdbBaseUrl}$endpoint'
      '${endpoint.contains('?') ? '&' : '?'}api_key=${AppConstants.tmdbApiKey}&language=en-US&page=1',
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw TmdbException('TMDB request failed (${response.statusCode}).');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final results = decoded['results'] as List<dynamic>? ?? const [];
      return results
          .map((item) => Movie.fromJson(item as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const TmdbException('Invalid data received from TMDB.');
    } on TmdbException {
      rethrow;
    } catch (_) {
      throw const TmdbException(
        'Could not connect to TMDB. Check your internet connection.',
      );
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    _checkApiKey();

    final uri = Uri.parse(
      '${AppConstants.tmdbBaseUrl}/movie/$movieId'
      '?api_key=${AppConstants.tmdbApiKey}&language=en-US',
    );

    try {
      final response = await _client.get(uri);
      if (response.statusCode != 200) {
        throw TmdbException('Movie details request failed (${response.statusCode}).');
      }
      return Movie.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on TmdbException {
      rethrow;
    } catch (_) {
      throw const TmdbException(
        'Could not connect to TMDB. Check your internet connection.',
      );
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    if (query.trim().isEmpty) return [];
    return getMovies('/search/movie?query=${Uri.encodeQueryComponent(query.trim())}');
  }

  void _checkApiKey() {
    if (AppConstants.tmdbApiKey.isEmpty ||
        AppConstants.tmdbApiKey == 'YOUR_TMDB_API_KEY') {
      throw const TmdbException(
        'TMDB API key is missing. Copy assets/config/api.env.example to '
        'assets/config/api.env and add your key.',
      );
    }
  }

  void dispose() => _client.close();
}
