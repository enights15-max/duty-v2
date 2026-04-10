<?php

namespace App\Http\Controllers\BackEnd;

use App\Http\Controllers\Controller;
use App\Models\BasicSettings\Basic;
use App\Models\BasicSettings\MailTemplate;
use App\Models\Identity;
use App\Models\Organizer;
use App\Models\Transaction;
use App\Models\Withdraw;
use App\Services\ProfessionalBalanceService;
use App\Services\ProfessionalCatalogBridgeService;
use Exception;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use PHPMailer\PHPMailer\PHPMailer;

class WithdrawController extends Controller
{
  public function __construct(
    private ProfessionalCatalogBridgeService $catalogBridge,
    private ProfessionalBalanceService $professionalBalanceService
  ) {
  }

  //index
  public function index()
  {
    $search = request()->input('search');

    $collection = Withdraw::with('method')
      ->when($search, function ($query, $keyword) {
        return $query->where('withdraws.withdraw_id', 'like', '%' . $keyword . '%');
      })
      ->orderBy('id', 'desc')->paginate(10);

    $collection->setCollection(
      $collection->getCollection()->map(fn(Withdraw $withdraw) => $this->hydrateWithdrawActorMetadata($withdraw))
    );

    $currencyInfo = $this->getCurrencyInfo();
    return view('backend.withdraw.history.index', compact('collection', 'currencyInfo'));
  }
  //delete
  public function delete(Request $request)
  {
    $withdraw = Withdraw::where('id', $request->id)->first();

    if ($withdraw->status == 0) {
      $this->restoreWithdrawBalance($withdraw);
    }

    $withdraw->delete();
    return redirect()->back()->with('success', 'Deleted Successfully');
  }

