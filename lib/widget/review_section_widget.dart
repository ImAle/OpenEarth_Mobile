import 'package:flutter/material.dart';
import 'package:openearth_mobile/widget/review_card.dart';

import '../model/review.dart';

class ReviewSectionWidget extends StatefulWidget {
  final List<Review> reviews;

  const ReviewSectionWidget({
    Key? key,
    required this.reviews,
  }) : super(key: key);

  @override
  _ReviewSectionState createState() => _ReviewSectionState();
}

class _ReviewSectionState extends State<ReviewSectionWidget> {
  final ScrollController _reviewsScrollController = ScrollController();

  @override
  void dispose() {
    _reviewsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.reviews.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(
              'Reviews (${widget.reviews.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              // Scrollable row of review cards
              ListView.builder(
                controller: _reviewsScrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.reviews.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 280,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: ReviewCard(
                        review: widget.reviews[index],
                      ),
                    ),
                  );
                },
              ),

              // Left scroll button
              if (widget.reviews.length > 1)
                Positioned(
                  left: 0,
                  top: 80,
                  child: _buildScrollButton(
                    direction: -1,
                  ),
                ),

              // Right scroll button
              if (widget.reviews.length > 1)
                Positioned(
                  right: 0,
                  top: 80,
                  child: _buildScrollButton(
                    direction: 1,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScrollButton({
    required int direction,
  }) {
    return InkWell(
      onTap: () {
        final currentPosition = _reviewsScrollController.offset;
        final scrollAmount = direction * 280.0;
        _reviewsScrollController.animateTo(
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