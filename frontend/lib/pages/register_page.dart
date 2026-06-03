import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String email = '';
  String password = '';
  bool _isLoading = false;

  void _register() async {
    // MENJALANKAN VALIDASI FORM
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);
      bool isSuccess = await ApiService.register(username, email, password);
      setState(() => _isLoading = false);

      if (!mounted) return;
      if (isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Register failed. Username/Email might be taken.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey, // Pasang form key untuk membaca validasi
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Genshin Import',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Join the Adventurer Guild!',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 40),

                // VALIDASI 1: Check Empty
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Username cannot be empty'
                      : null,
                  onSaved: (value) => username = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // VALIDASI 2: Email Pattern Check
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty)
                      return 'Email cannot be empty';
                    if (!value.contains('@') || !value.contains('.'))
                      return 'Enter a valid email address';
                    return null;
                  },
                  onSaved: (value) => email = value?.trim() ?? '',
                ),
                const SizedBox(height: 16),

                // VALIDASI 3: Minimum Character Length Check
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password cannot be empty';
                    if (value.length < 6)
                      return 'Password must be at least 6 characters';
                    return null;
                  },
                  onSaved: (value) => password = value ?? '',
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Already have an account? Log In"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
