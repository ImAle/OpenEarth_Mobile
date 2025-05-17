import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house_preview.dart';
import 'package:openearth_mobile/model/user.dart';
import 'package:openearth_mobile/service/user_service.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/service/currency_service.dart';
import 'package:openearth_mobile/widget/house_card.dart';
import 'package:openearth_mobile/widget/review_card.dart';
import 'package:openearth_mobile/widget/report_creation_widget.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserService _userService = UserService();
  final HouseService _houseService = HouseService();
  final CurrencyService _currencyService = CurrencyService();

  User? _user;
  List<HousePreview> _houses = [];
  bool _isLoading = true;
  String _currency = 'EUR'; // Default currency
  bool _isReportModalVisible = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _currencyService.initialized;
      _currency = _currencyService.getCurrentCurrencyCode();

      final response = await _userService.getUser(widget.userId);
      _user = User.fromJson(response['user']);

      // If user is HOSTESS, load their houses
      if (_user!.role == 'HOSTESS') {
        final housesResponse = await _houseService.getHousesByOwner(_user!.id, _currency);
        setState(() {
          _houses = (housesResponse['houses'] as List)
              .map((house) => HousePreview.fromJson(house))
              .toList();
        });
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  void _showReportModal() {
    setState(() {
      _isReportModalVisible = true;
    });
  }

  void _hideReportModal() {
    setState(() {
      _isReportModalVisible = false;
    });
  }

  void _navigateToChat() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat functionality coming soon')),
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

    if (_user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User not found')),
        body: const Center(
          child: Text('Unable to load user profile'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // Add space for the back button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 60),
                ),

                // User profile card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildUserProfileCard(),
                  ),
                ),

                // Action buttons (Chat and Report)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _buildActionButtons(),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: _user!.role == 'GUEST'
                        ? _buildGuestContent()
                        : _buildHostessContent(),
                  ),
                ),

                // Add bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 16,
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

          // Report Modal (if visible)
          if (_isReportModalVisible && _user != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ReportCreationWidget(
                reportedUserId: _user!.id,
                onReportSuccess: _hideReportModal,
                onCancel: _hideReportModal,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        children: [
          // Chat Button
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
              onPressed: _navigateToChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: environment.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Report Button
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flag_outlined, size: 18),
              label: const Text('Report'),
              onPressed: _showReportModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // User profile picture (left side)
            Container(
              width: 170,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _user?.picture == null
                      ? const AssetImage('assets/default_user.jpg')
                      : NetworkImage(environment.imageUrl + _user!.picture) as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Right side content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User info section
                    Text(
                      _user!.username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // User role
                    Row(
                      children: [
                        Icon(
                          _user!.role == 'GUEST' ? Icons.person : Icons.business_center,
                          size: 16,
                          color: environment.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _user!.role == 'GUEST' ? 'Guest' : 'Hostess',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Divider line
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[300], thickness: 1),
                    const SizedBox(height: 16),

                    // Registration date
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Joined ${DateFormat('MMMM yyyy').format(_user!.creationDate)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestContent() {
    if (_user!.reviews.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rate_rounded, color: environment.primaryColor, size: 20),
            const SizedBox(width: 4),
            Text(
              'Reviews (${_user!.reviews.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of reviews
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _user!.reviews.length,
          itemBuilder: (context, index) {
            return ReviewCard(review: _user!.reviews[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHostessContent() {
    if (_houses.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Text(
            'No properties listed yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return _buildHousesList();
  }

  Widget _buildHousesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.house, color: environment.primaryColor, size: 20),
            const SizedBox(width: 4),
            Text(
              'Properties (${_houses.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // List of houses
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _houses.length,
          itemBuilder: (context, index) {
            return HouseCard(house: _houses[index]);
          },
        ),
      ],
    );
  }
}