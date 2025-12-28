import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utility/app_colors.dart';
import '../utility/custom_app_bar.dart';

class LocationWebViewScreen extends StatefulWidget {
  final String title;
  final String url;

  const LocationWebViewScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<LocationWebViewScreen> createState() => _LocationWebViewScreenState();
}

class _LocationWebViewScreenState extends State<LocationWebViewScreen> {
  WebViewController? _controller;
  int _progress = 0;

  bool get _supportsInAppWebView {
    if (kIsWeb) return false;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return false;
    }
  }

  Future<void> _openExternal() async {
    final uri = Uri.tryParse(widget.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void initState() {
    super.initState();

    if (_supportsInAppWebView) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (p) => setState(() => _progress = p),
          ),
        )
        ..loadRequest(Uri.parse(widget.url));
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _openExternal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_supportsInAppWebView) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: widget.title),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thiết bị hiện tại không hỗ trợ WebView trong app.',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đã tự động mở website bằng trình duyệt mặc định. Nếu chưa mở, bạn bấm nút bên dưới.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openExternal,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Mở trong trình duyệt'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.cardBackground,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.title,
        actions: [
          IconButton(
            onPressed: () => _controller?.reload(),
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_progress < 100)
            LinearProgressIndicator(
              value: _progress / 100.0,
              backgroundColor: AppColors.primary.withOpacity(0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 2,
            ),
          Expanded(
            child: WebViewWidget(controller: _controller!),
          ),
        ],
      ),
    );
  }
}


