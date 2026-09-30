import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_constants.dart';
import '../models/movie_list_type.dart';
import '../services/database_service.dart';
import '../services/tmdb_service.dart';
import '../providers/auth_provider.dart';
import '../providers/movie_details_provider.dart';

class MovieDetailsScreen extends StatelessWidget {
  final int movieId;

  const MovieDetailsScreen({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return ChangeNotifierProvider(
      create: (_) => MovieDetailsProvider(
        movieService: context.read<TmdbService>(),
        databaseService: context.read<DatabaseService>(),
        userId: user.uid,
        movieId: movieId,
      )..load(),
      child: const _MovieDetailsBody(),
    );
  }
}

class _MovieDetailsBody extends StatelessWidget {
  const _MovieDetailsBody();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovieDetailsProvider>();

    if (controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.error != null || controller.movie == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(controller.error ?? 'Movie not found.', textAlign: TextAlign.center),
          ),
        ),
      );
    }

    final movie = controller.movie!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    '${AppConstants.tmdbBackdropBaseUrl}${movie.backdropPath}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const ColoredBox(color: Color(0xFF222631)),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 125,
                        height: 188,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const ColoredBox(
                              color: Color(0xFF222631),
                              child: Icon(Icons.movie_outlined, size: 46),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(movie.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text('★ ${movie.rating.toStringAsFixed(1)}'),
                            const SizedBox(height: 8),
                            Text(movie.releaseDate.isEmpty ? 'Release date unavailable' : movie.releaseDate),
                            if (movie.runtime != null) ...[
                              const SizedBox(height: 8),
                              Text('${movie.runtime} minutes'),
                            ],
                            if (movie.genres.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: movie.genres.map((g) => Chip(label: Text(g))).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text('Overview', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(movie.overview.isEmpty ? 'No overview available.' : movie.overview),
                  const SizedBox(height: 22),
                  Text('My Lists', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  if (controller.listError != null) ...[
                    Text(
                      controller.listError!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                    const SizedBox(height: 8),
                  ],
                  ...MovieListType.values.map(
                    (type) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _ListButton(type: type),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListButton extends StatelessWidget {
  final MovieListType type;

  const _ListButton({required this.type});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MovieDetailsProvider>();
    final selected = controller.membership[type] ?? false;

    return FilledButton.tonalIcon(
      onPressed: controller.isUpdatingList ? null : () => controller.toggleList(type),
      icon: Icon(selected ? Icons.check : Icons.add),
      label: Text(selected ? 'Remove from ${type.title}' : 'Add to ${type.title}'),
    );
  }
}
