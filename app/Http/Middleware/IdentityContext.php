<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use App\Models\Identity;
use App\Models\IdentityMember;
use App\Models\User;

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
        $memberUserIds = $this->resolveMemberUserIds($user);

        if ($identityId && $memberUserIds !== []) {
            $identity = Identity::where('id', $identityId)
                ->where('status', 'active')
                ->whereHas('members', function ($query) use ($memberUserIds) {
                    $query->whereIn('user_id', $memberUserIds)
                        ->where('status', 'active');
                })
                ->first();

            if ($identity) {
                // Attach identity to request
                $request->merge(['active_identity' => $identity]);

                // Also get the member record for role check later if needed
                $member = IdentityMember::where('identity_id', $identity->id)
                    ->whereIn('user_id', $memberUserIds)
                    ->first();
                $request->merge(['identity_member' => $member]);

                // Compatibility Injection: Inject legacy IDs if available in meta
                $legacyId = $this->resolveLegacyId($identity);
                if ($identity->type === 'organizer' && $legacyId !== null) {
                    $request->merge(['organizer_id_actor' => $legacyId]);
                }
                if ($identity->type === 'venue' && $legacyId !== null) {
                    $request->merge(['venue_id_actor' => $legacyId]);
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

    /**
     * @return array<int, int>
     */
    private function resolveMemberUserIds($user): array
    {
        if (!$user) {
            return [];
        }

        $ids = [];

        if ($user instanceof User) {
            $ids[] = (int) $user->id;
        }

        if (isset($user->user_id) && is_numeric((string) $user->user_id)) {
            $ids[] = (int) $user->user_id;
        }

        if (isset($user->email) && $user->email && Schema::hasTable('users')) {
            $matchedUserId = User::query()
                ->where('email', $user->email)
                ->value('id');

            if ($matchedUserId) {
                $ids[] = (int) $matchedUserId;
            }
        }

        return array_values(array_unique(array_filter($ids, fn ($id) => $id > 0)));
    }

    private function resolveLegacyId(Identity $identity): ?int
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];

        foreach (['legacy_id', 'id'] as $key) {
            if (isset($meta[$key]) && is_numeric((string) $meta[$key])) {
                return (int) $meta[$key];
            }
        }

        return null;
    }
}
