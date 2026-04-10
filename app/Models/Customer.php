<?php

namespace App\Models;

use App\Models\Event\Booking;
use App\Models\Event\Wishlist;
use App\Models\ShopManagement\OrderItem;
use App\Models\ShopManagement\ProductOrder;
use App\Models\ShopManagement\ProductReview;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Authenticatable as AuthenticatableContract;
use Laravel\Sanctum\HasApiTokens;


class Customer extends Model implements AuthenticatableContract
{
  use HasApiTokens, HasFactory, Authenticatable;
  protected $fillable = [
    'provider',
    'provider_id',
    'fname',
    'lname',
    'username',
    'email',
    'photo',
    'date_of_birth',
    'phone',
    'address',
    'country',
    'state',
    'city',
    'zip_code',
    'password',
    'gender',
    'firebase_uid',
    'is_private',
    'status',
    'email_verified_at',
    'phone_verified_at',
    'verification_token',
    'stripe_customer_id',
    'show_interested_events',
    'show_attended_events',
    'show_upcoming_attendance',
  ];

  protected $hidden = [
    'password',
    'remember_token',
    'two_factor_recovery_codes',
    'two_factor_secret',
  ];

  protected $casts = [
    'email_verified_at' => 'datetime',
    'phone_verified_at' => 'datetime',
    'is_private' => 'boolean',
    'show_interested_events' => 'boolean',
    'show_attended_events' => 'boolean',
    'show_upcoming_attendance' => 'boolean',
  ];

  protected $appends = ['age'];

  public function getAgeAttribute()
  {
    if ($this->date_of_birth) {
      return \Carbon\Carbon::parse($this->date_of_birth)->age;
    }
    return null;
  }

  //bookings
  public function bookings()
  {
    return $this->hasMany(Booking::class);
  }
  //order_items
  public function order_items()
  {
    return $this->hasMany(OrderItem::class, 'user_id', 'id');
  }
  //product_orders
  public function product_orders()
  {
    return $this->hasMany(ProductOrder::class, 'user_id', 'id');
  }
  //product_reviews
  public function product_reviews()
  {
    return $this->hasMany(ProductReview::class, 'user_id', 'id');
  }
  //support_tickets
  public function support_tickets()
  {
    return $this->hasMany(SupportTicket::class, 'user_id', 'id');
  }
  //wishlists
  public function wishlists()
  {
    return $this->hasMany(Wishlist::class, 'customer_id', 'id');
  }

  //following
  public function following()
  {
    return $this->hasMany(Follower::class, 'customer_id', 'id');
  }

  public function follows()
  {
    return $this->morphMany(Follow::class, 'follower');
  }

  public function followers()
  {
    return $this->morphMany(Follow::class, 'followable');
  }

  public function isFollowing($model): bool
  {
    return $this->follows()
      ->where('followable_id', $model->id)
      ->where('followable_type', get_class($model))
      ->where('status', 'accepted')
      ->exists();
  }

  public function hasPendingFollowRequest($model): bool
  {
    return $this->follows()
      ->where('followable_id', $model->id)
      ->where('followable_type', get_class($model))
      ->where('status', 'pending')
      ->exists();
  }

  /**
   * Get the payment methods for the customer.
   */
  public function paymentMethods()
  {
    return $this->hasMany(PaymentMethod::class, 'user_id', 'id');
  }
}
