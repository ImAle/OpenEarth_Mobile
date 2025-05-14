import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/service/currency_service.dart';
import 'package:openearth_mobile/widget/map_widget.dart';
import 'package:openearth_mobile/widget/nearby_houses.dart';
import 'package:openearth_mobile/widget/owner_card.dart';
import 'package:openearth_mobile/widget/rent_bar.dart';
import 'package:openearth_mobile/widget/review_section_widget.dart';

class HouseDetailsScreen extends StatefulWidget {
  final int houseId;

  const HouseDetailsScreen({
    Key? key,
    required this.houseId,
  }) : super(key: key);

  @override
  _HouseDetailsScreenState createState() => _HouseDetailsScreenState();
}

class _HouseDetailsScreenState extends State<HouseDetailsScreen> {
  final HouseService _houseService = HouseService();
  final CurrencyService _currencyService = CurrencyService();
  final double _nearbyRadius = 5.0; // km

  House? _house;
  List<HousePreview> _nearbyHouses = [];
  bool _isLoading = true;
  int _currentImageIndex = 0;
  String _currency = 'EUR'; // Default currency

  @override
  void initState() {
    super.initState();
    _loadHouseDetails();
  }

  Future<void> _loadHouseDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current currency from service
      await _currencyService.initialized;
      _currency = _currencyService.getCurrentCurrencyCode();

      // Load house details
      final response = await _houseService.getById(widget.houseId, _currency);
      setState(() {
        _house = House.fromJson(response['house']);
        _isLoading = false;
      });

      // Load nearby houses
      _loadNearbyHouses();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading house details: $e')),
      );
    }
  }

  Future<void> _loadNearbyHouses() async {
    if (_house == null) return;

    try {
      final response = await _houseService.getHousesNearTo(
          _house!.id,
          _nearbyRadius.toInt(),
          _currency
      );

      setState(() {
        _nearbyHouses = (response['houses'] as List)
            .map((house) => HousePreview.fromJson(house))
            .toList();
      });
    } catch (e) {
      // Silently handle error, nearby houses are not critical
      print('No nearby houses to this one');
    }
  }

  void _showDescriptionModal() {
    if (_house == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDescriptionModal(),
    );
  }

  Widget _buildDescriptionModal() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar for dragging
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scrollable description
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Text(
                    _house!.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_house == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('House not found')),
        body: const Center(
          child: Text('Unable to load house details'),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Main content with scroll
          CustomScrollView(
            slivers: [
              // Images gallery
              SliverToBoxAdapter(
                child: _buildImagesGallery(),
              ),

              // House details
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        _house!.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Location
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _house!.location,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // House features
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureItem(Icons.people_outline, '${_house!.guests} guests'),
                          _buildFeatureItem(Icons.house_outlined, '${_house!.bedrooms} bedrooms'),
                          _buildFeatureItem(Icons.bed_outlined, '${_house!.beds} beds'),
                          _buildFeatureItem(Icons.bathroom_outlined, '${_house!.bathrooms} bathrooms'),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Owner information
                      OwnerCard(owner: _house!.owner),
                      const SizedBox(height: 24),

                      // Description
                      _buildDescription(),
                      const SizedBox(height: 24),

                      // Nearby houses
                      if (_nearbyHouses.isNotEmpty) NearbyHouses(houses: _nearbyHouses),
                      if (_nearbyHouses.isNotEmpty) const SizedBox(height: 24),

                      // Reviews
                      if (_house!.reviews.isNotEmpty) ReviewSectionWidget(reviews: _house!.reviews),
                      if (_house!.reviews.isNotEmpty) const SizedBox(height: 24),

                      // Map
                      if (_house != null)
                        _buildMap(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Back button (positioned at top-left corner)
          Positioned(
            top: 40,
            left: 16,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),

          // Bottom reservation bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RentBar(house: _house!),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGallery() {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            controller: PageController(),
            itemCount: _house!.pictures.length,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(environment.imageUrl + _house!.pictures[index].url),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Point-Index indicator
          if (_house!.pictures.length > 1)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _house!.pictures.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.black
                          : Colors.black.withOpacity(0.4),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    String displayText = _house!.description;
    bool isTruncated = false;

    if (displayText.length > 250) {
      displayText = displayText.substring(0, 250) + '...';
      isTruncated = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(displayText),
        if (isTruncated)
          TextButton(
            onPressed: _showDescriptionModal,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerLeft,
              foregroundColor: environment.primaryColor,
            ),
            child: const Text('Show more'),
          ),
      ],
    );
  }

  Widget _buildMap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: Colors.grey[600]),
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ]
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          width: double.infinity,
          child: MapWidget.nonInteractive(house: _house!),
        ),
        const SizedBox(height: 80), // Extra space for bottom bar
      ],
    );
  }
}