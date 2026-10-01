import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

/// Picks a private IPv4 address other devices on the LAN can reach.
Future<String?> findLanHost() async {
  final candidates = <String>[];

  try {
    final wifi = await NetworkInfo().getWifiIP();
    if (wifi != null && wifi.isNotEmpty) candidates.add(wifi);
  } catch (_) {}

  try {
    final ifaces = await NetworkInterface.list(
      includeLinkLocal: false,
      type: InternetAddressType.IPv4,
    );
    for (final iface in ifaces) {
      for (final addr in iface.addresses) {
        if (!addr.isLoopback) candidates.add(addr.address);
      }
    }
  } catch (_) {}

  for (final ip in candidates) {
    if (ip != '0.0.0.0' && isPrivateV4(ip)) return ip;
  }
  return null;
}

bool isPrivateV4(String ip) {
  final parts = ip.split('.');
  if (parts.length != 4) return false;
  final a = int.tryParse(parts[0]);
  final b = int.tryParse(parts[1]);
  if (a == null || b == null) return false;
  if (a == 10 || a == 192 && b == 168) return true;
  if (a == 172 && b >= 16 && b <= 31) return true;
  if (a == 169 && b == 254) return true;
  return false;
}
