import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/database_service.dart';

class MovieListsProvider extends ChangeNotifier {
  final DatabaseService _service;
  final String userId;

  MovieListsProvider({required this._service, required this.userId});

  bool isLoading = false;
  String? error;
  final Map<MovieListType, List<Movie>> movies = {
    for (final type in MovieListType.values) type: <Movie>[],
  };

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      for (final type in MovieListType.values) {
        movies[type] = await _service.getMovies(
          userId: userId,
          listType: type.dbValue,
        );
      }
    } catch (exception, stackTrace) {
      debugPrint('Could not load movie lists: $exception\n$stackTrace');
      error = 'Could not load your movie lists.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeMovie(Movie movie, MovieListType type) async {
    try {
      error = null;
      await _service.removeMovie(
        movieId: movie.id,
        userId: userId,
        listType: type.dbValue,
      );
      final current = movies[type] ?? <Movie>[];
      movies[type] = current.where((item) => item.id != movie.id).toList();
    } catch (exception, stackTrace) {
      debugPrint('Could not remove movie from list: $exception\n$stackTrace');
      error = 'Could not update your movie lists.';
    } finally {
      notifyListeners();
    }
  }
}
