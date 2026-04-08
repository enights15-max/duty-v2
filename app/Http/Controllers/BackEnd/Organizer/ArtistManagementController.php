<?php

namespace App\Http\Controllers\BackEnd\Organizer;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Identity;
use App\Services\ProfessionalCatalogBridgeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;

class ArtistManagementController extends Controller
{
    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function index(Request $request)
    {
        $searchKey = $request->input('info');

        $artists = Artist::when($searchKey, function ($query, $searchKey) {
            return $query->where('name', 'like', '%' . $searchKey . '%')
                ->orWhere('email', 'like', '%' . $searchKey . '%');
        })
            ->orderBy('id', 'desc')
            ->paginate(10);

        $this->attachIdentityContextToArtists($artists->getCollection());

        return view('backend.end-user.artist.index', compact('artists'));
    }

    public function add()
    {
        return view('backend.end-user.artist.create');
    }

    public function create(Request $request)
    {
        $rules = [
            'name' => 'required',
            'username' => 'required|alpha_dash|unique:artists,username',
            'email' => 'required|email|unique:artists,email',
            'password' => 'required|min:6',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return Response::json([
                'errors' => $validator->getMessageBag()->toArray()
            ], 400);
        }

        $in = $request->all();
        $in['password'] = Hash::make($request->password);
        $in['email_verified_at'] = now();
        $in['status'] = 1;

        $file = $request->file('photo');
        if ($file) {
            $extension = $file->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/artist/');
            $fileName = uniqid() . '.' . $extension;
            @mkdir($directory, 0775, true);
            $file->move($directory, $fileName);
            $in['photo'] = $fileName;
        }

        Artist::create($in);

        Session::flash('success', 'Artist Added Successfully!');
        return Response::json(['status' => 'success'], 200);
    }

    public function edit($id)
    {
        $artist = Artist::findOrFail($id);
        $identityContext = $this->buildArtistIdentityContext($artist);

        return view('backend.end-user.artist.edit', compact('artist', 'identityContext'));
    }

    public function update(Request $request, $id)
    {
        $artist = Artist::findOrFail($id);

        $rules = [
            'name' => 'required',
            'username' => 'required|alpha_dash|unique:artists,username,' . $id,
            'email' => 'required|email|unique:artists,email,' . $id,
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

        $file = $request->file('photo');
        if ($file) {
            $extension = $file->getClientOriginalExtension();
            $directory = public_path('assets/admin/img/artist/');
            $fileName = uniqid() . '.' . $extension;
            @mkdir($directory, 0775, true);
            $file->move($directory, $fileName);

            @unlink($directory . $artist->photo);
            $in['photo'] = $fileName;
        }

        $artist->update($in);

        Session::flash('success', 'Artist Updated Successfully!');
        return Response::json(['status' => 'success'], 200);
    }

    public function delete($id)
    {
        $artist = Artist::findOrFail($id);
        if ($artist->photo != null) {
            @unlink(public_path('assets/admin/img/artist/') . $artist->photo);
        }
        $artist->delete();

        return redirect()->back()->with('success', 'Artist deleted successfully!');
    }

    public function bulk_delete(Request $request)
    {
        $ids = $request->ids;

        foreach ($ids as $id) {
            $artist = Artist::findOrFail($id);
            if ($artist->photo != null) {
                @unlink(public_path('assets/admin/img/artist/') . $artist->photo);
                $artist->delete();
            }
        }

        Session::flash('success', 'Deleted Successfully');
        return Response::json(['status' => 'success'], 200);
    }

    private function attachIdentityContextToArtists($artists): void
    {
        $identityMap = $this->catalogBridge
            ->resolveIdentityMap('artist', $artists->pluck('id')->all())
            ->values();

        if ($identityMap->isNotEmpty()) {
            $identityMap = Identity::query()
                ->with('owner')
                ->whereIn('id', $identityMap->pluck('id')->all())
                ->get()
                ->keyBy(function (Identity $identity) {
                    return (string) ($this->catalogBridge->legacyIdForIdentity($identity, 'artist') ?? $identity->id);
                });
        }

        foreach ($artists as $artist) {
            $identity = $identityMap->get((string) $artist->id);
            $artist->linked_identity = $identity;
            $artist->identity_context = $this->formatIdentityContext($identity);
        }
    }

    private function buildArtistIdentityContext(Artist $artist): array
    {
        $identity = $this->catalogBridge->findIdentityForLegacy('artist', $artist->id);
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
