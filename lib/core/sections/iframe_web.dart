import 'dart:html' as html;

String? getIframeUrl() {
  final iframe = html.querySelector('iframe') as html.IFrameElement?;
  return iframe?.contentWindow?.location.toString();
}