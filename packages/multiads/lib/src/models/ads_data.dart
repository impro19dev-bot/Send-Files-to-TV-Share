import '../networks/admob/admob_data.dart';
import '../networks/applovin/applovin_data.dart';
import '../networks/facebook/facebook_data.dart';
import '../networks/ironsource/ironsource_data.dart';
import 'ads_settings.dart';

class AdsData {
  final AdmobData admobData;
  final ApplovinData applovinData;
  final FacebookData facebookData;
  final IronsourceData ironsourceData;
  final AdsSettings settings;

  AdsData.fromJson(Map<String, dynamic> json)
    : admobData = AdmobData.fromJson(json['admob'] ?? {}),
      applovinData = ApplovinData.fromJson(json['applovin'] ?? {}),
      facebookData = FacebookData.fromJson(json['facebook'] ?? {}),
      ironsourceData = IronsourceData.fromJson(json['ironsource'] ?? {}),
      settings = AdsSettings.fromJson(json['settings'] ?? {});
}
