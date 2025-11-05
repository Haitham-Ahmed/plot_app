// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'dart:math'; // للتأكد من وجود Random
// import 'package:shared_preferences/shared_preferences.dart';
// import 'plot_data.dart'; // تأكد من استيراد النسخة المعدلة
// import 'custom_plot_type_screen.dart';
// import 'package:share_plus/share_plus.dart';
// import 'favorites_screen.dart';
// import 'main.dart'; // للوصول لـ themeNotifier
// import 'package:plot_app/paymob/payment_webview_screen.dart';
// import 'package:plot_app/paymob/paymob_service.dart'; // تأكد من استيراد النسخة المعدلة
// import 'author_screen.dart'; // ✅ استيراد شاشة قلم الكاتب الجديدة

// // استيراد AdManager و PaymentManager
// import 'ad_manager.dart';
// import 'package:plot_app/paymob/payment_manager.dart'; // تأكد من استيراد النسخة المعدلة

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0;
//   Map<String, List<String>> _plots = {};
//   final PaymobService _paymobService = PaymobService();

//   @override
//   void initState() {
//     super.initState();
//     _loadPlots();
//   }

//   Future<void> _loadPlots() async {
//     final data = await loadPlotsFromAssets();
//     if (mounted) {
//        setState(() => _plots = data);
//     }
//   }

//   // --- بداية منطق الحبكة العشوائية ---
// /*************  ✨ Windsurf Command ⭐  *************/
//   /// يعالج الحبكة العشوائية، ويحول بدون معاودة إذا كان المستخدم من المشتركين
//   /// ويحول معاودة من 3 محاولات جديدة بعد مشاهدة الإعلان
//   ///
// /*******  c1de6afa-a602-41d9-b642-1c551b0af41f  *******/
//   void _handleRandomPlotUsage() async {
//     bool isPremium = await PaymentManager.isPremiumUser();
//     if (isPremium) { _showRandomPlotDialog(); return; }
//     bool canUse = await PaymentManager.canUseRandomPlotFeature();
//     if (canUse) { _showRandomPlotDialog(); await PaymentManager.incrementRandomPlotUses(); }
//     else { _showWatchAdDialog(); }
//   }

//   void _showRandomPlotDialog() {
//     final randomPlotData = getRandomPlotWithTitleFromMap(_plots);
//     final title = randomPlotData['title'] ?? 'حبكة عشوائية';
//     final plotText = randomPlotData['plot'] ?? 'حدث خطأ.';
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title, textAlign: TextAlign.right, textDirection: TextDirection.rtl),
//         content: SingleChildScrollView(
//           child: Text(plotText, textDirection: TextDirection.rtl, style: const TextStyle(height: 1.5)),
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
//           if (randomPlotData['title'] != "خطأ")
//             TextButton(
//               onPressed: () { Share.share('"$title"\n\n$plotText'); Navigator.pop(context); },
//               child: const Text('مشاركة'),
//             ),
//         ],
//       ),
//     );
//   }

//   void _showWatchAdDialog() async {
//      bool adWatched = await PaymentManager.didWatchRandomPlotAdToday();
//      if (!mounted || adWatched) {
//         if(adWatched && mounted){
//            ScaffoldMessenger.of(context).showSnackBar(
//              const SnackBar(content: Text("لقد استهلكت جميع محاولاتك لهذا اليوم."), backgroundColor: Colors.orange),
//            );
//         }
//         return;
//      }
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text("المحاولات انتهت ⌛"),
//         content: const Text(
//           "لقد استهلكت محاولاتك المجانية (3) للحبكة العشوائية لهذا اليوم.\nهل تريد مشاهدة إعلان قصير للحصول على 3 محاولات إضافية؟",
//           textDirection: TextDirection.rtl,
//         ),
//         actions: [
//           TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
//           ElevatedButton(
//             child: const Text("مشاهدة إعلان 🎬"),
//             onPressed: () { Navigator.pop(ctx); _showRewardedAdForMoreUses(); },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showRewardedAdForMoreUses() {
//      if (!mounted) return;
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
//     AdManager.showRewardedAd(
//       () async {
//         if (!mounted) return;
//         Navigator.pop(context);
//         debugPrint("🎉 منح محاولات عشوائية إضافية.");
//         await PaymentManager.grantMoreRandomPlotUses();
//          if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("شكرًا لك! تم إضافة 3 محاولات عشوائية جديدة."), backgroundColor: Colors.green),
//         );
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
//   // --- نهاية منطق الحبكة العشوائية ---

