<?php

namespace App\Http\Controllers\BackEnd\Organizer;

use App\Http\Controllers\Controller;
use App\Models\Identity;
use App\Models\Venue;
use App\Services\ProfessionalCatalogBridgeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class VenueManagementController extends Controller
{
    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function index(Request $request)
    {
        $searchKey = $request->input('info');

        $venues = Venue::when($searchKey, function ($query, $searchKey) {
            return $query->where('name', 'like', '%' . $searchKey . '%')
                ->orWhere('email', 'like', '%' . $searchKey . '%');
        })
            ->orderBy('id', 'desc')
            ->paginate(10);

        $this->attachIdentityContextToVenues($venues->getCollection());

        return view('backend.end-user.venue.index', compact('venues'));
    }

    public function add()
    {
        return view('backend.end-user.venue.create');
    }

    public function create(Request $request)
    {
        $rules = [
            'name' => 'required',
            'username' => 'required|alpha_dash|unique:venues,username',
            'email' => 'required|email|unique:venues,email',
            'password' => 'required|min:6',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return Response::json([
                'errors' => $validator->getMessageBag()->toArray()
            ], 400);
        }

        $in = $request->all();
        $in['slug'] = Str::slug($request->name);
        $in['password'] = Hash::make($request->password);
        $in['email_verified_at'] = now();
        $in['status'] = 1;

        $file = $request->file('image');
        if ($file) {
            $extension = $file->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/venue/');
            $fileName = uniqid() . '.' . $extension;
            @mkdir($directory, 0775, true);
            $file->move($directory, $fileName);
            $in['image'] = $fileName;
        }

        Venue::create($in);

        Session::flash('success', 'Venue Added Successfully!');
        return Response::json(['status' => 'success'], 200);
    }

    public function edit($id)
    {
        $venue = Venue::findOrFail($id);
        $identityContext = $this->buildVenueIdentityContext($venue);

        return view('backend.end-user.venue.edit', compact('venue', 'identityContext'));
    }

    public function update(Request $request, $id)
    {
        $venue = Venue::findOrFail($id);

        $rules = [
            'name' => 'required',
            'username' => 'required|alpha_dash|unique:venues,username,' . $id,
            'email' => 'required|email|unique:venues,email,' . $id,
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return Response::json([
                'errors' => $validator->getMessageBag()->toArray()
            ], 400);
        }

        $in = $request->all();
        if ($request->filled('password')) {
            $in['password'] = Hash::make($request->password);
        } else {
            unset($in['password']);
        }

        $file = $request->file('image');
        if ($file) {
            $extension = $file->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/venue/');
            $fileName = uniqid() . '.' . $extension;
            @mkdir($directory, 0775, true);
            $file->move($directory, $fileName);

            @unlink($directory . $venue->image);
            $in['image'] = $fileName;
        }

        $venue->update($in);

        Session::flash('success', 'Venue Updated Successfully!');
        return Response::json(['status' => 'success'], 200);
    }

    public function delete($id)
    {
        $venue = Venue::findOrFail($id);
        if ($venue->image != null) {
            @unlink(public_path('assets/admin/img/venue/') . $venue->image);
        }
        $venue->delete();

        return redirect()->back()->with('success', 'Venue deleted successfully!');
    }

    public function bulk_delete(Request $request)
    {
        $ids = $request->ids;

        foreach ($ids as $id) {
            $venue = Venue::findOrFail($id);
            if ($venue->image != null) {
                @unlink(public_path('assets/admin/img/venue/') . $venue->image);
                $venue->delete();
            }
        }

        Session::flash('success', 'Deleted Successfully');
        return Response::json(['status' => 'success'], 200);
    }

    public function show($id)
    {
        $venue = Venue::with('events')->findOrFail($id);
        $identityContext = $this->buildVenueIdentityContext($venue);

        return view('backend.end-user.venue.details', compact('venue', 'identityContext'));
    }

    private function attachIdentityContextToVenues($venues): void
    {
        $identityMap = $this->catalogBridge
            ->resolveIdentityMap('venue', $venues->pluck('id')->all())
            ->values();

        if ($identityMap->isNotEmpty()) {
            $identityMap = Identity::query()
                ->with('owner')
                ->whereIn('id', $identityMap->pluck('id')->all())
                ->get()
                ->keyBy(function (Identity $identity) {
                    return (string) ($this->catalogBridge->legacyIdForIdentity($identity, 'venue') ?? $identity->id);
                });
        }

        foreach ($venues as $venue) {
            $identity = $identityMap->get((string) $venue->id);
            $venue->linked_identity = $identity;
            $venue->identity_context = $this->formatIdentityContext($identity);
        }
    }

    private function buildVenueIdentityContext(Venue $venue): array
    {
        $identity = $this->catalogBridge->findIdentityForLegacy('venue', $venue->id);
        if ($identity) {
            $identity->loadMissing('owner');
        }

        return $this->formatIdentityContext($identity);
    }

    private function formatIdentityContext(?Identity $identity): array
    {
        $latestHistory = collect(data_get($identity?->meta, 'moderation_history', []))
            ->filter(fn ($entry) => is_array($entry))
            ->last();

        return [
            'identity' => $identity,
            'status' => $identity?->status,
            'status_label' => match ($identity?->status) {
                'pending' => 'Pending',
                'active' => 'Active',
                'rejected' => 'Rejected',
                'suspended' => 'Suspended',
                null => 'Not linked',
                default => ucfirst((string) $identity?->status),
            },
            'status_class' => match ($identity?->status) {
                'pending' => 'warning',
                'active' => 'success',
                'rejected' => 'danger',
                'suspended' => 'dark',
                null => 'secondary',
                default => 'secondary',
            },
            'owner_name' => trim((string) optional($identity?->owner)->first_name . ' ' . optional($identity?->owner)->last_name),
            'owner_email' => optional($identity?->owner)->email,
            'latest_action' => $latestHistory['action'] ?? null,
            'latest_action_at' => $latestHistory['at'] ?? null,
        ];
    }
}
