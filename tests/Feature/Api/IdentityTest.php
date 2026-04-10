<?php

namespace Tests\Feature\Api;

use App\Models\User;
use App\Models\Identity;
use Laravel\Sanctum\Sanctum;
use Tests\Support\ActorFeatureTestCase;

class IdentityTest extends ActorFeatureTestCase
{
    protected array $baselineSchema = ['users_customers', 'identities'];
    protected array $baselineTruncate = [
        'identity_members',
        'identities',
        'users',
        'customers',
    ];

    public function test_user_can_list_their_identities()
    {
        $user = $this->createIdentityUser('john@example.com', 'john-doe');
        Sanctum::actingAs($user);

        // Personal identity should be created automatically (if you have observers/logic)
        // Or we create one manually for this test if your factory doesn't do it
        $identity = Identity::create([
            'type' => 'personal',
            'status' => 'active',
            'owner_user_id' => $user->id,
            'display_name' => 'John Doe',
            'slug' => 'john-doe'
        ]);
        $identity->members()->create(['user_id' => $user->id, 'role' => 'owner', 'status' => 'active']);

        $response = $this->getJson('/api/me/identities');

        $response->assertStatus(200)
            ->assertJsonFragment(['display_name' => 'John Doe']);
    }

    public function test_user_can_request_new_identity()
    {
        $user = $this->createIdentityUser('venue-owner@example.com', 'venue-owner');
        Sanctum::actingAs($user);

        $response = $this->postJson('/api/identities', [
            'type' => 'venue',
            'display_name' => 'The Great Hall',
            'meta' => [
                'legal_name' => 'Great Hall LLC',
                'contact_name' => 'Manager X',
                'contact_email' => 'manager@greathall.com',
                'contact_phone' => '123456789',
                'address_line' => '123 Event St',
                'city' => 'Metropolis',
                'country' => 'USA',
                'capacity' => 500,
                'whatsapp' => '123456789',
            ]
        ]);

        $response->assertStatus(201)
            ->assertJsonPath('status', 'success');

        $this->assertDatabaseHas('identities', [
            'display_name' => 'The Great Hall',
            'status' => 'pending'
        ]);
    }

    public function test_superadmin_can_approve_identity()
    {
        $admin = $this->createIdentityUser('admin@example.com', 'admin');
        Sanctum::actingAs($admin, [], 'admin_sanctum');

        $user = $this->createIdentityUser('identity-owner@example.com', 'identity-owner');
        $identity = Identity::create([
            'type' => 'organizer',
            'status' => 'pending',
            'owner_user_id' => $user->id,
            'display_name' => 'Event Pro',
            'slug' => 'event-pro',
            'meta' => ['contact_email' => 'test@test.com']
        ]);

        $response = $this->postJson("/api/admin/identities/{$identity->id}/approve");

        $response->assertStatus(200);
        $this->assertEquals('active', $identity->fresh()->status);
    }

    private function createIdentityUser(string $email, string $username): User
    {
        return User::query()->create([
            'email' => $email,
            'username' => $username,
            'first_name' => ucfirst(str_replace(['-', '_'], ' ', $username)),
            'password' => bcrypt('secret'),
            'status' => 1,
        ]);
    }
}
