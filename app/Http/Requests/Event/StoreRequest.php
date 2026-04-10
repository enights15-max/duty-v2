<?php

namespace App\Http\Requests\Event;

use App\Models\Language;
use App\Rules\ImageMimeTypeRule;
use App\Models\Event\EventContent;
use Illuminate\Support\Facades\DB;
use Illuminate\Foundation\Http\FormRequest;

class StoreRequest extends FormRequest
{
  protected bool $rewardDefinitionsPayloadInvalid = false;

  /**
   * Determine if the user is authorized to make this request.
   *
   * @return bool
   */
  public function authorize()
  {
    return true;
  }

  protected function prepareForValidation()
  {
    $payload = $this->input('reward_definitions_payload');

    if (!is_string($payload) || trim($payload) === '') {
      return;
    }

    $decoded = json_decode($payload, true);
    if (json_last_error() !== JSON_ERROR_NONE || !is_array($decoded)) {
      $this->rewardDefinitionsPayloadInvalid = true;
      return;
    }

    $this->merge([
      'reward_definitions' => $decoded,
    ]);
  }

  /**
   * Get the validation rules that apply to the request.
   *
   * @return array<string, mixed>
   */
  public function rules()
  {


    $request = $this->request->all();
    $ruleArray = [
      'slider_images' => 'required_without:slider_files',
      'slider_files' => 'required_without:slider_images|array',
      'slider_files.*' => [
        'image',
        'mimes:jpg,jpeg,png',
      ],
      'thumbnail' => [
        'required',
        new ImageMimeTypeRule(),
      ],
      'status' => 'required',
      'is_featured' => 'required',
      'age_limit' => 'nullable|integer|min:0',
      'artist_ids' => 'nullable|array',
      'owner_identity_id' => 'nullable|exists:identities,id',
      'venue_identity_id' => 'nullable|exists:identities,id',
      'hold_mode' => 'nullable|in:manual_admin,auto_after_grace_period',
      'grace_period_hours' => 'nullable|required_if:hold_mode,auto_after_grace_period|integer|min:1|max:720',
      'refund_window_hours' => 'nullable|integer|min:0|max:720',
      'auto_release_owner_share' => 'nullable|boolean',
      'auto_release_collaborator_shares' => 'nullable|boolean',
      'require_admin_approval' => 'nullable|boolean',
      'settlement_notes' => 'nullable|string|max:1000',
      'reservation_enabled' => 'nullable|boolean',
      'reservation_deposit_type' => 'nullable|required_if:reservation_enabled,1|in:fixed,percentage',
      'reservation_deposit_value' => 'nullable|required_if:reservation_enabled,1|numeric|min:0.01',
      'reservation_final_due_date' => 'nullable|required_if:reservation_enabled,1|date',
      'reservation_min_installment_amount' => 'nullable|numeric|min:0.01',
      'price_schedules' => 'nullable|array',
      'price_schedules.*.label' => 'nullable|string|max:255',
      'price_schedules.*.effective_from' => 'nullable|required_with:price_schedules.*.price|date',
      'price_schedules.*.price' => 'nullable|required_with:price_schedules.*.effective_from|numeric|min:0.01',
      'price_schedules.*.sort_order' => 'nullable|integer|min:0',
      'price_schedules.*.is_active' => 'nullable|boolean',
      'reward_definitions_payload' => 'nullable|string',
      'reward_definitions' => 'nullable|array|max:12',
      'reward_definitions.*.id' => 'nullable|integer|min:1',
      'reward_definitions.*.title' => 'required|string|max:255',
      'reward_definitions.*.description' => 'nullable|string|max:500',
      'reward_definitions.*.reward_type' => 'nullable|in:welcome_drink,drink_voucher,merch,perk_access,custom,perk',
      'reward_definitions.*.trigger_mode' => 'nullable|in:on_ticket_scan,on_booking_completed,manual_issue',
      'reward_definitions.*.fulfillment_mode' => 'nullable|in:qr_claim',
      'reward_definitions.*.inventory_limit' => 'nullable|integer|min:1|max:100000',
      'reward_definitions.*.per_ticket_quantity' => 'nullable|integer|min:1|max:10',
      'reward_definitions.*.status' => 'nullable|in:active,inactive',
      'reward_definitions.*.meta' => 'nullable|array',
      'reward_definitions.*.meta.claim_code_prefix' => 'nullable|string|max:8|regex:/^[A-Za-z0-9]+$/',
    ];

    if ($this->date_type == 'single') {
      $ruleArray['start_date'] = 'required';
      $ruleArray['start_time'] = 'required';
      $ruleArray['end_date'] = 'required';
      $ruleArray['end_time'] = 'required';
    }

    if ($this->date_type == 'multiple') {
      $ruleArray['m_start_date.*'] = 'required';
      $ruleArray['m_start_time.*'] = 'required';
      $ruleArray['m_end_date.*'] = 'required';
      $ruleArray['m_end_time.*'] = 'required';
    }

    if ($this->event_type == 'online') {
      $ruleArray['early_bird_discount_type'] = 'required';
      $ruleArray['meeting_url'] = 'required';
      $ruleArray['discount_type'] = 'required_if:early_bird_discount_type,enable';
      $ruleArray['early_bird_discount_amount'] = 'required_if:early_bird_discount_type,enable';
      $ruleArray['early_bird_discount_date'] = 'required_if:early_bird_discount_type,enable';
      $ruleArray['early_bird_discount_time'] = 'required_if:early_bird_discount_type,enable';
      $ruleArray['ticket_available_type'] = 'required';

      if ($this->filled('ticket_available_type') && $this->ticket_available_type == 'limited') {
        $ruleArray['ticket_available'] = 'required';
      }

      $ruleArray['max_ticket_buy_type'] = 'required';

      if ($this->filled('max_ticket_buy_type') && $this->max_ticket_buy_type == 'limited') {
        $ruleArray['max_buy_ticket'] = 'required';
      }

      if (!$this->filled('pricing_type')) {
        $ruleArray['price'] = 'required';
      }

      if ($request['early_bird_discount_type'] == 'enable' && $request['discount_type'] == 'percentage') {
        $ruleArray['early_bird_discount_amount'] = 'numeric|between:1,99';
      } elseif ($request['early_bird_discount_type'] == 'enable' && $request['discount_type'] == 'fixed') {
        $price = $request['price'] - 1;
        $ruleArray['early_bird_discount_amount'] = "numeric|between:1,$price";
      }
    }

    if ($this->event_type == 'venue') {
      if ((string) $this->input('venue_source') === 'external') {
        $ruleArray['latitude'] = 'required_if:event_type,venue';
        $ruleArray['longitude'] = 'required_if:event_type,venue';
      } else {
        $ruleArray['latitude'] = 'nullable';
        $ruleArray['longitude'] = 'nullable';
      }
    }

    $bs = DB::table('basic_settings')
      ->select('event_country_status', 'event_state_status')
      ->first();
    $languages = Language::all();
    foreach ($languages as $language) {
      $slug = createSlug($this[$language->code . '_title']);

      $ruleArray[$language->code . '_title'] = [
        'required',
        'max:255',
        function ($attribute, $value, $fail) use ($slug, $language) {
          $cis = EventContent::where('language_id', $language->id)->get();
          foreach ($cis as $ci) {
            if (strtolower($slug) == strtolower($ci->slug)) {
              $fail('The title field must be unique for ' . $language->name . ' language.');
            }
          }
        }
      ];

      if ($bs->event_country_status == 1) {
        $ruleArray[$language->code . '_country'] = $this->usesResolvedVenueSource()
          ? 'nullable'
          : 'required_if:event_type,venue';
      }
      if ($bs->event_state_status == 1) {
        $ruleArray[$language->code . '_state'] = $this->usesResolvedVenueSource()
          ? 'nullable'
          : 'required_if:event_type,venue';
      }

      $ruleArray[$language->code . '_category_id'] = 'required';
      $ruleArray[$language->code . '_description'] = 'min:30';
      $ruleArray[$language->code . '_address'] = $this->usesResolvedVenueSource()
        ? 'nullable'
        : 'required_if:event_type,venue';
      $ruleArray[$language->code . '_city'] = $this->usesResolvedVenueSource()
        ? 'nullable'
        : 'required_if:event_type,venue';
    }

    return $ruleArray;
  }