  //approve
  public function approve($id)
  {
    $withdraw = Withdraw::where('id', $id)->first();

    //mail sending
    // get the website title & mail's smtp information from db
    $info = Basic::select('website_title', 'smtp_status', 'smtp_host', 'smtp_port', 'encryption', 'smtp_username', 'smtp_password', 'from_mail', 'from_name', 'base_currency_symbol_position', 'base_currency_symbol')
      ->first();

    //preparing mail info
    // get the mail template info from db
    $mailTemplate = MailTemplate::query()->where('mail_type', '=', 'withdraw_approve')->first();
    $mailData['subject'] = $mailTemplate->mail_subject;
    $mailBody = $mailTemplate->mail_body;

    // get the website title info from db
    $website_info = Basic::select('website_title')->first();

    $actor = $this->resolveWithdrawActorContext($withdraw);

    // preparing dynamic data
    $organizerName = $actor['name'];
    $organizerEmail = $actor['email'];
    $organizer_amount = $actor['current_balance'];
    $withdraw_amount = $withdraw->amount;
    $total_charge = $withdraw->total_charge;
    $payable_amount = $withdraw->payable_amount;

    $method = $withdraw->method()->select('name')->first();

    $websiteTitle = $website_info->website_title;

    // replacing with actual data
    $mailBody = str_replace('{organizer_username}', $organizerName, $mailBody);
    $mailBody = str_replace('{withdraw_id}', $withdraw->withdraw_id, $mailBody);

    $mailBody = str_replace('{current_balance}', $info->base_currency_symbol . $organizer_amount, $mailBody);
    $mailBody = str_replace('{withdraw_amount}', $info->base_currency_symbol . $withdraw_amount, $mailBody);
    $mailBody = str_replace('{charge}', $info->base_currency_symbol . $total_charge, $mailBody);
    $mailBody = str_replace('{payable_amount}', $info->base_currency_symbol . $payable_amount, $mailBody);

    $mailBody = str_replace('{withdraw_method}', $method->name, $mailBody);
    $mailBody = str_replace('{website_title}', $websiteTitle, $mailBody);

    $mailData['body'] = $mailBody;

    $mailData['recipient'] = $organizerEmail;
    //preparing mail info end

    // initialize a new mail
    $mail = new PHPMailer(true);
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // if smtp status == 1, then set some value for PHPMailer
    if ($info->smtp_status == 1) {
      $mail->isSMTP();
      $mail->Host       = $info->smtp_host;
      $mail->SMTPAuth   = true;
      $mail->Username   = $info->smtp_username;
      $mail->Password   = $info->smtp_password;

      if ($info->encryption == 'TLS') {
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
      }

      $mail->Port       = $info->smtp_port;
    }

    // add other informations and send the mail
    try {
      $mail->setFrom($info->from_mail, $info->from_name);
      if (!empty($mailData['recipient'])) {
        $mail->addAddress($mailData['recipient']);
      }

      $mail->isHTML(true);
      $mail->Subject = $mailData['subject'];
      $mail->Body = $mailData['body'];

      $mail->send();
      Session::flash('success', 'Withdraw Request Approved Successfully!');
    } catch (Exception $e) {
      Session::flash('warning', 'Mail could not be sent. Mailer Error: ' . $mail->ErrorInfo);
    }
    $withdraw->status = 1;

    $transcation = Transaction::where('booking_id', $withdraw->id)->where('transcation_type', 3)->first();
    if ($transcation) {
      $transcation->update(['payment_status' => 1]);
    }
    //mail sending end
    $withdraw->save();
    return redirect()->back();
  }
  //decline
  public function decline($id)
  {
    $withdraw = Withdraw::where('id', $id)->first();

    //mail sending
    // get the website title & mail's smtp information from db
    $info = Basic::select('website_title', 'smtp_status', 'smtp_host', 'smtp_port', 'encryption', 'smtp_username', 'smtp_password', 'from_mail', 'from_name', 'base_currency_symbol_position', 'base_currency_symbol')
      ->first();

    //preparing mail info
    // get the mail template info from db
    $mailTemplate = MailTemplate::query()->where('mail_type', '=', 'withdraw_rejected')->first();
    $mailData['subject'] = $mailTemplate->mail_subject;
    $mailBody = $mailTemplate->mail_body;

    // get the website title info from db
    $website_info = Basic::select('website_title')->first();

    $actor = $this->resolveWithdrawActorContext($withdraw);

    // preparing dynamic data
    $organizerName = $actor['name'];
    $organizerEmail = $actor['email'];
    $organizer_amount = $actor['current_balance'] + (float) $withdraw->amount;

    $method = $withdraw->method()->select('name')->first();

    $websiteTitle = $website_info->website_title;

    // replacing with actual data
    $mailBody = str_replace('{organizer_username}', $organizerName, $mailBody);
    $mailBody = str_replace('{withdraw_id}', $withdraw->withdraw_id, $mailBody);

    $mailBody = str_replace('{current_balance}', $info->base_currency_symbol . $organizer_amount, $mailBody);
    $mailBody = str_replace('{website_title}', $websiteTitle, $mailBody);

    $mailData['body'] = $mailBody;

    $mailData['recipient'] = $organizerEmail;
    //preparing mail info end

    // initialize a new mail
    $mail = new PHPMailer(true);
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // if smtp status == 1, then set some value for PHPMailer
    if ($info->smtp_status == 1) {
      $mail->isSMTP();
      $mail->Host       = $info->smtp_host;
      $mail->SMTPAuth   = true;
      $mail->Username   = $info->smtp_username;
      $mail->Password   = $info->smtp_password;

      if ($info->encryption == 'TLS') {
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
      }
      $mail->Port       = $info->smtp_port;
    }

    // add other informations and send the mail
    try {
      $mail->setFrom($info->from_mail, $info->from_name);
      if (!empty($mailData['recipient'])) {
        $mail->addAddress($mailData['recipient']);
      }

      $mail->isHTML(true);
      $mail->Subject = $mailData['subject'];
      $mail->Body = $mailData['body'];

      $mail->send();
      Session::flash('success', 'Withdraw request decline & balance return to vendor account successfully!');
    } catch (Exception $e) {
      Session::flash('warning', 'Mail could not be sent.');
    }

    $this->restoreWithdrawBalance($withdraw);

    $transcation = Transaction::where([['booking_id', $withdraw->id], ['transcation_type', 3]])->first();
    if ($transcation) {
      $transcation->update(['payment_status' => 2]);
    }

    $withdraw->status = 2;

    //mail sending end
    $withdraw->save();
    return redirect()->back();
  }

