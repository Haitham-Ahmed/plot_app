// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// class PaymentManager {
//   // --- عداد الحبكة المخصصة (Custom Plot) ---
//   static const int maxCustomPlotUsesPerDay = 3;

//   // --- عداد الحبكة العشوائية (Random Plot) ---
//   static const int maxRandomPlotUsesPerDay = 3; // الحد الأقصى للمحاولات العشوائية المجانية الأولية
//   // لا يوجد حد أقصى بعد مشاهدة الإعلان لنفس اليوم


//   /// الحصول على مرجع لمستند المستخدم الحالي في Firestore
//   static DocumentReference<Map<String, dynamic>> _getUserDocRef() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       debugPrint("❌ خطأ: محاولة الوصول للبيانات والمستخدم غير مسجل.");
//       throw Exception("User not logged in");
//     }
//     return FirebaseFirestore.instance.collection('users').doc(user.uid);
//   }

//   /// التحقق مما إذا كان المستخدم مشتركًا (Premium)
//   static Future<bool> isPremiumUser() async {
//     try {
//       final doc = await _getUserDocRef().get();
//       // تأكد من أن الحقل موجود قبل الوصول إليه لتجنب الأخطاء
//       if (doc.exists && doc.data() != null && doc.data()!['isPremium'] == true) {
//         return true;
//       }
//       return false;
//     } catch (e) {
//       debugPrint("❌❌ خطأ عند التحقق من الاشتراك (isPremiumUser): $e");
//       return false; // افترض أنه ليس مشتركًا في حالة الخطأ
//     }
//   }

//   /// تفعيل الاشتراك للمستخدم
//   static Future<void> unlockPremium() async {
//     try {
//       await _getUserDocRef().set({
//         'isPremium': true,
//         'premiumSince': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true)); // استخدم merge لعدم الكتابة فوق بيانات أخرى
//        debugPrint("✅ تم تفعيل الاشتراك للمستخدم بنجاح.");
//     } catch (e) {
//       debugPrint("❌❌ خطأ عند تفعيل الاشتراك (unlockPremium): $e");
//     }
//   }

//   // --- دوال خاصة بالحبكة المخصصة (Custom Plot) ---

//   /// جلب بيانات استخدام الحبكة المخصصة وإعادة التعيين اليومي
//    static Future<Map<String, dynamic>> _getCustomPlotUsageData() async {
//     try {
//       final userDocRef = _getUserDocRef();
//       final doc = await userDocRef.get();
//       final today = DateTime.now().toIso8601String().substring(0, 10);

//       // البيانات الافتراضية للحبكة المخصصة
//       Map<String, dynamic> defaultData = {
//         'customPlotUsesCount': 0,
//         'customPlotLastUseDate': today,
//       };

//       if (!doc.exists || doc.data() == null) {
//         debugPrint("ℹ️ بيانات استخدام الحبكة المخصصة غير موجودة! يتم إنشاؤها.");
//         await userDocRef.set(defaultData, SetOptions(merge: true));
//         return defaultData;
//       }

//       final data = doc.data()!;
//       final lastUseDate = data['customPlotLastUseDate'] as String?;
//       int usesCount = data['customPlotUsesCount'] as int? ?? 0;

//       // إعادة التعيين اليومي
//       if (lastUseDate != today) {
//         debugPrint("ℹ️ يوم جديد للمستخدم (حبكة مخصصة)! يتم إعادة تعيين العداد.");
//         await userDocRef.update({
//           'customPlotUsesCount': 0,
//           'customPlotLastUseDate': today,
//         });
//         usesCount = 0;
//       }

//       // إرجاع البيانات الحالية أو المعاد تعيينها
//       return {'usesCount': usesCount, 'lastUseDate': today}; // اسم المفتاح تم تغييره لـ usesCount
//     } catch (e) {
//       debugPrint("❌❌ خطأ فادح عند جلب بيانات الحبكة المخصصة: $e");
//       // في حالة الخطأ، اسمح بالاستخدام لمنع حظر المستخدم
//       return {'usesCount': 0, 'lastUseDate': DateTime.now().toIso8601String().substring(0, 10)};
//     }
//   }

//   /// هل يمكن استخدام ميزة الحبكة المخصصة المجانية؟
//   static Future<bool> canUseFreeFeature() async { // تم تغيير الاسم ليكون أوضح
//     final usageData = await _getCustomPlotUsageData();
//     return (usageData['usesCount'] as int) < maxCustomPlotUsesPerDay;
//   }

