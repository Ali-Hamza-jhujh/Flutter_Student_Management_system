import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontened/secreens/appbar.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:frontened/secreens/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController fname = TextEditingController();
  final TextEditingController lname = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final t = 2 * math.pi;
  bool register = false;
  String get URLAPI => dotenv.env['BACKENED_API'] ?? '';
  Future<void> RegisterUser() async {
    if (fname.text.isEmpty ||
        lname.text.isEmpty ||
        email.text.isEmpty ||
        password.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: const Text("All fields required")));
      return;
    }
    setState(() => register = true);
    try {
      final response = await http.post(
        Uri.parse("http://$URLAPI:3000/users/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fname': fname.text,
          'lname': lname.text,
          'email': email.text,
          'password': password.text,
        }),
      );
      print("Sending to: http://$URLAPI:5000/users/register");
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Register successfully")));
        Navigator.pushNamed(context, AppRouter.login);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response.body}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (r) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $r"),backgroundColor: Colors.red,));
    } finally {
      if (mounted) setState(() => register = false);
    }
  }

  @override
  void dispose() {
    fname.dispose();
    lname.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Register"),
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
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFF1976D2),
                            child: const Icon(
                              Icons.person_add,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Create New Account",
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: fname,
                            decoration: InputDecoration(
                              hintText: "Enter your first name",
                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "First Name",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: lname,
                            decoration: InputDecoration(
                              hintText: "Enter your last name",
                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "Last Name",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: Icon(
                                Icons.person_2,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: email,
                            decoration: InputDecoration(
                              hintText: "Enter your email",
                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: Icon(
                                Icons.email,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.03,
                          ),
                          TextFormField(
                            style: const TextStyle(color: Colors.white),
                            controller: password,
                            obscureText: true,
                            decoration: InputDecoration(
                              hintText: "Enter your password",

                              hintStyle: const TextStyle(color: Colors.white38),
                              labelText: "Password",
                              labelStyle: const TextStyle(
                                color: Colors.white70,
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.white70,
                              ),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Colors.white30,
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
                              onPressed: register
                                  ? null
                                  : RegisterUser, // ✅ Disable while loading
                              icon: register
                                  ? const SizedBox(
                                      // ✅ Show spinner
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.how_to_reg,
                                      color: Colors.white,
                                    ),
                              label: Text(
                                register
                                    ? "Registering..."
                                    : "Register", 
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
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRouter.login);
                            },
                            child: Text(
                              "Already have an account? Login",
                              style: TextStyle(color: Colors.white70),
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
        ],
      ),
    );
  }
}
