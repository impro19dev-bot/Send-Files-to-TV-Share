import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:qr_flutter/qr_flutter.dart';

import '../brand/ink.dart';
import '../net/address_probe.dart';
import '../net/shelf_host.dart';

class HandoffDesk extends StatefulWidget {
  const HandoffDesk({super.key});

  @override
  State<HandoffDesk> createState() => _HandoffDeskState();
}

class _HandoffDeskState extends State<HandoffDesk> {
  final List<String> _chosen = [];
  ShelfHost? _shelf;
  String? _host;
  String? _problem;
  bool _working = false;

  String? get _address {
    final shelf = _shelf;
    final host = _host;
    if (shelf == null || !shelf.live || host == null) return null;
    return shelf.catalogUrl(host);
  }

  @override
  void dispose() {
    final shelf = _shelf;
    if (shelf != null) unawaited(shelf.close());
    super.dispose();
  }

  Future<void> _addFiles() async {
    setState(() => _problem = null);
    try {
      final picked = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      if (!mounted || picked == null) return;
      final merged = <String>{..._chosen};
      for (final file in picked.files) {
        final path = file.path;
        if (path != null && path.isNotEmpty) merged.add(path);
      }
      setState(() {
        _chosen
          ..clear()
          ..addAll(merged);
      });
    } catch (error) {
      setState(() => _problem = 'The picker did not return files ($error).');
    }
  }

  Future<void> _openShelf() async {
    if (_chosen.isEmpty || _working) return;
    setState(() {
      _working = true;
      _problem = null;
    });
    try {
      final host = await findLanHost();
      if (!mounted) return;
      if (host == null) {
        setState(() {
          _working = false;
          _problem =
              'No private Wi‑Fi address turned up. Join Wi‑Fi, pause a VPN, '
              'then check Settings → Wi‑Fi → the info button beside your network.';
        });
        return;
      }
      final shelf = ShelfHost.opened(List<String>.from(_chosen));
      if (shelf.count == 0) {
        setState(() {
          _working = false;
          _problem =
              'Those paths could not be read. Pick them again from Files.';
        });
        return;
      }
      await shelf.listen();
      if (!mounted) return;
      setState(() {
        _shelf = shelf;
        _host = host;
        _working = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _working = false;
        _problem = 'The shelf did not open ($error).';
      });
    }
  }

  Future<void> _closeShelf() async {
    await _shelf?.close();
    if (!mounted) return;
    setState(() {
      _shelf = null;
      _host = null;
    });
  }

  Future<void> _copy() async {
    final address = _address;
    if (address == null) return;
    await Clipboard.setData(ClipboardData(text: address));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Address copied')));
  }

  @override
  Widget build(BuildContext context) {
    final live = _shelf?.live ?? false;
    final address = _address;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send to TV'),
        actions: [
          if (_chosen.isNotEmpty && !live)
            TextButton(
              onPressed: () => setState(() {
                _chosen.clear();
                _problem = null;
              }),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const _Cue(
            n: '1',
            text: 'Put this iPhone and the television on the same Wi‑Fi.',
          ),
          const _Cue(
            n: '2',
            text: 'Choose files, then start sharing. Keep this screen open.',
          ),
          const _Cue(
            n: '3',
            text: 'On the television, open a web browser and type the address.',
          ),
          if (_problem != null) ...[
            const SizedBox(height: 8),
            Text(
              _problem!,
              style: const TextStyle(color: Pigment.clayDeep, height: 1.4),
            ),
          ],
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _working || live ? null : _addFiles,
            icon: const Icon(Icons.add),
            label: Text(live ? 'Sharing' : 'Choose files'),
          ),
          if (_chosen.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '${_chosen.length} waiting',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            for (final path in _chosen)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  p.basename(path),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: (_working || live || _chosen.isEmpty)
                ? null
                : _openShelf,
            child: Text(_working ? 'Starting…' : 'Start sharing'),
          ),
          if (live && address != null) ...[
            const SizedBox(height: 24),
            const Text(
              'Type this address in the TV browser',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: QrImageView(
                    data: address,
                    size: 188,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SelectableText(
              address,
              style: const TextStyle(
                color: Pigment.clayDeep,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton(onPressed: _copy, child: const Text('Copy')),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: _working ? null : _closeShelf,
                  child: const Text('Stop sharing'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Keep Send Files to TV: Share open until the TV finishes downloading. Stop sharing when you are done.',
              style: TextStyle(color: Pigment.mute, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cue extends StatelessWidget {
  const _Cue({required this.n, required this.text});

  final String n;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            n,
            style: const TextStyle(
              color: Pigment.olive,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}
