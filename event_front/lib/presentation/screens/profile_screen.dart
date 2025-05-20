import 'package:event_booking_app/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:event_booking_app/domain/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: authState.isAuthenticated
          ? _buildAuthenticatedProfile(context, ref, authState.user!)
          : _buildGuestProfile(context),
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, WidgetRef ref, UserModel user) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 250,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              user.name,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 66,
                      backgroundImage: user.avatar != null && user.avatar != 'default.jpg'
                          ? CachedNetworkImageProvider(user.avatar!)
                          : null,
                      child: user.avatar == null || user.avatar == 'default.jpg'
                          ? const Icon(Icons.person, size: 66, color: Colors.grey)
                          : null,
                    ),
                  ).animate().fadeIn().scale(),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(user.email),
                    subtitle: const Text('Email'),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 100)),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(user.role.capitalize()),
                    subtitle: const Text('Role'),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 200)),
                if (user.status != 'active')
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(user.status.capitalize()),
                      subtitle: const Text('Account Status'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 300)),
                if (user.phoneNumber != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.phone),
                      title: Text(user.phoneNumber!),
                      subtitle: const Text('Phone Number'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 400)),
                if (user.organizationName != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.business),
                      title: Text(user.organizationName!),
                      subtitle: const Text('Organization'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 500)),
                if (user.location != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(user.location!),
                      subtitle: const Text('Location'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 600)),
                if (user.website != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(user.website!),
                      subtitle: const Text('Website'),
                      onTap: () => _launchUrl(user.website!),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 700)),
                if (user.socialLinks != null && user.socialLinks!.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Social Links'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: user.socialLinks!
                            .map((link) => GestureDetector(
                                  onTap: () => _launchUrl(link),
                                  child: Text(
                                    link,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 800)),
                if (user.about != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.info),
                      title: Text(user.about!),
                      subtitle: const Text('About'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 900)),
                if (user.role == 'vendor' && user.serviceProvided != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.work),
                      title: Text(user.serviceProvided!),
                      subtitle: const Text('Service Provided'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
                if (user.role == 'vendor' && user.rating != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.star),
                      title: Text('${user.rating!.toStringAsFixed(1)} / 5'),
                      subtitle: const Text('Rating'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1100)),
                if (user.role == 'vendor' && user.price != null)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: Text(user.price!),
                      subtitle: const Text('Price'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1200)),
                if (user.role == 'vendor' && user.portfolio != null && user.portfolio!.isNotEmpty)

Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Portfolio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 120,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: user.portfolio!.length,
                              itemBuilder: (context, index) {
                                final item = user.portfolio![index];
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: item.image != null
                                            ? CachedNetworkImage(
                                                imageUrl: item.image!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: const Icon(Icons.image),
                                              ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.title ?? 'Untitled',
                                        style: const TextStyle(fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1300)),
                if (user.role == 'organizer' && user.eventCategories != null && user.eventCategories!.isNotEmpty)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.event),
                      title: Text(user.eventCategories!.join(', ')),
                      subtitle: const Text('Event Categories'),
                    ),
                  ).animate().fadeIn(delay: const Duration(milliseconds: 1400)),
                const SizedBox(height: 16),
                Text(
                  'Actions',
                  style: Theme.of(context).textTheme.titleLarge,
                ).animate().fadeIn(delay: const Duration(milliseconds: 1500)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit Profile'),
                    onTap: () => context.go('/edit-profile'),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 1600)),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.bookmark),
                    title: const Text('My Favorites'),
                    onTap: () => context.go('/favorites'),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 1700)),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.confirmation_number),
                    title: const Text('My Bookings'),
                    onTap: () => context.go('/tickets'),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 1800)),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Settings coming soon!')),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 1900)),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ).animate().fadeIn(delay: const Duration(milliseconds: 2000)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGuestProfile(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Guest User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Please log in to access your profile and enjoy personalized features.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Login'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('Create an Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
