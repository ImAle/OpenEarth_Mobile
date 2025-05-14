import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/model/currency.dart';
import 'package:openearth_mobile/screen/house_details_screen.dart';
import 'package:openearth_mobile/service/currency_service.dart';

class HouseCard extends StatefulWidget {
  final HousePreview house;
  final Function(int)? onTap;

  const HouseCard({
    Key? key,
    required this.house,
    this.onTap,
  }) : super(key: key);

  @override
  _HouseCardState createState() => _HouseCardState();
}

class _HouseCardState extends State<HouseCard> {
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  final CurrencyService currencyService = CurrencyService();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount, String currencyCode) {
    Currency currency = currencyService.currencies.firstWhere(
          (c) => c.code == currencyCode,
      orElse: () => Currency(
        code: currencyCode,
        name: currencyCode,
        symbol: currencyCode,
        continent: '',
      ),
    );

    return NumberFormat.currency(
      symbol: currency.symbol,
      decimalDigits: 0,
    ).format(amount);
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HouseDetailsScreen(houseId: widget.house.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image carousel with PageView for sliding
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: widget.house.pictures.length,
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
                            image: NetworkImage(environment.imageUrl + widget.house.pictures[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                  // Dots indicator
                  if (widget.house.pictures.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.house.pictures.asMap().entries.map((entry) {
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
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.house.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Text(
                    _truncateText(widget.house.location, 40),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // House features
                  Row(
                    children: [
                      _buildFeatureChip(Icons.people_outline, '${widget.house.guests}'),
                      const SizedBox(width: 12),
                      _buildFeatureChip(Icons.house_outlined, '${widget.house.bedrooms}'),
                      const SizedBox(width: 12),
                      _buildFeatureChip(Icons.bed_outlined, '${widget.house.beds}'),
                      const SizedBox(width: 12),
                      _buildFeatureChip(Icons.bathroom_outlined, '${widget.house.bathrooms}'),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatCurrency(widget.house.price, widget.house.currency),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        TextSpan(
                          text: ' / night',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}