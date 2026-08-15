import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../components/tw_snackbar.dart';

class TWErrorHandler {
  /// Translates raw exceptions into user-friendly strings and displays the TWSnackbar
  static void handle(BuildContext context, dynamic error, [StackTrace? stackTrace]) {
    String title = 'Something went wrong';
    String message = 'We encountered an unexpected error. Please try again.';

    // Safely extract message if it's a known string or exception object
    String errorString = error.toString();
    
    // 1. Network Errors
    if (error is SocketException || errorString.contains('SocketException') || errorString.contains('Failed host lookup')) {
      title = 'No Internet Connection';
      message = 'Looks like you\'re offline. Please check your internet connection and try again.';
    } 
    // 2. Auth Errors
    else if (error is AuthException || errorString.contains('AuthRetryableFetchException') || errorString.contains('AuthException')) {
      if (errorString.toLowerCase().contains('invalid login credentials')) {
        title = 'Login Failed';
        message = 'Invalid email or password. Please try again.';
      } else {
        title = 'Authentication Error';
        message = 'We could not verify your account. Please log in again.';
      }
    } 
    // 3. Database / Supabase Errors
    else if (error is PostgrestException || errorString.contains('PostgrestException')) {
      title = 'Server Error';
      message = 'Our servers are taking a quick nap or this resource does not exist. Try again in a moment.';
    }
    // 4. Custom Error Strings (e.g. from Riverpod AsyncValue.error if we threw a String)
    else if (error is String && error.isNotEmpty) {
      message = error;
    }

    // Finally, show the clean UI
    TWSnackbar.showError(context, message, title: title);
  }
}
