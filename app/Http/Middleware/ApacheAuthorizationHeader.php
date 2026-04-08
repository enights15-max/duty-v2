<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

/**
 * Fix for Apache + mod_php not populating $_SERVER['HTTP_AUTHORIZATION'].
 *
 * Apache with mod_php strips the Authorization header from $_SERVER,
 * but makes it available via apache_request_headers(). This middleware
 * reads it from there and sets it so Laravel/Sanctum can use it.
 */
class ApacheAuthorizationHeader
{
    public function handle(Request $request, Closure $next)
    {
        if (!$request->headers->has('Authorization') && function_exists('apache_request_headers')) {
            $headers = apache_request_headers();
            if (isset($headers['Authorization'])) {
                $request->headers->set('Authorization', $headers['Authorization']);
                $_SERVER['HTTP_AUTHORIZATION'] = $headers['Authorization'];
            }
        }

        return $next($request);
    }
}
