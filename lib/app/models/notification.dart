import 'package:nylo_framework/nylo_framework.dart';
import 'user.dart';
import 'post.dart';

class Notification extends Model {
  int? id;
  int? userId;
  int? fromUserId;
  int? postId;
  String? type;
  String? title;
  String? message;
  bool? isRead;
  DateTime? readAt;
  DateTime? createdAt;
  User? fromUser;
  Post? post;

  static StorageKey key = "notification";

  Notification() : super(key: key);

  Notification.fromJson(dynamic data) : super(key: key) {
    id = data['id'];
    userId = data['user_id'];
    fromUserId = data['from_user_id'];
    postId = data['post_id'];
    type = data['type'];
    title = data['title'];
    message = data['message'];
    isRead = data['is_read'];
    readAt = data['read_at'] != null ? DateTime.parse(data['read_at']) : null;
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
    fromUser =
        data['from_user'] != null ? User.fromJson(data['from_user']) : null;
    post = data['post'] != null ? Post.fromJson(data['post']) : null;
  }

  @override
  toJson() {
    return {
      "id": id,
      "user_id": userId,
      "from_user_id": fromUserId,
      "post_id": postId,
      "type": type,
      "title": title,
      "message": message,
      "is_read": isRead,
      "read_at": readAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "from_user": fromUser?.toJson(),
      "post": post?.toJson(),
    };
  }
}
