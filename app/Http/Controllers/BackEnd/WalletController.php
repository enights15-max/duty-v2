<?php

namespace App\Http\Controllers\BackEnd;

use App\Http\Controllers\Controller;
use App\Models\IdentityBalanceTransaction;
use App\Models\Wallet;
use App\Models\WalletTransaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

use App\Services\NotificationService;
use App\Services\ProfessionalBalanceService;

class WalletController extends Controller
{
    protected $notificationService;
    protected $professionalBalanceService;

    public function __construct(
        NotificationService $notificationService,
        ProfessionalBalanceService $professionalBalanceService
    )
    {
        $this->notificationService = $notificationService;
        $this->professionalBalanceService = $professionalBalanceService;
    }
    public function index(Request $request)
    {
        $searchKey = $request->input('info');

        $wallets = Wallet::with('user')
            ->when($searchKey, function ($query, $searchKey) {
                return $query->whereHas('user', function ($q) use ($searchKey) {
                    $q->where('fname', 'like', '%' . $searchKey . '%')
                        ->orWhere('lname', 'like', '%' . $searchKey . '%')
                        ->orWhere('email', 'like', '%' . $searchKey . '%');
                });
            })
            ->orderBy('id', 'desc')
            ->paginate(10);

        return view('backend.end-user.wallet.index', compact('wallets'));
    }

    public function history($id)
    {
        $wallet = Wallet::with('user')->findOrFail($id);
        $transactions = WalletTransaction::where('wallet_id', $wallet->id)
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return view('backend.end-user.wallet.history', compact('wallet', 'transactions'));
    }

    public function adjustBalance(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'type' => 'required|in:add,subtract',
            'amount' => 'required|numeric|min:0.01',
            'description' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $wallet = Wallet::findOrFail($id);
        $amount = $request->type === 'add' ? $request->amount : -$request->amount;

        WalletTransaction::create([
            'wallet_id' => $wallet->id,
            'type' => 'admin_adjustment',
            'amount' => $amount,
            'description' => $request->description,
            'reference_type' => 'admin_adjustment',
            'reference_id' => 'ADMIN-ADJ-' . time(),
            'idempotency_key' => 'adj_' . $wallet->id . '_' . microtime(true),
            'created_by' => Auth::guard('admin')->user()->id ?? null,
            'status' => 'completed',
        ]);

        $wallet->balance += $amount;
        $wallet->save();

        Session::flash('success', 'Wallet balance adjusted successfully.');
        return redirect()->back();
    }

    public function withdrawals(Request $request)
    {
        $status = $request->input('status');
        $withdrawals = \App\Models\Wallet\WithdrawalRequest::with('customer')
            ->when($status, function ($query, $status) {
                return $query->where('status', $status);
            })
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        return view('backend.end-user.wallet.withdrawals', compact('withdrawals'));
    }

    public function approveWithdrawal($id)
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($id) {
            $withdrawal = \App\Models\Wallet\WithdrawalRequest::findOrFail($id);

            if ($withdrawal->status !== 'pending') {
                return redirect()->back()->with('error', 'Withdrawal request is not pending.');
            }

            // In our system, funds were already "debited" as a hold when requested.
            // Approval simply confirms the external transaction.
            $withdrawal->update([
                'status' => 'approved',
                'admin_notes' => 'Approved by admin ' . Auth::guard('admin')->user()->username,
            ]);

            // Notify User
            $this->notificationService->notifyUser(
                $withdrawal->customer,
                'Withdrawal Approved',
                'Your withdrawal request for ' . env('BASE_CURRENCY_SYMBOL', '$') . number_format($withdrawal->amount, 2) . ' from ' . $this->withdrawalDisplayName($withdrawal) . ' has been approved.'
            );

            Session::flash('success', 'Withdrawal approved.');
            return redirect()->back();
        });
    }

    public function rejectWithdrawal(Request $request, $id)
    {
        return \Illuminate\Support\Facades\DB::transaction(function () use ($id, $request) {
            $withdrawal = \App\Models\Wallet\WithdrawalRequest::findOrFail($id);

            if ($withdrawal->status !== 'pending') {
                return redirect()->back()->with('error', 'Withdrawal request is not pending.');
            }

            $this->refundWithdrawalToOrigin($withdrawal);

            $withdrawal->update([
                'status' => 'rejected',
                'admin_notes' => $request->input('reason', 'Rejected by admin.'),
            ]);

            // Notify User
            $this->notificationService->notifyUser(
                $withdrawal->customer,
                'Withdrawal Rejected',
                'Your withdrawal request from ' . $this->withdrawalDisplayName($withdrawal) . ' has been rejected. Reason: ' . $withdrawal->admin_notes
            );

            Session::flash('success', 'Withdrawal rejected and funds refunded.');
            return redirect()->back();
        });
    }

    private function refundWithdrawalToOrigin(\App\Models\Wallet\WithdrawalRequest $withdrawal): void
    {
        if ($withdrawal->identity_id && in_array($withdrawal->actor_type, ['organizer', 'artist', 'venue'], true)) {
            $identityId = (int) $withdrawal->identity_id;
            $amount = (float) $withdrawal->amount;

            $result = match ($withdrawal->actor_type) {
                'organizer' => $this->professionalBalanceService->creditOrganizerBalance($identityId, null, $amount),
                'artist' => $this->professionalBalanceService->creditArtistBalance($identityId, null, $amount),
                'venue' => $this->professionalBalanceService->creditVenueBalance($identityId, null, $amount),
                default => throw new \RuntimeException('Unsupported withdrawal actor type.'),
            };

            IdentityBalanceTransaction::query()->create([
                'identity_id' => $identityId,
                'type' => 'credit',
                'amount' => $amount,
                'description' => 'Withdrawal refund',
                'reference_type' => 'withdrawal_refund',
                'reference_id' => (string) $withdrawal->id,
                'balance_before' => $result['pre_balance'] ?? 0,
                'balance_after' => $result['after_balance'] ?? 0,
                'meta' => [
                    'actor_type' => $withdrawal->actor_type,
                    'display_name' => $withdrawal->display_name,
                    'refunded_by_admin_id' => Auth::guard('admin')->id(),
                ],
            ]);

            return;
        }

        $walletService = app(\App\Services\WalletService::class);
        $walletService->credit(
            $withdrawal->customer,
            (float) $withdrawal->amount,
            'withdrawal_refund',
            $withdrawal->id,
            'WD-REFUND-' . $withdrawal->id
        );
    }

    private function withdrawalDisplayName(\App\Models\Wallet\WithdrawalRequest $withdrawal): string
    {
        if (!empty($withdrawal->display_name)) {
            return $withdrawal->display_name;
        }

        return $withdrawal->identity_id ? ucfirst((string) $withdrawal->actor_type) . ' wallet' : 'Personal wallet';
    }
}
