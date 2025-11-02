import 'package:nylo_framework/nylo_framework.dart';

class CacheConfig {
  static const Duration userFeedCache = Duration(minutes: 2);
  static const Duration userStatsCache = Duration(minutes: 5);
  static const Duration businessAccountsCache = Duration(minutes: 3);
  static const Duration popularTagsCache = Duration(minutes: 10);
  static const Duration trendingPostsCache = Duration(minutes: 5);
  static const Duration notificationCountCache = Duration(minutes: 1);
  static const Duration categoriesCache = Duration(hours: 1);
  static const Duration interestsCache = Duration(hours: 1);
  static const Duration userProfileCache = Duration(minutes: 5);
  static const Duration postDetailsCache = Duration(minutes: 5);
  static const Duration searchResultsCache = Duration(minutes: 3);
  static const Duration followersCache = Duration(minutes: 3);
  static const Duration followingCache = Duration(minutes: 3);
  static const Duration savedPostsCache = Duration(minutes: 3);
  static const Duration likedPostsCache = Duration(minutes: 3);
  static const Duration businessBookingsCache = Duration(minutes: 3);

  static const String userFeedKey = "user_feed";
  static const String userStatsKey = "user_stats";
  static const String businessAccountsKey = "business_accounts";
  static const String popularTagsKey = "popular_tags";
  static const String trendingPostsKey = "trending_posts";
  static const String notificationCountKey = "notification_count";
  static const String categoriesKey = "categories";
  static const String interestsKey = "interests";
  static const String currentUserKey = "current_user";
  static const String unreadCountKey = "unread_count";

  static Future<void> clearUserCache() async {
    await cache().clear(userFeedKey);
    await cache().clear(userStatsKey);
    await cache().clear(currentUserKey);
    await cache().clear(notificationCountKey);
    await cache().clear(unreadCountKey);
  }

  static Future<void> clearPostCache() async {
    try {

      await cache().clear(trendingPostsKey);

      final keys = await cache().documents();
      for (String key in keys) {
        if (key.startsWith('feed_') ||
            key.startsWith('post_details_') ||
            key.startsWith('user_posts_') ||
            key.startsWith('saved_posts') ||
            key.startsWith('liked_posts') ||
            key.startsWith('user_liked_posts_') ||
            key.startsWith('user_saved_posts_') ||
            key.startsWith('tagged_posts_') ||
            key.startsWith('posts_by_tags_')) {
          await cache().clear(key);
        }
      }

      print('✅ Post cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing post cache: $e');
    }
  }

  static Future<void> clearBusinessCache() async {
    await cache().clear(businessAccountsKey);
    await cache().clear("business_bookings");
  }

  static Future<void> clearSearchCache() async {

    final keys = await cache().documents();
    for (String key in keys) {
      if (key.startsWith('search_') ||
          key.startsWith('users_') ||
          key.startsWith('posts_by_tags_') ||
          key.startsWith('users_by_interests_') ||
          key.startsWith('users_by_profession_')) {
        await cache().clear(key);
      }
    }
  }

  static Future<void> clearAllCache() async {
    await cache().flush();
  }

  static Future<void> preloadEssentialData() async {

  }

  static Future<void> optimizeCacheForOffline() async {

  }
}
