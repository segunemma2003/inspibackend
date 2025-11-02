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
      isFollowed; // Added isFollowed to check if authenticated user is following this user

  static StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) {

    if (data == null) {

      return;
    }

    Map<String, dynamic> userData;
    if (data is Map<String, dynamic>) {
      userData = data;
    } else if (data is Map) {
      userData = Map<String, dynamic>.from(data);
    } else {

      return;
    }

    if (userData.containsKey('data')) {
      userData = userData['data'];

    }

    if (userData.containsKey('user')) {

      if (userData.containsKey('statistics') && userData['statistics'] is Map) {
        final stats = userData['statistics'] as Map<String, dynamic>;
        postsCount = stats['posts_count'] ?? 0;
        followersCount = stats['followers_count'] ?? 0;
        followingCount = stats['following_count'] ?? 0;

      }

      userData = userData['user'];

    } else {

      if (userData.containsKey('statistics') && userData['statistics'] is Map) {
        final stats = userData['statistics'] as Map<String, dynamic>;
        postsCount = stats['posts_count'] ?? 0;
        followersCount = stats['followers_count'] ?? 0;
        followingCount = stats['following_count'] ?? 0;

      } else {

        postsCount = userData['posts_count'] ?? 0;
        followersCount = userData['followers_count'] ?? 0;
        followingCount = userData['following_count'] ?? 0;

      }
    }

    id = userData['id'];
    name = userData['name']; // Parse name
    fullName = userData['full_name'];
    username = userData['username'];
    email = userData['email'];

    if (id == null) {

    }
    profilePicture = userData['profile_picture'];
    bio = userData['bio'];
    profession = userData['profession'];
    isBusiness = userData['is_business'];
    isAdmin = userData['is_admin'];
    interests = userData['interests'] != null
        ? (userData['interests'] as List).map((e) => e.toString()).toList()
        : null;
    notificationsEnabled = userData['notifications_enabled'];
    notificationPreferences = userData['notification_preferences'] != null
        ? Map<String, bool>.from(userData['notification_preferences'])
        : null;
    createdAt = userData['created_at'] != null
        ? DateTime.parse(userData['created_at'])
        : null;

    isFollowed = userData['is_followed'] ?? false; // Parse isFollowed

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
