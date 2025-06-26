import 'package:flutter/material.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for friends
    final List<Map<String, dynamic>> mockFriends = [
      {
        'name': 'John Doe',
        'mutualFriends': 5,
        'imageUrl': null,
      },
      {
        'name': 'Jane Smith',
        'mutualFriends': 12,
        'imageUrl': null,
      },
      {
        'name': 'Mike Johnson',
        'mutualFriends': 3,
        'imageUrl': null,
      },
      {
        'name': 'Sarah Wilson',
        'mutualFriends': 8,
        'imageUrl': null,
      },
      {
        'name': 'David Brown',
        'mutualFriends': 15,
        'imageUrl': null,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockFriends.length,
        itemBuilder: (context, index) {
          final friend = mockFriends[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: Text(
                friend['name'][0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              friend['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${friend['mutualFriends']} mutual friends'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle confirm friend request
                  },
                  child: const Text('Confirm'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Handle delete friend request
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 