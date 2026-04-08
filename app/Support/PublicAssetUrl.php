<?php

namespace App\Support;

class PublicAssetUrl
{
    public static function url(?string $filename, string $directory): ?string
    {
        $filename = trim((string) $filename);
        if ($filename === '') {
            return null;
        }

        if (filter_var($filename, FILTER_VALIDATE_URL)) {
            return $filename;
        }

        $directory = trim($directory, '/');
        $filename = ltrim($filename, '/');
        $relativePath = $directory . '/' . $filename;

        return is_file(public_path($relativePath)) ? asset($relativePath) : null;
    }
}
