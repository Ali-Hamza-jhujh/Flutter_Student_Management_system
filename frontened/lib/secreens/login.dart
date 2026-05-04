import 'package:flutter/material.dart';
import 'package:frontened/secreens/appbar.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:frontened/secreens/router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool login = false;
  String get URLAPI => dotenv.env['BACKEND_API'] ?? '';
  Future<void> LoginUser() async {
    if (email.text.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("All fields required")));
      return;
    }
    if (URLAPI.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("API URL not configured"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => login = true);

    try {
      final response = await http.post(
        Uri.parse("http://$URLAPI:3000/users/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.text, 'password': password.text}),
      );

      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Login successfully")));
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('userId', data['userId']);
        await prefs.setString('fname', data['fname']);
        await prefs.setString('lname', data['lname']);
        await prefs.setString('role', data['role']);
        if (!mounted) return;
        final role = prefs.getString('role') ?? '';
        if (role == "admin") {
          if (!mounted) return;
          Navigator.pushNamed(context, AppRouter.students);
        } else {
          if (!mounted) return;
          Navigator.pushNamed(context, AppRouter.dashboard);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (r) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $r"), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => login = false);
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = 2 * math.pi;

    return Scaffold(
      appBar: MyAppBar(title: "Login"),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [
                  Color(0xFF071330),
                  Color(0xFF0D2550),
                  Color(0xFF1040A0),
                  Color(0xFF072550),
                ],
                begin: Alignment(math.sin(t) * 0.8, math.cos(t) * 0.8),
                end: Alignment(-math.sin(t) * 0.8, -math.cos(t) * 0.8),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              child: ClipRRect(
                // 1 opens
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  // 2 opens
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    // 3 opens
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Form(
                      // 4 opens
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 36,
                            backgroundColor: Color(0xFF1976D2),
                            child: Icon(
                              Icons.person_add,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),

                          const Text(
                            "Login Here",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white, // ← white text
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),

                          TextFormField(
                            controller: email,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.email,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),

                          TextFormField(
                            controller: password,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Enter your password",
                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: const Icon(
                                Icons.lock,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: login ? null : LoginUser,
                              icon: login
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.login,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                login ? "Logging in..." : "Login",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                            ),
                          ),

                          // ── Register Link ──
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.register);
                            },
                            child: const Text(
                              "Do not have an account? Register",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ), // 4 closes Form
                  ), // 3 closes Container
                ), // 2 closes BackdropFilter
              ), // 1 closes ClipRRect
            ),
          ),
        ],
      ),
    );
  }
}
