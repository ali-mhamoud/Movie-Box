import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/home_provider.dart';
import '../models/movie.dart';
import 'movie_lists_screen.dart';
import 'movie_details_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';
import '../widgets/movie_horizontal_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();

    final pages = [
      _HomeContent(home: home),
      const SearchScreen(),
      const MovieListsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              title: const Text('MovieBox'),
              actions: [
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: home.isLoading ? null : () => home.loadHome(),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.bookmarks_outlined), selectedIcon: Icon(Icons.bookmarks), label: 'My Lists'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final HomeProvider home;

  const _HomeContent({required this.home});

  @override
  Widget build(BuildContext context) {
    if (home.isLoading && home.popular.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (home.error != null && home.popular.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 56),
              const SizedBox(height: 12),
              Text(home.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.read<HomeProvider>().loadHome(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: home.loadHome,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _WelcomeHeader(),
          _Section(title: 'Trending', movies: home.trending),
          _Section(title: 'Popular', movies: home.popular),
          _Section(title: 'Now Playing', movies: home.nowPlaying),
          _Section(title: 'Top Rated', movies: home.topRated),
          _Section(title: 'Upcoming', movies: home.upcoming),
        ],
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
      child: Text(
        'Discover movies you will love.',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Movie> movies;

  const _Section({required this.title, required this.movies});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        MovieHorizontalList(
          movies: movies,
          onTap: (movie) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailsScreen(movieId: movie.id),
              ),
            );
          },
        ),
      ],
    );
  }
}
