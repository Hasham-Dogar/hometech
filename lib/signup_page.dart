import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Gradient colors matching thermostat page
  static const List<Color> _buttonGradient = [
    Color(0xFFB16CEA),
    Color(0xFFFF5E69),
  ];

  Widget _gradientButton({
    required String text,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style:
            ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 2,
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ).copyWith(
              backgroundColor: MaterialStateProperty.all(Colors.transparent),
              elevation: MaterialStateProperty.all(0),
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _buttonGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            alignment: Alignment.center,
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String? _errorMessage;
  bool _isSigningUp = false;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _handleSignup() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill all fields.';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    if (password.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters long.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isSigningUp = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(); // Send verification email
        setState(() {
          _errorMessage =
              'A verification email has been sent to $email. Please verify before logging in.';
        });

        // Sign out after signup to prevent auto-login without verification
        await FirebaseAuth.instance.signOut();

        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'email-already-in-use') {
          _errorMessage =
              'This email is already registered. Please log in instead.';
        } else {
          _errorMessage = e.message ?? 'Signup failed.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSigningUp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  _gradientButton(
                    text: 'Sign Up',
                    onPressed: _handleSignup,
                    loading: _isSigningUp,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _isSigningUp
                        ? null
                        : () {
                            Navigator.of(
                              context,
                            ).pushReplacementNamed('/login');
                          },
                    child: const Text('Already have an account? Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
