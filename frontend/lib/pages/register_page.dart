import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  String username = '', email = '', password = '';
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);
      bool success = await ApiService.register(username, email, password);
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration Success! Please Login.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Failed!'),
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
                  height: 300,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/register_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, AppColors.bg2],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
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
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Join the Adventurer Guild!",
                        style: textTheme.bodyMedium?.copyWith(
                          color: AppColors.highlight,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Username",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      hint: "Enter Username",
                      isUsername: true,
                      onSaved: (v) => username = v!,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Email",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      hint: "Enter Email Address",
                      onSaved: (v) => email = v!,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Password",
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.primaryText.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildField(
                      hint: "Min. 8 characters",
                      isPassword: true,
                      onSaved: (v) => password = v!,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.highlight,
                        ),
                        child: Text(
                          "Sign Up",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.bg2,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Already have an account? Log In",
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryText.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String hint,
    bool isPassword = false,
    bool isUsername = false,
    Function(String?)? onSaved,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      obscureText: isPassword && !_isPasswordVisible,
      style: textTheme.bodyMedium?.copyWith(color: AppColors.primaryText),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryText.withOpacity(0.38),
        ),
        filled: true,
        fillColor: AppColors.primaryBlue,
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
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required field';
        if (isPassword && v.length < 8) return 'Min 8 chars';
        if (isUsername && !RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v)) {
          return 'No spaces or special characters allowed';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
