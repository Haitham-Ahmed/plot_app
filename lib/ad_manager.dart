// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'dart:io'; // لاستخدام أرقام الاختبار حسب نوع النظام
// import 'package:flutter/foundation.dart'; // لطباعة الأخطاء و kDebugMode

// class AdManager {

//   // ✅✅ --- بداية التعديل --- ✅✅
//   static String get rewardedAdUnitId {
//     // --- منطقة الاختبار والتطوير ---
//     if (kDebugMode) {
//       debugPrint("ℹ️ التطبيق يعمل في وضع التصحيح (Debug Mode) - سيتم استخدام إعلانات اختبارية.");
//       // استخدم أرقام اختبار AdMob الرسمية أثناء التطوير
//       if (Platform.isAndroid) {
//         // الرقم الاختباري الصحيح لإعلانات المكافأة للأندرويد
//         return 'ca-app-pub-3718558739804643/5582814998';
//       } else if (Platform.isIOS) {
//         // الرقم الاختباري الصحيح لإعلانات المكافأة لـ iOS
//         return 'ca-app-pub-3718558739804643/2895930145';
//       }
//     }

//     // --- منطقة الإعلانات الحقيقية (عند بناء التطبيق للنشر Release Mode) ---
//     debugPrint("ℹ️ التطبيق يعمل في وضع النشر (Release Mode) - سيتم استخدام إعلانات حقيقية.");
//     if (Platform.isAndroid) {
//       // ✅ الرقم الحقيقي الصحيح لوحدة إعلان المكافأة للأندرويد (من معلوماتك)
//       return 'ca-app-pub-3718558739804643~3656964583';
//     } else if (Platform.isIOS) {
//       // ✅ الرقم الحقيقي الصحيح لوحدة إعلان المكافأة لـ iOS (من معلوماتك)
//       return 'ca-app-pub-3718558739804643~1835141675'; // ⚠️ تأكد أن هذا هو رقم iOS الصحيح، يبدو مثل رقم أندرويد
//       // إذا كان لديك رقم iOS مختلف، ضعه هنا:
//       // return 'ca-app-pub-5182987122606498/XXXXXXXXXX';
//     }

//     // حالة احتياطية إذا لم يكن النظام أندرويد أو iOS
//     debugPrint("⚠️ نظام التشغيل غير مدعوم للإعلانات.");
//     return '';
//   }
//   // ✅✅ --- نهاية التعديل --- ✅✅


//   /// دالة عرض إعلان المكافأة
//   /// onAdCompleted: دالة تُنفذ عند مشاهدة الإعلان بنجاح
//   /// onAdFailed: دالة تُنفذ عند فشل تحميل أو عرض الإعلان
//   static void showRewardedAd(Function onAdCompleted, Function(String) onAdFailed) {
//     String adUnitIdToShow = rewardedAdUnitId; // احصل على الرقم المناسب (اختباري أو حقيقي)
//     debugPrint(" attempting to load ad with AdUnitId: $adUnitIdToShow"); // طباعة الرقم المستخدم

//     // التأكد من أن الرقم غير فارغ قبل محاولة التحميل
//     if (adUnitIdToShow.isEmpty) {
//       onAdFailed("لم يتم تحديد رقم وحدة إعلانية لهذا النظام.");
//       return;
//     }

//     RewardedAd.load(
//       adUnitId: adUnitIdToShow, // استخدام الرقم المحدد
//       request: const AdRequest(),
//       rewardedAdLoadCallback: RewardedAdLoadCallback(
//         onAdLoaded: (RewardedAd ad) {
//           debugPrint("✅ إعلان المكافأة تم تحميله بنجاح (AdUnitId: $adUnitIdToShow).");

//           ad.fullScreenContentCallback = FullScreenContentCallback(
//             onAdDismissedFullScreenContent: (RewardedAd ad) {
//               debugPrint("تم إغلاق الإعلان.");
//               ad.dispose();
//             },
//             onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
//               debugPrint("❌ فشل عرض الإعلان الذي تم تحميله: $error");
//               ad.dispose();
//               onAdFailed("فشل عرض الإعلان.");
//             },
//             // يمكنك إضافة onAdImpression و onAdClicked هنا إذا أردت تتبعها
//           );

