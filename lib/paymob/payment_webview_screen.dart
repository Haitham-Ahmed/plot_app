import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'payment_manager.dart'; // لاستدعاء دالة فتح الاشتراك

class PaymentWebViewScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
            // 2. مراقبة الـ URL للتحقق من نجاح الدفع
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            // يمكنك إضافة منطق هنا إذا أردت منع التنقل لروابط معينة
            return NavigationDecision.navigate;
          },
        ),
      )
      // 1. تحميل رابط الدفع
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkPaymentStatus(String url) {
    // Paymob تعيدنا لرابط يحتوي على "success=true" عند النجاح
    final uri = Uri.parse(url);
    if (uri.queryParameters['success'] == 'true') {
      debugPrint('✅ Payment Successful!');
      
      // 3. تفعيل الاشتراك وتنبيه المستخدم والعودة
      PaymentManager.unlockPremium().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("🎉 شكرًا لك! تم تفعيل الاشتراك."),
            backgroundColor: Colors.green,
          ),
        );
        // العودة للشاشة الرئيسية بعد ثانيتين
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        });
      });
    } else if (uri.queryParameters['success'] == 'false') {
      debugPrint('❌ Payment Failed or Cancelled.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("لم تتم عملية الدفع. حاول مرة أخرى."),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إتمام عملية الدفع")),
      body: WebViewWidget(controller: _controller),
    );
  }
}