import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:awaj/core/constants/extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCard extends StatelessWidget {
  final String postId;
  final String title;
  final String content;
  final String authorName;
  final String authorId;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;
  final bool showActions;
  final String? mediaType;
  final bool isAdmin;
  final int? downvotes;

  const PostCard({
    super.key,
    required this.postId,
    required this.title,
    required this.content,
    required this.authorName,
    required this.authorId,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.imageUrl,
    this.showActions = false,
    this.mediaType,
    this.isAdmin = false,
    this.downvotes,
  });

  Future<void> _handleVote(BuildContext context, bool isUpvote) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to vote.')),
      );
      return;
    }
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(postRef);
      if (!snapshot.exists) return;
      final data = snapshot.data()!;
      final upvotedBy = List<String>.from(data['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(data['downvotedBy'] ?? []);
      String uid = user.uid;
      if (isUpvote) {
        if (upvotedBy.contains(uid)) return; // Already upvoted
        upvotedBy.add(uid);
        downvotedBy.remove(uid);
      } else {
        if (downvotedBy.contains(uid)) return; // Already downvoted
        downvotedBy.add(uid);
        upvotedBy.remove(uid);
      }
      transaction.update(postRef, {
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
        'upvotes': upvotedBy.length,
        'downvotes': downvotedBy.length,
      });
    });
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final TextEditingController _commentController = TextEditingController();
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: SizedBox(
            height: 400,
            child: Column(
              children: [
                const SizedBox(height: 8),
                const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .doc(postId)
                        .collection('comments')
                        .orderBy('timestamp', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('No comments yet.'));
                      }
                      final comments = snapshot.data!.docs;
                      return ListView.builder(
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index].data() as Map<String, dynamic>;
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(comment['text'] ?? ''),
                            subtitle: Text(comment['authorName'] ?? 'Anonymous'),
                            trailing: Text(comment['timestamp']?.toString().substring(0, 16) ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () async {
                          final text = _commentController.text.trim();
                          if (text.isEmpty) return;
                          final user = FirebaseAuth.instance.currentUser;
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('comments')
                              .add({
                            'text': text,
                            'authorId': user?.uid ?? 'anonymous',
                            'authorName': user?.email ?? 'Anonymous',
                            'timestamp': DateTime.now().toIso8601String(),
                          });
                          _commentController.clear();
                          // Optionally update commentsCount in post doc
                          final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
                          postRef.update({
                            'commentsCount': FieldValue.increment(1),
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deletePost(BuildContext context) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    // Delete all comments
    final comments = await postRef.collection('comments').get();
    for (final doc in comments.docs) {
      await doc.reference.delete();
    }
    // Delete post
    await postRef.delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isOwnPost = user != null && user.uid == authorId;
    return Card(
      color: Colors.grey[50],
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.black12,
                  child: Text(
                    (authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.isNotEmpty ? title : 'Untitled Post',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (content.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            content,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                    ],
                  ),
                ),
                if (isOwnPost || isAdmin)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete_post') {
                        await _deletePost(context);
                      }
                    },
                    itemBuilder: (context) => [
                      if (isOwnPost || isAdmin)
                        const PopupMenuItem(
                          value: 'delete_post',
                          child: Text('Delete Post', style: TextStyle(color: Colors.red)),
                        ),
                    ],
                  ),
              ],
            ),
            if (imageUrl != null && (mediaType == null || mediaType == 'image')) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (imageUrl != null && mediaType == 'video') ...[
              const SizedBox(height: 10),
              Container(
                height: 180,
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.videocam, size: 48, color: Colors.black54),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_upward, color: Colors.green, size: 24),
                  onPressed: () => _handleVote(context, true),
                  tooltip: 'Upvote',
                ),
                Text('$likes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
                IconButton(
                  icon: const Icon(Icons.arrow_downward, color: Colors.red, size: 24),
                  onPressed: () => _handleVote(context, false),
                  tooltip: 'Downvote',
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Comment',
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              title: Text('Comments ($comments)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              children: [
                Container(
                  color: Colors.grey[100],
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                      final commentDocs = snapshot.data!.docs;
                      return Column(
                        children: [
                          for (final doc in commentDocs)
                            _CommentTile(
                              commentId: doc.id,
                              data: doc.data() as Map<String, dynamic>,
                              postId: postId,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            child: _AddCommentField(postId: postId),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (authorName.isNotEmpty ? authorName : 'Anonymous'),
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                Text(timestamp.fromNow(), style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final String commentId;
  final Map<String, dynamic> data;
  final String postId;
  const _CommentTile({required this.commentId, required this.data, required this.postId});

  Future<void> _handleVote(BuildContext context, bool isUpvote) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final commentRef = FirebaseFirestore.instance.collection('posts').doc(postId).collection('comments').doc(commentId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(commentRef);
      if (!snapshot.exists) return;
      final commentData = snapshot.data()!;
      final upvotedBy = List<String>.from(commentData['upvotedBy'] ?? []);
      final downvotedBy = List<String>.from(commentData['downvotedBy'] ?? []);
      String uid = user.uid;
      if (isUpvote) {
        if (upvotedBy.contains(uid)) return;
        upvotedBy.add(uid);
        downvotedBy.remove(uid);
      } else {
        if (downvotedBy.contains(uid)) return;
        downvotedBy.add(uid);
        upvotedBy.remove(uid);
      }
      transaction.update(commentRef, {
        'upvotedBy': upvotedBy,
        'downvotedBy': downvotedBy,
        'upvotes': upvotedBy.length,
        'downvotes': downvotedBy.length,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.person)),
      title: Text(data['text'] ?? ''),
      subtitle: Row(
        children: [
          Text('Upvotes: ${data['upvotes'] ?? 0}'),
          const SizedBox(width: 8),
          Text('Downvotes: ${data['downvotes'] ?? 0}'),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_upward, size: 18),
            onPressed: () => _handleVote(context, true),
            tooltip: 'Upvote',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_downward, size: 18),
            onPressed: () => _handleVote(context, false),
            tooltip: 'Downvote',
          ),
        ],
      ),
    );
  }
}

class _AddCommentField extends StatefulWidget {
  final String postId;
  const _AddCommentField({required this.postId});
  @override
  State<_AddCommentField> createState() => _AddCommentFieldState();
}

class _AddCommentFieldState extends State<_AddCommentField> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .add({
      'text': text,
      'authorId': user?.uid ?? 'anonymous',
      'authorName': user?.email ?? 'Anonymous',
      'timestamp': DateTime.now().toIso8601String(),
      'upvotes': 0,
      'downvotes': 0,
      'upvotedBy': [],
      'downvotedBy': [],
    });
    setState(() {
      _isSubmitting = false;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Add a comment...',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _isSubmitting
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: _controller.text.trim().isEmpty ? null : _submit,
              ),
      ],
    );
  }
} 