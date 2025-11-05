// import 'package:flutter/material.dart';
// import 'package:plot_app/paymob/payment_manager.dart'; // تأكد من استيراد النسخة المعدلة
// import 'package:plot_app/paymob/payment_webview_screen.dart';
// import 'package:plot_app/paymob/paymob_service.dart'; // تأكد من استيراد النسخة المعدلة

// import 'chat_screen.dart';
// import 'plot_data.dart';
// import 'ad_manager.dart'; // لاستدعاء الإعلانات

// class CustomPlotTypeScreen extends StatefulWidget {
//   const CustomPlotTypeScreen({super.key});

//   @override
//   State<CustomPlotTypeScreen> createState() => _CustomPlotTypeScreenState();
// }

// class _CustomPlotTypeScreenState extends State<CustomPlotTypeScreen> {
//   Map<String, List<String>> _plots = {};
//   final PaymobService _paymobService = PaymobService();

//   @override
//   void initState() {
//     super.initState();
//     _loadPlots();
//   }

//   Future<void> _loadPlots() async {
//     final data = await loadPlotsFromAssets();
//      if (mounted) {
//         setState(() => _plots = data);
//      }
//   }

//   void _onPlotTypeTapped(String plotType) async {
//     bool isPremium = await PaymentManager.isPremiumUser();
//     if (isPremium) { _goToChat(plotType); return; }
//     bool canUseFree = await PaymentManager.canUseFreeFeature();
//     if (canUseFree) { _showRewardedAdToUnlock(plotType); }
//     else { _showPaymentDialog(plotType); }
//   }

//   void _goToChat(String plotType) {
//      if (!mounted) return;
//     Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(plotType: plotType)));
//   }

//   void _showRewardedAdToUnlock(String plotType) {
//      if (!mounted) return;
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
//     AdManager.showRewardedAd(
//       () async {
//          if (!mounted) return;
//         Navigator.pop(context);
//         debugPrint("🎉 استهلاك محاولة مخصصة واحدة.");
//         await PaymentManager.incrementFreeUses();
//         _goToChat(plotType);
//       },
//       (String errorMessage) {
//          if (!mounted) return;
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
//         );
//       }
//     );
//   }

//   // ✅✅ --- بداية التعديل: تحديث نص السعر --- ✅✅
//   /// عرض نافذة الدفع عندما تنتهي المحاولات المخصصة
//   void _showPaymentDialog(String plotType) {
//      if (!mounted) return;
//      // السعر للعرض للمستخدم (تأكد منه)
//      const String displayPrice = "15 ريال سعودي";

//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("انتهت المحاولات المجانية 😔"),
//         content: Text( // استخدام Text مع متغير السعر
//           "لقد استهلكت محاولاتك المجانية (3) للحبكة المخصصة لهذا اليوم.\nللوصول الدائم وغير المحدود، يمكنك شراء الاشتراك الآن مقابل $displayPrice فقط.",
//           textDirection: TextDirection.rtl,
//         ),
//         actions: [
//           TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
//           ElevatedButton(
//             child: Text("شراء ($displayPrice) 💳"), // استخدام متغير السعر
//             onPressed: () { Navigator.pop(ctx); _handlePaymobPayment(); },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
//   // ✅✅ --- نهاية التعديل --- ✅✅


//   // ✅✅ --- بداية التعديل: تحديث العملة والمبلغ --- ✅✅
//   /// بدء عملية الدفع عبر Paymob (بالريال السعودي)
//   void _handlePaymobPayment() async {
//      if (!mounted) return;
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);

//     // ⚠️⚠️ السعر: 15 ريال سعودي = 1500 هللة (تأكد من هذا السعر)
//     const String amountCents = "1500"; // ⬅️ المبلغ بالهللات
//     const String currency = "SAR"; // ⬅️ تغيير العملة إلى ريال سعودي

