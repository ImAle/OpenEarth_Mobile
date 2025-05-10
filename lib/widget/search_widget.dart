import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/widget/CategoryBar.dart';

class SearchWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSearch;
  final Function() onClearFilters;
  final bool initiallyExpanded;

  const SearchWidget({
    Key? key,
    required this.onSearch,
    required this.onClearFilters,
    this.initiallyExpanded = false,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final HouseService _houseService = HouseService();

  // Animation controller for expanding/collapsing
  late AnimationController _animationController;
  late Animation<double> _heightFactor;

  // Filter values
  String? _location;
  RangeValues _priceRange = const RangeValues(0, 1000);
  int _beds = 0;
  int _guests = 0;
  String? _selectedCategory;

  // Categories
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _isExpanded = widget.initiallyExpanded;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _heightFactor = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (_isExpanded) {
      _animationController.value = 1.0;
    }

    // Listen for focus changes on search field
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus && _isExpanded) {
        _toggleExpanded();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _houseService.getCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: ${e.toString()}')),
      );
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
        // Remove focus from search field if filters are expanding
        FocusScope.of(context).unfocus();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _applyFilters() {
    // Create filters map
    final Map<String, dynamic> filters = {};

    if (_location != null && _location!.isNotEmpty) {
      filters['location'] = _location;
    }

    filters['minPrice'] = _priceRange.start;
    filters['maxPrice'] = _priceRange.end;

    if (_beds > 0) {
      filters['beds'] = _beds;
    }

    if (_guests > 0) {
      filters['guests'] = _guests;
    }

    if (_selectedCategory != null) {
      filters['category'] = _selectedCategory;
    }

    // Call the search function
    widget.onSearch(filters);

    // Close the filters
    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _location = null;
      _priceRange = const RangeValues(0, 1000);
      _beds = 0;
      _guests = 0;
      _selectedCategory = null;
    });

    widget.onClearFilters();

    if (_isExpanded) {
      _toggleExpanded();
    }
  }

  void _handleCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
    });

    // Apply the category filter immediately
    final Map<String, dynamic> filters = {};

    if (category != null) {
      filters['category'] = category;
      widget.onSearch(filters);
    } else {
      widget.onClearFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search Bar
        _buildSearchBar(),

        // Category Bar (only visible when not expanded)
        if (!_isExpanded)
          CategoryBar(
            categories: _categories,
            selectedCategory: _selectedCategory,
            onCategorySelected: _handleCategorySelected,
            isLoading: _isLoading,
          ),

        // Expanded Filters
        _buildExpandedFilters(),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.search, color: environment.primaryColor),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration.collapsed(
                  hintText: 'Where are you going?',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                onChanged: (value) {
                  setState(() {
                    _location = value;
                  });
                },
                onSubmitted: (_) {
                  _applyFilters();
                },
              ),
            ),
            GestureDetector(
              onTap: _toggleExpanded,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: environment.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.tune,
                  color: environment.primaryColor,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedFilters() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            heightFactor: _heightFactor.value,
            child: child,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price Range Filter
            _buildPriceRangeFilter(),

            const SizedBox(height: 16),

            // Beds and Guests
            _buildBedsAndGuestsFilter(),

            const SizedBox(height: 24),

            // Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '€${_priceRange.start.round()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      '€${_priceRange.end.round()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: environment.primaryColor,
                inactiveColor: Colors.grey.shade300,
                onChanged: (RangeValues values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBedsAndGuestsFilter() {
    return Row(
      children: [
        // Beds
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'Bedrooms',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCounterButton(
                      onPressed: () {
                        if (_beds > 0) {
                          setState(() {
                            _beds--;
                          });
                        }
                      },
                      icon: Icons.remove,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$_beds',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      onPressed: () {
                        setState(() {
                          _beds++;
                        });
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Guests
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'Guests',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCounterButton(
                      onPressed: () {
                        if (_guests > 0) {
                          setState(() {
                            _guests--;
                          });
                        }
                      },
                      icon: Icons.remove,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        '$_guests',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    _buildCounterButton(
                      onPressed: () {
                        setState(() {
                          _guests++;
                        });
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Clear All button
        TextButton(
          onPressed: _clearFilters,
          style: TextButton.styleFrom(
            foregroundColor: environment.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          child: const Text(
            'Clear all',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Search Button
        ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: environment.primaryColor,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.search, size: 18, color: Colors.white,),
              SizedBox(width: 8),
              Text(
                'Search',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({required VoidCallback onPressed, required IconData icon}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: environment.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 16, color: environment.primaryColor),
      ),
    );
  }
}