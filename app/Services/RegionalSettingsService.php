<?php

namespace App\Services;

use App\Models\BasicSettings\Basic;
use App\Models\Country;

class RegionalSettingsService
{
    public function getSettings(): array
    {
        $basic = Basic::query()->where('uniqid', 12345)->first();

        $defaultCountryIso2 = strtoupper(trim((string) ($basic?->app_default_country_iso2 ?: 'DO')));
        if ($defaultCountryIso2 === '') {
            $defaultCountryIso2 = 'DO';
        }

        $supportedCountryIso2s = $this->normalizeSupportedCountryIso2s(
            $basic?->app_supported_country_iso2s,
            $defaultCountryIso2,
        );

        $defaultCountry = Country::query()
            ->where('flag', 1)
            ->where('iso2', $defaultCountryIso2)
            ->first();

        return [
            'default_country_iso2' => $defaultCountryIso2,
            'default_country_id' => $defaultCountry?->id,
            'default_country_name' => $defaultCountry?->name ?? 'Dominican Republic',
            'default_country_native' => $defaultCountry?->native ?? 'República Dominicana',
            'supported_country_iso2s' => $supportedCountryIso2s,
            'timezone' => $basic?->timezone ?: 'America/Santo_Domingo',
            'currency' => [
                'code' => $basic?->base_currency_text ?: 'DOP',
                'symbol' => $basic?->base_currency_symbol ?: 'RD$',
                'symbol_position' => $basic?->base_currency_symbol_position ?: 'left',
                'text_position' => $basic?->base_currency_text_position ?: 'right',
                'rate' => (float) ($basic?->base_currency_rate ?: 1),
            ],
        ];
    }

    public function getSupportedCountries()
    {
        $settings = $this->getSettings();
        $defaultCountryIso2 = $settings['default_country_iso2'];
        $supportedCountryIso2s = $settings['supported_country_iso2s'];

        return Country::query()
            ->where('flag', 1)
            ->whereIn('iso2', $supportedCountryIso2s)
            ->get(['id', 'name', 'iso2', 'emoji', 'native', 'currency'])
            ->sortBy([
                fn ($country) => strtoupper((string) $country->iso2) === $defaultCountryIso2 ? 0 : 1,
                fn ($country) => $country->name,
            ])
            ->values();
    }

    /**
     * @return array<int, string>
     */
    public function normalizeSupportedCountryIso2s(mixed $rawValue, string $defaultCountryIso2 = 'DO'): array
    {
        $values = [];

        if (is_string($rawValue) && trim($rawValue) !== '') {
            $decoded = json_decode($rawValue, true);
            if (json_last_error() === JSON_ERROR_NONE && is_array($decoded)) {
                $values = $decoded;
            } else {
                $values = preg_split('/[\s,]+/', $rawValue) ?: [];
            }
        } elseif (is_array($rawValue)) {
            $values = $rawValue;
        }

        $normalized = collect($values)
            ->map(fn ($value) => strtoupper(trim((string) $value)))
            ->filter(fn ($value) => preg_match('/^[A-Z]{2}$/', $value) === 1)
            ->unique()
            ->values()
            ->all();

        if (empty($normalized)) {
            $normalized = [$defaultCountryIso2];
        } elseif (!in_array($defaultCountryIso2, $normalized, true)) {
            array_unshift($normalized, $defaultCountryIso2);
        }

        return array_values(array_unique($normalized));
    }
}
