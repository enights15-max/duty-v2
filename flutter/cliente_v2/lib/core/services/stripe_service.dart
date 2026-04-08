import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import '../constants/app_urls.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      debugPrint('Stripe initialization skipped: Unsupported platform.');
      return;
    }
    // Use the live publishable key from the backend environment
    Stripe.publishableKey =
        "pk_test_51Qsd1rPvUycBozh2w7L4Jn8IqnGPGk1mRxGVyDiOLRxJpJirPn9vHugIyyQRHHq52OlymC8Lm3A62cbmoylmoAIm00hi7nrStl";
    await Stripe.instance.applySettings();
  }

  // Updated to call your backend instead of the Stripe API directly.
  Future<String> createTestPaymentIntent(int amount, String currency) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        '${AppUrls.pgwBaseUrl}/create-payment-intent.php',
        data: {'amount': amount, 'currency': currency},
      );
      return response.data['client_secret'];
    } on DioException catch (e) {
      debugPrint(
        "Error fetching payment intent from backend: ${e.response?.data}",
      );
      rethrow;
    } catch (e) {
      debugPrint("Error fetching payment intent from backend: $e");
      rethrow;
    }
  }

  // TEMPORARY: For testing only. NEVER do this in production.
  Future<String> createTestSetupIntent(String customerId) async {
    final dio = Dio();
    try {
      final response = await dio.post(
        'https://api.stripe.com/v1/setup_intents',
        options: Options(
          headers: {
            'Authorization':
                'Bearer sk_test_51Qsd1rPvUycBozh2CRqY9XCE715ohMzCX0gxNiK2fSYGvfZziJOGlEBkAC9q6CDDqIA6puzNiZFFzgz0XQg4iWzU00eXUbJGp5',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {'customer': customerId, 'payment_method_types[]': 'card'},
      );
      return response.data['client_secret'];
    } on DioException catch (e) {
      debugPrint("Error creating test setup intent: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("Error creating test setup intent: $e");
      rethrow;
    }
  }

  Future<bool> makePayment({
    String? paymentIntentClientSecret,
    String? setupIntentClientSecret,
    String? customerEphemeralKeySecret,
    String? customerId,
    String? currency, // Optional now
    String? amount, // Optional now
  }) async {
    try {
      debugPrint("StripeService: Initializing Payment Sheet");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          setupIntentClientSecret: setupIntentClientSecret,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          customerId: customerId,
          merchantDisplayName: 'Duty',
          style: ThemeMode.dark, // Updated to match requested dark theme
          billingDetailsCollectionConfiguration:
              const BillingDetailsCollectionConfiguration(
                address: AddressCollectionMode.never,
                phone: CollectionMode.never,
                email: CollectionMode.never,
                name: CollectionMode.never,
                attachDefaultsToPaymentMethod: true,
              ),
        ),
      );

      debugPrint("StripeService: Presenting Payment Sheet");
      await Stripe.instance.presentPaymentSheet();

      debugPrint("StripeService: Payment Confirmed");
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        debugPrint("StripeService: Payment Canceled by user");
        return false;
      }
      debugPrint("StripeService Error: ${e.error.localizedMessage}");
      rethrow;
    } catch (e) {
      debugPrint("StripeService Unexpected Error: $e");
      rethrow;
    }
  }

  Future<bool> confirmCustomPayment({
    required String clientSecret,
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String name,
  }) async {
    try {
      // 1. Create Token using Stripe API directly (since flutter_stripe restricts raw data)
      final dio = Dio();
      final response = await dio.post(
        'https://api.stripe.com/v1/tokens',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Stripe.publishableKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'card[number]': number,
          'card[exp_month]': expMonth.toString(),
          'card[exp_year]': expYear.toString(),
          'card[cvc]': cvc,
          'card[name]': name,
        },
      );
      final tokenId = response.data['id'];

      // 2. Confirm Payment using Token
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromToken(
          paymentMethodData: PaymentMethodDataCardFromToken(token: tokenId),
        ),
      );

      return true;
    } on DioException catch (e) {
      debugPrint("Custom Payment Dio Error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("Custom Payment Error: $e");
      rethrow;
    }
  }
}
