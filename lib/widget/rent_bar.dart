import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/model/house.dart';
import 'package:openearth_mobile/model/currency.dart';
import 'package:openearth_mobile/service/currency_service.dart';

class RentBar extends StatefulWidget {
  final House house;

  const RentBar({
    super.key,
    required this.house,
  });

  @override
  State<RentBar> createState() => _RentBarState();
}

class _RentBarState extends State<RentBar> {
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 2));
  bool _isReservationModalOpen = false;
  late CurrencyService _currencyService;

  @override
  void initState() {
    super.initState();
    _currencyService = CurrencyService();
  }

  String _getCurrencySymbol(String currencyCode) {
    final currencies = _currencyService.getAllCurrencies();
    final currency = currencies.firstWhere(
          (c) => c.code == currencyCode,
      orElse: () => Currency(code: currencyCode, name: currencyCode, symbol: currencyCode, continent: ''),
    );
    return currency.symbol;
  }

  String _formatCurrency(double amount, String currencyCode) {
    final currencySymbol = _getCurrencySymbol(currencyCode);

    return NumberFormat.currency(
      symbol: currencySymbol,
      decimalDigits: 0,
    ).format(amount);
  }

  int _getNights() {
    return _endDate.difference(_startDate).inDays;
  }

  double _getTotalPrice() {
    return widget.house.price * _getNights();
  }

  // Show reservation modal
  void _showReservationModal() {
    setState(() {
      _isReservationModalOpen = true;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              return _buildReservationModal(modalContext, setModalState);
            }
        );
      },
    ).then((_) {
      setState(() {
        _isReservationModalOpen = false;
      });
    });
  }

  void _handleReservation() {
    Navigator.of(context).pop();
    setState(() {
      _isReservationModalOpen = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reservation process will be implemented soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: _formatCurrency(widget.house.price, widget.house.currency),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
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
                  Text(
                    'Taxes included',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Book button
            ElevatedButton(
              onPressed: _showReservationModal,
              style: ElevatedButton.styleFrom(
                backgroundColor: environment.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildReservationModal(BuildContext context, StateSetter setModalState) {
    final currencySymbol = _getCurrencySymbol(widget.house.currency);

    return Container(
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Reserve',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Date selection
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDateSelector(
                          context: context,
                          date: _startDate,
                          onSelect: (date) {
                            setState(() {
                              _startDate = date;
                              // Ensure end date is after start date
                              if (_endDate.isBefore(_startDate.add(const Duration(days: 1)))) {
                                _endDate = _startDate.add(const Duration(days: 1));
                              }
                            });
                            // Update modal state
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Check-out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDateSelector(
                          context: context,
                          date: _endDate,
                          onSelect: (date) {
                            setState(() {
                              _endDate = date;
                            });
                            // Update modal state
                            setModalState(() {});
                          },
                          minDate: _startDate.add(const Duration(days: 1)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$currencySymbol${widget.house.price} x ${_getNights()} nights',
                          style: const TextStyle(fontSize: 16),
                        ),
                        Text(
                          _formatCurrency(_getTotalPrice(), widget.house.currency),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _formatCurrency(_getTotalPrice(), widget.house.currency),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reserve button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleReservation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: environment.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue to Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(
                  foregroundColor: environment.primaryColor,
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required BuildContext context,
    required DateTime date,
    required Function(DateTime) onSelect,
    DateTime? minDate,
  }) {
    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day + 1);
        final minSelectableDate = minDate ?? tomorrow;

        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date.isBefore(minSelectableDate) ? minSelectableDate : date,
          firstDate: minSelectableDate,
          lastDate: DateTime(now.year + 1, now.month, now.day),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: environment.primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: environment.primaryColor,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedDate != null) {
          onSelect(selectedDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: const TextStyle(fontSize: 14),
            ),
            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}