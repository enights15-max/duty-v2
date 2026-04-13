<?php

namespace App\Providers;

use App\Models\BasicSettings\Basic;
use App\Models\Language;
use App\Models\ContactPage;
use App\Models\Journal\Blog;
use App\Models\HomePage\Section;
use App\Models\BasicSettings\SEO;
use Illuminate\Support\Facades\DB;
use Illuminate\Pagination\Paginator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\View;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\ServiceProvider;
use App\Models\BasicSettings\PageHeading;
use App\Models\BasicSettings\SocialMedia;

class AppServiceProvider extends ServiceProvider
{
  private ?array $basicSettingsColumns = null;
  private ?array $tableAvailability = null;

  /**
   * Register any application services.
   *
   * @return void
   */
  public function register()
  {
    //
  }

  /**
   * Bootstrap any application services.
   *
   * @return void
   */
  public function boot()
  {

    if (!app()->runningInConsole()) {
      set_time_limit(300);
      # code...
      Paginator::useBootstrap();

      $data = $this->loadBasicSettings(
        ['favicon', 'website_title', 'logo', 'timezone', 'preloader', 'event_guest_checkout_status', 'primary_color'],
        [
          'favicon' => null,
          'website_title' => config('app.name', 'Duty'),
          'logo' => null,
          'timezone' => config('app.timezone', 'America/Santo_Domingo'),
          'preloader' => null,
          'event_guest_checkout_status' => 0,
          'primary_color' => null,
        ]
      );

      // send this information to only back-end view files
      View::composer('backend.*', function ($view) {
        if (Auth::guard('admin')->check() == true) {
          $authAdmin = Auth::guard('admin')->user();
          $role = null;

          if (!is_null($authAdmin->role_id)) {
            $role = $authAdmin->role()->first();
          }
        }

        $language = $this->resolveLanguage();
        $websiteSettings = $this->loadBasicSettings(
          [
            'event_country_status',
            'event_state_status',
            'admin_theme_version',
            'base_currency_symbol_position',
            'base_currency_symbol',
            'base_currency_text',
            'google_map_status',
            'google_map_api_key',
          ],
          [
            'event_country_status' => 0,
            'event_state_status' => 0,
            'admin_theme_version' => null,
            'base_currency_symbol_position' => 'left',
            'base_currency_symbol' => null,
            'base_currency_text' => null,
            'google_map_status' => 0,
            'google_map_api_key' => null,
          ]
        );

        $footerText = $this->safeFirstForTable('footer_contents', function () use ($language) {
          return $language->footerContent()->first();
        });

        if (Auth::guard('admin')->check() == true) {
          $view->with('roleInfo', $role);
        }

        $view->with('defaultLang', $language);
        $view->with('settings', $websiteSettings);
        $view->with('footerTextInfo', $footerText);
      });

      // send this information to only back-end view files
      View::composer('organizer.*', function ($view) {
        $language = $this->resolveLanguage();
        $websiteSettings = $this->loadBasicSettings(
          [
            'admin_theme_version',
            'base_currency_symbol',
            'base_currency_symbol_position',
            'base_currency_text',
            'base_currency_text_position',
            'base_currency_rate',
            'organizer_email_verification',
            'event_state_status',
            'google_map_status',
            'google_map_api_key',
            'event_country_status',
            'event_state_status',
          ],
          [
            'admin_theme_version' => null,
            'base_currency_symbol' => null,
            'base_currency_symbol_position' => 'left',
            'base_currency_text' => null,
            'base_currency_text_position' => 'left',
            'base_currency_rate' => 1,
            'organizer_email_verification' => 0,
            'event_state_status' => 0,
            'google_map_status' => 0,
            'google_map_api_key' => null,
            'event_country_status' => 0,
          ]
        );

        $footerText = $this->safeFirstForTable('footer_contents', function () use ($language) {
          return $language->footerContent()->first();
        });


        $view->with('defaultLang', $language);
        $view->with('settings', $websiteSettings);
        $view->with('footerTextInfo', $footerText);
      });


      // send this information to only front-end view files
      View::composer('frontend.*', function ($view) {
        // get basic info
        $basicData = $this->loadBasicSettings(
          [
            'theme_version',
            'footer_logo',
            'primary_color',
            'breadcrumb_overlay_color',
            'breadcrumb_overlay_opacity',
            'breadcrumb',
            'email_address',
            'contact_number',
            'address',
            'latitude',
            'longitude',
            'base_currency_symbol',
            'base_currency_symbol_position',
            'base_currency_text',
            'base_currency_text_position',
            'base_currency_rate',
            'is_shop_rating',
            'facebook_login_status',
            'google_login_status',
            'google_recaptcha_status',
            'event_country_status',
            'event_state_status',
            'google_map_status',
            'google_map_api_key',
          ],
          [
            'theme_version' => 1,
            'footer_logo' => null,
            'primary_color' => null,
            'breadcrumb_overlay_color' => '000000',
            'breadcrumb_overlay_opacity' => 0.5,
            'breadcrumb' => null,
            'email_address' => null,
            'contact_number' => null,
            'address' => null,
            'latitude' => null,
            'longitude' => null,
            'base_currency_symbol' => null,
            'base_currency_symbol_position' => 'left',
            'base_currency_text' => null,
            'base_currency_text_position' => 'left',
            'base_currency_rate' => 1,
            'is_shop_rating' => 0,
            'facebook_login_status' => 0,
            'google_login_status' => 0,
            'google_recaptcha_status' => 0,
            'event_country_status' => 0,
            'event_state_status' => 0,
            'google_map_status' => 0,
            'google_map_api_key' => null,
          ]
        );


        // get all the languages of this system
        $allLanguages = $this->safeGetForTable('languages', function () {
          return Language::all();
        });

        // get the current locale of this website
        if (Session::has('lang')) {
          $locale = Session::get('lang');
        }
        if (empty($locale)) {
          $language = $this->resolveLanguage();
        } else {
          $language = $this->safeFirstForTable('languages', function () use ($locale) {
            return Language::where('code', $locale)->first();
          });
          if (empty($language)) {
            $language = $this->resolveLanguage();
          }
        }

        // get all the social medias
        $socialMedias = $this->safeGetForTable('social_medias', function () {
          return SocialMedia::orderBy('serial_number')->get();
        });

        //seo
        $seo = $this->safeFirstForTable('seos', function () use ($language) {
          return SEO::where('language_id', $language->id)->first();
        });
        //seo
        $pageHeading = $this->safeFirstForTable('page_headings', function () use ($language) {
          return PageHeading::where('language_id', $language->id)->first();
        });

        // get the menus of this website
        $siteMenuInfo = $this->safeFirstForTable('menu_builders', function () use ($language) {
          return $language->menuInfo()->first();
        });

        if (is_null($siteMenuInfo)) {
          $menus = json_encode([]);
        } else {
          $menus = $siteMenuInfo->menus;
        }

        // get the announcement popups
        $popups = $this->safeGetForTable('popups', function () use ($language) {
          return $language->announcementPopup()->where('status', 1)->orderBy('serial_number', 'asc')->get();
        });

        // get the cookie alert info
        $cookieAlert = $this->safeFirstForTable('cookie_alerts', function () use ($language) {
          return $language->cookieAlertInfo()->first();
        });

        // get footer section status (enable/disable) information
        $footerSectionStatus = $this->safeFirstForTable('sections', function () {
          return Section::query()->pluck('footer_section_status')->first();
        }, 0);

        if ($footerSectionStatus == 1) {
          // get the footer info
          $footerData = $this->safeFirstForTable('footer_contents', function () use ($language) {
            return $language->footerContent()->first();
          });

          // get the quick links of footer
          $quickLinks = $this->safeGetForTable('quick_links', function () use ($language) {
            return $language->footerQuickLink()->orderBy('serial_number', 'asc')->get();
          });

          // get latest blogs
          if ($basicData->theme_version != 3) {
            $blogs = $this->safeGetForTable('blogs', function () use ($language) {
              if (!$this->hasTableSafely('blog_informations')) {
                return collect();
              }

              return Blog::join('blog_informations', 'blogs.id', '=', 'blog_informations.blog_id')
                ->where('blog_informations.language_id', '=', $language->id)
                ->select('blogs.image', 'blogs.created_at', 'blog_informations.title', 'blog_informations.slug')
                ->orderByDesc('blogs.created_at')
                ->limit(3)
                ->get();
            });
          }

          // get newsletter title
          if ($basicData->theme_version == 2) {
            $newsletterTitle = method_exists($language, 'newsletterSec')
              ? $this->safeFirstForTable('newsletter_sections', function () use ($language) {
                return $language->newsletterSec()->pluck('title')->first();
              })
              : null;
          }
        }

        $bex = $this->safeFirstForTable('contact_pages', function () use ($language) {
          return ContactPage::where('language_id', $language->id)->first();
        });

        $view->with('basicInfo', $basicData);
        $view->with('seo', $seo);
        $view->with('bex', $bex);
        $view->with('allLanguageInfos', $allLanguages);
        $view->with('currentLanguageInfo', $language);
        $view->with('socialMediaInfos', $socialMedias);
        $view->with('menuInfos', $menus);
        $view->with('popupInfos', $popups);
        $view->with('cookieAlertInfo', $cookieAlert);
        $view->with('footerSecStatus', $footerSectionStatus);
        $view->with('pageHeading', $pageHeading);


        if ($footerSectionStatus == 1) {
          $view->with('footerInfo', $footerData);
          $view->with('quickLinkInfos', $quickLinks);

          if ($basicData->theme_version != 3) {
            $view->with('latestBlogInfos', $blogs);
          }

          if ($basicData->theme_version == 2) {
            $view->with('newsletterTitle', $newsletterTitle);
          }
        }

      });


      // send this information to both front-end & back-end view files
      View::share(['websiteInfo' => $data]);
    }
  }

