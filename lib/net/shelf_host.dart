import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

/// Temporary LAN shelf. A TV browser opens the catalog and downloads files.
class ShelfHost {
  ShelfHost._(this._files) : pass = _passphrase();

  factory ShelfHost.opened(List<String> paths) {
    final readable = paths.where((path) => File(path).existsSync()).toList();
    return ShelfHost._(readable);
  }

  static const _lane = 'beam';

  final List<String> _files;
  final String pass;

  HttpServer? _listener;
  StreamSubscription<HttpRequest>? _traffic;

  int? get port => _listener?.port;
  bool get live => _listener != null;
  int get count => _files.length;

  String catalogUrl(String host) {
    final bound = port;
    if (bound == null) return '';
    return 'http://$host:$bound/$_lane/$pass/catalog';
  }

  static String _passphrase() {
    const alphabet = 'abcdefghjkmnpqrstuvwxyz23456789';
    final roll = Random.secure();
    return List.generate(
      18,
      (_) => alphabet[roll.nextInt(alphabet.length)],
    ).join();
  }

  Future<void> listen() async {
    if (_listener != null) return;
    _listener = await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
    _traffic = _listener!.listen(
      _answer,
      onError: (_) {},
      cancelOnError: false,
    );
  }

  Future<void> close() async {
    await _traffic?.cancel();
    _traffic = null;
    await _listener?.close(force: true);
    _listener = null;
  }

  Future<void> _answer(HttpRequest request) async {
    final method = request.method;
    if (method != 'GET' && method != 'HEAD') {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      await request.response.close();
      return;
    }

    final parts = request.uri.pathSegments;
    if (parts.isNotEmpty && parts.first == 'favicon.ico') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      return;
    }

    if (parts.length < 3 || parts[0] != _lane || parts[1] != pass) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final tail = parts.sublist(2);
    if (tail.isEmpty || tail.first == 'catalog' || tail.first.isEmpty) {
      await _catalog(request);
      return;
    }
    if (tail.length == 2 && tail.first == 'item') {
      final index = int.tryParse(tail[1]);
      if (index == null || index < 0 || index >= _files.length) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }
      await _item(request, index);
      return;
    }

    request.response.statusCode = HttpStatus.notFound;
    await request.response.close();
  }

  Future<void> _catalog(HttpRequest request) async {
    final page = StringBuffer()
      ..writeln('<!DOCTYPE html><html lang="en"><head><meta charset="utf-8">')
      ..writeln(
        '<meta name="viewport" content="width=device-width,initial-scale=1">',
      )
      ..writeln('<title>Send Files to TV: Share</title>')
      ..writeln('<style>')
      ..writeln(
        'body{margin:0;background:#0C1733;color:#F4FBFF;font-family:-apple-system,BlinkMacSystemFont,sans-serif;}'
        'main{max-width:640px;margin:0 auto;padding:28px 20px;}'
        'h1{font-weight:650;font-size:1.7rem;}'
        'p{color:#9AADC4;line-height:1.5;}'
        'a{color:#18D6F5;}li{margin:14px 0;}',
      )
      ..writeln('</style></head><body><main>')
      ..writeln('<h1>Files ready</h1>')
      ..writeln(
        '<p>Choose a file. Keep Send Files to TV: Share open on the iPhone until the download finishes.</p><ul>',
      );

    for (var i = 0; i < _files.length; i++) {
      final name = htmlEscape.convert(p.basename(_files[i]));
      page.writeln('<li><a href="item/$i">$name</a></li>');
    }
    page.writeln('</ul></main></body></html>');

    final bytes = utf8.encode(page.toString());
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.html
      ..headers.contentLength = bytes.length
      ..headers.set('Access-Control-Allow-Origin', '*');
    if (request.method == 'GET') request.response.add(bytes);
    await request.response.close();
  }

  Future<void> _item(HttpRequest request, int index) async {
    final file = File(_files[index]);
    if (!await file.exists()) {
      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
      return;
    }

    final name = p.basename(file.path);
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    final length = await file.length();
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.parse(type)
      ..headers.contentLength = length
      ..headers.set(
        'Content-Disposition',
        'attachment; filename="${_safeName(name)}"',
      )
      ..headers.set('Access-Control-Allow-Origin', '*');

    if (request.method == 'HEAD') {
      await request.response.close();
      return;
    }

    try {
      await request.response.addStream(file.openRead());
    } catch (_) {}
    await request.response.close();
  }

  String _safeName(String name) {
    final cleaned = name.runes.map((code) {
      final ok = code >= 32 && code < 127 && code != 34 && code != 92;
      return ok ? String.fromCharCode(code) : '_';
    }).join();
    return cleaned.isEmpty ? 'file.bin' : cleaned;
  }
}
