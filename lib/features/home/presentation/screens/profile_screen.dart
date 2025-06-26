import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awaj/features/posts/presentation/widgets/post_card.dart';
import 'package:flutter/foundation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? bio;
  String? profilePicUrl;
  int postCount = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    if (!mounted) return;
    setState(() {
      name = doc.data()?['fullName'] ?? user!.email;
      bio = doc.data() != null && doc.data()!.containsKey('bio') ? doc['bio'] : '';
      profilePicUrl = doc.data() != null && doc.data()!.containsKey('profilePicUrl') ? doc['profilePicUrl'] : null;
    });
    final posts = await FirebaseFirestore.instance.collection('posts').where('authorId', isEqualTo: user!.uid).get();
    if (!mounted) return;
    setState(() {
      postCount = posts.docs.length;
    });
  }

  void _editProfile() async {
    final nameController = TextEditingController(text: name);
    final bioController = TextEditingController(text: bio);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(labelText: 'Bio'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                'fullName': nameController.text.trim(),
                'bio': bioController.text.trim(),
              });
              if (!mounted) return;
              setState(() {
                name = nameController.text.trim();
                bio = bioController.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text('Not signed in.'));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: profilePicUrl != null ? NetworkImage(profilePicUrl!) : null,
                    child: profilePicUrl == null ? const Icon(Icons.person, size: 60, color: Colors.grey) : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name ?? user!.email!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    bio ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('Posts', postCount.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _editProfile,
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Your Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            kIsWeb
                ? FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('posts')
                        .where('authorId', isEqualTo: user!.uid)
                        .orderBy('timestamp', descending: true)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No reports yet.'));
                      }
                      final posts = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index].data() as Map<String, dynamic>;
                          return PostCard(
                            postId: posts[index].id,
                            title: post['title'] ?? '',
                            content: post['content'] ?? '',
                            authorName: post['authorName'] ?? 'Anonymous',
                            authorId: post['authorId'] ?? '',
                            timestamp: DateTime.tryParse(post['timestamp'] ?? '') ?? DateTime.now(),
                            likes: post['upvotes'] ?? 0,
                            comments: post['commentsCount'] ?? 0,
                            imageUrl: post['mediaUrl'],
                            showActions: true,
                            mediaType: post['mediaType'],
                            isAdmin: false,
                          );
                        },
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where('authorId', isEqualTo: user!.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No reports yet.'));
                      }
                      final posts = snapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index].data() as Map<String, dynamic>;
                          return PostCard(
                            postId: posts[index].id,
                            title: post['title'] ?? '',
                            content: post['content'] ?? '',
                            authorName: post['authorName'] ?? 'Anonymous',
                            authorId: post['authorId'] ?? '',
                            timestamp: DateTime.tryParse(post['timestamp'] ?? '') ?? DateTime.now(),
                            likes: post['upvotes'] ?? 0,
                            comments: post['commentsCount'] ?? 0,
                            imageUrl: post['mediaUrl'],
                            showActions: true,
                            mediaType: post['mediaType'],
                            isAdmin: false,
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
} 