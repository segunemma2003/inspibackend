/* Cache Configuration
|--------------------------------------------------------------------------
| Comprehensive caching system for optimal performance
| Learn more: https://nylo.dev/docs/6.x/configuration
|-------------------------------------------------------------------------- */

import 'package:nylo_framework/nylo_framework.dart';

class CacheConfig {
  // Cache durations for different types of data
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

  // Cache keys for different data types
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

  // Cache management methods
  static Future<void> clearUserCache() async {
    await cache().clear(userFeedKey);
    await cache().clear(userStatsKey);
    await cache().clear(currentUserKey);
    await cache().clear(notificationCountKey);
    await cache().clear(unreadCountKey);
  }

  static Future<void> clearPostCache() async {
    await cache().clear(trendingPostsKey);
    await cache().clear("saved_posts");
    await cache().clear("liked_posts");
  }

  static Future<void> clearBusinessCache() async {
    await cache().clear(businessAccountsKey);
    await cache().clear("business_bookings");
  }

  static Future<void> clearSearchCache() async {
    // Clear all search-related cache
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

  // Performance optimization methods
  static Future<void> preloadEssentialData() async {
    // Preload categories and interests as they change rarely
    // This can be called during app initialization
  }

  static Future<void> optimizeCacheForOffline() async {
    // Implement offline cache optimization
  }
}
