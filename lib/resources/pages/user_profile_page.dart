import 'package:flutter/material.dart';
import 'package:flutter_app/resources/widgets/other_profile_widget.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart'; // Assuming you have a User model
import '/app/networking/user_api_service.dart'; // Assuming you have a UserApiService

class UserProfilePage extends NyStatefulWidget {
  static RouteView path = ('/user-profile', (context) => UserProfilePage());

  UserProfilePage({super.key}) : super(child: () => _UserProfilePageState());

  @override
  createState() => _UserProfilePageState();
}

class _UserProfilePageState extends NyPage<UserProfilePage> {
  User? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;
  int? _userId; // Make userId nullable and read from context

  @override
  get init => () async {
        print('👤 UserProfilePage: Initializing with data: ${widget.data()}');
        _userId =
            widget.data()['userId']; // Retrieve userId from Nylo's route data
        print('👤 UserProfilePage: Retrieved userId: $_userId');
        if (_userId == null) {
          print('❌ UserProfilePage: User ID is null');
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
          showToast(title: "Error", description: "User ID not provided.");
          return;
        }
        await _loadUserProfile();
      };

  Future<void> _loadUserProfile() async {
    print('👤 UserProfilePage: Loading user profile for ID: $_userId');
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      // Fetch basic user profile
      print('👤 UserProfilePage: Calling getUser API...');
      final userResponse =
          await api<UserApiService>((request) => request.getUser(_userId!));

      print('👤 UserProfilePage: API response: $userResponse');
      if (userResponse != null) {
        print('👤 UserProfilePage: User profile loaded successfully');
        print('👤 UserProfilePage: User ID: ${userResponse.id}');
        print('👤 UserProfilePage: User name: ${userResponse.fullName}');
        print('👤 UserProfilePage: User username: ${userResponse.username}');
        print('👤 UserProfilePage: User email: ${userResponse.email}');
        print(
            '👤 UserProfilePage: User profile picture: ${userResponse.profilePicture}');
        setState(() {
          _userProfile = userResponse;
        });
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
      // Specifically handle the 404 from getUserStats gracefully.
      // If getUser (basic profile) succeeded but getUserStats failed, _userProfile will still have basic data.
      if (_userProfile == null) {
        // Only set hasError if basic profile also failed
        setState(() {
          _hasError = true;
        });
      }
      showToast(title: "Error", description: "Failed to load user profile.");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary),
              ),
            )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 50, color: Colors.grey[400]),
                      SizedBox(height: 10),
                      Text('Failed to load user profile',
                          style: TextStyle(color: Colors.grey[600])),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadUserProfile,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : (_userProfile != null
                  ? (() {
                      print(
                          '👤 UserProfilePage: Creating OtherProfile with user: ${_userProfile!.id}');
                      return OtherProfile(user: _userProfile!);
                    })()
                  : Center(
                      child: Text('User not found',
                          style: TextStyle(color: Colors.grey[600])),
                    )),
    );
  }
}
