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
    $locale = $request->session()->get('lang');

    if (empty($locale)) {
      $languageCode = config('app.locale', 'en');

      try {
        $language = Schema::hasTable('languages')
          ? Language::where('is_default', 1)->first()
          : null;

        $languageCode = $language->code ?? $languageCode;
      } catch (\Throwable $exception) {
        // Fall back to the configured locale when the DB is unavailable.
      }

      App::setLocale($languageCode);
    } else {
      App::setLocale($locale);
    }

    return $next($request);
  }
}
