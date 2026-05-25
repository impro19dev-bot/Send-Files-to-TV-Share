import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

import '../services/local_file_server.dart';
import '../theme/app_colors.dart';
import '../util/lan_address.dart';

/// Serves selected files over HTTP on the LAN so a TV browser (or any device) can download them.
class WifiSendScreen extends StatefulWidget {
  const WifiSendScreen({super.key});

  @override
  State<WifiSendScreen> createState() => _WifiSendScreenState();
}

class _WifiSendScreenState extends State<WifiSendScreen>
    with WidgetsBindingObserver {
  final List<String> _paths = [];
  LocalFileServer? _server;
  String? _hostIp;
  String? _error;
  bool _busy = false;

  String? get _shareUrl {
    final s = _server;
    final ip = _hostIp;
    if (s == null || !s.isRunning || ip == null) return null;
    return s.fullBaseUrl(ip);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final s = _server;
    if (s != null) {
      unawaited(s.stop());
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final active = _server != null && _server!.isRunning;
      if (active) {
        unawaited(_stopSharingFromBackground());
      }
    }
  }

  Future<void> _stopSharingFromBackground() async {
    await _server?.stop();
    if (!mounted) return;
    setState(() {
      _server = null;
      _hostIp = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sharing stopped because the app went to the background. '
          'Open the app again to start a new session.',
        ),
      ),
    );
  }

  Future<void> _pickFiles() async {
    setState(() => _error = null);
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withReadStream: false,
      );
      if (!mounted || result == null) return;
      final next = <String>{..._paths};
      for (final f in result.files) {
        final path = f.path;
        if (path != null && path.isNotEmpty) next.add(path);
      }
      setState(() {
        _paths
          ..clear()
          ..addAll(next);
      });
    } catch (e) {
      setState(() => _error = 'Could not pick files: $e');
    }
  }

  void _clearFiles() {
    if (_server != null) return;
    setState(() {
      _paths.clear();
      _error = null;
    });
  }

  Future<void> _startSharing() async {
    if (_paths.isEmpty || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final ip = await resolveLanIPv4();
      if (!mounted) return;
      if (ip == null) {
        setState(() {
          _busy = false;
          _error =
              'Could not detect your Wi‑Fi address. Connect to Wi‑Fi, disable VPN if any, '
              'or enter your iPhone’s IP from Settings → Wi‑Fi → (i) next to the network.';
        });
        return;
      }

      final server = LocalFileServer.fromPaths(List<String>.from(_paths));
      if (server.fileCount == 0) {
        setState(() {
          _busy = false;
          _error =
              'No readable files were found. Try picking again from the Files app.';
        });
        return;
      }

      await server.start();
      if (!mounted) return;
      setState(() {
        _server = server;
        _hostIp = ip;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not start sharing: $e';
      });
    }
  }

  Future<void> _stopSharing() async {
    await _server?.stop();
    if (!mounted) return;
    setState(() {
      _server = null;
      _hostIp = null;
    });
  }

  Future<void> _copyUrl() async {
    final url = _shareUrl;
    if (url == null) return;
    await Clipboard.setData(ClipboardData(text: url));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied')));
  }

  @override
  Widget build(BuildContext context) {
    final sharing = _server != null && _server!.isRunning;
    final url = _shareUrl;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wi‑Fi send to TV'),
        actions: [
          if (_paths.isNotEmpty && !sharing)
            TextButton(onPressed: _clearFiles, child: const Text('Clear')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Pick files, then start sharing. On your TV, open the web browser, '
            'scan the QR code or type the address. Keep this iPhone in the foreground '
            'until downloads finish—sharing stops automatically if you leave the app.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
          ],
          FilledButton.tonalIcon(
            onPressed: _busy || sharing ? null : _pickFiles,
            icon: const Icon(Icons.folder_open),
            label: Text(sharing ? 'Sharing active' : 'Choose files'),
          ),
          if (_paths.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected (${_paths.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._paths.map(
              (path) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  p.basename(path),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: (_busy || sharing || _paths.isEmpty)
                ? null
                : _startSharing,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_busy) ...[
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                ] else ...[
                  const Icon(Icons.wifi_tethering, size: 22),
                  const SizedBox(width: 8),
                ],
                Text(sharing ? 'Sharing…' : 'Start Wi‑Fi sharing'),
              ],
            ),
          ),
          if (sharing && url != null) ...[
            const SizedBox(height: 28),
            Text(
              'On your TV’s browser, open:',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: url,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SelectableText(
              url,
              style: const TextStyle(
                color: AppColors.accentCyan,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(
                  onPressed: _copyUrl,
                  child: const Text('Copy link'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _busy ? null : _stopSharing,
                  child: const Text('Stop sharing'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tip: If the TV cannot open the page, confirm both devices use the same '
              'Wi‑Fi network and that no guest isolation mode blocks phone-to-phone traffic.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
