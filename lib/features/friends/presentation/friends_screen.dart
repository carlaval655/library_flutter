import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final usersProvider = FutureProvider<List<AppUser>>((ref) async {
  final List<dynamic> data = await Supabase.instance.client
      .from('profiles')
      .select();

  return data.map((userMap) {
    return AppUser(
      id: userMap['id'],
      name: '${userMap['nombre']} ${userMap['apellido']}',
      photoUrl: userMap['foto_url'] ?? '',
    );
  }).toList();
});

class AppUser {
  final String id;
  final String name;
  final String photoUrl;

  AppUser({required this.id, required this.name, required this.photoUrl});
}

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorar'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF7B1FA2), Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: usersAsync.when(
          data: (users) {
            if (users.isEmpty) {
              return const Center(child: Text('No hay usuarios disponibles.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 28,
                      backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                      child: user.photoUrl.isEmpty ? const Icon(Icons.person, size: 28, color: Colors.white) : null,
                      backgroundColor: Colors.deepPurple,
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple, fontSize: 16),
                    ),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        minimumSize: const Size(100, 36),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserRecommendationsScreen(
                              userId: user.id,
                              userName: user.name,
                            ),
                          ),
                        );
                      },
                      child: const Text("Ver Recomendaciones", 
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}

class UserRecommendationsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserRecommendationsScreen({super.key, required this.userId, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recomendaciones de $userName'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text('Aquí mostrarás las recomendaciones del usuario $userName.'),
      ),
    );
  }
}