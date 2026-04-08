<?php

namespace App\Services;

use App\Models\User;
use App\Models\PaymentMethod;
use Stripe\StripeClient;
use Exception;
use Illuminate\Support\Facades\Log;

class StripeService
{
    protected $stripe;

    public function __construct()
    {
        $this->stripe = new StripeClient(config('services.stripe.secret'));
    }

    /**
     * Get or create a Stripe Customer ID for a user.
     */
    public function getOrCreateCustomer($user)
    {
        if ($user->stripe_customer_id) {
            return $user->stripe_customer_id;
        }

        try {
            $customer = $this->stripe->customers->create([
                'email' => $user->email,
                'name' => ($user->fname ?? $user->first_name ?? 'Customer') . ' ' . ($user->lname ?? $user->last_name ?? ''),
                'metadata' => [
                    'user_id' => $user->id,
                    'type' => get_class($user),
                ],
            ]);

            $user->stripe_customer_id = $customer->id;
            $user->save();

            return $customer->id;
        } catch (Exception $e) {
            Log::error("Stripe Customer creation failed: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Create a SetupIntent for a user to save a card.
     */
    public function createSetupIntent($user)
    {
        $customerId = $this->getOrCreateCustomer($user);

        try {
            $setupIntent = $this->stripe->setupIntents->create([
                'customer' => $customerId,
                'payment_method_types' => ['card'],
            ]);

            return $setupIntent->client_secret;
        } catch (Exception $e) {
            Log::error("Stripe SetupIntent creation failed: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Retrieve payment method details from Stripe.
     */
    public function retrievePaymentMethod($paymentMethodId)
    {
        try {
            return $this->stripe->paymentMethods->retrieve($paymentMethodId);
        } catch (Exception $e) {
            Log::error("Stripe PaymentMethod retrieval failed: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Charge a saved payment method off-session.
     */
    public function chargeSavedCard($user, $amount, $currency, $description, $metadata = [])
    {
        $defaultPM = $user->paymentMethods()->where('is_default', true)->first();

        if (!$defaultPM) {
            throw new Exception("No default payment method found for user.");
        }

        try {
            $paymentIntent = $this->stripe->paymentIntents->create([
                'amount' => (int) ($amount * 100),
                'currency' => strtolower($currency),
                'customer' => $user->stripe_customer_id,
                'payment_method' => $defaultPM->stripe_payment_method_id,
                'off_session' => true,
                'confirm' => true,
                'description' => $description,
                'metadata' => $metadata,
            ]);

            return $paymentIntent;
        } catch (Exception $e) {
            Log::error("Stripe off-session charge failed: " . $e->getMessage());
            throw $e;
        }
    }
}
