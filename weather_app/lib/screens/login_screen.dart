import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart';
import 'weather_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  LoginScreen({super.key});

  void login(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => const WeatherScreen(),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => login(context), child: const Text("Login")),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
            child: const Text("Don't have an account? Register"),
          )
        ]),
      ),
    );
  }
}
