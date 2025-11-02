import 'package:shared_preferences/shared_preferences.dart';

class NotificationCounterService {
  static const String _counterKey = 'notification_counter';
  static const String _lastResetKey = 'notification_last_reset';

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final counter = prefs.getInt(_counterKey) ?? 0;
      print('🔔 NotificationCounterService: Initialized with counter: $counter');
    } catch (e) {
      print('❌ NotificationCounterService: Error initializing: $e');
    }
  }

  Future<int> getCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_counterKey) ?? 0;
    } catch (e) {
      print('❌ NotificationCounterService: Error getting count: $e');
      return 0;
    }
  }

  Future<void> incrementCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_counterKey) ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt(_counterKey, newCount);
      print('🔔 NotificationCounterService: Count incremented to: $newCount');
    } catch (e) {
      print('❌ NotificationCounterService: Error incrementing count: $e');
    }
  }

  Future<void> resetCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_counterKey, 0);
      await prefs.setString(_lastResetKey, DateTime.now().toIso8601String());
      print('🔔 NotificationCounterService: Count reset to 0');
    } catch (e) {
      print('❌ NotificationCounterService: Error resetting count: $e');
    }
  }

  Future<DateTime?> getLastResetTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastResetString = prefs.getString(_lastResetKey);
      if (lastResetString != null) {
        return DateTime.parse(lastResetString);
      }
      return null;
    } catch (e) {
      print('❌ NotificationCounterService: Error getting last reset time: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_counterKey);
      await prefs.remove(_lastResetKey);
      print('🔔 NotificationCounterService: All data cleared');
    } catch (e) {
      print('❌ NotificationCounterService: Error clearing data: $e');
    }
  }
}
