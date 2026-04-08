<?php

namespace App\Http\Controllers\BackEnd;

use App\Http\Controllers\Controller;
use App\Models\BasicSettings\Basic;
use App\Models\Event\Booking;
use App\Models\Language;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class BlackmarketController extends Controller
{
    public function tickets(Request $request)
    {
        $language = Language::where('is_default', 1)->first();

        $search = $request->input('search');

        $tickets = Booking::where('is_listed', 1)
            ->when($search, function ($query, $search) {
                return $query->where('order_number', 'like', '%' . $search . '%')
                    ->orWhere('email', 'like', '%' . $search . '%');
            })
            ->with(['event', 'customerInfo'])
            ->orderBy('id', 'desc')
            ->paginate(10);

        return view('backend.blackmarket.index', compact('tickets', 'language'));
    }

    public function settings()
    {
        $data = Basic::select('marketplace_commission', 'marketplace_max_price_rule')->first();
        return view('backend.blackmarket.settings', compact('data'));
    }

    public function updateSettings(Request $request)
    {
        $rules = [
            'marketplace_commission' => 'required|numeric|min:0',
            'marketplace_max_price_rule' => 'required|integer|in:0,1',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 400);
        }

        Basic::query()->update([
            'marketplace_commission' => $request->marketplace_commission,
            'marketplace_max_price_rule' => $request->marketplace_max_price_rule,
        ]);

        Session::flash('success', 'Marketplace settings updated successfully!');

        return response()->json(['status' => 'success'], 200);
    }
}
