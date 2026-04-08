<?php

namespace App\Models\Event;

use App\Models\Event;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;


class Ticket extends Model
{
  use HasFactory;

  protected $fillable = [
    'event_id',
    'event_type',
    'title',
    'ticket_available_type',
    'ticket_available',
    'max_ticket_buy_type',
    'max_buy_ticket',
    'description',
    'pricing_type',
    'price',
    'f_price',
    'early_bird_discount_type',
    'early_bird_discount',
    'early_bird_discount_amount',

    'early_bird_discount_date',
    'early_bird_discount_time',
    'variations',
    'trans_vars',

    'normal_ticket_slot_enable',
    'normal_ticket_slot_unique_id',

    'free_tickete_slot_enable',
    'free_tickete_slot_unique_id',

    'slot_seat_min_price',
    'reservation_enabled',
    'reservation_deposit_type',
    'reservation_deposit_value',
    'reservation_final_due_date',
    'reservation_min_installment_amount',
    'allow_promotional_resale',
    'sale_status',
    'archived_at',
    'gate_ticket_id',
    'gate_trigger',
    'gate_trigger_date',
  ];

  protected $casts = [
    'archived_at' => 'datetime',
    'gate_trigger_date' => 'datetime',
    'reservation_enabled' => 'boolean',
    'allow_promotional_resale' => 'boolean',
    'reservation_deposit_value' => 'float',
    'reservation_min_installment_amount' => 'float',
    'price' => 'float',
    'f_price' => 'float',
    'early_bird_discount_amount' => 'float',
  ];

  public function event()
  {
    return $this->belongsTo(Event::class,'event_id','id');
  }

  /**
   * The ticket that gates (blocks) this ticket from being sold.
   */
  public function gateTicket()
  {
    return $this->belongsTo(self::class, 'gate_ticket_id');
  }

  /**
   * Tickets that are gated (blocked) by this ticket.
   */
  public function gatedTickets()
  {
    return $this->hasMany(self::class, 'gate_ticket_id');
  }

  public function priceSchedules()
  {
    return $this->hasMany(TicketPriceSchedule::class, 'ticket_id')->orderBy('effective_from')->orderBy('sort_order');
  }

  public function contents()
  {
    return $this->hasMany(TicketContent::class, 'ticket_id');
  }

  public function scopeSellable(Builder $query): Builder
  {
    if (Schema::hasColumn($this->getTable(), 'sale_status')) {
      $query->where($this->getTable() . '.sale_status', 'active');
    }

    if (Schema::hasColumn($this->getTable(), 'archived_at')) {
      $query->whereNull($this->getTable() . '.archived_at');
    }

    return $query;
  }

    // when ticket delete
  protected static function boot()
  {
    parent::boot();
    static::deleting(function ($ticket) {
      $slot_unique_ids = [];
      $variations = json_decode($ticket->variations,true);
      if(!empty($variations)){
        $slot_unique_ids = array_merge($slot_unique_ids, array_column($variations, 'slot_unique_id'));
      }
      if(!empty($ticket->slot_unique_id)){
        $slot_unique_ids[] = $ticket->slot_unique_id;
      }
      $slot_unique_ids = array_unique($slot_unique_ids);
      foreach($slot_unique_ids as $slot_unique){
        $slot = Slot::where('slot_unique_id',$slot_unique)->first();
        if(!is_null($slot)){
          $slot->delete();
        }
        $slotImage = SlotImage::where('slot_unique_id',$slot_unique)->first();
        if(!is_null($slotImage)){
          @unlink(public_path('assets/admin/img/map-image/' . $slotImage->image));
          $slotImage->delete();
        }
      }
    });
  }
}
