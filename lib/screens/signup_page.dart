import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_data.dart';
import 'home_screen.dart'; // ✅ Make sure this import points to your real homepage

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();

  void _signUp() {
    if (_formKey.currentState!.validate()) {
      final auth = Provider.of<AuthData>(context, listen: false);
      final success = auth.signUp(
        _username.text.trim(),
        _password.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created!')),
        );

        // ✅ Navigate to HomeScreen instead of EventListPage
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username already exists')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter a username' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: (val) =>
                    val == null || val.length < 4 ? 'Min 4 characters' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Create Account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}