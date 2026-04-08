<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Follower;
use App\Models\Organizer;
use App\Models\Venue;
use App\Models\Artist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class FollowController extends Controller
{
    public function follow(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $rules = [
            'id' => 'required',
            'type' => 'required|in:organizer,venue,artist'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $type = $request->type;
        $id = $request->id;

        $following_type = '';
        if ($type == 'organizer') {
            $following_type = Organizer::class;
        } elseif ($type == 'venue') {
            $following_type = Venue::class;
        } elseif ($type == 'artist') {
            $following_type = Artist::class;
        }

        Follower::updateOrCreate([
            'customer_id' => $customer->id,
            'following_id' => $id,
            'following_type' => $following_type,
        ]);

        $count = Follower::where('following_id', $id)->where('following_type', $following_type)->count();

        return response()->json([
            'success' => true,
            'message' => 'Followed successfully',
            'followers_count' => $count,
            'is_followed' => true
        ]);
    }

    public function unfollow(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();
        if (!$customer) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        $rules = [
            'id' => 'required',
            'type' => 'required|in:organizer,venue,artist'
        ];

        $validator = Validator::make($request->all(), $rules);
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $type = $request->type;
        $id = $request->id;

        $following_type = '';
        if ($type == 'organizer') {
            $following_type = Organizer::class;
        } elseif ($type == 'venue') {
            $following_type = Venue::class;
        } elseif ($type == 'artist') {
            $following_type = Artist::class;
        }

        Follower::where([
            'customer_id' => $customer->id,
            'following_id' => $id,
            'following_type' => $following_type,
        ])->delete();

        $count = Follower::where('following_id', $id)->where('following_type', $following_type)->count();

        return response()->json([
            'success' => true,
            'message' => 'Unfollowed successfully',
            'followers_count' => $count,
            'is_followed' => false
        ]);
    }
}