//     try {
//       // تمرير المبلغ والعملة الجديدين
//       final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
//       if (!mounted) return;
//       Navigator.pop(context); // إخفاء مؤشر التحميل
//       if (!mounted) return;
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl),
//         ),
//       );
//     } catch (e) {
//        if (!mounted) return;
//       Navigator.pop(context); // إخفاء مؤشر التحميل
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red),
//       );
//     }
//   }
//   // ✅✅ --- نهاية التعديل --- ✅✅


//   @override
//   Widget build(BuildContext context) {
//     final categories = _plots.keys.toList();
//     return Scaffold(
//       appBar: AppBar(title: const Text('اختر نوع الحبكة 🎭')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: categories.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : GridView.builder(
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 3 / 2,
//                 ),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final categoryName = categories[index];
//                   final cardBackgroundColor = Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.white;
//                   final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.blueAccent : const Color(0xFF1E88E5);

//                   return Card(
//                     color: cardBackgroundColor,
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                     child: InkWell(
//                       onTap: () => _onPlotTypeTapped(categoryName),
//                       borderRadius: BorderRadius.circular(14),
//                       child: Center(
//                         child: Text(
//                           categoryName,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//       ),
//     );
//   }
// }



// [ملف: custom_plot_type_screen.dart]

import 'package:flutter/material.dart';
// ❌ تم حذف كل استيرادات الإعلانات والدفع من هنا
import 'chat_screen.dart';
import 'plot_data.dart';

class CustomPlotTypeScreen extends StatefulWidget {
  const CustomPlotTypeScreen({super.key});

  @override
  State<CustomPlotTypeScreen> createState() => _CustomPlotTypeScreenState();
}

class _CustomPlotTypeScreenState extends State<CustomPlotTypeScreen> {
  Map<String, List<String>> _plots = {};
  // ❌ تم حذف PaymobService و AdManager من هنا

  @override
  void initState() {
    super.initState();
    _loadPlots();
  }

  Future<void> _loadPlots() async {
    final data = await loadPlotsFromAssets();
     if (mounted) {
        setState(() => _plots = data);
     }
  }

  // ✅✅ --- بداية التعديل --- ✅✅
  /// الدالة الرئيسية عند الضغط على نوع الحبكة
  void _onPlotTypeTapped(String plotType) {
    // 1. الانتقال مباشرة إلى شاشة الشات
    _goToChat(plotType);
  }

  /// فتح شاشة الشات
  void _goToChat(String plotType) {
     if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(plotType: plotType)),
    );
  }
  // ❌ تم حذف جميع دوال الإعلانات والدفع
  // _showRewardedAdToUnlock() ❌
  // _showPaymentDialog() ❌
  // _handlePaymobPayment() ❌
  // ✅✅ --- نهاية التعديل --- ✅✅


  @override
  Widget build(BuildContext context) {
    // الحصول على قائمة أسماء التصنيفات من البيانات المحملة
    final categories = _plots.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('اختر نوع الحبكة 🎭')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // عرض مؤشر تحميل إذا كانت البيانات لم تُحمّل بعد
        child: categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            // عرض الشبكة بمجرد تحميل البيانات
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عمودان
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3 / 2, // نسبة العرض للارتفاع لكل عنصر
                ),
                itemCount: categories.length, // عدد العناصر هو عدد التصنيفات
                itemBuilder: (context, index) {
                  final categoryName = categories[index]; // اسم التصنيف الحالي

                  // استخدام لون مناسب للثيم للبطاقات
                  final cardBackgroundColor = Theme.of(context).brightness == Brightness.dark
                                              ? Colors.grey[800]
                                              : Colors.white;
                  // استخدام لون مناسب للثيم للنص
                   final textColor = Theme.of(context).brightness == Brightness.dark
                                     ? Colors.blueAccent
                                     : const Color(0xFF1E88E5);

                  return Card(
                    color: cardBackgroundColor, // لون البطاقة حسب الثيم
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      // ✅ استدعاء الدالة المبسطة
                      onTap: () => _onPlotTypeTapped(categoryName), // استدعاء الدالة الرئيسية عند الضغط
                      borderRadius: BorderRadius.circular(14),
                      child: Center(
                        child: Text(
                          categoryName, // عرض اسم التصنيف
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor // لون النص حسب الثيم
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}