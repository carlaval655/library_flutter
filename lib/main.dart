import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_movie_tracker/features/auth/presentation/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:my_movie_tracker/core/routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://fasglprdodxnhmwlleyh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZhc2dscHJkb2R4bmhtd2xsZXloIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE4NTQ3OTAsImV4cCI6MjA2NzQzMDc5MH0.HyhOGzWJ-bjcJOXpwGl9cUaopbiQ4UzRKXmBxdaOrwc',
  );

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'My Movie Tracker',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routerConfig: router,
    );
  }
}