  private function loadBasicSettings(array $columns, array $defaults = [])
  {
    $payload = [];

    foreach ($columns as $column) {
      $payload[$column] = $defaults[$column] ?? null;
    }

    $availableColumns = $this->getBasicSettingsColumns();

    if (empty($availableColumns)) {
      return (object) $payload;
    }

    $selectableColumns = array_values(array_filter($columns, function ($column) use ($availableColumns) {
      return isset($availableColumns[$column]);
    }));

    if (empty($selectableColumns)) {
      return (object) $payload;
    }

    try {
      $row = Basic::query()->select($selectableColumns)->first();
    } catch (\Throwable $exception) {
      return (object) $payload;
    }

    if (!$row) {
      return (object) $payload;
    }

    foreach ($selectableColumns as $column) {
      $payload[$column] = $row->{$column};
    }

    return (object) $payload;
  }

  private function getBasicSettingsColumns(): array
  {
    if ($this->basicSettingsColumns !== null) {
      return $this->basicSettingsColumns;
    }

    try {
      if (!Schema::hasTable('basic_settings')) {
        return $this->basicSettingsColumns = [];
      }

      return $this->basicSettingsColumns = array_flip(Schema::getColumnListing('basic_settings'));
    } catch (\Throwable $exception) {
      return $this->basicSettingsColumns = [];
    }
  }

