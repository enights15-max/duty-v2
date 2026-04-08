<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Country;
use App\Models\City;
use App\Services\RegionalSettingsService;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    public function __construct(
        private RegionalSettingsService $regionalSettingsService
    ) {
    }

    /**
     * Return all countries (id, name, iso2).
     * Admin can disable countries by setting flag=0.
     */
    public function countries()
    {
        $settings = $this->regionalSettingsService->getSettings();
        $defaultCountryIso2 = $settings['default_country_iso2'];

        $countries = $this->regionalSettingsService
            ->getSupportedCountries()
            ->map(function ($country) use ($defaultCountryIso2) {
                return [
                    'id' => $country->id,
                    'name' => $country->name,
                    'iso2' => $country->iso2,
                    'emoji' => $country->emoji,
                    'native' => $country->native,
                    'currency' => $country->currency,
                    'is_default' => strtoupper((string) $country->iso2) === $defaultCountryIso2,
                ];
            })
            ->values();

        return response()->json([
            'success' => true,
            'data' => $countries,
            'meta' => $settings,
        ]);
    }

    /**
     * Return cities for a given country_id.
     */
    public function cities(Request $request)
    {
        $countryId = $request->query('country_id');
        if (empty($countryId)) {
            return response()->json([
                'success' => false,
                'message' => 'country_id is required',
                'data' => [],
            ], 422);
        }

        $query = City::orderBy('name')->where('country_id', $countryId);

        $cities = $query->get(['id', 'name', 'country_id']);

        return response()->json([
            'success' => true,
            'data' => $cities,
        ]);
    }
}
