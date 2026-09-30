import 'package:flutter/material.dart';

import '../app_constants.dart';
import '../models/movie.dart';

class MovieHorizontalList extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie movie) onTap;

  const MovieHorizontalList({
    super.key,
    required this.movies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('No movies available.')),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final movie = movies[index];
          return SizedBox(
            width: 130,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => onTap(movie),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        '${AppConstants.tmdbImageBaseUrl}${movie.posterPath}',
                        width: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFF222631),
                          child: Center(child: Icon(Icons.movie_outlined)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '★ ${movie.rating.toStringAsFixed(1)}',
                    style: TextStyle(color: Colors.amber.shade300, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
