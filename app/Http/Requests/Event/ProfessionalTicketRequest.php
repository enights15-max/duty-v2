<?php

namespace App\Http\Requests\Event;

use Illuminate\Foundation\Http\FormRequest;

class ProfessionalTicketRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $pricingType = (string) $this->input('pricing_type', 'normal');
        $reservationEnabled = filter_var($this->input('reservation_enabled', false), FILTER_VALIDATE_BOOLEAN);

        $rules = [
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:2000',
            'pricing_type' => 'required|in:free,normal,variation',
            'ticket_available_type' => 'required|in:limited,unlimited',
            'ticket_available' => 'nullable|integer|min:0',
            'max_ticket_buy_type' => 'required|in:limited,unlimited',
            'max_buy_ticket' => 'nullable|integer|min:1',
            'early_bird_discount_type' => 'nullable|in:disable,enable',
            'discount_type' => 'nullable|in:fixed,percentage',
            'early_bird_discount_amount' => 'nullable|numeric|min:0',
            'early_bird_discount_date' => 'nullable|date',
            'early_bird_discount_time' => 'nullable|string|max:32',
            'reservation_enabled' => 'nullable|boolean',
            'reservation_deposit_type' => 'nullable|in:fixed,percentage',
            'reservation_deposit_value' => 'nullable|numeric|min:0',
            'reservation_final_due_date' => 'nullable|date',
            'reservation_min_installment_amount' => 'nullable|numeric|min:0',
            'allow_promotional_resale' => 'nullable|boolean',
            'sale_status' => 'nullable|in:active,paused,hidden,archived',
            'price_schedules' => 'nullable|array',
            'price_schedules.*.label' => 'nullable|string|max:255',
            'price_schedules.*.effective_from' => 'required_with:price_schedules.*.price|date',
            'price_schedules.*.price' => 'required_with:price_schedules.*.effective_from|numeric|min:0.01',
            'price_schedules.*.sort_order' => 'nullable|integer|min:0',
            'price_schedules.*.is_active' => 'nullable|boolean',
            'variations' => 'nullable|array',
            'variations.*.name' => 'required_with:variations|string|max:255',
            'variations.*.price' => 'required_with:variations|numeric|min:0',
            'variations.*.ticket_available_type' => 'nullable|in:limited,unlimited',
            'variations.*.ticket_available' => 'nullable|integer|min:0',
            'variations.*.max_ticket_buy_type' => 'nullable|in:limited,unlimited',
            'variations.*.max_buy_ticket' => 'nullable|integer|min:1',
            'variations.*.sort_order' => 'nullable|integer|min:0',
            'gate_ticket_id' => 'nullable|integer|exists:tickets,id',
            'gate_trigger' => 'nullable|in:sold_out,date,manual',
            'gate_trigger_date' => 'nullable|date',
        ];

        if ($pricingType === 'normal') {
            $rules['price'] = 'required|numeric|min:0.01';
        } elseif ($pricingType === 'free') {
            $rules['price'] = 'nullable|numeric|min:0';
        } else {
            $rules['price'] = 'nullable|numeric|min:0';
            $rules['variations'] = 'required|array|min:1';
        }

        if ($this->input('ticket_available_type') === 'limited') {
            $rules['ticket_available'] = 'required|integer|min:0';
        }

        if ($this->input('max_ticket_buy_type') === 'limited') {
            $rules['max_buy_ticket'] = 'required|integer|min:1';
        }

        if (($this->input('early_bird_discount_type') ?? 'disable') === 'enable') {
            $rules['discount_type'] = 'required|in:fixed,percentage';
            $rules['early_bird_discount_amount'] = 'required|numeric|min:0.01';
            $rules['early_bird_discount_date'] = 'required|date';
            $rules['early_bird_discount_time'] = 'required|string|max:32';
        }

        if ($reservationEnabled) {
            $rules['reservation_deposit_type'] = 'required|in:fixed,percentage';
            $rules['reservation_deposit_value'] = 'required|numeric|min:0.01';
            $rules['reservation_final_due_date'] = 'required|date';
        }

        return $rules;
    }
}
