import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../app/theme.dart';

/// Opens a web page in the browser. False when the link isn't http(s) or nothing opened it.
Future<bool> openWebPage(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) return false;
  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception {
    return false;
  }
}

/// Google's search suggestions for answers found with Google Search. Google requires showing
/// them, unmodified, next to what was found; a tap opens that search on Google.
///
/// Android and iOS render Google's HTML in a web view. Where there is no web view (Linux
/// desktop, tests), or no HTML came back, each search shows as a chip that opens it.
class SearchSuggestions extends StatelessWidget {
  const SearchSuggestions({super.key, required this.html, required this.queries});

  /// `searchEntryPoint.renderedContent` of each answer that searched.
  final List<String> html;

  /// The searches that were run.
  final List<String> queries;

  static bool get _hasWebView => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  @override
  Widget build(BuildContext context) {
    if (_hasWebView && html.isNotEmpty) {
      return Column(children: [for (final h in html) _SuggestionView(html: h)]);
    }
    if (queries.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 8),
            child: Center(
              child: Text(
                'Searched on Google',
                style: context.text.labelMedium?.copyWith(color: context.scheme.onSurfaceVariant),
              ),
            ),
          ),
          for (final q in queries)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: const Icon(Icons.search, size: 16),
                label: Text(q),
                onPressed: () => openWebPage(Uri.https('www.google.com', '/search', {'q': q}).toString()),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionView extends StatefulWidget {
  const _SuggestionView({required this.html});
  final String html;

  @override
  State<_SuggestionView> createState() => _SuggestionViewState();
}

class _SuggestionViewState extends State<_SuggestionView> {
  /// Google's block is one row: the logo and a carousel of chips, about 50 px high.
  static const _height = 52.0;

  late final WebViewController _controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.disabled)
    ..setBackgroundColor(Colors.transparent)
    ..setNavigationDelegate(
      NavigationDelegate(
        // A tapped chip opens Google in the browser instead of inside the strip.
        onNavigationRequest: (r) {
          final uri = Uri.tryParse(r.url);
          if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) return NavigationDecision.navigate;
          openWebPage(r.url);
          return NavigationDecision.prevent;
        },
      ),
    )
    ..loadHtmlString(
      '<!DOCTYPE html><html><head><meta name="viewport" content="width=device-width, initial-scale=1">'
      '</head><body style="margin:1px">${widget.html}</body></html>',
    );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: _height,
    child: WebViewWidget(
      controller: _controller,
      // Sideways swipes scroll Google's chips; the list keeps vertical ones.
      gestureRecognizers: {Factory<HorizontalDragGestureRecognizer>(HorizontalDragGestureRecognizer.new)},
    ),
  );
}
