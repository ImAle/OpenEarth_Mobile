import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';

class CategoryBar extends StatefulWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategorySelected;
  final bool isLoading;

  const CategoryBar({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  _CategoryBarState createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar> {
  // ScrollController for the category bar
  final ScrollController _categoryScrollController = ScrollController();

  @override
  void dispose() {
    _categoryScrollController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    if (widget.selectedCategory == category) {
      widget.onCategorySelected(null);
    } else {
      widget.onCategorySelected(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: widget.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _categoryScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: widget.categories.length,
          itemBuilder: (context, index) {
            final category = widget.categories[index];
            final isSelected = widget.selectedCategory == category;

            return GestureDetector(
              onTap: () => _selectCategory(category),
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? environment.primaryColor.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(category),
                        color: isSelected
                            ? environment.primaryColor
                            : Colors.grey,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? environment.primaryColor : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get icon for a category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'farm':
        return Icons.agriculture;
      case 'countryside':
        return Icons.nature_people;
      case 'beach':
        return Icons.beach_access;
      case 'lake':
        return Icons.water;
      case 'city':
        return Icons.location_city;
      case 'cabins':
        return Icons.cottage;
      case 'islands':
        return Icons.tsunami;
      case 'mansions':
        return Icons.villa;
      case 'treehouses':
        return Icons.forest;
      case 'tropical':
        return Icons.beach_access;
      case 'luxe':
        return Icons.star;
      case 'amazing_views':
        return Icons.landscape;
      case 'pools':
        return Icons.pool;
      case 'tiny':
        return Icons.home_mini;
      case 'caves':
        return Icons.terrain;
      case 'arctic':
        return Icons.ac_unit;
      case 'barns':
        return Icons.home_work;
      case 'minsus':
        return Icons.house_siding;
      case 'camping':
        return Icons.grass;
      case 'ryokans':
        return Icons.spa;
      case 'new':
        return Icons.new_releases;
      case 'national_parks':
        return Icons.park;
      case 'rooms':
        return Icons.bedroom_parent;
      case 'boats':
        return Icons.directions_boat_filled;
      case 'desert':
        return Icons.thermostat;
      case 'windmills':
        return Icons.air;
      case 'towers':
        return Icons.apartment;
      case 'containers':
        return Icons.inventory_2;
      default:
        return Icons.house;
    }
  }
}