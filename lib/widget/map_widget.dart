import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/widget/house_map_card.dart';

class MapWidget extends StatefulWidget {
  final bool isInteractive;
  final List<HousePreview>? houses;
  final Function(int houseId)? onHouseSelected;
  final House? singleHouse;

  const MapWidget({
    Key? key,
    this.houses,
    this.onHouseSelected,
    this.singleHouse,
    this.isInteractive = true,
  }) : assert(
  (isInteractive && houses != null) ||
      (!isInteractive && singleHouse != null),
  'Interactive mode requires houses list. Non-interactive mode requires singleHouse.'
  ),
        super(key: key);

  // Factory constructor for interactive mode (Home screen)
  factory MapWidget.interactive({
    Key? key,
    required List<HousePreview> houses,
    required Function(int houseId) onHouseSelected,
    MapController? mapController,
  }) {
    return MapWidget(
      key: key,
      houses: houses,
      onHouseSelected: onHouseSelected,
      isInteractive: true,
    );
  }

  // Factory constructor for non-interactive mode (Detail screen)
  factory MapWidget.nonInteractive({
    Key? key,
    required House house,
    MapController? mapController,
  }) {
    return MapWidget(
      key: key,
      singleHouse: house,
      isInteractive: false,
    );
  }

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  // Controller for the map
  late MapController _mapController;

  // Currently selected house (only used in interactive mode)
  HousePreview? _selectedHousePreview;

  // Configuration values
  final String mapboxUrl = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}';
  final String mapboxStyle = 'mapbox/streets-v11';
  final String mapboxToken = environment.mapboxToken;

  // Default center for home view
  final LatLng _westernEuropeCenter = LatLng(47.0, 5.0);
  final double _defaultZoom = 4.0;
  final double _detailZoom = 13.0;

  // Flag to indicate when the map is ready to be displayed
  bool _isMapReady = false;

  getMapHeight(){
    if(widget.isInteractive){
      return 550.0;
    }
    return 200.0;
  }

  @override
  void initState() {
    super.initState();

    // Use provided controller or create a new one
    _mapController = MapController();

    // Delay map initialization briefly to ensure all parameters are properly loaded
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isMapReady = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading placeholder until the map is ready
    if (!_isMapReady) {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Stack(
      children: [
        // The map itself
        SizedBox(
          height: getMapHeight(),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _getMapCenter(),
              zoom: _getMapZoom(),
              maxZoom: 18.0,
              minZoom: 3.0,
              onTap: widget.isInteractive ? _handleMapTap : null,
            ),
            children: [
              TileLayer(
                urlTemplate: mapboxUrl,
                additionalOptions: {
                  'accessToken': mapboxToken,
                  'id': mapboxStyle,
                },
              ),
              // House markers
              MarkerLayer(
                markers: _buildMarkers(),
              ),
            ],
          ),
        ),

        // House preview card
        if (_selectedHousePreview != null && widget.isInteractive)
          Positioned(
            bottom: 85,
            left: 20,
            right: 20,
            child: HouseMapCard(
              house: _selectedHousePreview!,
            ),
          ),
      ],
    );
  }

  void _handleMapTap(_, __) {
    if (_selectedHousePreview != null) {
      setState(() {
        _selectedHousePreview = null;
      });
    }
  }

  LatLng _getMapCenter() {
    if (widget.isInteractive) {
      return _westernEuropeCenter;
    } else {
      // Asegurar que las coordenadas son válidas
      if (widget.singleHouse != null) {
        try {
          return LatLng(widget.singleHouse!.latitude, widget.singleHouse!.longitude);
        } catch (e) {
          // En caso de error, usar un valor predeterminado
          return _westernEuropeCenter;
        }
      }
      return _westernEuropeCenter;
    }
  }

  double _getMapZoom() {
    return widget.isInteractive ? _defaultZoom : _detailZoom;
  }

  List<Marker> _buildMarkers() {
    if (widget.isInteractive && widget.houses != null) {
      // Interactive mode - build markers for all houses
      return widget.houses!.map((house) {
        bool isSelected = _selectedHousePreview?.id == house.id;
        return _buildMarkerFromCoordinates(
          latitude: house.latitude,
          longitude: house.longitude,
          isSelected: isSelected,
          onTap: () {
            setState(() {
              _selectedHousePreview = house;
            });
          },
        );
      }).toList();
    } else if (!widget.isInteractive && widget.singleHouse != null) {
      // Non-interactive mode - single house marker
      return [
        _buildMarkerFromCoordinates(
          latitude: widget.singleHouse!.latitude,
          longitude: widget.singleHouse!.longitude,
          isSelected: true,
          onTap: null,
        )
      ];
    }
    return []; // Retornar lista vacía como fallback
  }

  // Build a single marker using coordinates directly
  Marker _buildMarkerFromCoordinates({
    required double latitude,
    required double longitude,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(latitude, longitude),
      builder: (ctx) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? environment.primaryColor.withOpacity(0.8)
                : environment.primaryColor.withOpacity(0.6),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.home,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}