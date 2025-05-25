import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/rent.dart';
import 'package:openearth_mobile/screen/house_details_screen.dart';
import 'package:openearth_mobile/service/auth_service.dart';
import 'package:openearth_mobile/service/house_service.dart';
import 'package:openearth_mobile/service/rent_service.dart';

class RentScreen extends StatefulWidget {
  const RentScreen({Key? key}) : super(key: key);

  @override
  State<RentScreen> createState() => _RentScreenState();
}

class _RentScreenState extends State<RentScreen>
    with SingleTickerProviderStateMixin {
  final RentService _rentService = RentService();
  final HouseService _houseService = HouseService();
  final AuthService _authService = AuthService();

  List<Rent> _rents = [];
  Map<int, String> _houseNames = {};
  String _userRole = "";
  bool _isLoading = true;
  bool _showCancelConfirmDialog = false;
  Rent? _selectedRent;
  final Color _primaryColor = environment.primaryColor;

  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _loadUserRole();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    try {
      final response = await _authService.getRole();
      setState(() {
        _userRole = response!;
      });

      // Load rents based on user role
      if (_userRole == 'GUEST') {
        _loadGuestRents();
      } else if (_userRole == 'HOSTESS') {
        _loadHostessRents();
      }
    } catch (e) {
      _showMessage('Failed to load user role', isError: true);
    }
  }

  Future<void> _loadGuestRents() async {
    try {
      final response = await _rentService.getMyRents();
      setState(() {
        _rents = List<Rent>.from(response['rents']
            .map((rentJson) => Rent.fromJson(rentJson))
            .toList());
        _rents.sort((a, b) =>
            b.startTime.compareTo(a.startTime)); // Sort by date, newest first
      });
      await _loadHouseDetails();
    } catch (e) {
      _showMessage('Failed to load your rentals', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _loadHostessRents() async {
    try {
      final response = await _rentService.getRentsOfMyHouses();
      setState(() {
        _rents = List<Rent>.from(response['rents']
            .map((rentJson) => Rent.fromJson(rentJson))
            .toList());
        _rents.sort((a, b) =>
            b.startTime.compareTo(a.startTime)); // Sort by date, newest first
      });
      await _loadHouseDetails();
    } catch (e) {
      _showMessage('Failed to load house rentals', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _loadHouseDetails() async {
    try {
      for (var rent in _rents) {
        try {
          final response = await _houseService.getById(rent.houseId, "EUR");
          setState(() {
            _houseNames[rent.houseId] = response['house']['title'];
          });
        } catch (e) {
          print('Failed to load details for house ${rent.houseId}: $e');
        }
      }
    } catch (e) {
      print('Error loading house details: $e');
    }
  }

  Future<void> _cancelRent(int rentId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      await _rentService.cancel(rentId);

      // Reload rents after cancellation
      if (_userRole == 'GUEST') {
        await _loadGuestRents();
      }

      _showMessage('Rental cancelled successfully');
    } catch (e) {
      _showMessage('Failed to cancel rental', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showCancelConfirmation(Rent rent) {
    setState(() {
      _selectedRent = rent;
      _showCancelConfirmDialog = true;
    });
  }

  String _getRentStatus(Rent rent) {
    if (rent.cancelled) {
      return 'cancelled';
    }

    final now = DateTime.now();
    final start = rent.startDateTime;
    final end = rent.endDateTime;

    if (now.isBefore(start)) {
      return 'pending';
    } else if (now.isAfter(end)) {
      return 'completed';
    } else {
      return 'active';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.amber;
      case 'active':
        return Colors.green;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Rentals',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading rentals...',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _rents.isEmpty
              ? _buildEmptyState()
              : FadeTransition(
                  opacity: _fadeInAnimation,
                  child: RefreshIndicator(
                    onRefresh: _userRole == 'GUEST'
                        ? _loadGuestRents
                        : _loadHostessRents,
                    child: _buildRentalsList(),
                  ),
                ),
      bottomSheet:
          _showCancelConfirmDialog ? _buildCancelConfirmDialog() : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_work_outlined,
            size: 80,
            color: Colors.blue[400],
          ),
          const SizedBox(height: 24),
          Text(
            'No rentals found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _userRole == 'GUEST'
                  ? 'Start exploring properties to rent'
                  : 'Your properties haven\'t been rented yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushNamed('/home');
            },
            icon: const Icon(Icons.search, color: Colors.white),
            label: const Text('Explore Properties'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rents.length,
      itemBuilder: (context, index) {
        final rent = _rents[index];
        final status = _getRentStatus(rent);
        final houseName = _houseNames[rent.houseId] ?? 'Loading...';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildRentalCard(rent, status, houseName),
        );
      },
    );
  }

  Widget _buildRentalCard(Rent rent, String status, String houseName) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final startDate = dateFormat.format(rent.startDateTime);
    final endDate = dateFormat.format(rent.endDateTime);
    final canCancel =
        _userRole == 'GUEST' && status == 'pending' && !rent.cancelled;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HouseDetailsScreen(houseId: rent.houseId),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with property name and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      houseName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusChip(status),
                ],
              ),

              Divider(color: Colors.grey.shade200, height: 24),

              // Rental details
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.date_range,
                    color: Colors.blue[800],
                  ),
                ),
                title: const Text(
                  'Rental Period',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  '$startDate - $endDate',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.confirmation_number,
                    color: Colors.blue[800],
                  ),
                ),
                title: const Text(
                  'Rental ID',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                subtitle: Text(
                  '${rent.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Cancel Button (only for GUEST with pending rentals)
              if (canCancel)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCancelConfirmation(rent),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Cancel Rental',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCancelConfirmDialog() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cancel Rental',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to cancel your rental at ${_houseNames[_selectedRent?.houseId]}? This action cannot be undone.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showCancelConfirmDialog = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Keep Rental',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedRent != null) {
                        _cancelRent(_selectedRent!.id);
                      }
                      setState(() {
                        _showCancelConfirmDialog = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Cancel Rental',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
