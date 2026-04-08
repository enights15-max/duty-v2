<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Models\Customer;
use App\Models\Organizer;
use App\Models\Venue;
use App\Models\Artist;
use App\Models\Identity;
use App\Models\IdentityMember;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class MigrateIdentities extends Command
{
    protected $signature = 'identity:migrate';
    protected $description = 'Migrate existing users and entities to the new Identity system';

    public function handle()
    {
        $this->info('Starting identity migration...');

        DB::transaction(function () {
            // 1. Migrate Customers to Users (if not already there)
            $this->migrateCustomersToUsers();

            // 2. Create Personal Identities for all Users
            $this->createPersonalIdentities();

            // 3. Map existing Organizers, Venues, Artists to Identities
            $this->mapExistingEntitiesToIdentities();

            // 4. Update existing Events to point to new Identities
            $this->updateEventIdentities();
        });

        $this->info('Migration completed successfully.');
    }

    protected function migrateCustomersToUsers()
    {
        $this->comment('Migrating customers to users table...');
        $customers = Customer::all();

        foreach ($customers as $customer) {
            $user = User::where('email', $customer->email)->first();

            if (!$user) {
                $user = User::create([
                    'first_name' => $customer->fname ?? 'User',
                    'last_name' => $customer->lname ?? '',
                    'username' => $customer->username,
                    'email' => $customer->email,
                    'password' => $customer->password,
                    'contact_number' => $customer->phone,
                    'address' => $customer->address,
                    'city' => $customer->city,
                    'state' => $customer->state,
                    'country' => $customer->country,
                    'status' => $customer->status == 1 ? 1 : 0,
                    'email_verified_at' => $customer->email_verified_at,
                ]);
            }

            // Link customer to user (we might need a customer_id in users if we want to reverse map, 
            // but for now we follow the "standardize on users" plan)
        }
    }

    protected function createPersonalIdentities()
    {
        $this->comment('Creating personal identities for all users...');
        $users = User::all();

        foreach ($users as $user) {
            $existing = Identity::where('owner_user_id', $user->id)
                ->where('type', 'personal')
                ->first();

            if (!$existing) {
                $displayName = trim($user->first_name . ' ' . $user->last_name);
                if (empty($displayName))
                    $displayName = $user->username;

                $identity = Identity::create([
                    'type' => 'personal',
                    'status' => 'active',
                    'owner_user_id' => $user->id,
                    'display_name' => $displayName,
                    'slug' => $this->generateUniqueSlug($displayName, 'identities'),
                    'meta' => [
                        'country' => $user->country,
                        'city' => $user->city,
                    ],
                ]);

                IdentityMember::create([
                    'identity_id' => $identity->id,
                    'user_id' => $user->id,
                    'role' => 'owner',
                    'status' => 'active',
                ]);
            }
        }
    }

    protected function mapExistingEntitiesToIdentities()
    {
        // Organizers
        $this->comment('Mapping organizers to identities...');
        foreach (Organizer::all() as $org) {
            $user = User::where('email', $org->email)->first();
            if ($user) {
                $this->createIdentityFromModel($org, 'organizer', $user);
            }
        }

        // Venues
        $this->comment('Mapping venues to identities...');
        foreach (Venue::all() as $venue) {
            $user = User::where('email', $venue->email)->first();
            if ($user) {
                $this->createIdentityFromModel($venue, 'venue', $user);
            }
        }

        // Artists
        $this->comment('Mapping artists to identities...');
        foreach (Artist::all() as $artist) {
            $user = User::where('email', $artist->email)->first();
            if ($user) {
                $this->createIdentityFromModel($artist, 'artist', $user);
            }
        }
    }

    protected function createIdentityFromModel($model, $type, $user)
    {
        $existing = Identity::where('owner_user_id', $user->id)
            ->where('type', $type)
            ->where('display_name', $model->name ?? $model->username)
            ->first();

        if (!$existing) {
            $displayName = $model->name ?? $model->username;

            $identity = Identity::create([
                'type' => $type,
                'status' => $model->status == 1 ? 'active' : 'pending',
                'owner_user_id' => $user->id,
                'display_name' => $displayName,
                'slug' => $model->slug ?? $this->generateUniqueSlug($displayName, 'identities'),
                'meta' => $model->toArray(), // Map all existing fields to meta
            ]);

            IdentityMember::create([
                'identity_id' => $identity->id,
                'user_id' => $user->id,
                'role' => 'owner',
                'status' => 'active',
            ]);
        }
    }

    protected function updateEventIdentities()
    {
        $this->comment('Updating events with new identity IDs...');
        $events = \App\Models\Event::all();

        foreach ($events as $event) {
            $updated = false;

            if ($event->organizer_id) {
                $identity = Identity::where('type', 'organizer')
                    ->where('meta->id', $event->organizer_id)
                    ->first();
                if ($identity) {
                    $event->owner_identity_id = $identity->id;
                    $updated = true;
                }
            }

            if ($event->venue_id) {
                $identity = Identity::where('type', 'venue')
                    ->where('meta->id', $event->venue_id)
                    ->first();
                if ($identity) {
                    $event->venue_identity_id = $identity->id;
                    $updated = true;
                }
            }

            if ($updated) {
                $event->save();
            }
        }
    }

    protected function generateUniqueSlug($title, $table)
    {
        $slug = Str::slug($title);
        $count = DB::table($table)->where('slug', 'LIKE', "{$slug}%")->count();
        return $count ? "{$slug}-{$count}" : $slug;
    }
}
