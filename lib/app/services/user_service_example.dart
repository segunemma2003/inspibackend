
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/user_service.dart';
import '/app/models/user.dart';

class ExampleWidget extends StatefulWidget {
  const ExampleWidget({super.key});

  @override
  State<ExampleWidget> createState() => _ExampleWidgetState();
}

class _ExampleWidgetState extends NyState<ExampleWidget> {
  User? _currentUser;

  @override
  get init => () async {
        await _loadUserData();
      };

  Future<void> _loadUserData() async {
    try {

      final user = await UserService.getCurrentUserWithAuthCheck();

      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        print('✅ User loaded: ${user.fullName}');
      }

    } catch (e) {
      print('❌ Error loading user: $e');

    }
  }

  Future<void> _refreshUserData() async {
    try {
      final user = await UserService.refreshCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        print('✅ User data refreshed: ${user.fullName}');
      }
    } catch (e) {
      print('❌ Error refreshing user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentUser?.fullName ?? 'Loading...'),
      ),
      body: Center(
        child: Column(
          children: [
            if (_currentUser != null) ...[
              Text('Welcome, ${_currentUser!.fullName}!'),
              Text('Username: @${_currentUser!.username}'),
            ] else ...[
              const Text('Loading user data...'),
            ],
            ElevatedButton(
              onPressed: _refreshUserData,
              child: const Text('Refresh User Data'),
            ),
          ],
        ),
      ),
    );
  }
}
