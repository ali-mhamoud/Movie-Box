import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/database_service.dart';
import '../services/tmdb_service.dart';

class MovieDetailsProvider extends ChangeNotifier {
  final TmdbService _movieService;
  final DatabaseService _databaseService;
  final String userId;
  final int movieId;

  MovieDetailsProvider({
    required this._movieService,
    required this._databaseService,
    required this.userId,
    required this.movieId,
  });

  Movie? movie;
  bool isLoading = true;
  String? error;
  String? listError;
  bool isUpdatingList = false;
  final Map<MovieListType, bool> membership = {
    for (final type in MovieListType.values) type: false,
  };

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      movie = await _movieService.getMovieDetails(movieId);
      for (final type in MovieListType.values) {
        membership[type] = await _databaseService.containsMovie(
          movieId: movieId,
          userId: userId,
          listType: type.dbValue,
        );
      }
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleList(MovieListType type) async {
    final currentMovie = movie;
    if (currentMovie == null) return;

    isUpdatingList = true;
    listError = null;
    notifyListeners();

    try {
      if (membership[type] == true) {
        await _databaseService.removeMovie(
          movieId: currentMovie.id,
          userId: userId,
          listType: type.dbValue,
        );
        membership[type] = false;
      } else {
        await _databaseService.addMovie(
          movie: currentMovie,
          userId: userId,
          listType: type.dbValue,
        );
        membership[type] = true;
      }
    } catch (exception, stackTrace) {
      debugPrint('Could not save movie list: $exception\n$stackTrace');
      listError = 'Could not update this movie list. Please try again.';
    } finally {
      isUpdatingList = false;
      notifyListeners();
    }
  }
}
