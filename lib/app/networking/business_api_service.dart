import 'package:flutter/material.dart';
import '/config/decoders.dart';
import '/app/services/auth_service.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/business_account.dart';

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

  /// Get business accounts
  Future<Map<String, dynamic>?> getBusinessAccounts({
    String? query,
    String? type,
    int perPage = 20,
    int page = 1,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get("/business-accounts", queryParameters: {
        if (query != null) "q": query,
        if (type != null) "type": type,
        "per_page": perPage,
        "page": page,
      }),
      cacheKey: "business_accounts_${query ?? 'all'}_${type ?? 'all'}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }

  /// Create business account
  Future<BusinessAccount?> createBusinessAccount({
    required String businessName,
    required String businessDescription,
    required String businessType,
    String? website,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? instagramHandle,
    String? facebookUrl,
    String? tiktokHandle,
    String? linkedinUrl,
    String? whatsappNumber,
    String? xHandle,
    Map<String, String>? businessHours,
    List<String>? services,
  }) async {
    return await network<BusinessAccount>(
      request: (request) => request.post("/business-accounts", data: {
        "business_name": businessName,
        "business_description": businessDescription,
        "business_type": businessType,
        if (website != null) "website": website,
        if (phone != null) "phone": phone,
        if (email != null) "email": email,
        if (address != null) "address": address,
        if (city != null) "city": city,
        if (state != null) "state": state,
        if (country != null) "country": country,
        if (postalCode != null) "postal_code": postalCode,
        if (instagramHandle != null) "instagram_handle": instagramHandle,
        if (facebookUrl != null) "facebook_url": facebookUrl,
        if (tiktokHandle != null) "tiktok_handle": tiktokHandle,
        if (linkedinUrl != null) "linkedin_url": linkedinUrl,
        if (whatsappNumber != null) "whatsapp_number": whatsappNumber,
        if (xHandle != null) "x_handle": xHandle,
        if (businessHours != null) "business_hours": businessHours,
        if (services != null) "services": services,
      }),
    );
  }

  /// Get business account details
  Future<BusinessAccount?> getBusinessAccountDetails(
      int businessAccountId) async {
    return await network<BusinessAccount>(
      request: (request) =>
          request.get("/business-accounts/$businessAccountId"),
      cacheKey: "business_account_$businessAccountId",
      cacheDuration: const Duration(minutes: 5),
    );
  }

  /// Update business account
  Future<BusinessAccount?> updateBusinessAccount({
    required int businessAccountId,
    String? businessName,
    String? businessDescription,
    bool? acceptsBookings,
  }) async {
    return await network<BusinessAccount>(
      request: (request) =>
          request.put("/business-accounts/$businessAccountId", data: {
        if (businessName != null) "business_name": businessName,
        if (businessDescription != null)
          "business_description": businessDescription,
        if (acceptsBookings != null) "accepts_bookings": acceptsBookings,
      }),
    );
  }

  /// Delete business account
  Future<Map<String, dynamic>?> deleteBusinessAccount(
      int businessAccountId) async {
    return await network<Map<String, dynamic>>(
      request: (request) =>
          request.delete("/business-accounts/$businessAccountId"),
    );
  }

  /// Create booking
  Future<Booking?> createBooking({
    required int businessAccountId,
    required String serviceName,
    required String description,
    required DateTime appointmentDate,
    String? notes,
    String? contactPhone,
    String? contactEmail,
  }) async {
    return await network<Booking>(
      request: (request) =>
          request.post("/business-accounts/$businessAccountId/bookings", data: {
        "service_name": serviceName,
        "description": description,
        "appointment_date": appointmentDate.toIso8601String(),
        if (notes != null) "notes": notes,
        if (contactPhone != null) "contact_phone": contactPhone,
        if (contactEmail != null) "contact_email": contactEmail,
      }),
    );
  }

  /// Get business bookings
  Future<Map<String, dynamic>?> getBusinessBookings({
    required int businessAccountId,
    int page = 1,
    int perPage = 20,
  }) async {
    return await network<Map<String, dynamic>>(
      request: (request) => request.get(
          "/business-accounts/$businessAccountId/bookings",
          queryParameters: {
            "page": page,
            "per_page": perPage,
          }),
      cacheKey: "business_bookings_${businessAccountId}_$page",
      cacheDuration: const Duration(minutes: 3),
    );
  }
}
