import 'package:flutter/material.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/widget/nearby_house_card.dart';

class NearbyHouses extends StatefulWidget {
  final List<HousePreview> houses;

  const NearbyHouses({
    super.key,
    required this.houses,
  });

  @override
  _NearbyHousesWidgetState createState() => _NearbyHousesWidgetState();
}

class _NearbyHousesWidgetState extends State<NearbyHouses> {
  final ScrollController _nearbyHousesScrollController = ScrollController();

  @override
  void dispose() {
    _nearbyHousesScrollController.dispose();
    super.dispose();
  }

  void onHouseSelected(int id) {
    Navigator.of(context).pushNamed(
      '/house',
      arguments: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.houses.isEmpty) {
      return const SizedBox.shrink(); // Don't show anything if no nearby houses
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nearby Houses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 270,
          child: Stack(
            children: [
              // Scrollable row of house cards
              ListView.builder(
                controller: _nearbyHousesScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.houses.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: NearbyHouseCard(
                        house: widget.houses[index],

                      ),
                    ),
                  );
                },
              ),

              // Left scroll button
              if (widget.houses.length > 1)
                Positioned(
                  left: 0,
                  top: 100,
                  child: _buildScrollButton(direction: -1),
                ),

              // Right scroll button
              if (widget.houses.length > 1)
                Positioned(
                  right: 0,
                  top: 100,
                  child: _buildScrollButton(direction: 1),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollButton({required int direction}) {
    return InkWell(
      onTap: () {
        final currentPosition = _nearbyHousesScrollController.offset;
        final scrollAmount = direction * 280.0; // Width of a card
        _nearbyHousesScrollController.animateTo(
          currentPosition + scrollAmount,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          direction < 0 ? Icons.chevron_left : Icons.chevron_right,
          color: Colors.black87,
        ),
      ),
    );
  }
}