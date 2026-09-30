import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../services/tmdb_service.dart';

class MovieSearchProvider extends ChangeNotifier {
  final TmdbService _service;

  MovieSearchProvider(this._service);

  Timer? _debounce;
  bool isLoading = false;
  String? error;
  String query = '';
  List<Movie> results = [];
  int _requestNumber = 0;

  void onQueryChanged(String value) {
    query = value;
    _requestNumber++;
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      results = [];
      error = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      search(value);
    });
  }

  Future<void> search(String value) async {
    if (value.trim().isEmpty) return;

    final requestNumber = ++_requestNumber;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await _service.searchMovies(value);
      if (requestNumber == _requestNumber) results = response;
    } catch (e) {
      if (requestNumber == _requestNumber) {
        error = e.toString();
        results = [];
      }
    } finally {
      if (requestNumber == _requestNumber) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
