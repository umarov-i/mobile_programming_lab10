import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // AppScope creates the ONE classifier at start-up and closes it on shutdown.
  runApp(const AppScope(child: ClassifierApp()));
}

class ClassifierApp extends StatelessWidget {
  const ClassifierApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teach It, Ship It',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const WelcomeScreen(),
    );
  }
}
