import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/widget/house_card.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/widget/map_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HouseService _houseService = HouseService();
  bool _isLoading = true;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _loadHouses();
    _houseService.filteredHouses.addListener(_onHousesChanged);
  }

  @override
  void dispose() {
    _houseService.filteredHouses.removeListener(_onHousesChanged);
    super.dispose();
  }

  void _onHousesChanged() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadHouses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _houseService.getAll(
        // location: "Madrid",
        // minPrice: 100,
        // maxPrice: 500,
        // currency: "EUR",
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error at loading houses: ${e.toString()}')),
      );
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
      appBar: AppBar(
        title: const Text(
          'OpenEarth',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Filters
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          ValueListenableBuilder<List<HousePreview>?>(
            valueListenable: _houseService.filteredHouses,
            builder: (context, houses, child) {
              if (houses == null || houses.isEmpty) {
                return const Center(
                  child: Text('No houses available found'),
                );
              }

              if (_showMap) {
                // Map view
                return MapWidget(
                  houses: houses,
                  onHouseSelected: _navigateToHouseDetail,
                  isInteractive: true,
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

          // Custom toggle button centered at bottom
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
    );
  }
}