  public function messages()
  {
    $messageArray = [];
    $messageArray['m_start_date.required'] = 'The start date field is required.!';
    $messageArray['m_start_time.required'] = 'The start time field is required.!';
    $messageArray['m_end_date.required'] = 'The end date field is required.!';
    $messageArray['m_end_time.required'] = 'The end time field is required.!';

    $languages = Language::all();
    foreach ($languages as $language) {
      $code = $language->code;
      $langNameText = $language->name . ' language.';
      $messageArray[$code . '_title.required'] = 'The title field is required for ' . $langNameText;

      $messageArray[$code . '_address.required_if'] = 'The address field is required for ' . $langNameText;
      $messageArray[$code . '_country.required_if'] = 'The country field is required for ' . $langNameText;
      $messageArray[$code . '_city.required_if'] = 'The city field is required for ' . $langNameText;
      $messageArray[$code . '_state.required_if'] = 'The state field is required for ' . $langNameText;

      $messageArray[$code . '_category_id.required'] = 'The category field is required for ' . $langNameText;
      $messageArray[$code . '_description.min'] = 'The description must be at least 30 characters for ' . $langNameText;
    }

    return $messageArray;
  }

  public function withValidator($validator)
  {
    $validator->after(function ($validator) {
      if ($this->rewardDefinitionsPayloadInvalid) {
        $validator->errors()->add(
          'reward_definitions_payload',
          'The reward definitions payload must be a valid JSON array.'
        );
      }
    });
  }

  protected function usesResolvedVenueSource(): bool
  {
    $venueSource = (string) $this->input('venue_source');

    if (in_array($venueSource, ['registered', 'external'], true)) {
      return true;
    }

    return $venueSource === 'manual' && $this->usesManualVenueSnapshot();
  }

  protected function usesManualVenueSnapshot(): bool
  {
    if ((string) $this->input('venue_source') !== 'manual') {
      return false;
    }

    foreach ([
      'venue_name',
      'venue_address',
      'venue_city',
      'venue_state',
      'venue_country',
      'venue_postal_code',
      'venue_google_place_id',
      'latitude',
      'longitude',
    ] as $field) {
      if ($this->filled($field)) {
        return true;
      }
    }

    return false;
  }
}
