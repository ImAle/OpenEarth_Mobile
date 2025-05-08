import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/widget/House_map_card.dart';

class MapWidget extends StatefulWidget {
  final List<HousePreview> houses;
  final Function(int houseId)? onHouseSelected;
  final HousePreview? selectedHouse;
  final bool isInteractive;

  const MapWidget({
    Key? key,
    required this.houses,
    this.onHouseSelected,
    this.selectedHouse,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  HousePreview? _selectedHousePreview;
  final String mapboxToken = environment.mapboxToken;
  final String mapboxUrl = 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token={accessToken}';
  final String mapboxStyle = 'mapbox/streets-v11';

  // Default center for home view
  final LatLng _westernEuropeCenter = LatLng(47.0, 5.0);
  final double _defaultZoom = 4.0;

  @override
  void initState() {
    super.initState();
    if (widget.selectedHouse != null) {
      _selectedHousePreview = widget.selectedHouse;

      // Only center on the house if in home detail view
      Future.delayed(Duration(milliseconds: 100), () {
        _moveToSelectedHouse();
      });
    }
  }

  void _moveToSelectedHouse() {
    if (_selectedHousePreview != null) {
      _mapController.move(
        LatLng(_selectedHousePreview!.latitude, _selectedHousePreview!.longitude),
        13.0, // Zoom
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: _getMapCenter(),
            zoom: _getInitialZoom(),
            maxZoom: 18.0,
            minZoom: 3.0,
            onTap: (_, __) {
              // Drop house preview if tap the screen in no marker
              if (widget.isInteractive && _selectedHousePreview != null) {
                setState(() {
                  _selectedHousePreview = null;
                });
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: mapboxUrl,
              additionalOptions: {
                'accessToken': mapboxToken,
                'id': mapboxStyle,
              },
            ),
            MarkerLayer(
              markers: _buildMarkers(),
            ),
          ],
        ),

        // Show HouseMapCard when a marker is tapped
        if (_selectedHousePreview != null && widget.isInteractive)
          Positioned(
            bottom: 85,
            left: 20,
            right: 20,
            child: HouseMapCard(
              house: _selectedHousePreview!,
              onTap: () {
                if (widget.onHouseSelected != null) {
                  widget.onHouseSelected!(_selectedHousePreview!.id);
                }
              },
            ),
          ),
      ],
    );
  }

  double _getInitialZoom() {
    // High zoom for house detail view
    if (widget.selectedHouse != null) {
      return 13.0;
    }
    // Low zoom for home view
    return _defaultZoom;
  }

  LatLng _getMapCenter() {
    // Center on selected house only if in detail view
    if (widget.selectedHouse != null) {
      return LatLng(widget.selectedHouse!.latitude, widget.selectedHouse!.longitude);
    }

    // For home view, it centers the map to Western Europe as default
    return _westernEuropeCenter;
  }

  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    // Marker for house details view
    if (widget.selectedHouse != null) {
      markers.add(_buildMarker(widget.selectedHouse!, true));
      return markers;
    }

    // Markers for home view
    for (var house in widget.houses) {
      bool isSelected = _selectedHousePreview?.id == house.id;
      markers.add(_buildMarker(house, isSelected));
    }

    return markers;
  }

  Marker _buildMarker(HousePreview house, bool isSelected) {
    return Marker(
      width: 40.0,
      height: 40.0,
      point: LatLng(house.latitude, house.longitude),
      builder: (ctx) => GestureDetector(
        onTap: widget.isInteractive
            ? () {
          setState(() {
            _selectedHousePreview = house;
          });
        }
            : null,
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
          child: Icon(
            Icons.home,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}