import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/image_service.dart';
import 'auth_controller.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidoController = TextEditingController();
  final TextEditingController edadController = TextEditingController();

  File? selectedImage;

  final ImageService _imageService = ImageService();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF7B1FA2),
              Color(0xFF4A148C),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Card(
                  color: Colors.white.withOpacity(0.85),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Registro",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 36,
                              ),
                        ),
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await _imageService.pickImageFromGallery();
                            if (pickedFile != null) {
                              setState(() {
                                selectedImage = pickedFile;
                              });
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.deepPurple, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepPurple.withOpacity(0.3),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.deepPurple.shade50,
                              backgroundImage: selectedImage != null
                                  ? FileImage(selectedImage!)
                                  : null,
                              child: selectedImage == null
                                  ? const Icon(Icons.person, size: 60, color: Colors.deepPurple)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.lock),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: nombreController,
                          decoration: const InputDecoration(
                            labelText: "Nombre",
                            prefixIcon: Icon(Icons.person),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: apellidoController,
                          decoration: const InputDecoration(
                            labelText: "Apellido",
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: edadController,
                          decoration: const InputDecoration(
                            labelText: "Edad",
                            prefixIcon: Icon(Icons.cake),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 36),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
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
                                        fotoFile: selectedImage,
                                        context: context,
                                      );
                                },
                          child: authState is AsyncLoading
                              ? const CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                )
                              : const Text(
                                  "Registrarse",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}