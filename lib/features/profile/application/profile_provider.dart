import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/profile/application/current_user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Modelo de perfil de usuario
class Profile {
  final String nombre;
  final String apellido;
  final String email;
  final int edad;
  final String? fotoUrl;

  Profile({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.edad,
    this.fotoUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      nombre: map['nombre'] ?? '',
      apellido: map['apellido'] ?? '',
      email: map['email'] ?? '',
      edad: map['edad'] ?? 0,
      fotoUrl: map['foto_url'],
    );
  }
}

/// Repositorio para acceder al perfil
class ProfileRepository {
  Future<Profile> getUserProfileById(String userId) async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    if (data == null) {
      throw Exception("Perfil no encontrado.");
    }

    return Profile.fromMap(data);
  }
}

/// Provider del repositorio
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

/// Provider del perfil del usuario actual
final userProfileProvider = FutureProvider<Profile>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;
  if (user == null) throw Exception("No hay usuario logueado.");
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfileById(user.id);
});
