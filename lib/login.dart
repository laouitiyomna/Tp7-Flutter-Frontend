import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'user.dart';
import 'register.dart';
import 'dashboard.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<User> save(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    // Si les identifiants sont faux, Spring renvoie 200 avec un corps vide
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return User.fromMap(jsonDecode(res.body));
    } else {
      throw Exception('Failed to login.');
    }
  }

  Future<void> handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await save(_emailController.text, _passwordController.text);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not log in with these credentials!',
            style: TextStyle(fontSize: 16.0),
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Container(
                  width: 340.0,
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBDE6C6),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Login",
                        style: GoogleFonts.oswald(
                          fontWeight: FontWeight.w700,
                          fontSize: 50,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("Email",
                            style: GoogleFonts.roboto(fontSize: 24, color: Colors.purple)),
                      ),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return 'Email is empty';
                          return null;
                        },
                        style: TextStyle(fontSize: 22, color: Colors.blueGrey.shade700),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text("Password",
                            style: GoogleFonts.roboto(fontSize: 24, color: Colors.purple)),
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (String? value) {
                          if (value == null || value.isEmpty) return 'Password is empty';
                          return null;
                        },
                        style: TextStyle(fontSize: 22, color: Colors.blueGrey.shade700),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 40),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const Register()),
                          );
                        },
                        child: const Text(
                          "Don't have an Account?",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  height: 90,
                  width: 90,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(233, 65, 82, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: handleSignIn,
                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}