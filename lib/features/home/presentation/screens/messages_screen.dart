import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for messages
    final List<Map<String, dynamic>> mockMessages = [
      {
        'name': 'John Doe',
        'lastMessage': 'Hey, how are you?',
        'timestamp': '2:30 PM',
        'unreadCount': 2,
      },
      {
        'name': 'Jane Smith',
        'lastMessage': 'See you tomorrow!',
        'timestamp': '1:45 PM',
        'unreadCount': 0,
      },
      {
        'name': 'Mike Johnson',
        'lastMessage': 'Thanks for the help!',
        'timestamp': '12:20 PM',
        'unreadCount': 1,
      },
      {
        'name': 'Sarah Wilson',
        'lastMessage': 'Great meeting you!',
        'timestamp': '11:15 AM',
        'unreadCount': 0,
      },
      {
        'name': 'David Brown',
        'lastMessage': 'Happy birthday!',
        'timestamp': 'Yesterday',
        'unreadCount': 3,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Create new message
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: mockMessages.length,
        itemBuilder: (context, index) {
          final message = mockMessages[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[300],
              child: Text(
                message['name'][0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            title: Text(
              message['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              message['lastMessage'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message['timestamp'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (message['unreadCount'] > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${message['unreadCount']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              // TODO: Navigate to chat screen
            },
          );
        },
      ),
    );
  }
} 