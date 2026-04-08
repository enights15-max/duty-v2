<?php

namespace Database\Seeders;

use App\Models\Event;
use App\Models\Venue;
use App\Models\Event\EventContent;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class VenueDataMigrator extends Seeder
{
    public function run()
    {
        $events = Event::all();

        foreach ($events as $event) {
            $content = $event->information()->first(); // Get the first language content for location

            if ($content && !empty($content->address)) {
                // Try to find existing venue by name/address within the same city
                $venueName = $content->address; // Usually contains the venue name or address

                $venue = Venue::firstOrCreate(
                    [
                        'name' => $venueName,
                        'city' => $content->city,
                        'address' => $content->address
                    ],
                    [
                        'slug' => Str::slug($venueName) . '-' . uniqid(),
                        'state' => $content->state,
                        'country' => $content->country,
                        'zip_code' => $content->zip_code,
                        'latitude' => $event->latitude,
                        'longitude' => $event->longitude,
                        'status' => 1
                    ]
                );

                $event->venue_id = $venue->id;
                $event->save();
            }
        }
    }
}
