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

  // Professional subscription fields
  bool? isProfessional;
  String? subscriptionStatus; // 'active', 'expired', 'cancelled'
  DateTime? subscriptionStartedAt;
  DateTime? subscriptionExpiresAt;
  String? subscriptionPaymentId;
  String? appleOriginalTransactionId;
  String? appleTransactionId;
  String? appleProductId;

  // Social links (Professional users only)
  String? website;
  String? bookingLink;
  String? whatsappLink;
  String? linkedinLink;
  String? instagramLink;
  String? tiktokLink;
  String? snapchatLink;
  String? facebookLink;
  String? twitterLink;

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

    if (id == null) {}
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

    // Parse professional subscription fields
    isProfessional = userData['is_professional'] ?? false;
    subscriptionStatus = userData['subscription_status'];
    subscriptionStartedAt = userData['subscription_started_at'] != null
        ? DateTime.parse(userData['subscription_started_at'])
        : null;
    subscriptionExpiresAt = userData['subscription_expires_at'] != null
        ? DateTime.parse(userData['subscription_expires_at'])
        : null;
    subscriptionPaymentId = userData['subscription_payment_id'];
    appleOriginalTransactionId = userData['apple_original_transaction_id'];
    appleTransactionId = userData['apple_transaction_id'];
    appleProductId = userData['apple_product_id'];

    // Parse social links
    website = userData['website'];
    bookingLink = userData['booking_link'];
    whatsappLink = userData['whatsapp_link'];
    linkedinLink = userData['linkedin_link'];
    instagramLink = userData['instagram_link'];
    tiktokLink = userData['tiktok_link'];
    snapchatLink = userData['snapchat_link'];
    facebookLink = userData['facebook_link'];
    twitterLink = userData['twitter_link'];
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
        "is_professional": isProfessional,
        "subscription_status": subscriptionStatus,
        "subscription_started_at": subscriptionStartedAt?.toIso8601String(),
        "subscription_expires_at": subscriptionExpiresAt?.toIso8601String(),
        "subscription_payment_id": subscriptionPaymentId,
        "apple_original_transaction_id": appleOriginalTransactionId,
        "apple_transaction_id": appleTransactionId,
        "apple_product_id": appleProductId,
        "website": website,
        "booking_link": bookingLink,
        "whatsapp_link": whatsappLink,
        "linkedin_link": linkedinLink,
        "instagram_link": instagramLink,
        "tiktok_link": tiktokLink,
        "snapchat_link": snapchatLink,
        "facebook_link": facebookLink,
        "twitter_link": twitterLink,
      };
}
