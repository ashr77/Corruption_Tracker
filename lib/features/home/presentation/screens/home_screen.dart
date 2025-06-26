import 'package:flutter/material.dart';
import 'package:awaj/features/home/presentation/screens/feed_screen.dart';
import 'package:awaj/features/home/presentation/screens/friends_screen.dart';
import 'package:awaj/features/home/presentation/screens/profile_screen.dart';
import 'package:awaj/features/home/presentation/screens/messages_screen.dart';
import 'package:awaj/features/home/presentation/screens/stories_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Screens for regular users
  final List<Widget> _userScreens = [
    const FeedScreen(),
    const ProfileScreen(),
  ];

  // Screens for admin users
  final List<Widget> _adminScreens = [
    const FeedScreen(),
    const ProfileScreen(),
    const Center(child: Text('Users Management - Coming Soon')),
    const Center(child: Text('Analytics - Coming Soon')),
    const Center(child: Text('Problems Management - Coming Soon')),
  ];

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final userRole = args != null && args['role'] != null ? args['role'] as String : 'user';
    final isAdmin = userRole == 'admin' || userRole == 'administrator';
    
    // Use appropriate screens list based on user role
    final screens = isAdmin ? _adminScreens : _userScreens;

    return Scaffold(
      body: Row(
        children: [
          if (isAdmin)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Column(
                  children: [
                    const Text('CorruptWatch', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.feed),
                  label: Text('Feed'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person),
                  label: Text('Users'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.bar_chart),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.warning),
                  label: Text('Problems'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings),
                  label: Text('Settings'),
                ),
              ],
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: () => _logout(context),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                screens[_currentIndex],
                if (userRole == 'admin')
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Center(
                        child: Text(
                          'ADMIN MODE: You have the power to remove posts and users.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                if (userRole == 'administrator')
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.deepPurple.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: const Center(
                        child: Text(
                          'ADMINISTRATION MODE: You have the power to remove posts and users.',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isAdmin ? null : BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 