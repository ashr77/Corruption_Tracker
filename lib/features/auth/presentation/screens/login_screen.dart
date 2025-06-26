import 'package:flutter/material.dart';
import 'package:awaj/core/constants/app_colors.dart';
import 'package:awaj/core/constants/constants.dart';
import 'package:awaj/features/auth/presentation/screens/create_account_screen.dart';
import 'package:awaj/features/home/presentation/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Translation map
const translations = {
  'en': {
    'title': 'Corruption Control',
    'signUp': 'Sign Up',
    'signIn': 'Sign In',
    'continueAsGuest': 'Continue as Guest',
    'userLogin': 'Sign in as User',
    'adminLogin': 'Sign in as Admin',
    'adminstrationLogin': 'Sign in as Administrator',
    'language': 'Language',
    'signInOptions': 'Sign In Options',
    'required': 'This field is required',
    'userId': 'User ID',
    'password': 'Password',
    'invalidAdmin': 'Invalid admin credentials',
    'invalidAdministrator': 'Invalid administrator credentials',
    'home': 'Home',
    'logout': 'Logout',
    'welcome': 'Welcome!',
    'forgotPassword': 'Forgot Password',
    'resetLinkSent': 'Password reset link sent! (mock)',
    'sendResetLink': 'Send Reset Link',
    'cancel': 'Cancel',
    'email': 'Email',
  },
  'bn': {
    'title': 'দুর্নীতি নিয়ন্ত্রণ',
    'signUp': 'নিবন্ধন করুন',
    'signIn': 'সাইন ইন',
    'continueAsGuest': 'অতিথি হিসাবে চালিয়ে যান',
    'userLogin': 'ইউজার হিসেবে সাইন ইন',
    'adminLogin': 'অ্যাডমিন হিসেবে সাইন ইন',
    'adminstrationLogin': 'প্রশাসক হিসেবে সাইন ইন',
    'language': 'ভাষা',
    'signInOptions': 'সাইন ইন অপশন',
    'required': 'এই ঘরটি পূরণ করা আবশ্যক',
    'userId': 'ইউজার আইডি',
    'password': 'পাসওয়ার্ড',
    'invalidAdmin': 'ভুল অ্যাডমিন তথ্য',
    'invalidAdministrator': 'ভুল প্রশাসক তথ্য',
    'home': 'হোম',
    'logout': 'লগআউট',
    'welcome': 'স্বাগতম!',
    'forgotPassword': 'পাসওয়ার্ড ভুলে গেলে',
    'resetLinkSent': 'পাসওয়ার্ড রিসেট লিংক পাঠানো হয়েছে! (মক্)',
    'sendResetLink': 'পাসওয়ার্ড রিসেট লিংক পাঠান',
    'cancel': 'বাতিল',
    'email': 'ইমেইল',
  },
};

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _lang = 'en';

  String t(String key) => translations[_lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        title: Text(
          t('title'), 
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _lang,
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.blue),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
                DropdownMenuItem(value: 'bn', child: Text('BN', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
              ],
              onChanged: (val) => setState(() => _lang = val!),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.white,
                child: Icon(Icons.shield, size: 60, color: Colors.blue),
              ),
              const SizedBox(height: 24),
              Text(
                t('title'),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/createAccount');
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text(
                        t('signUp'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SignInOptionScreen(lang: _lang),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        side: const BorderSide(color: Colors.blue, width: 2),
                      ),
                      child: Text(
                        t('signIn'),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/home');
                      },
                      child: Text(
                        t('continueAsGuest'),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInOptionScreen extends StatefulWidget {
  final String lang;
  const SignInOptionScreen({super.key, required this.lang});

  @override
  State<SignInOptionScreen> createState() => _SignInOptionScreenState();
}

class _SignInOptionScreenState extends State<SignInOptionScreen> {
  late String _lang;
  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
  }
  String t(String key) => translations[_lang]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        title: Text(
          t('signInOptions'),
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _lang,
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.blue),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
                DropdownMenuItem(value: 'bn', child: Text('BN', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500))),
              ],
              onChanged: (val) => setState(() => _lang = val!),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SignInFormScreen(lang: _lang, role: 'user'),
                ));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue,
                elevation: 0,
              ),
              child: Text(
                t('userLogin'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SignInFormScreen(lang: _lang, role: 'admin'),
                ));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue,
                elevation: 0,
              ),
              child: Text(
                t('adminLogin'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SignInFormScreen(lang: _lang, role: 'administrator'),
                ));
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(220, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                backgroundColor: Colors.blue.shade50,
                foregroundColor: Colors.blue,
                elevation: 0,
              ),
              child: Text(
                t('adminstrationLogin'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Test credentials for different user types
// You can create these accounts using the sign-up form or use these pre-created ones:

// Normal User (create via sign-up):
// Email: user@example.com
// Password: userpass123

// Admin User:
// Email: admin@awaj.com
// Password: admin123

// Administrator User:
// Email: superadmin@awaj.com
// Password: super123

class SignInFormScreen extends StatefulWidget {
  final String lang;
  final String role; // 'user', 'admin', 'administrator'
  const SignInFormScreen({super.key, required this.lang, required this.role});

  @override
  State<SignInFormScreen> createState() => _SignInFormScreenState();
}

class _SignInFormScreenState extends State<SignInFormScreen> {
  late String _lang;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _error;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
  }

  String t(String key) => translations[_lang]?[key] ?? key;

  Future<void> _signIn() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid);
      final userDoc = await userDocRef.get();
      String userRole = 'user';
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userRole = (userData['role'] ?? 'user').toString().toLowerCase();
      } else {
        await userDocRef.set({
          'email': email,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        });
      }
      // Normalize role check
      if (userRole != widget.role.toLowerCase()) {
        await FirebaseAuth.instance.signOut();
        setState(() => _isLoading = false);
        setState(() => _error = 'You are not authorized to sign in as ${widget.role}.');
        return;
      }
      if (mounted) {
        if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin', arguments: {'role': userRole});
        } else if (userRole == 'administrator') {
          Navigator.pushReplacementNamed(context, '/administrator', arguments: {'role': userRole});
        } else {
          Navigator.pushReplacementNamed(context, '/home', arguments: {'role': userRole});
        }
      }
    } catch (e) {
      String msg = 'An error occurred: $e';
      setState(() => _error = msg);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _logout() {
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t('forgotPassword')),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: t('email'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t('cancel')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text(t('sendResetLink')),
            ),
          ],
        );
      },
    );
    
    if (result != null && result.isNotEmpty) {
      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: result);
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text('Password reset link sent to $result'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              content: Text('Error sending reset link: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black87),
        title: Text(
          t('signIn'), 
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _lang,
              underline: const SizedBox(),
              icon: const Icon(Icons.language, color: Colors.blue),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('EN', style: TextStyle(color: Colors.black87))),
                DropdownMenuItem(value: 'bn', child: Text('BN', style: TextStyle(color: Colors.black87))),
              ],
              onChanged: (val) => setState(() => _lang = val!),
            ),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: t('email'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.email, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v == null || v.isEmpty ? t('required') : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: t('password'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black87,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (v) => v == null || v.isEmpty ? t('required') : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: Text(
                      t('forgotPassword') + '?',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            t('signIn'),
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AuthHomeScreen extends StatelessWidget {
  final String lang;
  final VoidCallback onLogout;
  const AuthHomeScreen({super.key, required this.lang, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'en' ? 'Home' : 'হোম'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
            tooltip: lang == 'en' ? 'Logout' : 'লগআউট',
          ),
        ],
      ),
      body: Center(
        child: Text(lang == 'en' ? 'Welcome!' : 'স্বাগতম!'),
      ),
    );
  }
} 