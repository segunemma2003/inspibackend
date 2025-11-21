import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/networking/subscription_api_service.dart';
import 'package:flutter_app/app/networking/user_api_service.dart';
import 'package:flutter_app/app/services/auth_service.dart';

class SubscriptionService {
  /// Check if user has active professional subscription
  static bool isProfessional(User? user) {
    if (user == null) return false;
    if (user.isProfessional != true) return false;

    // Check if subscription is still valid
    if (user.subscriptionExpiresAt == null) return false;
    if (user.subscriptionExpiresAt!.isBefore(DateTime.now())) return false;
    if (user.subscriptionStatus != 'active') return false;

    return true;
  }

  /// Get subscription status for current user
  static Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.getSubscriptionStatus(),
      );
      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error getting subscription status: $e');
      return null;
    }
  }

  /// Get plan information (deprecated - use getSubscriptionPlans instead)
  static Future<Map<String, dynamic>?> getPlanInfo() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.getPlanInfo(),
      );
      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error getting plan info: $e');
      return null;
    }
  }

  /// Get all active subscription plans
  static Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.getSubscriptionPlans(),
      );
      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error getting subscription plans: $e');
      return null;
    }
  }

  /// Upgrade to professional with Apple receipt
  static Future<Map<String, dynamic>?> upgradeToProfessional({
    required String appleReceipt,
  }) async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.upgradeToProfessional(appleReceipt: appleReceipt),
      );

      if (response != null && response['success'] == true) {
        // Fetch updated user data from API to ensure we have the latest info
        try {
          final updatedUser = await api<UserApiService>(
            (request) => request.fetchCurrentUser(),
          );

          if (updatedUser != null) {
            // Update user in auth service storage
            await AuthService.instance.updateUserProfile(updatedUser.toJson());
          }
        } catch (e) {
          print('⚠️ SubscriptionService: Could not refresh user data: $e');
          // Continue anyway - the subscription is still activated
        }
      }

      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error upgrading to professional: $e');
      return null;
    }
  }

  /// Cancel subscription
  static Future<Map<String, dynamic>?> cancelSubscription() async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.cancelSubscription(),
      );
      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error cancelling subscription: $e');
      return null;
    }
  }

  /// Validate Apple receipt
  static Future<Map<String, dynamic>?> validateAppleReceipt({
    required String receiptData,
  }) async {
    try {
      final response = await api<SubscriptionApiService>(
        (request) => request.validateAppleReceipt(receiptData: receiptData),
      );
      return response;
    } catch (e) {
      print('❌ SubscriptionService: Error validating receipt: $e');
      return null;
    }
  }

  /// Check if subscription will expire soon
  static bool willExpireSoon(User? user) {
    if (user?.subscriptionExpiresAt == null) return false;
    final daysRemaining =
        user!.subscriptionExpiresAt!.difference(DateTime.now()).inDays;
    return daysRemaining <= 7 && daysRemaining > 0;
  }

  /// Get days remaining in subscription
  static int? getDaysRemaining(User? user) {
    if (user?.subscriptionExpiresAt == null) return null;
    final now = DateTime.now();
    if (user!.subscriptionExpiresAt!.isBefore(now)) return 0;
    return user.subscriptionExpiresAt!.difference(now).inDays;
  }
}
