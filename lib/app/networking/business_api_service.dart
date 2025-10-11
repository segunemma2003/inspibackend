import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/config/decoders.dart';

class BusinessApiService extends NyApiService {
  BusinessApiService({BuildContext? buildContext})
      : super(buildContext, decoders: modelDecoders);

  @override
  String get baseUrl =>
      getEnv('API_BASE_URL', defaultValue: 'https://api.inspirtag.com/api');

  @override
  Future<RequestHeaders> setAuthHeaders(RequestHeaders headers) async {
    print('🌐 BusinessApiService: Setting auth headers...');
    final authHeaders = await AuthService.instance.getAuthHeaders();
    print('🌐 BusinessApiService: Auth headers received: $authHeaders');
    headers.addAll(authHeaders);
    print('🌐 BusinessApiService: Final headers: ${headers.toString()}');
    return headers;
  }

  /// Get business accounts with pagination
  Future<Map<String, dynamic>?> getBusinessAccounts({
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/business-accounts", queryParameters: {
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "business_accounts_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Create business account
  Future<Map<String, dynamic>?> createBusinessAccount({
    required String name,
    required String description,
    required Map<String, dynamic> contactInfo,
    String? website,
    String? address,
    File? logo,
  }) async {
    final formData = FormData();

    formData.fields.add(MapEntry('name', name));
    formData.fields.add(MapEntry('description', description));
    formData.fields.add(MapEntry('contact_info', contactInfo.toString()));
    if (website != null) formData.fields.add(MapEntry('website', website));
    if (address != null) formData.fields.add(MapEntry('address', address));
    if (logo != null) {
      formData.files.add(MapEntry(
          'logo', MultipartFile.fromFileSync(logo.path, filename: 'logo.jpg')));
    }

    return await network<Map<String, dynamic>>(
      request: (request) => request.post("/business-accounts", data: formData),
      cacheKey: "business_account_create",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Get specific business account
  Future<Map<String, dynamic>?> getBusinessAccount(
      int businessAccountId) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.get("/business-accounts/$businessAccountId"),
      cacheKey: "business_account_$businessAccountId",
      cacheDuration: const Duration(minutes: 10),
    );
  }

  /// Update business account
  Future<Map<String, dynamic>?> updateBusinessAccount(
    int businessAccountId, {
    String? name,
    String? description,
    Map<String, dynamic>? contactInfo,
    String? website,
    String? address,
    File? logo,
  }) async {
    final formData = FormData();

    if (name != null) formData.fields.add(MapEntry('name', name));
    if (description != null)
      formData.fields.add(MapEntry('description', description));
    if (contactInfo != null)
      formData.fields.add(MapEntry('contact_info', contactInfo.toString()));
    if (website != null) formData.fields.add(MapEntry('website', website));
    if (address != null) formData.fields.add(MapEntry('address', address));
    if (logo != null) {
      formData.files.add(MapEntry(
          'logo', MultipartFile.fromFileSync(logo.path, filename: 'logo.jpg')));
    }

    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.put("/business-accounts/$businessAccountId", data: formData),
      cacheKey: "business_account_update_$businessAccountId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Delete business account
  Future<Map<String, dynamic>?> deleteBusinessAccount(
      int businessAccountId) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.delete("/business-accounts/$businessAccountId"),
      cacheKey: "business_account_delete_$businessAccountId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Create booking for business account
  Future<Map<String, dynamic>?> createBooking(
    int businessAccountId, {
    required DateTime dateTime,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.post("/business-accounts/$businessAccountId/bookings", data: {
        "date_time": dateTime.toIso8601String(),
        if (notes != null) "notes": notes,
        if (additionalData != null) "additional_data": additionalData,
      }),
      cacheKey: "booking_create_$businessAccountId",
      cacheDuration: const Duration(minutes: 1),
    );
  }

  /// Get bookings for business account
  Future<Map<String, dynamic>?> getBusinessBookings(
    int businessAccountId, {
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get(
          "/business-accounts/$businessAccountId/bookings",
          queryParameters: {
            "per_page": perPage,
            "page": page,
          }),
      cacheKey: "business_bookings_$businessAccountId" + "_$page",
      cacheDuration: const Duration(minutes: 5),
    );
  }
}