//   /// زيادة عداد استخدام الحبكة المخصصة
//   static Future<void> incrementFreeUses() async { // تم تغيير الاسم ليكون أوضح
//     try {
//       final userDocRef = _getUserDocRef();
//       // استخدام update لزيادة العداد وتحديث التاريخ
//       await userDocRef.update({
//         'customPlotUsesCount': FieldValue.increment(1),
//         'customPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
//       });
//     } catch (e) {
//        // إذا فشل التحديث (ربما الحقول غير موجودة)، حاول إنشائها
//        if (e is FirebaseException && e.code == 'not-found') {
//           await _getUserDocRef().set({
//             'customPlotUsesCount': 1,
//             'customPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
//           }, SetOptions(merge: true));
//        } else {
//          debugPrint("❌❌ خطأ عند زيادة عداد الحبكة المخصصة: $e");
//        }
//     }
//   }
//   // --- نهاية دوال الحبكة المخصصة ---


//   // --- دوال خاصة بالحبكة العشوائية (Random Plot) ---

//   /// جلب بيانات استخدام الحبكة العشوائية وإعادة التعيين اليومي
//   static Future<Map<String, dynamic>> _getRandomPlotUsageData() async {
//     try {
//       final userDocRef = _getUserDocRef();
//       final doc = await userDocRef.get();
//       final today = DateTime.now().toIso8601String().substring(0, 10);

//       // البيانات الافتراضية للحبكة العشوائية
//       Map<String, dynamic> defaultData = {
//         'randomPlotUsesCount': 0,
//         'randomPlotLastUseDate': today,
//         'randomPlotAdWatchedToday': false, // هل شاهد إعلان اليوم؟
//       };

//       if (!doc.exists || doc.data() == null) {
//         debugPrint("ℹ️ بيانات استخدام الحبكة العشوائية غير موجودة! يتم إنشاؤها.");
//         await userDocRef.set(defaultData, SetOptions(merge: true));
//         return defaultData;
//       }

//       final data = doc.data()!;
//       // التأكد من وجود الحقول قبل قراءتها، وإعطاء قيم افتراضية إذا لم تكن موجودة
//       final lastUseDate = data['randomPlotLastUseDate'] as String? ?? today; // افترض اليوم إذا كان null
//       int usesCount = data['randomPlotUsesCount'] as int? ?? 0;
//       bool adWatched = data['randomPlotAdWatchedToday'] as bool? ?? false;

//       // إعادة التعيين اليومي
//       if (lastUseDate != today) {
//         debugPrint("ℹ️ يوم جديد للمستخدم (حبكة عشوائية)! يتم إعادة تعيين العداد ومشاهدة الإعلان.");
//         await userDocRef.update({
//           'randomPlotUsesCount': 0,
//           'randomPlotLastUseDate': today,
//           'randomPlotAdWatchedToday': false, // إعادة تعيين مشاهدة الإعلان
//         });
//         usesCount = 0;
//         adWatched = false;
//       }

//       // إرجاع البيانات الحالية أو المعاد تعيينها
//       return {'usesCount': usesCount, 'adWatched': adWatched, 'lastUseDate': today};
//     } catch (e) {
//       debugPrint("❌❌ خطأ فادح عند جلب بيانات الحبكة العشوائية: $e");
//       // في حالة الخطأ، اسمح بالاستخدام لمنع حظر المستخدم
//       return {'usesCount': 0, 'adWatched': false, 'lastUseDate': DateTime.now().toIso8601String().substring(0, 10)};
//     }
//   }

//   /// هل يمكن للمستخدم استخدام ميزة الحبكة العشوائية المجانية الآن؟
//   static Future<bool> canUseRandomPlotFeature() async {
//     final usageData = await _getRandomPlotUsageData();
//     // يمكنه الاستخدام إذا كان عدد الاستخدامات أقل من الحد الأقصى
//     return (usageData['usesCount'] as int) < maxRandomPlotUsesPerDay;
//   }

