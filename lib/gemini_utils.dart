// import 'package:flutter_gemini/flutter_gemini.dart';

// String extractGeminiText(GeminiResponse? response) {
//   if (response == null) return "❌ لم يصل أي رد من Gemini.";
//   if (response.candidates == null || response.candidates!.isEmpty) {
//     return "❌ لم يتم العثور على محتوى داخل الرد.";
//   }

//   final candidate = response.candidates!.first;
//   final parts = candidate.content?.parts;

//   if (parts == null || parts.isEmpty) {
//     return "❌ الرد لا يحتوي على نص.";
//   }

//   // ✅ نفك الـ Part بالـ toJson
//   final texts = parts
//       .map((p) {
//         final json = Part.toJson(p); // Map<String, dynamic>
//         if (json.containsKey("text")) {
//           return json["text"] as String;
//         }
//         return null;
//       })
//       .whereType<String>()
//       .toList();

//   if (texts.isEmpty) {
//     return "❌ الرد ما فيه نص مفهوم.";
//   }

//   return texts.join(" ");
// }



import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:collection/collection.dart'; // لتوفير whereNotNull إذا لم تكن موجودة

// ✅ تعديل: الدالة الآن تقبل Candidates? بدلاً من GeminiResponse?
String extractGeminiTextFromCandidates(Candidates? candidates) {
  if (candidates == null) return "❌ لم يصل أي رد من Gemini.";

  final parts = candidates.content?.parts;

  if (parts == null || parts.isEmpty) {
    return "❌ الرد لا يحتوي على نص.";
  }

  final texts = IterableNullableExtension(parts
      .whereType<TextPart>() // فلترة للحصول على TextPart فقط
      .map((p) => p.text))
      .whereNotNull() // التأكد من أن النص ليس null
      .toList();

  if (texts.isEmpty) {
    return "❌ الرد ما فيه نص مفهوم.";
  }

  return texts.join(" ");
}

// دالة مساعدة للتأكد من أن القائمة لا تحتوي على قيم null
// لا تزال مطلوبة إذا لم يكن لديك 'package:collection/collection.dart'
extension<T> on Iterable<T?> {
  Iterable<T> whereNotNull() => where((e) => e != null).cast<T>();
}