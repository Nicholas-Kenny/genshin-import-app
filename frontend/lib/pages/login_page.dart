import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Deteksi Web vs Android
import 'package:frontend/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web; // Widget Khusus Web

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

  // 1. Pindahkan inisialisasi GoogleSignIn ke tingkat class agar bisa di-listen
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: "496744771200-gklgjer92qodhl48siq7e42c9ro482eu.apps.googleusercontent.com",
    scopes: ['email'],
  );

  @override
  void initState() {
    super.initState();
    // 2. KRUSIAL UNTUK WEB: Saat renderButton sukses login, listener ini akan terpicu
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      if (account != null) {
        _processGoogleToken(account);
      }
    });
  }

  // 3. Fungsi utama yang mengirimkan token dari Google ke Node.js kamu
  Future<void> _processGoogleToken(GoogleSignInAccount googleUser) async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Mengakomodasi JWT (Android) maupun Access Token (Web)
      final String? token = googleAuth.idToken ?? googleAuth.accessToken;

      if (token != null) {
        bool isSuccess = await ApiService.loginWithGoogle(token);

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
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login ditolak oleh server backend.'), backgroundColor: Colors.red),
      );
    } catch (e) {
      print("Token Processing Error: $e");
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifikasi Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // 4. Ini adalah fungsi klik manual (Hanya dipakai untuk Mobile/Android)
  void _loginWithGoogleMobile() async {
    setState(() => _isLoading = true);
    try {
      await _googleSignIn.signIn(); 
      // Hasil suksesnya akan ditangkap otomatis oleh listener di initState
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // Fungsi Login Lokal (Tidak berubah)
  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      bool isSuccess = await ApiService.login(username, password);

      if (isSuccess) {
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

                // TOMBOL INTEGRASI EXTERNAL OAUTH LINTAS PLATFORM
                kIsWeb
                    ? web.renderButton() // Akan merender tombol resmi Google (Jika diakses via Chrome)
                    : SizedBox(          // Akan merender tombol custom emas kamu (Jika diakses via Android)
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _isLoading ? null : _loginWithGoogleMobile,
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