  private function hydrateWithdrawActorMetadata(Withdraw $withdraw): Withdraw
  {
    $actor = $this->resolveWithdrawActorContext($withdraw);
    $withdraw->actor_name = $actor['name'];
    $withdraw->actor_email = $actor['email'];
    $withdraw->actor_type = $actor['type'];

    return $withdraw;
  }

  private function resolveWithdrawActorContext(Withdraw $withdraw): array
  {
    [$type, $identityId, $legacyId] = $this->detectWithdrawActor($withdraw);

    $identity = $identityId ? Identity::query()->with('owner')->find($identityId) : null;

    if (!$identity && $legacyId) {
      $identity = $this->catalogBridge->findIdentityForLegacy($type, $legacyId);
      $identityId = $identity?->id;
    }

    $legacyModel = match ($type) {
      'venue' => $withdraw->venue()->first(),
      'artist' => $withdraw->artist()->first(),
      default => $withdraw->organizer()->first(),
    };

    $legacyName = data_get($legacyModel, 'username')
      ?? data_get($legacyModel, 'name')
      ?? data_get($legacyModel, 'title');

    $legacyEmail = data_get($legacyModel, 'email');
    $identityMeta = is_array($identity?->meta) ? $identity->meta : [];
    $identityOwner = $identity?->relationLoaded('owner') ? $identity->owner : $identity?->owner()->first();

    return [
      'type' => $type,
      'identity_id' => $identity?->id ? (int) $identity->id : null,
      'legacy_id' => $legacyId,
      'name' => $identity?->display_name ?: ($legacyName ?: ucfirst($type) . ' #' . ($identity?->id ?: $legacyId ?: $withdraw->id)),
      'email' => $identityMeta['contact_email'] ?? $identityOwner?->email ?? $legacyEmail,
      'current_balance' => match ($type) {
        'venue' => $this->professionalBalanceService->currentVenueBalance($identity?->id, $legacyId),
        'artist' => $this->professionalBalanceService->currentArtistBalance($identity?->id, $legacyId),
        default => $this->professionalBalanceService->currentOrganizerBalance($identity?->id, $legacyId),
      },
    ];
  }

  private function detectWithdrawActor(Withdraw $withdraw): array
  {
    $venueIdentityId = $this->normalizeNullableInt(data_get($withdraw, 'venue_identity_id'));
    $venueId = $this->normalizeNullableInt(data_get($withdraw, 'venue_id'));
    if ($venueIdentityId !== null || $venueId !== null) {
      return ['venue', $venueIdentityId, $venueId];
    }

    $artistIdentityId = $this->normalizeNullableInt(data_get($withdraw, 'artist_identity_id'));
    $artistId = $this->normalizeNullableInt(data_get($withdraw, 'artist_id'));
    if ($artistIdentityId !== null || $artistId !== null) {
      return ['artist', $artistIdentityId, $artistId];
    }

    return [
      'organizer',
      $this->normalizeNullableInt(data_get($withdraw, 'organizer_identity_id')),
      $this->normalizeNullableInt(data_get($withdraw, 'organizer_id')),
    ];
  }

  private function restoreWithdrawBalance(Withdraw $withdraw): void
  {
    [$type, $identityId, $legacyId] = $this->detectWithdrawActor($withdraw);
    $amount = (float) $withdraw->amount;

    match ($type) {
      'venue' => $this->professionalBalanceService->creditVenueBalance($identityId, $legacyId, $amount),
      'artist' => $this->professionalBalanceService->creditArtistBalance($identityId, $legacyId, $amount),
      default => $this->professionalBalanceService->creditOrganizerBalance($identityId, $legacyId, $amount),
    };
  }

  private function normalizeNullableInt($value): ?int
  {
    if ($value === null || $value === '') {
      return null;
    }

    return is_numeric($value) ? (int) $value : null;
  }
}
