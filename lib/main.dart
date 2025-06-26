import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awaj/config/routes/routes.dart';
import 'package:awaj/config/themes/app_theme.dart';
import 'package:awaj/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  print('Initializing Firebase...');
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
    // Direct fetch for debug
    final snapshot = await FirebaseFirestore.instance.collection('posts').get();
    print('Direct fetch: Found \\${snapshot.docs.length} posts');
    for (var doc in snapshot.docs) {
      print('Direct fetch post: ' + doc.data().toString());
    }
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awaj',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: Routes.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
