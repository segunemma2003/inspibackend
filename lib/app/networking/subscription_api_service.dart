import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/config/decoders.dart';
import 'package:flutter_app/app/networking/dio/interceptors/bearer_auth_interceptor.dart';

class SubscriptionApiService extends NyApiService {
  SubscriptionApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Map<Type, Interceptor> get interceptors => {
        BearerAuthInterceptor: BearerAuthInterceptor(),
      };

  /// Get subscription plan information (deprecated - use getSubscriptionPlans instead)
  Future<Map<String, dynamic>?> getPlanInfo() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/subscription/plan-info"),
      cacheKey: "subscription_plan_info",
      cacheDuration: const Duration(hours: 24),
    );
  }

  /// Get all active subscription plans
  Future<Map<String, dynamic>?> getSubscriptionPlans() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/subscription/plans"),
      cacheKey: "subscription_plans",
      cacheDuration: const Duration(hours: 24),
    );
  }

  /// Get current subscription status
  Future<Map<String, dynamic>?> getSubscriptionStatus() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/subscription/status"),
      cacheKey: "subscription_status",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Upgrade to professional plan with Apple Pay receipt
  Future<Map<String, dynamic>?> upgradeToProfessional({
    required String appleReceipt,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/subscription/upgrade", data: {
        "apple_receipt": appleReceipt,
      }),
    );
  }

  /// Renew subscription with Apple Pay receipt
  Future<Map<String, dynamic>?> renewSubscription({
    required String appleReceipt,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/subscription/renew", data: {
        "apple_receipt": appleReceipt,
      }),
    );
  }

  /// Validate Apple receipt (standalone)
  Future<Map<String, dynamic>?> validateAppleReceipt({
    required String receiptData,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.post("/subscription/validate-apple-receipt", data: {
        "receipt_data": receiptData,
      }),
    );
  }

  /// Cancel subscription
  Future<Map<String, dynamic>?> cancelSubscription() async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/subscription/cancel"),
    );
  }
}


