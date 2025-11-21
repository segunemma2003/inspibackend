import 'package:nylo_framework/nylo_framework.dart';
import 'user.dart';
import 'category.dart';

class Post extends Model {
  int? id;
  int? userId;
  int? categoryId;
  String? caption;
  String? mediaUrl;
  String? mediaType;
  String? thumbnailUrl;
  String? location;
  bool? isPublic;
  int? likesCount;
  int? savesCount;
  int? commentsCount;
  int? sharesCount;
  bool? isLiked;
  bool? isSaved;
  DateTime? createdAt;
  // Ads and analytics fields
  bool? isAds; // Whether post is an ad (visible to everyone)
  int? viewsCount; // Total views
  int? impressionsCount; // Total impressions
  int? reachCount; // Total reach
  User? user;
  Category? category;
  List<Tag>? tags;
  List<User>? taggedUsers;

  static StorageKey key = "post";

  Post() : super(key: key);

  Post.fromJson(dynamic data) : super(key: key) {
    id = data['id'];
    userId = data['user_id'];
    categoryId = data['category_id'];
    caption = data['caption'];
    mediaUrl = data['media_url'];
    mediaType = data['media_type'];
    thumbnailUrl = data['thumbnail_url'];
    location = data['location'];
    isPublic = data['is_public'];
    likesCount = data['likes_count'];
    savesCount = data['saves_count'];
    commentsCount = data['comments_count'];
    sharesCount = data['shares_count'];
    isLiked = data['is_liked'];
    isSaved = data['is_saved'];
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
    isAds = data['is_ads'] ?? false;
    viewsCount = data['views_count'] ?? 0;
    impressionsCount = data['impressions_count'] ?? 0;
    reachCount = data['reach_count'] ?? 0;
    user = data['user'] != null ? User.fromJson(data['user']) : null;
    category =
        data['category'] != null ? Category.fromJson(data['category']) : null;
    tags = data['tags'] != null
        ? (data['tags'] as List).map((tag) => Tag.fromJson(tag)).toList()
        : null;
    taggedUsers = data['tagged_users'] != null
        ? (data['tagged_users'] as List)
            .map((user) => User.fromJson(user))
            .toList()
        : null;
  }

  @override
  toJson() {
    return {
      "id": id,
      "user_id": userId,
      "category_id": categoryId,
      "caption": caption,
      "media_url": mediaUrl,
      "media_type": mediaType,
      "thumbnail_url": thumbnailUrl,
      "location": location,
      "is_public": isPublic,
      "likes_count": likesCount,
      "saves_count": savesCount,
      "comments_count": commentsCount,
      "shares_count": sharesCount,
      "is_liked": isLiked,
      "is_saved": isSaved,
      "created_at": createdAt?.toIso8601String(),
      "is_ads": isAds,
      "views_count": viewsCount,
      "impressions_count": impressionsCount,
      "reach_count": reachCount,
      "user": user?.toJson(),
      "category": category?.toJson(),
      "tags": tags?.map((tag) => tag.toJson()).toList(),
      "tagged_users": taggedUsers?.map((user) => user.toJson()).toList(),
    };
  }
}

class Tag extends Model {
  int? id;
  String? name;
  String? slug;
  int? usageCount;

  static StorageKey key = "tag";

  Tag() : super(key: key);

  Tag.fromJson(dynamic data) : super(key: key) {
    id = data['id'];
    name = data['name'];
    slug = data['slug'];
    usageCount = data['usage_count'];
  }

  @override
  toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "usage_count": usageCount,
      };
}
