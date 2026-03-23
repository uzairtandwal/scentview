import 'package:flutter/foundation.dart';

class UrlUtils {
  static const String domainUrl = 'https://bgnupk.online/secondview/public';

  static String? toAbsoluteUrl(String? relativeUrl) {
    if (relativeUrl == null || relativeUrl.isEmpty) return null;

    // ✅ Already full URL or Asset path — return as-is
    if (relativeUrl.startsWith('http') || relativeUrl.startsWith('assets/')) {
      return relativeUrl;
    }

    String path = relativeUrl.trim();

    // ✅ Leading slashes hataao
    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    String finalUrl;

    if (path.startsWith('storage/')) {
      // Already storage/ hai — bas domain lagao
      finalUrl = '$domainUrl/$path';
    } else {
      // Raw path — storage/ add karo
      finalUrl = '$domainUrl/storage/$path';
    }

    if (kDebugMode) debugPrint("📸 Image URL: $finalUrl");
    return finalUrl;
  }
}
