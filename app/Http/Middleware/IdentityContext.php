<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use App\Models\Identity;
use App\Models\IdentityMember;

class IdentityContext
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse|\Illuminate\Http\JsonResponse)  $next
     * @param  string|null  $required (if 'required', the header is mandatory)
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse|\Illuminate\Http\JsonResponse
     */
    public function handle(Request $request, Closure $next, $required = null)
    {
        $identityId = $request->header('X-Identity-Id');
        $user = $request->user();

        if ($identityId && $user) {
            $identity = Identity::where('id', $identityId)
                ->where('status', 'active')
                ->whereHas('members', function ($query) use ($user) {
                    $query->where('user_id', $user->id)
                        ->where('status', 'active');
                })
                ->first();

            if ($identity) {
                // Attach identity to request
                $request->merge(['active_identity' => $identity]);

                // Also get the member record for role check later if needed
                $member = IdentityMember::where('identity_id', $identity->id)
                    ->where('user_id', $user->id)
                    ->first();
                $request->merge(['identity_member' => $member]);

                // Compatibility Injection: Inject legacy IDs if available in meta
                if ($identity->type === 'organizer' && isset($identity->meta['id'])) {
                    $request->merge(['organizer_id_actor' => $identity->meta['id']]);
                }
                if ($identity->type === 'venue' && isset($identity->meta['id'])) {
                    $request->merge(['venue_id_actor' => $identity->meta['id']]);
                }

                return $next($request);
            }

            if ($required === 'required') {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Invalid or inactive identity context.'
                ], 403);
            }
        }

        if ($required === 'required' && !$identityId) {
            return response()->json([
                'status' => 'error',
                'message' => 'X-Identity-Id header is required for this action.'
            ], 403);
        }

        return $next($request);
    }
}
