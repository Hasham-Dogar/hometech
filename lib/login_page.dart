import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Gradient colors matching thermostat page
  static const List<Color> _buttonGradient = [
    Color(0xFFB16CEA),
    Color(0xFFFF5E69),
  ];

  Widget _gradientButton({
    required String text,
    required VoidCallback? onPressed,
    Widget? icon,
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[icon, const SizedBox(width: 8)],
                      Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  String? _firebaseError;
  bool _isSigningIn = false;

  Future<void> _handleEmailLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _firebaseError = null;
      _isSigningIn = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _firebaseError =
              'Email not verified. A verification link has been sent to your email.';
        });
        await FirebaseAuth.instance.signOut();
        return;
      }
      if (mounted && user != null && user.emailVerified) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _firebaseError = e.message ?? 'Authentication failed';
      });
    } catch (e) {
      setState(() {
        _firebaseError = 'Error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true;
      _firebaseError = null;
    });

    try {
      if (kIsWeb) {
        // Web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Mobile
        await GoogleSignIn.instance.initialize(
          serverClientId:
              "727685610826-dn0aneka7p8s9ntjt66vljsj3lcqb324.apps.googleusercontent.com",
        );
        final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
            .authenticate();
        if (googleUser == null) {
          setState(() {
            _firebaseError = 'Google sign-in was cancelled.';
          });
          return;
        }
        final String? idToken = (await googleUser.authentication).idToken;
        if (idToken == null) {
          setState(() {
            _firebaseError = 'Failed to retrieve Google ID token.';
          });
          return;
        }
        final credential = GoogleAuthProvider.credential(idToken: idToken);
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } catch (error) {
      setState(() {
        _firebaseError = 'Google sign-in failed: ${error.toString()}';
      });
    } finally {
      setState(() {
        _isSigningIn = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
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
                  const SizedBox(height: 24),
                  _gradientButton(
                    text: 'Login',
                    onPressed: _handleEmailLogin,
                    loading: _isSigningIn,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _gradientButton(
                    text: 'Sign in with Google',
                    onPressed: _handleGoogleSignIn,
                    loading: _isSigningIn,
                    icon: Image.asset(
                      'assets/search.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                  if (_firebaseError != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _firebaseError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const SizedBox(height: 8),
                  Center(
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      elevation: 2,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _isSigningIn
                            ? null
                            : () {
                                Navigator.of(context).pushNamed('/signup');
                              },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'Sign Up',
                            style: const TextStyle(
                              color: Color(0xFFB16CEA),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
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
    super.dispose();
  }
}
