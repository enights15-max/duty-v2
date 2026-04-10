<?php

namespace App\Http\Controllers\BackEnd\Artist;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Transaction;
use App\Models\Withdraw;
use App\Models\WithdrawPaymentMethod;
use App\Services\ProfessionalBalanceService;
use App\Services\ProfessionalCatalogBridgeService;
use App\Traits\HasIdentityActor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class WithdrawController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService,
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function index()
    {
        $withdraws = Withdraw::where('artist_id', Auth::guard('artist')->id())->orderBy('id', 'desc')->paginate(10);
        return view('artist.withdraw.index', compact('withdraws'));
    }

    public function create()
    {
        $methods = WithdrawPaymentMethod::where('status', 1)->get();
        return view('artist.withdraw.create', compact('methods'));
    }

    public function store(Request $request)
    {
        $artist = Auth::guard('artist')->user();
        $method = WithdrawPaymentMethod::find($request->withdraw_method_id);

        if (!$method) {
            return back()->with('error', 'Please select a valid withdrawal method.');
        }

        $rules = [
            'withdraw_method_id' => 'required',
            'amount' => 'required|numeric|min:' . $method->min_limit . '|max:' . $method->max_limit,
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        if ($request->amount > $artist->amount) {
            Session::flash('error', 'Insufficient balance');
            return back()->withInput();
        }

        $withdraw = new Withdraw();
        $withdraw->artist_id = $artist->id;
        $artistIdentityId = $this->catalogBridge->findIdentityForLegacy('artist', $artist->id)?->id;
        $withdraw->artist_identity_id = $artistIdentityId;
        $withdraw->method_id = $request->withdraw_method_id;
        $withdraw->amount = $request->amount;
        $withdraw->payable_amount = $request->amount - ($method->fixed_charge + ($request->amount * $method->percentage_charge / 100));
        $withdraw->additional_reference = $request->additional_reference;
        $withdraw->status = 0; // pending
        $balancePreview = $this->professionalBalanceService->debitArtistBalance($artistIdentityId, $artist->id, (float) $request->amount);
        $withdraw->save();

        Transaction::create([
            'transcation_id' => time(),
            'booking_id' => $withdraw->id,
            'transcation_type' => 3,
            'artist_id' => $artist->id,
            'artist_identity_id' => $artistIdentityId,
            'payment_status' => 0,
            'payment_method' => $withdraw->method_id,
            'grand_total' => $withdraw->amount,
            'pre_balance' => $balancePreview['pre_balance'],
            'after_balance' => $balancePreview['after_balance'],
            'gateway_type' => null,
        ]);

        Session::flash('success', 'Withdraw request sent successfully');
        return redirect()->route('artist.withdraw');
    }
}
