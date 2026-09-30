import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../models/movie_list_type.dart';
import '../services/database_service.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_lists_provider.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class MovieListsScreen extends StatelessWidget {
  const MovieListsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return ChangeNotifierProvider(
      create: (_) => MovieListsProvider(
        service: context.read<DatabaseService>(),
        userId: user.uid,
      )..loadAll(),
      child: const _MovieListsBody(),
    );
  }
}

class _MovieListsBody extends StatefulWidget {
  const _MovieListsBody();

  @override
  State<_MovieListsBody> createState() => _MovieListsBodyState();
}

class _MovieListsBodyState extends State<_MovieListsBody> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovieListsProvider>();

    return DefaultTabController(
      length: MovieListType.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Lists'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Favorites'),
              Tab(text: 'Watched'),
              Tab(text: 'Watching'),
              Tab(text: 'Want to Watch'),
            ],
          ),
        ),
        body: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.error != null
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(controller.error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: controller.loadAll,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    children: MovieListType.values
                        .map((type) => _ListTab(type: type, movies: controller.movies[type] ?? const []))
                        .toList(),
                  ),
      ),
    );
  }
}

class _ListTab extends StatelessWidget {
  final MovieListType type;
  final List<Movie> movies;

  const _ListTab({required this.type, required this.movies});

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.movie_outlined, size: 56),
              const SizedBox(height: 12),
              Text('Your ${type.title} list is empty.'),
              const SizedBox(height: 6),
              const Text(
                'Open a movie and add it to this list.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return MovieCard(
          movie: movie,
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MovieDetailsScreen(movieId: movie.id)),
            );
            if (context.mounted) {
              context.read<MovieListsProvider>().loadAll();
            }
          },
          onRemove: () => context.read<MovieListsProvider>().removeMovie(movie, type),
        );
      },
    );
  }
}