//           // عرض الإعلان
//           ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
//             debugPrint("🎉 المستخدم ربح المكافأة: ${reward.amount} ${reward.type}");
//             // ✅ عند نجاح الإعلان، نفذ الدالة
//             onAdCompleted();
//           });
//         },
//         onAdFailedToLoad: (LoadAdError error) {
//           debugPrint('❌❌ فشل تحميل الإعلان (AdUnitId: $adUnitIdToShow): $error');
//           // ⚠️ لا تستدعي onAdCompleted هنا
//           onAdFailed("فشل تحميل الإعلان، حاول مرة أخرى لاحقًا.");
//         },
//       ),
//     );
//   }
// }





// [ملف: ad_manager.dart]

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io'; // لاستخدام أرقام الاختبار حسب نوع النظام
import 'package:flutter/foundation.dart'; // لطباعة الأخطاء و kDebugMode

class AdManager {

  static String get rewardedAdUnitId {
    // --- منطقة الاختبار والتطوير ---
    if (kDebugMode) {
      debugPrint("ℹ️ التطبيق يعمل في وضع التصحيح (Debug Mode) - سيتم استخدام إعلانات اختبارية.");
      // استخدم أرقام اختبار AdMob الرسمية أثناء التطوير
    if (Platform.isAndroid) {
        // الرقم الاختباري الرسمي
       return 'ca-app-pub-3940256099942544/5224354917'; // <-- TEST ID
      } else if (Platform.isIOS) {
        // الرقم الاختباري الرسمي
        return 'ca-app-pub-3940256099942544/1712485313'; // <-- TEST ID
      }
    }

    // ✅✅ --- بداية التعديل (الإعلانات الحقيقية) --- ✅✅
    // --- منطقة الإعلانات الحقيقية (عند بناء التطبيق للنشر Release Mode) ---
    debugPrint("ℹ️ التطبيق يعمل في وضع النشر (Release Mode) - سيتم استخدام إعلانات حقيقية.");
    if (Platform.isAndroid) {
      // ✅ الرقم الحقيقي الصحيح لوحدة إعلان المكافأة للأندرويد (من معلوماتك)
      return 'ca-app-pub-3718558739804643/5582814998'; // ⬅️ هذا هو الصحيح
    } else if (Platform.isIOS) {
      // ✅ الرقم الحقيقي الصحيح لوحدة إعلان المكافأة لـ iOS (من معلوماتك)
      return 'ca-app-pub-3718558739804643/2895930145'; // ⬅️ هذا هو الصحيح
    }
    // ✅✅ --- نهاية التعديل --- ✅✅

    // حالة احتياطية إذا لم يكن النظام أندرويد أو iOS
    debugPrint("⚠️ نظام التشغيل غير مدعوم للإعلانات.");
    return '';
  }


  /// دالة عرض إعلان المكافأة
  /// onAdCompleted: دالة تُنفذ عند مشاهدة الإعلان بنجاح
  /// onAdFailed: دالة تُنفذ عند فشل تحميل أو عرض الإعلان
  static void showRewardedAd(Function onAdCompleted, Function(String) onAdFailed) {
    String adUnitIdToShow = rewardedAdUnitId; 
    debugPrint(" attempting to load ad with AdUnitId: $adUnitIdToShow"); 

    if (adUnitIdToShow.isEmpty) {
      onAdFailed("لم يتم تحديد رقم وحدة إعلانية لهذا النظام.");
      return;
    }

    RewardedAd.load(
      adUnitId: adUnitIdToShow, 
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint("✅ إعلان المكافأة تم تحميله بنجاح (AdUnitId: $adUnitIdToShow).");

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              debugPrint("تم إغلاق الإعلان.");
              ad.dispose();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              debugPrint("❌ فشل عرض الإعلان الذي تم تحميله: $error");
              ad.dispose();
              onAdFailed("فشل عرض الإعلان.");
            },
          );

          ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
            debugPrint("🎉 المستخدم ربح المكافأة: ${reward.amount} ${reward.type}");
            onAdCompleted();
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌❌ فشل تحميل الإعلان (AdUnitId: $adUnitIdToShow): $error');
          onAdFailed("فشل تحميل الإعلان، حاول مرة أخرى لاحقًا.");
        },
      ),
    );
  }
}