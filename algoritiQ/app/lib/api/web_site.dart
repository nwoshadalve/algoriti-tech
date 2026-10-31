// Copyright (c) 2026 MD Nwoshad Alam Chowdhury, Founder AlgoritiQ.
// All rights reserved.
//
// Proprietary source code of AlgoritiQ. Unauthorized copying, modification,
// or distribution is prohibited.
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';

/// Where the built web app's files come from.
abstract interface class WebFiles {
  /// The file at [path] (`index.html`, `assets/index-abc.js`), or null.
  Future<Uint8List?> read(String path);
}

/// The web build (`web/dist`) bundled into the app under `assets/web/`.
final class BundledWebFiles implements WebFiles {
  BundledWebFiles({AssetBundle? bundle, this.root = 'assets/web'})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final String root;

  @override
  Future<Uint8List?> read(String path) async {
    try {
      final data = await _bundle.load('$root/$path');
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } on FlutterError {
      return null;
    }
  }
}

/// One file of the web app, ready to send.
final class WebAsset {
  const WebAsset({
    required this.bytes,
    required this.contentType,
    required this.headers,
  });

  final Uint8List bytes;
  final String contentType;

  /// Cache and browser-security headers for this file.
  final Map<String, String> headers;
}

/// The web app as the tablet serves it at `/`, next to the API at `/api/v1`.
///
/// - `/` is `index.html`; page routes of the single-page app (`/register`)
///   have no file and get `index.html` too, so a reload or a typed link works.
/// - Anything with a file extension that is not bundled is a plain 404, never
///   the app (a missing script must not come back as HTML).
/// - Hashed build files under `assets/` are cached for good; everything else
///   is checked again on each visit, so a new build shows at once.
final class WebSite {
  WebSite(this._files);

  final WebFiles _files;

  static final _safePath = RegExp(r'^[A-Za-z0-9_\-][A-Za-z0-9._\-/]*$');

  /// Browser rules for the app's pages: only this origin, no plugins, no
  /// framing. Styles may be inline (React sets some `style` attributes).
  static const contentSecurityPolicy =
      "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'; "
      "img-src 'self' data: blob:; font-src 'self'; connect-src 'self'; "
      "manifest-src 'self'; worker-src 'self'; object-src 'none'; "
      "base-uri 'self'; form-action 'self'; frame-ancestors 'none'";

  static const _types = {
    'html': 'text/html; charset=utf-8',
    'js': 'text/javascript; charset=utf-8',
    'mjs': 'text/javascript; charset=utf-8',
    'css': 'text/css; charset=utf-8',
    'json': 'application/json; charset=utf-8',
    'webmanifest': 'application/manifest+json; charset=utf-8',
    'svg': 'image/svg+xml',
    'png': 'image/png',
    'ico': 'image/x-icon',
    'ttf': 'font/ttf',
    'woff': 'font/woff',
    'woff2': 'font/woff2',
    'txt': 'text/plain; charset=utf-8',
    'map': 'application/json; charset=utf-8',
  };

  /// The file for the request path [urlPath] (`/`, `/register`,
  /// `/assets/x.js`), or null for a 404.
  Future<WebAsset?> find(String urlPath) async {
    final path = urlPath == '/' ? 'index.html' : urlPath.substring(1);
    if (!_safePath.hasMatch(path) ||
        path.contains('..') ||
        path.contains('//')) {
      return null;
    }

    final bytes = await _files.read(path);
    if (bytes != null) return _asset(path, bytes);

    final isPageRoute = !path.split('/').last.contains('.');
    if (!isPageRoute) return null;
    final index = await _files.read('index.html');
    return index == null ? null : _asset('index.html', index);
  }

  WebAsset _asset(String path, Uint8List bytes) {
    final extension = path.contains('.') ? path.split('.').last : '';
    final type = _types[extension] ?? 'application/octet-stream';
    final isHtml = extension == 'html';
    return WebAsset(
      bytes: bytes,
      contentType: type,
      headers: {
        'cache-control': path.startsWith('assets/')
            ? 'public, max-age=31536000, immutable'
            : 'no-cache',
        'x-content-type-options': 'nosniff',
        'referrer-policy': 'no-referrer',
        if (isHtml) ...{
          'content-security-policy': contentSecurityPolicy,
          'x-frame-options': 'DENY',
        },
      },
    );
  }
}
