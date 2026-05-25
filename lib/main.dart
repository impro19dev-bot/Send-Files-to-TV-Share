import 'package:fc_app3_send_files_to_tv/util/global.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:multiads/multiads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'util/ad_consent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // UMP consent must run before any AdMob ad requests (Policy: CMP required).
  await AdConsent.gather();

  if (!AdConsent.canRequestAds) {
    final prefs = await SharedPreferences.getInstance();
    bootstrapApp(prefs);
    return;
  }

  var url = Uri.parse(
    "https://drive.google.com/uc?export=download&id=1lp6XGt4OS0Qa9Y8nIldSzh0KvQuh9WnQ",
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      gAds = MultiAds(
        response.body,
        config: MultiAdsConfig(
          admobTestDeviceIds: ['79738754EC81FA5F64972928128B2FFF'],
          facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
          enableLogs: true, // set false before release
        ),
      );
      gAdsReady = true;
      await gAds.init();
      await gAds.loadAds();
    }
  } catch (_) {
    // Ads config unavailable; app still launches without ads.
  }

  final prefs = await SharedPreferences.getInstance();
  bootstrapApp(prefs);
}
