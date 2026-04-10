<?php

namespace App\Http\Middleware;

use App\Models\Language;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\App;
use Illuminate\Support\Facades\Schema;

class ChangeLanguage
{
  /**
   * Handle an incoming request.
   *
   * @param  \Illuminate\Http\Request  $request
   * @param  \Closure  $next
   * @return mixed
   */
  public function handle(Request $request, Closure $next)
  {
    if ($request->session()->has('lang')) {
      $locale = $request->session()->get('lang');
    }
    if (empty($locale)) {
      // set the default language as system locale
      $language = Schema::hasTable('languages')
        ? Language::where('is_default', 1)->first()
        : null;
      $languageCode = $language->code ?? config('app.locale', 'en');

      App::setLocale($languageCode);
    } else {
      // set the selected language as system locale
      App::setLocale($locale);
    }
    return $next($request);
  }
}
