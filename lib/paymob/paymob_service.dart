// import 'dart:convert';
// import 'package:flutter/foundation.dart'; // For debugPrint
// import 'package:http/http.dart' as http;

// class PaymobService {
//   // ✅✅ --- البيانات المستخرجة من الكود والمعلومات السابقة --- ✅✅
//   // ⚠️ تأكد من أن هذه البيانات هي الصحيحة لحساب العميل (Live Mode) وتدعم USD أو SAR حسب الحاجة
//   static const String _apiKey = "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RneE5Dd2libUZ0WlNJNkltbHVhWFJwWVd3aWZRLk11OEg4Q2x6S1VMRVFtbEpqc1diblBJa1VUZXIwalFxV0hla1VMcEVlNjhBS2pkeEM5d1BHTHpZckJRMFpSaG16ajVqRDRNZmtqOGxXb2pRQ1dWMjd3";
//   static const int _integrationId = 13495; // معرف التكامل (للدفع بالبطاقة غالبًا)
//   static const String _iframeId = "9226";    // معرف الإطار لعرض صفحة الدفع
//   // ✅✅ -------------------------------------------------------- ✅✅

//   // --- روابط Paymob السعودية ---
//   static const String _baseUrl = "https://ksa.paymob.com/api"; // ✅ استخدام الرابط السعودي

//   /// الدالة الرئيسية التي تحصل على رابط الدفع
//   /// amountCents: المبلغ بالوحدة الصغرى (هللة للريال أو سنت للدولار)
//   /// currency: رمز العملة (e.g., "SAR", "USD")
//   Future<String> getPaymentUrl(String amountCents, String currency) async {
//      // التحقق المبدئي
//      if (_apiKey.isEmpty || _integrationId <= 0 || _iframeId.isEmpty) {
//        debugPrint("❌ خطأ: بيانات Paymob غير مكتملة في paymob_service.dart.");
//        throw Exception("بيانات Paymob غير مكتملة.");
//      }
//      if (amountCents.isEmpty || currency.isEmpty) {
//        throw Exception("المبلغ أو العملة غير صحيحين.");
//      }
//      debugPrint("Requesting payment URL for $amountCents $currency");

//     try {
//       String authToken = await _getAuthToken();
//       debugPrint("Paymob Auth Token obtained.");
//       String orderId = await _registerOrder(authToken, amountCents, currency);
//       debugPrint("Paymob Order ID: $orderId");
//       String paymentKey = await _getPaymentKey(authToken, orderId, amountCents, currency);
//       debugPrint("Paymob Payment Key obtained.");
//       // استخدام الرابط السعودي للـ IFrame
//       final paymentUrl = "$_baseUrl/acceptance/iframes/$_iframeId?payment_token=$paymentKey";
//       debugPrint("Paymob Payment URL: $paymentUrl");
//       return paymentUrl;
//     } catch (e) {
//       // طباعة الخطأ هنا للمطور
//       debugPrint("❌ خطأ كامل في عملية Paymob: $e");
//       // أعد رمي الخطأ ليتم عرضه للمستخدم في الشاشة (SnackBar)
//       rethrow;
//     }
//   }

//   /// الخطوة 1: الحصول على توكن المصادقة
//   Future<String> _getAuthToken() async {
//     final url = "$_baseUrl/auth/tokens"; // ✅ استخدام الرابط السعودي
//     debugPrint("Requesting Auth Token from: $url");
//     final response = await http.post(
//        Uri.parse(url),
//        headers: {'Content-Type': 'application/json'},
//        body: json.encode({"api_key": _apiKey}),
//      );
//      debugPrint("Auth Token Response Status: ${response.statusCode}");
//      // debugPrint("Auth Token Response Body: ${response.body}"); // تفعيل عند الحاجة

