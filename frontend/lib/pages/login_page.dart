import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);
      bool isSuccess = await ApiService.login(username, password);

      if (isSuccess) {
        // PERBAIKAN: Ikut simpan nama username agar ProfilePage bisa membacanya
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        setState(() => _isLoading = false);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      // Inisialisasi Google Sign In menggunakan Client ID dari Cloud Console tadi
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId:
            "546755253913-6nfosvt12r6ha3e7qmhlgqvsfsd8pmlf.apps.googleusercontent.com",
        scopes: ['email'],
      );

      // 1. Munculkan pop-up pilihan akun Google di HP
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser != null) {
        // 2. Ambil data autentikasinya
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // 3. Ekstrak idToken-nya
        final String? idToken = googleAuth.idToken;

        if (idToken != null) {
          // 4. Kirim idToken asli dari Google ini ke Backend Express kamu
          bool isSuccess = await ApiService.loginWithGoogle(idToken);

          if (isSuccess) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(
              'username',
              googleUser.displayName ?? 'Google Traveler',
            );

            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
            return;
          }
        }
      }

      // Jika batal atau gagal
      setState(() => _isLoading = false);
    } catch (e) {
      print("Google Sign-In Error: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Google Sign-In Error: $e'),
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
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Genshin Import',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Welcome back, Traveler!',
                  style: TextStyle(color: Color(0xFFD4AF37)),
                ),
                const SizedBox(height: 40),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your username'
                      : null,
                  onSaved: (value) => username = value ?? '',
                ),
                const SizedBox(height: 16),

                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter your password'
                      : null,
                  onSaved: (value) => password = value ?? '',
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // TOMBOL INTEGRASI EXTERNAL OAUTH
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 30,
                      color: Color(0xFFD4AF37),
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD4AF37)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
