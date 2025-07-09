import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_movie_tracker/core/services/image_service.dart';
import 'package:my_movie_tracker/features/content_seen/presentation/content_seen_screen.dart';
import 'package:my_movie_tracker/features/profile/application/current_user_provider.dart';
import 'package:my_movie_tracker/features/profile/application/profile_provider.dart';
import 'package:my_movie_tracker/features/content_seen/application/movies_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>(
  (ref) => AuthController(ref),
);
final ImageService _imageService = ImageService();

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  AuthController(this.ref) : super(const AsyncData(null));

  Future<void> login({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();

    try {
      final res = await Supabase.instance.client.auth
          .signInWithPassword(email: email, password: password);

      if (res.user != null) {
        state = const AsyncData(null);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Login exitoso!")),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/home');
        });
      } else {
        throw Exception("Credenciales inválidas");
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String nombre,
    required String apellido,
    required int edad,
    File? fotoFile,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      final userId = res.user?.id;

      if (userId == null) {
        throw Exception("No se pudo registrar usuario");
      }

      /// Subir foto si se seleccionó
      String? fotoUrl;
      if (fotoFile != null) {
        fotoUrl = await _imageService.uploadProfileImage(fotoFile, userId);
      }

      /// Insertar en tabla profiles
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'email': email,
        'nombre': nombre,
        'apellido': apellido,
        'edad': edad,
        'foto_url': fotoUrl,
      });

      state = const AsyncData(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Registro exitoso!")),
      );
      if (res.session != null) {
  // Si el usuario quedó logueado automáticamente, lo deslogueamos para forzar login manual
  await Supabase.instance.client.auth.signOut();
}

WidgetsBinding.instance.addPostFrameCallback((_) {
  context.go('/login');
});
    } catch (e) {
      print("Error en registro: $e");
      state = AsyncError(e, StackTrace.current);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
final userId = Supabase.instance.client.auth.currentUser?.id;
if (userId != null) {
  ref.invalidate(moviesProvider(userId));
}
ref.invalidate(userProfileProvider);
ref.invalidate(currentUserProvider);

await Supabase.instance.client.auth.signOut();
context.go('/login');
  }
}
