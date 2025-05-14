import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/service/currency_service.dart';
import 'package:openearth_mobile/widget/navegation_widget.dart';
import 'package:openearth_mobile/widget/house_card.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/widget/map_widget.dart';
import 'package:openearth_mobile/widget/search_widget.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HouseService _houseService = HouseService();
  final CurrencyService _currencyService = CurrencyService();
  bool _isLoading = true;
  bool _showMap = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Keep track of current search filters
  Map<String, dynamic> _currentFilters = {};

  @override
  void initState() {
    super.initState();
    // Wait for currencyService to initialize before loading the houses
    _initializeAndLoadHouses();
    _houseService.filteredHouses.addListener(_onHousesChanged);
    // Apply filters with the new currency
    _currencyService.currentCurrency.addListener(_onCurrencyChanged);
  }

  Future<void> _initializeAndLoadHouses() async {
    try {
      await _currencyService.initialized;
      await _loadHouses();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error at initializing: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    _houseService.filteredHouses.removeListener(_onHousesChanged);
    _currencyService.currentCurrency.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _onHousesChanged() {
    setState(() {
      _isLoading = false;
    });
  }

  // When currency changes, reload houses with the new currency
  void _onCurrencyChanged() {
    // Reload houses with current filters but new currency
    _applyFiltersWithCurrentCurrency();
  }

  // Apply current filters with updated currency
  void _applyFiltersWithCurrentCurrency() {
    final currentCurrency = _currencyService.getCurrentCurrencyCode();

    // If we have active filters, reapply them with the new currency
    if (_currentFilters.isNotEmpty) {
      _handleSearch({
        ..._currentFilters,
        'currency': currentCurrency,
      });
    } else {
      _loadHouses();
    }
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      // Clear current filters
      _currentFilters = {};
    });

    try {
      await _houseService.getAll(
        currency: _currencyService.getCurrentCurrencyCode(),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error at loading houses: ${e.toString()}')),
      );
    }
  }

  Future<void> _handleSearch(Map<String, dynamic> filters) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      // Save the current filters for potential reuse when currency changes
      _currentFilters = Map.from(filters);
    });

    try {
      await _houseService.getAll(
        location: filters['location'],
        minPrice: filters['minPrice'],
        maxPrice: filters['maxPrice'],
        beds: filters['beds'],
        guests: filters['guests'],
        category: filters['category'],
        currency: _currencyService.getCurrentCurrencyCode(),
      );
    } catch (e) {
      if (e.toString().contains('204')) {
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _navigateToHouseDetail(int houseId) {
    Navigator.of(context).pushNamed(
      '/house',
      arguments: houseId,
    );
  }

  void _toggleMapView() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SearchWidget(
              onSearch: _handleSearch,
              onClearFilters: _loadHouses,
              currencySymbol: _currencyService.getCurrentCurrencySymbol(),
            ),

            // Main content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    SizedBox(height: 16),
                    Text('No exact matches'),
                    SizedBox(height: 16),
                    Text('Try changing or removing some of your filters\n or adjusting your search area.', textAlign: TextAlign.center,),
                  ],
                ),
              )
                  : Stack(
                children: [
                  ValueListenableBuilder<List<HousePreview>?>(
                    valueListenable: _houseService.filteredHouses,
                    builder: (context, houses, child) {
                      if (houses == null || houses.isEmpty) {
                        // Display the "No exact matches" message
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'No exact matches',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                                child: Text(
                                  'Try changing or removing some of your filters or adjusting your search area.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: _loadHouses,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: environment.primaryColor,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: const Text(
                                  'Clear filters',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (_showMap) {
                        // Map view
                        return MapWidget.interactive(
                          houses: houses,
                          onHouseSelected: _navigateToHouseDetail,
                        );
                      } else {
                        // List view
                        return RefreshIndicator(
                          onRefresh: _loadHouses,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            itemCount: houses.length,
                            itemBuilder: (context, index) {
                              return HouseCard(
                                house: houses[index],
                                onTap: _navigateToHouseDetail,
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),

                  // Toggle button centered at bottom
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Material(
                        color: environment.primaryColor,
                        elevation: 3,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          onTap: _toggleMapView,
                          borderRadius: BorderRadius.circular(22),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _showMap ? Icons.list : Icons.map,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showMap ? 'List' : 'Map',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavigationWidget(
        currentIndex: 0,
      ),
    );
  }
}