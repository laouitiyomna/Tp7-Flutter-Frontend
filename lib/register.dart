import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'user.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<User> register(String email, String password) async {
    final res = await http.post(
      Uri.parse("$baseUrl/register"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );
    if (res.statusCode == 200 && res.body.isNotEmpty) {
      return User.fromMap(jsonDecode(res.body));
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await register(_emailController.text, _passwordController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! You can log in now.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not register (email already used?)',
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
                        "Register",
                        style: GoogleFonts.pacifico(fontSize: 36, color: Colors.black45),
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
                        onTap: () => Navigator.pop(context),
                        child: const Text(
                          "Already have an Account?",
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
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: handleRegister,
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