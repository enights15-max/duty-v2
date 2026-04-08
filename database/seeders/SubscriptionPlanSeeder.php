<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\SubscriptionPlan;

class SubscriptionPlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        SubscriptionPlan::updateOrCreate(
            ['name' => 'VIP Gold'],
            [
                'description' => 'Acceso exclusivo a preventas y lounge VIP.',
                'price' => 500.00,
                'currency' => 'DOP',
                'stripe_price_id' => 'price_test_gold_plan', // Placeholder for test mode
                'status' => 'active',
                'features' => [
                    'Preventas exclusivas',
                    'Acceso al Lounge VIP',
                    'Asientos preferenciales',
                    'Soporte prioritario'
                ]
            ]
        );

        SubscriptionPlan::updateOrCreate(
            ['name' => 'VIP Platinum'],
            [
                'description' => 'La experiencia máxima. Todo lo de Gold más acceso a Meet & Greets.',
                'price' => 1500.00,
                'currency' => 'DOP',
                'stripe_price_id' => 'price_test_platinum_plan', // Placeholder for test mode
                'status' => 'active',
                'features' => [
                    'Todo lo de Gold',
                    'Meet & Greets ilimitados',
                    'Bebidas gratis en eventos selectos',
                    'Badge de perfil especial'
                ]
            ]
        );
    }
}