//   void _goToCustomPlot() {
//      if (!mounted) return;
//     Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomPlotTypeScreen()));
//   }

//   /// بناء الواجهة الرئيسية (مع إضافة أيقونات الأزرار وشعار)
//   Widget _buildMain() {
//     return Center(
//        child: SingleChildScrollView( // يسمح بالتمرير إذا أصبحت الشاشة أصغر
//         padding: const EdgeInsets.symmetric(horizontal: 20.0), // إضافة padding أفقي
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عموديًا
//           children: <Widget>[
//             const SizedBox(height: 40), // مسافة من الأعلى

//             // ✅ إضافة شعار التطبيق (تأكد من وجود الملف في assets/images/logo.png)
//             // يمكنك تغيير حجمه حسب الحاجة
//             Image.asset(
//               'assets/images/open-book.png', 
//               width: 100, // <-- تأكد من اسم الملف والمسار
//               height: 120,
//               // errorBuilder: (context, error, stackTrace) {
//               //    // في حالة عدم وجود الشعار، اعرض النص كبديل
//               //    return const Icon(Icons.book_online, size: 100, color: Colors.blue); // أو أي أيقونة أخرى
//               // },
//              ),
//              //Image.asset('assets/images/open-book.png', width: 100, height: 100), // الكتاب القديم

//             const SizedBox(height: 16),
//             const Text('مولد الحبكات', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//             const Text('Plot Generator', style: TextStyle(fontSize: 18, color: Colors.grey)),
//             const SizedBox(height: 40), // تقليل المسافة قليلًا
//             const Text('أهلا بك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             const Text('اضغط على أدناه لتبدأ', style: TextStyle(fontSize: 16)),
//             const SizedBox(height: 30), // تقليل المسافة
//             SizedBox( // زر العشوائي
//               width: 280, height: 64,
//               child: ElevatedButton.icon(
//                 onPressed: _handleRandomPlotUsage,
//                 // ✅ إضافة أيقونة الزهر (🎲)
//                 icon: const Text('🎲', style: TextStyle(fontSize: 24)), // استخدام نص كأيقونة
//                 // icon: const Icon(Icons.casino_rounded, size: 26, color: Colors.white), // أو أيقونة Flutter
//                 label: const Text('توليد حبكة عشوائية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox( // زر المخصص
//               width: 280, height: 64,
//               child: ElevatedButton.icon(
//                 onPressed: _goToCustomPlot,
//                  // ✅ إضافة أيقونة الجوهرة (💎)
//                  icon: const Text('💎', style: TextStyle(fontSize: 24)), // استخدام نص كأيقونة
//                 // icon: const Icon(Icons.diamond_outlined, size: 30, color: Color(0xFF5950d4)), // أو أيقونة Flutter
//                 label: const Text('حبكة مخصصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).cardColor, foregroundColor: const Color(0xFF1E88E5),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     side: const BorderSide(color: Color(0xFF1E88E5), width: 2),
//                   ),
//                 ),
//               ),
//             ),
//              const SizedBox(height: 40), // مسافة سفلية
//           ],
//         ),
//       ),
//     );
//   }

//   /// بدء عملية الدفع عبر Paymob (بالريال السعودي)
//    void _handlePaymobPayment() async {
//      if (!mounted) return;
//     showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
//     const String amountCents = "1500"; // 15 ريال
//     const String currency = "SAR";
//     try {
//       final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
//       if (!mounted) return;
//       Navigator.pop(context);
//       if (!mounted) return;
//       Navigator.push( context, MaterialPageRoute( builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl), ), );
//     } catch (e) {
//        if (!mounted) return;
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red), );
//     }
//   }