//   /// زيادة عداد استخدام الحبكة العشوائية
//   static Future<void> incrementRandomPlotUses() async {
//     try {
//       final userDocRef = _getUserDocRef();
//       await userDocRef.update({
//         'randomPlotUsesCount': FieldValue.increment(1),
//         'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
//       });
//     } catch (e) {
//       // إذا فشلت الزيادة (ربما الحقول غير موجودة)، حاول إنشائها
//        if (e is FirebaseException && (e.code == 'not-found' || e.message?.contains('No document to update') == true) ) {
//          await _getUserDocRef().set({
//             'randomPlotUsesCount': 1,
//             'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
//          }, SetOptions(merge: true));
//        } else {
//          debugPrint("❌❌ خطأ عند زيادة عداد الحبكة العشوائية: $e");
//        }
//     }
//   }

//   /// هل شاهد المستخدم إعلان الحبكة العشوائية اليوم؟ (لمنع عرض نافذة الإعلان إذا شاهدها بالفعل)
//    static Future<bool> didWatchRandomPlotAdToday() async {
//      final usageData = await _getRandomPlotUsageData();
//      return usageData['adWatched'] as bool;
//    }

//   /// إعادة تعيين عداد الحبكة العشوائية إلى صفر ومنح 3 محاولات جديدة بعد مشاهدة الإعلان
//   static Future<void> grantMoreRandomPlotUses() async {
//     try {
//       final userDocRef = _getUserDocRef();
//       final today = DateTime.now().toIso8601String().substring(0, 10);
//       // استخدام update لتحديث الحقول الموجودة
//       await userDocRef.update({
//         'randomPlotUsesCount': 0, // إعادة العداد إلى صفر ليحصل على 3 محاولات جديدة
//         'randomPlotAdWatchedToday': true, // تسجيل أنه شاهد الإعلان
//         'randomPlotLastUseDate': today, // تحديث التاريخ
//       });
//        debugPrint("✅ تم منح 3 محاولات عشوائية إضافية للمستخدم.");
//     } catch (e) {
//       // إذا فشل التحديث (ربما الحقول غير موجودة)، حاول إنشائها باستخدام set + merge
//        if (e is FirebaseException && (e.code == 'not-found' || e.message?.contains('No document to update') == true)) {
//           await _getUserDocRef().set({
//             'randomPlotUsesCount': 0, // ابدأ بصفر
//             'randomPlotAdWatchedToday': true, // شاهد الإعلان
//             'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
//           }, SetOptions(merge: true));
//            debugPrint("✅ تم منح 3 محاولات عشوائية إضافية للمستخدم (إنشاء حقول).");
//        } else {
//           debugPrint("❌❌ خطأ عند منح محاولات عشوائية إضافية: $e");
//        }
//     }
//   }
//   // --- نهاية دوال الحبكة العشوائية ---
// }




