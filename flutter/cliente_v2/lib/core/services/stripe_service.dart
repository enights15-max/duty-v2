import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:dio/dio.dart';
import 'package:duty_client/core/utils/app_logger.dart';

class StripeService {
  StripeService._();

  static final StripeService instance = StripeService._();
  static const String _publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51Qsd1rPvUycBozh2w7L4Jn8IqnGPGk1mRxGVyDiOLRxJpJirPn9vHugIyyQRHHq52OlymC8Lm3A62cbmoylmoAIm00hi7nrStl',
  );

  Future<void> initialize() async {
    if (kIsWeb || (!Platform.isIOS && !Platform.isAndroid)) {
      appLog('Stripe initialization skipped: Unsupported platform.');
      return;
    }
    if (_publishableKey.isEmpty) {
      appLog(
        'Stripe initialization skipped: STRIPE_PUBLISHABLE_KEY is not configured.',
      );
      return;
    }

    Stripe.publishableKey = _publishableKey;
    Stripe.merchantIdentifier = 'merchant.com.duty.app';
    await Stripe.instance.applySettings();
  }

  Future<String> createTestSetupIntent(String customerId) async {
    throw UnsupportedError(
      'Setup intents must be created by the backend endpoint /customers/payment-methods/setup-intent.',
    );
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
      appLog("StripeService: Initializing Payment Sheet");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          setupIntentClientSecret: setupIntentClientSecret,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          customerId: customerId,
          merchantDisplayName: 'Duty',
          style: ThemeMode.dark,
          applePay: const PaymentSheetApplePay(merchantCountryCode: 'DO'),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'DO',
            testEnv: true,
          ),
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

      appLog("StripeService: Presenting Payment Sheet");
      await Stripe.instance.presentPaymentSheet();

      appLog("StripeService: Payment Confirmed");
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        appLog("StripeService: Payment Canceled by user");
        return false;
      }
      appLog("StripeService Error: ${e.error.localizedMessage}");
      rethrow;
    } catch (e) {
      appLog("StripeService Unexpected Error: $e");
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
      appLog("Custom Payment Dio Error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      appLog("Custom Payment Error: $e");
      rethrow;
    }
  }

  Future<bool> confirmSavedCardPayment({
    required String clientSecret,
    required String paymentMethodId,
  }) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        appLog("StripeService: Payment Canceled by user");
        return false;
      }
      appLog("StripeService Error: ${e.error.localizedMessage}");
      rethrow;
    } catch (e) {
      appLog("StripeService Unexpected Error: $e");
      rethrow;
    }
  }

  Future<bool> confirmCustomSetupIntent({
    required String clientSecret,
    required String number,
    required int expMonth,
    required int expYear,
    required String cvc,
    required String name,
  }) async {
    try {
      // 1. Create PaymentMethod using Stripe API directly
      final dio = Dio();
      final response = await dio.post(
        'https://api.stripe.com/v1/payment_methods',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${Stripe.publishableKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: {
          'type': 'card',
          'card[number]': number,
          'card[exp_month]': expMonth.toString(),
          'card[exp_year]': expYear.toString(),
          'card[cvc]': cvc,
          'billing_details[name]': name,
        },
      );
      final paymentMethodId = response.data['id'];

      // 2. Confirm SetupIntent using PaymentMethod ID
      await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: PaymentMethodParams.cardFromMethodId(
          paymentMethodData: PaymentMethodDataCardFromMethod(
            paymentMethodId: paymentMethodId,
          ),
        ),
      );

      return true;
    } on DioException catch (e) {
      appLog("Custom SetupIntent Dio Error: ${e.response?.data}");
      rethrow;
    } catch (e) {
      appLog("Custom SetupIntent Error: $e");
      rethrow;
    }
  }
}
