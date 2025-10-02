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
    id = data['id'];
    name = data['name'];
    slug = data['slug'];
    description = data['description'];
    color = data['color'];
    icon = data['icon'];
    isActive = data['is_active'];
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