// [ملف: payment_manager.dart]

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PaymentManager {
  
  // ✅✅ --- بداية التعديل (توضيح الأسماء) --- ✅✅
  // --- عداد الحبكة المخصصة (Custom Plot) ---
  static const int maxCustomPlotUsesPerDay = 3;
  // ✅✅ --- نهاية التعديل --- ✅✅

  // --- عداد الحبكة العشوائية (Random Plot) ---
  static const int maxRandomPlotUsesPerDay = 3; // الحد الأقصى للمحاولات العشوائية المجانية الأولية


  /// الحصول على مرجع لمستند المستخدم الحالي في Firestore
  static DocumentReference<Map<String, dynamic>> _getUserDocRef() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint("❌ خطأ: محاولة الوصول للبيانات والمستخدم غير مسجل.");
      throw Exception("User not logged in");
    }
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  /// التحقق مما إذا كان المستخدم مشتركًا (Premium)
  static Future<bool> isPremiumUser() async {
    try {
      final doc = await _getUserDocRef().get();
      // تأكد من أن الحقل موجود قبل الوصول إليه لتجنب الأخطاء
      if (doc.exists && doc.data() != null && doc.data()!['isPremium'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("❌❌ خطأ عند التحقق من الاشتراك (isPremiumUser): $e");
      return false; // افترض أنه ليس مشتركًا في حالة الخطأ
    }
  }

  /// تفعيل الاشتراك للمستخدم
  static Future<void> unlockPremium() async {
    try {
      await _getUserDocRef().set({
        'isPremium': true,
        'premiumSince': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)); // استخدم merge لعدم الكتابة فوق بيانات أخرى
       debugPrint("✅ تم تفعيل الاشتراك للمستخدم بنجاح.");
    } catch (e) {
      debugPrint("❌❌ خطأ عند تفعيل الاشتراك (unlockPremium): $e");
    }
  }

  // --- دوال خاصة بالحبكة المخصصة (Custom Plot) ---

  /// جلب بيانات استخدام الحبكة المخصصة وإعادة التعيين اليومي
   static Future<Map<String, dynamic>> _getCustomPlotUsageData() async {
    try {
      final userDocRef = _getUserDocRef();
      final doc = await userDocRef.get();
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // البيانات الافتراضية للحبكة المخصصة
      Map<String, dynamic> defaultData = {
        'customPlotUsesCount': 0,
        'customPlotLastUseDate': today,
      };

      if (!doc.exists || doc.data() == null) {
        debugPrint("ℹ️ بيانات استخدام الحبكة المخصصة غير موجودة! يتم إنشاؤها.");
        await userDocRef.set(defaultData, SetOptions(merge: true));
        return defaultData;
      }

      final data = doc.data()!;
      final lastUseDate = data['customPlotLastUseDate'] as String?;
      int usesCount = data['customPlotUsesCount'] as int? ?? 0;

      // إعادة التعيين اليومي
      if (lastUseDate != today) {
        debugPrint("ℹ️ يوم جديد للمستخدم (حبكة مخصصة)! يتم إعادة تعيين العداد.");
        await userDocRef.update({
          'customPlotUsesCount': 0,
          'customPlotLastUseDate': today,
        });
        usesCount = 0;
      }

      // إرجاع البيانات الحالية أو المعاد تعيينها
      return {'usesCount': usesCount, 'lastUseDate': today};
    } catch (e) {
      debugPrint("❌❌ خطأ فادح عند جلب بيانات الحبكة المخصصة: $e");
      // في حالة الخطأ، اسمح بالاستخدام لمنع حظر المستخدم
      return {'usesCount': 0, 'lastUseDate': DateTime.now().toIso8601String().substring(0, 10)};
    }
  }

  // ✅✅ --- بداية التعديل (تغيير اسم الدالة) --- ✅✅
  /// هل يمكن استخدام ميزة الحبكة المخصصة المجانية؟
  static Future<bool> canUseCustomPlot() async { 
    final usageData = await _getCustomPlotUsageData();
    return (usageData['usesCount'] as int) < maxCustomPlotUsesPerDay;
  }

  /// زيادة عداد استخدام الحبكة المخصصة
  static Future<void> incrementCustomPlotUses() async { 
    try {
      final userDocRef = _getUserDocRef();
      // استخدام update لزيادة العداد وتحديث التاريخ
      await userDocRef.update({
        'customPlotUsesCount': FieldValue.increment(1),
        'customPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
      });
    } catch (e) {
       // إذا فشل التحديث (ربما الحقول غير موجودة)، حاول إنشائها
       if (e is FirebaseException && (e.code == 'not-found' || e.message?.contains('No document to update') == true)) {
          await _getUserDocRef().set({
            'customPlotUsesCount': 1,
            'customPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
          }, SetOptions(merge: true));
       } else {
         debugPrint("❌❌ خطأ عند زيادة عداد الحبكة المخصصة: $e");
       }
    }
  }
  // ✅✅ --- نهاية التعديل --- ✅✅
  
  // --- نهاية دوال الحبكة المخصصة ---


  // --- دوال خاصة بالحبكة العشوائية (Random Plot) ---

  /// جلب بيانات استخدام الحبكة العشوائية وإعادة التعيين اليومي
  static Future<Map<String, dynamic>> _getRandomPlotUsageData() async {
    try {
      final userDocRef = _getUserDocRef();
      final doc = await userDocRef.get();
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // البيانات الافتراضية للحبكة العشوائية
      Map<String, dynamic> defaultData = {
        'randomPlotUsesCount': 0,
        'randomPlotLastUseDate': today,
        'randomPlotAdWatchedToday': false, // هل شاهد إعلان اليوم؟
      };

      if (!doc.exists || doc.data() == null) {
        debugPrint("ℹ️ بيانات استخدام الحبكة العشوائية غير موجودة! يتم إنشاؤها.");
        await userDocRef.set(defaultData, SetOptions(merge: true));
        return defaultData;
      }

      final data = doc.data()!;
      // التأكد من وجود الحقول قبل قراءتها، وإعطاء قيم افتراضية إذا لم تكن موجودة
      final lastUseDate = data['randomPlotLastUseDate'] as String? ?? today; // افترض اليوم إذا كان null
      int usesCount = data['randomPlotUsesCount'] as int? ?? 0;
      bool adWatched = data['randomPlotAdWatchedToday'] as bool? ?? false;

      // إعادة التعيين اليومي
      if (lastUseDate != today) {
        debugPrint("ℹ️ يوم جديد للمستخدم (حبكة عشوائية)! يتم إعادة تعيين العداد ومشاهدة الإعلان.");
        await userDocRef.update({
          'randomPlotUsesCount': 0,
          'randomPlotLastUseDate': today,
          'randomPlotAdWatchedToday': false, // إعادة تعيين مشاهدة الإعلان
        });
        usesCount = 0;
        adWatched = false;
      }

      // إرجاع البيانات الحالية أو المعاد تعيينها
      return {'usesCount': usesCount, 'adWatched': adWatched, 'lastUseDate': today};
    } catch (e) {
      debugPrint("❌❌ خطأ فادح عند جلب بيانات الحبكة العشوائية: $e");
      // في حالة الخطأ، اسمح بالاستخدام لمنع حظر المستخدم
      return {'usesCount': 0, 'adWatched': false, 'lastUseDate': DateTime.now().toIso8601String().substring(0, 10)};
    }
  }

  /// هل يمكن للمستخدم استخدام ميزة الحبكة العشوائية المجانية الآن؟
  static Future<bool> canUseRandomPlotFeature() async {
    final usageData = await _getRandomPlotUsageData();
    // يمكنه الاستخدام إذا كان عدد الاستخدامات أقل من الحد الأقصى
    return (usageData['usesCount'] as int) < maxRandomPlotUsesPerDay;
  }

  /// زيادة عداد استخدام الحبكة العشوائية
  static Future<void> incrementRandomPlotUses() async {
    try {
      final userDocRef = _getUserDocRef();
      await userDocRef.update({
        'randomPlotUsesCount': FieldValue.increment(1),
        'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
      });
    } catch (e) {
      // إذا فشلت الزيادة (ربما الحقول غير موجودة)، حاول إنشائها
       if (e is FirebaseException && (e.code == 'not-found' || e.message?.contains('No document to update') == true) ) {
         await _getUserDocRef().set({
            'randomPlotUsesCount': 1,
            'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
         }, SetOptions(merge: true));
       } else {
         debugPrint("❌❌ خطأ عند زيادة عداد الحبكة العشوائية: $e");
       }
    }
  }

  /// هل شاهد المستخدم إعلان الحبكة العشوائية اليوم؟ (لمنع عرض نافذة الإعلان إذا شاهدها بالفعل)
   static Future<bool> didWatchRandomPlotAdToday() async {
     final usageData = await _getRandomPlotUsageData();
     return usageData['adWatched'] as bool;
   }

  /// إعادة تعيين عداد الحبكة العشوائية إلى صفر ومنح 3 محاولات جديدة بعد مشاهدة الإعلان
  static Future<void> grantMoreRandomPlotUses() async {
    try {
      final userDocRef = _getUserDocRef();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      // استخدام update لتحديث الحقول الموجودة
      await userDocRef.update({
        'randomPlotUsesCount': 0, // إعادة العداد إلى صفر ليحصل على 3 محاولات جديدة
        'randomPlotAdWatchedToday': true, // تسجيل أنه شاهد الإعلان
        'randomPlotLastUseDate': today, // تحديث التاريخ
      });
       debugPrint("✅ تم منح 3 محاولات عشوائية إضافية للمستخدم.");
    } catch (e) {
      // إذا فشل التحديث (ربما الحقول غير موجودة)، حاول إنشائها باستخدام set + merge
       if (e is FirebaseException && (e.code == 'not-found' || e.message?.contains('No document to update') == true)) {
          await _getUserDocRef().set({
            'randomPlotUsesCount': 0, // ابدأ بصفر
            'randomPlotAdWatchedToday': true, // شاهد الإعلان
            'randomPlotLastUseDate': DateTime.now().toIso8601String().substring(0, 10),
          }, SetOptions(merge: true));
           debugPrint("✅ تم منح 3 محاولات عشوائية إضافية للمستخدم (إنشاء حقول).");
       } else {
          debugPrint("❌❌ خطأ عند منح محاولات عشوائية إضافية: $e");
       }
    }
  }
  // --- نهاية دوال الحبكة العشوائية ---
}