//   /// بناء صفحة الترقية (بالريال السعودي)
//   Widget _buildUpgradePage() {
//     final theme = Theme.of(context);
//     final titleStyle = theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);
//     final subtitleStyle = theme.textTheme.bodyLarge;
//     const String displayPrice = "15 ريال سعودي";
//     return Padding(
//        padding: const EdgeInsets.all(24.0),
//        child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text('💎 افتح تجربة الكتابة الكاملة', style: titleStyle, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
//             const SizedBox(height: 30),
//             _buildFeatureItem(icon: '🔁', text: 'توليد حبكات غير محدود'),
//             _buildFeatureItem(icon: '🚫', text: 'بدون إعلانات'),
//             _buildFeatureItem(icon: '🎭', text: 'وصول مباشر للحبكة المخصصة'),
//             _buildFeatureItem(icon: '✨', text: 'تحديثات قادمة ومزايا حصرية للمشتركين'),
//             const SizedBox(height: 40),
//             ElevatedButton.icon(
//               icon: const Icon(Icons.diamond_outlined, color: Colors.white),
//               label: Text('اشترِ النسخة الكاملة الآن بـ $displayPrice', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//               onPressed: _handlePaymobPayment,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: theme.primaryColor,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text('عمليات الشراء آمنة وتتم عبر PayMob.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
//             const SizedBox(height: 50),
//             Text(
//               '✍ الكتابة ليست صدفة… بل قرار.\nاتخذ قرارك اليوم.',
//               textAlign: TextAlign.center,
//               style: subtitleStyle?.copyWith(fontStyle: FontStyle.italic),
//               textDirection: TextDirection.rtl,
//             ),
//           ],
//         ),
//     );
//   }

//   /// دالة مساعدة لصفحة الترقية
//   Widget _buildFeatureItem({required String icon, required String text}) {
//     return Padding(
//        padding: const EdgeInsets.symmetric(vertical: 8.0),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.end,
//          children: [
//            Text(text, style: Theme.of(context).textTheme.bodyLarge, textDirection: TextDirection.rtl),
//            const SizedBox(width: 12),
//            Text(icon, style: const TextStyle(fontSize: 20)),
//          ],
//        ),
//     );
//   }

//   // ❌❌ تم حذف دالة بناء صفحة الإعدادات القديمة ❌❌


//   @override
//   Widget build(BuildContext context) {
//      // ✅✅ تحديث قائمة الصفحات للشريط السفلي ✅✅
//     final pages = [
//       _buildMain(),           // Index 0: الرئيسية
//       const FavoritesScreen(),// Index 1: المفضلة
//       _buildUpgradePage(),    // Index 2: الترقية
//       const AuthorScreen(),   // Index 3: قلم الكاتب (بدلاً من الإعدادات)
//     ];

//     // تحديد الثيم الحالي لتمريره إلى الشريط السفلي إذا لزم الأمر
//     final bool isDark = Theme.of(context).brightness == Brightness.dark;
//     final Color selectedColor = isDark ? Colors.blueAccent : const Color(0xFF1E88E5);
//     final Color unselectedColor = Colors.grey;

//     return Scaffold(
//       // لا حاجة لـ AppBar هنا لأن كل صفحة تبني ما تحتاجه
//       // appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.transparent, elevation: 0),
//       body: pages[_currentIndex], // عرض الصفحة الحالية بناءً على Index
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: (i) {
//           if (mounted) {
//              setState(() => _currentIndex = i); // تحديث الـ Index عند الضغط
//           }
//         },
//         type: BottomNavigationBarType.fixed, // مهم لعرض كل العناصر دائمًا
//         selectedItemColor: selectedColor, // لون العنصر المختار
//         unselectedItemColor: unselectedColor, // لون العناصر غير المختارة
//         //backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white, // لون خلفية الشريط (اختياري)
//         // ✅✅ تحديث عناصر الشريط السفلي ✅✅
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'الرئيسية'), // أيقونة للرئيسية
//           BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'المفضلة'), // أيقونة للمفضلة
//           BottomNavigationBarItem(icon: Icon(Icons.diamond_outlined), activeIcon: Icon(Icons.diamond), label: 'الترقية'), // أيقونة للترقية (جوهرة)
//           BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note), label: 'قلم الكاتب'), // 🖋 أيقونة لقلم الكاتب
//         ],
//       ),
//     );
//   }
// }




