import 'dart:io';

import 'package:awaj/core/constants/app_colors.dart';
import 'package:awaj/core/constants/constants.dart';
import 'package:awaj/core/utils/utils.dart';
import 'package:awaj/core/widgets/pick_image_widget.dart';
import 'package:awaj/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const translations = {
  'en': {
    'signUp': 'Sign Up',
    'fullName': 'Full Name',
    'email': 'Email',
    'userId': 'User ID',
    'phone': 'Phone',
    'nid': 'NID / Birth Certificate No',
    'dob': 'Date of Birth',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'role': 'Role',
    'normalUser': 'Normal User',
    'admin': 'Admin',
    'administration': 'Administration',
    'selectDob': 'Select your birth date',
    'alreadyAccount': 'Already have an account?',
    'signIn': 'Sign In',
    'required': 'This field is required',
    'unique': 'Must be unique',
    'emailInUse': 'Email already in use',
    'invalidEmail': 'Invalid email address',
    'weakPassword': 'Password is too weak',
    'unknownError': 'An unknown error occurred',
  },
  'bn': {
    'signUp': 'নিবন্ধন করুন',
    'fullName': 'পূর্ণ নাম',
    'email': 'ইমেইল',
    'userId': 'ইউজার আইডি',
    'phone': 'ফোন নম্বর',
    'nid': 'জাতীয় পরিচয়পত্র / জন্ম সনদ নম্বর',
    'dob': 'জন্ম তারিখ',
    'password': 'পাসওয়ার্ড',
    'confirmPassword': 'পাসওয়ার্ড নিশ্চিত করুন',
    'role': 'ভূমিকা',
    'normalUser': 'সাধারণ ব্যবহারকারী',
    'admin': 'অ্যাডমিন',
    'administration': 'প্রশাসন',
    'selectDob': 'জন্ম তারিখ নির্বাচন করুন',
    'alreadyAccount': 'ইতিমধ্যে একটি অ্যাকাউন্ট আছে?',
    'signIn': 'সাইন ইন',
    'required': 'এই ঘরটি পূরণ করা আবশ্যক',
    'unique': 'অবশ্যই ইউনিক হতে হবে',
    'emailInUse': 'ইমেইল ইতিমধ্যে ব্যবহার করা হয়েছে',
    'invalidEmail': 'বাধ্যত্বযুক্ত ইমেইল ঠিকানা',
    'weakPassword': 'পাসওয়ার্ড দুর্বল',
    'unknownError': 'অপরিতিত ত্রুটি ঘটেছে',
  },
};

final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  File? image;
  String _lang = 'en';
  DateTime? _dob;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _userIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String t(String key) => translations[_lang]![key]!;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _userIdController.dispose();
    _phoneController.dispose();
    _nidController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('selectDob'))),
      );
      return;
    }
    
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      // Store additional user info in Firestore
      try {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'fullName': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'userId': _userIdController.text.trim(),
          'phone': _phoneController.text.trim(),
          'nid': _nidController.text.trim(),
          'dob': _dob!.toIso8601String(),
          'role': 'user', // Default role for new users
          'createdAt': FieldValue.serverTimestamp(),
          'uid': userCredential.user!.uid,
        });
      } catch (e) {
        // If Firestore fails, still allow navigation
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'An error occurred: ${e.code} - ${e.message ?? e.toString()}';
      if (e.code == 'email-already-in-use') {
        msg = t('emailInUse');
      } else if (e.code == 'invalid-email') {
        msg = t('invalidEmail');
      } else if (e.code == 'weak-password') {
        msg = t('weakPassword');
      } else if (e.code == 'operation-not-allowed') {
        msg = 'Email/password accounts are not enabled. Please contact support.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.realWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.realWhiteColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.blackColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: AppColors.blackColor,
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
                DropdownMenuItem(value: 'en', child: Text('EN')),
                DropdownMenuItem(value: 'bn', child: Text('BN')),
              ],
              onChanged: (val) => setState(() => _lang = val!),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: Constants.defaultPadding,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Profile image picker
                GestureDetector(
                  onTap: () async {
                    final pickedImage = await pickImage();
                    if (pickedImage != null) {
                      setState(() {
                        image = pickedImage;
                      });
                    }
                  },
                  child: PickImageWidget(image: image),
                ),
                const SizedBox(height: 32),
                // Full name field
                TextFormField(
                  controller: _fullNameController,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('fullName'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.person, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('email'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.email, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // User ID field
                TextFormField(
                  controller: _userIdController,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('userId'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.account_circle, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Phone field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('phone'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // NID field
                TextFormField(
                  controller: _nidController,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('nid'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.badge, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Birth date selection
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: t('dob'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.black87),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  child: ListTile(
                    title: Text(
                      _dob != null
                          ? '${_dob!.day}/${_dob!.month}/${_dob!.year}'
                          : t('selectDob'),
                      style: const TextStyle(color: Colors.black87),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _dob = picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('password'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Confirm password field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: InputDecoration(
                    labelText: t('confirmPassword'),
                    labelStyle: const TextStyle(color: Colors.black87),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock, color: Colors.black87),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t('required');
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Create account button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blueColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
                            t('signUp'),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t('alreadyAccount')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        t('signIn'),
                        style: const TextStyle(
                          color: AppColors.blueColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
