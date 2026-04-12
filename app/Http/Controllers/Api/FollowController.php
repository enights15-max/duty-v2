<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artist;
use App\Models\Customer;
use App\Models\Follow;
use App\Models\Organizer;
use App\Models\Venue;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class FollowController extends Controller
{
    /**
     * Map type string to Eloquent class.
     */
    private function resolveClass(string $type): ?string
    {
        return match ($type) {
            'organizer' => Organizer::class,
            'venue'     => Venue::class,
            'artist'    => Artist::class,
            'customer'  => Customer::class,
            default     => null,
        };
    }

    public function follow(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $validator = Validator::make($request->all(), [
            'id'   => 'required|integer',
            'type' => 'required|in:organizer,venue,artist,customer',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $followableClass = $this->resolveClass($request->type);

        // For customer-to-customer follows we need the target to check privacy
        $status = 'accepted';
        if ($request->type === 'customer') {
            $followable = Customer::find($request->id);
            if (!$followable) {
                return response()->json(['success' => false, 'message' => 'User not found.'], 404);
            }
            if ($followable->id === $customer->id) {
                return response()->json(['success' => false, 'message' => 'Cannot follow yourself.'], 422);
            }
            if (!empty($followable->is_private)) {
                $status = 'pending';
            }
        }

        $followableId = (int) $request->id;

        $follow = Follow::firstOrCreate(
            [
                'follower_id'    => $customer->id,
                'follower_type'  => Customer::class,
                'followable_id'  => $followableId,
                'followable_type' => $followableClass,
            ],
            ['status' => $status]
        );

        $count = Follow::where('followable_id', $followableId)
            ->where('followable_type', $followableClass)
            ->where('status', 'accepted')
            ->count();

        return response()->json([
            'success'          => true,
            'message'          => $follow->wasRecentlyCreated
                ? ($status === 'pending' ? 'Follow request sent.' : 'Followed successfully.')
                : 'Already following.',
            'followers_count'  => $count,
            'is_followed'      => $follow->status === 'accepted',
            'is_pending'       => $follow->status === 'pending',
        ]);
    }

    public function unfollow(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $validator = Validator::make($request->all(), [
            'id'   => 'required|integer',
            'type' => 'required|in:organizer,venue,artist,customer',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $followableClass = $this->resolveClass($request->type);

        Follow::where([
            'follower_id'    => $customer->id,
            'follower_type'  => Customer::class,
            'followable_id'  => $request->id,
            'followable_type' => $followableClass,
        ])->delete();

        $count = Follow::where('followable_id', $request->id)
            ->where('followable_type', $followableClass)
            ->where('status', 'accepted')
            ->count();

        return response()->json([
            'success'         => true,
            'message'         => 'Unfollowed successfully.',
            'followers_count' => $count,
            'is_followed'     => false,
        ]);
    }

    /**
     * GET /api/follows/requests
     * Returns pending follow requests directed at the authenticated user.
     */
    public function getPendingRequests()
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $requests = Follow::where('followable_id', $customer->id)
            ->where('followable_type', Customer::class)
            ->where('status', 'pending')
            ->with('follower')
            ->orderBy('created_at', 'desc')
            ->get();

        $data = $requests->map(function (Follow $follow) {
            $requester = $follow->follower;
            if (!$requester) {
                return null;
            }

            return [
                'request_id' => $follow->id,
                'user' => [
                    'id'       => $requester->id,
                    'name'     => trim(($requester->fname ?? '') . ' ' . ($requester->lname ?? '')),
                    'username' => $requester->username ?? '',
                    'photo'    => $requester->photo
                        ? asset('assets/admin/img/customer-profile/' . $requester->photo)
                        : null,
                ],
                'created_at' => $follow->created_at?->toIso8601String(),
            ];
        })->filter()->values();

        return response()->json(['success' => true, 'data' => $data]);
    }

    /**
     * POST /api/follows/requests/{id}/accept
     */
    public function acceptRequest(int $id)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $follow = Follow::where('id', $id)
            ->where('followable_id', $customer->id)
            ->where('followable_type', Customer::class)
            ->where('status', 'pending')
            ->first();

        if (!$follow) {
            return response()->json(['success' => false, 'message' => 'Request not found.'], 404);
        }

        $follow->update(['status' => 'accepted']);

        return response()->json(['success' => true, 'message' => 'Follow request accepted.']);
    }

    /**
     * POST /api/follows/requests/{id}/reject
     */
    public function rejectRequest(int $id)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $follow = Follow::where('id', $id)
            ->where('followable_id', $customer->id)
            ->where('followable_type', Customer::class)
            ->where('status', 'pending')
            ->first();

        if (!$follow) {
            return response()->json(['success' => false, 'message' => 'Request not found.'], 404);
        }

        $follow->delete();

        return response()->json(['success' => true, 'message' => 'Follow request rejected.']);
    }
}
