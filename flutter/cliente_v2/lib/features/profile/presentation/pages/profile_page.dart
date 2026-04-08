import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
<<<<<<< Updated upstream
    // We can use authProvider to get basic user info if stored,
    // or fetch detailed profile from API using profileProvider
    final profileAsync = ref.watch(profileProvider);
=======
    final activeProfile = ref.watch(activeProfileProvider);
    final user = ref.watch(currentUserProvider);
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final fullAvatarUrl =
        activeProfile?.avatarUrl ??
        AppUrls.getAvatarUrl(user['photo']?.toString());
>>>>>>> Stashed changes

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: profileAsync.when(
        data: (profile) {
          final user = profile['customer'] ?? {}; // Adjust key based on API
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(
                    'assets/images/user-placeholder.png',
                  ), // Placeholder
                  // backgroundImage: NetworkImage(user['photo'] ?? ''), // If photo available
                ),
                const SizedBox(height: 16),
                Text(
                  '${user['fname'] ?? 'Usuario'} ${user['lname'] ?? ''}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  user['email'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),

                const SizedBox(height: 32),

                ListTile(
                  leading: const Icon(Icons.confirmation_number_outlined),
                  title: const Text('Mis Entradas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/my-tickets'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Editar Perfil'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to Edit Profile Page (Not implemented in this phase)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Próximamente')),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Cambiar Contraseña'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red),
                  ),
<<<<<<< Updated upstream
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
=======
                  actions: [
                    IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),

                // Profile Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProfileAvatar(fullAvatarUrl),
                        const SizedBox(height: 16),
                        Text(
                          activeProfile?.name ??
                              '${user['fname'] ?? ''} ${user['lname'] ?? ''}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (activeProfile != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF6200EE,
                              ).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF6200EE,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Text(
                              activeProfile.type.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFBB86FC),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Profile Switcher (The core selection component)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: ProfileSwitcher(),
                  ),
                ),

                // Menu Items
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      title: 'Mis Entradas',
                      onTap: () => context.push('/my-tickets'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Datos Personales',
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Seguridad',
                      onTap: () {},
                    ),
                    if (activeProfile?.type == ProfileType.organizer ||
                        activeProfile?.type == ProfileType.venue)
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard_customize_outlined,
                        title: 'Panel Administrativo',
                        subtitle: 'Gestiona tus eventos y ventas',
                        onTap: () {},
                        highlight: true,
                      ),
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: isLoggingOut
                          ? 'Cerrando Sesión...'
                          : 'Cerrar Sesión',
                      onTap: isLoggingOut
                          ? () {}
                          : () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .logout();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                      textColor: Colors.redAccent,
                    ),
                    const SizedBox(height: 100),
                  ]),
>>>>>>> Stashed changes
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
