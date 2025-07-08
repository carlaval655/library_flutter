import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/supabase/supabase_client.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) => AuthController());

class AuthController extends StateNotifier<bool> {
  AuthController() : super(false);

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      final response = await SupabaseManager.client.auth
          .signInWithPassword(email: email, password: password);

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login exitoso!")),
        );
        // TODO: Navegar al home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }
}