<?php

use Illuminate\Support\Facades\Route;

Route::prefix('/artist')->group(function () {
    Route::middleware('guest:artist', 'change.lang', 'adminLang')->group(function () {
        Route::get('/login', 'BackEnd\Artist\ArtistController@login')->name('artist.login');
        Route::post('/store', 'BackEnd\Artist\ArtistController@authentication')->name('artist.authentication');
        Route::get('/forget-password', 'BackEnd\Artist\ArtistController@forget_password')->name('artist.forget.password');
        Route::post('/send-forget-mail', 'BackEnd\Artist\ArtistController@forget_mail')->name('artist.forget.mail');
        Route::get('/reset-password', 'BackEnd\Artist\ArtistController@reset_password')->name('artist.reset.password');
        Route::post('/update-forget-password', 'BackEnd\Artist\ArtistController@update_password')->name('artist.update-forget-password');
    });

    Route::get('/logout', 'BackEnd\Artist\ArtistController@logout')->name('artist.logout');
});

Route::prefix('/artist')->middleware('auth:artist', 'adminLang')->group(function () {
    Route::get('/dashboard', 'BackEnd\Artist\ArtistController@index')->name('artist.dashboard');

    Route::get('/edit-profile', 'BackEnd\Artist\ArtistController@edit_profile')->name('artist.edit.profile');
    Route::post('/update-profile', 'BackEnd\Artist\ArtistController@update_profile')->name('artist.update_profile');
    Route::get('/change-password', 'BackEnd\Artist\ArtistController@change_password')->name('artist.change.password');
    Route::post('/update-password', 'BackEnd\Artist\ArtistController@updated_password')->name('artist.update_password');

    // Income & Transactions
    Route::get('/monthly-income', 'BackEnd\Artist\ArtistController@monthly_income')->name('artist.monthly_income');
    Route::get('/transactions', 'BackEnd\Artist\ArtistController@transcation')->name('artist.transcation');

    // Withdrawals
    Route::get('/withdraw', 'BackEnd\Artist\WithdrawController@index')->name('artist.withdraw');
    Route::get('/withdraw/create', 'BackEnd\Artist\WithdrawController@create')->name('artist.withdraw.create');
    Route::post('/withdraw/store', 'BackEnd\Artist\WithdrawController@store')->name('artist.withdraw.store');

    // Helper routes for withdrawals (mimicking organizer/venue structure)
    Route::get('/get-withdraw-method/input/{id}', 'BackEnd\Organizer\OrganizerWithdrawController@get_inputs')->name('artist.withdraw.get_inputs');
    Route::get('/withdraw/balance-calculation/{method}/{amount}', 'BackEnd\Artist\ArtistController@balance_calculation')->name('artist.withdraw.balance_calculation');
});