//      if (response.statusCode == 201) {
//        final responseBody = json.decode(response.body);
//        if (responseBody != null && responseBody['token'] != null) {
//            return responseBody['token'];
//        } else {
//           throw Exception('Auth token response format invalid: ${response.body}');
//        }
//      } else {
//        String errorMessage = response.body;
//        try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
//        debugPrint("❌ Auth Token Error: $errorMessage");
//        throw Exception('Failed to get auth token (Status ${response.statusCode}): $errorMessage');
//      }
//   }

//   /// الخطوة 2: تسجيل طلب جديد
//   Future<String> _registerOrder(String authToken, String amountCents, String currency) async {
//     final url = "$_baseUrl/ecommerce/orders"; // ✅ استخدام الرابط السعودي
//      debugPrint("Registering Order at: $url with amount: $amountCents $currency");
//     final response = await http.post(
//        Uri.parse(url),
//        headers: {'Content-Type': 'application/json'},
//        body: json.encode({
//          "auth_token": authToken,
//          "delivery_needed": "false", // للمنتجات الرقمية
//          "amount_cents": amountCents,
//          "currency": currency, // العملة الممررة (SAR أو USD)
//          "items": [], // قائمة المنتجات (يمكن تركها فارغة)
//          // "merchant_order_id": "YOUR_UNIQUE_ORDER_ID_${DateTime.now().millisecondsSinceEpoch}" // (اختياري)
//        }),
//      );
//      debugPrint("Register Order Response Status: ${response.statusCode}");
//      // debugPrint("Register Order Response Body: ${response.body}"); // تفعيل عند الحاجة

//      if (response.statusCode == 201) {
//        final responseBody = json.decode(response.body);
//        if (responseBody != null && responseBody['id'] != null) {
//             return responseBody['id'].toString();
//        } else {
//            throw Exception('Register order response format invalid: ${response.body}');
//        }
//      } else {
//        String errorMessage = response.body;
//        try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
//        debugPrint("❌ Register Order Error: $errorMessage");
//        throw Exception('Failed to register order (Status ${response.statusCode}): $errorMessage');
//      }
//   }

//   /// الخطوة 3: الحصول على مفتاح الدفع
//   Future<String> _getPaymentKey(String authToken, String orderId, String amountCents, String currency) async {
//     final url = "$_baseUrl/acceptance/payment_keys"; // ✅ استخدام الرابط السعودي
//      debugPrint("Requesting Payment Key from: $url for Order ID: $orderId");

//     // بيانات الفوترة السعودية (تأكد من صحة رقم الهاتف والبريد)
//     Map<String, dynamic> billingData = {
//           "apartment": "NA", // غير متوفر أو غير مطلوب
//           "email": "ABagalagel.1@gmail.com", // بريد العميل (أو بريد المستخدم المسجل)
//           "floor": "NA",
//           "first_name": "عبدالله", // الاسم الأول
//           "street": "NA",
//           "building": "NA",
//           "phone_number": "+966544980290", // رقم الهاتف السعودي (تأكد من صحته!)
//           "shipping_method": "NA",
//           "postal_code": "NA", // يمكن وضع رمز بريدي عام للسعودية مثل "11564" إذا لم يكن متوفرًا
//           "city": "Riyadh", // مدينة عامة أو مدينة المستخدم إذا كانت متوفرة
//           "country": "SA", // رمز السعودية
//           "last_name": "باقلاقل", // الاسم الأخير
//           "state": "Riyadh" // منطقة عامة أو منطقة المستخدم إذا كانت متوفرة
//         };
//      debugPrint("Billing Data: ${json.encode(billingData)}");

