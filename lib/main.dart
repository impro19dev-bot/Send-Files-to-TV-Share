import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:multiads/multiads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'orchard_app.dart';
import 'util/global.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final url = Uri.parse(
    'https://drive.google.com/uc?export=download&id=1iiMdEfdUrnuI_i5aP8yNaINBshllorEg',
  );
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      gAds = MultiAds(
        response.body,
        config: const MultiAdsConfig(
          admobTestDeviceIds: ['79738754EC81FA5F64972928128B2FFF'],
          facebookTestingId: 'd1a0df1f-2528-4e41-a4d3-1b401ba14f7d',
          enableLogs: true, // set false before release
        ),
      );
      // Config ready; UMP + SDK init run on the opening screen so the
      // consent form can present (needs a visible UI window).
      gAdsReady = true;
    }
  } catch (_) {
    // Ads config unavailable; app still launches without ads.
    gAdsReady = false;
  }

  final prefs = await SharedPreferences.getInstance();
  launchOrchard(prefs);
}
