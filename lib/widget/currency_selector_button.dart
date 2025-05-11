import 'package:flutter/material.dart';
import 'package:openearth_mobile/service/currency_service.dart';
import 'package:openearth_mobile/widget/currency_widget.dart';

class CurrencySelectorButton extends StatefulWidget {
  final CurrencyService currencyService;

  const CurrencySelectorButton({
    Key? key,
    required this.currencyService,
  }) : super(key: key);

  @override
  State<CurrencySelectorButton> createState() => _CurrencySelectorButtonState();
}

class _CurrencySelectorButtonState extends State<CurrencySelectorButton> {
  @override
  void initState() {
    super.initState();
    widget.currencyService.currentCurrency.addListener(_onCurrencyChanged);
  }

  @override
  void dispose() {
    widget.currencyService.currentCurrency.removeListener(_onCurrencyChanged);
    super.dispose();
  }

  void _onCurrencyChanged() {
    setState(() {});
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CurrencySelectorWidget(
          currencyService: widget.currencyService,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.currencyService.currentCurrency.value;

    return OutlinedButton(
      onPressed: _showCurrencySelector,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide(color: Colors.grey[300]!),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currency.symbol,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            currency.code,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.keyboard_arrow_down,
            size: 20,
            color: Colors.grey[600],
          ),
        ],
      ),
    );
  }
}