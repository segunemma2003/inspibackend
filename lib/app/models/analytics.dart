import 'package:nylo_framework/nylo_framework.dart';

class UserAnalytics extends Model {
  int? userId;
  int? totalPosts;
  int? adsPosts;
  int? totalViews;
  int? totalImpressions;
  int? totalReach;
  int? totalLikes;
  int? totalSaves;
  int? totalShares;
  int? totalComments;
  int? totalFollowers;
  int? totalInteractions;
  double? averageEngagementRate;

  static StorageKey key = 'user_analytics';

  UserAnalytics() : super(key: key);

  UserAnalytics.fromJson(dynamic data) : super(key: key) {
    if (data == null) return;

    Map<String, dynamic> analyticsData;
    if (data is Map<String, dynamic>) {
      analyticsData = data;
    } else if (data is Map) {
      analyticsData = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    if (analyticsData.containsKey('data')) {
      analyticsData = analyticsData['data'];
    }

    userId = analyticsData['user_id'];
    totalPosts = analyticsData['total_posts'] ?? 0;
    adsPosts = analyticsData['ads_posts'] ?? 0;
    totalViews = analyticsData['total_views'] ?? 0;
    totalImpressions = analyticsData['total_impressions'] ?? 0;
    totalReach = analyticsData['total_reach'] ?? 0;
    totalLikes = analyticsData['total_likes'] ?? 0;
    totalSaves = analyticsData['total_saves'] ?? 0;
    totalShares = analyticsData['total_shares'] ?? 0;
    totalComments = analyticsData['total_comments'] ?? 0;
    totalFollowers = analyticsData['total_followers'] ?? 0;
    totalInteractions = analyticsData['total_interactions'] ?? 0;
    averageEngagementRate =
        analyticsData['average_engagement_rate']?.toDouble() ?? 0.0;
  }

  @override
  toJson() => {
        "user_id": userId,
        "total_posts": totalPosts,
        "ads_posts": adsPosts,
        "total_views": totalViews,
        "total_impressions": totalImpressions,
        "total_reach": totalReach,
        "total_likes": totalLikes,
        "total_saves": totalSaves,
        "total_shares": totalShares,
        "total_comments": totalComments,
        "total_followers": totalFollowers,
        "total_interactions": totalInteractions,
        "average_engagement_rate": averageEngagementRate,
      };
}

class PostAnalytics extends Model {
  int? postId;
  int? views;
  int? impressions;
  int? reach;
  int? likes;
  int? saves;
  int? shares;
  int? comments;
  int? uniqueViews;
  int? totalInteractions;
  double? engagementRate;

  static StorageKey key = 'post_analytics';

  PostAnalytics() : super(key: key);

  PostAnalytics.fromJson(dynamic data) : super(key: key) {
    if (data == null) return;

    Map<String, dynamic> analyticsData;
    if (data is Map<String, dynamic>) {
      analyticsData = data;
    } else if (data is Map) {
      analyticsData = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    if (analyticsData.containsKey('data')) {
      analyticsData = analyticsData['data'];
    }

    postId = analyticsData['post_id'];
    views = analyticsData['views'] ?? 0;
    impressions = analyticsData['impressions'] ?? 0;
    reach = analyticsData['reach'] ?? 0;
    likes = analyticsData['likes'] ?? 0;
    saves = analyticsData['saves'] ?? 0;
    shares = analyticsData['shares'] ?? 0;
    comments = analyticsData['comments'] ?? 0;
    uniqueViews = analyticsData['unique_views'] ?? 0;
    totalInteractions = analyticsData['total_interactions'] ?? 0;
    engagementRate = analyticsData['engagement_rate']?.toDouble() ?? 0.0;
  }

  @override
  toJson() => {
        "post_id": postId,
        "views": views,
        "impressions": impressions,
        "reach": reach,
        "likes": likes,
        "saves": saves,
        "shares": shares,
        "comments": comments,
        "unique_views": uniqueViews,
        "total_interactions": totalInteractions,
        "engagement_rate": engagementRate,
      };
}