//     final response = await http.post(
//        Uri.parse(url),
//        headers: {'Content-Type': 'application/json'},
//        body: json.encode({
//          "auth_token": authToken,
//          "amount_cents": amountCents, // المبلغ بالهللات أو السنتات
//          "expiration": 3600, // صلاحية المفتاح (ساعة واحدة)
//          "order_id": orderId,
//          "billing_data": billingData, // استخدام البيانات المحدثة
//          "currency": currency, // العملة الممررة (SAR أو USD)
//          "integration_id": _integrationId, // معرف التكامل الخاص بالعميل
//          "lock_order_when_paid": "false" // السماح بإعادة المحاولة إذا فشل الدفع
//        }),
//      );
//      debugPrint("Payment Key Response Status: ${response.statusCode}");
//      // debugPrint("Payment Key Response Body: ${response.body}"); // تفعيل عند الحاجة

//      if (response.statusCode == 201) {
//         final responseBody = json.decode(response.body);
//         if (responseBody != null && responseBody['token'] != null) {
//              return responseBody['token']; // هذا هو payment_token المطلوب للـ IFrame
//         } else {
//             throw Exception('Payment key response format invalid: ${response.body}');
//         }
//      } else {
//         String errorMessage = response.body;
//         try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
//         debugPrint("❌ Payment Key Error: $errorMessage");
//         throw Exception('Failed to get payment key (Status ${response.statusCode}): $errorMessage');
//      }
//   }
// }




import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http;

class PaymobService {
  // --- بيانات العميل (تأكد من صحتها وأنها للوضع Live وتدعم SAR) ---
  static const String _apiKey = "ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2T1RneE5Dd2libUZ0WlNJNkltbHVhWFJwWVd3aWZRLk11OEg4Q2x6S1VMRVFtbEpqc1diblBJa1VUZXIwalFxV0hla1VMcEVlNjhBS2pkeEM5d1BHTHpZckJRMFpSaG16ajVqRDRNZmtqOGxXb2pRQ1dWMjd3"; // ⬅️ استبدل بمفتاح العميل
  static const int _integrationId = 13495; // ⬅️ استبدل بمعرف تكامل العميل (للبطاقة)
  static const String _iframeId = "9226";    // ⬅️ استبدل بمعرف إطار العميل

  // --- روابط Paymob السعودية ---
  static const String _baseUrl = "https://ksa.paymob.com/api"; // ✅ استخدام الرابط السعودي

  /// الدالة الرئيسية التي تحصل على رابط الدفع
  /// amountCents: المبلغ بالهللات (للسعودية)
  /// currency: رمز العملة ("SAR")
  Future<String> getPaymentUrl(String amountCents, String currency) async {
     // التحقق المبدئي
     if (_apiKey.contains("ZXlK") == false || _integrationId <= 0 || _iframeId.isEmpty) {
        // Basic check if default placeholders weren't replaced, adjust if needed
       debugPrint("❌ خطأ: بيانات Paymob قد تكون غير صحيحة.");
       // Consider throwing a more specific error if possible
       // For now, let it proceed but log the warning.
     }
     if (amountCents.isEmpty || currency.isEmpty) { throw Exception("المبلغ أو العملة غير صحيحين."); }
     if (currency != "SAR") { debugPrint("⚠️ تحذير: العملة المطلوبة ليست SAR ($currency)."); }

    try {
      String authToken = await _getAuthToken();
      debugPrint("Paymob Auth Token obtained.");
      String orderId = await _registerOrder(authToken, amountCents, currency);
      debugPrint("Paymob Order ID: $orderId");
      String paymentKey = await _getPaymentKey(authToken, orderId, amountCents, currency);
      debugPrint("Paymob Payment Key obtained.");
      // استخدام الرابط السعودي للـ IFrame
      final paymentUrl = "$_baseUrl/acceptance/iframes/$_iframeId?payment_token=$paymentKey";
      debugPrint("Paymob Payment URL: $paymentUrl");
      return paymentUrl;
    } catch (e) {
      debugPrint("❌ خطأ كامل في عملية Paymob: $e");
      rethrow;
    }
  }

