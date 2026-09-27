// lib/custom_widgets/network_error_widget.dart

import 'package:flutter/material.dart';

class NetworkErrorWidget extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryButtonText;
  final IconData? icon;

  const NetworkErrorWidget({
    Key? key,
    this.title,
    this.message,
    this.onRetry,
    this.retryButtonText,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network error icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.wifi_off_rounded,
                size: 64,
                color: Colors.red.shade400,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              title ?? "No Internet Connection",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Message
            Text(
              message ?? "Please check your internet connection and try again.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Retry button
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(retryButtonText ?? "Try Again"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Network connectivity helper class
class NetworkHelper {
  // Check if error is network related
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    
    final errorMessage = error.toString().toLowerCase();
    return errorMessage.contains('network') ||
           errorMessage.contains('internet') ||
           errorMessage.contains('connection') ||
           errorMessage.contains('timeout') ||
           errorMessage.contains('socket') ||
           errorMessage.contains('unreachable') ||
           errorMessage.contains('failed host lookup');
  }
  
  // Get appropriate error message
  static String getErrorMessage(dynamic error) {
    if (isNetworkError(error)) {
      return "Please check your internet connection";
    }
    return "Something went wrong. Please try again.";
  }
  
  // Get appropriate error title
  static String getErrorTitle(dynamic error) {
    if (isNetworkError(error)) {
      return "No Internet Connection";
    }
    return "Error Occurred";
  }
  
  // Get appropriate icon
  static IconData getErrorIcon(dynamic error) {
    if (isNetworkError(error)) {
      return Icons.wifi_off_rounded;
    }
    return Icons.error_outline_rounded;
  }
}