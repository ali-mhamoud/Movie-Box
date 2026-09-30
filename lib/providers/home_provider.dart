import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

class HomeProvider extends ChangeNotifier {
  final TmdbService _service;

  HomeProvider(this._service);

  bool isLoading = false;
  String? error;
  List<Movie> popular = [];
  List<Movie> topRated = [];
  List<Movie> nowPlaying = [];
  List<Movie> upcoming = [];
  List<Movie> trending = [];

  Future<void> loadHome() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getPopular(),
        _service.getTopRated(),
        _service.getNowPlaying(),
        _service.getUpcoming(),
        _service.getTrending(),
      ]);

      popular = results[0];
      topRated = results[1];
      nowPlaying = results[2];
      upcoming = results[3];
      trending = results[4];
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
