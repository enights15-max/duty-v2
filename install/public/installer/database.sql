-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Host: localhost:8889
-- Generation Time: Nov 11, 2025 at 02:17 PM
-- Server version: 5.7.39
-- PHP Version: 8.2.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `evento`
--

-- --------------------------------------------------------

--
-- Table structure for table `about_us_sections`
--

CREATE TABLE `about_us_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `text` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `about_us_sections`
--

INSERT INTO `about_us_sections` (`id`, `language_id`, `image`, `title`, `subtitle`, `text`, `created_at`, `updated_at`) VALUES
(3, 8, '63d6263036d9d.png', 'Know more about the Culture of Events', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium euismod ligula,', '<div class=\"feature-item mt-30\" style=\"margin: 30px 0px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Free Events Host</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>\r\n<div class=\"feature-item\" style=\"margin: 0px 0px 30px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Build-in Video conference Platform</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>\r\n<div class=\"feature-item\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Connect your attendees with events</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>', '2021-12-19 06:23:27', '2023-05-20 12:00:38'),
(6, 22, '6458839f29e16.png', 'اعرف المزيد عن ثقافة الفعاليات', 'حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى', '<h4>استضافة فعاليات مجانية</h4><p>كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><h2><br></h2><h4>بناء في منصة مؤتمرات الفيديو</h4><p>ادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br></p><h4>ربط الحاضرين بالأحداث</h4><p>&nbsp;حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث<br></p>', '2023-05-08 05:07:43', '2023-05-08 05:08:27');

-- --------------------------------------------------------

--
-- Table structure for table `action_sections`
--

CREATE TABLE `action_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `background_image` varchar(255) NOT NULL,
  `first_title` varchar(255) DEFAULT NULL,
  `second_title` varchar(255) DEFAULT NULL,
  `first_button` varchar(255) DEFAULT NULL,
  `first_button_url` varchar(255) DEFAULT NULL,
  `second_button` varchar(255) DEFAULT NULL,
  `second_button_url` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `action_sections`
--

INSERT INTO `action_sections` (`id`, `language_id`, `background_image`, `first_title`, `second_title`, `first_button`, `first_button_url`, `second_button`, `second_button_url`, `image`, `created_at`, `updated_at`) VALUES
(3, 8, '61a6fe5929b63.jpg', 'Are You Ready for This Offer?', '50% Offer for Very First 50 Students and Mentors.', 'Become A Student', 'https://codecanyon.kreativdev.com/coursela/user/signup', 'All Courses', 'https://codecanyon.kreativdev.com/coursela/user/courses', '6280a19f2edad.png', '2021-11-30 22:47:21', '2022-05-15 00:45:51');

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `role_id` bigint(20) UNSIGNED DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` text,
  `address` text,
  `details` longtext,
  `password` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `role_id`, `first_name`, `last_name`, `image`, `username`, `email`, `phone`, `address`, `details`, `password`, `status`, `created_at`, `updated_at`) VALUES
(1, NULL, 'Fahad', 'Hossain', '1632736531.png', 'admin', 'fahadahmadshemul@gmail.com', '082319382109', 'Dhaka, Bangladesh', 'Lorem ipsum dolor sit, amet consectetur adipisicing elit. Aperiam exercitationem, deserunt praesentium consectetur quo neque temporibus fuga eveniet est aliquid distinctio? Magnam possimus voluptatem suscipit voluptates natus, autem officia quas?', '$2y$10$6Y4HCFAAIfqpklq2UIKhQuFetg9/LooM9m9jHdLjVs3dmc.5BMLf6', 1, NULL, '2023-01-21 12:43:45');

-- --------------------------------------------------------

--
-- Table structure for table `advertisements`
--

CREATE TABLE `advertisements` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `ad_type` varchar(255) NOT NULL,
  `resolution_type` smallint(5) UNSIGNED NOT NULL COMMENT '1 => 300 x 250, 2 => 300 x 600, 3 => 728 x 90',
  `image` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `slot` varchar(50) DEFAULT NULL,
  `views` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `advertisements`
--

INSERT INTO `advertisements` (`id`, `ad_type`, `resolution_type`, `image`, `url`, `slot`, `views`, `created_at`, `updated_at`) VALUES
(9, 'banner', 1, '64577e55b2478.png', 'https://www.lg.com/bd', NULL, 0, '2021-08-15 23:12:31', '2023-05-07 10:32:53'),
(10, 'banner', 2, '64577e6649d8a.png', 'https://www.toyota.com/', NULL, 2, '2021-08-15 23:13:44', '2023-05-07 10:33:10'),
(11, 'banner', 2, '64577e5f10164.png', 'https://www.getrentequip.com/', NULL, 1, '2021-08-15 23:15:14', '2023-05-07 10:33:03'),
(12, 'banner', 1, '64577e4d3d1b3.png', 'https://www.batabd.com/', NULL, 0, '2021-08-15 23:16:41', '2023-05-07 10:32:45'),
(14, 'banner', 3, '64577dfdeb19e.png', 'http://example.com/', NULL, 2, '2022-05-17 08:30:56', '2023-05-07 10:31:25'),
(15, 'banner', 1, '64577e476a7d2.png', 'http://example.com/', NULL, 0, '2022-05-17 08:31:36', '2023-05-07 10:32:39'),
(16, 'banner', 3, '64577dea0f0ec.png', 'https://fahad.kreativdev.com/', NULL, 0, '2022-07-18 05:47:26', '2023-05-07 10:31:06');

-- --------------------------------------------------------

--
-- Table structure for table `basic_settings`
--

CREATE TABLE `basic_settings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uniqid` int(10) UNSIGNED NOT NULL DEFAULT '12345',
  `favicon` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `website_title` varchar(255) DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `contact_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(8,5) DEFAULT NULL,
  `longitude` decimal(8,5) DEFAULT NULL,
  `theme_version` smallint(5) UNSIGNED NOT NULL,
  `base_currency_symbol` varchar(255) DEFAULT NULL,
  `base_currency_symbol_position` varchar(20) DEFAULT NULL,
  `base_currency_text` varchar(20) DEFAULT NULL,
  `base_currency_text_position` varchar(20) DEFAULT NULL,
  `base_currency_rate` decimal(8,2) DEFAULT NULL,
  `primary_color` varchar(30) DEFAULT NULL,
  `breadcrumb_overlay_color` varchar(30) DEFAULT NULL,
  `breadcrumb_overlay_opacity` decimal(4,2) DEFAULT NULL,
  `smtp_status` tinyint(4) DEFAULT NULL,
  `smtp_host` varchar(255) DEFAULT NULL,
  `smtp_port` int(11) DEFAULT NULL,
  `encryption` varchar(50) DEFAULT NULL,
  `smtp_username` varchar(255) DEFAULT NULL,
  `smtp_password` varchar(255) DEFAULT NULL,
  `from_mail` varchar(255) DEFAULT NULL,
  `from_name` varchar(255) DEFAULT NULL,
  `to_mail` varchar(255) DEFAULT NULL,
  `breadcrumb` varchar(255) DEFAULT NULL,
  `disqus_status` tinyint(3) UNSIGNED DEFAULT NULL,
  `disqus_short_name` varchar(255) DEFAULT NULL,
  `google_recaptcha_status` tinyint(4) DEFAULT NULL,
  `google_recaptcha_site_key` varchar(255) DEFAULT NULL,
  `google_recaptcha_secret_key` varchar(255) DEFAULT NULL,
  `facebook_login_status` int(11) DEFAULT '0',
  `facebook_app_id` varchar(255) DEFAULT NULL,
  `facebook_app_secret` varchar(255) DEFAULT NULL,
  `google_login_status` int(11) DEFAULT '0',
  `google_client_id` varchar(255) DEFAULT NULL,
  `google_client_secret` varchar(255) DEFAULT NULL,
  `whatsapp_status` tinyint(3) UNSIGNED DEFAULT NULL,
  `whatsapp_number` varchar(20) DEFAULT NULL,
  `whatsapp_header_title` varchar(255) DEFAULT NULL,
  `whatsapp_popup_status` tinyint(3) UNSIGNED DEFAULT NULL,
  `whatsapp_popup_message` text,
  `maintenance_img` varchar(255) DEFAULT NULL,
  `maintenance_status` tinyint(4) DEFAULT NULL,
  `maintenance_msg` text,
  `bypass_token` varchar(255) DEFAULT NULL,
  `footer_logo` varchar(255) DEFAULT NULL,
  `preloader` varchar(255) DEFAULT NULL,
  `admin_theme_version` varchar(10) NOT NULL DEFAULT 'light',
  `features_section_image` varchar(255) DEFAULT NULL,
  `testimonials_section_image` varchar(255) DEFAULT NULL,
  `course_categories_section_image` varchar(255) DEFAULT NULL,
  `notification_image` varchar(255) DEFAULT NULL,
  `google_adsense_publisher_id` varchar(255) DEFAULT NULL,
  `shop_status` tinyint(4) DEFAULT '1' COMMENT '1 - active, 0 - deactive',
  `catalog_mode` tinyint(4) DEFAULT '1' COMMENT '1 - active, 0 - deactive',
  `is_shop_rating` tinyint(4) DEFAULT '1' COMMENT '1 - active, 0 - deactive',
  `shop_guest_checkout` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1 - active, 0 - deactive',
  `shop_tax` float DEFAULT NULL,
  `tax` double(8,2) DEFAULT '0.00',
  `commission` double(8,2) DEFAULT '0.00',
  `organizer_email_verification` int(11) NOT NULL DEFAULT '0',
  `organizer_admin_approval` int(11) NOT NULL DEFAULT '0',
  `admin_approval_notice` longtext,
  `timezone` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `event_guest_checkout_status` int(11) DEFAULT '0' COMMENT '0=deactive, 1=active',
  `how_ticket_will_be_send` varchar(255) DEFAULT 'inbackground',
  `google_map_status` tinyint(4) NOT NULL DEFAULT '0',
  `google_map_api_key` varchar(255) DEFAULT NULL,
  `google_map_radius` varchar(255) DEFAULT NULL,
  `event_country_status` tinyint(4) NOT NULL DEFAULT '0',
  `event_state_status` tinyint(4) NOT NULL DEFAULT '0',
  `mobile_app_logo` varchar(255) DEFAULT NULL,
  `mobile_breadcrumb_overlay_colour` varchar(255) DEFAULT NULL,
  `mobile_breadcrumb_overlay_opacity` varchar(255) DEFAULT NULL,
  `mobile_primary_colour` varchar(255) DEFAULT NULL,
  `mobile_favicon` varchar(255) DEFAULT NULL,
  `firebase_admin_json` varchar(255) DEFAULT NULL,
  `app_google_map_status` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `basic_settings`
--

INSERT INTO `basic_settings` (`id`, `uniqid`, `favicon`, `logo`, `website_title`, `email_address`, `contact_number`, `address`, `latitude`, `longitude`, `theme_version`, `base_currency_symbol`, `base_currency_symbol_position`, `base_currency_text`, `base_currency_text_position`, `base_currency_rate`, `primary_color`, `breadcrumb_overlay_color`, `breadcrumb_overlay_opacity`, `smtp_status`, `smtp_host`, `smtp_port`, `encryption`, `smtp_username`, `smtp_password`, `from_mail`, `from_name`, `to_mail`, `breadcrumb`, `disqus_status`, `disqus_short_name`, `google_recaptcha_status`, `google_recaptcha_site_key`, `google_recaptcha_secret_key`, `facebook_login_status`, `facebook_app_id`, `facebook_app_secret`, `google_login_status`, `google_client_id`, `google_client_secret`, `whatsapp_status`, `whatsapp_number`, `whatsapp_header_title`, `whatsapp_popup_status`, `whatsapp_popup_message`, `maintenance_img`, `maintenance_status`, `maintenance_msg`, `bypass_token`, `footer_logo`, `preloader`, `admin_theme_version`, `features_section_image`, `testimonials_section_image`, `course_categories_section_image`, `notification_image`, `google_adsense_publisher_id`, `shop_status`, `catalog_mode`, `is_shop_rating`, `shop_guest_checkout`, `shop_tax`, `tax`, `commission`, `organizer_email_verification`, `organizer_admin_approval`, `admin_approval_notice`, `timezone`, `updated_at`, `event_guest_checkout_status`, `how_ticket_will_be_send`, `google_map_status`, `google_map_api_key`, `google_map_radius`, `event_country_status`, `event_state_status`, `mobile_app_logo`, `mobile_breadcrumb_overlay_colour`, `mobile_breadcrumb_overlay_opacity`, `mobile_primary_colour`, `mobile_favicon`, `firebase_admin_json`, `app_google_map_status`) VALUES
(2, 12345, '64533cea2a869.ico', '62a02a43863d9.png', 'Evento', 'demo@gmail.com', '+321-7890123', 'Los Angeles, USA', '34.05224', '-118.24368', 1, '$', 'left', 'INR', 'right', '1.00', '22B0AF', '030A15', '0.80', 1, 'smtp.gmail.com', 587, 'TLS', 'airdrop446646@gmail.com', 'fhgg eodt tryj zjqd', 'airdrop446646@gmail.com', 'Evento', '', '62d5204681dc2.jpg', 1, 'evento-6', 0, '6LcCWGgnAAAAADgP1vWv-VXVVrdIERCECIWAOThC', '6LcCWGgnAAAAAM2mM9Mbe4Y04GNZdOzu-9BQBas6', 1, '643057404544999', 'f59e1a04cc1e5ebf95d880dea77c5815', 0, '308392347627-t2eosbvgh68hvi1amq546b7iu6ndnbs4.apps.googleusercontent.com', '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', 1, '+880 1686321-356', 'Hi, there!', 1, 'If you have any issues, let us know.', '1632725312.png', 0, 'We are upgrading our site. We will come back soon. \r\nPlease stay with us.\r\nThank you.', 'secret', '62a03c82d28b0.png', '63cbb14274c51.gif', 'dark', '1633502472.jpg', '61bf1ed024d95.png', '61bf1fc25a8f6.jpg', '619b7d5e5e9df.png', '', 1, 1, 1, 1, 5, 10.00, 5.00, 1, 1, 'Your account is deactivated or pending now please get in touch with admin.', 'Europe/Vienna', '2023-05-01 09:41:21', 1, 'instant', 0, 'AIzaSyBh-Q9sZzK43b6UssN6vCDrdwgWv4NOL68', '747503', 1, 1, '68f34a282dc00.png', '4830FF', '0.9', 'FF0D3D', '68f34a282bff1.png', '68f4a0ae20bd5.json', 1);

-- --------------------------------------------------------

--
-- Table structure for table `blogs`
--

CREATE TABLE `blogs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(255) NOT NULL,
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `blogs`
--

INSERT INTO `blogs` (`id`, `image`, `serial_number`, `created_at`, `updated_at`) VALUES
(19, '6280c8d9b530c.jpg', 1, '2022-05-15 03:33:13', '2022-05-15 03:33:13'),
(20, '6280cc169c6a3.jpg', 2, '2022-05-15 03:33:13', '2022-05-15 03:47:02'),
(21, '6280cec65474f.jpg', 3, '2022-05-15 03:33:13', '2022-05-15 03:58:30'),
(22, '6280cf79b89b3.jpg', 4, '2022-05-15 03:33:13', '2022-05-15 04:01:29'),
(23, '6280d0469ef47.jpg', 5, '2022-05-15 03:33:13', '2022-05-15 04:04:54'),
(24, '6280d0d0a5182.jpg', 6, '2022-05-15 03:33:13', '2022-05-15 04:07:12');

-- --------------------------------------------------------

--
-- Table structure for table `blog_categories`
--

CREATE TABLE `blog_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL,
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `blog_categories`
--

INSERT INTO `blog_categories` (`id`, `language_id`, `name`, `slug`, `status`, `serial_number`, `created_at`, `updated_at`) VALUES
(36, 8, 'Business', 'business', 1, 1, '2021-10-12 22:51:29', '2023-05-07 10:14:18'),
(37, 8, 'Conference', 'conference', 1, 2, '2021-10-12 22:51:38', '2023-05-07 10:14:01'),
(38, 8, 'Wedding', 'wedding', 1, 3, '2021-10-12 22:51:52', '2023-05-11 04:34:57'),
(43, 8, 'Others', 'others', 1, 4, '2022-04-05 05:50:10', '2022-05-15 03:12:27'),
(49, 22, 'الأعمال', 'الأعمال', 1, 1, '2023-05-02 14:17:36', '2023-05-08 05:27:14'),
(50, 22, 'مؤتمر', 'مؤتمر', 1, 2, '2023-05-08 05:27:33', '2023-05-08 05:27:33'),
(51, 22, 'ازاله الاعشاب الضاره', 'ازاله-الاعشاب-الضاره', 1, 3, '2023-05-08 05:27:55', '2023-05-08 05:27:55'),
(52, 22, 'الاخرين', 'الاخرين', 1, 4, '2023-05-08 05:28:15', '2023-05-08 05:28:15');

-- --------------------------------------------------------

--
-- Table structure for table `blog_informations`
--

CREATE TABLE `blog_informations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `blog_category_id` bigint(20) UNSIGNED NOT NULL,
  `blog_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `blog_informations`
--

INSERT INTO `blog_informations` (`id`, `language_id`, `blog_category_id`, `blog_id`, `title`, `slug`, `author`, `content`, `meta_keywords`, `meta_description`, `created_at`, `updated_at`) VALUES
(33, 8, 36, 19, 'Morbi in sem quis dui placerat ornare. Pellentesque odio nisi', 'morbi-in-sem-quis-dui-placerat-ornare.-pellentesque-odio-nisi', 'Maximilian', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 03:33:13'),
(35, 8, 37, 20, 'Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris', 'donec-nec-justo-eget-felis-facilisis-fermentum.-aliquam-porttitor-mauris', 'Donnarumma', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 03:47:02'),
(37, 8, 38, 21, 'Phasellus ultrices nulla quis nibh. Quisque a lectus', 'phasellus-ultrices-nulla-quis-nibh.-quisque-a-lectus', 'Gianluca', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 03:58:30'),
(39, 8, 43, 22, 'Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus', 'nam-dui-mi-tincidunt-quis-accumsan-porttitor-facilisis-luctus-metus', 'Arnold', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 03:58:30'),
(41, 8, 36, 23, 'Vestibulum commodo felis quis tortor.', 'vestibulum-commodo-felis-quis-tortor.', 'Modric', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 04:04:54'),
(43, 8, 37, 24, 'Vivamus vestibulum ntulla nec ante.', 'vivamus-vestibulum-ntulla-nec-ante.', 'Karem', '<p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Donec odio. Quisque volutpat mattis eros. Nullam malesuada erat ut turpis. Suspendisse urna nibh, viverra non, semper suscipit, posuere a, pede.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Donec nec justo eget felis facilisis fermentum. Aliquam porttitor mauris sit amet orci. Aenean dignissim pellentesque felis.</p><ul><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Lorem ipsum dolor sit amet, consectetuer adipiscing elit.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Aliquam tincidunt mauris eu risus.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Vestibulum auctor dapibus neque.</li><li style=\"font-style:inherit;font-weight:inherit;font-size:18px;line-height:28px;\">Nunc dignissim risus id metus.</li></ul><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Morbi in sem quis dui placerat ornare. Pellentesque odio nisi, euismod in, pharetra a, ultricies in, diam. Sed arcu. Cras consequat.</p><p style=\"font-size:18px;line-height:26px;font-family:stolzl, sans-serif;\">Praesent dapibus, neque id cursus faucibus, tortor neque egestas auguae, eu vulputate magna eros eu erat. Aliquam erat volutpat. Nam dui mi, tincidunt quis, accumsan porttitor, facilisis luctus, metus.</p>', NULL, NULL, '2022-05-15 03:33:13', '2022-05-15 04:07:12'),
(45, 22, 50, 24, 'حكام ويتّفق بين, أم جُل النفط والإتحاد التغييرا', 'حكام-ويتّفق-بين-أم-جُل-النفط-والإتحاد-التغييرا', 'فهد أحمد شيمول', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>', NULL, NULL, '2023-05-02 14:18:47', '2023-05-08 05:34:55'),
(47, 22, 49, 19, 'أن سقوط إحكام ويتّفق بين, أم جُل النف', 'أن-سقوط-إحكام-ويتّفق-بين-أم-جُل-النف', 'ماكسيميليان', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><div><br /></div>', NULL, NULL, '2023-05-08 05:30:05', '2023-05-08 05:30:05'),
(48, 22, 50, 20, ', بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ا', '-بل-ومن-الهادي-واشتدّت-فكانت-السادس-الأراضي-فصل-ا', 'دوناروما', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p>', NULL, NULL, '2023-05-08 05:31:29', '2023-05-08 05:31:29'),
(49, 22, 51, 21, '. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضر', '.-ساعة-بمباركة-اليابان،-أما-من-وسفن-ليبين-المضي-قام-مع.-حتى-في-بأضر', 'جيانلوكا', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p>', NULL, NULL, '2023-05-08 05:32:27', '2023-05-08 05:32:27'),
(50, 22, 52, 22, 'ت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق', 'ت-فكانت-السادس-الأراضي-فصل-ان.-قد-كان-لغزو-كنقطة-بالرّغم-أن-سقوط-إحكام-ويتّفق', 'ارنولد', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p><br /></p>', NULL, NULL, '2023-05-08 05:33:18', '2023-05-08 05:33:18'),
(51, 22, 49, 23, 'تعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم ا', 'تعلّق-فعل-كل-جهة-هامش-مارد-وإقامة.-أم-بلا-وبعد-يقوم-ومضى-خطّة-لعدم-ا', 'مودريتش', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><p><br /></p><p><br /></p><p>, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>', NULL, NULL, '2023-05-08 05:34:04', '2023-05-08 05:34:04');

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `event_id` varchar(255) DEFAULT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `fname` varchar(255) DEFAULT NULL,
  `lname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `variation` text,
  `price` float(8,2) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `tax` float(8,2) DEFAULT '0.00',
  `commission` float(8,2) DEFAULT '0.00',
  `early_bird_discount` float DEFAULT NULL,
  `currencyText` varchar(255) DEFAULT NULL,
  `currencyTextPosition` varchar(255) DEFAULT NULL,
  `currencySymbol` varchar(255) DEFAULT NULL,
  `currencySymbolPosition` varchar(255) DEFAULT NULL,
  `paymentMethod` varchar(255) DEFAULT NULL,
  `gatewayType` varchar(255) DEFAULT NULL,
  `paymentStatus` varchar(255) DEFAULT NULL,
  `invoice` varchar(255) DEFAULT NULL,
  `attachmentFile` varchar(255) DEFAULT NULL,
  `event_date` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `tax_percentage` double(8,2) DEFAULT '0.00',
  `commission_percentage` double(8,2) DEFAULT '0.00',
  `scan_status` int(11) NOT NULL DEFAULT '0' COMMENT '1=scanned, 0 = not scan yet',
  `scanned_tickets` varchar(255) DEFAULT NULL,
  `conversation_id` varchar(255) DEFAULT NULL,
  `fcm_token` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`id`, `customer_id`, `booking_id`, `event_id`, `organizer_id`, `fname`, `lname`, `email`, `phone`, `country`, `state`, `city`, `zip_code`, `address`, `variation`, `price`, `quantity`, `discount`, `tax`, `commission`, `early_bird_discount`, `currencyText`, `currencyTextPosition`, `currencySymbol`, `currencySymbolPosition`, `paymentMethod`, `gatewayType`, `paymentStatus`, `invoice`, `attachmentFile`, `event_date`, `created_at`, `updated_at`, `tax_percentage`, `commission_percentage`, `scan_status`, `scanned_tickets`, `conversation_id`, `fcm_token`) VALUES
(186, '23', '690855b086dea', '91', 25, 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '[{\"ticket_id\":113,\"early_bird_dicount\":0,\"name\":\"Early bird discount ticket(fixed)\",\"qty\":1,\"price\":\"90\",\"scan_status\":0,\"unique_id\":\"cex1hWLgY\"},{\"ticket_id\":113,\"early_bird_dicount\":0,\"name\":\"Early bird discount ticket(fixed)\",\"qty\":1,\"price\":\"90\",\"scan_status\":0,\"unique_id\":\"G1Ij48c4f\"}]', 180.00, '2', 0, 18.00, 9.00, 0, 'INR', 'right', '$', 'left', 'Citibank', 'offline', 'completed', '690855b086dea.pdf', NULL, 'Sun, Jan 18, 2026 04:39pm', '2025-11-03 02:11:44', '2025-11-03 02:12:06', 10.00, 5.00, 0, NULL, NULL, NULL),
(187, 'guest', '690867924160f', '91', 25, 'Saif', 'Islam', 'saif@example.com', '01700000000', 'Bangladesh', NULL, NULL, NULL, 'dd', NULL, 100.00, '2', 0, 0.00, 5.00, 0, 'INR', 'right', '$', 'left', 'citybank', 'offline', 'pending', NULL, NULL, 'Sat, Jan 17, 2026 10:18am', '2025-11-03 03:28:02', '2025-11-03 03:28:02', 10.00, 5.00, 0, NULL, NULL, '123456'),
(188, 'guest', '690867bf032a8', '91', 25, 'Saif', 'Islam', 'saif@example.com', '01700000000', 'Bangladesh', NULL, NULL, NULL, 'dd', NULL, 100.00, '2', 0, 0.00, 5.00, 0, 'INR', 'right', '$', 'left', 'paypal', 'online', 'completed', '690867bf032a8.pdf', NULL, 'Sat, Jan 17, 2026 10:18am', '2025-11-03 03:28:47', '2025-11-03 03:28:50', 10.00, 5.00, 0, NULL, NULL, '123456'),
(191, 'guest', '6909814fd9284', '101', 23, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 0.00, '1', 0, 0.00, 0.00, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'free', '6909814fd9284.pdf', NULL, 'Fri, Jan 30, 2026 11:10am', '2025-11-03 23:30:07', '2025-11-03 23:30:12', 10.00, 5.00, 0, NULL, NULL, NULL),
(192, 'guest', '6909ab03bed94', '105', 23, 'Aileen', 'Vinson', 'tejumaby@mailinator.com', '+1 (219) 348-4469', 'Explicabo Laudantiu', 'Laudantium rerum ve', 'Non eaque irure veli', 'Non eaque irure veli', 'Ea tempore temporib', '[{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dsJCCIxHI\",\"seat_id\":268,\"seat_name\":\"RR-01\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"fveJEa37V\",\"seat_id\":269,\"seat_name\":\"RR-02\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"nGcSNK0D6\",\"seat_id\":270,\"seat_name\":\"RR-03\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"5JNbkU6el\",\"seat_id\":271,\"seat_name\":\"RR-04\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"tD5QeHU8T\",\"seat_id\":272,\"seat_name\":\"RR-05\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"z4WQMSwEe\",\"seat_id\":273,\"seat_name\":\"RR-06\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xsbedZiNK\",\"seat_id\":274,\"seat_name\":\"RR-07\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"lLo8xemI8\",\"seat_id\":275,\"seat_name\":\"RR-08\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"19rMJhKbw\",\"seat_id\":276,\"seat_name\":\"RR-09\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":189,\"early_bird_dicount\":0,\"name\":\"Evergreen Hospital\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"w8uymBVBs\",\"seat_id\":277,\"seat_name\":\"RR-10\",\"slot_id\":30,\"slot_name\":\"RR\",\"slot_unique_id\":671518},{\"ticket_id\":190,\"early_bird_dicount\":0,\"name\":\"I will create any kind of graphic design with idea\",\"qty\":1,\"price\":100,\"scan_status\":0,\"unique_id\":\"Zyt4LVV52\",\"seat_id\":281,\"seat_name\":\"B2-04\",\"slot_id\":31,\"slot_name\":1,\"slot_unique_id\":436376},{\"ticket_id\":190,\"early_bird_dicount\":0,\"name\":\"I will create any kind of graphic design with idea\",\"qty\":1,\"price\":100,\"scan_status\":0,\"unique_id\":\"yWaNjl841\",\"seat_id\":282,\"seat_name\":\"B2-05\",\"slot_id\":31,\"slot_name\":1,\"slot_unique_id\":436376}]', 200.00, '12', 0, 20.00, 10.00, 0, 'INR', 'right', '$', 'left', 'Citibank', 'offline', 'completed', '6909ab03bed94.pdf', NULL, 'Sat, Jan 17, 2026 10:18am', '2025-11-04 02:28:03', '2025-11-04 02:28:27', 10.00, 5.00, 0, NULL, NULL, NULL),
(194, 'guest', '690f3e3e47df8', '126', 23, 'Ginger', 'Vang', 'zetipicin@mailinator.com', '+1 (855) 905-5593', 'Aperiam sed laborum', 'Enim ullamco velit e', 'Totam deserunt offic', 'Totam deserunt offic', 'Voluptatem dolores e', '[{\"ticket_id\":205,\"early_bird_dicount\":0,\"name\":\"Economy\",\"qty\":1,\"price\":\"20\",\"scan_status\":0,\"unique_id\":\"xhhbfTobT\"},{\"ticket_id\":205,\"early_bird_dicount\":0,\"name\":\"Economy\",\"qty\":1,\"price\":\"20\",\"scan_status\":0,\"unique_id\":\"opT9cqF70\"},{\"ticket_id\":198,\"early_bird_dicount\":2,\"name\":\"North Preferred\",\"qty\":1,\"price\":20,\"scan_status\":0,\"unique_id\":\"57OZ3ObjT\",\"seat_id\":390,\"seat_name\":\"NZ-First-01\",\"slot_id\":49,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":3,\"name\":\"North Preferred\",\"qty\":1,\"price\":30,\"scan_status\":0,\"unique_id\":\"sDWXvoLQN\",\"seat_id\":391,\"seat_name\":\"NZ-First-02\",\"slot_id\":49,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":4,\"name\":\"North Preferred\",\"qty\":1,\"price\":40,\"scan_status\":0,\"unique_id\":\"LdjAa2U0B\",\"seat_id\":392,\"seat_name\":\"NZ-First-03\",\"slot_id\":49,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":0.9000000000000004,\"name\":\"East Preferred\",\"qty\":1,\"price\":9,\"scan_status\":0,\"unique_id\":\"RrP59U1Cq\",\"seat_id\":420,\"seat_name\":\"EZ-Sceond-04\",\"slot_id\":53,\"slot_name\":1,\"slot_unique_id\":470615},{\"ticket_id\":198,\"early_bird_dicount\":1,\"name\":\"East Preferred\",\"qty\":1,\"price\":10,\"scan_status\":0,\"unique_id\":\"af6Lk1CnT\",\"seat_id\":421,\"seat_name\":\"EZ-Sceond-05\",\"slot_id\":53,\"slot_name\":1,\"slot_unique_id\":470615},{\"ticket_id\":198,\"early_bird_dicount\":3,\"name\":\"West Preferred\",\"qty\":1,\"price\":30,\"scan_status\":0,\"unique_id\":\"vvK7bLW9o\",\"seat_id\":430,\"seat_name\":\"SZ-First-04\",\"slot_id\":54,\"slot_name\":1,\"slot_unique_id\":412059},{\"ticket_id\":198,\"early_bird_dicount\":1,\"name\":\"West Preferred\",\"qty\":1,\"price\":10,\"scan_status\":0,\"unique_id\":\"xvotVIrfo\",\"seat_id\":431,\"seat_name\":\"SZ-First-05\",\"slot_id\":54,\"slot_name\":1,\"slot_unique_id\":412059},{\"ticket_id\":198,\"early_bird_dicount\":1,\"name\":\"West Preferred\",\"qty\":1,\"price\":10,\"scan_status\":0,\"unique_id\":\"IbAYzvXCn\",\"seat_id\":429,\"seat_name\":\"SZ-First-03\",\"slot_id\":54,\"slot_name\":1,\"slot_unique_id\":412059}]', 183.10, '10', 0, 18.31, 9.16, 15.9, 'INR', 'right', '$', 'left', 'Citibank', 'offline', 'completed', '690f3e3e47df8.pdf', NULL, 'Sat, Oct 06, 2029 02:43am', '2025-11-08 07:57:34', '2025-11-08 07:58:05', 10.00, 5.00, 0, NULL, NULL, NULL),
(195, 'guest', '690f3e90ba28b', '128', 23, 'Ashton', 'Harvey', 'qaxibi@mailinator.com', '+1 (712) 722-5208', 'Anim magni voluptate', 'Sunt amet beatae qu', 'Laboris ducimus odi', 'Laboris ducimus odi', 'Quidem facilis rerum', '[{\"ticket_id\":202,\"early_bird_dicount\":0,\"name\":\"Seat Ticket\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"2ktUuWtgc\",\"seat_id\":534,\"seat_name\":\"G6-01\",\"slot_id\":103,\"slot_name\":\"G6\",\"slot_unique_id\":971199},{\"ticket_id\":202,\"early_bird_dicount\":0,\"name\":\"Seat Ticket\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"oAUVLJLDS\",\"seat_id\":535,\"seat_name\":\"G7-01\",\"slot_id\":104,\"slot_name\":\"G7\",\"slot_unique_id\":971199}]', 0.00, '2', 0, 0.00, 0.00, 0, NULL, NULL, NULL, NULL, NULL, NULL, 'free', '690f3e90ba28b.pdf', NULL, 'Sat, Jan 01, 2028 05:43pm', '2025-11-08 07:58:56', '2025-11-08 07:58:57', 10.00, 5.00, 0, NULL, NULL, NULL),
(196, '23', '691034407db32', '126', 23, 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '[{\"ticket_id\":205,\"early_bird_dicount\":0,\"name\":\"Economy\",\"qty\":1,\"price\":20,\"scan_status\":0,\"unique_id\":\"ONFbggi1G\"},{\"ticket_id\":198,\"early_bird_dicount\":1,\"name\":\"North Preferred\",\"qty\":1,\"price\":10,\"scan_status\":0,\"unique_id\":\"gxlIB74sA\",\"seat_id\":395,\"seat_name\":\"NZ-Second-01\",\"slot_id\":50,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":2,\"name\":\"North Preferred\",\"qty\":1,\"price\":20,\"scan_status\":0,\"unique_id\":\"EvjjQjANm\",\"seat_id\":396,\"seat_name\":\"NZ-Second-02\",\"slot_id\":50,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":3,\"name\":\"North Preferred\",\"qty\":1,\"price\":30,\"scan_status\":0,\"unique_id\":\"jizYH03IW\",\"seat_id\":397,\"seat_name\":\"NZ-Second-03\",\"slot_id\":50,\"slot_name\":1,\"slot_unique_id\":659237},{\"ticket_id\":198,\"early_bird_dicount\":4,\"name\":\"North Preferred\",\"qty\":1,\"price\":40,\"scan_status\":0,\"unique_id\":\"vrVBicQ73\",\"seat_id\":398,\"seat_name\":\"NZ-Second-04\",\"slot_id\":50,\"slot_name\":1,\"slot_unique_id\":659237}]', 110.00, '5', 0, 11.00, 5.50, 10, 'INR', 'right', '$', 'left', 'PayPal', 'online', 'completed', '691034407db32.pdf', NULL, 'Sat, Oct 06, 2029 02:43am', '2025-11-09 01:27:12', '2025-11-09 01:27:15', 10.00, 5.00, 0, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `cities`
--

CREATE TABLE `cities` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `state_id` mediumint(8) UNSIGNED NOT NULL,
  `state_code` varchar(255) NOT NULL,
  `country_id` mediumint(8) UNSIGNED NOT NULL,
  `country_code` char(2) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '2014-01-01 00:31:01',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `flag` tinyint(1) NOT NULL DEFAULT '1',
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Table structure for table `contact_pages`
--

CREATE TABLE `contact_pages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `contact_form_title` varchar(255) DEFAULT NULL,
  `contact_form_subtitle` text,
  `contact_addresses` text,
  `contact_numbers` varchar(255) DEFAULT NULL,
  `contact_mails` text,
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `map_zoom` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `contact_pages`
--

INSERT INTO `contact_pages` (`id`, `contact_form_title`, `contact_form_subtitle`, `contact_addresses`, `contact_numbers`, `contact_mails`, `latitude`, `longitude`, `map_zoom`, `language_id`, `created_at`, `updated_at`) VALUES
(1, 'Contact Us', 'Contact Us', 'Winooski, Virginia, United States\r\nMobile , Alaska, United States\r\nColorado Springs, Colorado , United States', '(225)571-6212,(480)529-9734', 'demo@demo.com,example@examle.com', '23.8698828', '38.804826', '-104.819859', 8, '2022-07-17 05:00:10', '2023-05-07 11:36:32'),
(3, 'اتصل بنا', 'اتصل بنا', 'وينوسكي, فيرجينيا, الولايات المتحدة\r\nموبايل , ألاسكا, الولايات المتحدة الأمريكية\r\nكولورادو سبرينغس, كولورادو , الولايات المتحدة', '(225)571-6212,(480)529-9734', 'test@gmail.com,test2@gmail.com', '38.804826', '-104.819859', '0', 22, '2022-07-17 05:00:10', '2023-05-07 11:36:43');

-- --------------------------------------------------------

--
-- Table structure for table `conversations`
--

CREATE TABLE `conversations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL COMMENT '1=user, 2=admin, 3=organizer',
  `support_ticket_id` int(11) DEFAULT NULL,
  `reply` longtext,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `conversations`
--

INSERT INTO `conversations` (`id`, `user_id`, `type`, `support_ticket_id`, `reply`, `file`, `created_at`, `updated_at`) VALUES
(16, 1, 2, 7, '<p>hi</p>', NULL, '2023-03-22 06:08:55', '2023-03-22 06:08:55'),
(17, 1, 1, 7, 'helo ami user', NULL, '2023-03-22 06:16:40', '2023-03-22 06:16:40'),
(19, 8, 2, 7, '<p>hello ami moderator bolci<br /></p>', NULL, '2023-03-22 06:21:08', '2023-03-22 06:21:08'),
(20, 8, 2, 7, '<p>admin assing to me</p>', NULL, '2023-03-22 06:28:59', '2023-03-22 06:28:59'),
(21, 1, 2, 7, '<p>yeah i assign </p>', NULL, '2023-03-22 06:29:20', '2023-03-22 06:29:20'),
(22, 1, 1, 7, 'ok i got it', NULL, '2023-03-22 06:29:38', '2023-03-22 06:29:38'),
(23, 1, 1, 7, 'this is attactment', '641aa22b1762b.zip', '2023-03-22 06:37:31', '2023-03-22 06:37:31'),
(24, 8, 2, 7, '<p>admin zip file</p>', '641aa2c717d3f.zip', '2023-03-22 06:40:07', '2023-03-22 06:40:07'),
(33, 25, 1, 9, 'hi', NULL, '2023-05-06 08:27:22', '2023-05-06 08:27:22'),
(34, 1, 2, 14, '<p>Hi.!!</p>', NULL, '2023-05-08 11:25:37', '2023-05-08 11:25:37'),
(35, 23, 1, 14, 'Hello! please let me ensure', NULL, '2023-05-08 11:26:17', '2023-05-08 11:26:17'),
(36, 1, 2, 14, '<p>we have an issue on our site. we will fixed it soon</p>Thanks</p>', NULL, '2023-05-08 11:27:01', '2023-05-08 11:27:01'),
(37, 1, 2, 12, '<p>We have successfully checked your withdrawal request.</p><p>You have given an invalid account statement. please give us a proper statement,</p><p>then we will accept your request.</p><p>Thanks</p>', NULL, '2023-05-08 11:29:57', '2023-05-08 11:29:57'),
(38, 23, 3, 12, '<p>Thanks a lot for your valuable information.</p>', NULL, '2023-05-08 11:30:44', '2023-05-08 11:30:44'),
(39, 1, 2, 16, '<p>if you have a venue event</p><p>then you have to add a ticket from manage ticket option</p><p>Thanks</p>', NULL, '2023-05-08 11:35:58', '2023-05-08 11:35:58'),
(40, 23, 3, 16, '<p>Thank you so much</p><p>now it\'s work properly</p>', NULL, '2023-05-08 11:36:47', '2023-05-08 11:36:47'),
(41, 23, 1, 13, 'hi', NULL, '2023-05-08 11:37:51', '2023-05-08 11:37:51'),
(42, 1, 2, 13, 'what was your payment method?', NULL, '2023-05-08 11:39:49', '2023-05-08 11:39:49'),
(43, 23, 1, 13, 'City Bank', NULL, '2023-05-08 11:40:06', '2023-05-08 11:40:06'),
(44, 1, 2, 13, '<p>Please give the proper info and book again</p><p>Thanks</p>', NULL, '2023-05-08 11:40:25', '2023-05-08 11:40:25'),
(45, 23, 1, 13, 'Thanks.', NULL, '2023-05-08 11:40:42', '2023-05-08 11:40:42'),
(48, 1, 2, 18, '<p>dfsafaf</p>', NULL, '2023-09-23 09:35:55', '2023-09-23 09:35:55'),
(49, 1, 2, 19, '<p>rrr</p>', NULL, '2025-10-12 23:45:49', '2025-10-12 23:45:49'),
(50, 33, 1, 19, 'rrrrr', NULL, '2025-10-12 23:46:45', '2025-10-12 23:46:45'),
(51, 1, 2, 20, '<p>The test is successfull.</p>', NULL, '2025-10-13 00:50:04', '2025-10-13 00:50:04'),
(52, 34, 1, 20, 'Ok', NULL, '2025-10-13 00:50:18', '2025-10-13 00:50:18'),
(53, 1, 2, 20, '<p>Closing the ticket</p>', NULL, '2025-10-13 00:50:45', '2025-10-13 00:50:45'),
(54, 1, 2, 21, '<p>Success</p>', NULL, '2025-10-13 00:51:36', '2025-10-13 00:51:36'),
(55, 35, 1, 21, 'ok', NULL, '2025-10-13 00:51:46', '2025-10-13 00:51:46'),
(56, 1, 2, 23, '<p>Test is successfull.</p>', NULL, '2025-10-13 05:25:21', '2025-10-13 05:25:21'),
(57, 34, 1, 23, 'Good News!', NULL, '2025-10-13 05:25:38', '2025-10-13 05:25:38'),
(58, 34, 1, 23, '.', NULL, '2025-10-13 05:25:53', '2025-10-13 05:25:53');

-- --------------------------------------------------------

--
-- Table structure for table `cookie_alerts`
--

CREATE TABLE `cookie_alerts` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `cookie_alert_status` tinyint(3) UNSIGNED NOT NULL,
  `cookie_alert_btn_text` varchar(255) NOT NULL,
  `cookie_alert_text` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `cookie_alerts`
--

INSERT INTO `cookie_alerts` (`id`, `language_id`, `cookie_alert_status`, `cookie_alert_btn_text`, `cookie_alert_text`, `created_at`, `updated_at`) VALUES
(1, 8, 1, 'I Agree', '<p>We use cookies to give you the best online experience.<br>By continuing to browse the site you are agreeing to our use of cookies.</p>', '2021-06-02 06:25:54', '2023-05-20 12:07:47'),
(3, 22, 1, 'أوافق', '<p><br></p><p>نحن نستخدم ملفات تعريف الارتباط لنمنحك أفضل تجربة عبر الإنترنت.</p><p>من خلال الاستمرار في تصفح الموقع ، فإنك توافق على استخدامنا لملفات تعريف الارتباط.</p>', '2023-05-08 05:58:24', '2023-05-08 05:58:32');

-- --------------------------------------------------------

--
-- Table structure for table `countries`
--

CREATE TABLE `countries` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `iso3` char(3) DEFAULT NULL,
  `numeric_code` char(3) DEFAULT NULL,
  `iso2` char(2) DEFAULT NULL,
  `phonecode` varchar(255) DEFAULT NULL,
  `capital` varchar(255) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `currency_name` varchar(255) DEFAULT NULL,
  `currency_symbol` varchar(255) DEFAULT NULL,
  `tld` varchar(255) DEFAULT NULL,
  `native` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `subregion` varchar(255) DEFAULT NULL,
  `timezones` text,
  `translations` text,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `emoji` varchar(191) DEFAULT NULL,
  `emojiU` varchar(191) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `flag` tinyint(1) NOT NULL DEFAULT '1',
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `countries`
--

INSERT INTO `countries` (`id`, `name`, `iso3`, `numeric_code`, `iso2`, `phonecode`, `capital`, `currency`, `currency_name`, `currency_symbol`, `tld`, `native`, `region`, `subregion`, `timezones`, `translations`, `latitude`, `longitude`, `emoji`, `emojiU`, `created_at`, `updated_at`, `flag`, `wikiDataId`) VALUES
(1, 'Afghanistan', 'AFG', '004', 'AF', '93', 'Kabul', 'AFN', 'Afghan afghani', '؋', '.af', 'افغانستان', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Kabul\",\"gmtOffset\":16200,\"gmtOffsetName\":\"UTC+04:30\",\"abbreviation\":\"AFT\",\"tzName\":\"Afghanistan Time\"}]', '{\"kr\":\"아프가니스탄\",\"br\":\"Afeganistão\",\"pt\":\"Afeganistão\",\"nl\":\"Afghanistan\",\"hr\":\"Afganistan\",\"fa\":\"افغانستان\",\"de\":\"Afghanistan\",\"es\":\"Afganistán\",\"fr\":\"Afghanistan\",\"ja\":\"アフガニスタン\",\"it\":\"Afghanistan\",\"cn\":\"阿富汗\",\"tr\":\"Afganistan\"}', '33.00000000', '65.00000000', '', 'U+1F1E6 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q889'),
(2, 'Aland Islands', 'ALA', '248', 'AX', '+358-18', 'Mariehamn', 'EUR', 'Euro', '€', '.ax', 'Åland', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Mariehamn\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"올란드 제도\",\"br\":\"Ilhas de Aland\",\"pt\":\"Ilhas de Aland\",\"nl\":\"Ålandeilanden\",\"hr\":\"Ålandski otoci\",\"fa\":\"جزایر الند\",\"de\":\"Åland\",\"es\":\"Alandia\",\"fr\":\"Åland\",\"ja\":\"オーランド諸島\",\"it\":\"Isole Aland\",\"cn\":\"奥兰群岛\",\"tr\":\"Åland Adalari\"}', '60.11666700', '19.90000000', '', 'U+1F1E6 U+1F1FD', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, NULL),
(3, 'Albania', 'ALB', '008', 'AL', '355', 'Tirana', 'ALL', 'Albanian lek', 'Lek', '.al', 'Shqipëria', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Tirane\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"알바니아\",\"br\":\"Albânia\",\"pt\":\"Albânia\",\"nl\":\"Albanië\",\"hr\":\"Albanija\",\"fa\":\"آلبانی\",\"de\":\"Albanien\",\"es\":\"Albania\",\"fr\":\"Albanie\",\"ja\":\"アルバニア\",\"it\":\"Albania\",\"cn\":\"阿尔巴尼亚\",\"tr\":\"Arnavutluk\"}', '41.00000000', '20.00000000', '', 'U+1F1E6 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q222'),
(4, 'Algeria', 'DZA', '012', 'DZ', '213', 'Algiers', 'DZD', 'Algerian dinar', 'دج', '.dz', 'الجزائر', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Algiers\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"알제리\",\"br\":\"Argélia\",\"pt\":\"Argélia\",\"nl\":\"Algerije\",\"hr\":\"Alžir\",\"fa\":\"الجزایر\",\"de\":\"Algerien\",\"es\":\"Argelia\",\"fr\":\"Algérie\",\"ja\":\"アルジェリア\",\"it\":\"Algeria\",\"cn\":\"阿尔及利亚\",\"tr\":\"Cezayir\"}', '28.00000000', '3.00000000', '', 'U+1F1E9 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q262'),
(5, 'American Samoa', 'ASM', '016', 'AS', '+1-684', 'Pago Pago', 'USD', 'US Dollar', '$', '.as', 'American Samoa', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Pago_Pago\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"SST\",\"tzName\":\"Samoa Standard Time\"}]', '{\"kr\":\"아메리칸사모아\",\"br\":\"Samoa Americana\",\"pt\":\"Samoa Americana\",\"nl\":\"Amerikaans Samoa\",\"hr\":\"Američka Samoa\",\"fa\":\"ساموآی آمریکا\",\"de\":\"Amerikanisch-Samoa\",\"es\":\"Samoa Americana\",\"fr\":\"Samoa américaines\",\"ja\":\"アメリカ領サモア\",\"it\":\"Samoa Americane\",\"cn\":\"美属萨摩亚\",\"tr\":\"Amerikan Samoasi\"}', '-14.33333333', '-170.00000000', '', 'U+1F1E6 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, NULL),
(6, 'Andorra', 'AND', '020', 'AD', '376', 'Andorra la Vella', 'EUR', 'Euro', '€', '.ad', 'Andorra', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Andorra\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"안도라\",\"br\":\"Andorra\",\"pt\":\"Andorra\",\"nl\":\"Andorra\",\"hr\":\"Andora\",\"fa\":\"آندورا\",\"de\":\"Andorra\",\"es\":\"Andorra\",\"fr\":\"Andorre\",\"ja\":\"アンドラ\",\"it\":\"Andorra\",\"cn\":\"安道尔\",\"tr\":\"Andorra\"}', '42.50000000', '1.50000000', '', 'U+1F1E6 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q228'),
(7, 'Angola', 'AGO', '024', 'AO', '244', 'Luanda', 'AOA', 'Angolan kwanza', 'Kz', '.ao', 'Angola', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Luanda\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"앙골라\",\"br\":\"Angola\",\"pt\":\"Angola\",\"nl\":\"Angola\",\"hr\":\"Angola\",\"fa\":\"آنگولا\",\"de\":\"Angola\",\"es\":\"Angola\",\"fr\":\"Angola\",\"ja\":\"アンゴラ\",\"it\":\"Angola\",\"cn\":\"安哥拉\",\"tr\":\"Angola\"}', '-12.50000000', '18.50000000', '', 'U+1F1E6 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q916'),
(8, 'Anguilla', 'AIA', '660', 'AI', '+1-264', 'The Valley', 'XCD', 'East Caribbean dollar', '$', '.ai', 'Anguilla', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"앵귈라\",\"br\":\"Anguila\",\"pt\":\"Anguila\",\"nl\":\"Anguilla\",\"hr\":\"Angvila\",\"fa\":\"آنگویلا\",\"de\":\"Anguilla\",\"es\":\"Anguilla\",\"fr\":\"Anguilla\",\"ja\":\"アンギラ\",\"it\":\"Anguilla\",\"cn\":\"安圭拉\",\"tr\":\"Anguilla\"}', '18.25000000', '-63.16666666', '', 'U+1F1E6 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, NULL),
(9, 'Antarctica', 'ATA', '010', 'AQ', '672', '', 'AAD', 'Antarctican dollar', '$', '.aq', 'Antarctica', 'Polar', '', '[{\"zoneName\":\"Antarctica/Casey\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AWST\",\"tzName\":\"Australian Western Standard Time\"},{\"zoneName\":\"Antarctica/Davis\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"DAVT\",\"tzName\":\"Davis Time\"},{\"zoneName\":\"Antarctica/DumontDUrville\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"DDUT\",\"tzName\":\"Dumont d\'Urville Time\"},{\"zoneName\":\"Antarctica/Mawson\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MAWT\",\"tzName\":\"Mawson Station Time\"},{\"zoneName\":\"Antarctica/McMurdo\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"NZDT\",\"tzName\":\"New Zealand Daylight Time\"},{\"zoneName\":\"Antarctica/Palmer\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"Antarctica/Rothera\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ROTT\",\"tzName\":\"Rothera Research Station Time\"},{\"zoneName\":\"Antarctica/Syowa\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"SYOT\",\"tzName\":\"Showa Station Time\"},{\"zoneName\":\"Antarctica/Troll\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"},{\"zoneName\":\"Antarctica/Vostok\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"VOST\",\"tzName\":\"Vostok Station Time\"}]', '{\"kr\":\"남극\",\"br\":\"Antártida\",\"pt\":\"Antárctida\",\"nl\":\"Antarctica\",\"hr\":\"Antarktika\",\"fa\":\"جنوبگان\",\"de\":\"Antarktika\",\"es\":\"Antártida\",\"fr\":\"Antarctique\",\"ja\":\"南極大陸\",\"it\":\"Antartide\",\"cn\":\"南极洲\",\"tr\":\"Antartika\"}', '-74.65000000', '4.48000000', '', 'U+1F1E6 U+1F1F6', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, NULL),
(10, 'Antigua And Barbuda', 'ATG', '028', 'AG', '+1-268', 'St. John\'s', 'XCD', 'Eastern Caribbean dollar', '$', '.ag', 'Antigua and Barbuda', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Antigua\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"앤티가 바부다\",\"br\":\"Antígua e Barbuda\",\"pt\":\"Antígua e Barbuda\",\"nl\":\"Antigua en Barbuda\",\"hr\":\"Antigva i Barbuda\",\"fa\":\"آنتیگوا و باربودا\",\"de\":\"Antigua und Barbuda\",\"es\":\"Antigua y Barbuda\",\"fr\":\"Antigua-et-Barbuda\",\"ja\":\"アンティグア・バーブーダ\",\"it\":\"Antigua e Barbuda\",\"cn\":\"安提瓜和巴布达\",\"tr\":\"Antigua Ve Barbuda\"}', '17.05000000', '-61.80000000', '', 'U+1F1E6 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q781'),
(11, 'Argentina', 'ARG', '032', 'AR', '54', 'Buenos Aires', 'ARS', 'Argentine peso', '$', '.ar', 'Argentina', 'Americas', 'South America', '[{\"zoneName\":\"America/Argentina/Buenos_Aires\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Catamarca\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Cordoba\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Jujuy\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/La_Rioja\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Mendoza\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Rio_Gallegos\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Salta\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/San_Juan\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/San_Luis\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Tucuman\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Ushuaia\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"}]', '{\"kr\":\"아르헨티나\",\"br\":\"Argentina\",\"pt\":\"Argentina\",\"nl\":\"Argentinië\",\"hr\":\"Argentina\",\"fa\":\"آرژانتین\",\"de\":\"Argentinien\",\"es\":\"Argentina\",\"fr\":\"Argentine\",\"ja\":\"アルゼンチン\",\"it\":\"Argentina\",\"cn\":\"阿根廷\",\"tr\":\"Arjantin\"}', '-34.00000000', '-64.00000000', '', 'U+1F1E6 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q414'),
(12, 'Armenia', 'ARM', '051', 'AM', '374', 'Yerevan', 'AMD', 'Armenian dram', '֏', '.am', 'Հայաստան', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Yerevan\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Armenia Time\"}]', '{\"kr\":\"아르메니아\",\"br\":\"Armênia\",\"pt\":\"Arménia\",\"nl\":\"Armenië\",\"hr\":\"Armenija\",\"fa\":\"ارمنستان\",\"de\":\"Armenien\",\"es\":\"Armenia\",\"fr\":\"Arménie\",\"ja\":\"アルメニア\",\"it\":\"Armenia\",\"cn\":\"亚美尼亚\",\"tr\":\"Ermenistan\"}', '40.00000000', '45.00000000', '', 'U+1F1E6 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q399'),
(13, 'Aruba', 'ABW', '533', 'AW', '297', 'Oranjestad', 'AWG', 'Aruban florin', 'ƒ', '.aw', 'Aruba', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Aruba\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"아루바\",\"br\":\"Aruba\",\"pt\":\"Aruba\",\"nl\":\"Aruba\",\"hr\":\"Aruba\",\"fa\":\"آروبا\",\"de\":\"Aruba\",\"es\":\"Aruba\",\"fr\":\"Aruba\",\"ja\":\"アルバ\",\"it\":\"Aruba\",\"cn\":\"阿鲁巴\",\"tr\":\"Aruba\"}', '12.50000000', '-69.96666666', '', 'U+1F1E6 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, NULL),
(14, 'Australia', 'AUS', '036', 'AU', '61', 'Canberra', 'AUD', 'Australian dollar', '$', '.au', 'Australia', 'Oceania', 'Australia and New Zealand', '[{\"zoneName\":\"Antarctica/Macquarie\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"MIST\",\"tzName\":\"Macquarie Island Station Time\"},{\"zoneName\":\"Australia/Adelaide\",\"gmtOffset\":37800,\"gmtOffsetName\":\"UTC+10:30\",\"abbreviation\":\"ACDT\",\"tzName\":\"Australian Central Daylight Saving Time\"},{\"zoneName\":\"Australia/Brisbane\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"AEST\",\"tzName\":\"Australian Eastern Standard Time\"},{\"zoneName\":\"Australia/Broken_Hill\",\"gmtOffset\":37800,\"gmtOffsetName\":\"UTC+10:30\",\"abbreviation\":\"ACDT\",\"tzName\":\"Australian Central Daylight Saving Time\"},{\"zoneName\":\"Australia/Currie\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Darwin\",\"gmtOffset\":34200,\"gmtOffsetName\":\"UTC+09:30\",\"abbreviation\":\"ACST\",\"tzName\":\"Australian Central Standard Time\"},{\"zoneName\":\"Australia/Eucla\",\"gmtOffset\":31500,\"gmtOffsetName\":\"UTC+08:45\",\"abbreviation\":\"ACWST\",\"tzName\":\"Australian Central Western Standard Time (Unofficial)\"},{\"zoneName\":\"Australia/Hobart\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Lindeman\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"AEST\",\"tzName\":\"Australian Eastern Standard Time\"},{\"zoneName\":\"Australia/Lord_Howe\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"LHST\",\"tzName\":\"Lord Howe Summer Time\"},{\"zoneName\":\"Australia/Melbourne\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Perth\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"AWST\",\"tzName\":\"Australian Western Standard Time\"},{\"zoneName\":\"Australia/Sydney\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"}]', '{\"kr\":\"호주\",\"br\":\"Austrália\",\"pt\":\"Austrália\",\"nl\":\"Australië\",\"hr\":\"Australija\",\"fa\":\"استرالیا\",\"de\":\"Australien\",\"es\":\"Australia\",\"fr\":\"Australie\",\"ja\":\"オーストラリア\",\"it\":\"Australia\",\"cn\":\"澳大利亚\",\"tr\":\"Avustralya\"}', '-27.00000000', '133.00000000', '', 'U+1F1E6 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q408'),
(15, 'Austria', 'AUT', '040', 'AT', '43', 'Vienna', 'EUR', 'Euro', '€', '.at', 'Österreich', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Vienna\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"오스트리아\",\"br\":\"áustria\",\"pt\":\"áustria\",\"nl\":\"Oostenrijk\",\"hr\":\"Austrija\",\"fa\":\"اتریش\",\"de\":\"Österreich\",\"es\":\"Austria\",\"fr\":\"Autriche\",\"ja\":\"オーストリア\",\"it\":\"Austria\",\"cn\":\"奥地利\",\"tr\":\"Avusturya\"}', '47.33333333', '13.33333333', '', 'U+1F1E6 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q40'),
(16, 'Azerbaijan', 'AZE', '031', 'AZ', '994', 'Baku', 'AZN', 'Azerbaijani manat', 'm', '.az', 'Azərbaycan', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Baku\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"AZT\",\"tzName\":\"Azerbaijan Time\"}]', '{\"kr\":\"아제르바이잔\",\"br\":\"Azerbaijão\",\"pt\":\"Azerbaijão\",\"nl\":\"Azerbeidzjan\",\"hr\":\"Azerbajdžan\",\"fa\":\"آذربایجان\",\"de\":\"Aserbaidschan\",\"es\":\"Azerbaiyán\",\"fr\":\"Azerbaïdjan\",\"ja\":\"アゼルバイジャン\",\"it\":\"Azerbaijan\",\"cn\":\"阿塞拜疆\",\"tr\":\"Azerbaycan\"}', '40.50000000', '47.50000000', '', 'U+1F1E6 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q227'),
(17, 'The Bahamas', 'BHS', '044', 'BS', '+1-242', 'Nassau', 'BSD', 'Bahamian dollar', 'B$', '.bs', 'Bahamas', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Nassau\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America)\"}]', '{\"kr\":\"바하마\",\"br\":\"Bahamas\",\"pt\":\"Baamas\",\"nl\":\"Bahama’s\",\"hr\":\"Bahami\",\"fa\":\"باهاما\",\"de\":\"Bahamas\",\"es\":\"Bahamas\",\"fr\":\"Bahamas\",\"ja\":\"バハマ\",\"it\":\"Bahamas\",\"cn\":\"巴哈马\",\"tr\":\"Bahamalar\"}', '24.25000000', '-76.00000000', '', 'U+1F1E7 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:06:00', 1, 'Q778'),
(18, 'Bahrain', 'BHR', '048', 'BH', '973', 'Manama', 'BHD', 'Bahraini dinar', '.د.ب', '.bh', '‏البحرين', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Bahrain\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"바레인\",\"br\":\"Bahrein\",\"pt\":\"Barém\",\"nl\":\"Bahrein\",\"hr\":\"Bahrein\",\"fa\":\"بحرین\",\"de\":\"Bahrain\",\"es\":\"Bahrein\",\"fr\":\"Bahreïn\",\"ja\":\"バーレーン\",\"it\":\"Bahrein\",\"cn\":\"巴林\",\"tr\":\"Bahreyn\"}', '26.00000000', '50.55000000', '', 'U+1F1E7 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q398'),
(19, 'Bangladesh', 'BGD', '050', 'BD', '880', 'Dhaka', 'BDT', 'Bangladeshi taka', '৳', '.bd', 'Bangladesh', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Dhaka\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"BDT\",\"tzName\":\"Bangladesh Standard Time\"}]', '{\"kr\":\"방글라데시\",\"br\":\"Bangladesh\",\"pt\":\"Bangladeche\",\"nl\":\"Bangladesh\",\"hr\":\"Bangladeš\",\"fa\":\"بنگلادش\",\"de\":\"Bangladesch\",\"es\":\"Bangladesh\",\"fr\":\"Bangladesh\",\"ja\":\"バングラデシュ\",\"it\":\"Bangladesh\",\"cn\":\"孟加拉\",\"tr\":\"Bangladeş\"}', '24.00000000', '90.00000000', '', 'U+1F1E7 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q902'),
(20, 'Barbados', 'BRB', '052', 'BB', '+1-246', 'Bridgetown', 'BBD', 'Barbadian dollar', 'Bds$', '.bb', 'Barbados', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Barbados\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"바베이도스\",\"br\":\"Barbados\",\"pt\":\"Barbados\",\"nl\":\"Barbados\",\"hr\":\"Barbados\",\"fa\":\"باربادوس\",\"de\":\"Barbados\",\"es\":\"Barbados\",\"fr\":\"Barbade\",\"ja\":\"バルバドス\",\"it\":\"Barbados\",\"cn\":\"巴巴多斯\",\"tr\":\"Barbados\"}', '13.16666666', '-59.53333333', '', 'U+1F1E7 U+1F1E7', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q244'),
(21, 'Belarus', 'BLR', '112', 'BY', '375', 'Minsk', 'BYN', 'Belarusian ruble', 'Br', '.by', 'Белару́сь', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Minsk\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"}]', '{\"kr\":\"벨라루스\",\"br\":\"Bielorrússia\",\"pt\":\"Bielorrússia\",\"nl\":\"Wit-Rusland\",\"hr\":\"Bjelorusija\",\"fa\":\"بلاروس\",\"de\":\"Weißrussland\",\"es\":\"Bielorrusia\",\"fr\":\"Biélorussie\",\"ja\":\"ベラルーシ\",\"it\":\"Bielorussia\",\"cn\":\"白俄罗斯\",\"tr\":\"Belarus\"}', '53.00000000', '28.00000000', '', 'U+1F1E7 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q184'),
(22, 'Belgium', 'BEL', '056', 'BE', '32', 'Brussels', 'EUR', 'Euro', '€', '.be', 'België', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Brussels\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"벨기에\",\"br\":\"Bélgica\",\"pt\":\"Bélgica\",\"nl\":\"België\",\"hr\":\"Belgija\",\"fa\":\"بلژیک\",\"de\":\"Belgien\",\"es\":\"Bélgica\",\"fr\":\"Belgique\",\"ja\":\"ベルギー\",\"it\":\"Belgio\",\"cn\":\"比利时\",\"tr\":\"Belçika\"}', '50.83333333', '4.00000000', '', 'U+1F1E7 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q31'),
(23, 'Belize', 'BLZ', '084', 'BZ', '501', 'Belmopan', 'BZD', 'Belize dollar', '$', '.bz', 'Belize', 'Americas', 'Central America', '[{\"zoneName\":\"America/Belize\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America)\"}]', '{\"kr\":\"벨리즈\",\"br\":\"Belize\",\"pt\":\"Belize\",\"nl\":\"Belize\",\"hr\":\"Belize\",\"fa\":\"بلیز\",\"de\":\"Belize\",\"es\":\"Belice\",\"fr\":\"Belize\",\"ja\":\"ベリーズ\",\"it\":\"Belize\",\"cn\":\"伯利兹\",\"tr\":\"Belize\"}', '17.25000000', '-88.75000000', '', 'U+1F1E7 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q242'),
(24, 'Benin', 'BEN', '204', 'BJ', '229', 'Porto-Novo', 'XOF', 'West African CFA franc', 'CFA', '.bj', 'Bénin', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Porto-Novo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"베냉\",\"br\":\"Benin\",\"pt\":\"Benim\",\"nl\":\"Benin\",\"hr\":\"Benin\",\"fa\":\"بنین\",\"de\":\"Benin\",\"es\":\"Benín\",\"fr\":\"Bénin\",\"ja\":\"ベナン\",\"it\":\"Benin\",\"cn\":\"贝宁\",\"tr\":\"Benin\"}', '9.50000000', '2.25000000', '', 'U+1F1E7 U+1F1EF', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q962'),
(25, 'Bermuda', 'BMU', '060', 'BM', '+1-441', 'Hamilton', 'BMD', 'Bermudian dollar', '$', '.bm', 'Bermuda', 'Americas', 'Northern America', '[{\"zoneName\":\"Atlantic/Bermuda\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"버뮤다\",\"br\":\"Bermudas\",\"pt\":\"Bermudas\",\"nl\":\"Bermuda\",\"hr\":\"Bermudi\",\"fa\":\"برمودا\",\"de\":\"Bermuda\",\"es\":\"Bermudas\",\"fr\":\"Bermudes\",\"ja\":\"バミューダ\",\"it\":\"Bermuda\",\"cn\":\"百慕大\",\"tr\":\"Bermuda\"}', '32.33333333', '-64.75000000', '', 'U+1F1E7 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(26, 'Bhutan', 'BTN', '064', 'BT', '975', 'Thimphu', 'BTN', 'Bhutanese ngultrum', 'Nu.', '.bt', 'ʼbrug-yul', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Thimphu\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"BTT\",\"tzName\":\"Bhutan Time\"}]', '{\"kr\":\"부탄\",\"br\":\"Butão\",\"pt\":\"Butão\",\"nl\":\"Bhutan\",\"hr\":\"Butan\",\"fa\":\"بوتان\",\"de\":\"Bhutan\",\"es\":\"Bután\",\"fr\":\"Bhoutan\",\"ja\":\"ブータン\",\"it\":\"Bhutan\",\"cn\":\"不丹\",\"tr\":\"Butan\"}', '27.50000000', '90.50000000', '', 'U+1F1E7 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q917'),
(27, 'Bolivia', 'BOL', '068', 'BO', '591', 'Sucre', 'BOB', 'Bolivian boliviano', 'Bs.', '.bo', 'Bolivia', 'Americas', 'South America', '[{\"zoneName\":\"America/La_Paz\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"BOT\",\"tzName\":\"Bolivia Time\"}]', '{\"kr\":\"볼리비아\",\"br\":\"Bolívia\",\"pt\":\"Bolívia\",\"nl\":\"Bolivia\",\"hr\":\"Bolivija\",\"fa\":\"بولیوی\",\"de\":\"Bolivien\",\"es\":\"Bolivia\",\"fr\":\"Bolivie\",\"ja\":\"ボリビア多民族国\",\"it\":\"Bolivia\",\"cn\":\"玻利维亚\",\"tr\":\"Bolivya\"}', '-17.00000000', '-65.00000000', '', 'U+1F1E7 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q750'),
(28, 'Bosnia and Herzegovina', 'BIH', '070', 'BA', '387', 'Sarajevo', 'BAM', 'Bosnia and Herzegovina convertible mark', 'KM', '.ba', 'Bosna i Hercegovina', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Sarajevo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"보스니아 헤르체고비나\",\"br\":\"Bósnia e Herzegovina\",\"pt\":\"Bósnia e Herzegovina\",\"nl\":\"Bosnië en Herzegovina\",\"hr\":\"Bosna i Hercegovina\",\"fa\":\"بوسنی و هرزگوین\",\"de\":\"Bosnien und Herzegowina\",\"es\":\"Bosnia y Herzegovina\",\"fr\":\"Bosnie-Herzégovine\",\"ja\":\"ボスニア・ヘルツェゴビナ\",\"it\":\"Bosnia ed Erzegovina\",\"cn\":\"波斯尼亚和黑塞哥维那\",\"tr\":\"Bosna Hersek\"}', '44.00000000', '18.00000000', '', 'U+1F1E7 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q225'),
(29, 'Botswana', 'BWA', '072', 'BW', '267', 'Gaborone', 'BWP', 'Botswana pula', 'P', '.bw', 'Botswana', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Africa/Gaborone\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"보츠와나\",\"br\":\"Botsuana\",\"pt\":\"Botsuana\",\"nl\":\"Botswana\",\"hr\":\"Bocvana\",\"fa\":\"بوتسوانا\",\"de\":\"Botswana\",\"es\":\"Botswana\",\"fr\":\"Botswana\",\"ja\":\"ボツワナ\",\"it\":\"Botswana\",\"cn\":\"博茨瓦纳\",\"tr\":\"Botsvana\"}', '-22.00000000', '24.00000000', '', 'U+1F1E7 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q963'),
(30, 'Bouvet Island', 'BVT', '074', 'BV', '0055', '', 'NOK', 'Norwegian Krone', 'kr', '.bv', 'Bouvetøya', '', '', '[{\"zoneName\":\"Europe/Oslo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"부벳 섬\",\"br\":\"Ilha Bouvet\",\"pt\":\"Ilha Bouvet\",\"nl\":\"Bouveteiland\",\"hr\":\"Otok Bouvet\",\"fa\":\"جزیره بووه\",\"de\":\"Bouvetinsel\",\"es\":\"Isla Bouvet\",\"fr\":\"Île Bouvet\",\"ja\":\"ブーベ島\",\"it\":\"Isola Bouvet\",\"cn\":\"布维岛\",\"tr\":\"Bouvet Adasi\"}', '-54.43333333', '3.40000000', '', 'U+1F1E7 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(31, 'Brazil', 'BRA', '076', 'BR', '55', 'Brasilia', 'BRL', 'Brazilian real', 'R$', '.br', 'Brasil', 'Americas', 'South America', '[{\"zoneName\":\"America/Araguaina\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Bahia\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Belem\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Boa_Vista\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Campo_Grande\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Cuiaba\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasilia Time\"},{\"zoneName\":\"America/Eirunepe\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ACT\",\"tzName\":\"Acre Time\"},{\"zoneName\":\"America/Fortaleza\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Maceio\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Manaus\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)\"},{\"zoneName\":\"America/Noronha\",\"gmtOffset\":-7200,\"gmtOffsetName\":\"UTC-02:00\",\"abbreviation\":\"FNT\",\"tzName\":\"Fernando de Noronha Time\"},{\"zoneName\":\"America/Porto_Velho\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Recife\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Rio_Branco\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ACT\",\"tzName\":\"Acre Time\"},{\"zoneName\":\"America/Santarem\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Sao_Paulo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"}]', '{\"kr\":\"브라질\",\"br\":\"Brasil\",\"pt\":\"Brasil\",\"nl\":\"Brazilië\",\"hr\":\"Brazil\",\"fa\":\"برزیل\",\"de\":\"Brasilien\",\"es\":\"Brasil\",\"fr\":\"Brésil\",\"ja\":\"ブラジル\",\"it\":\"Brasile\",\"cn\":\"巴西\",\"tr\":\"Brezilya\"}', '-10.00000000', '-55.00000000', '', 'U+1F1E7 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q155'),
(32, 'British Indian Ocean Territory', 'IOT', '086', 'IO', '246', 'Diego Garcia', 'USD', 'United States dollar', '$', '.io', 'British Indian Ocean Territory', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Chagos\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"IOT\",\"tzName\":\"Indian Ocean Time\"}]', '{\"kr\":\"영국령 인도양 지역\",\"br\":\"Território Britânico do Oceano íÍdico\",\"pt\":\"Território Britânico do Oceano Índico\",\"nl\":\"Britse Gebieden in de Indische Oceaan\",\"hr\":\"Britanski Indijskooceanski teritorij\",\"fa\":\"قلمرو بریتانیا در اقیانوس هند\",\"de\":\"Britisches Territorium im Indischen Ozean\",\"es\":\"Territorio Británico del Océano Índico\",\"fr\":\"Territoire britannique de l\'océan Indien\",\"ja\":\"イギリス領インド洋地域\",\"it\":\"Territorio britannico dell\'oceano indiano\",\"cn\":\"英属印度洋领地\",\"tr\":\"Britanya Hint Okyanusu Topraklari\"}', '-6.00000000', '71.50000000', '', 'U+1F1EE U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(33, 'Brunei', 'BRN', '096', 'BN', '673', 'Bandar Seri Begawan', 'BND', 'Brunei dollar', 'B$', '.bn', 'Negara Brunei Darussalam', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Brunei\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"BNT\",\"tzName\":\"Brunei Darussalam Time\"}]', '{\"kr\":\"브루나이\",\"br\":\"Brunei\",\"pt\":\"Brunei\",\"nl\":\"Brunei\",\"hr\":\"Brunej\",\"fa\":\"برونئی\",\"de\":\"Brunei\",\"es\":\"Brunei\",\"fr\":\"Brunei\",\"ja\":\"ブルネイ・ダルサラーム\",\"it\":\"Brunei\",\"cn\":\"文莱\",\"tr\":\"Brunei\"}', '4.50000000', '114.66666666', '', 'U+1F1E7 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q921'),
(34, 'Bulgaria', 'BGR', '100', 'BG', '359', 'Sofia', 'BGN', 'Bulgarian lev', 'Лв.', '.bg', 'България', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Sofia\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"불가리아\",\"br\":\"Bulgária\",\"pt\":\"Bulgária\",\"nl\":\"Bulgarije\",\"hr\":\"Bugarska\",\"fa\":\"بلغارستان\",\"de\":\"Bulgarien\",\"es\":\"Bulgaria\",\"fr\":\"Bulgarie\",\"ja\":\"ブルガリア\",\"it\":\"Bulgaria\",\"cn\":\"保加利亚\",\"tr\":\"Bulgaristan\"}', '43.00000000', '25.00000000', '', 'U+1F1E7 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q219'),
(35, 'Burkina Faso', 'BFA', '854', 'BF', '226', 'Ouagadougou', 'XOF', 'West African CFA franc', 'CFA', '.bf', 'Burkina Faso', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Ouagadougou\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"부르키나 파소\",\"br\":\"Burkina Faso\",\"pt\":\"Burquina Faso\",\"nl\":\"Burkina Faso\",\"hr\":\"Burkina Faso\",\"fa\":\"بورکینافاسو\",\"de\":\"Burkina Faso\",\"es\":\"Burkina Faso\",\"fr\":\"Burkina Faso\",\"ja\":\"ブルキナファソ\",\"it\":\"Burkina Faso\",\"cn\":\"布基纳法索\",\"tr\":\"Burkina Faso\"}', '13.00000000', '-2.00000000', '', 'U+1F1E7 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q965'),
(36, 'Burundi', 'BDI', '108', 'BI', '257', 'Bujumbura', 'BIF', 'Burundian franc', 'FBu', '.bi', 'Burundi', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Bujumbura\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"부룬디\",\"br\":\"Burundi\",\"pt\":\"Burúndi\",\"nl\":\"Burundi\",\"hr\":\"Burundi\",\"fa\":\"بوروندی\",\"de\":\"Burundi\",\"es\":\"Burundi\",\"fr\":\"Burundi\",\"ja\":\"ブルンジ\",\"it\":\"Burundi\",\"cn\":\"布隆迪\",\"tr\":\"Burundi\"}', '-3.50000000', '30.00000000', '', 'U+1F1E7 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q967'),
(37, 'Cambodia', 'KHM', '116', 'KH', '855', 'Phnom Penh', 'KHR', 'Cambodian riel', 'KHR', '.kh', 'Kâmpŭchéa', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Phnom_Penh\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]', '{\"kr\":\"캄보디아\",\"br\":\"Camboja\",\"pt\":\"Camboja\",\"nl\":\"Cambodja\",\"hr\":\"Kambodža\",\"fa\":\"کامبوج\",\"de\":\"Kambodscha\",\"es\":\"Camboya\",\"fr\":\"Cambodge\",\"ja\":\"カンボジア\",\"it\":\"Cambogia\",\"cn\":\"柬埔寨\",\"tr\":\"Kamboçya\"}', '13.00000000', '105.00000000', '', 'U+1F1F0 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q424'),
(38, 'Cameroon', 'CMR', '120', 'CM', '237', 'Yaounde', 'XAF', 'Central African CFA franc', 'FCFA', '.cm', 'Cameroon', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Douala\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"카메룬\",\"br\":\"Camarões\",\"pt\":\"Camarões\",\"nl\":\"Kameroen\",\"hr\":\"Kamerun\",\"fa\":\"کامرون\",\"de\":\"Kamerun\",\"es\":\"Camerún\",\"fr\":\"Cameroun\",\"ja\":\"カメルーン\",\"it\":\"Camerun\",\"cn\":\"喀麦隆\",\"tr\":\"Kamerun\"}', '6.00000000', '12.00000000', '', 'U+1F1E8 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q1009'),
(39, 'Canada', 'CAN', '124', 'CA', '1', 'Ottawa', 'CAD', 'Canadian dollar', '$', '.ca', 'Canada', 'Americas', 'Northern America', '[{\"zoneName\":\"America/Atikokan\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America)\"},{\"zoneName\":\"America/Blanc-Sablon\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Cambridge_Bay\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Creston\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Dawson\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Dawson_Creek\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Edmonton\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Fort_Nelson\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Glace_Bay\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Goose_Bay\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Halifax\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Inuvik\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Iqaluit\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Moncton\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Nipigon\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Pangnirtung\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Rainy_River\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Rankin_Inlet\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Regina\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Resolute\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/St_Johns\",\"gmtOffset\":-12600,\"gmtOffsetName\":\"UTC-03:30\",\"abbreviation\":\"NST\",\"tzName\":\"Newfoundland Standard Time\"},{\"zoneName\":\"America/Swift_Current\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Thunder_Bay\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Toronto\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Vancouver\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"},{\"zoneName\":\"America/Whitehorse\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Winnipeg\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Yellowknife\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"}]', '{\"kr\":\"캐나다\",\"br\":\"Canadá\",\"pt\":\"Canadá\",\"nl\":\"Canada\",\"hr\":\"Kanada\",\"fa\":\"کانادا\",\"de\":\"Kanada\",\"es\":\"Canadá\",\"fr\":\"Canada\",\"ja\":\"カナダ\",\"it\":\"Canada\",\"cn\":\"加拿大\",\"tr\":\"Kanada\"}', '60.00000000', '-95.00000000', '', 'U+1F1E8 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q16'),
(40, 'Cape Verde', 'CPV', '132', 'CV', '238', 'Praia', 'CVE', 'Cape Verdean escudo', '$', '.cv', 'Cabo Verde', 'Africa', 'Western Africa', '[{\"zoneName\":\"Atlantic/Cape_Verde\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"CVT\",\"tzName\":\"Cape Verde Time\"}]', '{\"kr\":\"카보베르데\",\"br\":\"Cabo Verde\",\"pt\":\"Cabo Verde\",\"nl\":\"Kaapverdië\",\"hr\":\"Zelenortska Republika\",\"fa\":\"کیپ ورد\",\"de\":\"Kap Verde\",\"es\":\"Cabo Verde\",\"fr\":\"Cap Vert\",\"ja\":\"カーボベルデ\",\"it\":\"Capo Verde\",\"cn\":\"佛得角\",\"tr\":\"Cabo Verde\"}', '16.00000000', '-24.00000000', '', 'U+1F1E8 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q1011'),
(41, 'Cayman Islands', 'CYM', '136', 'KY', '+1-345', 'George Town', 'KYD', 'Cayman Islands dollar', '$', '.ky', 'Cayman Islands', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Cayman\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]', '{\"kr\":\"케이먼 제도\",\"br\":\"Ilhas Cayman\",\"pt\":\"Ilhas Caimão\",\"nl\":\"Caymaneilanden\",\"hr\":\"Kajmanski otoci\",\"fa\":\"جزایر کیمن\",\"de\":\"Kaimaninseln\",\"es\":\"Islas Caimán\",\"fr\":\"Îles Caïmans\",\"ja\":\"ケイマン諸島\",\"it\":\"Isole Cayman\",\"cn\":\"开曼群岛\",\"tr\":\"Cayman Adalari\"}', '19.50000000', '-80.50000000', '', 'U+1F1F0 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(42, 'Central African Republic', 'CAF', '140', 'CF', '236', 'Bangui', 'XAF', 'Central African CFA franc', 'FCFA', '.cf', 'Ködörösêse tî Bêafrîka', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Bangui\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"중앙아프리카 공화국\",\"br\":\"República Centro-Africana\",\"pt\":\"República Centro-Africana\",\"nl\":\"Centraal-Afrikaanse Republiek\",\"hr\":\"Srednjoafrička Republika\",\"fa\":\"جمهوری آفریقای مرکزی\",\"de\":\"Zentralafrikanische Republik\",\"es\":\"República Centroafricana\",\"fr\":\"République centrafricaine\",\"ja\":\"中央アフリカ共和国\",\"it\":\"Repubblica Centrafricana\",\"cn\":\"中非\",\"tr\":\"Orta Afrika Cumhuriyeti\"}', '7.00000000', '21.00000000', '', 'U+1F1E8 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q929'),
(43, 'Chad', 'TCD', '148', 'TD', '235', 'N\'Djamena', 'XAF', 'Central African CFA franc', 'FCFA', '.td', 'Tchad', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Ndjamena\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"차드\",\"br\":\"Chade\",\"pt\":\"Chade\",\"nl\":\"Tsjaad\",\"hr\":\"Čad\",\"fa\":\"چاد\",\"de\":\"Tschad\",\"es\":\"Chad\",\"fr\":\"Tchad\",\"ja\":\"チャド\",\"it\":\"Ciad\",\"cn\":\"乍得\",\"tr\":\"Çad\"}', '15.00000000', '19.00000000', '', 'U+1F1F9 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q657'),
(44, 'Chile', 'CHL', '152', 'CL', '56', 'Santiago', 'CLP', 'Chilean peso', '$', '.cl', 'Chile', 'Americas', 'South America', '[{\"zoneName\":\"America/Punta_Arenas\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"America/Santiago\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"Pacific/Easter\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EASST\",\"tzName\":\"Easter Island Summer Time\"}]', '{\"kr\":\"칠리\",\"br\":\"Chile\",\"pt\":\"Chile\",\"nl\":\"Chili\",\"hr\":\"Čile\",\"fa\":\"شیلی\",\"de\":\"Chile\",\"es\":\"Chile\",\"fr\":\"Chili\",\"ja\":\"チリ\",\"it\":\"Cile\",\"cn\":\"智利\",\"tr\":\"Şili\"}', '-30.00000000', '-71.00000000', '', 'U+1F1E8 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q298'),
(45, 'China', 'CHN', '156', 'CN', '86', 'Beijing', 'CNY', 'Chinese yuan', '¥', '.cn', '中国', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Shanghai\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"},{\"zoneName\":\"Asia/Urumqi\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"XJT\",\"tzName\":\"China Standard Time\"}]', '{\"kr\":\"중국\",\"br\":\"China\",\"pt\":\"China\",\"nl\":\"China\",\"hr\":\"Kina\",\"fa\":\"چین\",\"de\":\"China\",\"es\":\"China\",\"fr\":\"Chine\",\"ja\":\"中国\",\"it\":\"Cina\",\"cn\":\"中国\",\"tr\":\"Çin\"}', '35.00000000', '105.00000000', '', 'U+1F1E8 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q148'),
(46, 'Christmas Island', 'CXR', '162', 'CX', '61', 'Flying Fish Cove', 'AUD', 'Australian dollar', '$', '.cx', 'Christmas Island', 'Oceania', 'Australia and New Zealand', '[{\"zoneName\":\"Indian/Christmas\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"CXT\",\"tzName\":\"Christmas Island Time\"}]', '{\"kr\":\"크리스마스 섬\",\"br\":\"Ilha Christmas\",\"pt\":\"Ilha do Natal\",\"nl\":\"Christmaseiland\",\"hr\":\"Božićni otok\",\"fa\":\"جزیره کریسمس\",\"de\":\"Weihnachtsinsel\",\"es\":\"Isla de Navidad\",\"fr\":\"Île Christmas\",\"ja\":\"クリスマス島\",\"it\":\"Isola di Natale\",\"cn\":\"圣诞岛\",\"tr\":\"Christmas Adasi\"}', '-10.50000000', '105.66666666', '', 'U+1F1E8 U+1F1FD', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(47, 'Cocos (Keeling) Islands', 'CCK', '166', 'CC', '61', 'West Island', 'AUD', 'Australian dollar', '$', '.cc', 'Cocos (Keeling) Islands', 'Oceania', 'Australia and New Zealand', '[{\"zoneName\":\"Indian/Cocos\",\"gmtOffset\":23400,\"gmtOffsetName\":\"UTC+06:30\",\"abbreviation\":\"CCT\",\"tzName\":\"Cocos Islands Time\"}]', '{\"kr\":\"코코스 제도\",\"br\":\"Ilhas Cocos\",\"pt\":\"Ilhas dos Cocos\",\"nl\":\"Cocoseilanden\",\"hr\":\"Kokosovi Otoci\",\"fa\":\"جزایر کوکوس\",\"de\":\"Kokosinseln\",\"es\":\"Islas Cocos o Islas Keeling\",\"fr\":\"Îles Cocos\",\"ja\":\"ココス（キーリング）諸島\",\"it\":\"Isole Cocos e Keeling\",\"cn\":\"科科斯（基林）群岛\",\"tr\":\"Cocos Adalari\"}', '-12.50000000', '96.83333333', '', 'U+1F1E8 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, NULL),
(48, 'Colombia', 'COL', '170', 'CO', '57', 'Bogotá', 'COP', 'Colombian peso', '$', '.co', 'Colombia', 'Americas', 'South America', '[{\"zoneName\":\"America/Bogota\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"COT\",\"tzName\":\"Colombia Time\"}]', '{\"kr\":\"콜롬비아\",\"br\":\"Colômbia\",\"pt\":\"Colômbia\",\"nl\":\"Colombia\",\"hr\":\"Kolumbija\",\"fa\":\"کلمبیا\",\"de\":\"Kolumbien\",\"es\":\"Colombia\",\"fr\":\"Colombie\",\"ja\":\"コロンビア\",\"it\":\"Colombia\",\"cn\":\"哥伦比亚\",\"tr\":\"Kolombiya\"}', '4.00000000', '-72.00000000', '', 'U+1F1E8 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q739'),
(49, 'Comoros', 'COM', '174', 'KM', '269', 'Moroni', 'KMF', 'Comorian franc', 'CF', '.km', 'Komori', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Comoro\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"코모로\",\"br\":\"Comores\",\"pt\":\"Comores\",\"nl\":\"Comoren\",\"hr\":\"Komori\",\"fa\":\"کومور\",\"de\":\"Union der Komoren\",\"es\":\"Comoras\",\"fr\":\"Comores\",\"ja\":\"コモロ\",\"it\":\"Comore\",\"cn\":\"科摩罗\",\"tr\":\"Komorlar\"}', '-12.16666666', '44.25000000', '', 'U+1F1F0 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q970'),
(50, 'Congo', 'COG', '178', 'CG', '242', 'Brazzaville', 'XAF', 'Central African CFA franc', 'FC', '.cg', 'République du Congo', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Brazzaville\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"콩고\",\"br\":\"Congo\",\"pt\":\"Congo\",\"nl\":\"Congo [Republiek]\",\"hr\":\"Kongo\",\"fa\":\"کنگو\",\"de\":\"Kongo\",\"es\":\"Congo\",\"fr\":\"Congo\",\"ja\":\"コンゴ共和国\",\"it\":\"Congo\",\"cn\":\"刚果\",\"tr\":\"Kongo\"}', '-1.00000000', '15.00000000', '', 'U+1F1E8 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:11:20', 1, 'Q971'),
(51, 'Democratic Republic of the Congo', 'COD', '180', 'CD', '243', 'Kinshasa', 'CDF', 'Congolese Franc', 'FC', '.cd', 'République démocratique du Congo', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Kinshasa\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"},{\"zoneName\":\"Africa/Lubumbashi\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"콩고 민주 공화국\",\"br\":\"RD Congo\",\"pt\":\"RD Congo\",\"nl\":\"Congo [DRC]\",\"hr\":\"Kongo, Demokratska Republika\",\"fa\":\"جمهوری کنگو\",\"de\":\"Kongo (Dem. Rep.)\",\"es\":\"Congo (Rep. Dem.)\",\"fr\":\"Congo (Rép. dém.)\",\"ja\":\"コンゴ民主共和国\",\"it\":\"Congo (Rep. Dem.)\",\"cn\":\"刚果（金）\",\"tr\":\"Kongo Demokratik Cumhuriyeti\"}', '0.00000000', '25.00000000', '', 'U+1F1E8 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q974'),
(52, 'Cook Islands', 'COK', '184', 'CK', '682', 'Avarua', 'NZD', 'Cook Islands dollar', '$', '.ck', 'Cook Islands', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Rarotonga\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"CKT\",\"tzName\":\"Cook Island Time\"}]', '{\"kr\":\"쿡 제도\",\"br\":\"Ilhas Cook\",\"pt\":\"Ilhas Cook\",\"nl\":\"Cookeilanden\",\"hr\":\"Cookovo Otočje\",\"fa\":\"جزایر کوک\",\"de\":\"Cookinseln\",\"es\":\"Islas Cook\",\"fr\":\"Îles Cook\",\"ja\":\"クック諸島\",\"it\":\"Isole Cook\",\"cn\":\"库克群岛\",\"tr\":\"Cook Adalari\"}', '-21.23333333', '-159.76666666', '', 'U+1F1E8 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q26988'),
(53, 'Costa Rica', 'CRI', '188', 'CR', '506', 'San Jose', 'CRC', 'Costa Rican colón', '₡', '.cr', 'Costa Rica', 'Americas', 'Central America', '[{\"zoneName\":\"America/Costa_Rica\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]', '{\"kr\":\"코스타리카\",\"br\":\"Costa Rica\",\"pt\":\"Costa Rica\",\"nl\":\"Costa Rica\",\"hr\":\"Kostarika\",\"fa\":\"کاستاریکا\",\"de\":\"Costa Rica\",\"es\":\"Costa Rica\",\"fr\":\"Costa Rica\",\"ja\":\"コスタリカ\",\"it\":\"Costa Rica\",\"cn\":\"哥斯达黎加\",\"tr\":\"Kosta Rika\"}', '10.00000000', '-84.00000000', '', 'U+1F1E8 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q800'),
(54, 'Cote D\'Ivoire (Ivory Coast)', 'CIV', '384', 'CI', '225', 'Yamoussoukro', 'XOF', 'West African CFA franc', 'CFA', '.ci', NULL, 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Abidjan\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"코트디부아르\",\"br\":\"Costa do Marfim\",\"pt\":\"Costa do Marfim\",\"nl\":\"Ivoorkust\",\"hr\":\"Obala Bjelokosti\",\"fa\":\"ساحل عاج\",\"de\":\"Elfenbeinküste\",\"es\":\"Costa de Marfil\",\"fr\":\"Côte d\'Ivoire\",\"ja\":\"コートジボワール\",\"it\":\"Costa D\'Avorio\",\"cn\":\"科特迪瓦\",\"tr\":\"Kotdivuar\"}', '8.00000000', '-5.00000000', '', 'U+1F1E8 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q1008'),
(55, 'Croatia', 'HRV', '191', 'HR', '385', 'Zagreb', 'HRK', 'Croatian kuna', 'kn', '.hr', 'Hrvatska', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Zagreb\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"크로아티아\",\"br\":\"Croácia\",\"pt\":\"Croácia\",\"nl\":\"Kroatië\",\"hr\":\"Hrvatska\",\"fa\":\"کرواسی\",\"de\":\"Kroatien\",\"es\":\"Croacia\",\"fr\":\"Croatie\",\"ja\":\"クロアチア\",\"it\":\"Croazia\",\"cn\":\"克罗地亚\",\"tr\":\"Hirvatistan\"}', '45.16666666', '15.50000000', '', 'U+1F1ED U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q224');
INSERT INTO `countries` (`id`, `name`, `iso3`, `numeric_code`, `iso2`, `phonecode`, `capital`, `currency`, `currency_name`, `currency_symbol`, `tld`, `native`, `region`, `subregion`, `timezones`, `translations`, `latitude`, `longitude`, `emoji`, `emojiU`, `created_at`, `updated_at`, `flag`, `wikiDataId`) VALUES
(56, 'Cuba', 'CUB', '192', 'CU', '53', 'Havana', 'CUP', 'Cuban peso', '$', '.cu', 'Cuba', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Havana\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"CST\",\"tzName\":\"Cuba Standard Time\"}]', '{\"kr\":\"쿠바\",\"br\":\"Cuba\",\"pt\":\"Cuba\",\"nl\":\"Cuba\",\"hr\":\"Kuba\",\"fa\":\"کوبا\",\"de\":\"Kuba\",\"es\":\"Cuba\",\"fr\":\"Cuba\",\"ja\":\"キューバ\",\"it\":\"Cuba\",\"cn\":\"古巴\",\"tr\":\"Küba\"}', '21.50000000', '-80.00000000', '', 'U+1F1E8 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q241'),
(57, 'Cyprus', 'CYP', '196', 'CY', '357', 'Nicosia', 'EUR', 'Euro', '€', '.cy', 'Κύπρος', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Asia/Famagusta\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Asia/Nicosia\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"키프로스\",\"br\":\"Chipre\",\"pt\":\"Chipre\",\"nl\":\"Cyprus\",\"hr\":\"Cipar\",\"fa\":\"قبرس\",\"de\":\"Zypern\",\"es\":\"Chipre\",\"fr\":\"Chypre\",\"ja\":\"キプロス\",\"it\":\"Cipro\",\"cn\":\"塞浦路斯\",\"tr\":\"Kuzey Kıbrıs Türk Cumhuriyeti\"}', '35.00000000', '33.00000000', '', 'U+1F1E8 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q229'),
(58, 'Czech Republic', 'CZE', '203', 'CZ', '420', 'Prague', 'CZK', 'Czech koruna', 'Kč', '.cz', 'Česká republika', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Prague\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"체코\",\"br\":\"República Tcheca\",\"pt\":\"República Checa\",\"nl\":\"Tsjechië\",\"hr\":\"Češka\",\"fa\":\"جمهوری چک\",\"de\":\"Tschechische Republik\",\"es\":\"República Checa\",\"fr\":\"République tchèque\",\"ja\":\"チェコ\",\"it\":\"Repubblica Ceca\",\"cn\":\"捷克\",\"tr\":\"Çekya\"}', '49.75000000', '15.50000000', '', 'U+1F1E8 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q213'),
(59, 'Denmark', 'DNK', '208', 'DK', '45', 'Copenhagen', 'DKK', 'Danish krone', 'Kr.', '.dk', 'Danmark', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Copenhagen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"덴마크\",\"br\":\"Dinamarca\",\"pt\":\"Dinamarca\",\"nl\":\"Denemarken\",\"hr\":\"Danska\",\"fa\":\"دانمارک\",\"de\":\"Dänemark\",\"es\":\"Dinamarca\",\"fr\":\"Danemark\",\"ja\":\"デンマーク\",\"it\":\"Danimarca\",\"cn\":\"丹麦\",\"tr\":\"Danimarka\"}', '56.00000000', '10.00000000', '', 'U+1F1E9 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:13:35', 1, 'Q35'),
(60, 'Djibouti', 'DJI', '262', 'DJ', '253', 'Djibouti', 'DJF', 'Djiboutian franc', 'Fdj', '.dj', 'Djibouti', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Djibouti\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"지부티\",\"br\":\"Djibuti\",\"pt\":\"Djibuti\",\"nl\":\"Djibouti\",\"hr\":\"Džibuti\",\"fa\":\"جیبوتی\",\"de\":\"Dschibuti\",\"es\":\"Yibuti\",\"fr\":\"Djibouti\",\"ja\":\"ジブチ\",\"it\":\"Gibuti\",\"cn\":\"吉布提\",\"tr\":\"Cibuti\"}', '11.50000000', '43.00000000', '', 'U+1F1E9 U+1F1EF', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q977'),
(61, 'Dominica', 'DMA', '212', 'DM', '+1-767', 'Roseau', 'XCD', 'Eastern Caribbean dollar', '$', '.dm', 'Dominica', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Dominica\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"도미니카 연방\",\"br\":\"Dominica\",\"pt\":\"Dominica\",\"nl\":\"Dominica\",\"hr\":\"Dominika\",\"fa\":\"دومینیکا\",\"de\":\"Dominica\",\"es\":\"Dominica\",\"fr\":\"Dominique\",\"ja\":\"ドミニカ国\",\"it\":\"Dominica\",\"cn\":\"多米尼加\",\"tr\":\"Dominika\"}', '15.41666666', '-61.33333333', '', 'U+1F1E9 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q784'),
(62, 'Dominican Republic', 'DOM', '214', 'DO', '+1-809 and 1-829', 'Santo Domingo', 'DOP', 'Dominican peso', '$', '.do', 'República Dominicana', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Santo_Domingo\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"도미니카 공화국\",\"br\":\"República Dominicana\",\"pt\":\"República Dominicana\",\"nl\":\"Dominicaanse Republiek\",\"hr\":\"Dominikanska Republika\",\"fa\":\"جمهوری دومینیکن\",\"de\":\"Dominikanische Republik\",\"es\":\"República Dominicana\",\"fr\":\"République dominicaine\",\"ja\":\"ドミニカ共和国\",\"it\":\"Repubblica Dominicana\",\"cn\":\"多明尼加共和国\",\"tr\":\"Dominik Cumhuriyeti\"}', '19.00000000', '-70.66666666', '', 'U+1F1E9 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q786'),
(63, 'East Timor', 'TLS', '626', 'TL', '670', 'Dili', 'USD', 'United States dollar', '$', '.tl', 'Timor-Leste', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Dili\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"TLT\",\"tzName\":\"Timor Leste Time\"}]', '{\"kr\":\"동티모르\",\"br\":\"Timor Leste\",\"pt\":\"Timor Leste\",\"nl\":\"Oost-Timor\",\"hr\":\"Istočni Timor\",\"fa\":\"تیمور شرقی\",\"de\":\"Timor-Leste\",\"es\":\"Timor Oriental\",\"fr\":\"Timor oriental\",\"ja\":\"東ティモール\",\"it\":\"Timor Est\",\"cn\":\"东帝汶\",\"tr\":\"Doğu Timor\"}', '-8.83333333', '125.91666666', '', 'U+1F1F9 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q574'),
(64, 'Ecuador', 'ECU', '218', 'EC', '593', 'Quito', 'USD', 'United States dollar', '$', '.ec', 'Ecuador', 'Americas', 'South America', '[{\"zoneName\":\"America/Guayaquil\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ECT\",\"tzName\":\"Ecuador Time\"},{\"zoneName\":\"Pacific/Galapagos\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"GALT\",\"tzName\":\"Galápagos Time\"}]', '{\"kr\":\"에콰도르\",\"br\":\"Equador\",\"pt\":\"Equador\",\"nl\":\"Ecuador\",\"hr\":\"Ekvador\",\"fa\":\"اکوادور\",\"de\":\"Ecuador\",\"es\":\"Ecuador\",\"fr\":\"Équateur\",\"ja\":\"エクアドル\",\"it\":\"Ecuador\",\"cn\":\"厄瓜多尔\",\"tr\":\"Ekvator\"}', '-2.00000000', '-77.50000000', '', 'U+1F1EA U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q736'),
(65, 'Egypt', 'EGY', '818', 'EG', '20', 'Cairo', 'EGP', 'Egyptian pound', 'ج.م', '.eg', 'مصر‎', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Cairo\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"이집트\",\"br\":\"Egito\",\"pt\":\"Egipto\",\"nl\":\"Egypte\",\"hr\":\"Egipat\",\"fa\":\"مصر\",\"de\":\"Ägypten\",\"es\":\"Egipto\",\"fr\":\"Égypte\",\"ja\":\"エジプト\",\"it\":\"Egitto\",\"cn\":\"埃及\",\"tr\":\"Mısır\"}', '27.00000000', '30.00000000', '', 'U+1F1EA U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q79'),
(66, 'El Salvador', 'SLV', '222', 'SV', '503', 'San Salvador', 'USD', 'United States dollar', '$', '.sv', 'El Salvador', 'Americas', 'Central America', '[{\"zoneName\":\"America/El_Salvador\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]', '{\"kr\":\"엘살바도르\",\"br\":\"El Salvador\",\"pt\":\"El Salvador\",\"nl\":\"El Salvador\",\"hr\":\"Salvador\",\"fa\":\"السالوادور\",\"de\":\"El Salvador\",\"es\":\"El Salvador\",\"fr\":\"Salvador\",\"ja\":\"エルサルバドル\",\"it\":\"El Salvador\",\"cn\":\"萨尔瓦多\",\"tr\":\"El Salvador\"}', '13.83333333', '-88.91666666', '', 'U+1F1F8 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q792'),
(67, 'Equatorial Guinea', 'GNQ', '226', 'GQ', '240', 'Malabo', 'XAF', 'Central African CFA franc', 'FCFA', '.gq', 'Guinea Ecuatorial', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Malabo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"적도 기니\",\"br\":\"Guiné Equatorial\",\"pt\":\"Guiné Equatorial\",\"nl\":\"Equatoriaal-Guinea\",\"hr\":\"Ekvatorijalna Gvineja\",\"fa\":\"گینه استوایی\",\"de\":\"Äquatorial-Guinea\",\"es\":\"Guinea Ecuatorial\",\"fr\":\"Guinée-Équatoriale\",\"ja\":\"赤道ギニア\",\"it\":\"Guinea Equatoriale\",\"cn\":\"赤道几内亚\",\"tr\":\"Ekvator Ginesi\"}', '2.00000000', '10.00000000', '', 'U+1F1EC U+1F1F6', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q983'),
(68, 'Eritrea', 'ERI', '232', 'ER', '291', 'Asmara', 'ERN', 'Eritrean nakfa', 'Nfk', '.er', 'ኤርትራ', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Asmara\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"에리트레아\",\"br\":\"Eritreia\",\"pt\":\"Eritreia\",\"nl\":\"Eritrea\",\"hr\":\"Eritreja\",\"fa\":\"اریتره\",\"de\":\"Eritrea\",\"es\":\"Eritrea\",\"fr\":\"Érythrée\",\"ja\":\"エリトリア\",\"it\":\"Eritrea\",\"cn\":\"厄立特里亚\",\"tr\":\"Eritre\"}', '15.00000000', '39.00000000', '', 'U+1F1EA U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q986'),
(69, 'Estonia', 'EST', '233', 'EE', '372', 'Tallinn', 'EUR', 'Euro', '€', '.ee', 'Eesti', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Tallinn\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"에스토니아\",\"br\":\"Estônia\",\"pt\":\"Estónia\",\"nl\":\"Estland\",\"hr\":\"Estonija\",\"fa\":\"استونی\",\"de\":\"Estland\",\"es\":\"Estonia\",\"fr\":\"Estonie\",\"ja\":\"エストニア\",\"it\":\"Estonia\",\"cn\":\"爱沙尼亚\",\"tr\":\"Estonya\"}', '59.00000000', '26.00000000', '', 'U+1F1EA U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:17:53', 1, 'Q191'),
(70, 'Ethiopia', 'ETH', '231', 'ET', '251', 'Addis Ababa', 'ETB', 'Ethiopian birr', 'Nkf', '.et', 'ኢትዮጵያ', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Addis_Ababa\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"에티오피아\",\"br\":\"Etiópia\",\"pt\":\"Etiópia\",\"nl\":\"Ethiopië\",\"hr\":\"Etiopija\",\"fa\":\"اتیوپی\",\"de\":\"Äthiopien\",\"es\":\"Etiopía\",\"fr\":\"Éthiopie\",\"ja\":\"エチオピア\",\"it\":\"Etiopia\",\"cn\":\"埃塞俄比亚\",\"tr\":\"Etiyopya\"}', '8.00000000', '38.00000000', '', 'U+1F1EA U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q115'),
(71, 'Falkland Islands', 'FLK', '238', 'FK', '500', 'Stanley', 'FKP', 'Falkland Islands pound', '£', '.fk', 'Falkland Islands', 'Americas', 'South America', '[{\"zoneName\":\"Atlantic/Stanley\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"FKST\",\"tzName\":\"Falkland Islands Summer Time\"}]', '{\"kr\":\"포클랜드 제도\",\"br\":\"Ilhas Malvinas\",\"pt\":\"Ilhas Falkland\",\"nl\":\"Falklandeilanden [Islas Malvinas]\",\"hr\":\"Falklandski Otoci\",\"fa\":\"جزایر فالکلند\",\"de\":\"Falklandinseln\",\"es\":\"Islas Malvinas\",\"fr\":\"Îles Malouines\",\"ja\":\"フォークランド（マルビナス）諸島\",\"it\":\"Isole Falkland o Isole Malvine\",\"cn\":\"福克兰群岛\",\"tr\":\"Falkland Adalari\"}', '-51.75000000', '-59.00000000', '', 'U+1F1EB U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(72, 'Faroe Islands', 'FRO', '234', 'FO', '298', 'Torshavn', 'DKK', 'Danish krone', 'Kr.', '.fo', 'Føroyar', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Atlantic/Faroe\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"}]', '{\"kr\":\"페로 제도\",\"br\":\"Ilhas Faroé\",\"pt\":\"Ilhas Faroé\",\"nl\":\"Faeröer\",\"hr\":\"Farski Otoci\",\"fa\":\"جزایر فارو\",\"de\":\"Färöer-Inseln\",\"es\":\"Islas Faroe\",\"fr\":\"Îles Féroé\",\"ja\":\"フェロー諸島\",\"it\":\"Isole Far Oer\",\"cn\":\"法罗群岛\",\"tr\":\"Faroe Adalari\"}', '62.00000000', '-7.00000000', '', 'U+1F1EB U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(73, 'Fiji Islands', 'FJI', '242', 'FJ', '679', 'Suva', 'FJD', 'Fijian dollar', 'FJ$', '.fj', 'Fiji', 'Oceania', 'Melanesia', '[{\"zoneName\":\"Pacific/Fiji\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"FJT\",\"tzName\":\"Fiji Time\"}]', '{\"kr\":\"피지\",\"br\":\"Fiji\",\"pt\":\"Fiji\",\"nl\":\"Fiji\",\"hr\":\"Fiđi\",\"fa\":\"فیجی\",\"de\":\"Fidschi\",\"es\":\"Fiyi\",\"fr\":\"Fidji\",\"ja\":\"フィジー\",\"it\":\"Figi\",\"cn\":\"斐济\",\"tr\":\"Fiji\"}', '-18.00000000', '175.00000000', '', 'U+1F1EB U+1F1EF', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q712'),
(74, 'Finland', 'FIN', '246', 'FI', '358', 'Helsinki', 'EUR', 'Euro', '€', '.fi', 'Suomi', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Helsinki\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"핀란드\",\"br\":\"Finlândia\",\"pt\":\"Finlândia\",\"nl\":\"Finland\",\"hr\":\"Finska\",\"fa\":\"فنلاند\",\"de\":\"Finnland\",\"es\":\"Finlandia\",\"fr\":\"Finlande\",\"ja\":\"フィンランド\",\"it\":\"Finlandia\",\"cn\":\"芬兰\",\"tr\":\"Finlandiya\"}', '64.00000000', '26.00000000', '', 'U+1F1EB U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q33'),
(75, 'France', 'FRA', '250', 'FR', '33', 'Paris', 'EUR', 'Euro', '€', '.fr', 'France', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Paris\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"프랑스\",\"br\":\"França\",\"pt\":\"França\",\"nl\":\"Frankrijk\",\"hr\":\"Francuska\",\"fa\":\"فرانسه\",\"de\":\"Frankreich\",\"es\":\"Francia\",\"fr\":\"France\",\"ja\":\"フランス\",\"it\":\"Francia\",\"cn\":\"法国\",\"tr\":\"Fransa\"}', '46.00000000', '2.00000000', '', 'U+1F1EB U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q142'),
(76, 'French Guiana', 'GUF', '254', 'GF', '594', 'Cayenne', 'EUR', 'Euro', '€', '.gf', 'Guyane française', 'Americas', 'South America', '[{\"zoneName\":\"America/Cayenne\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"GFT\",\"tzName\":\"French Guiana Time\"}]', '{\"kr\":\"프랑스령 기아나\",\"br\":\"Guiana Francesa\",\"pt\":\"Guiana Francesa\",\"nl\":\"Frans-Guyana\",\"hr\":\"Francuska Gvajana\",\"fa\":\"گویان فرانسه\",\"de\":\"Französisch Guyana\",\"es\":\"Guayana Francesa\",\"fr\":\"Guayane\",\"ja\":\"フランス領ギアナ\",\"it\":\"Guyana francese\",\"cn\":\"法属圭亚那\",\"tr\":\"Fransiz Guyanasi\"}', '4.00000000', '-53.00000000', '', 'U+1F1EC U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(77, 'French Polynesia', 'PYF', '258', 'PF', '689', 'Papeete', 'XPF', 'CFP franc', '₣', '.pf', 'Polynésie française', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Gambier\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"GAMT\",\"tzName\":\"Gambier Islands Time\"},{\"zoneName\":\"Pacific/Marquesas\",\"gmtOffset\":-34200,\"gmtOffsetName\":\"UTC-09:30\",\"abbreviation\":\"MART\",\"tzName\":\"Marquesas Islands Time\"},{\"zoneName\":\"Pacific/Tahiti\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"TAHT\",\"tzName\":\"Tahiti Time\"}]', '{\"kr\":\"프랑스령 폴리네시아\",\"br\":\"Polinésia Francesa\",\"pt\":\"Polinésia Francesa\",\"nl\":\"Frans-Polynesië\",\"hr\":\"Francuska Polinezija\",\"fa\":\"پلی‌نزی فرانسه\",\"de\":\"Französisch-Polynesien\",\"es\":\"Polinesia Francesa\",\"fr\":\"Polynésie française\",\"ja\":\"フランス領ポリネシア\",\"it\":\"Polinesia Francese\",\"cn\":\"法属波利尼西亚\",\"tr\":\"Fransiz Polinezyasi\"}', '-15.00000000', '-140.00000000', '', 'U+1F1F5 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(78, 'French Southern Territories', 'ATF', '260', 'TF', '262', 'Port-aux-Francais', 'EUR', 'Euro', '€', '.tf', 'Territoire des Terres australes et antarctiques fr', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Indian/Kerguelen\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TFT\",\"tzName\":\"French Southern and Antarctic Time\"}]', '{\"kr\":\"프랑스령 남방 및 남극\",\"br\":\"Terras Austrais e Antárticas Francesas\",\"pt\":\"Terras Austrais e Antárticas Francesas\",\"nl\":\"Franse Gebieden in de zuidelijke Indische Oceaan\",\"hr\":\"Francuski južni i antarktički teritoriji\",\"fa\":\"سرزمین‌های جنوبی و جنوبگانی فرانسه\",\"de\":\"Französische Süd- und Antarktisgebiete\",\"es\":\"Tierras Australes y Antárticas Francesas\",\"fr\":\"Terres australes et antarctiques françaises\",\"ja\":\"フランス領南方・南極地域\",\"it\":\"Territori Francesi del Sud\",\"cn\":\"法属南部领地\",\"tr\":\"Fransiz Güney Topraklari\"}', '-49.25000000', '69.16700000', '', 'U+1F1F9 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(79, 'Gabon', 'GAB', '266', 'GA', '241', 'Libreville', 'XAF', 'Central African CFA franc', 'FCFA', '.ga', 'Gabon', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Libreville\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"가봉\",\"br\":\"Gabão\",\"pt\":\"Gabão\",\"nl\":\"Gabon\",\"hr\":\"Gabon\",\"fa\":\"گابن\",\"de\":\"Gabun\",\"es\":\"Gabón\",\"fr\":\"Gabon\",\"ja\":\"ガボン\",\"it\":\"Gabon\",\"cn\":\"加蓬\",\"tr\":\"Gabon\"}', '-1.00000000', '11.75000000', '', 'U+1F1EC U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q1000'),
(80, 'Gambia The', 'GMB', '270', 'GM', '220', 'Banjul', 'GMD', 'Gambian dalasi', 'D', '.gm', 'Gambia', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Banjul\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"감비아\",\"br\":\"Gâmbia\",\"pt\":\"Gâmbia\",\"nl\":\"Gambia\",\"hr\":\"Gambija\",\"fa\":\"گامبیا\",\"de\":\"Gambia\",\"es\":\"Gambia\",\"fr\":\"Gambie\",\"ja\":\"ガンビア\",\"it\":\"Gambia\",\"cn\":\"冈比亚\",\"tr\":\"Gambiya\"}', '13.46666666', '-16.56666666', '', 'U+1F1EC U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q1005'),
(81, 'Georgia', 'GEO', '268', 'GE', '995', 'Tbilisi', 'GEL', 'Georgian lari', 'ლ', '.ge', 'საქართველო', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Tbilisi\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GET\",\"tzName\":\"Georgia Standard Time\"}]', '{\"kr\":\"조지아\",\"br\":\"Geórgia\",\"pt\":\"Geórgia\",\"nl\":\"Georgië\",\"hr\":\"Gruzija\",\"fa\":\"گرجستان\",\"de\":\"Georgien\",\"es\":\"Georgia\",\"fr\":\"Géorgie\",\"ja\":\"グルジア\",\"it\":\"Georgia\",\"cn\":\"格鲁吉亚\",\"tr\":\"Gürcistan\"}', '42.00000000', '43.50000000', '', 'U+1F1EC U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q230'),
(82, 'Germany', 'DEU', '276', 'DE', '49', 'Berlin', 'EUR', 'Euro', '€', '.de', 'Deutschland', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Berlin\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"},{\"zoneName\":\"Europe/Busingen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"독일\",\"br\":\"Alemanha\",\"pt\":\"Alemanha\",\"nl\":\"Duitsland\",\"hr\":\"Njemačka\",\"fa\":\"آلمان\",\"de\":\"Deutschland\",\"es\":\"Alemania\",\"fr\":\"Allemagne\",\"ja\":\"ドイツ\",\"it\":\"Germania\",\"cn\":\"德国\",\"tr\":\"Almanya\"}', '51.00000000', '9.00000000', '', 'U+1F1E9 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q183'),
(83, 'Ghana', 'GHA', '288', 'GH', '233', 'Accra', 'GHS', 'Ghanaian cedi', 'GH₵', '.gh', 'Ghana', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Accra\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"가나\",\"br\":\"Gana\",\"pt\":\"Gana\",\"nl\":\"Ghana\",\"hr\":\"Gana\",\"fa\":\"غنا\",\"de\":\"Ghana\",\"es\":\"Ghana\",\"fr\":\"Ghana\",\"ja\":\"ガーナ\",\"it\":\"Ghana\",\"cn\":\"加纳\",\"tr\":\"Gana\"}', '8.00000000', '-2.00000000', '', 'U+1F1EC U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q117'),
(84, 'Gibraltar', 'GIB', '292', 'GI', '350', 'Gibraltar', 'GIP', 'Gibraltar pound', '£', '.gi', 'Gibraltar', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Gibraltar\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"지브롤터\",\"br\":\"Gibraltar\",\"pt\":\"Gibraltar\",\"nl\":\"Gibraltar\",\"hr\":\"Gibraltar\",\"fa\":\"جبل‌طارق\",\"de\":\"Gibraltar\",\"es\":\"Gibraltar\",\"fr\":\"Gibraltar\",\"ja\":\"ジブラルタル\",\"it\":\"Gibilterra\",\"cn\":\"直布罗陀\",\"tr\":\"Cebelitarik\"}', '36.13333333', '-5.35000000', '', 'U+1F1EC U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(85, 'Greece', 'GRC', '300', 'GR', '30', 'Athens', 'EUR', 'Euro', '€', '.gr', 'Ελλάδα', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Athens\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"그리스\",\"br\":\"Grécia\",\"pt\":\"Grécia\",\"nl\":\"Griekenland\",\"hr\":\"Grčka\",\"fa\":\"یونان\",\"de\":\"Griechenland\",\"es\":\"Grecia\",\"fr\":\"Grèce\",\"ja\":\"ギリシャ\",\"it\":\"Grecia\",\"cn\":\"希腊\",\"tr\":\"Yunanistan\"}', '39.00000000', '22.00000000', '', 'U+1F1EC U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q41'),
(86, 'Greenland', 'GRL', '304', 'GL', '299', 'Nuuk', 'DKK', 'Danish krone', 'Kr.', '.gl', 'Kalaallit Nunaat', 'Americas', 'Northern America', '[{\"zoneName\":\"America/Danmarkshavn\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"},{\"zoneName\":\"America/Nuuk\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"WGT\",\"tzName\":\"West Greenland Time\"},{\"zoneName\":\"America/Scoresbysund\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"EGT\",\"tzName\":\"Eastern Greenland Time\"},{\"zoneName\":\"America/Thule\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"그린란드\",\"br\":\"Groelândia\",\"pt\":\"Gronelândia\",\"nl\":\"Groenland\",\"hr\":\"Grenland\",\"fa\":\"گرینلند\",\"de\":\"Grönland\",\"es\":\"Groenlandia\",\"fr\":\"Groenland\",\"ja\":\"グリーンランド\",\"it\":\"Groenlandia\",\"cn\":\"格陵兰岛\",\"tr\":\"Grönland\"}', '72.00000000', '-40.00000000', '', 'U+1F1EC U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(87, 'Grenada', 'GRD', '308', 'GD', '+1-473', 'St. George\'s', 'XCD', 'Eastern Caribbean dollar', '$', '.gd', 'Grenada', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Grenada\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"그레나다\",\"br\":\"Granada\",\"pt\":\"Granada\",\"nl\":\"Grenada\",\"hr\":\"Grenada\",\"fa\":\"گرنادا\",\"de\":\"Grenada\",\"es\":\"Grenada\",\"fr\":\"Grenade\",\"ja\":\"グレナダ\",\"it\":\"Grenada\",\"cn\":\"格林纳达\",\"tr\":\"Grenada\"}', '12.11666666', '-61.66666666', '', 'U+1F1EC U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q769'),
(88, 'Guadeloupe', 'GLP', '312', 'GP', '590', 'Basse-Terre', 'EUR', 'Euro', '€', '.gp', 'Guadeloupe', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Guadeloupe\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"과들루프\",\"br\":\"Guadalupe\",\"pt\":\"Guadalupe\",\"nl\":\"Guadeloupe\",\"hr\":\"Gvadalupa\",\"fa\":\"جزیره گوادلوپ\",\"de\":\"Guadeloupe\",\"es\":\"Guadalupe\",\"fr\":\"Guadeloupe\",\"ja\":\"グアドループ\",\"it\":\"Guadeloupa\",\"cn\":\"瓜德罗普岛\",\"tr\":\"Guadeloupe\"}', '16.25000000', '-61.58333300', '', 'U+1F1EC U+1F1F5', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(89, 'Guam', 'GUM', '316', 'GU', '+1-671', 'Hagatna', 'USD', 'US Dollar', '$', '.gu', 'Guam', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Guam\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"CHST\",\"tzName\":\"Chamorro Standard Time\"}]', '{\"kr\":\"괌\",\"br\":\"Guam\",\"pt\":\"Guame\",\"nl\":\"Guam\",\"hr\":\"Guam\",\"fa\":\"گوام\",\"de\":\"Guam\",\"es\":\"Guam\",\"fr\":\"Guam\",\"ja\":\"グアム\",\"it\":\"Guam\",\"cn\":\"关岛\",\"tr\":\"Guam\"}', '13.46666666', '144.78333333', '', 'U+1F1EC U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, NULL),
(90, 'Guatemala', 'GTM', '320', 'GT', '502', 'Guatemala City', 'GTQ', 'Guatemalan quetzal', 'Q', '.gt', 'Guatemala', 'Americas', 'Central America', '[{\"zoneName\":\"America/Guatemala\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]', '{\"kr\":\"과테말라\",\"br\":\"Guatemala\",\"pt\":\"Guatemala\",\"nl\":\"Guatemala\",\"hr\":\"Gvatemala\",\"fa\":\"گواتمالا\",\"de\":\"Guatemala\",\"es\":\"Guatemala\",\"fr\":\"Guatemala\",\"ja\":\"グアテマラ\",\"it\":\"Guatemala\",\"cn\":\"危地马拉\",\"tr\":\"Guatemala\"}', '15.50000000', '-90.25000000', '', 'U+1F1EC U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:20:25', 1, 'Q774'),
(91, 'Guernsey and Alderney', 'GGY', '831', 'GG', '+44-1481', 'St Peter Port', 'GBP', 'British pound', '£', '.gg', 'Guernsey', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Guernsey\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"건지, 올더니\",\"br\":\"Guernsey\",\"pt\":\"Guernsey\",\"nl\":\"Guernsey\",\"hr\":\"Guernsey\",\"fa\":\"گرنزی\",\"de\":\"Guernsey\",\"es\":\"Guernsey\",\"fr\":\"Guernesey\",\"ja\":\"ガーンジー\",\"it\":\"Guernsey\",\"cn\":\"根西岛\",\"tr\":\"Alderney\"}', '49.46666666', '-2.58333333', '', 'U+1F1EC U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(92, 'Guinea', 'GIN', '324', 'GN', '224', 'Conakry', 'GNF', 'Guinean franc', 'FG', '.gn', 'Guinée', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Conakry\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"기니\",\"br\":\"Guiné\",\"pt\":\"Guiné\",\"nl\":\"Guinee\",\"hr\":\"Gvineja\",\"fa\":\"گینه\",\"de\":\"Guinea\",\"es\":\"Guinea\",\"fr\":\"Guinée\",\"ja\":\"ギニア\",\"it\":\"Guinea\",\"cn\":\"几内亚\",\"tr\":\"Gine\"}', '11.00000000', '-10.00000000', '', 'U+1F1EC U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1006'),
(93, 'Guinea-Bissau', 'GNB', '624', 'GW', '245', 'Bissau', 'XOF', 'West African CFA franc', 'CFA', '.gw', 'Guiné-Bissau', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Bissau\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"기니비사우\",\"br\":\"Guiné-Bissau\",\"pt\":\"Guiné-Bissau\",\"nl\":\"Guinee-Bissau\",\"hr\":\"Gvineja Bisau\",\"fa\":\"گینه بیسائو\",\"de\":\"Guinea-Bissau\",\"es\":\"Guinea-Bisáu\",\"fr\":\"Guinée-Bissau\",\"ja\":\"ギニアビサウ\",\"it\":\"Guinea-Bissau\",\"cn\":\"几内亚比绍\",\"tr\":\"Gine-bissau\"}', '12.00000000', '-15.00000000', '', 'U+1F1EC U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1007'),
(94, 'Guyana', 'GUY', '328', 'GY', '592', 'Georgetown', 'GYD', 'Guyanese dollar', '$', '.gy', 'Guyana', 'Americas', 'South America', '[{\"zoneName\":\"America/Guyana\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"GYT\",\"tzName\":\"Guyana Time\"}]', '{\"kr\":\"가이아나\",\"br\":\"Guiana\",\"pt\":\"Guiana\",\"nl\":\"Guyana\",\"hr\":\"Gvajana\",\"fa\":\"گویان\",\"de\":\"Guyana\",\"es\":\"Guyana\",\"fr\":\"Guyane\",\"ja\":\"ガイアナ\",\"it\":\"Guyana\",\"cn\":\"圭亚那\",\"tr\":\"Guyana\"}', '5.00000000', '-59.00000000', '', 'U+1F1EC U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q734'),
(95, 'Haiti', 'HTI', '332', 'HT', '509', 'Port-au-Prince', 'HTG', 'Haitian gourde', 'G', '.ht', 'Haïti', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Port-au-Prince\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]', '{\"kr\":\"아이티\",\"br\":\"Haiti\",\"pt\":\"Haiti\",\"nl\":\"Haïti\",\"hr\":\"Haiti\",\"fa\":\"هائیتی\",\"de\":\"Haiti\",\"es\":\"Haiti\",\"fr\":\"Haïti\",\"ja\":\"ハイチ\",\"it\":\"Haiti\",\"cn\":\"海地\",\"tr\":\"Haiti\"}', '19.00000000', '-72.41666666', '', 'U+1F1ED U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q790'),
(96, 'Heard Island and McDonald Islands', 'HMD', '334', 'HM', '672', '', 'AUD', 'Australian dollar', '$', '.hm', 'Heard Island and McDonald Islands', '', '', '[{\"zoneName\":\"Indian/Kerguelen\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TFT\",\"tzName\":\"French Southern and Antarctic Time\"}]', '{\"kr\":\"허드 맥도날드 제도\",\"br\":\"Ilha Heard e Ilhas McDonald\",\"pt\":\"Ilha Heard e Ilhas McDonald\",\"nl\":\"Heard- en McDonaldeilanden\",\"hr\":\"Otok Heard i otočje McDonald\",\"fa\":\"جزیره هرد و جزایر مک‌دونالد\",\"de\":\"Heard und die McDonaldinseln\",\"es\":\"Islas Heard y McDonald\",\"fr\":\"Îles Heard-et-MacDonald\",\"ja\":\"ハード島とマクドナルド諸島\",\"it\":\"Isole Heard e McDonald\",\"cn\":\"赫德·唐纳岛及麦唐纳岛\",\"tr\":\"Heard Adasi Ve Mcdonald Adalari\"}', '-53.10000000', '72.51666666', '', 'U+1F1ED U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(97, 'Honduras', 'HND', '340', 'HN', '504', 'Tegucigalpa', 'HNL', 'Honduran lempira', 'L', '.hn', 'Honduras', 'Americas', 'Central America', '[{\"zoneName\":\"America/Tegucigalpa\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]', '{\"kr\":\"온두라스\",\"br\":\"Honduras\",\"pt\":\"Honduras\",\"nl\":\"Honduras\",\"hr\":\"Honduras\",\"fa\":\"هندوراس\",\"de\":\"Honduras\",\"es\":\"Honduras\",\"fr\":\"Honduras\",\"ja\":\"ホンジュラス\",\"it\":\"Honduras\",\"cn\":\"洪都拉斯\",\"tr\":\"Honduras\"}', '15.00000000', '-86.50000000', '', 'U+1F1ED U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q783'),
(98, 'Hong Kong S.A.R.', 'HKG', '344', 'HK', '852', 'Hong Kong', 'HKD', 'Hong Kong dollar', '$', '.hk', '香港', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Hong_Kong\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"HKT\",\"tzName\":\"Hong Kong Time\"}]', '{\"kr\":\"홍콩\",\"br\":\"Hong Kong\",\"pt\":\"Hong Kong\",\"nl\":\"Hongkong\",\"hr\":\"Hong Kong\",\"fa\":\"هنگ‌کنگ\",\"de\":\"Hong Kong\",\"es\":\"Hong Kong\",\"fr\":\"Hong Kong\",\"ja\":\"香港\",\"it\":\"Hong Kong\",\"cn\":\"中国香港\",\"tr\":\"Hong Kong\"}', '22.25000000', '114.16666666', '', 'U+1F1ED U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q8646'),
(99, 'Hungary', 'HUN', '348', 'HU', '36', 'Budapest', 'HUF', 'Hungarian forint', 'Ft', '.hu', 'Magyarország', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Budapest\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"헝가리\",\"br\":\"Hungria\",\"pt\":\"Hungria\",\"nl\":\"Hongarije\",\"hr\":\"Mađarska\",\"fa\":\"مجارستان\",\"de\":\"Ungarn\",\"es\":\"Hungría\",\"fr\":\"Hongrie\",\"ja\":\"ハンガリー\",\"it\":\"Ungheria\",\"cn\":\"匈牙利\",\"tr\":\"Macaristan\"}', '47.00000000', '20.00000000', '', 'U+1F1ED U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q28'),
(100, 'Iceland', 'ISL', '352', 'IS', '354', 'Reykjavik', 'ISK', 'Icelandic króna', 'kr', '.is', 'Ísland', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Atlantic/Reykjavik\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"아이슬란드\",\"br\":\"Islândia\",\"pt\":\"Islândia\",\"nl\":\"IJsland\",\"hr\":\"Island\",\"fa\":\"ایسلند\",\"de\":\"Island\",\"es\":\"Islandia\",\"fr\":\"Islande\",\"ja\":\"アイスランド\",\"it\":\"Islanda\",\"cn\":\"冰岛\",\"tr\":\"İzlanda\"}', '65.00000000', '-18.00000000', '', 'U+1F1EE U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q189'),
(101, 'India', 'IND', '356', 'IN', '91', 'New Delhi', 'INR', 'Indian rupee', '₹', '.in', 'भारत', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Kolkata\",\"gmtOffset\":19800,\"gmtOffsetName\":\"UTC+05:30\",\"abbreviation\":\"IST\",\"tzName\":\"Indian Standard Time\"}]', '{\"kr\":\"인도\",\"br\":\"Índia\",\"pt\":\"Índia\",\"nl\":\"India\",\"hr\":\"Indija\",\"fa\":\"هند\",\"de\":\"Indien\",\"es\":\"India\",\"fr\":\"Inde\",\"ja\":\"インド\",\"it\":\"India\",\"cn\":\"印度\",\"tr\":\"Hindistan\"}', '20.00000000', '77.00000000', '', 'U+1F1EE U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q668'),
(102, 'Indonesia', 'IDN', '360', 'ID', '62', 'Jakarta', 'IDR', 'Indonesian rupiah', 'Rp', '.id', 'Indonesia', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Jakarta\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"WIB\",\"tzName\":\"Western Indonesian Time\"},{\"zoneName\":\"Asia/Jayapura\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"WIT\",\"tzName\":\"Eastern Indonesian Time\"},{\"zoneName\":\"Asia/Makassar\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"WITA\",\"tzName\":\"Central Indonesia Time\"},{\"zoneName\":\"Asia/Pontianak\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"WIB\",\"tzName\":\"Western Indonesian Time\"}]', '{\"kr\":\"인도네시아\",\"br\":\"Indonésia\",\"pt\":\"Indonésia\",\"nl\":\"Indonesië\",\"hr\":\"Indonezija\",\"fa\":\"اندونزی\",\"de\":\"Indonesien\",\"es\":\"Indonesia\",\"fr\":\"Indonésie\",\"ja\":\"インドネシア\",\"it\":\"Indonesia\",\"cn\":\"印度尼西亚\",\"tr\":\"Endonezya\"}', '-5.00000000', '120.00000000', '', 'U+1F1EE U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q252'),
(103, 'Iran', 'IRN', '364', 'IR', '98', 'Tehran', 'IRR', 'Iranian rial', '﷼', '.ir', 'ایران', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Tehran\",\"gmtOffset\":12600,\"gmtOffsetName\":\"UTC+03:30\",\"abbreviation\":\"IRDT\",\"tzName\":\"Iran Daylight Time\"}]', '{\"kr\":\"이란\",\"br\":\"Irã\",\"pt\":\"Irão\",\"nl\":\"Iran\",\"hr\":\"Iran\",\"fa\":\"ایران\",\"de\":\"Iran\",\"es\":\"Iran\",\"fr\":\"Iran\",\"ja\":\"イラン・イスラム共和国\",\"cn\":\"伊朗\",\"tr\":\"İran\"}', '32.00000000', '53.00000000', '', 'U+1F1EE U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q794'),
(104, 'Iraq', 'IRQ', '368', 'IQ', '964', 'Baghdad', 'IQD', 'Iraqi dinar', 'د.ع', '.iq', 'العراق', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Baghdad\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"이라크\",\"br\":\"Iraque\",\"pt\":\"Iraque\",\"nl\":\"Irak\",\"hr\":\"Irak\",\"fa\":\"عراق\",\"de\":\"Irak\",\"es\":\"Irak\",\"fr\":\"Irak\",\"ja\":\"イラク\",\"it\":\"Iraq\",\"cn\":\"伊拉克\",\"tr\":\"Irak\"}', '33.00000000', '44.00000000', '', 'U+1F1EE U+1F1F6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q796'),
(105, 'Ireland', 'IRL', '372', 'IE', '353', 'Dublin', 'EUR', 'Euro', '€', '.ie', 'Éire', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Dublin\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"아일랜드\",\"br\":\"Irlanda\",\"pt\":\"Irlanda\",\"nl\":\"Ierland\",\"hr\":\"Irska\",\"fa\":\"ایرلند\",\"de\":\"Irland\",\"es\":\"Irlanda\",\"fr\":\"Irlande\",\"ja\":\"アイルランド\",\"it\":\"Irlanda\",\"cn\":\"爱尔兰\",\"tr\":\"İrlanda\"}', '53.00000000', '-8.00000000', '', 'U+1F1EE U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q27'),
(106, 'Israel', 'ISR', '376', 'IL', '972', 'Jerusalem', 'ILS', 'Israeli new shekel', '₪', '.il', 'יִשְׂרָאֵל', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Jerusalem\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"IST\",\"tzName\":\"Israel Standard Time\"}]', '{\"kr\":\"이스라엘\",\"br\":\"Israel\",\"pt\":\"Israel\",\"nl\":\"Israël\",\"hr\":\"Izrael\",\"fa\":\"اسرائیل\",\"de\":\"Israel\",\"es\":\"Israel\",\"fr\":\"Israël\",\"ja\":\"イスラエル\",\"it\":\"Israele\",\"cn\":\"以色列\",\"tr\":\"İsrail\"}', '31.50000000', '34.75000000', '', 'U+1F1EE U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q801'),
(107, 'Italy', 'ITA', '380', 'IT', '39', 'Rome', 'EUR', 'Euro', '€', '.it', 'Italia', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Rome\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"이탈리아\",\"br\":\"Itália\",\"pt\":\"Itália\",\"nl\":\"Italië\",\"hr\":\"Italija\",\"fa\":\"ایتالیا\",\"de\":\"Italien\",\"es\":\"Italia\",\"fr\":\"Italie\",\"ja\":\"イタリア\",\"it\":\"Italia\",\"cn\":\"意大利\",\"tr\":\"İtalya\"}', '42.83333333', '12.83333333', '', 'U+1F1EE U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q38'),
(108, 'Jamaica', 'JAM', '388', 'JM', '+1-876', 'Kingston', 'JMD', 'Jamaican dollar', 'J$', '.jm', 'Jamaica', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Jamaica\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]', '{\"kr\":\"자메이카\",\"br\":\"Jamaica\",\"pt\":\"Jamaica\",\"nl\":\"Jamaica\",\"hr\":\"Jamajka\",\"fa\":\"جامائیکا\",\"de\":\"Jamaika\",\"es\":\"Jamaica\",\"fr\":\"Jamaïque\",\"ja\":\"ジャマイカ\",\"it\":\"Giamaica\",\"cn\":\"牙买加\",\"tr\":\"Jamaika\"}', '18.25000000', '-77.50000000', '', 'U+1F1EF U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q766'),
(109, 'Japan', 'JPN', '392', 'JP', '81', 'Tokyo', 'JPY', 'Japanese yen', '¥', '.jp', '日本', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Tokyo\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"JST\",\"tzName\":\"Japan Standard Time\"}]', '{\"kr\":\"일본\",\"br\":\"Japão\",\"pt\":\"Japão\",\"nl\":\"Japan\",\"hr\":\"Japan\",\"fa\":\"ژاپن\",\"de\":\"Japan\",\"es\":\"Japón\",\"fr\":\"Japon\",\"ja\":\"日本\",\"it\":\"Giappone\",\"cn\":\"日本\",\"tr\":\"Japonya\"}', '36.00000000', '138.00000000', '', 'U+1F1EF U+1F1F5', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q17'),
(110, 'Jersey', 'JEY', '832', 'JE', '+44-1534', 'Saint Helier', 'GBP', 'British pound', '£', '.je', 'Jersey', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Jersey\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"저지 섬\",\"br\":\"Jersey\",\"pt\":\"Jersey\",\"nl\":\"Jersey\",\"hr\":\"Jersey\",\"fa\":\"جرزی\",\"de\":\"Jersey\",\"es\":\"Jersey\",\"fr\":\"Jersey\",\"ja\":\"ジャージー\",\"it\":\"Isola di Jersey\",\"cn\":\"泽西岛\",\"tr\":\"Jersey\"}', '49.25000000', '-2.16666666', '', 'U+1F1EF U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q785'),
(111, 'Jordan', 'JOR', '400', 'JO', '962', 'Amman', 'JOD', 'Jordanian dinar', 'ا.د', '.jo', 'الأردن', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Amman\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"요르단\",\"br\":\"Jordânia\",\"pt\":\"Jordânia\",\"nl\":\"Jordanië\",\"hr\":\"Jordan\",\"fa\":\"اردن\",\"de\":\"Jordanien\",\"es\":\"Jordania\",\"fr\":\"Jordanie\",\"ja\":\"ヨルダン\",\"it\":\"Giordania\",\"cn\":\"约旦\",\"tr\":\"Ürdün\"}', '31.00000000', '36.00000000', '', 'U+1F1EF U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q810'),
(112, 'Kazakhstan', 'KAZ', '398', 'KZ', '7', 'Astana', 'KZT', 'Kazakhstani tenge', 'лв', '.kz', 'Қазақстан', 'Asia', 'Central Asia', '[{\"zoneName\":\"Asia/Almaty\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"ALMT\",\"tzName\":\"Alma-Ata Time[1\"},{\"zoneName\":\"Asia/Aqtau\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"AQTT\",\"tzName\":\"Aqtobe Time\"},{\"zoneName\":\"Asia/Aqtobe\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"AQTT\",\"tzName\":\"Aqtobe Time\"},{\"zoneName\":\"Asia/Atyrau\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MSD+1\",\"tzName\":\"Moscow Daylight Time+1\"},{\"zoneName\":\"Asia/Oral\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"ORAT\",\"tzName\":\"Oral Time\"},{\"zoneName\":\"Asia/Qostanay\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"QYZST\",\"tzName\":\"Qyzylorda Summer Time\"},{\"zoneName\":\"Asia/Qyzylorda\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"QYZT\",\"tzName\":\"Qyzylorda Summer Time\"}]', '{\"kr\":\"카자흐스탄\",\"br\":\"Cazaquistão\",\"pt\":\"Cazaquistão\",\"nl\":\"Kazachstan\",\"hr\":\"Kazahstan\",\"fa\":\"قزاقستان\",\"de\":\"Kasachstan\",\"es\":\"Kazajistán\",\"fr\":\"Kazakhstan\",\"ja\":\"カザフスタン\",\"it\":\"Kazakistan\",\"cn\":\"哈萨克斯坦\",\"tr\":\"Kazakistan\"}', '48.00000000', '68.00000000', '', 'U+1F1F0 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q232'),
(113, 'Kenya', 'KEN', '404', 'KE', '254', 'Nairobi', 'KES', 'Kenyan shilling', 'KSh', '.ke', 'Kenya', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Nairobi\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"케냐\",\"br\":\"Quênia\",\"pt\":\"Quénia\",\"nl\":\"Kenia\",\"hr\":\"Kenija\",\"fa\":\"کنیا\",\"de\":\"Kenia\",\"es\":\"Kenia\",\"fr\":\"Kenya\",\"ja\":\"ケニア\",\"it\":\"Kenya\",\"cn\":\"肯尼亚\",\"tr\":\"Kenya\"}', '1.00000000', '38.00000000', '', 'U+1F1F0 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q114'),
(114, 'Kiribati', 'KIR', '296', 'KI', '686', 'Tarawa', 'AUD', 'Australian dollar', '$', '.ki', 'Kiribati', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Enderbury\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"PHOT\",\"tzName\":\"Phoenix Island Time\"},{\"zoneName\":\"Pacific/Kiritimati\",\"gmtOffset\":50400,\"gmtOffsetName\":\"UTC+14:00\",\"abbreviation\":\"LINT\",\"tzName\":\"Line Islands Time\"},{\"zoneName\":\"Pacific/Tarawa\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"GILT\",\"tzName\":\"Gilbert Island Time\"}]', '{\"kr\":\"키리바시\",\"br\":\"Kiribati\",\"pt\":\"Quiribáti\",\"nl\":\"Kiribati\",\"hr\":\"Kiribati\",\"fa\":\"کیریباتی\",\"de\":\"Kiribati\",\"es\":\"Kiribati\",\"fr\":\"Kiribati\",\"ja\":\"キリバス\",\"it\":\"Kiribati\",\"cn\":\"基里巴斯\",\"tr\":\"Kiribati\"}', '1.41666666', '173.00000000', '', 'U+1F1F0 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q710'),
(115, 'North Korea', 'PRK', '408', 'KP', '850', 'Pyongyang', 'KPW', 'North Korean Won', '₩', '.kp', '북한', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Pyongyang\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"KST\",\"tzName\":\"Korea Standard Time\"}]', '{\"kr\":\"조선민주주의인민공화국\",\"br\":\"Coreia do Norte\",\"pt\":\"Coreia do Norte\",\"nl\":\"Noord-Korea\",\"hr\":\"Sjeverna Koreja\",\"fa\":\"کره جنوبی\",\"de\":\"Nordkorea\",\"es\":\"Corea del Norte\",\"fr\":\"Corée du Nord\",\"ja\":\"朝鮮民主主義人民共和国\",\"it\":\"Corea del Nord\",\"cn\":\"朝鲜\",\"tr\":\"Kuzey Kore\"}', '40.00000000', '127.00000000', '', 'U+1F1F0 U+1F1F5', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q423'),
(116, 'South Korea', 'KOR', '410', 'KR', '82', 'Seoul', 'KRW', 'Won', '₩', '.kr', '대한민국', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Seoul\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"KST\",\"tzName\":\"Korea Standard Time\"}]', '{\"kr\":\"대한민국\",\"br\":\"Coreia do Sul\",\"pt\":\"Coreia do Sul\",\"nl\":\"Zuid-Korea\",\"hr\":\"Južna Koreja\",\"fa\":\"کره شمالی\",\"de\":\"Südkorea\",\"es\":\"Corea del Sur\",\"fr\":\"Corée du Sud\",\"ja\":\"大韓民国\",\"it\":\"Corea del Sud\",\"cn\":\"韩国\",\"tr\":\"Güney Kore\"}', '37.00000000', '127.50000000', '', 'U+1F1F0 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q884'),
(117, 'Kuwait', 'KWT', '414', 'KW', '965', 'Kuwait City', 'KWD', 'Kuwaiti dinar', 'ك.د', '.kw', 'الكويت', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Kuwait\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"쿠웨이트\",\"br\":\"Kuwait\",\"pt\":\"Kuwait\",\"nl\":\"Koeweit\",\"hr\":\"Kuvajt\",\"fa\":\"کویت\",\"de\":\"Kuwait\",\"es\":\"Kuwait\",\"fr\":\"Koweït\",\"ja\":\"クウェート\",\"it\":\"Kuwait\",\"cn\":\"科威特\",\"tr\":\"Kuveyt\"}', '29.50000000', '45.75000000', '', 'U+1F1F0 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q817'),
(118, 'Kyrgyzstan', 'KGZ', '417', 'KG', '996', 'Bishkek', 'KGS', 'Kyrgyzstani som', 'лв', '.kg', 'Кыргызстан', 'Asia', 'Central Asia', '[{\"zoneName\":\"Asia/Bishkek\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"KGT\",\"tzName\":\"Kyrgyzstan Time\"}]', '{\"kr\":\"키르기스스탄\",\"br\":\"Quirguistão\",\"pt\":\"Quirguizistão\",\"nl\":\"Kirgizië\",\"hr\":\"Kirgistan\",\"fa\":\"قرقیزستان\",\"de\":\"Kirgisistan\",\"es\":\"Kirguizistán\",\"fr\":\"Kirghizistan\",\"ja\":\"キルギス\",\"it\":\"Kirghizistan\",\"cn\":\"吉尔吉斯斯坦\",\"tr\":\"Kirgizistan\"}', '41.00000000', '75.00000000', '', 'U+1F1F0 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q813'),
(119, 'Laos', 'LAO', '418', 'LA', '856', 'Vientiane', 'LAK', 'Lao kip', '₭', '.la', 'ສປປລາວ', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Vientiane\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]', '{\"kr\":\"라오스\",\"br\":\"Laos\",\"pt\":\"Laos\",\"nl\":\"Laos\",\"hr\":\"Laos\",\"fa\":\"لائوس\",\"de\":\"Laos\",\"es\":\"Laos\",\"fr\":\"Laos\",\"ja\":\"ラオス人民民主共和国\",\"it\":\"Laos\",\"cn\":\"寮人民民主共和国\",\"tr\":\"Laos\"}', '18.00000000', '105.00000000', '', 'U+1F1F1 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q819'),
(120, 'Latvia', 'LVA', '428', 'LV', '371', 'Riga', 'EUR', 'Euro', '€', '.lv', 'Latvija', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Riga\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"라트비아\",\"br\":\"Letônia\",\"pt\":\"Letónia\",\"nl\":\"Letland\",\"hr\":\"Latvija\",\"fa\":\"لتونی\",\"de\":\"Lettland\",\"es\":\"Letonia\",\"fr\":\"Lettonie\",\"ja\":\"ラトビア\",\"it\":\"Lettonia\",\"cn\":\"拉脱维亚\",\"tr\":\"Letonya\"}', '57.00000000', '25.00000000', '', 'U+1F1F1 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q211'),
(121, 'Lebanon', 'LBN', '422', 'LB', '961', 'Beirut', 'LBP', 'Lebanese pound', '£', '.lb', 'لبنان', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Beirut\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"레바논\",\"br\":\"Líbano\",\"pt\":\"Líbano\",\"nl\":\"Libanon\",\"hr\":\"Libanon\",\"fa\":\"لبنان\",\"de\":\"Libanon\",\"es\":\"Líbano\",\"fr\":\"Liban\",\"ja\":\"レバノン\",\"it\":\"Libano\",\"cn\":\"黎巴嫩\",\"tr\":\"Lübnan\"}', '33.83333333', '35.83333333', '', 'U+1F1F1 U+1F1E7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q822'),
(122, 'Lesotho', 'LSO', '426', 'LS', '266', 'Maseru', 'LSL', 'Lesotho loti', 'L', '.ls', 'Lesotho', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Africa/Maseru\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]', '{\"kr\":\"레소토\",\"br\":\"Lesoto\",\"pt\":\"Lesoto\",\"nl\":\"Lesotho\",\"hr\":\"Lesoto\",\"fa\":\"لسوتو\",\"de\":\"Lesotho\",\"es\":\"Lesotho\",\"fr\":\"Lesotho\",\"ja\":\"レソト\",\"it\":\"Lesotho\",\"cn\":\"莱索托\",\"tr\":\"Lesotho\"}', '-29.50000000', '28.50000000', '', 'U+1F1F1 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1013'),
(123, 'Liberia', 'LBR', '430', 'LR', '231', 'Monrovia', 'LRD', 'Liberian dollar', '$', '.lr', 'Liberia', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Monrovia\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"라이베리아\",\"br\":\"Libéria\",\"pt\":\"Libéria\",\"nl\":\"Liberia\",\"hr\":\"Liberija\",\"fa\":\"لیبریا\",\"de\":\"Liberia\",\"es\":\"Liberia\",\"fr\":\"Liberia\",\"ja\":\"リベリア\",\"it\":\"Liberia\",\"cn\":\"利比里亚\",\"tr\":\"Liberya\"}', '6.50000000', '-9.50000000', '', 'U+1F1F1 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1014'),
(124, 'Libya', 'LBY', '434', 'LY', '218', 'Tripolis', 'LYD', 'Libyan dinar', 'د.ل', '.ly', '‏ليبيا', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Tripoli\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"리비아\",\"br\":\"Líbia\",\"pt\":\"Líbia\",\"nl\":\"Libië\",\"hr\":\"Libija\",\"fa\":\"لیبی\",\"de\":\"Libyen\",\"es\":\"Libia\",\"fr\":\"Libye\",\"ja\":\"リビア\",\"it\":\"Libia\",\"cn\":\"利比亚\",\"tr\":\"Libya\"}', '25.00000000', '17.00000000', '', 'U+1F1F1 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1016'),
(125, 'Liechtenstein', 'LIE', '438', 'LI', '423', 'Vaduz', 'CHF', 'Swiss franc', 'CHf', '.li', 'Liechtenstein', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Vaduz\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"리히텐슈타인\",\"br\":\"Liechtenstein\",\"pt\":\"Listenstaine\",\"nl\":\"Liechtenstein\",\"hr\":\"Lihtenštajn\",\"fa\":\"لیختن‌اشتاین\",\"de\":\"Liechtenstein\",\"es\":\"Liechtenstein\",\"fr\":\"Liechtenstein\",\"ja\":\"リヒテンシュタイン\",\"it\":\"Liechtenstein\",\"cn\":\"列支敦士登\",\"tr\":\"Lihtenştayn\"}', '47.26666666', '9.53333333', '', 'U+1F1F1 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q347'),
(126, 'Lithuania', 'LTU', '440', 'LT', '370', 'Vilnius', 'EUR', 'Euro', '€', '.lt', 'Lietuva', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Vilnius\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"리투아니아\",\"br\":\"Lituânia\",\"pt\":\"Lituânia\",\"nl\":\"Litouwen\",\"hr\":\"Litva\",\"fa\":\"لیتوانی\",\"de\":\"Litauen\",\"es\":\"Lituania\",\"fr\":\"Lituanie\",\"ja\":\"リトアニア\",\"it\":\"Lituania\",\"cn\":\"立陶宛\",\"tr\":\"Litvanya\"}', '56.00000000', '24.00000000', '', 'U+1F1F1 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q37');
INSERT INTO `countries` (`id`, `name`, `iso3`, `numeric_code`, `iso2`, `phonecode`, `capital`, `currency`, `currency_name`, `currency_symbol`, `tld`, `native`, `region`, `subregion`, `timezones`, `translations`, `latitude`, `longitude`, `emoji`, `emojiU`, `created_at`, `updated_at`, `flag`, `wikiDataId`) VALUES
(127, 'Luxembourg', 'LUX', '442', 'LU', '352', 'Luxembourg', 'EUR', 'Euro', '€', '.lu', 'Luxembourg', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Luxembourg\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"룩셈부르크\",\"br\":\"Luxemburgo\",\"pt\":\"Luxemburgo\",\"nl\":\"Luxemburg\",\"hr\":\"Luksemburg\",\"fa\":\"لوکزامبورگ\",\"de\":\"Luxemburg\",\"es\":\"Luxemburgo\",\"fr\":\"Luxembourg\",\"ja\":\"ルクセンブルク\",\"it\":\"Lussemburgo\",\"cn\":\"卢森堡\",\"tr\":\"Lüksemburg\"}', '49.75000000', '6.16666666', '', 'U+1F1F1 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q32'),
(128, 'Macau S.A.R.', 'MAC', '446', 'MO', '853', 'Macao', 'MOP', 'Macanese pataca', '$', '.mo', '澳門', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Macau\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"}]', '{\"kr\":\"마카오\",\"br\":\"Macau\",\"pt\":\"Macau\",\"nl\":\"Macao\",\"hr\":\"Makao\",\"fa\":\"مکائو\",\"de\":\"Macao\",\"es\":\"Macao\",\"fr\":\"Macao\",\"ja\":\"マカオ\",\"it\":\"Macao\",\"cn\":\"中国澳门\",\"tr\":\"Makao\"}', '22.16666666', '113.55000000', '', 'U+1F1F2 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(129, 'Macedonia', 'MKD', '807', 'MK', '389', 'Skopje', 'MKD', 'Denar', 'ден', '.mk', 'Северна Македонија', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Skopje\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"마케도니아\",\"br\":\"Macedônia\",\"pt\":\"Macedónia\",\"nl\":\"Macedonië\",\"hr\":\"Makedonija\",\"fa\":\"\",\"de\":\"Mazedonien\",\"es\":\"Macedonia\",\"fr\":\"Macédoine\",\"ja\":\"マケドニア旧ユーゴスラビア共和国\",\"it\":\"Macedonia\",\"cn\":\"马其顿\",\"tr\":\"Kuzey Makedonya\"}', '41.83333333', '22.00000000', '', 'U+1F1F2 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q221'),
(130, 'Madagascar', 'MDG', '450', 'MG', '261', 'Antananarivo', 'MGA', 'Malagasy ariary', 'Ar', '.mg', 'Madagasikara', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Antananarivo\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"마다가스카르\",\"br\":\"Madagascar\",\"pt\":\"Madagáscar\",\"nl\":\"Madagaskar\",\"hr\":\"Madagaskar\",\"fa\":\"ماداگاسکار\",\"de\":\"Madagaskar\",\"es\":\"Madagascar\",\"fr\":\"Madagascar\",\"ja\":\"マダガスカル\",\"it\":\"Madagascar\",\"cn\":\"马达加斯加\",\"tr\":\"Madagaskar\"}', '-20.00000000', '47.00000000', '', 'U+1F1F2 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1019'),
(131, 'Malawi', 'MWI', '454', 'MW', '265', 'Lilongwe', 'MWK', 'Malawian kwacha', 'MK', '.mw', 'Malawi', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Blantyre\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"말라위\",\"br\":\"Malawi\",\"pt\":\"Malávi\",\"nl\":\"Malawi\",\"hr\":\"Malavi\",\"fa\":\"مالاوی\",\"de\":\"Malawi\",\"es\":\"Malawi\",\"fr\":\"Malawi\",\"ja\":\"マラウイ\",\"it\":\"Malawi\",\"cn\":\"马拉维\",\"tr\":\"Malavi\"}', '-13.50000000', '34.00000000', '', 'U+1F1F2 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1020'),
(132, 'Malaysia', 'MYS', '458', 'MY', '60', 'Kuala Lumpur', 'MYR', 'Malaysian ringgit', 'RM', '.my', 'Malaysia', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Kuala_Lumpur\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"MYT\",\"tzName\":\"Malaysia Time\"},{\"zoneName\":\"Asia/Kuching\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"MYT\",\"tzName\":\"Malaysia Time\"}]', '{\"kr\":\"말레이시아\",\"br\":\"Malásia\",\"pt\":\"Malásia\",\"nl\":\"Maleisië\",\"hr\":\"Malezija\",\"fa\":\"مالزی\",\"de\":\"Malaysia\",\"es\":\"Malasia\",\"fr\":\"Malaisie\",\"ja\":\"マレーシア\",\"it\":\"Malesia\",\"cn\":\"马来西亚\",\"tr\":\"Malezya\"}', '2.50000000', '112.50000000', '', 'U+1F1F2 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q833'),
(133, 'Maldives', 'MDV', '462', 'MV', '960', 'Male', 'MVR', 'Maldivian rufiyaa', 'Rf', '.mv', 'Maldives', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Indian/Maldives\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MVT\",\"tzName\":\"Maldives Time\"}]', '{\"kr\":\"몰디브\",\"br\":\"Maldivas\",\"pt\":\"Maldivas\",\"nl\":\"Maldiven\",\"hr\":\"Maldivi\",\"fa\":\"مالدیو\",\"de\":\"Malediven\",\"es\":\"Maldivas\",\"fr\":\"Maldives\",\"ja\":\"モルディブ\",\"it\":\"Maldive\",\"cn\":\"马尔代夫\",\"tr\":\"Maldivler\"}', '3.25000000', '73.00000000', '', 'U+1F1F2 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q826'),
(134, 'Mali', 'MLI', '466', 'ML', '223', 'Bamako', 'XOF', 'West African CFA franc', 'CFA', '.ml', 'Mali', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Bamako\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"말리\",\"br\":\"Mali\",\"pt\":\"Mali\",\"nl\":\"Mali\",\"hr\":\"Mali\",\"fa\":\"مالی\",\"de\":\"Mali\",\"es\":\"Mali\",\"fr\":\"Mali\",\"ja\":\"マリ\",\"it\":\"Mali\",\"cn\":\"马里\",\"tr\":\"Mali\"}', '17.00000000', '-4.00000000', '', 'U+1F1F2 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q912'),
(135, 'Malta', 'MLT', '470', 'MT', '356', 'Valletta', 'EUR', 'Euro', '€', '.mt', 'Malta', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Malta\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"몰타\",\"br\":\"Malta\",\"pt\":\"Malta\",\"nl\":\"Malta\",\"hr\":\"Malta\",\"fa\":\"مالت\",\"de\":\"Malta\",\"es\":\"Malta\",\"fr\":\"Malte\",\"ja\":\"マルタ\",\"it\":\"Malta\",\"cn\":\"马耳他\",\"tr\":\"Malta\"}', '35.83333333', '14.58333333', '', 'U+1F1F2 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q233'),
(136, 'Man (Isle of)', 'IMN', '833', 'IM', '+44-1624', 'Douglas, Isle of Man', 'GBP', 'British pound', '£', '.im', 'Isle of Man', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Isle_of_Man\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"맨 섬\",\"br\":\"Ilha de Man\",\"pt\":\"Ilha de Man\",\"nl\":\"Isle of Man\",\"hr\":\"Otok Man\",\"fa\":\"جزیره من\",\"de\":\"Insel Man\",\"es\":\"Isla de Man\",\"fr\":\"Île de Man\",\"ja\":\"マン島\",\"it\":\"Isola di Man\",\"cn\":\"马恩岛\",\"tr\":\"Man Adasi\"}', '54.25000000', '-4.50000000', '', 'U+1F1EE U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(137, 'Marshall Islands', 'MHL', '584', 'MH', '692', 'Majuro', 'USD', 'United States dollar', '$', '.mh', 'M̧ajeļ', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Kwajalein\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"MHT\",\"tzName\":\"Marshall Islands Time\"},{\"zoneName\":\"Pacific/Majuro\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"MHT\",\"tzName\":\"Marshall Islands Time\"}]', '{\"kr\":\"마셜 제도\",\"br\":\"Ilhas Marshall\",\"pt\":\"Ilhas Marshall\",\"nl\":\"Marshalleilanden\",\"hr\":\"Maršalovi Otoci\",\"fa\":\"جزایر مارشال\",\"de\":\"Marshallinseln\",\"es\":\"Islas Marshall\",\"fr\":\"Îles Marshall\",\"ja\":\"マーシャル諸島\",\"it\":\"Isole Marshall\",\"cn\":\"马绍尔群岛\",\"tr\":\"Marşal Adalari\"}', '9.00000000', '168.00000000', '', 'U+1F1F2 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q709'),
(138, 'Martinique', 'MTQ', '474', 'MQ', '596', 'Fort-de-France', 'EUR', 'Euro', '€', '.mq', 'Martinique', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Martinique\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"마르티니크\",\"br\":\"Martinica\",\"pt\":\"Martinica\",\"nl\":\"Martinique\",\"hr\":\"Martinique\",\"fa\":\"مونتسرات\",\"de\":\"Martinique\",\"es\":\"Martinica\",\"fr\":\"Martinique\",\"ja\":\"マルティニーク\",\"it\":\"Martinica\",\"cn\":\"马提尼克岛\",\"tr\":\"Martinik\"}', '14.66666700', '-61.00000000', '', 'U+1F1F2 U+1F1F6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(139, 'Mauritania', 'MRT', '478', 'MR', '222', 'Nouakchott', 'MRO', 'Mauritanian ouguiya', 'MRU', '.mr', 'موريتانيا', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Nouakchott\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"모리타니\",\"br\":\"Mauritânia\",\"pt\":\"Mauritânia\",\"nl\":\"Mauritanië\",\"hr\":\"Mauritanija\",\"fa\":\"موریتانی\",\"de\":\"Mauretanien\",\"es\":\"Mauritania\",\"fr\":\"Mauritanie\",\"ja\":\"モーリタニア\",\"it\":\"Mauritania\",\"cn\":\"毛里塔尼亚\",\"tr\":\"Moritanya\"}', '20.00000000', '-12.00000000', '', 'U+1F1F2 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1025'),
(140, 'Mauritius', 'MUS', '480', 'MU', '230', 'Port Louis', 'MUR', 'Mauritian rupee', '₨', '.mu', 'Maurice', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Mauritius\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MUT\",\"tzName\":\"Mauritius Time\"}]', '{\"kr\":\"모리셔스\",\"br\":\"Maurício\",\"pt\":\"Maurícia\",\"nl\":\"Mauritius\",\"hr\":\"Mauricijus\",\"fa\":\"موریس\",\"de\":\"Mauritius\",\"es\":\"Mauricio\",\"fr\":\"Île Maurice\",\"ja\":\"モーリシャス\",\"it\":\"Mauritius\",\"cn\":\"毛里求斯\",\"tr\":\"Morityus\"}', '-20.28333333', '57.55000000', '', 'U+1F1F2 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1027'),
(141, 'Mayotte', 'MYT', '175', 'YT', '262', 'Mamoudzou', 'EUR', 'Euro', '€', '.yt', 'Mayotte', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Mayotte\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"마요트\",\"br\":\"Mayotte\",\"pt\":\"Mayotte\",\"nl\":\"Mayotte\",\"hr\":\"Mayotte\",\"fa\":\"مایوت\",\"de\":\"Mayotte\",\"es\":\"Mayotte\",\"fr\":\"Mayotte\",\"ja\":\"マヨット\",\"it\":\"Mayotte\",\"cn\":\"马约特\",\"tr\":\"Mayotte\"}', '-12.83333333', '45.16666666', '', 'U+1F1FE U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(142, 'Mexico', 'MEX', '484', 'MX', '52', 'Ciudad de México', 'MXN', 'Mexican peso', '$', '.mx', 'México', 'Americas', 'Central America', '[{\"zoneName\":\"America/Bahia_Banderas\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Cancun\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Chihuahua\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Hermosillo\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Matamoros\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Mazatlan\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Merida\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Mexico_City\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Monterrey\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Ojinaga\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Tijuana\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"}]', '{\"kr\":\"멕시코\",\"br\":\"México\",\"pt\":\"México\",\"nl\":\"Mexico\",\"hr\":\"Meksiko\",\"fa\":\"مکزیک\",\"de\":\"Mexiko\",\"es\":\"México\",\"fr\":\"Mexique\",\"ja\":\"メキシコ\",\"it\":\"Messico\",\"cn\":\"墨西哥\",\"tr\":\"Meksika\"}', '23.00000000', '-102.00000000', '', 'U+1F1F2 U+1F1FD', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q96'),
(143, 'Micronesia', 'FSM', '583', 'FM', '691', 'Palikir', 'USD', 'United States dollar', '$', '.fm', 'Micronesia', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Chuuk\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"CHUT\",\"tzName\":\"Chuuk Time\"},{\"zoneName\":\"Pacific/Kosrae\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"KOST\",\"tzName\":\"Kosrae Time\"},{\"zoneName\":\"Pacific/Pohnpei\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"PONT\",\"tzName\":\"Pohnpei Standard Time\"}]', '{\"kr\":\"미크로네시아 연방\",\"br\":\"Micronésia\",\"pt\":\"Micronésia\",\"nl\":\"Micronesië\",\"hr\":\"Mikronezija\",\"fa\":\"ایالات فدرال میکرونزی\",\"de\":\"Mikronesien\",\"es\":\"Micronesia\",\"fr\":\"Micronésie\",\"ja\":\"ミクロネシア連邦\",\"it\":\"Micronesia\",\"cn\":\"密克罗尼西亚\",\"tr\":\"Mikronezya\"}', '6.91666666', '158.25000000', '', 'U+1F1EB U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q702'),
(144, 'Moldova', 'MDA', '498', 'MD', '373', 'Chisinau', 'MDL', 'Moldovan leu', 'L', '.md', 'Moldova', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Chisinau\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"몰도바\",\"br\":\"Moldávia\",\"pt\":\"Moldávia\",\"nl\":\"Moldavië\",\"hr\":\"Moldova\",\"fa\":\"مولداوی\",\"de\":\"Moldawie\",\"es\":\"Moldavia\",\"fr\":\"Moldavie\",\"ja\":\"モルドバ共和国\",\"it\":\"Moldavia\",\"cn\":\"摩尔多瓦\",\"tr\":\"Moldova\"}', '47.00000000', '29.00000000', '', 'U+1F1F2 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q217'),
(145, 'Monaco', 'MCO', '492', 'MC', '377', 'Monaco', 'EUR', 'Euro', '€', '.mc', 'Monaco', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Monaco\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"모나코\",\"br\":\"Mônaco\",\"pt\":\"Mónaco\",\"nl\":\"Monaco\",\"hr\":\"Monako\",\"fa\":\"موناکو\",\"de\":\"Monaco\",\"es\":\"Mónaco\",\"fr\":\"Monaco\",\"ja\":\"モナコ\",\"it\":\"Principato di Monaco\",\"cn\":\"摩纳哥\",\"tr\":\"Monako\"}', '43.73333333', '7.40000000', '', 'U+1F1F2 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q235'),
(146, 'Mongolia', 'MNG', '496', 'MN', '976', 'Ulan Bator', 'MNT', 'Mongolian tögrög', '₮', '.mn', 'Монгол улс', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Choibalsan\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CHOT\",\"tzName\":\"Choibalsan Standard Time\"},{\"zoneName\":\"Asia/Hovd\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"HOVT\",\"tzName\":\"Hovd Time\"},{\"zoneName\":\"Asia/Ulaanbaatar\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"ULAT\",\"tzName\":\"Ulaanbaatar Standard Time\"}]', '{\"kr\":\"몽골\",\"br\":\"Mongólia\",\"pt\":\"Mongólia\",\"nl\":\"Mongolië\",\"hr\":\"Mongolija\",\"fa\":\"مغولستان\",\"de\":\"Mongolei\",\"es\":\"Mongolia\",\"fr\":\"Mongolie\",\"ja\":\"モンゴル\",\"it\":\"Mongolia\",\"cn\":\"蒙古\",\"tr\":\"Moğolistan\"}', '46.00000000', '105.00000000', '', 'U+1F1F2 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q711'),
(147, 'Montenegro', 'MNE', '499', 'ME', '382', 'Podgorica', 'EUR', 'Euro', '€', '.me', 'Црна Гора', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Podgorica\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"몬테네그로\",\"br\":\"Montenegro\",\"pt\":\"Montenegro\",\"nl\":\"Montenegro\",\"hr\":\"Crna Gora\",\"fa\":\"مونته‌نگرو\",\"de\":\"Montenegro\",\"es\":\"Montenegro\",\"fr\":\"Monténégro\",\"ja\":\"モンテネグロ\",\"it\":\"Montenegro\",\"cn\":\"黑山\",\"tr\":\"Karadağ\"}', '42.50000000', '19.30000000', '', 'U+1F1F2 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q236'),
(148, 'Montserrat', 'MSR', '500', 'MS', '+1-664', 'Plymouth', 'XCD', 'Eastern Caribbean dollar', '$', '.ms', 'Montserrat', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Montserrat\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"몬트세랫\",\"br\":\"Montserrat\",\"pt\":\"Monserrate\",\"nl\":\"Montserrat\",\"hr\":\"Montserrat\",\"fa\":\"مایوت\",\"de\":\"Montserrat\",\"es\":\"Montserrat\",\"fr\":\"Montserrat\",\"ja\":\"モントセラト\",\"it\":\"Montserrat\",\"cn\":\"蒙特塞拉特\",\"tr\":\"Montserrat\"}', '16.75000000', '-62.20000000', '', 'U+1F1F2 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(149, 'Morocco', 'MAR', '504', 'MA', '212', 'Rabat', 'MAD', 'Moroccan dirham', 'DH', '.ma', 'المغرب', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Casablanca\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WEST\",\"tzName\":\"Western European Summer Time\"}]', '{\"kr\":\"모로코\",\"br\":\"Marrocos\",\"pt\":\"Marrocos\",\"nl\":\"Marokko\",\"hr\":\"Maroko\",\"fa\":\"مراکش\",\"de\":\"Marokko\",\"es\":\"Marruecos\",\"fr\":\"Maroc\",\"ja\":\"モロッコ\",\"it\":\"Marocco\",\"cn\":\"摩洛哥\",\"tr\":\"Fas\"}', '32.00000000', '-5.00000000', '', 'U+1F1F2 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1028'),
(150, 'Mozambique', 'MOZ', '508', 'MZ', '258', 'Maputo', 'MZN', 'Mozambican metical', 'MT', '.mz', 'Moçambique', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Maputo\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"모잠비크\",\"br\":\"Moçambique\",\"pt\":\"Moçambique\",\"nl\":\"Mozambique\",\"hr\":\"Mozambik\",\"fa\":\"موزامبیک\",\"de\":\"Mosambik\",\"es\":\"Mozambique\",\"fr\":\"Mozambique\",\"ja\":\"モザンビーク\",\"it\":\"Mozambico\",\"cn\":\"莫桑比克\",\"tr\":\"Mozambik\"}', '-18.25000000', '35.00000000', '', 'U+1F1F2 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1029'),
(151, 'Myanmar', 'MMR', '104', 'MM', '95', 'Nay Pyi Taw', 'MMK', 'Burmese kyat', 'K', '.mm', 'မြန်မာ', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Yangon\",\"gmtOffset\":23400,\"gmtOffsetName\":\"UTC+06:30\",\"abbreviation\":\"MMT\",\"tzName\":\"Myanmar Standard Time\"}]', '{\"kr\":\"미얀마\",\"br\":\"Myanmar\",\"pt\":\"Myanmar\",\"nl\":\"Myanmar\",\"hr\":\"Mijanmar\",\"fa\":\"میانمار\",\"de\":\"Myanmar\",\"es\":\"Myanmar\",\"fr\":\"Myanmar\",\"ja\":\"ミャンマー\",\"it\":\"Birmania\",\"cn\":\"缅甸\",\"tr\":\"Myanmar\"}', '22.00000000', '98.00000000', '', 'U+1F1F2 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q836'),
(152, 'Namibia', 'NAM', '516', 'NA', '264', 'Windhoek', 'NAD', 'Namibian dollar', '$', '.na', 'Namibia', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Africa/Windhoek\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"WAST\",\"tzName\":\"West Africa Summer Time\"}]', '{\"kr\":\"나미비아\",\"br\":\"Namíbia\",\"pt\":\"Namíbia\",\"nl\":\"Namibië\",\"hr\":\"Namibija\",\"fa\":\"نامیبیا\",\"de\":\"Namibia\",\"es\":\"Namibia\",\"fr\":\"Namibie\",\"ja\":\"ナミビア\",\"it\":\"Namibia\",\"cn\":\"纳米比亚\",\"tr\":\"Namibya\"}', '-22.00000000', '17.00000000', '', 'U+1F1F3 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1030'),
(153, 'Nauru', 'NRU', '520', 'NR', '674', 'Yaren', 'AUD', 'Australian dollar', '$', '.nr', 'Nauru', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Nauru\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"NRT\",\"tzName\":\"Nauru Time\"}]', '{\"kr\":\"나우루\",\"br\":\"Nauru\",\"pt\":\"Nauru\",\"nl\":\"Nauru\",\"hr\":\"Nauru\",\"fa\":\"نائورو\",\"de\":\"Nauru\",\"es\":\"Nauru\",\"fr\":\"Nauru\",\"ja\":\"ナウル\",\"it\":\"Nauru\",\"cn\":\"瑙鲁\",\"tr\":\"Nauru\"}', '-0.53333333', '166.91666666', '', 'U+1F1F3 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q697'),
(154, 'Nepal', 'NPL', '524', 'NP', '977', 'Kathmandu', 'NPR', 'Nepalese rupee', '₨', '.np', 'नपल', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Kathmandu\",\"gmtOffset\":20700,\"gmtOffsetName\":\"UTC+05:45\",\"abbreviation\":\"NPT\",\"tzName\":\"Nepal Time\"}]', '{\"kr\":\"네팔\",\"br\":\"Nepal\",\"pt\":\"Nepal\",\"nl\":\"Nepal\",\"hr\":\"Nepal\",\"fa\":\"نپال\",\"de\":\"Népal\",\"es\":\"Nepal\",\"fr\":\"Népal\",\"ja\":\"ネパール\",\"it\":\"Nepal\",\"cn\":\"尼泊尔\",\"tr\":\"Nepal\"}', '28.00000000', '84.00000000', '', 'U+1F1F3 U+1F1F5', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q837'),
(155, 'Bonaire, Sint Eustatius and Saba', 'BES', '535', 'BQ', '599', 'Kralendijk', 'USD', 'United States dollar', '$', '.an', 'Caribisch Nederland', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"보네르 섬\",\"br\":\"Bonaire\",\"pt\":\"Bonaire\",\"fa\":\"بونیر\",\"de\":\"Bonaire, Sint Eustatius und Saba\",\"fr\":\"Bonaire, Saint-Eustache et Saba\",\"it\":\"Bonaire, Saint-Eustache e Saba\",\"cn\":\"博内尔岛、圣尤斯特歇斯和萨巴岛\",\"tr\":\"Karayip Hollandasi\"}', '12.15000000', '-68.26666700', '', 'U+1F1E7 U+1F1F6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q27561'),
(156, 'Netherlands', 'NLD', '528', 'NL', '31', 'Amsterdam', 'EUR', 'Euro', '€', '.nl', 'Nederland', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Amsterdam\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"네덜란드 \",\"br\":\"Holanda\",\"pt\":\"Países Baixos\",\"nl\":\"Nederland\",\"hr\":\"Nizozemska\",\"fa\":\"پادشاهی هلند\",\"de\":\"Niederlande\",\"es\":\"Países Bajos\",\"fr\":\"Pays-Bas\",\"ja\":\"オランダ\",\"it\":\"Paesi Bassi\",\"cn\":\"荷兰\",\"tr\":\"Hollanda\"}', '52.50000000', '5.75000000', '', 'U+1F1F3 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q55'),
(157, 'New Caledonia', 'NCL', '540', 'NC', '687', 'Noumea', 'XPF', 'CFP franc', '₣', '.nc', 'Nouvelle-Calédonie', 'Oceania', 'Melanesia', '[{\"zoneName\":\"Pacific/Noumea\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"NCT\",\"tzName\":\"New Caledonia Time\"}]', '{\"kr\":\"누벨칼레도니\",\"br\":\"Nova Caledônia\",\"pt\":\"Nova Caledónia\",\"nl\":\"Nieuw-Caledonië\",\"hr\":\"Nova Kaledonija\",\"fa\":\"کالدونیای جدید\",\"de\":\"Neukaledonien\",\"es\":\"Nueva Caledonia\",\"fr\":\"Nouvelle-Calédonie\",\"ja\":\"ニューカレドニア\",\"it\":\"Nuova Caledonia\",\"cn\":\"新喀里多尼亚\",\"tr\":\"Yeni Kaledonya\"}', '-21.50000000', '165.50000000', '', 'U+1F1F3 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(158, 'New Zealand', 'NZL', '554', 'NZ', '64', 'Wellington', 'NZD', 'New Zealand dollar', '$', '.nz', 'New Zealand', 'Oceania', 'Australia and New Zealand', '[{\"zoneName\":\"Pacific/Auckland\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"NZDT\",\"tzName\":\"New Zealand Daylight Time\"},{\"zoneName\":\"Pacific/Chatham\",\"gmtOffset\":49500,\"gmtOffsetName\":\"UTC+13:45\",\"abbreviation\":\"CHAST\",\"tzName\":\"Chatham Standard Time\"}]', '{\"kr\":\"뉴질랜드\",\"br\":\"Nova Zelândia\",\"pt\":\"Nova Zelândia\",\"nl\":\"Nieuw-Zeeland\",\"hr\":\"Novi Zeland\",\"fa\":\"نیوزیلند\",\"de\":\"Neuseeland\",\"es\":\"Nueva Zelanda\",\"fr\":\"Nouvelle-Zélande\",\"ja\":\"ニュージーランド\",\"it\":\"Nuova Zelanda\",\"cn\":\"新西兰\",\"tr\":\"Yeni Zelanda\"}', '-41.00000000', '174.00000000', '', 'U+1F1F3 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q664'),
(159, 'Nicaragua', 'NIC', '558', 'NI', '505', 'Managua', 'NIO', 'Nicaraguan córdoba', 'C$', '.ni', 'Nicaragua', 'Americas', 'Central America', '[{\"zoneName\":\"America/Managua\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]', '{\"kr\":\"니카라과\",\"br\":\"Nicarágua\",\"pt\":\"Nicarágua\",\"nl\":\"Nicaragua\",\"hr\":\"Nikaragva\",\"fa\":\"نیکاراگوئه\",\"de\":\"Nicaragua\",\"es\":\"Nicaragua\",\"fr\":\"Nicaragua\",\"ja\":\"ニカラグア\",\"it\":\"Nicaragua\",\"cn\":\"尼加拉瓜\",\"tr\":\"Nikaragua\"}', '13.00000000', '-85.00000000', '', 'U+1F1F3 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q811'),
(160, 'Niger', 'NER', '562', 'NE', '227', 'Niamey', 'XOF', 'West African CFA franc', 'CFA', '.ne', 'Niger', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Niamey\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"니제르\",\"br\":\"Níger\",\"pt\":\"Níger\",\"nl\":\"Niger\",\"hr\":\"Niger\",\"fa\":\"نیجر\",\"de\":\"Niger\",\"es\":\"Níger\",\"fr\":\"Niger\",\"ja\":\"ニジェール\",\"it\":\"Niger\",\"cn\":\"尼日尔\",\"tr\":\"Nijer\"}', '16.00000000', '8.00000000', '', 'U+1F1F3 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1032'),
(161, 'Nigeria', 'NGA', '566', 'NG', '234', 'Abuja', 'NGN', 'Nigerian naira', '₦', '.ng', 'Nigeria', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Lagos\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]', '{\"kr\":\"나이지리아\",\"br\":\"Nigéria\",\"pt\":\"Nigéria\",\"nl\":\"Nigeria\",\"hr\":\"Nigerija\",\"fa\":\"نیجریه\",\"de\":\"Nigeria\",\"es\":\"Nigeria\",\"fr\":\"Nigéria\",\"ja\":\"ナイジェリア\",\"it\":\"Nigeria\",\"cn\":\"尼日利亚\",\"tr\":\"Nijerya\"}', '10.00000000', '8.00000000', '', 'U+1F1F3 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1033'),
(162, 'Niue', 'NIU', '570', 'NU', '683', 'Alofi', 'NZD', 'New Zealand dollar', '$', '.nu', 'Niuē', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Niue\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"NUT\",\"tzName\":\"Niue Time\"}]', '{\"kr\":\"니우에\",\"br\":\"Niue\",\"pt\":\"Niue\",\"nl\":\"Niue\",\"hr\":\"Niue\",\"fa\":\"نیووی\",\"de\":\"Niue\",\"es\":\"Niue\",\"fr\":\"Niue\",\"ja\":\"ニウエ\",\"it\":\"Niue\",\"cn\":\"纽埃\",\"tr\":\"Niue\"}', '-19.03333333', '-169.86666666', '', 'U+1F1F3 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q34020'),
(163, 'Norfolk Island', 'NFK', '574', 'NF', '672', 'Kingston', 'AUD', 'Australian dollar', '$', '.nf', 'Norfolk Island', 'Oceania', 'Australia and New Zealand', '[{\"zoneName\":\"Pacific/Norfolk\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"NFT\",\"tzName\":\"Norfolk Time\"}]', '{\"kr\":\"노퍽 섬\",\"br\":\"Ilha Norfolk\",\"pt\":\"Ilha Norfolk\",\"nl\":\"Norfolkeiland\",\"hr\":\"Otok Norfolk\",\"fa\":\"جزیره نورفک\",\"de\":\"Norfolkinsel\",\"es\":\"Isla de Norfolk\",\"fr\":\"Île de Norfolk\",\"ja\":\"ノーフォーク島\",\"it\":\"Isola Norfolk\",\"cn\":\"诺福克岛\",\"tr\":\"Norfolk Adasi\"}', '-29.03333333', '167.95000000', '', 'U+1F1F3 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(164, 'Northern Mariana Islands', 'MNP', '580', 'MP', '+1-670', 'Saipan', 'USD', 'United States dollar', '$', '.mp', 'Northern Mariana Islands', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Saipan\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"ChST\",\"tzName\":\"Chamorro Standard Time\"}]', '{\"kr\":\"북마리아나 제도\",\"br\":\"Ilhas Marianas\",\"pt\":\"Ilhas Marianas\",\"nl\":\"Noordelijke Marianeneilanden\",\"hr\":\"Sjevernomarijanski otoci\",\"fa\":\"جزایر ماریانای شمالی\",\"de\":\"Nördliche Marianen\",\"es\":\"Islas Marianas del Norte\",\"fr\":\"Îles Mariannes du Nord\",\"ja\":\"北マリアナ諸島\",\"it\":\"Isole Marianne Settentrionali\",\"cn\":\"北马里亚纳群岛\",\"tr\":\"Kuzey Mariana Adalari\"}', '15.20000000', '145.75000000', '', 'U+1F1F2 U+1F1F5', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(165, 'Norway', 'NOR', '578', 'NO', '47', 'Oslo', 'NOK', 'Norwegian krone', 'kr', '.no', 'Norge', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Oslo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"노르웨이\",\"br\":\"Noruega\",\"pt\":\"Noruega\",\"nl\":\"Noorwegen\",\"hr\":\"Norveška\",\"fa\":\"نروژ\",\"de\":\"Norwegen\",\"es\":\"Noruega\",\"fr\":\"Norvège\",\"ja\":\"ノルウェー\",\"it\":\"Norvegia\",\"cn\":\"挪威\",\"tr\":\"Norveç\"}', '62.00000000', '10.00000000', '', 'U+1F1F3 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q20'),
(166, 'Oman', 'OMN', '512', 'OM', '968', 'Muscat', 'OMR', 'Omani rial', '.ع.ر', '.om', 'عمان', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Muscat\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GST\",\"tzName\":\"Gulf Standard Time\"}]', '{\"kr\":\"오만\",\"br\":\"Omã\",\"pt\":\"Omã\",\"nl\":\"Oman\",\"hr\":\"Oman\",\"fa\":\"عمان\",\"de\":\"Oman\",\"es\":\"Omán\",\"fr\":\"Oman\",\"ja\":\"オマーン\",\"it\":\"oman\",\"cn\":\"阿曼\",\"tr\":\"Umman\"}', '21.00000000', '57.00000000', '', 'U+1F1F4 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q842'),
(167, 'Pakistan', 'PAK', '586', 'PK', '92', 'Islamabad', 'PKR', 'Pakistani rupee', '₨', '.pk', 'Pakistan', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Karachi\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"PKT\",\"tzName\":\"Pakistan Standard Time\"}]', '{\"kr\":\"파키스탄\",\"br\":\"Paquistão\",\"pt\":\"Paquistão\",\"nl\":\"Pakistan\",\"hr\":\"Pakistan\",\"fa\":\"پاکستان\",\"de\":\"Pakistan\",\"es\":\"Pakistán\",\"fr\":\"Pakistan\",\"ja\":\"パキスタン\",\"it\":\"Pakistan\",\"cn\":\"巴基斯坦\",\"tr\":\"Pakistan\"}', '30.00000000', '70.00000000', '', 'U+1F1F5 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q843'),
(168, 'Palau', 'PLW', '585', 'PW', '680', 'Melekeok', 'USD', 'United States dollar', '$', '.pw', 'Palau', 'Oceania', 'Micronesia', '[{\"zoneName\":\"Pacific/Palau\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"PWT\",\"tzName\":\"Palau Time\"}]', '{\"kr\":\"팔라우\",\"br\":\"Palau\",\"pt\":\"Palau\",\"nl\":\"Palau\",\"hr\":\"Palau\",\"fa\":\"پالائو\",\"de\":\"Palau\",\"es\":\"Palau\",\"fr\":\"Palaos\",\"ja\":\"パラオ\",\"it\":\"Palau\",\"cn\":\"帕劳\",\"tr\":\"Palau\"}', '7.50000000', '134.50000000', '', 'U+1F1F5 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q695'),
(169, 'Palestinian Territory Occupied', 'PSE', '275', 'PS', '970', 'East Jerusalem', 'ILS', 'Israeli new shekel', '₪', '.ps', 'فلسطين', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Gaza\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Asia/Hebron\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"팔레스타인 영토\",\"br\":\"Palestina\",\"pt\":\"Palestina\",\"nl\":\"Palestijnse gebieden\",\"hr\":\"Palestina\",\"fa\":\"فلسطین\",\"de\":\"Palästina\",\"es\":\"Palestina\",\"fr\":\"Palestine\",\"ja\":\"パレスチナ\",\"it\":\"Palestina\",\"cn\":\"巴勒斯坦\",\"tr\":\"Filistin\"}', '31.90000000', '35.20000000', '', 'U+1F1F5 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(170, 'Panama', 'PAN', '591', 'PA', '507', 'Panama City', 'PAB', 'Panamanian balboa', 'B/.', '.pa', 'Panamá', 'Americas', 'Central America', '[{\"zoneName\":\"America/Panama\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]', '{\"kr\":\"파나마\",\"br\":\"Panamá\",\"pt\":\"Panamá\",\"nl\":\"Panama\",\"hr\":\"Panama\",\"fa\":\"پاناما\",\"de\":\"Panama\",\"es\":\"Panamá\",\"fr\":\"Panama\",\"ja\":\"パナマ\",\"it\":\"Panama\",\"cn\":\"巴拿马\",\"tr\":\"Panama\"}', '9.00000000', '-80.00000000', '', 'U+1F1F5 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q804'),
(171, 'Papua new Guinea', 'PNG', '598', 'PG', '675', 'Port Moresby', 'PGK', 'Papua New Guinean kina', 'K', '.pg', 'Papua Niugini', 'Oceania', 'Melanesia', '[{\"zoneName\":\"Pacific/Bougainville\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"BST\",\"tzName\":\"Bougainville Standard Time[6\"},{\"zoneName\":\"Pacific/Port_Moresby\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"PGT\",\"tzName\":\"Papua New Guinea Time\"}]', '{\"kr\":\"파푸아뉴기니\",\"br\":\"Papua Nova Guiné\",\"pt\":\"Papua Nova Guiné\",\"nl\":\"Papoea-Nieuw-Guinea\",\"hr\":\"Papua Nova Gvineja\",\"fa\":\"پاپوآ گینه نو\",\"de\":\"Papua-Neuguinea\",\"es\":\"Papúa Nueva Guinea\",\"fr\":\"Papouasie-Nouvelle-Guinée\",\"ja\":\"パプアニューギニア\",\"it\":\"Papua Nuova Guinea\",\"cn\":\"巴布亚新几内亚\",\"tr\":\"Papua Yeni Gine\"}', '-6.00000000', '147.00000000', '', 'U+1F1F5 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q691'),
(172, 'Paraguay', 'PRY', '600', 'PY', '595', 'Asuncion', 'PYG', 'Paraguayan guarani', '₲', '.py', 'Paraguay', 'Americas', 'South America', '[{\"zoneName\":\"America/Asuncion\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"PYST\",\"tzName\":\"Paraguay Summer Time\"}]', '{\"kr\":\"파라과이\",\"br\":\"Paraguai\",\"pt\":\"Paraguai\",\"nl\":\"Paraguay\",\"hr\":\"Paragvaj\",\"fa\":\"پاراگوئه\",\"de\":\"Paraguay\",\"es\":\"Paraguay\",\"fr\":\"Paraguay\",\"ja\":\"パラグアイ\",\"it\":\"Paraguay\",\"cn\":\"巴拉圭\",\"tr\":\"Paraguay\"}', '-23.00000000', '-58.00000000', '', 'U+1F1F5 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q733'),
(173, 'Peru', 'PER', '604', 'PE', '51', 'Lima', 'PEN', 'Peruvian sol', 'S/.', '.pe', 'Perú', 'Americas', 'South America', '[{\"zoneName\":\"America/Lima\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"PET\",\"tzName\":\"Peru Time\"}]', '{\"kr\":\"페루\",\"br\":\"Peru\",\"pt\":\"Peru\",\"nl\":\"Peru\",\"hr\":\"Peru\",\"fa\":\"پرو\",\"de\":\"Peru\",\"es\":\"Perú\",\"fr\":\"Pérou\",\"ja\":\"ペルー\",\"it\":\"Perù\",\"cn\":\"秘鲁\",\"tr\":\"Peru\"}', '-10.00000000', '-76.00000000', '', 'U+1F1F5 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q419'),
(174, 'Philippines', 'PHL', '608', 'PH', '63', 'Manila', 'PHP', 'Philippine peso', '₱', '.ph', 'Pilipinas', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Manila\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"PHT\",\"tzName\":\"Philippine Time\"}]', '{\"kr\":\"필리핀\",\"br\":\"Filipinas\",\"pt\":\"Filipinas\",\"nl\":\"Filipijnen\",\"hr\":\"Filipini\",\"fa\":\"جزایر الندفیلیپین\",\"de\":\"Philippinen\",\"es\":\"Filipinas\",\"fr\":\"Philippines\",\"ja\":\"フィリピン\",\"it\":\"Filippine\",\"cn\":\"菲律宾\",\"tr\":\"Filipinler\"}', '13.00000000', '122.00000000', '', 'U+1F1F5 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q928'),
(175, 'Pitcairn Island', 'PCN', '612', 'PN', '870', 'Adamstown', 'NZD', 'New Zealand dollar', '$', '.pn', 'Pitcairn Islands', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Pitcairn\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"}]', '{\"kr\":\"핏케언 제도\",\"br\":\"Ilhas Pitcairn\",\"pt\":\"Ilhas Picárnia\",\"nl\":\"Pitcairneilanden\",\"hr\":\"Pitcairnovo otočje\",\"fa\":\"پیتکرن\",\"de\":\"Pitcairn\",\"es\":\"Islas Pitcairn\",\"fr\":\"Îles Pitcairn\",\"ja\":\"ピトケアン\",\"it\":\"Isole Pitcairn\",\"cn\":\"皮特凯恩群岛\",\"tr\":\"Pitcairn Adalari\"}', '-25.06666666', '-130.10000000', '', 'U+1F1F5 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(176, 'Poland', 'POL', '616', 'PL', '48', 'Warsaw', 'PLN', 'Polish złoty', 'zł', '.pl', 'Polska', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Warsaw\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"폴란드\",\"br\":\"Polônia\",\"pt\":\"Polónia\",\"nl\":\"Polen\",\"hr\":\"Poljska\",\"fa\":\"لهستان\",\"de\":\"Polen\",\"es\":\"Polonia\",\"fr\":\"Pologne\",\"ja\":\"ポーランド\",\"it\":\"Polonia\",\"cn\":\"波兰\",\"tr\":\"Polonya\"}', '52.00000000', '20.00000000', '', 'U+1F1F5 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q36'),
(177, 'Portugal', 'PRT', '620', 'PT', '351', 'Lisbon', 'EUR', 'Euro', '€', '.pt', 'Portugal', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Atlantic/Azores\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"AZOT\",\"tzName\":\"Azores Standard Time\"},{\"zoneName\":\"Atlantic/Madeira\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"},{\"zoneName\":\"Europe/Lisbon\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"}]', '{\"kr\":\"포르투갈\",\"br\":\"Portugal\",\"pt\":\"Portugal\",\"nl\":\"Portugal\",\"hr\":\"Portugal\",\"fa\":\"پرتغال\",\"de\":\"Portugal\",\"es\":\"Portugal\",\"fr\":\"Portugal\",\"ja\":\"ポルトガル\",\"it\":\"Portogallo\",\"cn\":\"葡萄牙\",\"tr\":\"Portekiz\"}', '39.50000000', '-8.00000000', '', 'U+1F1F5 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q45'),
(178, 'Puerto Rico', 'PRI', '630', 'PR', '+1-787 and 1-939', 'San Juan', 'USD', 'United States dollar', '$', '.pr', 'Puerto Rico', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Puerto_Rico\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"푸에르토리코\",\"br\":\"Porto Rico\",\"pt\":\"Porto Rico\",\"nl\":\"Puerto Rico\",\"hr\":\"Portoriko\",\"fa\":\"پورتو ریکو\",\"de\":\"Puerto Rico\",\"es\":\"Puerto Rico\",\"fr\":\"Porto Rico\",\"ja\":\"プエルトリコ\",\"it\":\"Porto Rico\",\"cn\":\"波多黎各\",\"tr\":\"Porto Riko\"}', '18.25000000', '-66.50000000', '', 'U+1F1F5 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(179, 'Qatar', 'QAT', '634', 'QA', '974', 'Doha', 'QAR', 'Qatari riyal', 'ق.ر', '.qa', 'قطر', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Qatar\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"카타르\",\"br\":\"Catar\",\"pt\":\"Catar\",\"nl\":\"Qatar\",\"hr\":\"Katar\",\"fa\":\"قطر\",\"de\":\"Katar\",\"es\":\"Catar\",\"fr\":\"Qatar\",\"ja\":\"カタール\",\"it\":\"Qatar\",\"cn\":\"卡塔尔\",\"tr\":\"Katar\"}', '25.50000000', '51.25000000', '', 'U+1F1F6 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q846'),
(180, 'Reunion', 'REU', '638', 'RE', '262', 'Saint-Denis', 'EUR', 'Euro', '€', '.re', 'La Réunion', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Reunion\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"RET\",\"tzName\":\"Réunion Time\"}]', '{\"kr\":\"레위니옹\",\"br\":\"Reunião\",\"pt\":\"Reunião\",\"nl\":\"Réunion\",\"hr\":\"Réunion\",\"fa\":\"رئونیون\",\"de\":\"Réunion\",\"es\":\"Reunión\",\"fr\":\"Réunion\",\"ja\":\"レユニオン\",\"it\":\"Riunione\",\"cn\":\"留尼汪岛\",\"tr\":\"Réunion\"}', '-21.15000000', '55.50000000', '', 'U+1F1F7 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(181, 'Romania', 'ROU', '642', 'RO', '40', 'Bucharest', 'RON', 'Romanian leu', 'lei', '.ro', 'România', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Bucharest\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"루마니아\",\"br\":\"Romênia\",\"pt\":\"Roménia\",\"nl\":\"Roemenië\",\"hr\":\"Rumunjska\",\"fa\":\"رومانی\",\"de\":\"Rumänien\",\"es\":\"Rumania\",\"fr\":\"Roumanie\",\"ja\":\"ルーマニア\",\"it\":\"Romania\",\"cn\":\"罗马尼亚\",\"tr\":\"Romanya\"}', '46.00000000', '25.00000000', '', 'U+1F1F7 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q218'),
(182, 'Russia', 'RUS', '643', 'RU', '7', 'Moscow', 'RUB', 'Russian ruble', '₽', '.ru', 'Россия', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Asia/Anadyr\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"ANAT\",\"tzName\":\"Anadyr Time[4\"},{\"zoneName\":\"Asia/Barnaul\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Chita\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Irkutsk\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"IRKT\",\"tzName\":\"Irkutsk Time\"},{\"zoneName\":\"Asia/Kamchatka\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"PETT\",\"tzName\":\"Kamchatka Time\"},{\"zoneName\":\"Asia/Khandyga\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Krasnoyarsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Magadan\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"MAGT\",\"tzName\":\"Magadan Time\"},{\"zoneName\":\"Asia/Novokuznetsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Novosibirsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"NOVT\",\"tzName\":\"Novosibirsk Time\"},{\"zoneName\":\"Asia/Omsk\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"OMST\",\"tzName\":\"Omsk Time\"},{\"zoneName\":\"Asia/Sakhalin\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SAKT\",\"tzName\":\"Sakhalin Island Time\"},{\"zoneName\":\"Asia/Srednekolymsk\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SRET\",\"tzName\":\"Srednekolymsk Time\"},{\"zoneName\":\"Asia/Tomsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"MSD+3\",\"tzName\":\"Moscow Daylight Time+3\"},{\"zoneName\":\"Asia/Ust-Nera\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"VLAT\",\"tzName\":\"Vladivostok Time\"},{\"zoneName\":\"Asia/Vladivostok\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"VLAT\",\"tzName\":\"Vladivostok Time\"},{\"zoneName\":\"Asia/Yakutsk\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Yekaterinburg\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"YEKT\",\"tzName\":\"Yekaterinburg Time\"},{\"zoneName\":\"Europe/Astrakhan\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Kaliningrad\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Kirov\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Moscow\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Samara\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Saratov\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MSD\",\"tzName\":\"Moscow Daylight Time+4\"},{\"zoneName\":\"Europe/Ulyanovsk\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Volgograd\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Standard Time\"}]', '{\"kr\":\"러시아\",\"br\":\"Rússia\",\"pt\":\"Rússia\",\"nl\":\"Rusland\",\"hr\":\"Rusija\",\"fa\":\"روسیه\",\"de\":\"Russland\",\"es\":\"Rusia\",\"fr\":\"Russie\",\"ja\":\"ロシア連邦\",\"it\":\"Russia\",\"cn\":\"俄罗斯联邦\",\"tr\":\"Rusya\"}', '60.00000000', '100.00000000', '', 'U+1F1F7 U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q159'),
(183, 'Rwanda', 'RWA', '646', 'RW', '250', 'Kigali', 'RWF', 'Rwandan franc', 'FRw', '.rw', 'Rwanda', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Kigali\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"르완다\",\"br\":\"Ruanda\",\"pt\":\"Ruanda\",\"nl\":\"Rwanda\",\"hr\":\"Ruanda\",\"fa\":\"رواندا\",\"de\":\"Ruanda\",\"es\":\"Ruanda\",\"fr\":\"Rwanda\",\"ja\":\"ルワンダ\",\"it\":\"Ruanda\",\"cn\":\"卢旺达\",\"tr\":\"Ruanda\"}', '-2.00000000', '30.00000000', '', 'U+1F1F7 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q1037'),
(184, 'Saint Helena', 'SHN', '654', 'SH', '290', 'Jamestown', 'SHP', 'Saint Helena pound', '£', '.sh', 'Saint Helena', 'Africa', 'Western Africa', '[{\"zoneName\":\"Atlantic/St_Helena\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"세인트헬레나\",\"br\":\"Santa Helena\",\"pt\":\"Santa Helena\",\"nl\":\"Sint-Helena\",\"hr\":\"Sveta Helena\",\"fa\":\"سنت هلنا، اسنشن و تریستان دا کونا\",\"de\":\"Sankt Helena\",\"es\":\"Santa Helena\",\"fr\":\"Sainte-Hélène\",\"ja\":\"セントヘレナ・アセンションおよびトリスタンダクーニャ\",\"it\":\"Sant\'Elena\",\"cn\":\"圣赫勒拿\",\"tr\":\"Saint Helena\"}', '-15.95000000', '-5.70000000', '', 'U+1F1F8 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(185, 'Saint Kitts And Nevis', 'KNA', '659', 'KN', '+1-869', 'Basseterre', 'XCD', 'Eastern Caribbean dollar', '$', '.kn', 'Saint Kitts and Nevis', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/St_Kitts\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"세인트키츠 네비스\",\"br\":\"São Cristóvão e Neves\",\"pt\":\"São Cristóvão e Neves\",\"nl\":\"Saint Kitts en Nevis\",\"hr\":\"Sveti Kristof i Nevis\",\"fa\":\"سنت کیتس و نویس\",\"de\":\"St. Kitts und Nevis\",\"es\":\"San Cristóbal y Nieves\",\"fr\":\"Saint-Christophe-et-Niévès\",\"ja\":\"セントクリストファー・ネイビス\",\"it\":\"Saint Kitts e Nevis\",\"cn\":\"圣基茨和尼维斯\",\"tr\":\"Saint Kitts Ve Nevis\"}', '17.33333333', '-62.75000000', '', 'U+1F1F0 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q763'),
(186, 'Saint Lucia', 'LCA', '662', 'LC', '+1-758', 'Castries', 'XCD', 'Eastern Caribbean dollar', '$', '.lc', 'Saint Lucia', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/St_Lucia\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"세인트루시아\",\"br\":\"Santa Lúcia\",\"pt\":\"Santa Lúcia\",\"nl\":\"Saint Lucia\",\"hr\":\"Sveta Lucija\",\"fa\":\"سنت لوسیا\",\"de\":\"Saint Lucia\",\"es\":\"Santa Lucía\",\"fr\":\"Saint-Lucie\",\"ja\":\"セントルシア\",\"it\":\"Santa Lucia\",\"cn\":\"圣卢西亚\",\"tr\":\"Saint Lucia\"}', '13.88333333', '-60.96666666', '', 'U+1F1F1 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, 'Q760'),
(187, 'Saint Pierre and Miquelon', 'SPM', '666', 'PM', '508', 'Saint-Pierre', 'EUR', 'Euro', '€', '.pm', 'Saint-Pierre-et-Miquelon', 'Americas', 'Northern America', '[{\"zoneName\":\"America/Miquelon\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"PMDT\",\"tzName\":\"Pierre & Miquelon Daylight Time\"}]', '{\"kr\":\"생피에르 미클롱\",\"br\":\"Saint-Pierre e Miquelon\",\"pt\":\"São Pedro e Miquelon\",\"nl\":\"Saint Pierre en Miquelon\",\"hr\":\"Sveti Petar i Mikelon\",\"fa\":\"سن پیر و میکلن\",\"de\":\"Saint-Pierre und Miquelon\",\"es\":\"San Pedro y Miquelón\",\"fr\":\"Saint-Pierre-et-Miquelon\",\"ja\":\"サンピエール島・ミクロン島\",\"it\":\"Saint-Pierre e Miquelon\",\"cn\":\"圣皮埃尔和密克隆\",\"tr\":\"Saint Pierre Ve Miquelon\"}', '46.83333333', '-56.33333333', '', 'U+1F1F5 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:32:07', 1, NULL),
(188, 'Saint Vincent And The Grenadines', 'VCT', '670', 'VC', '+1-784', 'Kingstown', 'XCD', 'Eastern Caribbean dollar', '$', '.vc', 'Saint Vincent and the Grenadines', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/St_Vincent\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"세인트빈센트 그레나딘\",\"br\":\"São Vicente e Granadinas\",\"pt\":\"São Vicente e Granadinas\",\"nl\":\"Saint Vincent en de Grenadines\",\"hr\":\"Sveti Vincent i Grenadini\",\"fa\":\"سنت وینسنت و گرنادین‌ها\",\"de\":\"Saint Vincent und die Grenadinen\",\"es\":\"San Vicente y Granadinas\",\"fr\":\"Saint-Vincent-et-les-Grenadines\",\"ja\":\"セントビンセントおよびグレナディーン諸島\",\"it\":\"Saint Vincent e Grenadine\",\"cn\":\"圣文森特和格林纳丁斯\",\"tr\":\"Saint Vincent Ve Grenadinler\"}', '13.25000000', '-61.20000000', '', 'U+1F1FB U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q757'),
(189, 'Saint-Barthelemy', 'BLM', '652', 'BL', '590', 'Gustavia', 'EUR', 'Euro', '€', '.bl', 'Saint-Barthélemy', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/St_Barthelemy\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"생바르텔레미\",\"br\":\"São Bartolomeu\",\"pt\":\"São Bartolomeu\",\"nl\":\"Saint Barthélemy\",\"hr\":\"Saint Barthélemy\",\"fa\":\"سن-بارتلمی\",\"de\":\"Saint-Barthélemy\",\"es\":\"San Bartolomé\",\"fr\":\"Saint-Barthélemy\",\"ja\":\"サン・バルテルミー\",\"it\":\"Antille Francesi\",\"cn\":\"圣巴泰勒米\",\"tr\":\"Saint Barthélemy\"}', '18.50000000', '-63.41666666', '', 'U+1F1E7 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(190, 'Saint-Martin (French part)', 'MAF', '663', 'MF', '590', 'Marigot', 'EUR', 'Euro', '€', '.mf', 'Saint-Martin', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Marigot\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"세인트마틴 섬\",\"br\":\"Saint Martin\",\"pt\":\"Ilha São Martinho\",\"nl\":\"Saint-Martin\",\"hr\":\"Sveti Martin\",\"fa\":\"سینت مارتن\",\"de\":\"Saint Martin\",\"es\":\"Saint Martin\",\"fr\":\"Saint-Martin\",\"ja\":\"サン・マルタン（フランス領）\",\"it\":\"Saint Martin\",\"cn\":\"密克罗尼西亚\",\"tr\":\"Saint Martin\"}', '18.08333333', '-63.95000000', '', 'U+1F1F2 U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL);
INSERT INTO `countries` (`id`, `name`, `iso3`, `numeric_code`, `iso2`, `phonecode`, `capital`, `currency`, `currency_name`, `currency_symbol`, `tld`, `native`, `region`, `subregion`, `timezones`, `translations`, `latitude`, `longitude`, `emoji`, `emojiU`, `created_at`, `updated_at`, `flag`, `wikiDataId`) VALUES
(191, 'Samoa', 'WSM', '882', 'WS', '685', 'Apia', 'WST', 'Samoan tālā', 'SAT', '.ws', 'Samoa', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Apia\",\"gmtOffset\":50400,\"gmtOffsetName\":\"UTC+14:00\",\"abbreviation\":\"WST\",\"tzName\":\"West Samoa Time\"}]', '{\"kr\":\"사모아\",\"br\":\"Samoa\",\"pt\":\"Samoa\",\"nl\":\"Samoa\",\"hr\":\"Samoa\",\"fa\":\"ساموآ\",\"de\":\"Samoa\",\"es\":\"Samoa\",\"fr\":\"Samoa\",\"ja\":\"サモア\",\"it\":\"Samoa\",\"cn\":\"萨摩亚\",\"tr\":\"Samoa\"}', '-13.58333333', '-172.33333333', '', 'U+1F1FC U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q683'),
(192, 'San Marino', 'SMR', '674', 'SM', '378', 'San Marino', 'EUR', 'Euro', '€', '.sm', 'San Marino', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/San_Marino\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"산마리노\",\"br\":\"San Marino\",\"pt\":\"São Marinho\",\"nl\":\"San Marino\",\"hr\":\"San Marino\",\"fa\":\"سان مارینو\",\"de\":\"San Marino\",\"es\":\"San Marino\",\"fr\":\"Saint-Marin\",\"ja\":\"サンマリノ\",\"it\":\"San Marino\",\"cn\":\"圣马力诺\",\"tr\":\"San Marino\"}', '43.76666666', '12.41666666', '', 'U+1F1F8 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q238'),
(193, 'Sao Tome and Principe', 'STP', '678', 'ST', '239', 'Sao Tome', 'STD', 'Dobra', 'Db', '.st', 'São Tomé e Príncipe', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Sao_Tome\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"상투메 프린시페\",\"br\":\"São Tomé e Príncipe\",\"pt\":\"São Tomé e Príncipe\",\"nl\":\"Sao Tomé en Principe\",\"hr\":\"Sveti Toma i Princip\",\"fa\":\"کواترو دو فرویرو\",\"de\":\"São Tomé und Príncipe\",\"es\":\"Santo Tomé y Príncipe\",\"fr\":\"Sao Tomé-et-Principe\",\"ja\":\"サントメ・プリンシペ\",\"it\":\"São Tomé e Príncipe\",\"cn\":\"圣多美和普林西比\",\"tr\":\"Sao Tome Ve Prinsipe\"}', '1.00000000', '7.00000000', '', 'U+1F1F8 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1039'),
(194, 'Saudi Arabia', 'SAU', '682', 'SA', '966', 'Riyadh', 'SAR', 'Saudi riyal', '﷼', '.sa', 'المملكة العربية السعودية', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Riyadh\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"사우디아라비아\",\"br\":\"Arábia Saudita\",\"pt\":\"Arábia Saudita\",\"nl\":\"Saoedi-Arabië\",\"hr\":\"Saudijska Arabija\",\"fa\":\"عربستان سعودی\",\"de\":\"Saudi-Arabien\",\"es\":\"Arabia Saudí\",\"fr\":\"Arabie Saoudite\",\"ja\":\"サウジアラビア\",\"it\":\"Arabia Saudita\",\"cn\":\"沙特阿拉伯\",\"tr\":\"Suudi Arabistan\"}', '25.00000000', '45.00000000', '', 'U+1F1F8 U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q851'),
(195, 'Senegal', 'SEN', '686', 'SN', '221', 'Dakar', 'XOF', 'West African CFA franc', 'CFA', '.sn', 'Sénégal', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Dakar\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"세네갈\",\"br\":\"Senegal\",\"pt\":\"Senegal\",\"nl\":\"Senegal\",\"hr\":\"Senegal\",\"fa\":\"سنگال\",\"de\":\"Senegal\",\"es\":\"Senegal\",\"fr\":\"Sénégal\",\"ja\":\"セネガル\",\"it\":\"Senegal\",\"cn\":\"塞内加尔\",\"tr\":\"Senegal\"}', '14.00000000', '-14.00000000', '', 'U+1F1F8 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1041'),
(196, 'Serbia', 'SRB', '688', 'RS', '381', 'Belgrade', 'RSD', 'Serbian dinar', 'din', '.rs', 'Србија', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Belgrade\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"세르비아\",\"br\":\"Sérvia\",\"pt\":\"Sérvia\",\"nl\":\"Servië\",\"hr\":\"Srbija\",\"fa\":\"صربستان\",\"de\":\"Serbien\",\"es\":\"Serbia\",\"fr\":\"Serbie\",\"ja\":\"セルビア\",\"it\":\"Serbia\",\"cn\":\"塞尔维亚\",\"tr\":\"Sirbistan\"}', '44.00000000', '21.00000000', '', 'U+1F1F7 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q403'),
(197, 'Seychelles', 'SYC', '690', 'SC', '248', 'Victoria', 'SCR', 'Seychellois rupee', 'SRe', '.sc', 'Seychelles', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Indian/Mahe\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SCT\",\"tzName\":\"Seychelles Time\"}]', '{\"kr\":\"세이셸\",\"br\":\"Seicheles\",\"pt\":\"Seicheles\",\"nl\":\"Seychellen\",\"hr\":\"Sejšeli\",\"fa\":\"سیشل\",\"de\":\"Seychellen\",\"es\":\"Seychelles\",\"fr\":\"Seychelles\",\"ja\":\"セーシェル\",\"it\":\"Seychelles\",\"cn\":\"塞舌尔\",\"tr\":\"Seyşeller\"}', '-4.58333333', '55.66666666', '', 'U+1F1F8 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1042'),
(198, 'Sierra Leone', 'SLE', '694', 'SL', '232', 'Freetown', 'SLL', 'Sierra Leonean leone', 'Le', '.sl', 'Sierra Leone', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Freetown\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"시에라리온\",\"br\":\"Serra Leoa\",\"pt\":\"Serra Leoa\",\"nl\":\"Sierra Leone\",\"hr\":\"Sijera Leone\",\"fa\":\"سیرالئون\",\"de\":\"Sierra Leone\",\"es\":\"Sierra Leone\",\"fr\":\"Sierra Leone\",\"ja\":\"シエラレオネ\",\"it\":\"Sierra Leone\",\"cn\":\"塞拉利昂\",\"tr\":\"Sierra Leone\"}', '8.50000000', '-11.50000000', '', 'U+1F1F8 U+1F1F1', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1044'),
(199, 'Singapore', 'SGP', '702', 'SG', '65', 'Singapur', 'SGD', 'Singapore dollar', '$', '.sg', 'Singapore', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Singapore\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"SGT\",\"tzName\":\"Singapore Time\"}]', '{\"kr\":\"싱가포르\",\"br\":\"Singapura\",\"pt\":\"Singapura\",\"nl\":\"Singapore\",\"hr\":\"Singapur\",\"fa\":\"سنگاپور\",\"de\":\"Singapur\",\"es\":\"Singapur\",\"fr\":\"Singapour\",\"ja\":\"シンガポール\",\"it\":\"Singapore\",\"cn\":\"新加坡\",\"tr\":\"Singapur\"}', '1.36666666', '103.80000000', '', 'U+1F1F8 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q334'),
(200, 'Slovakia', 'SVK', '703', 'SK', '421', 'Bratislava', 'EUR', 'Euro', '€', '.sk', 'Slovensko', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Bratislava\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"슬로바키아\",\"br\":\"Eslováquia\",\"pt\":\"Eslováquia\",\"nl\":\"Slowakije\",\"hr\":\"Slovačka\",\"fa\":\"اسلواکی\",\"de\":\"Slowakei\",\"es\":\"República Eslovaca\",\"fr\":\"Slovaquie\",\"ja\":\"スロバキア\",\"it\":\"Slovacchia\",\"cn\":\"斯洛伐克\",\"tr\":\"Slovakya\"}', '48.66666666', '19.50000000', '', 'U+1F1F8 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q214'),
(201, 'Slovenia', 'SVN', '705', 'SI', '386', 'Ljubljana', 'EUR', 'Euro', '€', '.si', 'Slovenija', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Ljubljana\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"슬로베니아\",\"br\":\"Eslovênia\",\"pt\":\"Eslovénia\",\"nl\":\"Slovenië\",\"hr\":\"Slovenija\",\"fa\":\"اسلوونی\",\"de\":\"Slowenien\",\"es\":\"Eslovenia\",\"fr\":\"Slovénie\",\"ja\":\"スロベニア\",\"it\":\"Slovenia\",\"cn\":\"斯洛文尼亚\",\"tr\":\"Slovenya\"}', '46.11666666', '14.81666666', '', 'U+1F1F8 U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q215'),
(202, 'Solomon Islands', 'SLB', '090', 'SB', '677', 'Honiara', 'SBD', 'Solomon Islands dollar', 'Si$', '.sb', 'Solomon Islands', 'Oceania', 'Melanesia', '[{\"zoneName\":\"Pacific/Guadalcanal\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SBT\",\"tzName\":\"Solomon Islands Time\"}]', '{\"kr\":\"솔로몬 제도\",\"br\":\"Ilhas Salomão\",\"pt\":\"Ilhas Salomão\",\"nl\":\"Salomonseilanden\",\"hr\":\"Solomonski Otoci\",\"fa\":\"جزایر سلیمان\",\"de\":\"Salomonen\",\"es\":\"Islas Salomón\",\"fr\":\"Îles Salomon\",\"ja\":\"ソロモン諸島\",\"it\":\"Isole Salomone\",\"cn\":\"所罗门群岛\",\"tr\":\"Solomon Adalari\"}', '-8.00000000', '159.00000000', '', 'U+1F1F8 U+1F1E7', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q685'),
(203, 'Somalia', 'SOM', '706', 'SO', '252', 'Mogadishu', 'SOS', 'Somali shilling', 'Sh.so.', '.so', 'Soomaaliya', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Mogadishu\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"소말리아\",\"br\":\"Somália\",\"pt\":\"Somália\",\"nl\":\"Somalië\",\"hr\":\"Somalija\",\"fa\":\"سومالی\",\"de\":\"Somalia\",\"es\":\"Somalia\",\"fr\":\"Somalie\",\"ja\":\"ソマリア\",\"it\":\"Somalia\",\"cn\":\"索马里\",\"tr\":\"Somali\"}', '10.00000000', '49.00000000', '', 'U+1F1F8 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1045'),
(204, 'South Africa', 'ZAF', '710', 'ZA', '27', 'Pretoria', 'ZAR', 'South African rand', 'R', '.za', 'South Africa', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Africa/Johannesburg\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]', '{\"kr\":\"남아프리카 공화국\",\"br\":\"República Sul-Africana\",\"pt\":\"República Sul-Africana\",\"nl\":\"Zuid-Afrika\",\"hr\":\"Južnoafrička Republika\",\"fa\":\"آفریقای جنوبی\",\"de\":\"Republik Südafrika\",\"es\":\"República de Sudáfrica\",\"fr\":\"Afrique du Sud\",\"ja\":\"南アフリカ\",\"it\":\"Sud Africa\",\"cn\":\"南非\",\"tr\":\"Güney Afrika Cumhuriyeti\"}', '-29.00000000', '24.00000000', '', 'U+1F1FF U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q258'),
(205, 'South Georgia', 'SGS', '239', 'GS', '500', 'Grytviken', 'GBP', 'British pound', '£', '.gs', 'South Georgia', 'Americas', 'South America', '[{\"zoneName\":\"Atlantic/South_Georgia\",\"gmtOffset\":-7200,\"gmtOffsetName\":\"UTC-02:00\",\"abbreviation\":\"GST\",\"tzName\":\"South Georgia and the South Sandwich Islands Time\"}]', '{\"kr\":\"사우스조지아\",\"br\":\"Ilhas Geórgias do Sul e Sandwich do Sul\",\"pt\":\"Ilhas Geórgia do Sul e Sanduíche do Sul\",\"nl\":\"Zuid-Georgia en Zuidelijke Sandwicheilanden\",\"hr\":\"Južna Georgija i otočje Južni Sandwich\",\"fa\":\"جزایر جورجیای جنوبی و ساندویچ جنوبی\",\"de\":\"Südgeorgien und die Südlichen Sandwichinseln\",\"es\":\"Islas Georgias del Sur y Sandwich del Sur\",\"fr\":\"Géorgie du Sud-et-les Îles Sandwich du Sud\",\"ja\":\"サウスジョージア・サウスサンドウィッチ諸島\",\"it\":\"Georgia del Sud e Isole Sandwich Meridionali\",\"cn\":\"南乔治亚\",\"tr\":\"Güney Georgia\"}', '-54.50000000', '-37.00000000', '', 'U+1F1EC U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(206, 'South Sudan', 'SSD', '728', 'SS', '211', 'Juba', 'SSP', 'South Sudanese pound', '£', '.ss', 'South Sudan', 'Africa', 'Middle Africa', '[{\"zoneName\":\"Africa/Juba\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"남수단\",\"br\":\"Sudão do Sul\",\"pt\":\"Sudão do Sul\",\"nl\":\"Zuid-Soedan\",\"hr\":\"Južni Sudan\",\"fa\":\"سودان جنوبی\",\"de\":\"Südsudan\",\"es\":\"Sudán del Sur\",\"fr\":\"Soudan du Sud\",\"ja\":\"南スーダン\",\"it\":\"Sudan del sud\",\"cn\":\"南苏丹\",\"tr\":\"Güney Sudan\"}', '7.00000000', '30.00000000', '', 'U+1F1F8 U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q958'),
(207, 'Spain', 'ESP', '724', 'ES', '34', 'Madrid', 'EUR', 'Euro', '€', '.es', 'España', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Africa/Ceuta\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"},{\"zoneName\":\"Atlantic/Canary\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"},{\"zoneName\":\"Europe/Madrid\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"스페인\",\"br\":\"Espanha\",\"pt\":\"Espanha\",\"nl\":\"Spanje\",\"hr\":\"Španjolska\",\"fa\":\"اسپانیا\",\"de\":\"Spanien\",\"es\":\"España\",\"fr\":\"Espagne\",\"ja\":\"スペイン\",\"it\":\"Spagna\",\"cn\":\"西班牙\",\"tr\":\"İspanya\"}', '40.00000000', '-4.00000000', '', 'U+1F1EA U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q29'),
(208, 'Sri Lanka', 'LKA', '144', 'LK', '94', 'Colombo', 'LKR', 'Sri Lankan rupee', 'Rs', '.lk', 'śrī laṃkāva', 'Asia', 'Southern Asia', '[{\"zoneName\":\"Asia/Colombo\",\"gmtOffset\":19800,\"gmtOffsetName\":\"UTC+05:30\",\"abbreviation\":\"IST\",\"tzName\":\"Indian Standard Time\"}]', '{\"kr\":\"스리랑카\",\"br\":\"Sri Lanka\",\"pt\":\"Sri Lanka\",\"nl\":\"Sri Lanka\",\"hr\":\"Šri Lanka\",\"fa\":\"سری‌لانکا\",\"de\":\"Sri Lanka\",\"es\":\"Sri Lanka\",\"fr\":\"Sri Lanka\",\"ja\":\"スリランカ\",\"it\":\"Sri Lanka\",\"cn\":\"斯里兰卡\",\"tr\":\"Sri Lanka\"}', '7.00000000', '81.00000000', '', 'U+1F1F1 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q854'),
(209, 'Sudan', 'SDN', '729', 'SD', '249', 'Khartoum', 'SDG', 'Sudanese pound', '.س.ج', '.sd', 'السودان', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Khartoum\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EAT\",\"tzName\":\"Eastern African Time\"}]', '{\"kr\":\"수단\",\"br\":\"Sudão\",\"pt\":\"Sudão\",\"nl\":\"Soedan\",\"hr\":\"Sudan\",\"fa\":\"سودان\",\"de\":\"Sudan\",\"es\":\"Sudán\",\"fr\":\"Soudan\",\"ja\":\"スーダン\",\"it\":\"Sudan\",\"cn\":\"苏丹\",\"tr\":\"Sudan\"}', '15.00000000', '30.00000000', '', 'U+1F1F8 U+1F1E9', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1049'),
(210, 'Suriname', 'SUR', '740', 'SR', '597', 'Paramaribo', 'SRD', 'Surinamese dollar', '$', '.sr', 'Suriname', 'Americas', 'South America', '[{\"zoneName\":\"America/Paramaribo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"SRT\",\"tzName\":\"Suriname Time\"}]', '{\"kr\":\"수리남\",\"br\":\"Suriname\",\"pt\":\"Suriname\",\"nl\":\"Suriname\",\"hr\":\"Surinam\",\"fa\":\"سورینام\",\"de\":\"Suriname\",\"es\":\"Surinam\",\"fr\":\"Surinam\",\"ja\":\"スリナム\",\"it\":\"Suriname\",\"cn\":\"苏里南\",\"tr\":\"Surinam\"}', '4.00000000', '-56.00000000', '', 'U+1F1F8 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q730'),
(211, 'Svalbard And Jan Mayen Islands', 'SJM', '744', 'SJ', '47', 'Longyearbyen', 'NOK', 'Norwegian Krone', 'kr', '.sj', 'Svalbard og Jan Mayen', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Arctic/Longyearbyen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"스발바르 얀마옌 제도\",\"br\":\"Svalbard\",\"pt\":\"Svalbard\",\"nl\":\"Svalbard en Jan Mayen\",\"hr\":\"Svalbard i Jan Mayen\",\"fa\":\"سوالبارد و یان ماین\",\"de\":\"Svalbard und Jan Mayen\",\"es\":\"Islas Svalbard y Jan Mayen\",\"fr\":\"Svalbard et Jan Mayen\",\"ja\":\"スヴァールバル諸島およびヤンマイエン島\",\"it\":\"Svalbard e Jan Mayen\",\"cn\":\"斯瓦尔巴和扬马延群岛\",\"tr\":\"Svalbard Ve Jan Mayen\"}', '78.00000000', '20.00000000', '', 'U+1F1F8 U+1F1EF', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(212, 'Swaziland', 'SWZ', '748', 'SZ', '268', 'Mbabane', 'SZL', 'Lilangeni', 'E', '.sz', 'Swaziland', 'Africa', 'Southern Africa', '[{\"zoneName\":\"Africa/Mbabane\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]', '{\"kr\":\"에스와티니\",\"br\":\"Suazilândia\",\"pt\":\"Suazilândia\",\"nl\":\"Swaziland\",\"hr\":\"Svazi\",\"fa\":\"سوازیلند\",\"de\":\"Swasiland\",\"es\":\"Suazilandia\",\"fr\":\"Swaziland\",\"ja\":\"スワジランド\",\"it\":\"Swaziland\",\"cn\":\"斯威士兰\",\"tr\":\"Esvatini\"}', '-26.50000000', '31.50000000', '', 'U+1F1F8 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1050'),
(213, 'Sweden', 'SWE', '752', 'SE', '46', 'Stockholm', 'SEK', 'Swedish krona', 'kr', '.se', 'Sverige', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/Stockholm\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"스웨덴\",\"br\":\"Suécia\",\"pt\":\"Suécia\",\"nl\":\"Zweden\",\"hr\":\"Švedska\",\"fa\":\"سوئد\",\"de\":\"Schweden\",\"es\":\"Suecia\",\"fr\":\"Suède\",\"ja\":\"スウェーデン\",\"it\":\"Svezia\",\"cn\":\"瑞典\",\"tr\":\"İsveç\"}', '62.00000000', '15.00000000', '', 'U+1F1F8 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q34'),
(214, 'Switzerland', 'CHE', '756', 'CH', '41', 'Bern', 'CHF', 'Swiss franc', 'CHf', '.ch', 'Schweiz', 'Europe', 'Western Europe', '[{\"zoneName\":\"Europe/Zurich\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"스위스\",\"br\":\"Suíça\",\"pt\":\"Suíça\",\"nl\":\"Zwitserland\",\"hr\":\"Švicarska\",\"fa\":\"سوئیس\",\"de\":\"Schweiz\",\"es\":\"Suiza\",\"fr\":\"Suisse\",\"ja\":\"スイス\",\"it\":\"Svizzera\",\"cn\":\"瑞士\",\"tr\":\"İsviçre\"}', '47.00000000', '8.00000000', '', 'U+1F1E8 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q39'),
(215, 'Syria', 'SYR', '760', 'SY', '963', 'Damascus', 'SYP', 'Syrian pound', 'LS', '.sy', 'سوريا', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Damascus\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"시리아\",\"br\":\"Síria\",\"pt\":\"Síria\",\"nl\":\"Syrië\",\"hr\":\"Sirija\",\"fa\":\"سوریه\",\"de\":\"Syrien\",\"es\":\"Siria\",\"fr\":\"Syrie\",\"ja\":\"シリア・アラブ共和国\",\"it\":\"Siria\",\"cn\":\"叙利亚\",\"tr\":\"Suriye\"}', '35.00000000', '38.00000000', '', 'U+1F1F8 U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q858'),
(216, 'Taiwan', 'TWN', '158', 'TW', '886', 'Taipei', 'TWD', 'New Taiwan dollar', '$', '.tw', '臺灣', 'Asia', 'Eastern Asia', '[{\"zoneName\":\"Asia/Taipei\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"}]', '{\"kr\":\"대만\",\"br\":\"Taiwan\",\"pt\":\"Taiwan\",\"nl\":\"Taiwan\",\"hr\":\"Tajvan\",\"fa\":\"تایوان\",\"de\":\"Taiwan\",\"es\":\"Taiwán\",\"fr\":\"Taïwan\",\"ja\":\"台湾（中華民国）\",\"it\":\"Taiwan\",\"cn\":\"中国台湾\",\"tr\":\"Tayvan\"}', '23.50000000', '121.00000000', '', 'U+1F1F9 U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q865'),
(217, 'Tajikistan', 'TJK', '762', 'TJ', '992', 'Dushanbe', 'TJS', 'Tajikistani somoni', 'SM', '.tj', 'Тоҷикистон', 'Asia', 'Central Asia', '[{\"zoneName\":\"Asia/Dushanbe\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TJT\",\"tzName\":\"Tajikistan Time\"}]', '{\"kr\":\"타지키스탄\",\"br\":\"Tajiquistão\",\"pt\":\"Tajiquistão\",\"nl\":\"Tadzjikistan\",\"hr\":\"Tađikistan\",\"fa\":\"تاجیکستان\",\"de\":\"Tadschikistan\",\"es\":\"Tayikistán\",\"fr\":\"Tadjikistan\",\"ja\":\"タジキスタン\",\"it\":\"Tagikistan\",\"cn\":\"塔吉克斯坦\",\"tr\":\"Tacikistan\"}', '39.00000000', '71.00000000', '', 'U+1F1F9 U+1F1EF', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q863'),
(218, 'Tanzania', 'TZA', '834', 'TZ', '255', 'Dodoma', 'TZS', 'Tanzanian shilling', 'TSh', '.tz', 'Tanzania', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Dar_es_Salaam\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"탄자니아\",\"br\":\"Tanzânia\",\"pt\":\"Tanzânia\",\"nl\":\"Tanzania\",\"hr\":\"Tanzanija\",\"fa\":\"تانزانیا\",\"de\":\"Tansania\",\"es\":\"Tanzania\",\"fr\":\"Tanzanie\",\"ja\":\"タンザニア\",\"it\":\"Tanzania\",\"cn\":\"坦桑尼亚\",\"tr\":\"Tanzanya\"}', '-6.00000000', '35.00000000', '', 'U+1F1F9 U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q924'),
(219, 'Thailand', 'THA', '764', 'TH', '66', 'Bangkok', 'THB', 'Thai baht', '฿', '.th', 'ประเทศไทย', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Bangkok\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]', '{\"kr\":\"태국\",\"br\":\"Tailândia\",\"pt\":\"Tailândia\",\"nl\":\"Thailand\",\"hr\":\"Tajland\",\"fa\":\"تایلند\",\"de\":\"Thailand\",\"es\":\"Tailandia\",\"fr\":\"Thaïlande\",\"ja\":\"タイ\",\"it\":\"Tailandia\",\"cn\":\"泰国\",\"tr\":\"Tayland\"}', '15.00000000', '100.00000000', '', 'U+1F1F9 U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q869'),
(220, 'Togo', 'TGO', '768', 'TG', '228', 'Lome', 'XOF', 'West African CFA franc', 'CFA', '.tg', 'Togo', 'Africa', 'Western Africa', '[{\"zoneName\":\"Africa/Lome\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"토고\",\"br\":\"Togo\",\"pt\":\"Togo\",\"nl\":\"Togo\",\"hr\":\"Togo\",\"fa\":\"توگو\",\"de\":\"Togo\",\"es\":\"Togo\",\"fr\":\"Togo\",\"ja\":\"トーゴ\",\"it\":\"Togo\",\"cn\":\"多哥\",\"tr\":\"Togo\"}', '8.00000000', '1.16666666', '', 'U+1F1F9 U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q945'),
(221, 'Tokelau', 'TKL', '772', 'TK', '690', '', 'NZD', 'New Zealand dollar', '$', '.tk', 'Tokelau', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Fakaofo\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"TKT\",\"tzName\":\"Tokelau Time\"}]', '{\"kr\":\"토켈라우\",\"br\":\"Tokelau\",\"pt\":\"Toquelau\",\"nl\":\"Tokelau\",\"hr\":\"Tokelau\",\"fa\":\"توکلائو\",\"de\":\"Tokelau\",\"es\":\"Islas Tokelau\",\"fr\":\"Tokelau\",\"ja\":\"トケラウ\",\"it\":\"Isole Tokelau\",\"cn\":\"托克劳\",\"tr\":\"Tokelau\"}', '-9.00000000', '-172.00000000', '', 'U+1F1F9 U+1F1F0', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(222, 'Tonga', 'TON', '776', 'TO', '676', 'Nuku\'alofa', 'TOP', 'Tongan paʻanga', '$', '.to', 'Tonga', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Tongatapu\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"TOT\",\"tzName\":\"Tonga Time\"}]', '{\"kr\":\"통가\",\"br\":\"Tonga\",\"pt\":\"Tonga\",\"nl\":\"Tonga\",\"hr\":\"Tonga\",\"fa\":\"تونگا\",\"de\":\"Tonga\",\"es\":\"Tonga\",\"fr\":\"Tonga\",\"ja\":\"トンガ\",\"it\":\"Tonga\",\"cn\":\"汤加\",\"tr\":\"Tonga\"}', '-20.00000000', '-175.00000000', '', 'U+1F1F9 U+1F1F4', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q678'),
(223, 'Trinidad And Tobago', 'TTO', '780', 'TT', '+1-868', 'Port of Spain', 'TTD', 'Trinidad and Tobago dollar', '$', '.tt', 'Trinidad and Tobago', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Port_of_Spain\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"트리니다드 토바고\",\"br\":\"Trinidad e Tobago\",\"pt\":\"Trindade e Tobago\",\"nl\":\"Trinidad en Tobago\",\"hr\":\"Trinidad i Tobago\",\"fa\":\"ترینیداد و توباگو\",\"de\":\"Trinidad und Tobago\",\"es\":\"Trinidad y Tobago\",\"fr\":\"Trinité et Tobago\",\"ja\":\"トリニダード・トバゴ\",\"it\":\"Trinidad e Tobago\",\"cn\":\"特立尼达和多巴哥\",\"tr\":\"Trinidad Ve Tobago\"}', '11.00000000', '-61.00000000', '', 'U+1F1F9 U+1F1F9', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q754'),
(224, 'Tunisia', 'TUN', '788', 'TN', '216', 'Tunis', 'TND', 'Tunisian dinar', 'ت.د', '.tn', 'تونس', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/Tunis\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"튀니지\",\"br\":\"Tunísia\",\"pt\":\"Tunísia\",\"nl\":\"Tunesië\",\"hr\":\"Tunis\",\"fa\":\"تونس\",\"de\":\"Tunesien\",\"es\":\"Túnez\",\"fr\":\"Tunisie\",\"ja\":\"チュニジア\",\"it\":\"Tunisia\",\"cn\":\"突尼斯\",\"tr\":\"Tunus\"}', '34.00000000', '9.00000000', '', 'U+1F1F9 U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q948'),
(225, 'Turkey', 'TUR', '792', 'TR', '90', 'Ankara', 'TRY', 'Turkish lira', '₺', '.tr', 'Türkiye', 'Asia', 'Western Asia', '[{\"zoneName\":\"Europe/Istanbul\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"터키\",\"br\":\"Turquia\",\"pt\":\"Turquia\",\"nl\":\"Turkije\",\"hr\":\"Turska\",\"fa\":\"ترکیه\",\"de\":\"Türkei\",\"es\":\"Turquía\",\"fr\":\"Turquie\",\"ja\":\"トルコ\",\"it\":\"Turchia\",\"cn\":\"土耳其\",\"tr\":\"Türkiye\"}', '39.00000000', '35.00000000', '', 'U+1F1F9 U+1F1F7', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q43'),
(226, 'Turkmenistan', 'TKM', '795', 'TM', '993', 'Ashgabat', 'TMT', 'Turkmenistan manat', 'T', '.tm', 'Türkmenistan', 'Asia', 'Central Asia', '[{\"zoneName\":\"Asia/Ashgabat\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TMT\",\"tzName\":\"Turkmenistan Time\"}]', '{\"kr\":\"투르크메니스탄\",\"br\":\"Turcomenistão\",\"pt\":\"Turquemenistão\",\"nl\":\"Turkmenistan\",\"hr\":\"Turkmenistan\",\"fa\":\"ترکمنستان\",\"de\":\"Turkmenistan\",\"es\":\"Turkmenistán\",\"fr\":\"Turkménistan\",\"ja\":\"トルクメニスタン\",\"it\":\"Turkmenistan\",\"cn\":\"土库曼斯坦\",\"tr\":\"Türkmenistan\"}', '40.00000000', '60.00000000', '', 'U+1F1F9 U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q874'),
(227, 'Turks And Caicos Islands', 'TCA', '796', 'TC', '+1-649', 'Cockburn Town', 'USD', 'United States dollar', '$', '.tc', 'Turks and Caicos Islands', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Grand_Turk\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]', '{\"kr\":\"터크스 케이커스 제도\",\"br\":\"Ilhas Turcas e Caicos\",\"pt\":\"Ilhas Turcas e Caicos\",\"nl\":\"Turks- en Caicoseilanden\",\"hr\":\"Otoci Turks i Caicos\",\"fa\":\"جزایر تورکس و کایکوس\",\"de\":\"Turks- und Caicosinseln\",\"es\":\"Islas Turks y Caicos\",\"fr\":\"Îles Turques-et-Caïques\",\"ja\":\"タークス・カイコス諸島\",\"it\":\"Isole Turks e Caicos\",\"cn\":\"特克斯和凯科斯群岛\",\"tr\":\"Turks Ve Caicos Adalari\"}', '21.75000000', '-71.58333333', '', 'U+1F1F9 U+1F1E8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(228, 'Tuvalu', 'TUV', '798', 'TV', '688', 'Funafuti', 'AUD', 'Australian dollar', '$', '.tv', 'Tuvalu', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Funafuti\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"TVT\",\"tzName\":\"Tuvalu Time\"}]', '{\"kr\":\"투발루\",\"br\":\"Tuvalu\",\"pt\":\"Tuvalu\",\"nl\":\"Tuvalu\",\"hr\":\"Tuvalu\",\"fa\":\"تووالو\",\"de\":\"Tuvalu\",\"es\":\"Tuvalu\",\"fr\":\"Tuvalu\",\"ja\":\"ツバル\",\"it\":\"Tuvalu\",\"cn\":\"图瓦卢\",\"tr\":\"Tuvalu\"}', '-8.00000000', '178.00000000', '', 'U+1F1F9 U+1F1FB', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q672'),
(229, 'Uganda', 'UGA', '800', 'UG', '256', 'Kampala', 'UGX', 'Ugandan shilling', 'USh', '.ug', 'Uganda', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Kampala\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]', '{\"kr\":\"우간다\",\"br\":\"Uganda\",\"pt\":\"Uganda\",\"nl\":\"Oeganda\",\"hr\":\"Uganda\",\"fa\":\"اوگاندا\",\"de\":\"Uganda\",\"es\":\"Uganda\",\"fr\":\"Uganda\",\"ja\":\"ウガンダ\",\"it\":\"Uganda\",\"cn\":\"乌干达\",\"tr\":\"Uganda\"}', '1.00000000', '32.00000000', '', 'U+1F1FA U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q1036'),
(230, 'Ukraine', 'UKR', '804', 'UA', '380', 'Kiev', 'UAH', 'Ukrainian hryvnia', '₴', '.ua', 'Україна', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Kiev\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Simferopol\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Uzhgorod\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Zaporozhye\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]', '{\"kr\":\"우크라이나\",\"br\":\"Ucrânia\",\"pt\":\"Ucrânia\",\"nl\":\"Oekraïne\",\"hr\":\"Ukrajina\",\"fa\":\"وکراین\",\"de\":\"Ukraine\",\"es\":\"Ucrania\",\"fr\":\"Ukraine\",\"ja\":\"ウクライナ\",\"it\":\"Ucraina\",\"cn\":\"乌克兰\",\"tr\":\"Ukrayna\"}', '49.00000000', '32.00000000', '', 'U+1F1FA U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q212'),
(231, 'United Arab Emirates', 'ARE', '784', 'AE', '971', 'Abu Dhabi', 'AED', 'United Arab Emirates dirham', 'إ.د', '.ae', 'دولة الإمارات العربية المتحدة', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Dubai\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GST\",\"tzName\":\"Gulf Standard Time\"}]', '{\"kr\":\"아랍에미리트\",\"br\":\"Emirados árabes Unidos\",\"pt\":\"Emirados árabes Unidos\",\"nl\":\"Verenigde Arabische Emiraten\",\"hr\":\"Ujedinjeni Arapski Emirati\",\"fa\":\"امارات متحده عربی\",\"de\":\"Vereinigte Arabische Emirate\",\"es\":\"Emiratos Árabes Unidos\",\"fr\":\"Émirats arabes unis\",\"ja\":\"アラブ首長国連邦\",\"it\":\"Emirati Arabi Uniti\",\"cn\":\"阿拉伯联合酋长国\",\"tr\":\"Birleşik Arap Emirlikleri\"}', '24.00000000', '54.00000000', '', 'U+1F1E6 U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q878'),
(232, 'United Kingdom', 'GBR', '826', 'GB', '44', 'London', 'GBP', 'British pound', '£', '.uk', 'United Kingdom', 'Europe', 'Northern Europe', '[{\"zoneName\":\"Europe/London\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]', '{\"kr\":\"영국\",\"br\":\"Reino Unido\",\"pt\":\"Reino Unido\",\"nl\":\"Verenigd Koninkrijk\",\"hr\":\"Ujedinjeno Kraljevstvo\",\"fa\":\"بریتانیای کبیر و ایرلند شمالی\",\"de\":\"Vereinigtes Königreich\",\"es\":\"Reino Unido\",\"fr\":\"Royaume-Uni\",\"ja\":\"イギリス\",\"it\":\"Regno Unito\",\"cn\":\"英国\",\"tr\":\"Birleşik Krallik\"}', '54.00000000', '-2.00000000', '', 'U+1F1EC U+1F1E7', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q145'),
(233, 'United States', 'USA', '840', 'US', '1', 'Washington', 'USD', 'United States dollar', '$', '.us', 'United States', 'Americas', 'Northern America', '[{\"zoneName\":\"America/Adak\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"HST\",\"tzName\":\"Hawaii–Aleutian Standard Time\"},{\"zoneName\":\"America/Anchorage\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Boise\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Chicago\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Denver\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Detroit\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Indianapolis\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Knox\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Marengo\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Petersburg\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Tell_City\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Vevay\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Vincennes\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Winamac\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Juneau\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Kentucky/Louisville\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Kentucky/Monticello\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Los_Angeles\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"},{\"zoneName\":\"America/Menominee\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Metlakatla\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/New_York\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Nome\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/North_Dakota/Beulah\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/North_Dakota/Center\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/North_Dakota/New_Salem\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Phoenix\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Sitka\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Yakutat\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"Pacific/Honolulu\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"HST\",\"tzName\":\"Hawaii–Aleutian Standard Time\"}]', '{\"kr\":\"미국\",\"br\":\"Estados Unidos\",\"pt\":\"Estados Unidos\",\"nl\":\"Verenigde Staten\",\"hr\":\"Sjedinjene Američke Države\",\"fa\":\"ایالات متحده آمریکا\",\"de\":\"Vereinigte Staaten von Amerika\",\"es\":\"Estados Unidos\",\"fr\":\"États-Unis\",\"ja\":\"アメリカ合衆国\",\"it\":\"Stati Uniti D\'America\",\"cn\":\"美国\",\"tr\":\"Amerika\"}', '38.00000000', '-97.00000000', '', 'U+1F1FA U+1F1F8', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q30'),
(234, 'United States Minor Outlying Islands', 'UMI', '581', 'UM', '1', '', 'USD', 'United States dollar', '$', '.us', 'United States Minor Outlying Islands', 'Americas', 'Northern America', '[{\"zoneName\":\"Pacific/Midway\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"SST\",\"tzName\":\"Samoa Standard Time\"},{\"zoneName\":\"Pacific/Wake\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"WAKT\",\"tzName\":\"Wake Island Time\"}]', '{\"kr\":\"미국령 군소 제도\",\"br\":\"Ilhas Menores Distantes dos Estados Unidos\",\"pt\":\"Ilhas Menores Distantes dos Estados Unidos\",\"nl\":\"Kleine afgelegen eilanden van de Verenigde Staten\",\"hr\":\"Mali udaljeni otoci SAD-a\",\"fa\":\"جزایر کوچک حاشیه‌ای ایالات متحده آمریکا\",\"de\":\"Kleinere Inselbesitzungen der Vereinigten Staaten\",\"es\":\"Islas Ultramarinas Menores de Estados Unidos\",\"fr\":\"Îles mineures éloignées des États-Unis\",\"ja\":\"合衆国領有小離島\",\"it\":\"Isole minori esterne degli Stati Uniti d\'America\",\"cn\":\"美国本土外小岛屿\",\"tr\":\"Abd Küçük Harici Adalari\"}', '0.00000000', '0.00000000', '', 'U+1F1FA U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(235, 'Uruguay', 'URY', '858', 'UY', '598', 'Montevideo', 'UYU', 'Uruguayan peso', '$', '.uy', 'Uruguay', 'Americas', 'South America', '[{\"zoneName\":\"America/Montevideo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"UYT\",\"tzName\":\"Uruguay Standard Time\"}]', '{\"kr\":\"우루과이\",\"br\":\"Uruguai\",\"pt\":\"Uruguai\",\"nl\":\"Uruguay\",\"hr\":\"Urugvaj\",\"fa\":\"اروگوئه\",\"de\":\"Uruguay\",\"es\":\"Uruguay\",\"fr\":\"Uruguay\",\"ja\":\"ウルグアイ\",\"it\":\"Uruguay\",\"cn\":\"乌拉圭\",\"tr\":\"Uruguay\"}', '-33.00000000', '-56.00000000', '', 'U+1F1FA U+1F1FE', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q77'),
(236, 'Uzbekistan', 'UZB', '860', 'UZ', '998', 'Tashkent', 'UZS', 'Uzbekistani soʻm', 'лв', '.uz', 'O‘zbekiston', 'Asia', 'Central Asia', '[{\"zoneName\":\"Asia/Samarkand\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"UZT\",\"tzName\":\"Uzbekistan Time\"},{\"zoneName\":\"Asia/Tashkent\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"UZT\",\"tzName\":\"Uzbekistan Time\"}]', '{\"kr\":\"우즈베키스탄\",\"br\":\"Uzbequistão\",\"pt\":\"Usbequistão\",\"nl\":\"Oezbekistan\",\"hr\":\"Uzbekistan\",\"fa\":\"ازبکستان\",\"de\":\"Usbekistan\",\"es\":\"Uzbekistán\",\"fr\":\"Ouzbékistan\",\"ja\":\"ウズベキスタン\",\"it\":\"Uzbekistan\",\"cn\":\"乌兹别克斯坦\",\"tr\":\"Özbekistan\"}', '41.00000000', '64.00000000', '', 'U+1F1FA U+1F1FF', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q265'),
(237, 'Vanuatu', 'VUT', '548', 'VU', '678', 'Port Vila', 'VUV', 'Vanuatu vatu', 'VT', '.vu', 'Vanuatu', 'Oceania', 'Melanesia', '[{\"zoneName\":\"Pacific/Efate\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"VUT\",\"tzName\":\"Vanuatu Time\"}]', '{\"kr\":\"바누아투\",\"br\":\"Vanuatu\",\"pt\":\"Vanuatu\",\"nl\":\"Vanuatu\",\"hr\":\"Vanuatu\",\"fa\":\"وانواتو\",\"de\":\"Vanuatu\",\"es\":\"Vanuatu\",\"fr\":\"Vanuatu\",\"ja\":\"バヌアツ\",\"it\":\"Vanuatu\",\"cn\":\"瓦努阿图\",\"tr\":\"Vanuatu\"}', '-16.00000000', '167.00000000', '', 'U+1F1FB U+1F1FA', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q686'),
(238, 'Vatican City State (Holy See)', 'VAT', '336', 'VA', '379', 'Vatican City', 'EUR', 'Euro', '€', '.va', 'Vaticano', 'Europe', 'Southern Europe', '[{\"zoneName\":\"Europe/Vatican\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"바티칸 시국\",\"br\":\"Vaticano\",\"pt\":\"Vaticano\",\"nl\":\"Heilige Stoel\",\"hr\":\"Sveta Stolica\",\"fa\":\"سریر مقدس\",\"de\":\"Heiliger Stuhl\",\"es\":\"Santa Sede\",\"fr\":\"voir Saint\",\"ja\":\"聖座\",\"it\":\"Santa Sede\",\"cn\":\"梵蒂冈\",\"tr\":\"Vatikan\"}', '41.90000000', '12.45000000', '', 'U+1F1FB U+1F1E6', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q237'),
(239, 'Venezuela', 'VEN', '862', 'VE', '58', 'Caracas', 'VEF', 'Bolívar', 'Bs', '.ve', 'Venezuela', 'Americas', 'South America', '[{\"zoneName\":\"America/Caracas\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"VET\",\"tzName\":\"Venezuelan Standard Time\"}]', '{\"kr\":\"베네수엘라\",\"br\":\"Venezuela\",\"pt\":\"Venezuela\",\"nl\":\"Venezuela\",\"hr\":\"Venezuela\",\"fa\":\"ونزوئلا\",\"de\":\"Venezuela\",\"es\":\"Venezuela\",\"fr\":\"Venezuela\",\"ja\":\"ベネズエラ・ボリバル共和国\",\"it\":\"Venezuela\",\"cn\":\"委内瑞拉\",\"tr\":\"Venezuela\"}', '8.00000000', '-66.00000000', '', 'U+1F1FB U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q717'),
(240, 'Vietnam', 'VNM', '704', 'VN', '84', 'Hanoi', 'VND', 'Vietnamese đồng', '₫', '.vn', 'Việt Nam', 'Asia', 'South-Eastern Asia', '[{\"zoneName\":\"Asia/Ho_Chi_Minh\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]', '{\"kr\":\"베트남\",\"br\":\"Vietnã\",\"pt\":\"Vietname\",\"nl\":\"Vietnam\",\"hr\":\"Vijetnam\",\"fa\":\"ویتنام\",\"de\":\"Vietnam\",\"es\":\"Vietnam\",\"fr\":\"Viêt Nam\",\"ja\":\"ベトナム\",\"it\":\"Vietnam\",\"cn\":\"越南\",\"tr\":\"Vietnam\"}', '16.16666666', '107.83333333', '', 'U+1F1FB U+1F1F3', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q881'),
(241, 'Virgin Islands (British)', 'VGB', '092', 'VG', '+1-284', 'Road Town', 'USD', 'United States dollar', '$', '.vg', 'British Virgin Islands', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Tortola\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"영국령 버진아일랜드\",\"br\":\"Ilhas Virgens Britânicas\",\"pt\":\"Ilhas Virgens Britânicas\",\"nl\":\"Britse Maagdeneilanden\",\"hr\":\"Britanski Djevičanski Otoci\",\"fa\":\"جزایر ویرجین بریتانیا\",\"de\":\"Britische Jungferninseln\",\"es\":\"Islas Vírgenes del Reino Unido\",\"fr\":\"Îles Vierges britanniques\",\"ja\":\"イギリス領ヴァージン諸島\",\"it\":\"Isole Vergini Britanniche\",\"cn\":\"圣文森特和格林纳丁斯\",\"tr\":\"Britanya Virjin Adalari\"}', '18.43138300', '-64.62305000', '', 'U+1F1FB U+1F1EC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(242, 'Virgin Islands (US)', 'VIR', '850', 'VI', '+1-340', 'Charlotte Amalie', 'USD', 'United States dollar', '$', '.vi', 'United States Virgin Islands', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/St_Thomas\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"미국령 버진아일랜드\",\"br\":\"Ilhas Virgens Americanas\",\"pt\":\"Ilhas Virgens Americanas\",\"nl\":\"Verenigde Staten Maagdeneilanden\",\"fa\":\"جزایر ویرجین آمریکا\",\"de\":\"Amerikanische Jungferninseln\",\"es\":\"Islas Vírgenes de los Estados Unidos\",\"fr\":\"Îles Vierges des États-Unis\",\"ja\":\"アメリカ領ヴァージン諸島\",\"it\":\"Isole Vergini americane\",\"cn\":\"维尔京群岛（美国）\",\"tr\":\"Abd Virjin Adalari\"}', '18.34000000', '-64.93000000', '', 'U+1F1FB U+1F1EE', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(243, 'Wallis And Futuna Islands', 'WLF', '876', 'WF', '681', 'Mata Utu', 'XPF', 'CFP franc', '₣', '.wf', 'Wallis et Futuna', 'Oceania', 'Polynesia', '[{\"zoneName\":\"Pacific/Wallis\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"WFT\",\"tzName\":\"Wallis & Futuna Time\"}]', '{\"kr\":\"왈리스 푸투나\",\"br\":\"Wallis e Futuna\",\"pt\":\"Wallis e Futuna\",\"nl\":\"Wallis en Futuna\",\"hr\":\"Wallis i Fortuna\",\"fa\":\"والیس و فوتونا\",\"de\":\"Wallis und Futuna\",\"es\":\"Wallis y Futuna\",\"fr\":\"Wallis-et-Futuna\",\"ja\":\"ウォリス・フツナ\",\"it\":\"Wallis e Futuna\",\"cn\":\"瓦利斯群岛和富图纳群岛\",\"tr\":\"Wallis Ve Futuna\"}', '-13.30000000', '-176.20000000', '', 'U+1F1FC U+1F1EB', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(244, 'Western Sahara', 'ESH', '732', 'EH', '212', 'El-Aaiun', 'MAD', 'Moroccan Dirham', 'MAD', '.eh', 'الصحراء الغربية', 'Africa', 'Northern Africa', '[{\"zoneName\":\"Africa/El_Aaiun\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WEST\",\"tzName\":\"Western European Summer Time\"}]', '{\"kr\":\"서사하라\",\"br\":\"Saara Ocidental\",\"pt\":\"Saara Ocidental\",\"nl\":\"Westelijke Sahara\",\"hr\":\"Zapadna Sahara\",\"fa\":\"جمهوری دموکراتیک عربی صحرا\",\"de\":\"Westsahara\",\"es\":\"Sahara Occidental\",\"fr\":\"Sahara Occidental\",\"ja\":\"西サハラ\",\"it\":\"Sahara Occidentale\",\"cn\":\"西撒哈拉\",\"tr\":\"Bati Sahra\"}', '24.50000000', '-13.00000000', '', 'U+1F1EA U+1F1ED', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, NULL),
(245, 'Yemen', 'YEM', '887', 'YE', '967', 'Sanaa', 'YER', 'Yemeni rial', '﷼', '.ye', 'اليَمَن', 'Asia', 'Western Asia', '[{\"zoneName\":\"Asia/Aden\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]', '{\"kr\":\"예멘\",\"br\":\"Iêmen\",\"pt\":\"Iémen\",\"nl\":\"Jemen\",\"hr\":\"Jemen\",\"fa\":\"یمن\",\"de\":\"Jemen\",\"es\":\"Yemen\",\"fr\":\"Yémen\",\"ja\":\"イエメン\",\"it\":\"Yemen\",\"cn\":\"也门\",\"tr\":\"Yemen\"}', '15.00000000', '48.00000000', '', 'U+1F1FE U+1F1EA', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q805'),
(246, 'Zambia', 'ZMB', '894', 'ZM', '260', 'Lusaka', 'ZMW', 'Zambian kwacha', 'ZK', '.zm', 'Zambia', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Lusaka\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"잠비아\",\"br\":\"Zâmbia\",\"pt\":\"Zâmbia\",\"nl\":\"Zambia\",\"hr\":\"Zambija\",\"fa\":\"زامبیا\",\"de\":\"Sambia\",\"es\":\"Zambia\",\"fr\":\"Zambie\",\"ja\":\"ザンビア\",\"it\":\"Zambia\",\"cn\":\"赞比亚\",\"tr\":\"Zambiya\"}', '-15.00000000', '30.00000000', '', 'U+1F1FF U+1F1F2', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q953'),
(247, 'Zimbabwe', 'ZWE', '716', 'ZW', '263', 'Harare', 'ZWL', 'Zimbabwe Dollar', '$', '.zw', 'Zimbabwe', 'Africa', 'Eastern Africa', '[{\"zoneName\":\"Africa/Harare\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]', '{\"kr\":\"짐바브웨\",\"br\":\"Zimbabwe\",\"pt\":\"Zimbabué\",\"nl\":\"Zimbabwe\",\"hr\":\"Zimbabve\",\"fa\":\"زیمباوه\",\"de\":\"Simbabwe\",\"es\":\"Zimbabue\",\"fr\":\"Zimbabwe\",\"ja\":\"ジンバブエ\",\"it\":\"Zimbabwe\",\"cn\":\"津巴布韦\",\"tr\":\"Zimbabve\"}', '-20.00000000', '30.00000000', '', 'U+1F1FF U+1F1FC', '2018-07-21 01:11:03', '2022-05-21 15:39:27', 1, 'Q954'),
(248, 'Kosovo', 'XKX', '926', 'XK', '383', 'Pristina', 'EUR', 'Euro', '€', '.xk', 'Republika e Kosovës', 'Europe', 'Eastern Europe', '[{\"zoneName\":\"Europe/Belgrade\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]', '{\"kr\":\"코소보\",\"cn\":\"科索沃\",\"tr\":\"Kosova\"}', '42.56129090', '20.34030350', '', 'U+1F1FD U+1F1F0', '2020-08-15 20:33:50', '2022-05-21 15:39:27', 1, 'Q1246'),
(249, 'Curaçao', 'CUW', '531', 'CW', '599', 'Willemstad', 'ANG', 'Netherlands Antillean guilder', 'ƒ', '.cw', 'Curaçao', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Curacao\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"퀴라소\",\"br\":\"Curaçao\",\"pt\":\"Curaçao\",\"nl\":\"Curaçao\",\"fa\":\"کوراسائو\",\"de\":\"Curaçao\",\"fr\":\"Curaçao\",\"it\":\"Curaçao\",\"cn\":\"库拉索\",\"tr\":\"Curaçao\"}', '12.11666700', '-68.93333300', '', 'U+1F1E8 U+1F1FC', '2020-10-25 19:54:20', '2022-05-21 15:39:27', 1, 'Q25279'),
(250, 'Sint Maarten (Dutch part)', 'SXM', '534', 'SX', '1721', 'Philipsburg', 'ANG', 'Netherlands Antillean guilder', 'ƒ', '.sx', 'Sint Maarten', 'Americas', 'Caribbean', '[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]', '{\"kr\":\"신트마르턴\",\"br\":\"Sint Maarten\",\"pt\":\"São Martinho\",\"nl\":\"Sint Maarten\",\"fa\":\"سینت مارتن\",\"de\":\"Sint Maarten (niederl. Teil)\",\"fr\":\"Saint Martin (partie néerlandaise)\",\"it\":\"Saint Martin (parte olandese)\",\"cn\":\"圣马丁岛（荷兰部分）\",\"tr\":\"Sint Maarten\"}', '18.03333300', '-63.05000000', '', 'U+1F1F8 U+1F1FD', '2020-12-05 18:03:39', '2022-05-21 15:39:27', 1, 'Q26273');

-- --------------------------------------------------------

--
-- Table structure for table `count_informations`
--

CREATE TABLE `count_informations` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `amount` int(10) UNSIGNED NOT NULL,
  `serial_number` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `count_informations`
--

INSERT INTO `count_informations` (`id`, `language_id`, `icon`, `color`, `title`, `amount`, `serial_number`, `created_at`, `updated_at`) VALUES
(5, 8, 'fas fa-user-friends', '24FFCD', 'Qualified Instructors', 20, 1, '2021-10-11 01:20:18', '2022-05-15 00:17:03'),
(6, 8, 'fas fa-globe', 'FFAB74', 'Worldwide Students', 1490, 2, '2021-10-11 01:20:47', '2021-12-19 04:44:42'),
(7, 8, 'fas fa-book-reader', '00FCFF', 'Courses', 100, 3, '2021-10-11 01:21:31', '2021-12-19 04:45:36'),
(8, 8, 'fas fa-calendar-alt', 'FFC924', 'Years\' Experience', 10, 4, '2021-10-11 01:21:55', '2021-12-19 04:46:07');

-- --------------------------------------------------------

--
-- Table structure for table `coupons`
--

CREATE TABLE `coupons` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `events` varchar(255) DEFAULT NULL,
  `start_date` varchar(255) NOT NULL,
  `end_date` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `coupons`
--

INSERT INTO `coupons` (`id`, `name`, `code`, `type`, `value`, `events`, `start_date`, `end_date`, `created_at`, `updated_at`) VALUES
(6, 'mega00', 'mega00', 'fixed', '5', NULL, '2023-05-06', '2026-05-13', '2023-05-08 09:26:43', '2023-05-20 04:43:38');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `provider_id` varchar(255) DEFAULT NULL,
  `fname` varchar(255) NOT NULL,
  `lname` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `email_verified_at` varchar(255) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `provider`, `provider_id`, `fname`, `lname`, `email`, `username`, `photo`, `phone`, `address`, `country`, `state`, `city`, `zip_code`, `password`, `status`, `email_verified_at`, `verification_token`, `created_at`, `updated_at`) VALUES
(23, NULL, NULL, 'Jone', 'Doe', 'metewa8928@fintehs.com', 'user', '6457527d067f4.png', '202-555-0152', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Uniteud States', 'North Carolina', 'Rockingham', '28339', '$2y$10$pBe72hi1pFPznE2hIK89uOnannmG5WfSn1XOF4/g5wo28lwShudMG', 1, '2023-05-01 11:50:26', '07eaf3d938eb4b69a6807bc77b7669d8', '2023-05-01 05:50:06', '2025-11-09 01:11:03'),
(30, 'facebook', '2338264536346469', 'Samiul Alim Pratik', NULL, 'pratik.anwar@gmail.com', '2338264536346469', '2338264536346469.jpg', NULL, NULL, NULL, NULL, NULL, NULL, 'eyJpdiI6IkxSaG5sOHErbThSN0R4VGkwWG1SUEE9PSIsInZhbHVlIjoiUDZVdVFNVXpVcG15bW9lNmxTSURXQT09IiwibWFjIjoiYjc5YTQ2NmY3ZWZiZmZiMzlmZWQyODI5MDk5YTJjNWNhODQ4MTRhYjJmZjFhYjNiNjk3ZjY5MDY4MzkwY2Q0YyIsInRhZyI6IiJ9', 1, '2023-05-17 12:19:13', NULL, '2023-05-17 10:19:13', '2023-05-17 10:19:13'),
(31, 'facebook', '2338281389678117', 'Samiul Alim Pratik', NULL, 'pratik.anwar@gmail.com', '2338281389678117', '2338281389678117.jpg', NULL, NULL, NULL, NULL, NULL, NULL, 'eyJpdiI6InFSUWdqT0lwYjl3Sm51NnpXaGwxVGc9PSIsInZhbHVlIjoiWkZPYjVnMXlKaVN5bXdNKzJaSUMvQT09IiwibWFjIjoiOGFlOWIzN2FjZDQ4Mjc4NGM1YWVkYjM1M2IzOWI0N2MxNmQ0NjYxMjI3Y2U0YTgxNDFlYTE4ODU0YzY4ZjE0YyIsInRhZyI6IiJ9', 1, '2023-05-17 12:35:26', NULL, '2023-05-17 10:35:26', '2023-05-17 10:35:26'),
(32, 'google', '106086486044918458871', 'Genius Test', NULL, 'geniustest11@gmail.com', '106086486044918458871', '106086486044918458871.jpg', NULL, NULL, NULL, NULL, NULL, NULL, 'eyJpdiI6ImI1YWtzUUwyNUEwQm1sV1laZ09FQ0E9PSIsInZhbHVlIjoiZDJkWmdhM2lpbmw4ZEh6eFQxdkNKZz09IiwibWFjIjoiMWRiNjU3YTc1MWEwZDkwMDUzMWVlZTY2MWUwYTljMWNiOWQ4YjdhYjI2YmQwNDAzM2Q2MDdkNjdjM2M4NDhiNyIsInRhZyI6IiJ9', 1, '2023-05-17 12:55:08', NULL, '2023-05-17 10:55:08', '2023-05-17 10:55:08'),
(33, NULL, NULL, 'Goutam', 'Sharma', 'goutam052597@gmail.com', 'goutam', '68f472873eaf5.png', '+232 1872330757', 'Ut est mollitia par', 'Sierra Leone', 'California', 'Sit amet rem facili', '75002', '$2y$10$8rP7lAXvR7jS1yg3RzhHBe2.JG4LaJfKUqq8X5GuWuZVPqSw6OI6W', 1, '2025-10-09 09:04:20', NULL, '2025-10-09 03:04:20', '2025-10-19 01:09:36'),
(34, NULL, NULL, 'Test', 'Customer', 'goutams1048@gmail.com', 'test', '68ecb6bb40103.png', '01601966496', '134/1 eastern housing', 'Bangladesh', 'Dhaka', 'Dhaka', '1200', '$2y$10$FfG4C.uI4I.ZWyDBBKWCfusPjdkKqEbDqTx8WjWAPgQXwiZDZA4Zm', 1, '2025-10-13 06:13:27', NULL, '2025-10-13 00:13:27', '2025-10-14 01:24:14'),
(35, NULL, NULL, 'Test', 'User', 'testuser@kreativdev.com', 'test0', '68ecb475458ce.png', '+8801711794393', '32 kreativdev', 'Bangaldesh', 'Dhaka', 'Dhaka', '1200', '$2y$10$SNxMVVu2Nva8MNmJQQ.OuumTiJhd9aTaoL6YUG.gNk1u8bnqkReSm', 1, '2025-10-13 06:23:14', NULL, '2025-10-13 00:23:15', '2025-10-13 04:50:57'),
(36, NULL, NULL, 'Jin', 'Vincent', 'jafylesus@mailinator.com', 'mopopymag', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$ONygash/0Y5KRLvOflOFjOscQJlActwJkqf7yoTYNmmmTfreU4cSW', 1, NULL, 'b5b50939313796a21ce78c6f2e418302', '2025-11-05 07:16:36', '2025-11-05 07:16:36'),
(37, NULL, NULL, 'Warren', 'Massey', 'moxesak@mailinator.com', 'levod', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$zjD4i0k1Ik6qkUnL8nuJGuOX7fB.u.TLBFrCXiRI.dTvLHuKeMfNG', 1, NULL, '1a4d9f83f9d20aa133c4810d744aeaf7', '2025-11-05 23:31:52', '2025-11-05 23:31:52'),
(38, NULL, NULL, 'Vernon', 'Brady', 'bocowovan@mailinator.com', 'hekewyw', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$thHmakYecv2n.HsojWTaOuFyS/EwDYUqiwNq0yz.SYdzhB91AU4Ry', 1, NULL, 'de5b5e987d286cdaa8a221a39f7b768e', '2025-11-05 23:36:03', '2025-11-05 23:36:03'),
(39, NULL, NULL, 'Quinlan', 'Maynard', 'cesesipok@mailinator.com', 'buhuz', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$NxJ69dLcsC1XZLfebw31gO1Ta9aRxzxLqn5MhFgj4uv.mb8Xai34G', 1, NULL, '42b88297c360803d4d1f21cffa28618d', '2025-11-06 00:06:05', '2025-11-06 00:06:05'),
(40, NULL, NULL, 'Montana', 'Rhodes', 'citi@mailinator.com', 'ziculofy', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$5.Wc/7iOGn7ADEDfUCCWoOwhYEeWoQgDgD3OK/YY/INW/Fiqyu0ey', 1, NULL, '430e10e5ec880185da2ef0f6c816bf04', '2025-11-06 00:52:07', '2025-11-06 00:52:07'),
(41, NULL, NULL, 'Irene', 'Velez', 'pegyti@mailinator.com', 'fejikyz', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$alP8EZ9hmvFaKDo70bh9z.mf7LkBLqhT5JIq8xxVMn/wb0ZD4yKmi', 1, NULL, 'f2a37e8a089960b0d3229f1a8508cd12', '2025-11-06 01:00:08', '2025-11-06 01:00:08'),
(42, NULL, NULL, 'Yen', 'Crane', 'mevove@mailinator.com', 'musamifisu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '$2y$10$LDR2vBXNzU8iEyuIdRIeHuzfrpuWhF2L0FwdDwvTg/9zAYkzAW3F6', 1, NULL, '0b8ee746caef3e51edd89db4779a30cb', '2025-11-06 01:04:52', '2025-11-06 01:04:52');

-- --------------------------------------------------------

--
-- Table structure for table `earnings`
--

CREATE TABLE `earnings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `total_revenue` float(8,2) DEFAULT '0.00',
  `total_earning` double(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `earnings`
--

INSERT INTO `earnings` (`id`, `total_revenue`, `total_earning`, `created_at`, `updated_at`) VALUES
(1, 278002.78, 61048.20, '2023-04-30 06:35:51', '2025-11-09 01:27:25');

-- --------------------------------------------------------

--
-- Table structure for table `events`
--

CREATE TABLE `events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `thumbnail` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT '1',
  `date_type` varchar(20) DEFAULT NULL,
  `countdown_status` int(11) DEFAULT '1',
  `start_date` date DEFAULT NULL,
  `start_time` varchar(255) DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `end_time` varchar(255) DEFAULT NULL,
  `end_date_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `is_featured` varchar(255) NOT NULL DEFAULT 'no',
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `instructions` text,
  `meeting_url` varchar(255) DEFAULT NULL,
  `ticket_logo` varchar(255) DEFAULT NULL,
  `ticket_image` text,
  `ticket_slot_image` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `events`
--

INSERT INTO `events` (`id`, `organizer_id`, `thumbnail`, `status`, `date_type`, `countdown_status`, `start_date`, `start_time`, `duration`, `end_date`, `end_time`, `end_date_time`, `created_at`, `updated_at`, `event_type`, `is_featured`, `latitude`, `longitude`, `instructions`, `meeting_url`, `ticket_logo`, `ticket_image`, `ticket_slot_image`) VALUES
(91, 25, '1683370360.png', '1', 'single', 1, '2026-01-18', '16:39', '2d 1m', '2026-01-20', '16:40', '2026-01-20 16:40:00', '2023-05-06 14:22:40', '2025-10-21 00:46:11', 'venue', 'yes', '40.7484436', '-73.9856672', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334526113.png', '1725334526794.png', NULL),
(92, 23, '1683370978.png', '1', 'single', 1, '2026-01-15', '16:01', '3d ', '2026-01-18', '16:01', '2026-01-18 16:01:00', '2023-05-06 11:02:58', '2025-11-06 01:14:30', 'online', 'no', NULL, NULL, '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334446394.png', '1725334493272.png', NULL),
(93, NULL, '1683371808.png', '1', 'single', 1, '2026-01-20', '17:12', '2d ', '2026-01-22', '17:12', '2026-01-22 17:12:00', '2023-05-06 11:16:48', '2025-10-21 00:46:05', 'venue', 'yes', '-33.8567844', '151.2152967', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com/</p>', NULL, '1725334383971.png', '1725334383969.png', NULL),
(94, 23, '1683372521.png', '1', 'multiple', 1, NULL, NULL, '2d 3h ', NULL, NULL, '2025-01-20 20:30:00', '2023-05-06 11:28:41', '2025-10-21 00:46:03', 'venue', 'yes', '52.5074434', '13.3903913', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334326300.png', '1725334326289.png', NULL),
(100, 23, '1683373446.png', '1', 'single', 1, '2026-02-25', '17:40', '18h 20m', '2026-02-26', '12:00', '2026-02-26 12:00:00', '2023-05-06 11:44:06', '2025-11-06 01:14:23', 'venue', 'no', '-33.8523063', '151.2107871', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com/</p>', NULL, '1725334276712.png', '1725334276825.png', NULL),
(101, 23, '1683436339.png', '1', 'single', 1, '2026-01-30', '11:10', '5h 58m', '2026-01-30', '17:08', '2026-01-30 17:08:00', '2023-05-07 05:12:19', '2025-10-21 00:45:58', 'online', 'yes', NULL, NULL, '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334230492.png', '1725334230233.png', NULL),
(102, 25, '1683437890.png', '1', 'single', 1, '2025-01-25', '10:00', '2h ', '2025-01-25', '12:00', '2025-01-25 12:00:00', '2023-05-07 05:38:10', '2025-11-06 01:12:52', 'venue', 'yes', '51.50811239999999', '-0.0759493', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334175282.png', '1725334175384.png', NULL),
(103, NULL, '1683438918.png', '1', 'single', 1, '2026-01-27', '09:49', '2h 11m', '2026-01-27', '12:00', '2026-01-27 12:00:00', '2023-05-07 05:55:18', '2025-11-06 01:12:50', 'venue', 'yes', '42.8220187', '-71.7626255', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725334122335.png', '1725334122959.png', NULL),
(104, 24, '1683439609.png', '1', 'multiple', 1, NULL, NULL, '4y 7mo 1697d 23h 58m', NULL, NULL, '2030-08-27 11:31:00', '2023-05-07 06:06:49', '2025-11-10 08:02:27', 'online', 'yes', NULL, NULL, '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', 'https://evento.test/admin/edit-event/116', '1725334060439.png', '1725334060681.png', NULL),
(105, 23, '1683440346.png', '1', 'single', 1, '2026-01-17', '10:18', '12h ', '2026-01-17', '22:18', '2026-01-17 22:18:00', '2023-05-07 06:19:06', '2025-11-10 07:26:13', 'venue', 'yes', '52.5162746', '13.3777041', '<p><strong>Important information</strong></p>\r\n<p>• We are AltokeTicket and we are dedicated to selling tickets for the best events in the country. However, you must remember that we are not the organizers of the event, that is, we are not responsible for the general condition, safety conditions of the establishment or for rescheduling or cancellations that may occur before, during or after the event.</p>\r\n<p>• Therefore, in the event of any eventuality, you will have to contact the company organizing the event. You can obtain information about this through all of our customer service channels.</p>\r\n<p>• If you decide to purchase from unauthorized points of sale, the responsibility will be yours, therefore, if the ticket turns out to be <br>false or adulterated, the promoter may NOT AUTHORIZE entry to the event.</p>\r\n<p>• Do not disclose or share the ticket with third parties.</p>\r\n<p>• IMPORTANT! When you arrive at the event you must present your ticket (printed or virtual) along with your identification document <br>.</p>\r\n<p>• If you purchased insurance, the insurance certificate will be sent by Altoke Ticket to the email address indicated by the ticket. </p>\r\n<p> </p>\r\n<p>For any questions or queries about the event or this ticket, you can contact us from the <br>Support option on our website https://www.example.com</p>', NULL, '1725333987370.png', '1759920703559.png', '1761732310844.png'),
(116, 23, '1695543215.png', '1', 'single', 1, '2024-08-31', '10:12', '26d 2m', '2024-09-26', '10:14', '2024-09-26 10:14:00', '2023-09-24 08:13:35', '2025-10-21 00:45:49', 'online', 'yes', NULL, NULL, '<div>\r\n<div>$bookingInfo-&gt;emailwgwer</div>\r\n<div>ert</div>\r\n<div>rg</div>\r\n<div>gwer</div>\r\n<div>gg</div>\r\n<div>e4g</div>\r\n<div> </div>\r\n</div>', 'https://evento.test/admin/edit-event/116', '1724832630241.png', NULL, NULL),
(126, 23, '1762418910.png', '1', 'single', 1, '2029-10-06', '02:43', '3mo 117d 19h 56m', '2029-06-10', '06:47', '2029-06-10 06:47:00', '2025-11-06 03:48:30', '2025-11-08 07:33:29', 'venue', 'yes', '24.3746', '149.91553', NULL, NULL, NULL, NULL, NULL),
(127, 23, '1762580461.png', '1', 'single', 1, '2028-10-08', '11:43', '5h 37m', '2028-10-08', '17:20', '2028-10-08 17:20:00', '2025-11-08 00:41:01', '2025-11-09 01:13:40', 'venue', 'yes', '24.3746', '149.91553', NULL, NULL, NULL, NULL, NULL),
(128, 23, '1762602276.png', '1', 'single', 1, '2028-01-01', '17:43', '3h 4m', '2028-01-01', '20:47', '2028-01-01 20:47:00', '2025-11-08 06:44:36', '2025-11-08 06:44:36', 'venue', 'yes', '24.3746', '149.91553', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `event_categories`
--

CREATE TABLE `event_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `language_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT '0',
  `serial_number` mediumint(9) NOT NULL,
  `is_featured` char(4) NOT NULL DEFAULT 'no',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event_categories`
--

INSERT INTO `event_categories` (`id`, `name`, `language_id`, `image`, `slug`, `status`, `serial_number`, `is_featured`, `created_at`, `updated_at`) VALUES
(22, 'Wedding', 8, '64562bfad4d11.png', 'wedding', 1, 1, 'yes', '2023-05-06 13:59:14', '2023-05-06 13:59:14'),
(23, 'قِرَان', 22, '64562c248f20b.png', 'قِرَان', 1, 1, 'yes', '2023-05-06 13:59:56', '2023-05-06 13:59:56'),
(24, 'Business', 8, '64562c6444649.png', 'business', 1, 2, 'yes', '2023-05-06 14:01:00', '2023-05-06 14:01:00'),
(25, 'عمل', 22, '64562c7e84a9b.png', 'عمل', 1, 2, 'yes', '2023-05-06 14:01:26', '2023-05-06 14:01:26'),
(26, 'Career', 8, '64562cf6593fc.png', 'career', 1, 3, 'yes', '2023-05-06 14:03:26', '2023-05-06 14:03:26'),
(27, 'حياة مهنية', 22, '64562d0d992b7.png', 'حياة-مهنية', 1, 3, 'yes', '2023-05-06 14:03:49', '2023-05-06 14:03:49'),
(28, 'Conference', 8, '64562d35c2a79.png', 'conference', 1, 4, 'yes', '2023-05-06 14:04:29', '2023-05-06 14:04:29'),
(29, 'مؤتمر', 22, '64562d4abe97c.png', 'مؤتمر', 1, 4, 'yes', '2023-05-06 14:04:50', '2023-05-06 14:04:50'),
(30, 'Sports', 8, '64562d5ae960a.png', 'sports', 1, 5, 'yes', '2023-05-06 14:05:06', '2023-05-06 14:05:06'),
(31, 'رياضات', 22, '64562d728513e.png', 'رياضات', 1, 5, 'yes', '2023-05-06 14:05:30', '2023-05-06 14:05:30'),
(32, 'Medical', 8, '68ecc2b5a5ecb.jpg', 'medical', 1, 6, 'no', '2025-10-13 05:13:25', '2025-10-13 05:14:14');

-- --------------------------------------------------------

--
-- Table structure for table `event_cities`
--

CREATE TABLE `event_cities` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) DEFAULT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_cities`
--

INSERT INTO `event_cities` (`id`, `language_id`, `country_id`, `state_id`, `name`, `slug`, `status`, `serial_number`, `created_at`, `updated_at`) VALUES
(14, 8, 1, 1, 'New York', 'new-york', '1', 1, '2025-08-11 03:57:59', '2025-08-11 03:58:23'),
(15, 8, 3, 2, 'London', 'london', '1', 2, '2025-08-11 03:58:46', '2025-08-11 03:58:46'),
(16, 8, 5, 3, 'Toronto', 'toronto', '1', 3, '2025-08-11 03:59:04', '2025-08-11 03:59:04'),
(17, 8, 7, 4, 'Sydney', 'sydney', '1', 4, '2025-08-11 03:59:17', '2025-08-11 03:59:17'),
(18, 8, 7, 4, 'Berlin', 'berlin', '1', 5, '2025-08-11 03:59:32', '2025-11-04 02:24:41'),
(19, 22, 10, 16, 'برلين', 'برلين', '1', 5, '2025-08-11 04:12:07', '2025-08-11 11:41:01'),
(20, 22, 8, 15, 'سيدني', 'سيدني', '1', 4, '2025-08-11 04:12:32', '2025-08-11 11:40:55'),
(21, 22, 6, 14, 'تورنتو', 'تورنتو', '1', 3, '2025-08-11 04:12:51', '2025-08-11 11:40:48'),
(22, 22, 4, 13, 'لندن', 'لندن', '1', 2, '2025-08-11 04:13:07', '2025-08-11 11:40:41'),
(23, 22, 2, 12, 'نيويورك', 'نيويورك', '1', 1, '2025-08-11 04:13:25', '2025-08-11 11:40:35');

-- --------------------------------------------------------

--
-- Table structure for table `event_contents`
--

CREATE TABLE `event_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` int(11) NOT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `city_id` bigint(20) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `event_category_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` longtext,
  `meta_keywords` text,
  `meta_description` longtext,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `address` text,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `google_calendar_id` varchar(255) DEFAULT NULL,
  `refund_policy` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event_contents`
--

INSERT INTO `event_contents` (`id`, `event_id`, `country_id`, `city_id`, `state_id`, `language_id`, `event_category_id`, `title`, `slug`, `description`, `meta_keywords`, `meta_description`, `created_at`, `updated_at`, `address`, `country`, `state`, `city`, `zip_code`, `google_calendar_id`, `refund_policy`) VALUES
(185, 91, 1, 14, 1, 8, 22, 'Decoration of the marriage', 'decoration-of-the-marriage', '<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.</p>\r\n<p> </p>\r\n<p>It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p>\r\n<p> </p>\r\n<p>It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p>', 'Decoration of the marriage table', 'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', '2023-05-06 08:22:41', '2025-08-11 04:19:36', '350 5th Avenue, New York, NY, USA', 'Australia', 'New South Wales', 'Nyora', '2646', '8vvq11n589d3tm1h4khtu444gg', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'),
(186, 91, 2, 23, 12, 22, 23, 'زخرفة طاولة الزواج', 'زخرفة-طاولة-الزواج', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ </p>\r\n<p style=\"text-align:right;\">علي الجانب الآخر نشجب ونستنكر هؤلاء الرجال المفتونون بنشوة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من أجل ألا يتحمل ما هو أسو</p>\r\n<div style=\"text-align: right;\"> </div>', NULL, NULL, '2023-05-06 08:22:43', '2025-08-11 04:19:36', '350 الجادة الخامسة، نيويورك، نيويورك، الولايات المتحدة الأمريكية', 'أستراليا', 'نيو ساوث ويلز', 'نيورا', '2646', NULL, 'وة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث'),
(187, 92, NULL, NULL, NULL, 8, 24, 'Small Business Ideas', 'small-business-ideas', '<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.</p><p><br /></p><p>It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p><p><br /></p><p>It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p>', 'Small Business Ideas', 'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', '2023-05-06 05:02:59', '2023-05-09 04:53:26', NULL, NULL, NULL, NULL, NULL, 'ogqtgnqusgdmifjjf7gs4rvt3o', 'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.'),
(188, 92, NULL, NULL, NULL, 22, 25, 'أفكار الأعمال الصغيرة', 'أفكار-الأعمال-الصغيرة', '<p><br /></p><p>و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ </p><p>علي الجانب الآخر نشجب ونستنكر هؤلاء الرجال المفتونون بنشوة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من أجل ألا يتحمل ما هو أسو</p>', NULL, NULL, '2023-05-06 05:03:00', '2023-05-09 04:55:12', NULL, NULL, NULL, NULL, NULL, NULL, 'رونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من'),
(189, 93, 7, 17, 4, 8, 26, 'Design Research by Australia', 'design-research-by-australia', '<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.</p>\r\n<p> </p>\r\n<p>It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p>\r\n<p> </p>\r\n<p>It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p>', NULL, NULL, '2023-05-06 05:16:48', '2025-08-12 05:29:46', 'Sydney Opera House', 'Brisbane', 'New South Wales', 'Brisbane', '4036', '3ojcpokjeshfgset5a2nemt05o', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'),
(190, 93, 8, 20, 15, 22, 27, 'تصميم البحوث من قبل UX أستراليا', 'تصميم-البحوث-من-قبل-ux-أستراليا', '<p style=\"text-align:right;\">و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ </p>\r\n<p style=\"text-align:right;\">علي الجانب الآخر نشجب ونستنكر هؤلاء الرجال المفتونون بنشوة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من أجل ألا يتحمل ما هو أسو</p>', NULL, NULL, '2023-05-06 05:16:50', '2025-08-12 05:29:46', 'دار الأوبرا في سيدني', 'بريسبين', 'نيو ساوث ويلز', 'بريسبين', '4036', NULL, 'و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟'),
(191, 94, 9, 18, 5, 8, 28, 'Journalist Conference', 'journalist-conference', '<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.</p>\r\n<p> </p>\r\n<p>It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p>\r\n<p> </p>\r\n<p>It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p>', NULL, NULL, '2023-05-06 05:28:41', '2025-08-11 04:18:04', 'Checkpoint Charlie, Friedrichstraße, Berlin, Germany', 'Australia', 'New South Wales', 'Sydney', '5309', 'p25r2b6819t32l060amhdrovms', 'Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.'),
(192, 94, 10, 19, 16, 22, 29, 'مؤتمر الصحفيين', 'مؤتمر-الصحفيين', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ </p>\r\n<p style=\"text-align:right;\">علي الجانب الآخر نشجب ونستنكر هؤلاء الرجال المفتونون بنشوة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من أجل ألا يتحمل ما هو أسو</p>', NULL, NULL, '2023-05-06 05:28:43', '2025-08-11 04:18:04', 'نقطة تفتيش تشارلي، شارع فريدريش، برلين، ألمانيا', 'أستراليا', 'نيو ساوث ويلز', 'سيدني', '5309', NULL, 'هذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ \r\n\r\nعلي الجانب'),
(198, 100, 7, 17, 4, 8, 30, 'Player draft 2023', 'player-draft-2023', '<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry\'s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged.</p>\r\n<p> </p>\r\n<p>It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.</p>\r\n<p> </p>\r\n<p>It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using \'Content here, content here\', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for \'lorem ipsum\' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).</p>', NULL, NULL, '2023-05-06 05:44:06', '2025-08-12 05:29:22', 'Sydney Harbour Bridge', 'United States', 'New Jersey', 'Lumberton', '8048', 'hqiirkgt7bv7csbqatlbra59uo', 'It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.'),
(199, 100, 8, 20, 15, 22, 31, 'مسودة اللاعب 2023', 'مسودة-اللاعب-2023', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">و سأعرض مثال حي لهذا، من منا لم يتحمل جهد بدني شاق إلا من أجل الحصول على ميزة أو فائدة؟ ولكن من لديه الحق أن ينتقد شخص ما أراد أن يشعر بالسعادة التي لا تشوبها عواقب أليمة أو آخر أراد أن يتجنب الألم الذي ربما تنجم عنه بعض المتعة ؟ </p>\r\n<p style=\"text-align:right;\">علي الجانب الآخر نشجب ونستنكر هؤلاء الرجال المفتونون بنشوة اللحظة الهائمون في رغباتهم فلا يدركون ما يعقبها من الألم والأسي المحتم، واللوم كذلك يشمل هؤلاء الذين أخفقوا في واجباتهم نتيجة لضعف إرادتهم فيتساوي مع هؤلاء الذين يتجنبون وينأون عن تحمل الكدح والألم . من المفترض أن نفرق بين هذه الحالات بكل سهولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات التي يفرضها علينا الواجب والعمل سنتنازل غالباً ونرفض الشعور بالسرور ونقبل ما يجلبه إلينا الأسى. الإنسان الحكيم عليه أن يمسك زمام الأمور ويختار إما أن يرفض مصادر السعادة من أجل ما هو أكثر أهمية أو يتحمل الألم من أجل ألا يتحمل ما هو أسو</p>', NULL, NULL, '2023-05-06 05:44:07', '2025-08-12 05:29:22', 'جسر ميناء سيدني', 'الولايات المتحدة الأمريكية', 'نيو جيرسي', 'لومبيرتون', '8048', NULL, 'هولة ومرونة. في ذاك الوقت عندما تكون قدرتنا علي الاختيار غير مقيدة بشرط وعندما لا نجد ما يمنعنا أن نفعل الأفضل فها نحن نرحب بالسرور والسعادة ونتجنب كل ما يبعث إلينا الألم. في بعض الأحيان ونظراً للالتزامات الت'),
(200, 101, NULL, NULL, NULL, 8, 24, 'Motivation for online business', 'motivation-for-online-business', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-06 23:12:20', '2023-05-06 23:12:22', NULL, NULL, NULL, NULL, NULL, '71ffc2p5vluqai7d77a6dna6dg', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.'),
(201, 101, NULL, NULL, NULL, 22, 25, 'الدافع للأعمال التجارية عبر الإنترنت', 'الدافع-للأعمال-التجارية-عبر-الإنترنت', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p><div><br /></div>', NULL, NULL, '2023-05-06 23:12:22', '2023-05-06 23:12:22', NULL, NULL, NULL, NULL, NULL, NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.'),
(202, 102, 3, 15, 2, 8, 30, 'Sports grand opening', 'sports-grand-opening', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-06 23:38:11', '2025-08-11 04:16:22', 'Tower of London, London, UK', 'United States', 'Maine', 'Wayland', '01778', '023uknnecjqbvip96rob11oaf8', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.'),
(203, 102, 4, 22, 13, 22, 31, 'حفل الافتتاح الرياضي الكبير', 'حفل-الافتتاح-الرياضي-الكبير', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-06 23:38:13', '2025-08-11 04:16:22', 'برج لندن، لندن، المملكة المتحدة', 'الولايات المتحدة الأمريكية', 'مين', 'وايلاند', '01778', NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.'),
(204, 103, 5, 16, 3, 8, 22, 'Grand night party', 'grand-night-party', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>\r\n<div> </div>', NULL, NULL, '2023-05-06 23:55:18', '2025-08-11 04:15:25', '454 Isaac Frye Hwy, Wilton, NH, United States', '4', '7', '3', '03086', 'qdu28ucktt4bjkkhllfdjo1adk', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.'),
(205, 103, 6, 21, 14, 22, 23, 'حفلة ليلية كبيرة', 'حفلة-ليلية-كبيرة', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-06 23:55:19', '2025-08-11 04:15:25', '454 طريق إسحاق فراي السريع، ويلتون، نيو هامبشاير، الولايات المتحدة', '13', '10', '6', '03086', NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.'),
(206, 104, NULL, NULL, NULL, 8, 28, 'The conference planners', 'the-conference-planners', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 00:06:49', '2024-08-26 22:43:14', NULL, NULL, NULL, NULL, NULL, 'l76lbrqm82v3p8ubdefqp1l1ks', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.'),
(207, 104, NULL, NULL, NULL, 22, 29, 'معرض مخططي المؤتمرات', 'معرض-مخططي-المؤتمرات', '<p style=\"text-align:right;\">وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 00:06:50', '2024-08-26 22:43:14', NULL, NULL, NULL, NULL, NULL, NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.'),
(208, 105, 1, 14, 1, 8, 28, 'Designer carrier conference', 'designer-carrier-conference', '<p><em><strong>Lorem ipsum</strong> <strong>i</strong></em>s a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also <strong>called </strong>placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 00:19:06', '2025-10-29 08:11:06', 'Brandenburg Gate, Pariser Platz, Berlin, Germany', '5', '11', NULL, '05350', 'uj9er7k93qnktt57ocg18q8q54', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.'),
(209, 105, 2, 23, 12, 22, 29, 'مؤتمر الناقل المصمم', 'مؤتمر-الناقل-المصمم', '<p style=\"text-align:right;\">وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>\r\n<div style=\"text-align: right;\"> </div>', NULL, NULL, '2023-05-07 00:19:07', '2025-08-11 11:11:30', 'بوابة براندنبورغ، باريسر بلاتز، برلين، ألمانيا', '2', '12', '23', '05350', NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.'),
(210, 116, NULL, NULL, NULL, 8, 22, 'Multiple Dates Event', 'multiple-dates-event', '<p>Lorem ipsum, dolor sit amet consectetur adipisicing elit. Optio delectus facilis quasi repudiandae. Quo tempore modi ea est pariatur, optio eos voluptates esse neque. Minima dolorum ut aliquam sint nostrum?</p>', NULL, NULL, '2023-09-24 08:13:36', '2023-09-24 08:13:36', NULL, NULL, NULL, NULL, NULL, NULL, 'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Optio delectus facilis quasi repudiandae. Quo tempore modi ea est pariatur, optio eos voluptates esse neque. Minima dolorum ut aliquam sint nostrum?'),
(211, 116, NULL, NULL, NULL, 22, 23, 'Multiple date check', 'multiple-date-check', '<p style=\"text-align:right;\">Lorem ipsum, dolor sit amet consectetur adipisicing elit. Optio delectus facilis quasi repudiandae. Quo tempore modi ea est pariatur, optio eos voluptates esse neque. Minima dolorum ut aliquam sint nostrum?Lorem ipsum, dolor sit amet consectetur adipisicing elit. Optio delectus facilis quasi repudiandae. Quo tempore modi ea est pariatur, optio eos voluptates esse neque. Minima dolorum ut aliquam sint nostrum?</p>', NULL, NULL, '2023-09-24 08:13:36', '2023-09-24 08:13:36', NULL, NULL, NULL, NULL, NULL, NULL, 'Lorem ipsum, dolor sit amet consectetur adipisicing elit. Optio delectus facilis quasi repudiandae. Quo tempore modi ea est pariatur, optio eos voluptates esse neque. Minima dolorum ut aliquam sint nostrum?'),
(230, 126, 1, 14, 1, 8, 30, 'Betsson Peruvian Volleyball', 'betsson-peruvian-volleyball', '<p>The 2025-2026 Peruvian Women\'s Volleyball League will be the twenty-fourth edition of the country\'s premier women\'s volleyball competition and the second under its new name. Organized by the Peruvian Volleyball Federation (FPV), this season reaffirms the institution\'s commitment to strengthening and developing national volleyball, promoting sporting excellence and fostering a passion for the sport throughout Peru.</p>\r\n<p>For the fourth consecutive year, the tournament will bring together twelve professional teams who will compete with dedication, discipline, and sportsmanship for the national title. The winning club will qualify for the 2027 South American Women\'s Volleyball Club Championship, taking Peru\'s name to the international stage.</p>\r\n<p>The Peruvian Women\'s Volleyball League 2025-2026 is much more than a tournament: it is the reflection of the joint effort of clubs, players, coaches and fans who, with passion and commitment, continue to demonstrate that:  <em>Together, we make Peruvian volleyball great!</em></p>', NULL, NULL, '2025-11-06 03:48:31', '2025-11-08 07:29:29', 'Malibu, California , USA', NULL, NULL, NULL, '19261', NULL, NULL),
(231, 126, 10, 19, 16, 22, 31, 'دوري بيتسون البيروفي للكرة الطائرة', 'دوري-بيتسون-البيروفي-للكرة-الطائرة', '<p style=\"text-align:right;\">سيكون دوري الكرة الطائرة النسائي البيروفي لموسم 2025-2026 النسخة الرابعة والعشرين من أبرز بطولات الكرة الطائرة النسائية في البلاد، والثانية تحت مسمى جديد. يُنظم هذا الموسم الاتحاد البيروفي للكرة الطائرة (FPV)، ويؤكد التزام المؤسسة بتعزيز وتطوير الكرة الطائرة الوطنية، وتعزيز التميز الرياضي، وغرس الشغف بهذه الرياضة في جميع أنحاء بيرو.</p>\r\n<p style=\"text-align:right;\">للعام الرابع على التوالي، ستجمع البطولة اثني عشر فريقًا محترفًا سيتنافسون بتفانٍ وانضباط وروح رياضية عالية للفوز باللقب الوطني. سيتأهل النادي الفائز إلى بطولة أمريكا الجنوبية لأندية الكرة الطائرة النسائية لعام 2027، رافعين اسم بيرو إلى الساحة الدولية.</p>\r\n<p style=\"text-align:right;\">دوري الكرة الطائرة النسائي البيروفي لموسم 2025-2026 هو أكثر من مجرد بطولة: إنه انعكاس للجهد المشترك للأندية واللاعبات والمدربين والمشجعين الذين يواصلون، بشغف والتزام، إثبات أننا: معًا، نجعل الكرة الطائرة البيروفية عظيمة!</p>', NULL, NULL, '2025-11-06 03:48:31', '2025-11-08 07:29:29', 'الولايات المتحدة الأمريكية', NULL, NULL, NULL, '90853', NULL, NULL),
(232, 127, 1, 14, 1, 8, 24, 'Peter pan up to his leg', 'peter-pan-up-to-his-leg', '<p>* Recommended for ages 14 and up accompanied by an adult.<br /><br />This version of Peter Pan promises to be a guaranteed disaster! </p>\r\n<p>In “Peter Pan Up to His Legs,” a group of enthusiastic performers have the challenging mission of bringing the classic story of the boy who doesn\'t want to grow up to the stage. </p>\r\n<p>We\'ll see how a play within a play can have technical earthquakes, outlandish attitudes, and thousands of conflicts within the cast… in other words, everything that can go wrong, goes worse than you can imagine!</p>\r\n<p>Will they manage to reach Neverland unscathed? We don\'t know, but one thing is for sure: it will be a journey full of unexpected events and lots of laughs! </p>\r\n<p>This show is a unique opportunity to witness how a play as well-known as PETER PAN can really go UP TO HIS LEG. Between laughs, disasters, and unforgettable moments, you\'ll experience a night that will make you feel like you\'ve lived your own adventure in Neverland</p>', NULL, NULL, '2025-11-08 00:41:02', '2025-11-09 01:13:40', 'Los Angeles, California', NULL, NULL, NULL, NULL, NULL, NULL),
(233, 127, 8, 20, 15, 22, 31, 'بيتر بان هو الساق.', 'بيتر-بان-هو-الساق.', '<p style=\"text-align:right;\">* يُنصح به لمن يبلغون من العمر ١٤ عامًا فما فوق برفقة شخص بالغ.</p>\r\n<p style=\"text-align:right;\">هذه النسخة من بيتر بان واعدة بكارثة حتمية!</p>\r\n<p style=\"text-align:right;\">في عرض \"بيتر بان حتى ساقيه\"، تتولى مجموعة من الممثلين المتحمسين مهمة صعبة تتمثل في تقديم القصة الكلاسيكية للصبي الذي لا يريد أن يكبر على خشبة المسرح.</p>\r\n<p style=\"text-align:right;\">سنرى كيف يمكن لمسرحية داخل مسرحية أن تشهد زلازل فنية، ومواقف غريبة، وآلاف الصراعات بين الممثلين... بمعنى آخر، كل ما يمكن أن يحدث خطأ، أسوأ مما تتخيل!</p>\r\n<p style=\"text-align:right;\">هل سيتمكنون من الوصول إلى نيفرلاند سالمين؟ لا نعلم، لكن هناك شيء واحد مؤكد: ستكون رحلة مليئة بالأحداث غير المتوقعة والكثير من الضحك!</p>\r\n<p style=\"text-align:right;\">هذا العرض فرصة فريدة لمشاهدة كيف يمكن لمسرحية مشهورة مثل بيتر بان أن تصل إلى ساقيه. بين الضحكات والكوارث واللحظات التي لا تُنسى، ستعيش ليلة تجعلك تشعر وكأنك عشت مغامرتك الخاصة في نيفرلاند.</p>', NULL, NULL, '2025-11-08 00:41:02', '2025-11-09 01:13:40', 'لوس أنجلوس، كاليفورنيا', NULL, NULL, NULL, '1', NULL, NULL),
(234, 128, 1, 14, 1, 8, 28, 'Tech & Innovation Expo', 'tech-&-innovation-expo', '<p><em><strong>Lorem ipsum</strong> <strong>i</strong></em>s a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also <strong>called </strong>placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2025-11-08 06:44:36', '2025-11-08 06:44:36', 'California, Western United States.', NULL, NULL, NULL, NULL, NULL, NULL),
(235, 128, 2, 23, 12, 22, 29, 'معرض التكنولوجيا والابتكار', 'معرض-التكنولوجيا-والابتكار', '<p>لوريم إيبسوم هو نص شبه لاتيني يُستخدم في تصميم الويب والطباعة والتخطيط والطباعة بدلاً من اللغة الإنجليزية للتأكيد على عناصر التصميم على حساب المحتوى. ويُسمى أيضًا نصًا نائبًا (أو نصًا حشوًا). وهو أداة ملائمة للنماذج الأولية. يساعد في تحديد العناصر المرئية للمستند أو العرض التقديمي، مثل الطباعة أو الخط أو التخطيط.</p>\r\n<p>لوريم إيبسوم هو في الغالب جزء من نص لاتيني للمؤلف والفيلسوف الكلاسيكي شيشرون. وقد تم تغيير كلماته وحروفه عن طريق الإضافة أو الإزالة،</p>\r\n<p>لجعل محتواه غير منطقي عمدًا؛ لم يعد لاتينيًا أصليًا أو صحيحًا أو مفهومًا.</p>\r\n<p>في حين أن لوريم إيبسوم لا يزال يشبه اللاتينية الكلاسيكية، إلا أنه في الواقع ليس له أي معنى على الإطلاق. وبما أن نص شيشرون لا يحتوي على الحروف K أو W أو Z، وهي غريبة عن اللاتينية، فإن هذه الحروف وغيرها غالبًا ما تُدرج عشوائيًا لتقليد المظهر المطبعي للغات الأوروبية، كما هو الحال مع الحروف الثنائية التي لا توجد في النص الأصلي.</p>', NULL, NULL, '2025-11-08 06:44:36', '2025-11-08 06:44:36', 'كاليفورنيا', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `event_countries`
--

CREATE TABLE `event_countries` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `unquid` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_countries`
--

INSERT INTO `event_countries` (`id`, `language_id`, `name`, `slug`, `status`, `serial_number`, `unquid`, `created_at`, `updated_at`) VALUES
(1, '8', 'USA', 'usa', '1', 1, NULL, '2025-08-11 03:33:39', '2025-08-11 03:33:39'),
(2, '22', 'الولايات المتحدة الأمريكية', 'الولايات-المتحدة-الأمريكية', '1', 1, NULL, '2025-08-11 03:33:51', '2025-08-11 11:37:09'),
(3, '8', 'UK', 'uk', '1', 2, NULL, '2025-08-11 03:34:02', '2025-08-11 03:34:02'),
(4, '22', 'المملكة المتحدة', 'المملكة-المتحدة', '1', 2, NULL, '2025-08-11 03:34:09', '2025-08-11 11:36:59'),
(5, '8', 'Canada', 'canada', '1', 3, NULL, '2025-08-11 03:34:21', '2025-08-11 03:34:21'),
(6, '22', 'كندا', 'كندا', '1', 3, NULL, '2025-08-11 03:34:28', '2025-08-11 11:36:51'),
(7, '8', 'Australia', 'australia', '1', 4, NULL, '2025-08-11 03:34:38', '2025-08-11 03:34:38'),
(8, '22', 'أستراليا', 'أستراليا', '1', 4, NULL, '2025-08-11 03:34:48', '2025-08-11 11:36:45'),
(9, '8', 'Germany', 'germany', '1', 5, NULL, '2025-08-11 03:34:59', '2025-08-11 03:34:59'),
(10, '22', 'ألمانيا', 'ألمانيا', '1', 5, NULL, '2025-08-11 03:35:06', '2025-08-11 11:36:37');

-- --------------------------------------------------------

--
-- Table structure for table `event_dates`
--

CREATE TABLE `event_dates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) DEFAULT NULL,
  `start_date` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_date` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `duration` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `start_date_time` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `end_date_time` datetime DEFAULT CURRENT_TIMESTAMP,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_dates`
--

INSERT INTO `event_dates` (`id`, `event_id`, `start_date`, `start_time`, `end_date`, `end_time`, `duration`, `start_date_time`, `end_date_time`, `created_at`, `updated_at`) VALUES
(16, 64, '2023-03-27', '14:59', '2023-03-28', '14:59', '1d ', '2023-03-27 14:59:00', '2023-03-28 14:59:00', '2023-03-27 08:59:45', '2023-04-30 06:05:39'),
(17, 64, '2023-03-30', '14:01', '2023-03-31', '14:59', '1d 58m', '2023-03-30 14:01:00', '2023-03-31 14:59:00', '2023-03-27 08:59:45', '2023-04-30 06:05:39'),
(18, 64, '2023-04-03', '14:01', '2023-04-06', '14:00', '2d 23h 59m', '2023-04-03 14:01:00', '2023-04-06 14:00:00', '2023-03-27 08:59:45', '2023-04-30 06:05:39'),
(19, 65, '2023-03-30', '11:39', '2023-03-31', '11:40', '1d 1m', '2023-03-30 11:39:00', '2023-03-31 11:40:00', '2023-03-28 05:41:51', '2023-04-30 11:30:28'),
(20, 65, '2023-04-01', '11:40', '2023-04-02', '01:40', '14h ', '2023-04-01 11:40:00', '2023-04-02 01:40:00', '2023-03-28 05:41:51', '2023-04-30 11:30:28'),
(23, 65, '2023-04-30', '17:32', '2023-05-30', '17:32', '1mo 30d ', '2023-04-30 17:32:00', '2023-05-30 17:32:00', '2023-04-30 11:30:28', '2023-04-30 11:30:28'),
(24, 67, '2023-05-01', '11:51', '2023-05-10', '11:52', '9d 1m', '2023-05-01 11:51:00', '2023-05-10 11:52:00', '2023-05-01 05:53:43', '2023-05-01 15:20:47'),
(25, 67, '2023-05-11', '23:52', '2023-05-22', '11:53', '10d 12h 1m', '2023-05-11 23:52:00', '2023-05-22 11:53:00', '2023-05-01 05:53:43', '2023-05-01 15:20:47'),
(26, 69, '2023-05-01', '12:22', '2023-05-10', '13:22', '9d 1h ', '2023-05-01 12:22:00', '2023-05-10 13:22:00', '2023-05-01 06:24:39', '2023-05-01 15:19:33'),
(27, 69, '2023-05-12', '12:26', '2023-05-22', '17:22', '10d 4h 56m', '2023-05-12 12:26:00', '2023-05-22 17:22:00', '2023-05-01 06:24:39', '2023-05-01 15:19:33'),
(36, 94, '2025-01-18', '17:30', '2025-01-20', '20:30', '2d 3h ', '2025-01-18 17:30:00', '2025-01-20 20:30:00', '2023-05-06 11:28:41', '2025-08-11 04:18:04'),
(49, 112, '2023-05-09', '17:09', '2023-06-03', '17:09', '25d ', '2023-05-09 17:09:00', '2023-06-03 17:09:00', '2023-05-08 11:12:59', '2023-05-08 11:12:59'),
(50, 112, '2023-05-10', '17:10', '2024-05-23', '17:11', '1y 379d 1m', '2023-05-10 17:10:00', '2024-05-23 17:11:00', '2023-05-08 11:12:59', '2023-05-08 11:12:59'),
(55, 104, '2026-01-02', '11:33', '2030-08-27', '11:31', '4y 7mo 1697d 23h 58m', '2026-01-02 11:33:00', '2030-08-27 11:31:00', '2023-05-15 05:29:01', '2025-11-10 08:02:27'),
(57, 116, '2023-09-22', '03:11', '2023-09-23', '14:30', '1d 11h 19m', '2023-09-22 03:11:00', '2023-09-23 14:30:00', '2023-09-24 08:13:35', '2024-08-24 21:55:02'),
(58, 116, '2023-09-26', '14:15', '2023-09-27', '14:16', '1d 1m', '2023-09-26 14:15:00', '2023-09-27 14:16:00', '2023-09-24 08:13:35', '2024-08-24 21:55:02');

-- --------------------------------------------------------

--
-- Table structure for table `event_features`
--

CREATE TABLE `event_features` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event_features`
--

INSERT INTO `event_features` (`id`, `language_id`, `icon`, `title`, `text`, `serial_number`, `created_at`, `updated_at`) VALUES
(4, 8, 'fas fa-globe', 'Online Events', 'While lorem ipsum\'s still resembles classical Latin, it has no meaning whatsoever.', 1, '2022-06-07 00:14:56', '2023-05-11 05:25:09'),
(6, 8, 'fas fa-map-marked', 'Venue Events', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing.', 2, '2022-06-07 00:16:30', '2023-05-11 05:24:27'),
(9, 22, 'fas fa-map-marked', 'فعاليات المكان', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في', 2, '2023-05-07 11:43:28', '2023-05-11 05:36:43'),
(10, 22, 'fas fa-globe', 'الأحداث عبر الإنترنت', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في', 1, '2023-05-07 11:44:03', '2023-05-11 05:36:13'),
(11, 8, 'fas fa-ticket-alt', 'Ticket Variations', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing', 3, '2023-05-07 11:48:45', '2023-05-11 05:24:02'),
(12, 8, 'fas fa-qrcode', 'PWA Ticket Scanner', 'Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero.', 5, '2023-05-07 11:51:56', '2023-05-11 05:29:09'),
(13, 8, 'fas fa-headset', 'Support Tickets', 'Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero.', 6, '2023-05-07 11:54:11', '2023-05-11 05:28:52'),
(14, 22, 'fas fa-ticket-alt', 'تنويعات التذاكر', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في', 3, '2023-05-07 11:57:09', '2023-05-11 05:36:27'),
(15, 22, 'fas fa-qrcode', 'بوا الماسح الضوئي للتذاكر', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار', 5, '2023-05-07 11:59:33', '2023-05-11 05:35:58'),
(16, 22, 'fas fa-headset', 'تذاكر الدعم الفني', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين تفاء بال كل وبغطاء الثقي', 6, '2023-05-07 12:00:11', '2023-05-11 05:35:32'),
(17, 8, 'fas fa-hand-holding-usd', 'Low Commission Rate', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Praesentium vero eligendi nihil.', 4, '2023-05-11 05:27:00', '2023-05-11 05:29:00'),
(18, 22, 'fas fa-hand-holding-usd', 'معدل عمولة منخفض', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في', 4, '2023-05-11 05:31:02', '2023-05-11 05:31:20');

-- --------------------------------------------------------

--
-- Table structure for table `event_feature_sections`
--

CREATE TABLE `event_feature_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event_feature_sections`
--

INSERT INTO `event_feature_sections` (`id`, `language_id`, `title`, `text`, `created_at`, `updated_at`) VALUES
(1, 8, 'Evento Features', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt', '2022-06-06 23:24:33', '2023-05-11 05:38:44'),
(2, 9, 'test arabic sdf', 'text arabic fdsa', '2022-06-06 23:25:08', '2022-06-06 23:25:16'),
(3, 17, 'ميزة الأحداث الرائعة', 'صفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام', '2023-01-31 05:48:01', '2023-01-31 05:48:01'),
(4, 22, 'ميزات إيفينتو', 'ل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سق', '2023-05-07 11:41:58', '2023-05-11 05:38:35');

-- --------------------------------------------------------

--
-- Table structure for table `event_images`
--

CREATE TABLE `event_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` int(11) DEFAULT NULL,
  `image` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `event_images`
--

INSERT INTO `event_images` (`id`, `event_id`, `image`, `created_at`, `updated_at`) VALUES
(9, NULL, '62b98c589565d.jpg', '2022-06-27 04:54:16', '2022-06-27 04:54:16'),
(10, NULL, '62b98c589565a.jpg', '2022-06-27 04:54:16', '2022-06-27 04:54:16'),
(11, NULL, '62b98c58c13ab.jpg', '2022-06-27 04:54:16', '2022-06-27 04:54:16'),
(12, NULL, '62b98c58c634d.jpg', '2022-06-27 04:54:16', '2022-06-27 04:54:16'),
(13, NULL, '62b98c5900f81.jpg', '2022-06-27 04:54:17', '2022-06-27 04:54:17'),
(14, NULL, '62b98c59019ad.jpg', '2022-06-27 04:54:17', '2022-06-27 04:54:17'),
(15, NULL, '62b98c5928677.jpg', '2022-06-27 04:54:17', '2022-06-27 04:54:17'),
(16, NULL, '62b98c592ec8f.jpg', '2022-06-27 04:54:17', '2022-06-27 04:54:17'),
(17, NULL, '62b98c594e479.jpg', '2022-06-27 04:54:17', '2022-06-27 04:54:17'),
(23, 12, '62db792a6c818.jpg', '2022-07-22 22:29:30', '2022-07-22 22:32:20'),
(24, 12, '62db792a6c7f1.jpg', '2022-07-22 22:29:30', '2022-07-22 22:32:20'),
(25, 13, '62db7a63df567.jpg', '2022-07-22 22:34:43', '2022-07-22 22:37:47'),
(26, 13, '62db7a63df622.jpg', '2022-07-22 22:34:43', '2022-07-22 22:37:47'),
(27, 13, '62db7a64130ce.jpg', '2022-07-22 22:34:44', '2022-07-22 22:37:47'),
(28, 14, '62db7eb7a2b9d.jpg', '2022-07-22 22:53:11', '2022-07-22 22:55:03'),
(29, 14, '62db7eb7a4c84.jpg', '2022-07-22 22:53:11', '2022-07-22 22:55:03'),
(30, 14, '62db7eb7cf18c.jpg', '2022-07-22 22:53:11', '2022-07-22 22:55:03'),
(46, NULL, '63b26d14b0745.jpg', '2023-01-02 05:35:16', '2023-01-02 05:35:16'),
(50, NULL, '63b417430d8bb.jpg', '2023-01-03 11:53:39', '2023-01-03 11:53:39'),
(51, NULL, '63b417df970ab.jpg', '2023-01-03 11:56:15', '2023-01-03 11:56:15'),
(57, NULL, '63b66899aeb4e.jpg', '2023-01-05 06:05:13', '2023-01-05 06:05:13'),
(119, NULL, '63d24331e3b98.jpg', '2023-01-26 09:09:05', '2023-01-26 09:09:05'),
(120, NULL, '63d24331e6257.jpg', '2023-01-26 09:09:05', '2023-01-26 09:09:05'),
(203, 91, '64562e23ab99c.jpg', '2023-05-06 14:08:27', '2023-05-06 14:22:40'),
(207, 91, '64562f7d9e74d.jpg', '2023-05-06 14:14:13', '2023-05-06 14:22:40'),
(208, 92, '645633de40711.jpg', '2023-05-06 11:02:54', '2023-05-06 11:02:58'),
(209, 92, '645633de49ac7.jpg', '2023-05-06 11:02:54', '2023-05-06 11:02:58'),
(210, NULL, '6456350644d9b.jpg', '2023-05-06 11:07:50', '2023-05-06 11:07:50'),
(211, NULL, '6456350644d9b.jpg', '2023-05-06 11:07:50', '2023-05-06 11:07:50'),
(212, 93, '6456373e07af7.jpg', '2023-05-06 11:17:18', '2023-05-06 11:17:18'),
(213, 93, '6456373e0773c.jpg', '2023-05-06 11:17:18', '2023-05-06 11:17:18'),
(214, 94, '6456383260d19.jpg', '2023-05-06 11:21:22', '2023-05-06 11:28:41'),
(215, 94, '645638326a025.jpg', '2023-05-06 11:21:22', '2023-05-06 11:28:41'),
(218, 100, '64563d3e17ff1.jpg', '2023-05-06 11:42:54', '2023-05-06 11:44:06'),
(219, 100, '64563d3e22c9c.jpg', '2023-05-06 11:42:54', '2023-05-06 11:44:06'),
(220, 101, '6457323560d56.jpg', '2023-05-07 05:08:05', '2023-05-07 05:12:19'),
(221, 101, '6457323560d47.jpg', '2023-05-07 05:08:05', '2023-05-07 05:12:19'),
(222, 102, '6457355173455.jpg', '2023-05-07 05:21:21', '2023-05-07 05:38:10'),
(223, 102, '6457355174ef6.jpg', '2023-05-07 05:21:21', '2023-05-07 05:38:10'),
(224, 103, '64573bd0cfc99.jpg', '2023-05-07 05:49:04', '2023-05-07 05:55:18'),
(225, 103, '64573bd0d06a9.jpg', '2023-05-07 05:49:04', '2023-05-07 05:55:18'),
(228, 104, '64573f1f4820c.jpg', '2023-05-07 06:03:11', '2023-05-07 06:06:49'),
(229, 104, '64573f1f52382.jpg', '2023-05-07 06:03:11', '2023-05-07 06:06:49'),
(230, 105, '6457429c32842.jpg', '2023-05-07 06:18:04', '2023-05-07 06:19:06'),
(231, 105, '6457429c3a965.jpg', '2023-05-07 06:18:04', '2023-05-07 06:19:06'),
(241, 116, '650fef61f0884.jpg', '2023-09-24 08:12:17', '2023-09-24 08:13:35'),
(242, 116, '650fef61f0875.jpg', '2023-09-24 08:12:17', '2023-09-24 08:13:35'),
(243, 116, '650fef62301e7.jpg', '2023-09-24 08:12:18', '2023-09-24 08:13:35'),
(244, 116, '650fef62301ee.jpg', '2023-09-24 08:12:18', '2023-09-24 08:13:35'),
(252, NULL, '68981fcfc6f9b.jpg', '2025-08-09 22:27:59', '2025-08-09 22:27:59'),
(257, NULL, '68e0c34cea7ec.jpg', '2025-10-04 00:48:44', '2025-10-04 00:48:44'),
(259, NULL, '68e0cb18d9019.jpg', '2025-10-04 01:22:00', '2025-10-04 01:22:00'),
(260, NULL, '690730714c408.jpg', '2025-11-02 05:20:33', '2025-11-02 05:20:33'),
(262, 126, '690c5f3fa76cf.jpg', '2025-11-06 03:41:35', '2025-11-06 03:48:30'),
(263, 126, '690c5f465f5e0.jpg', '2025-11-06 03:41:42', '2025-11-06 03:48:30'),
(264, 126, '690c5f4b15d74.jpg', '2025-11-06 03:41:47', '2025-11-06 03:48:30'),
(265, 127, '690ed26ccc711.jpg', '2025-11-08 00:17:32', '2025-11-08 00:41:01'),
(266, 127, '690ed26f2ec1c.jpg', '2025-11-08 00:17:35', '2025-11-08 00:41:01'),
(267, 127, '690ed271bbc5a.jpg', '2025-11-08 00:17:37', '2025-11-08 00:41:01'),
(268, 128, '690f2a7ddfa66.jpg', '2025-11-08 06:33:17', '2025-11-08 06:44:36'),
(269, 128, '690f2a8023598.jpg', '2025-11-08 06:33:20', '2025-11-08 06:44:36'),
(270, 128, '690f2a8293d85.jpg', '2025-11-08 06:33:22', '2025-11-08 06:44:36');

-- --------------------------------------------------------

--
-- Table structure for table `event_states`
--

CREATE TABLE `event_states` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) DEFAULT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slug` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `event_states`
--

INSERT INTO `event_states` (`id`, `language_id`, `country_id`, `name`, `slug`, `status`, `serial_number`, `created_at`, `updated_at`) VALUES
(1, 8, 1, 'New York', 'new-york', '1', 1, '2025-08-11 03:36:38', '2025-08-11 11:39:42'),
(2, 8, 3, 'Greater London', 'greater-london', '1', 2, '2025-08-11 03:36:57', '2025-08-11 03:36:57'),
(3, 8, 5, 'Ontario', 'ontario', '1', 3, '2025-08-11 03:37:09', '2025-08-11 03:37:09'),
(4, 8, 7, 'New South Wales', 'new-south-wales', '1', 4, '2025-08-11 03:37:26', '2025-08-11 03:37:26'),
(5, 8, 9, 'Berlin', 'berlin', '1', 5, '2025-08-11 03:37:45', '2025-08-11 03:37:45'),
(6, 8, 9, 'Bavaria', 'bavaria', '1', 6, '2025-08-11 04:00:28', '2025-08-11 04:00:28'),
(7, 8, 9, 'Hamburg', 'hamburg', '1', 7, '2025-08-11 04:00:40', '2025-08-11 04:00:40'),
(8, 8, 3, 'Scotland', 'scotland', '1', 8, '2025-08-11 04:01:02', '2025-08-11 04:01:02'),
(9, 8, 1, 'Texas', 'texas', '1', 9, '2025-08-11 04:01:25', '2025-08-11 04:01:25'),
(10, 8, 5, 'Nova Scotia', 'nova-scotia', '1', 10, '2025-08-11 04:01:50', '2025-08-11 04:01:50'),
(11, 8, 5, 'Quebec', 'quebec', '1', 11, '2025-08-11 04:02:10', '2025-08-11 04:02:10'),
(12, 22, 2, 'نيويورك', 'نيويورك', '1', 1, '2025-08-11 03:36:38', '2025-08-11 11:40:16'),
(13, 22, 4, 'لندن الكبرى', 'لندن-الكبرى', '1', 2, '2025-08-11 03:36:57', '2025-08-11 11:38:40'),
(14, 22, 6, 'أونتاريو', 'أونتاريو', '1', 3, '2025-08-11 03:37:09', '2025-08-11 11:38:33'),
(15, 22, 8, 'نيو ساوث ويلز', 'نيو-ساوث-ويلز', '1', 4, '2025-08-11 03:37:26', '2025-08-11 11:38:26'),
(16, 22, 10, 'برلين', 'برلين', '1', 5, '2025-08-11 03:37:45', '2025-08-11 11:38:18'),
(17, 22, 10, 'بافاريا', 'بافاريا', '1', 6, '2025-08-11 04:00:28', '2025-08-11 11:38:12'),
(18, 22, 10, 'هامبورغ', 'هامبورغ', '1', 7, '2025-08-11 04:00:40', '2025-08-11 11:38:05'),
(19, 22, 4, 'اسكتلندا', 'اسكتلندا', '1', 8, '2025-08-11 04:01:02', '2025-08-11 11:37:56'),
(20, 22, 2, 'تكساس', 'تكساس', '1', 9, '2025-08-11 04:01:25', '2025-08-11 11:37:48'),
(21, 22, 6, 'نوفا سكوشا', 'نوفا-سكوشا', '1', 10, '2025-08-11 04:01:50', '2025-08-11 11:37:43'),
(22, 22, 6, 'كيبيك', 'كيبيك', '1', 11, '2025-08-11 04:02:10', '2025-08-11 11:37:22');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `faqs`
--

CREATE TABLE `faqs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `faqs`
--

INSERT INTO `faqs` (`id`, `language_id`, `question`, `answer`, `serial_number`, `created_at`, `updated_at`) VALUES
(5, 8, 'What is an event management and ticket selling system?', 'An event management and ticket selling system is a software platform that helps event organizers manage all aspects of their events, including ticket sales, registration, marketing, and logistics.', 1, '2021-06-26 00:35:52', '2023-05-08 06:08:55'),
(6, 8, 'How does an event management and ticket selling system work?', 'An event management and ticket selling system typically allows event organizers to create event pages, sell tickets online, track registration and attendance, collect payments, and communicate with attendees through email or social media.', 2, '2021-06-26 00:38:14', '2023-05-08 06:09:12'),
(7, 8, 'What are the benefits of using an event management and ticket selling system?', 'The benefits of using an event management and ticket selling system include increased efficiency, reduced administrative workload, improved attendee experience, better data management, and increased revenue potential.', 3, '2021-06-26 00:39:02', '2023-05-08 06:09:28'),
(16, 8, 'What types of events can be managed with an event management and ticket selling system?', 'An event management and ticket selling system can be used for a wide range of events, including conferences, trade shows, concerts, festivals, sports games, and fundraising events.', 4, '2021-06-26 00:35:52', '2023-05-08 06:09:43'),
(17, 8, 'How can event organizers promote their events using an event management and ticket selling system?', 'Event organizers can promote their events using an event management and ticket selling system by creating customized event pages, sending targeted emails to potential attendees, and leveraging social media to reach a wider audience.', 5, '2021-06-26 00:38:14', '2023-05-08 06:10:00'),
(18, 8, 'How can attendees purchase tickets through an event management and ticket selling system?', 'Attendees can purchase tickets through an event management and ticket selling system by visiting the event page, selecting the desired ticket type and quantity, and completing the checkout process online.', 6, '2021-06-26 00:39:02', '2023-05-08 06:10:14'),
(22, 8, 'What payment methods are typically accepted by an event management and ticket selling system?', 'An event management and ticket selling system may accept various payment methods, such as credit cards, debit cards, PayPal, or other online payment systems.', 7, '2023-05-08 06:10:29', '2023-05-08 06:10:29'),
(23, 8, 'Can an event management and ticket selling system help manage event logistics, such as venue setup and staffing?', 'Yes, some event management and ticket selling systems offer features to help event organizers manage logistics, such as creating seating charts, assigning staff roles, and tracking equipment rentals.', 8, '2023-05-08 06:10:44', '2023-05-08 06:10:44'),
(24, 8, 'How can event organizers use data collected through an event management and ticket selling system?', 'Event organizers can use data collected through an event management and ticket selling system to analyze attendance patterns, track marketing effectiveness, and make informed decisions about future events.', 9, '2023-05-08 06:10:57', '2023-05-08 06:10:57'),
(25, 8, 'Are there any drawbacks to using an event management and ticket selling system?', 'Some potential drawbacks of using an event management and ticket selling system include upfront costs, ongoing fees, potential technical issues, and the need for staff training to use the system effectively.', 10, '2023-05-08 06:11:09', '2023-05-08 06:11:09'),
(26, 22, 'ما هو نظام إدارة الفعاليات وبيع التذاكر؟', 'نظام إدارة الأحداث وبيع التذاكر عبارة عن منصة برمجية تساعد منظمي الأحداث على إدارة جميع جوانب أحداثهم ، بما في ذلك مبيعات التذاكر والتسجيل والتسويق والخدمات اللوجستية.', 1, '2023-05-08 08:09:24', '2023-05-08 08:09:24'),
(27, 22, 'كيف يعمل نظام إدارة الأحداث وبيع التذاكر؟', 'عادة ما يسمح نظام إدارة الأحداث وبيع التذاكر لمنظمي الأحداث بإنشاء صفحات الحدث ، وبيع التذاكر عبر الإنترنت ، وتتبع التسجيل والحضور ، وجمع المدفوعات ، والتواصل مع', 2, '2023-05-08 08:10:28', '2023-05-08 08:10:28'),
(28, 22, 'ما هي فوائد استخدام نظام إدارة الفعاليات وبيع التذاكر؟', 'تشمل فوائد استخدام نظام إدارة الأحداث وبيع التذاكر زيادة الكفاءة وتقليل عبء العمل الإداري وتحسين تجربة الحضور وتحسين إدارة البيانات وزيادة', 3, '2023-05-08 08:11:20', '2023-05-08 08:11:20'),
(29, 22, 'ما هي أنواع الأحداث التي يمكن إدارتها باستخدام نظام إدارة الأحداث وبيع التذاكر؟', 'يمكن استخدام نظام إدارة الأحداث وبيع التذاكر لمجموعة واسعة من الأحداث ، بما في ذلك المؤتمرات والمعارض التجارية والحفلات الموسيقية والمهرجانات والألعاب الرياضية وأحداث جمع التبرعات.', 4, '2023-05-08 08:12:02', '2023-05-08 08:12:02'),
(30, 22, 'كيف يمكن لمنظمي الفعاليات الترويج لأحداثهم باستخدام نظام إدارة الأحداث وبيع التذاكر؟', 'يمكن لمنظمي الأحداث الترويج لأحداثهم باستخدام نظام إدارة الأحداث وبيع التذاكر من خلال إنشاء صفحات مخصصة للحدث ، وإرسال رسائل بريد إلكتروني مستهدفة إلى الحاضرين المحتملين ، والاستفادة من وسائل التواصل الاجتماعي', 5, '2023-05-08 08:12:45', '2023-05-08 08:12:45'),
(31, 22, 'كيف يمكن للحضور شراء التذاكر من خلال نظام إدارة الفعاليات وبيع التذاكر؟', 'يمكن للحضور شراء التذاكر من خلال نظام إدارة الفعاليات وبيع التذاكر من خلال زيارة صفحة الفعالية، واختيار نوع التذكرة المطلوبة وكميتها، وإتمام عملية الدفع على الفور.', 6, '2023-05-08 08:13:16', '2023-05-08 08:13:16'),
(32, 22, 'ما هي طرق الدفع التي يقبلها عادة نظام إدارة الأحداث وبيع التذاكر؟', 'قد يقبل نظام إدارة الأحداث وبيع التذاكر طرق دفع مختلفة ، مثل بطاقات الائتمان أو بطاقات الخصم أو PayPal أو أنظمة الدفع الأخرى عبر الإنترنت.', 7, '2023-05-08 08:14:00', '2023-05-08 08:14:00'),
(33, 22, 'هل يمكن لنظام إدارة الأحداث وبيع التذاكر المساعدة في إدارة الخدمات اللوجستية للحدث ، مثل إعداد المكان والموظفين؟', 'نعم ، تقدم بعض أنظمة إدارة الأحداث وبيع التذاكر ميزات لمساعدة منظمي الأحداث على إدارة الخدمات اللوجستية ، مثل إنشاء مخططات المقاعد وتعيين أدوار الموظفين وتتبع تأجير المعدات.', 8, '2023-05-08 08:14:43', '2023-05-08 08:14:43'),
(34, 22, 'كيف يمكن لمنظمي الحدث استخدام البيانات التي تم جمعها من خلال نظام إدارة الحدث وبيع التذاكر؟', 'يمكن لمنظمي الأحداث استخدام البيانات التي تم جمعها من خلال نظام إدارة الأحداث وبيع التذاكر لتحليل أنماط الحضور وتتبع فعالية التسويق واتخاذ قرارات مستنيرة بشأن المركبات الكهربائية المستقبلية', 9, '2023-05-08 08:15:28', '2023-05-08 08:15:28'),
(35, 22, 'هل هناك أي عيوب لاستخدام نظام إدارة الأحداث وبيع التذاكر؟', 'تتضمن بعض العيوب المحتملة لاستخدام نظام إدارة الأحداث وبيع التذاكر التكاليف الأولية والرسوم المستمرة والمشكلات الفنية المحتملة والحاجة إلى تدريب الموظفين لاستخدام فعالية النظام', 10, '2023-05-08 08:16:06', '2023-05-08 08:16:06');

-- --------------------------------------------------------

--
-- Table structure for table `fcm_tokens`
--

CREATE TABLE `fcm_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `platform` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `fcm_tokens`
--

INSERT INTO `fcm_tokens` (`id`, `user_id`, `token`, `platform`, `message_title`, `message_description`, `created_at`, `updated_at`, `booking_id`) VALUES
(1, NULL, NULL, NULL, NULL, NULL, '2025-10-18 07:22:51', '2025-10-18 07:22:51', NULL),
(2, 33, NULL, 'web', 'Paymant status', 'Payment Success', '2025-10-18 07:29:16', '2025-10-18 07:29:16', NULL),
(3, NULL, NULL, NULL, NULL, NULL, '2025-10-27 02:07:28', '2025-10-27 02:07:43', NULL),
(4, 33, NULL, NULL, NULL, NULL, '2025-10-27 02:07:59', '2025-10-27 02:08:11', NULL),
(5, NULL, NULL, 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:37:03', '2025-10-28 00:37:03', NULL),
(7, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:46:20', '2025-10-28 00:46:20', NULL),
(8, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:48:05', '2025-10-28 00:48:05', NULL),
(9, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:50:00', '2025-10-28 00:50:00', NULL),
(10, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:52:48', '2025-10-28 00:52:48', NULL),
(11, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:53:31', '2025-10-28 00:53:31', NULL),
(12, NULL, '44', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-10-28 00:54:44', '2025-10-28 00:54:44', NULL),
(13, 33, '123456', NULL, NULL, NULL, '2025-10-28 05:03:30', '2025-10-28 05:03:30', NULL),
(14, 33, '123456', 'web', 'Event Booking Complete', 'Your current payment status pending', '2025-11-03 03:28:02', '2025-11-03 05:22:38', NULL),
(15, 33, '123456', 'web', 'Event Booking Complete', 'Your current payment status completed', '2025-11-03 03:29:02', '2025-11-03 05:22:38', NULL),
(16, 33, '12345655', NULL, NULL, NULL, '2025-11-03 05:22:45', '2025-11-03 05:22:45', NULL),
(17, 33, 'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU', 'web', 'Event Booking Complete', 'Your current payment status pending', '2025-11-03 06:27:12', '2025-11-03 06:27:12', 190),
(18, 33, 'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-11-03 06:31:47', '2025-11-03 06:31:47', 190),
(19, 33, 'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU', 'web', 'Payment Status Updated', 'Your current payment status completed', '2025-11-03 06:34:25', '2025-11-03 06:34:25', 190);

-- --------------------------------------------------------

--
-- Table structure for table `features`
--

CREATE TABLE `features` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `background_color` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `text` text NOT NULL,
  `serial_number` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `features`
--

INSERT INTO `features` (`id`, `language_id`, `background_color`, `icon`, `title`, `text`, `serial_number`, `created_at`, `updated_at`) VALUES
(6, 8, '0066FF', 'fas fa-book-reader', 'Highly Qualified Mentors & Instructors', 'See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.', 3, '2021-10-11 00:11:50', '2022-05-15 00:03:40'),
(7, 8, '8976FF', 'fas fa-book', 'Quizzes, Videos, Code Snippets & More', 'See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.', 2, '2021-10-11 00:13:02', '2022-05-15 00:02:41'),
(8, 8, '30BCFF', 'fas fa-chalkboard-teacher', 'Course Completion Certificate', 'See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.', 1, '2021-10-11 00:13:44', '2022-05-15 00:01:54'),
(12, 8, '2ECC71', NULL, 'Drag & Drop Lesson Contents Decoration', 'See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.', 4, '2022-05-15 00:05:22', '2022-05-15 00:06:29');

-- --------------------------------------------------------

--
-- Table structure for table `footer_contents`
--

CREATE TABLE `footer_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `footer_background_color` varchar(255) DEFAULT NULL,
  `about_company` text,
  `copyright_text` text,
  `footer_logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `footer_contents`
--

INSERT INTO `footer_contents` (`id`, `language_id`, `footer_background_color`, `about_company`, `copyright_text`, `footer_logo`, `created_at`, `updated_at`) VALUES
(1, 8, '011444', 'Lorem ipsum dolor sit amet consectetur adipisicing elit. Possimus dignissimos quibusdam quia sit delectus. Cupiditate corporis, delectus quo ullam repudiandae illum culpa, magni modi, asperiores quis non magnam fugit vitae!', 'Copyright ©{year}. All Rights Reserved.', '1683629311.png', '2021-06-19 05:57:47', '2023-05-18 08:08:59'),
(3, 22, '011444', ', ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p>حقوق الطبع والنشر © {year}. جميع الحقوق محفوظة.<br /></p>', '1683523303.png', '2023-05-08 05:21:44', '2023-05-09 10:33:52');

-- --------------------------------------------------------

--
-- Table structure for table `fun_fact_sections`
--

CREATE TABLE `fun_fact_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `background_image` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `fun_fact_sections`
--

INSERT INTO `fun_fact_sections` (`id`, `language_id`, `background_image`, `title`, `created_at`, `updated_at`) VALUES
(3, 8, '61befc8312cee.jpg', 'Some Fun Facts from Us', '2021-10-07 03:23:12', '2021-12-19 03:33:55');

-- --------------------------------------------------------

--
-- Table structure for table `gooogle_calendar_infos`
--

CREATE TABLE `gooogle_calendar_infos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `google_calendar_event_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `guests`
--

CREATE TABLE `guests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `endpoint` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `guests`
--

INSERT INTO `guests` (`id`, `endpoint`, `created_at`, `updated_at`) VALUES
(7, 'https://fcm.googleapis.com/fcm/send/diZDc7939-k:APA91bFXdlYgz6msLEKBUM3NaoM1fdH1Z7rURz[…]KOTBNqZbKyaPJ-Qjn9JpOLzVasqpIIonOPiQHp3YiV540-UJNhvh1LSdyi8', '2025-10-29 07:41:19', '2025-10-29 07:41:19'),
(8, 'https://fcm.googleapis.com/fcm/send/dPnvaQfjZmY:APA91bFKyN3JcgGME6ZrIMuxy1b6H1L2TCG9N2lfBI6lcogRmeziZtfB2fOCOW7NJG6HcPk2lMu0xnnye1wqYtoBl5bvekqIY9KNH-RToHeTXQ6gIaZ9S3lkTuWrDMQYRcWUfUiOmhaI', '2025-10-29 07:44:42', '2025-10-29 07:44:42'),
(9, 'https://fcm.googleapis.com/fcm/send/eUF90OisF2U:APA91bHloRcT7GAh0i6GWngRhJIh-OHUXCIqLowa-HAdvxu2XpZTgdfzCPHzYM7pJK5wwTufedyGm2ocjLkNfSPtk3toEa5nrsMcbmZUVaXdAzXNnzU4mNq4zVlpYtt1B0E9f_Y3RFDB', '2025-11-02 05:06:11', '2025-11-02 05:06:11'),
(10, 'https://fcm.googleapis.com/fcm/send/faKkK9nx67A:APA91bERXmwrqZivBOcIjz1OlixofdUiikI0Qh9dkzOW2S51FI0Y76Akf70KX0P64sgvefAKL_ggFVlBhN29J89dwjvFc53jP1mqN45MG7LEIej4suEL-t48_Z09e6rpLX-Jlttneygu', '2025-11-03 03:27:11', '2025-11-03 03:27:11'),
(11, 'https://fcm.googleapis.com/fcm/send/fDXXEc0DzIY:APA91bGWBfzFjM7p1YD9SuhF8DvJsVdwRYGhFer21viIJhCmfVFNsYlHSlV61Xi8D0GWKA84naNFTE3nkg7D8CIzhFQAad_RoRu8wuLWhoJYYzYDa7g45VAF-jZJeUMxtJV49c97bt6K', '2025-11-06 03:53:06', '2025-11-06 03:53:06'),
(12, 'https://fcm.googleapis.com/fcm/send/d_wJzTj2InY:APA91bGkg9h1l2rvZKqtKwszwCSRsUg5byk2vJT_wnkHOfJ5W5oEu5kc6w5QhmgfgJBptACpYlU9mOpwzsuWJkd3ypGb5qIi15h55DTn6Em3vR_eW8FnnQjh6CHb1I_PYzd6uJisx89l', '2025-11-08 01:28:56', '2025-11-08 01:28:56'),
(13, 'https://fcm.googleapis.com/fcm/send/eEVDuoYjbyw:APA91bE69Dvppa8x8H7MLm_sAXW-CeA3lv2hwKRU9KWQew2OoTnTvtgB2SSe_bp-7b6YdJ_L0tyVDAPVR-cvpiiN9ivyU5sfZZaYb2B1sU7J7YeY6zV6uOPU66lzi43OVfrR3pPdRi3Y', '2025-11-08 04:37:29', '2025-11-08 04:37:29'),
(14, 'https://fcm.googleapis.com/fcm/send/fyqQImbJth8:APA91bHmbK6jxzev-d7dEc12xuTHkgZZIEP96fndr0tomw8PfZDzPBrTJnx6qY0XAjbjv9zZbXoAlf3EK7x8OGv_QCyfJWFzWgAYO9XcqMRJ-KCvU7bbtTY6XAVRHbujL7qJSeJo1yC1', '2025-11-08 07:28:28', '2025-11-08 07:28:28'),
(15, 'https://fcm.googleapis.com/fcm/send/cEjVVc6iP54:APA91bFzWtZ5M77jyBwiYKbQQus6RIYUyZjuQ68wIekQOdRpAIhpV6LAVWsc1rkpokRdya2tU-2NFjzxek3yQTKi1StM-ae2bVfOOJL-4ezoDDcM_pai5ZuvgV8EXndSKjxjeYJQT1tU', '2025-11-08 07:54:17', '2025-11-08 07:54:17');

-- --------------------------------------------------------

--
-- Table structure for table `hero_sections`
--

CREATE TABLE `hero_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `background_image` varchar(255) NOT NULL,
  `first_title` varchar(255) DEFAULT NULL,
  `second_title` varchar(255) DEFAULT NULL,
  `first_button` varchar(255) DEFAULT NULL,
  `first_button_url` varchar(255) DEFAULT NULL,
  `second_button` varchar(255) DEFAULT NULL,
  `second_button_url` varchar(255) DEFAULT NULL,
  `video_url` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `hero_sections`
--

INSERT INTO `hero_sections` (`id`, `language_id`, `background_image`, `first_title`, `second_title`, `first_button`, `first_button_url`, `second_button`, `second_button_url`, `video_url`, `image`, `created_at`, `updated_at`) VALUES
(2, 8, '629ec0bd9c0b0.jpg', 'Our vision Our innovation Event Solutions', 'nterdum et malesuada fames ac ante ipsum primis in faucibus. Vestibulum placerat pulvinar metus ut viverra. Phasellus sem magna,', 'Find Events', 'https://codecanyon.kreativdev.com/coursela/courses', 'Meet Instructors', 'https://codecanyon.kreativdev.com/coursela/instructors', NULL, '61bda9c61892c.png', '2021-11-30 22:30:04', '2023-05-07 11:38:24'),
(7, 22, '64578de91220f.jpg', 'رؤيتنا ابتكارنا حلول الفعاليات', 'أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم', 'البحث عن الأحداث', NULL, NULL, NULL, NULL, NULL, '2023-05-07 11:39:21', '2023-05-07 11:39:21');

-- --------------------------------------------------------

--
-- Table structure for table `how_works`
--

CREATE TABLE `how_works` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `how_works`
--

INSERT INTO `how_works` (`id`, `language_id`, `title`, `text`, `created_at`, `updated_at`) VALUES
(1, 8, 'how does it work', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt', '2022-06-07 00:42:14', '2022-06-07 00:58:43'),
(4, 22, 'كيف يعمل', 'وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', '2023-05-07 12:07:19', '2023-05-07 12:07:19');

-- --------------------------------------------------------

--
-- Table structure for table `how_work_items`
--

CREATE TABLE `how_work_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `how_work_items`
--

INSERT INTO `how_work_items` (`id`, `language_id`, `icon`, `title`, `text`, `serial_number`, `created_at`, `updated_at`) VALUES
(1, 8, 'fas fa-user-plus', 'Register your account', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.', 1, '2022-06-07 00:45:47', '2023-05-07 12:01:00'),
(2, 8, 'fas fa-plus', 'Create your events', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam .', 2, '2022-06-07 00:48:26', '2023-05-07 12:01:45'),
(3, 8, 'fas fa-cart-arrow-down', 'Sell tickets & get paid', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.', 3, '2022-06-07 00:49:09', '2023-05-07 12:09:09'),
(4, 8, 'fas fa-wallet', 'Withdraw', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.', 4, '2022-06-07 00:49:38', '2023-05-07 12:02:56'),
(11, 22, 'fas fa-user-plus', 'سجل حسابك', 'وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', 1, '2023-05-07 12:04:22', '2023-05-07 12:04:22'),
(12, 22, 'fas fa-plus', 'إنشاء الأحداث الخاصة بك', 'وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', 2, '2023-05-07 12:08:07', '2023-05-07 12:08:15'),
(13, 22, 'fas fa-cart-arrow-down', 'بيع التذاكر والحصول على أموال', 'وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', 3, '2023-05-07 12:08:46', '2023-05-07 12:08:46'),
(14, 22, 'fas fa-wallet', 'سحب', 'وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', 4, '2023-05-07 12:09:35', '2023-05-07 12:09:35');

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) UNSIGNED NOT NULL,
  `reserved_at` int(10) UNSIGNED DEFAULT NULL,
  `available_at` int(10) UNSIGNED NOT NULL,
  `created_at` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `languages`
--

CREATE TABLE `languages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `code` char(255) NOT NULL,
  `direction` tinyint(4) NOT NULL,
  `is_default` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `languages`
--

INSERT INTO `languages` (`id`, `name`, `code`, `direction`, `is_default`, `created_at`, `updated_at`) VALUES
(8, 'English', 'en', 0, 1, '2021-05-31 05:58:22', '2024-08-31 06:37:26'),
(22, 'عربية', 'ar', 1, 0, '2023-02-02 11:07:56', '2024-08-31 06:37:26');

-- --------------------------------------------------------

--
-- Table structure for table `mail_templates`
--

CREATE TABLE `mail_templates` (
  `id` int(11) NOT NULL,
  `mail_type` varchar(50) NOT NULL,
  `mail_subject` varchar(255) NOT NULL,
  `mail_body` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `mail_templates`
--

INSERT INTO `mail_templates` (`id`, `mail_type`, `mail_subject`, `mail_body`) VALUES
(4, 'verify_email', 'Verify Your Email Address', '<p>Hi <b>{username}</b>,</p><p>We just need to verify your email address before you can access to your dashboard.</p><p>Verify your email address, {verification_link}.</p><p>Thank you.<br />{website_title}</p><p><br /></p>'),
(5, 'reset_password', 'Recover Password of Your Account', '<p>Hi {customer_name},</p><p>We have received a request to reset your password. If you did not make the request, just ignore this email. Otherwise, you can reset your password using this below link.</p><p>{password_reset_link}</p><p>Thanks,<br>{website_title}</p>'),
(9, 'event_booking', 'Event Confirmation', '<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p>\r\n<p>You have successfully enrol in the following event.</p>\r\n<p>Booking Id: #{order_id}<br />Event: {title}</p>\r\n<p>Also, we have attached an invoice in this mail.</p>\r\n<p>Meeting Link :{meeting_url}</p>\r\n<p>Best regards.<br />{website_title}</p>'),
(10, 'event_booking_approved', 'Approval of Event Booking', '<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your payment is completed, and we have approved your booking for the following evnent.</p><p>Booking Id: #{order_id}<br /></p><p>Event : {title}</p><p>Also, we have attached an invoice in this mail.</p><p>Best regards.<br />{website_title}</p>'),
(11, 'event_booking_rejected', 'Rejection of Event Booking', '<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your payment is not completed, thus we have rejected your Booking for the following Event.</p><p>Booking Id: #{order_id}<br /></p><p>Event : {title}</p><p>For further information, please do not hesitate to contact us.<br />{website_title}</p>'),
(12, 'product_order', 'Order Confirmation', '<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your Order  has been  successfully Placed.</p><p>Order Id: #{order_id}<br /></p><p>Also, we have attached an invoice in this mail.</p><p>Best regards.<br />{website_title}</p>'),
(13, 'withdraw_approve', 'Confirmation of Withdraw Approve', '<p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Hi {organizer_username},</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">This email confirms that your withdrawal request  {withdraw_id} is approved. </p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Your current balance is {current_balance}, withdraw amount {withdraw_amount}, charge : {charge},payable amount {payable_amount}</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">withdraw method : {withdraw_method}. The transaction id is {transaction_id}.</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\"><br /></p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Best Regards.<br />{website_title}</p>'),
(14, 'withdraw_rejected', 'Withdraw Request Rejected', '<p>Hi {organizer_username},</p><p>This email confirms that your withdrawal request  {withdraw_id} is rejected and the balance added to your account. </p><p>Your current balance is {current_balance}</p><p><br /></p><p>Best Regards.<br />{website_title}</p>'),
(15, 'balance_add', 'Balance Add', '<p>Hi {username}</p><p>{amount} added to your account.</p><p>Your current balance is {current_balance}. </p><p>The transaction id is {transaction_id}.<br /></p><p><br /></p><p>Best Regards.<br />{website_title}<br /></p>'),
(16, 'balance_subtract', 'Balance Subtract', '<p>Hi {username}</p><p>{amount} subtract from your account.</p><p>Your current balance is {current_balance}.</p><p>The transaction id is {transaction_id}.<br /></p><p><br /></p><p>Best Regards.<br />{website_title}</p>'),
(17, 'product_shipping', 'Product Shipping Status', '<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your order shipping status is {status}.</p><p>Order Id: #{order_id}</p><p>Best regards.<br />{website_title}</p>');

-- --------------------------------------------------------

--
-- Table structure for table `menu_builders`
--

CREATE TABLE `menu_builders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `menus` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `menu_builders`
--

INSERT INTO `menu_builders` (`id`, `language_id`, `menus`, `created_at`, `updated_at`) VALUES
(2, 8, '[{\"type\":\"home\",\"text\":\"Home\",\"target\":\"_self\"},{\"text\":\"Events\",\"href\":\"events\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"events\"},{\"text\":\"Organizers\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"organizers\"},{\"text\":\"Shop\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"custom\",\"children\":[{\"text\":\"Shop\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"shop\"},{\"text\":\"Cart\",\"href\":\"shop/cart\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"cart\"},{\"text\":\"Checkout\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"shop/checkout\"}]},{\"text\":\"Pages\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"custom\",\"children\":[{\"text\":\"About Us\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"about\"},{\"text\":\"Terms & Conditions\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"terms-&-conditions\"},{\"text\":\"Privacy Policy\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"privacy-policy\"},{\"text\":\"FAQ\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"faq\"}]},{\"text\":\"Blog\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"blog\"},{\"text\":\"Contact\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"contact\"}]', '2021-12-01 05:32:09', '2023-10-06 05:39:42'),
(6, 22, '[{\"text\":\"بيت\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"home\"},{\"text\":\"الأحداث\",\"href\":\"events\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"events\"},{\"text\":\"المنظمون\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"organizers\"},{\"text\":\"محل\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"custom\",\"children\":[{\"text\":\"محل\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"shop\"},{\"text\":\"عربة التسوق\",\"href\":\"shop/cart\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"cart\"},{\"text\":\"الدفع\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"shop/checkout\"}]},{\"text\":\"الصفحات\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"custom\",\"children\":[{\"text\":\"معلومات عنا\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"about\"},{\"text\":\"سياسة الخصوصية\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"سياسة-الخصوصية\"},{\"text\":\"الشروط والأحكام\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"الشروط-والأحكام\"},{\"text\":\"التعليمات\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"faq\"}]},{\"text\":\"مدونة\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"blog\"},{\"text\":\"اتصال\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"contact\"}]', '2023-02-02 11:07:56', '2023-05-21 04:44:26');

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(3, '2023_03_04_134315_drop_secondary_color_from_basic_settings_table', 1),
(6, '2023_03_05_152403_add_tax_commission_percentage_column_to_bookings_table', 2),
(9, '2023_03_22_115828_add_column_to_conversations_table', 3),
(10, '2023_05_11_150902_create_ticket_contents_table', 4),
(14, '2023_05_13_124521_create_variation_contents_table', 5),
(15, '2023_05_20_154216_add_about_page_title_column_to_page_headings_table', 6),
(16, '2023_05_20_154329_add_meta_keyword_description_column_to_seos_table', 6),
(17, '2023_07_30_094527_add_scan_status_column_to_bookings_table', 7),
(18, '2023_09_30_162759_add_tax_percentage_column_to_product_orders_table', 8),
(21, '2023_11_16_062730_add_event_guest_checkout_status_to_basic_settings_table', 9),
(22, '2023_11_23_034714_add_scanned_tickets_column_to_bookings_table', 10),
(23, '2024_02_07_055018_add_midtrans_payment_gateway_row_to_online_gateways_table', 11),
(26, '2024_02_07_172740_add_iyzico_payment_gateway_into_online_gateways_table', 12),
(32, '2024_02_10_105443_add_toyyibpay_payment_gateway_into_online_gateways', 14),
(35, '2024_02_10_122829_add_phonepe_payment_gateway_into_online_gateways_table', 15),
(37, '2024_02_10_152845_add_yoco_payment_gateway_into_online_gateways', 16),
(39, '2024_02_10_172724_add_xindit_payment_gateway_into_online_gateways', 17),
(44, '2021_02_01_030511_create_payment_invoices_table', 18),
(45, '2024_02_11_143939_add_myfatoorah_payment_gateway_into_online_gateways', 18),
(46, '2024_02_12_120007_add_conversation_id_to_event_bookings_table', 19),
(47, '2024_02_12_162617_add_conversation_id_to_product_orders_table', 20),
(49, '2024_02_08_153546_add_paytabs_payment_gateway_into_online_gateways', 21),
(51, '2024_02_14_112643_add_perfect_money_payment_gateway_into_online_gateways_table', 22),
(52, '2024_08_24_050913_add_ticket_header_image_ticket_background_color_instructiob_to_events_table', 23),
(53, '2024_08_24_075435_theme_version_add_to_organizers_table', 23),
(54, '2024_08_25_033713_meeting_url_add_to_events_table', 24),
(55, '2024_08_27_062045_ticket_logo_add_to_events_table', 25),
(56, '2024_08_29_034732_ticket_image_add_to_events_table', 26),
(57, '2024_10_23_054145_add_scanned_tickets_colum_in_the_bookings_table', 27),
(58, '2025_03_05_023749_add_a_colum_to_basic_settings', 28),
(60, '2025_08_06_045540_add_column_into_basic_settings_table', 29),
(61, '2025_08_06_065645_create_event_countries_table', 30),
(62, '2025_08_06_083111_create_event_states_table', 31),
(63, '2025_08_06_100543_create_event_cities_table', 32),
(64, '2025_08_09_101952_add_column_into_event_contents_table', 33),
(65, '2025_09_29_100732_create_slot_seats_table', 34),
(66, '2025_09_29_100848_create_slot_images_table', 34),
(67, '2025_09_29_102256_add_column_to_slot_column', 34),
(68, '2025_09_29_114230_create_slots_table', 35),
(69, '2025_09_30_092809_add_column_to_slot_free', 36),
(70, '2019_12_14_000001_create_personal_access_tokens_table', 37),
(72, '2025_10_14_065846_add_column_mobile_app', 38),
(73, '2025_10_15_082023_add_column_to_mobile_interface', 39),
(74, '2025_10_15_084350_add_row_create_to_online_payment_gateway', 40),
(75, '2025_10_15_091301_add_row_create_to_online_payment_gateway_now_payment', 41),
(76, '2025_10_15_110548_add_column_firebase_admin_json_to_basic_settings', 42),
(77, '2025_10_18_124132_create_fcm_tokens_table', 43),
(78, '2025_10_19_081020_add_column_fcm_token_to_bookings', 44),
(79, '2025_10_19_112931_add_column_name_ticeket_seat_min_price_tickets', 45),
(80, '2025_10_27_073616_add_column_message_title_message_description', 46),
(81, '2025_10_28_103324_add_column_primary_colour_to_basic_settings', 47),
(82, '2025_10_29_103618_add_coloumn_ticket_slot_image_to_events', 48),
(85, '2025_11_03_094910_add_column_booking_id_to_fcm_tokens', 50),
(87, '2025_11_04_054320_add_column_app_google_map_status_to_basic_settings', 51),
(88, '2025_11_10_123600_add_column_mobile_interface_section_title', 52);

-- --------------------------------------------------------

--
-- Table structure for table `offline_gateways`
--

CREATE TABLE `offline_gateways` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `short_description` text,
  `instructions` blob,
  `status` tinyint(1) NOT NULL DEFAULT '1' COMMENT '0 -> gateway is deactive, 1 -> gateway is active.',
  `has_attachment` tinyint(1) NOT NULL COMMENT '0 -> do not need attachment, 1 -> need attachment.',
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `offline_gateways`
--

INSERT INTO `offline_gateways` (`id`, `name`, `short_description`, `instructions`, `status`, `has_attachment`, `serial_number`, `created_at`, `updated_at`) VALUES
(2, 'Citibank', 'A pioneer of both the credit card industry and automated teller machines, Citibank – formerly the City Bank of New York.', 0x3c703e3c7370616e207374796c653d22636f6c6f723a7267622835312c35312c3531293b666f6e742d66616d696c793a2770726f78696d612d6e6f7661272c2073616e732d73657269663b666f6e742d73697a653a313670783b223e412070696f6e656572206f6620626f74682074686520637265646974206361726420696e64757374727920616e64206175746f6d617465642074656c6c6572206d616368696e65732cc2a03c2f7370616e3e3c6120687265663d2268747470733a2f2f736d61727461737365742e636f6d2f636865636b696e672d6163636f756e742f4369746962616e6b2d62616e6b696e672d726576696577223e4369746962616e6b3c2f613e3c7370616e207374796c653d22636f6c6f723a7267622835312c35312c3531293b666f6e742d66616d696c793a2770726f78696d612d6e6f7661272c2073616e732d73657269663b666f6e742d73697a653a313670783b223ec2a0e2809320666f726d65726c792074686520436974792042616e6b206f66204e657720596f726b20e280932077617320726567617264656420617320616e204561737420436f617374206571756976616c656e7420746f2057656c6c7320466172676f20647572696e672074686520313974682063656e747572792e3c2f7370616e3e3c2f703e, 1, 0, 1, '2021-07-16 22:41:59', '2023-05-20 07:01:34'),
(3, 'Bank of America', 'Bank of America has 4,265 branches in the country, only about 700 fewer than Chase. It started as a small institution serving immigrants in San Francisco.', 0x3c703e3c7370616e207374796c653d22636f6c6f723a7267622835312c35312c3531293b666f6e742d66616d696c793a2770726f78696d612d6e6f7661272c2073616e732d73657269663b666f6e742d73697a653a313670783b223e576974682024312e38207472696c6c696f6e20696e20636f6e736f6c696461746564206173736574732cc2a03c2f7370616e3e3c6120687265663d2268747470733a2f2f736d61727461737365742e636f6d2f636865636b696e672d6163636f756e742f62616e6b2d6f662d616d65726963612d726576696577223e42616e6b206f6620416d65726963613c2f613e3c7370616e207374796c653d22636f6c6f723a7267622835312c35312c3531293b666f6e742d66616d696c793a2770726f78696d612d6e6f7661272c2073616e732d73657269663b666f6e742d73697a653a313670783b223e206973207365636f6e64206f6e20746865206c6973742e204974732068656164717561727465727320696e20436861726c6f7474652c204e6f727468204361726f6c696e612c2073696e676c6568616e6465646c79206d616b657320746861742063697479206f6e65206f662074686520626967676573742066696e616e6369616c2063656e7465727320696e2074686520636f756e7472792e3c2f7370616e3e3c2f703e, 1, 1, 2, '2021-07-16 22:43:19', '2023-05-20 07:01:49');

-- --------------------------------------------------------

--
-- Table structure for table `online_gateways`
--

CREATE TABLE `online_gateways` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `information` mediumtext NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL,
  `mobile_status` tinyint(4) NOT NULL DEFAULT '0',
  `mobile_information` longtext
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `online_gateways`
--

INSERT INTO `online_gateways` (`id`, `name`, `keyword`, `information`, `status`, `mobile_status`, `mobile_information`) VALUES
(1, 'PayPal', 'paypal', '{\"sandbox_status\":\"1\",\"client_id\":\"AVYKFEw63FtDt9aeYOe9biyifNI56s2Hc2F1Us11hWoY5GMuegipJRQBfWLiIKNbwQ5tmqKSrQTU3zB3\",\"client_secret\":\"EJY0qOKliVg7wKsR3uPN7lngr9rL1N7q4WV0FulT1h4Fw3_e5Itv1mxSdbtSUwAaQoXQFgq-RLlk_sQu\"}', 1, 1, '{\"sandbox_status\":\"1\",\"client_id\":\"rr\",\"client_secret\":\"rr\"}'),
(2, 'Instamojo', 'instamojo', '{\"sandbox_status\":\"1\",\"key\":\"rr6\",\"token\":\"rr6\"}', 1, 0, NULL),
(3, 'Paystack', 'paystack', '{\"key\":\"rr\"}', 1, 1, '{\"key\":\"rr\"}'),
(4, 'Flutterwave', 'flutterwave', '{\"public_key\":\"rr6\",\"secret_key\":\"rr6\"}', 1, 1, '{\"public_key\":\"rr\",\"secret_key\":\"rr\"}'),
(5, 'Razorpay', 'razorpay', '{\"key\":\"rr\",\"secret\":\"rr\"}', 1, 0, '{\"key\":\"rr\",\"secret\":\"rr\"}'),
(6, 'MercadoPago', 'mercadopago', '{\"sandbox_status\":\"1\",\"token\":\"rr6\"}', 1, 1, '{\"sandbox_status\":\"1\",\"token\":\"rr\"}'),
(7, 'Mollie', 'mollie', '{\"key\":\"rr6\"}', 1, 1, '{\"key\":\"rr\"}'),
(8, 'Stripe', 'stripe', '{\"key\":\"rr6\",\"secret\":\"rr6\"}', 1, 1, '{\"key\":\"rr\",\"secret\":\"rr\"}'),
(9, 'Paytm', 'paytm', '{\"environment\":\"local\",\"merchant_key\":\"rr6\",\"merchant_mid\":\"rr6\",\"merchant_website\":\"rr6\",\"industry_type\":\"rr6\"}', 1, 0, NULL),
(10, 'Midtrans', 'midtrans', '{\"is_production\":\"1\",\"server_key\":\"rr6\"}', 1, 1, '{\"is_production\":\"1\",\"server_key\":\"rr\"}'),
(13, 'Iyzico', 'iyzico', '{\"sandbox_status\":\"1\",\"api_key\":\"rr6\",\"secret_key\":\"rr6\"}', 1, 0, NULL),
(19, 'Toyyibpay', 'toyyibpay', '{\"sandbox_status\":\"1\",\"secret_key\":\"rr6\",\"category_code\":\"rr6\"}', 0, 0, '{\"sandbox_status\":\"0\",\"secret_key\":\"rr\",\"category_code\":\"rr\"}'),
(22, 'Phonepe', 'phonepe', '{\"merchant_id\":\"rr6\",\"sandbox_status\":\"1\",\"salt_key\":\"rr6\",\"salt_index\":\"6\"}', 1, 1, '{\"merchant_id\":\"rr\",\"sandbox_status\":\"1\",\"salt_key\":\"rr\",\"salt_index\":\"1\"}'),
(24, 'Yoco', 'yoco', '{\"secret_key\":\"rr6\"}', 1, 0, NULL),
(26, 'Xendit', 'xendit', '{\"secret_key\":\"rr6\"}', 1, 1, '{\"secret_key\":\"rr\"}'),
(29, 'Myfatoorah', 'myfatoorah', '{\"token\":\"rr\",\"sandbox_status\":\"1\"}', 1, 1, '{\"token\":\"rr\",\"sandbox_status\":\"1\"}'),
(30, 'Paytabs', 'paytabs', '{\"server_key\":\"rr6\",\"profile_id\":\"rr6\",\"country\":\"global\",\"api_endpoint\":\"rr6\"}', 1, 0, NULL),
(32, 'Perfect Money', 'perfect_money', '{\"perfect_money_wallet_id\":\"rr6\"}', 1, 0, NULL),
(33, 'Authorize.net', 'authorize.net', '', 0, 0, ''),
(34, 'Monnify', 'monnify', '', 0, 1, '{\"sandbox_status\":\"1\",\"api_key\":\"rr\",\"secret_key\":\"rr\",\"wallet_account_number\":\"1\"}'),
(35, 'NowPayments', 'now_payments', '', 0, 0, '{\"api_key\":\"rr\"}');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `qty` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `summery` text,
  `description` longtext,
  `price` decimal(8,2) DEFAULT NULL,
  `previous_price` decimal(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `product_order_id`, `product_id`, `user_id`, `title`, `sku`, `qty`, `category`, `image`, `summery`, `description`, `price`, `previous_price`, `created_at`, `updated_at`) VALUES
(59, 40, 11, 23, 'Printer', '33793966', '1', '', '1683454265.png', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p> </p>\r\n<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', '250.00', NULL, '2024-02-13 06:17:58', '2024-02-13 06:17:58'),
(60, 40, 9, 23, 'Sunscreen Cream', '44170596', '1', '', '1683453987.png', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p><div><br /></div>', '40.00', '42.00', '2024-02-13 06:17:58', '2024-02-13 06:17:58'),
(61, 41, 3, 23, 'Edifier W820NB Active Noise Cancelling Bluetooth Stereo Headphone', '74171591', '1', '', '1683452614.png', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', '50.00', '40.00', '2024-02-14 06:58:49', '2024-02-14 06:58:49'),
(62, 42, 11, 23, 'Printer', '33793966', '1', '', '1683454265.png', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p> </p>\r\n<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', '250.00', NULL, '2025-10-07 08:07:16', '2025-10-07 08:07:16'),
(63, 43, 11, 23, 'Printer', '33793966', '1', '', '1683454265.png', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p> </p>\r\n<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', '250.00', NULL, '2025-10-08 00:57:52', '2025-10-08 00:57:52'),
(64, 44, 11, 23, 'Printer', '33793966', '1', '', '1683454265.png', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p> </p>\r\n<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', '250.00', NULL, '2025-10-08 04:56:13', '2025-10-08 04:56:13');

-- --------------------------------------------------------

--
-- Table structure for table `organizers`
--

CREATE TABLE `organizers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT '1',
  `amount` float DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `twitter` varchar(255) DEFAULT NULL,
  `linkedin` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `theme_version` varchar(255) DEFAULT 'light'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `organizers`
--

INSERT INTO `organizers` (`id`, `photo`, `email`, `phone`, `username`, `password`, `status`, `amount`, `email_verified_at`, `facebook`, `twitter`, `linkedin`, `created_at`, `updated_at`, `theme_version`) VALUES
(23, '6457819a4ad93.png', 'azimahmed11041@gmail.com', '456 178929', 'organizer', '$2y$10$jSZFPerkySqIO8TvPOJTVOFVdjwxQe9jAIbHuNwQQcPLnMyH4SZTm', '1', 47405.1, '2023-05-02 09:50:40', 'https://www.facebook.com/', 'https://www.twitter.com/', 'https://www.linkedin.com/', '2023-05-02 09:50:29', '2025-11-09 01:27:25', 'dark'),
(24, '68ec8cf561ec0.png', 'champlin@gmail.com', '+1 (356) 897-2164', 'champlin', '$2y$10$M0ybp3gWIo4QH9xTPtbWnObN1QgTqBA186UtE8cDMV0AIoGBZ/YKy', '1', 162318, '2023-05-07 10:53:07', 'example.com', 'example.com', 'example.com', '2023-05-07 10:53:07', '2025-10-19 00:19:15', 'light'),
(25, '645784074a45c.png', 'ambrose@gmail.com', '+1 (456) 275-2116', 'ambrose', '$2y$10$jcY16T.Y7YMiBWuoBG4BNulc161uItshbYVNOORPjVgsANow4QDCq', '1', 4446, '2023-05-07 10:57:11', 'example.com', 'example.com', 'example.com', '2023-05-07 10:57:11', '2025-11-03 03:29:02', 'light'),
(26, '64578503d1473.png', 'alexanne@gmail.com', '+1 (379) 658-1366', 'alexanne', '$2y$10$Au06SRT/s0GhChPuXHRKb.3KOSOaDkMBUSRW/IDiqEaIwJ8eoiR2y', '1', 0, '2023-05-07 11:01:23', 'example.com', 'example.com', 'example.com', '2023-05-07 11:01:23', '2023-05-11 05:43:42', 'light'),
(27, NULL, 'xisehaworo@mailinator.com', NULL, 'kiholo', '$2y$10$YvtfwfxIelullgBTkpuiI.ZA5ygPHCH3jQkDev6lMYgrOm1TqgNsu', '0', NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:10:02', '2025-11-05 07:10:02', 'light'),
(28, NULL, 'sajurukavo@mailinator.com', NULL, 'tysonoqa', '$2y$10$BJsen5lqO2gAIgCNwoavA.IVD0Z2SL.j6c2kTwY9PaJ47QHPNf6GK', '0', NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:10:21', '2025-11-05 07:10:21', 'light'),
(29, NULL, 'pytuhu@mailinator.com', NULL, 'celajuc', '$2y$10$IDxFNF65/WLI0hV5Fiso0ebM8JnWfMm0J4FIlX56z6ITwr0hpM6cy', '0', NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:12:57', '2025-11-05 07:12:57', 'light'),
(30, NULL, 'fadawaler@mailinator.com', NULL, 'cudowo', '$2y$10$q6TBjOfmEhTzrbGleADRHusB.0UlQtXBjNnQU8eEOtqmCKv01Cnsy', '0', NULL, NULL, NULL, NULL, NULL, '2025-11-06 00:59:45', '2025-11-06 00:59:45', 'light');

-- --------------------------------------------------------

--
-- Table structure for table `organizer_infos`
--

CREATE TABLE `organizer_infos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) DEFAULT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `country` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `city` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `state` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `zip_code` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `address` text COLLATE utf8mb4_unicode_ci,
  `details` longtext COLLATE utf8mb4_unicode_ci,
  `designation` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `organizer_infos`
--

INSERT INTO `organizer_infos` (`id`, `language_id`, `organizer_id`, `name`, `country`, `city`, `state`, `zip_code`, `address`, `details`, `designation`, `created_at`, `updated_at`) VALUES
(2, 8, 20, 'Hossain', 'Bangladesh', 'Dhaka', 'North Carolina', '1230', 'House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh', 'Hi there! I\'m ChatSonic, an AI Chatbot that uses the latest and most advanced natural language processing technology to answer your questions accurately and informatively. I\'m here to help you with your questions about yourself. Here is a list of 101 facts about myself: I love to start numbering from zero instead of one, I love to take photographs wherever I go, I love harmony, I love martial arts, I can eat same food, day-in-day-out and not get bored, I can listen to same song non-stop in loop for days and still enjoy it, I can\'t live without access to my linux box,', 'fsadfaf', '2023-01-09 12:01:26', '2023-01-12 06:07:10'),
(3, 17, 20, 'Hossain', 'Bangladesh', 'Dhaka', 'North Carolina', '1230', 'House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh', 'Hi there! I\'m ChatSonic, an AI Chatbot that uses the latest and most advanced natural language processing technology to answer your questions accurately and informatively. I\'m here to help you with your questions about yourself. Here is a list of 101 facts about myself: I love to start numbering from zero instead of one, I love to take photographs wherever I go, I love harmony, I love martial arts, I can eat same food, day-in-day-out and not get bored, I can listen to same song non-stop in loop for days and still enjoy it, I can\'t live without access to my linux box,', 'fsadfaf', '2023-01-09 12:33:08', '2023-01-12 06:07:10'),
(4, 8, 18, 'Fahad Ahmad Shemul', 'Bangladesh', 'Dhaka', 'North Carolina', '1230', 'House no 3, Road 5/c, sector 11, Uttara', 'opt to that kind of lifestyle, I would rather sit alone on my a$$ with a book than booze and party, I would rather play exhausting sport than sit on my a$$ and read a book, I love the fragrance of wet mud, I like to dream, I am a teetotaler, and this bugs a lot of my buddies, If God gave me the power to remove any 3 vices from the world, I would remove: Politicians/Politics Greed and Jealousy, In my view breathing techniques, are the most advanced form of exercises. I have been trained in a few of these techniques, and someday I\'ll learn and', 'fsadfaf', '2023-01-12 06:07:40', '2023-01-21 10:34:33'),
(5, 17, 18, 'Fahad Ahmad Shemul', 'Bangladesh', 'Dhaka', 'North Carolina', '1230', 'House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh', 'opt to that kind of lifestyle, I would rather sit alone on my a$$ with a book than booze and party, I would rather play exhausting sport than sit on my a$$ and read a book, I love the fragrance of wet mud, I like to dream, I am a teetotaler, and this bugs a lot of my buddies, If God gave me the power to remove any 3 vices from the world, I would remove: Politicians/Politics Greed and Jealousy, In my view breathing techniques, are the most advanced form of exercises. I have been trained in a few of these techniques, and someday I\'ll learn and', 'fsadfaf', '2023-01-12 06:07:40', '2023-01-21 10:34:47'),
(6, 8, 21, 'Lamar Wilder', 'Dolore quibusdam aut', 'Omnis sit voluptas m', 'Et dolor eiusmod eni', '93092', 'Autem id in aliqua', 'Culpa dolore velit', 'Ut veniam et dolore', '2023-01-21 06:59:11', '2023-01-21 06:59:11'),
(7, 17, 21, 'Lamar Wilder', 'Dolore quibusdam aut', 'Omnis sit voluptas m', 'Et dolor eiusmod eni', '93092', 'Autem id in aliqua', 'Culpa dolore velit', 'Ut veniam et dolore', '2023-01-21 06:59:11', '2023-01-21 06:59:11'),
(8, 8, 22, 'Talon Beard', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2023-05-01 09:03:40', '2023-05-01 09:03:40'),
(9, 8, 23, 'Robert J. Murray', 'United States', 'Readsboro', 'North Carolina', '05350', 'Readsboro, North Carolina, United States', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups', 'Chief executive officer', '2023-05-02 09:50:29', '2023-05-07 11:03:02'),
(10, 22, 23, 'جوناس', 'الولايات المتحدة الأمريكية', 'ريدسبورو', 'نورث كارولينا', '05350', 'ريدسبورو ، نورث كارولينا ، الولايات المتحدة', 'من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم ا\r\nلأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.', 'الرئيس التنفيذي', '2023-05-02 09:51:44', '2023-05-07 11:03:02'),
(11, 27, 23, 'Fahad Ahmad Shemul', 'Bangladesh', 'Dhaka', 'North Carolina', '1230', 'House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh', NULL, 'fsadfaf', '2023-05-02 09:51:44', '2023-05-02 09:51:44'),
(12, 8, 24, 'Ken Champlin', 'Australia', 'Sydney', 'New South Wales', '59154', 'Elizabeth Bay NSW 2011, Sydney, Australia', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', 'ceo of abc', '2023-05-07 10:53:07', '2023-05-11 05:45:20'),
(13, 22, 24, 'ماجي برينس', 'أستراليا', 'سيدني', 'نيو ساوث ويلز', '59154', 'إليزابيث باي نيو ساوث ويلز 2011, سيدني, أستراليا', 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.', 'الرئيس التنفيذي لشركة عمار', '2023-05-07 10:53:07', '2023-05-07 10:53:07'),
(14, 8, 25, 'Ambrose Thiel', 'United States', 'Columbus', 'Ohio', '24855', 'Columbus, Ohio, United States', 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', 'Executive', '2023-05-07 10:57:11', '2023-05-11 05:44:46'),
(15, 22, 25, 'جوسلين كاش', 'الولايات المتحدة الأمريكية', 'كولومبوس', 'أوهايو', '24855', 'كولومبوس ، أوهايو ، الولايات المتحدة', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', 'تنفيذي', '2023-05-07 10:57:11', '2023-05-07 10:57:11'),
(16, 8, 26, 'Amber Cannon', 'United States', 'Tonopah', 'North Carolina', '69114', 'Tonopah, North Carolina, United States', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.', 'Chief marketing officer', '2023-05-07 11:01:23', '2023-05-07 11:01:23'),
(17, 22, 26, 'مدفع العنبر', 'الولايات المتحدة الأمريكية', 'تونوباه', 'نورث كارولينا', '69114', 'تونوباه ، كارولاينا الشمالية ، الولايات المتحدة', 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.', 'الرئيس التنفيذي للتسويق', '2023-05-07 11:01:23', '2023-05-07 11:01:23'),
(18, 8, 27, 'Burke Watts', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2023-05-11 05:59:10', '2023-05-11 05:59:10'),
(19, 8, 27, 'Magee Hernandez', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:10:02', '2025-11-05 07:10:02'),
(20, 8, 28, 'Kelly Gregory', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:10:21', '2025-11-05 07:10:21'),
(21, 8, 29, 'Xander Workman', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-05 07:12:57', '2025-11-05 07:12:57'),
(22, 8, 30, 'Caldwell Taylor', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2025-11-06 00:59:45', '2025-11-06 00:59:45');

-- --------------------------------------------------------

--
-- Table structure for table `pages`
--

CREATE TABLE `pages` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `pages`
--

INSERT INTO `pages` (`id`, `status`, `created_at`, `updated_at`) VALUES
(14, 1, '2021-10-18 02:33:45', '2021-10-18 02:33:45'),
(16, 1, '2023-05-20 04:53:32', '2023-05-20 04:53:32');

-- --------------------------------------------------------

--
-- Table structure for table `page_contents`
--

CREATE TABLE `page_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `page_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` blob NOT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `page_contents`
--

INSERT INTO `page_contents` (`id`, `language_id`, `page_id`, `title`, `slug`, `content`, `meta_keywords`, `meta_description`, `created_at`, `updated_at`) VALUES
(30, 8, 14, 'Terms & Conditions', 'terms-&-conditions', 0x3c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e57656c636f6d6520746f204576656e746f2e205468657365207465726d7320616e6420636f6e646974696f6e73206f75746c696e65207468652072756c657320616e6420726567756c6174696f6e7320666f722074686520757365206f66206f757220776562736974652e3c2f703e0a2020202020200a2020202020203c68353e312e20416363657074616e6365206f66205465726d733c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e427920616363657373696e6720616e64207573696e67206f757220776562736974652c20796f7520616772656520746f20626520626f756e64206279207468657365207465726d7320616e6420636f6e646974696f6e732e20496620796f7520646f206e6f7420616772656520746f207468657365207465726d7320616e6420636f6e646974696f6e732c20796f752073686f756c64206e6f7420757365206f757220776562736974652e3c2f703e0a2020202020200a2020202020203c68353e322e20496e74656c6c65637475616c2050726f70657274793c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e416c6c20696e74656c6c65637475616c2070726f70657274792072696768747320696e20746865207765627369746520616e642074686520636f6e74656e74207075626c6973686564206f6e2069742c20696e636c7564696e6720627574206e6f74206c696d6974656420746f20636f7079726967687420616e642074726164656d61726b732c20617265206f776e6564206279207573206f72206f7572206c6963656e736f72732e20596f75206d6179206e6f742075736520616e79206f66206f757220696e74656c6c65637475616c2070726f706572747920776974686f7574206f7572207072696f72207772697474656e20636f6e73656e742e3c2f703e0a2020202020200a2020202020203c68353e332e205573657220436f6e74656e743c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e4279207375626d697474696e6720616e7920636f6e74656e7420746f206f757220776562736974652c20796f75206772616e74207573206120776f726c64776964652c206e6f6e2d6578636c75736976652c20726f79616c74792d66726565206c6963656e736520746f207573652c20726570726f647563652c20646973747269627574652c20616e6420646973706c6179207375636820636f6e74656e7420696e20616e79206d6564696120666f726d61747320616e64207468726f75676820616e79206d65646961206368616e6e656c732e3c2f703e0a2020202020200a2020202020203c68353e342e20446973636c61696d6572206f662057617272616e746965733c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e4f7572207765627369746520616e642074686520636f6e74656e74207075626c6973686564206f6e206974206172652070726f7669646564206f6e20616e202261732069732220616e642022617320617661696c61626c65222062617369732e20576520646f206e6f74206d616b6520616e792077617272616e746965732c2065787072657373206f7220696d706c6965642c20726567617264696e672074686520776562736974652c20696e636c7564696e6720627574206e6f74206c696d6974656420746f207468652061636375726163792c2072656c696162696c6974792c206f7220737569746162696c697479206f662074686520636f6e74656e7420666f7220616e7920706172746963756c617220707572706f73652e3c2f703e0a2020202020200a2020202020203c68353e352e204c696d69746174696f6e206f66204c696162696c6974793c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e5765207368616c6c206e6f74206265206c6961626c6520666f7220616e792064616d616765732c20696e636c7564696e6720627574206e6f74206c696d6974656420746f206469726563742c20696e6469726563742c20696e636964656e74616c2c2070756e69746976652c20616e6420636f6e73657175656e7469616c2064616d616765732c2061726973696e672066726f6d2074686520757365206f7220696e6162696c69747920746f20757365206f75722077656273697465206f722074686520636f6e74656e74207075626c6973686564206f6e2069742e3c2f703e0a2020202020200a2020202020203c68353e362e204d6f64696669636174696f6e7320746f205465726d7320616e6420436f6e646974696f6e733c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e576520726573657276652074686520726967687420746f206d6f64696679207468657365207465726d7320616e6420636f6e646974696f6e7320617420616e792074696d6520776974686f7574207072696f72206e6f746963652e20596f757220636f6e74696e75656420757365206f66206f7572207765627369746520616674657220616e792073756368206d6f64696669636174696f6e7320696e6469636174657320796f757220616363657074616e6365206f6620746865206d6f646966696564207465726d7320616e6420636f6e646974696f6e732e3c2f703e0a2020202020200a2020202020203c68353e372e20476f7665726e696e67204c617720616e64204a7572697364696374696f6e3c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e5468657365207465726d7320616e6420636f6e646974696f6e73207368616c6c20626520676f7665726e656420627920616e6420636f6e73747275656420696e206163636f7264616e6365207769746820746865206c617773206f6620746865206a7572697364696374696f6e20696e207768696368207765206f7065726174652c20776974686f757420676976696e672065666665637420746f20616e79207072696e6369706c6573206f6620636f6e666c69637473206f66206c61772e20416e79206c6567616c2070726f63656564696e67732061726973696e67206f7574206f66206f7220696e20636f6e6e656374696f6e2077697468207468657365207465726d7320616e6420636f6e646974696f6e73207368616c6c2062652062726f7567687420736f6c656c7920696e2074686520636f75727473206c6f636174656420696e20746865206a7572697364696374696f6e20696e207768696368207765206f7065726174652e3c2f703e0a2020202020200a2020202020203c68353e382e205465726d696e6174696f6e3c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e5765206d6179207465726d696e617465206f722073757370656e6420796f75722061636365737320746f206f7572207765627369746520696d6d6564696174656c792c20776974686f7574207072696f72206e6f74696365206f72206c696162696c6974792c20666f7220616e7920726561736f6e2077686174736f657665722c20696e636c7564696e6720776974686f7574206c696d69746174696f6e20696620796f7520627265616368207468657365207465726d7320616e6420636f6e646974696f6e732e3c2f703e0a2020202020200a2020202020203c68353e392e20436f6e7461637420496e666f726d6174696f6e3c2f68353e0a2020202020203c70207374796c653d22636f6c6f723a233734373437343b666f6e742d66616d696c793a527562696b2c2073616e732d73657269663b223e496620796f75206861766520616e79207175657374696f6e73206f7220636f6d6d656e74732061626f7574207468657365207465726d7320616e6420636f6e646974696f6e732c20706c6561736520636f6e7461637420757320617420696e666f406576656e746f2e636f6d2e3c2f703e, 'terms', 'Unless otherwise stated, Evento and/or its licensors own the intellectual property rights for all material on Evento. All intellectual property rights are reserved. You may access this from Evento for your own personal use subjected to restrictions set in these terms and conditions.', '2021-10-18 02:33:45', '2023-05-18 08:11:05'),
(38, 22, 14, 'الشروط والأحكام', 'الشروط-والأحكام', 0x3c703ed985d8b1d8add8a8d8a720d8a8d983d98520d981d98a20d8a5d98ad981d98ad986d8aad9882e20d8aad8add8afd8af20d987d8b0d98720d8a7d984d8b4d8b1d988d8b720d988d8a7d984d8a3d8add983d8a7d98520d8a7d984d982d988d8a7d8b9d8af20d988d8a7d984d984d988d8a7d8a6d8ad20d8a7d984d8aed8a7d8b5d8a920d8a8d8a7d8b3d8aad8aed8afd8a7d98520d985d988d982d8b9d986d8a72e3c2f703e3c68353e3c6272202f3e3c2f68353e3c68353ed982d8a8d988d98420d8a7d984d8b4d8b1d988d8b73c2f68353e3c703ed985d98620d8aed984d8a7d98420d8a7d984d988d8b5d988d98420d8a5d984d98920d985d988d982d8b9d986d8a720d988d8a7d8b3d8aad8aed8afd8a7d985d98720d88c20d981d8a5d986d98320d8aad988d8a7d981d98220d8b9d984d98920d8a7d984d8a7d984d8aad8b2d8a7d98520d8a8d987d8b0d98720d8a7d984d8b4d8b1d988d8b720d988d8a7d984d8a3d8add983d8a7d9852e20d8a5d8b0d8a720d983d986d8aa20d984d8a720d8aad988d8a7d981d98220d8b9d984d98920d987d8b0d98720d8a7d984d8b4d8b1d988d8b720d988d8a7d984d8a3d8add983d8a7d98520d88c20d98ad8acd8a820d8b9d984d98ad98320d8b9d8afd98520d8a7d8b3d8aad8aed8afd8a7d98520d985d988d982d8b9d986d8a72e3c2f703e3c68353ed8a7d984d985d984d983d98ad8a920d8a7d984d981d983d8b1d98ad8a93c2f68353e3c703ed8acd985d98ad8b920d8add982d988d98220d8a7d984d985d984d983d98ad8a920d8a7d984d981d983d8b1d98ad8a920d981d98a20d8a7d984d985d988d982d8b920d988d8a7d984d985d8add8aad988d98920d8a7d984d985d986d8b4d988d8b120d8b9d984d98ad98720d88c20d8a8d985d8a720d981d98a20d8b0d984d98320d8b9d984d98920d8b3d8a8d98ad98420d8a7d984d985d8abd8a7d98420d984d8a720d8a7d984d8add8b5d8b120d8add982d988d98220d8a7d984d8b7d8a8d8b920d988d8a7d984d986d8b4d8b120d988d8a7d984d8b9d984d8a7d985d8a7d8aa20d8a7d984d8aad8acd8a7d8b1d98ad8a920d88c20d985d985d984d988d983d8a920d984d986d8a720d8a3d98820d984d984d985d8b1d8aed8b5d98ad98620d984d8afd98ad986d8a72e20d984d8a720d98ad8acd988d8b220d984d98320d8a7d8b3d8aad8aed8afd8a7d98520d8a3d98a20d985d98620696e7420d984d8afd98ad986d8a73c2f703e3c68353ed985d8add8aad988d98920d8a7d984d985d8b3d8aad8aed8afd9853c2f68353e3c703ed985d98620d8aed984d8a7d98420d8aad982d8afd98ad98520d8a3d98a20d985d8add8aad988d98920d8a5d984d98920d985d988d982d8b9d986d8a720d88c20d981d8a5d986d98320d8aad985d986d8add986d8a720d8aad8b1d8aed98ad8b5d8a720d8b9d8a7d984d985d98ad8a720d988d8bad98ad8b120d8add8b5d8b1d98a20d988d8aed8a7d984d98a20d985d98620d8add982d988d98220d8a7d984d985d984d983d98ad8a920d984d8a7d8b3d8aad8aed8afd8a7d98520d987d8b0d8a720d8a7d984d985d8add8aad988d98920d988d8a5d8b9d8a7d8afd8a920d8a5d986d8aad8a7d8acd98720d988d8aad988d8b2d98ad8b9d98720d988d8b9d8b1d8b6d98720d8a8d8a3d98a20d8aad986d8b3d98ad98220d988d8b3d8a7d8a6d8b720d988d985d98620d8aed984d8a7d98420d8a3d98a20d988d8b3d98ad984d8a920d8a5d8b9d984d8a7d985d98ad8a92e3c2f703e3c68353ed8a5d8aed984d8a7d8a120d8a7d984d985d8b3d8a4d988d984d98ad8a920d8b9d98620d8a7d984d8b6d985d8a7d986d8a7d8aa3c2f68353e3c703ed98ad8aad98520d8aad988d981d98ad8b120d985d988d982d8b9d986d8a720d8a7d984d8a5d984d983d8aad8b1d988d986d98a20d988d8a7d984d985d8add8aad988d98920d8a7d984d985d986d8b4d988d8b120d8b9d984d98ad98720d8b9d984d98920d8a3d8b3d8a7d8b32022d983d985d8a720d987d9882220d9882022d983d985d8a720d987d98820d985d8aad8a7d8ad222e20d986d8add98620d984d8a720d986d982d8afd98520d8a3d98a20d8b6d985d8a7d986d8a7d8aa20d88c20d8b5d8b1d98ad8add8a920d8a3d98820d8b6d985d986d98ad8a920d88c20d981d98ad985d8a720d98ad8aad8b9d984d98220d8a8d8a7d984d985d988d982d8b920d88c20d8a8d985d8a720d981d98a20d8b0d984d98320d8b9d984d98920d8b3d8a8d98ad98420d8a7d984d985d8abd8a7d98420d984d8a720d8a7d984d8add8b5d8b13c2f703e3c68353ed8aad8add8afd98ad8af20d8a7d984d985d8b3d8a4d988d984d98ad8a93c2f68353e3c703ed984d98620d986d983d988d98620d985d8b3d8a4d988d984d98ad98620d8b9d98620d8a3d98a20d8a3d8b6d8b1d8a7d8b120d88c20d8a8d985d8a720d981d98a20d8b0d984d98320d8b9d984d98920d8b3d8a8d98ad98420d8a7d984d985d8abd8a7d98420d984d8a720d8a7d984d8add8b5d8b120d8a7d984d8a3d8b6d8b1d8a7d8b120d8a7d984d985d8a8d8a7d8b4d8b1d8a920d988d8bad98ad8b120d8a7d984d985d8a8d8a7d8b4d8b1d8a920d988d8a7d984d8b9d8b1d8b6d98ad8a920d988d8a7d984d8b9d982d8a7d8a8d98ad8a920d988d8a7d984d8aad8a8d8b9d98ad8a920d88c20d8a7d984d986d8a7d8b4d8a6d8a920d8b9d98620d8a7d8b3d8aad8aed8afd8a7d98520d8a3d98820d8b9d8afd98520d8a7d984d982d8afd8b1d8a920d8b9d984d98920d8a7d8b3d8aad8aed8afd8a7d98520d985d988d982d8b9d986d8a720d8a3d98820d8a7d984d985d982d8a7d988d984d8a7d8aa2e3c2f703e3c68353ed8a7d984d8aad8b9d8afd98ad984d8a7d8aa20d8b9d984d98920d8a7d984d8b4d8b1d988d8b720d988d8a7d984d8a3d8add983d8a7d9853c2f68353e3c703ed986d8add8aad981d8b820d8a8d8a7d984d8add98220d981d98a20d8aad8b9d8afd98ad98420d987d8b0d98720d8a7d984d8b4d8b1d988d8b720d988d8a7d984d8a3d8add983d8a7d98520d981d98a20d8a3d98a20d988d982d8aa20d8afd988d98620d8a5d8b4d8b9d8a7d8b120d985d8b3d8a8d9822e20d8a5d98620d8a7d8b3d8aad985d8b1d8a7d8b1d98320d981d98a20d8a7d8b3d8aad8aed8afd8a7d98520d985d988d982d8b9d986d8a720d8a7d984d8a5d984d983d8aad8b1d988d986d98a20d8a8d8b9d8af20d8a3d98a20d8aad8b9d8afd98ad984d8a7d8aa20d985d98620d987d8b0d8a720d8a7d984d982d8a8d98ad98420d98ad8b4d98ad8b120d8a5d984d98920d985d988d8a7d981d982d8aad98320d8b9d984d98920d8a7d984d8aad8b9d8afd98ad98420d8a7d984d8abd8a7d984d8ab2e3c6272202f3e3c2f703e, NULL, NULL, '2023-05-08 07:33:27', '2023-05-08 07:33:27'),
(39, 8, 16, 'Privacy Policy', 'privacy-policy', 0x3c703e5072697661637920506f6c6963793c2f703e0d0a3c703e54686973205072697661637920506f6c69637920646573637269626573204f757220706f6c696369657320616e642070726f63656475726573206f6e2074686520636f6c6c656374696f6e2c2075736520616e6420646973636c6f73757265206f6620596f757220696e666f726d6174696f6e207768656e20596f752075736520746865205365727669636520616e642074656c6c7320596f752061626f757420596f757220707269766163792072696768747320616e6420686f7720746865206c61772070726f746563747320596f752e3c2f703e0d0a3c703e57652075736520596f757220506572736f6e616c206461746120746f2070726f7669646520616e6420696d70726f76652074686520536572766963652e204279207573696e672074686520536572766963652c20596f7520616772656520746f2074686520636f6c6c656374696f6e20616e6420757365206f6620696e666f726d6174696f6e20696e206163636f7264616e636520776974682074686973205072697661637920506f6c6963792ec2a03c2f703e0d0a3c68343e496e746572707265746174696f6e3c2f68343e0d0a3c703e54686520776f726473206f662077686963682074686520696e697469616c206c6574746572206973206361706974616c697a65642068617665206d65616e696e677320646566696e656420756e6465722074686520666f6c6c6f77696e6720636f6e646974696f6e732e2054686520666f6c6c6f77696e6720646566696e6974696f6e73207368616c6c2068617665207468652073616d65206d65616e696e67207265676172646c657373206f66207768657468657220746865792061707065617220696e2073696e67756c6172206f7220696e20706c7572616c2e3c2f703e0d0a3c68343e446566696e6974696f6e733c2f68343e0d0a3c703e466f722074686520707572706f736573206f662074686973205072697661637920506f6c6963793a3c2f703e0d0a3c756c3e0d0a3c6c693e0d0a3c703e3c7374726f6e673e4163636f756e743c2f7374726f6e673e206d65616e73206120756e69717565206163636f756e74206372656174656420666f7220596f7520746f20616363657373206f75722053657276696365206f72207061727473206f66206f757220536572766963652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e416666696c696174653c2f7374726f6e673e206d65616e7320616e20656e74697479207468617420636f6e74726f6c732c20697320636f6e74726f6c6c6564206279206f7220697320756e64657220636f6d6d6f6e20636f6e74726f6c207769746820612070617274792c2077686572652022636f6e74726f6c22206d65616e73206f776e657273686970206f6620353025206f72206d6f7265206f6620746865207368617265732c2065717569747920696e746572657374206f72206f74686572207365637572697469657320656e7469746c656420746f20766f746520666f7220656c656374696f6e206f66206469726563746f7273206f72206f74686572206d616e6167696e6720617574686f726974792e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e436f6d70616e793c2f7374726f6e673e2028726566657272656420746f20617320656974686572202274686520436f6d70616e79222c20225765222c2022557322206f7220224f75722220696e20746869732041677265656d656e74292072656665727320746f204576656e746f2e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e436f6f6b6965733c2f7374726f6e673e2061726520736d616c6c2066696c657320746861742061726520706c61636564206f6e20596f757220636f6d70757465722c206d6f62696c6520646576696365206f7220616e79206f7468657220646576696365206279206120776562736974652c20636f6e7461696e696e67207468652064657461696c73206f6620596f75722062726f7773696e6720686973746f7279206f6e2074686174207765627369746520616d6f6e6720697473206d616e7920757365732e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e436f756e7472793c2f7374726f6e673e2072656665727320746f3a20416c61736b612c20556e69746564205374617465733c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e4465766963653c2f7374726f6e673e206d65616e7320616e792064657669636520746861742063616e206163636573732074686520536572766963652073756368206173206120636f6d70757465722c20612063656c6c70686f6e65206f722061206469676974616c207461626c65742e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e506572736f6e616c20446174613c2f7374726f6e673e20697320616e7920696e666f726d6174696f6e20746861742072656c6174657320746f20616e206964656e746966696564206f72206964656e7469666961626c6520696e646976696475616c2e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e536572766963653c2f7374726f6e673e2072656665727320746f2074686520576562736974652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e536572766963652050726f76696465723c2f7374726f6e673e206d65616e7320616e79206e61747572616c206f72206c6567616c20706572736f6e2077686f2070726f636573736573207468652064617461206f6e20626568616c66206f662074686520436f6d70616e792e2049742072656665727320746f2074686972642d706172747920636f6d70616e696573206f7220696e646976696475616c7320656d706c6f7965642062792074686520436f6d70616e7920746f20666163696c69746174652074686520536572766963652c20746f2070726f76696465207468652053657276696365206f6e20626568616c66206f662074686520436f6d70616e792c20746f20706572666f726d2073657276696365732072656c6174656420746f207468652053657276696365206f7220746f206173736973742074686520436f6d70616e7920696e20616e616c797a696e6720686f7720746865205365727669636520697320757365642e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e54686972642d706172747920536f6369616c204d6564696120536572766963653c2f7374726f6e673e2072656665727320746f20616e792077656273697465206f7220616e7920736f6369616c206e6574776f726b2077656273697465207468726f756768207768696368206120557365722063616e206c6f6720696e206f722063726561746520616e206163636f756e7420746f207573652074686520536572766963652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e557361676520446174613c2f7374726f6e673e2072656665727320746f206461746120636f6c6c6563746564206175746f6d61746963616c6c792c206569746865722067656e6572617465642062792074686520757365206f66207468652053657276696365206f722066726f6d20746865205365727669636520696e66726173747275637475726520697473656c662028666f72206578616d706c652c20746865206475726174696f6e206f6620612070616765207669736974292e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e576562736974653c2f7374726f6e673e2072656665727320746f204576656e746f2c2061636365737369626c652066726f6d203c6120687265663d2268747470733a2f2f636f646563616e796f6e382e6b7265617469766465762e636f6d2f6576656e746f223e68747470733a2f2f636f646563616e796f6e382e6b7265617469766465762e636f6d2f6576656e746f3c2f613e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e596f753c2f7374726f6e673e206d65616e732074686520696e646976696475616c20616363657373696e67206f72207573696e672074686520536572766963652c206f722074686520636f6d70616e792c206f72206f74686572206c6567616c20656e74697479206f6e20626568616c66206f66207768696368207375636820696e646976696475616c20697320616363657373696e67206f72207573696e672074686520536572766963652c206173206170706c696361626c652e3c2f703e0d0a3c2f6c693e0d0a3c2f756c3e0d0a3c703e436f6c6c656374696e6720616e64205573696e6720596f757220506572736f6e616c20446174613c2f703e0d0a3c703ec2a03c2f703e0d0a3c68343e3c7370616e207374796c653d22666f6e742d73697a653a312e3033373572656d3b666f6e742d7765696768743a626f6c643b223e506572736f6e616c20446174613c2f7370616e3e3c2f68343e0d0a3c703e5768696c65207573696e67204f757220536572766963652c205765206d61792061736b20596f7520746f2070726f766964652055732077697468206365727461696e20706572736f6e616c6c79206964656e7469666961626c6520696e666f726d6174696f6e20746861742063616e206265207573656420746f20636f6e74616374206f72206964656e7469667920596f752e20506572736f6e616c6c79206964656e7469666961626c6520696e666f726d6174696f6e206d617920696e636c7564652c20627574206973206e6f74206c696d6974656420746f3a3c2f703e0d0a3c756c3e0d0a3c6c693e0d0a3c703e456d61696c20616464726573733c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e4669727374206e616d6520616e64206c617374206e616d653c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e50686f6e65206e756d6265723c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e416464726573732c2053746174652c2050726f76696e63652c205a49502f506f7374616c20636f64652c20436974793c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e557361676520446174613c2f703e0d0a3c2f6c693e0d0a3c2f756c3e0d0a3c68343e557361676520446174613c2f68343e0d0a3c703e5573616765204461746120697320636f6c6c6563746564206175746f6d61746963616c6c79207768656e207573696e672074686520536572766963652e3c2f703e0d0a3c703e55736167652044617461206d617920696e636c75646520696e666f726d6174696f6e207375636820617320596f757220446576696365277320496e7465726e65742050726f746f636f6c20616464726573732028652e672e2049502061646472657373292c2062726f7773657220747970652c2062726f777365722076657273696f6e2c20746865207061676573206f66206f75722053657276696365207468617420596f752076697369742c207468652074696d6520616e642064617465206f6620596f75722076697369742c207468652074696d65207370656e74206f6e2074686f73652070616765732c20756e6971756520646576696365206964656e7469666965727320616e64206f7468657220646961676e6f7374696320646174612e3c2f703e0d0a3c703e5768656e20596f7520616363657373207468652053657276696365206279206f72207468726f7567682061206d6f62696c65206465766963652c205765206d617920636f6c6c656374206365727461696e20696e666f726d6174696f6e206175746f6d61746963616c6c792c20696e636c7564696e672c20627574206e6f74206c696d6974656420746f2c207468652074797065206f66206d6f62696c652064657669636520596f75207573652c20596f7572206d6f62696c652064657669636520756e697175652049442c207468652049502061646472657373206f6620596f7572206d6f62696c65206465766963652c20596f7572206d6f62696c65206f7065726174696e672073797374656d2c207468652074797065206f66206d6f62696c6520496e7465726e65742062726f7773657220596f75207573652c20756e6971756520646576696365206964656e7469666965727320616e64206f7468657220646961676e6f7374696320646174612e3c2f703e0d0a3c703e5765206d617920616c736f20636f6c6c65637420696e666f726d6174696f6e207468617420596f75722062726f777365722073656e6473207768656e6576657220596f75207669736974206f75722053657276696365206f72207768656e20596f7520616363657373207468652053657276696365206279206f72207468726f7567682061206d6f62696c65206465766963652e3c2f703e0d0a3c68343e496e666f726d6174696f6e2066726f6d2054686972642d506172747920536f6369616c204d656469612053657276696365733c2f68343e0d0a3c703e54686520436f6d70616e7920616c6c6f777320596f7520746f2063726561746520616e206163636f756e7420616e64206c6f6720696e20746f20757365207468652053657276696365207468726f7567682074686520666f6c6c6f77696e672054686972642d706172747920536f6369616c204d656469612053657276696365733a3c2f703e0d0a3c756c3e0d0a3c6c693e476f6f676c653c2f6c693e0d0a3c6c693e46616365626f6f6b3c2f6c693e0d0a3c2f756c3e0d0a3c703e496620596f752064656369646520746f207265676973746572207468726f756768206f72206f7468657277697365206772616e742075732061636365737320746f20612054686972642d506172747920536f6369616c204d6564696120536572766963652c205765206d617920636f6c6c65637420506572736f6e616c2064617461207468617420697320616c7265616479206173736f636961746564207769746820596f75722054686972642d506172747920536f6369616c204d6564696120536572766963652773206163636f756e742c207375636820617320596f7572206e616d652c20596f757220656d61696c20616464726573732c20596f75722061637469766974696573206f7220596f757220636f6e74616374206c697374206173736f63696174656420776974682074686174206163636f756e742e3c2f703e0d0a3c703e596f75206d617920616c736f206861766520746865206f7074696f6e206f662073686172696e67206164646974696f6e616c20696e666f726d6174696f6e20776974682074686520436f6d70616e79207468726f75676820596f75722054686972642d506172747920536f6369616c204d6564696120536572766963652773206163636f756e742e20496620596f752063686f6f736520746f2070726f76696465207375636820696e666f726d6174696f6e20616e6420506572736f6e616c20446174612c20647572696e6720726567697374726174696f6e206f72206f74686572776973652c20596f752061726520676976696e672074686520436f6d70616e79207065726d697373696f6e20746f207573652c2073686172652c20616e642073746f726520697420696e2061206d616e6e657220636f6e73697374656e7420776974682074686973205072697661637920506f6c6963792e3c2f703e0d0a3c68343e547261636b696e6720546563686e6f6c6f6769657320616e6420436f6f6b6965733c2f68343e0d0a3c703e57652075736520436f6f6b69657320616e642073696d696c617220747261636b696e6720746563686e6f6c6f6769657320746f20747261636b20746865206163746976697479206f6e204f7572205365727669636520616e642073746f7265206365727461696e20696e666f726d6174696f6e2e20547261636b696e6720746563686e6f6c6f6769657320757365642061726520626561636f6e732c20746167732c20616e64207363726970747320746f20636f6c6c65637420616e6420747261636b20696e666f726d6174696f6e20616e6420746f20696d70726f766520616e6420616e616c797a65204f757220536572766963652e2054686520746563686e6f6c6f6769657320576520757365206d617920696e636c7564653a3c2f703e0d0a3c756c3e0d0a3c6c693e3c7374726f6e673e436f6f6b696573206f722042726f7773657220436f6f6b6965732e3c2f7374726f6e673e204120636f6f6b6965206973206120736d616c6c2066696c6520706c61636564206f6e20596f7572204465766963652e20596f752063616e20696e73747275637420596f75722062726f7773657220746f2072656675736520616c6c20436f6f6b696573206f7220746f20696e646963617465207768656e206120436f6f6b6965206973206265696e672073656e742e20486f77657665722c20696620596f7520646f206e6f742061636365707420436f6f6b6965732c20596f75206d6179206e6f742062652061626c6520746f2075736520736f6d65207061727473206f66206f757220536572766963652e20556e6c65737320796f7520686176652061646a757374656420596f75722062726f777365722073657474696e6720736f20746861742069742077696c6c2072656675736520436f6f6b6965732c206f75722053657276696365206d61792075736520436f6f6b6965732e3c2f6c693e0d0a3c6c693e3c7374726f6e673e57656220426561636f6e732e3c2f7374726f6e673e204365727461696e2073656374696f6e73206f66206f7572205365727669636520616e64206f757220656d61696c73206d617920636f6e7461696e20736d616c6c20656c656374726f6e69632066696c6573206b6e6f776e2061732077656220626561636f6e732028616c736f20726566657272656420746f20617320636c65617220676966732c20706978656c20746167732c20616e642073696e676c652d706978656c2067696673292074686174207065726d69742074686520436f6d70616e792c20666f72206578616d706c652c20746f20636f756e742075736572732077686f206861766520766973697465642074686f7365207061676573206f72206f70656e656420616e20656d61696c20616e6420666f72206f746865722072656c61746564207765627369746520737461746973746963732028666f72206578616d706c652c207265636f7264696e672074686520706f70756c6172697479206f662061206365727461696e2073656374696f6e20616e6420766572696679696e672073797374656d20616e642073657276657220696e74656772697479292e3c2f6c693e0d0a3c2f756c3e0d0a3c703e436f6f6b6965732063616e206265202250657273697374656e7422206f72202253657373696f6e2220436f6f6b6965732e2050657273697374656e7420436f6f6b6965732072656d61696e206f6e20596f757220706572736f6e616c20636f6d7075746572206f72206d6f62696c6520646576696365207768656e20596f7520676f206f66666c696e652c207768696c652053657373696f6e20436f6f6b696573206172652064656c6574656420617320736f6f6e20617320596f7520636c6f736520596f7572207765622062726f777365722e204c6561726e206d6f72652061626f757420636f6f6b696573206f6e20746865203c6120687265663d2268747470733a2f2f7777772e6672656570726976616379706f6c6963792e636f6d2f626c6f672f73616d706c652d707269766163792d706f6c6963792d74656d706c6174652f235573655f4f665f436f6f6b6965735f416e645f547261636b696e67223e46726565205072697661637920506f6c69637920776562736974653c2f613e2061727469636c652e3c2f703e0d0a3c703e57652075736520626f74682053657373696f6e20616e642050657273697374656e7420436f6f6b69657320666f722074686520707572706f73657320736574206f75742062656c6f773a3c2f703e0d0a3c756c3e0d0a3c6c693e0d0a3c703e3c7374726f6e673e4e6563657373617279202f20457373656e7469616c20436f6f6b6965733c2f7374726f6e673e3c2f703e0d0a3c703e547970653a2053657373696f6e20436f6f6b6965733c2f703e0d0a3c703e41646d696e697374657265642062793a2055733c2f703e0d0a3c703e507572706f73653a20546865736520436f6f6b6965732061726520657373656e7469616c20746f2070726f7669646520596f75207769746820736572766963657320617661696c61626c65207468726f75676820746865205765627369746520616e6420746f20656e61626c6520596f7520746f2075736520736f6d65206f66206974732066656174757265732e20546865792068656c7020746f2061757468656e74696361746520757365727320616e642070726576656e74206672617564756c656e7420757365206f662075736572206163636f756e74732e20576974686f757420746865736520436f6f6b6965732c20746865207365727669636573207468617420596f7520686176652061736b656420666f722063616e6e6f742062652070726f76696465642c20616e64205765206f6e6c792075736520746865736520436f6f6b69657320746f2070726f7669646520596f7520776974682074686f73652073657276696365732e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e436f6f6b69657320506f6c696379202f204e6f7469636520416363657074616e636520436f6f6b6965733c2f7374726f6e673e3c2f703e0d0a3c703e547970653a2050657273697374656e7420436f6f6b6965733c2f703e0d0a3c703e41646d696e697374657265642062793a2055733c2f703e0d0a3c703e507572706f73653a20546865736520436f6f6b696573206964656e7469667920696620757365727320686176652061636365707465642074686520757365206f6620636f6f6b696573206f6e2074686520576562736974652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e46756e6374696f6e616c69747920436f6f6b6965733c2f7374726f6e673e3c2f703e0d0a3c703e547970653a2050657273697374656e7420436f6f6b6965733c2f703e0d0a3c703e41646d696e697374657265642062793a2055733c2f703e0d0a3c703e507572706f73653a20546865736520436f6f6b69657320616c6c6f7720757320746f2072656d656d6265722063686f6963657320596f75206d616b65207768656e20596f75207573652074686520576562736974652c20737563682061732072656d656d626572696e6720796f7572206c6f67696e2064657461696c73206f72206c616e677561676520707265666572656e63652e2054686520707572706f7365206f6620746865736520436f6f6b69657320697320746f2070726f7669646520596f7520776974682061206d6f726520706572736f6e616c20657870657269656e636520616e6420746f2061766f696420596f7520686176696e6720746f2072652d656e74657220796f757220707265666572656e6365732065766572792074696d6520596f75207573652074686520576562736974652e3c2f703e0d0a3c2f6c693e0d0a3c2f756c3e0d0a3c703e466f72206d6f726520696e666f726d6174696f6e2061626f75742074686520636f6f6b6965732077652075736520616e6420796f75722063686f6963657320726567617264696e6720636f6f6b6965732c20706c65617365207669736974206f757220436f6f6b69657320506f6c696379206f722074686520436f6f6b6965732073656374696f6e206f66206f7572205072697661637920506f6c6963792e3c2f703e0d0a3c68343e557365206f6620596f757220506572736f6e616c20446174613c2f68343e0d0a3c703e54686520436f6d70616e79206d61792075736520506572736f6e616c204461746120666f722074686520666f6c6c6f77696e6720707572706f7365733a3c2f703e0d0a3c756c3e0d0a3c6c693e0d0a3c703e3c7374726f6e673e546f2070726f7669646520616e64206d61696e7461696e206f757220536572766963653c2f7374726f6e673e2c20696e636c7564696e6720746f206d6f6e69746f7220746865207573616765206f66206f757220536572766963652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e546f206d616e61676520596f7572204163636f756e743a3c2f7374726f6e673e20746f206d616e61676520596f757220726567697374726174696f6e20617320612075736572206f662074686520536572766963652e2054686520506572736f6e616c204461746120596f752070726f766964652063616e206769766520596f752061636365737320746f20646966666572656e742066756e6374696f6e616c6974696573206f6620746865205365727669636520746861742061726520617661696c61626c6520746f20596f752061732061207265676973746572656420757365722e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e466f722074686520706572666f726d616e6365206f66206120636f6e74726163743a3c2f7374726f6e673e2074686520646576656c6f706d656e742c20636f6d706c69616e636520616e6420756e64657274616b696e67206f662074686520707572636861736520636f6e747261637420666f72207468652070726f64756374732c206974656d73206f7220736572766963657320596f75206861766520707572636861736564206f72206f6620616e79206f7468657220636f6e74726163742077697468205573207468726f7567682074686520536572766963652e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e546f20636f6e7461637420596f753a3c2f7374726f6e673e20546f20636f6e7461637420596f7520627920656d61696c2c2074656c6570686f6e652063616c6c732c20534d532c206f72206f74686572206571756976616c656e7420666f726d73206f6620656c656374726f6e696320636f6d6d756e69636174696f6e2c20737563682061732061206d6f62696c65206170706c69636174696f6e27732070757368206e6f74696669636174696f6e7320726567617264696e672075706461746573206f7220696e666f726d617469766520636f6d6d756e69636174696f6e732072656c6174656420746f207468652066756e6374696f6e616c69746965732c2070726f6475637473206f7220636f6e747261637465642073657276696365732c20696e636c7564696e672074686520736563757269747920757064617465732c207768656e206e6563657373617279206f7220726561736f6e61626c6520666f7220746865697220696d706c656d656e746174696f6e2e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e546f2070726f7669646520596f753c2f7374726f6e673e2077697468206e6577732c207370656369616c206f666665727320616e642067656e6572616c20696e666f726d6174696f6e2061626f7574206f7468657220676f6f64732c20736572766963657320616e64206576656e7473207768696368207765206f666665722074686174206172652073696d696c617220746f2074686f7365207468617420796f75206861766520616c726561647920707572636861736564206f7220656e7175697265642061626f757420756e6c65737320596f752068617665206f70746564206e6f7420746f2072656365697665207375636820696e666f726d6174696f6e2e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e546f206d616e61676520596f75722072657175657374733a3c2f7374726f6e673e20546f20617474656e6420616e64206d616e61676520596f757220726571756573747320746f2055732e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e466f7220627573696e657373207472616e73666572733a3c2f7374726f6e673e205765206d61792075736520596f757220696e666f726d6174696f6e20746f206576616c75617465206f7220636f6e647563742061206d65726765722c2064697665737469747572652c2072657374727563747572696e672c2072656f7267616e697a6174696f6e2c20646973736f6c7574696f6e2c206f72206f746865722073616c65206f72207472616e73666572206f6620736f6d65206f7220616c6c206f66204f7572206173736574732c2077686574686572206173206120676f696e6720636f6e6365726e206f722061732070617274206f662062616e6b7275707463792c206c69717569646174696f6e2c206f722073696d696c61722070726f63656564696e672c20696e20776869636820506572736f6e616c20446174612068656c642062792055732061626f7574206f7572205365727669636520757365727320697320616d6f6e672074686520617373657473207472616e736665727265642e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703e3c7374726f6e673e466f72206f7468657220707572706f7365733c2f7374726f6e673e3a205765206d61792075736520596f757220696e666f726d6174696f6e20666f72206f7468657220707572706f7365732c2073756368206173206461746120616e616c797369732c206964656e74696679696e67207573616765207472656e64732c2064657465726d696e696e6720746865206566666563746976656e657373206f66206f75722070726f6d6f74696f6e616c2063616d706169676e7320616e6420746f206576616c7561746520616e6420696d70726f7665206f757220536572766963652c2070726f64756374732c2073657276696365732c206d61726b6574696e6720616e6420796f757220657870657269656e63652e3c2f703e0d0a3c2f6c693e0d0a3c2f756c3e0d0a3c703e5765206d617920736861726520596f757220706572736f6e616c20696e666f726d6174696f6e20696e2074686520666f6c6c6f77696e6720736974756174696f6e733a3c2f703e0d0a3c756c3e0d0a3c6c693e3c7374726f6e673e5769746820536572766963652050726f7669646572733a3c2f7374726f6e673e205765206d617920736861726520596f757220706572736f6e616c20696e666f726d6174696f6e207769746820536572766963652050726f76696465727320746f206d6f6e69746f7220616e6420616e616c797a652074686520757365206f66206f757220536572766963652c20746f20636f6e7461637420596f752e3c2f6c693e0d0a3c6c693e3c7374726f6e673e466f7220627573696e657373207472616e73666572733a3c2f7374726f6e673e205765206d6179207368617265206f72207472616e7366657220596f757220706572736f6e616c20696e666f726d6174696f6e20696e20636f6e6e656374696f6e20776974682c206f7220647572696e67206e65676f74696174696f6e73206f662c20616e79206d65726765722c2073616c65206f6620436f6d70616e79206173736574732c2066696e616e63696e672c206f72206163717569736974696f6e206f6620616c6c206f72206120706f7274696f6e206f66204f757220627573696e65737320746f20616e6f7468657220636f6d70616e792e3c2f6c693e0d0a3c6c693e3c7374726f6e673e5769746820416666696c69617465733a3c2f7374726f6e673e205765206d617920736861726520596f757220696e666f726d6174696f6e2077697468204f757220616666696c69617465732c20696e20776869636820636173652077652077696c6c20726571756972652074686f736520616666696c696174657320746f20686f6e6f722074686973205072697661637920506f6c6963792e20416666696c696174657320696e636c756465204f757220706172656e7420636f6d70616e7920616e6420616e79206f74686572207375627369646961726965732c206a6f696e742076656e7475726520706172746e657273206f72206f7468657220636f6d70616e696573207468617420576520636f6e74726f6c206f7220746861742061726520756e64657220636f6d6d6f6e20636f6e74726f6c20776974682055732e3c2f6c693e0d0a3c6c693e3c7374726f6e673e5769746820627573696e65737320706172746e6572733a3c2f7374726f6e673e205765206d617920736861726520596f757220696e666f726d6174696f6e2077697468204f757220627573696e65737320706172746e65727320746f206f6666657220596f75206365727461696e2070726f64756374732c207365727669636573206f722070726f6d6f74696f6e732e3c2f6c693e0d0a3c6c693e3c7374726f6e673e57697468206f746865722075736572733a3c2f7374726f6e673e207768656e20596f7520736861726520706572736f6e616c20696e666f726d6174696f6e206f72206f746865727769736520696e74657261637420696e20746865207075626c69632061726561732077697468206f746865722075736572732c207375636820696e666f726d6174696f6e206d61792062652076696577656420627920616c6c20757365727320616e64206d6179206265207075626c69636c79206469737472696275746564206f7574736964652e20496620596f7520696e7465726163742077697468206f74686572207573657273206f72207265676973746572207468726f75676820612054686972642d506172747920536f6369616c204d6564696120536572766963652c20596f757220636f6e7461637473206f6e207468652054686972642d506172747920536f6369616c204d656469612053657276696365206d61792073656520596f7572206e616d652c2070726f66696c652c20706963747572657320616e64206465736372697074696f6e206f6620596f75722061637469766974792e2053696d696c61726c792c206f746865722075736572732077696c6c2062652061626c6520746f2076696577206465736372697074696f6e73206f6620596f75722061637469766974792c20636f6d6d756e6963617465207769746820596f7520616e64207669657720596f75722070726f66696c652e3c2f6c693e0d0a3c6c693e3c7374726f6e673e5769746820596f757220636f6e73656e743c2f7374726f6e673e3a205765206d617920646973636c6f736520596f757220706572736f6e616c20696e666f726d6174696f6e20666f7220616e79206f7468657220707572706f7365207769746820596f757220636f6e73656e742e3c2f6c693e0d0a3c2f756c3e0d0a3c68343e526574656e74696f6e206f6620596f757220506572736f6e616c20446174613c2f68343e0d0a3c703e54686520436f6d70616e792077696c6c2072657461696e20596f757220506572736f6e616c2044617461206f6e6c7920666f72206173206c6f6e67206173206973206e656365737361727920666f722074686520707572706f73657320736574206f757420696e2074686973205072697661637920506f6c6963792e2057652077696c6c2072657461696e20616e642075736520596f757220506572736f6e616c204461746120746f2074686520657874656e74206e656365737361727920746f20636f6d706c792077697468206f7572206c6567616c206f626c69676174696f6e732028666f72206578616d706c652c2069662077652061726520726571756972656420746f2072657461696e20796f7572206461746120746f20636f6d706c792077697468206170706c696361626c65206c617773292c207265736f6c76652064697370757465732c20616e6420656e666f726365206f7572206c6567616c2061677265656d656e747320616e6420706f6c69636965732e3c2f703e0d0a3c703e54686520436f6d70616e792077696c6c20616c736f2072657461696e205573616765204461746120666f7220696e7465726e616c20616e616c7973697320707572706f7365732e20557361676520446174612069732067656e6572616c6c792072657461696e656420666f7220612073686f7274657220706572696f64206f662074696d652c20657863657074207768656e20746869732064617461206973207573656420746f20737472656e677468656e20746865207365637572697479206f7220746f20696d70726f7665207468652066756e6374696f6e616c697479206f66204f757220536572766963652c206f7220576520617265206c6567616c6c79206f626c69676174656420746f2072657461696e2074686973206461746120666f72206c6f6e6765722074696d6520706572696f64732e3c2f703e0d0a3c68343e5472616e73666572206f6620596f757220506572736f6e616c20446174613c2f68343e0d0a3c703e596f757220696e666f726d6174696f6e2c20696e636c7564696e6720506572736f6e616c20446174612c2069732070726f6365737365642061742074686520436f6d70616e792773206f7065726174696e67206f66666963657320616e6420696e20616e79206f7468657220706c6163657320776865726520746865207061727469657320696e766f6c76656420696e207468652070726f63657373696e6720617265206c6f63617465642e204974206d65616e732074686174207468697320696e666f726d6174696f6e206d6179206265207472616e7366657272656420746f20e2809420616e64206d61696e7461696e6564206f6e20e2809420636f6d707574657273206c6f6361746564206f757473696465206f6620596f75722073746174652c2070726f76696e63652c20636f756e747279206f72206f7468657220676f7665726e6d656e74616c206a7572697364696374696f6e2077686572652074686520646174612070726f74656374696f6e206c617773206d617920646966666572207468616e2074686f73652066726f6d20596f7572206a7572697364696374696f6e2e3c2f703e0d0a3c703e596f757220636f6e73656e7420746f2074686973205072697661637920506f6c69637920666f6c6c6f77656420627920596f7572207375626d697373696f6e206f66207375636820696e666f726d6174696f6e20726570726573656e747320596f75722061677265656d656e7420746f2074686174207472616e736665722e3c2f703e0d0a3c703e54686520436f6d70616e792077696c6c2074616b6520616c6c20737465707320726561736f6e61626c79206e656365737361727920746f20656e73757265207468617420596f757220646174612069732074726561746564207365637572656c7920616e6420696e206163636f7264616e636520776974682074686973205072697661637920506f6c69637920616e64206e6f207472616e73666572206f6620596f757220506572736f6e616c20446174612077696c6c2074616b6520706c61636520746f20616e206f7267616e697a6174696f6e206f72206120636f756e74727920756e6c6573732074686572652061726520616465717561746520636f6e74726f6c7320696e20706c61636520696e636c7564696e6720746865207365637572697479206f6620596f7572206461746120616e64206f7468657220706572736f6e616c20696e666f726d6174696f6e2e3c2f703e0d0a3c68343e44656c65746520596f757220506572736f6e616c20446174613c2f68343e0d0a3c703e596f7520686176652074686520726967687420746f2064656c657465206f72207265717565737420746861742057652061737369737420696e2064656c6574696e672074686520506572736f6e616c20446174612074686174205765206861766520636f6c6c65637465642061626f757420596f752e3c2f703e0d0a3c703e4f75722053657276696365206d6179206769766520596f7520746865206162696c69747920746f2064656c657465206365727461696e20696e666f726d6174696f6e2061626f757420596f752066726f6d2077697468696e2074686520536572766963652e3c2f703e0d0a3c703e596f75206d6179207570646174652c20616d656e642c206f722064656c65746520596f757220696e666f726d6174696f6e20617420616e792074696d65206279207369676e696e6720696e20746f20596f7572204163636f756e742c20696620796f752068617665206f6e652c20616e64207669736974696e6720746865206163636f756e742073657474696e67732073656374696f6e207468617420616c6c6f777320796f7520746f206d616e61676520596f757220706572736f6e616c20696e666f726d6174696f6e2e20596f75206d617920616c736f20636f6e7461637420557320746f20726571756573742061636365737320746f2c20636f72726563742c206f722064656c65746520616e7920706572736f6e616c20696e666f726d6174696f6e207468617420596f7520686176652070726f766964656420746f2055732e3c2f703e0d0a3c703e506c65617365206e6f74652c20686f77657665722c2074686174205765206d6179206e65656420746f2072657461696e206365727461696e20696e666f726d6174696f6e207768656e20776520686176652061206c6567616c206f626c69676174696f6e206f72206c617766756c20626173697320746f20646f20736f2e3c2f703e0d0a3c68343e3c7370616e207374796c653d22666f6e742d73697a653a312e3136323572656d3b223e427573696e657373205472616e73616374696f6e733c2f7370616e3e3c2f68343e0d0a3c703e49662074686520436f6d70616e7920697320696e766f6c76656420696e2061206d65726765722c206163717569736974696f6e206f722061737365742073616c652c20596f757220506572736f6e616c2044617461206d6179206265207472616e736665727265642e2057652077696c6c2070726f76696465206e6f74696365206265666f726520596f757220506572736f6e616c2044617461206973207472616e7366657272656420616e64206265636f6d6573207375626a65637420746f206120646966666572656e74205072697661637920506f6c6963792e3c2f703e0d0a3c68343e4c617720656e666f7263656d656e743c2f68343e0d0a3c703e556e646572206365727461696e2063697263756d7374616e6365732c2074686520436f6d70616e79206d617920626520726571756972656420746f20646973636c6f736520596f757220506572736f6e616c204461746120696620726571756972656420746f20646f20736f206279206c6177206f7220696e20726573706f6e736520746f2076616c6964207265717565737473206279207075626c696320617574686f7269746965732028652e672e206120636f757274206f72206120676f7665726e6d656e74206167656e6379292e3c2f703e0d0a3c68343e4f74686572206c6567616c20726571756972656d656e74733c2f68343e0d0a3c703e54686520436f6d70616e79206d617920646973636c6f736520596f757220506572736f6e616c204461746120696e2074686520676f6f642066616974682062656c6965662074686174207375636820616374696f6e206973206e656365737361727920746f3a3c2f703e0d0a3c756c3e0d0a3c6c693e436f6d706c7920776974682061206c6567616c206f626c69676174696f6e3c2f6c693e0d0a3c6c693e50726f7465637420616e6420646566656e642074686520726967687473206f722070726f7065727479206f662074686520436f6d70616e793c2f6c693e0d0a3c6c693e50726576656e74206f7220696e76657374696761746520706f737369626c652077726f6e67646f696e6720696e20636f6e6e656374696f6e20776974682074686520536572766963653c2f6c693e0d0a3c6c693e50726f746563742074686520706572736f6e616c20736166657479206f66205573657273206f66207468652053657276696365206f7220746865207075626c69633c2f6c693e0d0a3c6c693e50726f7465637420616761696e7374206c6567616c206c696162696c6974793c2f6c693e0d0a3c2f756c3e0d0a3c68343e5365637572697479206f6620596f757220506572736f6e616c20446174613c2f68343e0d0a3c703e546865207365637572697479206f6620596f757220506572736f6e616c204461746120697320696d706f7274616e7420746f2055732c206275742072656d656d6265722074686174206e6f206d6574686f64206f66207472616e736d697373696f6e206f7665722074686520496e7465726e65742c206f72206d6574686f64206f6620656c656374726f6e69632073746f726167652069732031303025207365637572652e205768696c652057652073747269766520746f2075736520636f6d6d65726369616c6c792061636365707461626c65206d65616e7320746f2070726f7465637420596f757220506572736f6e616c20446174612c2057652063616e6e6f742067756172616e74656520697473206162736f6c7574652073656375726974792e3c2f703e0d0a3c703e4368696c6472656e277320507269766163793c2f703e0d0a3c703e4f7572205365727669636520646f6573206e6f74206164647265737320616e796f6e6520756e6465722074686520616765206f662031332e20576520646f206e6f74206b6e6f77696e676c7920636f6c6c65637420706572736f6e616c6c79206964656e7469666961626c6520696e666f726d6174696f6e2066726f6d20616e796f6e6520756e6465722074686520616765206f662031332e20496620596f7520617265206120706172656e74206f7220677561726469616e20616e6420596f7520617265206177617265207468617420596f7572206368696c64206861732070726f7669646564205573207769746820506572736f6e616c20446174612c20706c6561736520636f6e746163742055732e204966205765206265636f6d652061776172652074686174205765206861766520636f6c6c656374656420506572736f6e616c20446174612066726f6d20616e796f6e6520756e6465722074686520616765206f6620313320776974686f757420766572696669636174696f6e206f6620706172656e74616c20636f6e73656e742c2057652074616b6520737465707320746f2072656d6f7665207468617420696e666f726d6174696f6e2066726f6d204f757220736572766572732e3c2f703e0d0a3c703e4966205765206e65656420746f2072656c79206f6e20636f6e73656e742061732061206c6567616c20626173697320666f722070726f63657373696e6720596f757220696e666f726d6174696f6e20616e6420596f757220636f756e74727920726571756972657320636f6e73656e742066726f6d206120706172656e742c205765206d6179207265717569726520596f757220706172656e74277320636f6e73656e74206265666f726520576520636f6c6c65637420616e6420757365207468617420696e666f726d6174696f6e2e3c2f703e0d0a3c703e4c696e6b7320746f204f746865722057656273697465733c2f703e0d0a3c703e4f75722053657276696365206d617920636f6e7461696e206c696e6b7320746f206f74686572207765627369746573207468617420617265206e6f74206f706572617465642062792055732e20496620596f7520636c69636b206f6e2061207468697264207061727479206c696e6b2c20596f752077696c6c20626520646972656374656420746f2074686174207468697264207061727479277320736974652e205765207374726f6e676c792061647669736520596f7520746f2072657669657720746865205072697661637920506f6c696379206f66206576657279207369746520596f752076697369742e3c2f703e0d0a3c703e57652068617665206e6f20636f6e74726f6c206f76657220616e6420617373756d65206e6f20726573706f6e736962696c69747920666f722074686520636f6e74656e742c207072697661637920706f6c6963696573206f7220707261637469636573206f6620616e79207468697264207061727479207369746573206f722073657276696365732e3c2f703e0d0a3c703e4368616e67657320746f2074686973205072697661637920506f6c6963793c2f703e0d0a3c703e5765206d617920757064617465204f7572205072697661637920506f6c6963792066726f6d2074696d6520746f2074696d652e2057652077696c6c206e6f7469667920596f75206f6620616e79206368616e67657320627920706f7374696e6720746865206e6577205072697661637920506f6c696379206f6e207468697320706167652e3c2f703e0d0a3c703e57652077696c6c206c657420596f75206b6e6f772076696120656d61696c20616e642f6f7220612070726f6d696e656e74206e6f74696365206f6e204f757220536572766963652c207072696f7220746f20746865206368616e6765206265636f6d696e672065666665637469766520616e64207570646174652074686520224c61737420757064617465642220646174652061742074686520746f70206f662074686973205072697661637920506f6c6963792e3c2f703e0d0a3c703e596f7520617265206164766973656420746f207265766965772074686973205072697661637920506f6c69637920706572696f646963616c6c7920666f7220616e79206368616e6765732e204368616e67657320746f2074686973205072697661637920506f6c6963792061726520656666656374697665207768656e20746865792061726520706f73746564206f6e207468697320706167652e3c2f703e0d0a3c703e436f6e746163742055733c2f703e0d0a3c703e496620796f75206861766520616e79207175657374696f6e732061626f75742074686973205072697661637920506f6c6963792c20596f752063616e20636f6e746163742075733a3c2f703e, NULL, NULL, '2023-05-20 04:53:32', '2023-05-20 12:01:50');
INSERT INTO `page_contents` (`id`, `language_id`, `page_id`, `title`, `slug`, `content`, `meta_keywords`, `meta_description`, `created_at`, `updated_at`) VALUES
(40, 22, 16, 'سياسة الخصوصية', 'سياسة-الخصوصية', 0x3c6469763ed8b3d98ad8a7d8b3d8a920d8a7d984d8aed8b5d988d8b5d98ad8a93c2f6469763e0d0a3c703ed8aad8b5d98120d8b3d98ad8a7d8b3d8a920d8a7d984d8aed8b5d988d8b5d98ad8a920d987d8b0d98720d8b3d98ad8a7d8b3d8a7d8aad986d8a720d988d8a5d8acd8b1d8a7d8a1d8a7d8aad986d8a720d8a7d984d985d8aad8b9d984d982d8a920d8a8d8acd985d8b920d985d8b9d984d988d985d8a7d8aad98320d988d8a7d8b3d8aad8aed8afd8a7d985d987d8a720d988d8a7d984d983d8b4d98120d8b9d986d987d8a720d8b9d986d8af20d8a7d8b3d8aad8aed8afd8a7d985d98320d984d984d8aed8afd985d8a920d988d8aad8aed8a8d8b1d98320d8a8d8add982d988d98220d8a7d984d8aed8b5d988d8b5d98ad8a920d8a7d984d8aed8a7d8b5d8a920d8a8d98320d988d983d98ad98120d98ad8add985d98ad98320d8a7d984d982d8a7d986d988d9862e3c2f703e0d0a3c703ec2a03c2f703e0d0a3c68323e3c7370616e207374796c653d22666f6e742d73697a653a313470783b666f6e742d7765696768743a3430303b223ed986d8b3d8aad8aed8afd98520d8a8d98ad8a7d986d8a7d8aad98320d8a7d984d8b4d8aed8b5d98ad8a920d984d8aad982d8afd98ad98520d8a7d984d8aed8afd985d8a920d988d8aad8add8b3d98ad986d987d8a72e20d8a8d8a7d8b3d8aad8aed8afd8a7d98520d8a7d984d8aed8afd985d8a920d88c20d981d8a5d986d98320d8aad988d8a7d981d98220d8b9d984d98920d8acd985d8b920d988d8a7d8b3d8aad8aed8afd8a7d98520d8a7d984d985d8b9d984d988d985d8a7d8aa20d988d981d982d98bd8a720d984d8b3d98ad8a7d8b3d8a920d8a7d984d8aed8b5d988d8b5d98ad8a920d987d8b0d9872e3c2f7370616e3e3c2f68323e0d0a3c68343ed8aad981d8b3d98ad8b13c2f68343e0d0a3c703ed8a7d984d983d984d985d8a7d8aa20d8a7d984d8aad98a20d98ad8aad98520d983d8aad8a7d8a8d8a920d8a7d984d8add8b1d98120d8a7d984d8a3d988d98420d8a8d987d8a720d985d8b9d8a7d986d98a20d985d8add8afd8afd8a920d988d981d982d98bd8a720d984d984d8b4d8b1d988d8b720d8a7d984d8aad8a7d984d98ad8a92e20d98ad8acd8a820d8a3d98620d98ad983d988d98620d984d984d8aad8b9d8b1d98ad981d8a7d8aa20d8a7d984d8aad8a7d984d98ad8a920d986d981d8b320d8a7d984d985d8b9d986d98920d8a8d8bad8b620d8a7d984d986d8b8d8b120d8b9d985d8a720d8a5d8b0d8a720d983d8a7d986d8aa20d8aad8b8d987d8b120d8a8d8b5d98ad8bad8a920d8a7d984d985d981d8b1d8af20d8a3d98820d8a7d984d8acd985d8b92e3c2f703e0d0a3c68343ed8aad8b9d8b1d98ad981d8a7d8aa3c2f68343e0d0a3c68323e3c7370616e207374796c653d22666f6e742d73697a653a313470783b666f6e742d7765696768743a3430303b223ed984d8a3d8bad8b1d8a7d8b620d8b3d98ad8a7d8b3d8a920d8a7d984d8aed8b5d988d8b5d98ad8a920d987d8b0d9873a3c2f7370616e3e3c2f68323e0d0a3c68323e3c7370616e207374796c653d22666f6e742d73697a653a313470783b666f6e742d7765696768743a6e6f726d616c3b223ed8a7d984d8add8b3d8a7d8a820d98ad8b9d986d98a20d8add8b3d8a7d8a8d98bd8a720d981d8b1d98ad8afd98bd8a720d8aad98520d8a5d986d8b4d8a7d8a4d98720d984d98320d984d984d988d8b5d988d98420d8a5d984d98920d8aed8afd985d8aad986d8a720d8a3d98820d8a3d8acd8b2d8a7d8a120d985d98620d8aed8afd985d8aad986d8a72e3c2f7370616e3e3c2f68323e0d0a3c68323e3c7370616e207374796c653d22666f6e742d7765696768743a6e6f726d616c3b223e3c7370616e207374796c653d22666f6e742d73697a653a313470783b223ed8a7d984d8b4d8b1d983d8a920d8a7d984d8aad8a7d8a8d8b9d8a920d8aad8b9d986d98a20d8a7d984d983d98ad8a7d98620d8a7d984d8b0d98a20d98ad8aad8add983d98520d8a3d98820d98ad8aad8add983d98520d981d98ad98720d8a3d98820d98ad8aed8b6d8b920d984d8b3d98ad8b7d8b1d8a920d985d8b4d8aad8b1d983d8a920d985d8b920d8a3d8add8af20d8a7d984d8a3d8b7d8b1d8a7d98120d88c20d8add98ad8ab20d8aad8b9d986d98a2022d8a7d984d8b3d98ad8b7d8b1d8a92220d985d984d983d98ad8a9203530d9aa20d8a3d98820d8a3d983d8abd8b120d985d98620d8a7d984d8a3d8b3d987d98520d8a3d98820d8add982d988d98220d8a7d984d985d984d983d98ad8a920d8a3d98820d8a7d984d8a3d988d8b1d8a7d98220d8a7d984d985d8a7d984d98ad8a920d8a7d984d8a3d8aed8b1d98920d8a7d984d8aad98a20d98ad8add98220d984d987d8a720d8a7d984d8aad8b5d988d98ad8aa20d984d8a7d986d8aad8aed8a7d8a820d8a3d8b9d8b6d8a7d8a120d985d8acd984d8b320d8a7d984d8a5d8afd8a7d8b1d8a920d8a3d98820d8a3d98a20d8b3d984d8b7d8a920d8a5d8afd8a7d8b1d98ad8a920d8a3d8aed8b1d989202e3c2f7370616e3e3c62723e3c2f7370616e3e3c2f68323e0d0a3c756c3e0d0a3c6c693e0d0a3c703ed8aad8b4d98ad8b120d8a7d984d8b4d8b1d983d8a92028d8a7d984d985d8b4d8a7d8b120d8a5d984d98ad987d8a720d8a8d8a7d8b3d9852022d8a7d984d8b4d8b1d983d8a92220d8a3d9882022d986d8add9862220d8a3d9882022d984d986d8a72220d8a3d9882022d984d986d8a72220d981d98a20d987d8b0d98720d8a7d984d8a7d8aad981d8a7d982d98ad8a92920d8a5d984d98920d8add8afd8abd9882e3c2f703e0d0a3c2f6c693e0d0a3c6c693e0d0a3c703ed985d984d981d8a7d8aa20d8aad8b9d8b1d98ad98120d8a7d984d8a7d8b1d8aad8a8d8a7d8b720d987d98a20d985d984d981d8a7d8aa20d8b5d8bad98ad8b1d8a920d98ad8aad98520d988d8b6d8b9d987d8a720d8b9d984d98920d8acd987d8a7d8b220d8a7d984d983d985d8a8d98ad988d8aad8b120d8a3d98820d8a7d984d8acd987d8a7d8b220d8a7d984d985d8add985d988d98420d8a3d98820d8a3d98a20d8acd987d8a7d8b220d8a2d8aed8b120d8a8d988d8a7d8b3d8b7d8a920d985d988d982d8b920d988d98ad8a820d88c20d988d8aad8add8aad988d98a20d8b9d984d98920d8aad981d8a7d8b5d98ad98420d985d8add981d988d8b8d8a7d8aa20d8a7d984d8a7d8b3d8aad8b9d8b1d8a7d8b620d8a7d984d8aed8a7d8b5d8a920d8a8d9833c2f703e0d0a3c703ec2a03c2f703e0d0a3c2f6c693e0d0a3c2f756c3e0d0a3c68343e3c7370616e207374796c653d22666f6e742d73697a653a31382e3670783b223ed8a8d98ad8a7d986d8a7d8aa20d8b4d8aed8b5d98ad8a93c2f7370616e3e3c2f68343e0d0a3c68323e3c7370616e207374796c653d22666f6e742d73697a653a313470783b666f6e742d7765696768743a3430303b223ed8a3d8abd986d8a7d8a120d8a7d8b3d8aad8aed8afd8a7d98520d8aed8afd985d8aad986d8a720d88c20d982d8af20d986d8b7d984d8a820d985d986d98320d8aad8b2d988d98ad8afd986d8a720d8a8d985d8b9d984d988d985d8a7d8aa20d8aad8b9d8b1d98ad98120d8b4d8aed8b5d98ad8a920d985d8b9d98ad986d8a920d98ad985d983d98620d8a7d8b3d8aad8aed8afd8a7d985d987d8a720d984d984d8a7d8aad8b5d8a7d98420d8a8d98320d8a3d98820d8a7d984d8aad8b9d8b1d98120d8b9d984d98ad9832e20d982d8af20d8aad8aad8b6d985d98620d985d8b9d984d988d985d8a7d8aa20d8a7d984d8aad8b9d8b1d98ad98120d8a7d984d8b4d8aed8b5d98ad8a920d88c20d8b9d984d98920d8b3d8a8d98ad98420d8a7d984d985d8abd8a7d98420d984d8a720d8a7d984d8add8b5d8b13a3c2f7370616e3e3c2f68323e, NULL, NULL, '2023-05-20 04:53:32', '2023-05-20 12:01:50');

-- --------------------------------------------------------

--
-- Table structure for table `page_headings`
--

CREATE TABLE `page_headings` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED DEFAULT NULL,
  `blog_page_title` varchar(255) DEFAULT NULL,
  `blog_details_page_title` varchar(255) DEFAULT NULL,
  `contact_page_title` varchar(255) DEFAULT NULL,
  `about_page_title` varchar(255) DEFAULT NULL,
  `event_page_title` varchar(255) DEFAULT NULL,
  `shop_page_title` varchar(255) DEFAULT NULL,
  `cart_page_title` varchar(255) DEFAULT NULL,
  `event_details_page_title` varchar(255) DEFAULT NULL,
  `faq_page_title` varchar(255) DEFAULT NULL,
  `customer_forget_password_page_title` varchar(255) DEFAULT NULL,
  `organizer_forget_password_page_title` varchar(255) DEFAULT NULL,
  `organizer_page_title` varchar(255) DEFAULT NULL,
  `customer_login_page_title` varchar(255) DEFAULT NULL,
  `customer_signup_page_title` varchar(255) DEFAULT NULL,
  `organizer_login_page_title` varchar(255) DEFAULT NULL,
  `organizer_signup_page_title` varchar(255) DEFAULT NULL,
  `customer_dashboard_page_title` varchar(255) DEFAULT NULL,
  `customer_booking_page_title` varchar(255) DEFAULT NULL,
  `customer_booking_details_page_title` varchar(255) DEFAULT NULL,
  `customer_order_page_title` varchar(255) DEFAULT NULL,
  `customer_order_details_page_title` varchar(255) DEFAULT NULL,
  `customer_wishlist_page_title` varchar(255) DEFAULT NULL,
  `customer_support_ticket_page_title` varchar(255) DEFAULT NULL,
  `support_ticket_create_page_title` varchar(255) DEFAULT NULL,
  `support_ticket_details_page_title` varchar(255) DEFAULT NULL,
  `customer_edit_profile_page_title` varchar(255) DEFAULT NULL,
  `customer_change_password_page_title` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `page_headings`
--

INSERT INTO `page_headings` (`id`, `language_id`, `blog_page_title`, `blog_details_page_title`, `contact_page_title`, `about_page_title`, `event_page_title`, `shop_page_title`, `cart_page_title`, `event_details_page_title`, `faq_page_title`, `customer_forget_password_page_title`, `organizer_forget_password_page_title`, `organizer_page_title`, `customer_login_page_title`, `customer_signup_page_title`, `organizer_login_page_title`, `organizer_signup_page_title`, `customer_dashboard_page_title`, `customer_booking_page_title`, `customer_booking_details_page_title`, `customer_order_page_title`, `customer_order_details_page_title`, `customer_wishlist_page_title`, `customer_support_ticket_page_title`, `support_ticket_create_page_title`, `support_ticket_details_page_title`, `customer_edit_profile_page_title`, `customer_change_password_page_title`, `created_at`, `updated_at`) VALUES
(4, 8, 'Blog', 'Blog Details', 'Contact', 'About Us', 'Our Events', 'Shop', 'Cart', 'Event  Details', 'FAQ', 'Forget Password', 'Forget Password', 'Organizer', 'Customer Login', 'Customer Signup', 'Organizer Login', 'Organizer Signup', 'Dashboard', 'My Bookings', 'Booking Details', 'My Orders', 'Order Details', 'My Wishlists', 'Support Tickets', 'Create a Support Ticket', 'Support Ticket Details', 'Edit Profile', 'Change Password', '2021-10-14 02:42:42', '2023-05-20 09:48:27'),
(6, 22, 'المدونة', 'تفاصيل المدونة', 'الاتصال', 'معلومات عنا', 'الاتصال', 'دكان', 'عَرَبَة نَقْل', 'تفاصيل الفعالية', 'الأسئلة المتداولة', 'نسيت كلمة المرور', 'نسيت كلمة المرور', 'منظم', 'دخول العميل', 'دخول العميل', 'تسجيل دخول المنظم', 'تسجيل المنظم', 'لوحة المعلومات', 'حجوزاتي', 'تفاصيل الحجز', 'طلباتي', 'تفاصيل الطلب', 'قوائم الرغبات الخاصة بي', 'تذاكر الدعم الفني', 'إنشاء تذكرة دعم', 'تفاصيل تذكرة الدعم الفني', 'تحرير الملف الشخصي', 'تغيير كلمة المرور', '2023-05-08 05:44:00', '2023-05-20 09:48:42');

-- --------------------------------------------------------

--
-- Table structure for table `partners`
--

CREATE TABLE `partners` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `partners`
--

INSERT INTO `partners` (`id`, `image`, `url`, `serial_number`, `created_at`, `updated_at`) VALUES
(7, '645879b813135.png', 'example.com', '1', '2022-06-07 03:06:07', '2023-05-08 04:25:28'),
(8, '645878ede2556.png', 'example.com', '2', '2022-06-07 03:06:16', '2023-05-08 04:22:05'),
(9, '645879c4e8561.png', 'example.com', '3', '2023-05-08 04:25:40', '2023-05-08 04:25:40'),
(10, '645879d17fb68.png', 'example.com', '4', '2023-05-08 04:25:53', '2023-05-08 04:25:53');

-- --------------------------------------------------------

--
-- Table structure for table `partner_sections`
--

CREATE TABLE `partner_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `partner_sections`
--

INSERT INTO `partner_sections` (`id`, `language_id`, `title`, `text`, `created_at`, `updated_at`) VALUES
(1, 8, 'Our Partner', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt', '2022-06-07 21:53:57', '2022-06-07 21:53:57'),
(2, 9, 'شريكنا', 'خدمتنا مجانية للمستخدمين لأن البائعين يدفعون لنا عندما يتلقون زيارات على شبكة', '2022-06-07 21:54:13', '2022-07-16 22:56:35'),
(3, 17, 'شريكنا', 'الأحرف. خمسة قرون من الزمن لم تقضي على هذا النص، بل انه حتى صار', '2023-01-31 05:52:18', '2023-01-31 05:52:18');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('fahadahmadshemul@gmail.com', '5ffRsAn2iFAOtkFkJVuTicgt2OL3Hv2h', NULL),
('fahadahmadshemul@gmail.com', 'MofULe7iGv69cBBtn8WEprM0G73m3Vte', NULL),
('fahadahmadshemul@gmail.com', 'wLZLzqpItzNrGkg6A3HPu6naSi7h8hN9', NULL),
('fahadahmadshemul@gmail.com', '2ckcECbtz9aDkUIP1NaRka0k6FYC6cOU', NULL),
('fahadahmadshemul@gmail.com', 'z4DS2ezbNaAPPDykmZlC22FlKIWzhSoE', NULL),
('fahadahmadshemul@gmail.com', 'jDM2Ak7oXiTxnD6bLOp3ABjrYGGIm0qK', NULL),
('fahadahmadshemul@gmail.com', 'hteh4kg4180Lm2EMM9su205LzosT9z7G', NULL),
('azimahmed11041@gmail.com', '76oktXOsiLEjZHosFRiwT0FQa1XhOiwm', NULL),
('azimahmed11041@gmail.com', 'gCCJ0Eq89hSbYC5FfEAoWfeOYwOzPrk9', NULL),
('azimahmed11041@gmail.com', 'HVJq3vkfpWo0utGb1BvAmyCDs6L8kV39', NULL),
('azimahmed11041@gmail.com', 'ikDwaz58Gnvu9aXT2OI5WMz5bhjVpr0x', NULL),
('azimahmed11041@gmail.com', 'P4NHQSghVyYsdDxw6MOnAQDO60EMQniE', NULL),
('azimahmed11041@gmail.com', 'xROVrvqPpq3l9hIcr8uIS3u7Ba8AR5DM', NULL),
('azimahmed11041@gmail.com', 'OcqFf6pJXIXUyEeftH2lB9O32Ii28MvM', NULL),
('azimahmed11041@gmail.com', 'wgQyOzq4BEBV805C0xLjxgm9IGRQsOs0', NULL),
('azimahmed11041@gmail.com', 'W6ER6gTl3oDzHKQPrPoGPAGRC6O33apb', NULL),
('azimahmed11041@gmail.com', 'KFh3PtHmvxTz9hzm5K3XzocMSHj2wIMY', NULL),
('azimahmed11041@gmail.com', 'OMNZpQc7sTpvnCGfLPhdWD0SGGJLvUdh', NULL),
('azimahmed11041@gmail.com', 'Bs1q0lBbKUM0a0siD5xXRD0nAEot8wXb', NULL),
('azimahmed11041@gmail.com', 'F9WDH2kaPJLqJDKG7xmYzToMBBO5fTpw', NULL),
('azimahmed11041@gmail.com', 'gcmVlQNRKFKsFkEB3FndVw5ucIzlYH4B', NULL),
('azimahmed11041@gmail.com', 'VZuVu7c0iDf2d6SOaFNZWp7xD6WYF8Mn', NULL),
('azimahmed11041@gmail.com', 'AFY0WxtG7x1sOX1J90v8z2yGsApwM9dL', NULL),
('metewa8928@fintehs.com', 'bduwYIdsoDUfSdbR7hQikKdpa2L2IY2j', NULL),
('metewa8928@fintehs.com', 'cxgkh3X99D0W2R3R36hraiC9zM8vWhEt', NULL),
('metewa8928@fintehs.com', 'ddfvucZgc8EiMEATN1m5tMNNIBa5yysl', NULL),
('metewa8928@fintehs.com', 'PE0eIlt6fGZniHe9yMOGdbszOquHDdV6', NULL),
('metewa8928@fintehs.com', 'awqSYGZTM2ezfH15jrZ5oIKOMbWiMHte', NULL),
('metewa8928@fintehs.com', 'w8JXb3O48WkjmtMZtCI2eLwO42NX2aJs', NULL),
('woxad75234@fanlvr.com', '$2y$10$oDfdo.zH4PpMZ03iAfQgI.kg7WkPB98jNoXJQVM/RSf9Fsof/0rd2', '2025-10-14 00:36:13'),
('woxad75234@fanlvr.com', 'Z5ZsRNd7uggKB7rW4AiueejJnCWE4pJ8', NULL),
('woxad75234@fanlvr.com', 'RxmdmgI1vAylGNqc6NBrXZCdywjqfGkG', NULL),
('goutams1048@gmail.com', '$2y$10$o6AH2eLB63aLyfj47Nw1pePCT6Dj/D4KCh0oCU2WMq0JnqsrSzQlW', '2025-10-14 06:06:55');

-- --------------------------------------------------------

--
-- Table structure for table `payment_invoices`
--

CREATE TABLE `payment_invoices` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `order_id` bigint(20) UNSIGNED NOT NULL,
  `client_id` bigint(20) UNSIGNED NOT NULL,
  `InvoiceId` bigint(20) UNSIGNED NOT NULL,
  `InvoiceStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InvoiceValue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `Currency` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `InvoiceDisplayValue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `TransactionId` bigint(20) UNSIGNED NOT NULL,
  `TransactionStatus` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PaymentGateway` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `PaymentId` bigint(20) UNSIGNED NOT NULL,
  `CardNumber` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `personal_access_tokens`
--

INSERT INTO `personal_access_tokens` (`id`, `tokenable_type`, `tokenable_id`, `name`, `token`, `abilities`, `last_used_at`, `expires_at`, `created_at`, `updated_at`) VALUES
(32, 'App\\Models\\Customer', 35, 'customer-login', 'df5b17f9c4040c895e12672f2a1e8c23511d04f5e25c20fc0b9842725e7ad332', '[\"*\"]', '2025-10-14 01:56:17', NULL, '2025-10-14 01:17:29', '2025-10-14 01:56:17'),
(50, 'App\\Models\\Customer', 34, 'customer-login', '74cf8cd001ec7c1c309f8b350a784b22222a683eb9ed6740a39ba1964dac14f1', '[\"*\"]', '2025-10-19 06:11:07', NULL, '2025-10-19 03:27:13', '2025-10-19 06:11:07'),
(55, 'App\\Models\\Customer', 33, 'rr', '45b64822b35b3de8c003653d47b849dcfa5f19777e8eecaba8e73075d5621d18', '[\"*\"]', '2025-10-27 04:25:27', NULL, '2025-10-27 04:24:50', '2025-10-27 04:25:27'),
(56, 'App\\Models\\Customer', 33, 'evento-android-mhg59kow-u0rldd', 'afbbdc3b16fd717c86dc46342df7ac65286fc2eab2de45bafcc4f387a34dfb99', '[\"*\"]', '2025-11-03 06:27:36', NULL, '2025-11-03 06:27:35', '2025-11-03 06:27:36'),
(57, 'App\\Models\\Customer', 33, 'evento-android-mhg59kow-u0rldd', '6768045cadb62c5c9d59ff6e545c2b68a31ca780a30f1738621339e6af61d458', '[\"*\"]', '2025-11-03 06:27:51', NULL, '2025-11-03 06:27:42', '2025-11-03 06:27:51'),
(58, 'App\\Models\\Customer', 33, 'rr', '4df4016712a6bc156c03a7db1485001cb70f67658fec44f501ddc74b89248877', '[\"*\"]', '2025-11-04 05:48:42', NULL, '2025-11-04 05:42:37', '2025-11-04 05:48:42');

-- --------------------------------------------------------

--
-- Table structure for table `popups`
--

CREATE TABLE `popups` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `type` smallint(5) UNSIGNED NOT NULL,
  `image` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `background_color_opacity` decimal(3,2) UNSIGNED DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `button_text` varchar(255) DEFAULT NULL,
  `button_color` varchar(255) DEFAULT NULL,
  `button_url` varchar(255) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `delay` int(10) UNSIGNED NOT NULL COMMENT 'value will be in milliseconds',
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1' COMMENT '0 => deactive, 1 => active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `popups`
--

INSERT INTO `popups` (`id`, `language_id`, `type`, `image`, `name`, `background_color`, `background_color_opacity`, `title`, `text`, `button_text`, `button_color`, `button_url`, `end_date`, `end_time`, `delay`, `serial_number`, `status`, `created_at`, `updated_at`) VALUES
(7, 8, 1, '64577a7c2cee5.png', 'Black Friday', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1500, 1, 0, '2021-08-10 05:05:12', '2023-05-07 10:17:45'),
(8, 8, 2, '64577ac23d6b5.png', 'Month End Sale', '2079FF', '0.80', 'ENJOY 10% OFF', 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.', 'Book Now', '2079FF', 'https://codecanyon8.kreativdev.com/evento', NULL, NULL, 2000, 2, 0, '2021-08-10 05:07:11', '2025-02-27 03:19:17'),
(10, 8, 3, '64577b1c72c92.png', 'Summer Sale', '2079FF', '0.70', 'Newsletter', 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.', 'Subscribe', '2079FF', NULL, NULL, NULL, 2000, 3, 0, '2021-08-11 05:42:11', '2023-05-09 11:07:35'),
(11, 8, 4, '64577cffd4533.png', 'Winter Offer', NULL, NULL, 'Get 10% off your first order', 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt', 'Book Now', '2079FF', 'https://codecanyon8.kreativdev.com/evento', NULL, NULL, 1500, 4, 0, '2021-08-11 06:38:08', '2023-05-07 10:41:01'),
(14, 8, 7, '64577d4bcea74.png', 'Flash Sale', '2079FF', NULL, 'Hurry, Sale Ends This Friday', 'This is your last chance to save 30%', 'Yes, I Want to Save 30%', '2079FF', 'https://codecanyon8.kreativdev.com/evento', '2026-05-07', '12:00:00', 1500, 5, 0, '2021-08-11 07:15:16', '2023-05-07 10:40:53'),
(20, 8, 5, '64577d6d84030.png', 'Email Popup', NULL, NULL, 'Get 10% off your first order', 'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt', 'Subscribe', '2079FF', NULL, NULL, NULL, 1500, 2, 0, '2022-05-17 08:08:14', '2023-05-07 10:29:24'),
(21, 8, 6, '64577d905ecf9.png', 'Countdown Popup', NULL, NULL, 'Hurry, Sale Ends This Friday', 'This is your last chance to save 30%', 'Yes,I Want to Save 30%', '2079FF', 'https://codecanyon8.kreativdev.com/evento', '2025-05-16', '12:00:00', 1000, 1, 0, '2022-05-17 08:10:41', '2023-05-09 11:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `stock` varchar(255) DEFAULT NULL,
  `sku` int(11) DEFAULT NULL,
  `feature_image` varchar(255) DEFAULT NULL,
  `current_price` decimal(8,2) DEFAULT NULL,
  `previous_price` decimal(8,2) DEFAULT NULL,
  `is_feature` varchar(255) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL COMMENT 'digital-digital product, physical - physical product',
  `file_type` varchar(255) DEFAULT NULL COMMENT 'upload->file, link=>download_link',
  `download_file` varchar(255) DEFAULT NULL,
  `download_link` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `stock`, `sku`, `feature_image`, `current_price`, `previous_price`, `is_feature`, `status`, `type`, `file_type`, `download_file`, `download_link`, `created_at`, `updated_at`) VALUES
(1, '23', 61620385, '1683451573.png', '90.00', '100.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 09:20:50', '2023-05-07 09:26:13'),
(3, '12', 74171591, '1683452614.png', '50.00', '40.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 09:43:34', '2023-05-07 09:43:34'),
(4, '10', 18801441, '1683452895.png', '150.00', '190.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 09:48:15', '2023-05-07 09:48:15'),
(5, '20', 62656544, '1683453051.png', '200.00', '210.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 09:50:51', '2023-05-07 09:50:51'),
(6, NULL, 60813162, '1683453408.png', '15.00', '20.00', 'yes', 1, 'digital', 'upload', '1683547140.zip', 'http://www.example.com/', '2023-05-07 09:56:48', '2023-05-08 12:02:56'),
(7, NULL, 46408261, '1683453560.png', '20.00', '22.00', 'yes', 1, 'digital', 'link', NULL, 'http://www.example.com/', '2023-05-07 09:59:20', '2023-05-07 09:59:20'),
(8, '30', 95249709, '1683453819.png', '300.00', '310.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 10:03:39', '2023-05-07 10:03:39'),
(9, '100', 44170596, '1683453987.png', '40.00', '42.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 10:06:27', '2023-05-07 10:06:27'),
(10, '100', 72199521, '1683454147.png', '500.00', '550.00', 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 10:09:07', '2023-05-07 10:09:07'),
(11, '5', 33793966, '1683454265.png', '250.00', NULL, 'yes', 1, 'physical', NULL, NULL, NULL, '2023-05-07 10:11:05', '2023-10-01 03:43:44');

-- --------------------------------------------------------

--
-- Table structure for table `product_categories`
--

CREATE TABLE `product_categories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '1' COMMENT '1-yes, 0-no',
  `is_feature` int(11) NOT NULL DEFAULT '0' COMMENT '1-yes, 0-no',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_categories`
--

INSERT INTO `product_categories` (`id`, `name`, `slug`, `language_id`, `status`, `is_feature`, `created_at`, `updated_at`) VALUES
(2, 'Electronic  Accessories', 'Electronic-Accessories', 8, 1, 1, '2023-05-07 08:55:58', '2023-05-07 09:01:02'),
(3, 'Fashion & Beauty', 'Fashion-&-Beauty', 8, 1, 1, '2023-05-07 08:58:15', '2023-05-07 08:59:34'),
(4, 'Home Appliances', 'home-appliances', 8, 1, 1, '2023-05-07 08:58:42', '2023-05-07 08:58:52'),
(5, 'Books', 'Books', 8, 1, 1, '2023-05-07 08:59:58', '2023-05-07 09:02:49'),
(6, 'الملحقات الإلكترونية', 'الملحقات-الإلكترونية', 22, 1, 1, '2023-05-07 09:01:30', '2023-05-07 09:03:28'),
(7, 'الموضة والجمال', 'الموضة-والجمال', 22, 1, 1, '2023-05-07 09:02:00', '2023-05-07 09:03:27'),
(8, 'المنزليه', 'المنزليه', 22, 1, 1, '2023-05-07 09:02:20', '2023-05-07 09:03:25'),
(9, 'الكتب', 'الكتب', 22, 1, 1, '2023-05-07 09:02:55', '2023-05-07 09:03:23');

-- --------------------------------------------------------

--
-- Table structure for table `product_contents`
--

CREATE TABLE `product_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `tags` text,
  `summary` text,
  `description` longtext,
  `meta_keywords` text,
  `meta_description` longtext,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_contents`
--

INSERT INTO `product_contents` (`id`, `title`, `product_id`, `slug`, `language_id`, `category_id`, `tags`, `summary`, `description`, `meta_keywords`, `meta_description`, `created_at`, `updated_at`) VALUES
(1, 'Men\'s Hoodie', 1, 'men\'s-hoodie', 8, 3, 'hoodie', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 09:20:50', '2023-05-07 09:20:50'),
(2, 'هوديي رجالي', 1, 'هوديي-رجالي', 22, 7, 'hoodie', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:20:50', '2023-05-07 09:20:50'),
(5, 'Edifier W820NB Active Noise Cancelling Bluetooth Stereo Headphone', 3, 'edifier-w820nb-active-noise-cancelling-bluetooth-stereo-headphone', 8, 2, 'headphone', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 09:43:34', '2023-05-07 09:43:34'),
(6, 'نشط إلغاء الضوضاء بلوتوث ستيريو سماعة', 3, 'نشط-إلغاء-الضوضاء-بلوتوث-ستيريو-سماعة', 22, 6, 'headphone', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:43:34', '2023-05-07 09:43:34'),
(7, 'Table Desk Lamp With Light Bulb', 4, 'table-desk-lamp-with-light-bulb', 8, 4, 'Lamp', 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 09:48:15', '2023-05-07 09:48:15'),
(8, 'مصباح مكتب الجدول مع المصباح الكهربائي', 4, 'مصباح-مكتب-الجدول-مع-المصباح-الكهربائي', 22, 8, 'Lamp', 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:48:15', '2023-05-07 09:48:15'),
(9, 'Wireless Vibration GamePad', 5, 'wireless-vibration-gamepad', 8, 2, NULL, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 09:50:51', '2023-05-07 09:50:51'),
(10, 'لوحة ألعاب الاهتزاز اللاسلكية', 5, 'لوحة-ألعاب-الاهتزاز-اللاسلكية', 22, 6, NULL, 'من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.\r\n\r\nعل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.', '<p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:50:51', '2023-05-07 09:50:51'),
(11, 'User Manual Book', 6, 'user-manual-book', 8, 5, NULL, 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p><div><br /></div>', NULL, NULL, '2023-05-07 09:56:48', '2023-05-07 09:56:48'),
(12, 'كتاب دليل المستخدم', 6, 'كتاب-دليل-المستخدم', 22, 9, NULL, 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:56:48', '2023-05-07 09:56:48'),
(13, 'Manual Guide', 7, 'manual-guide', 8, 5, NULL, 'Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 09:59:20', '2023-05-07 09:59:20'),
(14, 'دليل يدوي', 7, 'دليل-يدوي', 22, 9, NULL, 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 09:59:20', '2023-05-07 09:59:20'),
(15, 'Living room sofa set', 8, 'living-room-sofa-set', 8, 4, NULL, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 10:03:39', '2023-05-07 10:03:39'),
(16, 'مجموعة أريكة غرفة المعيشة', 8, 'مجموعة-أريكة-غرفة-المعيشة', 22, 8, NULL, 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 10:03:39', '2023-05-07 10:03:39'),
(17, 'Sunscreen Cream', 9, 'sunscreen-cream', 8, 3, NULL, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p><div><br /></div>', NULL, NULL, '2023-05-07 10:06:27', '2023-05-07 10:06:27'),
(18, 'كريم واقي من الشمس', 9, 'كريم-واقي-من-الشمس', 22, 7, NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.', '<p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 10:06:27', '2023-05-07 10:06:27'),
(19, 'Smart Phone', 10, 'smart-phone', 8, 2, NULL, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p><br /></p><p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p><p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p><p><br /></p><p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p><p><br /></p><p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p><div><br /></div>', NULL, NULL, '2023-05-07 10:09:07', '2023-05-07 10:09:07'),
(20, 'الهواتف الذكية', 10, 'الهواتف-الذكية', 22, 6, NULL, 'إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.', '<p><br /></p><p>وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p><p><br /></p><p>إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p><p><br /></p><p>من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p><p><br /></p><p>عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 10:09:07', '2023-05-07 10:09:07'),
(21, 'Printer', 11, 'printer', 8, 2, NULL, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.', '<p> </p>\r\n<p>Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.</p>\r\n<p> Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero. Its words and letters have been changed by addition or removal, </p>\r\n<p> </p>\r\n<p>so to deliberately render its content nonsensical; it\'s not genuine, correct, or comprehensible Latin anymore.</p>\r\n<p> </p>\r\n<p> While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.</p>', NULL, NULL, '2023-05-07 10:11:05', '2023-05-20 11:59:42'),
(22, 'طابعة', 11, 'طابعة', 22, 6, NULL, 'وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', '<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم الأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.</p>\r\n<p style=\"text-align:right;\"> </p>\r\n<p style=\"text-align:right;\">عل الا الجنرال العالمية, تونس بتطويق كل يبق. لم وتم جدول محاولات الإثنان. عل الا وقبل حكومة. إذ جورج الشطر استرجاع تحت.</p>', NULL, NULL, '2023-05-07 10:11:05', '2023-10-01 03:43:44');

-- --------------------------------------------------------

--
-- Table structure for table `product_images`
--

CREATE TABLE `product_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_images`
--

INSERT INTO `product_images` (`id`, `product_id`, `image`, `created_at`, `updated_at`) VALUES
(1, 1, '64576e5a69169.jpg', '2023-05-07 09:24:42', '2023-05-07 09:26:13'),
(2, 1, '64576e5a6aefc.jpg', '2023-05-07 09:24:42', '2023-05-07 09:26:13'),
(3, 1, '64576e5aa0159.jpg', '2023-05-07 09:24:42', '2023-05-07 09:26:13'),
(5, 3, '64577265e9392.jpg', '2023-05-07 09:41:57', '2023-05-07 09:43:34'),
(6, 3, '64577265e943b.jpg', '2023-05-07 09:41:57', '2023-05-07 09:43:34'),
(7, 3, '645772662fd54.jpg', '2023-05-07 09:41:58', '2023-05-07 09:43:34'),
(8, 4, '6457734a98de7.jpg', '2023-05-07 09:45:46', '2023-05-07 09:48:15'),
(9, 4, '6457734aa3510.jpg', '2023-05-07 09:45:46', '2023-05-07 09:48:15'),
(10, 4, '6457734ad1673.jpg', '2023-05-07 09:45:46', '2023-05-07 09:48:15'),
(11, 5, '6457742ba6349.jpg', '2023-05-07 09:49:31', '2023-05-07 09:50:51'),
(12, 5, '6457742baa5cc.jpg', '2023-05-07 09:49:31', '2023-05-07 09:50:51'),
(13, 5, '6457742bd9402.jpg', '2023-05-07 09:49:31', '2023-05-07 09:50:51'),
(17, 6, '645775970e137.jpg', '2023-05-07 09:55:35', '2023-05-07 09:56:48'),
(18, 6, '645775970faab.jpg', '2023-05-07 09:55:35', '2023-05-07 09:56:48'),
(19, 6, '6457759748b92.jpg', '2023-05-07 09:55:35', '2023-05-07 09:56:48'),
(20, 7, '6457762c76e95.jpg', '2023-05-07 09:58:04', '2023-05-07 09:59:20'),
(21, 7, '6457762c82b2d.jpg', '2023-05-07 09:58:04', '2023-05-07 09:59:20'),
(22, 7, '6457762cad8f1.jpg', '2023-05-07 09:58:04', '2023-05-07 09:59:20'),
(23, 8, '645776c2b7c86.jpg', '2023-05-07 10:00:34', '2023-05-07 10:03:39'),
(24, 8, '645776c2bc73b.jpg', '2023-05-07 10:00:34', '2023-05-07 10:03:39'),
(25, 8, '645776c2ef21b.jpg', '2023-05-07 10:00:34', '2023-05-07 10:03:39'),
(26, 9, '645777a3d4af0.jpg', '2023-05-07 10:04:19', '2023-05-07 10:06:27'),
(27, 9, '645777a8edfed.jpg', '2023-05-07 10:04:24', '2023-05-07 10:06:27'),
(28, 9, '645777a8f1603.jpg', '2023-05-07 10:04:24', '2023-05-07 10:06:27'),
(29, 10, '6457785d4c410.jpg', '2023-05-07 10:07:25', '2023-05-07 10:09:07'),
(30, 10, '6457785d4c410.jpg', '2023-05-07 10:07:25', '2023-05-07 10:09:07'),
(31, 10, '6457785d82009.jpg', '2023-05-07 10:07:25', '2023-05-07 10:09:07'),
(32, 11, '645778ee46853.jpg', '2023-05-07 10:09:50', '2023-05-07 10:11:05'),
(33, 11, '645778ee5119f.jpg', '2023-05-07 10:09:50', '2023-05-07 10:11:05'),
(34, 11, '645778ee850dd.jpg', '2023-05-07 10:09:50', '2023-05-07 10:11:05');

-- --------------------------------------------------------

--
-- Table structure for table `product_orders`
--

CREATE TABLE `product_orders` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `billing_fname` varchar(255) DEFAULT NULL,
  `billing_lname` varchar(255) DEFAULT NULL,
  `billing_email` varchar(255) DEFAULT NULL,
  `billing_phone` varchar(255) DEFAULT NULL,
  `billing_country` varchar(255) DEFAULT NULL,
  `billing_state` varchar(255) DEFAULT NULL,
  `billing_city` varchar(255) DEFAULT NULL,
  `billing_zip_code` varchar(255) DEFAULT NULL,
  `billing_address` varchar(255) DEFAULT NULL,
  `shipping_fname` varchar(255) DEFAULT NULL,
  `shipping_lname` varchar(255) DEFAULT NULL,
  `shipping_email` varchar(255) DEFAULT NULL,
  `shipping_phone` varchar(255) DEFAULT NULL,
  `shipping_country` varchar(255) DEFAULT NULL,
  `shipping_state` varchar(255) DEFAULT NULL,
  `shipping_city` varchar(255) DEFAULT NULL,
  `shipping_zip_code` varchar(255) DEFAULT NULL,
  `shipping_address` varchar(255) DEFAULT NULL,
  `cart_total` decimal(8,2) DEFAULT NULL,
  `discount` decimal(8,2) DEFAULT NULL,
  `tax` varchar(255) DEFAULT NULL,
  `tax_percentage` double(8,2) DEFAULT '0.00',
  `total` decimal(8,2) DEFAULT NULL,
  `method` varchar(255) DEFAULT NULL,
  `gateway_type` varchar(255) DEFAULT NULL,
  `currency_text` varchar(255) DEFAULT NULL,
  `currency_text_position` varchar(255) DEFAULT NULL,
  `currency_symbol` varchar(255) DEFAULT NULL,
  `currency_symbol_position` varchar(255) DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
  `shipping_method` varchar(255) DEFAULT NULL,
  `shipping_charge` varchar(255) DEFAULT NULL,
  `payment_status` varchar(255) DEFAULT NULL,
  `order_status` varchar(255) DEFAULT NULL,
  `tnxid` varchar(255) DEFAULT NULL,
  `charge_id` varchar(255) DEFAULT NULL,
  `invoice_number` varchar(255) DEFAULT NULL,
  `receipt` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `conversation_id` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_orders`
--

INSERT INTO `product_orders` (`id`, `user_id`, `billing_fname`, `billing_lname`, `billing_email`, `billing_phone`, `billing_country`, `billing_state`, `billing_city`, `billing_zip_code`, `billing_address`, `shipping_fname`, `shipping_lname`, `shipping_email`, `shipping_phone`, `shipping_country`, `shipping_state`, `shipping_city`, `shipping_zip_code`, `shipping_address`, `cart_total`, `discount`, `tax`, `tax_percentage`, `total`, `method`, `gateway_type`, `currency_text`, `currency_text_position`, `currency_symbol`, `currency_symbol_position`, `order_number`, `shipping_method`, `shipping_charge`, `payment_status`, `order_status`, `tnxid`, `charge_id`, `invoice_number`, `receipt`, `created_at`, `updated_at`, `conversation_id`) VALUES
(40, 23, 'Jone', 'Doe', 'user@gmail.com', '202-555-0152', 'United States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Jone', 'Doe', 'user@gmail.com', '202-555-0152', 'United States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '290.00', NULL, '14.5', 5.00, '314.50', 'Xendit', 'online', 'PHP', 'right', '$', 'left', '65cb0996d9776', 'Method Two', '10.00', 'completed', 'pending', '', '7', '65cb0996d9776.pdf', NULL, '2024-02-13 06:17:58', '2024-02-13 06:17:59', NULL),
(41, 23, 'Jone', 'Doe', 'user@gmail.com', '202-555-0152', 'United States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Jone', 'Doe', 'user@gmail.com', '202-555-0152', 'United States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '50.00', NULL, '2.5', 5.00, '62.50', 'Phonepe', 'online', 'USD', 'right', '$', 'left', '65cc64a909cfb', 'Method Two', '10.00', 'completed', 'pending', '', '7', '65cc64a909cfb.pdf', NULL, '2024-02-14 06:58:49', '2024-02-14 06:58:49', NULL),
(42, 23, 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '250.00', NULL, '12.5', 5.00, '272.50', 'Citibank', 'offline', 'PHP', 'right', '$', 'left', '68e50274b47ab', 'Method Two', '10.00', 'pending', 'pending', '', '7', NULL, NULL, '2025-10-07 08:07:16', '2025-10-07 08:07:16', NULL),
(43, 23, 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '250.00', NULL, '12.5', 5.00, '272.50', 'Midtrans', 'online', 'IDR', 'right', '$', 'left', '68e5ef50d49a0', 'Method Two', '10.00', 'completed', 'pending', '', '7', '68e5ef50d49a0.pdf', NULL, '2025-10-08 00:57:52', '2025-10-08 00:57:55', NULL),
(44, 23, 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', '28339', '33 Robin Covington Road, Rockingham,nc, 28339  United States', 'Jone', 'Doe', 'metewa8928@fintehs.com', '202-555-0152', 'Uniteud States', 'North Carolina', 'Rockingham', 'Rockingham', '33 Robin Covington Road, Rockingham,nc, 28339  United States', '250.00', NULL, '12.5', 5.00, '272.50', 'Xendit', 'online', 'PHP', 'right', '$', 'left', '68e6272d701a3', 'Method Two', '10.00', 'completed', 'pending', '', '7', '68e6272d701a3.pdf', NULL, '2025-10-08 04:56:13', '2025-10-08 04:56:15', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `product_reviews`
--

CREATE TABLE `product_reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `review` float DEFAULT NULL,
  `comment` longtext,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `product_reviews`
--

INSERT INTO `product_reviews` (`id`, `user_id`, `product_id`, `review`, `comment`, `created_at`, `updated_at`) VALUES
(4, 23, 11, 5, 'This is a great product. recommended it', '2023-05-09 10:56:36', '2023-05-09 10:56:36'),
(5, 23, 9, 4, 'Not bad', '2023-05-09 10:56:58', '2023-05-09 10:56:58'),
(6, 23, 6, 1, 'Poor book', '2023-05-09 10:57:24', '2023-05-09 10:57:24'),
(7, 23, 8, 5, 'Awesome Product', '2023-05-09 10:57:49', '2023-05-09 10:57:49'),
(8, 23, 10, 3, 'not really good', '2023-05-09 10:58:31', '2023-05-09 10:58:31');

-- --------------------------------------------------------

--
-- Table structure for table `push_subscriptions`
--

CREATE TABLE `push_subscriptions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `subscribable_type` varchar(255) NOT NULL,
  `subscribable_id` bigint(20) UNSIGNED NOT NULL,
  `endpoint` varchar(500) NOT NULL,
  `public_key` varchar(255) DEFAULT NULL,
  `auth_token` varchar(255) DEFAULT NULL,
  `content_encoding` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `push_subscriptions`
--

INSERT INTO `push_subscriptions` (`id`, `subscribable_type`, `subscribable_id`, `endpoint`, `public_key`, `auth_token`, `content_encoding`, `created_at`, `updated_at`) VALUES
(7, 'App\\Models\\Guest', 8, 'https://fcm.googleapis.com/fcm/send/dPnvaQfjZmY:APA91bFKyN3JcgGME6ZrIMuxy1b6H1L2TCG9N2lfBI6lcogRmeziZtfB2fOCOW7NJG6HcPk2lMu0xnnye1wqYtoBl5bvekqIY9KNH-RToHeTXQ6gIaZ9S3lkTuWrDMQYRcWUfUiOmhaI', 'BFqvV_X7wkJCjnZzEQwdn2AKIdxMJ5ARuG14a2oYNCsWw86ByIRXEJMC7LgMQvpqA6E6s5_8E12Hp0MH4AmEeJI', 'aRpGEzfh-gvLgh4OiA0vvQ', NULL, '2025-10-29 07:44:42', '2025-10-29 07:44:42'),
(8, 'App\\Models\\Guest', 9, 'https://fcm.googleapis.com/fcm/send/eUF90OisF2U:APA91bHloRcT7GAh0i6GWngRhJIh-OHUXCIqLowa-HAdvxu2XpZTgdfzCPHzYM7pJK5wwTufedyGm2ocjLkNfSPtk3toEa5nrsMcbmZUVaXdAzXNnzU4mNq4zVlpYtt1B0E9f_Y3RFDB', 'BNivTmt7ovwVLlGnXvkd4gXsn29D1BfETYlz_VS19A8IpuqxQYZV0XEfU8voThR4bmkymsBk3VDwAF6OmfJ0Fcw', 'b8VNRVcT4hw9NqskTstB6A', NULL, '2025-11-02 05:06:11', '2025-11-02 05:06:11'),
(9, 'App\\Models\\Guest', 10, 'https://fcm.googleapis.com/fcm/send/faKkK9nx67A:APA91bERXmwrqZivBOcIjz1OlixofdUiikI0Qh9dkzOW2S51FI0Y76Akf70KX0P64sgvefAKL_ggFVlBhN29J89dwjvFc53jP1mqN45MG7LEIej4suEL-t48_Z09e6rpLX-Jlttneygu', 'BOpBGn-ypFZO_sYCJuv7v2qhfHT6KkEm22YEZFV-c0vwsLTr8r_P-1LvGxn7IPx6Mw_YhwB4uo0i68dw2Mf9pOo', '-dQKK-GmQs0noP08096GNQ', NULL, '2025-11-03 03:27:11', '2025-11-05 00:50:40'),
(10, 'App\\Models\\Guest', 11, 'https://fcm.googleapis.com/fcm/send/fDXXEc0DzIY:APA91bGWBfzFjM7p1YD9SuhF8DvJsVdwRYGhFer21viIJhCmfVFNsYlHSlV61Xi8D0GWKA84naNFTE3nkg7D8CIzhFQAad_RoRu8wuLWhoJYYzYDa7g45VAF-jZJeUMxtJV49c97bt6K', 'BC-TUfzh04kDvupVDbJg4enNWR4TkJuULZFcZQ6BYNdZvcs8aGACUVWrflEX3ay_JlaesCTNeQo9BNdcF8BZyyo', '3c20gFMyJUAmXFnKPji5gg', NULL, '2025-11-06 03:53:06', '2025-11-06 03:53:06'),
(11, 'App\\Models\\Guest', 12, 'https://fcm.googleapis.com/fcm/send/d_wJzTj2InY:APA91bGkg9h1l2rvZKqtKwszwCSRsUg5byk2vJT_wnkHOfJ5W5oEu5kc6w5QhmgfgJBptACpYlU9mOpwzsuWJkd3ypGb5qIi15h55DTn6Em3vR_eW8FnnQjh6CHb1I_PYzd6uJisx89l', 'BBAAoWfBYUIZVCfioVYASjtK-aEJg-T9owcM7drqMCLDIYb_dqLw9JR2SN7QPnzITQB06uoCz2M95y3i64lfgOA', '6TTsTi0GN8jOvX0Zf2uXIA', NULL, '2025-11-08 01:28:56', '2025-11-08 01:28:56'),
(12, 'App\\Models\\Guest', 13, 'https://fcm.googleapis.com/fcm/send/eEVDuoYjbyw:APA91bE69Dvppa8x8H7MLm_sAXW-CeA3lv2hwKRU9KWQew2OoTnTvtgB2SSe_bp-7b6YdJ_L0tyVDAPVR-cvpiiN9ivyU5sfZZaYb2B1sU7J7YeY6zV6uOPU66lzi43OVfrR3pPdRi3Y', 'BFbOLrnj2KHLb9g_RyZkM_vwxg24QESoR4hHP5_bBWq80gY3RBys16tpRDcOtqDC8tB2b0EpOBXqzXiI7YBnNNE', 'F_aqdRZPKgz5s4Uj6j-XvA', NULL, '2025-11-08 04:37:29', '2025-11-08 04:37:29'),
(13, 'App\\Models\\Guest', 14, 'https://fcm.googleapis.com/fcm/send/fyqQImbJth8:APA91bHmbK6jxzev-d7dEc12xuTHkgZZIEP96fndr0tomw8PfZDzPBrTJnx6qY0XAjbjv9zZbXoAlf3EK7x8OGv_QCyfJWFzWgAYO9XcqMRJ-KCvU7bbtTY6XAVRHbujL7qJSeJo1yC1', 'BCDMHhfvYJBO5Dsh4a0OauV27GQXHrNqvNHxB2ol3eoKXGSGDM-Zz6liOiTo8wXbNBqmDpFcLcNdLqksnyhAZrM', 'RhPKWPyRQkeYGTF6HUM7PQ', NULL, '2025-11-08 07:28:28', '2025-11-08 07:28:28'),
(14, 'App\\Models\\Guest', 15, 'https://fcm.googleapis.com/fcm/send/cEjVVc6iP54:APA91bFzWtZ5M77jyBwiYKbQQus6RIYUyZjuQ68wIekQOdRpAIhpV6LAVWsc1rkpokRdya2tU-2NFjzxek3yQTKi1StM-ae2bVfOOJL-4ezoDDcM_pai5ZuvgV8EXndSKjxjeYJQT1tU', 'BDip2r0utkG8PZIQVlt7tD_k9RUrcwOUhxNFv9zRcOkvL6IZKyHUl4HIzjv-fnDpsQ-5rtnoWFcMa6ld-a5uW7o', 'mcsQIEZQQTfe-_9CQw8flg', NULL, '2025-11-08 07:54:17', '2025-11-08 07:54:17');

-- --------------------------------------------------------

--
-- Table structure for table `quick_links`
--

CREATE TABLE `quick_links` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `serial_number` smallint(5) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `quick_links`
--

INSERT INTO `quick_links` (`id`, `language_id`, `title`, `url`, `serial_number`, `created_at`, `updated_at`) VALUES
(3, 8, 'Terms & Conditions', 'https://codecanyon8.kreativdev.com/evento/terms-&-conditions', 1, '2021-06-22 22:52:38', '2023-05-07 10:42:03'),
(4, 8, 'About Us', 'https://codecanyon8.kreativdev.com/evento/about', 2, '2021-06-22 22:53:09', '2023-05-07 10:41:57'),
(5, 8, 'Contact Us', 'https://codecanyon8.kreativdev.com/evento/contact', 1, '2021-06-22 22:53:27', '2023-05-07 10:41:51'),
(9, 8, 'Organizers', 'https://codecanyon8.kreativdev.com/evento/organizers', 3, '2022-10-03 00:47:32', '2023-05-07 10:41:39'),
(10, 22, 'الشروط والأحكام', 'https://codecanyon8.kreativdev.com/evento/terms-&-conditions', 1, '2023-05-08 05:23:45', '2023-05-08 05:23:45'),
(11, 22, 'من نحن', 'https://codecanyon8.kreativdev.com/evento/about', 2, '2023-05-08 05:24:20', '2023-05-08 05:24:20'),
(12, 22, 'اتصل بنا', 'https://codecanyon8.kreativdev.com/evento/contact', 3, '2023-05-08 05:24:55', '2023-05-08 05:24:55'),
(13, 22, 'المنظمون', 'https://codecanyon8.kreativdev.com/evento/organizers', 4, '2023-05-08 05:25:20', '2023-05-08 05:25:20');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `permissions` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `name`, `permissions`, `created_at`, `updated_at`) VALUES
(4, 'Admin', '[\"Admin Management\",\"Basic Settings\",\"Payment Gateways\",\"Push Notification\",\"Subscribers\",\"Announcement Popups\",\"Advertise\",\"FAQ Management\",\"Blog Management\",\"Custom Pages\",\"Footer\",\"Home Page\",\"Support Ticket\",\"Customer Management\",\"Organizer Mangement\",\"Event Management\",\"Withdraw Method\",\"Menu Builder\",\"Lifetime Earning\",\"Total Profit\"]', '2021-08-06 22:42:38', '2023-05-03 12:55:43'),
(6, 'Moderator', '[\"Support Ticket\"]', '2021-08-07 22:14:34', '2023-05-03 12:59:16'),
(14, 'Supervisor', '[\"Mobile Interface\"]', '2021-11-24 22:48:53', '2025-10-28 04:55:58');

-- --------------------------------------------------------

--
-- Table structure for table `sections`
--

CREATE TABLE `sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `categories_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `about_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `featured_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `features_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `how_work_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `testimonials_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `partner_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `footer_section_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `sections`
--

INSERT INTO `sections` (`id`, `categories_section_status`, `about_section_status`, `featured_section_status`, `features_section_status`, `how_work_section_status`, `testimonials_section_status`, `partner_section_status`, `footer_section_status`, `created_at`, `updated_at`) VALUES
(1, 1, 1, 1, 1, 1, 1, 1, 1, '2021-12-11 00:55:13', '2023-01-21 05:55:02');

-- --------------------------------------------------------

--
-- Table structure for table `section_titles`
--

CREATE TABLE `section_titles` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `event_section_title` varchar(255) DEFAULT NULL,
  `category_section_title` varchar(255) DEFAULT NULL,
  `featured_instructors_section_title` varchar(255) DEFAULT NULL,
  `testimonials_section_title` varchar(255) DEFAULT NULL,
  `features_section_title` varchar(255) DEFAULT NULL,
  `blog_section_title` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `category_title` varchar(255) DEFAULT NULL,
  `upcoming_event_title` varchar(255) DEFAULT NULL,
  `features_title` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `section_titles`
--

INSERT INTO `section_titles` (`id`, `language_id`, `event_section_title`, `category_section_title`, `featured_instructors_section_title`, `testimonials_section_title`, `features_section_title`, `blog_section_title`, `created_at`, `updated_at`, `category_title`, `upcoming_event_title`, `features_title`) VALUES
(1, 8, 'Explore Our Events', 'Explore Category', 'Our Instructors', 'Customer Feedbacks', 'Our Features', 'Latest Blog', '2021-10-05 03:30:05', '2025-11-10 07:10:01', 'Category Section Title', 'Upcoming Event Section Title', 'Features Section Title'),
(4, 22, 'استكشف فعالياتنا', 'استكشاف الفئة', NULL, NULL, NULL, NULL, '2023-05-07 11:41:01', '2025-11-10 07:10:14', 'Features Section Title', 'Upcoming Event Section Title', 'Features Section Title');

-- --------------------------------------------------------

--
-- Table structure for table `seos`
--

CREATE TABLE `seos` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `meta_keyword_home` varchar(255) DEFAULT NULL,
  `meta_description_home` text,
  `meta_keyword_event` varchar(255) DEFAULT NULL,
  `meta_description_event` text,
  `meta_keyword_organizer` varchar(255) DEFAULT NULL,
  `meta_description_organizer` text,
  `meta_keyword_shop` varchar(255) DEFAULT NULL,
  `meta_description_shop` text,
  `meta_keyword_blog` varchar(255) DEFAULT NULL,
  `meta_description_blog` text,
  `meta_keyword_faq` varchar(255) DEFAULT NULL,
  `meta_description_faq` text,
  `meta_keyword_contact` varchar(255) DEFAULT NULL,
  `meta_description_contact` text,
  `meta_description_about` varchar(255) DEFAULT NULL,
  `meta_keyword_about` varchar(255) DEFAULT NULL,
  `meta_keyword_customer_login` varchar(255) DEFAULT NULL,
  `meta_description_customer_login` text,
  `meta_keyword_customer_signup` varchar(255) DEFAULT NULL,
  `meta_description_customer_signup` text,
  `meta_keyword_organizer_login` varchar(255) DEFAULT NULL,
  `meta_description_organizer_login` text,
  `meta_keyword_organizer_signup` varchar(255) DEFAULT NULL,
  `meta_description_organizer_signup` text,
  `meta_keyword_customer_forget_password` varchar(255) DEFAULT NULL,
  `meta_description_customer_forget_password` text,
  `meta_keyword_organizer_forget_password` varchar(255) DEFAULT NULL,
  `meta_description_organizer_forget_password` text,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `seos`
--

INSERT INTO `seos` (`id`, `language_id`, `meta_keyword_home`, `meta_description_home`, `meta_keyword_event`, `meta_description_event`, `meta_keyword_organizer`, `meta_description_organizer`, `meta_keyword_shop`, `meta_description_shop`, `meta_keyword_blog`, `meta_description_blog`, `meta_keyword_faq`, `meta_description_faq`, `meta_keyword_contact`, `meta_description_contact`, `meta_description_about`, `meta_keyword_about`, `meta_keyword_customer_login`, `meta_description_customer_login`, `meta_keyword_customer_signup`, `meta_description_customer_signup`, `meta_keyword_organizer_login`, `meta_description_organizer_login`, `meta_keyword_organizer_signup`, `meta_description_organizer_signup`, `meta_keyword_customer_forget_password`, `meta_description_customer_forget_password`, `meta_keyword_organizer_forget_password`, `meta_description_organizer_forget_password`, `created_at`, `updated_at`) VALUES
(2, 8, 'home', 'Home Description', 'Events', 'Event  Description', 'Organizer', 'Organizer Description', 'Shop', 'Shop Description', 'blog', 'Blog Description', 'faq', 'FAQ Description', 'contact', 'Contact Description', 'about us descriptions', 'about,us', 'login', 'Login Description', 'signup', 'Signup Description', 'organizer_login', 'Organizer Login Description', 'Organizer_signup', 'Organizer Signup Page', 'forget password', 'Forget Password Description', 'Organizer_forget', 'Organizer forget password', '2021-07-30 05:57:39', '2023-05-20 09:50:11'),
(3, 22, 'وطن', 'وصف المنزل', 'احداث', 'وصف الحدث', 'منظم', 'وصف المنظم', 'دكان', 'وصف المتجر', 'المدونة', 'وصف المدونة', 'الأسئلة المتداولة', 'وصف الأسئلة الشائعة', 'الاتصال', 'وصف الاتصال', NULL, NULL, 'تسجيل الدخول', 'وصف تسجيل الدخول', 'التسجيل', 'وصف الاشتراك', 'تسجيل دخول المنظم', 'وصف تسجيل دخول المنظم', 'تسجيل المنظم', 'صفحة تسجيل المنظم', 'نسيت كلمة المرور', 'نسيت وصف كلمة المرور', 'المنظم نسيت كلمة المرور', 'المنظم نسيت كلمة المرور', '2023-05-08 05:56:13', '2023-05-08 05:56:13');

-- --------------------------------------------------------

--
-- Table structure for table `shipping_charges`
--

CREATE TABLE `shipping_charges` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `days` varchar(255) DEFAULT NULL,
  `charge` decimal(11,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shipping_charges`
--

INSERT INTO `shipping_charges` (`id`, `title`, `language_id`, `text`, `days`, `charge`, `created_at`, `updated_at`) VALUES
(7, 'Method Two', 8, 'Method Two Shipping Charge', NULL, '10.00', '2022-06-26 00:31:09', '2023-05-06 10:40:35'),
(11, 'Method One', 8, 'Method One shipping charge', NULL, '12.00', '2022-07-01 23:06:39', '2023-05-06 10:40:16');

-- --------------------------------------------------------

--
-- Table structure for table `shop_coupons`
--

CREATE TABLE `shop_coupons` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `value` decimal(11,2) DEFAULT NULL,
  `start_date` varchar(255) DEFAULT NULL,
  `end_date` varchar(255) DEFAULT NULL,
  `minimum_spend` decimal(11,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `shop_coupons`
--

INSERT INTO `shop_coupons` (`id`, `name`, `code`, `type`, `value`, `start_date`, `end_date`, `minimum_spend`, `created_at`, `updated_at`) VALUES
(5, '999', '999', 'percentage', '10.00', '03/23/2023', '04/29/2026', '100.00', '2022-06-26 03:18:09', '2023-09-30 10:20:31'),
(7, 'Hot 11', 'hot11', 'fixed', '10.00', '05/06/2023', '04/29/2026', '100.00', '2023-05-07 07:48:18', '2023-05-07 07:48:18');

-- --------------------------------------------------------

--
-- Table structure for table `slots`
--

CREATE TABLE `slots` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) UNSIGNED NOT NULL,
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `pricing_type` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `slot_enable` tinyint(4) NOT NULL DEFAULT '0',
  `slot_unique_id` bigint(20) UNSIGNED NOT NULL,
  `type` tinyint(4) NOT NULL COMMENT '1= slot with manual select seat 2 = slot auto manual select seats',
  `number_of_seat` int(11) NOT NULL,
  `pos_x` double NOT NULL,
  `pos_y` double NOT NULL,
  `width` double NOT NULL,
  `height` double NOT NULL,
  `round` int(11) NOT NULL DEFAULT '0',
  `price` decimal(8,2) NOT NULL DEFAULT '0.00',
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rotate` double(8,2) DEFAULT NULL,
  `background_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `border_color` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `font_size` double(8,2) NOT NULL DEFAULT '14.00',
  `is_deactive` tinyint(4) NOT NULL DEFAULT '0',
  `is_booked` tinyint(4) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `slots`
--

INSERT INTO `slots` (`id`, `event_id`, `ticket_id`, `pricing_type`, `slot_enable`, `slot_unique_id`, `type`, `number_of_seat`, `pos_x`, `pos_y`, `width`, `height`, `round`, `price`, `name`, `rotate`, `background_color`, `border_color`, `font_size`, `is_deactive`, `is_booked`, `created_at`, `updated_at`) VALUES
(13, 105, 164, 'free', 1, 708424, 2, 1, 190, 286.84375, 30, 30, 10, '0.00', 'A1', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-04 07:07:34', '2025-10-11 08:49:11'),
(14, 105, 164, 'free', 1, 708424, 1, 2, 261, 294.84375, 30, 30, 10, '0.00', 'A2', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-04 07:07:57', '2025-10-11 08:49:11'),
(16, 105, 164, 'normal', 1, 756471, 2, 5, 192, 284.84375, 30, 30, 10, '50.00', 'RR', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-04 07:10:21', '2025-10-11 08:50:12'),
(17, 105, 164, 'normal', 1, 756471, 1, 6, 252, 285.84375, 30, 30, 65, '10.00', 'R3', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-04 07:10:55', '2025-10-11 08:50:12'),
(19, 105, 164, 'variation', 0, 231988, 2, 12, 244, 285.84375, 30, 30, 49, '15.00', 'R', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-04 23:51:16', '2025-10-21 01:11:42'),
(20, 105, 185, 'free', 1, 192783, 2, 10, 189, 284.84375, 30, 30, 10, '0.00', 'B2', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-08 08:14:25', '2025-10-20 08:00:40'),
(21, 105, 164, 'normal', 1, 756471, 2, 5, 455.2325439453125, 285.0762939453125, 30, 30, 10, '10.00', 'B2', 10.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-09 08:07:41', '2025-10-11 08:50:12'),
(22, 105, 164, 'variation', 0, 231988, 2, 5, 299, 285.84375, 30, 30, 10, '10.00', 'RR', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-14 05:45:23', '2025-10-21 01:11:42'),
(23, 105, 164, 'variation', 0, 231988, 1, 5, 416, 283.84375, 30, 30, 10, '5.00', 'B2', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-14 05:45:54', '2025-10-21 01:11:42'),
(24, 105, 164, 'variation', 0, 231988, 1, 2, 479, 289.84375, 30, 30, 10, '10.00', 'x', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-14 05:47:41', '2025-10-21 01:11:42'),
(27, 105, 187, 'free', 0, 485878, 2, 10, 213, 289.84375, 30, 30, 10, '0.00', 'A1', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 01:32:50', '2025-10-21 01:32:50'),
(28, 105, 188, 'normal', 0, 363827, 2, 1, 203.6231689453125, 297.4669189453125, 30, 30, 10, '10.00', 'RR', 10.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 01:40:45', '2025-10-21 01:41:01'),
(30, 105, 189, 'free', 1, 671518, 2, 10, 193, 288.84375, 30, 30, 10, '0.00', 'RR', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 03:10:15', '2025-11-02 06:47:46'),
(31, 105, 190, 'normal', 1, 436376, 1, 10, 404.6231689453125, 294.4669189453125, 30, 30, 10, '3.00', 'B2', 10.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 03:12:00', '2025-11-02 06:47:46'),
(32, 105, 188, 'variation', 0, 300460, 1, 10, 535, 42.84375, 30, 30, 10, '100.00', '1x', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 03:16:35', '2025-10-29 05:52:54'),
(33, 105, 190, 'normal', 1, 436376, 2, 10, 263, 292.84375, 30, 30, 10, '10.00', 'RR', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 04:29:19', '2025-11-02 06:47:46'),
(34, 105, 190, 'normal', 1, 436376, 1, 10, 247, 367.84375, 30, 30, 10, '0.00', '55', 0.00, '#00e5b5', NULL, 14.00, 1, 0, '2025-10-21 04:39:45', '2025-10-21 05:08:34'),
(35, 105, 191, 'normal', 0, 898428, 2, 10, 193, 281.84375, 30, 30, 10, '100.00', 'Test Slot', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-21 06:23:32', '2025-10-29 03:15:42'),
(36, 105, 191, 'normal', 0, 898428, 1, 5, 297.8419189453125, 282.6856689453125, 30, 30, 10, '0.00', '5', 10.00, '#00e5b5', NULL, 14.00, 1, 0, '2025-10-21 06:28:04', '2025-10-29 03:15:42'),
(37, 103, 192, 'normal', 0, 162478, 2, 5, 190, 288.84375, 30, 30, 10, '10.00', 'TR', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-10-22 07:46:47', '2025-10-25 01:36:38'),
(40, 125, 194, 'free', 1, 564966, 1, 2, 97, 359.84375, 180, 80, 10, '0.00', 'B2', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-05 00:35:10', '2025-11-06 01:13:22'),
(41, 125, 194, 'free', 1, 564966, 1, 2, 475, 286.84375, 30, 30, 10, '0.00', 'b4', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-05 01:30:38', '2025-11-05 02:12:38'),
(49, 126, 198, 'variation', 1, 659237, 1, 5, 220, 118.8125, 83, 66, 8, '20.00', 'NZ-First', 0.00, '#00e5b5', NULL, 16.00, 0, 0, '2025-11-06 04:41:43', '2025-11-10 06:31:18'),
(50, 126, 198, 'variation', 1, 659237, 1, 6, 313, 115.8125, 83, 66, 7, '10.00', 'NZ-Second', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-06 04:46:55', '2025-11-10 06:31:18'),
(51, 126, 198, 'variation', 1, 659237, 1, 6, 405, 116.828125, 83, 66, 8, '20.00', 'NZ-Third', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-06 04:49:15', '2025-11-10 06:31:18'),
(52, 126, 198, 'variation', 1, 470615, 1, 10, 495, 119.8125, 66, 128, 6, '9.00', 'EZ-First', 0.00, '#00e5b5', NULL, 18.00, 0, 0, '2025-11-06 04:56:06', '2025-11-10 06:31:18'),
(53, 126, 198, 'variation', 1, 470615, 1, 10, 492, 255.8125, 66, 128, 8, '9.00', 'EZ-Sceond', 0.00, '#00e5b5', NULL, 17.00, 0, 0, '2025-11-06 04:58:35', '2025-11-10 06:31:18'),
(54, 126, 198, 'variation', 1, 412059, 1, 5, 217, 317, 83, 66, 10, '10.00', 'SZ-First', 0.00, '#00e5b5', NULL, 16.00, 0, 0, '2025-11-06 05:01:46', '2025-11-10 06:31:18'),
(55, 126, 198, 'variation', 1, 412059, 1, 3, 311, 317.84375, 83, 66, 10, '50.00', 'SZ-Second', 0.00, '#00e5b5', NULL, 16.00, 0, 0, '2025-11-06 05:05:36', '2025-11-10 06:31:18'),
(56, 126, 198, 'variation', 1, 412059, 1, 5, 402, 317, 83, 66, 8, '20.00', 'SZ-Third', 0.00, '#00e5b5', NULL, 16.00, 0, 0, '2025-11-06 05:09:37', '2025-11-10 06:31:18'),
(57, 126, 198, 'variation', 1, 982246, 1, 5, 140, 119, 66, 128, 7, '20.00', 'WZ-First', 0.00, '#00e5b5', NULL, 16.00, 0, 0, '2025-11-06 05:12:54', '2025-11-10 06:31:18'),
(58, 126, 198, 'variation', 1, 982246, 1, 5, 143, 256, 66, 128, 9, '60.00', 'WZ-Second', 0.00, '#00e5b5', NULL, 17.00, 0, 0, '2025-11-06 05:14:55', '2025-11-10 06:31:18'),
(59, 127, 200, 'normal', 1, 688688, 2, 2, 106, 307.84375, 105, 51, 10, '108.00', 'Couple-1', 0.00, '#7ee600', NULL, 14.00, 0, 0, '2025-11-08 00:54:03', '2025-11-08 07:51:52'),
(60, 127, 200, 'normal', 1, 688688, 2, 2, 220, 306.84375, 104, 50, 10, '50.00', 'Couple-2', 0.00, '#7ee600', NULL, 14.00, 1, 0, '2025-11-08 00:57:13', '2025-11-08 07:51:52'),
(61, 127, 200, 'normal', 1, 688688, 2, 1, 333, 308.84375, 50, 50, 57, '5.00', 'A2', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 00:58:43', '2025-11-08 07:51:52'),
(62, 127, 200, 'normal', 1, 688688, 2, 1, 392, 309.84375, 50, 50, 61, '5.00', 'A2', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 00:59:51', '2025-11-08 07:51:52'),
(63, 127, 200, 'normal', 1, 688688, 2, 2, 450, 307.84375, 107, 50, 10, '0.00', 'Couple-3', 0.00, '#7ee600', NULL, 14.00, 0, 0, '2025-11-08 01:00:24', '2025-11-08 07:51:52'),
(64, 127, 200, 'normal', 1, 688688, 2, 2, 565, 307.84375, 110, 50, 10, '10.00', 'couple-5', 0.00, '#7ee600', NULL, 14.00, 1, 0, '2025-11-08 01:01:54', '2025-11-08 07:51:52'),
(65, 127, 200, 'normal', 1, 688688, 2, 1, 105, 377.84375, 50, 50, 51, '10.00', 'B1', 0.00, '#af640d', NULL, 14.00, 1, 0, '2025-11-08 01:02:49', '2025-11-08 07:51:52'),
(66, 127, 200, 'normal', 1, 688688, 2, 1, 169, 378.84375, 50, 50, 61, '12.00', 'B2', 0.00, '#af640d', NULL, 14.00, 1, 0, '2025-11-08 01:03:45', '2025-11-08 07:51:52'),
(67, 127, 200, 'normal', 1, 688688, 2, 1, 233, 377.84375, 50, 50, 71, '15.00', 'B3', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:04:38', '2025-11-08 07:51:52'),
(68, 127, 200, 'normal', 1, 688688, 2, 1, 297, 375.84375, 50, 50, 60, '60.00', 'B4', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:05:19', '2025-11-08 07:51:52'),
(69, 127, 200, 'normal', 1, 688688, 2, 1, 360, 377.84375, 50, 50, 61, '10.00', 'B5', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:07:12', '2025-11-08 07:51:52'),
(70, 127, 200, 'normal', 1, 688688, 2, 1, 427, 377.84375, 50, 50, 61, '15.00', 'B6', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:08:33', '2025-11-08 07:51:52'),
(71, 127, 200, 'normal', 1, 688688, 2, 7, 489, 378.84375, 50, 50, 50, '10.00', 'B7', 0.00, '#af640d', NULL, 14.00, 1, 0, '2025-11-08 01:16:24', '2025-11-08 07:51:52'),
(73, 127, 200, 'normal', 1, 688688, 2, 1, 552, 377.84375, 50, 50, 66, '110.00', 'B9', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:19:06', '2025-11-08 07:51:52'),
(74, 127, 200, 'normal', 1, 688688, 2, 1, 619, 379.84375, 50, 50, 50, '0.00', 'B10', 0.00, '#af640d', NULL, 14.00, 0, 0, '2025-11-08 01:19:46', '2025-11-08 07:51:52'),
(75, 127, 200, 'normal', 1, 688688, 1, 5, 104, 448.84375, 277, 49, 6, '12.00', 'Gold Class', 0.00, '#ffd000', NULL, 25.00, 0, 0, '2025-11-08 01:23:47', '2025-11-08 07:51:52'),
(76, 127, 200, 'normal', 1, 688688, 1, 7, 396, 446.84375, 274, 51, 7, '20.00', 'Platinum', 0.00, '#ffd000', NULL, 22.00, 0, 0, '2025-11-08 01:25:59', '2025-11-08 07:51:52'),
(77, 127, 200, 'normal', 1, 688688, 2, 1, 92, 629.84375, 50, 50, 50, '10.00', 'D1', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:28:22', '2025-11-08 07:51:52'),
(78, 127, 200, 'normal', 1, 688688, 2, 1, 171, 628.84375, 50, 50, 50, '10.00', 'D2', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:30:04', '2025-11-08 07:51:52'),
(79, 127, 200, 'normal', 1, 688688, 2, 1, 247, 628.84375, 50, 50, 50, '50.00', 'D3', 0.00, '#a9610d', NULL, 14.00, 1, 0, '2025-11-08 01:31:04', '2025-11-08 07:51:52'),
(80, 127, 200, 'normal', 1, 688688, 2, 1, 324, 629.84375, 50, 50, 50, '20.00', 'D4', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:32:19', '2025-11-08 07:51:52'),
(81, 127, 200, 'normal', 1, 688688, 2, 1, 401, 629.84375, 50, 50, 50, '10.00', 'D5', 0.00, '#a9610d', NULL, 14.00, 1, 0, '2025-11-08 01:33:29', '2025-11-08 07:51:52'),
(82, 127, 200, 'normal', 1, 688688, 2, 1, 479, 629.84375, 50, 50, 50, '150.00', 'D6', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:34:17', '2025-11-08 07:51:52'),
(83, 127, 200, 'normal', 1, 688688, 2, 7, 556, 629.84375, 50, 50, 50, '110.00', 'D7', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:35:01', '2025-11-08 07:51:52'),
(84, 127, 200, 'normal', 1, 688688, 2, 1, 634, 626.84375, 50, 50, 50, '110.00', 'D8', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:35:48', '2025-11-08 07:51:52'),
(85, 127, 200, 'normal', 1, 688688, 2, 1, 130, 695.84375, 50, 50, 50, '10.00', 'E1', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:38:24', '2025-11-08 07:51:52'),
(86, 127, 200, 'normal', 1, 688688, 2, 1, 208, 695.84375, 50, 50, 50, '0.00', 'E2', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:39:03', '2025-11-08 07:51:52'),
(87, 127, 200, 'normal', 1, 688688, 2, 1, 285, 694.84375, 50, 50, 50, '10.00', 'E3', 0.00, '#a9610d', NULL, 14.00, 1, 0, '2025-11-08 01:39:46', '2025-11-08 07:51:52'),
(88, 127, 200, 'normal', 1, 688688, 2, 1, 364, 696.84375, 50, 50, 74, '10.00', 'E4', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:41:04', '2025-11-08 07:51:52'),
(89, 127, 200, 'normal', 1, 688688, 2, 1, 441, 696.84375, 50, 50, 50, '0.00', 'E6', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:41:37', '2025-11-08 07:51:52'),
(90, 127, 200, 'normal', 1, 688688, 2, 1, 519, 697.84375, 50, 50, 50, '0.00', 'E7', 0.00, '#a9610d', NULL, 14.00, 0, 0, '2025-11-08 01:42:44', '2025-11-08 07:51:52'),
(91, 127, 200, 'normal', 1, 688688, 2, 1, 592, 696.84375, 50, 50, 50, '10.00', 'E8', 0.00, '#a25a09', NULL, 14.00, 1, 0, '2025-11-08 01:43:30', '2025-11-08 07:51:52'),
(92, 127, 201, 'normal', 0, 428313, 2, 2, 209, 571.84375, 30, 30, 10, '0.00', 'Test Slot', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 03:45:15', '2025-11-08 03:45:15'),
(93, 127, 201, 'normal', 0, 428313, 2, 1, 433, 566.84375, 30, 30, 10, '10.00', 'A1', 0.00, '#00e5b5', NULL, 14.00, 1, 0, '2025-11-08 03:45:30', '2025-11-08 03:45:51'),
(94, 128, 202, 'free', 1, 971199, 1, 10, 88, 302.84375, 204, 50, 6, '0.00', 'Executive VIP', 0.00, '#67e600', NULL, 16.00, 0, 0, '2025-11-08 07:09:22', '2025-11-08 07:58:29'),
(95, 128, 202, 'free', 1, 971199, 1, 5, 408, 304.84375, 205, 50, 6, '0.00', 'Elite Business', 0.00, '#67e600', NULL, 16.00, 0, 0, '2025-11-08 07:11:26', '2025-11-08 07:58:29'),
(96, 128, 202, 'free', 1, 971199, 2, 1, 297, 306.84375, 50, 50, 78, '0.00', 'D1', 0.00, '#bf00e6', NULL, 14.00, 1, 0, '2025-11-08 07:12:13', '2025-11-08 07:58:29'),
(97, 128, 202, 'free', 1, 971199, 2, 1, 355, 306.84375, 50, 50, 50, '0.00', 'D2', 0.00, '#bf00e6', NULL, 14.00, 0, 0, '2025-11-08 07:12:50', '2025-11-08 07:58:29'),
(98, 128, 202, 'free', 1, 971199, 2, 1, 93, 368.84375, 50, 50, 50, '0.00', 'G1', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:14:19', '2025-11-08 07:58:29'),
(99, 128, 202, 'free', 1, 971199, 2, 1, 150, 368.84375, 50, 50, 50, '0.00', 'G2', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:14:39', '2025-11-08 07:58:29'),
(100, 128, 202, 'free', 1, 971199, 2, 1, 210, 370.84375, 50, 50, 50, '0.00', 'G3', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:15:09', '2025-11-08 07:58:29'),
(101, 128, 202, 'free', 1, 971199, 2, 1, 268, 367.84375, 50, 50, 50, '0.00', 'G4', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:15:35', '2025-11-08 07:58:29'),
(102, 128, 202, 'free', 1, 971199, 2, 1, 325, 366.84375, 50, 50, 50, '0.00', 'G5', 0.00, '#00e5b5', NULL, 14.00, 1, 0, '2025-11-08 07:16:13', '2025-11-08 07:58:29'),
(103, 128, 202, 'free', 1, 971199, 2, 1, 385, 367.84375, 50, 50, 50, '0.00', 'G6', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:16:51', '2025-11-08 07:58:29'),
(104, 128, 202, 'free', 1, 971199, 2, 1, 440, 368.84375, 50, 50, 50, '0.00', 'G7', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:17:17', '2025-11-08 07:58:29'),
(105, 128, 202, 'free', 1, 971199, 2, 1, 500, 366.84375, 50, 50, 50, '0.00', 'G8', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:17:48', '2025-11-08 07:58:29'),
(106, 128, 202, 'free', 1, 971199, 2, 1, 558, 366.84375, 50, 50, 50, '0.00', 'G8', 0.00, '#00e5b5', NULL, 14.00, 0, 0, '2025-11-08 07:18:38', '2025-11-08 07:58:29'),
(107, 128, 202, 'free', 1, 971199, 2, 2, 94, 438.84375, 168, 50, 6, '0.00', 'Couple A', 0.00, '#cb2a98', NULL, 19.00, 1, 0, '2025-11-08 07:19:59', '2025-11-08 07:58:29'),
(108, 128, 202, 'free', 1, 971199, 2, 5, 269, 436.84375, 164, 50, 5, '0.00', 'Group -Person - 5', 0.00, '#cb2a98', NULL, 19.00, 0, 0, '2025-11-08 07:21:39', '2025-11-08 07:58:29'),
(109, 128, 202, 'free', 1, 971199, 2, 7, 442, 435.84375, 165, 50, 6, '0.00', 'Group - Person -7', 0.00, '#cb2a98', NULL, 19.00, 0, 0, '2025-11-08 07:23:38', '2025-11-08 07:58:29'),
(110, 128, 202, 'free', 1, 971199, 1, 8, 93, 502.84375, 167, 50, 10, '0.00', 'General Access', 0.00, '#c4b721', NULL, 19.00, 0, 0, '2025-11-08 07:25:22', '2025-11-08 07:58:29'),
(111, 128, 202, 'free', 1, 971199, 1, 10, 270, 504.84375, 165, 50, 6, '0.00', 'Student Pass', 0.00, '#c4b721', NULL, 19.00, 0, 0, '2025-11-08 07:26:33', '2025-11-08 07:58:29'),
(112, 128, 202, 'free', 1, 971199, 1, 10, 442, 504.84375, 167, 50, 6, '0.00', 'Media Seat', 0.00, '#c4b721', NULL, 18.00, 1, 0, '2025-11-08 07:27:36', '2025-11-08 07:58:29');

-- --------------------------------------------------------

--
-- Table structure for table `slot_images`
--

CREATE TABLE `slot_images` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` bigint(20) UNSIGNED NOT NULL,
  `ticket_id` bigint(20) UNSIGNED NOT NULL,
  `slot_unique_id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `slot_images`
--

INSERT INTO `slot_images` (`id`, `event_id`, `ticket_id`, `slot_unique_id`, `image`, `created_at`, `updated_at`) VALUES
(1, 105, 164, 708424, '68dbbe12f2bab.jpg', '2025-09-30 04:42:23', '2025-09-30 05:25:06'),
(2, 105, 164, 756471, '68dcc0c71ab7f.jpg', '2025-09-30 23:48:55', '2025-09-30 23:48:55'),
(6, 105, 185, 192783, '68e6559574956.jpg', '2025-10-08 08:14:13', '2025-10-08 08:14:13'),
(8, 105, 186, 583008, '68f716254778a.jpg', '2025-10-21 01:12:05', '2025-10-21 01:12:05'),
(9, 105, 187, 485878, '68f71ad0401ee.jpg', '2025-10-21 01:32:00', '2025-10-21 01:32:00'),
(10, 105, 188, 363827, '68f71cc0b2662.jpg', '2025-10-21 01:40:16', '2025-10-21 01:40:16'),
(12, 105, 189, 671518, '68f731c7f2c34.jpg', '2025-10-21 03:10:00', '2025-10-21 03:10:00'),
(13, 105, 190, 436376, '68f73234e3cc4.jpg', '2025-10-21 03:11:48', '2025-10-21 03:11:48'),
(14, 105, 191, 898428, '6900c02aac6e5.jpg', '2025-10-21 05:27:35', '2025-10-28 08:07:54'),
(15, 103, 192, 162478, '68f8c4154c3ef.jpg', '2025-10-22 07:46:29', '2025-10-22 07:46:29'),
(17, 125, 194, 564966, '690ae1f1deecd.jpg', '2025-11-05 00:34:41', '2025-11-05 00:34:41'),
(18, 126, 198, 659237, '690c85910c74a.jpg', '2025-11-06 03:57:18', '2025-11-06 06:25:05'),
(19, 126, 198, 470615, '6911c6bf006ea.jpg', '2025-11-06 04:51:24', '2025-11-10 06:04:31'),
(20, 126, 198, 412059, '6911c6cf50510.jpg', '2025-11-06 05:01:03', '2025-11-10 06:04:47'),
(21, 126, 198, 982246, '6911c6b26265b.jpg', '2025-11-06 05:11:18', '2025-11-10 06:04:18'),
(22, 126, 199, 236612, '690c817f0baeb.jpg', '2025-11-06 06:07:43', '2025-11-06 06:07:43'),
(23, 127, 200, 688688, '690edabcc7844.jpg', '2025-11-08 00:53:00', '2025-11-08 00:53:00'),
(24, 127, 201, 428313, '690f0309a0193.jpg', '2025-11-08 03:44:57', '2025-11-08 03:44:57'),
(25, 128, 202, 971199, '690f327f7327e.jpg', '2025-11-08 06:46:03', '2025-11-08 07:07:27');

-- --------------------------------------------------------

--
-- Table structure for table `slot_seats`
--

CREATE TABLE `slot_seats` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `slot_id` int(10) UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` decimal(8,2) NOT NULL DEFAULT '0.00',
  `is_deactive` tinyint(4) NOT NULL DEFAULT '0',
  `is_booked` tinyint(4) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `slot_seats`
--

INSERT INTO `slot_seats` (`id`, `slot_id`, `name`, `price`, `is_deactive`, `is_booked`) VALUES
(155, 13, 'A1-01', '0.00', 0, 0),
(156, 14, 'A2-01', '0.00', 0, 0),
(157, 14, 'A2-02', '0.00', 0, 0),
(160, 16, 'RR-01', '10.00', 0, 0),
(161, 16, 'RR-02', '10.00', 0, 0),
(162, 16, 'RR-03', '10.00', 0, 0),
(163, 16, 'RR-04', '10.00', 0, 0),
(164, 16, 'RR-05', '10.00', 0, 0),
(165, 17, 'R3-01', '10.00', 0, 0),
(166, 17, 'R3-02', '20.00', 0, 0),
(167, 17, 'R3-03', '30.00', 0, 0),
(168, 17, 'R3-04', '40.00', 0, 0),
(169, 17, 'R3-05', '50.00', 0, 0),
(170, 17, 'R3-06', '60.00', 0, 0),
(173, 19, 'R-01', '1.25', 0, 0),
(174, 19, 'R-02', '1.25', 0, 0),
(175, 19, 'R-03', '1.25', 0, 0),
(176, 19, 'R-04', '1.25', 0, 0),
(177, 19, 'R-05', '1.25', 0, 0),
(178, 19, 'R-06', '1.25', 0, 0),
(179, 19, 'R-07', '1.25', 0, 0),
(180, 19, 'R-08', '1.25', 0, 0),
(181, 19, 'R-09', '1.25', 0, 0),
(182, 19, 'R-10', '1.25', 0, 0),
(183, 19, 'R-11', '1.25', 0, 0),
(184, 19, 'R-12', '1.25', 0, 0),
(185, 20, 'B2-01', '0.00', 0, 0),
(186, 20, 'B2-02', '0.00', 0, 0),
(187, 20, 'B2-03', '0.00', 0, 0),
(188, 20, 'B2-04', '0.00', 0, 0),
(189, 20, 'B2-05', '0.00', 0, 0),
(190, 20, 'B2-06', '0.00', 0, 0),
(191, 20, 'B2-07', '0.00', 0, 0),
(192, 20, 'B2-08', '0.00', 0, 0),
(193, 20, 'B2-09', '0.00', 0, 0),
(194, 20, 'B2-10', '0.00', 0, 0),
(195, 21, 'B2-01', '2.00', 0, 0),
(196, 21, 'B2-02', '2.00', 0, 0),
(197, 21, 'B2-03', '2.00', 0, 0),
(198, 21, 'B2-04', '2.00', 0, 0),
(199, 21, 'B2-05', '2.00', 0, 0),
(200, 22, 'RR-01', '2.00', 0, 0),
(201, 22, 'RR-02', '2.00', 0, 0),
(202, 22, 'RR-03', '2.00', 0, 0),
(203, 22, 'RR-04', '2.00', 0, 0),
(204, 22, 'RR-05', '2.00', 0, 0),
(205, 23, 'B2-01', '100.00', 0, 0),
(206, 23, 'B2-02', '50.00', 0, 0),
(207, 23, 'B2-03', '60.00', 0, 0),
(208, 23, 'B2-04', '80.00', 0, 0),
(209, 23, 'B2-05', '5.00', 1, 0),
(235, 24, 'x-01', '80.00', 1, 0),
(236, 24, 'x-02', '10.00', 1, 0),
(247, 27, 'A1-01', '0.00', 0, 0),
(248, 27, 'A1-02', '0.00', 0, 0),
(249, 27, 'A1-03', '0.00', 0, 0),
(250, 27, 'A1-04', '0.00', 0, 0),
(251, 27, 'A1-05', '0.00', 0, 0),
(252, 27, 'A1-06', '0.00', 0, 0),
(253, 27, 'A1-07', '0.00', 0, 0),
(254, 27, 'A1-08', '0.00', 0, 0),
(255, 27, 'A1-09', '0.00', 0, 0),
(256, 27, 'A1-10', '0.00', 0, 0),
(257, 28, 'RR-01', '10.00', 0, 0),
(268, 30, 'RR-01', '0.00', 0, 0),
(269, 30, 'RR-02', '0.00', 0, 0),
(270, 30, 'RR-03', '0.00', 0, 0),
(271, 30, 'RR-04', '0.00', 0, 0),
(272, 30, 'RR-05', '0.00', 0, 0),
(273, 30, 'RR-06', '0.00', 0, 0),
(274, 30, 'RR-07', '0.00', 0, 0),
(275, 30, 'RR-08', '0.00', 0, 0),
(276, 30, 'RR-09', '0.00', 0, 0),
(277, 30, 'RR-10', '0.00', 0, 0),
(278, 31, 'B2-01', '100.00', 0, 0),
(279, 31, 'B2-02', '3.00', 0, 0),
(280, 31, 'B2-03', '100.00', 0, 0),
(281, 31, 'B2-04', '100.00', 0, 0),
(282, 31, 'B2-05', '100.00', 0, 0),
(283, 31, 'B2-06', '100.00', 0, 0),
(284, 31, 'B2-07', '100.00', 0, 0),
(285, 31, 'B2-08', '100.00', 0, 0),
(286, 31, 'B2-09', '100.00', 0, 0),
(287, 31, 'B2-10', '100.00', 0, 0),
(288, 32, '1x-01', '100.00', 0, 0),
(289, 32, '1x-02', '100.00', 0, 0),
(290, 32, '1x-03', '100.00', 0, 0),
(291, 32, '1x-04', '100.00', 0, 0),
(292, 32, '1x-05', '100.00', 0, 0),
(293, 32, '1x-06', '100.00', 0, 0),
(294, 32, '1x-07', '100.00', 0, 0),
(295, 32, '1x-08', '100.00', 0, 0),
(296, 32, '1x-09', '100.00', 0, 0),
(297, 32, '1x-10', '100.00', 0, 0),
(298, 33, 'RR-01', '1.00', 0, 0),
(299, 33, 'RR-02', '1.00', 0, 0),
(300, 33, 'RR-03', '1.00', 0, 0),
(301, 33, 'RR-04', '1.00', 0, 0),
(302, 33, 'RR-05', '1.00', 0, 0),
(303, 33, 'RR-06', '1.00', 0, 0),
(304, 33, 'RR-07', '1.00', 0, 0),
(305, 33, 'RR-08', '1.00', 0, 0),
(306, 33, 'RR-09', '1.00', 0, 0),
(307, 33, 'RR-10', '1.00', 0, 0),
(308, 34, '55-01', '100.00', 0, 0),
(309, 34, '55-02', '5.00', 0, 0),
(310, 34, '55-03', '0.00', 0, 0),
(311, 34, '55-04', '0.00', 0, 0),
(312, 34, '55-05', '0.00', 0, 0),
(313, 34, '55-06', '0.00', 0, 0),
(314, 34, '55-07', '0.00', 0, 0),
(315, 34, '55-08', '0.00', 0, 0),
(316, 34, '55-09', '0.00', 0, 0),
(317, 34, '55-10', '0.00', 0, 0),
(318, 35, 'Test Slot-01', '10.00', 1, 0),
(319, 35, 'Test Slot-02', '10.00', 1, 0),
(320, 35, 'Test Slot-03', '10.00', 0, 0),
(321, 35, 'Test Slot-04', '10.00', 0, 0),
(322, 35, 'Test Slot-05', '10.00', 0, 0),
(323, 35, 'Test Slot-06', '10.00', 0, 0),
(324, 35, 'Test Slot-07', '10.00', 0, 0),
(325, 35, 'Test Slot-08', '10.00', 0, 0),
(326, 35, 'Test Slot-09', '10.00', 0, 0),
(327, 35, 'Test Slot-10', '10.00', 0, 0),
(328, 36, '5-01', '100.00', 1, 0),
(329, 36, '5-02', '200.00', 1, 0),
(330, 36, '5-03', '300.00', 1, 0),
(331, 36, '5-04', '0.00', 0, 0),
(332, 36, '5-05', '0.00', 0, 0),
(333, 37, 'TR-01', '2.00', 0, 0),
(334, 37, 'TR-02', '2.00', 0, 0),
(335, 37, 'TR-03', '2.00', 0, 0),
(336, 37, 'TR-04', '2.00', 0, 0),
(337, 37, 'TR-05', '2.00', 0, 0),
(350, 40, 'B2-01', '0.00', 0, 0),
(351, 40, 'B2-02', '0.00', 0, 0),
(352, 41, 'b4-01', '0.00', 0, 0),
(353, 41, 'b4-02', '0.00', 0, 0),
(390, 49, 'NZ-First-01', '20.00', 0, 0),
(391, 49, 'NZ-First-02', '30.00', 0, 0),
(392, 49, 'NZ-First-03', '40.00', 0, 0),
(393, 49, 'NZ-First-04', '50.00', 0, 0),
(394, 49, 'NZ-First-05', '60.00', 0, 0),
(395, 50, 'NZ-Second-01', '10.00', 0, 0),
(396, 50, 'NZ-Second-02', '20.00', 0, 0),
(397, 50, 'NZ-Second-03', '30.00', 0, 0),
(398, 50, 'NZ-Second-04', '40.00', 0, 0),
(399, 50, 'NZ-Second-05', '50.00', 0, 0),
(400, 50, 'NZ-Second-06', '20.00', 0, 0),
(401, 51, 'NZ-Third-01', '100.00', 0, 0),
(402, 51, 'NZ-Third-02', '200.00', 0, 0),
(403, 51, 'NZ-Third-03', '30.00', 0, 0),
(404, 51, 'NZ-Third-04', '30.00', 0, 0),
(405, 51, 'NZ-Third-05', '20.00', 0, 0),
(406, 51, 'NZ-Third-06', '21.00', 0, 0),
(407, 52, 'EZ-First-01', '10.00', 0, 0),
(408, 52, 'EZ-First-02', '20.00', 0, 0),
(409, 52, 'EZ-First-03', '30.00', 0, 0),
(410, 52, 'EZ-First-04', '40.00', 0, 0),
(411, 52, 'EZ-First-05', '9.00', 0, 0),
(412, 52, 'EZ-First-06', '10.00', 0, 0),
(413, 52, 'EZ-First-07', '10.00', 0, 0),
(414, 52, 'EZ-First-08', '10.00', 0, 0),
(415, 52, 'EZ-First-09', '20.00', 0, 0),
(416, 52, 'EZ-First-10', '20.00', 0, 0),
(417, 53, 'EZ-Sceond-01', '10.00', 0, 0),
(418, 53, 'EZ-Sceond-02', '10.00', 0, 0),
(419, 53, 'EZ-Sceond-03', '10.00', 0, 0),
(420, 53, 'EZ-Sceond-04', '9.00', 0, 0),
(421, 53, 'EZ-Sceond-05', '10.00', 0, 0),
(422, 53, 'EZ-Sceond-06', '10.00', 0, 0),
(423, 53, 'EZ-Sceond-07', '10.00', 0, 0),
(424, 53, 'EZ-Sceond-08', '10.00', 0, 0),
(425, 53, 'EZ-Sceond-09', '10.00', 0, 0),
(426, 53, 'EZ-Sceond-10', '10.00', 0, 0),
(427, 54, 'SZ-First-01', '10.00', 0, 0),
(428, 54, 'SZ-First-02', '20.00', 0, 0),
(429, 54, 'SZ-First-03', '10.00', 0, 0),
(430, 54, 'SZ-First-04', '30.00', 0, 0),
(431, 54, 'SZ-First-05', '10.00', 0, 0),
(432, 55, 'SZ-Second-01', '50.00', 0, 0),
(433, 55, 'SZ-Second-02', '70.00', 0, 0),
(434, 55, 'SZ-Second-03', '80.00', 0, 0),
(435, 56, 'SZ-Third-01', '20.00', 0, 0),
(436, 56, 'SZ-Third-02', '20.00', 0, 0),
(437, 56, 'SZ-Third-03', '30.00', 0, 0),
(438, 56, 'SZ-Third-04', '20.00', 0, 0),
(439, 56, 'SZ-Third-05', '20.00', 0, 0),
(440, 57, 'WZ-First-01', '20.00', 0, 0),
(441, 57, 'WZ-First-02', '20.00', 0, 0),
(442, 57, 'WZ-First-03', '30.00', 0, 0),
(443, 57, 'WZ-First-04', '30.00', 0, 0),
(444, 57, 'WZ-First-05', '40.00', 0, 0),
(445, 58, 'WZ-Scond-01', '60.00', 0, 0),
(446, 58, 'WZ-Scond-02', '70.00', 0, 0),
(447, 58, 'WZ-Scond-03', '60.00', 0, 0),
(448, 58, 'WZ-Scond-04', '60.00', 0, 0),
(449, 58, 'WZ-Scond-05', '60.00', 0, 0),
(450, 59, 'Couple-01', '54.00', 0, 0),
(451, 59, 'Couple-02', '54.00', 0, 0),
(452, 60, 'Couple-2-01', '25.00', 0, 0),
(453, 60, 'Couple-2-02', '25.00', 0, 0),
(454, 61, 'A1-01', '5.00', 0, 0),
(455, 62, 'A2-01', '5.00', 0, 0),
(456, 63, 'Couple-3-01', '0.00', 0, 0),
(457, 63, 'Couple-3-02', '0.00', 0, 0),
(458, 64, 'couple-5-01', '5.00', 0, 0),
(459, 64, 'couple-5-02', '5.00', 0, 0),
(460, 65, 'B1-01', '10.00', 0, 0),
(461, 66, 'B2-01', '12.00', 0, 0),
(462, 67, 'B3-01', '15.00', 0, 0),
(463, 68, 'B4-01', '60.00', 0, 0),
(464, 69, 'B5-01', '10.00', 0, 0),
(465, 70, 'B6-01', '15.00', 0, 0),
(466, 71, 'B6-01', '1.43', 0, 0),
(467, 71, 'B6-02', '1.43', 0, 0),
(468, 71, 'B6-03', '1.43', 0, 0),
(469, 71, 'B6-04', '1.43', 0, 0),
(470, 71, 'B6-05', '1.43', 0, 0),
(471, 71, 'B6-06', '1.43', 0, 0),
(472, 71, 'B6-07', '1.42', 0, 0),
(474, 73, 'B9-01', '110.00', 0, 0),
(475, 74, 'B10-01', '0.00', 0, 0),
(476, 75, 'Gold Class-01', '12.00', 0, 0),
(477, 75, 'Gold Class-02', '12.00', 0, 0),
(478, 75, 'Gold Class-03', '12.00', 0, 0),
(479, 75, 'Gold Class-04', '12.00', 0, 0),
(480, 75, 'Gold Class-05', '12.00', 0, 0),
(481, 76, 'Platinum-01', '20.00', 0, 0),
(482, 76, 'Platinum-02', '20.00', 0, 0),
(483, 76, 'Platinum-03', '20.00', 0, 0),
(484, 76, 'Platinum-04', '20.00', 1, 0),
(485, 76, 'Platinum-05', '20.00', 1, 0),
(486, 76, 'Platinum-06', '20.00', 1, 0),
(487, 76, 'Platinum-07', '20.00', 0, 0),
(488, 77, 'D1-01', '10.00', 0, 0),
(489, 78, 'D2-01', '10.00', 0, 0),
(490, 79, 'D3-01', '50.00', 0, 0),
(491, 80, 'D4-01', '20.00', 0, 0),
(492, 81, 'D5-01', '10.00', 0, 0),
(493, 82, 'D6-01', '150.00', 0, 0),
(494, 83, 'D7-01', '15.71', 0, 0),
(495, 83, 'D7-02', '15.71', 0, 0),
(496, 83, 'D7-03', '15.71', 0, 0),
(497, 83, 'D7-04', '15.71', 0, 0),
(498, 83, 'D7-05', '15.71', 0, 0),
(499, 83, 'D7-06', '15.71', 0, 0),
(500, 83, 'D7-07', '15.74', 0, 0),
(501, 84, 'D8-01', '110.00', 0, 0),
(502, 85, 'E1-01', '10.00', 0, 0),
(503, 86, 'E2-01', '0.00', 0, 0),
(504, 87, 'E3-01', '10.00', 0, 0),
(505, 88, 'E4-01', '10.00', 0, 0),
(506, 89, 'E6-01', '0.00', 0, 0),
(507, 90, 'E7-01', '0.00', 0, 0),
(508, 91, 'E8-01', '10.00', 0, 0),
(509, 92, 'Test Slot-01', '0.00', 0, 0),
(510, 92, 'Test Slot-02', '0.00', 0, 0),
(511, 93, 'A1-01', '10.00', 0, 0),
(512, 94, 'Executive VIP-01', '0.00', 1, 0),
(513, 94, 'Executive VIP-02', '0.00', 1, 0),
(514, 94, 'Executive VIP-03', '0.00', 1, 0),
(515, 94, 'Executive VIP-04', '0.00', 1, 0),
(516, 94, 'Executive VIP-05', '0.00', 0, 0),
(517, 94, 'Executive VIP-06', '0.00', 0, 0),
(518, 94, 'Executive VIP-07', '0.00', 0, 0),
(519, 94, 'Executive VIP-08', '0.00', 0, 0),
(520, 94, 'Executive VIP-09', '0.00', 0, 0),
(521, 94, 'Executive VIP-10', '0.00', 0, 0),
(522, 95, 'Elite Business-01', '0.00', 0, 0),
(523, 95, 'Elite Business-02', '0.00', 0, 0),
(524, 95, 'Elite Business-03', '0.00', 0, 0),
(525, 95, 'Elite Business-04', '0.00', 0, 0),
(526, 95, 'Elite Business-05', '0.00', 0, 0),
(527, 96, 'D-01', '0.00', 0, 0),
(528, 97, 'D2-01', '0.00', 0, 0),
(529, 98, 'G1-01', '0.00', 0, 0),
(530, 99, 'G1-01', '0.00', 0, 0),
(531, 100, 'G2-01', '0.00', 0, 0),
(532, 101, 'G4-01', '0.00', 0, 0),
(533, 102, 'G5-01', '0.00', 0, 0),
(534, 103, 'G6-01', '0.00', 0, 0),
(535, 104, 'G7-01', '0.00', 0, 0),
(536, 105, 'G8-01', '0.00', 0, 0),
(537, 106, 'G8-01', '0.00', 0, 0),
(538, 107, 'Couple-01', '0.00', 0, 0),
(539, 107, 'Couple-02', '0.00', 0, 0),
(540, 108, 'Group Seat-01', '0.00', 0, 0),
(541, 108, 'Group Seat-02', '0.00', 0, 0),
(542, 108, 'Group Seat-03', '0.00', 0, 0),
(543, 108, 'Group Seat-04', '0.00', 0, 0),
(544, 108, 'Group Seat-05', '0.00', 0, 0),
(545, 109, 'Group - Person -7-01', '0.00', 0, 0),
(546, 109, 'Group - Person -7-02', '0.00', 0, 0),
(547, 109, 'Group - Person -7-03', '0.00', 0, 0),
(548, 109, 'Group - Person -7-04', '0.00', 0, 0),
(549, 109, 'Group - Person -7-05', '0.00', 0, 0),
(550, 109, 'Group - Person -7-06', '0.00', 0, 0),
(551, 109, 'Group - Person -7-07', '0.00', 0, 0),
(552, 110, 'General Access-01', '0.00', 0, 0),
(553, 110, 'General Access-02', '0.00', 0, 0),
(554, 110, 'General Access-03', '0.00', 0, 0),
(555, 110, 'General Access-04', '0.00', 0, 0),
(556, 110, 'General Access-05', '0.00', 0, 0),
(557, 110, 'General Access-06', '0.00', 0, 0),
(558, 110, 'General Access-07', '0.00', 0, 0),
(559, 110, 'General Access-08', '0.00', 0, 0),
(560, 111, 'Student Pass-01', '0.00', 0, 0),
(561, 111, 'Student Pass-02', '0.00', 0, 0),
(562, 111, 'Student Pass-03', '0.00', 0, 0),
(563, 111, 'Student Pass-04', '0.00', 0, 0),
(564, 111, 'Student Pass-05', '0.00', 0, 0),
(565, 111, 'Student Pass-06', '0.00', 0, 0),
(566, 111, 'Student Pass-07', '0.00', 0, 0),
(567, 111, 'Student Pass-08', '0.00', 0, 0),
(568, 111, 'Student Pass-09', '0.00', 0, 0),
(569, 111, 'Student Pass-10', '0.00', 0, 0),
(570, 112, 'Media Seat-01', '0.00', 0, 0),
(571, 112, 'Media Seat-02', '0.00', 0, 0),
(572, 112, 'Media Seat-03', '0.00', 0, 0),
(573, 112, 'Media Seat-04', '0.00', 0, 0),
(574, 112, 'Media Seat-05', '0.00', 0, 0),
(575, 112, 'Media Seat-06', '0.00', 0, 0),
(576, 112, 'Media Seat-07', '0.00', 0, 0),
(577, 112, 'Media Seat-08', '0.00', 0, 0),
(578, 112, 'Media Seat-09', '0.00', 0, 0),
(579, 112, 'Media Seat-10', '0.00', 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `social_medias`
--

CREATE TABLE `social_medias` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `icon` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `serial_number` mediumint(8) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `social_medias`
--

INSERT INTO `social_medias` (`id`, `icon`, `url`, `serial_number`, `created_at`, `updated_at`) VALUES
(36, 'fab fa-facebook-f', 'https://www.facebook.com/', 1, '2021-11-20 03:01:42', '2021-11-20 03:01:42'),
(37, 'fab fa-twitter', 'https://twitter.com/', 3, '2021-11-20 03:03:22', '2021-11-20 03:03:22'),
(38, 'fab fa-linkedin-in', 'https://www.linkedin.com/', 2, '2021-11-20 03:04:29', '2021-11-20 03:04:29');

-- --------------------------------------------------------

--
-- Table structure for table `states`
--

CREATE TABLE `states` (
  `id` mediumint(8) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `country_id` mediumint(8) UNSIGNED NOT NULL,
  `country_code` char(2) NOT NULL,
  `fips_code` varchar(255) DEFAULT NULL,
  `iso2` varchar(255) DEFAULT NULL,
  `type` varchar(191) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `flag` tinyint(1) NOT NULL DEFAULT '1',
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Table structure for table `subscribers`
--

CREATE TABLE `subscribers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `email_id` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `support_tickets`
--

CREATE TABLE `support_tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `user_type` varchar(20) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `ticket_number` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `description` longtext,
  `attachment` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT '1' COMMENT '1-pending, 2-open, 3-closed',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `last_message` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `support_tickets`
--

INSERT INTO `support_tickets` (`id`, `user_id`, `user_type`, `admin_id`, `ticket_number`, `email`, `subject`, `description`, `attachment`, `status`, `created_at`, `updated_at`, `last_message`) VALUES
(12, 23, 'organizer', NULL, NULL, 'organizer@gmail.com', 'Withdraw Rejected', 'Please let me ensure why my withdraw request was rejected. my withdraw id is #6458d9a93f2e3', NULL, 3, '2023-05-08 11:19:22', '2023-05-08 11:31:47', '2023-05-08 11:30:44'),
(13, 23, 'customer', NULL, NULL, 'user@gmail.com', 'Payment Rejected', 'Why my payment was rejected? I was booking a ticket for the \"Designer carrier conference\" Event.', NULL, 3, '2023-05-08 11:22:07', '2023-05-08 11:40:46', '2023-05-08 11:40:42'),
(14, 23, 'customer', NULL, NULL, 'user@gmail.com', 'I can\'t purchase product', 'Please let me ensure why I can\'t purchase products.', NULL, 2, '2023-05-08 11:23:21', '2023-05-08 11:27:01', '2023-05-08 11:27:01'),
(15, 23, 'organizer', NULL, NULL, 'organizer@gmail.com', 'Feature a Event', 'Please featured my event. my event name is \"Designer carrier conference\"', NULL, 1, '2023-05-08 11:24:49', '2023-05-08 11:24:49', NULL),
(16, 23, 'organizer', NULL, NULL, 'organizer@gmail.com', 'Why my event has no ticket ?', 'let me ensure why the event has no ticket.', NULL, 2, '2023-05-08 11:32:52', '2023-05-20 12:16:54', '2023-05-20 12:16:54'),
(17, 23, 'customer', NULL, NULL, 'user@gmail.com', 'I cant\'t go contact page', 'i found a error when i go the contact page', NULL, 1, '2023-05-08 11:41:38', '2023-05-08 11:41:38', NULL),
(18, 23, 'customer', NULL, NULL, 'user@gmail.com', 'Payment Rejected', 'fdsafaf', '650eb15073ddf.zip', 2, '2023-09-23 09:35:12', '2023-09-23 09:35:55', '2023-09-23 09:35:55'),
(19, 33, 'customer', NULL, NULL, 'poned@mailinator.com', 'dd', '11', '68ec706d16c2c.zip', 2, '2025-10-12 23:22:21', '2025-10-12 23:46:45', '2025-10-12 23:46:45'),
(20, 34, 'customer', NULL, NULL, 'test@kreativdev.com', 'Test Ticket Create', 'This a Test of creating ticket using mobile application', '68ec84ce6535d.zip', 3, '2025-10-13 00:49:18', '2025-10-13 00:50:50', '2025-10-13 00:50:45'),
(21, 35, 'customer', NULL, NULL, 'test@kreativdev.com', 'Support Text Ticket', 'Support Text Ticket', NULL, 3, '2025-10-13 00:51:17', '2025-10-13 00:51:50', '2025-10-13 00:51:46'),
(22, 33, 'customer', NULL, NULL, 'wupi@mailinator.com', 'vazyb@mailinator.com', 'Quis corrupti ipsum', '68ec91c9eef30.zip', 1, '2025-10-13 01:44:41', '2025-10-13 01:44:41', NULL),
(23, 34, 'customer', NULL, NULL, 'goutams1048@gmail.com', 'This is another test from mobile', 'This is another test from mobile', '68ecc4acdf430.zip', 3, '2025-10-13 05:21:48', '2025-10-13 05:25:53', '2025-10-13 05:25:53');

-- --------------------------------------------------------

--
-- Table structure for table `support_ticket_statuses`
--

CREATE TABLE `support_ticket_statuses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `support_ticket_status` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `support_ticket_statuses`
--

INSERT INTO `support_ticket_statuses` (`id`, `support_ticket_status`, `created_at`, `updated_at`) VALUES
(1, 'active', '2022-06-25 03:52:18', '2023-01-29 10:07:53');

-- --------------------------------------------------------

--
-- Table structure for table `testimonials`
--

CREATE TABLE `testimonials` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) UNSIGNED NOT NULL,
  `image` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `occupation` varchar(255) NOT NULL,
  `rating` int(11) DEFAULT '0',
  `comment` text NOT NULL,
  `serial_number` int(10) UNSIGNED NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `testimonials`
--

INSERT INTO `testimonials` (`id`, `language_id`, `image`, `name`, `occupation`, `rating`, `comment`, `serial_number`, `created_at`, `updated_at`) VALUES
(6, 8, '6345065d82969.jpg', 'Jane Doe', 'Chief marketing officer', 5, 'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not just those that pay us', 1, '2021-10-11 03:21:50', '2023-05-08 04:41:31'),
(9, 8, '63450650b0f0a.jpg', 'Jef Hardy', 'Chief executive officer (CEO)', 4, 'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not  justfdfdhghdd ghdfghdfdg', 2, '2021-12-15 03:38:04', '2023-05-08 04:41:20'),
(10, 8, '63450657af7b1.jpg', 'Matt Hardy', 'Manager', 5, 'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not  just those that pay us', 3, '2021-12-15 03:40:37', '2023-05-08 04:41:04'),
(14, 22, '64587b53223ed.jpg', 'الكسندرا', 'تنفيذي', 5, ', ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', 1, '2023-05-08 04:32:19', '2023-05-08 04:38:06'),
(15, 8, '64587ddb29fdc.jpg', 'Patty O’Furniture', 'Chief financial officer', 4, 'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn', 4, '2023-05-08 04:43:07', '2023-05-08 04:43:59'),
(16, 22, '64587e6cf164d.jpg', 'عايدة بوغ', 'الرئيس التنفيذي للتسويق', 4, ', ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', 2, '2023-05-08 04:45:32', '2023-05-08 04:45:32'),
(17, 22, '64587ec5bb55c.jpg', 'مورين بيولوجي', 'الرئيس التنفيذي للعمليات', 5, ', ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', 3, '2023-05-08 04:47:01', '2023-05-08 04:47:01'),
(18, 22, '64587f0ecf55b.jpg', 'هارييت أوب', 'العمليات والإنتاج', 5, ', ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.', 4, '2023-05-08 04:48:14', '2023-05-08 04:48:14');

-- --------------------------------------------------------

--
-- Table structure for table `testimonial_sections`
--

CREATE TABLE `testimonial_sections` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text,
  `image` varchar(255) DEFAULT NULL,
  `review_text` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `testimonial_sections`
--

INSERT INTO `testimonial_sections` (`id`, `language_id`, `title`, `text`, `image`, `review_text`, `created_at`, `updated_at`) VALUES
(3, 8, 'What Our Clients Say about Us', 'Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium euismod ligula, quis suscipit dui.', '629f26d7b602d.jpg', '12k Clients reviews', '2022-06-07 04:22:15', '2022-06-07 04:24:54'),
(4, 9, 'gdfsas', 'sdfa', '629f2792b156e.jpg', 'sfdaf', '2022-06-07 04:25:22', '2022-06-07 04:25:22'),
(5, 17, 'ما يقوله عملائنا عنا', 'الأحرف. خمسة قرون من الزمن لم تقضي على هذا النص، بل انه حتى صار', '63d8ad0181103.png', '2k', '2023-01-31 05:54:09', '2023-01-31 05:54:09'),
(6, 22, 'ماذا يقول عملاؤنا عنا', 'وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا', '64587a5803048.jpg', 'ألف مراجعات العملاء', '2023-05-08 04:28:08', '2023-05-08 04:29:14');

-- --------------------------------------------------------

--
-- Table structure for table `tickets`
--

CREATE TABLE `tickets` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `event_id` int(11) NOT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `ticket_available_type` varchar(255) DEFAULT NULL,
  `ticket_available` int(11) DEFAULT NULL,
  `max_ticket_buy_type` varchar(255) DEFAULT NULL,
  `max_buy_ticket` int(11) DEFAULT NULL,
  `description` longtext,
  `pricing_type` varchar(255) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL,
  `f_price` float DEFAULT NULL,
  `early_bird_discount` varchar(255) NOT NULL DEFAULT 'disable',
  `early_bird_discount_amount` varchar(255) DEFAULT NULL,
  `early_bird_discount_type` varchar(255) DEFAULT NULL,
  `early_bird_discount_date` varchar(255) DEFAULT NULL,
  `early_bird_discount_time` varchar(255) DEFAULT NULL,
  `variations` longtext,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `normal_ticket_slot_enable` tinyint(4) NOT NULL DEFAULT '0',
  `normal_ticket_slot_unique_id` int(11) DEFAULT NULL,
  `free_tickete_slot_enable` tinyint(4) NOT NULL DEFAULT '0',
  `free_tickete_slot_unique_id` int(11) DEFAULT NULL,
  `slot_seat_min_price` decimal(8,2) NOT NULL DEFAULT '0.00'
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tickets`
--

INSERT INTO `tickets` (`id`, `event_id`, `event_type`, `title`, `ticket_available_type`, `ticket_available`, `max_ticket_buy_type`, `max_buy_ticket`, `description`, `pricing_type`, `price`, `f_price`, `early_bird_discount`, `early_bird_discount_amount`, `early_bird_discount_type`, `early_bird_discount_date`, `early_bird_discount_time`, `variations`, `created_at`, `updated_at`, `normal_ticket_slot_enable`, `normal_ticket_slot_unique_id`, `free_tickete_slot_enable`, `free_tickete_slot_unique_id`, `slot_seat_min_price`) VALUES
(109, 92, 'online', NULL, 'limited', 81, 'limited', 4, NULL, 'normal', '100', 100, 'enable', '5', 'percentage', '2023-05-16', '05:00', NULL, '2023-05-06 11:02:58', '2025-10-21 00:49:34', 0, 735161, 0, 887281, '0.00'),
(113, 91, 'venue', 'Early bird discount ticket(fixed)', 'unlimited', -4, 'unlimited', NULL, NULL, 'normal', '90', 90, 'enable', '10', 'fixed', '2023-05-17', '23:00', NULL, '2023-05-07 04:59:51', '2025-11-03 03:28:47', 0, 727536, 0, 26635, '0.00'),
(114, 101, 'online', NULL, 'unlimited', -19, 'limited', 3, NULL, 'free', NULL, NULL, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-05-07 05:12:19', '2025-11-03 23:30:07', 0, 896416, 0, 642922, '0.00'),
(115, 104, 'online', NULL, 'limited', 3275, 'unlimited', NULL, NULL, 'normal', '66', 66, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-05-07 06:06:49', '2025-11-10 08:02:27', 0, 713512, 0, 291122, '0.00'),
(156, 93, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'variation', NULL, 40, 'enable', '2', 'fixed', '2026-01-07', '13:17', '[{\"name\":\"Economy\",\"price\":20,\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":64061,\"slot_seat_min_price\":0},{\"name\":\"Business\",\"price\":30,\"ticket_available_type\":\"limited\",\"ticket_available\":288,\"max_ticket_buy_type\":\"limited\",\"v_max_ticket_buy\":\"3\",\"slot_enable\":0,\"slot_unique_id\":684032,\"slot_seat_min_price\":0},{\"name\":\"First\",\"price\":40,\"ticket_available_type\":\"limited\",\"ticket_available\":193,\"max_ticket_buy_type\":\"limited\",\"v_max_ticket_buy\":\"2\",\"slot_enable\":0,\"slot_unique_id\":857653,\"slot_seat_min_price\":0}]', '2023-05-14 04:35:53', '2025-10-21 00:49:34', 0, 662063, 0, 196366, '0.00'),
(157, 94, 'venue', NULL, 'unlimited', NULL, 'limited', 4, NULL, 'normal', '20', 20, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-05-14 04:50:48', '2025-10-21 00:49:34', 0, 959774, 0, 676217, '0.00'),
(158, 100, 'venue', NULL, 'limited', 89, 'limited', 2, NULL, 'free', '0', NULL, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-05-14 05:18:02', '2025-10-21 00:49:34', 0, 180613, 0, 622546, '0.00'),
(159, 102, 'venue', NULL, 'limited', 90, 'limited', 2, NULL, 'normal', '20', 20, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-05-14 05:24:51', '2025-10-21 00:49:34', 0, 948054, 0, 475023, '0.00'),
(160, 103, 'venue', NULL, 'limited', 88, 'unlimited', NULL, NULL, 'normal', '100', 100, 'enable', '5', 'fixed', '2026-01-07', '11:31', NULL, '2023-05-14 05:28:23', '2025-11-06 01:18:47', 0, 299586, 0, 898326, '0.00'),
(161, 103, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'normal', '79', 79, 'enable', '10', 'percentage', '2026-07-14', '11:31', NULL, '2023-05-14 05:29:29', '2025-10-21 00:49:34', 0, 184616, 0, 985132, '0.00'),
(172, 116, 'online', NULL, 'unlimited', -5, 'unlimited', NULL, NULL, 'normal', '100', 100, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2023-09-24 08:13:35', '2025-10-21 00:49:34', 0, 674980, 0, 654092, '0.00'),
(195, 105, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'variation', NULL, 60, 'disable', NULL, 'fixed', NULL, NULL, '[{\"name\":\"Economy\",\"price\":\"40\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":196010,\"slot_seat_min_price\":0},{\"name\":\"Business\",\"price\":\"50\",\"ticket_available_type\":\"limited\",\"ticket_available\":\"293\",\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":199203,\"slot_seat_min_price\":0},{\"name\":\"First\",\"price\":\"60\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":807136,\"slot_seat_min_price\":0}]', '2025-11-06 01:17:05', '2025-11-06 01:20:26', 0, 170781, 0, 666002, '0.00'),
(196, 105, 'venue', NULL, 'limited', 111, 'unlimited', NULL, NULL, 'normal', '100', 100, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2025-11-06 01:17:46', '2025-11-06 01:20:26', 0, 956745, 0, 318219, '0.00'),
(197, 105, 'venue', NULL, 'limited', 7, 'unlimited', NULL, NULL, 'free', '0', NULL, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2025-11-06 01:18:13', '2025-11-06 01:20:26', 0, 680616, 0, 69499, '0.00'),
(198, 126, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'variation', NULL, 500, 'enable', '10', 'percentage', '2028-10-08', '06:55', '[{\"name\":\"North Preferred\",\"price\":\"200\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":659237,\"slot_seat_min_price\":\"10.00\"},{\"name\":\"East Preferred\",\"price\":\"200\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":470615,\"slot_seat_min_price\":\"9.00\"},{\"name\":\"West Preferred\",\"price\":\"500\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":412059,\"slot_seat_min_price\":\"10.00\"},{\"name\":\"South Preferred\",\"price\":\"200\",\"ticket_available_type\":\"unlimited\",\"ticket_available\":null,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":982246,\"slot_seat_min_price\":\"20.00\"}]', '2025-11-06 03:52:33', '2025-11-10 06:31:18', 0, 738336, 0, 775720, '0.00'),
(200, 127, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'normal', '100', 100, 'enable', '10', 'percentage', '2028-10-08', '18:54', NULL, '2025-11-08 00:52:38', '2025-11-08 07:51:52', 1, 688688, 0, 925136, '5.00'),
(202, 128, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'free', '0', 100, 'enable', '10', 'percentage', '2029-10-08', '06:52', NULL, '2025-11-08 06:45:39', '2025-11-08 07:58:29', 0, 900902, 1, 971199, '0.00'),
(203, 128, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'free', '0', NULL, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2025-11-08 07:47:59', '2025-11-08 07:48:37', 0, 580223, 0, 941199, '0.00'),
(204, 127, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'normal', '10', 10, 'disable', NULL, 'fixed', NULL, NULL, NULL, '2025-11-08 07:49:49', '2025-11-08 07:52:19', 0, 329569, 0, 218259, '0.00'),
(205, 126, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'variation', NULL, 20, 'disable', NULL, 'fixed', NULL, NULL, '[{\"name\":\"Economy\",\"price\":20,\"ticket_available_type\":\"limited\",\"ticket_available\":997,\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":447381,\"slot_seat_min_price\":0},{\"name\":\"Standard\",\"price\":50,\"ticket_available_type\":\"limited\",\"ticket_available\":\"200\",\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":0,\"slot_unique_id\":436535,\"slot_seat_min_price\":0}]', '2025-11-08 07:53:38', '2025-11-09 01:27:12', 0, 654532, 0, 910933, '0.00'),
(209, 126, 'venue', NULL, 'unlimited', NULL, 'unlimited', NULL, NULL, 'variation', '0', NULL, 'disable', NULL, 'fixed', NULL, NULL, '[{\"name\":\"Economy\",\"price\":\"20\",\"ticket_available_type\":\"limited\",\"ticket_available\":\"100\",\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":221253,\"slot_seat_min_price\":\"0.00\"},{\"name\":\"Economy\",\"price\":\"20\",\"ticket_available_type\":\"limited\",\"ticket_available\":\"10\",\"max_ticket_buy_type\":\"unlimited\",\"v_max_ticket_buy\":null,\"slot_enable\":1,\"slot_unique_id\":939040,\"slot_seat_min_price\":\"0.00\"}]', '2025-11-10 06:15:55', '2025-11-10 06:32:23', 0, 126476, 0, 41168, '0.00');

-- --------------------------------------------------------

--
-- Table structure for table `ticket_contents`
--

CREATE TABLE `ticket_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) DEFAULT NULL,
  `ticket_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `ticket_contents`
--

INSERT INTO `ticket_contents` (`id`, `language_id`, `ticket_id`, `title`, `description`, `created_at`, `updated_at`) VALUES
(1, 8, 155, 'Toyota Starlet', NULL, '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(2, 22, 155, 'Toyota Starlet', NULL, '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(3, 8, 154, 'fdsaf', NULL, '2023-05-13 11:20:35', '2023-05-13 11:20:35'),
(4, 22, 154, 'fdsaf', NULL, '2023-05-13 11:20:35', '2023-05-13 11:20:35'),
(5, 8, 113, 'Early bird discount ticket(fixed)', NULL, '2023-05-14 04:18:02', '2023-05-14 04:18:02'),
(6, 22, 113, 'تذكرة خصم مبكرة (ثابتة)', NULL, '2023-05-14 04:18:02', '2023-05-14 04:18:02'),
(7, 8, 156, 'Variation Wise Tickets', NULL, '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(8, 22, 156, 'تذاكر التغيير الحكيم', NULL, '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(9, 8, 157, 'Normal Ticket', NULL, '2023-05-14 04:50:48', '2023-05-14 04:50:48'),
(10, 22, 157, 'تذكرة عادية', NULL, '2023-05-14 04:50:48', '2023-05-14 04:50:48'),
(11, 8, 158, 'Free Ticket', NULL, '2023-05-14 05:18:02', '2023-05-14 05:18:02'),
(12, 22, 158, 'بطاقة مجانية', NULL, '2023-05-14 05:18:02', '2023-05-14 05:18:02'),
(13, 8, 159, 'Limited ticket', NULL, '2023-05-14 05:24:51', '2023-05-14 05:24:51'),
(14, 22, 159, 'تذكرة محدودة', NULL, '2023-05-14 05:24:51', '2023-05-14 05:24:51'),
(15, 8, 160, 'Normal Ticket (fixed discount)', NULL, '2023-05-14 05:28:23', '2023-05-14 05:28:23'),
(16, 22, 160, 'تذكرة عادية (خصم ثابت)', NULL, '2023-05-14 05:28:23', '2023-05-14 05:28:23'),
(17, 8, 161, 'Normal Ticket(percentage discount)', NULL, '2023-05-14 05:29:29', '2023-05-14 05:29:29'),
(18, 22, 161, 'تذكرة عادية (خصم بنسبة مئوية)', NULL, '2023-05-14 05:29:29', '2023-05-14 05:29:29'),
(25, 8, 166, 'Free Ticket', NULL, '2023-05-14 09:22:52', '2023-05-14 09:22:52'),
(26, 22, 166, 'بطاقة مجانية', NULL, '2023-05-14 09:22:52', '2023-05-14 09:22:52'),
(27, 8, 167, 'Normal Ticket', NULL, '2023-05-14 09:23:26', '2023-05-14 09:23:26'),
(28, 22, 167, 'تذكرة عادية', NULL, '2023-05-14 09:23:26', '2023-05-14 09:23:26'),
(29, 8, 168, 'Variation Wise', NULL, '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(30, 22, 168, 'الاختلاف الحكيم', NULL, '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(31, 8, 169, 'Normal Discount', NULL, '2023-05-14 09:25:20', '2023-05-14 09:25:20'),
(32, 22, 169, 'خصم عادي', NULL, '2023-05-14 09:25:20', '2023-05-14 09:25:20'),
(33, 8, 170, 'Variation Discount', NULL, '2023-05-14 09:26:25', '2023-05-14 09:26:25'),
(34, 22, 170, 'خصم التغيير', NULL, '2023-05-14 09:26:25', '2023-05-14 09:26:25'),
(35, 8, 175, 'Test Ticket', 'Test Ticket description', '2023-11-18 00:20:10', '2023-11-18 00:20:10'),
(36, 22, 175, 'Test Ticket', 'Test Ticket description', '2023-11-18 00:20:10', '2023-11-18 00:20:10'),
(37, 8, 176, 'Without Variation test ticket', 'Without Variation test ticket description', '2023-11-18 00:21:38', '2023-11-18 00:21:38'),
(38, 22, 176, 'Without Variation test ticket', 'Without Variation test ticket description', '2023-11-18 00:21:38', '2023-11-18 00:21:38'),
(39, 8, 177, 'Free ticket', 'free ticket description', '2023-11-18 00:26:42', '2023-11-18 00:26:42'),
(40, 22, 177, 'Free ticket', 'free ticket description', '2023-11-18 00:26:42', '2023-11-18 00:26:42'),
(41, 8, 178, 'Without varitaion ticket', 'Without variation ticket description', '2023-11-18 00:28:56', '2023-11-18 00:28:56'),
(42, 22, 178, 'Without varitaion ticket', 'Without variation ticket description', '2023-11-18 00:28:56', '2023-11-18 00:28:56'),
(43, 8, 179, 'Variation wise', 'Variation wise description', '2023-11-18 00:47:32', '2023-11-18 00:47:32'),
(44, 22, 179, 'Variation wise', 'Variation wise description', '2023-11-18 00:47:32', '2023-11-18 00:47:32'),
(45, 8, 180, 'sdafadf', 'asdfdasfdaf', '2023-11-18 01:03:31', '2023-11-18 01:03:31'),
(46, 22, 180, 'sdafadf', 'asdfdasfdaf', '2023-11-18 01:03:31', '2023-11-18 01:03:31'),
(59, 8, 188, 'Sydnee Neal', 'Laboris voluptatem', '2025-10-21 01:38:19', '2025-10-21 01:38:19'),
(60, 22, 188, 'العيش عند مدخل لا شيء على الإطلاق.', '11', '2025-10-21 01:38:19', '2025-10-21 01:38:19'),
(61, 8, 189, 'Evergreen Hospital', 'rr', '2025-10-21 03:09:33', '2025-10-21 03:09:33'),
(62, 22, 189, 'rr', 'rrrrrr', '2025-10-21 03:09:33', '2025-10-21 03:09:33'),
(63, 8, 190, 'I will create any kind of graphic design with idea', '11', '2025-10-21 03:11:23', '2025-10-21 03:11:23'),
(64, 22, 190, 'I will create any kind of graphic design with idea', '11', '2025-10-21 03:11:23', '2025-10-21 03:11:23'),
(65, 8, 191, 'Dana Faulkner', 'Eaque ea nostrum eu', '2025-10-21 05:19:37', '2025-10-21 05:25:27'),
(66, 22, 191, 'Dana Faulkner', 'Evergreen Hospital', '2025-10-21 05:19:37', '2025-10-21 05:25:27'),
(69, 8, 193, 'I will create any kind of graphic design with idea', '1223', '2025-11-02 06:04:01', '2025-11-02 06:04:01'),
(70, 22, 193, 'العيش عند مدخل لا شيء على الإطلاق.', '6333333333', '2025-11-02 06:04:01', '2025-11-02 06:04:01'),
(71, 8, 194, 'Tech Innovators Conference 2025', 'Join us at the Tech Innovators Conference 2025, where visionaries, developers, and industry leaders come together to shape the future of technology. This year’s theme, “Bridging Ideas with Innovation,” focuses on emerging trends in AI, Web Development, Cloud Computing, and Cybersecurity.', '2025-11-05 00:34:23', '2025-11-05 00:34:23'),
(72, 22, 194, 'Tech Innovators Conference 2025', 'Join us at the Tech Innovators Conference 2025, where visionaries, developers, and industry leaders come together to shape the future of technology. This year’s theme, “Bridging Ideas with Innovation,” focuses on emerging trends in AI, Web Development, Cloud Computing, and Cybersecurity.', '2025-11-05 00:34:23', '2025-11-05 00:34:23'),
(73, 8, 195, 'All Tickets', NULL, '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(74, 22, 195, 'جميع التذاكر', NULL, '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(75, 8, 196, 'Normal Ticket', NULL, '2025-11-06 01:17:46', '2025-11-06 01:17:46'),
(76, 22, 196, 'تذكرة عادية', NULL, '2025-11-06 01:17:46', '2025-11-06 01:17:46'),
(77, 8, 197, 'Free Ticket (limited)', NULL, '2025-11-06 01:18:13', '2025-11-06 01:18:13'),
(78, 22, 197, 'بطاقة مجانية', NULL, '2025-11-06 01:18:13', '2025-11-06 01:18:13'),
(79, 8, 198, 'First Stage', NULL, '2025-11-06 03:52:33', '2025-11-06 03:52:33'),
(80, 22, 198, 'المرحلة الأولى', NULL, '2025-11-06 03:52:33', '2025-11-06 03:52:33'),
(83, 8, 200, 'Seat Ticket', NULL, '2025-11-08 00:52:38', '2025-11-08 07:49:29'),
(84, 22, 200, 'تذكرة فيلم', NULL, '2025-11-08 00:52:38', '2025-11-08 00:52:38'),
(87, 8, 202, 'Seat Ticket', NULL, '2025-11-08 06:45:39', '2025-11-08 07:48:25'),
(88, 22, 202, 'تذكرة مجانية', NULL, '2025-11-08 06:45:39', '2025-11-08 06:45:39'),
(89, 8, 203, 'Stranding Ticket', NULL, '2025-11-08 07:47:59', '2025-11-08 07:47:59'),
(90, 22, 203, 'تذكرة جنوح', NULL, '2025-11-08 07:47:59', '2025-11-08 07:47:59'),
(91, 8, 204, 'Standing Ticket', NULL, '2025-11-08 07:49:49', '2025-11-08 07:49:49'),
(92, 22, 204, 'تذكرة جنوح', NULL, '2025-11-08 07:49:49', '2025-11-08 07:49:49'),
(93, 8, 205, 'Standing Ticket', NULL, '2025-11-08 07:53:38', '2025-11-08 07:53:38'),
(94, 22, 205, 'تذكرة جنوح', NULL, '2025-11-08 07:53:38', '2025-11-08 07:53:38'),
(101, 8, 209, 'rr', NULL, '2025-11-10 06:15:55', '2025-11-10 06:15:55'),
(102, 22, 209, 'rr', NULL, '2025-11-10 06:15:55', '2025-11-10 06:15:55');

-- --------------------------------------------------------

--
-- Table structure for table `timezones`
--

CREATE TABLE `timezones` (
  `country_code` char(3) NOT NULL,
  `timezone` varchar(125) NOT NULL DEFAULT '',
  `gmt_offset` float(10,2) DEFAULT NULL,
  `dst_offset` float(10,2) DEFAULT NULL,
  `raw_offset` float(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `timezones`
--

INSERT INTO `timezones` (`country_code`, `timezone`, `gmt_offset`, `dst_offset`, `raw_offset`) VALUES
('AD', 'Europe/Andorra', 1.00, 2.00, 1.00),
('AE', 'Asia/Dubai', 4.00, 4.00, 4.00),
('AF', 'Asia/Kabul', 4.50, 4.50, 4.50),
('AG', 'America/Antigua', -4.00, -4.00, -4.00),
('AI', 'America/Anguilla', -4.00, -4.00, -4.00),
('AL', 'Europe/Tirane', 1.00, 2.00, 1.00),
('AM', 'Asia/Yerevan', 4.00, 4.00, 4.00),
('AO', 'Africa/Luanda', 1.00, 1.00, 1.00),
('AQ', 'Antarctica/Casey', 8.00, 8.00, 8.00),
('AQ', 'Antarctica/Davis', 7.00, 7.00, 7.00),
('AQ', 'Antarctica/DumontDUrville', 10.00, 10.00, 10.00),
('AQ', 'Antarctica/Mawson', 5.00, 5.00, 5.00),
('AQ', 'Antarctica/McMurdo', 13.00, 12.00, 12.00),
('AQ', 'Antarctica/Palmer', -3.00, -4.00, -4.00),
('AQ', 'Antarctica/Rothera', -3.00, -3.00, -3.00),
('AQ', 'Antarctica/South_Pole', 13.00, 12.00, 12.00),
('AQ', 'Antarctica/Syowa', 3.00, 3.00, 3.00),
('AQ', 'Antarctica/Vostok', 6.00, 6.00, 6.00),
('AR', 'America/Argentina/Buenos_Aires', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Catamarca', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Cordoba', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Jujuy', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/La_Rioja', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Mendoza', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Rio_Gallegos', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Salta', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/San_Juan', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/San_Luis', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Tucuman', -3.00, -3.00, -3.00),
('AR', 'America/Argentina/Ushuaia', -3.00, -3.00, -3.00),
('AS', 'Pacific/Pago_Pago', -11.00, -11.00, -11.00),
('AT', 'Europe/Vienna', 1.00, 2.00, 1.00),
('AU', 'Antarctica/Macquarie', 11.00, 11.00, 11.00),
('AU', 'Australia/Adelaide', 10.50, 9.50, 9.50),
('AU', 'Australia/Brisbane', 10.00, 10.00, 10.00),
('AU', 'Australia/Broken_Hill', 10.50, 9.50, 9.50),
('AU', 'Australia/Currie', 11.00, 10.00, 10.00),
('AU', 'Australia/Darwin', 9.50, 9.50, 9.50),
('AU', 'Australia/Eucla', 8.75, 8.75, 8.75),
('AU', 'Australia/Hobart', 11.00, 10.00, 10.00),
('AU', 'Australia/Lindeman', 10.00, 10.00, 10.00),
('AU', 'Australia/Lord_Howe', 11.00, 10.50, 10.50),
('AU', 'Australia/Melbourne', 11.00, 10.00, 10.00),
('AU', 'Australia/Perth', 8.00, 8.00, 8.00),
('AU', 'Australia/Sydney', 11.00, 10.00, 10.00),
('AW', 'America/Aruba', -4.00, -4.00, -4.00),
('AX', 'Europe/Mariehamn', 2.00, 3.00, 2.00),
('AZ', 'Asia/Baku', 4.00, 5.00, 4.00),
('BA', 'Europe/Sarajevo', 1.00, 2.00, 1.00),
('BB', 'America/Barbados', -4.00, -4.00, -4.00),
('BD', 'Asia/Dhaka', 6.00, 6.00, 6.00),
('BE', 'Europe/Brussels', 1.00, 2.00, 1.00),
('BF', 'Africa/Ouagadougou', 0.00, 0.00, 0.00),
('BG', 'Europe/Sofia', 2.00, 3.00, 2.00),
('BH', 'Asia/Bahrain', 3.00, 3.00, 3.00),
('BI', 'Africa/Bujumbura', 2.00, 2.00, 2.00),
('BJ', 'Africa/Porto-Novo', 1.00, 1.00, 1.00),
('BL', 'America/St_Barthelemy', -4.00, -4.00, -4.00),
('BM', 'Atlantic/Bermuda', -4.00, -3.00, -4.00),
('BN', 'Asia/Brunei', 8.00, 8.00, 8.00),
('BO', 'America/La_Paz', -4.00, -4.00, -4.00),
('BQ', 'America/Kralendijk', -4.00, -4.00, -4.00),
('BR', 'America/Araguaina', -3.00, -3.00, -3.00),
('BR', 'America/Bahia', -3.00, -3.00, -3.00),
('BR', 'America/Belem', -3.00, -3.00, -3.00),
('BR', 'America/Boa_Vista', -4.00, -4.00, -4.00),
('BR', 'America/Campo_Grande', -3.00, -4.00, -4.00),
('BR', 'America/Cuiaba', -3.00, -4.00, -4.00),
('BR', 'America/Eirunepe', -5.00, -5.00, -5.00),
('BR', 'America/Fortaleza', -3.00, -3.00, -3.00),
('BR', 'America/Maceio', -3.00, -3.00, -3.00),
('BR', 'America/Manaus', -4.00, -4.00, -4.00),
('BR', 'America/Noronha', -2.00, -2.00, -2.00),
('BR', 'America/Porto_Velho', -4.00, -4.00, -4.00),
('BR', 'America/Recife', -3.00, -3.00, -3.00),
('BR', 'America/Rio_Branco', -5.00, -5.00, -5.00),
('BR', 'America/Santarem', -3.00, -3.00, -3.00),
('BR', 'America/Sao_Paulo', -2.00, -3.00, -3.00),
('BS', 'America/Nassau', -5.00, -4.00, -5.00),
('BT', 'Asia/Thimphu', 6.00, 6.00, 6.00),
('BW', 'Africa/Gaborone', 2.00, 2.00, 2.00),
('BY', 'Europe/Minsk', 3.00, 3.00, 3.00),
('BZ', 'America/Belize', -6.00, -6.00, -6.00),
('CA', 'America/Atikokan', -5.00, -5.00, -5.00),
('CA', 'America/Blanc-Sablon', -4.00, -4.00, -4.00),
('CA', 'America/Cambridge_Bay', -7.00, -6.00, -7.00),
('CA', 'America/Creston', -7.00, -7.00, -7.00),
('CA', 'America/Dawson', -8.00, -7.00, -8.00),
('CA', 'America/Dawson_Creek', -7.00, -7.00, -7.00),
('CA', 'America/Edmonton', -7.00, -6.00, -7.00),
('CA', 'America/Glace_Bay', -4.00, -3.00, -4.00),
('CA', 'America/Goose_Bay', -4.00, -3.00, -4.00),
('CA', 'America/Halifax', -4.00, -3.00, -4.00),
('CA', 'America/Inuvik', -7.00, -6.00, -7.00),
('CA', 'America/Iqaluit', -5.00, -4.00, -5.00),
('CA', 'America/Moncton', -4.00, -3.00, -4.00),
('CA', 'America/Montreal', -5.00, -4.00, -5.00),
('CA', 'America/Nipigon', -5.00, -4.00, -5.00),
('CA', 'America/Pangnirtung', -5.00, -4.00, -5.00),
('CA', 'America/Rainy_River', -6.00, -5.00, -6.00),
('CA', 'America/Rankin_Inlet', -6.00, -5.00, -6.00),
('CA', 'America/Regina', -6.00, -6.00, -6.00),
('CA', 'America/Resolute', -6.00, -5.00, -6.00),
('CA', 'America/St_Johns', -3.50, -2.50, -3.50),
('CA', 'America/Swift_Current', -6.00, -6.00, -6.00),
('CA', 'America/Thunder_Bay', -5.00, -4.00, -5.00),
('CA', 'America/Toronto', -5.00, -4.00, -5.00),
('CA', 'America/Vancouver', -8.00, -7.00, -8.00),
('CA', 'America/Whitehorse', -8.00, -7.00, -8.00),
('CA', 'America/Winnipeg', -6.00, -5.00, -6.00),
('CA', 'America/Yellowknife', -7.00, -6.00, -7.00),
('CC', 'Indian/Cocos', 6.50, 6.50, 6.50),
('CD', 'Africa/Kinshasa', 1.00, 1.00, 1.00),
('CD', 'Africa/Lubumbashi', 2.00, 2.00, 2.00),
('CF', 'Africa/Bangui', 1.00, 1.00, 1.00),
('CG', 'Africa/Brazzaville', 1.00, 1.00, 1.00),
('CH', 'Europe/Zurich', 1.00, 2.00, 1.00),
('CI', 'Africa/Abidjan', 0.00, 0.00, 0.00),
('CK', 'Pacific/Rarotonga', -10.00, -10.00, -10.00),
('CL', 'America/Santiago', -3.00, -4.00, -4.00),
('CL', 'Pacific/Easter', -5.00, -6.00, -6.00),
('CM', 'Africa/Douala', 1.00, 1.00, 1.00),
('CN', 'Asia/Chongqing', 8.00, 8.00, 8.00),
('CN', 'Asia/Harbin', 8.00, 8.00, 8.00),
('CN', 'Asia/Kashgar', 8.00, 8.00, 8.00),
('CN', 'Asia/Shanghai', 8.00, 8.00, 8.00),
('CN', 'Asia/Urumqi', 8.00, 8.00, 8.00),
('CO', 'America/Bogota', -5.00, -5.00, -5.00),
('CR', 'America/Costa_Rica', -6.00, -6.00, -6.00),
('CU', 'America/Havana', -5.00, -4.00, -5.00),
('CV', 'Atlantic/Cape_Verde', -1.00, -1.00, -1.00),
('CW', 'America/Curacao', -4.00, -4.00, -4.00),
('CX', 'Indian/Christmas', 7.00, 7.00, 7.00),
('CY', 'Asia/Nicosia', 2.00, 3.00, 2.00),
('CZ', 'Europe/Prague', 1.00, 2.00, 1.00),
('DE', 'Europe/Berlin', 1.00, 2.00, 1.00),
('DE', 'Europe/Busingen', 1.00, 2.00, 1.00),
('DJ', 'Africa/Djibouti', 3.00, 3.00, 3.00),
('DK', 'Europe/Copenhagen', 1.00, 2.00, 1.00),
('DM', 'America/Dominica', -4.00, -4.00, -4.00),
('DO', 'America/Santo_Domingo', -4.00, -4.00, -4.00),
('DZ', 'Africa/Algiers', 1.00, 1.00, 1.00),
('EC', 'America/Guayaquil', -5.00, -5.00, -5.00),
('EC', 'Pacific/Galapagos', -6.00, -6.00, -6.00),
('EE', 'Europe/Tallinn', 2.00, 3.00, 2.00),
('EG', 'Africa/Cairo', 2.00, 2.00, 2.00),
('EH', 'Africa/El_Aaiun', 0.00, 0.00, 0.00),
('ER', 'Africa/Asmara', 3.00, 3.00, 3.00),
('ES', 'Africa/Ceuta', 1.00, 2.00, 1.00),
('ES', 'Atlantic/Canary', 0.00, 1.00, 0.00),
('ES', 'Europe/Madrid', 1.00, 2.00, 1.00),
('ET', 'Africa/Addis_Ababa', 3.00, 3.00, 3.00),
('FI', 'Europe/Helsinki', 2.00, 3.00, 2.00),
('FJ', 'Pacific/Fiji', 13.00, 12.00, 12.00),
('FK', 'Atlantic/Stanley', -3.00, -3.00, -3.00),
('FM', 'Pacific/Chuuk', 10.00, 10.00, 10.00),
('FM', 'Pacific/Kosrae', 11.00, 11.00, 11.00),
('FM', 'Pacific/Pohnpei', 11.00, 11.00, 11.00),
('FO', 'Atlantic/Faroe', 0.00, 1.00, 0.00),
('FR', 'Europe/Paris', 1.00, 2.00, 1.00),
('GA', 'Africa/Libreville', 1.00, 1.00, 1.00),
('GB', 'Europe/London', 0.00, 1.00, 0.00),
('GD', 'America/Grenada', -4.00, -4.00, -4.00),
('GE', 'Asia/Tbilisi', 4.00, 4.00, 4.00),
('GF', 'America/Cayenne', -3.00, -3.00, -3.00),
('GG', 'Europe/Guernsey', 0.00, 1.00, 0.00),
('GH', 'Africa/Accra', 0.00, 0.00, 0.00),
('GI', 'Europe/Gibraltar', 1.00, 2.00, 1.00),
('GL', 'America/Danmarkshavn', 0.00, 0.00, 0.00),
('GL', 'America/Godthab', -3.00, -2.00, -3.00),
('GL', 'America/Scoresbysund', -1.00, 0.00, -1.00),
('GL', 'America/Thule', -4.00, -3.00, -4.00),
('GM', 'Africa/Banjul', 0.00, 0.00, 0.00),
('GN', 'Africa/Conakry', 0.00, 0.00, 0.00),
('GP', 'America/Guadeloupe', -4.00, -4.00, -4.00),
('GQ', 'Africa/Malabo', 1.00, 1.00, 1.00),
('GR', 'Europe/Athens', 2.00, 3.00, 2.00),
('GS', 'Atlantic/South_Georgia', -2.00, -2.00, -2.00),
('GT', 'America/Guatemala', -6.00, -6.00, -6.00),
('GU', 'Pacific/Guam', 10.00, 10.00, 10.00),
('GW', 'Africa/Bissau', 0.00, 0.00, 0.00),
('GY', 'America/Guyana', -4.00, -4.00, -4.00),
('HK', 'Asia/Hong_Kong', 8.00, 8.00, 8.00),
('HN', 'America/Tegucigalpa', -6.00, -6.00, -6.00),
('HR', 'Europe/Zagreb', 1.00, 2.00, 1.00),
('HT', 'America/Port-au-Prince', -5.00, -4.00, -5.00),
('HU', 'Europe/Budapest', 1.00, 2.00, 1.00),
('ID', 'Asia/Jakarta', 7.00, 7.00, 7.00),
('ID', 'Asia/Jayapura', 9.00, 9.00, 9.00),
('ID', 'Asia/Makassar', 8.00, 8.00, 8.00),
('ID', 'Asia/Pontianak', 7.00, 7.00, 7.00),
('IE', 'Europe/Dublin', 0.00, 1.00, 0.00),
('IL', 'Asia/Jerusalem', 2.00, 3.00, 2.00),
('IM', 'Europe/Isle_of_Man', 0.00, 1.00, 0.00),
('IN', 'Asia/Kolkata', 5.50, 5.50, 5.50),
('IO', 'Indian/Chagos', 6.00, 6.00, 6.00),
('IQ', 'Asia/Baghdad', 3.00, 3.00, 3.00),
('IR', 'Asia/Tehran', 3.50, 4.50, 3.50),
('IS', 'Atlantic/Reykjavik', 0.00, 0.00, 0.00),
('IT', 'Europe/Rome', 1.00, 2.00, 1.00),
('JE', 'Europe/Jersey', 0.00, 1.00, 0.00),
('JM', 'America/Jamaica', -5.00, -5.00, -5.00),
('JO', 'Asia/Amman', 2.00, 3.00, 2.00),
('JP', 'Asia/Tokyo', 9.00, 9.00, 9.00),
('KE', 'Africa/Nairobi', 3.00, 3.00, 3.00),
('KG', 'Asia/Bishkek', 6.00, 6.00, 6.00),
('KH', 'Asia/Phnom_Penh', 7.00, 7.00, 7.00),
('KI', 'Pacific/Enderbury', 13.00, 13.00, 13.00),
('KI', 'Pacific/Kiritimati', 14.00, 14.00, 14.00),
('KI', 'Pacific/Tarawa', 12.00, 12.00, 12.00),
('KM', 'Indian/Comoro', 3.00, 3.00, 3.00),
('KN', 'America/St_Kitts', -4.00, -4.00, -4.00),
('KP', 'Asia/Pyongyang', 9.00, 9.00, 9.00),
('KR', 'Asia/Seoul', 9.00, 9.00, 9.00),
('KW', 'Asia/Kuwait', 3.00, 3.00, 3.00),
('KY', 'America/Cayman', -5.00, -5.00, -5.00),
('KZ', 'Asia/Almaty', 6.00, 6.00, 6.00),
('KZ', 'Asia/Aqtau', 5.00, 5.00, 5.00),
('KZ', 'Asia/Aqtobe', 5.00, 5.00, 5.00),
('KZ', 'Asia/Oral', 5.00, 5.00, 5.00),
('KZ', 'Asia/Qyzylorda', 6.00, 6.00, 6.00),
('LA', 'Asia/Vientiane', 7.00, 7.00, 7.00),
('LB', 'Asia/Beirut', 2.00, 3.00, 2.00),
('LC', 'America/St_Lucia', -4.00, -4.00, -4.00),
('LI', 'Europe/Vaduz', 1.00, 2.00, 1.00),
('LK', 'Asia/Colombo', 5.50, 5.50, 5.50),
('LR', 'Africa/Monrovia', 0.00, 0.00, 0.00),
('LS', 'Africa/Maseru', 2.00, 2.00, 2.00),
('LT', 'Europe/Vilnius', 2.00, 3.00, 2.00),
('LU', 'Europe/Luxembourg', 1.00, 2.00, 1.00),
('LV', 'Europe/Riga', 2.00, 3.00, 2.00),
('LY', 'Africa/Tripoli', 2.00, 2.00, 2.00),
('MA', 'Africa/Casablanca', 0.00, 0.00, 0.00),
('MC', 'Europe/Monaco', 1.00, 2.00, 1.00),
('MD', 'Europe/Chisinau', 2.00, 3.00, 2.00),
('ME', 'Europe/Podgorica', 1.00, 2.00, 1.00),
('MF', 'America/Marigot', -4.00, -4.00, -4.00),
('MG', 'Indian/Antananarivo', 3.00, 3.00, 3.00),
('MH', 'Pacific/Kwajalein', 12.00, 12.00, 12.00),
('MH', 'Pacific/Majuro', 12.00, 12.00, 12.00),
('MK', 'Europe/Skopje', 1.00, 2.00, 1.00),
('ML', 'Africa/Bamako', 0.00, 0.00, 0.00),
('MM', 'Asia/Rangoon', 6.50, 6.50, 6.50),
('MN', 'Asia/Choibalsan', 8.00, 8.00, 8.00),
('MN', 'Asia/Hovd', 7.00, 7.00, 7.00),
('MN', 'Asia/Ulaanbaatar', 8.00, 8.00, 8.00),
('MO', 'Asia/Macau', 8.00, 8.00, 8.00),
('MP', 'Pacific/Saipan', 10.00, 10.00, 10.00),
('MQ', 'America/Martinique', -4.00, -4.00, -4.00),
('MR', 'Africa/Nouakchott', 0.00, 0.00, 0.00),
('MS', 'America/Montserrat', -4.00, -4.00, -4.00),
('MT', 'Europe/Malta', 1.00, 2.00, 1.00),
('MU', 'Indian/Mauritius', 4.00, 4.00, 4.00),
('MV', 'Indian/Maldives', 5.00, 5.00, 5.00),
('MW', 'Africa/Blantyre', 2.00, 2.00, 2.00),
('MX', 'America/Bahia_Banderas', -6.00, -5.00, -6.00),
('MX', 'America/Cancun', -6.00, -5.00, -6.00),
('MX', 'America/Chihuahua', -7.00, -6.00, -7.00),
('MX', 'America/Hermosillo', -7.00, -7.00, -7.00),
('MX', 'America/Matamoros', -6.00, -5.00, -6.00),
('MX', 'America/Mazatlan', -7.00, -6.00, -7.00),
('MX', 'America/Merida', -6.00, -5.00, -6.00),
('MX', 'America/Mexico_City', -6.00, -5.00, -6.00),
('MX', 'America/Monterrey', -6.00, -5.00, -6.00),
('MX', 'America/Ojinaga', -7.00, -6.00, -7.00),
('MX', 'America/Santa_Isabel', -8.00, -7.00, -8.00),
('MX', 'America/Tijuana', -8.00, -7.00, -8.00),
('MY', 'Asia/Kuala_Lumpur', 8.00, 8.00, 8.00),
('MY', 'Asia/Kuching', 8.00, 8.00, 8.00),
('MZ', 'Africa/Maputo', 2.00, 2.00, 2.00),
('NA', 'Africa/Windhoek', 2.00, 1.00, 1.00),
('NC', 'Pacific/Noumea', 11.00, 11.00, 11.00),
('NE', 'Africa/Niamey', 1.00, 1.00, 1.00),
('NF', 'Pacific/Norfolk', 11.50, 11.50, 11.50),
('NG', 'Africa/Lagos', 1.00, 1.00, 1.00),
('NI', 'America/Managua', -6.00, -6.00, -6.00),
('NL', 'Europe/Amsterdam', 1.00, 2.00, 1.00),
('NO', 'Europe/Oslo', 1.00, 2.00, 1.00),
('NP', 'Asia/Kathmandu', 5.75, 5.75, 5.75),
('NR', 'Pacific/Nauru', 12.00, 12.00, 12.00),
('NU', 'Pacific/Niue', -11.00, -11.00, -11.00),
('NZ', 'Pacific/Auckland', 13.00, 12.00, 12.00),
('NZ', 'Pacific/Chatham', 13.75, 12.75, 12.75),
('OM', 'Asia/Muscat', 4.00, 4.00, 4.00),
('PA', 'America/Panama', -5.00, -5.00, -5.00),
('PE', 'America/Lima', -5.00, -5.00, -5.00),
('PF', 'Pacific/Gambier', -9.00, -9.00, -9.00),
('PF', 'Pacific/Marquesas', -9.50, -9.50, -9.50),
('PF', 'Pacific/Tahiti', -10.00, -10.00, -10.00),
('PG', 'Pacific/Port_Moresby', 10.00, 10.00, 10.00),
('PH', 'Asia/Manila', 8.00, 8.00, 8.00),
('PK', 'Asia/Karachi', 5.00, 5.00, 5.00),
('PL', 'Europe/Warsaw', 1.00, 2.00, 1.00),
('PM', 'America/Miquelon', -3.00, -2.00, -3.00),
('PN', 'Pacific/Pitcairn', -8.00, -8.00, -8.00),
('PR', 'America/Puerto_Rico', -4.00, -4.00, -4.00),
('PS', 'Asia/Gaza', 2.00, 3.00, 2.00),
('PS', 'Asia/Hebron', 2.00, 3.00, 2.00),
('PT', 'Atlantic/Azores', -1.00, 0.00, -1.00),
('PT', 'Atlantic/Madeira', 0.00, 1.00, 0.00),
('PT', 'Europe/Lisbon', 0.00, 1.00, 0.00),
('PW', 'Pacific/Palau', 9.00, 9.00, 9.00),
('PY', 'America/Asuncion', -3.00, -4.00, -4.00),
('QA', 'Asia/Qatar', 3.00, 3.00, 3.00),
('RE', 'Indian/Reunion', 4.00, 4.00, 4.00),
('RO', 'Europe/Bucharest', 2.00, 3.00, 2.00),
('RS', 'Europe/Belgrade', 1.00, 2.00, 1.00),
('RU', 'Asia/Anadyr', 12.00, 12.00, 12.00),
('RU', 'Asia/Irkutsk', 9.00, 9.00, 9.00),
('RU', 'Asia/Kamchatka', 12.00, 12.00, 12.00),
('RU', 'Asia/Khandyga', 10.00, 10.00, 10.00),
('RU', 'Asia/Krasnoyarsk', 8.00, 8.00, 8.00),
('RU', 'Asia/Magadan', 12.00, 12.00, 12.00),
('RU', 'Asia/Novokuznetsk', 7.00, 7.00, 7.00),
('RU', 'Asia/Novosibirsk', 7.00, 7.00, 7.00),
('RU', 'Asia/Omsk', 7.00, 7.00, 7.00),
('RU', 'Asia/Sakhalin', 11.00, 11.00, 11.00),
('RU', 'Asia/Ust-Nera', 11.00, 11.00, 11.00),
('RU', 'Asia/Vladivostok', 11.00, 11.00, 11.00),
('RU', 'Asia/Yakutsk', 10.00, 10.00, 10.00),
('RU', 'Asia/Yekaterinburg', 6.00, 6.00, 6.00),
('RU', 'Europe/Kaliningrad', 3.00, 3.00, 3.00),
('RU', 'Europe/Moscow', 4.00, 4.00, 4.00),
('RU', 'Europe/Samara', 4.00, 4.00, 4.00),
('RU', 'Europe/Volgograd', 4.00, 4.00, 4.00),
('RW', 'Africa/Kigali', 2.00, 2.00, 2.00),
('SA', 'Asia/Riyadh', 3.00, 3.00, 3.00),
('SB', 'Pacific/Guadalcanal', 11.00, 11.00, 11.00),
('SC', 'Indian/Mahe', 4.00, 4.00, 4.00),
('SD', 'Africa/Khartoum', 3.00, 3.00, 3.00),
('SE', 'Europe/Stockholm', 1.00, 2.00, 1.00),
('SG', 'Asia/Singapore', 8.00, 8.00, 8.00),
('SH', 'Atlantic/St_Helena', 0.00, 0.00, 0.00),
('SI', 'Europe/Ljubljana', 1.00, 2.00, 1.00),
('SJ', 'Arctic/Longyearbyen', 1.00, 2.00, 1.00),
('SK', 'Europe/Bratislava', 1.00, 2.00, 1.00),
('SL', 'Africa/Freetown', 0.00, 0.00, 0.00),
('SM', 'Europe/San_Marino', 1.00, 2.00, 1.00),
('SN', 'Africa/Dakar', 0.00, 0.00, 0.00),
('SO', 'Africa/Mogadishu', 3.00, 3.00, 3.00),
('SR', 'America/Paramaribo', -3.00, -3.00, -3.00),
('SS', 'Africa/Juba', 3.00, 3.00, 3.00),
('ST', 'Africa/Sao_Tome', 0.00, 0.00, 0.00),
('SV', 'America/El_Salvador', -6.00, -6.00, -6.00),
('SX', 'America/Lower_Princes', -4.00, -4.00, -4.00),
('SY', 'Asia/Damascus', 2.00, 3.00, 2.00),
('SZ', 'Africa/Mbabane', 2.00, 2.00, 2.00),
('TC', 'America/Grand_Turk', -5.00, -4.00, -5.00),
('TD', 'Africa/Ndjamena', 1.00, 1.00, 1.00),
('TF', 'Indian/Kerguelen', 5.00, 5.00, 5.00),
('TG', 'Africa/Lome', 0.00, 0.00, 0.00),
('TH', 'Asia/Bangkok', 7.00, 7.00, 7.00),
('TJ', 'Asia/Dushanbe', 5.00, 5.00, 5.00),
('TK', 'Pacific/Fakaofo', 13.00, 13.00, 13.00),
('TL', 'Asia/Dili', 9.00, 9.00, 9.00),
('TM', 'Asia/Ashgabat', 5.00, 5.00, 5.00),
('TN', 'Africa/Tunis', 1.00, 1.00, 1.00),
('TO', 'Pacific/Tongatapu', 13.00, 13.00, 13.00),
('TR', 'Europe/Istanbul', 2.00, 3.00, 2.00),
('TT', 'America/Port_of_Spain', -4.00, -4.00, -4.00),
('TV', 'Pacific/Funafuti', 12.00, 12.00, 12.00),
('TW', 'Asia/Taipei', 8.00, 8.00, 8.00),
('TZ', 'Africa/Dar_es_Salaam', 3.00, 3.00, 3.00),
('UA', 'Europe/Kiev', 2.00, 3.00, 2.00),
('UA', 'Europe/Simferopol', 2.00, 4.00, 4.00),
('UA', 'Europe/Uzhgorod', 2.00, 3.00, 2.00),
('UA', 'Europe/Zaporozhye', 2.00, 3.00, 2.00),
('UG', 'Africa/Kampala', 3.00, 3.00, 3.00),
('UM', 'Pacific/Johnston', -10.00, -10.00, -10.00),
('UM', 'Pacific/Midway', -11.00, -11.00, -11.00),
('UM', 'Pacific/Wake', 12.00, 12.00, 12.00),
('US', 'America/Adak', -10.00, -9.00, -10.00),
('US', 'America/Anchorage', -9.00, -8.00, -9.00),
('US', 'America/Boise', -7.00, -6.00, -7.00),
('US', 'America/Chicago', -6.00, -5.00, -6.00),
('US', 'America/Denver', -7.00, -6.00, -7.00),
('US', 'America/Detroit', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Indianapolis', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Knox', -6.00, -5.00, -6.00),
('US', 'America/Indiana/Marengo', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Petersburg', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Tell_City', -6.00, -5.00, -6.00),
('US', 'America/Indiana/Vevay', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Vincennes', -5.00, -4.00, -5.00),
('US', 'America/Indiana/Winamac', -5.00, -4.00, -5.00),
('US', 'America/Juneau', -9.00, -8.00, -9.00),
('US', 'America/Kentucky/Louisville', -5.00, -4.00, -5.00),
('US', 'America/Kentucky/Monticello', -5.00, -4.00, -5.00),
('US', 'America/Los_Angeles', -8.00, -7.00, -8.00),
('US', 'America/Menominee', -6.00, -5.00, -6.00),
('US', 'America/Metlakatla', -8.00, -8.00, -8.00),
('US', 'America/New_York', -5.00, -4.00, -5.00),
('US', 'America/Nome', -9.00, -8.00, -9.00),
('US', 'America/North_Dakota/Beulah', -6.00, -5.00, -6.00),
('US', 'America/North_Dakota/Center', -6.00, -5.00, -6.00),
('US', 'America/North_Dakota/New_Salem', -6.00, -5.00, -6.00),
('US', 'America/Phoenix', -7.00, -7.00, -7.00),
('US', 'America/Shiprock', -7.00, -6.00, -7.00),
('US', 'America/Sitka', -9.00, -8.00, -9.00),
('US', 'America/Yakutat', -9.00, -8.00, -9.00),
('US', 'Pacific/Honolulu', -10.00, -10.00, -10.00),
('UY', 'America/Montevideo', -2.00, -3.00, -3.00),
('UZ', 'Asia/Samarkand', 5.00, 5.00, 5.00),
('UZ', 'Asia/Tashkent', 5.00, 5.00, 5.00),
('VA', 'Europe/Vatican', 1.00, 2.00, 1.00),
('VC', 'America/St_Vincent', -4.00, -4.00, -4.00),
('VE', 'America/Caracas', -4.50, -4.50, -4.50),
('VG', 'America/Tortola', -4.00, -4.00, -4.00),
('VI', 'America/St_Thomas', -4.00, -4.00, -4.00),
('VN', 'Asia/Ho_Chi_Minh', 7.00, 7.00, 7.00),
('VU', 'Pacific/Efate', 11.00, 11.00, 11.00),
('WF', 'Pacific/Wallis', 12.00, 12.00, 12.00),
('WS', 'Pacific/Apia', 14.00, 13.00, 13.00),
('YE', 'Asia/Aden', 3.00, 3.00, 3.00),
('YT', 'Indian/Mayotte', 3.00, 3.00, 3.00),
('ZA', 'Africa/Johannesburg', 2.00, 2.00, 2.00),
('ZM', 'Africa/Lusaka', 2.00, 2.00, 2.00),
('ZW', 'Africa/Harare', 2.00, 2.00, 2.00);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `transcation_id` varchar(255) DEFAULT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `transcation_type` int(11) DEFAULT NULL COMMENT '1=event, 2=product, 3= withdraw, 4= balance add, 5 = balance subtract',
  `customer_id` bigint(20) DEFAULT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `payment_status` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `grand_total` double(8,2) DEFAULT NULL,
  `commission` float(8,2) DEFAULT '0.00',
  `tax` float(8,2) DEFAULT '0.00',
  `pre_balance` float(8,2) DEFAULT '0.00',
  `after_balance` float(8,2) DEFAULT '0.00',
  `gateway_type` varchar(255) DEFAULT NULL,
  `currency_symbol` varchar(255) DEFAULT NULL,
  `currency_symbol_position` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`id`, `transcation_id`, `booking_id`, `transcation_type`, `customer_id`, `organizer_id`, `payment_status`, `payment_method`, `grand_total`, `commission`, `tax`, `pre_balance`, `after_balance`, `gateway_type`, `currency_symbol`, `currency_symbol_position`, `created_at`, `updated_at`) VALUES
(1, '1684058634', '1', 2, 23, NULL, '1', 'PayPal', 550.00, 550.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-05-14 10:03:54', '2023-05-14 10:03:54'),
(2, '1684058744', '2', 2, 23, NULL, '1', 'PayPal', 25.00, 25.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-05-14 10:05:44', '2023-05-14 10:44:24'),
(3, '1684058782', '3', 2, 23, NULL, '1', 'PayPal', 770.00, 770.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-05-14 10:06:22', '2023-05-14 10:06:22'),
(4, '1684058804', '4', 2, 23, NULL, '1', 'Citibank', 250.00, 250.00, 0.00, 0.00, 0.00, 'offline', '$', 'left', '2023-05-14 10:06:44', '2023-05-14 10:06:44'),
(5, '1684058827', '5', 2, 23, NULL, '1', 'Citibank', 340.00, 340.00, 0.00, 0.00, 0.00, 'offline', '$', 'left', '2023-05-14 10:07:07', '2023-05-14 10:07:07'),
(6, '1684058854', '6', 2, 23, NULL, '1', 'Bank of America', 320.00, 320.00, 0.00, 0.00, 0.00, 'offline', '$', 'left', '2023-05-14 10:07:34', '2023-05-14 10:07:34'),
(7, '1684059006', '1', 1, 23, 25, '1', 'PayPal', 160.00, 8.00, 16.00, 0.00, 152.00, 'online', '$', 'left', '2023-05-14 10:10:06', '2023-05-14 10:10:06'),
(8, '1684059272', '2', 1, 23, 23, '1', 'PayPal', 95.00, 4.75, 9.50, 0.00, 90.25, 'online', '$', 'left', '2023-05-14 10:14:32', '2023-05-14 10:14:32'),
(9, '1684059352', '3', 1, 23, NULL, '1', 'PayPal', 112.00, 5.60, 11.20, 0.00, NULL, 'online', '$', 'left', '2023-05-14 10:15:52', '2023-05-14 10:15:52'),
(10, '1684059437', '4', 1, 23, 23, '1', 'PayPal', 40.00, 2.00, 4.00, 90.25, 128.25, 'online', '$', 'left', '2023-05-14 10:17:17', '2023-05-14 10:17:17'),
(11, '1684059694', '7', 1, 23, 25, '1', 'Citibank', 20.00, 1.00, 2.00, 152.00, 171.00, 'offline', '$', 'left', '2023-05-14 10:21:34', '2023-05-14 10:21:34'),
(12, '1684060293', '8', 1, 23, NULL, '1', 'PayPal', 237.20, 11.86, 23.72, 0.00, NULL, 'online', '$', 'left', '2023-05-14 10:31:33', '2023-05-14 10:31:33'),
(13, '1684060340', '9', 1, 23, 24, '1', 'Bank of America', 50.00, 2.50, 5.00, 0.00, 47.50, 'offline', '$', 'left', '2023-05-14 10:32:20', '2023-05-14 10:32:20'),
(14, '1684060389', '10', 1, 23, 23, '1', 'PayPal', 500.00, 25.00, 50.00, 128.25, 603.25, 'online', '$', 'left', '2023-05-14 10:33:09', '2023-05-14 10:33:09'),
(15, '1684060587', '7', 2, 23, NULL, '1', 'PayPal', 300.00, 300.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-05-14 10:36:27', '2023-05-14 10:36:27'),
(16, '1684060744', '13', 1, 23, 24, '1', 'PayPal', 50.00, 2.50, 5.00, 47.50, 95.00, 'online', '$', 'left', '2023-05-14 10:39:04', '2023-05-14 10:39:04'),
(17, '1684060996', '1', 3, NULL, 23, '1', '4', 50.00, 0.00, 0.00, 603.25, 553.25, NULL, '$', 'left', '2023-05-14 10:43:16', '2023-05-14 10:44:14'),
(18, '1684061019', '2', 3, NULL, 23, '2', '5', 70.00, 0.00, 0.00, 553.25, 483.25, NULL, '$', 'left', '2023-05-14 10:43:39', '2023-05-14 10:53:53'),
(19, '1684061084', '3', 3, NULL, 23, '0', '4', 100.00, 0.00, 0.00, 553.25, 453.25, NULL, '$', 'left', '2023-05-14 10:44:44', '2023-05-14 10:44:44'),
(20, '1690701577', '14', 1, 23, NULL, '1', 'Stripe', 166.10, 8.31, 16.61, 0.00, NULL, 'online', '$', 'left', '2023-07-30 07:19:37', '2023-07-30 07:19:37'),
(21, '1690709435', '15', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 453.25, 690.75, 'online', '$', 'left', '2023-07-30 09:30:35', '2023-07-30 09:30:35'),
(22, '1690709686', '18', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 690.75, 928.25, 'online', '$', 'left', '2023-07-30 09:34:46', '2023-07-30 09:34:46'),
(23, '1690709701', '19', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 928.25, 1165.75, 'online', '$', 'left', '2023-07-30 09:35:01', '2023-07-30 09:35:01'),
(24, '1690709784', '20', 1, 23, 23, '1', 'PayPal', 190.00, 9.50, 19.00, 1165.75, 1346.25, 'online', '$', 'left', '2023-07-30 09:36:24', '2023-07-30 09:36:24'),
(25, '1690709837', '21', 1, 23, 23, '1', 'PayPal', 140.00, 7.00, 14.00, 1346.25, 1479.25, 'online', '$', 'left', '2023-07-30 09:37:17', '2023-07-30 09:37:17'),
(26, '1690711904', '22', 1, 23, 23, '1', 'Stripe', 100.00, 5.00, 10.00, 1479.25, 1574.25, 'online', '$', 'left', '2023-07-30 10:11:44', '2023-07-30 10:11:44'),
(27, '1690712455', '23', 1, 23, NULL, '1', 'Stripe', 142.20, 7.11, 14.22, 0.00, NULL, 'online', '$', 'left', '2023-07-30 10:20:55', '2023-07-30 10:20:55'),
(28, '1690712617', '24', 1, 23, NULL, '1', 'Stripe', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2023-07-30 10:23:37', '2023-07-30 10:23:37'),
(29, '1690712825', '25', 1, 23, 25, '1', 'Stripe', 20.00, 1.00, 2.00, 171.00, 190.00, 'online', '$', 'left', '2023-07-30 10:27:05', '2023-07-30 10:27:05'),
(30, '1690712878', '26', 1, 23, 23, '1', 'Stripe', 40.00, 2.00, 4.00, 1574.25, 1612.25, 'online', '$', 'left', '2023-07-30 10:27:58', '2023-07-30 10:27:58'),
(31, '1690784185', '27', 1, 23, 23, '1', 'Stripe', 100.00, 5.00, 10.00, 1612.25, 1707.25, 'online', '$', 'left', '2023-07-31 06:16:25', '2023-07-31 06:16:25'),
(32, '1690785075', '28', 1, 23, 23, '1', 'Stripe', 60.00, 3.00, 6.00, 1707.25, 1764.25, 'online', '$', 'left', '2023-07-31 06:31:15', '2023-07-31 06:31:15'),
(33, '1690785167', '29', 1, 23, NULL, '1', 'Stripe', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2023-07-31 06:32:47', '2023-07-31 06:32:47'),
(34, '1690785889', '8', 2, 23, NULL, '1', 'Stripe', 760.00, 760.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-07-31 06:44:49', '2023-07-31 06:44:49'),
(35, '1696070205', '9', 2, NULL, NULL, '1', 'PayPal', 756.55, 756.55, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-09-30 10:36:45', '2023-09-30 10:36:45'),
(36, '1696132488', '10', 2, 23, NULL, '1', 'PayPal', 973.90, 973.90, 0.00, 0.00, 0.00, 'online', '$', 'left', '2023-10-01 03:54:48', '2023-10-01 03:54:48'),
(37, '1700125979', '30', 1, NULL, NULL, '1', 'PayPal', 166.10, 8.31, 16.61, 0.00, NULL, 'online', '$', 'left', '2023-11-16 03:12:59', '2023-11-16 03:12:59'),
(38, '1700130298', '31', 1, NULL, 23, '1', 'Citibank', 190.00, 9.50, 19.00, 1764.25, 1944.75, 'offline', '$', 'left', '2023-11-16 04:24:58', '2023-11-16 04:24:58'),
(39, '1700281254', '32', 1, NULL, NULL, '1', 'PayPal', 166.10, 8.31, 16.61, 0.00, NULL, 'online', '$', 'left', '2023-11-17 22:20:54', '2023-11-17 22:20:54'),
(40, '1700281373', '34', 1, NULL, 23, '1', 'PayPal', 140.00, 7.00, 14.00, 1944.75, 2077.75, 'online', '$', 'left', '2023-11-17 22:22:53', '2023-11-17 22:22:53'),
(41, '1700282231', '35', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 2077.75, 2315.25, 'online', '$', 'left', '2023-11-17 22:37:11', '2023-11-17 22:37:11'),
(42, '1700282308', '36', 1, 23, 23, '1', 'PayPal', 40.00, 2.00, 4.00, 2315.25, 2353.25, 'online', '$', 'left', '2023-11-17 22:38:28', '2023-11-17 22:38:28'),
(43, '1700633180', '37', 1, 23, NULL, '1', 'PayPal', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2023-11-22 00:06:20', '2023-11-22 00:06:20'),
(44, '1700633763', '38', 1, 23, NULL, '1', 'PayPal', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2023-11-22 00:16:03', '2023-11-22 00:16:03'),
(45, '1700633845', '39', 1, 23, 23, '1', 'PayPal', 40.00, 2.00, 4.00, 2353.25, 2391.25, 'online', '$', 'left', '2023-11-22 00:17:25', '2023-11-22 00:17:25'),
(46, '1700636224', '40', 1, 23, 23, '1', 'PayPal', 240.00, 12.00, 24.00, 2391.25, 2619.25, 'online', '$', 'left', '2023-11-22 00:57:04', '2023-11-22 00:57:04'),
(47, '1700636402', '41', 1, 23, 23, '1', 'PayPal', 410.00, 20.50, 41.00, 2619.25, 3008.75, 'online', '$', 'left', '2023-11-22 01:00:02', '2023-11-22 01:00:02'),
(48, '1700637043', '1', 1, 23, 23, '1', 'PayPal', 190.00, 9.50, 19.00, 3008.75, 3189.25, 'online', '$', 'left', '2023-11-22 01:10:43', '2023-11-22 01:10:43'),
(49, '1700637871', '4', 1, 23, 23, '1', 'PayPal', 450.00, 22.50, 45.00, 3189.25, 3616.75, 'online', '$', 'left', '2023-11-22 01:24:31', '2023-11-22 01:24:31'),
(50, '1700638051', '5', 1, 23, 23, '1', 'PayPal', 400.00, 20.00, 40.00, 3616.75, 3996.75, 'online', '$', 'left', '2023-11-22 01:27:31', '2023-11-22 01:27:31'),
(51, '1700642581', '6', 1, 23, 23, '1', 'PayPal', 450.00, 22.50, 45.00, 3996.75, 4424.25, 'online', '$', 'left', '2023-11-22 02:43:01', '2023-11-22 02:43:01'),
(52, '1700645909', '7', 1, 23, 23, '1', 'PayPal', 520.00, 26.00, 52.00, 4424.25, 4918.25, 'online', '$', 'left', '2023-11-22 03:38:29', '2023-11-22 03:38:29'),
(53, '1700646364', '8', 1, 23, 23, '1', 'PayPal', 450.00, 22.50, 45.00, 4918.25, 5345.75, 'online', '$', 'left', '2023-11-22 03:46:04', '2023-11-22 03:46:04'),
(54, '1700647186', '9', 1, 23, 25, '1', 'PayPal', 40.00, 2.00, 4.00, 190.00, 228.00, 'online', '$', 'left', '2023-11-22 03:59:46', '2023-11-22 03:59:46'),
(55, '1700647238', '10', 1, 23, 23, '1', 'PayPal', 100.00, 5.00, 10.00, 5345.75, 5440.75, 'online', '$', 'left', '2023-11-22 04:00:38', '2023-11-22 04:00:38'),
(56, '1700647346', '11', 1, 23, 23, '0', 'PayPal', 200.00, 10.00, 20.00, 5440.75, 5630.75, 'online', '$', 'left', '2023-11-22 04:02:26', '2024-09-03 04:00:36'),
(57, '1700714591', '12', 1, NULL, 23, '1', 'PayPal', 430.00, 21.50, 43.00, 5630.75, 6039.25, 'online', '$', 'left', '2023-11-22 22:43:11', '2023-11-22 22:43:11'),
(58, '1707289183', '14', 1, 23, 23, '1', 'PayPal', 110.00, 5.50, 11.00, 6039.25, 6143.75, 'online', '$', 'left', '2024-02-07 06:59:43', '2024-02-07 06:59:43'),
(59, '1707289307', '15', 1, 23, NULL, '1', 'Midtrans', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2024-02-07 07:01:47', '2024-02-07 07:01:47'),
(60, '1707297038', '16', 1, 23, 23, '1', 'Midtrans', 60.00, 3.00, 6.00, 6143.75, 6200.75, 'online', '$', 'left', '2024-02-07 09:10:38', '2024-02-07 09:10:38'),
(61, '1707298102', '11', 2, 23, NULL, '1', 'Midtrans', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-07 09:28:22', '2024-02-07 09:28:22'),
(62, '1707298365', '17', 1, 23, 23, '1', 'Midtrans', 40.00, 2.00, 4.00, 6200.75, 6238.75, 'online', '$', 'left', '2024-02-07 09:32:45', '2024-02-07 09:32:45'),
(63, '1707298491', '12', 2, 23, NULL, '1', 'Midtrans', 62.50, 62.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-07 09:34:51', '2024-02-07 09:34:51'),
(64, '1707298828', '13', 2, 23, NULL, '1', 'Midtrans', 167.50, 167.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-07 09:40:28', '2024-02-07 09:40:28'),
(65, '1707298932', '18', 1, 23, 23, '1', 'Midtrans', 20.00, 1.00, 2.00, 6238.75, 6257.75, 'online', '$', 'left', '2024-02-07 09:42:12', '2024-02-07 09:42:12'),
(66, '1707374905', '19', 1, 23, 23, '1', 'Iyzico', 60.00, 3.00, 6.00, 6257.75, 6314.75, 'online', '$', 'left', '2024-02-08 06:48:25', '2024-02-08 06:48:25'),
(67, '1707375040', '20', 1, 23, NULL, '1', 'Iyzico', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2024-02-08 06:50:40', '2024-02-08 06:50:40'),
(68, '1707375157', '21', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 6314.75, 6419.25, 'online', '$', 'left', '2024-02-08 06:52:37', '2024-02-08 06:52:37'),
(69, '1707375819', '22', 1, 23, 23, '1', 'Iyzico', 140.00, 7.00, 14.00, 6419.25, 6552.25, 'online', '$', 'left', '2024-02-08 07:03:39', '2024-02-08 07:03:39'),
(70, '1707384583', '23', 1, 23, 23, '1', 'Iyzico', 40.00, 2.00, 4.00, 6552.25, 6590.25, 'online', '$', 'left', '2024-02-08 09:29:43', '2024-02-08 09:29:43'),
(71, '1707391819', '24', 1, 23, 23, '1', 'PayPal', 60.00, 3.00, 6.00, 6590.25, 6647.25, 'online', '$', 'left', '2024-02-08 11:30:19', '2024-02-08 11:30:19'),
(72, '1707391913', '25', 1, 23, 23, '1', 'Paytabs', 110.00, 5.50, 11.00, 6647.25, 6751.75, 'online', '$', 'left', '2024-02-08 11:31:53', '2024-02-08 11:31:53'),
(73, '1707392022', '26', 1, 23, 23, '1', 'Paytabs', 90.00, 4.50, 9.00, 6751.75, 6837.25, 'online', '$', 'left', '2024-02-08 11:33:42', '2024-02-08 11:33:42'),
(74, '1707392104', '27', 1, 23, NULL, '1', 'Paytabs', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2024-02-08 11:35:04', '2024-02-08 11:35:04'),
(75, '1707393235', '28', 1, 23, 23, '1', 'Paytabs', 60.00, 3.00, 6.00, 6837.25, 6894.25, 'online', '$', 'left', '2024-02-08 11:53:55', '2024-02-08 11:53:55'),
(76, '1707393584', '29', 1, 23, 23, '1', 'Paytabs', 60.00, 3.00, 6.00, 6894.25, 6951.25, 'online', '$', 'left', '2024-02-08 11:59:44', '2024-02-08 11:59:44'),
(77, '1707394165', '14', 2, 23, NULL, '1', 'Midtrans', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-08 12:09:25', '2024-02-08 12:09:25'),
(78, '1707394224', '15', 2, 23, NULL, '1', 'Paytabs', 325.00, 325.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-08 12:10:24', '2024-02-08 12:10:24'),
(79, '1707540316', '30', 1, 23, NULL, '1', 'Paytabs', 71.10, 3.56, 7.11, 0.00, NULL, 'online', '$', 'left', '2024-02-10 04:45:16', '2024-02-10 04:45:16'),
(80, '1707540443', '31', 1, 23, 23, '1', 'Paytabs', 60.00, 3.00, 6.00, 6951.25, 7008.25, 'online', '$', 'left', '2024-02-10 04:47:23', '2024-02-10 04:47:23'),
(81, '1707540523', '16', 2, 23, NULL, '1', 'Paytabs', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 04:48:43', '2024-02-10 04:48:43'),
(82, '1707544647', '32', 1, 23, 23, '1', 'Toyyibpay', 60.00, 3.00, 6.00, 7008.25, 7065.25, 'online', '$', 'left', '2024-02-10 05:57:27', '2024-02-10 05:57:27'),
(83, '1707545475', '17', 2, 23, NULL, '1', 'Midtrans', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 06:11:15', '2024-02-10 06:11:15'),
(84, '1707545544', '18', 2, 23, NULL, '1', 'Toyyibpay', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 06:12:24', '2024-02-10 06:12:24'),
(85, '1707551316', '33', 1, 23, 23, '1', 'Phonepe', 120.00, 6.00, 12.00, 7065.25, 7179.25, 'online', '$', 'left', '2024-02-10 07:48:36', '2024-02-10 07:48:36'),
(86, '1707551387', '34', 1, 23, 23, '1', 'Phonepe', 120.00, 6.00, 12.00, 7179.25, 7293.25, 'online', '$', 'left', '2024-02-10 07:49:47', '2024-02-10 07:49:47'),
(87, '1707556727', '19', 2, 23, NULL, '1', 'Paytabs', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 09:18:47', '2024-02-10 09:18:47'),
(88, '1707556806', '20', 2, 23, NULL, '1', 'Paytabs', 325.00, 325.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 09:20:06', '2024-02-10 09:20:06'),
(89, '1707556885', '21', 2, 23, NULL, '1', 'Phonepe', 325.00, 325.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 09:21:25', '2024-02-10 09:21:25'),
(90, '1707560997', '35', 1, 23, 23, '1', 'Toyyibpay', 120.00, 6.00, 12.00, 7293.25, 7407.25, 'online', '$', 'left', '2024-02-10 10:29:57', '2024-02-10 10:29:57'),
(91, '1707561061', '36', 1, 23, 23, '1', 'Yoco', 120.00, 6.00, 12.00, 7407.25, 7521.25, 'online', '$', 'left', '2024-02-10 10:31:01', '2024-02-10 10:31:01'),
(92, '1707561086', '37', 1, 23, 23, '1', 'Yoco', 120.00, 6.00, 12.00, 7521.25, 7635.25, 'online', '$', 'left', '2024-02-10 10:31:26', '2024-02-10 10:31:26'),
(93, '1707561185', '38', 1, 23, 23, '1', 'Yoco', 120.00, 6.00, 12.00, 7635.25, 7749.25, 'online', '$', 'left', '2024-02-10 10:33:05', '2024-02-10 10:33:05'),
(94, '1707562039', '22', 2, 23, NULL, '1', 'Toyyibpay', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:47:19', '2024-02-10 10:47:19'),
(95, '1707562252', '23', 2, 23, NULL, '1', 'Toyyibpay', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:50:52', '2024-02-10 10:50:52'),
(96, '1707562442', '24', 2, 23, NULL, '1', 'Toyyibpay', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:54:02', '2024-02-10 10:54:02'),
(97, '1707562502', '25', 2, 23, NULL, '1', 'Yoco', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:55:02', '2024-02-10 10:55:02'),
(98, '1707562581', '26', 2, 23, NULL, '1', 'Yoco', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:56:21', '2024-02-10 10:56:21'),
(99, '1707562621', '27', 2, 23, NULL, '1', 'Yoco', 577.00, 577.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-10 10:57:01', '2024-02-10 10:57:01'),
(100, '1707629171', '39', 1, 23, 23, '1', 'Toyyibpay', 60.00, 3.00, 6.00, 7749.25, 7806.25, 'online', '$', 'left', '2024-02-11 05:26:11', '2024-02-11 05:26:11'),
(101, '1707629231', '40', 1, 23, 23, '1', 'Xendit', 120.00, 6.00, 12.00, 7806.25, 7920.25, 'online', '$', 'left', '2024-02-11 05:27:11', '2024-02-11 05:27:11'),
(102, '1707639815', '28', 2, 23, NULL, '1', 'Xendit', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-11 08:23:35', '2024-02-11 08:23:35'),
(103, '1707640275', '29', 2, 23, NULL, '1', 'Xendit', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-11 08:31:15', '2024-02-11 08:31:15'),
(104, '1707645477', '41', 1, 23, 23, '1', 'Xendit', 120.00, 6.00, 12.00, 7920.25, 8034.25, 'online', '$', 'left', '2024-02-11 09:57:57', '2024-02-11 09:57:57'),
(105, '1707645868', '42', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8034.25, 8148.25, 'online', '$', 'left', '2024-02-11 10:04:28', '2024-02-11 10:04:28'),
(106, '1707645995', '43', 1, 23, 23, '0', 'Myfatoorah', 120.00, 6.00, 12.00, 8148.25, 8262.25, 'online', '$', 'left', '2024-02-11 10:06:35', '2025-02-28 23:02:14'),
(107, '1707646005', '44', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8262.25, 8376.25, 'online', '$', 'left', '2024-02-11 10:06:45', '2024-02-11 10:06:45'),
(108, '1707646012', '45', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8376.25, 8490.25, 'online', '$', 'left', '2024-02-11 10:06:52', '2024-02-11 10:06:52'),
(109, '1707646120', '46', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8490.25, 8604.25, 'online', '$', 'left', '2024-02-11 10:08:40', '2024-02-11 10:08:40'),
(110, '1707646195', '47', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8604.25, 8718.25, 'online', '$', 'left', '2024-02-11 10:09:55', '2024-02-11 10:09:55'),
(111, '1707646277', '48', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8718.25, 8832.25, 'online', '$', 'left', '2024-02-11 10:11:17', '2024-02-11 10:11:17'),
(112, '1707646313', '49', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8832.25, 8946.25, 'online', '$', 'left', '2024-02-11 10:11:53', '2024-02-11 10:11:53'),
(113, '1707646451', '50', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 8946.25, 9060.25, 'online', '$', 'left', '2024-02-11 10:14:11', '2024-02-11 10:14:11'),
(114, '1707646477', '51', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9060.25, 9174.25, 'online', '$', 'left', '2024-02-11 10:14:37', '2024-02-11 10:14:37'),
(115, '1707646513', '52', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9174.25, 9288.25, 'online', '$', 'left', '2024-02-11 10:15:13', '2024-02-11 10:15:13'),
(116, '1707646589', '53', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9288.25, 9402.25, 'online', '$', 'left', '2024-02-11 10:16:29', '2024-02-11 10:16:29'),
(117, '1707646726', '54', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9402.25, 9516.25, 'online', '$', 'left', '2024-02-11 10:18:46', '2024-02-11 10:18:46'),
(118, '1707646858', '55', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9516.25, 9630.25, 'online', '$', 'left', '2024-02-11 10:20:58', '2024-02-11 10:20:58'),
(119, '1707646896', '56', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9630.25, 9744.25, 'online', '$', 'left', '2024-02-11 10:21:36', '2024-02-11 10:21:36'),
(120, '1707647285', '57', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9744.25, 9858.25, 'online', '$', 'left', '2024-02-11 10:28:05', '2024-02-11 10:28:05'),
(121, '1707647427', '58', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 9858.25, 9972.25, 'online', '$', 'left', '2024-02-11 10:30:27', '2024-02-11 10:30:27'),
(122, '1707648546', '59', 1, 23, 23, '1', 'Myfatoorah', 160.00, 8.00, 16.00, 9972.25, 10124.25, 'online', '$', 'left', '2024-02-11 10:49:06', '2024-02-11 10:49:06'),
(123, '1707649518', '60', 1, 23, 23, '1', 'Myfatoorah', 120.00, 6.00, 12.00, 10124.20, 10238.20, 'online', '$', 'left', '2024-02-11 11:05:18', '2024-02-11 11:05:18'),
(124, '1707649641', '61', 1, 23, 23, '1', 'Myfatoorah', 170.00, 8.50, 17.00, 10238.20, 10399.70, 'online', '$', 'left', '2024-02-11 11:07:21', '2024-02-11 11:07:21'),
(125, '1707650952', '30', 2, 23, NULL, '1', 'Myfatoorah', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-11 11:29:12', '2024-02-11 11:29:12'),
(126, '1707651012', '62', 1, 23, 23, '1', 'Myfatoorah', 210.00, 10.50, 21.00, 10399.70, 10599.20, 'online', '$', 'left', '2024-02-11 11:30:12', '2024-02-11 11:30:12'),
(127, '1707714717', '63', 1, 23, 23, '1', 'Midtrans', 170.00, 8.50, 17.00, 10599.20, 10760.70, 'online', '$', 'left', '2024-02-12 05:11:57', '2024-02-12 05:11:57'),
(128, '1707714790', '31', 2, 23, NULL, '1', 'Midtrans', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-12 05:13:10', '2024-02-12 05:13:10'),
(129, '1707715082', '64', 1, 23, 23, '1', 'Iyzico', 100.00, 5.00, 10.00, 10760.70, 10855.70, 'online', '$', 'left', '2024-02-12 05:18:02', '2024-02-12 05:18:02'),
(130, '1707718559', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 10855.70, 10960.20, 'online', '$', 'left', '2024-02-12 06:15:59', '2024-02-12 06:15:59'),
(131, '1707718606', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 10960.20, 11064.70, 'online', '$', 'left', '2024-02-12 06:16:46', '2024-02-12 06:16:46'),
(132, '1707718674', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11064.70, 11169.20, 'online', '$', 'left', '2024-02-12 06:17:54', '2024-02-12 06:17:54'),
(133, '1707719217', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11169.20, 11273.70, 'online', '$', 'left', '2024-02-12 06:26:57', '2024-02-12 06:26:57'),
(134, '1707719337', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11273.70, 11378.20, 'online', '$', 'left', '2024-02-12 06:28:57', '2024-02-12 06:28:57'),
(135, '1707719357', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11273.70, 11378.20, 'online', '$', 'left', '2024-02-12 06:29:17', '2024-02-12 06:29:17'),
(136, '1707719382', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11378.20, 11482.70, 'online', '$', 'left', '2024-02-12 06:29:42', '2024-02-12 06:29:42'),
(137, '1707719424', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11482.70, 11587.20, 'online', '$', 'left', '2024-02-12 06:30:24', '2024-02-12 06:30:24'),
(138, '1707733442', '32', 2, 23, NULL, '1', 'Citibank', 272.50, 272.50, 0.00, 0.00, 0.00, 'offline', '$', 'left', '2024-02-12 10:24:02', '2024-02-12 10:24:02'),
(139, '1707735695', '67', 1, 23, 23, '1', 'Iyzico', 110.00, 5.50, 11.00, 11691.70, 11796.20, 'online', '$', 'left', '2024-02-12 11:01:35', '2024-02-12 11:01:35'),
(140, '1707735804', '68', 1, 23, 23, '1', 'Iyzico', 100.00, 5.00, 10.00, 11796.20, 11891.20, 'online', '$', 'left', '2024-02-12 11:03:24', '2024-02-12 11:03:24'),
(141, '1707735832', '33', 2, 23, NULL, '1', 'Iyzico', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-12 11:03:52', '2024-02-12 11:03:52'),
(142, '1707735879', '33', 2, 23, NULL, '1', 'Iyzico', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-12 11:04:39', '2024-02-12 11:04:39'),
(143, '1707735959', '33', 2, 23, NULL, '1', 'Iyzico', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-12 11:05:59', '2024-02-12 11:05:59'),
(144, '1707736476', '33', 2, 23, NULL, '1', 'Iyzico', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-12 11:14:36', '2024-02-12 11:14:36'),
(145, '1707800104', '69', 1, 23, 23, '1', 'Midtrans', 120.00, 6.00, 12.00, 11891.20, 12005.20, 'online', '$', 'left', '2024-02-13 04:55:04', '2024-02-13 04:55:04'),
(146, '1707800459', '70', 1, 23, 23, '1', 'Paytabs', 140.00, 7.00, 14.00, 12005.20, 12138.20, 'online', '$', 'left', '2024-02-13 05:00:59', '2024-02-13 05:00:59'),
(147, '1707800707', '34', 2, 23, NULL, '1', 'Paytabs', 797.50, 797.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 05:05:07', '2024-02-13 05:05:07'),
(148, '1707801277', '71', 1, 23, 23, '1', 'Toyyibpay', 80.00, 4.00, 8.00, 12138.20, 12214.20, 'online', '$', 'left', '2024-02-13 05:14:37', '2024-02-13 05:14:37'),
(149, '1707801368', '35', 2, 23, NULL, '1', 'Toyyibpay', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 05:16:08', '2024-02-13 05:16:08'),
(150, '1707802925', '36', 2, 23, NULL, '1', 'Toyyibpay', 36.75, 36.75, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 05:42:05', '2024-02-13 05:42:05'),
(151, '1707803276', '72', 1, 23, 23, '1', 'Phonepe', 220.00, 11.00, 22.00, 12214.20, 12423.20, 'online', '$', 'left', '2024-02-13 05:47:56', '2024-02-13 05:47:56'),
(152, '1707803325', '37', 2, 23, NULL, '1', 'Phonepe', 325.00, 325.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 05:48:45', '2024-02-13 05:48:45'),
(153, '1707803490', '73', 1, 23, 23, '1', 'Yoco', 140.00, 7.00, 14.00, 12423.20, 12556.20, 'online', '$', 'left', '2024-02-13 05:51:30', '2024-02-13 05:51:30'),
(154, '1707803667', '38', 2, 23, NULL, '1', 'Yoco', 325.00, 325.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 05:54:27', '2024-02-13 05:54:27'),
(155, '1707804565', '74', 1, 23, 23, '1', 'Myfatoorah', 180.00, 9.00, 18.00, 12556.20, 12727.20, 'online', '$', 'left', '2024-02-13 06:09:25', '2024-02-13 06:09:25'),
(156, '1707804915', '39', 2, 23, NULL, '1', 'Myfatoorah', 535.00, 535.00, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 06:15:15', '2024-02-13 06:15:15'),
(157, '1707805029', '75', 1, 23, 23, '1', 'Xendit', 130.00, 6.50, 13.00, 12727.20, 12850.70, 'online', '$', 'left', '2024-02-13 06:17:09', '2024-02-13 06:17:09'),
(158, '1707805078', '40', 2, 23, NULL, '1', 'Xendit', 314.50, 314.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-13 06:17:58', '2024-02-13 06:17:58'),
(159, '1707821253', '76', 1, 23, NULL, '1', 'Paytabs', 142.20, 7.11, 14.22, 0.00, NULL, 'online', '$', 'left', '2024-02-13 10:47:33', '2024-02-13 10:47:33'),
(160, '1707892607', '77', 1, 23, 23, '1', 'Phonepe', 80.00, 4.00, 8.00, 12850.70, 12926.70, 'online', NULL, NULL, '2024-02-14 06:36:47', '2024-02-14 06:36:47'),
(161, '1707893929', '41', 2, 23, NULL, '1', 'Phonepe', 62.50, 62.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2024-02-14 06:58:49', '2024-02-14 06:58:49'),
(162, '1724489895', '78', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 12926.70, 13164.20, 'online', '$', 'left', '2024-08-24 02:58:15', '2024-08-24 02:58:15'),
(163, '1724490209', '79', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 13164.20, 13401.70, 'online', '$', 'left', '2024-08-24 03:03:29', '2024-08-24 03:03:29'),
(164, '1724490291', '80', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 13401.70, 13639.20, 'online', '$', 'left', '2024-08-24 03:04:51', '2024-08-24 03:04:51'),
(165, '1724490835', '82', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 13639.20, 13876.70, 'online', '$', 'left', '2024-08-24 03:13:55', '2024-08-24 03:13:55'),
(166, '1724491356', '84', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 13876.70, 14114.20, 'offline', '$', 'left', '2024-08-24 03:22:36', '2024-08-24 03:22:36'),
(167, '1724491948', '85', 1, 23, 23, '1', 'PayPal', 250.00, 12.50, 25.00, 14114.20, 14351.70, 'online', '$', 'left', '2024-08-24 03:32:28', '2024-08-24 03:32:28'),
(168, '1724558959', '86', 1, 23, 23, '1', 'PayPal', 140.00, 7.00, 14.00, 14351.70, 14484.70, 'online', '$', 'left', '2024-08-24 22:09:19', '2024-08-24 22:09:19'),
(169, '1724559034', '87', 1, 23, 23, '1', 'PayPal', 1000.00, 50.00, 100.00, 14484.70, 15434.70, 'online', '$', 'left', '2024-08-24 22:10:34', '2024-08-24 22:10:34'),
(170, '1724559681', '88', 1, 23, 23, '1', 'PayPal', 200.00, 10.00, 20.00, 15434.70, 15624.70, 'online', '$', 'left', '2024-08-24 22:21:21', '2024-08-24 22:21:21'),
(171, '1724559830', '89', 1, 23, 23, '1', 'PayPal', 200.00, 10.00, 20.00, 15624.70, 15814.70, 'online', '$', 'left', '2024-08-24 22:23:50', '2024-08-24 22:23:50'),
(172, '1724559938', '90', 1, 23, 23, '1', 'PayPal', 100.00, 5.00, 10.00, 15814.70, 15909.70, 'online', '$', 'left', '2024-08-24 22:25:38', '2024-08-24 22:25:38'),
(173, '1724560158', '91', 1, 23, 23, '1', 'PayPal', 500.00, 25.00, 50.00, 15909.70, 16384.70, 'online', '$', 'left', '2024-08-24 22:29:18', '2024-08-24 22:29:18'),
(174, '1724560544', '92', 1, 23, 23, '1', 'PayPal', 300.00, 15.00, 30.00, 16384.70, 16669.70, 'online', '$', 'left', '2024-08-24 22:35:44', '2024-08-24 22:35:44'),
(175, '1724560584', '93', 1, 23, 23, '1', 'PayPal', 300.00, 15.00, 30.00, 16669.70, 16954.70, 'online', '$', 'left', '2024-08-24 22:36:24', '2024-08-24 22:36:24'),
(176, '1724561018', '94', 1, 23, 23, '1', 'PayPal', 110.00, 5.50, 11.00, 16954.70, 17059.20, 'online', '$', 'left', '2024-08-24 22:43:38', '2024-08-24 22:43:38'),
(177, '1724561052', '95', 1, 23, 23, '1', 'PayPal', 110.00, 5.50, 11.00, 17059.20, 17163.70, 'online', '$', 'left', '2024-08-24 22:44:12', '2024-08-24 22:44:12'),
(178, '1724561177', '96', 1, 23, 23, '1', 'PayPal', 400.00, 20.00, 40.00, 17163.70, 17543.70, 'online', '$', 'left', '2024-08-24 22:46:17', '2024-08-24 22:46:17'),
(179, '1724561361', '97', 1, 23, 23, '1', 'PayPal', 600.00, 30.00, 60.00, 17543.70, 18113.70, 'online', '$', 'left', '2024-08-24 22:49:21', '2024-08-24 22:49:21'),
(180, '1724561377', '98', 1, 23, 23, '1', 'PayPal', 600.00, 30.00, 60.00, 18113.70, 18683.70, 'online', '$', 'left', '2024-08-24 22:49:37', '2024-08-24 22:49:37'),
(181, '1724561505', '99', 1, 23, 23, '1', 'PayPal', 600.00, 30.00, 60.00, 18683.70, 19253.70, 'online', '$', 'left', '2024-08-24 22:51:45', '2024-08-24 22:51:45'),
(182, '1724562063', '105', 1, 23, 23, '1', 'PayPal', 600.00, 30.00, 60.00, 19253.70, 19823.70, 'online', '$', 'left', '2024-08-24 23:01:03', '2024-08-24 23:01:03'),
(183, '1724562444', '106', 1, 23, 23, '1', 'PayPal', 500.00, 25.00, 50.00, 19823.70, 20298.70, 'online', '$', 'left', '2024-08-24 23:07:24', '2024-08-24 23:07:24'),
(184, '1724731840', '14', 1, NULL, 23, '1', 'PayPal', 100.00, 5.00, 10.00, 20298.70, 20393.70, 'offline', '$', 'left', '2024-08-26 22:10:40', '2024-08-26 22:10:40'),
(185, '1724732024', '13', 1, 23, 24, '1', 'PayPal', 50.00, 2.50, 5.00, 95.00, 142.50, 'offline', '$', 'left', '2024-08-26 22:13:44', '2024-08-26 22:13:44'),
(186, '1724732198', '4', 1, 23, 23, '1', 'PayPal', 40.00, 2.00, 4.00, 20393.70, 20431.70, 'offline', '$', 'left', '2024-08-26 22:16:38', '2024-08-26 22:16:38'),
(187, '1724732204', '3', 1, 23, NULL, '1', 'PayPal', 112.00, 5.60, 11.20, 0.00, NULL, 'offline', '$', 'left', '2024-08-26 22:16:44', '2024-08-26 22:16:44'),
(188, '1724732212', '2', 1, 23, 23, '1', 'PayPal', 95.00, 4.75, 9.50, 20431.70, 20521.95, 'offline', '$', 'left', '2024-08-26 22:16:52', '2024-08-26 22:16:52'),
(189, '1724732221', '1', 1, 23, 25, '1', 'PayPal', 160.00, 8.00, 16.00, 228.00, 380.00, 'offline', '$', 'left', '2024-08-26 22:17:01', '2024-08-26 22:17:01'),
(190, '1724733114', '15', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 20521.90, 20759.40, 'offline', '$', 'left', '2024-08-26 22:31:54', '2024-08-26 22:31:54'),
(191, '1724733296', '16', 1, 23, 23, '1', 'Citibank', 680.00, 34.00, 68.00, 20759.40, 21405.40, 'offline', '$', 'left', '2024-08-26 22:34:56', '2024-08-26 22:34:56'),
(192, '1724733839', '19', 1, 23, 24, '1', 'Bank of America', 300.00, 15.00, 30.00, 142.50, 427.50, 'offline', '$', 'left', '2024-08-26 22:43:59', '2024-08-26 22:43:59'),
(193, '1724733949', '20', 1, 23, NULL, '1', 'Paypal', 308.30, 15.42, 30.83, 0.00, NULL, 'offline', '$', 'left', '2024-08-26 22:45:49', '2024-08-26 22:45:49'),
(194, '1724734098', '21', 1, 23, 23, '1', 'Paypal', 40.00, 2.00, 4.00, 21405.40, 21443.40, 'offline', '$', 'left', '2024-08-26 22:48:18', '2024-08-26 22:48:18'),
(195, '1724737684', '21', 1, 23, 23, '1', 'Paypal', 40.00, 2.00, 4.00, 21443.40, 21481.40, 'offline', '$', 'left', '2024-08-26 23:48:04', '2024-08-26 23:48:04'),
(196, '1724737812', '21', 1, 23, 23, '1', 'Paypal', 40.00, 2.00, 4.00, 21481.40, 21519.40, 'offline', '$', 'left', '2024-08-26 23:50:12', '2024-08-26 23:50:12'),
(197, '1724740461', '22', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 21519.40, 21756.90, 'offline', '$', 'left', '2024-08-27 00:34:21', '2024-08-27 00:34:21'),
(198, '1724740544', '22', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 21756.90, 21994.40, 'offline', '$', 'left', '2024-08-27 00:35:44', '2024-08-27 00:35:44'),
(199, '1724740625', '22', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 21994.40, 22231.90, 'offline', '$', 'left', '2024-08-27 00:37:05', '2024-08-27 00:37:05'),
(200, '1724746391', '23', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 22231.90, 22469.40, 'offline', '$', 'left', '2024-08-27 02:13:11', '2024-08-27 02:13:11'),
(201, '1724746470', '24', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 22469.40, 22706.90, 'offline', '$', 'left', '2024-08-27 02:14:30', '2024-08-27 02:14:30'),
(202, '1724746612', '25', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 22706.90, 22944.40, 'offline', '$', 'left', '2024-08-27 02:16:52', '2024-08-27 02:16:52'),
(203, '1724746707', '26', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 22944.40, 23181.90, 'offline', '$', 'left', '2024-08-27 02:18:27', '2024-08-27 02:18:27'),
(204, '1724746893', '27', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 23181.90, 23419.40, 'offline', '$', 'left', '2024-08-27 02:21:33', '2024-08-27 02:21:33'),
(205, '1724746974', '27', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 23419.40, 23656.90, 'offline', '$', 'left', '2024-08-27 02:22:54', '2024-08-27 02:22:54'),
(206, '1724747561', '28', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 23656.90, 23894.40, 'offline', '$', 'left', '2024-08-27 02:32:41', '2024-08-27 02:32:41'),
(207, '1724748611', '29', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 23894.40, 24131.90, 'offline', '$', 'left', '2024-08-27 02:50:11', '2024-08-27 02:50:11'),
(208, '1724748833', '30', 1, 23, 24, '1', 'Citibank', 200.00, 10.00, 20.00, 427.50, 617.50, 'offline', '$', 'left', '2024-08-27 02:53:53', '2024-08-27 02:53:53'),
(209, '1724832750', '31', 1, 23, 23, '1', 'Citibank', 350.00, 17.50, 35.00, 24131.90, 24464.40, 'offline', '$', 'left', '2024-08-28 02:12:30', '2024-08-28 02:12:30'),
(210, '1724904082', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 24464.40, 24701.90, 'offline', '$', 'left', '2024-08-28 22:01:22', '2024-08-28 22:01:22'),
(211, '1724904206', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 24701.90, 24939.40, 'offline', '$', 'left', '2024-08-28 22:03:26', '2024-08-28 22:03:26'),
(212, '1724904487', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 24939.40, 25176.90, 'offline', '$', 'left', '2024-08-28 22:08:07', '2024-08-28 22:08:07'),
(213, '1724904607', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 25176.90, 25414.40, 'offline', '$', 'left', '2024-08-28 22:10:07', '2024-08-28 22:10:07'),
(214, '1724904710', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 25414.40, 25651.90, 'offline', '$', 'left', '2024-08-28 22:11:50', '2024-08-28 22:11:50'),
(215, '1724904887', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 25651.90, 25889.40, 'offline', '$', 'left', '2024-08-28 22:14:47', '2024-08-28 22:14:47'),
(216, '1724905372', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 25889.40, 26126.90, 'offline', '$', 'left', '2024-08-28 22:22:52', '2024-08-28 22:22:52'),
(217, '1724905446', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 26126.90, 26364.40, 'offline', '$', 'left', '2024-08-28 22:24:06', '2024-08-28 22:24:06'),
(218, '1724905498', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 26364.40, 26601.90, 'offline', '$', 'left', '2024-08-28 22:24:58', '2024-08-28 22:24:58'),
(219, '1724905610', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 26601.90, 26839.40, 'offline', '$', 'left', '2024-08-28 22:26:50', '2024-08-28 22:26:50'),
(220, '1724905664', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 26839.40, 27076.90, 'offline', '$', 'left', '2024-08-28 22:27:44', '2024-08-28 22:27:44'),
(221, '1724905870', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 27076.90, 27314.40, 'offline', '$', 'left', '2024-08-28 22:31:10', '2024-08-28 22:31:10'),
(222, '1724905935', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 27314.40, 27551.90, 'offline', '$', 'left', '2024-08-28 22:32:15', '2024-08-28 22:32:15'),
(223, '1724906227', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 27551.90, 27789.40, 'offline', '$', 'left', '2024-08-28 22:37:07', '2024-08-28 22:37:07'),
(224, '1724906270', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 617.50, 665.00, 'offline', '$', 'left', '2024-08-28 22:37:50', '2024-08-28 22:37:50'),
(225, '1724906329', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 27789.40, 28026.90, 'offline', '$', 'left', '2024-08-28 22:38:49', '2024-08-28 22:38:49'),
(226, '1724906413', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 28026.90, 28264.40, 'offline', '$', 'left', '2024-08-28 22:40:13', '2024-08-28 22:40:13'),
(227, '1724906554', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 28264.40, 28501.90, 'offline', '$', 'left', '2024-08-28 22:42:34', '2024-08-28 22:42:34'),
(228, '1724906628', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 28501.90, 28739.40, 'offline', '$', 'left', '2024-08-28 22:43:48', '2024-08-28 22:43:48'),
(229, '1724907093', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 28739.40, 28976.90, 'offline', '$', 'left', '2024-08-28 22:51:33', '2024-08-28 22:51:33'),
(230, '1724907102', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 665.00, 712.50, 'offline', '$', 'left', '2024-08-28 22:51:42', '2024-08-28 22:51:42'),
(231, '1724907261', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 712.50, 760.00, 'offline', '$', 'left', '2024-08-28 22:54:21', '2024-08-28 22:54:21'),
(232, '1724907270', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 28976.90, 29214.40, 'offline', '$', 'left', '2024-08-28 22:54:30', '2024-08-28 22:54:30'),
(233, '1724907471', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 760.00, 807.50, 'offline', '$', 'left', '2024-08-28 22:57:51', '2024-08-28 22:57:51'),
(234, '1724907487', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 29214.40, 29451.90, 'offline', '$', 'left', '2024-08-28 22:58:07', '2024-08-28 22:58:07'),
(235, '1724907650', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 807.50, 855.00, 'offline', '$', 'left', '2024-08-28 23:00:50', '2024-08-28 23:00:50'),
(236, '1724908128', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 29451.90, 29689.40, 'offline', '$', 'left', '2024-08-28 23:08:48', '2024-08-28 23:08:48'),
(237, '1724908141', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 855.00, 902.50, 'offline', '$', 'left', '2024-08-28 23:09:01', '2024-08-28 23:09:01'),
(238, '1724908221', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 29689.40, 29926.90, 'offline', '$', 'left', '2024-08-28 23:10:21', '2024-08-28 23:10:21'),
(239, '1724908243', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 902.50, 950.00, 'offline', '$', 'left', '2024-08-28 23:10:43', '2024-08-28 23:10:43'),
(240, '1724908802', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 29926.90, 30164.40, 'offline', '$', 'left', '2024-08-28 23:20:02', '2024-08-28 23:20:02'),
(241, '1724909168', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 30164.40, 30401.90, 'offline', '$', 'left', '2024-08-28 23:26:08', '2024-08-28 23:26:08'),
(242, '1724909326', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 30401.90, 30639.40, 'offline', '$', 'left', '2024-08-28 23:28:46', '2024-08-28 23:28:46'),
(243, '1724909366', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 30639.40, 30876.90, 'offline', '$', 'left', '2024-08-28 23:29:26', '2024-08-28 23:29:26'),
(244, '1724909430', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 30876.90, 31114.40, 'offline', '$', 'left', '2024-08-28 23:30:30', '2024-08-28 23:30:30'),
(245, '1724909552', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 31114.40, 31351.90, 'offline', '$', 'left', '2024-08-28 23:32:32', '2024-08-28 23:32:32'),
(246, '1724909596', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 31351.90, 31589.40, 'offline', '$', 'left', '2024-08-28 23:33:16', '2024-08-28 23:33:16'),
(247, '1724909754', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 31589.40, 31826.90, 'offline', '$', 'left', '2024-08-28 23:35:54', '2024-08-28 23:35:54'),
(248, '1724909827', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 31826.90, 32064.40, 'offline', '$', 'left', '2024-08-28 23:37:07', '2024-08-28 23:37:07'),
(249, '1724910568', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 32064.40, 32301.90, 'offline', '$', 'left', '2024-08-28 23:49:28', '2024-08-28 23:49:28'),
(250, '1724910632', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 950.00, 997.50, 'offline', '$', 'left', '2024-08-28 23:50:32', '2024-08-28 23:50:32'),
(251, '1724910647', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 32301.90, 32539.40, 'offline', '$', 'left', '2024-08-28 23:50:47', '2024-08-28 23:50:47'),
(252, '1724910983', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 32539.40, 32776.90, 'offline', '$', 'left', '2024-08-28 23:56:23', '2024-08-28 23:56:23'),
(253, '1724910999', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 997.50, 1045.00, 'offline', '$', 'left', '2024-08-28 23:56:39', '2024-08-28 23:56:39'),
(254, '1724913846', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1045.00, 1092.50, 'offline', '$', 'left', '2024-08-29 00:44:06', '2024-08-29 00:44:06'),
(255, '1724913863', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 32776.90, 33014.40, 'offline', '$', 'left', '2024-08-29 00:44:23', '2024-08-29 00:44:23'),
(256, '1724915431', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 33014.40, 33251.90, 'offline', '$', 'left', '2024-08-29 01:10:31', '2024-08-29 01:10:31'),
(257, '1724915493', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 33251.90, 33489.40, 'offline', '$', 'left', '2024-08-29 01:11:33', '2024-08-29 01:11:33'),
(258, '1724919147', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 33489.40, 33726.90, 'offline', '$', 'left', '2024-08-29 02:12:27', '2024-08-29 02:12:27'),
(259, '1724919285', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 33726.90, 33964.40, 'offline', '$', 'left', '2024-08-29 02:14:45', '2024-08-29 02:14:45'),
(260, '1724919383', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 33964.40, 34201.90, 'offline', '$', 'left', '2024-08-29 02:16:23', '2024-08-29 02:16:23'),
(261, '1724919439', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 34201.90, 34439.40, 'offline', '$', 'left', '2024-08-29 02:17:19', '2024-08-29 02:17:19'),
(262, '1724920918', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 34439.40, 34676.90, 'offline', '$', 'left', '2024-08-29 02:41:58', '2024-08-29 02:41:58'),
(263, '1724921141', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 34676.90, 34914.40, 'offline', '$', 'left', '2024-08-29 02:45:41', '2024-08-29 02:45:41'),
(264, '1724925407', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 34914.40, 35151.90, 'offline', '$', 'left', '2024-08-29 03:56:47', '2024-08-29 03:56:47'),
(265, '1724925427', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1092.50, 1140.00, 'offline', '$', 'left', '2024-08-29 03:57:07', '2024-08-29 03:57:07'),
(266, '1724925580', '34', 1, 23, 24, '1', 'PayPal', 300.00, 15.00, 30.00, 1140.00, 1425.00, 'online', '$', 'left', '2024-08-29 03:59:40', '2024-08-29 03:59:40'),
(267, '1724925644', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 35151.90, 35389.40, 'offline', '$', 'left', '2024-08-29 04:00:44', '2024-08-29 04:00:44'),
(268, '1724925757', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 35389.40, 35626.90, 'offline', '$', 'left', '2024-08-29 04:02:37', '2024-08-29 04:02:37'),
(269, '1724926007', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 35626.90, 35864.40, 'offline', '$', 'left', '2024-08-29 04:06:47', '2024-08-29 04:06:47'),
(270, '1725071185', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 35864.40, 36101.90, 'offline', '$', 'left', '2024-08-30 20:26:25', '2024-08-30 20:26:25'),
(271, '1725071419', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 36101.90, 36339.40, 'offline', '$', 'left', '2024-08-30 20:30:19', '2024-08-30 20:30:19'),
(272, '1725071577', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1425.00, 1472.50, 'offline', '$', 'left', '2024-08-30 20:32:57', '2024-08-30 20:32:57'),
(273, '1725071779', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1472.50, 1520.00, 'offline', '$', 'left', '2024-08-30 20:36:19', '2024-08-30 20:36:19'),
(274, '1725071853', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1520.00, 1567.50, 'offline', '$', 'left', '2024-08-30 20:37:33', '2024-08-30 20:37:33'),
(275, '1725071956', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1567.50, 1615.00, 'offline', '$', 'left', '2024-08-30 20:39:16', '2024-08-30 20:39:16'),
(276, '1725072038', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1615.00, 1662.50, 'offline', '$', 'left', '2024-08-30 20:40:38', '2024-08-30 20:40:38'),
(277, '1725072098', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1662.50, 1710.00, 'offline', '$', 'left', '2024-08-31 02:41:38', '2024-08-31 02:41:38'),
(278, '1725072564', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1710.00, 1757.50, 'offline', '$', 'left', '2024-08-31 02:49:24', '2024-08-31 02:49:24'),
(279, '1725072745', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1757.50, 1805.00, 'offline', '$', 'left', '2024-08-31 02:52:25', '2024-08-31 02:52:25'),
(280, '1725072832', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1805.00, 1852.50, 'offline', '$', 'left', '2024-08-31 02:53:52', '2024-08-31 02:53:52'),
(281, '1725072880', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1852.50, 1900.00, 'offline', '$', 'left', '2024-08-31 02:54:40', '2024-08-31 02:54:40'),
(282, '1725080492', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 36339.40, 36576.90, 'offline', '$', 'left', '2024-08-31 05:01:32', '2024-08-31 05:01:32'),
(283, '1725080518', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1900.00, 1947.50, 'offline', '$', 'left', '2024-08-31 05:01:58', '2024-08-31 05:01:58'),
(284, '1725080722', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 36576.90, 36814.40, 'offline', '$', 'left', '2024-08-31 05:05:22', '2024-08-31 05:05:22'),
(285, '1725080827', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 36814.40, 37051.90, 'offline', '$', 'left', '2024-08-31 05:07:07', '2024-08-31 05:07:07'),
(286, '1725081135', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 37051.90, 37289.40, 'offline', '$', 'left', '2024-08-31 05:12:15', '2024-08-31 05:12:15'),
(287, '1725081366', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 37289.40, 37526.90, 'offline', '$', 'left', '2024-08-31 05:16:06', '2024-08-31 05:16:06'),
(288, '1725081704', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 37526.90, 37764.40, 'offline', '$', 'left', '2024-08-31 05:21:44', '2024-08-31 05:21:44'),
(289, '1725082207', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 37764.40, 38001.90, 'offline', '$', 'left', '2024-08-31 05:30:07', '2024-08-31 05:30:07'),
(290, '1725082689', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1947.50, 1995.00, 'offline', '$', 'left', '2024-08-31 05:38:09', '2024-08-31 05:38:09'),
(291, '1725082793', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 1995.00, 2042.50, 'offline', '$', 'left', '2024-08-31 05:39:53', '2024-08-31 05:39:53'),
(292, '1725082825', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 38001.90, 38239.40, 'offline', '$', 'left', '2024-08-31 05:40:25', '2024-08-31 05:40:25'),
(293, '1725083491', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 38239.40, 38476.90, 'offline', '$', 'left', '2024-08-31 05:51:31', '2024-08-31 05:51:31'),
(294, '1725083593', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 38476.90, 38714.40, 'offline', '$', 'left', '2024-08-31 05:53:13', '2024-08-31 05:53:13'),
(295, '1725084444', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 38714.40, 38951.90, 'offline', '$', 'left', '2024-08-31 06:07:24', '2024-08-31 06:07:24'),
(296, '1725084914', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 38951.90, 39189.40, 'offline', '$', 'left', '2024-08-31 06:15:14', '2024-08-31 06:15:14'),
(297, '1725085039', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 39189.40, 39426.90, 'offline', '$', 'left', '2024-08-31 06:17:19', '2024-08-31 06:17:19'),
(298, '1725086168', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 39426.90, 39664.40, 'offline', '$', 'left', '2024-08-31 06:36:08', '2024-08-31 06:36:08'),
(299, '1725086184', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 2042.50, 2090.00, 'offline', '$', 'left', '2024-08-31 06:36:24', '2024-08-31 06:36:24'),
(300, '1725086252', '33', 1, 23, 24, '1', 'Citibank', 50.00, 2.50, 5.00, 2090.00, 2137.50, 'offline', '$', 'left', '2024-08-31 06:37:32', '2024-08-31 06:37:32'),
(301, '1725086277', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 39664.40, 39901.90, 'offline', '$', 'left', '2024-08-31 06:37:57', '2024-08-31 06:37:57'),
(302, '1725086687', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 39901.90, 40139.40, 'offline', '$', 'left', '2024-08-31 06:44:47', '2024-08-31 06:44:47'),
(303, '1725086935', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 40139.40, 40376.90, 'offline', '$', 'left', '2024-08-31 06:48:55', '2024-08-31 06:48:55'),
(304, '1725087261', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 40376.90, 40614.40, 'offline', '$', 'left', '2024-08-31 06:54:21', '2024-08-31 06:54:21'),
(305, '1725087390', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 40614.40, 40851.90, 'offline', '$', 'left', '2024-08-31 06:56:30', '2024-08-31 06:56:30'),
(306, '1725087557', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 40851.90, 41089.40, 'offline', '$', 'left', '2024-08-31 06:59:17', '2024-08-31 06:59:17'),
(307, '1725090819', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 41089.40, 41326.90, 'offline', '$', 'left', '2024-08-31 07:53:39', '2024-08-31 07:53:39'),
(308, '1725090958', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 41326.90, 41564.40, 'offline', '$', 'left', '2024-08-31 07:55:58', '2024-08-31 07:55:58'),
(309, '1725162632', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 41564.40, 41801.90, 'offline', '$', 'left', '2024-09-01 03:50:32', '2024-09-01 03:50:32');
INSERT INTO `transactions` (`id`, `transcation_id`, `booking_id`, `transcation_type`, `customer_id`, `organizer_id`, `payment_status`, `payment_method`, `grand_total`, `commission`, `tax`, `pre_balance`, `after_balance`, `gateway_type`, `currency_symbol`, `currency_symbol_position`, `created_at`, `updated_at`) VALUES
(310, '1725162681', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 41801.90, 42039.40, 'offline', '$', 'left', '2024-09-01 03:51:21', '2024-09-01 03:51:21'),
(311, '1725162753', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 42039.40, 42276.90, 'offline', '$', 'left', '2024-09-01 03:52:33', '2024-09-01 03:52:33'),
(312, '1725162827', '32', 1, 23, 23, '1', 'Citibank', 250.00, 12.50, 25.00, 42276.90, 42514.40, 'offline', '$', 'left', '2024-09-01 03:53:47', '2024-09-01 03:53:47'),
(313, '1725335129', '1', 1, 23, 25, '1', 'PayPal', 180.00, 9.00, 18.00, 380.00, 551.00, 'online', '$', 'left', '2024-09-03 03:45:29', '2024-09-03 03:45:29'),
(314, '1725335463', '2', 1, 23, 23, '1', 'PayPal', 200.00, 10.00, 20.00, 42514.40, 42704.40, 'online', '$', 'left', '2024-09-03 03:51:03', '2024-09-03 03:51:03'),
(315, '1725335542', '3', 1, 23, NULL, '1', 'PayPal', 112.00, 5.60, 11.20, 0.00, NULL, 'online', '$', 'left', '2024-09-03 03:52:22', '2024-09-03 03:52:22'),
(316, '1725335565', '4', 1, 23, 23, '1', 'PayPal', 40.00, 2.00, 4.00, 42704.40, 42742.40, 'online', '$', 'left', '2024-09-03 03:52:45', '2024-09-03 03:52:45'),
(317, '1725335767', '8', 1, 23, NULL, '1', 'PayPal', 237.20, 11.86, 23.72, 0.00, NULL, 'online', '$', 'left', '2024-09-03 03:56:07', '2024-09-03 03:56:07'),
(318, '1725335880', '10', 1, 23, 23, '1', 'PayPal', 500.00, 25.00, 50.00, 42742.40, 43217.40, 'online', '$', 'left', '2024-09-03 03:58:00', '2024-09-03 03:58:00'),
(319, '1725335987', '13', 1, 23, 24, '1', 'PayPal', 50.00, 2.50, 5.00, 2137.50, 2185.00, 'online', '$', 'left', '2024-09-03 03:59:47', '2024-09-03 03:59:47'),
(320, '1725336046', '9', 1, 23, 24, '1', 'Bank of America', 100.00, 5.00, 10.00, 2185.00, 2280.00, 'offline', '$', 'left', '2024-09-03 04:00:46', '2024-09-03 04:00:46'),
(321, '1725336062', '7', 1, 23, 25, '1', 'Citibank', 40.00, 2.00, 4.00, 551.00, 589.00, 'offline', '$', 'left', '2024-09-03 04:01:02', '2024-09-03 04:01:02'),
(322, '1729659721', '14', 1, NULL, 24, '1', 'PayPal', 200.00, 10.00, 20.00, 2280.00, 2470.00, 'online', '$', 'left', '2024-10-22 23:02:01', '2024-10-22 23:02:01'),
(323, '1729659883', '15', 1, NULL, 24, '1', 'Citibank', 100.00, 5.00, 10.00, 2470.00, 2565.00, 'offline', '$', 'left', '2024-10-22 23:04:43', '2024-10-22 23:04:43'),
(324, '1740646302', '21', 1, NULL, 24, '1', 'PayPal', 1000.00, 50.00, 100.00, 2565.00, 3515.00, 'online', '$', 'left', '2025-02-27 02:51:42', '2025-02-27 02:51:42'),
(325, '1740646784', '22', 1, NULL, 24, '1', 'PayPal', 16300.00, 815.00, 1630.00, 3515.00, 19000.00, 'online', '$', 'left', '2025-02-27 02:59:44', '2025-02-27 02:59:44'),
(326, '1740647065', '23', 1, NULL, 24, '1', 'PayPal', 200.00, 10.00, 20.00, 19000.00, 19190.00, 'online', '$', 'left', '2025-02-27 03:04:25', '2025-02-27 03:04:25'),
(327, '1740647155', '24', 1, NULL, 24, '1', 'PayPal', 500.00, 25.00, 50.00, 19190.00, 19665.00, 'online', '$', 'left', '2025-02-27 03:05:55', '2025-02-27 03:05:55'),
(328, '1740647256', '25', 1, NULL, 24, '1', 'PayPal', 300.00, 15.00, 30.00, 19665.00, 19950.00, 'online', '$', 'left', '2025-02-27 03:07:36', '2025-02-27 03:07:36'),
(329, '1740647469', '26', 1, NULL, 24, '1', 'PayPal', 200.00, 10.00, 20.00, 19950.00, 20140.00, 'online', '$', 'left', '2025-02-27 03:11:09', '2025-02-27 03:11:09'),
(330, '1740647597', '27', 1, NULL, 24, '1', 'PayPal', 600.00, 30.00, 60.00, 20140.00, 20710.00, 'online', '$', 'left', '2025-02-27 03:13:17', '2025-02-27 03:13:17'),
(331, '1740648007', '28', 1, NULL, 24, '1', 'PayPal', 300.00, 15.00, 30.00, 20710.00, 20995.00, 'online', '$', 'left', '2025-02-27 03:20:07', '2025-02-27 03:20:07'),
(332, '1740648158', '29', 1, NULL, 24, '1', 'PayPal', 400.00, 20.00, 40.00, 20995.00, 21375.00, 'online', '$', 'left', '2025-02-27 03:22:38', '2025-02-27 03:22:38'),
(333, '1740648359', '30', 1, NULL, 24, '1', 'PayPal', 500.00, 25.00, 50.00, 21375.00, 21850.00, 'online', '$', 'left', '2025-02-27 03:25:59', '2025-02-27 03:25:59'),
(334, '1740649586', '31', 1, 23, 24, '1', 'PayPal', 500.00, 25.00, 50.00, 21850.00, 22325.00, 'online', '$', 'left', '2025-02-27 03:46:26', '2025-02-27 03:46:26'),
(335, '1740798693', '32', 1, 23, 24, '1', 'PayPal', 300.00, 15.00, 30.00, 22325.00, 22610.00, 'online', '$', 'left', '2025-02-28 21:11:33', '2025-02-28 21:11:33'),
(336, '1740799225', '33', 1, 23, 24, '1', 'PayPal', 200.00, 10.00, 20.00, 22610.00, 22800.00, 'online', '$', 'left', '2025-02-28 21:20:25', '2025-02-28 21:20:25'),
(337, '1740799459', '34', 1, 23, 24, '1', 'PayPal', 20500.00, 1025.00, 2050.00, 22800.00, 42275.00, 'online', '$', 'left', '2025-02-28 21:24:19', '2025-02-28 21:24:19'),
(338, '1740800021', '35', 1, 23, 24, '1', 'PayPal', 20600.00, 1030.00, 2060.00, 42275.00, 61845.00, 'online', '$', 'left', '2025-02-28 21:33:41', '2025-02-28 21:33:41'),
(339, '1740800695', '36', 1, 23, 24, '1', 'PayPal', 200.00, 10.00, 20.00, 61845.00, 62035.00, 'online', '$', 'left', '2025-02-28 21:44:55', '2025-02-28 21:44:55'),
(340, '1740800899', '37', 1, 23, 24, '1', 'PayPal', 20200.00, 1010.00, 2020.00, 62035.00, 81225.00, 'online', '$', 'left', '2025-02-28 21:48:19', '2025-02-28 21:48:19'),
(341, '1740801281', '38', 1, 23, 24, '1', 'PayPal', 20500.00, 1025.00, 2050.00, 81225.00, 100700.00, 'online', '$', 'left', '2025-02-28 21:54:41', '2025-02-28 21:54:41'),
(342, '1740801688', '39', 1, 23, 24, '1', 'PayPal', 20600.00, 1030.00, 2060.00, 100700.00, 120270.00, 'online', '$', 'left', '2025-02-28 22:01:28', '2025-02-28 22:01:28'),
(343, '1740802105', '40', 1, 23, 24, '1', 'PayPal', 300.00, 15.00, 30.00, 120270.00, 120555.00, 'online', '$', 'left', '2025-02-28 22:08:25', '2025-02-28 22:08:25'),
(344, '1740803112', '41', 1, 23, 24, '1', 'PayPal', 20800.00, 1040.00, 2080.00, 120555.00, 140315.00, 'online', '$', 'left', '2025-02-28 22:25:12', '2025-02-28 22:25:12'),
(345, '1740804412', '42', 1, 23, 24, '1', 'Citibank', 300.00, 15.00, 30.00, 140315.00, 140600.00, 'offline', '$', 'left', '2025-02-28 22:46:52', '2025-02-28 22:46:52'),
(346, '1740804702', '43', 1, 23, 24, '1', 'Citibank', 20300.00, 1015.00, 2030.00, 140600.00, 159885.00, 'offline', '$', 'left', '2025-02-28 22:51:42', '2025-02-28 22:51:42'),
(347, '1740972843', '45', 1, 23, 24, '1', 'PayPal', 150.00, 7.50, 15.00, 159885.00, 160027.50, 'online', '$', 'left', '2025-03-02 21:34:03', '2025-03-02 21:34:03'),
(348, '1740973483', '46', 1, 23, 24, '1', 'Citibank', 100.00, 5.00, 10.00, 160028.00, 160123.00, 'offline', '$', 'left', '2025-03-02 21:44:43', '2025-03-02 21:44:43'),
(349, '1740976425', '47', 1, 23, 23, '1', 'PayPal', 420.00, 21.00, 42.00, 43217.40, 43616.40, 'online', '$', 'left', '2025-03-02 22:33:45', '2025-03-02 22:33:45'),
(350, '1740976986', '49', 1, 23, 24, '1', 'PayPal', 462.00, 23.10, 46.20, 160123.00, 160561.91, 'online', '$', 'left', '2025-03-02 22:43:06', '2025-03-02 22:43:06'),
(351, '1740977180', '50', 1, 23, 24, '1', 'PayPal', 264.00, 13.20, 26.40, 160562.00, 160812.80, 'online', '$', 'left', '2025-03-02 22:46:20', '2025-03-02 22:46:20'),
(352, '1740978229', '51', 1, 23, 24, '1', 'PayPal', 264.00, 13.20, 26.40, 160813.00, 161063.80, 'online', '$', 'left', '2025-03-02 23:03:49', '2025-03-02 23:03:49'),
(353, '1740979227', '52', 1, 23, 24, '1', 'PayPal', 330.00, 16.50, 33.00, 161064.00, 161377.50, 'online', '$', 'left', '2025-03-02 23:20:27', '2025-03-02 23:20:27'),
(354, '1741057427', '53', 1, NULL, 24, '1', 'PayPal', 462.00, 23.10, 46.20, 161378.00, 161816.91, 'online', '$', 'left', '2025-03-03 21:03:47', '2025-03-03 21:03:47'),
(355, '1741403208', '54', 1, NULL, 24, '1', 'PayPal', 198.00, 9.90, 19.80, 161817.00, 162005.09, 'online', '$', 'left', '2025-03-07 21:06:48', '2025-03-07 21:06:48'),
(356, '1741403284', '55', 1, NULL, 24, '1', 'PayPal', 132.00, 6.60, 13.20, 162005.00, 162130.41, 'online', '$', 'left', '2025-03-07 21:08:04', '2025-03-07 21:08:04'),
(357, '1741404931', '56', 1, NULL, 24, '1', 'Citibank', 132.00, 6.60, 13.20, 162130.00, 162255.41, 'offline', '$', 'left', '2025-03-07 21:35:31', '2025-03-07 21:35:31'),
(358, '1759733725', '91', 1, NULL, 23, '1', 'PayPal', 10.00, 0.50, 1.00, 43616.40, 43625.90, 'online', '$', 'left', '2025-10-06 02:55:25', '2025-10-06 02:55:25'),
(359, '1759735005', '92', 1, NULL, 23, '1', 'Citibank', 20.00, 1.00, 2.00, 43625.90, 43644.90, 'offline', '$', 'left', '2025-10-06 03:16:45', '2025-10-06 03:16:45'),
(360, '1759735589', '93', 1, NULL, 23, '1', 'Bank of America', 20.00, 1.00, 2.00, 43644.90, 43663.90, 'offline', '$', 'left', '2025-10-06 03:26:29', '2025-10-06 03:26:29'),
(361, '1759741398', '96', 1, NULL, 23, '1', 'PayPal', 10.00, 0.50, 1.00, 43663.90, 43673.40, 'online', '$', 'left', '2025-10-06 05:03:18', '2025-10-06 05:03:18'),
(362, '1759741617', '95', 1, NULL, 23, '1', 'Citibank', 10.00, 0.50, 1.00, 43673.40, 43682.90, 'offline', '$', 'left', '2025-10-06 05:06:57', '2025-10-06 05:06:57'),
(363, '1759742388', '97', 1, NULL, 23, '1', 'Citibank', 30.00, 1.50, 3.00, 43682.90, 43711.40, 'offline', '$', 'left', '2025-10-06 05:19:48', '2025-10-06 05:19:48'),
(364, '1759745845', '4', 3, NULL, 23, '1', '4', 70.00, 0.00, 0.00, 43711.40, 43641.40, NULL, '$', 'right', '2025-10-06 06:17:25', '2025-10-06 06:20:42'),
(365, '1759746063', '5', 3, NULL, 23, '0', '5', 100.00, 0.00, 0.00, 43641.40, 43541.40, NULL, '$', 'right', '2025-10-06 06:21:03', '2025-10-06 06:21:03'),
(366, '1759746128', '6', 3, NULL, 23, '2', '5', 100.00, 0.00, 0.00, 43541.40, 43441.40, NULL, '$', 'right', '2025-10-06 06:22:08', '2025-10-06 06:22:59'),
(367, '1759746203', '7', 3, NULL, 23, '0', '4', 100.00, 0.00, 0.00, 43541.40, 43441.40, NULL, '$', 'right', '2025-10-06 06:23:23', '2025-10-06 06:23:23'),
(368, '1759747452', '8', 3, NULL, 23, '2', '5', 100.00, 0.00, 0.00, 43441.40, 43341.40, NULL, '$', 'right', '2025-10-06 06:44:12', '2025-10-07 05:06:47'),
(369, '1759747482', '9', 3, NULL, 23, '0', '5', 70.00, 0.00, 0.00, 43341.40, 43271.40, NULL, '$', 'right', '2025-10-06 06:44:42', '2025-10-06 06:44:42'),
(370, '1759827198', '10', 3, NULL, 23, '2', '5', 10.00, 0.00, 0.00, 43271.40, 43261.40, NULL, '$', 'right', '2025-10-07 04:53:18', '2025-10-07 04:54:52'),
(371, '1759827563', '11', 3, NULL, 23, '0', '5', 100.00, 0.00, 0.00, 43271.40, 43171.40, NULL, '$', 'right', '2025-10-07 04:59:23', '2025-10-07 04:59:23'),
(372, '1759827935', '12', 3, NULL, 23, '0', '5', 100.00, 0.00, 0.00, 43171.40, 43071.40, NULL, '$', 'right', '2025-10-07 05:05:35', '2025-10-07 05:05:35'),
(373, '1759828131', '13', 3, NULL, 23, '0', '5', 10.00, 0.00, 0.00, 43341.40, 43331.40, NULL, '$', 'right', '2025-10-07 05:08:51', '2025-10-07 05:08:51'),
(374, '1759828251', '14', 3, NULL, 23, '0', '5', 100.00, 0.00, 0.00, 43341.40, 43241.40, NULL, '$', 'right', '2025-10-07 05:10:51', '2025-10-07 05:10:51'),
(375, '1759828277', '15', 3, NULL, 23, '2', '5', 100.00, 0.00, 0.00, 43341.40, 43241.40, NULL, '$', 'right', '2025-10-07 05:11:17', '2025-10-07 05:11:48'),
(376, '1759831225', '98', 1, NULL, 23, '1', 'Xendit', 10.00, 0.50, 1.00, 43341.40, 43350.90, 'online', '$', 'left', '2025-10-07 06:00:25', '2025-10-07 06:00:25'),
(377, '1759831424', '99', 1, NULL, 23, '1', 'Xendit', 10.00, 0.50, 1.00, 43350.90, 43360.40, 'online', '$', 'left', '2025-10-07 06:03:44', '2025-10-07 06:03:44'),
(378, '1759831777', '100', 1, 23, 23, '1', 'Xendit', 20.00, 1.00, 2.00, 43360.40, 43379.40, 'online', '$', 'left', '2025-10-07 06:09:37', '2025-10-07 06:09:37'),
(379, '1759832004', '101', 1, NULL, 23, '1', 'Xendit', 10.00, 0.50, 1.00, 43379.40, 43388.90, 'online', '$', 'left', '2025-10-07 06:13:24', '2025-10-07 06:13:24'),
(380, '1759832418', '102', 1, NULL, 23, '1', 'Xendit', 10.00, 0.50, 1.00, 43388.90, 43398.40, 'online', '$', 'left', '2025-10-07 06:20:18', '2025-10-07 06:20:18'),
(381, '1759838168', '103', 1, NULL, 23, '1', 'Xendit', 120.00, 6.00, 12.00, 43398.40, 43512.40, 'online', '$', 'left', '2025-10-07 07:56:08', '2025-10-07 07:56:08'),
(382, '1759838836', '42', 2, 23, NULL, '1', 'Citibank', 272.50, 272.50, 0.00, 0.00, 0.00, 'offline', '$', 'left', '2025-10-07 08:07:16', '2025-10-07 08:07:16'),
(383, '1759898056', '16', 3, NULL, 23, '0', '6', 100.00, 0.00, 0.00, 43512.40, 43412.40, NULL, '$', 'right', '2025-10-08 00:34:16', '2025-10-08 00:34:16'),
(384, '1759899472', '43', 2, 23, NULL, '1', 'Midtrans', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2025-10-08 00:57:52', '2025-10-08 00:57:52'),
(385, '1759901118', '105', 1, 23, 23, '1', 'Midtrans', 30.00, 1.50, 3.00, 43412.40, 43440.90, 'online', '$', 'left', '2025-10-08 01:25:18', '2025-10-08 01:25:18'),
(386, '1759901346', '106', 1, 23, 23, '1', 'PayPal', 10.00, 0.50, 1.00, 43440.90, 43450.40, 'online', '$', 'left', '2025-10-08 01:29:06', '2025-10-08 01:29:06'),
(387, '1759904044', '107', 1, 23, 23, '1', 'Xendit', 20.00, 1.00, 2.00, 43450.40, 43469.40, 'online', '$', 'left', '2025-10-08 02:14:04', '2025-10-08 02:14:04'),
(388, '1759904415', '108', 1, 23, 23, '1', 'Stripe', 10.00, 0.50, 1.00, 43469.40, 43478.90, 'online', '$', 'left', '2025-10-08 02:20:15', '2025-10-08 02:20:15'),
(389, '1759904825', '110', 1, 23, 23, '1', 'Mollie', 10.00, 0.50, 1.00, 43478.90, 43488.40, 'online', '$', 'left', '2025-10-08 02:27:05', '2025-10-08 02:27:05'),
(390, '1759913773', '44', 2, 23, NULL, '1', 'Xendit', 272.50, 272.50, 0.00, 0.00, 0.00, 'online', '$', 'left', '2025-10-08 04:56:13', '2025-10-08 04:56:13'),
(391, '1759918752', '111', 1, 23, 23, '1', 'Stripe', 30.00, 1.50, 3.00, 43488.40, 43516.90, 'online', '$', 'left', '2025-10-08 06:19:12', '2025-10-08 06:19:12'),
(392, '1759919100', '112', 1, 23, 23, '1', 'PayPal', 25.00, 1.25, 2.50, 43516.90, 43540.65, 'online', '$', 'left', '2025-10-08 06:25:00', '2025-10-08 06:25:00'),
(393, '1759919224', '113', 1, 23, 23, '1', 'Stripe', 60.00, 3.00, 6.00, 43540.60, 43597.60, 'online', '$', 'left', '2025-10-08 06:27:04', '2025-10-08 06:27:04'),
(394, '1759920281', '114', 1, 23, 23, '1', 'Stripe', 10.00, 0.50, 1.00, 43597.60, 43607.10, 'online', '$', 'left', '2025-10-08 06:44:41', '2025-10-08 06:44:41'),
(395, '1759920800', '115', 1, 23, 23, '1', 'Stripe', 30.00, 1.50, 3.00, 43607.10, 43635.60, 'online', '$', 'left', '2025-10-08 06:53:20', '2025-10-08 06:53:20'),
(396, '1759921302', '116', 1, 23, 23, '1', 'PayPal', 20.00, 1.00, 2.00, 43635.60, 43654.60, 'online', '$', 'left', '2025-10-08 07:01:42', '2025-10-08 07:01:42'),
(397, '1759922161', '116', 1, 23, 23, '1', 'PayPal', 20.00, 1.00, 2.00, 43654.60, 43673.60, 'offline', '$', 'left', '2025-10-08 07:16:01', '2025-10-08 07:16:01'),
(398, '1759922583', '116', 1, 23, 23, '1', 'PayPal', 20.00, 1.00, 2.00, 43673.60, 43692.60, 'offline', '$', 'left', '2025-10-08 07:23:03', '2025-10-08 07:23:03'),
(399, '1759922720', '116', 1, 23, 23, '1', 'PayPal', 20.00, 1.00, 2.00, 43692.60, 43711.60, 'offline', '$', 'left', '2025-10-08 07:25:20', '2025-10-08 07:25:20'),
(400, '1759922834', '116', 1, 23, 23, '1', 'PayPal', 20.00, 1.00, 2.00, 43711.60, 43730.60, 'offline', '$', 'left', '2025-10-08 07:27:14', '2025-10-08 07:27:14'),
(401, '1760334184', '122', 1, 35, NULL, '1', 'Citibank', 95.00, 4.75, 9.50, 0.00, NULL, 'offline', '$', 'left', '2025-10-13 01:43:04', '2025-10-13 01:43:04'),
(402, '1760334203', '120', 1, 35, NULL, '1', 'Citibank', 95.00, 4.75, 9.50, 0.00, NULL, 'offline', '$', 'left', '2025-10-13 01:43:23', '2025-10-13 01:43:23'),
(403, '1760335489', '124', 1, 35, 23, '1', 'Citibank', 12.50, 0.63, 1.25, 43730.60, 43742.47, 'offline', '$', 'left', '2025-10-13 02:04:49', '2025-10-13 02:04:49'),
(404, '1760847536', '133', 1, 34, 23, '1', 'Citibank', 99.00, 4.95, 9.90, 43742.50, 43836.55, 'offline', '$', 'left', '2025-10-19 00:18:56', '2025-10-19 00:18:56'),
(405, '1760847555', '132', 1, 34, 24, '1', 'Citibank', 66.00, 3.30, 6.60, 162255.00, 162317.70, 'offline', '$', 'left', '2025-10-19 00:19:15', '2025-10-19 00:19:15'),
(406, '1760847581', '131', 1, 34, 23, '1', 'Citibank', 103.50, 5.18, 10.35, 43836.60, 43934.92, 'offline', '$', 'left', '2025-10-19 00:19:41', '2025-10-19 00:19:41'),
(407, '1760848608', '137', 1, 33, 23, '1', 'Bank of America', 198.00, 9.90, 19.80, 43934.90, 44123.00, 'offline', '$', 'left', '2025-10-19 00:36:48', '2025-10-19 00:36:48'),
(408, '1760854345', '139', 1, 34, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:12:25', '2025-10-19 02:12:25'),
(409, '1760854937', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:22:17', '2025-10-19 02:22:17'),
(410, '1760854952', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:22:32', '2025-10-19 02:22:32'),
(411, '1760855238', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:27:18', '2025-10-19 02:27:18'),
(412, '1760855282', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:28:02', '2025-10-19 02:28:02'),
(413, '1760855308', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:28:28', '2025-10-19 02:28:28'),
(414, '1760855340', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:29:00', '2025-10-19 02:29:00'),
(415, '1760855571', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:32:51', '2025-10-19 02:32:51'),
(416, '1760855656', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:34:16', '2025-10-19 02:34:16'),
(417, '1760856860', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:54:20', '2025-10-19 02:54:20'),
(418, '1760856893', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 02:54:53', '2025-10-19 02:54:53'),
(419, '1760857404', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:03:24', '2025-10-19 03:03:24'),
(420, '1760857446', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:04:06', '2025-10-19 03:04:06'),
(421, '1760857498', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:04:58', '2025-10-19 03:04:58'),
(422, '1760857757', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:09:17', '2025-10-19 03:09:17'),
(423, '1760857816', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:10:16', '2025-10-19 03:10:16'),
(424, '1760858100', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:15:00', '2025-10-19 03:15:00'),
(425, '1760858597', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 03:23:17', '2025-10-19 03:23:17'),
(426, '1760862427', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 04:27:07', '2025-10-19 04:27:07'),
(427, '1760862558', '139', 1, 33, NULL, '1', 'Citibank', 166.10, 8.31, 16.61, 0.00, NULL, 'offline', '$', 'left', '2025-10-19 04:29:18', '2025-10-19 04:29:18'),
(428, '1761567988', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 589.00, 845.50, 'offline', '$', 'left', '2025-10-27 07:26:28', '2025-10-27 07:26:28'),
(429, '1761628981', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 845.50, 1102.00, 'offline', '$', 'left', '2025-10-28 00:23:01', '2025-10-28 00:23:01'),
(430, '1761629135', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 1102.00, 1358.50, 'offline', '$', 'left', '2025-10-28 00:25:35', '2025-10-28 00:25:35'),
(431, '1761629327', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 1358.50, 1615.00, 'offline', '$', 'left', '2025-10-28 00:28:47', '2025-10-28 00:28:47'),
(432, '1761629535', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 1615.00, 1871.50, 'offline', '$', 'left', '2025-10-28 00:32:15', '2025-10-28 00:32:15'),
(433, '1761629721', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 1871.50, 2128.00, 'offline', '$', 'left', '2025-10-28 00:35:21', '2025-10-28 00:35:21'),
(434, '1761629812', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 2128.00, 2384.50, 'offline', '$', 'left', '2025-10-28 00:36:52', '2025-10-28 00:36:52'),
(435, '1761629849', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 2384.50, 2641.00, 'offline', '$', 'left', '2025-10-28 00:37:29', '2025-10-28 00:37:29'),
(436, '1761630369', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 2641.00, 2897.50, 'offline', '$', 'left', '2025-10-28 00:46:09', '2025-10-28 00:46:09'),
(437, '1761630474', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 2897.50, 3154.00, 'offline', '$', 'left', '2025-10-28 00:47:54', '2025-10-28 00:47:54'),
(438, '1761630589', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 3154.00, 3410.50, 'offline', '$', 'left', '2025-10-28 00:49:49', '2025-10-28 00:49:49'),
(439, '1761630757', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 3410.50, 3667.00, 'offline', '$', 'left', '2025-10-28 00:52:37', '2025-10-28 00:52:37'),
(440, '1761630799', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 3667.00, 3923.50, 'offline', '$', 'left', '2025-10-28 00:53:19', '2025-10-28 00:53:19'),
(441, '1761630872', '177', 1, NULL, 25, '1', 'Citibank', 270.00, 13.50, 27.00, 3923.50, 4180.00, 'offline', '$', 'left', '2025-10-28 00:54:32', '2025-10-28 00:54:32'),
(442, '1761722405', '178', 1, NULL, 23, '1', 'Citibank', 10.00, 0.50, 1.00, 44123.00, 44132.50, 'offline', '$', 'left', '2025-10-29 02:20:05', '2025-10-29 02:20:05'),
(443, '1761726066', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44132.50, 44257.90, 'offline', '$', 'left', '2025-10-29 03:21:06', '2025-10-29 03:21:06'),
(444, '1761727250', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44257.90, 44383.30, 'offline', '$', 'left', '2025-10-29 03:40:50', '2025-10-29 03:40:50'),
(445, '1761727364', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44383.30, 44508.70, 'offline', '$', 'left', '2025-10-29 03:42:44', '2025-10-29 03:42:44'),
(446, '1761727475', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44508.70, 44634.10, 'offline', '$', 'left', '2025-10-29 03:44:35', '2025-10-29 03:44:35'),
(447, '1761727729', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44634.10, 44759.50, 'offline', '$', 'left', '2025-10-29 03:48:49', '2025-10-29 03:48:49'),
(448, '1761727799', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44759.50, 44884.90, 'offline', '$', 'left', '2025-10-29 03:49:59', '2025-10-29 03:49:59'),
(449, '1761728077', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 44884.90, 45010.30, 'offline', '$', 'left', '2025-10-29 03:54:37', '2025-10-29 03:54:37'),
(450, '1761728142', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45010.30, 45135.70, 'offline', '$', 'left', '2025-10-29 03:55:42', '2025-10-29 03:55:42'),
(451, '1761728273', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45135.70, 45261.10, 'offline', '$', 'left', '2025-10-29 03:57:53', '2025-10-29 03:57:53'),
(452, '1761728479', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45261.10, 45386.50, 'offline', '$', 'left', '2025-10-29 04:01:19', '2025-10-29 04:01:19'),
(453, '1761728996', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45386.50, 45511.90, 'offline', '$', 'left', '2025-10-29 04:09:56', '2025-10-29 04:09:56'),
(454, '1761729070', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45511.90, 45637.30, 'offline', '$', 'left', '2025-10-29 04:11:10', '2025-10-29 04:11:10'),
(455, '1761729149', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45637.30, 45762.70, 'offline', '$', 'left', '2025-10-29 04:12:29', '2025-10-29 04:12:29'),
(456, '1761731718', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45762.70, 45888.10, 'offline', '$', 'left', '2025-10-29 04:55:18', '2025-10-29 04:55:18'),
(457, '1761732350', '179', 1, NULL, 23, '1', 'Citibank', 132.00, 6.60, 13.20, 45888.10, 46013.50, 'offline', '$', 'left', '2025-10-29 05:05:50', '2025-10-29 05:05:50'),
(458, '1761735458', '181', 1, 33, 23, '1', 'Citibank', 532.00, 26.60, 53.20, 46013.50, 46518.90, 'offline', '$', 'left', '2025-10-29 05:57:38', '2025-10-29 05:57:38'),
(459, '1761743596', '183', 1, 33, 23, '1', 'PayPal', 200.00, 10.00, 20.00, 46518.90, 46708.90, 'online', '$', 'left', '2025-10-29 08:13:16', '2025-10-29 08:13:16'),
(460, '1762064515', '17', 3, NULL, 23, '0', '5', 100.00, 0.00, 0.00, 46708.90, 46608.90, NULL, '$', 'right', '2025-11-02 01:21:55', '2025-11-02 01:21:55'),
(461, '1762064548', '18', 3, NULL, 23, '2', '4', 100.00, 0.00, 0.00, 46708.90, 46608.90, NULL, '$', 'right', '2025-11-02 01:22:28', '2025-11-02 01:22:44'),
(462, '1762078676', '184', 1, NULL, 23, '1', 'PayPal', 261.00, 13.05, 26.10, 46708.90, 46956.85, 'online', '$', 'left', '2025-11-02 05:17:56', '2025-11-02 05:17:56'),
(463, '1762143646', '185', 1, NULL, 23, '0', 'Bank of America', 20.00, 1.00, 2.00, 46956.90, 46975.90, 'offline', '$', 'left', '2025-11-02 23:20:46', '2025-11-02 23:25:17'),
(464, '1762148848', '19', 3, NULL, 23, '0', '4', 100.00, 0.00, 0.00, 46975.90, 46875.90, NULL, '$', 'right', '2025-11-03 00:47:28', '2025-11-03 00:47:28'),
(465, '1762153926', '186', 1, 23, 25, '1', 'Citibank', 180.00, 9.00, 18.00, 4180.00, 4351.00, 'offline', '$', 'left', '2025-11-03 02:12:06', '2025-11-03 02:12:06'),
(466, '1762158542', '188', 1, NULL, 25, '1', 'paypal', 100.00, 5.00, 0.00, 4351.00, 4446.00, 'online', '$', 'left', '2025-11-03 03:29:02', '2025-11-03 03:29:02'),
(467, '1762168999', '189', 1, 23, 23, '1', 'Bank of America', 20.00, 1.00, 2.00, 46875.90, 46894.90, 'offline', '$', 'left', '2025-11-03 06:23:19', '2025-11-03 06:23:19'),
(468, '1762169496', '190', 1, 23, 23, '1', 'Citibank', 22.00, 1.10, 0.00, 46894.90, 46915.80, 'offline', '$', 'left', '2025-11-03 06:31:36', '2025-11-03 06:31:36'),
(469, '1762169656', '190', 1, NULL, 23, '1', 'Citibank', 22.00, 1.10, 0.00, 46915.80, 46936.70, 'offline', '$', 'left', '2025-11-03 06:34:16', '2025-11-03 06:34:16'),
(470, '1762241307', '192', 1, NULL, 23, '1', 'Citibank', 200.00, 10.00, 20.00, 46936.70, 47126.70, 'offline', '$', 'left', '2025-11-04 02:28:27', '2025-11-04 02:28:27'),
(471, '1762606685', '194', 1, NULL, 23, '1', 'Citibank', 183.10, 9.16, 18.31, 47126.70, 47300.64, 'offline', '$', 'left', '2025-11-08 07:58:05', '2025-11-08 07:58:05'),
(472, '1762669645', '196', 1, 23, 23, '1', 'PayPal', 110.00, 5.50, 11.00, 47300.60, 47405.10, 'online', '$', 'left', '2025-11-09 01:27:25', '2025-11-09 01:27:25');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `contact_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '0 -> banned or deactive, 1 -> active',
  `verification_token` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `edit_profile_status` tinyint(3) UNSIGNED NOT NULL DEFAULT '0' COMMENT '0 -> not edited user profile, 1 -> edited user profile',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `last_name`, `image`, `username`, `email`, `email_verified_at`, `password`, `contact_number`, `address`, `city`, `state`, `country`, `status`, `verification_token`, `remember_token`, `edit_profile_status`, `created_at`, `updated_at`) VALUES
(9, 'Saeed', 'Mahmud', '1636607574.png', 'saeed', 'geniustest11@gmail.com', '2021-12-13 02:35:32', '$2a$12$T9Z/6tQKjnW8bQdmgNW70eEGuum0f69NUAJ2wQsGqBx6UoJ/bU0Qa', '+132456789', 'Mirpur 12', 'Dhaka', NULL, 'BD', 1, NULL, NULL, 1, '2021-11-04 03:31:44', '2021-12-23 05:00:40'),
(10, 'Samiul', 'Pratik', NULL, 'pratik', 'pratik.anwar@gmail.com', '2022-04-26 02:14:48', '$2a$12$ID6qjVPRRIE7m3YwbkAZ1eCFBc1uBvtA2pcnY.oArzBklxwx1a7Uq', '+132456789', 'House - 44, Road, - 3, Sector - 11, Uttara, Dhaka', 'Dhaka', 'Dhaka', 'Bangladesh', 1, NULL, NULL, 1, '2022-04-26 02:14:29', '2022-04-26 02:15:46'),
(11, NULL, NULL, NULL, 'rynupyzan', 'user@gmail.com', NULL, '$2y$10$bRif2OK0/gzPRTYMODqAFOL4DVFk8Uvrr7p3ZsQ.1BIqEqozSvYvC', NULL, NULL, NULL, NULL, NULL, 0, '8cc2740a37e351c21d8798de23ced22c', NULL, 0, '2022-06-14 04:13:58', '2022-06-14 04:13:58'),
(12, 'Fahad', 'Hossain', '62a9725fd40d8.jpg', 'fahadahmadshemul', 'fahadahmadshemul@gmail.com', NULL, '$2y$10$sUWgkndzQpWxjy5PmF0RqO1h1Wp3CpkeXcb/hyJF6ak9TL0YFyrLy', '0123982109', 'Dhaka, Bangladesh', 'Dhaka', 'N/A', 'Bangladesh', 1, NULL, NULL, 1, '2022-06-14 23:44:29', '2022-12-17 23:14:59');

-- --------------------------------------------------------

--
-- Table structure for table `variation_contents`
--

CREATE TABLE `variation_contents` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `language_id` bigint(20) DEFAULT NULL,
  `ticket_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `key` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `variation_contents`
--

INSERT INTO `variation_contents` (`id`, `language_id`, `ticket_id`, `name`, `key`, `created_at`, `updated_at`) VALUES
(33, 8, 155, '234', '0', '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(34, 8, 155, '2323', '1', '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(35, 22, 155, 'ewwerwer', '0', '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(36, 22, 155, '234234', '1', '2023-05-13 11:17:48', '2023-05-13 11:17:48'),
(37, 8, 154, 'VIP en', '0', '2023-05-13 11:20:35', '2023-05-13 11:20:35'),
(38, 22, 154, 'VIP ar', '0', '2023-05-13 11:20:35', '2023-05-13 11:20:35'),
(39, 8, 156, 'Economy', '0', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(40, 8, 156, 'Business', '1', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(41, 8, 156, 'First', '2', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(42, 22, 156, 'اقتصاد', '0', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(43, 22, 156, 'عمل', '1', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(44, 22, 156, 'أولاً', '2', '2023-05-14 04:35:53', '2023-05-14 04:35:53'),
(51, 8, 168, 'Vip', '0', '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(52, 8, 168, 'Normal', '1', '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(53, 22, 168, 'كبار الشخصيات', '0', '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(54, 22, 168, 'طبيعي', '1', '2023-05-14 09:24:29', '2023-05-14 09:24:29'),
(67, 8, 170, 'Premium', '0', '2023-05-14 09:37:08', '2023-05-14 09:37:08'),
(68, 8, 170, 'First', '1', '2023-05-14 09:37:08', '2023-05-14 09:37:08'),
(69, 22, 170, 'غالي', '0', '2023-05-14 09:37:08', '2023-05-14 09:37:08'),
(70, 22, 170, 'أولاً', '1', '2023-05-14 09:37:08', '2023-05-14 09:37:08'),
(81, 8, 179, 'VIP en', '0', '2023-11-18 00:51:38', '2023-11-18 00:51:38'),
(82, 8, 179, 'Fahad en', '1', '2023-11-18 00:51:38', '2023-11-18 00:51:38'),
(83, 22, 179, 'VIP ar', '0', '2023-11-18 00:51:38', '2023-11-18 00:51:38'),
(84, 22, 179, 'dfsafaf', '1', '2023-11-18 00:51:38', '2023-11-18 00:51:38'),
(85, 8, 178, 'VIP en', '0', '2023-11-18 01:00:31', '2023-11-18 01:00:31'),
(86, 22, 178, 'VIP ar', '0', '2023-11-18 01:00:31', '2023-11-18 01:00:31'),
(89, 8, 180, 'fdasfasf', '0', '2023-11-18 01:03:46', '2023-11-18 01:03:46'),
(90, 22, 180, 'fdasfasf', '0', '2023-11-18 01:03:46', '2023-11-18 01:03:46'),
(635, 8, 191, 'rr44', '0', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(636, 8, 191, 'Economy', '1', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(637, 8, 191, 'tick 3 en', '2', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(638, 22, 191, '4444', '0', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(639, 22, 191, 'اقتصاد', '1', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(640, 22, 191, '4444', '2', '2025-10-21 07:25:53', '2025-10-21 07:25:53'),
(643, 8, 188, 'Economy', '0', '2025-10-29 05:52:54', '2025-10-29 05:52:54'),
(644, 22, 188, 'اقتصاد', '0', '2025-10-29 05:52:54', '2025-10-29 05:52:54'),
(657, 8, 193, 'Economy', '0', '2025-11-03 06:59:49', '2025-11-03 06:59:49'),
(658, 22, 193, '4444', '0', '2025-11-03 06:59:49', '2025-11-03 06:59:49'),
(659, 8, 195, 'Economy', '0', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(660, 8, 195, 'Business', '1', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(661, 8, 195, 'First', '2', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(662, 22, 195, 'اقتصاد', '0', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(663, 22, 195, 'عمل', '1', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(664, 22, 195, 'أولاً', '2', '2025-11-06 01:17:05', '2025-11-06 01:17:05'),
(707, 8, 205, 'Economy', '0', '2025-11-08 07:55:07', '2025-11-08 07:55:07'),
(708, 8, 205, 'Standard', '1', '2025-11-08 07:55:07', '2025-11-08 07:55:07'),
(709, 22, 205, 'اقتصاد', '0', '2025-11-08 07:55:07', '2025-11-08 07:55:07'),
(710, 22, 205, 'معيار', '1', '2025-11-08 07:55:07', '2025-11-08 07:55:07'),
(849, 8, 198, 'North Preferred', '0', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(850, 8, 198, 'East Preferred', '1', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(851, 8, 198, 'West Preferred', '2', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(852, 8, 198, 'South Preferred', '3', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(853, 22, 198, 'الغرب المفضل', '0', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(854, 22, 198, 'الشرق المفضل', '1', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(855, 22, 198, 'الشمال المفضل', '2', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(856, 22, 198, 'الجنوب المفضل', '3', '2025-11-10 06:31:18', '2025-11-10 06:31:18'),
(861, 8, 209, 'Economy', '0', '2025-11-10 06:32:23', '2025-11-10 06:32:23'),
(862, 8, 209, 'Economy', '1', '2025-11-10 06:32:23', '2025-11-10 06:32:23'),
(863, 22, 209, 'الغرب المفضل', '0', '2025-11-10 06:32:23', '2025-11-10 06:32:23'),
(864, 22, 209, 'الغرب المفضل', '1', '2025-11-10 06:32:23', '2025-11-10 06:32:23');

-- --------------------------------------------------------

--
-- Table structure for table `wishlists`
--

CREATE TABLE `wishlists` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `customer_id` bigint(20) NOT NULL,
  `event_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `wishlists`
--

INSERT INTO `wishlists` (`id`, `customer_id`, `event_id`, `created_at`, `updated_at`) VALUES
(39, 23, 102, '2023-05-08 11:20:00', '2023-05-08 11:20:00'),
(40, 23, 92, '2023-05-08 11:20:03', '2023-05-08 11:20:03'),
(41, 23, 104, '2023-05-08 11:20:07', '2023-05-08 11:20:07'),
(42, 23, 94, '2023-05-08 11:20:10', '2023-05-08 11:20:10'),
(43, 33, 101, '2025-10-09 06:44:27', '2025-10-09 06:44:27'),
(44, 33, 105, '2025-10-09 08:25:25', '2025-10-09 08:25:25'),
(45, 33, 24, '2025-10-09 08:39:44', '2025-10-09 08:39:44'),
(47, 34, 104, '2025-10-13 01:36:08', '2025-10-13 01:36:08'),
(48, 34, 100, '2025-10-13 02:58:01', '2025-10-13 02:58:01'),
(49, 34, 93, '2025-10-13 02:59:49', '2025-10-13 02:59:49'),
(50, 34, 91, '2025-10-13 05:33:58', '2025-10-13 05:33:58'),
(51, 33, 104, '2025-10-19 02:26:40', '2025-10-19 02:26:40'),
(52, 33, 103, '2025-10-19 02:30:42', '2025-10-19 02:30:42');

-- --------------------------------------------------------

--
-- Table structure for table `withdraws`
--

CREATE TABLE `withdraws` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `organizer_id` int(11) NOT NULL,
  `withdraw_id` varchar(255) DEFAULT NULL,
  `method_id` int(11) NOT NULL,
  `amount` varchar(255) NOT NULL,
  `payable_amount` float(8,2) DEFAULT '0.00',
  `total_charge` float(8,2) DEFAULT '0.00',
  `additional_reference` longtext,
  `feilds` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT '0' COMMENT '0-pending, 1-approved, 2-decline',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `withdraws`
--

INSERT INTO `withdraws` (`id`, `organizer_id`, `withdraw_id`, `method_id`, `amount`, `payable_amount`, `total_charge`, `additional_reference`, `feilds`, `status`, `created_at`, `updated_at`) VALUES
(6, 23, '68e39850854cb', 5, '100', 93.12, 6.88, NULL, '{\"Account_No\":\"100\"}', 2, '2025-10-06 06:22:08', '2025-10-06 06:22:59'),
(8, 23, '68e39d7c517c7', 5, '100', 93.12, 6.88, '11', '{\"Account_No\":\"111\"}', 2, '2025-10-06 06:44:12', '2025-10-07 05:06:47'),
(16, 23, '68e5e9c81e42f', 6, '100', 95.00, 5.00, NULL, '{\"Address\":\"66\"}', 0, '2025-10-08 00:34:16', '2025-10-08 00:34:16'),
(19, 23, '690841f02e30e', 4, '100', 72.00, 28.00, NULL, '{\"Contact_Number\":\"556\",\"Address\":\"Ut est mollitia par\"}', 0, '2025-11-03 00:47:28', '2025-11-03 00:47:28');

-- --------------------------------------------------------

--
-- Table structure for table `withdraw_method_inputs`
--

CREATE TABLE `withdraw_method_inputs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `withdraw_payment_method_id` int(11) NOT NULL,
  `type` tinyint(4) DEFAULT NULL COMMENT '1-text, 2-select, 3-checkbox, 4-textarea, 5-datepicker, 6-timepicker, 7-number',
  `label` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `placeholder` varchar(255) DEFAULT NULL,
  `required` tinyint(4) NOT NULL DEFAULT '0' COMMENT '1-required, 0- optional',
  `order_number` int(11) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `withdraw_method_inputs`
--

INSERT INTO `withdraw_method_inputs` (`id`, `withdraw_payment_method_id`, `type`, `label`, `name`, `placeholder`, `required`, `order_number`, `created_at`, `updated_at`) VALUES
(15, 4, 7, 'Contact Number', 'Contact_Number', 'Enter Contact Number', 1, 1, '2023-01-17 10:52:21', '2025-11-01 00:23:24'),
(16, 5, 1, 'Account No', 'Account_No', 'Enter Account Number', 1, 1, '2023-01-21 06:37:04', '2023-01-21 06:37:04'),
(17, 4, 1, 'Address', 'Address', 'ADDRESS', 1, 2, '2025-10-08 00:30:29', '2025-11-01 00:23:24'),
(18, 6, 4, 'Address', 'Address', 'Enter Address', 1, 1, '2025-10-08 00:31:47', '2025-10-08 00:31:47');

-- --------------------------------------------------------

--
-- Table structure for table `withdraw_method_options`
--

CREATE TABLE `withdraw_method_options` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `withdraw_method_input_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `withdraw_payment_methods`
--

CREATE TABLE `withdraw_payment_methods` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `fixed_charge` float(8,2) DEFAULT '0.00',
  `percentage_charge` float DEFAULT '0',
  `min_limit` varchar(255) NOT NULL,
  `max_limit` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT '1',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Dumping data for table `withdraw_payment_methods`
--

INSERT INTO `withdraw_payment_methods` (`id`, `fixed_charge`, `percentage_charge`, `min_limit`, `max_limit`, `name`, `status`, `created_at`, `updated_at`) VALUES
(4, 10.00, 20, '50', '1000', 'Bitcoin', 1, '2023-01-05 10:52:20', '2023-05-06 10:31:42'),
(5, 3.00, 4, '10', '100', 'Perfect Money', 1, '2023-01-05 11:02:57', '2023-01-05 11:02:57'),
(6, 0.00, 5, '63', '400', 'Louis Copeland', 1, '2025-10-08 00:30:18', '2025-10-08 00:33:42');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `about_us_sections`
--
ALTER TABLE `about_us_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `action_sections`
--
ALTER TABLE `action_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `admins_username_unique` (`username`),
  ADD UNIQUE KEY `admins_email_unique` (`email`),
  ADD KEY `admins_role_id_foreign` (`role_id`);

--
-- Indexes for table `advertisements`
--
ALTER TABLE `advertisements`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `basic_settings`
--
ALTER TABLE `basic_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blogs`
--
ALTER TABLE `blogs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `blog_categories_language_id_foreign` (`language_id`);

--
-- Indexes for table `blog_informations`
--
ALTER TABLE `blog_informations`
  ADD PRIMARY KEY (`id`),
  ADD KEY `blog_informations_language_id_foreign` (`language_id`),
  ADD KEY `blog_informations_blog_category_id_foreign` (`blog_category_id`),
  ADD KEY `blog_informations_blog_id_foreign` (`blog_id`);

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cities`
--
ALTER TABLE `cities`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cities_test_ibfk_1` (`state_id`),
  ADD KEY `cities_test_ibfk_2` (`country_id`);

--
-- Indexes for table `contact_pages`
--
ALTER TABLE `contact_pages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `conversations`
--
ALTER TABLE `conversations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `cookie_alerts`
--
ALTER TABLE `cookie_alerts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `cookie_alerts_language_id_foreign` (`language_id`);

--
-- Indexes for table `countries`
--
ALTER TABLE `countries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `count_informations`
--
ALTER TABLE `count_informations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `coupons`
--
ALTER TABLE `coupons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `earnings`
--
ALTER TABLE `earnings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `events`
--
ALTER TABLE `events`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_categories`
--
ALTER TABLE `event_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_cities`
--
ALTER TABLE `event_cities`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_contents`
--
ALTER TABLE `event_contents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_countries`
--
ALTER TABLE `event_countries`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_dates`
--
ALTER TABLE `event_dates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_features`
--
ALTER TABLE `event_features`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_feature_sections`
--
ALTER TABLE `event_feature_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_images`
--
ALTER TABLE `event_images`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `event_states`
--
ALTER TABLE `event_states`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `faqs_language_id_foreign` (`language_id`);

--
-- Indexes for table `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `features`
--
ALTER TABLE `features`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `footer_contents`
--
ALTER TABLE `footer_contents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `footer_texts_language_id_foreign` (`language_id`);

--
-- Indexes for table `fun_fact_sections`
--
ALTER TABLE `fun_fact_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `gooogle_calendar_infos`
--
ALTER TABLE `gooogle_calendar_infos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `guests`
--
ALTER TABLE `guests`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `hero_sections`
--
ALTER TABLE `hero_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `how_works`
--
ALTER TABLE `how_works`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `how_work_items`
--
ALTER TABLE `how_work_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `mail_templates`
--
ALTER TABLE `mail_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `menu_builders`
--
ALTER TABLE `menu_builders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `offline_gateways`
--
ALTER TABLE `offline_gateways`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `online_gateways`
--
ALTER TABLE `online_gateways`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `organizers`
--
ALTER TABLE `organizers`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `organizer_infos`
--
ALTER TABLE `organizer_infos`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pages`
--
ALTER TABLE `pages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `page_contents`
--
ALTER TABLE `page_contents`
  ADD PRIMARY KEY (`id`),
  ADD KEY `page_contents_language_id_foreign` (`language_id`),
  ADD KEY `page_contents_page_id_foreign` (`page_id`);

--
-- Indexes for table `page_headings`
--
ALTER TABLE `page_headings`
  ADD PRIMARY KEY (`id`),
  ADD KEY `page_headings_language_id_foreign` (`language_id`);

--
-- Indexes for table `partners`
--
ALTER TABLE `partners`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `partner_sections`
--
ALTER TABLE `partner_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD KEY `password_resets_email_index` (`email`);

--
-- Indexes for table `payment_invoices`
--
ALTER TABLE `payment_invoices`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `popups`
--
ALTER TABLE `popups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `popups_language_id_foreign` (`language_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_categories`
--
ALTER TABLE `product_categories`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_contents`
--
ALTER TABLE `product_contents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_images`
--
ALTER TABLE `product_images`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_orders`
--
ALTER TABLE `product_orders`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `product_reviews`
--
ALTER TABLE `product_reviews`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `push_subscriptions`
--
ALTER TABLE `push_subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `push_subscriptions_endpoint_unique` (`endpoint`),
  ADD KEY `push_subscriptions_subscribable_type_subscribable_id_index` (`subscribable_type`,`subscribable_id`);

--
-- Indexes for table `quick_links`
--
ALTER TABLE `quick_links`
  ADD PRIMARY KEY (`id`),
  ADD KEY `quick_links_language_id_foreign` (`language_id`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `sections`
--
ALTER TABLE `sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `section_titles`
--
ALTER TABLE `section_titles`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `seos`
--
ALTER TABLE `seos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `seos_language_id_foreign` (`language_id`);

--
-- Indexes for table `shipping_charges`
--
ALTER TABLE `shipping_charges`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `shop_coupons`
--
ALTER TABLE `shop_coupons`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `slots`
--
ALTER TABLE `slots`
  ADD PRIMARY KEY (`id`),
  ADD KEY `slots_event_id_index` (`event_id`),
  ADD KEY `slots_ticket_id_index` (`ticket_id`),
  ADD KEY `slots_slot_unique_id_index` (`slot_unique_id`),
  ADD KEY `slots_type_index` (`type`);

--
-- Indexes for table `slot_images`
--
ALTER TABLE `slot_images`
  ADD PRIMARY KEY (`id`),
  ADD KEY `slot_images_event_id_index` (`event_id`),
  ADD KEY `slot_images_ticket_id_index` (`ticket_id`),
  ADD KEY `slot_images_slot_unique_id_index` (`slot_unique_id`);

--
-- Indexes for table `slot_seats`
--
ALTER TABLE `slot_seats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `slot_seats_slot_id_index` (`slot_id`);

--
-- Indexes for table `social_medias`
--
ALTER TABLE `social_medias`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `states`
--
ALTER TABLE `states`
  ADD PRIMARY KEY (`id`),
  ADD KEY `country_region` (`country_id`);

--
-- Indexes for table `subscribers`
--
ALTER TABLE `subscribers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `subscribers_email_id_unique` (`email_id`);

--
-- Indexes for table `support_tickets`
--
ALTER TABLE `support_tickets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `support_ticket_statuses`
--
ALTER TABLE `support_ticket_statuses`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `testimonials`
--
ALTER TABLE `testimonials`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `testimonial_sections`
--
ALTER TABLE `testimonial_sections`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `ticket_contents`
--
ALTER TABLE `ticket_contents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `timezones`
--
ALTER TABLE `timezones`
  ADD PRIMARY KEY (`country_code`,`timezone`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_username_unique` (`username`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `variation_contents`
--
ALTER TABLE `variation_contents`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `wishlists`
--
ALTER TABLE `wishlists`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `withdraws`
--
ALTER TABLE `withdraws`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `withdraw_method_inputs`
--
ALTER TABLE `withdraw_method_inputs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `withdraw_method_options`
--
ALTER TABLE `withdraw_method_options`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `withdraw_payment_methods`
--
ALTER TABLE `withdraw_payment_methods`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `about_us_sections`
--
ALTER TABLE `about_us_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `action_sections`
--
ALTER TABLE `action_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `advertisements`
--
ALTER TABLE `advertisements`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `basic_settings`
--
ALTER TABLE `basic_settings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `blogs`
--
ALTER TABLE `blogs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `blog_categories`
--
ALTER TABLE `blog_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `blog_informations`
--
ALTER TABLE `blog_informations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=197;

--
-- AUTO_INCREMENT for table `cities`
--
ALTER TABLE `cities`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=150106;

--
-- AUTO_INCREMENT for table `contact_pages`
--
ALTER TABLE `contact_pages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `conversations`
--
ALTER TABLE `conversations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `cookie_alerts`
--
ALTER TABLE `cookie_alerts`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `countries`
--
ALTER TABLE `countries`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=251;

--
-- AUTO_INCREMENT for table `count_informations`
--
ALTER TABLE `count_informations`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `coupons`
--
ALTER TABLE `coupons`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=43;

--
-- AUTO_INCREMENT for table `earnings`
--
ALTER TABLE `earnings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `events`
--
ALTER TABLE `events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=129;

--
-- AUTO_INCREMENT for table `event_categories`
--
ALTER TABLE `event_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `event_cities`
--
ALTER TABLE `event_cities`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `event_contents`
--
ALTER TABLE `event_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=236;

--
-- AUTO_INCREMENT for table `event_countries`
--
ALTER TABLE `event_countries`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `event_dates`
--
ALTER TABLE `event_dates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `event_features`
--
ALTER TABLE `event_features`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `event_feature_sections`
--
ALTER TABLE `event_feature_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `event_images`
--
ALTER TABLE `event_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=271;

--
-- AUTO_INCREMENT for table `event_states`
--
ALTER TABLE `event_states`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `faqs`
--
ALTER TABLE `faqs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `fcm_tokens`
--
ALTER TABLE `fcm_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `features`
--
ALTER TABLE `features`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `footer_contents`
--
ALTER TABLE `footer_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `fun_fact_sections`
--
ALTER TABLE `fun_fact_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `gooogle_calendar_infos`
--
ALTER TABLE `gooogle_calendar_infos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `guests`
--
ALTER TABLE `guests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `hero_sections`
--
ALTER TABLE `hero_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `how_works`
--
ALTER TABLE `how_works`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `how_work_items`
--
ALTER TABLE `how_work_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=112;

--
-- AUTO_INCREMENT for table `languages`
--
ALTER TABLE `languages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `mail_templates`
--
ALTER TABLE `mail_templates`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `menu_builders`
--
ALTER TABLE `menu_builders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=89;

--
-- AUTO_INCREMENT for table `offline_gateways`
--
ALTER TABLE `offline_gateways`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `online_gateways`
--
ALTER TABLE `online_gateways`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=65;

--
-- AUTO_INCREMENT for table `organizers`
--
ALTER TABLE `organizers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `organizer_infos`
--
ALTER TABLE `organizer_infos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `pages`
--
ALTER TABLE `pages`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `page_contents`
--
ALTER TABLE `page_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;

--
-- AUTO_INCREMENT for table `page_headings`
--
ALTER TABLE `page_headings`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `partners`
--
ALTER TABLE `partners`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `partner_sections`
--
ALTER TABLE `partner_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `payment_invoices`
--
ALTER TABLE `payment_invoices`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `popups`
--
ALTER TABLE `popups`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `product_categories`
--
ALTER TABLE `product_categories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `product_contents`
--
ALTER TABLE `product_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `product_images`
--
ALTER TABLE `product_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=35;

--
-- AUTO_INCREMENT for table `product_orders`
--
ALTER TABLE `product_orders`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `product_reviews`
--
ALTER TABLE `product_reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `push_subscriptions`
--
ALTER TABLE `push_subscriptions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `quick_links`
--
ALTER TABLE `quick_links`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT for table `role_permissions`
--
ALTER TABLE `role_permissions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `sections`
--
ALTER TABLE `sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `section_titles`
--
ALTER TABLE `section_titles`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `seos`
--
ALTER TABLE `seos`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `shipping_charges`
--
ALTER TABLE `shipping_charges`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `shop_coupons`
--
ALTER TABLE `shop_coupons`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `slots`
--
ALTER TABLE `slots`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=113;

--
-- AUTO_INCREMENT for table `slot_images`
--
ALTER TABLE `slot_images`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `slot_seats`
--
ALTER TABLE `slot_seats`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=580;

--
-- AUTO_INCREMENT for table `social_medias`
--
ALTER TABLE `social_medias`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=39;

--
-- AUTO_INCREMENT for table `states`
--
ALTER TABLE `states`
  MODIFY `id` mediumint(8) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5089;

--
-- AUTO_INCREMENT for table `subscribers`
--
ALTER TABLE `subscribers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `support_tickets`
--
ALTER TABLE `support_tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=24;

--
-- AUTO_INCREMENT for table `support_ticket_statuses`
--
ALTER TABLE `support_ticket_statuses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `testimonials`
--
ALTER TABLE `testimonials`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT for table `testimonial_sections`
--
ALTER TABLE `testimonial_sections`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT for table `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=210;

--
-- AUTO_INCREMENT for table `ticket_contents`
--
ALTER TABLE `ticket_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=103;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=473;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `variation_contents`
--
ALTER TABLE `variation_contents`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=865;

--
-- AUTO_INCREMENT for table `wishlists`
--
ALTER TABLE `wishlists`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- AUTO_INCREMENT for table `withdraws`
--
ALTER TABLE `withdraws`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `withdraw_method_inputs`
--
ALTER TABLE `withdraw_method_inputs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `withdraw_method_options`
--
ALTER TABLE `withdraw_method_options`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `withdraw_payment_methods`
--
ALTER TABLE `withdraw_payment_methods`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admins`
--
ALTER TABLE `admins`
  ADD CONSTRAINT `admins_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `role_permissions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `blog_categories`
--
ALTER TABLE `blog_categories`
  ADD CONSTRAINT `blog_categories_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `blog_informations`
--
ALTER TABLE `blog_informations`
  ADD CONSTRAINT `blog_informations_blog_category_id_foreign` FOREIGN KEY (`blog_category_id`) REFERENCES `blog_categories` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `blog_informations_blog_id_foreign` FOREIGN KEY (`blog_id`) REFERENCES `blogs` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `blog_informations_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `cities`
--
ALTER TABLE `cities`
  ADD CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`),
  ADD CONSTRAINT `cities_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);

--
-- Constraints for table `cookie_alerts`
--
ALTER TABLE `cookie_alerts`
  ADD CONSTRAINT `cookie_alerts_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `faqs`
--
ALTER TABLE `faqs`
  ADD CONSTRAINT `faqs_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `footer_contents`
--
ALTER TABLE `footer_contents`
  ADD CONSTRAINT `footer_texts_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `page_contents`
--
ALTER TABLE `page_contents`
  ADD CONSTRAINT `page_contents_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `page_contents_page_id_foreign` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `popups`
--
ALTER TABLE `popups`
  ADD CONSTRAINT `popups_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `quick_links`
--
ALTER TABLE `quick_links`
  ADD CONSTRAINT `quick_links_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `seos`
--
ALTER TABLE `seos`
  ADD CONSTRAINT `seos_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `states`
--
ALTER TABLE `states`
  ADD CONSTRAINT `country_region_final` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
