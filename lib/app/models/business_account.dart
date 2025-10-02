import 'package:nylo_framework/nylo_framework.dart';
import 'user.dart';

class BusinessAccount extends Model {
  int? id;
  int? userId;
  String? businessName;
  String? businessDescription;
  String? businessType;
  String? website;
  String? phone;
  String? email;
  String? address;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? instagramHandle;
  String? facebookUrl;
  String? tiktokHandle;
  String? linkedinUrl;
  String? whatsappNumber;
  String? xHandle;
  Map<String, String>? businessHours;
  List<String>? services;
  double? rating;
  int? reviewsCount;
  bool? isVerified;
  bool? acceptsBookings;
  User? user;
  List<Booking>? bookings;

  static StorageKey key = "business_account";

  BusinessAccount() : super(key: key);

  BusinessAccount.fromJson(dynamic data) : super(key: key) {
    id = data['id'];
    userId = data['user_id'];
    businessName = data['business_name'];
    businessDescription = data['business_description'];
    businessType = data['business_type'];
    website = data['website'];
    phone = data['phone'];
    email = data['email'];
    address = data['address'];
    city = data['city'];
    state = data['state'];
    country = data['country'];
    postalCode = data['postal_code'];
    instagramHandle = data['instagram_handle'];
    facebookUrl = data['facebook_url'];
    tiktokHandle = data['tiktok_handle'];
    linkedinUrl = data['linkedin_url'];
    whatsappNumber = data['whatsapp_number'];
    xHandle = data['x_handle'];
    businessHours = data['business_hours'] != null
        ? Map<String, String>.from(data['business_hours'])
        : null;
    services =
        data['services'] != null ? List<String>.from(data['services']) : null;
    rating = data['rating']?.toDouble();
    reviewsCount = data['reviews_count'];
    isVerified = data['is_verified'];
    acceptsBookings = data['accepts_bookings'];
    user = data['user'] != null ? User.fromJson(data['user']) : null;
    bookings = data['bookings'] != null
        ? (data['bookings'] as List)
            .map((booking) => Booking.fromJson(booking))
            .toList()
        : null;
  }

  @override
  toJson() {
    return {
      "id": id,
      "user_id": userId,
      "business_name": businessName,
      "business_description": businessDescription,
      "business_type": businessType,
      "website": website,
      "phone": phone,
      "email": email,
      "address": address,
      "city": city,
      "state": state,
      "country": country,
      "postal_code": postalCode,
      "instagram_handle": instagramHandle,
      "facebook_url": facebookUrl,
      "tiktok_handle": tiktokHandle,
      "linkedin_url": linkedinUrl,
      "whatsapp_number": whatsappNumber,
      "x_handle": xHandle,
      "business_hours": businessHours,
      "services": services,
      "rating": rating,
      "reviews_count": reviewsCount,
      "is_verified": isVerified,
      "accepts_bookings": acceptsBookings,
      "user": user?.toJson(),
      "bookings": bookings?.map((booking) => booking.toJson()).toList(),
    };
  }
}

class Booking extends Model {
  int? id;
  int? userId;
  int? businessAccountId;
  String? serviceName;
  String? description;
  DateTime? appointmentDate;
  String? status;
  String? notes;
  String? contactPhone;
  String? contactEmail;
  DateTime? createdAt;
  User? user;

  static StorageKey key = "booking";

  Booking() : super(key: key);

  Booking.fromJson(dynamic data) : super(key: key) {
    id = data['id'];
    userId = data['user_id'];
    businessAccountId = data['business_account_id'];
    serviceName = data['service_name'];
    description = data['description'];
    appointmentDate = data['appointment_date'] != null
        ? DateTime.parse(data['appointment_date'])
        : null;
    status = data['status'];
    notes = data['notes'];
    contactPhone = data['contact_phone'];
    contactEmail = data['contact_email'];
    createdAt =
        data['created_at'] != null ? DateTime.parse(data['created_at']) : null;
    user = data['user'] != null ? User.fromJson(data['user']) : null;
  }

  @override
  toJson() => {
        "id": id,
        "user_id": userId,
        "business_account_id": businessAccountId,
        "service_name": serviceName,
        "description": description,
        "appointment_date": appointmentDate?.toIso8601String(),
        "status": status,
        "notes": notes,
        "contact_phone": contactPhone,
        "contact_email": contactEmail,
        "created_at": createdAt?.toIso8601String(),
        "user": user?.toJson(),
      };
}
