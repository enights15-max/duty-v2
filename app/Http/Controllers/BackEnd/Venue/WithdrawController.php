<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use App\Models\Withdraw;
use App\Models\WithdrawPaymentMethod;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class WithdrawController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService
    ) {
    }

    public function index()
    {
        $withdraws = Withdraw::where('venue_id', Auth::guard('venue')->id())->orderBy('id', 'desc')->paginate(10);
        return view('venue.withdraw.index', compact('withdraws'));
    }

    public function create()
    {
        $methods = WithdrawPaymentMethod::where('status', 1)->get();
        return view('venue.withdraw.create', compact('methods'));
    }

    public function store(Request $request)
    {
        $venue = Auth::guard('venue')->user();
        $method = WithdrawPaymentMethod::find($request->withdraw_method_id);

        $rules = [
            'withdraw_method_id' => 'required',
            'amount' => 'required|numeric|min:' . $method->min_limit . '|max:' . $method->max_limit,
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        if ($request->amount > $venue->amount) {
            Session::flash('error', 'Insufficient balance');
            return back()->withInput();
        }

        $withdraw = new Withdraw();
        $withdraw->venue_id = $venue->id;
        $withdraw->withdraw_method_id = $request->withdraw_method_id;
        $withdraw->amount = $request->amount;
        $withdraw->payable_amount = $request->amount - ($method->fixed_charge + ($request->amount * $method->percentage_charge / 100));
        $withdraw->additional_reference = $request->additional_reference;
        $withdraw->status = 0; // pending
        $withdraw->save();

        $venue->amount -= $request->amount;
        $venue->save();

        Session::flash('success', 'Withdraw request sent successfully');
        return redirect()->route('venue.withdraw');
    }
}
