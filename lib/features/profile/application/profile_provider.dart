import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileProvider = FutureProvider<ProfileData>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) {
    throw Exception("No hay usuario logueado.");
  }

  final response = await Supabase.instance.client
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();

  return ProfileData(
    nombre: response['nombre'] ?? '',
    apellido: response['apellido'] ?? '',
    email: response['email'] ?? '',
    edad: response['edad'] ?? 0,
    fotoUrl: response['foto_url'],
  );
});

class ProfileData {
  final String nombre;
  final String apellido;
  final String email;
  final int edad;
  final String? fotoUrl;

  ProfileData({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.edad,
    this.fotoUrl,
  });
}