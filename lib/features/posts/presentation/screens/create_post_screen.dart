import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _mediaFile;
  Uint8List? _webImageBytes;
  String? _mediaType; // 'image' or 'video'
  bool _isLoading = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia(ImageSource source, {required bool isVideo}) async {
    final picker = ImagePicker();
    final picked = isVideo
        ? await picker.pickVideo(source: source)
        : await picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      if (kIsWeb && !isVideo) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _mediaFile = null;
          _mediaType = 'image';
        });
      } else {
        setState(() {
          _mediaFile = File(picked.path);
          _webImageBytes = null;
          _mediaType = isVideo ? 'video' : 'image';
        });
      }
    }
  }

  Future<String?> _uploadMedia(File file, String type) async {
    final ext = type == 'image' ? 'jpg' : 'mp4';
    final ref = FirebaseStorage.instance.ref().child('post_media/${DateTime.now().millisecondsSinceEpoch}.$ext');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _createPost() async {
    if (_contentController.text.trim().isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some content or select media')),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });
    String? mediaUrl;
    if (_mediaFile != null && _mediaType != null) {
      mediaUrl = await _uploadMedia(_mediaFile!, _mediaType!);
    }
    await FirebaseFirestore.instance.collection('posts').add({
      'content': _contentController.text.trim(),
      'mediaUrl': mediaUrl,
      'mediaType': _mediaType,
      'timestamp': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
      'upvotedBy': [],
      'downvotedBy': [],
      'commentsCount': 0,
      'authorId': 'anonymous',
      'authorName': 'Anonymous',
    });
    setState(() {
      _isLoading = false;
      _contentController.clear();
      _mediaFile = null;
      _mediaType = null;
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post created successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _createPost,
              child: const Text(
                'Post',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Your Name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            if ((_mediaFile != null && _mediaType == 'image') || (_webImageBytes != null && _mediaType == 'image'))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: kIsWeb && _webImageBytes != null
                    ? Image.memory(_webImageBytes!, height: 120)
                    : _mediaFile != null
                        ? Image.file(_mediaFile!, height: 120)
                        : const SizedBox.shrink(),
              ),
            if (_mediaFile != null && _mediaType == 'video')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: const Icon(Icons.videocam, size: 48), // Placeholder for video preview
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Add to your post:'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => _pickMedia(ImageSource.gallery, isVideo: false),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam),
                  onPressed: () => _pickMedia(ImageSource.gallery, isVideo: true),
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 