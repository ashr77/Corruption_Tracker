// This is a helper script to create test users in Firestore
// You can run this once to set up test accounts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awaj/firebase_options.dart';

Future<void> createTestUsers() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  final firestore = FirebaseFirestore.instance;
  
  // Test users data
  final testUsers = [
    {
      'email': 'admin@awaj.com',
      'fullName': 'Admin User',
      'userId': 'admin001',
      'phone': '+880123456789',
      'nid': '1234567890123',
      'dob': '1990-01-01T00:00:00.000Z',
      'role': 'admin',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'email': 'superadmin@awaj.com',
      'fullName': 'Super Administrator',
      'userId': 'superadmin001',
      'phone': '+880987654321',
      'nid': '9876543210987',
      'dob': '1985-01-01T00:00:00.000Z',
      'role': 'administrator',
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'email': 'user@example.com',
      'fullName': 'Normal User',
      'userId': 'user001',
      'phone': '+880111222333',
      'nid': '1112223334444',
      'dob': '1995-01-01T00:00:00.000Z',
      'role': 'user',
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];
  
  try {
    for (final userData in testUsers) {
      // Create a document with a custom ID (email as ID for easy reference)
      await firestore
          .collection('users')
          .doc(userData['email'] as String)
          .set(userData);
      
      print('Created test user: ${userData['email']} with role: ${userData['role']}');
    }
    
    print('\nTest users created successfully!');
    print('\nTest Credentials:');
    print('1. Normal User: user@example.com / userpass123');
    print('2. Admin: admin@awaj.com / admin123');
    print('3. Administrator: superadmin@awaj.com / super123');
    print('\nNote: You need to create these accounts using the sign-up form first,');
    print('then manually update their roles in Firestore using the Firebase Console.');
    
  } catch (e) {
    print('Error creating test users: $e');
  }
}

// Uncomment the line below to run this script
// void main() => createTestUsers(); 