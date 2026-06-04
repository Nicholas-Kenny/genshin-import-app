import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '';
  String password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "496744771200-gklgjer92qodhl48siq7e42c9ro482eu.apps.googleusercontent.com",
    scopes: ['email'],
  );

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((account) {
      if (account != null) _processGoogleToken(account);
    });
  }

  Future<void> _processGoogleToken(GoogleSignInAccount googleUser) async {
    setState(() => _isLoading = true);
    final auth = await googleUser.authentication;
    final token = auth.idToken ?? auth.accessToken;
    if (token != null) {
      bool success = await ApiService.loginWithGoogle(token);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', googleUser.displayName ?? 'Traveler');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
        return;
      }
    }
    setState(() => _isLoading = false);
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      bool success = await ApiService.login(username, password);
      setState(() => _isLoading = false);
      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.bg2,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/login_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.bg2.withOpacity(0.8),
                        AppColors.bg2,
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Genshin Import",
                            style: textTheme.displayLarge?.copyWith(
                              fontSize: 32,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Welcome back, Traveler!",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.highlight,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: "Enter your Username",
                      onSaved: (v) => username = v!,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Password",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      hint: "Password must be minimum 8 characters",
                      obscure: !_isPasswordVisible,
                      isPassword: true,
                      onSaved: (v) => password = v!,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.highlight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : Text(
                                "Login",
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppColors.bg2,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "or",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryText.withOpacity(0.38),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: SizedBox(
                        width: 280,
                        child: kIsWeb
                            ? web.renderButton()
                            : _buildGoogleButton(context),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryText.withOpacity(0.7),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: Text(
                            "Sign Up",
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.highlight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    bool obscure = false,
    bool isPassword = false,
    Function(String?)? onSaved,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      obscureText: obscure,
      style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryText.withOpacity(0.38),
          fontSize: 14,
        ),
        filled: true,
        fillColor: AppColors.primaryBlue,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.primaryText.withOpacity(0.38),
                ),
                onPressed: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
      ),
      validator: (v) => v == null || v.isEmpty
          ? 'Required field'
          : (isPassword && v.length < 8 ? 'Min 8 chars' : null),
      onSaved: onSaved,
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _googleSignIn.signIn(),
        icon: Image.network(
          'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
          height: 20,
        ),
        label: Text(
          "Continue with Google",
          style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryText.withOpacity(0.24)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
