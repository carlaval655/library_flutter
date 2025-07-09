import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerWidget {
  RegisterScreen({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Registro",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(labelText: "Nombre"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: apellidoController,
                    decoration: const InputDecoration(labelText: "Apellido"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: edadController,
                    decoration: const InputDecoration(labelText: "Edad"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: authState is AsyncLoading
                        ? null
                        : () {
                            ref
                                .read(authControllerProvider.notifier)
                                .register(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  nombre: nombreController.text.trim(),
                                  apellido: apellidoController.text.trim(),
                                  edad: int.tryParse(edadController.text) ?? 0,
                                  context: context,
                                );
                          },
                    child: authState is AsyncLoading
                        ? const CircularProgressIndicator()
                        : const Text("Registrarse"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}