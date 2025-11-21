import 'package:nylo_framework/nylo_framework.dart';

class Subscription extends Model {
  int? id;
  int? userId;
  String? planName;
  double? price;
  String? currency;
  int? duration;
  String? durationUnit;
  String? status; // 'active', 'expired', 'cancelled'
  DateTime? startedAt;
  DateTime? expiresAt;
  String? paymentId;
  String? appleOriginalTransactionId;
  String? appleTransactionId;
  String? appleProductId;
  DateTime? createdAt;
  DateTime? updatedAt;

  static StorageKey key = 'subscription';

  Subscription() : super(key: key);

  Subscription.fromJson(dynamic data) : super(key: key) {
    if (data == null) return;

    Map<String, dynamic> subData;
    if (data is Map<String, dynamic>) {
      subData = data;
    } else if (data is Map) {
      subData = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    if (subData.containsKey('data')) {
      subData = subData['data'];
    }

    id = subData['id'];
    userId = subData['user_id'];
    planName = subData['plan_name'];
    price = subData['price']?.toDouble();
    currency = subData['currency'];
    duration = subData['duration'];
    durationUnit = subData['duration_unit'];
    status = subData['status'];
    startedAt = subData['started_at'] != null
        ? DateTime.parse(subData['started_at'])
        : null;
    expiresAt = subData['expires_at'] != null
        ? DateTime.parse(subData['expires_at'])
        : null;
    paymentId = subData['payment_id'];
    appleOriginalTransactionId = subData['apple_original_transaction_id'];
    appleTransactionId = subData['apple_transaction_id'];
    appleProductId = subData['apple_product_id'];
    createdAt = subData['created_at'] != null
        ? DateTime.parse(subData['created_at'])
        : null;
    updatedAt = subData['updated_at'] != null
        ? DateTime.parse(subData['updated_at'])
        : null;
  }

  @override
  toJson() => {
        "id": id,
        "user_id": userId,
        "plan_name": planName,
        "price": price,
        "currency": currency,
        "duration": duration,
        "duration_unit": durationUnit,
        "status": status,
        "started_at": startedAt?.toIso8601String(),
        "expires_at": expiresAt?.toIso8601String(),
        "payment_id": paymentId,
        "apple_original_transaction_id": appleOriginalTransactionId,
        "apple_transaction_id": appleTransactionId,
        "apple_product_id": appleProductId,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };

  bool get isActive =>
      status == 'active' &&
      expiresAt != null &&
      expiresAt!.isAfter(DateTime.now());

  int? get daysRemaining {
    if (expiresAt == null) return null;
    final now = DateTime.now();
    if (expiresAt!.isBefore(now)) return 0;
    return expiresAt!.difference(now).inDays;
  }

  bool get willExpireSoon => daysRemaining != null && daysRemaining! <= 7;
}

class SubscriptionPlan extends Model {
  int? id;
  String? name;
  String? slug;
  String? appleProductId;
  double? price;
  String? currency;
  int? durationDays;
  List<String>? features;
  bool? isActive;
  bool? isDefault;
  DateTime? createdAt;
  DateTime? updatedAt;

  // Legacy fields for backward compatibility
  String? get planName => name;
  int? get duration => durationDays;
  String? get durationUnit => durationDays != null ? 'days' : null;

  static StorageKey key = 'subscription_plan';

  SubscriptionPlan() : super(key: key);

  SubscriptionPlan.fromJson(dynamic data) : super(key: key) {
    if (data == null) return;

    Map<String, dynamic> planData;
    if (data is Map<String, dynamic>) {
      planData = data;
    } else if (data is Map) {
      planData = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    // Handle nested data structure
    if (planData.containsKey('data') && planData['data'] is! List) {
      planData = planData['data'];
    }

    id = planData['id'];
    name = planData['name'];
    slug = planData['slug'];
    appleProductId = planData['apple_product_id'];
    price = planData['price'] != null
        ? (planData['price'] is String
            ? double.tryParse(planData['price'])
            : planData['price']?.toDouble())
        : null;
    currency = planData['currency'];
    durationDays = planData['duration_days'] ?? planData['duration'];
    features = planData['features'] != null
        ? List<String>.from(planData['features'])
        : null;
    isActive = planData['is_active'];
    isDefault = planData['is_default'];
    createdAt = planData['created_at'] != null
        ? DateTime.tryParse(planData['created_at'])
        : null;
    updatedAt = planData['updated_at'] != null
        ? DateTime.tryParse(planData['updated_at'])
        : null;
  }

  @override
  toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "apple_product_id": appleProductId,
        "price": price,
        "currency": currency,
        "duration_days": durationDays,
        "features": features,
        "is_active": isActive,
        "is_default": isDefault,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}


