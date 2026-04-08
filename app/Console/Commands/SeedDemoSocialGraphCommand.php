<?php

namespace App\Console\Commands;

use App\Models\Customer;
use App\Models\Follow;
use App\Models\Identity;
use App\Models\IdentityMember;
use App\Models\User;
use App\Services\IdentityLegacyMirrorService;
use Illuminate\Console\Command;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class SeedDemoSocialGraphCommand extends Command
{
    protected $signature = 'demo:seed-social-graph
        {--count=10 : Number of demo users to create}
        {--owner-email=gian@monkey.com.do : Email of the main test account}
        {--password=DutyDemo123! : Password to assign to demo users}';

    protected $description = 'Create demo users and build a dense social follow graph around a main account and its professional profiles.';

    private const DEMO_AVATAR_FILENAME = 'demo-social-avatar.jpg';

    public function handle(IdentityLegacyMirrorService $mirrorService): int
    {
        $count = max(1, (int) $this->option('count'));
        $ownerEmail = trim((string) $this->option('owner-email'));
        $password = (string) $this->option('password');

        /** @var Customer|null $ownerCustomer */
        $ownerCustomer = Customer::query()
            ->where('email', $ownerEmail)
            ->orWhere('username', 'gianvald')
            ->first();

        if (!$ownerCustomer) {
            $this->error("No encontré el customer principal para {$ownerEmail}.");
            return self::FAILURE;
        }

        /** @var User|null $ownerUser */
        $ownerUser = User::query()
            ->where('email', $ownerCustomer->email)
            ->first();

        if (!$ownerUser) {
            $this->error("No encontré el user base asociado a {$ownerCustomer->email}.");
            return self::FAILURE;
        }

        $mirrorService->syncOwnerProfessionalIdentities((int) $ownerUser->id);

        $professionalTargets = $this->resolveProfessionalTargets((int) $ownerUser->id);
        $demoAvatar = $this->ensureDemoAvatar();

        $createdUsers = collect();

        DB::transaction(function () use (
            $count,
            $password,
            $ownerCustomer,
            $createdUsers,
            $professionalTargets,
            $demoAvatar,
        ): void {
            $demoCustomers = collect();

            for ($i = 1; $i <= $count; $i++) {
                $profile = $this->demoProfileFor($i);
                $username = $profile['username'];
                $email = $profile['email'];

                $user = User::query()->updateOrCreate(
                    ['email' => $email],
                    [
                        'first_name' => $profile['first_name'],
                        'last_name' => $profile['last_name'],
                        'username' => $username,
                        'password' => Hash::make($password),
                        'status' => 1,
                    ]
                );

                $customer = Customer::query()->updateOrCreate(
                    ['email' => $email],
                    [
                        'fname' => $profile['first_name'],
                        'lname' => $profile['last_name'],
                        'username' => $username,
                        'password' => Hash::make($password),
                        'status' => 1,
                        'is_private' => 0,
                        'show_interested_events' => 1,
                        'show_attended_events' => 1,
                        'show_upcoming_attendance' => 1,
                        'email_verified_at' => now(),
                        'photo' => $demoAvatar,
                    ]
                );

                $identity = Identity::query()->updateOrCreate(
                    [
                        'owner_user_id' => $user->id,
                        'type' => 'personal',
                    ],
                    [
                        'status' => 'active',
                        'display_name' => trim($profile['first_name'] . ' ' . $profile['last_name']),
                        'slug' => $this->uniqueIdentitySlug($username, $user->id),
                        'meta' => [
                            'display_name' => trim($profile['first_name'] . ' ' . $profile['last_name']),
                            'country' => 'Dominican Republic',
                            'city' => 'Santo Domingo',
                            'photo' => $demoAvatar,
                        ],
                    ]
                );

                IdentityMember::query()->updateOrCreate(
                    [
                        'identity_id' => $identity->id,
                        'user_id' => $user->id,
                    ],
                    [
                        'role' => 'owner',
                        'permissions' => null,
                        'status' => 'active',
                    ]
                );

                $demoCustomers->push($customer);
                $createdUsers->push([
                    'name' => trim($customer->fname . ' ' . $customer->lname),
                    'username' => '@' . $customer->username,
                    'email' => $customer->email,
                ]);
            }

            $networkCustomers = $demoCustomers
                ->push($ownerCustomer)
                ->unique('id')
                ->values();

            $this->createMutualCustomerFollows($networkCustomers);
            $this->followProfessionalTargets($demoCustomers, $professionalTargets);
        });

        $counts = $this->buildCountsSummary($ownerCustomer, $professionalTargets);

        $this->info('Usuarios demo creados y red social sembrada.');
        $this->line('Password demo: ' . $password);
        $this->newLine();
        $this->table(
            ['Nombre', 'Username', 'Email'],
            $createdUsers->all()
        );
        $this->newLine();
        $this->table(
            ['Target', 'Followers'],
            $counts
        );

        return self::SUCCESS;
    }

    private function createMutualCustomerFollows(Collection $customers): void
    {
        foreach ($customers as $follower) {
            foreach ($customers as $target) {
                if ((int) $follower->id === (int) $target->id) {
                    continue;
                }

                Follow::query()->firstOrCreate(
                    [
                        'follower_type' => Customer::class,
                        'follower_id' => $follower->id,
                        'followable_type' => Customer::class,
                        'followable_id' => $target->id,
                    ],
                    [
                        'status' => 'accepted',
                    ]
                );
            }
        }
    }

    private function followProfessionalTargets(Collection $demoCustomers, array $targets): void
    {
        foreach ($demoCustomers as $customer) {
            foreach ($targets as $target) {
                if (!$target['id'] || !$target['type']) {
                    continue;
                }

                Follow::query()->firstOrCreate(
                    [
                        'follower_type' => Customer::class,
                        'follower_id' => $customer->id,
                        'followable_type' => $target['type'],
                        'followable_id' => $target['id'],
                    ],
                    [
                        'status' => 'accepted',
                    ]
                );
            }
        }
    }

    private function resolveProfessionalTargets(int $ownerUserId): array
    {
        $targets = [];

        $identities = Identity::query()
            ->where('owner_user_id', $ownerUserId)
            ->whereIn('type', ['artist', 'venue', 'organizer'])
            ->where('status', 'active')
            ->get();

        foreach ($identities as $identity) {
            $meta = is_array($identity->meta) ? $identity->meta : [];
            $legacyId = (int) ($meta['legacy_id'] ?? $meta['id'] ?? 0);

            if ($legacyId <= 0) {
                continue;
            }

            $targets[] = match ($identity->type) {
                'artist' => ['label' => 'Artist: ' . $identity->display_name, 'type' => \App\Models\Artist::class, 'id' => $legacyId],
                'venue' => ['label' => 'Venue: ' . $identity->display_name, 'type' => \App\Models\Venue::class, 'id' => $legacyId],
                'organizer' => ['label' => 'Organizer: ' . $identity->display_name, 'type' => \App\Models\Organizer::class, 'id' => $legacyId],
                default => null,
            };
        }

        return array_values(array_filter($targets));
    }

    private function buildCountsSummary(Customer $ownerCustomer, array $professionalTargets): array
    {
        $rows = [
            [
                'Target' => 'Personal: @' . $ownerCustomer->username,
                'Followers' => Follow::query()
                    ->where('followable_type', Customer::class)
                    ->where('followable_id', $ownerCustomer->id)
                    ->where('status', 'accepted')
                    ->count(),
            ],
        ];

        foreach ($professionalTargets as $target) {
            $rows[] = [
                'Target' => $target['label'],
                'Followers' => Follow::query()
                    ->where('followable_type', $target['type'])
                    ->where('followable_id', $target['id'])
                    ->where('status', 'accepted')
                    ->count(),
            ];
        }

        $rows[] = [
            'Target' => 'Total follows',
            'Followers' => Follow::query()->count(),
        ];

        return $rows;
    }

    private function uniqueIdentitySlug(string $username, int $userId): string
    {
        $base = Str::slug($username);
        $slug = $base !== '' ? $base : 'demo-user-' . $userId;
        $candidate = $slug;
        $suffix = 2;

        while (Identity::query()
            ->where('slug', $candidate)
            ->where('owner_user_id', '!=', $userId)
            ->exists()) {
            $candidate = $slug . '-' . $suffix;
            $suffix++;
        }

        return $candidate;
    }

    private function ensureDemoAvatar(): string
    {
        $targetDirectory = public_path('assets/admin/img/customer-profile');
        $targetPath = $targetDirectory . DIRECTORY_SEPARATOR . self::DEMO_AVATAR_FILENAME;

        if (!File::exists($targetDirectory)) {
            File::makeDirectory($targetDirectory, 0755, true);
        }

        if (!File::exists($targetPath)) {
            $sourceCandidates = [
                public_path('assets/admin/img/profile.jpg'),
                public_path('assets/front/images/profile.jpg'),
                public_path('assets/admin/img/blank_user.jpg'),
            ];

            foreach ($sourceCandidates as $sourcePath) {
                if (!File::exists($sourcePath)) {
                    continue;
                }

                File::copy($sourcePath, $targetPath);
                break;
            }
        }

        return self::DEMO_AVATAR_FILENAME;
    }

    private function demoProfileFor(int $index): array
    {
        $profiles = [
            ['Ari', 'Nova'],
            ['Lia', 'Cruz'],
            ['Milo', 'Reyes'],
            ['Nina', 'Lopez'],
            ['Teo', 'Suarez'],
            ['Alma', 'Vega'],
            ['Ivo', 'Matos'],
            ['Cora', 'Santos'],
            ['Ezra', 'Pena'],
            ['Zoe', 'Castro'],
            ['Leo', 'Marte'],
            ['Mia', 'Rosario'],
        ];

        $pair = $profiles[($index - 1) % count($profiles)];
        $username = sprintf('demo%02dcrew', $index);

        return [
            'first_name' => $pair[0],
            'last_name' => $pair[1],
            'username' => $username,
            'email' => sprintf('demo.%02d@profiles.duty.local', $index),
        ];
    }
}