  Future<String> _getAuthToken() async {
    final url = "$_baseUrl/auth/tokens";
    debugPrint("Requesting Auth Token from: $url");
    final response = await http.post(
       Uri.parse(url),
       headers: {'Content-Type': 'application/json'},
       body: json.encode({"api_key": _apiKey}),
     );
     debugPrint("Auth Token Response Status: ${response.statusCode}");
     if (response.statusCode == 201) {
       final responseBody = json.decode(response.body);
       if (responseBody != null && responseBody['token'] != null) {
           return responseBody['token'];
       } else {
          throw Exception('Auth token response format invalid: ${response.body}');
       }
     } else {
       String errorMessage = response.body;
       try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
       debugPrint("❌ Auth Token Error: $errorMessage");
       throw Exception('Failed to get auth token (Status ${response.statusCode}): $errorMessage');
     }
  }

  Future<String> _registerOrder(String authToken, String amountCents, String currency) async {
    final url = "$_baseUrl/ecommerce/orders";
     debugPrint("Registering Order at: $url with amount: $amountCents $currency");
    final response = await http.post(
       Uri.parse(url),
       headers: {'Content-Type': 'application/json'},
       body: json.encode({
         "auth_token": authToken, "delivery_needed": "false",
         "amount_cents": amountCents, // بالهللات
         "currency": currency, // SAR
         "items": [],
       }),
     );
     debugPrint("Register Order Response Status: ${response.statusCode}");
     if (response.statusCode == 201) {
       final responseBody = json.decode(response.body);
       if (responseBody != null && responseBody['id'] != null) {
            return responseBody['id'].toString();
       } else {
           throw Exception('Register order response format invalid: ${response.body}');
       }
     } else {
       String errorMessage = response.body;
       try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
       debugPrint("❌ Register Order Error: $errorMessage");
       throw Exception('Failed to register order (Status ${response.statusCode}): $errorMessage');
     }
  }

  Future<String> _getPaymentKey(String authToken, String orderId, String amountCents, String currency) async {
    final url = "$_baseUrl/acceptance/payment_keys";
     debugPrint("Requesting Payment Key from: $url for Order ID: $orderId");

    // بيانات الفوترة السعودية (تأكد من صحة رقم الهاتف والبريد)
    Map<String, dynamic> billingData = {
          "apartment": "NA",
          "email": "ABagalagel.1@gmail.com", // بريد العميل
          "floor": "NA",
          "first_name": "عبدالله", // الاسم الأول
          "street": "NA",
          "building": "NA",
          "phone_number": "+966544980290", // رقم الهاتف السعودي
          "shipping_method": "NA",
          "postal_code": "NA", // يمكن وضع رمز بريدي عام للسعودية مثل "11564" إذا لم يكن متوفرًا
          "city": "Riyadh", // مدينة عامة
          "country": "SA", // رمز السعودية
          "last_name": "باقلاقل", // الاسم الأخير
          "state": "Riyadh" // منطقة عامة
        };
     debugPrint("Billing Data: ${json.encode(billingData)}");

    final response = await http.post(
       Uri.parse(url),
       headers: {'Content-Type': 'application/json'},
       body: json.encode({
         "auth_token": authToken,
         "amount_cents": amountCents, // بالهللات
         "expiration": 3600,
         "order_id": orderId,
         "billing_data": billingData,
         "currency": currency, // SAR
         "integration_id": _integrationId,
         "lock_order_when_paid": "false"
       }),
     );
     debugPrint("Payment Key Response Status: ${response.statusCode}");
     if (response.statusCode == 201) {
        final responseBody = json.decode(response.body);
        if (responseBody != null && responseBody['token'] != null) {
             return responseBody['token'];
        } else {
            throw Exception('Payment key response format invalid: ${response.body}');
        }
     } else {
        String errorMessage = response.body;
        try { final errorBody = json.decode(response.body); errorMessage = errorBody['message'] ?? errorBody['detail'] ?? response.body; } catch (_) {}
        debugPrint("❌ Payment Key Error: $errorMessage");
        throw Exception('Failed to get payment key (Status ${response.statusCode}): $errorMessage');
     }
  }
}