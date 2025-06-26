import 'package:flutter/material.dart';

class ChatWithProfessionalsScreen extends StatelessWidget {
  const ChatWithProfessionalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Professionals'),
      ),
      body: const Center(
        child: Text(
          'Live chat with professionals coming soon!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
} 