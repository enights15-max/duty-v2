<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\Venue;
use App\Services\ProfessionalBalanceService;
use App\Traits\HasIdentityActor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Transaction;
use App\Models\Language;
use DB;
use DateTime;

class VenueController extends Controller
{
    use HasIdentityActor;

    public function __construct(
        private ProfessionalBalanceService $professionalBalanceService
    ) {
    }

    public function login()
    {
        return view('frontend.venue.login');
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
            Auth::guard('venue')->attempt([
                'username' => $request->username,
                'password' => $request->password
            ])
        ) {
            $authVenue = Auth::guard('venue')->user();
            if ($authVenue->status == 0) {
                Auth::guard('venue')->logout();
                return redirect()->back()->with('alert', 'Your account is currently deactivated!');
            }
            return redirect()->route('venue.dashboard');
        } else {
            return redirect()->back()->with('alert', 'Oops, Username or password does not match!');
        }
    }

    public function index()
    {
        $venueId = Auth::guard('venue')->id();
        $information['total_events'] = Event::where('venue_id', $venueId)->whereNull('organizer_id')->count();
        $information['total_event_bookings'] = Booking::whereHas('event', function ($query) use ($venueId) {
            $query->where('venue_id', $venueId)->whereNull('organizer_id');
        })->count();
        $information['transcation_count'] = Transaction::where('venue_id', $venueId)->count();

        // Income of event bookings
        $eventBookingTotalIncomes = DB::table('bookings')
            ->select(DB::raw('month(created_at) as month'), DB::raw('sum(price) as total'))
            ->where('paymentStatus', '=', 'completed')
            ->groupBy('month')
            ->whereYear('created_at', '=', date('Y'))
            ->whereHas('event', function ($query) use ($venueId) {
                $query->where('venue_id', $venueId)->whereNull('organizer_id');
            })
            ->get();

        $TotalEventBookings = DB::table('bookings')
            ->select(DB::raw('month(created_at) as month'), DB::raw('count(id) as total'))
            ->where('paymentStatus', '=', 'completed')
            ->groupBy('month')
            ->whereYear('created_at', '=', date('Y'))
            ->whereHas('event', function ($query) use ($venueId) {
                $query->where('venue_id', $venueId)->whereNull('organizer_id');
            })
            ->get();

        $eventMonths = [];
        $eventIncomes = [];
        $totalBookings = [];

        for ($i = 1; $i <= 12; $i++) {
            $monthNum = $i;
            $dateObj = DateTime::createFromFormat('!m', $monthNum);
            $monthName = $dateObj->format('M');
            array_push($eventMonths, $monthName);

            $incomeFound = false;
            foreach ($eventBookingTotalIncomes as $eventIncomeInfo) {
                if ($eventIncomeInfo->month == $i) {
                    $incomeFound = true;
                    array_push($eventIncomes, $eventIncomeInfo->total);
                    break;
                }
            }
            if (!$incomeFound)
                array_push($eventIncomes, 0);

            $bookingFound = false;
            foreach ($TotalEventBookings as $eventInfo) {
                if ($eventInfo->month == $i) {
                    $bookingFound = true;
                    array_push($totalBookings, $eventInfo->total);
                    break;
                }
            }
            if (!$bookingFound)
                array_push($totalBookings, 0);
        }

        $information['eventIncomes'] = $eventIncomes;
        $information['eventMonths'] = $eventMonths;
        $information['totalBookings'] = $totalBookings;
        $information['admin_setting'] = DB::table('basic_settings')->where('uniqid', 12345)->select('venue_admin_approval', 'admin_approval_notice')->first();
        $information['defaultLang'] = Language::where('is_default', 1)->first();
        $information['settings'] = DB::table('basic_settings')->where('uniqid', 12345)->first();

        return view('venue.index', $information);
    }

    public function monthly_income(Request $request)
    {
        $venueId = Auth::guard('venue')->id();
        $year = $request->input('year', date('Y'));

        $monthWiseTotalIncomes = DB::table('transactions')->where('venue_id', $venueId)
            ->select(DB::raw('month(created_at) as month'), DB::raw('sum(grand_total) as total'))
            ->where(function ($query) {
                return $query->where('transcation_type', 1)->orWhere('transcation_type', 4);
            })
            ->where('payment_status', 1)
            ->groupBy('month')
            ->whereYear('created_at', '=', $year)
            ->get();

        $months = [];
        $incomes = [];
        for ($i = 1; $i <= 12; $i++) {
            $dateObj = DateTime::createFromFormat('!m', $i);
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

        return view('venue.income', compact('months', 'incomes'));
    }

    public function transcation(Request $request)
    {
        $transcation_id = $request->input('transcation_id');
        $transcations = Transaction::where('venue_id', Auth::guard('venue')->id())
            ->when($transcation_id, function ($query) use ($transcation_id) {
                return $query->where('transcation_id', 'like', '%' . $transcation_id . '%');
            })
            ->orderBy('id', 'desc')->paginate(10);
        return view('venue.transaction', compact('transcations'));
    }

    public function pwa()
    {
        return view('venue.pwa.index');
    }

    public function logout()
    {
        Auth::guard('venue')->logout();
        return redirect()->route('venue.login');
    }

    public function edit_profile()
    {
        $venue = Auth::guard('venue')->user();
        return view('venue.edit-profile', compact('venue'));
    }

    public function update_profile(Request $request)
    {
        $venue = Auth::guard('venue')->user();
        $rules = [
            'name' => 'required',
            'email' => 'required|email|unique:venues,email,' . $venue->id,
            'username' => 'required|unique:venues,username,' . $venue->id,
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }

        $in = $request->all();
        if ($request->hasFile('image')) {
            $img = $request->file('image');
            $filename = time() . '.' . $img->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/venue/');
            @mkdir($directory, 0775, true);
            $img->move($directory, $filename);

            if ($venue->image != null) {
                @unlink($directory . $venue->image);
            }
            $in['image'] = $filename;
        }

        $venue->update($in);
        Session::flash('success', 'Profile updated successfully!');
        return redirect()->back();
    }

    public function change_password()
    {
        return view('venue.change-password');
    }

    public function updated_password(Request $request)
    {
        $rules = [
            'current_password' => 'required',
            'new_password' => 'required|confirmed|min:6',
        ];

        $venue = Auth::guard('venue')->user();

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator);
        }

        if (!Hash::check($request->current_password, $venue->password)) {
            return redirect()->back()->withErrors(['current_password' => 'Current password does not match!']);
        }

        $venue->update([
            'password' => Hash::make($request->new_password)
        ]);

        Session::flash('success', 'Password updated successfully!');
        return redirect()->back();
    }

    public function changeTheme(Request $request)
    {
        $venue = Auth::guard('venue')->user();
        // theme_version column may not exist on all deployments; guard with try/catch
        try {
            Venue::where('id', $venue->id)->update(['theme_version' => $request->theme_version]);
        } catch (\Throwable $e) {
            // silently ignore if column does not exist
        }
        return redirect()->back();
    }
}
