import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

String lastMessage = "";

Widget getIframe(String url) {
  return DynamicIframe(url: url);
}


class DynamicIframe extends StatefulWidget {
  final String url;

  const DynamicIframe({super.key, required this.url});

  @override
  State<DynamicIframe> createState() => _DynamicIframeState();
}

class _DynamicIframeState extends State<DynamicIframe> {
  late html.IFrameElement _iframe;
  late String _viewId;

  @override
  void initState() {
    super.initState();

    _viewId = 'iframe-${widget.url.hashCode}';

    // Create the iframe
    _iframe = html.IFrameElement()
      ..src = widget.url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%';
    // Listen for messages from iframe
    html.window.onMessage.listen((event) {
        setState(() {
          lastMessage = event.data.toString();
          print('Message from iframe: ${event.data}');
        });
    });

    // Register the iframe as a platform view
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) => _iframe);
  }

  /// Send a message to the iframe
  void sendMessage(dynamic message) {
    _iframe.contentWindow?.postMessage(message, '*'); // Replace '*' with your iframe origin if known
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewId);
  }
}