class CategoryModel {
  final String id;
  final String name;
  final String iconPath;
  final String groupName;
  final int providerCount;
  final String? description;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.groupName,
    required this.providerCount,
    this.description,
  });
}

class CategoryGroup {
  final String name;
  final List<CategoryModel> categories;

  const CategoryGroup({
    required this.name,
    required this.categories,
  });
}
