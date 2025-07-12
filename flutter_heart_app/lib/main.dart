// ========================
// 📄 lib/main.dart
// ========================

import 'package:flutter/material.dart';
import 'package:flutter_heart_app_new/root/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_heart_app_new/providers/user_provider.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'amplifyconfiguration.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Amplify.addPlugin(AmplifyAuthCognito());
    await Amplify.configure(amplifyconfig);
  } catch (e) {
    safePrint('Amplify configure error: $e');
  }

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => UserProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Heart App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const Root(),
    );
  }
}
