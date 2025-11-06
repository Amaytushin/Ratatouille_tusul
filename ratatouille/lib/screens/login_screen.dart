import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _imageSlide;
  late final Animation<Offset> _titleSlide;
  late final Animation<Offset> _fieldsSlide;
  late final Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _imageSlide = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3, curve: Curves.easeOut)));

    _titleSlide = Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)));

    _fieldsSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)));

    _buttonSlide = Tween<Offset>(begin: const Offset(0, 2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1, curve: Curves.easeOut)));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedTextField({required String hint, required IconData icon, bool obscure = false}) {
    return SlideTransition(
      position: _fieldsSlide,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SlideTransition(
                position: _imageSlide,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/linguini.jpg',
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _titleSlide,
                child: const Text(
                  'Ratatouille',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF4C1D95),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildAnimatedTextField(hint: 'И-майл', icon: Icons.email_outlined),
              _buildAnimatedTextField(hint: 'Нууц үг', icon: Icons.lock_outline, obscure: true),
              const SizedBox(height: 24),
              SlideTransition(
                position: _buttonSlide,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6D28D9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SlideTransition(
                position: _buttonSlide,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    "Don't have an account? Sign up",
                    style: TextStyle(
                      color: Color(0xFF4C1D95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
