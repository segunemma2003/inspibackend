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
    // print('👤 User: From Json: type of data: ${data.runtimeType}');

    // Handle case where data might be null or not a Map
    if (data == null) {
      // print('👤 User: Data is null, returning empty user');
      return;
    }

    // print('👤 User: Raw data: $data');

    // Convert to Map if it's not already
    Map<String, dynamic> userData;
    if (data is Map<String, dynamic>) {
      userData = data;
    } else if (data is Map) {
      userData = Map<String, dynamic>.from(data);
    } else {
      // print('👤 User: Data is not a Map, returning empty user');
      return;
    }

    // Handle nested 'data' wrapper
    if (userData.containsKey('data')) {
      userData = userData['data'];
      // print('👤 User: Extracted data from wrapper: $userData');
    }

    // Handle nested 'user' object (for responses like { "data": { "user": {...}, "statistics": {...} } })
    if (userData.containsKey('user')) {
      // print('👤 User: Found nested user object');

      // Handle statistics from nested format
      if (userData.containsKey('statistics') && userData['statistics'] is Map) {
        final stats = userData['statistics'] as Map<String, dynamic>;
        postsCount = stats['posts_count'] ?? 0;
        followersCount = stats['followers_count'] ?? 0;
        followingCount = stats['following_count'] ?? 0;
        // print(
        //     '👤 User: Parsed from nested statistics: postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount');
      }

      // Extract the actual user data
      userData = userData['user'];
      // print('👤 User: Extracted user data: $userData');
    } else {
      // print('👤 User: No nested user object, using direct data');

      // Handle statistics from direct format
      if (userData.containsKey('statistics') && userData['statistics'] is Map) {
        final stats = userData['statistics'] as Map<String, dynamic>;
        postsCount = stats['posts_count'] ?? 0;
        followersCount = stats['followers_count'] ?? 0;
        followingCount = stats['following_count'] ?? 0;
        // print(
        //     '👤 User: Parsed from direct statistics: postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount');
      } else {
        // Fallback to direct fields
        postsCount = userData['posts_count'] ?? 0;
        followersCount = userData['followers_count'] ?? 0;
        followingCount = userData['following_count'] ?? 0;
        // print(
        //     '👤 User: Parsed from direct fields: postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount');
      }
    }

    id = userData['id'];
    name = userData['name']; // Parse name
    fullName = userData['full_name'];
    username = userData['username'];
    email = userData['email'];

    // print('👤 User: Parsed id: $id, name: $name, username: $username');
    // print('👤 User: ID is null: ${id == null}');
    if (id == null) {
      // print('❌ User: ID is null! This will cause issues with profile loading');
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

    // Handle statistics from /me API response

    isFollowed = userData['is_followed'] ?? false; // Parse isFollowed

    // print(
    //     '👤 User: Final parsed postsCount: $postsCount, followersCount: $followersCount, followingCount: $followingCount, isFollowed: $isFollowed');
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
