<?php

namespace App\Http\Controllers\BackEnd\Artist;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use App\Models\Event;
use App\Traits\HasIdentityActor;
use DB;

class ArtistController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService
    ) {
    }

    public function login()
    {
        return view('frontend.artist.login');
    }

    public function authentication(Request $request)
    {
        $rules = [
            'username' => 'required',
            'password' => 'required'
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator->errors());
        }

        if (
            Auth::guard('artist')->attempt([
                'username' => $request->username,
                'password' => $request->password
            ])
        ) {
            $authArtist = Auth::guard('artist')->user();
            if ($authArtist->status == 0) {
                Auth::guard('artist')->logout();
                return redirect()->back()->with('alert', 'Your account is currently deactivated!');
            }
            return redirect()->route('artist.dashboard');
        } else {
            return redirect()->back()->with('alert', 'Oops, Username or password does not match!');
        }
    }

    public function index()
    {
        $artistId = $this->getArtistId();
        $information['total_events'] = DB::table('event_artist')->where('artist_id', $artistId)->count();
        $information['total_followers'] = \App\Models\Follower::where('following_id', $artistId)
            ->where('following_type', Artist::class)
            ->count();

        return view('artist.index', $information);
    }

    public function monthly_income(Request $request)
    {
        $artistId = $this->getArtistId();
        $year = $request->input('year', date('Y'));

        $monthWiseTotalIncomes = DB::table('transactions')->where('artist_id', $artistId)
            ->select(DB::raw('month(created_at) as month'), DB::raw('sum(grand_total) as total'))
            ->where('payment_status', 1)
            ->groupBy('month')
            ->whereYear('created_at', '=', $year)
            ->get();

        $months = [];
        $incomes = [];
        for ($i = 1; $i <= 12; $i++) {
            $dateObj = \DateTime::createFromFormat('!m', $i);
            array_push($months, $dateObj->format('M'));
            $found = false;
            foreach ($monthWiseTotalIncomes as $income) {
                if ($income->month == $i) {
                    array_push($incomes, $income->total);
                    $found = true;
                    break;
                }
            }
            if (!$found)
                array_push($incomes, 0);
        }

        return view('artist.income', compact('months', 'incomes'));
    }

    public function transcation(Request $request)
    {
        $transcation_id = $request->input('transcation_id');
        $transcations = \App\Models\Transaction::where('artist_id', $this->getArtistId())
            ->when($transcation_id, function ($query) use ($transcation_id) {
                return $query->where('transcation_id', 'like', '%' . $transcation_id . '%');
            })
            ->orderBy('id', 'desc')->paginate(10);
        return view('artist.transaction', compact('transcations'));
    }

    public function balance_calculation($method, $amount)
    {
        $artist = Auth::guard('artist')->user();
        if ($artist->amount < $amount) {
            return 'error';
        }
        $method = \App\Models\WithdrawPaymentMethod::find($method);
        $fixed_charge = $method->fixed_charge;
        $percentage = $method->percentage_charge;

        $percentage_balance = (($amount - $fixed_charge) * $percentage) / 100;

        $total_charge = $percentage_balance + $fixed_charge;
        $receive_balance = $amount - $total_charge;
        $user_balance = $artist->amount - $amount;

        return ['total_charge' => round($total_charge, 2), 'receive_balance' => round($receive_balance, 2), 'user_balance' => round($user_balance, 2)];
    }

    public function logout()
    {
        Auth::guard('artist')->logout();
        return redirect()->route('artist.login');
    }

    public function edit_profile()
    {
        $artist = Artist::find($this->getArtistId());
        return view('artist.edit-profile', compact('artist'));
    }

    public function update_profile(Request $request)
    {
        $artist = Artist::find($this->getArtistId());
        $rules = [
            'name' => 'required',
            'email' => 'required|email|unique:artists,email,' . $artist->id,
            'username' => 'required|unique:artists,username,' . $artist->id,
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $in = $request->all();
        if ($request->hasFile('photo')) {
            $img = $request->file('photo');
            $filename = time() . '.' . $img->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/artist/');
            @mkdir($directory, 0775, true);
            $img->move($directory, $filename);

            if ($artist->photo != null) {
                @unlink($directory . $artist->photo);
            }
            $in['photo'] = $filename;
        }

        $artist->update($in);
        Session::flash('success', 'Profile updated successfully!');
        return redirect()->back();
    }

    public function change_password()
    {
        return view('artist.change-password');
    }

    public function updated_password(Request $request)
    {
        $rules = [
            'current_password' => 'required',
            'new_password' => 'required|confirmed|min:6',
        ];

        $artist = Auth::guard('artist')->user();

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator);
        }

        if (!Hash::check($request->current_password, $artist->password)) {
            return redirect()->back()->withErrors(['current_password' => 'Current password does not match!']);
        }

        $artist->update([
            'password' => Hash::make($request->new_password)
        ]);

        Session::flash('success', 'Password updated successfully!');
        return redirect()->back();
    }
}