// [ملف: home_screen.dart] - النسخة الكاملة والمعدلة

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math'; // للتأكد من وجود Random
import 'package:shared_preferences/shared_preferences.dart';
import 'plot_data.dart'; // تأكد من استيراد النسخة المعدلة

// ✅✅ --- بداية التعديل (إخفاء PaymentManager من هذا الاستيراد) --- ✅✅
// هذا يحل مشكلة اسم الكلاس المتعارض
import 'custom_plot_type_screen.dart' hide PaymentManager;
// ✅✅ --- نهاية التعديل --- ✅✅

import 'package:share_plus/share_plus.dart';
import 'favorites_screen.dart';
import 'main.dart'; // للوصول لـ themeNotifier
import 'package:plot_app/paymob/payment_webview_screen.dart';
import 'package:plot_app/paymob/paymob_service.dart'; // تأكد من استيراد النسخة المعدلة
import 'author_screen.dart'; // ✅ استيراد شاشة قلم الكاتب الجديدة

// استيراد AdManager و PaymentManager
import 'ad_manager.dart';
// ✅ هذا الاستيراد هو الذي سنعتمد عليه لـ PaymentManager
import 'package:plot_app/paymob/payment_manager.dart'; // تأكد من استيراد النسخة المعدلة

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  Map<String, List<String>> _plots = {};
  final PaymobService _paymobService = PaymobService();

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

  // --- بداية منطق الحبكة العشوائية ---
  void _handleRandomPlotUsage() async {
    bool isPremium = await PaymentManager.isPremiumUser();
    if (isPremium) { _showRandomPlotDialog(); return; }
    bool canUse = await PaymentManager.canUseRandomPlotFeature();
    if (canUse) { _showRandomPlotDialog(); await PaymentManager.incrementRandomPlotUses(); }
    else { _showWatchAdDialog(); }
  }

  void _showRandomPlotDialog() {
    final randomPlotData = getRandomPlotWithTitleFromMap(_plots);
    final title = randomPlotData['title'] ?? 'حبكة عشوائية';
    final plotText = randomPlotData['plot'] ?? 'حدث خطأ.';
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, textAlign: TextAlign.right, textDirection: TextDirection.rtl),
        content: SingleChildScrollView(
          child: Text(plotText, textDirection: TextDirection.rtl, style: const TextStyle(height: 1.5)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
          if (randomPlotData['title'] != "خطأ")
            TextButton(
              onPressed: () { Share.share('"$title"\n\n$plotText'); Navigator.pop(context); },
              child: const Text('مشاركة'),
            ),
        ],
      ),
    );
  }

  void _showWatchAdDialog() async {
     bool adWatched = await PaymentManager.didWatchRandomPlotAdToday();
     if (!mounted || adWatched) {
        if(adWatched && mounted){ // Show message only if ad was already watched
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("لقد استهلكت جميع محاولاتك لهذا اليوم."), backgroundColor: Colors.orange),
           );
        }
        return;
     }
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("المحاولات انتهت ⌛"),
        content: const Text(
          "لقد استهلكت محاولاتك المجانية (3) للحبكة العشوائية لهذا اليوم.\nهل تريد مشاهدة إعلان قصير للحصول على 3 محاولات إضافية؟",
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(child: const Text("لاحقًا"), onPressed: () => Navigator.pop(ctx)),
          ElevatedButton(
            child: const Text("مشاهدة إعلان 🎬"),
            onPressed: () { Navigator.pop(ctx); _showRewardedAdForMoreUses(); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  void _showRewardedAdForMoreUses() {
     if (!mounted) return;
    // Show loading indicator while the ad is loading/showing
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    AdManager.showRewardedAd(
      () async { // onAdCompleted callback
        if (!mounted) return;
        Navigator.pop(context); // Dismiss loading indicator
        debugPrint("🎉 منح محاولات عشوائية إضافية.");
        await PaymentManager.grantMoreRandomPlotUses();
         if (!mounted) return; // Check again after await
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("شكرًا لك! تم إضافة 3 محاولات عشوائية جديدة."), backgroundColor: Colors.green),
        );
      },
      (String errorMessage) { // onAdFailed callback
         if (!mounted) return;
        Navigator.pop(context); // Dismiss loading indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    );
  }
  // --- نهاية منطق الحبكة العشوائية ---

  void _goToCustomPlot() {
     if (!mounted) return;
     // تأكد من أن CustomPlotTypeScreen معرف ككلاس
     // (هذا يجب أن يعمل الآن بعد تصحيح الاستيراد)
     Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomPlotTypeScreen()));
  }

  /// بناء الواجهة الرئيسية (مع إضافة أيقونات الأزرار وشعار)
  Widget _buildMain() {
    return Center(
       child: SingleChildScrollView( // يسمح بالتمرير إذا أصبحت الشاشة أصغر
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // إضافة padding أفقي
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // توسيط المحتوى عموديًا
          children: <Widget>[
            const SizedBox(height: 40), // مسافة من الأعلى

            // ✅ إضافة شعار التطبيق (تأكد من وجود الملف في assets/images/open-book.png)
            Image.asset(
              'assets/images/open-book.png',
              width: 100,
              height: 120,
              // Optional: Add error builder if the image might not exist
              // errorBuilder: (context, error, stackTrace) {
              //    return const Icon(Icons.book_online, size: 100, color: Colors.blue);
              // },
             ),

            const SizedBox(height: 16),
            const Text('مولد الحبكات', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const Text('Plot Generator', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 40), // تقليل المسافة قليلًا
            const Text('أهلا بك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('اضغط على أدناه لتبدأ', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 30), // تقليل المسافة
            SizedBox( // زر العشوائي
              width: 280, height: 64,
              child: ElevatedButton.icon(
                onPressed: _handleRandomPlotUsage,
                // ✅ استخدام أيقونة الزهر (🎲) كنص
                icon: const Text('🎲', style: TextStyle(fontSize: 24, color: Colors.white)), // Ensure white color
                label: const Text('توليد حبكة عشوائية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5), foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox( // زر المخصص
              width: 280, height: 64,
              child: ElevatedButton.icon(
                onPressed: _goToCustomPlot,
                 // ✅ استخدام أيقونة الجوهرة (💎) كنص
                 icon: const Text('💎', style: TextStyle(fontSize: 24, color: Color(0xFF1E88E5))), // Ensure blue color
                label: const Text('حبكة مخصصة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor, // Use card color for background
                  foregroundColor: const Color(0xFF1E88E5), // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFF1E88E5), width: 2), // Blue border
                  ),
                  elevation: 2, // Add slight elevation
                ),
              ),
            ),
             const SizedBox(height: 40), // مسافة سفلية
          ],
        ),
      ),
    );
  }

  /// بدء عملية الدفع عبر Paymob (بالريال السعودي)
   void _handlePaymobPayment() async {
     if (!mounted) return;
    // Show loading indicator
    showDialog(context: context, builder: (context) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    // ⚠️⚠️ السعر: 15 ريال سعودي = 1500 هللة
    const String amountCents = "1500"; // ⬅️ المبلغ بالهللات
    const String currency = "SAR"; // ⬅️ تغيير العملة إلى ريال سعودي
    try {
      final paymentUrl = await _paymobService.getPaymentUrl(amountCents, currency);
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading indicator
      if (!mounted) return; // Check again after await
      // Open webview
      Navigator.push( context, MaterialPageRoute( builder: (context) => PaymentWebViewScreen(paymentUrl: paymentUrl), ), );
    } catch (e) {
       if (!mounted) return;
      Navigator.pop(context); // Dismiss loading indicator
      ScaffoldMessenger.of(context).showSnackBar( SnackBar(content: Text("❌ فشل بدء الدفع: ${e.toString()}"), backgroundColor: Colors.red), );
    }
  }

  /// بناء صفحة الترقية (بالريال السعودي)
  Widget _buildUpgradePage() {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold);
    final subtitleStyle = theme.textTheme.bodyLarge;
    // ✅✅ السعر لعرضه للمستخدم بالريال ✅✅
    const String displayPrice = "15 ريال سعودي"; // ⬅️ تأكد من هذا السعر
    return Padding(
       padding: const EdgeInsets.all(24.0),
       child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('💎 افتح تجربة الكتابة الكاملة', style: titleStyle, textAlign: TextAlign.center, textDirection: TextDirection.rtl),
            const SizedBox(height: 30),
            _buildFeatureItem(icon: '🔁', text: 'توليد حبكات غير محدود'),
            _buildFeatureItem(icon: '🚫', text: 'بدون إعلانات'),
            _buildFeatureItem(icon: '🎭', text: 'وصول مباشر للحبكة المخصصة'),
            _buildFeatureItem(icon: '✨', text: 'تحديثات قادمة ومزايا حصرية للمشتركين'),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.diamond_outlined, color: Colors.white),
              label: Text('اشترِ النسخة الكاملة الآن بـ $displayPrice', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: _handlePaymobPayment, // Link the updated payment function
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor, // Use primary theme color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('عمليات الشراء آمنة وتتم عبر PayMob.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 50),
            Text(
              '✍ الكتابة ليست صدفة… بل قرار.\nاتخذ قرارك اليوم.',
              textAlign: TextAlign.center,
              style: subtitleStyle?.copyWith(fontStyle: FontStyle.italic),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
    );
  }

  /// دالة مساعدة لصفحة الترقية
  Widget _buildFeatureItem({required String icon, required String text}) {
    return Padding(
       padding: const EdgeInsets.symmetric(vertical: 8.0),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.end, // Align to the right
         children: [
           Text(text, style: Theme.of(context).textTheme.bodyLarge, textDirection: TextDirection.rtl),
           const SizedBox(width: 12),
           Text(icon, style: const TextStyle(fontSize: 20)),
         ],
       ),
    );
  }

  // ❌❌ تم حذف دالة بناء صفحة الإعدادات القديمة (_buildSettingsPage) ❌❌

  @override
  Widget build(BuildContext context) {
     // ✅✅ تحديث قائمة الصفحات للشريط السفلي ✅✅
    final pages = [
      _buildMain(),           // Index 0: الرئيسية
      const FavoritesScreen(),// Index 1: المفضلة
      _buildUpgradePage(),    // Index 2: الترقية
      const AuthorScreen(),   // Index 3: قلم الكاتب (بدلاً من الإعدادات)
    ];

    // تحديد ألوان الشريط السفلي بناءً على الثيم
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color selectedColor = isDark ? Colors.blueAccent : const Color(0xFF1E88E5);
    final Color unselectedColor = Colors.grey;
    final Color? bottomNavBarBackground = isDark ? const Color(0xFF1E1E1E) : Colors.white; // Optional background color

    return Scaffold(
      // appBar is removed as each page might define its own or none
      body: pages[_currentIndex], // Display the currently selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          if (mounted) {
             setState(() => _currentIndex = i); // Update the index on tap
          }
        },
        type: BottomNavigationBarType.fixed, // Ensure all items are visible
        selectedItemColor: selectedColor, // Color for the selected item
        unselectedItemColor: unselectedColor, // Color for unselected items
        backgroundColor: bottomNavBarBackground, // Set background color based on theme
        elevation: 8.0, // Add some elevation
        // ✅✅ تحديث عناصر الشريط السفلي مع أيقونات مناسبة ✅✅
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),          // Outline icon when inactive
            activeIcon: Icon(Icons.home),             // Filled icon when active
            label: 'الرئيسية'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond_outlined),
            activeIcon: Icon(Icons.diamond),
            label: 'الترقية'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),     // Icon for "Pen of the Writer"
            activeIcon: Icon(Icons.edit_note),
            label: 'قلم الكاتب'
          ),
        ],
      ),
    );
  }
}