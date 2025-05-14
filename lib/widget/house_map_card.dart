import 'package:flutter/material.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/screen/house_details_screen.dart';

class HouseMapCard extends StatelessWidget {
  final HousePreview house;

  const HouseMapCard({
    Key? key,
    required this.house,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HouseDetailsScreen(houseId: house.id),
            ),
          );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: house.pictures.isNotEmpty
                  ? Image.network( environment.imageUrl + house.pictures[0],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.home, color: Colors.grey),
                  );
                },
              )
                  : Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.home, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),
            // House information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    house.location,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${house.price} ${house.currency}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: environment.primaryColor,
                        ),
                      ),
                      const Text(' · '),
                      Row(
                        children: [
                          const Icon(Icons.person_outlined, size: 16),
                          const SizedBox(width: 2),
                          Text('${house.guests}'),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.house_outlined, size: 16),
                          const SizedBox(width: 2),
                          Text('${house.bedrooms}'),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.king_bed_outlined, size: 16),
                          const SizedBox(width: 2),
                          Text('${house.beds}'),
                        ],
                      ),

                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(Icons.bathroom_outlined, size: 16),
                          const SizedBox(width: 2),
                          Text('${house.bathrooms}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
}