import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  int? id;
  String? name; // Added name field
  String? fullName;
  String? username;
  String? email;
  String? profilePicture;
  String? bio;
  String? profession;
  bool? isBusiness;
  bool? isAdmin;
  List<String>? interests;
  bool? notificationsEnabled;
  Map<String, bool>? notificationPreferences;
  DateTime? createdAt;
  int? postsCount; // Added postsCount
  int? followersCount; // Added followersCount
  int? followingCount; // Added followingCount
  bool?
      isFollowed; // Added isFollowed to track if current user follows this user

  static StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) {
    print('👤 User.fromJson: Raw data: $data');
    print('👤 User.fromJson: Data type: ${data.runtimeType}');

    // Handle nested response structure
    dynamic userData = data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      userData = data['data'];
      print('👤 User.fromJson: Using nested data: $userData');
    }

    id = userData['id'];
    name = userData['name']; // Parse name
    fullName = userData['full_name'];
    username = userData['username'];
    email = userData['email'];
    profilePicture = userData['profile_picture'];
    bio = userData['bio'];
    profession = userData['profession'];
    isBusiness = userData['is_business'];
    isAdmin = userData['is_admin'];
    interests = userData['interests'] != null
        ? List<String>.from(userData['interests'])
        : null;
    notificationsEnabled = userData['notifications_enabled'];
    notificationPreferences = userData['notification_preferences'] != null
        ? Map<String, bool>.from(userData['notification_preferences'])
        : null;
    createdAt = userData['created_at'] != null
        ? DateTime.parse(userData['created_at'])
        : null;
    postsCount = userData['posts_count']; // Parse postsCount
    followersCount = userData['followers_count']; // Parse followersCount
    followingCount = userData['following_count']; // Parse followingCount
    isFollowed = userData['is_followed']; // Parse isFollowed

    print(
        '👤 User.fromJson: Parsed user - ID: $id, Name: $fullName, Username: $username');
  }

  @override
  toJson() => {
        "id": id,
        "name": name, // Serialize name
        "full_name": fullName,
        "username": username,
        "email": email,
        "profile_picture": profilePicture,
        "bio": bio,
        "profession": profession,
        "is_business": isBusiness,
        "is_admin": isAdmin,
        "interests": interests,
        "notifications_enabled": notificationsEnabled,
        "notification_preferences": notificationPreferences,
        "created_at": createdAt?.toIso8601String(),
        "posts_count": postsCount, // Serialize postsCount
        "followers_count": followersCount, // Serialize followersCount
        "following_count": followingCount, // Serialize followingCount
        "is_followed": isFollowed, // Serialize isFollowed
      };
}
