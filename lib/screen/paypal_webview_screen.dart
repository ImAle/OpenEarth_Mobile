import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/service/paypal_service.dart';

class PaypalWebViewScreen extends StatefulWidget {
  final String approvalUrl;
  final Function(String) onPaymentSuccess;
  final Function() onPaymentCancelled;

  const PaypalWebViewScreen({
    super.key,
    required this.approvalUrl,
    required this.onPaymentSuccess,
    required this.onPaymentCancelled,
  });

  @override
  State<PaypalWebViewScreen> createState() => _PaypalWebViewScreenState();
}

class _PaypalWebViewScreenState extends State<PaypalWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Configure the WebView controller
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Handle return URL from PayPal
            if (request.url.startsWith('${environment.rootUrl}/paypal-success')) {
              // Extract the order ID from the URL
              Uri uri = Uri.parse(request.url);
              String? token = uri.queryParameters['token'];

              if (token != null) {
                // Call the success callback with the order ID
                widget.onPaymentSuccess(token);
              }
              return NavigationDecision.prevent;
            }

            // Handle cancel URL from PayPal
            if (request.url.startsWith('${environment.rootUrl}/paypal-cancel')) {
              widget.onPaymentCancelled();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayPal Payment'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onPaymentCancelled();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}