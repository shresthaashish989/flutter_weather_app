import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'weather_screen.dart';

class RegisterScreen extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  RegisterScreen({super.key});

  void register(BuildContext context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => const WeatherScreen(),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration failed: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
          TextField(controller: passwordController, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => register(context), child: const Text("Register")),
        ]),
      ),
    );
  }
}
