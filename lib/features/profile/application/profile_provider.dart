import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<Profile> getUserProfile() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      throw Exception("No hay sesión activa.");
    }

    final user = session.user;
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user.id)
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
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile();
});