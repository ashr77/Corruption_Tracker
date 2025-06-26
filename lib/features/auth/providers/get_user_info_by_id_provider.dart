import 'package:flutter_riverpod/flutter_riverpod.dart';

// Placeholder provider - will be implemented with Firebase later
final getUserInfoByIdProvider = FutureProvider.family<String, String>((ref, userId) async {
  // TODO: Implement Firebase user fetching
  await Future.delayed(const Duration(milliseconds: 500));
  return 'User $userId';
}); 