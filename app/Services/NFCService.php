<?php

namespace App\Services;

use App\Models\NfcToken;
use App\Models\Customer;
use Illuminate\Support\Facades\Hash;

class NFCService
{
    /**
     * Generate a secure hash of the raw NFC UID.
     * We use HMAC to ensure the raw UID is never stored and is resistant to rainbow tables.
     */
    public function generateHash(string $uid): string
    {
        $secret = config('services.nfc.secret', 'duty_nfc_default_secret');
        return hash_hmac('sha256', $uid, $secret);
    }

    /**
     * Link a physical NFC tag to a user.
     */
    public function linkToken(Customer $customer, string $uidRaw, string $pin = null): NfcToken
    {
        $hash = $this->generateHash($uidRaw);

        $payload = [
            'uid_hash' => $hash,
            'pin_hash' => $pin ? Hash::make($pin) : null,
            'status' => 'active',
        ];

        if (NfcToken::supportsActorColumns()) {
            $payload['actor_type'] = 'customer';
            $payload['actor_id'] = $customer->id;
        }

        return NfcToken::updateOrCreate(
            ['user_id' => $customer->id],
            $payload
        );
    }

    /**
     * Validate a raw UID and return the token if active.
     */
    public function validateToken(string $uidRaw): ?NfcToken
    {
        $hash = $this->generateHash($uidRaw);

        $token = NfcToken::where('uid_hash', $hash)->first();

        if (!$token || $token->status !== 'active') {
            return null;
        }

        return $token;
    }

    /**
     * Verify if the provided PIN matches the token's PIN.
     */
    public function verifyPin(NfcToken $token, string $pin): bool
    {
        if (empty($token->pin_hash)) {
            return true; // No PIN required
        }

        return Hash::check($pin, $token->pin_hash);
    }
}
