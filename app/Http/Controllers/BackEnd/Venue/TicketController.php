<?php

namespace App\Http\Controllers\BackEnd\Venue;

use App\Http\Controllers\Controller;
use App\Models\SupportTicket;
use App\Models\SupportTicketMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Validator;
use App\Traits\HasIdentityActor;

class TicketController extends Controller
{
    use HasIdentityActor;
    public function index()
    {
        $tickets = SupportTicket::where('venue_id', $this->getVenueId())->orderBy('id', 'desc')->paginate(10);
        return view('venue.support_ticket.index', compact('tickets'));
    }

    public function create()
    {
        return view('venue.support_ticket.create');
    }

    public function store(Request $request)
    {
        $rules = [
            'subject' => 'required',
            'description' => 'required',
        ];

        $validator = Validator::make($request->all(), $rules);

        if ($validator->fails()) {
            return back()->withErrors($validator)->withInput();
        }

        $ticket = new SupportTicket();
        $ticket->venue_id = $this->getVenueId();
        $ticket->ticket_id = uniqid();
        $ticket->subject = $request->subject;
        $ticket->description = $request->description;
        $ticket->status = 1; // open
        $ticket->save();

        Session::flash('success', 'Support ticket created successfully');
        return redirect()->route('venue.support_tickets');
    }

    public function messages($id)
    {
        $ticket = SupportTicket::where('venue_id', $this->getVenueId())->where('id', $id)->firstOrFail();
        $messages = SupportTicketMessage::where('support_ticket_id', $id)->get();
        return view('venue.support_ticket.messages', compact('ticket', 'messages'));
    }
}
