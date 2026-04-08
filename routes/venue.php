<?php

use Illuminate\Support\Facades\Route;

Route::prefix('/venue')->group(function () {
    Route::middleware('guest:venue', 'change.lang', 'adminLang')->group(function () {
        Route::get('/login', 'BackEnd\Venue\VenueController@login')->name('venue.login');
        // Venues are registered by admin, so no signup here for now
        Route::post('/store', 'BackEnd\Venue\VenueController@authentication')->name('venue.authentication');
        Route::get('/forget-password', 'BackEnd\Venue\VenueController@forget_password')->name('venue.forget.password');
        Route::post('/send-forget-mail', 'BackEnd\Venue\VenueController@forget_mail')->name('venue.forget.mail');
        Route::get('/reset-password', 'BackEnd\Venue\VenueController@reset_password')->name('venue.reset.password');
        Route::post('/update-forget-password', 'BackEnd\Venue\VenueController@update_password')->name('venue.update-forget-password');
    });

    Route::get('/logout', 'BackEnd\Venue\VenueController@logout')->name('venue.logout');
});

Route::prefix('/venue')->middleware('auth:venue', 'adminLang')->group(function () {
    Route::get('/dashboard', 'BackEnd\Venue\VenueController@index')->name('venue.dashboard');

    Route::get('/edit-profile', 'BackEnd\Venue\VenueController@edit_profile')->name('venue.edit.profile');
    Route::post('/update-profile', 'BackEnd\Venue\VenueController@update_profile')->name('venue.update_profile');
    Route::get('/change-password', 'BackEnd\Venue\VenueController@change_password')->name('venue.change.password');
    Route::post('/update-password', 'BackEnd\Venue\VenueController@updated_password')->name('venue.update_password');

    // Event Management for Venue
    Route::get('event-management/events/', 'BackEnd\Venue\EventController@index')->name('venue.event_management.event');
    Route::get('choose-event-type/', 'BackEnd\Venue\EventController@choose_event_type')->name('venue.choose-event-type');
    Route::get('add-event/', 'BackEnd\Venue\EventController@add_event')->name('venue.add.event.event');
    Route::post('event-imagesstore', 'BackEnd\Venue\EventController@gallerystore')->name('venue.event.imagesstore');
    Route::post('event-imagermv', 'BackEnd\Venue\EventController@imagermv')->name('venue.event.imagermv');
    Route::post('event-store', 'BackEnd\Venue\EventController@store')->name('venue.event_management.store_event');
    Route::post('/event/{id}/update-status', 'BackEnd\Venue\EventController@updateStatus')->name('venue.event_management.event.event_status');
    Route::post('/delete-event/{id}', 'BackEnd\Venue\EventController@destroy')->name('venue.event_management.delete_event');
    Route::get('/edit-event/{id}', 'BackEnd\Venue\EventController@edit')->name('venue.event_management.edit_event');
    Route::post('/event-update', 'BackEnd\Venue\EventController@update')->name('venue.event.update');
    Route::post('bulk/delete/event', 'BackEnd\Venue\EventController@bulk_delete')->name('venue.event_management.bulk_delete_event');

    // Income & Transactions
    Route::get('/monthly-income', 'BackEnd\Venue\VenueController@monthly_income')->name('venue.monthly_income');
    Route::get('/transactions', 'BackEnd\Venue\VenueController@transcation')->name('venue.transcation');

    // Booking Management
    Route::get('/event-bookings', 'BackEnd\Venue\BookingController@index')->name('venue.event.booking');
    Route::get('/event-booking/{id}/details', 'BackEnd\Venue\BookingController@details')->name('venue.event_booking.details');
    Route::get('/event-booking/report', 'BackEnd\Venue\BookingController@report')->name('venue.event_booking.report');

    // Withdrawals
    Route::get('/withdraw', 'BackEnd\Venue\WithdrawController@index')->name('venue.withdraw');
    Route::get('/withdraw/create', 'BackEnd\Venue\WithdrawController@create')->name('venue.withdraw.create');
    Route::post('/withdraw/store', 'BackEnd\Venue\WithdrawController@store')->name('venue.withdraw.store');

    // Support Tickets
    Route::get('/support-tickets', 'BackEnd\Venue\TicketController@index')->name('venue.support_tickets');
    Route::get('/support-tickets/{id}/messages', 'BackEnd\Venue\TicketController@messages')->name('venue.support_tickets.message');
    Route::get('/support-ticket/create', 'BackEnd\Venue\TicketController@create')->name('venue.support_ticket.create');
    Route::post('/support-ticket/store', 'BackEnd\Venue\TicketController@store')->name('venue.support_ticket.store');

    // PWA
    Route::get('/pwa-scanner', 'BackEnd\Venue\VenueController@pwa')->name('venue.pwa');

    // Common routes for helper data (cities, states etc)
    Route::get('all-country', 'BackEnd\Venue\EventController@getCountry')->name('venue.get_country');
    Route::get('all-state', 'BackEnd\Venue\EventController@searchSate')->name('venue.get_state');
    Route::get('all-city', 'BackEnd\Venue\EventController@getSearchCity')->name('venue.get_city');
    Route::get('get-state/', 'BackEnd\Venue\EventController@get_state')->name('venue.get.city.state');
    Route::get('get-cities/', 'BackEnd\Venue\EventController@getcities')->name('venue.get.cities.state');
});
