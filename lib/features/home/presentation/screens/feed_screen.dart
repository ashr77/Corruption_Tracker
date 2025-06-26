import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awaj/features/posts/presentation/widgets/post_card.dart';
import 'package:awaj/features/posts/presentation/screens/create_post_screen.dart';
import 'package:awaj/core/constants/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:awaj/features/home/presentation/screens/chat_with_professionals_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final TextEditingController _reportTitleController = TextEditingController();
  final TextEditingController _reportDetailsController = TextEditingController();
  File? _mediaFile;
  Uint8List? _webImageBytes;
  String? _mediaType; // 'image' or 'video'
  bool _isSubmitting = false;
  List<QueryDocumentSnapshot>? _webPostsCache;
  bool _webLoading = false;
  String? _webError;
  bool _showReportForm = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) _fetchWebPosts();
  }

  @override
  void dispose() {
    _reportTitleController.dispose();
    _reportDetailsController.dispose();
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

  Future<String?> _uploadMedia(dynamic fileOrBytes, String type) async {
    final ext = type == 'image' ? 'jpg' : 'mp4';
    final ref = FirebaseStorage.instance.ref().child('post_media/${DateTime.now().millisecondsSinceEpoch}.$ext');
    if (kIsWeb && fileOrBytes is Uint8List) {
      final uploadTask = ref.putData(fileOrBytes, SettableMetadata(contentType: type == 'image' ? 'image/jpeg' : 'video/mp4'));
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } else if (fileOrBytes is File) {
      final uploadTask = ref.putFile(fileOrBytes);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    }
    return null;
  }

  Future<void> _submitReport() async {
    final title = _reportTitleController.text.trim();
    final details = _reportDetailsController.text.trim();
    if (title.isEmpty || details.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and details are required.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    String? mediaUrl;
    if ((_mediaFile != null && _mediaType != null) || (_webImageBytes != null && _mediaType == 'image')) {
      mediaUrl = await _uploadMedia(kIsWeb ? _webImageBytes : _mediaFile, _mediaType!);
    }
    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'content': details,
      'mediaUrl': mediaUrl,
      'mediaType': _mediaType,
      'timestamp': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
      'upvotedBy': [],
      'downvotedBy': [],
      'commentsCount': 0,
      'authorId': user?.uid ?? 'anonymous',
      'authorName': user?.email ?? 'Anonymous',
    });
    setState(() {
      _isSubmitting = false;
      _reportTitleController.clear();
      _reportDetailsController.clear();
      _mediaFile = null;
      _webImageBytes = null;
      _mediaType = null;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted!')),
      );
    }
  }

  Future<void> _testFirestoreConnection() async {
    try {
      print('Testing Firestore connection...');
      final snapshot = await FirebaseFirestore.instance.collection('posts').limit(1).get();
      print('Firestore connection successful. Found ${snapshot.docs.length} posts.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore connection successful! Found ${snapshot.docs.length} posts.')),
      );
    } catch (e) {
      print('Firestore connection failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Firestore connection failed: $e')),
      );
    }
  }

  Future<void> _fetchWebPosts() async {
    setState(() {
      _webLoading = true;
      _webError = null;
    });
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .get();
      setState(() {
        _webPostsCache = snapshot.docs;
        _webLoading = false;
      });
    } catch (e) {
      setState(() {
        _webError = e.toString();
        _webLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userRole = args != null && args['role'] != null ? args['role'] as String : 'user';
    final isAdmin = userRole == 'admin' || userRole == 'administrator';

    return Scaffold(
      backgroundColor: AppColors.realWhiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.realWhiteColor,
        elevation: 0,
        title: const Text(
          'Report a Problem',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black),
            onPressed: () {}, // TODO: Language toggle
          ),
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.black),
            onPressed: _testFirestoreConnection,
            tooltip: 'Test Firestore Connection',
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible Report a Problem Card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: _showReportForm ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () => setState(() => _showReportForm = true),
                  child: const Text('Report an Issue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              secondChild: Card(
                color: AppColors.realWhiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.black12,
                            child: Icon(Icons.report, color: Colors.black54, size: 28),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Report an Issue',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _reportTitleController,
                        decoration: const InputDecoration(
                          hintText: 'Title',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _reportDetailsController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Describe the problem...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _isSubmitting ? null : () async {
                              await _submitReport();
                              setState(() => _showReportForm = false);
                            },
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Submit Report'),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => setState(() => _showReportForm = false),
                            child: const Text('Cancel'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32), // More space between submission and posts
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          if (kIsWeb)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  onPressed: () => setState(() {}),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ),
          // Newsfeed (platform-specific)
          Expanded(
            child: kIsWeb
                ? FutureBuilder<QuerySnapshot>(
                    key: UniqueKey(),
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('upvotes', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                const Text('Failed to load newsfeed.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No reports yet.'));
                      }
                      final posts = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index].data() as Map<String, dynamic>;
                          return PostCard(
                            postId: posts[index].id,
                            title: post['title'] ?? 'Untitled Post',
                            content: post['content'] ?? '',
                            authorName: post['authorName'] ?? 'Anonymous',
                            authorId: post['authorId'] ?? '',
                            timestamp: DateTime.tryParse(post['timestamp'] ?? '') ?? DateTime.now(),
                            likes: post['upvotes'] ?? 0,
                            downvotes: post['downvotes'] ?? 0,
                            comments: post['commentsCount'] ?? 0,
                            imageUrl: post['mediaUrl'],
                            showActions: true,
                            mediaType: post['mediaType'],
                            isAdmin: isAdmin,
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .orderBy('upvotes', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 48),
                                const SizedBox(height: 16),
                                const Text('Failed to load newsfeed.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => setState(() {}),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No reports yet.'));
                      }
                      final posts = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index].data() as Map<String, dynamic>;
                          return PostCard(
                            postId: posts[index].id,
                            title: post['title'] ?? 'Untitled Post',
                            content: post['content'] ?? '',
                            authorName: post['authorName'] ?? 'Anonymous',
                            authorId: post['authorId'] ?? '',
                            timestamp: DateTime.tryParse(post['timestamp'] ?? '') ?? DateTime.now(),
                            likes: post['upvotes'] ?? 0,
                            downvotes: post['downvotes'] ?? 0,
                            comments: post['commentsCount'] ?? 0,
                            imageUrl: post['mediaUrl'],
                            showActions: true,
                            mediaType: post['mediaType'],
                            isAdmin: isAdmin,
                          );
                        },
                      );
                    },
                  ),
          ),
          // Quick Actions Bar (always visible at the bottom)
          Container(
            color: AppColors.realWhiteColor,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatWithProfessionalsScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Chat with Professionals', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Emergency call
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Emergency Call', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 