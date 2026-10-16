class IronsourceData {
  final String appKey;
  final String bannerId;
  final String interId;
  final String rewardId;
  final String nativeId;

  IronsourceData.fromJson(Map<String, dynamic> json)
    : appKey = json['app_key'] ?? '',
      bannerId = json['bannerId'] ?? '',
      interId = json['interId'] ?? '',
      rewardId = json['rewardId'] ?? '',
      nativeId = json['nativeId'] ?? '';
}
