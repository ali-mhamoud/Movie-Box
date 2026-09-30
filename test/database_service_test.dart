import 'package:flutter_test/flutter_test.dart';
import 'package:movie_box_iti/models/movie.dart';
import 'package:movie_box_iti/services/database_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('movie lists save, reload, and remove per user and list', () async {
    final database = DatabaseService();
    const movie = Movie(
      id: 987654,
      title: 'Database smoke test',
      overview: 'Test movie',
      posterPath: '/poster.jpg',
      backdropPath: '/backdrop.jpg',
      releaseDate: '2026-01-01',
      rating: 8.5,
    );
    const userId = 'database-smoke-test-user';

    await database.clearUserData(userId);
    await database.addMovie(
      movie: movie,
      userId: userId,
      listType: 'favorites',
    );
    await database.addMovie(
      movie: movie,
      userId: userId,
      listType: 'watched',
    );

    expect(
      await database.containsMovie(
        movieId: movie.id,
        userId: userId,
        listType: 'favorites',
      ),
      isTrue,
    );
    final savedMovies = await database.getMovies(
      userId: userId,
      listType: 'favorites',
    );
    expect(savedMovies, hasLength(1));
    expect(savedMovies.single.id, movie.id);
    expect(savedMovies.single.title, movie.title);
    expect(savedMovies.single.rating, movie.rating);
    expect(
      await database.containsMovie(
        movieId: movie.id,
        userId: 'another-user',
        listType: 'favorites',
      ),
      isFalse,
    );

    await database.removeMovie(
      movieId: movie.id,
      userId: userId,
      listType: 'favorites',
    );

    expect(
      await database.containsMovie(
        movieId: movie.id,
        userId: userId,
        listType: 'favorites',
      ),
      isFalse,
    );
    expect(
      await database.containsMovie(
        movieId: movie.id,
        userId: userId,
        listType: 'watched',
      ),
      isTrue,
    );

    await database.clearUserData(userId);
  });
}
