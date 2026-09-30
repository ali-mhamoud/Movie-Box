enum MovieListType {
  favorites,
  watched,
  watching,
  wantToWatch,
}

extension MovieListTypeX on MovieListType {
  String get dbValue {
    switch (this) {
      case MovieListType.favorites:
        return 'favorites';
      case MovieListType.watched:
        return 'watched';
      case MovieListType.watching:
        return 'watching';
      case MovieListType.wantToWatch:
        return 'want_to_watch';
    }
  }

  String get title {
    switch (this) {
      case MovieListType.favorites:
        return 'Favorites';
      case MovieListType.watched:
        return 'Watched';
      case MovieListType.watching:
        return 'Watching';
      case MovieListType.wantToWatch:
        return 'Want to Watch';
    }
  }
}
