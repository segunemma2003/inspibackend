import 'package:nylo_framework/nylo_framework.dart';

class Category extends Model {
  int? id;
  String? name;
  String? slug;
  String? description;
  String? color;
  String? icon;
  bool? isActive;

  static StorageKey key = "category";

  Category() : super(key: key);

  Category.fromJson(dynamic data) : super(key: key) {
    // Handle case where data might be null or not a Map
    if (data == null) {
      return;
    }

    // Convert to Map if it's not already
    Map<String, dynamic> categoryData;
    if (data is Map<String, dynamic>) {
      categoryData = data;
    } else if (data is Map) {
      categoryData = Map<String, dynamic>.from(data);
    } else {
      return;
    }

    id = categoryData['id'];
    name = categoryData['name'];
    slug = categoryData['slug'];
    description = categoryData['description'];
    color = categoryData['color'];
    icon = categoryData['icon'];
    isActive = categoryData['is_active'];
  }

  @override
  toJson() {
    return {
      "id": id,
      "name": name,
      "slug": slug,
      "description": description,
      "color": color,
      "icon": icon,
      "is_active": isActive,
    };
  }
}
