import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:event_booking_app/domain/providers/event_provider.dart';
import 'package:event_booking_app/presentation/widgets/event_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> categories = ['All', 'music', 'entertainment', 'sport', 'Tech', 'Art', 'General', 'education'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            title: const Text('Discover Events'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(142), // Increased to 142
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories
                            .map((category) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(category),
                                    selected: _selectedCategory == category,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedCategory = category;
                                        });
                                      }
                                    },
                                    selectedColor: Theme.of(context).colorScheme.secondary,
                                    labelStyle: TextStyle(
                                      color: _selectedCategory == category
                                          ? Colors.white
                                          : Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: eventsAsync.when(
              data: (events) {
                final filteredEvents = events
                    .where((event) =>
                        event.title
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()) &&
                        (_selectedCategory == 'All' ||
                            event.category == _selectedCategory))
                    .toList();

                if (events.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.background,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            )
                                .animate()
                                .scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 24),
                            Text(
                              'No Events Available',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 16),
                            Text(
                              'It looks like there are no events at the moment. Check back later for exciting updates!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (filteredEvents.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              Theme.of(context).colorScheme.background,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            )
                                .animate()
                                .scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 24),
                            Text(
                              'No Events Found',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            )
                                .animate()
                                .fadeIn(delay: 200.ms, duration: 400.ms),
                            const SizedBox(height: 16),
                            Text(
                              'Try a different search term or category to find events.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    height: 1.5,
                                  ),
                            )
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms),
                            const SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCategory = 'All';
                                });
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Reset Filters'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                textStyle: const TextStyle(fontSize: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Colors.white,
                              ),
                            )
                                .animate()
                                .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 600.ms,
                                  duration: 400.ms,
                                  curve: Curves.easeOut,
                                ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return EventCard(event: filteredEvents[index])
                          .animate()
                          .fadeIn(delay: Duration(milliseconds: index * 100))
                          .slideY(begin: 0.2, end: 0);
                    },
                    childCount: filteredEvents.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: _buildSkeletonLoader(context),
              ),
              error: (error, stackTrace) {
                if (kDebugMode) {
                  print('Error in eventsProvider: $error');
                }
                return SliverToBoxAdapter(
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            Theme.of(context).colorScheme.background,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 80,
                            color: Theme.of(context).colorScheme.error.withOpacity(0.7),
                          )
                              .animate()
                              .scale(duration: 600.ms, curve: Curves.easeOutBack),
                          const SizedBox(height: 24),
                          Text(
                            'Connection Issue',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          )
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms),
                          const SizedBox(height: 16),
                          Text(
                            'Unable to load events. Please check your internet connection and try again.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                  height: 1.5,
                                ),
                          )
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: () => ref.refresh(eventsProvider),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Try Again'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                            ),
                          )
                              .animate()
                              .slideY(
                                begin: 0.2,
                                end: 0,
                                delay: 600.ms,
                                duration: 400.ms,
                                curve: Curves.easeOut,
                              ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // Simulate 6 placeholder cards
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      color: Colors.grey[300],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().shimmer(
              duration: const Duration(milliseconds: 1000),
              color: Colors.grey[100],
            );
      },
    );
  }
}