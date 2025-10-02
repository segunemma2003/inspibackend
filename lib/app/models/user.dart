import 'package:nylo_framework/nylo_framework.dart';

class User extends Model {
  int? id;
  String? name;
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

  static StorageKey key = 'user';

  User() : super(key: key);

  User.fromJson(dynamic data) {
    id = data['id'];
    name = data['name'];
    fullName = data['full_name'];
    username = data['username'];
    email = data['email'];
    profilePicture = data['profile_picture'];
    bio = data['bio'];
    profession = data['profession'];
    isBusiness = data['is_business'];
    isAdmin = data['is_admin'];
    interests =
        data['interests'] != null ? List<String>.from(data['interests']) : null;
    notificationsEnabled = data['notifications_enabled'];
    notificationPreferences = data['notification_preferences'] != null
        ? Map<String, bool>.from(data['notification_preferences'])
        : null;
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
  }

  @override
  toJson() => {
        "id": id,
        "name": name,
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
      };
}
