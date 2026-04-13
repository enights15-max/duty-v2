<?php

namespace App\Http\Controllers;

use App\Models\Advertisement;
use App\Models\BasicSettings\Basic;
use App\Models\BasicSettings\PageHeading;
use App\Models\BasicSettings\SEO;
use App\Models\Language;
use App\Models\Subscriber;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;
use Illuminate\Foundation\Bus\DispatchesJobs;
use Illuminate\Foundation\Validation\ValidatesRequests;
use Illuminate\Http\Request;
use Illuminate\Routing\Controller as BaseController;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Facades\Validator;

class Controller extends BaseController
{
  use AuthorizesRequests, DispatchesJobs, ValidatesRequests;

  protected function hasTable(string $table): bool
  {
    try {
      return Schema::hasTable($table);
    } catch (\Throwable $exception) {
      return false;
    }
  }

  protected function safeFirst(string $table, callable $callback, $default = null)
  {
    if (!$this->hasTable($table)) {
      return $default;
    }

    try {
      return $callback() ?? $default;
    } catch (\Throwable $exception) {
      return $default;
    }
  }

  protected function safeGet(string $table, callable $callback)
  {
    if (!$this->hasTable($table)) {
      return collect();
    }

    try {
      return $callback() ?? collect();
    } catch (\Throwable $exception) {
      return collect();
    }
  }

  protected function fallbackLanguage(): Language
  {
    return new Language([
      'id' => 1,
      'code' => config('app.locale', 'en'),
      'direction' => 'ltr',
      'is_default' => 1,
    ]);
  }

  public function getCurrencyInfo()
  {
    if (!Schema::hasTable('basic_settings')) {
      return (object) [
        'base_currency_symbol' => 'RD$',
        'base_currency_symbol_position' => 'left',
        'base_currency_text' => 'DOP',
        'base_currency_text_position' => 'right',
        'base_currency_rate' => 1,
      ];
    }

    $baseCurrencyInfo = Basic::select('base_currency_symbol', 'base_currency_symbol_position', 'base_currency_text', 'base_currency_text_position', 'base_currency_rate')
      ->first();

    if (!$baseCurrencyInfo) {
      return (object) [
        'base_currency_symbol' => 'RD$',
        'base_currency_symbol_position' => 'left',
        'base_currency_text' => 'DOP',
        'base_currency_text_position' => 'right',
        'base_currency_rate' => 1,
      ];
    }

    return $baseCurrencyInfo;
  }


  public function getLanguage()
  {
    $fallbackLanguage = $this->fallbackLanguage();

    if (!Schema::hasTable('languages')) {
      return $fallbackLanguage;
    }

    // get the current locale of this system
    $locale = Session::get('lang');

    if (!empty($locale)) {
      $language = Language::where('code', $locale)->first();
      if (!empty($language)) {
        return $language;
      }
    }

    return Language::where('is_default', 1)->first()
      ?? Language::query()->orderBy('id')->first()
      ?? $fallbackLanguage;
  }


  public function getPageHeading($language)
  {
    if (empty($language?->id)) {
      return null;
    }

    return $this->safeFirst((new PageHeading())->getTable(), function () use ($language) {
      $pageHeading = null;

      if (URL::current() == Route::is('courses')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('courses_page_title')->first();
      } else if (URL::current() == Route::is('course_details')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('course_details_page_title')->first();
      } else if (URL::current() == Route::is('instructors')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('instructors_page_title')->first();
      } else if (URL::current() == Route::is('blogs')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('blog_page_title')->first();
      } else if (URL::current() == Route::is('blog_details')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('blog_details_page_title')->first();
      } else if (URL::current() == Route::is('faqs')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('faq_page_title')->first();
      } else if (URL::current() == Route::is('contact')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('contact_page_title')->first();
      } else if (URL::current() == Route::is('user.login')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('login_page_title')->first();
      } else if (URL::current() == Route::is('user.forget_password')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('forget_password_page_title')->first();
      } else if (URL::current() == Route::is('user.signup')) {
        $pageHeading = PageHeading::where('language_id', $language->id)->select('signup_page_title')->first();
      }

      return $pageHeading;
    });
  }

  protected function getSeoInfo($language, array $columns = [])
  {
    if (empty($language?->id)) {
      return null;
    }

    return $this->safeFirst((new SEO())->getTable(), function () use ($language, $columns) {
      $query = $language->seoInfo();

      if (!empty($columns)) {
        $query->select($columns);
      }

      return $query->first();
    });
  }


  public static function getBreadcrumb()
  {
    try {
      if (!Schema::hasTable('basic_settings') || !Schema::hasColumn('basic_settings', 'breadcrumb')) {
        return (object) ['breadcrumb' => null];
      }

      $breadcrumb = Basic::select('breadcrumb')->first();
    } catch (\Throwable $exception) {
      return (object) ['breadcrumb' => null];
    }

    return $breadcrumb ?: (object) ['breadcrumb' => null];
  }


  public function changeLanguage(Request $request)
  {
    // put the selected language in session
    $langCode = $request['lang_code'];

    $request->session()->put('lang', $langCode);

    return redirect()->back();
  }


  public function serviceUnavailable()
  {
    $info = DB::table('basic_settings')->select('maintenance_img', 'maintenance_msg')->first();

    return view('errors.503', compact('info'));
  }


  public function countAdView($id)
  {
    try {
      $ad = Advertisement::where('id', $id)->first();

      $ad->update([
        'views' => $ad->views + 1
      ]);

      return response()->json(['success' => 'Advertisement view counted successfully.']);
    } catch (ModelNotFoundException $e) {
      return response()->json(['error' => 'Sorry, something went wrong!']);
    }
  }


  public function storeSubscriber(Request $request)
  {
    $rules = [
      'email_id' => 'required|email:rfc,dns|unique:subscribers'
    ];

    $messages = [
      'email_id.required' => 'Please enter your email address.',
      'email_id.unique' => 'This email address is already exist!'
    ];

    $validator = Validator::make($request->all(), $rules, $messages);

    if ($validator->fails()) {
      return Response::json([
        'error' => $validator->getMessageBag()
      ], 400);
    }

    Subscriber::create($request->all());

    return Response::json([
      'success' => 'You have successfully subscribed to our newsletter.'
    ], 200);
  }


}
