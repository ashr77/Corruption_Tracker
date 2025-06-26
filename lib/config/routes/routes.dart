import 'package:flutter/material.dart';
import 'package:awaj/core/screens/error_screen.dart';
import 'package:awaj/features/auth/presentation/screens/create_account_screen.dart';
import 'package:awaj/features/posts/presentation/screens/create_post_screen.dart';
import 'package:awaj/features/home/presentation/screens/home_screen.dart';
import 'package:awaj/features/auth/presentation/screens/login_screen.dart';

class Routes {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/createAccount':
        return MaterialPageRoute(builder: (_) => const CreateAccountScreen());
      case '/createPost':
        return MaterialPageRoute(builder: (_) => const CreatePostScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const ErrorScreen(error: 'Page not found'),
        );
    }
  }

  Routes._();
}
