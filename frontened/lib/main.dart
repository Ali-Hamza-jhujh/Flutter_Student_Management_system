import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontened/secreens/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // ✅ Add this
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, 
      initialRoute: AppRouter.login,        
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}