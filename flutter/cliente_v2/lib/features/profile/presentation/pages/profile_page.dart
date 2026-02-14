import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use authProvider to get basic user info if stored,
    // or fetch detailed profile from API using profileProvider
    final profileAsync = ref.watch(profileProvider);

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
                  onTap: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
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
