import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VnpayWebView extends StatefulWidget {
  final String paymentUrl;
  final void Function(bool success, int? orderId) onPaymentResult; // Thêm orderId

  const VnpayWebView({super.key, required this.paymentUrl, required this.onPaymentResult});

  @override
  State<VnpayWebView> createState() => _VnpayWebViewState();
}

class _VnpayWebViewState extends State<VnpayWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            print('Redirect URL: ${request.url}');
            if (request.url.contains('api/vnpay/return')) {
              try {
                final response = await http.get(Uri.parse(request.url)).timeout(const Duration(seconds: 10));
                print('Response Status: ${response.statusCode}');
                print('Response Body: ${response.body}');
                if (response.statusCode == 200) {
                  final data = jsonDecode(utf8.decode(response.bodyBytes));
                  bool success = data['status'] == 'success';
                  int? orderId = data['order_id'] as int?;
                  print('Payment Success: $success, Order ID: $orderId');
                  widget.onPaymentResult(success, orderId);
                } else {
                  print('Payment Failed: Status ${response.statusCode}');
                  widget.onPaymentResult(false, null);
                }
              } catch (e) {
                widget.onPaymentResult(false, null);
              }
              // Đừng pop ở đây nữa!
              // if (mounted) Navigator.pop(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onPaymentResult(false, null); // Xử lý khi người dùng thoát thủ công
        return true;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Thanh toán VNPay')),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}