<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event\Booking;
use App\Models\Customer;
use App\Models\TicketTransfer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Crypt;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

use App\Services\NotificationService;

class MarketplaceController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    private function resolveRecipientFromRequest(Request $request): ?Customer
    {
        $recipientId = $request->input('recipient_id');
        if ($recipientId !== null && $recipientId !== '') {
            return Customer::find($recipientId);
        }

        $recipientStr = trim((string) $request->input('recipient', ''));
        if ($recipientStr === '') {
            return null;
        }

        return Customer::where('email', $recipientStr)
            ->orWhere('username', $recipientStr)
            ->first();
    }

    private function validateTransferableBooking(Booking $booking): ?string
    {
        if (!$booking->is_transferable) {
            return 'This ticket is not transferable.';
        }

        if ($booking->is_listed) {
            return 'Please remove the ticket from the Blackmarket before transferring.';
        }

        $hasPendingTransfer = TicketTransfer::where('booking_id', $booking->id)
            ->where('status', 'pending')
            ->lockForUpdate()
            ->exists();

        if ($booking->transfer_status === 'transfer_pending' || $hasPendingTransfer) {
            return 'This ticket already has a pending transfer request.';
        }

        $event = \App\Models\Event::find($booking->event_id);
        if ($event && $event->end_date_time && now()->greaterThan($event->end_date_time)) {
            return 'Cannot transfer tickets for past events.';
        }

        return null;
    }

    private function buildTransferQrToken(Booking $booking, Customer $owner): string
    {
        return Crypt::encryptString(json_encode([
            'booking_id' => (int) $booking->id,
            'owner_customer_id' => (int) $owner->id,
            'issued_at' => now()->toISOString(),
        ]));
    }

    private function decodeTransferQrToken(string $token): ?array
    {
        try {
            $decoded = json_decode(Crypt::decryptString($token), true);
            return is_array($decoded) ? $decoded : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    private function resolveAcceptedOwner(TicketTransfer $transfer): ?Customer
    {
        $newOwnerId = $transfer->flow === 'receiver_request'
            ? $transfer->from_customer_id
            : $transfer->to_customer_id;

        return Customer::find($newOwnerId);
    }

    private function resolveEventTitleFromBooking(?Booking $booking): string
    {
        if (!$booking) {
            return 'Unknown Event';
        }

        $eventModel = $booking->relationLoaded('evnt') ? $booking->getRelation('evnt') : $booking->evnt;
        if ($eventModel && !empty($eventModel->title)) {
            return $eventModel->title;
        }

        try {
            $content = $booking->relationLoaded('event') ? $booking->getRelation('event') : $booking->event;
            if ($content && !empty($content->title)) {
                return $content->title;
            }
        } catch (\Throwable $e) {
            // Tests and some lightweight environments do not materialize event_contents.
        }

        return 'Unknown Event';
    }

    private function serializeTransfer(TicketTransfer $transfer, Customer $viewer): array
    {
        $booking = $transfer->booking;
        $eventTitle = $this->resolveEventTitleFromBooking($booking);
        $eventDate = $booking?->event_date ?? null;
        $eventThumbnail = optional($booking?->evnt)->thumbnail ?? null;
        $sender = $transfer->sender;
        $receiver = $transfer->receiver;
        $flow = $transfer->flow ?? 'owner_offer';
        $isIncoming = (int) $transfer->to_customer_id === (int) $viewer->id;
        $isActionOwner = $transfer->status === 'pending' && $isIncoming;
        $senderDisplay = $sender->fname ?? $sender->username ?? 'Someone';
        $receiverDisplay = $receiver->fname ?? $receiver->username ?? 'Someone';

        if ($isIncoming) {
            $messageTitle = $flow === 'receiver_request'
                ? 'Ticket request'
                : 'Incoming transfer';

            $messageBody = $flow === 'receiver_request'
                ? ($senderDisplay . ' wants your ticket for ' . $eventTitle . '.')
                : ($senderDisplay . ' wants to send you a ticket for ' . $eventTitle . '.');
        } else {
            $messageTitle = $flow === 'receiver_request'
                ? 'Request sent'
                : 'Transfer pending';

            if ($transfer->status === 'accepted') {
                $messageBody = $flow === 'receiver_request'
                    ? 'Your request for ' . $eventTitle . ' was approved.'
                    : $receiverDisplay . ' accepted your ticket for ' . $eventTitle . '.';
            } elseif ($transfer->status === 'rejected') {
                $messageBody = $flow === 'receiver_request'
                    ? 'Your request for ' . $eventTitle . ' was declined.'
                    : $receiverDisplay . ' declined your ticket for ' . $eventTitle . '.';
            } elseif ($transfer->status === 'cancelled') {
                $messageBody = $flow === 'receiver_request'
                    ? 'You cancelled your request for ' . $eventTitle . '.'
                    : 'This transfer for ' . $eventTitle . ' was cancelled.';
            } else {
                $messageBody = $flow === 'receiver_request'
                    ? 'Waiting for the owner to approve your request for ' . $eventTitle . '.'
                    : 'Waiting for ' . $receiverDisplay . ' to accept your ticket for ' . $eventTitle . '.';
            }
        }

        return [
            'id' => $transfer->id,
            'booking_id' => $transfer->booking_id,
            'flow' => $flow,
            'status' => $transfer->status,
            'direction' => $isIncoming ? 'incoming' : 'outgoing',
            'requires_action' => $transfer->status === 'pending' && $isActionOwner,
            'can_accept' => $transfer->status === 'pending' && $isActionOwner,
            'can_reject' => $transfer->status === 'pending' && $isActionOwner,
            'can_cancel' => $transfer->status === 'pending' && (int) $transfer->from_customer_id === (int) $viewer->id,
            'message_title' => $messageTitle,
            'message_body' => $messageBody,
            'event' => [
                'title' => $eventTitle,
                'date' => $eventDate,
                'thumbnail' => $eventThumbnail,
            ],
            'sender' => [
                'id' => $sender->id ?? null,
                'name' => trim(($sender->fname ?? '') . ' ' . ($sender->lname ?? '')),
                'username' => $sender->username ?? null,
                'photo' => $sender->photo ?? null,
            ],
            'receiver' => [
                'id' => $receiver->id ?? null,
                'name' => trim(($receiver->fname ?? '') . ' ' . ($receiver->lname ?? '')),
                'username' => $receiver->username ?? null,
                'photo' => $receiver->photo ?? null,
            ],
            'created_at' => optional($transfer->created_at)->toISOString(),
            'notes' => $transfer->notes,
        ];
    }

    /**
     * Transfer a ticket to another user.
     */
    /**
     * Verify if a recipient exists before initiating a transfer.
     */
    public function verifyRecipient(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'recipient' => 'required_without:recipient_id|nullable|string',
            'recipient_id' => 'required_without:recipient|nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $recipient = $this->resolveRecipientFromRequest($request);

        if (!$recipient) {
            return response()->json(['success' => false, 'message' => 'User not found.'], 404);
        }

        $currentUser = Auth::guard('sanctum')->user();
        if ($recipient->id === $currentUser->id) {
            return response()->json(['success' => false, 'message' => 'You cannot transfer a ticket to yourself.'], 400);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $recipient->id,
                'name' => ($recipient->fname ?? '') . ' ' . ($recipient->lname ?? ''),
                'username' => $recipient->username,
                'email' => $recipient->email,
                'photo' => $recipient->photo,
            ]
        ]);
    }

    /**
     * Initiate a transfer request (pending approval by recipient).
     */
    public function transfer(Request $request, $id)
    {
        $customer = Auth::guard('sanctum')->user();

        $validator = Validator::make($request->all(), [
            'recipient' => 'required_without:recipient_id|nullable|string',
            'recipient_id' => 'required_without:recipient|nullable|integer',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $recipient = $this->resolveRecipientFromRequest($request);

        if (!$recipient) {
            return response()->json(['success' => false, 'message' => 'Recipient user not found.'], 404);
        }

        if ($recipient->id === $customer->id) {
            return response()->json(['success' => false, 'message' => 'You cannot transfer a ticket to yourself.'], 400);
        }

        try {
            $result = DB::transaction(function () use ($id, $customer, $recipient) {
                $booking = Booking::where('id', $id)
                    ->where('customer_id', $customer->id)
                    ->lockForUpdate()
                    ->first();

                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404),
                    ];
                }

                $transferError = $this->validateTransferableBooking($booking);
                if ($transferError !== null) {
                    $status = str_contains($transferError, 'past events') || str_contains($transferError, 'not transferable')
                        ? 403
                        : 409;

                    return [
                        'response' => response()->json(['success' => false, 'message' => $transferError], $status),
                    ];
                }

                $transfer = TicketTransfer::create([
                    'booking_id' => $booking->id,
                    'from_customer_id' => $customer->id,
                    'to_customer_id' => $recipient->id,
                    'notes' => 'Transfer request via Mobile App',
                    'status' => 'pending',
                    'flow' => 'owner_offer',
                ]);

                $booking->transfer_status = 'transfer_pending';
                $booking->save();

                return [
                    'transfer' => $transfer,
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $recipient,
                    'Transfer Request',
                    ($customer->fname ?? $customer->username) . ' wants to send you a ticket for ' . $eventTitle . '. Open the app to accept or reject.',
                    [
                        'type' => 'transfer_request',
                        'transfer_id' => $transfer->id,
                        'flow' => 'owner_offer',
                        'booking_id' => $booking->id,
                        'event_id' => $booking->event_id,
                    ]
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }
            return response()->json([
                'success' => true,
                'message' => 'Transfer request sent to ' . ($recipient->fname ?? $recipient->username) . '. Waiting for approval.',
                'data' => [
                    'transfer_id' => $transfer->id,
                    'status' => 'pending',
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Transfer request failed: ' . $e->getMessage()], 500);
        }
    }

    public function transferQr($id)
    {
        $customer = Auth::guard('sanctum')->user();

        $booking = Booking::where('id', $id)
            ->where('customer_id', $customer->id)
            ->lockForUpdate()
            ->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404);
        }

        $transferError = $this->validateTransferableBooking($booking);
        if ($transferError !== null) {
            $status = str_contains($transferError, 'past events') || str_contains($transferError, 'not transferable')
                ? 403
                : 409;

            return response()->json(['success' => false, 'message' => $transferError], $status);
        }

        $token = $this->buildTransferQrToken($booking, $customer);

        return response()->json([
            'success' => true,
            'data' => [
                'booking_id' => $booking->id,
                'event_title' => $this->resolveEventTitleFromBooking($booking),
                'qr_value' => 'duty://transfer-ticket?token=' . urlencode($token),
                'transfer_token' => $token,
                'expires_at' => now()->addDay()->toISOString(),
            ],
        ]);
    }

    public function requestFromTicketScan(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();

        $validator = Validator::make($request->all(), [
            'transfer_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $payload = $this->decodeTransferQrToken((string) $request->input('transfer_token'));
        if (!$payload) {
            return response()->json(['success' => false, 'message' => 'This transfer QR is invalid or has expired.'], 422);
        }

        $bookingId = (int) ($payload['booking_id'] ?? 0);
        $ownerId = (int) ($payload['owner_customer_id'] ?? 0);
        $issuedAt = null;
        if (isset($payload['issued_at'])) {
            try {
                $issuedAt = \Illuminate\Support\Carbon::parse($payload['issued_at']);
            } catch (\Throwable $e) {
                $issuedAt = null;
            }
        }

        if ($bookingId <= 0 || $ownerId <= 0 || !$issuedAt || $issuedAt->lt(now()->subDay())) {
            return response()->json(['success' => false, 'message' => 'This transfer QR is invalid or has expired.'], 422);
        }

        if ($customer->id === $ownerId) {
            return response()->json(['success' => false, 'message' => 'You cannot request your own ticket.'], 400);
        }

        $owner = Customer::find($ownerId);
        if (!$owner) {
            return response()->json(['success' => false, 'message' => 'The ticket owner could not be found.'], 404);
        }

        try {
            $result = DB::transaction(function () use ($bookingId, $ownerId, $customer) {
                $booking = Booking::where('id', $bookingId)
                    ->where('customer_id', $ownerId)
                    ->lockForUpdate()
                    ->first();

                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'This ticket is no longer available for transfer.'], 404),
                    ];
                }

                $transferError = $this->validateTransferableBooking($booking);
                if ($transferError !== null) {
                    $status = str_contains($transferError, 'past events') || str_contains($transferError, 'not transferable')
                        ? 403
                        : 409;

                    return [
                        'response' => response()->json(['success' => false, 'message' => $transferError], $status),
                    ];
                }

                $transfer = TicketTransfer::create([
                    'booking_id' => $booking->id,
                    'from_customer_id' => $customer->id,
                    'to_customer_id' => $ownerId,
                    'notes' => 'Transfer request via Ticket QR',
                    'status' => 'pending',
                    'flow' => 'receiver_request',
                ]);

                $booking->transfer_status = 'transfer_pending';
                $booking->save();

                return [
                    'transfer' => $transfer,
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $owner,
                    'Ticket Request',
                    ($customer->fname ?? $customer->username) . ' wants your ticket for ' . $eventTitle . '. Open Duty to approve or reject.',
                    [
                        'type' => 'transfer_request',
                        'transfer_id' => $transfer->id,
                        'flow' => 'receiver_request',
                        'booking_id' => $booking->id,
                        'event_id' => $booking->event_id,
                    ]
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Transfer request sent to the ticket owner. Waiting for approval.',
                'data' => [
                    'transfer_id' => $transfer->id,
                    'status' => 'pending',
                    'flow' => 'receiver_request',
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Transfer request failed: ' . $e->getMessage()], 500);
        }
    }

    public function transferDetails($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        $transfer = TicketTransfer::with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->where('id', $transferId)
            ->where(function ($query) use ($customer) {
                $query->where('from_customer_id', $customer->id)
                    ->orWhere('to_customer_id', $customer->id);
            })
            ->first();

        if (!$transfer) {
            return response()->json(['success' => false, 'message' => 'Transfer request not found.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->serializeTransfer($transfer, $customer),
        ]);
    }

    /**
     * List pending incoming transfer requests for the current user.
     */
    public function pendingTransfers()
    {
        $customer = Auth::guard('sanctum')->user();

        $transfers = TicketTransfer::where('to_customer_id', $customer->id)
            ->where('status', 'pending')
            ->with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->orderByDesc('id')
            ->get()
            ->map(fn ($transfer) => $this->serializeTransfer($transfer, $customer))
            ->values();

        return response()->json([
            'success' => true,
            'data' => $transfers,
        ]);
    }

    /**
     * List outgoing transfer requests started by the current user.
     */
    public function outboxTransfers()
    {
        $customer = Auth::guard('sanctum')->user();

        $transfers = TicketTransfer::where('from_customer_id', $customer->id)
            ->where(function ($query) {
                $query->whereNull('notes')
                    ->orWhere('notes', '!=', 'Marketplace Purchase');
            })
            ->with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->orderByDesc('id')
            ->get()
            ->map(fn ($transfer) => $this->serializeTransfer($transfer, $customer))
            ->values();

        return response()->json([
            'success' => true,
            'data' => $transfers,
        ]);
    }

    /**
     * Accept a pending transfer request.
     */
    public function acceptTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('to_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();

                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Associated ticket no longer exists.'], 404),
                    ];
                }

                $newOwner = $this->resolveAcceptedOwner($transfer);
                if (!$newOwner) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'The transfer recipient could not be resolved.'], 404),
                    ];
                }

                // Transfer ownership
                $booking->update([
                    'customer_id' => $newOwner->id,
                    'fname' => $newOwner->fname,
                    'lname' => $newOwner->lname,
                    'email' => $newOwner->email,
                    'phone' => $newOwner->phone,
                    'is_listed' => false,
                    'transfer_status' => null,
                ]);

                $transfer->update(['status' => 'accepted']);

                return [
                    'transfer' => $transfer->fresh(),
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $sender = Customer::find($transfer->from_customer_id);
                $eventTitle = optional($booking->evnt)->title ?? 'an event';

                if ($sender) {
                    $this->notificationService->notifyUser(
                        $sender,
                        'Transfer Accepted',
                        ($customer->fname ?? $customer->username) . ' accepted your ticket transfer for ' . $eventTitle . '.',
                        [
                            'type' => 'transfer_accepted',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => $booking->id,
                            'event_id' => $booking->event_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            $message = ($transfer->flow ?? 'owner_offer') === 'receiver_request'
                ? 'Transfer approved. The ticket has been sent.'
                : 'Transfer accepted! The ticket is now yours.';

            return response()->json([
                'success' => true,
                'message' => $message,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Accept failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Reject a pending transfer request.
     */
    public function rejectTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('to_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();
                if ($booking) {
                    $booking->update(['transfer_status' => null]);
                }

                $transfer->update(['status' => 'rejected']);

                return [
                    'transfer' => $transfer->fresh(),
                    'booking' => $booking ? $booking->fresh() : null,
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $sender = Customer::find($transfer->from_customer_id);
                $eventTitle = optional(optional($booking)->evnt)->title ?? 'an event';

                if ($sender) {
                    $this->notificationService->notifyUser(
                        $sender,
                        'Transfer Rejected',
                        ($customer->fname ?? $customer->username) . ' rejected your ticket transfer for ' . $eventTitle . '.',
                        [
                            'type' => 'transfer_rejected',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => optional($booking)->id,
                            'event_id' => optional($booking)->event_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Transfer request rejected.',
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Reject failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Cancel a pending transfer request (by the sender).
     */
    public function cancelTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('from_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();
                if ($booking) {
                    $booking->update(['transfer_status' => null]);
                }

                $transfer->update(['status' => 'cancelled']);

                return [
                    'transfer' => $transfer->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];

            try {
                $receiver = Customer::find($transfer->to_customer_id);
                if ($receiver) {
                    $this->notificationService->notifyUser(
                        $receiver,
                        'Transfer Cancelled',
                        ($customer->fname ?? $customer->username) . ' cancelled a pending ticket transfer.',
                        [
                            'type' => 'transfer_cancelled',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => $transfer->booking_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Transfer request cancelled.',
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Cancel failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * List a ticket for sale on the marketplace.
     */
    public function listForSale(Request $request, $id)
    {
        $customer = Auth::guard('sanctum')->user();
        $booking = Booking::where('id', $id)->where('customer_id', $customer->id)->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404);
        }

        // Check if the event has already concluded
        $event = \App\Models\Event::find($booking->event_id);
        if ($event && $event->end_date_time && now()->greaterThan($event->end_date_time)) {
            return response()->json(['success' => false, 'message' => 'Cannot list tickets for past events.'], 403);
        }

        $basic = \App\Models\BasicSettings\Basic::select('marketplace_max_price_rule')->first();

        $maxPriceRule = '';
        if ($basic && $basic->marketplace_max_price_rule == 1) {
            $maxPriceRule = '|max:' . $booking->price;
        }

        $validator = Validator::make($request->all(), [
            'price' => 'required|numeric|min:0' . $maxPriceRule,
            'is_listed' => 'required|boolean',
        ], [
            'price.max' => 'The listing price cannot exceed the original purchase price (' . $booking->price . ').'
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $booking->update([
            'is_listed' => $request->is_listed,
            'listing_price' => $request->price,
        ]);

        $status = $request->is_listed ? 'listed' : 'unlisted';

        return response()->json([
            'success' => true,
            'message' => "Ticket successfully {$status}.",
            'data' => [
                'is_listed' => $booking->is_listed,
                'listing_price' => $booking->listing_price,
            ]
        ]);
    }

    /**
     * List all tickets currently for sale on the marketplace.
     */
    public function index(Request $request)
    {
        $search = $request->input('search');
        $categoryId = $request->input('category_id');
        $minPrice = $request->input('min_price');
        $maxPrice = $request->input('max_price');

        $bookings = Booking::where('is_listed', true)
            ->where('customer_id', '!=', Auth::guard('sanctum')->id()) // Don't show own tickets
            ->when($search, function ($query, $search) {
                return $query->whereHas('event', function ($q) use ($search) {
                    $q->where('title', 'like', '%' . $search . '%');
                });
            })
            ->when($categoryId, function ($query, $categoryId) {
                return $query->whereHas('event', function ($q) use ($categoryId) {
                    $q->where('event_category_id', $categoryId);
                });
            })
            ->when($minPrice !== null, function ($query) use ($minPrice) {
                return $query->where('listing_price', '>=', $minPrice);
            })
            ->when($maxPrice !== null, function ($query) use ($maxPrice) {
                return $query->where('listing_price', '<=', $maxPrice);
            })
            ->with(['customerInfo', 'evnt', 'event'])
            ->get()
            ->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'event' => [
                        'id' => $booking->evnt->id ?? null,
                        'title' => $booking->event->title ?? 'Unknown Event',
                        'thumbnail' => $booking->evnt->thumbnail ?? null,
                        'date' => $booking->event_date,
                    ],
                    'seller' => [
                        'name' => ($booking->customerInfo->fname ?? '') . ' ' . ($booking->customerInfo->lname ?? ''),
                        'username' => $booking->customerInfo->username ?? 'Unknown',
                        'photo' => $booking->customerInfo->photo ?? null,
                    ],
                    'price' => $booking->listing_price,
                    'original_price' => $booking->price,
                    'quantity' => $booking->quantity,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $bookings
        ]);
    }

    /**
     * Purchase a ticket from the marketplace.
     */
    public function purchase(Request $request, $id)
    {
        $buyer = Auth::guard('sanctum')->user();

        try {
            $walletService = app(\App\Services\WalletService::class);
            $result = DB::transaction(function () use ($id, $buyer, $walletService) {
                $booking = Booking::where('id', $id)->lockForUpdate()->first();
                if (!$booking || !$booking->is_listed) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Ticket no longer available.'], 404),
                    ];
                }

                if ((int) $booking->customer_id === (int) $buyer->id) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'You cannot buy your own ticket.'], 400),
                    ];
                }

                $seller = Customer::find($booking->customer_id);
                if (!$seller) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Seller not found.'], 404),
                    ];
                }

                $price = (float) $booking->listing_price;
                $basicSetting = \App\Models\BasicSettings\Basic::select('marketplace_commission')->first();
                $platformFeePercent = ($basicSetting->marketplace_commission ?? 5) / 100;
                $fee = $price * $platformFeePercent;
                $sellerPayout = $price - $fee;

                // Check if buyer has enough funds before trying debit.
                $buyerWallet = $walletService->getOrCreateWallet($buyer);
                if (!$buyerWallet || $buyerWallet->balance < $price) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Insufficient wallet balance.'], 402),
                    ];
                }

                // Deterministic idempotency key per (booking, buyer) pair.
                $operationKey = 'marketplace_booking_' . $booking->id . '_buyer_' . $buyer->id;

                $walletService->debit(
                    $buyer,
                    $price,
                    'Marketplace Purchase',
                    (string) $booking->id,
                    'MP_BUY_' . $operationKey
                );

                $walletService->credit(
                    $seller,
                    $sellerPayout,
                    'Marketplace Sale',
                    (string) $booking->id,
                    'MP_SELL_' . $operationKey
                );

                TicketTransfer::create([
                    'booking_id' => $booking->id,
                    'from_customer_id' => $booking->customer_id,
                    'to_customer_id' => $buyer->id,
                    'notes' => 'Marketplace Purchase',
                    'status' => 'accepted',
                    'flow' => 'owner_offer',
                ]);

                $booking->update([
                    'customer_id' => $buyer->id,
                    'fname' => $buyer->fname,
                    'lname' => $buyer->lname,
                    'email' => $buyer->email,
                    'phone' => $buyer->phone,
                    'is_listed' => false,
                    'listing_price' => 0,
                ]);

                return [
                    'seller' => $seller,
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $seller = $result['seller'];
            $booking = $result['booking'];

            // Notifications must not fail the purchase flow after commit.
            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $seller,
                    'Ticket Sold!',
                    'Your ticket for ' . $eventTitle . ' has been sold.'
                );
                $this->notificationService->notifyUser(
                    $buyer,
                    'Ticket Purchased',
                    'You have successfully purchased a ticket for ' . $eventTitle . ' from the marketplace.'
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            $loyaltyCustomer = $buyer instanceof Customer ? $buyer : Customer::find(optional($buyer)->id);
            if ($loyaltyCustomer) {
                app(\App\Services\LoyaltyService::class)->awardFromRule(
                    $loyaltyCustomer,
                    'marketplace_purchase',
                    'marketplace_booking',
                    (string) $booking->id,
                    [
                        'event_id' => (int) ($booking->event_id ?? 0),
                        'purchase_source' => 'marketplace',
                    ]
                );
            }

            return response()->json([
                'success' => true,
                'message' => 'Ticket purchased successfully!',
                'data' => $booking
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Purchase failed: ' . $e->getMessage()], 500);
        }
    }
}