  private function hasTableSafely(string $table): bool
  {
    if ($this->tableAvailability !== null && array_key_exists($table, $this->tableAvailability)) {
      return $this->tableAvailability[$table];
    }

    try {
      $exists = Schema::hasTable($table);
    } catch (\Throwable $exception) {
      $exists = false;
    }

    $this->tableAvailability ??= [];
    $this->tableAvailability[$table] = $exists;

    return $exists;
  }

  private function safeFirstForTable(string $table, callable $callback, $default = null)
  {
    if (!$this->hasTableSafely($table)) {
      return $default;
    }

    try {
      return $callback() ?? $default;
    } catch (\Throwable $exception) {
      return $default;
    }
  }

  private function safeGetForTable(string $table, callable $callback)
  {
    if (!$this->hasTableSafely($table)) {
      return collect();
    }

    try {
      return $callback() ?? collect();
    } catch (\Throwable $exception) {
      return collect();
    }
  }

  private function resolveLanguage(): Language
  {
    $fallbackLanguage = new Language([
      'id' => 1,
      'code' => config('app.locale', 'en'),
      'direction' => 'ltr',
      'is_default' => 1,
    ]);

    if (!$this->hasTableSafely('languages')) {
      return $fallbackLanguage;
    }

    return Language::where('is_default', 1)->first()
      ?? Language::query()->orderBy('id')->first()
      ?? $fallbackLanguage;
  }
}
