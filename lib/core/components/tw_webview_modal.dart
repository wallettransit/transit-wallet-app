import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TWWebviewModal extends StatefulWidget {
  final String url;
  final String title;

  const TWWebviewModal({
    super.key,
    required this.url,
    this.title = 'Payment',
  });

  static void show(BuildContext context, {required String url, String title = 'Secure Payment'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false, // Prevent accidental closing while paying
      builder: (context) => TWWebviewModal(url: url, title: title),
    );
  }

  @override
  State<TWWebviewModal> createState() => _TWWebviewModalState();
}

class _TWWebviewModalState extends State<TWWebviewModal> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.cardBackground)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (NavigationRequest request) {
            // If they reach the success callback URL, we can automatically close the modal.
            // The deep link handler in passenger_top_up_screen will pick it up and verify.
            if (request.url.contains('transitwallet.app/topup/callback') || 
                request.url.contains('transitwallet://payment/callback')) {
              Navigator.pop(context); // Close the modal
              // The deep link listener will handle the verification.
              // Alternatively, we could just let the webview redirect, and the OS will catch the app link.
              return NavigationDecision.navigate;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.ink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(bottom: BorderSide(color: AppColors.borderStroke)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.paper),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.heading3.copyWith(color: AppColors.paper),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.lock, size: 12, color: AppColors.kekeGreen),
                          const SizedBox(width: 4),
                          Text('Secured by Paystack', style: AppTypography.label.copyWith(color: AppColors.kekeGreen)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Progress Bar
          if (_isLoading)
            const LinearProgressIndicator(
              color: AppColors.kekeGreen,
              backgroundColor: AppColors.ink,
              minHeight: 2,
            ).animate().fade(),
            
          // Webview
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(0),
              ),
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
