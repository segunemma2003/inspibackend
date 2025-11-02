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

    if (data == null) {
      return;
    }

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
