import '/app/networking/category_api_service.dart';
import '/app/models/category.dart';
import '/app/models/notification.dart';
import '/app/models/business_account.dart';
import '/app/models/post.dart';
import '/app/networking/notification_api_service.dart';
import '/app/networking/business_api_service.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/app/networking/search_api_service.dart';
import '/app/controllers/home_controller.dart';
import '/app/models/user.dart';
import '/app/networking/api_service.dart';

/* Model Decoders
|--------------------------------------------------------------------------
| Model decoders are used in 'app/networking/' for morphing json payloads
| into Models.
|
| Learn more https://nylo.dev/docs/6.x/decoders#model-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> modelDecoders = {
  Map<String, dynamic>: (data) => Map<String, dynamic>.from(data),

  // User models
  List<User>: (data) =>
      List.from(data).map((json) => User.fromJson(json)).toList(),
  User: (data) => User.fromJson(data),

  // Post models
  List<Post>: (data) =>
      List.from(data).map((json) => Post.fromJson(json)).toList(),
  Post: (data) => Post.fromJson(data),

  // Tag models
  List<Tag>: (data) =>
      List.from(data).map((json) => Tag.fromJson(json)).toList(),
  Tag: (data) => Tag.fromJson(data),

  // Business Account models
  List<BusinessAccount>: (data) =>
      List.from(data).map((json) => BusinessAccount.fromJson(json)).toList(),
  BusinessAccount: (data) => BusinessAccount.fromJson(data),

  // Booking models
  List<Booking>: (data) =>
      List.from(data).map((json) => Booking.fromJson(json)).toList(),
  Booking: (data) => Booking.fromJson(data),

  // Notification models
  List<Notification>: (data) =>
      List.from(data).map((json) => Notification.fromJson(json)).toList(),
  Notification: (data) => Notification.fromJson(data),

  // Category models
  List<Category>: (data) =>
      List.from(data).map((json) => Category.fromJson(json)).toList(),
  Category: (data) => Category.fromJson(data),
};

/* API Decoders
| -------------------------------------------------------------------------
| API decoders are used when you need to access an API service using the
| 'api' helper. E.g. api<MyApiService>((request) => request.fetchData());
|
| Learn more https://nylo.dev/docs/6.x/decoders#api-decoders
|-------------------------------------------------------------------------- */

final Map<Type, dynamic> apiDecoders = {
  ApiService: () => ApiService(),

  // API Services as singletons for better performance
  AuthApiService: AuthApiService(),
  UserApiService: UserApiService(),
  PostApiService: PostApiService(),
  BusinessApiService: BusinessApiService(),
  NotificationApiService: NotificationApiService(),
  CategoryApiService: CategoryApiService(),
  SearchApiService: SearchApiService(),
};

/* Controller Decoders
| -------------------------------------------------------------------------
| Controller are used in pages.
|
| Learn more https://nylo.dev/docs/6.x/controllers
|-------------------------------------------------------------------------- */
final Map<Type, dynamic> controllers = {
  HomeController: () => HomeController(),

  // ...
};
