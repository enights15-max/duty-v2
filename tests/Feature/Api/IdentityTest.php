<?php

namespace Tests\Feature\Api;

use Tests\TestCase;
use App\Models\User;
use App\Models\Identity;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class IdentityTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_list_their_identities()
    {
        $user = User::factory()->create();
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
        $user = User::factory()->create();
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
                'capacity' => 500
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
        $admin = User::factory()->create(['is_admin' => 1]); // Assuming 1 is superadmin
        Sanctum::actingAs($admin);

        $user = User::factory()->create();
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
}
