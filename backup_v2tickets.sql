/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-12.2.2-MariaDB, for osx10.21 (arm64)
--
-- Host: localhost    Database: v2tickets
-- ------------------------------------------------------
-- Server version	12.2.2-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `about_us_sections`
--

DROP TABLE IF EXISTS `about_us_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `about_us_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `subtitle` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `about_us_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `about_us_sections` WRITE;
/*!40000 ALTER TABLE `about_us_sections` DISABLE KEYS */;
INSERT INTO `about_us_sections` VALUES
(3,8,'63d6263036d9d.png','Know more about the Culture of Events','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium euismod ligula,','<div class=\"feature-item mt-30\" style=\"margin: 30px 0px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Free Events Host</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>\r\n<div class=\"feature-item\" style=\"margin: 0px 0px 30px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Build-in Video conference Platform</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>\r\n<div class=\"feature-item\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none; display: flex; background-image: initial; background-position: initial; background-size: initial; background-repeat: initial; background-attachment: initial; background-origin: initial; background-clip: initial; color: rgb(69, 69, 69); font-family: Roboto, sans-serif; font-size: 16px;\">\r\n<div class=\"feature-content\" style=\"margin: 0px; padding: 0px; border: none; outline: none; box-shadow: none;\">\r\n<h4 style=\"margin-right: 0px; margin-bottom: 12px; margin-left: 0px; padding: 0px; border: none; outline: none; box-shadow: none; line-height: 1.46; font-size: 22px; font-family: var(--heading-font); color: var(--heading-color);\">Connect your attendees with events</h4>\r\n<p style=\"padding: 0px; border: none; outline: none; box-shadow: none;\">Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium</p>\r\n</div>\r\n</div>','2021-12-19 06:23:27','2023-05-20 12:00:38');
/*!40000 ALTER TABLE `about_us_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `action_sections`
--

DROP TABLE IF EXISTS `action_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `action_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `background_image` varchar(255) NOT NULL,
  `first_title` varchar(255) DEFAULT NULL,
  `second_title` varchar(255) DEFAULT NULL,
  `first_button` varchar(255) DEFAULT NULL,
  `first_button_url` varchar(255) DEFAULT NULL,
  `second_button` varchar(255) DEFAULT NULL,
  `second_button_url` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `action_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `action_sections` WRITE;
/*!40000 ALTER TABLE `action_sections` DISABLE KEYS */;
INSERT INTO `action_sections` VALUES
(3,8,'61a6fe5929b63.jpg','Are You Ready for This Offer?','50% Offer for Very First 50 Students and Mentors.','Become A Student','https://codecanyon.kreativdev.com/coursela/user/signup','All Courses','https://codecanyon.kreativdev.com/coursela/user/courses','6280a19f2edad.png','2021-11-30 22:47:21','2022-05-15 00:45:51');
/*!40000 ALTER TABLE `action_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `admins` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `role_id` bigint(20) unsigned DEFAULT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` text DEFAULT NULL,
  `address` text DEFAULT NULL,
  `details` longtext DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `admins_username_unique` (`username`),
  UNIQUE KEY `admins_email_unique` (`email`),
  KEY `admins_role_id_foreign` (`role_id`),
  CONSTRAINT `admins_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `role_permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES
(1,NULL,'Duty','Tickets','1632736531.png','admin','admin@duty.do','082319382109','Santo Domingo',NULL,'$2y$10$L8Cq/DkxDUS/UQBPx1vlXuvkCReRwluC0Oljzy5AIpZLArVyEpzre',1,NULL,'2025-12-06 05:38:17'),
(2,4,'Davila','Ramos','6933c1a228fe7.jpg','davila','davila@duty.do',NULL,NULL,NULL,'$2y$10$AxO4Old0j9dkSVYTyEdZzOaPy.Pjlw173ew9eRG76i.w75solrxZa',1,'2025-12-06 05:39:46','2025-12-06 05:39:46'),
(3,4,'Hector','Perreaux','695171694bb5d.gif','hector','hector@duty.do',NULL,NULL,NULL,'$2y$10$3IgLJuJX4N5Tm14LwxtXxOgGMDUYoDXwEf6lnRfk4zPoBCY3nZdHq',1,'2025-12-28 18:05:29','2025-12-28 18:15:34');
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `advertisements`
--

DROP TABLE IF EXISTS `advertisements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `advertisements` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ad_type` varchar(255) NOT NULL,
  `resolution_type` smallint(5) unsigned NOT NULL COMMENT '1 => 300 x 250, 2 => 300 x 600, 3 => 728 x 90',
  `image` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `slot` varchar(50) DEFAULT NULL,
  `views` int(10) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `advertisements`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `advertisements` WRITE;
/*!40000 ALTER TABLE `advertisements` DISABLE KEYS */;
/*!40000 ALTER TABLE `advertisements` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `artists`
--

DROP TABLE IF EXISTS `artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `artists` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `details` text DEFAULT NULL,
  `facebook` varchar(255) DEFAULT NULL,
  `twitter` varchar(255) DEFAULT NULL,
  `linkedin` varchar(255) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `amount` decimal(20,2) NOT NULL DEFAULT 0.00,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `artists_username_unique` (`username`),
  UNIQUE KEY `artists_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `artists`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `artists` WRITE;
/*!40000 ALTER TABLE `artists` DISABLE KEYS */;
/*!40000 ALTER TABLE `artists` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `basic_settings`
--

DROP TABLE IF EXISTS `basic_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `basic_settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uniqid` int(10) unsigned NOT NULL DEFAULT 12345,
  `favicon` varchar(255) DEFAULT NULL,
  `logo` varchar(255) DEFAULT NULL,
  `website_title` varchar(255) DEFAULT NULL,
  `email_address` varchar(255) DEFAULT NULL,
  `contact_number` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `latitude` decimal(8,5) DEFAULT NULL,
  `longitude` decimal(8,5) DEFAULT NULL,
  `theme_version` smallint(5) unsigned NOT NULL,
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
  `disqus_status` tinyint(3) unsigned DEFAULT NULL,
  `disqus_short_name` varchar(255) DEFAULT NULL,
  `google_recaptcha_status` tinyint(4) DEFAULT NULL,
  `google_recaptcha_site_key` varchar(255) DEFAULT NULL,
  `google_recaptcha_secret_key` varchar(255) DEFAULT NULL,
  `facebook_login_status` int(11) DEFAULT 0,
  `facebook_app_id` varchar(255) DEFAULT NULL,
  `facebook_app_secret` varchar(255) DEFAULT NULL,
  `google_login_status` int(11) DEFAULT 0,
  `google_client_id` varchar(255) DEFAULT NULL,
  `google_client_secret` varchar(255) DEFAULT NULL,
  `whatsapp_status` tinyint(3) unsigned DEFAULT NULL,
  `whatsapp_number` varchar(20) DEFAULT NULL,
  `whatsapp_header_title` varchar(255) DEFAULT NULL,
  `whatsapp_popup_status` tinyint(3) unsigned DEFAULT NULL,
  `whatsapp_popup_message` text DEFAULT NULL,
  `maintenance_img` varchar(255) DEFAULT NULL,
  `maintenance_status` tinyint(4) DEFAULT NULL,
  `maintenance_msg` text DEFAULT NULL,
  `bypass_token` varchar(255) DEFAULT NULL,
  `footer_logo` varchar(255) DEFAULT NULL,
  `preloader` varchar(255) DEFAULT NULL,
  `admin_theme_version` varchar(10) NOT NULL DEFAULT 'light',
  `features_section_image` varchar(255) DEFAULT NULL,
  `testimonials_section_image` varchar(255) DEFAULT NULL,
  `course_categories_section_image` varchar(255) DEFAULT NULL,
  `notification_image` varchar(255) DEFAULT NULL,
  `google_adsense_publisher_id` varchar(255) DEFAULT NULL,
  `shop_status` tinyint(4) DEFAULT 1 COMMENT '1 - active, 0 - deactive',
  `catalog_mode` tinyint(4) DEFAULT 1 COMMENT '1 - active, 0 - deactive',
  `is_shop_rating` tinyint(4) DEFAULT 1 COMMENT '1 - active, 0 - deactive',
  `shop_guest_checkout` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1 - active, 0 - deactive',
  `shop_tax` float DEFAULT NULL,
  `tax` double(8,2) DEFAULT 0.00,
  `commission` double(8,2) DEFAULT 0.00,
  `marketplace_commission` decimal(5,2) NOT NULL DEFAULT 5.00,
  `organizer_email_verification` int(11) NOT NULL DEFAULT 0,
  `organizer_admin_approval` int(11) NOT NULL DEFAULT 0,
  `admin_approval_notice` longtext DEFAULT NULL,
  `timezone` varchar(255) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `event_guest_checkout_status` int(11) DEFAULT 0 COMMENT '0=deactive, 1=active',
  `how_ticket_will_be_send` varchar(255) DEFAULT 'inbackground',
  `google_map_status` tinyint(4) NOT NULL DEFAULT 0,
  `google_map_api_key` varchar(255) DEFAULT NULL,
  `google_map_radius` varchar(255) DEFAULT NULL,
  `event_country_status` tinyint(4) NOT NULL DEFAULT 0,
  `event_state_status` tinyint(4) NOT NULL DEFAULT 0,
  `mobile_app_logo` varchar(255) DEFAULT NULL,
  `mobile_breadcrumb_overlay_colour` varchar(255) DEFAULT NULL,
  `mobile_breadcrumb_overlay_opacity` varchar(255) DEFAULT NULL,
  `mobile_primary_colour` varchar(255) DEFAULT NULL,
  `mobile_favicon` varchar(255) DEFAULT NULL,
  `firebase_admin_json` varchar(255) DEFAULT NULL,
  `app_google_map_status` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `basic_settings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `basic_settings` WRITE;
/*!40000 ALTER TABLE `basic_settings` DISABLE KEYS */;
INSERT INTO `basic_settings` VALUES
(2,12345,'692280bce3c86.png','692282c1ccff1.png','Duty','tickets@duty.do','+1 (849) 917-4205','Santo Domingo',18.48004,-69.98808,1,'RD$','left','DOP','right',1.00,'FF0000','030A15',0.80,1,'mail.duty.do',587,'TLS','tickets@duty.do','CYt}Y}1VSHth8ro[','tickets@duty.do','Duty Tickets','admin@duty.do','69403c13b285d.jpg',0,'evento-6',0,'6LcCWGgnAAAAADgP1vWv-VXVVrdIERCECIWAOThC','6LcCWGgnAAAAAM2mM9Mbe4Y04GNZdOzu-9BQBas6',0,'643057404544999','f59e1a04cc1e5ebf95d880dea77c5815',0,'308392347627-t2eosbvgh68hvi1amq546b7iu6ndnbs4.apps.googleusercontent.com','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',0,'+880 1686321-356','Hi, there!',1,'If you have any issues, let us know.','1632725312.png',0,'We are upgrading our site. We will come back soon. \r\nPlease stay with us.\r\nThank you.','secret','692282b8881b9.png','63cbb14274c51.gif','light','1633502472.jpg','61bf1ed024d95.png','61bf1fc25a8f6.jpg','619b7d5e5e9df.png','',0,1,1,0,0,0.00,0.00,5.00,1,1,'Your account is deactivated or pending now please get in touch with admin.','America/Santo_Domingo','2025-12-06 05:48:06',0,'instant',0,'AIzaSyBh-Q9sZzK43b6UssN6vCDrdwgWv4NOL68','747503',0,0,'694255f8d960e.png','000000','0.9','FF0000','69403b2debe13.png','694265081ea21.json',1);
/*!40000 ALTER TABLE `basic_settings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `blog_categories`
--

DROP TABLE IF EXISTS `blog_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `serial_number` mediumint(8) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `blog_categories_language_id_foreign` (`language_id`),
  CONSTRAINT `blog_categories_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `blog_categories` WRITE;
/*!40000 ALTER TABLE `blog_categories` DISABLE KEYS */;
INSERT INTO `blog_categories` VALUES
(36,8,'Business','business',1,1,'2021-10-12 22:51:29','2023-05-07 10:14:18'),
(37,8,'Conference','conference',1,2,'2021-10-12 22:51:38','2023-05-07 10:14:01'),
(38,8,'Wedding','wedding',1,3,'2021-10-12 22:51:52','2023-05-11 04:34:57'),
(43,8,'Others','others',1,4,'2022-04-05 05:50:10','2022-05-15 03:12:27');
/*!40000 ALTER TABLE `blog_categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `blog_informations`
--

DROP TABLE IF EXISTS `blog_informations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blog_informations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `blog_category_id` bigint(20) unsigned NOT NULL,
  `blog_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `author` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `blog_informations_language_id_foreign` (`language_id`),
  KEY `blog_informations_blog_category_id_foreign` (`blog_category_id`),
  KEY `blog_informations_blog_id_foreign` (`blog_id`),
  CONSTRAINT `blog_informations_blog_category_id_foreign` FOREIGN KEY (`blog_category_id`) REFERENCES `blog_categories` (`id`) ON DELETE CASCADE,
  CONSTRAINT `blog_informations_blog_id_foreign` FOREIGN KEY (`blog_id`) REFERENCES `blogs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `blog_informations_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blog_informations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `blog_informations` WRITE;
/*!40000 ALTER TABLE `blog_informations` DISABLE KEYS */;
/*!40000 ALTER TABLE `blog_informations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `blogs`
--

DROP TABLE IF EXISTS `blogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `blogs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `image` varchar(255) NOT NULL,
  `serial_number` mediumint(8) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blogs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `blogs` WRITE;
/*!40000 ALTER TABLE `blogs` DISABLE KEYS */;
/*!40000 ALTER TABLE `blogs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `bookings`
--

DROP TABLE IF EXISTS `bookings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `bookings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(255) DEFAULT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `order_number` varchar(255) DEFAULT NULL,
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
  `variation` text DEFAULT NULL,
  `price` float(8,2) DEFAULT NULL,
  `quantity` varchar(255) DEFAULT NULL,
  `discount` float DEFAULT NULL,
  `tax` float(8,2) DEFAULT 0.00,
  `commission` float(8,2) DEFAULT 0.00,
  `early_bird_discount` float DEFAULT NULL,
  `currencyText` varchar(255) DEFAULT NULL,
  `currencyTextPosition` varchar(255) DEFAULT NULL,
  `currencySymbol` varchar(255) DEFAULT NULL,
  `currencySymbolPosition` varchar(255) DEFAULT NULL,
  `paymentMethod` varchar(255) DEFAULT NULL,
  `gatewayType` varchar(255) DEFAULT NULL,
  `paymentStatus` varchar(255) DEFAULT NULL,
  `is_transferable` tinyint(1) NOT NULL DEFAULT 1,
  `is_listed` tinyint(1) NOT NULL DEFAULT 0,
  `listing_price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `invoice` varchar(255) DEFAULT NULL,
  `attachmentFile` varchar(255) DEFAULT NULL,
  `event_date` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `tax_percentage` double(8,2) DEFAULT 0.00,
  `commission_percentage` double(8,2) DEFAULT 0.00,
  `scan_status` int(11) NOT NULL DEFAULT 0 COMMENT '1=scanned, 0 = not scan yet',
  `scanned_tickets` varchar(255) DEFAULT NULL,
  `conversation_id` varchar(255) DEFAULT NULL,
  `fcm_token` text DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=362 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bookings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `bookings` WRITE;
/*!40000 ALTER TABLE `bookings` DISABLE KEYS */;
INSERT INTO `bookings` VALUES
(206,'45','6941b77dafa9a',NULL,'134',31,'Milauri','Paulino','milipaulino4@gmail.com','8295191771','Dominican Republic','DO-Santo Domingo','Santo Domingo','Santo Domingo','C. Mercedes','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"UP9jamOG3\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"86Qjln1w3\"}]',400.00,'2',400,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6941b77dafa9a.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-16 19:48:13','2025-12-16 19:48:14',10.00,5.00,0,NULL,NULL,NULL),
(207,'guest','6941ba509a4e6',NULL,'134',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,NULL,NULL,'Calle 1','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"ubNXp4juC\"}]',400.00,'1',0,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6941ba509a4e6.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 01:00:16','2025-12-17 01:00:17',10.00,5.00,0,NULL,NULL,NULL),
(208,'46','6941bc8dafd96',NULL,'134',31,'Adrian','Torres','adrian50-50@hotmail.com','8092997085','Dominican Republic',NULL,NULL,NULL,'NA','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"Er0L7Mf7X\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"kGh2A53fN\"}]',400.00,'2',400,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6941bc8dafd96.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-16 20:09:49','2025-12-21 03:37:32',10.00,5.00,0,'[\"Er0L7Mf7X\",\"kGh2A53fN\"]',NULL,NULL),
(209,'48','6941ee3ba9b50',NULL,'134',31,'Jeffrey','Ynoa','jeeffydn@gmail.com','8495399704','Domincan Republic',NULL,NULL,NULL,'Leonor Feltz #11','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"DeO3vvz8l\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"8QUvPnPnx\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"0durCi8Kg\"}]',600.00,'3',600,60.00,30.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6941ee3ba9b50.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-16 23:41:47','2025-12-21 05:20:41',10.00,5.00,0,'[\"DeO3vvz8l\",\"8QUvPnPnx\",\"0durCi8Kg\"]',NULL,NULL),
(210,'guest','6941fccfbe51e',NULL,'134',31,'Smarlin','Mejía','smamejia@outlook.com','8096136411','República Dominicana','Santo Domingo','Santo Domingo Este','Santo Domingo Este','Invivienda','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"gCYQaQcqL\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"od75QdpRa\"}]',400.00,'2',400,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6941fccfbe51e.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 00:43:59','2025-12-21 03:20:36',10.00,5.00,0,'[\"gCYQaQcqL\",\"od75QdpRa\"]',NULL,NULL),
(211,'47','6942008142432',NULL,'134',31,'Dilencio','Vargas','dilenciovarlirz@gmail.com','8496569508','Dominican Republic','Santo Domingo','Santo Domingo Norte','Santo Domingo Norte','Carretera de Jacagua, Residencial Praderas del Arroyo','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"g1hqSz8km\"}]',200.00,'1',200,20.00,10.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6942008142432.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 00:59:45','2025-12-17 00:59:45',10.00,5.00,0,NULL,NULL,NULL),
(212,'guest','69420e8a10b44',NULL,'134',31,'Joan','Pérez Pujols','Joanfperezp@gmail.com','8294185980','Rep dom',NULL,NULL,NULL,'C/Agueda Suarez, res LP9, Alameda','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"iKBvmjIKw\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"ucjsnsx0d\"}]',400.00,'2',400,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69420e8a10b44.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 01:59:38','2025-12-21 03:21:07',10.00,5.00,0,'[\"iKBvmjIKw\",\"ucjsnsx0d\"]',NULL,NULL),
(213,'43','69424d97dd79c',NULL,'134',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"a6gfovU66\"}]',400.00,'1',0,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69424d97dd79c.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 06:28:39','2025-12-17 06:28:40',10.00,5.00,0,NULL,NULL,NULL),
(214,'43','69424d99e776f',NULL,'134',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"6oj95tJCl\"}]',400.00,'1',0,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69424d99e776f.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-17 06:28:41','2025-12-20 20:12:34',10.00,5.00,0,'[\"6oj95tJCl\"]',NULL,NULL),
(216,'guest','6944b33f8612d',NULL,'134',31,'Nicolette','Santana','carlasantanam8@gmail.com','8496231619','República Dominicana','Santo Domingo','Distrito Nacional','Distrito Nacional','Calle Francisco Villaespesa 217','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"AyHYT909V\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"7f6IC5ypd\"}]',400.00,'2',400,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6944b33f8612d.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-19 02:06:55','2025-12-21 06:00:02',10.00,5.00,0,'[\"AyHYT909V\",\"7f6IC5ypd\"]',NULL,NULL),
(217,'guest','6946c784a84f5',NULL,'134',31,'Emmanuel','Arias','juniorwkx@gmail.com','8095435058','Dominican Republic',NULL,NULL,NULL,'Roberto Pastoriza 853','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"XF0RXLMxm\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"PgZxRUO7x\"}]',800.00,'2',0,80.00,40.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6946c784a84f5.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-20 15:57:56','2025-12-21 05:17:20',10.00,5.00,0,'[\"PgZxRUO7x\",\"XF0RXLMxm\"]',NULL,NULL),
(218,'45','6946fa5da2df9',NULL,'134',31,'Milauri','Paulino','milipaulino4@gmail.com','8295191771','Dominican Republic','DO-Santo Domingo','Santo Domingo','Santo Domingo','C. Mercedes 408','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"GBrHmj2TP\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"h5qV8jcD7\"}]',800.00,'2',0,80.00,40.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'6946fa5da2df9.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-20 19:34:53','2025-12-20 19:34:54',10.00,5.00,0,NULL,NULL,NULL),
(219,'guest','69472957bd1fd',NULL,'134',31,'Nikaully','Mirambeaux','nikaully.mirambeaux@gmail.com','8299246329','Republica Dominicana','Santo Domingo','Santo Domingo','Santo Domingo','Cacique 29','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"mCvWTxoqe\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"FvgNYzL9S\"}]',800.00,'2',0,80.00,40.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69472957bd1fd.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-20 22:55:19','2025-12-20 22:55:20',10.00,5.00,0,NULL,NULL,NULL),
(220,'guest','69476746be02f',NULL,'134',31,'Carolay','Sosa','Carolaysosa8@gmail.com','8296165773','Julio César linval',NULL,NULL,NULL,'Calle Julio César linval #77','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"gww0JmEEQ\"}]',400.00,'1',0,40.00,20.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69476746be02f.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-21 03:19:34','2025-12-21 05:21:33',10.00,5.00,0,'[\"gww0JmEEQ\"]',NULL,NULL),
(221,'guest','69477e43571b5',NULL,'134',31,'Lineuris','Jimenez','Lineurisjimenez@gmail.com','8097107876','Dominican Republic','Santo Domingo','Santo Domingo','Santo Domingo','Los ríos','[{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"DoU8uOERc\"},{\"ticket_id\":210,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"400\",\"scan_status\":0,\"unique_id\":\"bWVQpSJiO\"}]',800.00,'2',0,80.00,40.00,0,'DOP','right','$','left','Stripe','online','completed',1,0,0.00,'69477e43571b5.pdf',NULL,'Sat, Dec 20, 2025 08:00pm','2025-12-21 04:57:39','2025-12-21 05:09:03',10.00,5.00,0,'[\"DoU8uOERc\",\"bWVQpSJiO\"]',NULL,NULL),
(222,'guest','694eda361c934',NULL,'135',31,'Dawrin J','Caba','dawrinjcaba@hotmail.com','8293803895','Dominican Republic','Santo Domingo','Distrito Nacional','Distrito Nacional','Av. Privada #34. Los Cacicazgos. Distrito Nacional.','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"c7gEVgA9m\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'694eda361c934.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-26 18:55:50','2025-12-26 18:55:51',0.00,0.00,0,NULL,NULL,NULL),
(223,'50','694ef5d6c9c5b',NULL,'135',31,'Juan Diego Perez','De Los Santos','juandiego05@gmail.com','8098175888','República Dominicana',NULL,'Distrito Nacional','Distrito Nacional','Calle Presidente Hipólito Irigoyen #3\r\nResidencial Maite 403','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"AwRvdr8A3\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'694ef5d6c9c5b.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-26 20:53:42','2026-01-01 06:25:37',0.00,0.00,0,'[\"AwRvdr8A3\"]',NULL,NULL),
(224,'51','69504d7e474ba',NULL,'135',31,'Ivan','Noboa','ivan.noboa@gmail.com','8093908777','Dominican Republic','DN','Santo Domingo','Santo Domingo','Av bolivar 814 apt 9b','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"KsoOzJhty\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"WTRj7UrB7\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"1T8NlviTy\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"zvPd8fhSc\"}]',2800.00,'4',0,0.00,0.00,1200,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'69504d7e474ba.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-27 21:19:58','2026-01-01 06:53:40',0.00,0.00,0,'[\"KsoOzJhty\",\"WTRj7UrB7\",\"1T8NlviTy\",\"zvPd8fhSc\"]',NULL,NULL),
(227,'52','6951cecbacb77',NULL,'135',31,'Erick','Benjamín','erick.benjamin.leon@gmail.com','8293262530','República Dominicana',NULL,'Santo Domingo','Santo Domingo','Magalis Estrella','[{\"ticket_id\":213,\"early_bird_dicount\":0,\"name\":\"Guest\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"XVidutP3C\"},{\"ticket_id\":213,\"early_bird_dicount\":0,\"name\":\"Guest\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"hrZtuNyEk\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6951cecbacb77.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-29 00:43:55','2025-12-29 00:43:56',0.00,0.00,0,NULL,NULL,NULL),
(229,'49','6953ee8cdd43b',NULL,'135',31,'Edgar','Garcia','edgar255075@gmail.com','8296610318','Dominican Republic','Santo Domingo','Santo Domingo Norte','Santo Domingo Norte','Calle Segunda\r\nCasa #2','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"x67wcse50\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"BqWYIK63L\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6953ee8cdd43b.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-30 15:23:56','2026-01-01 06:35:50',0.00,0.00,0,'[\"x67wcse50\",\"BqWYIK63L\"]',NULL,NULL),
(230,'53','69547b0676325',NULL,'135',31,'Maxwell','Morrison','maxflips16@gmail.com','7633169540','United States','Minnesota','Saint paul','Saint paul','1277 Farrington st, Saint Paul 55117','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"rfv3ERxDt\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'69547b0676325.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 01:23:18','2026-01-01 03:48:43',0.00,0.00,0,'[\"rfv3ERxDt\"]',NULL,NULL),
(231,'55','6955256624add',NULL,'135',31,'Victor','Hurtado','victor.hurtadomena@gmail.com','8297545854','Dominican Republic','Santo Domingo','Santo Domingo','Santo Domingo','Calle 1ra #19 Residencial Santo Domingo, 19','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"fsF99YlW3\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"yHp2jK9cQ\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955256624add.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 13:30:14','2026-01-01 04:28:49',0.00,0.00,0,'[\"fsF99YlW3\",\"yHp2jK9cQ\"]',NULL,NULL),
(232,'43','69552da609d90',NULL,'135',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":216,\"early_bird_dicount\":0,\"name\":\"Guestlist\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"4CdfZdnZr\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69552da609d90.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 14:05:26','2025-12-31 14:11:45',0.00,0.00,0,'[\"4CdfZdnZr\"]',NULL,NULL),
(233,'57','69553cbe7cc29',NULL,'135',31,'Rob','Santana','juniorwkx@gmail.com','8095435058','Republica Dominicana',NULL,NULL,NULL,'Roberto Pastoriza 800','[{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"kSIPhG3eQ\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"zIlQl5Mqb\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"pWblG9Opq\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"JeashUjpS\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"vddsJtoeX\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"9CRgrmmyO\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xzk9Bvr0x\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"hygUQnqmC\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"j5u46nvUY\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rWmRRQFtf\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"StC5rV6b4\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"U8HGLoswx\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"M5ovIUKft\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"B2vkyTE7y\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"sPNHoGgmS\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"SpCUUSirK\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"c4ZsU4rF6\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rkPSxHrO4\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"EB13mFczf\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"IvhYlKuRf\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"P6gpaVV9e\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"yxMDpI7C6\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"36q9vQSQY\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"bbjqgkOUp\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"QU8gp2PdO\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"2zKPoZnUE\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"gq1Di1DnH\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"IQXj1c2NH\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"vuoKInSCn\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"CAw3LZ6eV\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"5zlosQ35F\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qsqkEeWel\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"NJQux3wVX\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rOBLRQycr\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"XJWqxkgL2\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"OjmTKTYGl\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"seMTUyf0S\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"iG1uaOUyM\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"IAp1Auk9X\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"5mvm7SehD\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"MMaIv7JJb\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"ZgYJSMYUz\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"IWF7wU2Hd\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dnN2CJXGU\"},{\"ticket_id\":217,\"early_bird_dicount\":0,\"name\":\"Guestlist - Santana\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"jCDQuIYLU\"}]',0.00,'45',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69553cbe7cc29.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 15:09:50','2026-01-01 05:35:37',0.00,0.00,0,'[\"36q9vQSQY\",\"MMaIv7JJb\",\"9CRgrmmyO\",\"IAp1Auk9X\",\"iG1uaOUyM\",\"sPNHoGgmS\",\"rkPSxHrO4\",\"c4ZsU4rF6\",\"5mvm7SehD\",\"2zKPoZnUE\",\"vuoKInSCn\",\"seMTUyf0S\",\"OjmTKTYGl\",\"EB13mFczf\",\"IvhYlKuRf\",\"P6gpaVV9e\",\"j5u46nvUY\",\"hygUQnqmC\",\"vddsJtoeX\",\"XJWqxkgL2\",\"CAw3LZ6eV\"]',NULL,NULL),
(234,'58','69553fee27810',NULL,'135',31,'Ramses','Sultan','suhl.tnbookings@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"2bDr7S48l\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"AaVEs8jUM\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Hp7miNMGM\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"gpH8ZTgej\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"eoH3q5DML\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qgJqHjJyB\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rcnF7S9Bz\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qKA65RH5K\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"bPE31q931\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"VZcmPAJWH\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"hhUUGNRGl\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"tbIYU3meu\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"KTr3OXArH\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Td9LVUTFG\"},{\"ticket_id\":218,\"early_bird_dicount\":0,\"name\":\"Guestlist - Sultan\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"LMRqgwMrf\"}]',0.00,'15',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69553fee27810.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 15:23:26','2026-01-01 06:56:18',0.00,0.00,0,'[\"rcnF7S9Bz\",\"Hp7miNMGM\",\"eoH3q5DML\",\"gpH8ZTgej\",\"VZcmPAJWH\",\"hhUUGNRGl\",\"qKA65RH5K\",\"bPE31q931\"]',NULL,NULL),
(235,'60','69555722c6160',NULL,'135',31,'Alberto','Parada','saulalbertoparada@gmail.com','8296492347','Santo domingo','Santo domingo','Distrito nacional','Distrito nacional','Calle Francisco prats Ramírez','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"0nA0OKwkU\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'69555722c6160.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 17:02:26','2026-01-01 05:30:43',0.00,0.00,0,'[\"0nA0OKwkU\"]',NULL,NULL),
(236,'61','6955671e52058',NULL,'135',31,'Christ Austin','Lamour','Christaustinlamour@gmail.com','8296827297','Dominican Republic','Santo domingo','Zona colonial','Zona colonial','Calle 20 villa juana','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"BTcSqLVl8\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"QQC0iGdoV\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955671e52058.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 18:10:38','2026-01-01 06:57:32',0.00,0.00,0,'[\"BTcSqLVl8\",\"QQC0iGdoV\"]',NULL,NULL),
(237,'56','6955679352100',NULL,'135',31,'Martina','Occhi','martina.occhi2@unibo.it','+39 3341583686','Italia','Emilia Romagna','Imola','Imola','Via Forlì 21','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"ymsV6rrdH\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"02VMcEfIJ\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955679352100.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 18:12:35','2026-01-01 03:59:29',0.00,0.00,0,'[\"02VMcEfIJ\",\"ymsV6rrdH\"]',NULL,NULL),
(238,'62','69556b71b135a',NULL,'135',31,'Génesis','Blanco','genesisvanessablanco@gmail.com','8299865610','República Dominicana','Santo Domingo',NULL,NULL,'Paseo de los locutores 47','[{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"0gxEcHcyJ\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"YOSPd060H\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"4EpG2AAKQ\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"g1OrbUh7G\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"QZrFMQDd2\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"GxRRb8rAv\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"RyhZxeCP1\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rdCzthsr7\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"NyjKWMziu\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"01kpMudST\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"J33kM20MC\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"VBv1UTXyC\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"amq5FNMXS\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"td2iwW1Qo\"},{\"ticket_id\":219,\"early_bird_dicount\":0,\"name\":\"Guestlist - Genesis\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xjFAlDPZr\"}]',0.00,'15',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69556b71b135a.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 18:29:05','2026-01-01 07:23:27',0.00,0.00,0,'[\"QZrFMQDd2\",\"GxRRb8rAv\",\"RyhZxeCP1\",\"rdCzthsr7\",\"NyjKWMziu\",\"01kpMudST\",\"0gxEcHcyJ\",\"J33kM20MC\",\"VBv1UTXyC\",\"YOSPd060H\",\"g1OrbUh7G\",\"4EpG2AAKQ\"]',NULL,NULL),
(239,'43','6955793237ed2',NULL,'135',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":220,\"early_bird_dicount\":0,\"name\":\"Guestlist - Gianvald\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"M2wUO9aQa\"},{\"ticket_id\":220,\"early_bird_dicount\":0,\"name\":\"Guestlist - Gianvald\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"SX9qgVWv4\"},{\"ticket_id\":220,\"early_bird_dicount\":0,\"name\":\"Guestlist - Gianvald\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"hF5slE7Zl\"},{\"ticket_id\":220,\"early_bird_dicount\":0,\"name\":\"Guestlist - Gianvald\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"V7S9BiOwX\"}]',0.00,'4',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6955793237ed2.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 19:27:46','2026-01-01 06:52:53',0.00,0.00,0,'[\"V7S9BiOwX\",\"hF5slE7Zl\"]',NULL,NULL),
(240,'59','69558400a3326',NULL,'135',31,'Yamilet J.','Terrero Batista','yamilettb20@gmail.com','8092508999','República Dominicana',NULL,'Santos Domingo','Santos Domingo','C/mi Esfuerzo 5,','[{\"ticket_id\":221,\"early_bird_dicount\":0,\"name\":\"Guestlist - YJam\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"daiDCxoHa\"},{\"ticket_id\":221,\"early_bird_dicount\":0,\"name\":\"Guestlist - YJam\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"UhIh7bJ0Q\"},{\"ticket_id\":221,\"early_bird_dicount\":0,\"name\":\"Guestlist - YJam\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"XJ7OTZUlq\"},{\"ticket_id\":221,\"early_bird_dicount\":0,\"name\":\"Guestlist - YJam\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"DIoL3qElV\"},{\"ticket_id\":221,\"early_bird_dicount\":0,\"name\":\"Guestlist - YJam\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"9iJ9KYvvz\"}]',0.00,'5',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69558400a3326.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 20:13:52','2026-01-01 03:44:59',0.00,0.00,0,'[\"daiDCxoHa\",\"UhIh7bJ0Q\",\"XJ7OTZUlq\",\"DIoL3qElV\"]',NULL,NULL),
(241,'63','6955888219d98',NULL,'135',31,'Braulio','Paulino','braulioap1998@gmail.com','8299281086','Santo Domingo','Santo Domingo','Santo Domingo Oeste','Santo Domingo Oeste','Tomas Jaime 42 Manoguayabo Santo Domingo Oeste','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"Edf6Zhmpd\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"fe5YcIEiG\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955888219d98.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 20:33:06','2026-01-01 06:29:32',0.00,0.00,0,'[\"Edf6Zhmpd\",\"fe5YcIEiG\"]',NULL,NULL),
(242,'54','69558af500165',NULL,'135',31,'Jeremy','Caro','espiritado.innato9j@icloud.com','8098197795','Republica Dominicana','Distrito Nacional','Santo Domingo','Santo Domingo','Calle Santa Cris de Tenerife 54a, Santo Domingo','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"vBizxe2L9\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'69558af500165.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 20:43:33','2026-01-01 03:48:16',0.00,0.00,0,'[\"vBizxe2L9\"]',NULL,NULL),
(243,'45','695599716ea1d',NULL,'135',31,'Milauri','Paulino','milipaulino4@gmail.com','8295191771','Dominican Republic','DO-Santo Domingo','Santo Domingo','Santo Domingo','C. Mercedes 408','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"KAsHvr98f\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'695599716ea1d.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 21:45:21','2026-01-01 05:19:51',0.00,0.00,0,'[\"KAsHvr98f\"]',NULL,NULL),
(244,'43','6955a343ec9a2',NULL,'135',31,'Santana','Santaba','gian@monkey.com.do','809434234','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":222,\"early_bird_dicount\":0,\"name\":\"Guest List General\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Fll0gW9CC\"},{\"ticket_id\":222,\"early_bird_dicount\":0,\"name\":\"Guest List General\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"lgqhbS5eS\"},{\"ticket_id\":222,\"early_bird_dicount\":0,\"name\":\"Guest List General\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"lcORFEiYY\"}]',0.00,'3',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6955a343ec9a2.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 22:27:15','2026-01-01 06:49:38',0.00,0.00,0,'[\"Fll0gW9CC\",\"lcORFEiYY\"]',NULL,NULL),
(245,'66','6955a785b9f6e',NULL,'135',31,'caleb','deriel','jonathanjoestar775@hotmail.com','8298622667','Dominican Republic','santo domingo','Santo domingo','Santo domingo','Av tiradentes 96, distrito nacional','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"sNpfbMaGr\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"J6DJIZ4yf\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955a785b9f6e.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 22:45:25','2026-01-01 04:28:31',0.00,0.00,0,'[\"sNpfbMaGr\",\"J6DJIZ4yf\"]',NULL,NULL),
(246,'67','6955a93c8ac4c',NULL,'135',31,'Massiel','Tejeda','themazzy27@gmail.com','8496511528','Dominican Republic','Santo Domingo','Santo Domingo oeste','Santo Domingo oeste','Calle A#7 miosotis herrera','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"SCPeaC3MJ\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"SmzFwRmuq\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"XpZ6CdLSs\"}]',2100.00,'3',0,0.00,0.00,900,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955a93c8ac4c.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 22:52:44','2026-01-01 06:56:38',0.00,0.00,0,'[\"SCPeaC3MJ\",\"SmzFwRmuq\"]',NULL,NULL),
(247,'49','6955a94a6c427',NULL,'135',31,'Edgar','Garcia','edgar255075@gmail.com','8296610318','Dominican Republic','Santo Domingo','Santo Domingo Norte','Santo Domingo Norte','Calle Segunda\r\nCasa #2','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"lBqbz1zyF\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955a94a6c427.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 22:52:58','2026-01-01 08:24:37',0.00,0.00,0,'[\"lBqbz1zyF\"]',NULL,NULL),
(248,'68','6955acc721b44',NULL,'135',31,'Jeffry','Zabala Ramirez','jefffcito@gmail.com','8492096570','República Dominicana','Distrito Nacional','Santo Domingo','Santo Domingo','Juan Marichal #9 Los rios','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"CN7cnctT5\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955acc721b44.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 23:07:51','2026-01-01 06:30:18',0.00,0.00,0,'[\"CN7cnctT5\"]',NULL,NULL),
(249,'69','6955b08669bb2',NULL,'135',31,'Roberto','Rojas','angelfitdash@gmail.com','8499129101','Dominican Republic','Santo Domingo','Distrito Nacional','Distrito Nacional','Calle Juan Marichal #27','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"K4x124z3F\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955b08669bb2.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 23:23:50','2026-01-01 06:31:12',0.00,0.00,0,'[\"K4x124z3F\"]',NULL,NULL),
(250,'70','6955b0f09366f',NULL,'135',31,'Zion','Lowe','zionlowe7@gmail.com','3102567210','United States','California','Los Angeles','Los Angeles','1517 west 87th street','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"0ZxyFevk7\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"dAM3nhmkY\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955b0f09366f.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 23:25:36','2026-01-01 09:17:21',0.00,0.00,0,'[\"0ZxyFevk7\"]',NULL,NULL),
(251,'71','6955b6436ad8c',NULL,'135',31,'Brainer','Espinal Aquino','drbrainer156@gmail.com','8093014548','Rep.Dom','Distrito Nacional','Santo Domingo','Santo Domingo','Los ríos','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"H37kMhmqL\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955b6436ad8c.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 23:48:19','2026-01-01 06:30:47',0.00,0.00,0,'[\"H37kMhmqL\"]',NULL,NULL),
(252,'72','6955b7620620a',NULL,'135',31,'Emanuel','Duarte','durtanu@gmail.com','5708003557','United States','NY','Long Island City','Long Island City','4001 12th st\r\n3E','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"gRatI3HQx\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"5Rc915Sne\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955b7620620a.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2025-12-31 23:53:06','2026-01-01 05:31:42',0.00,0.00,0,'[\"gRatI3HQx\",\"5Rc915Sne\"]',NULL,NULL),
(253,'73','6955bd094e243',NULL,'135',31,'Daniel Antonio','De león Javier','daniel_d01@outlook.com','8299791666','Santo domingo',NULL,NULL,NULL,'C/ edif 16 apart 3D los ríos','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"UeX4Rll5q\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955bd094e243.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 00:17:13','2026-01-01 06:30:56',0.00,0.00,0,'[\"UeX4Rll5q\"]',NULL,NULL),
(254,'66','6955bf319b682',NULL,'135',31,'caleb','deriel','jonathanjoestar775@hotmail.com','8298622667','Dominican Republic','santo domingo','Santo domingo','Santo domingo','Av tiradentes 96, distrito nacional','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"K1FCOV2LA\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955bf319b682.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 00:26:25','2026-01-01 05:38:50',0.00,0.00,0,'[\"K1FCOV2LA\"]',NULL,NULL),
(255,'76','6955c9119e038',NULL,'135',31,'Jeison','Torres','jasontorreslapaix@gmail.com','8292834633','Dominican Republic',NULL,NULL,NULL,'Las praderas','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"prVxJQDfC\"},{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"fd5MD2hBA\"}]',1400.00,'2',0,0.00,0.00,600,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955c9119e038.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 01:08:33','2026-01-01 04:13:08',0.00,0.00,0,'[\"prVxJQDfC\",\"fd5MD2hBA\"]',NULL,NULL),
(256,'76','6955cdf9b5617',NULL,'135',31,'Jeison','Torres','jasontorreslapaix@gmail.com','8292834633','Dominican republic',NULL,NULL,NULL,'Las praderas','[{\"ticket_id\":212,\"early_bird_dicount\":300,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"I4tgWO4pu\"}]',700.00,'1',0,0.00,0.00,300,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'6955cdf9b5617.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 01:29:29','2026-01-01 04:13:27',0.00,0.00,0,'[\"I4tgWO4pu\"]',NULL,NULL),
(257,'78','69562211650bd',NULL,'135',31,'Jorge Luis','Alejo Herrera','jorgeluisalejoherrera120@gmail.com','8497107702','Santo Domingo','Santo Domingo','Santo Domingo','Santo Domingo','Costa Rica','[{\"ticket_id\":212,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"v3iRvmwpS\"}]',1000.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'69562211650bd.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 07:28:17','2026-01-01 07:29:05',0.00,0.00,0,'[\"v3iRvmwpS\"]',NULL,NULL),
(258,'79','695622dd9092b',NULL,'135',31,'Jean carlos','Jimenez','jean.abreuj@gmail.com','8492696609','Santo Domingo','Distrito nacional','Naco','Naco','Calle','[{\"ticket_id\":212,\"early_bird_dicount\":0,\"name\":\"General\",\"qty\":1,\"price\":\"1000\",\"scan_status\":0,\"unique_id\":\"yrngg9a6k\"}]',1000.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','Stripe','online','completed',1,0,0.00,'695622dd9092b.pdf',NULL,'Wed, Dec 31, 2025 10:00pm','2026-01-01 07:31:41','2026-01-01 07:32:59',0.00,0.00,0,'[\"yrngg9a6k\"]',NULL,NULL),
(259,'49','69588475df264',NULL,'136',31,'Edgar','Garcia','edgar255075@gmail.com','8296610318','Dominican Republic','Santo Domingo','Santo Domingo Norte','Santo Domingo Norte','Calle Segunda','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dM2eilC1U\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588475df264.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:52:37','2026-01-04 02:44:16',0.00,0.00,0,'[\"dM2eilC1U\"]',NULL,NULL),
(260,'71','6958858f18a11',NULL,'136',31,'Brainer','Espinal Aquino','drbrainer156@gmail.com','8093014548','República dominica','Santo domingo','Distrito nacional','Distrito nacional','Kilómetro 9','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"PDIGROU3A\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958858f18a11.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:57:19','2026-01-04 03:12:55',0.00,0.00,0,'[\"PDIGROU3A\"]',NULL,NULL),
(261,'82','6958859cdaf18',NULL,'136',31,'Diego','Rojas','diegoguillen0105@gmail.com','8297746020','Rd',NULL,'Santo Domingo','Santo Domingo','Santo Domingo','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"mFpJHEKoa\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958859cdaf18.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:57:32','2026-01-03 02:57:33',0.00,0.00,0,NULL,NULL,NULL),
(262,'83','695885ca93678',NULL,'136',31,'sebastián','marmolejos','sbmarmolejos@gmail.com',NULL,'santo domingo','distrito nacional','santo domingo','santo domingo','arroyo hondo, arroyo viejo','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"LCQA19pdO\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"HGuizoZMy\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"AywKQm2IV\"}]',0.00,'3',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695885ca93678.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:58:18','2026-01-03 02:58:19',0.00,0.00,0,NULL,NULL,NULL),
(263,'80','6958861de851c',NULL,'136',31,'John','Lugo','johnldiaz07@gmail.com','8295139675','República Dominicana',NULL,'Santo Domingo','Santo Domingo','Ave. Tiradentes','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"nPUmMyxrk\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"gbIQr697W\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958861de851c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:59:41','2026-01-04 04:17:28',0.00,0.00,0,'[\"nPUmMyxrk\",\"gbIQr697W\"]',NULL,NULL),
(264,'44','695886221b005',NULL,'136',31,'Davila Esperanza','Paulino Ramos','daavilaramos@gmail.com','8293413175','Dominican Republic',NULL,'Santo Domingo Este','Santo Domingo Este','Carr. Mella, Alma Rosa','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"kor19PM54\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695886221b005.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:59:46','2026-01-03 02:59:46',0.00,0.00,0,NULL,NULL,NULL),
(265,'68','6958862b8e367',NULL,'136',31,'Jeffry','Zabala Ramirez','jefffcito@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dNhfmglWe\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958862b8e367.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 02:59:55','2026-01-04 03:13:04',0.00,0.00,0,'[\"dNhfmglWe\"]',NULL,NULL),
(266,'68','6958878d75bf8',NULL,'136',31,'Jeffry','Zabala Ramirez','jefffcito@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"P4PAnqgfq\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958878d75bf8.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:05:49','2026-01-03 03:05:49',0.00,0.00,0,NULL,NULL,NULL),
(267,'85','695887a6e5689',NULL,'136',31,'Luis','M','beltre90@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"BNkDlICFI\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695887a6e5689.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:06:14','2026-01-03 03:06:15',0.00,0.00,0,NULL,NULL,NULL),
(268,'44','695887add2c86',NULL,'136',31,'Davila Esperanza','Paulino Ramos','daavilaramos@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"N6NoTFGGT\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695887add2c86.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:06:21','2026-01-03 03:06:22',0.00,0.00,0,NULL,NULL,NULL),
(269,'73','695887ee8bfe4',NULL,'136',31,'Daniel Antonio','De león Javier','daniel_d01@outlook.com','8299791666','Santo domingo',NULL,NULL,NULL,'Calle D edif 16 los ríos','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"90IRVca9v\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695887ee8bfe4.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:07:26','2026-01-04 03:13:09',0.00,0.00,0,'[\"90IRVca9v\"]',NULL,NULL),
(270,'44','6958888ae008b',NULL,'136',31,'Davila Esperanza','Paulino Ramos','daavilaramos@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Qu5hDG16X\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958888ae008b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:10:02','2026-01-03 03:10:03',0.00,0.00,0,NULL,NULL,NULL),
(271,'87','695888b0564f9',NULL,'136',31,'Patricia','Garcia','patriciag8002@gmail.com','8297749600','República Dominicana','Santo Domingo','Distrito Nacional','Distrito Nacional','Renacimiento, distrito nacional','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"5ktWfLTxW\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695888b0564f9.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:10:40','2026-01-04 03:18:48',0.00,0.00,0,'[\"5ktWfLTxW\"]',NULL,NULL),
(272,'81','695888b54c832',NULL,'136',31,'Joel Francisco','Ramirez alvarez','alvarezjoel923@gmail.com','8294640449',NULL,NULL,'Santo Domingo','Santo Domingo',NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"jr9llAnE5\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695888b54c832.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:10:45','2026-01-03 03:10:45',0.00,0.00,0,NULL,NULL,NULL),
(273,'48','695888bd96b4f',NULL,'136',31,'Jeffrey','Ynoa','jeeffydn@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"aUeMaOLbR\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"LJIsqSgrH\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"yezsOBeCl\"}]',0.00,'3',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695888bd96b4f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:10:53','2026-01-03 03:10:54',0.00,0.00,0,NULL,NULL,NULL),
(274,'84','69588a6089307',NULL,'136',31,'Miguel angel','Del valle bruno','m8498478202@gmail.com','8498478202','República dominicana','Santo domingo','Los ríos','Los ríos','Los ríos','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"nOez5v1IA\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588a6089307.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:17:52','2026-01-03 03:17:52',0.00,0.00,0,NULL,NULL,NULL),
(275,'89','69588a741899b',NULL,'136',31,'Luz','Castillo','luzmariacastillomarte13@gmail.com','8296602580','República Dominicana','Santo Domingo','Herrera','Herrera','Avenida México 194','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"JsaOKis12\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588a741899b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:18:12','2026-01-04 03:13:00',0.00,0.00,0,'[\"JsaOKis12\"]',NULL,NULL),
(276,'91','69588a977a3c5',NULL,'136',31,'Emil','Fernandez','emileduardofernandezarias@gmail.com','8299018959',NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"79ZTwJwXu\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588a977a3c5.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:18:47','2026-01-03 03:18:47',0.00,0.00,0,NULL,NULL,NULL),
(277,'92','69588b03481dd',NULL,'136',31,'Joel','Peralta','joel.peralta1696@gmail.com','8492829063','Dominican republic',NULL,NULL,NULL,'Calle m','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"mY8PB7rbq\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"UmELHLl5y\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dLwauexLd\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"7Xj200FXt\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"oKnPNQK4Q\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"vwQRdETGY\"}]',0.00,'6',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588b03481dd.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:20:35','2026-01-03 03:20:36',0.00,0.00,0,NULL,NULL,NULL),
(278,'90','69588bca7ffbe',NULL,'136',31,'Denis','Rivera','omegadr@yahoo.com','8099046622','Dominican Republic','Santo Domingo','Distrito Nacional','Distrito Nacional','Ave. Central #36\r\nEdificio Candy II, Apto. 301\r\n1er Piso. \r\n30 de Mayo','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qDEo8Dm7G\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588bca7ffbe.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:23:54','2026-01-03 03:23:54',0.00,0.00,0,NULL,NULL,NULL),
(279,'93','69588d29acc61',NULL,'136',31,'Juan','Toribio Lied','jtoribiolied@gmail.com','8293640407','República Dominicana','Distrito Nacional','Santo Domingo','Santo Domingo','Calle Bellas Artes 15 Residencial DM, apto. 502 El Millón, Santo Domingo, DN','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"EGHNC2pH3\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588d29acc61.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:29:45','2026-01-03 03:29:46',0.00,0.00,0,NULL,NULL,NULL),
(280,'94','69588e560e1cb',NULL,'136',31,'Isaías','Paredes','isaiasdelorbeparedes@gmail.com','8497536876','República Dominicana','Santo Domingo','Distrito Nacional','Distrito Nacional','Calle calas 5','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"zuaAYKrsK\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588e560e1cb.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:34:46','2026-01-04 03:19:06',0.00,0.00,0,'[\"zuaAYKrsK\"]',NULL,NULL),
(281,'96','69588f702355e',NULL,'136',31,'Step','Vazquez','johannavazquez7@gmail.com','8293914139','República Dominicana','Santo Domingo','27 de febrero','27 de febrero','27 de febrero','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"I3kGHw6Qn\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"BttHuNfQA\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"lC47wMnuq\"}]',0.00,'3',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588f702355e.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:39:28','2026-01-03 03:39:28',0.00,0.00,0,NULL,NULL,NULL),
(282,'95','69588f8a5c9e1',NULL,'136',31,'anthony','peguero','anthonpguero@gmail.com','8297239205','republica dominicana','distrito nacional','santo domingo','santo domingo',NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"nfUqtJK0k\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69588f8a5c9e1.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:39:54','2026-01-03 03:39:54',0.00,0.00,0,NULL,NULL,NULL),
(283,'97','695892c67c8af',NULL,'136',31,'MATEO','VASQUEZ','mathimparable@hotmail.com','8297205121','República Dominicana','Santo Domingo','Santo Domingo','Santo Domingo','Avenida Rmulo Betancourt','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"x2HVUHt27\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dI6Md88zm\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695892c67c8af.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 03:53:42','2026-01-03 03:53:42',0.00,0.00,0,NULL,NULL,NULL),
(284,'98','695899e5b132b',NULL,'136',31,'Hamlet','Almonte','hamlet.almonte@gmail.com','3479517580','USA',NULL,NULL,NULL,'2529 35th st','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"VSXg6FfSM\"},{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qohedRDMh\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695899e5b132b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:24:05','2026-01-04 02:54:09',0.00,0.00,0,'[\"VSXg6FfSM\",\"qohedRDMh\"]',NULL,NULL),
(285,'100','69589b87335ec',NULL,'136',31,'Jini','Luciano','jini_2d@hotmail.com','8295584114','República Dominicana',NULL,'Distrito Nacional','Distrito Nacional','Rafael hernandez 14','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"1DAbsPXWl\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69589b87335ec.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:31:03','2026-01-03 04:31:03',0.00,0.00,0,NULL,NULL,NULL),
(286,'101','69589bfa1399a',NULL,'136',31,'Kelvin','Ortiz gonzalez','mj3817133@gmail.com','8494677805','Santo domingo','Santo domingo','Santo domingo','Santo domingo','Calle las carreras','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"f2Hw8id3F\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69589bfa1399a.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:32:58','2026-01-04 04:18:41',0.00,0.00,0,'[\"f2Hw8id3F\"]',NULL,NULL),
(287,'102','69589c958cebf',NULL,'136',31,'Jhon','Chalinger','patax22mh@gmail.com','8093952457','Republica Dominicana','Santo Domingo','Distrito nacional','Distrito nacional','C/ General Cabral #109 zona colonial','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"w4jrIKpW0\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69589c958cebf.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:35:33','2026-01-04 04:18:50',0.00,0.00,0,'[\"w4jrIKpW0\"]',NULL,NULL),
(288,'105','69589ed0640ad',NULL,'136',31,'Green','Muñoz','greenmunoz61@gmail.com','8494677805','Usa','NJ','New Jersey','New Jersey','310 montclair av, Newark NJ','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"V341UeY70\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69589ed0640ad.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:45:04','2026-01-03 04:45:04',0.00,0.00,0,NULL,NULL,NULL),
(289,'106','6958a0764c7d5',NULL,'136',31,'Angel','Pereyra','angelpereyra1307@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"pFLatbbx3\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958a0764c7d5.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:52:06','2026-01-03 04:52:06',0.00,0.00,0,NULL,NULL,NULL),
(290,'108','6958a1ec162b9',NULL,'136',31,'Juairin','Payano','ko8361907@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"0mel0Pi0F\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958a1ec162b9.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 04:58:20','2026-01-04 04:15:37',0.00,0.00,0,'[\"0mel0Pi0F\"]',NULL,NULL),
(291,'109','6958a36d19bfc',NULL,'136',31,'Roberson','Jose','josebaez1988@hotmail.com','8494677805','República dominicana','Santo domingo','Distrito nacional','Distrito nacional','C/ vicente celestino #115 zona colonial','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"OZGKzVl4U\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958a36d19bfc.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 05:04:45','2026-01-03 05:04:45',0.00,0.00,0,NULL,NULL,NULL),
(292,'111','6958a4ee0516b',NULL,'136',31,'Olga','Mendez','olgamendez03@gmail.com','8096020173','Dominican Republic',NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"1XQJuYBTb\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958a4ee0516b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 05:11:10','2026-01-04 04:18:31',0.00,0.00,0,'[\"1XQJuYBTb\"]',NULL,NULL),
(293,'112','6958aa265738f',NULL,'136',31,'Angey','Antigua','angieantigua15@gmail.com',NULL,'República Dominicana',NULL,NULL,NULL,'Calle María de Toledo #2','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"XwSy5GvnW\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958aa265738f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 05:33:26','2026-01-04 03:43:51',0.00,0.00,0,'[\"XwSy5GvnW\"]',NULL,NULL),
(294,'114','6958cadfbf4d9',NULL,'136',31,'Fairam','Castillo','fairam.louis@gmail.com','8297088599','Dominican Republic','Distrito Nacional','Santo Domingo','Santo Domingo','Bienvenido García Gautier','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"pPjLKfhXy\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6958cadfbf4d9.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 07:53:03','2026-01-03 07:53:04',0.00,0.00,0,NULL,NULL,NULL),
(295,'115','6959162fc8a31',NULL,'136',31,'Fausto','Marte','faustopena170@gmail.com','8096755010',NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"8UjtOoLHW\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959162fc8a31.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 13:14:23','2026-01-03 13:14:24',0.00,0.00,0,NULL,NULL,NULL),
(296,'116','69592846e7339',NULL,'136',31,'Josue','Valentin Villa','datjoshie@gmail.com','8296993587','Santo domingo oeste','Distrito nacional','Buenos aires de Herrera','Buenos aires de Herrera','Callejón México #14','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"67O19VGJx\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69592846e7339.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 14:31:34','2026-01-03 14:31:35',0.00,0.00,0,NULL,NULL,NULL),
(297,'117','69592b3519374',NULL,'136',31,'Aider','Kun','aidersupp30@gmail.com','8493710826','República Dominicana','91000','Distrito Nacional','Distrito Nacional','Calle Correa y Cidrom','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"23Mhg59vJ\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69592b3519374.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 14:44:05','2026-01-04 03:41:53',0.00,0.00,0,'[\"23Mhg59vJ\"]',NULL,NULL),
(298,'118','6959360bc835b',NULL,'136',31,'Rafael','Romero','678tasha678@gmail.com',NULL,NULL,NULL,NULL,NULL,'Calle Santome esquina conde zona colonial','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"VKzHzpjOX\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959360bc835b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 15:30:19','2026-01-03 15:30:20',0.00,0.00,0,NULL,NULL,NULL),
(299,'119','69593c0a8a131',NULL,'136',31,'Luis','Perez','lbpm9513@gmail.com','8092992480','Santo dlmingo',NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"r0VcqnQUI\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593c0a8a131.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 15:55:54','2026-01-03 15:55:54',0.00,0.00,0,NULL,NULL,NULL),
(300,'119','69593c0bdbe4c',NULL,'136',31,'Luis','Perez','lbpm9513@gmail.com','8092992480','Santo dlmingo',NULL,NULL,NULL,NULL,NULL,0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593c0bdbe4c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 15:55:55','2026-01-03 15:55:56',0.00,0.00,0,NULL,NULL,NULL),
(301,'121','69593cd9547dc',NULL,'136',31,'janiel','acosta','janielacostarealestate@gmail.com','8498156493','santo domingo','Rep dominicana','distrito nacional','distrito nacional','30 de marzo #44','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Q25aoHT2h\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593cd9547dc.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 15:59:21','2026-01-03 15:59:21',0.00,0.00,0,NULL,NULL,NULL),
(302,'120','69593cfd46ab6',NULL,'136',31,'Joan','Pérez Pujols','joanp1994@hotmail.com','8294185980','Republica dominicana',NULL,NULL,NULL,'C Águeda suare','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"hYMI918Yt\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593cfd46ab6.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 15:59:57','2026-01-04 04:15:22',0.00,0.00,0,'[\"hYMI918Yt\"]',NULL,NULL),
(303,'122','69593d6999ce8',NULL,'136',31,'Stefano','Amador','amadorstefano15@gmail.com',NULL,'United States','MA','Boston','Boston','99 E Dedham St','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"2fL85aWoy\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593d6999ce8.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:01:45','2026-01-04 02:20:46',0.00,0.00,0,'[\"2fL85aWoy\"]',NULL,NULL),
(304,'123','69593ed05c59a',NULL,'136',31,'Pavel','Calderon','stefano.amador@gmail.com',NULL,'United States','MA','Saugus','Saugus','19 Flushing Rd','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"fgTL9V9ch\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69593ed05c59a.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:07:44','2026-01-04 02:20:56',0.00,0.00,0,'[\"fgTL9V9ch\"]',NULL,NULL),
(305,'124','6959405c62b6a',NULL,'136',31,'Dulce','Wiese','dulcewiese18@gmail.com','8293054840','República Dominicana','Edificio Oscar 1','Santo Domingo','Santo Domingo','Alfonso moreno martinez #68','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"ni9D3xuyD\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959405c62b6a.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:14:20','2026-01-03 16:14:20',0.00,0.00,0,NULL,NULL,NULL),
(306,'125','695940a503fd1',NULL,'136',31,'Mary','De León','marygdeleonf@gmail.com','8494575730','Republica dominicana',NULL,NULL,NULL,'C Águeda Suárez','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"43smHLoc4\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695940a503fd1.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:15:33','2026-01-04 04:15:26',0.00,0.00,0,'[\"43smHLoc4\"]',NULL,NULL),
(307,'128','695947038ac17',NULL,'136',31,'Luis Angel','Tavarez Taveras','angel.tvrzs@gmail.com',NULL,'Rep dom','Santo Domingo','Distrito nacional','Distrito nacional','Calle G','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"soudrrDSb\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695947038ac17.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:42:43','2026-01-03 16:42:43',0.00,0.00,0,NULL,NULL,NULL),
(308,'128','69594704d4e7c',NULL,'136',31,'Luis Angel','Tavarez Taveras','angel.tvrzs@gmail.com',NULL,'Rep dom','Santo Domingo','Distrito nacional','Distrito nacional','Calle G',NULL,0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594704d4e7c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:42:44','2026-01-04 02:54:23',0.00,0.00,0,'[\"1\"]',NULL,NULL),
(309,'127','6959474deb229',NULL,'136',31,'Salimah','Veras','salimahveras@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"m98PkvfyG\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959474deb229.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:43:57','2026-01-03 16:43:58',0.00,0.00,0,NULL,NULL,NULL),
(310,'64','6959499056496',NULL,'136',31,'Joel','Morillo','daesolucioneselectro@gmail.com','8299202525','República Dominicana','Santo Domingo','santo domingo este','santo domingo este','ciudad juan bosch','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"HzZVHCAfA\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959499056496.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:53:36','2026-01-03 16:53:36',0.00,0.00,0,NULL,NULL,NULL),
(311,'43','695949991a242',NULL,'136',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1','[{\"ticket_id\":223,\"early_bird_dicount\":0,\"name\":\"Guest List\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"SqZJsrxXO\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695949991a242.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 16:53:45','2026-01-03 16:53:45',0.00,0.00,0,NULL,NULL,NULL),
(312,'64','69594b739f08f',NULL,'136',31,'Joel','Morillo','daesolucioneselectro@gmail.com','8299202525','República Dominicana','Santo Domingo','santo domingo este','santo domingo este','ciudad juan bosch','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"EW2prpJNr\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594b739f08f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:01:39','2026-01-03 17:01:40',0.00,0.00,0,NULL,NULL,NULL),
(313,'44','69594bbf7bdf7',NULL,'136',31,'Davila Esperanza','Paulino Ramos','daavilaramos@gmail.com','8298156480','Dominican Republic',NULL,'Bonao','Bonao','Calle 1ra #15 El Cacique','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"DtpxXCSJP\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594bbf7bdf7.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:02:55','2026-01-03 17:08:51',0.00,0.00,0,'[\"DtpxXCSJP\"]',NULL,NULL),
(314,'133','69594bd25bb5d',NULL,'136',31,'Raúl','Cabrera','rau0809@gmail.com','8293165265','Dominican Republic','Santo Domingo','Santo Domingo','Santo Domingo','Santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"NGKxBJeod\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594bd25bb5d.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:03:14','2026-01-04 02:54:28',0.00,0.00,0,'[\"NGKxBJeod\"]',NULL,NULL),
(315,'135','69594c473ad1d',NULL,'136',31,'Jordi Rafael','Ramos Ventura','jordi.ramos.1990@gmail.com',NULL,NULL,NULL,NULL,NULL,'Santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"L5XF20VUZ\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Z7G5SrfCQ\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"jC52DIF4M\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"kMXCv3Fi8\"}]',0.00,'4',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594c473ad1d.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:05:11','2026-01-03 17:05:11',0.00,0.00,0,NULL,NULL,NULL),
(316,'136','69594e3391020',NULL,'136',31,'Vishnu','Fernández','vishnufernandez@icloud.com','8298040124','República Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle Jimani','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"pQwUqlxTp\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594e3391020.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:13:23','2026-01-03 17:13:23',0.00,0.00,0,NULL,NULL,NULL),
(317,'137','69594f9d87f2b',NULL,'136',31,'Gino','Carezzano','gino.carezzano@gmail.com','8493532802','Dominican republic',NULL,NULL,NULL,'Calle las carreras 9','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"GPkrrKKvZ\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69594f9d87f2b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:19:25','2026-01-04 04:16:42',0.00,0.00,0,'[\"GPkrrKKvZ\"]',NULL,NULL),
(318,'69','695955a34c2a7',NULL,'136',31,'Roberto','Rojas','angelfitdash@gmail.com','8499129101','República Dominicana',NULL,'Distrito Nacional','Distrito Nacional','La Esperanza, Calle Juan Marichal','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"tM64OjQYm\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695955a34c2a7.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:45:07','2026-01-04 03:13:29',0.00,0.00,0,'[\"tM64OjQYm\"]',NULL,NULL),
(319,'63','695957d5095f7',NULL,'136',31,'Braulio','Paulino','braulioap1998@gmail.com','8299281086','Santo Domingo','Santo Domingo','Santo Domingo Oeste','Santo Domingo Oeste',NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"G4FSfFkgr\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695957d5095f7.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:54:29','2026-01-03 17:54:29',0.00,0.00,0,NULL,NULL,NULL),
(320,'140','695958a63c390',NULL,'136',31,'Ramnerys','Mena De la Cruz','ramnerysmena@gmail.com','8098991869','Santo Domingo',NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"m7KOiZbJY\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695958a63c390.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:57:58','2026-01-03 17:57:58',0.00,0.00,0,NULL,NULL,NULL),
(321,'140','695958a76f270',NULL,'136',31,'Ramnerys','Mena De la Cruz','ramnerysmena@gmail.com','8098991869','Santo Domingo',NULL,NULL,NULL,NULL,NULL,0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695958a76f270.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 17:57:59','2026-01-03 17:57:59',0.00,0.00,0,NULL,NULL,NULL),
(322,'130','69596179f178d',NULL,'136',31,'Aubrey','Fernández','aubreyfer02@gmail.com','8292795856','República Dominicana',NULL,'Santo Domingo','Santo Domingo','Residencial Pequeño Burgués','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"Ww5ze73UC\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69596179f178d.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 18:35:37','2026-01-03 18:35:38',0.00,0.00,0,NULL,NULL,NULL),
(323,'142','69596277ba84c',NULL,'136',31,'Aimee','Morel','aimeemorel04@icloud.com','8097561075','Dominican Republic','Santo Domingo Norte','Santo Domingo','Santo Domingo','Urbanización Máximo Gómez','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"x1JYRqQjZ\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69596277ba84c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 18:39:51','2026-01-03 18:39:52',0.00,0.00,0,NULL,NULL,NULL),
(324,'144','6959684e1745a',NULL,'136',31,'Marcos','De Leon','marcosjavierdeleon31@gmail.com','8099929393','Dominican Republic','Santo Domingo','Santo Domingo','Santo Domingo','Calle Pablito Mirabal\r\nSanto Domingo\r\nDistrito Nacional\r\nDominican Republic','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"ZZrpJ9ES5\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959684e1745a.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 19:04:46','2026-01-03 19:04:46',0.00,0.00,0,NULL,NULL,NULL),
(325,'67','69596a197c825',NULL,'136',31,'Massiel','Tejeda','themazzy27@gmail.com','8496511528','Dominican Republic','Santo Domingo','Santo Domingo Oeste','Santo Domingo Oeste','Calle A#7 miosotis herrera','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"mOppvd9iz\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69596a197c825.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 19:12:25','2026-01-03 19:12:25',0.00,0.00,0,NULL,NULL,NULL),
(326,'145','69596ee3132f1',NULL,'136',31,'Rafael','Bueno','rafaelbueno1923@hotmail.com','8292942675','Dominican Republic',NULL,NULL,NULL,'Santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"qoEPoHVEe\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69596ee3132f1.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 19:32:51','2026-01-03 19:32:51',0.00,0.00,0,NULL,NULL,NULL),
(327,'146','695970060f75d',NULL,'136',31,'Sebastian','Suriel','ssuriel16@hotmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"rTHV3EMqV\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695970060f75d.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 19:37:42','2026-01-03 19:37:42',0.00,0.00,0,NULL,NULL,NULL),
(328,'147','6959763c35efe',NULL,'136',31,'Yeralqui','Frias','yeralquialexander@gmail.com','8296192311','República Dominicana',NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"4aqo2AqZv\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959763c35efe.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 20:04:12','2026-01-03 20:04:12',0.00,0.00,0,NULL,NULL,NULL),
(329,'148','69597b9857e4c',NULL,'136',31,'Jerry Steven','Reyes Veloz','jeesreve@gmail.com','8093223799','Santo Domingo','República Dominicana','Santo Domingo','Santo Domingo','Evaristo Morales santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"8gO5soVun\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69597b9857e4c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 20:27:04','2026-01-04 03:08:34',0.00,0.00,0,'[\"8gO5soVun\"]',NULL,NULL),
(330,'149','69597cfaa43c8',NULL,'136',31,'Rosy','Villa','rosyxvilla@gmail.com','8097422016','Dominican Republic','SANTO DOMINGO','Santo Domingo','Santo Domingo','Calle Helios 117, Bella Vista','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"JDe9qEpFK\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69597cfaa43c8.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 20:32:58','2026-01-04 03:08:38',0.00,0.00,0,'[\"JDe9qEpFK\"]',NULL,NULL),
(331,'150','695986c7128ba',NULL,'136',31,'NAIROBI','HERNANDEZ GOMEZ','nairobihgomez.2010@gmail.com','8495229536','República Dominicana',NULL,'SANTO DOMINGO','SANTO DOMINGO','Los palmares, calle marien','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"MeO3Gpw9L\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695986c7128ba.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:14:47','2026-01-03 21:14:47',0.00,0.00,0,NULL,NULL,NULL),
(332,'147','69598c7709dcc',NULL,'136',31,'Alexander','Gautier','jag.gautier09@gmail.com','8096726883','República Dominicana',NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"AjXztMiC1\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69598c7709dcc.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:39:03','2026-01-03 21:39:03',0.00,0.00,0,NULL,NULL,NULL),
(333,'153','69598e2f24945',NULL,'136',31,'Alexander','Suarez','ALEXSUAREZMEN27@GMAIL.COM',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"mwCBTuBYG\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69598e2f24945.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:46:23','2026-01-04 04:24:59',0.00,0.00,0,'[\"mwCBTuBYG\"]',NULL,NULL),
(334,'151','69598e3894736',NULL,'136',31,'Emilis','Castillo','emily.garrix@gmail.com','8295721822','República Dominicana','Santo Domingo','Santo Domingo','Santo Domingo','Calle 41 #59 los mina, Santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xRKVPMzxg\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"POSxFiWPX\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69598e3894736.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:46:32','2026-01-03 21:46:33',0.00,0.00,0,NULL,NULL,NULL),
(335,'152','69598e5e82c13',NULL,'136',31,'Erick','Hiciano','hiciano.envio@gmail.com','8096274616','Dominican Republic','Distrito Nacional','Santo Domingo','Santo Domingo','Jsjsjjssjs','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"baKqTNwvH\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"AXvRExnPY\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69598e5e82c13.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:47:10','2026-01-03 21:47:10',0.00,0.00,0,NULL,NULL,NULL),
(336,'154','69598f9e0477c',NULL,'136',31,'Franchel','Velázquez','franchard7@gmail.com','8297309290','República dominicana','Distrito nacional','Santo Domingo','Santo Domingo','Santo Domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"eNobcHewV\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"gFTesh93T\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69598f9e0477c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 21:52:30','2026-01-04 03:08:58',0.00,0.00,0,'[\"eNobcHewV\",\"gFTesh93T\"]',NULL,NULL),
(337,'155','6959925e8ad44',NULL,'136',31,'Eduardo','Cruz','eduardocruzcastillo07@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"ePv1Al3KH\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959925e8ad44.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:04:14','2026-01-03 22:04:14',0.00,0.00,0,NULL,NULL,NULL),
(338,'156','69599601607f6',NULL,'136',31,'Krysht','Fernández','krysht.13@gmail.com','8293220372','República Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle pedernales 128','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"OBjrHCirW\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69599601607f6.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:19:45','2026-01-03 22:19:45',0.00,0.00,0,NULL,NULL,NULL),
(339,'157','695996ea99d4f',NULL,'136',31,'Alexander','Gautier','yeralquialexander@hotmail.com','8296192311',NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"kl6FWOSzz\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695996ea99d4f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:23:38','2026-01-03 22:23:38',0.00,0.00,0,NULL,NULL,NULL),
(340,'159','695998ef89ede',NULL,'136',31,'Gabriella','Medina','gabriella.carmin@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"RGrSID18B\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'695998ef89ede.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:32:15','2026-01-03 22:32:15',0.00,0.00,0,NULL,NULL,NULL),
(341,'161','69599bc4ed05c',NULL,'136',31,'Kiara','Hernandez','hernandezkiara88@gmail.com','+18572077077','USA','MA','Dorchester','Dorchester','7 Ocean View Dr','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"uaLsCxQ31\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69599bc4ed05c.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:44:20','2026-01-04 03:30:13',0.00,0.00,0,'[\"uaLsCxQ31\"]',NULL,NULL),
(342,'160','69599d2c1e944',NULL,'136',31,'Jesús','Mora','jesusricoso17@gmail.com','8298521017','Dominican republic','Santo Domingo','Distrito nacional','Distrito nacional',NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"lVuxpD0IE\"},{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"YtZgMvFcA\"}]',0.00,'2',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69599d2c1e944.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:50:20','2026-01-03 22:50:20',0.00,0.00,0,NULL,NULL,NULL),
(343,'155','69599d34359aa',NULL,'136',31,'Eduardo','Cruz','eduardocruzcastillo07@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"7IfRnIF2j\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69599d34359aa.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:50:28','2026-01-03 22:50:28',0.00,0.00,0,NULL,NULL,NULL),
(344,'150','69599e3a9876b',NULL,'136',31,'José Luis','Henríquez Montero','Jlhm741852@gmail.com','+1 (829) 928-5070','República Dominicana',NULL,'Distrito Nacional','Distrito Nacional','Santo Domingo, Distrito, Cristo Rey','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dA9NdERcj\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'69599e3a9876b.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 22:54:50','2026-01-03 22:54:50',0.00,0.00,0,NULL,NULL,NULL),
(345,'163','6959a0f7688e2',NULL,'136',31,'Jassel','Santana','jasselenrique@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"S9UwFjNUu\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959a0f7688e2.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 23:06:31','2026-01-03 23:06:31',0.00,0.00,0,NULL,NULL,NULL),
(346,'164','6959a1d8161e4',NULL,'136',31,'Jean','Diaz','jeancarlosdiazrod@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"MxpAA3z4b\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959a1d8161e4.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-03 23:10:16','2026-01-03 23:10:16',0.00,0.00,0,NULL,NULL,NULL),
(347,'171','6959c8aa86fe7',NULL,'136',31,'Kevin','Lopez','kevinlopezb1321@gmail.com','8498820862','Dominican rep','Distrito nacional','Santo domingo','Santo domingo','C manolo Tavares justo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"L3wvrujiM\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959c8aa86fe7.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 01:55:54','2026-01-04 01:55:54',0.00,0.00,0,NULL,NULL,NULL),
(348,'175','6959d487b304f',NULL,'136',31,'Danisa','Berigüete','danisaberiguete47@gmail.com','8292605349','Santo Domingo',NULL,NULL,NULL,'Calle Peña Batlle #109, Villa Juana','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"EYtbN2QYf\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959d487b304f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 02:46:31','2026-01-04 04:16:25',0.00,0.00,0,'[\"EYtbN2QYf\"]',NULL,NULL),
(349,'176','6959d55526828',NULL,'136',31,'Ana rosa','Mondesi','ripok943@stayhome.li','8494677805','República Dominicana',NULL,'Santo domingo','Santo domingo','Calle las carreras','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"I2R6NDifP\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959d55526828.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 02:49:57','2026-01-04 04:18:46',0.00,0.00,0,'[\"I2R6NDifP\"]',NULL,NULL),
(350,'178','6959d6fa49260',NULL,'136',31,'Loren','Ramos','Nerolramos@hotmail.com','8296048642','Santo Domingo',NULL,NULL,NULL,'C/5 Edificio 12 # 204, Santo Domingo este','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xww2xgnV9\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959d6fa49260.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 02:56:58','2026-01-04 04:16:37',0.00,0.00,0,'[\"xww2xgnV9\"]',NULL,NULL),
(351,'173','6959d794980e7',NULL,'136',31,'Ruth','Vasquez','michvs1202@gmail.com','8629771590','República Dominicana','Santo Domingo','Ciudad nueva','Ciudad nueva','Calle las carreras #9','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"ftipTOJe8\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959d794980e7.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 02:59:32','2026-01-04 04:16:17',0.00,0.00,0,'[\"ftipTOJe8\"]',NULL,NULL),
(352,'179','6959d8e5e019f',NULL,'136',31,'Nicole','Santana Rojas','nicolesantanarojas@gmail.com','8498736726','Republica Dominicana',NULL,NULL,NULL,'Santo domingo','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"2ymKYUUyw\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959d8e5e019f.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 03:05:09','2026-01-04 04:16:32',0.00,0.00,0,'[\"2ymKYUUyw\"]',NULL,NULL),
(353,'180','6959de94bebff',NULL,'136',31,'Yoan','Perez','yoanrayo@gmail.com','8098472271','Santo Domingo',NULL,NULL,NULL,'Calle 1 rosario edificio 33 apartamento 5','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"SXEc1jSQ3\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959de94bebff.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 03:29:24','2026-01-04 03:42:06',0.00,0.00,0,'[\"SXEc1jSQ3\"]',NULL,NULL),
(354,'181','6959e80f2c791',NULL,'136',31,'Hector','Avellaneda','havellanedapineda@gmail.com','8094476222','Colombia','Norte De Santander','Cúcuta','Cúcuta','Calle 9 12-24 el llano','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"wIjDZu0R6\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959e80f2c791.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 04:09:51','2026-01-04 04:09:51',0.00,0.00,0,NULL,NULL,NULL),
(355,'183','6959ef388b0f8',NULL,'136',31,'Emanuel','Barrios','rolfcast@gmail.com',NULL,NULL,NULL,NULL,NULL,NULL,'[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"xzYKTi6dy\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959ef388b0f8.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 04:40:24','2026-01-04 04:40:24',0.00,0.00,0,NULL,NULL,NULL),
(356,'182','6959f01b440f0',NULL,'136',31,'Angie','Gaona','angievalentinagaonasierra@gmail.com','8094451910','Colombia','Norte de santander','Cucuta','Cucuta','Calle 0an #4e-24','[{\"ticket_id\":224,\"early_bird_dicount\":0,\"name\":\"GUESTLIST\",\"qty\":1,\"price\":0,\"scan_status\":0,\"unique_id\":\"dHGR8jeK8\"}]',0.00,'1',0,0.00,0.00,0,NULL,NULL,NULL,NULL,NULL,NULL,'free',1,0,0.00,'6959f01b440f0.pdf',NULL,'Sat, Jan 03, 2026 08:00pm','2026-01-04 04:44:11','2026-01-04 04:44:11',0.00,0.00,0,NULL,NULL,NULL),
(357,'guest','6995db024dc42',NULL,'139',31,'Test','User','test@test.com','1234567890','Test Country',NULL,NULL,NULL,'Test Address',NULL,500.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','stripe','online','completed',1,0,0.00,'6995db024dc42.pdf',NULL,'2026-02-28','2026-02-18 15:30:10','2026-02-18 15:33:13',0.00,0.00,0,NULL,NULL,NULL),
(358,'guest','6995dbc096891',NULL,'139',31,'Test','User','test@test.com','1234567890','Test Country',NULL,NULL,NULL,'Test Address',NULL,500.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','stripe','online','completed',1,0,0.00,'6995dbc096891.pdf',NULL,'2026-02-28','2026-02-18 15:33:20','2026-02-18 15:36:23',0.00,0.00,0,NULL,NULL,NULL),
(359,'guest','6995dc8a29846',NULL,'139',31,'Test','User','test@test.com','1234567890','Test Country',NULL,NULL,NULL,'Test Address',NULL,500.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','stripe','online','completed',1,0,0.00,'6995dc8a29846.pdf',NULL,'2026-02-28','2026-02-18 15:36:42','2026-02-18 15:36:43',0.00,0.00,0,NULL,NULL,NULL),
(360,'43','69966fa56c085',NULL,'139',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1',NULL,500.00,'1',0,0.00,0.00,0,'DOP','right','RD$','left','stripe','online','completed',1,0,0.00,'69966fa56c085.pdf',NULL,'2026-02-28','2026-02-19 02:04:21','2026-02-19 02:04:22',0.00,0.00,0,NULL,NULL,NULL),
(361,'43','6996824bdaf9e',NULL,'140',31,'Giancarlos','Valdez','gian@monkey.com.do','8493538839','Republica Dominicana',NULL,'Santo Domingo','Santo Domingo','Calle 1',NULL,600.00,'2',0,0.00,0.00,0,'DOP','right','RD$','left','stripe','online','completed',1,0,0.00,'6996824bdaf9e.pdf',NULL,'2026-03-01','2026-02-19 03:23:55','2026-02-19 03:23:56',0.00,0.00,0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `bookings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chat_messages`
--

DROP TABLE IF EXISTS `chat_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chat_messages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `chat_id` bigint(20) unsigned NOT NULL,
  `sender_id` bigint(20) unsigned NOT NULL,
  `sender_type` enum('customer','organizer') NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chat_messages_chat_id_foreign` (`chat_id`),
  CONSTRAINT `chat_messages_chat_id_foreign` FOREIGN KEY (`chat_id`) REFERENCES `chats` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_messages`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chat_messages` WRITE;
/*!40000 ALTER TABLE `chat_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_messages` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `chats`
--

DROP TABLE IF EXISTS `chats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `chats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) unsigned NOT NULL,
  `organizer_id` bigint(20) unsigned NOT NULL,
  `last_message` text DEFAULT NULL,
  `last_message_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `chats_customer_id_foreign` (`customer_id`),
  KEY `chats_organizer_id_foreign` (`organizer_id`),
  CONSTRAINT `chats_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chats_organizer_id_foreign` FOREIGN KEY (`organizer_id`) REFERENCES `organizers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chats`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `chats` WRITE;
/*!40000 ALTER TABLE `chats` DISABLE KEYS */;
/*!40000 ALTER TABLE `chats` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cities`
--

DROP TABLE IF EXISTS `cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cities` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `state_id` mediumint(8) unsigned NOT NULL,
  `state_code` varchar(255) NOT NULL,
  `country_id` mediumint(8) unsigned NOT NULL,
  `country_code` char(2) NOT NULL,
  `latitude` decimal(10,8) NOT NULL,
  `longitude` decimal(11,8) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT '2014-01-01 00:31:01',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `flag` tinyint(1) NOT NULL DEFAULT 1,
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities',
  PRIMARY KEY (`id`),
  KEY `cities_test_ibfk_1` (`state_id`),
  KEY `cities_test_ibfk_2` (`country_id`),
  CONSTRAINT `cities_ibfk_1` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`),
  CONSTRAINT `cities_ibfk_2` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=150106 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cities`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cities` WRITE;
/*!40000 ALTER TABLE `cities` DISABLE KEYS */;
/*!40000 ALTER TABLE `cities` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `contact_pages`
--

DROP TABLE IF EXISTS `contact_pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_pages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `contact_form_title` varchar(255) DEFAULT NULL,
  `contact_form_subtitle` text DEFAULT NULL,
  `contact_addresses` text DEFAULT NULL,
  `contact_numbers` varchar(255) DEFAULT NULL,
  `contact_mails` text DEFAULT NULL,
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `map_zoom` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_pages`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `contact_pages` WRITE;
/*!40000 ALTER TABLE `contact_pages` DISABLE KEYS */;
INSERT INTO `contact_pages` VALUES
(1,'Contact Us','Contact Us','Santo Domingo, Republica Dominicana','+1 (849) 917-4205','info@duty.do','18.4800379','-69.9880795','17',8,'2022-07-17 05:00:10','2025-12-15 16:21:39');
/*!40000 ALTER TABLE `contact_pages` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `type` tinyint(4) DEFAULT NULL COMMENT '1=user, 2=admin, 3=organizer',
  `support_ticket_id` int(11) DEFAULT NULL,
  `reply` longtext DEFAULT NULL,
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES
(16,1,2,7,'<p>hi</p>',NULL,'2023-03-22 06:08:55','2023-03-22 06:08:55'),
(17,1,1,7,'helo ami user',NULL,'2023-03-22 06:16:40','2023-03-22 06:16:40'),
(19,8,2,7,'<p>hello ami moderator bolci<br /></p>',NULL,'2023-03-22 06:21:08','2023-03-22 06:21:08'),
(20,8,2,7,'<p>admin assing to me</p>',NULL,'2023-03-22 06:28:59','2023-03-22 06:28:59'),
(21,1,2,7,'<p>yeah i assign </p>',NULL,'2023-03-22 06:29:20','2023-03-22 06:29:20'),
(22,1,1,7,'ok i got it',NULL,'2023-03-22 06:29:38','2023-03-22 06:29:38'),
(23,1,1,7,'this is attactment','641aa22b1762b.zip','2023-03-22 06:37:31','2023-03-22 06:37:31'),
(24,8,2,7,'<p>admin zip file</p>','641aa2c717d3f.zip','2023-03-22 06:40:07','2023-03-22 06:40:07'),
(33,25,1,9,'hi',NULL,'2023-05-06 08:27:22','2023-05-06 08:27:22'),
(34,1,2,14,'<p>Hi.!!</p>',NULL,'2023-05-08 11:25:37','2023-05-08 11:25:37'),
(35,23,1,14,'Hello! please let me ensure',NULL,'2023-05-08 11:26:17','2023-05-08 11:26:17'),
(36,1,2,14,'<p>we have an issue on our site. we will fixed it soon</p>Thanks</p>',NULL,'2023-05-08 11:27:01','2023-05-08 11:27:01'),
(37,1,2,12,'<p>We have successfully checked your withdrawal request.</p><p>You have given an invalid account statement. please give us a proper statement,</p><p>then we will accept your request.</p><p>Thanks</p>',NULL,'2023-05-08 11:29:57','2023-05-08 11:29:57'),
(38,23,3,12,'<p>Thanks a lot for your valuable information.</p>',NULL,'2023-05-08 11:30:44','2023-05-08 11:30:44'),
(39,1,2,16,'<p>if you have a venue event</p><p>then you have to add a ticket from manage ticket option</p><p>Thanks</p>',NULL,'2023-05-08 11:35:58','2023-05-08 11:35:58'),
(40,23,3,16,'<p>Thank you so much</p><p>now it\'s work properly</p>',NULL,'2023-05-08 11:36:47','2023-05-08 11:36:47'),
(41,23,1,13,'hi',NULL,'2023-05-08 11:37:51','2023-05-08 11:37:51'),
(42,1,2,13,'what was your payment method?',NULL,'2023-05-08 11:39:49','2023-05-08 11:39:49'),
(43,23,1,13,'City Bank',NULL,'2023-05-08 11:40:06','2023-05-08 11:40:06'),
(44,1,2,13,'<p>Please give the proper info and book again</p><p>Thanks</p>',NULL,'2023-05-08 11:40:25','2023-05-08 11:40:25'),
(45,23,1,13,'Thanks.',NULL,'2023-05-08 11:40:42','2023-05-08 11:40:42'),
(48,1,2,18,'<p>dfsafaf</p>',NULL,'2023-09-23 09:35:55','2023-09-23 09:35:55'),
(49,1,2,19,'<p>rrr</p>',NULL,'2025-10-12 23:45:49','2025-10-12 23:45:49'),
(50,33,1,19,'rrrrr',NULL,'2025-10-12 23:46:45','2025-10-12 23:46:45'),
(51,1,2,20,'<p>The test is successfull.</p>',NULL,'2025-10-13 00:50:04','2025-10-13 00:50:04'),
(52,34,1,20,'Ok',NULL,'2025-10-13 00:50:18','2025-10-13 00:50:18'),
(53,1,2,20,'<p>Closing the ticket</p>',NULL,'2025-10-13 00:50:45','2025-10-13 00:50:45'),
(54,1,2,21,'<p>Success</p>',NULL,'2025-10-13 00:51:36','2025-10-13 00:51:36'),
(55,35,1,21,'ok',NULL,'2025-10-13 00:51:46','2025-10-13 00:51:46'),
(56,1,2,23,'<p>Test is successfull.</p>',NULL,'2025-10-13 05:25:21','2025-10-13 05:25:21'),
(57,34,1,23,'Good News!',NULL,'2025-10-13 05:25:38','2025-10-13 05:25:38'),
(58,34,1,23,'.',NULL,'2025-10-13 05:25:53','2025-10-13 05:25:53');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `cookie_alerts`
--

DROP TABLE IF EXISTS `cookie_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `cookie_alerts` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `cookie_alert_status` tinyint(3) unsigned NOT NULL,
  `cookie_alert_btn_text` varchar(255) NOT NULL,
  `cookie_alert_text` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `cookie_alerts_language_id_foreign` (`language_id`),
  CONSTRAINT `cookie_alerts_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cookie_alerts`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `cookie_alerts` WRITE;
/*!40000 ALTER TABLE `cookie_alerts` DISABLE KEYS */;
INSERT INTO `cookie_alerts` VALUES
(1,8,1,'I Agree','<p>We use cookies to give you the best online experience.<br>By continuing to browse the site you are agreeing to our use of cookies.</p>','2021-06-02 06:25:54','2023-05-20 12:07:47');
/*!40000 ALTER TABLE `cookie_alerts` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `count_informations`
--

DROP TABLE IF EXISTS `count_informations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `count_informations` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `amount` int(10) unsigned NOT NULL,
  `serial_number` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `count_informations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `count_informations` WRITE;
/*!40000 ALTER TABLE `count_informations` DISABLE KEYS */;
INSERT INTO `count_informations` VALUES
(5,8,'fas fa-user-friends','24FFCD','Qualified Instructors',20,1,'2021-10-11 01:20:18','2022-05-15 00:17:03'),
(6,8,'fas fa-globe','FFAB74','Worldwide Students',1490,2,'2021-10-11 01:20:47','2021-12-19 04:44:42'),
(7,8,'fas fa-book-reader','00FCFF','Courses',100,3,'2021-10-11 01:21:31','2021-12-19 04:45:36'),
(8,8,'fas fa-calendar-alt','FFC924','Years\' Experience',10,4,'2021-10-11 01:21:55','2021-12-19 04:46:07');
/*!40000 ALTER TABLE `count_informations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
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
  `timezones` text DEFAULT NULL,
  `translations` text DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `emoji` varchar(191) DEFAULT NULL,
  `emojiU` varchar(191) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `flag` tinyint(1) NOT NULL DEFAULT 1,
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES
(1,'Afghanistan','AFG','004','AF','93','Kabul','AFN','Afghan afghani','؋','.af','افغانستان','Asia','Southern Asia','[{\"zoneName\":\"Asia/Kabul\",\"gmtOffset\":16200,\"gmtOffsetName\":\"UTC+04:30\",\"abbreviation\":\"AFT\",\"tzName\":\"Afghanistan Time\"}]','{\"kr\":\"아프가니스탄\",\"br\":\"Afeganistão\",\"pt\":\"Afeganistão\",\"nl\":\"Afghanistan\",\"hr\":\"Afganistan\",\"fa\":\"افغانستان\",\"de\":\"Afghanistan\",\"es\":\"Afganistán\",\"fr\":\"Afghanistan\",\"ja\":\"アフガニスタン\",\"it\":\"Afghanistan\",\"cn\":\"阿富汗\",\"tr\":\"Afganistan\"}',33.00000000,65.00000000,'','U+1F1E6 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q889'),
(2,'Aland Islands','ALA','248','AX','+358-18','Mariehamn','EUR','Euro','€','.ax','Åland','Europe','Northern Europe','[{\"zoneName\":\"Europe/Mariehamn\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"올란드 제도\",\"br\":\"Ilhas de Aland\",\"pt\":\"Ilhas de Aland\",\"nl\":\"Ålandeilanden\",\"hr\":\"Ålandski otoci\",\"fa\":\"جزایر الند\",\"de\":\"Åland\",\"es\":\"Alandia\",\"fr\":\"Åland\",\"ja\":\"オーランド諸島\",\"it\":\"Isole Aland\",\"cn\":\"奥兰群岛\",\"tr\":\"Åland Adalari\"}',60.11666700,19.90000000,'','U+1F1E6 U+1F1FD','2018-07-21 01:11:03','2022-05-21 15:06:00',1,NULL),
(3,'Albania','ALB','008','AL','355','Tirana','ALL','Albanian lek','Lek','.al','Shqipëria','Europe','Southern Europe','[{\"zoneName\":\"Europe/Tirane\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"알바니아\",\"br\":\"Albânia\",\"pt\":\"Albânia\",\"nl\":\"Albanië\",\"hr\":\"Albanija\",\"fa\":\"آلبانی\",\"de\":\"Albanien\",\"es\":\"Albania\",\"fr\":\"Albanie\",\"ja\":\"アルバニア\",\"it\":\"Albania\",\"cn\":\"阿尔巴尼亚\",\"tr\":\"Arnavutluk\"}',41.00000000,20.00000000,'','U+1F1E6 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q222'),
(4,'Algeria','DZA','012','DZ','213','Algiers','DZD','Algerian dinar','دج','.dz','الجزائر','Africa','Northern Africa','[{\"zoneName\":\"Africa/Algiers\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"알제리\",\"br\":\"Argélia\",\"pt\":\"Argélia\",\"nl\":\"Algerije\",\"hr\":\"Alžir\",\"fa\":\"الجزایر\",\"de\":\"Algerien\",\"es\":\"Argelia\",\"fr\":\"Algérie\",\"ja\":\"アルジェリア\",\"it\":\"Algeria\",\"cn\":\"阿尔及利亚\",\"tr\":\"Cezayir\"}',28.00000000,3.00000000,'','U+1F1E9 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q262'),
(5,'American Samoa','ASM','016','AS','+1-684','Pago Pago','USD','US Dollar','$','.as','American Samoa','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Pago_Pago\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"SST\",\"tzName\":\"Samoa Standard Time\"}]','{\"kr\":\"아메리칸사모아\",\"br\":\"Samoa Americana\",\"pt\":\"Samoa Americana\",\"nl\":\"Amerikaans Samoa\",\"hr\":\"Američka Samoa\",\"fa\":\"ساموآی آمریکا\",\"de\":\"Amerikanisch-Samoa\",\"es\":\"Samoa Americana\",\"fr\":\"Samoa américaines\",\"ja\":\"アメリカ領サモア\",\"it\":\"Samoa Americane\",\"cn\":\"美属萨摩亚\",\"tr\":\"Amerikan Samoasi\"}',-14.33333333,-170.00000000,'','U+1F1E6 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:06:00',1,NULL),
(6,'Andorra','AND','020','AD','376','Andorra la Vella','EUR','Euro','€','.ad','Andorra','Europe','Southern Europe','[{\"zoneName\":\"Europe/Andorra\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"안도라\",\"br\":\"Andorra\",\"pt\":\"Andorra\",\"nl\":\"Andorra\",\"hr\":\"Andora\",\"fa\":\"آندورا\",\"de\":\"Andorra\",\"es\":\"Andorra\",\"fr\":\"Andorre\",\"ja\":\"アンドラ\",\"it\":\"Andorra\",\"cn\":\"安道尔\",\"tr\":\"Andorra\"}',42.50000000,1.50000000,'','U+1F1E6 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q228'),
(7,'Angola','AGO','024','AO','244','Luanda','AOA','Angolan kwanza','Kz','.ao','Angola','Africa','Middle Africa','[{\"zoneName\":\"Africa/Luanda\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"앙골라\",\"br\":\"Angola\",\"pt\":\"Angola\",\"nl\":\"Angola\",\"hr\":\"Angola\",\"fa\":\"آنگولا\",\"de\":\"Angola\",\"es\":\"Angola\",\"fr\":\"Angola\",\"ja\":\"アンゴラ\",\"it\":\"Angola\",\"cn\":\"安哥拉\",\"tr\":\"Angola\"}',-12.50000000,18.50000000,'','U+1F1E6 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q916'),
(8,'Anguilla','AIA','660','AI','+1-264','The Valley','XCD','East Caribbean dollar','$','.ai','Anguilla','Americas','Caribbean','[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"앵귈라\",\"br\":\"Anguila\",\"pt\":\"Anguila\",\"nl\":\"Anguilla\",\"hr\":\"Angvila\",\"fa\":\"آنگویلا\",\"de\":\"Anguilla\",\"es\":\"Anguilla\",\"fr\":\"Anguilla\",\"ja\":\"アンギラ\",\"it\":\"Anguilla\",\"cn\":\"安圭拉\",\"tr\":\"Anguilla\"}',18.25000000,-63.16666666,'','U+1F1E6 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:06:00',1,NULL),
(9,'Antarctica','ATA','010','AQ','672','','AAD','Antarctican dollar','$','.aq','Antarctica','Polar','','[{\"zoneName\":\"Antarctica/Casey\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AWST\",\"tzName\":\"Australian Western Standard Time\"},{\"zoneName\":\"Antarctica/Davis\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"DAVT\",\"tzName\":\"Davis Time\"},{\"zoneName\":\"Antarctica/DumontDUrville\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"DDUT\",\"tzName\":\"Dumont d\'Urville Time\"},{\"zoneName\":\"Antarctica/Mawson\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MAWT\",\"tzName\":\"Mawson Station Time\"},{\"zoneName\":\"Antarctica/McMurdo\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"NZDT\",\"tzName\":\"New Zealand Daylight Time\"},{\"zoneName\":\"Antarctica/Palmer\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"Antarctica/Rothera\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ROTT\",\"tzName\":\"Rothera Research Station Time\"},{\"zoneName\":\"Antarctica/Syowa\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"SYOT\",\"tzName\":\"Showa Station Time\"},{\"zoneName\":\"Antarctica/Troll\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"},{\"zoneName\":\"Antarctica/Vostok\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"VOST\",\"tzName\":\"Vostok Station Time\"}]','{\"kr\":\"남극\",\"br\":\"Antártida\",\"pt\":\"Antárctida\",\"nl\":\"Antarctica\",\"hr\":\"Antarktika\",\"fa\":\"جنوبگان\",\"de\":\"Antarktika\",\"es\":\"Antártida\",\"fr\":\"Antarctique\",\"ja\":\"南極大陸\",\"it\":\"Antartide\",\"cn\":\"南极洲\",\"tr\":\"Antartika\"}',-74.65000000,4.48000000,'','U+1F1E6 U+1F1F6','2018-07-21 01:11:03','2022-05-21 15:06:00',1,NULL),
(10,'Antigua And Barbuda','ATG','028','AG','+1-268','St. John\'s','XCD','Eastern Caribbean dollar','$','.ag','Antigua and Barbuda','Americas','Caribbean','[{\"zoneName\":\"America/Antigua\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"앤티가 바부다\",\"br\":\"Antígua e Barbuda\",\"pt\":\"Antígua e Barbuda\",\"nl\":\"Antigua en Barbuda\",\"hr\":\"Antigva i Barbuda\",\"fa\":\"آنتیگوا و باربودا\",\"de\":\"Antigua und Barbuda\",\"es\":\"Antigua y Barbuda\",\"fr\":\"Antigua-et-Barbuda\",\"ja\":\"アンティグア・バーブーダ\",\"it\":\"Antigua e Barbuda\",\"cn\":\"安提瓜和巴布达\",\"tr\":\"Antigua Ve Barbuda\"}',17.05000000,-61.80000000,'','U+1F1E6 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q781'),
(11,'Argentina','ARG','032','AR','54','Buenos Aires','ARS','Argentine peso','$','.ar','Argentina','Americas','South America','[{\"zoneName\":\"America/Argentina/Buenos_Aires\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Catamarca\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Cordoba\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Jujuy\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/La_Rioja\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Mendoza\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Rio_Gallegos\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Salta\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/San_Juan\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/San_Luis\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Tucuman\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"},{\"zoneName\":\"America/Argentina/Ushuaia\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"ART\",\"tzName\":\"Argentina Time\"}]','{\"kr\":\"아르헨티나\",\"br\":\"Argentina\",\"pt\":\"Argentina\",\"nl\":\"Argentinië\",\"hr\":\"Argentina\",\"fa\":\"آرژانتین\",\"de\":\"Argentinien\",\"es\":\"Argentina\",\"fr\":\"Argentine\",\"ja\":\"アルゼンチン\",\"it\":\"Argentina\",\"cn\":\"阿根廷\",\"tr\":\"Arjantin\"}',-34.00000000,-64.00000000,'','U+1F1E6 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q414'),
(12,'Armenia','ARM','051','AM','374','Yerevan','AMD','Armenian dram','֏','.am','Հայաստան','Asia','Western Asia','[{\"zoneName\":\"Asia/Yerevan\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Armenia Time\"}]','{\"kr\":\"아르메니아\",\"br\":\"Armênia\",\"pt\":\"Arménia\",\"nl\":\"Armenië\",\"hr\":\"Armenija\",\"fa\":\"ارمنستان\",\"de\":\"Armenien\",\"es\":\"Armenia\",\"fr\":\"Arménie\",\"ja\":\"アルメニア\",\"it\":\"Armenia\",\"cn\":\"亚美尼亚\",\"tr\":\"Ermenistan\"}',40.00000000,45.00000000,'','U+1F1E6 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q399'),
(13,'Aruba','ABW','533','AW','297','Oranjestad','AWG','Aruban florin','ƒ','.aw','Aruba','Americas','Caribbean','[{\"zoneName\":\"America/Aruba\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"아루바\",\"br\":\"Aruba\",\"pt\":\"Aruba\",\"nl\":\"Aruba\",\"hr\":\"Aruba\",\"fa\":\"آروبا\",\"de\":\"Aruba\",\"es\":\"Aruba\",\"fr\":\"Aruba\",\"ja\":\"アルバ\",\"it\":\"Aruba\",\"cn\":\"阿鲁巴\",\"tr\":\"Aruba\"}',12.50000000,-69.96666666,'','U+1F1E6 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:06:00',1,NULL),
(14,'Australia','AUS','036','AU','61','Canberra','AUD','Australian dollar','$','.au','Australia','Oceania','Australia and New Zealand','[{\"zoneName\":\"Antarctica/Macquarie\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"MIST\",\"tzName\":\"Macquarie Island Station Time\"},{\"zoneName\":\"Australia/Adelaide\",\"gmtOffset\":37800,\"gmtOffsetName\":\"UTC+10:30\",\"abbreviation\":\"ACDT\",\"tzName\":\"Australian Central Daylight Saving Time\"},{\"zoneName\":\"Australia/Brisbane\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"AEST\",\"tzName\":\"Australian Eastern Standard Time\"},{\"zoneName\":\"Australia/Broken_Hill\",\"gmtOffset\":37800,\"gmtOffsetName\":\"UTC+10:30\",\"abbreviation\":\"ACDT\",\"tzName\":\"Australian Central Daylight Saving Time\"},{\"zoneName\":\"Australia/Currie\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Darwin\",\"gmtOffset\":34200,\"gmtOffsetName\":\"UTC+09:30\",\"abbreviation\":\"ACST\",\"tzName\":\"Australian Central Standard Time\"},{\"zoneName\":\"Australia/Eucla\",\"gmtOffset\":31500,\"gmtOffsetName\":\"UTC+08:45\",\"abbreviation\":\"ACWST\",\"tzName\":\"Australian Central Western Standard Time (Unofficial)\"},{\"zoneName\":\"Australia/Hobart\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Lindeman\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"AEST\",\"tzName\":\"Australian Eastern Standard Time\"},{\"zoneName\":\"Australia/Lord_Howe\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"LHST\",\"tzName\":\"Lord Howe Summer Time\"},{\"zoneName\":\"Australia/Melbourne\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"},{\"zoneName\":\"Australia/Perth\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"AWST\",\"tzName\":\"Australian Western Standard Time\"},{\"zoneName\":\"Australia/Sydney\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"AEDT\",\"tzName\":\"Australian Eastern Daylight Saving Time\"}]','{\"kr\":\"호주\",\"br\":\"Austrália\",\"pt\":\"Austrália\",\"nl\":\"Australië\",\"hr\":\"Australija\",\"fa\":\"استرالیا\",\"de\":\"Australien\",\"es\":\"Australia\",\"fr\":\"Australie\",\"ja\":\"オーストラリア\",\"it\":\"Australia\",\"cn\":\"澳大利亚\",\"tr\":\"Avustralya\"}',-27.00000000,133.00000000,'','U+1F1E6 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q408'),
(15,'Austria','AUT','040','AT','43','Vienna','EUR','Euro','€','.at','Österreich','Europe','Western Europe','[{\"zoneName\":\"Europe/Vienna\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"오스트리아\",\"br\":\"áustria\",\"pt\":\"áustria\",\"nl\":\"Oostenrijk\",\"hr\":\"Austrija\",\"fa\":\"اتریش\",\"de\":\"Österreich\",\"es\":\"Austria\",\"fr\":\"Autriche\",\"ja\":\"オーストリア\",\"it\":\"Austria\",\"cn\":\"奥地利\",\"tr\":\"Avusturya\"}',47.33333333,13.33333333,'','U+1F1E6 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q40'),
(16,'Azerbaijan','AZE','031','AZ','994','Baku','AZN','Azerbaijani manat','m','.az','Azərbaycan','Asia','Western Asia','[{\"zoneName\":\"Asia/Baku\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"AZT\",\"tzName\":\"Azerbaijan Time\"}]','{\"kr\":\"아제르바이잔\",\"br\":\"Azerbaijão\",\"pt\":\"Azerbaijão\",\"nl\":\"Azerbeidzjan\",\"hr\":\"Azerbajdžan\",\"fa\":\"آذربایجان\",\"de\":\"Aserbaidschan\",\"es\":\"Azerbaiyán\",\"fr\":\"Azerbaïdjan\",\"ja\":\"アゼルバイジャン\",\"it\":\"Azerbaijan\",\"cn\":\"阿塞拜疆\",\"tr\":\"Azerbaycan\"}',40.50000000,47.50000000,'','U+1F1E6 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q227'),
(17,'The Bahamas','BHS','044','BS','+1-242','Nassau','BSD','Bahamian dollar','B$','.bs','Bahamas','Americas','Caribbean','[{\"zoneName\":\"America/Nassau\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America)\"}]','{\"kr\":\"바하마\",\"br\":\"Bahamas\",\"pt\":\"Baamas\",\"nl\":\"Bahama’s\",\"hr\":\"Bahami\",\"fa\":\"باهاما\",\"de\":\"Bahamas\",\"es\":\"Bahamas\",\"fr\":\"Bahamas\",\"ja\":\"バハマ\",\"it\":\"Bahamas\",\"cn\":\"巴哈马\",\"tr\":\"Bahamalar\"}',24.25000000,-76.00000000,'','U+1F1E7 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:06:00',1,'Q778'),
(18,'Bahrain','BHR','048','BH','973','Manama','BHD','Bahraini dinar','.د.ب','.bh','‏البحرين','Asia','Western Asia','[{\"zoneName\":\"Asia/Bahrain\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"바레인\",\"br\":\"Bahrein\",\"pt\":\"Barém\",\"nl\":\"Bahrein\",\"hr\":\"Bahrein\",\"fa\":\"بحرین\",\"de\":\"Bahrain\",\"es\":\"Bahrein\",\"fr\":\"Bahreïn\",\"ja\":\"バーレーン\",\"it\":\"Bahrein\",\"cn\":\"巴林\",\"tr\":\"Bahreyn\"}',26.00000000,50.55000000,'','U+1F1E7 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q398'),
(19,'Bangladesh','BGD','050','BD','880','Dhaka','BDT','Bangladeshi taka','৳','.bd','Bangladesh','Asia','Southern Asia','[{\"zoneName\":\"Asia/Dhaka\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"BDT\",\"tzName\":\"Bangladesh Standard Time\"}]','{\"kr\":\"방글라데시\",\"br\":\"Bangladesh\",\"pt\":\"Bangladeche\",\"nl\":\"Bangladesh\",\"hr\":\"Bangladeš\",\"fa\":\"بنگلادش\",\"de\":\"Bangladesch\",\"es\":\"Bangladesh\",\"fr\":\"Bangladesh\",\"ja\":\"バングラデシュ\",\"it\":\"Bangladesh\",\"cn\":\"孟加拉\",\"tr\":\"Bangladeş\"}',24.00000000,90.00000000,'','U+1F1E7 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q902'),
(20,'Barbados','BRB','052','BB','+1-246','Bridgetown','BBD','Barbadian dollar','Bds$','.bb','Barbados','Americas','Caribbean','[{\"zoneName\":\"America/Barbados\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"바베이도스\",\"br\":\"Barbados\",\"pt\":\"Barbados\",\"nl\":\"Barbados\",\"hr\":\"Barbados\",\"fa\":\"باربادوس\",\"de\":\"Barbados\",\"es\":\"Barbados\",\"fr\":\"Barbade\",\"ja\":\"バルバドス\",\"it\":\"Barbados\",\"cn\":\"巴巴多斯\",\"tr\":\"Barbados\"}',13.16666666,-59.53333333,'','U+1F1E7 U+1F1E7','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q244'),
(21,'Belarus','BLR','112','BY','375','Minsk','BYN','Belarusian ruble','Br','.by','Белару́сь','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Minsk\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"}]','{\"kr\":\"벨라루스\",\"br\":\"Bielorrússia\",\"pt\":\"Bielorrússia\",\"nl\":\"Wit-Rusland\",\"hr\":\"Bjelorusija\",\"fa\":\"بلاروس\",\"de\":\"Weißrussland\",\"es\":\"Bielorrusia\",\"fr\":\"Biélorussie\",\"ja\":\"ベラルーシ\",\"it\":\"Bielorussia\",\"cn\":\"白俄罗斯\",\"tr\":\"Belarus\"}',53.00000000,28.00000000,'','U+1F1E7 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q184'),
(22,'Belgium','BEL','056','BE','32','Brussels','EUR','Euro','€','.be','België','Europe','Western Europe','[{\"zoneName\":\"Europe/Brussels\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"벨기에\",\"br\":\"Bélgica\",\"pt\":\"Bélgica\",\"nl\":\"België\",\"hr\":\"Belgija\",\"fa\":\"بلژیک\",\"de\":\"Belgien\",\"es\":\"Bélgica\",\"fr\":\"Belgique\",\"ja\":\"ベルギー\",\"it\":\"Belgio\",\"cn\":\"比利时\",\"tr\":\"Belçika\"}',50.83333333,4.00000000,'','U+1F1E7 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q31'),
(23,'Belize','BLZ','084','BZ','501','Belmopan','BZD','Belize dollar','$','.bz','Belize','Americas','Central America','[{\"zoneName\":\"America/Belize\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America)\"}]','{\"kr\":\"벨리즈\",\"br\":\"Belize\",\"pt\":\"Belize\",\"nl\":\"Belize\",\"hr\":\"Belize\",\"fa\":\"بلیز\",\"de\":\"Belize\",\"es\":\"Belice\",\"fr\":\"Belize\",\"ja\":\"ベリーズ\",\"it\":\"Belize\",\"cn\":\"伯利兹\",\"tr\":\"Belize\"}',17.25000000,-88.75000000,'','U+1F1E7 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q242'),
(24,'Benin','BEN','204','BJ','229','Porto-Novo','XOF','West African CFA franc','CFA','.bj','Bénin','Africa','Western Africa','[{\"zoneName\":\"Africa/Porto-Novo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"베냉\",\"br\":\"Benin\",\"pt\":\"Benim\",\"nl\":\"Benin\",\"hr\":\"Benin\",\"fa\":\"بنین\",\"de\":\"Benin\",\"es\":\"Benín\",\"fr\":\"Bénin\",\"ja\":\"ベナン\",\"it\":\"Benin\",\"cn\":\"贝宁\",\"tr\":\"Benin\"}',9.50000000,2.25000000,'','U+1F1E7 U+1F1EF','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q962'),
(25,'Bermuda','BMU','060','BM','+1-441','Hamilton','BMD','Bermudian dollar','$','.bm','Bermuda','Americas','Northern America','[{\"zoneName\":\"Atlantic/Bermuda\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"버뮤다\",\"br\":\"Bermudas\",\"pt\":\"Bermudas\",\"nl\":\"Bermuda\",\"hr\":\"Bermudi\",\"fa\":\"برمودا\",\"de\":\"Bermuda\",\"es\":\"Bermudas\",\"fr\":\"Bermudes\",\"ja\":\"バミューダ\",\"it\":\"Bermuda\",\"cn\":\"百慕大\",\"tr\":\"Bermuda\"}',32.33333333,-64.75000000,'','U+1F1E7 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(26,'Bhutan','BTN','064','BT','975','Thimphu','BTN','Bhutanese ngultrum','Nu.','.bt','ʼbrug-yul','Asia','Southern Asia','[{\"zoneName\":\"Asia/Thimphu\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"BTT\",\"tzName\":\"Bhutan Time\"}]','{\"kr\":\"부탄\",\"br\":\"Butão\",\"pt\":\"Butão\",\"nl\":\"Bhutan\",\"hr\":\"Butan\",\"fa\":\"بوتان\",\"de\":\"Bhutan\",\"es\":\"Bután\",\"fr\":\"Bhoutan\",\"ja\":\"ブータン\",\"it\":\"Bhutan\",\"cn\":\"不丹\",\"tr\":\"Butan\"}',27.50000000,90.50000000,'','U+1F1E7 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q917'),
(27,'Bolivia','BOL','068','BO','591','Sucre','BOB','Bolivian boliviano','Bs.','.bo','Bolivia','Americas','South America','[{\"zoneName\":\"America/La_Paz\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"BOT\",\"tzName\":\"Bolivia Time\"}]','{\"kr\":\"볼리비아\",\"br\":\"Bolívia\",\"pt\":\"Bolívia\",\"nl\":\"Bolivia\",\"hr\":\"Bolivija\",\"fa\":\"بولیوی\",\"de\":\"Bolivien\",\"es\":\"Bolivia\",\"fr\":\"Bolivie\",\"ja\":\"ボリビア多民族国\",\"it\":\"Bolivia\",\"cn\":\"玻利维亚\",\"tr\":\"Bolivya\"}',-17.00000000,-65.00000000,'','U+1F1E7 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q750'),
(28,'Bosnia and Herzegovina','BIH','070','BA','387','Sarajevo','BAM','Bosnia and Herzegovina convertible mark','KM','.ba','Bosna i Hercegovina','Europe','Southern Europe','[{\"zoneName\":\"Europe/Sarajevo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"보스니아 헤르체고비나\",\"br\":\"Bósnia e Herzegovina\",\"pt\":\"Bósnia e Herzegovina\",\"nl\":\"Bosnië en Herzegovina\",\"hr\":\"Bosna i Hercegovina\",\"fa\":\"بوسنی و هرزگوین\",\"de\":\"Bosnien und Herzegowina\",\"es\":\"Bosnia y Herzegovina\",\"fr\":\"Bosnie-Herzégovine\",\"ja\":\"ボスニア・ヘルツェゴビナ\",\"it\":\"Bosnia ed Erzegovina\",\"cn\":\"波斯尼亚和黑塞哥维那\",\"tr\":\"Bosna Hersek\"}',44.00000000,18.00000000,'','U+1F1E7 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q225'),
(29,'Botswana','BWA','072','BW','267','Gaborone','BWP','Botswana pula','P','.bw','Botswana','Africa','Southern Africa','[{\"zoneName\":\"Africa/Gaborone\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"보츠와나\",\"br\":\"Botsuana\",\"pt\":\"Botsuana\",\"nl\":\"Botswana\",\"hr\":\"Bocvana\",\"fa\":\"بوتسوانا\",\"de\":\"Botswana\",\"es\":\"Botswana\",\"fr\":\"Botswana\",\"ja\":\"ボツワナ\",\"it\":\"Botswana\",\"cn\":\"博茨瓦纳\",\"tr\":\"Botsvana\"}',-22.00000000,24.00000000,'','U+1F1E7 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q963'),
(30,'Bouvet Island','BVT','074','BV','0055','','NOK','Norwegian Krone','kr','.bv','Bouvetøya','','','[{\"zoneName\":\"Europe/Oslo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"부벳 섬\",\"br\":\"Ilha Bouvet\",\"pt\":\"Ilha Bouvet\",\"nl\":\"Bouveteiland\",\"hr\":\"Otok Bouvet\",\"fa\":\"جزیره بووه\",\"de\":\"Bouvetinsel\",\"es\":\"Isla Bouvet\",\"fr\":\"Île Bouvet\",\"ja\":\"ブーベ島\",\"it\":\"Isola Bouvet\",\"cn\":\"布维岛\",\"tr\":\"Bouvet Adasi\"}',-54.43333333,3.40000000,'','U+1F1E7 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(31,'Brazil','BRA','076','BR','55','Brasilia','BRL','Brazilian real','R$','.br','Brasil','Americas','South America','[{\"zoneName\":\"America/Araguaina\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Bahia\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Belem\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Boa_Vista\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Campo_Grande\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Cuiaba\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasilia Time\"},{\"zoneName\":\"America/Eirunepe\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ACT\",\"tzName\":\"Acre Time\"},{\"zoneName\":\"America/Fortaleza\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Maceio\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Manaus\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)\"},{\"zoneName\":\"America/Noronha\",\"gmtOffset\":-7200,\"gmtOffsetName\":\"UTC-02:00\",\"abbreviation\":\"FNT\",\"tzName\":\"Fernando de Noronha Time\"},{\"zoneName\":\"America/Porto_Velho\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AMT\",\"tzName\":\"Amazon Time (Brazil)[3\"},{\"zoneName\":\"America/Recife\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Rio_Branco\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ACT\",\"tzName\":\"Acre Time\"},{\"zoneName\":\"America/Santarem\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"},{\"zoneName\":\"America/Sao_Paulo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"BRT\",\"tzName\":\"Brasília Time\"}]','{\"kr\":\"브라질\",\"br\":\"Brasil\",\"pt\":\"Brasil\",\"nl\":\"Brazilië\",\"hr\":\"Brazil\",\"fa\":\"برزیل\",\"de\":\"Brasilien\",\"es\":\"Brasil\",\"fr\":\"Brésil\",\"ja\":\"ブラジル\",\"it\":\"Brasile\",\"cn\":\"巴西\",\"tr\":\"Brezilya\"}',-10.00000000,-55.00000000,'','U+1F1E7 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q155'),
(32,'British Indian Ocean Territory','IOT','086','IO','246','Diego Garcia','USD','United States dollar','$','.io','British Indian Ocean Territory','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Chagos\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"IOT\",\"tzName\":\"Indian Ocean Time\"}]','{\"kr\":\"영국령 인도양 지역\",\"br\":\"Território Britânico do Oceano íÍdico\",\"pt\":\"Território Britânico do Oceano Índico\",\"nl\":\"Britse Gebieden in de Indische Oceaan\",\"hr\":\"Britanski Indijskooceanski teritorij\",\"fa\":\"قلمرو بریتانیا در اقیانوس هند\",\"de\":\"Britisches Territorium im Indischen Ozean\",\"es\":\"Territorio Británico del Océano Índico\",\"fr\":\"Territoire britannique de l\'océan Indien\",\"ja\":\"イギリス領インド洋地域\",\"it\":\"Territorio britannico dell\'oceano indiano\",\"cn\":\"英属印度洋领地\",\"tr\":\"Britanya Hint Okyanusu Topraklari\"}',-6.00000000,71.50000000,'','U+1F1EE U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(33,'Brunei','BRN','096','BN','673','Bandar Seri Begawan','BND','Brunei dollar','B$','.bn','Negara Brunei Darussalam','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Brunei\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"BNT\",\"tzName\":\"Brunei Darussalam Time\"}]','{\"kr\":\"브루나이\",\"br\":\"Brunei\",\"pt\":\"Brunei\",\"nl\":\"Brunei\",\"hr\":\"Brunej\",\"fa\":\"برونئی\",\"de\":\"Brunei\",\"es\":\"Brunei\",\"fr\":\"Brunei\",\"ja\":\"ブルネイ・ダルサラーム\",\"it\":\"Brunei\",\"cn\":\"文莱\",\"tr\":\"Brunei\"}',4.50000000,114.66666666,'','U+1F1E7 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q921'),
(34,'Bulgaria','BGR','100','BG','359','Sofia','BGN','Bulgarian lev','Лв.','.bg','България','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Sofia\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"불가리아\",\"br\":\"Bulgária\",\"pt\":\"Bulgária\",\"nl\":\"Bulgarije\",\"hr\":\"Bugarska\",\"fa\":\"بلغارستان\",\"de\":\"Bulgarien\",\"es\":\"Bulgaria\",\"fr\":\"Bulgarie\",\"ja\":\"ブルガリア\",\"it\":\"Bulgaria\",\"cn\":\"保加利亚\",\"tr\":\"Bulgaristan\"}',43.00000000,25.00000000,'','U+1F1E7 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q219'),
(35,'Burkina Faso','BFA','854','BF','226','Ouagadougou','XOF','West African CFA franc','CFA','.bf','Burkina Faso','Africa','Western Africa','[{\"zoneName\":\"Africa/Ouagadougou\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"부르키나 파소\",\"br\":\"Burkina Faso\",\"pt\":\"Burquina Faso\",\"nl\":\"Burkina Faso\",\"hr\":\"Burkina Faso\",\"fa\":\"بورکینافاسو\",\"de\":\"Burkina Faso\",\"es\":\"Burkina Faso\",\"fr\":\"Burkina Faso\",\"ja\":\"ブルキナファソ\",\"it\":\"Burkina Faso\",\"cn\":\"布基纳法索\",\"tr\":\"Burkina Faso\"}',13.00000000,-2.00000000,'','U+1F1E7 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q965'),
(36,'Burundi','BDI','108','BI','257','Bujumbura','BIF','Burundian franc','FBu','.bi','Burundi','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Bujumbura\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"부룬디\",\"br\":\"Burundi\",\"pt\":\"Burúndi\",\"nl\":\"Burundi\",\"hr\":\"Burundi\",\"fa\":\"بوروندی\",\"de\":\"Burundi\",\"es\":\"Burundi\",\"fr\":\"Burundi\",\"ja\":\"ブルンジ\",\"it\":\"Burundi\",\"cn\":\"布隆迪\",\"tr\":\"Burundi\"}',-3.50000000,30.00000000,'','U+1F1E7 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q967'),
(37,'Cambodia','KHM','116','KH','855','Phnom Penh','KHR','Cambodian riel','KHR','.kh','Kâmpŭchéa','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Phnom_Penh\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]','{\"kr\":\"캄보디아\",\"br\":\"Camboja\",\"pt\":\"Camboja\",\"nl\":\"Cambodja\",\"hr\":\"Kambodža\",\"fa\":\"کامبوج\",\"de\":\"Kambodscha\",\"es\":\"Camboya\",\"fr\":\"Cambodge\",\"ja\":\"カンボジア\",\"it\":\"Cambogia\",\"cn\":\"柬埔寨\",\"tr\":\"Kamboçya\"}',13.00000000,105.00000000,'','U+1F1F0 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q424'),
(38,'Cameroon','CMR','120','CM','237','Yaounde','XAF','Central African CFA franc','FCFA','.cm','Cameroon','Africa','Middle Africa','[{\"zoneName\":\"Africa/Douala\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"카메룬\",\"br\":\"Camarões\",\"pt\":\"Camarões\",\"nl\":\"Kameroen\",\"hr\":\"Kamerun\",\"fa\":\"کامرون\",\"de\":\"Kamerun\",\"es\":\"Camerún\",\"fr\":\"Cameroun\",\"ja\":\"カメルーン\",\"it\":\"Camerun\",\"cn\":\"喀麦隆\",\"tr\":\"Kamerun\"}',6.00000000,12.00000000,'','U+1F1E8 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q1009'),
(39,'Canada','CAN','124','CA','1','Ottawa','CAD','Canadian dollar','$','.ca','Canada','Americas','Northern America','[{\"zoneName\":\"America/Atikokan\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America)\"},{\"zoneName\":\"America/Blanc-Sablon\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Cambridge_Bay\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Creston\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Dawson\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Dawson_Creek\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Edmonton\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Fort_Nelson\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America)\"},{\"zoneName\":\"America/Glace_Bay\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Goose_Bay\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Halifax\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Inuvik\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Iqaluit\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Moncton\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"},{\"zoneName\":\"America/Nipigon\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Pangnirtung\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Rainy_River\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Rankin_Inlet\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Regina\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Resolute\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/St_Johns\",\"gmtOffset\":-12600,\"gmtOffsetName\":\"UTC-03:30\",\"abbreviation\":\"NST\",\"tzName\":\"Newfoundland Standard Time\"},{\"zoneName\":\"America/Swift_Current\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Thunder_Bay\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Toronto\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Vancouver\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"},{\"zoneName\":\"America/Whitehorse\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Winnipeg\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Yellowknife\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"}]','{\"kr\":\"캐나다\",\"br\":\"Canadá\",\"pt\":\"Canadá\",\"nl\":\"Canada\",\"hr\":\"Kanada\",\"fa\":\"کانادا\",\"de\":\"Kanada\",\"es\":\"Canadá\",\"fr\":\"Canada\",\"ja\":\"カナダ\",\"it\":\"Canada\",\"cn\":\"加拿大\",\"tr\":\"Kanada\"}',60.00000000,-95.00000000,'','U+1F1E8 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q16'),
(40,'Cape Verde','CPV','132','CV','238','Praia','CVE','Cape Verdean escudo','$','.cv','Cabo Verde','Africa','Western Africa','[{\"zoneName\":\"Atlantic/Cape_Verde\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"CVT\",\"tzName\":\"Cape Verde Time\"}]','{\"kr\":\"카보베르데\",\"br\":\"Cabo Verde\",\"pt\":\"Cabo Verde\",\"nl\":\"Kaapverdië\",\"hr\":\"Zelenortska Republika\",\"fa\":\"کیپ ورد\",\"de\":\"Kap Verde\",\"es\":\"Cabo Verde\",\"fr\":\"Cap Vert\",\"ja\":\"カーボベルデ\",\"it\":\"Capo Verde\",\"cn\":\"佛得角\",\"tr\":\"Cabo Verde\"}',16.00000000,-24.00000000,'','U+1F1E8 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q1011'),
(41,'Cayman Islands','CYM','136','KY','+1-345','George Town','KYD','Cayman Islands dollar','$','.ky','Cayman Islands','Americas','Caribbean','[{\"zoneName\":\"America/Cayman\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]','{\"kr\":\"케이먼 제도\",\"br\":\"Ilhas Cayman\",\"pt\":\"Ilhas Caimão\",\"nl\":\"Caymaneilanden\",\"hr\":\"Kajmanski otoci\",\"fa\":\"جزایر کیمن\",\"de\":\"Kaimaninseln\",\"es\":\"Islas Caimán\",\"fr\":\"Îles Caïmans\",\"ja\":\"ケイマン諸島\",\"it\":\"Isole Cayman\",\"cn\":\"开曼群岛\",\"tr\":\"Cayman Adalari\"}',19.50000000,-80.50000000,'','U+1F1F0 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(42,'Central African Republic','CAF','140','CF','236','Bangui','XAF','Central African CFA franc','FCFA','.cf','Ködörösêse tî Bêafrîka','Africa','Middle Africa','[{\"zoneName\":\"Africa/Bangui\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"중앙아프리카 공화국\",\"br\":\"República Centro-Africana\",\"pt\":\"República Centro-Africana\",\"nl\":\"Centraal-Afrikaanse Republiek\",\"hr\":\"Srednjoafrička Republika\",\"fa\":\"جمهوری آفریقای مرکزی\",\"de\":\"Zentralafrikanische Republik\",\"es\":\"República Centroafricana\",\"fr\":\"République centrafricaine\",\"ja\":\"中央アフリカ共和国\",\"it\":\"Repubblica Centrafricana\",\"cn\":\"中非\",\"tr\":\"Orta Afrika Cumhuriyeti\"}',7.00000000,21.00000000,'','U+1F1E8 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q929'),
(43,'Chad','TCD','148','TD','235','N\'Djamena','XAF','Central African CFA franc','FCFA','.td','Tchad','Africa','Middle Africa','[{\"zoneName\":\"Africa/Ndjamena\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"차드\",\"br\":\"Chade\",\"pt\":\"Chade\",\"nl\":\"Tsjaad\",\"hr\":\"Čad\",\"fa\":\"چاد\",\"de\":\"Tschad\",\"es\":\"Chad\",\"fr\":\"Tchad\",\"ja\":\"チャド\",\"it\":\"Ciad\",\"cn\":\"乍得\",\"tr\":\"Çad\"}',15.00000000,19.00000000,'','U+1F1F9 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q657'),
(44,'Chile','CHL','152','CL','56','Santiago','CLP','Chilean peso','$','.cl','Chile','Americas','South America','[{\"zoneName\":\"America/Punta_Arenas\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"America/Santiago\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"CLST\",\"tzName\":\"Chile Summer Time\"},{\"zoneName\":\"Pacific/Easter\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EASST\",\"tzName\":\"Easter Island Summer Time\"}]','{\"kr\":\"칠리\",\"br\":\"Chile\",\"pt\":\"Chile\",\"nl\":\"Chili\",\"hr\":\"Čile\",\"fa\":\"شیلی\",\"de\":\"Chile\",\"es\":\"Chile\",\"fr\":\"Chili\",\"ja\":\"チリ\",\"it\":\"Cile\",\"cn\":\"智利\",\"tr\":\"Şili\"}',-30.00000000,-71.00000000,'','U+1F1E8 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q298'),
(45,'China','CHN','156','CN','86','Beijing','CNY','Chinese yuan','¥','.cn','中国','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Shanghai\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"},{\"zoneName\":\"Asia/Urumqi\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"XJT\",\"tzName\":\"China Standard Time\"}]','{\"kr\":\"중국\",\"br\":\"China\",\"pt\":\"China\",\"nl\":\"China\",\"hr\":\"Kina\",\"fa\":\"چین\",\"de\":\"China\",\"es\":\"China\",\"fr\":\"Chine\",\"ja\":\"中国\",\"it\":\"Cina\",\"cn\":\"中国\",\"tr\":\"Çin\"}',35.00000000,105.00000000,'','U+1F1E8 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q148'),
(46,'Christmas Island','CXR','162','CX','61','Flying Fish Cove','AUD','Australian dollar','$','.cx','Christmas Island','Oceania','Australia and New Zealand','[{\"zoneName\":\"Indian/Christmas\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"CXT\",\"tzName\":\"Christmas Island Time\"}]','{\"kr\":\"크리스마스 섬\",\"br\":\"Ilha Christmas\",\"pt\":\"Ilha do Natal\",\"nl\":\"Christmaseiland\",\"hr\":\"Božićni otok\",\"fa\":\"جزیره کریسمس\",\"de\":\"Weihnachtsinsel\",\"es\":\"Isla de Navidad\",\"fr\":\"Île Christmas\",\"ja\":\"クリスマス島\",\"it\":\"Isola di Natale\",\"cn\":\"圣诞岛\",\"tr\":\"Christmas Adasi\"}',-10.50000000,105.66666666,'','U+1F1E8 U+1F1FD','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(47,'Cocos (Keeling) Islands','CCK','166','CC','61','West Island','AUD','Australian dollar','$','.cc','Cocos (Keeling) Islands','Oceania','Australia and New Zealand','[{\"zoneName\":\"Indian/Cocos\",\"gmtOffset\":23400,\"gmtOffsetName\":\"UTC+06:30\",\"abbreviation\":\"CCT\",\"tzName\":\"Cocos Islands Time\"}]','{\"kr\":\"코코스 제도\",\"br\":\"Ilhas Cocos\",\"pt\":\"Ilhas dos Cocos\",\"nl\":\"Cocoseilanden\",\"hr\":\"Kokosovi Otoci\",\"fa\":\"جزایر کوکوس\",\"de\":\"Kokosinseln\",\"es\":\"Islas Cocos o Islas Keeling\",\"fr\":\"Îles Cocos\",\"ja\":\"ココス（キーリング）諸島\",\"it\":\"Isole Cocos e Keeling\",\"cn\":\"科科斯（基林）群岛\",\"tr\":\"Cocos Adalari\"}',-12.50000000,96.83333333,'','U+1F1E8 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:11:20',1,NULL),
(48,'Colombia','COL','170','CO','57','Bogotá','COP','Colombian peso','$','.co','Colombia','Americas','South America','[{\"zoneName\":\"America/Bogota\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"COT\",\"tzName\":\"Colombia Time\"}]','{\"kr\":\"콜롬비아\",\"br\":\"Colômbia\",\"pt\":\"Colômbia\",\"nl\":\"Colombia\",\"hr\":\"Kolumbija\",\"fa\":\"کلمبیا\",\"de\":\"Kolumbien\",\"es\":\"Colombia\",\"fr\":\"Colombie\",\"ja\":\"コロンビア\",\"it\":\"Colombia\",\"cn\":\"哥伦比亚\",\"tr\":\"Kolombiya\"}',4.00000000,-72.00000000,'','U+1F1E8 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q739'),
(49,'Comoros','COM','174','KM','269','Moroni','KMF','Comorian franc','CF','.km','Komori','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Comoro\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"코모로\",\"br\":\"Comores\",\"pt\":\"Comores\",\"nl\":\"Comoren\",\"hr\":\"Komori\",\"fa\":\"کومور\",\"de\":\"Union der Komoren\",\"es\":\"Comoras\",\"fr\":\"Comores\",\"ja\":\"コモロ\",\"it\":\"Comore\",\"cn\":\"科摩罗\",\"tr\":\"Komorlar\"}',-12.16666666,44.25000000,'','U+1F1F0 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q970'),
(50,'Congo','COG','178','CG','242','Brazzaville','XAF','Central African CFA franc','FC','.cg','République du Congo','Africa','Middle Africa','[{\"zoneName\":\"Africa/Brazzaville\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"콩고\",\"br\":\"Congo\",\"pt\":\"Congo\",\"nl\":\"Congo [Republiek]\",\"hr\":\"Kongo\",\"fa\":\"کنگو\",\"de\":\"Kongo\",\"es\":\"Congo\",\"fr\":\"Congo\",\"ja\":\"コンゴ共和国\",\"it\":\"Congo\",\"cn\":\"刚果\",\"tr\":\"Kongo\"}',-1.00000000,15.00000000,'','U+1F1E8 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:11:20',1,'Q971'),
(51,'Democratic Republic of the Congo','COD','180','CD','243','Kinshasa','CDF','Congolese Franc','FC','.cd','République démocratique du Congo','Africa','Middle Africa','[{\"zoneName\":\"Africa/Kinshasa\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"},{\"zoneName\":\"Africa/Lubumbashi\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"콩고 민주 공화국\",\"br\":\"RD Congo\",\"pt\":\"RD Congo\",\"nl\":\"Congo [DRC]\",\"hr\":\"Kongo, Demokratska Republika\",\"fa\":\"جمهوری کنگو\",\"de\":\"Kongo (Dem. Rep.)\",\"es\":\"Congo (Rep. Dem.)\",\"fr\":\"Congo (Rép. dém.)\",\"ja\":\"コンゴ民主共和国\",\"it\":\"Congo (Rep. Dem.)\",\"cn\":\"刚果（金）\",\"tr\":\"Kongo Demokratik Cumhuriyeti\"}',0.00000000,25.00000000,'','U+1F1E8 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q974'),
(52,'Cook Islands','COK','184','CK','682','Avarua','NZD','Cook Islands dollar','$','.ck','Cook Islands','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Rarotonga\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"CKT\",\"tzName\":\"Cook Island Time\"}]','{\"kr\":\"쿡 제도\",\"br\":\"Ilhas Cook\",\"pt\":\"Ilhas Cook\",\"nl\":\"Cookeilanden\",\"hr\":\"Cookovo Otočje\",\"fa\":\"جزایر کوک\",\"de\":\"Cookinseln\",\"es\":\"Islas Cook\",\"fr\":\"Îles Cook\",\"ja\":\"クック諸島\",\"it\":\"Isole Cook\",\"cn\":\"库克群岛\",\"tr\":\"Cook Adalari\"}',-21.23333333,-159.76666666,'','U+1F1E8 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q26988'),
(53,'Costa Rica','CRI','188','CR','506','San Jose','CRC','Costa Rican colón','₡','.cr','Costa Rica','Americas','Central America','[{\"zoneName\":\"America/Costa_Rica\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]','{\"kr\":\"코스타리카\",\"br\":\"Costa Rica\",\"pt\":\"Costa Rica\",\"nl\":\"Costa Rica\",\"hr\":\"Kostarika\",\"fa\":\"کاستاریکا\",\"de\":\"Costa Rica\",\"es\":\"Costa Rica\",\"fr\":\"Costa Rica\",\"ja\":\"コスタリカ\",\"it\":\"Costa Rica\",\"cn\":\"哥斯达黎加\",\"tr\":\"Kosta Rika\"}',10.00000000,-84.00000000,'','U+1F1E8 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q800'),
(54,'Cote D\'Ivoire (Ivory Coast)','CIV','384','CI','225','Yamoussoukro','XOF','West African CFA franc','CFA','.ci',NULL,'Africa','Western Africa','[{\"zoneName\":\"Africa/Abidjan\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"코트디부아르\",\"br\":\"Costa do Marfim\",\"pt\":\"Costa do Marfim\",\"nl\":\"Ivoorkust\",\"hr\":\"Obala Bjelokosti\",\"fa\":\"ساحل عاج\",\"de\":\"Elfenbeinküste\",\"es\":\"Costa de Marfil\",\"fr\":\"Côte d\'Ivoire\",\"ja\":\"コートジボワール\",\"it\":\"Costa D\'Avorio\",\"cn\":\"科特迪瓦\",\"tr\":\"Kotdivuar\"}',8.00000000,-5.00000000,'','U+1F1E8 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q1008'),
(55,'Croatia','HRV','191','HR','385','Zagreb','HRK','Croatian kuna','kn','.hr','Hrvatska','Europe','Southern Europe','[{\"zoneName\":\"Europe/Zagreb\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"크로아티아\",\"br\":\"Croácia\",\"pt\":\"Croácia\",\"nl\":\"Kroatië\",\"hr\":\"Hrvatska\",\"fa\":\"کرواسی\",\"de\":\"Kroatien\",\"es\":\"Croacia\",\"fr\":\"Croatie\",\"ja\":\"クロアチア\",\"it\":\"Croazia\",\"cn\":\"克罗地亚\",\"tr\":\"Hirvatistan\"}',45.16666666,15.50000000,'','U+1F1ED U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q224'),
(56,'Cuba','CUB','192','CU','53','Havana','CUP','Cuban peso','$','.cu','Cuba','Americas','Caribbean','[{\"zoneName\":\"America/Havana\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"CST\",\"tzName\":\"Cuba Standard Time\"}]','{\"kr\":\"쿠바\",\"br\":\"Cuba\",\"pt\":\"Cuba\",\"nl\":\"Cuba\",\"hr\":\"Kuba\",\"fa\":\"کوبا\",\"de\":\"Kuba\",\"es\":\"Cuba\",\"fr\":\"Cuba\",\"ja\":\"キューバ\",\"it\":\"Cuba\",\"cn\":\"古巴\",\"tr\":\"Küba\"}',21.50000000,-80.00000000,'','U+1F1E8 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q241'),
(57,'Cyprus','CYP','196','CY','357','Nicosia','EUR','Euro','€','.cy','Κύπρος','Europe','Southern Europe','[{\"zoneName\":\"Asia/Famagusta\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Asia/Nicosia\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"키프로스\",\"br\":\"Chipre\",\"pt\":\"Chipre\",\"nl\":\"Cyprus\",\"hr\":\"Cipar\",\"fa\":\"قبرس\",\"de\":\"Zypern\",\"es\":\"Chipre\",\"fr\":\"Chypre\",\"ja\":\"キプロス\",\"it\":\"Cipro\",\"cn\":\"塞浦路斯\",\"tr\":\"Kuzey Kıbrıs Türk Cumhuriyeti\"}',35.00000000,33.00000000,'','U+1F1E8 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q229'),
(58,'Czech Republic','CZE','203','CZ','420','Prague','CZK','Czech koruna','Kč','.cz','Česká republika','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Prague\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"체코\",\"br\":\"República Tcheca\",\"pt\":\"República Checa\",\"nl\":\"Tsjechië\",\"hr\":\"Češka\",\"fa\":\"جمهوری چک\",\"de\":\"Tschechische Republik\",\"es\":\"República Checa\",\"fr\":\"République tchèque\",\"ja\":\"チェコ\",\"it\":\"Repubblica Ceca\",\"cn\":\"捷克\",\"tr\":\"Çekya\"}',49.75000000,15.50000000,'','U+1F1E8 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q213'),
(59,'Denmark','DNK','208','DK','45','Copenhagen','DKK','Danish krone','Kr.','.dk','Danmark','Europe','Northern Europe','[{\"zoneName\":\"Europe/Copenhagen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"덴마크\",\"br\":\"Dinamarca\",\"pt\":\"Dinamarca\",\"nl\":\"Denemarken\",\"hr\":\"Danska\",\"fa\":\"دانمارک\",\"de\":\"Dänemark\",\"es\":\"Dinamarca\",\"fr\":\"Danemark\",\"ja\":\"デンマーク\",\"it\":\"Danimarca\",\"cn\":\"丹麦\",\"tr\":\"Danimarka\"}',56.00000000,10.00000000,'','U+1F1E9 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:13:35',1,'Q35'),
(60,'Djibouti','DJI','262','DJ','253','Djibouti','DJF','Djiboutian franc','Fdj','.dj','Djibouti','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Djibouti\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"지부티\",\"br\":\"Djibuti\",\"pt\":\"Djibuti\",\"nl\":\"Djibouti\",\"hr\":\"Džibuti\",\"fa\":\"جیبوتی\",\"de\":\"Dschibuti\",\"es\":\"Yibuti\",\"fr\":\"Djibouti\",\"ja\":\"ジブチ\",\"it\":\"Gibuti\",\"cn\":\"吉布提\",\"tr\":\"Cibuti\"}',11.50000000,43.00000000,'','U+1F1E9 U+1F1EF','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q977'),
(61,'Dominica','DMA','212','DM','+1-767','Roseau','XCD','Eastern Caribbean dollar','$','.dm','Dominica','Americas','Caribbean','[{\"zoneName\":\"America/Dominica\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"도미니카 연방\",\"br\":\"Dominica\",\"pt\":\"Dominica\",\"nl\":\"Dominica\",\"hr\":\"Dominika\",\"fa\":\"دومینیکا\",\"de\":\"Dominica\",\"es\":\"Dominica\",\"fr\":\"Dominique\",\"ja\":\"ドミニカ国\",\"it\":\"Dominica\",\"cn\":\"多米尼加\",\"tr\":\"Dominika\"}',15.41666666,-61.33333333,'','U+1F1E9 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q784'),
(62,'Dominican Republic','DOM','214','DO','+1-809 and 1-829','Santo Domingo','DOP','Dominican peso','$','.do','República Dominicana','Americas','Caribbean','[{\"zoneName\":\"America/Santo_Domingo\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"도미니카 공화국\",\"br\":\"República Dominicana\",\"pt\":\"República Dominicana\",\"nl\":\"Dominicaanse Republiek\",\"hr\":\"Dominikanska Republika\",\"fa\":\"جمهوری دومینیکن\",\"de\":\"Dominikanische Republik\",\"es\":\"República Dominicana\",\"fr\":\"République dominicaine\",\"ja\":\"ドミニカ共和国\",\"it\":\"Repubblica Dominicana\",\"cn\":\"多明尼加共和国\",\"tr\":\"Dominik Cumhuriyeti\"}',19.00000000,-70.66666666,'','U+1F1E9 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q786'),
(63,'East Timor','TLS','626','TL','670','Dili','USD','United States dollar','$','.tl','Timor-Leste','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Dili\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"TLT\",\"tzName\":\"Timor Leste Time\"}]','{\"kr\":\"동티모르\",\"br\":\"Timor Leste\",\"pt\":\"Timor Leste\",\"nl\":\"Oost-Timor\",\"hr\":\"Istočni Timor\",\"fa\":\"تیمور شرقی\",\"de\":\"Timor-Leste\",\"es\":\"Timor Oriental\",\"fr\":\"Timor oriental\",\"ja\":\"東ティモール\",\"it\":\"Timor Est\",\"cn\":\"东帝汶\",\"tr\":\"Doğu Timor\"}',-8.83333333,125.91666666,'','U+1F1F9 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q574'),
(64,'Ecuador','ECU','218','EC','593','Quito','USD','United States dollar','$','.ec','Ecuador','Americas','South America','[{\"zoneName\":\"America/Guayaquil\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"ECT\",\"tzName\":\"Ecuador Time\"},{\"zoneName\":\"Pacific/Galapagos\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"GALT\",\"tzName\":\"Galápagos Time\"}]','{\"kr\":\"에콰도르\",\"br\":\"Equador\",\"pt\":\"Equador\",\"nl\":\"Ecuador\",\"hr\":\"Ekvador\",\"fa\":\"اکوادور\",\"de\":\"Ecuador\",\"es\":\"Ecuador\",\"fr\":\"Équateur\",\"ja\":\"エクアドル\",\"it\":\"Ecuador\",\"cn\":\"厄瓜多尔\",\"tr\":\"Ekvator\"}',-2.00000000,-77.50000000,'','U+1F1EA U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q736'),
(65,'Egypt','EGY','818','EG','20','Cairo','EGP','Egyptian pound','ج.م','.eg','مصر‎','Africa','Northern Africa','[{\"zoneName\":\"Africa/Cairo\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"이집트\",\"br\":\"Egito\",\"pt\":\"Egipto\",\"nl\":\"Egypte\",\"hr\":\"Egipat\",\"fa\":\"مصر\",\"de\":\"Ägypten\",\"es\":\"Egipto\",\"fr\":\"Égypte\",\"ja\":\"エジプト\",\"it\":\"Egitto\",\"cn\":\"埃及\",\"tr\":\"Mısır\"}',27.00000000,30.00000000,'','U+1F1EA U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q79'),
(66,'El Salvador','SLV','222','SV','503','San Salvador','USD','United States dollar','$','.sv','El Salvador','Americas','Central America','[{\"zoneName\":\"America/El_Salvador\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]','{\"kr\":\"엘살바도르\",\"br\":\"El Salvador\",\"pt\":\"El Salvador\",\"nl\":\"El Salvador\",\"hr\":\"Salvador\",\"fa\":\"السالوادور\",\"de\":\"El Salvador\",\"es\":\"El Salvador\",\"fr\":\"Salvador\",\"ja\":\"エルサルバドル\",\"it\":\"El Salvador\",\"cn\":\"萨尔瓦多\",\"tr\":\"El Salvador\"}',13.83333333,-88.91666666,'','U+1F1F8 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q792'),
(67,'Equatorial Guinea','GNQ','226','GQ','240','Malabo','XAF','Central African CFA franc','FCFA','.gq','Guinea Ecuatorial','Africa','Middle Africa','[{\"zoneName\":\"Africa/Malabo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"적도 기니\",\"br\":\"Guiné Equatorial\",\"pt\":\"Guiné Equatorial\",\"nl\":\"Equatoriaal-Guinea\",\"hr\":\"Ekvatorijalna Gvineja\",\"fa\":\"گینه استوایی\",\"de\":\"Äquatorial-Guinea\",\"es\":\"Guinea Ecuatorial\",\"fr\":\"Guinée-Équatoriale\",\"ja\":\"赤道ギニア\",\"it\":\"Guinea Equatoriale\",\"cn\":\"赤道几内亚\",\"tr\":\"Ekvator Ginesi\"}',2.00000000,10.00000000,'','U+1F1EC U+1F1F6','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q983'),
(68,'Eritrea','ERI','232','ER','291','Asmara','ERN','Eritrean nakfa','Nfk','.er','ኤርትራ','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Asmara\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"에리트레아\",\"br\":\"Eritreia\",\"pt\":\"Eritreia\",\"nl\":\"Eritrea\",\"hr\":\"Eritreja\",\"fa\":\"اریتره\",\"de\":\"Eritrea\",\"es\":\"Eritrea\",\"fr\":\"Érythrée\",\"ja\":\"エリトリア\",\"it\":\"Eritrea\",\"cn\":\"厄立特里亚\",\"tr\":\"Eritre\"}',15.00000000,39.00000000,'','U+1F1EA U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q986'),
(69,'Estonia','EST','233','EE','372','Tallinn','EUR','Euro','€','.ee','Eesti','Europe','Northern Europe','[{\"zoneName\":\"Europe/Tallinn\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"에스토니아\",\"br\":\"Estônia\",\"pt\":\"Estónia\",\"nl\":\"Estland\",\"hr\":\"Estonija\",\"fa\":\"استونی\",\"de\":\"Estland\",\"es\":\"Estonia\",\"fr\":\"Estonie\",\"ja\":\"エストニア\",\"it\":\"Estonia\",\"cn\":\"爱沙尼亚\",\"tr\":\"Estonya\"}',59.00000000,26.00000000,'','U+1F1EA U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:17:53',1,'Q191'),
(70,'Ethiopia','ETH','231','ET','251','Addis Ababa','ETB','Ethiopian birr','Nkf','.et','ኢትዮጵያ','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Addis_Ababa\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"에티오피아\",\"br\":\"Etiópia\",\"pt\":\"Etiópia\",\"nl\":\"Ethiopië\",\"hr\":\"Etiopija\",\"fa\":\"اتیوپی\",\"de\":\"Äthiopien\",\"es\":\"Etiopía\",\"fr\":\"Éthiopie\",\"ja\":\"エチオピア\",\"it\":\"Etiopia\",\"cn\":\"埃塞俄比亚\",\"tr\":\"Etiyopya\"}',8.00000000,38.00000000,'','U+1F1EA U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q115'),
(71,'Falkland Islands','FLK','238','FK','500','Stanley','FKP','Falkland Islands pound','£','.fk','Falkland Islands','Americas','South America','[{\"zoneName\":\"Atlantic/Stanley\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"FKST\",\"tzName\":\"Falkland Islands Summer Time\"}]','{\"kr\":\"포클랜드 제도\",\"br\":\"Ilhas Malvinas\",\"pt\":\"Ilhas Falkland\",\"nl\":\"Falklandeilanden [Islas Malvinas]\",\"hr\":\"Falklandski Otoci\",\"fa\":\"جزایر فالکلند\",\"de\":\"Falklandinseln\",\"es\":\"Islas Malvinas\",\"fr\":\"Îles Malouines\",\"ja\":\"フォークランド（マルビナス）諸島\",\"it\":\"Isole Falkland o Isole Malvine\",\"cn\":\"福克兰群岛\",\"tr\":\"Falkland Adalari\"}',-51.75000000,-59.00000000,'','U+1F1EB U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(72,'Faroe Islands','FRO','234','FO','298','Torshavn','DKK','Danish krone','Kr.','.fo','Føroyar','Europe','Northern Europe','[{\"zoneName\":\"Atlantic/Faroe\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"}]','{\"kr\":\"페로 제도\",\"br\":\"Ilhas Faroé\",\"pt\":\"Ilhas Faroé\",\"nl\":\"Faeröer\",\"hr\":\"Farski Otoci\",\"fa\":\"جزایر فارو\",\"de\":\"Färöer-Inseln\",\"es\":\"Islas Faroe\",\"fr\":\"Îles Féroé\",\"ja\":\"フェロー諸島\",\"it\":\"Isole Far Oer\",\"cn\":\"法罗群岛\",\"tr\":\"Faroe Adalari\"}',62.00000000,-7.00000000,'','U+1F1EB U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(73,'Fiji Islands','FJI','242','FJ','679','Suva','FJD','Fijian dollar','FJ$','.fj','Fiji','Oceania','Melanesia','[{\"zoneName\":\"Pacific/Fiji\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"FJT\",\"tzName\":\"Fiji Time\"}]','{\"kr\":\"피지\",\"br\":\"Fiji\",\"pt\":\"Fiji\",\"nl\":\"Fiji\",\"hr\":\"Fiđi\",\"fa\":\"فیجی\",\"de\":\"Fidschi\",\"es\":\"Fiyi\",\"fr\":\"Fidji\",\"ja\":\"フィジー\",\"it\":\"Figi\",\"cn\":\"斐济\",\"tr\":\"Fiji\"}',-18.00000000,175.00000000,'','U+1F1EB U+1F1EF','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q712'),
(74,'Finland','FIN','246','FI','358','Helsinki','EUR','Euro','€','.fi','Suomi','Europe','Northern Europe','[{\"zoneName\":\"Europe/Helsinki\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"핀란드\",\"br\":\"Finlândia\",\"pt\":\"Finlândia\",\"nl\":\"Finland\",\"hr\":\"Finska\",\"fa\":\"فنلاند\",\"de\":\"Finnland\",\"es\":\"Finlandia\",\"fr\":\"Finlande\",\"ja\":\"フィンランド\",\"it\":\"Finlandia\",\"cn\":\"芬兰\",\"tr\":\"Finlandiya\"}',64.00000000,26.00000000,'','U+1F1EB U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q33'),
(75,'France','FRA','250','FR','33','Paris','EUR','Euro','€','.fr','France','Europe','Western Europe','[{\"zoneName\":\"Europe/Paris\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"프랑스\",\"br\":\"França\",\"pt\":\"França\",\"nl\":\"Frankrijk\",\"hr\":\"Francuska\",\"fa\":\"فرانسه\",\"de\":\"Frankreich\",\"es\":\"Francia\",\"fr\":\"France\",\"ja\":\"フランス\",\"it\":\"Francia\",\"cn\":\"法国\",\"tr\":\"Fransa\"}',46.00000000,2.00000000,'','U+1F1EB U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q142'),
(76,'French Guiana','GUF','254','GF','594','Cayenne','EUR','Euro','€','.gf','Guyane française','Americas','South America','[{\"zoneName\":\"America/Cayenne\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"GFT\",\"tzName\":\"French Guiana Time\"}]','{\"kr\":\"프랑스령 기아나\",\"br\":\"Guiana Francesa\",\"pt\":\"Guiana Francesa\",\"nl\":\"Frans-Guyana\",\"hr\":\"Francuska Gvajana\",\"fa\":\"گویان فرانسه\",\"de\":\"Französisch Guyana\",\"es\":\"Guayana Francesa\",\"fr\":\"Guayane\",\"ja\":\"フランス領ギアナ\",\"it\":\"Guyana francese\",\"cn\":\"法属圭亚那\",\"tr\":\"Fransiz Guyanasi\"}',4.00000000,-53.00000000,'','U+1F1EC U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(77,'French Polynesia','PYF','258','PF','689','Papeete','XPF','CFP franc','₣','.pf','Polynésie française','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Gambier\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"GAMT\",\"tzName\":\"Gambier Islands Time\"},{\"zoneName\":\"Pacific/Marquesas\",\"gmtOffset\":-34200,\"gmtOffsetName\":\"UTC-09:30\",\"abbreviation\":\"MART\",\"tzName\":\"Marquesas Islands Time\"},{\"zoneName\":\"Pacific/Tahiti\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"TAHT\",\"tzName\":\"Tahiti Time\"}]','{\"kr\":\"프랑스령 폴리네시아\",\"br\":\"Polinésia Francesa\",\"pt\":\"Polinésia Francesa\",\"nl\":\"Frans-Polynesië\",\"hr\":\"Francuska Polinezija\",\"fa\":\"پلی‌نزی فرانسه\",\"de\":\"Französisch-Polynesien\",\"es\":\"Polinesia Francesa\",\"fr\":\"Polynésie française\",\"ja\":\"フランス領ポリネシア\",\"it\":\"Polinesia Francese\",\"cn\":\"法属波利尼西亚\",\"tr\":\"Fransiz Polinezyasi\"}',-15.00000000,-140.00000000,'','U+1F1F5 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(78,'French Southern Territories','ATF','260','TF','262','Port-aux-Francais','EUR','Euro','€','.tf','Territoire des Terres australes et antarctiques fr','Africa','Southern Africa','[{\"zoneName\":\"Indian/Kerguelen\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TFT\",\"tzName\":\"French Southern and Antarctic Time\"}]','{\"kr\":\"프랑스령 남방 및 남극\",\"br\":\"Terras Austrais e Antárticas Francesas\",\"pt\":\"Terras Austrais e Antárticas Francesas\",\"nl\":\"Franse Gebieden in de zuidelijke Indische Oceaan\",\"hr\":\"Francuski južni i antarktički teritoriji\",\"fa\":\"سرزمین‌های جنوبی و جنوبگانی فرانسه\",\"de\":\"Französische Süd- und Antarktisgebiete\",\"es\":\"Tierras Australes y Antárticas Francesas\",\"fr\":\"Terres australes et antarctiques françaises\",\"ja\":\"フランス領南方・南極地域\",\"it\":\"Territori Francesi del Sud\",\"cn\":\"法属南部领地\",\"tr\":\"Fransiz Güney Topraklari\"}',-49.25000000,69.16700000,'','U+1F1F9 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(79,'Gabon','GAB','266','GA','241','Libreville','XAF','Central African CFA franc','FCFA','.ga','Gabon','Africa','Middle Africa','[{\"zoneName\":\"Africa/Libreville\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"가봉\",\"br\":\"Gabão\",\"pt\":\"Gabão\",\"nl\":\"Gabon\",\"hr\":\"Gabon\",\"fa\":\"گابن\",\"de\":\"Gabun\",\"es\":\"Gabón\",\"fr\":\"Gabon\",\"ja\":\"ガボン\",\"it\":\"Gabon\",\"cn\":\"加蓬\",\"tr\":\"Gabon\"}',-1.00000000,11.75000000,'','U+1F1EC U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q1000'),
(80,'Gambia The','GMB','270','GM','220','Banjul','GMD','Gambian dalasi','D','.gm','Gambia','Africa','Western Africa','[{\"zoneName\":\"Africa/Banjul\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"감비아\",\"br\":\"Gâmbia\",\"pt\":\"Gâmbia\",\"nl\":\"Gambia\",\"hr\":\"Gambija\",\"fa\":\"گامبیا\",\"de\":\"Gambia\",\"es\":\"Gambia\",\"fr\":\"Gambie\",\"ja\":\"ガンビア\",\"it\":\"Gambia\",\"cn\":\"冈比亚\",\"tr\":\"Gambiya\"}',13.46666666,-16.56666666,'','U+1F1EC U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q1005'),
(81,'Georgia','GEO','268','GE','995','Tbilisi','GEL','Georgian lari','ლ','.ge','საქართველო','Asia','Western Asia','[{\"zoneName\":\"Asia/Tbilisi\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GET\",\"tzName\":\"Georgia Standard Time\"}]','{\"kr\":\"조지아\",\"br\":\"Geórgia\",\"pt\":\"Geórgia\",\"nl\":\"Georgië\",\"hr\":\"Gruzija\",\"fa\":\"گرجستان\",\"de\":\"Georgien\",\"es\":\"Georgia\",\"fr\":\"Géorgie\",\"ja\":\"グルジア\",\"it\":\"Georgia\",\"cn\":\"格鲁吉亚\",\"tr\":\"Gürcistan\"}',42.00000000,43.50000000,'','U+1F1EC U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q230'),
(82,'Germany','DEU','276','DE','49','Berlin','EUR','Euro','€','.de','Deutschland','Europe','Western Europe','[{\"zoneName\":\"Europe/Berlin\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"},{\"zoneName\":\"Europe/Busingen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"독일\",\"br\":\"Alemanha\",\"pt\":\"Alemanha\",\"nl\":\"Duitsland\",\"hr\":\"Njemačka\",\"fa\":\"آلمان\",\"de\":\"Deutschland\",\"es\":\"Alemania\",\"fr\":\"Allemagne\",\"ja\":\"ドイツ\",\"it\":\"Germania\",\"cn\":\"德国\",\"tr\":\"Almanya\"}',51.00000000,9.00000000,'','U+1F1E9 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q183'),
(83,'Ghana','GHA','288','GH','233','Accra','GHS','Ghanaian cedi','GH₵','.gh','Ghana','Africa','Western Africa','[{\"zoneName\":\"Africa/Accra\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"가나\",\"br\":\"Gana\",\"pt\":\"Gana\",\"nl\":\"Ghana\",\"hr\":\"Gana\",\"fa\":\"غنا\",\"de\":\"Ghana\",\"es\":\"Ghana\",\"fr\":\"Ghana\",\"ja\":\"ガーナ\",\"it\":\"Ghana\",\"cn\":\"加纳\",\"tr\":\"Gana\"}',8.00000000,-2.00000000,'','U+1F1EC U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q117'),
(84,'Gibraltar','GIB','292','GI','350','Gibraltar','GIP','Gibraltar pound','£','.gi','Gibraltar','Europe','Southern Europe','[{\"zoneName\":\"Europe/Gibraltar\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"지브롤터\",\"br\":\"Gibraltar\",\"pt\":\"Gibraltar\",\"nl\":\"Gibraltar\",\"hr\":\"Gibraltar\",\"fa\":\"جبل‌طارق\",\"de\":\"Gibraltar\",\"es\":\"Gibraltar\",\"fr\":\"Gibraltar\",\"ja\":\"ジブラルタル\",\"it\":\"Gibilterra\",\"cn\":\"直布罗陀\",\"tr\":\"Cebelitarik\"}',36.13333333,-5.35000000,'','U+1F1EC U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(85,'Greece','GRC','300','GR','30','Athens','EUR','Euro','€','.gr','Ελλάδα','Europe','Southern Europe','[{\"zoneName\":\"Europe/Athens\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"그리스\",\"br\":\"Grécia\",\"pt\":\"Grécia\",\"nl\":\"Griekenland\",\"hr\":\"Grčka\",\"fa\":\"یونان\",\"de\":\"Griechenland\",\"es\":\"Grecia\",\"fr\":\"Grèce\",\"ja\":\"ギリシャ\",\"it\":\"Grecia\",\"cn\":\"希腊\",\"tr\":\"Yunanistan\"}',39.00000000,22.00000000,'','U+1F1EC U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q41'),
(86,'Greenland','GRL','304','GL','299','Nuuk','DKK','Danish krone','Kr.','.gl','Kalaallit Nunaat','Americas','Northern America','[{\"zoneName\":\"America/Danmarkshavn\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"},{\"zoneName\":\"America/Nuuk\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"WGT\",\"tzName\":\"West Greenland Time\"},{\"zoneName\":\"America/Scoresbysund\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"EGT\",\"tzName\":\"Eastern Greenland Time\"},{\"zoneName\":\"America/Thule\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"그린란드\",\"br\":\"Groelândia\",\"pt\":\"Gronelândia\",\"nl\":\"Groenland\",\"hr\":\"Grenland\",\"fa\":\"گرینلند\",\"de\":\"Grönland\",\"es\":\"Groenlandia\",\"fr\":\"Groenland\",\"ja\":\"グリーンランド\",\"it\":\"Groenlandia\",\"cn\":\"格陵兰岛\",\"tr\":\"Grönland\"}',72.00000000,-40.00000000,'','U+1F1EC U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(87,'Grenada','GRD','308','GD','+1-473','St. George\'s','XCD','Eastern Caribbean dollar','$','.gd','Grenada','Americas','Caribbean','[{\"zoneName\":\"America/Grenada\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"그레나다\",\"br\":\"Granada\",\"pt\":\"Granada\",\"nl\":\"Grenada\",\"hr\":\"Grenada\",\"fa\":\"گرنادا\",\"de\":\"Grenada\",\"es\":\"Grenada\",\"fr\":\"Grenade\",\"ja\":\"グレナダ\",\"it\":\"Grenada\",\"cn\":\"格林纳达\",\"tr\":\"Grenada\"}',12.11666666,-61.66666666,'','U+1F1EC U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q769'),
(88,'Guadeloupe','GLP','312','GP','590','Basse-Terre','EUR','Euro','€','.gp','Guadeloupe','Americas','Caribbean','[{\"zoneName\":\"America/Guadeloupe\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"과들루프\",\"br\":\"Guadalupe\",\"pt\":\"Guadalupe\",\"nl\":\"Guadeloupe\",\"hr\":\"Gvadalupa\",\"fa\":\"جزیره گوادلوپ\",\"de\":\"Guadeloupe\",\"es\":\"Guadalupe\",\"fr\":\"Guadeloupe\",\"ja\":\"グアドループ\",\"it\":\"Guadeloupa\",\"cn\":\"瓜德罗普岛\",\"tr\":\"Guadeloupe\"}',16.25000000,-61.58333300,'','U+1F1EC U+1F1F5','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(89,'Guam','GUM','316','GU','+1-671','Hagatna','USD','US Dollar','$','.gu','Guam','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Guam\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"CHST\",\"tzName\":\"Chamorro Standard Time\"}]','{\"kr\":\"괌\",\"br\":\"Guam\",\"pt\":\"Guame\",\"nl\":\"Guam\",\"hr\":\"Guam\",\"fa\":\"گوام\",\"de\":\"Guam\",\"es\":\"Guam\",\"fr\":\"Guam\",\"ja\":\"グアム\",\"it\":\"Guam\",\"cn\":\"关岛\",\"tr\":\"Guam\"}',13.46666666,144.78333333,'','U+1F1EC U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:20:25',1,NULL),
(90,'Guatemala','GTM','320','GT','502','Guatemala City','GTQ','Guatemalan quetzal','Q','.gt','Guatemala','Americas','Central America','[{\"zoneName\":\"America/Guatemala\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]','{\"kr\":\"과테말라\",\"br\":\"Guatemala\",\"pt\":\"Guatemala\",\"nl\":\"Guatemala\",\"hr\":\"Gvatemala\",\"fa\":\"گواتمالا\",\"de\":\"Guatemala\",\"es\":\"Guatemala\",\"fr\":\"Guatemala\",\"ja\":\"グアテマラ\",\"it\":\"Guatemala\",\"cn\":\"危地马拉\",\"tr\":\"Guatemala\"}',15.50000000,-90.25000000,'','U+1F1EC U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:20:25',1,'Q774'),
(91,'Guernsey and Alderney','GGY','831','GG','+44-1481','St Peter Port','GBP','British pound','£','.gg','Guernsey','Europe','Northern Europe','[{\"zoneName\":\"Europe/Guernsey\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"건지, 올더니\",\"br\":\"Guernsey\",\"pt\":\"Guernsey\",\"nl\":\"Guernsey\",\"hr\":\"Guernsey\",\"fa\":\"گرنزی\",\"de\":\"Guernsey\",\"es\":\"Guernsey\",\"fr\":\"Guernesey\",\"ja\":\"ガーンジー\",\"it\":\"Guernsey\",\"cn\":\"根西岛\",\"tr\":\"Alderney\"}',49.46666666,-2.58333333,'','U+1F1EC U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(92,'Guinea','GIN','324','GN','224','Conakry','GNF','Guinean franc','FG','.gn','Guinée','Africa','Western Africa','[{\"zoneName\":\"Africa/Conakry\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"기니\",\"br\":\"Guiné\",\"pt\":\"Guiné\",\"nl\":\"Guinee\",\"hr\":\"Gvineja\",\"fa\":\"گینه\",\"de\":\"Guinea\",\"es\":\"Guinea\",\"fr\":\"Guinée\",\"ja\":\"ギニア\",\"it\":\"Guinea\",\"cn\":\"几内亚\",\"tr\":\"Gine\"}',11.00000000,-10.00000000,'','U+1F1EC U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1006'),
(93,'Guinea-Bissau','GNB','624','GW','245','Bissau','XOF','West African CFA franc','CFA','.gw','Guiné-Bissau','Africa','Western Africa','[{\"zoneName\":\"Africa/Bissau\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"기니비사우\",\"br\":\"Guiné-Bissau\",\"pt\":\"Guiné-Bissau\",\"nl\":\"Guinee-Bissau\",\"hr\":\"Gvineja Bisau\",\"fa\":\"گینه بیسائو\",\"de\":\"Guinea-Bissau\",\"es\":\"Guinea-Bisáu\",\"fr\":\"Guinée-Bissau\",\"ja\":\"ギニアビサウ\",\"it\":\"Guinea-Bissau\",\"cn\":\"几内亚比绍\",\"tr\":\"Gine-bissau\"}',12.00000000,-15.00000000,'','U+1F1EC U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1007'),
(94,'Guyana','GUY','328','GY','592','Georgetown','GYD','Guyanese dollar','$','.gy','Guyana','Americas','South America','[{\"zoneName\":\"America/Guyana\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"GYT\",\"tzName\":\"Guyana Time\"}]','{\"kr\":\"가이아나\",\"br\":\"Guiana\",\"pt\":\"Guiana\",\"nl\":\"Guyana\",\"hr\":\"Gvajana\",\"fa\":\"گویان\",\"de\":\"Guyana\",\"es\":\"Guyana\",\"fr\":\"Guyane\",\"ja\":\"ガイアナ\",\"it\":\"Guyana\",\"cn\":\"圭亚那\",\"tr\":\"Guyana\"}',5.00000000,-59.00000000,'','U+1F1EC U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q734'),
(95,'Haiti','HTI','332','HT','509','Port-au-Prince','HTG','Haitian gourde','G','.ht','Haïti','Americas','Caribbean','[{\"zoneName\":\"America/Port-au-Prince\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]','{\"kr\":\"아이티\",\"br\":\"Haiti\",\"pt\":\"Haiti\",\"nl\":\"Haïti\",\"hr\":\"Haiti\",\"fa\":\"هائیتی\",\"de\":\"Haiti\",\"es\":\"Haiti\",\"fr\":\"Haïti\",\"ja\":\"ハイチ\",\"it\":\"Haiti\",\"cn\":\"海地\",\"tr\":\"Haiti\"}',19.00000000,-72.41666666,'','U+1F1ED U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q790'),
(96,'Heard Island and McDonald Islands','HMD','334','HM','672','','AUD','Australian dollar','$','.hm','Heard Island and McDonald Islands','','','[{\"zoneName\":\"Indian/Kerguelen\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TFT\",\"tzName\":\"French Southern and Antarctic Time\"}]','{\"kr\":\"허드 맥도날드 제도\",\"br\":\"Ilha Heard e Ilhas McDonald\",\"pt\":\"Ilha Heard e Ilhas McDonald\",\"nl\":\"Heard- en McDonaldeilanden\",\"hr\":\"Otok Heard i otočje McDonald\",\"fa\":\"جزیره هرد و جزایر مک‌دونالد\",\"de\":\"Heard und die McDonaldinseln\",\"es\":\"Islas Heard y McDonald\",\"fr\":\"Îles Heard-et-MacDonald\",\"ja\":\"ハード島とマクドナルド諸島\",\"it\":\"Isole Heard e McDonald\",\"cn\":\"赫德·唐纳岛及麦唐纳岛\",\"tr\":\"Heard Adasi Ve Mcdonald Adalari\"}',-53.10000000,72.51666666,'','U+1F1ED U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(97,'Honduras','HND','340','HN','504','Tegucigalpa','HNL','Honduran lempira','L','.hn','Honduras','Americas','Central America','[{\"zoneName\":\"America/Tegucigalpa\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]','{\"kr\":\"온두라스\",\"br\":\"Honduras\",\"pt\":\"Honduras\",\"nl\":\"Honduras\",\"hr\":\"Honduras\",\"fa\":\"هندوراس\",\"de\":\"Honduras\",\"es\":\"Honduras\",\"fr\":\"Honduras\",\"ja\":\"ホンジュラス\",\"it\":\"Honduras\",\"cn\":\"洪都拉斯\",\"tr\":\"Honduras\"}',15.00000000,-86.50000000,'','U+1F1ED U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q783'),
(98,'Hong Kong S.A.R.','HKG','344','HK','852','Hong Kong','HKD','Hong Kong dollar','$','.hk','香港','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Hong_Kong\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"HKT\",\"tzName\":\"Hong Kong Time\"}]','{\"kr\":\"홍콩\",\"br\":\"Hong Kong\",\"pt\":\"Hong Kong\",\"nl\":\"Hongkong\",\"hr\":\"Hong Kong\",\"fa\":\"هنگ‌کنگ\",\"de\":\"Hong Kong\",\"es\":\"Hong Kong\",\"fr\":\"Hong Kong\",\"ja\":\"香港\",\"it\":\"Hong Kong\",\"cn\":\"中国香港\",\"tr\":\"Hong Kong\"}',22.25000000,114.16666666,'','U+1F1ED U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q8646'),
(99,'Hungary','HUN','348','HU','36','Budapest','HUF','Hungarian forint','Ft','.hu','Magyarország','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Budapest\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"헝가리\",\"br\":\"Hungria\",\"pt\":\"Hungria\",\"nl\":\"Hongarije\",\"hr\":\"Mađarska\",\"fa\":\"مجارستان\",\"de\":\"Ungarn\",\"es\":\"Hungría\",\"fr\":\"Hongrie\",\"ja\":\"ハンガリー\",\"it\":\"Ungheria\",\"cn\":\"匈牙利\",\"tr\":\"Macaristan\"}',47.00000000,20.00000000,'','U+1F1ED U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q28'),
(100,'Iceland','ISL','352','IS','354','Reykjavik','ISK','Icelandic króna','kr','.is','Ísland','Europe','Northern Europe','[{\"zoneName\":\"Atlantic/Reykjavik\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"아이슬란드\",\"br\":\"Islândia\",\"pt\":\"Islândia\",\"nl\":\"IJsland\",\"hr\":\"Island\",\"fa\":\"ایسلند\",\"de\":\"Island\",\"es\":\"Islandia\",\"fr\":\"Islande\",\"ja\":\"アイスランド\",\"it\":\"Islanda\",\"cn\":\"冰岛\",\"tr\":\"İzlanda\"}',65.00000000,-18.00000000,'','U+1F1EE U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q189'),
(101,'India','IND','356','IN','91','New Delhi','INR','Indian rupee','₹','.in','भारत','Asia','Southern Asia','[{\"zoneName\":\"Asia/Kolkata\",\"gmtOffset\":19800,\"gmtOffsetName\":\"UTC+05:30\",\"abbreviation\":\"IST\",\"tzName\":\"Indian Standard Time\"}]','{\"kr\":\"인도\",\"br\":\"Índia\",\"pt\":\"Índia\",\"nl\":\"India\",\"hr\":\"Indija\",\"fa\":\"هند\",\"de\":\"Indien\",\"es\":\"India\",\"fr\":\"Inde\",\"ja\":\"インド\",\"it\":\"India\",\"cn\":\"印度\",\"tr\":\"Hindistan\"}',20.00000000,77.00000000,'','U+1F1EE U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q668'),
(102,'Indonesia','IDN','360','ID','62','Jakarta','IDR','Indonesian rupiah','Rp','.id','Indonesia','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Jakarta\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"WIB\",\"tzName\":\"Western Indonesian Time\"},{\"zoneName\":\"Asia/Jayapura\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"WIT\",\"tzName\":\"Eastern Indonesian Time\"},{\"zoneName\":\"Asia/Makassar\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"WITA\",\"tzName\":\"Central Indonesia Time\"},{\"zoneName\":\"Asia/Pontianak\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"WIB\",\"tzName\":\"Western Indonesian Time\"}]','{\"kr\":\"인도네시아\",\"br\":\"Indonésia\",\"pt\":\"Indonésia\",\"nl\":\"Indonesië\",\"hr\":\"Indonezija\",\"fa\":\"اندونزی\",\"de\":\"Indonesien\",\"es\":\"Indonesia\",\"fr\":\"Indonésie\",\"ja\":\"インドネシア\",\"it\":\"Indonesia\",\"cn\":\"印度尼西亚\",\"tr\":\"Endonezya\"}',-5.00000000,120.00000000,'','U+1F1EE U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q252'),
(103,'Iran','IRN','364','IR','98','Tehran','IRR','Iranian rial','﷼','.ir','ایران','Asia','Southern Asia','[{\"zoneName\":\"Asia/Tehran\",\"gmtOffset\":12600,\"gmtOffsetName\":\"UTC+03:30\",\"abbreviation\":\"IRDT\",\"tzName\":\"Iran Daylight Time\"}]','{\"kr\":\"이란\",\"br\":\"Irã\",\"pt\":\"Irão\",\"nl\":\"Iran\",\"hr\":\"Iran\",\"fa\":\"ایران\",\"de\":\"Iran\",\"es\":\"Iran\",\"fr\":\"Iran\",\"ja\":\"イラン・イスラム共和国\",\"cn\":\"伊朗\",\"tr\":\"İran\"}',32.00000000,53.00000000,'','U+1F1EE U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q794'),
(104,'Iraq','IRQ','368','IQ','964','Baghdad','IQD','Iraqi dinar','د.ع','.iq','العراق','Asia','Western Asia','[{\"zoneName\":\"Asia/Baghdad\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"이라크\",\"br\":\"Iraque\",\"pt\":\"Iraque\",\"nl\":\"Irak\",\"hr\":\"Irak\",\"fa\":\"عراق\",\"de\":\"Irak\",\"es\":\"Irak\",\"fr\":\"Irak\",\"ja\":\"イラク\",\"it\":\"Iraq\",\"cn\":\"伊拉克\",\"tr\":\"Irak\"}',33.00000000,44.00000000,'','U+1F1EE U+1F1F6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q796'),
(105,'Ireland','IRL','372','IE','353','Dublin','EUR','Euro','€','.ie','Éire','Europe','Northern Europe','[{\"zoneName\":\"Europe/Dublin\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"아일랜드\",\"br\":\"Irlanda\",\"pt\":\"Irlanda\",\"nl\":\"Ierland\",\"hr\":\"Irska\",\"fa\":\"ایرلند\",\"de\":\"Irland\",\"es\":\"Irlanda\",\"fr\":\"Irlande\",\"ja\":\"アイルランド\",\"it\":\"Irlanda\",\"cn\":\"爱尔兰\",\"tr\":\"İrlanda\"}',53.00000000,-8.00000000,'','U+1F1EE U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q27'),
(106,'Israel','ISR','376','IL','972','Jerusalem','ILS','Israeli new shekel','₪','.il','יִשְׂרָאֵל','Asia','Western Asia','[{\"zoneName\":\"Asia/Jerusalem\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"IST\",\"tzName\":\"Israel Standard Time\"}]','{\"kr\":\"이스라엘\",\"br\":\"Israel\",\"pt\":\"Israel\",\"nl\":\"Israël\",\"hr\":\"Izrael\",\"fa\":\"اسرائیل\",\"de\":\"Israel\",\"es\":\"Israel\",\"fr\":\"Israël\",\"ja\":\"イスラエル\",\"it\":\"Israele\",\"cn\":\"以色列\",\"tr\":\"İsrail\"}',31.50000000,34.75000000,'','U+1F1EE U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q801'),
(107,'Italy','ITA','380','IT','39','Rome','EUR','Euro','€','.it','Italia','Europe','Southern Europe','[{\"zoneName\":\"Europe/Rome\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"이탈리아\",\"br\":\"Itália\",\"pt\":\"Itália\",\"nl\":\"Italië\",\"hr\":\"Italija\",\"fa\":\"ایتالیا\",\"de\":\"Italien\",\"es\":\"Italia\",\"fr\":\"Italie\",\"ja\":\"イタリア\",\"it\":\"Italia\",\"cn\":\"意大利\",\"tr\":\"İtalya\"}',42.83333333,12.83333333,'','U+1F1EE U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q38'),
(108,'Jamaica','JAM','388','JM','+1-876','Kingston','JMD','Jamaican dollar','J$','.jm','Jamaica','Americas','Caribbean','[{\"zoneName\":\"America/Jamaica\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]','{\"kr\":\"자메이카\",\"br\":\"Jamaica\",\"pt\":\"Jamaica\",\"nl\":\"Jamaica\",\"hr\":\"Jamajka\",\"fa\":\"جامائیکا\",\"de\":\"Jamaika\",\"es\":\"Jamaica\",\"fr\":\"Jamaïque\",\"ja\":\"ジャマイカ\",\"it\":\"Giamaica\",\"cn\":\"牙买加\",\"tr\":\"Jamaika\"}',18.25000000,-77.50000000,'','U+1F1EF U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q766'),
(109,'Japan','JPN','392','JP','81','Tokyo','JPY','Japanese yen','¥','.jp','日本','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Tokyo\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"JST\",\"tzName\":\"Japan Standard Time\"}]','{\"kr\":\"일본\",\"br\":\"Japão\",\"pt\":\"Japão\",\"nl\":\"Japan\",\"hr\":\"Japan\",\"fa\":\"ژاپن\",\"de\":\"Japan\",\"es\":\"Japón\",\"fr\":\"Japon\",\"ja\":\"日本\",\"it\":\"Giappone\",\"cn\":\"日本\",\"tr\":\"Japonya\"}',36.00000000,138.00000000,'','U+1F1EF U+1F1F5','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q17'),
(110,'Jersey','JEY','832','JE','+44-1534','Saint Helier','GBP','British pound','£','.je','Jersey','Europe','Northern Europe','[{\"zoneName\":\"Europe/Jersey\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"저지 섬\",\"br\":\"Jersey\",\"pt\":\"Jersey\",\"nl\":\"Jersey\",\"hr\":\"Jersey\",\"fa\":\"جرزی\",\"de\":\"Jersey\",\"es\":\"Jersey\",\"fr\":\"Jersey\",\"ja\":\"ジャージー\",\"it\":\"Isola di Jersey\",\"cn\":\"泽西岛\",\"tr\":\"Jersey\"}',49.25000000,-2.16666666,'','U+1F1EF U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q785'),
(111,'Jordan','JOR','400','JO','962','Amman','JOD','Jordanian dinar','ا.د','.jo','الأردن','Asia','Western Asia','[{\"zoneName\":\"Asia/Amman\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"요르단\",\"br\":\"Jordânia\",\"pt\":\"Jordânia\",\"nl\":\"Jordanië\",\"hr\":\"Jordan\",\"fa\":\"اردن\",\"de\":\"Jordanien\",\"es\":\"Jordania\",\"fr\":\"Jordanie\",\"ja\":\"ヨルダン\",\"it\":\"Giordania\",\"cn\":\"约旦\",\"tr\":\"Ürdün\"}',31.00000000,36.00000000,'','U+1F1EF U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q810'),
(112,'Kazakhstan','KAZ','398','KZ','7','Astana','KZT','Kazakhstani tenge','лв','.kz','Қазақстан','Asia','Central Asia','[{\"zoneName\":\"Asia/Almaty\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"ALMT\",\"tzName\":\"Alma-Ata Time[1\"},{\"zoneName\":\"Asia/Aqtau\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"AQTT\",\"tzName\":\"Aqtobe Time\"},{\"zoneName\":\"Asia/Aqtobe\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"AQTT\",\"tzName\":\"Aqtobe Time\"},{\"zoneName\":\"Asia/Atyrau\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MSD+1\",\"tzName\":\"Moscow Daylight Time+1\"},{\"zoneName\":\"Asia/Oral\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"ORAT\",\"tzName\":\"Oral Time\"},{\"zoneName\":\"Asia/Qostanay\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"QYZST\",\"tzName\":\"Qyzylorda Summer Time\"},{\"zoneName\":\"Asia/Qyzylorda\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"QYZT\",\"tzName\":\"Qyzylorda Summer Time\"}]','{\"kr\":\"카자흐스탄\",\"br\":\"Cazaquistão\",\"pt\":\"Cazaquistão\",\"nl\":\"Kazachstan\",\"hr\":\"Kazahstan\",\"fa\":\"قزاقستان\",\"de\":\"Kasachstan\",\"es\":\"Kazajistán\",\"fr\":\"Kazakhstan\",\"ja\":\"カザフスタン\",\"it\":\"Kazakistan\",\"cn\":\"哈萨克斯坦\",\"tr\":\"Kazakistan\"}',48.00000000,68.00000000,'','U+1F1F0 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q232'),
(113,'Kenya','KEN','404','KE','254','Nairobi','KES','Kenyan shilling','KSh','.ke','Kenya','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Nairobi\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"케냐\",\"br\":\"Quênia\",\"pt\":\"Quénia\",\"nl\":\"Kenia\",\"hr\":\"Kenija\",\"fa\":\"کنیا\",\"de\":\"Kenia\",\"es\":\"Kenia\",\"fr\":\"Kenya\",\"ja\":\"ケニア\",\"it\":\"Kenya\",\"cn\":\"肯尼亚\",\"tr\":\"Kenya\"}',1.00000000,38.00000000,'','U+1F1F0 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q114'),
(114,'Kiribati','KIR','296','KI','686','Tarawa','AUD','Australian dollar','$','.ki','Kiribati','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Enderbury\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"PHOT\",\"tzName\":\"Phoenix Island Time\"},{\"zoneName\":\"Pacific/Kiritimati\",\"gmtOffset\":50400,\"gmtOffsetName\":\"UTC+14:00\",\"abbreviation\":\"LINT\",\"tzName\":\"Line Islands Time\"},{\"zoneName\":\"Pacific/Tarawa\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"GILT\",\"tzName\":\"Gilbert Island Time\"}]','{\"kr\":\"키리바시\",\"br\":\"Kiribati\",\"pt\":\"Quiribáti\",\"nl\":\"Kiribati\",\"hr\":\"Kiribati\",\"fa\":\"کیریباتی\",\"de\":\"Kiribati\",\"es\":\"Kiribati\",\"fr\":\"Kiribati\",\"ja\":\"キリバス\",\"it\":\"Kiribati\",\"cn\":\"基里巴斯\",\"tr\":\"Kiribati\"}',1.41666666,173.00000000,'','U+1F1F0 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q710'),
(115,'North Korea','PRK','408','KP','850','Pyongyang','KPW','North Korean Won','₩','.kp','북한','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Pyongyang\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"KST\",\"tzName\":\"Korea Standard Time\"}]','{\"kr\":\"조선민주주의인민공화국\",\"br\":\"Coreia do Norte\",\"pt\":\"Coreia do Norte\",\"nl\":\"Noord-Korea\",\"hr\":\"Sjeverna Koreja\",\"fa\":\"کره جنوبی\",\"de\":\"Nordkorea\",\"es\":\"Corea del Norte\",\"fr\":\"Corée du Nord\",\"ja\":\"朝鮮民主主義人民共和国\",\"it\":\"Corea del Nord\",\"cn\":\"朝鲜\",\"tr\":\"Kuzey Kore\"}',40.00000000,127.00000000,'','U+1F1F0 U+1F1F5','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q423'),
(116,'South Korea','KOR','410','KR','82','Seoul','KRW','Won','₩','.kr','대한민국','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Seoul\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"KST\",\"tzName\":\"Korea Standard Time\"}]','{\"kr\":\"대한민국\",\"br\":\"Coreia do Sul\",\"pt\":\"Coreia do Sul\",\"nl\":\"Zuid-Korea\",\"hr\":\"Južna Koreja\",\"fa\":\"کره شمالی\",\"de\":\"Südkorea\",\"es\":\"Corea del Sur\",\"fr\":\"Corée du Sud\",\"ja\":\"大韓民国\",\"it\":\"Corea del Sud\",\"cn\":\"韩国\",\"tr\":\"Güney Kore\"}',37.00000000,127.50000000,'','U+1F1F0 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q884'),
(117,'Kuwait','KWT','414','KW','965','Kuwait City','KWD','Kuwaiti dinar','ك.د','.kw','الكويت','Asia','Western Asia','[{\"zoneName\":\"Asia/Kuwait\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"쿠웨이트\",\"br\":\"Kuwait\",\"pt\":\"Kuwait\",\"nl\":\"Koeweit\",\"hr\":\"Kuvajt\",\"fa\":\"کویت\",\"de\":\"Kuwait\",\"es\":\"Kuwait\",\"fr\":\"Koweït\",\"ja\":\"クウェート\",\"it\":\"Kuwait\",\"cn\":\"科威特\",\"tr\":\"Kuveyt\"}',29.50000000,45.75000000,'','U+1F1F0 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q817'),
(118,'Kyrgyzstan','KGZ','417','KG','996','Bishkek','KGS','Kyrgyzstani som','лв','.kg','Кыргызстан','Asia','Central Asia','[{\"zoneName\":\"Asia/Bishkek\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"KGT\",\"tzName\":\"Kyrgyzstan Time\"}]','{\"kr\":\"키르기스스탄\",\"br\":\"Quirguistão\",\"pt\":\"Quirguizistão\",\"nl\":\"Kirgizië\",\"hr\":\"Kirgistan\",\"fa\":\"قرقیزستان\",\"de\":\"Kirgisistan\",\"es\":\"Kirguizistán\",\"fr\":\"Kirghizistan\",\"ja\":\"キルギス\",\"it\":\"Kirghizistan\",\"cn\":\"吉尔吉斯斯坦\",\"tr\":\"Kirgizistan\"}',41.00000000,75.00000000,'','U+1F1F0 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q813'),
(119,'Laos','LAO','418','LA','856','Vientiane','LAK','Lao kip','₭','.la','ສປປລາວ','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Vientiane\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]','{\"kr\":\"라오스\",\"br\":\"Laos\",\"pt\":\"Laos\",\"nl\":\"Laos\",\"hr\":\"Laos\",\"fa\":\"لائوس\",\"de\":\"Laos\",\"es\":\"Laos\",\"fr\":\"Laos\",\"ja\":\"ラオス人民民主共和国\",\"it\":\"Laos\",\"cn\":\"寮人民民主共和国\",\"tr\":\"Laos\"}',18.00000000,105.00000000,'','U+1F1F1 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q819'),
(120,'Latvia','LVA','428','LV','371','Riga','EUR','Euro','€','.lv','Latvija','Europe','Northern Europe','[{\"zoneName\":\"Europe/Riga\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"라트비아\",\"br\":\"Letônia\",\"pt\":\"Letónia\",\"nl\":\"Letland\",\"hr\":\"Latvija\",\"fa\":\"لتونی\",\"de\":\"Lettland\",\"es\":\"Letonia\",\"fr\":\"Lettonie\",\"ja\":\"ラトビア\",\"it\":\"Lettonia\",\"cn\":\"拉脱维亚\",\"tr\":\"Letonya\"}',57.00000000,25.00000000,'','U+1F1F1 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q211'),
(121,'Lebanon','LBN','422','LB','961','Beirut','LBP','Lebanese pound','£','.lb','لبنان','Asia','Western Asia','[{\"zoneName\":\"Asia/Beirut\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"레바논\",\"br\":\"Líbano\",\"pt\":\"Líbano\",\"nl\":\"Libanon\",\"hr\":\"Libanon\",\"fa\":\"لبنان\",\"de\":\"Libanon\",\"es\":\"Líbano\",\"fr\":\"Liban\",\"ja\":\"レバノン\",\"it\":\"Libano\",\"cn\":\"黎巴嫩\",\"tr\":\"Lübnan\"}',33.83333333,35.83333333,'','U+1F1F1 U+1F1E7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q822'),
(122,'Lesotho','LSO','426','LS','266','Maseru','LSL','Lesotho loti','L','.ls','Lesotho','Africa','Southern Africa','[{\"zoneName\":\"Africa/Maseru\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]','{\"kr\":\"레소토\",\"br\":\"Lesoto\",\"pt\":\"Lesoto\",\"nl\":\"Lesotho\",\"hr\":\"Lesoto\",\"fa\":\"لسوتو\",\"de\":\"Lesotho\",\"es\":\"Lesotho\",\"fr\":\"Lesotho\",\"ja\":\"レソト\",\"it\":\"Lesotho\",\"cn\":\"莱索托\",\"tr\":\"Lesotho\"}',-29.50000000,28.50000000,'','U+1F1F1 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1013'),
(123,'Liberia','LBR','430','LR','231','Monrovia','LRD','Liberian dollar','$','.lr','Liberia','Africa','Western Africa','[{\"zoneName\":\"Africa/Monrovia\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"라이베리아\",\"br\":\"Libéria\",\"pt\":\"Libéria\",\"nl\":\"Liberia\",\"hr\":\"Liberija\",\"fa\":\"لیبریا\",\"de\":\"Liberia\",\"es\":\"Liberia\",\"fr\":\"Liberia\",\"ja\":\"リベリア\",\"it\":\"Liberia\",\"cn\":\"利比里亚\",\"tr\":\"Liberya\"}',6.50000000,-9.50000000,'','U+1F1F1 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1014'),
(124,'Libya','LBY','434','LY','218','Tripolis','LYD','Libyan dinar','د.ل','.ly','‏ليبيا','Africa','Northern Africa','[{\"zoneName\":\"Africa/Tripoli\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"리비아\",\"br\":\"Líbia\",\"pt\":\"Líbia\",\"nl\":\"Libië\",\"hr\":\"Libija\",\"fa\":\"لیبی\",\"de\":\"Libyen\",\"es\":\"Libia\",\"fr\":\"Libye\",\"ja\":\"リビア\",\"it\":\"Libia\",\"cn\":\"利比亚\",\"tr\":\"Libya\"}',25.00000000,17.00000000,'','U+1F1F1 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1016'),
(125,'Liechtenstein','LIE','438','LI','423','Vaduz','CHF','Swiss franc','CHf','.li','Liechtenstein','Europe','Western Europe','[{\"zoneName\":\"Europe/Vaduz\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"리히텐슈타인\",\"br\":\"Liechtenstein\",\"pt\":\"Listenstaine\",\"nl\":\"Liechtenstein\",\"hr\":\"Lihtenštajn\",\"fa\":\"لیختن‌اشتاین\",\"de\":\"Liechtenstein\",\"es\":\"Liechtenstein\",\"fr\":\"Liechtenstein\",\"ja\":\"リヒテンシュタイン\",\"it\":\"Liechtenstein\",\"cn\":\"列支敦士登\",\"tr\":\"Lihtenştayn\"}',47.26666666,9.53333333,'','U+1F1F1 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q347'),
(126,'Lithuania','LTU','440','LT','370','Vilnius','EUR','Euro','€','.lt','Lietuva','Europe','Northern Europe','[{\"zoneName\":\"Europe/Vilnius\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"리투아니아\",\"br\":\"Lituânia\",\"pt\":\"Lituânia\",\"nl\":\"Litouwen\",\"hr\":\"Litva\",\"fa\":\"لیتوانی\",\"de\":\"Litauen\",\"es\":\"Lituania\",\"fr\":\"Lituanie\",\"ja\":\"リトアニア\",\"it\":\"Lituania\",\"cn\":\"立陶宛\",\"tr\":\"Litvanya\"}',56.00000000,24.00000000,'','U+1F1F1 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q37'),
(127,'Luxembourg','LUX','442','LU','352','Luxembourg','EUR','Euro','€','.lu','Luxembourg','Europe','Western Europe','[{\"zoneName\":\"Europe/Luxembourg\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"룩셈부르크\",\"br\":\"Luxemburgo\",\"pt\":\"Luxemburgo\",\"nl\":\"Luxemburg\",\"hr\":\"Luksemburg\",\"fa\":\"لوکزامبورگ\",\"de\":\"Luxemburg\",\"es\":\"Luxemburgo\",\"fr\":\"Luxembourg\",\"ja\":\"ルクセンブルク\",\"it\":\"Lussemburgo\",\"cn\":\"卢森堡\",\"tr\":\"Lüksemburg\"}',49.75000000,6.16666666,'','U+1F1F1 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q32'),
(128,'Macau S.A.R.','MAC','446','MO','853','Macao','MOP','Macanese pataca','$','.mo','澳門','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Macau\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"}]','{\"kr\":\"마카오\",\"br\":\"Macau\",\"pt\":\"Macau\",\"nl\":\"Macao\",\"hr\":\"Makao\",\"fa\":\"مکائو\",\"de\":\"Macao\",\"es\":\"Macao\",\"fr\":\"Macao\",\"ja\":\"マカオ\",\"it\":\"Macao\",\"cn\":\"中国澳门\",\"tr\":\"Makao\"}',22.16666666,113.55000000,'','U+1F1F2 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(129,'Macedonia','MKD','807','MK','389','Skopje','MKD','Denar','ден','.mk','Северна Македонија','Europe','Southern Europe','[{\"zoneName\":\"Europe/Skopje\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"마케도니아\",\"br\":\"Macedônia\",\"pt\":\"Macedónia\",\"nl\":\"Macedonië\",\"hr\":\"Makedonija\",\"fa\":\"\",\"de\":\"Mazedonien\",\"es\":\"Macedonia\",\"fr\":\"Macédoine\",\"ja\":\"マケドニア旧ユーゴスラビア共和国\",\"it\":\"Macedonia\",\"cn\":\"马其顿\",\"tr\":\"Kuzey Makedonya\"}',41.83333333,22.00000000,'','U+1F1F2 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q221'),
(130,'Madagascar','MDG','450','MG','261','Antananarivo','MGA','Malagasy ariary','Ar','.mg','Madagasikara','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Antananarivo\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"마다가스카르\",\"br\":\"Madagascar\",\"pt\":\"Madagáscar\",\"nl\":\"Madagaskar\",\"hr\":\"Madagaskar\",\"fa\":\"ماداگاسکار\",\"de\":\"Madagaskar\",\"es\":\"Madagascar\",\"fr\":\"Madagascar\",\"ja\":\"マダガスカル\",\"it\":\"Madagascar\",\"cn\":\"马达加斯加\",\"tr\":\"Madagaskar\"}',-20.00000000,47.00000000,'','U+1F1F2 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1019'),
(131,'Malawi','MWI','454','MW','265','Lilongwe','MWK','Malawian kwacha','MK','.mw','Malawi','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Blantyre\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"말라위\",\"br\":\"Malawi\",\"pt\":\"Malávi\",\"nl\":\"Malawi\",\"hr\":\"Malavi\",\"fa\":\"مالاوی\",\"de\":\"Malawi\",\"es\":\"Malawi\",\"fr\":\"Malawi\",\"ja\":\"マラウイ\",\"it\":\"Malawi\",\"cn\":\"马拉维\",\"tr\":\"Malavi\"}',-13.50000000,34.00000000,'','U+1F1F2 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1020'),
(132,'Malaysia','MYS','458','MY','60','Kuala Lumpur','MYR','Malaysian ringgit','RM','.my','Malaysia','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Kuala_Lumpur\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"MYT\",\"tzName\":\"Malaysia Time\"},{\"zoneName\":\"Asia/Kuching\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"MYT\",\"tzName\":\"Malaysia Time\"}]','{\"kr\":\"말레이시아\",\"br\":\"Malásia\",\"pt\":\"Malásia\",\"nl\":\"Maleisië\",\"hr\":\"Malezija\",\"fa\":\"مالزی\",\"de\":\"Malaysia\",\"es\":\"Malasia\",\"fr\":\"Malaisie\",\"ja\":\"マレーシア\",\"it\":\"Malesia\",\"cn\":\"马来西亚\",\"tr\":\"Malezya\"}',2.50000000,112.50000000,'','U+1F1F2 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q833'),
(133,'Maldives','MDV','462','MV','960','Male','MVR','Maldivian rufiyaa','Rf','.mv','Maldives','Asia','Southern Asia','[{\"zoneName\":\"Indian/Maldives\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"MVT\",\"tzName\":\"Maldives Time\"}]','{\"kr\":\"몰디브\",\"br\":\"Maldivas\",\"pt\":\"Maldivas\",\"nl\":\"Maldiven\",\"hr\":\"Maldivi\",\"fa\":\"مالدیو\",\"de\":\"Malediven\",\"es\":\"Maldivas\",\"fr\":\"Maldives\",\"ja\":\"モルディブ\",\"it\":\"Maldive\",\"cn\":\"马尔代夫\",\"tr\":\"Maldivler\"}',3.25000000,73.00000000,'','U+1F1F2 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q826'),
(134,'Mali','MLI','466','ML','223','Bamako','XOF','West African CFA franc','CFA','.ml','Mali','Africa','Western Africa','[{\"zoneName\":\"Africa/Bamako\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"말리\",\"br\":\"Mali\",\"pt\":\"Mali\",\"nl\":\"Mali\",\"hr\":\"Mali\",\"fa\":\"مالی\",\"de\":\"Mali\",\"es\":\"Mali\",\"fr\":\"Mali\",\"ja\":\"マリ\",\"it\":\"Mali\",\"cn\":\"马里\",\"tr\":\"Mali\"}',17.00000000,-4.00000000,'','U+1F1F2 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q912'),
(135,'Malta','MLT','470','MT','356','Valletta','EUR','Euro','€','.mt','Malta','Europe','Southern Europe','[{\"zoneName\":\"Europe/Malta\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"몰타\",\"br\":\"Malta\",\"pt\":\"Malta\",\"nl\":\"Malta\",\"hr\":\"Malta\",\"fa\":\"مالت\",\"de\":\"Malta\",\"es\":\"Malta\",\"fr\":\"Malte\",\"ja\":\"マルタ\",\"it\":\"Malta\",\"cn\":\"马耳他\",\"tr\":\"Malta\"}',35.83333333,14.58333333,'','U+1F1F2 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q233'),
(136,'Man (Isle of)','IMN','833','IM','+44-1624','Douglas, Isle of Man','GBP','British pound','£','.im','Isle of Man','Europe','Northern Europe','[{\"zoneName\":\"Europe/Isle_of_Man\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"맨 섬\",\"br\":\"Ilha de Man\",\"pt\":\"Ilha de Man\",\"nl\":\"Isle of Man\",\"hr\":\"Otok Man\",\"fa\":\"جزیره من\",\"de\":\"Insel Man\",\"es\":\"Isla de Man\",\"fr\":\"Île de Man\",\"ja\":\"マン島\",\"it\":\"Isola di Man\",\"cn\":\"马恩岛\",\"tr\":\"Man Adasi\"}',54.25000000,-4.50000000,'','U+1F1EE U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(137,'Marshall Islands','MHL','584','MH','692','Majuro','USD','United States dollar','$','.mh','M̧ajeļ','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Kwajalein\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"MHT\",\"tzName\":\"Marshall Islands Time\"},{\"zoneName\":\"Pacific/Majuro\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"MHT\",\"tzName\":\"Marshall Islands Time\"}]','{\"kr\":\"마셜 제도\",\"br\":\"Ilhas Marshall\",\"pt\":\"Ilhas Marshall\",\"nl\":\"Marshalleilanden\",\"hr\":\"Maršalovi Otoci\",\"fa\":\"جزایر مارشال\",\"de\":\"Marshallinseln\",\"es\":\"Islas Marshall\",\"fr\":\"Îles Marshall\",\"ja\":\"マーシャル諸島\",\"it\":\"Isole Marshall\",\"cn\":\"马绍尔群岛\",\"tr\":\"Marşal Adalari\"}',9.00000000,168.00000000,'','U+1F1F2 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q709'),
(138,'Martinique','MTQ','474','MQ','596','Fort-de-France','EUR','Euro','€','.mq','Martinique','Americas','Caribbean','[{\"zoneName\":\"America/Martinique\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"마르티니크\",\"br\":\"Martinica\",\"pt\":\"Martinica\",\"nl\":\"Martinique\",\"hr\":\"Martinique\",\"fa\":\"مونتسرات\",\"de\":\"Martinique\",\"es\":\"Martinica\",\"fr\":\"Martinique\",\"ja\":\"マルティニーク\",\"it\":\"Martinica\",\"cn\":\"马提尼克岛\",\"tr\":\"Martinik\"}',14.66666700,-61.00000000,'','U+1F1F2 U+1F1F6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(139,'Mauritania','MRT','478','MR','222','Nouakchott','MRO','Mauritanian ouguiya','MRU','.mr','موريتانيا','Africa','Western Africa','[{\"zoneName\":\"Africa/Nouakchott\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"모리타니\",\"br\":\"Mauritânia\",\"pt\":\"Mauritânia\",\"nl\":\"Mauritanië\",\"hr\":\"Mauritanija\",\"fa\":\"موریتانی\",\"de\":\"Mauretanien\",\"es\":\"Mauritania\",\"fr\":\"Mauritanie\",\"ja\":\"モーリタニア\",\"it\":\"Mauritania\",\"cn\":\"毛里塔尼亚\",\"tr\":\"Moritanya\"}',20.00000000,-12.00000000,'','U+1F1F2 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1025'),
(140,'Mauritius','MUS','480','MU','230','Port Louis','MUR','Mauritian rupee','₨','.mu','Maurice','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Mauritius\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MUT\",\"tzName\":\"Mauritius Time\"}]','{\"kr\":\"모리셔스\",\"br\":\"Maurício\",\"pt\":\"Maurícia\",\"nl\":\"Mauritius\",\"hr\":\"Mauricijus\",\"fa\":\"موریس\",\"de\":\"Mauritius\",\"es\":\"Mauricio\",\"fr\":\"Île Maurice\",\"ja\":\"モーリシャス\",\"it\":\"Mauritius\",\"cn\":\"毛里求斯\",\"tr\":\"Morityus\"}',-20.28333333,57.55000000,'','U+1F1F2 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1027'),
(141,'Mayotte','MYT','175','YT','262','Mamoudzou','EUR','Euro','€','.yt','Mayotte','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Mayotte\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"마요트\",\"br\":\"Mayotte\",\"pt\":\"Mayotte\",\"nl\":\"Mayotte\",\"hr\":\"Mayotte\",\"fa\":\"مایوت\",\"de\":\"Mayotte\",\"es\":\"Mayotte\",\"fr\":\"Mayotte\",\"ja\":\"マヨット\",\"it\":\"Mayotte\",\"cn\":\"马约特\",\"tr\":\"Mayotte\"}',-12.83333333,45.16666666,'','U+1F1FE U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(142,'Mexico','MEX','484','MX','52','Ciudad de México','MXN','Mexican peso','$','.mx','México','Americas','Central America','[{\"zoneName\":\"America/Bahia_Banderas\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Cancun\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Chihuahua\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Hermosillo\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Matamoros\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Mazatlan\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Merida\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Mexico_City\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Monterrey\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Ojinaga\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Tijuana\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"}]','{\"kr\":\"멕시코\",\"br\":\"México\",\"pt\":\"México\",\"nl\":\"Mexico\",\"hr\":\"Meksiko\",\"fa\":\"مکزیک\",\"de\":\"Mexiko\",\"es\":\"México\",\"fr\":\"Mexique\",\"ja\":\"メキシコ\",\"it\":\"Messico\",\"cn\":\"墨西哥\",\"tr\":\"Meksika\"}',23.00000000,-102.00000000,'','U+1F1F2 U+1F1FD','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q96'),
(143,'Micronesia','FSM','583','FM','691','Palikir','USD','United States dollar','$','.fm','Micronesia','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Chuuk\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"CHUT\",\"tzName\":\"Chuuk Time\"},{\"zoneName\":\"Pacific/Kosrae\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"KOST\",\"tzName\":\"Kosrae Time\"},{\"zoneName\":\"Pacific/Pohnpei\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"PONT\",\"tzName\":\"Pohnpei Standard Time\"}]','{\"kr\":\"미크로네시아 연방\",\"br\":\"Micronésia\",\"pt\":\"Micronésia\",\"nl\":\"Micronesië\",\"hr\":\"Mikronezija\",\"fa\":\"ایالات فدرال میکرونزی\",\"de\":\"Mikronesien\",\"es\":\"Micronesia\",\"fr\":\"Micronésie\",\"ja\":\"ミクロネシア連邦\",\"it\":\"Micronesia\",\"cn\":\"密克罗尼西亚\",\"tr\":\"Mikronezya\"}',6.91666666,158.25000000,'','U+1F1EB U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q702'),
(144,'Moldova','MDA','498','MD','373','Chisinau','MDL','Moldovan leu','L','.md','Moldova','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Chisinau\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"몰도바\",\"br\":\"Moldávia\",\"pt\":\"Moldávia\",\"nl\":\"Moldavië\",\"hr\":\"Moldova\",\"fa\":\"مولداوی\",\"de\":\"Moldawie\",\"es\":\"Moldavia\",\"fr\":\"Moldavie\",\"ja\":\"モルドバ共和国\",\"it\":\"Moldavia\",\"cn\":\"摩尔多瓦\",\"tr\":\"Moldova\"}',47.00000000,29.00000000,'','U+1F1F2 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q217'),
(145,'Monaco','MCO','492','MC','377','Monaco','EUR','Euro','€','.mc','Monaco','Europe','Western Europe','[{\"zoneName\":\"Europe/Monaco\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"모나코\",\"br\":\"Mônaco\",\"pt\":\"Mónaco\",\"nl\":\"Monaco\",\"hr\":\"Monako\",\"fa\":\"موناکو\",\"de\":\"Monaco\",\"es\":\"Mónaco\",\"fr\":\"Monaco\",\"ja\":\"モナコ\",\"it\":\"Principato di Monaco\",\"cn\":\"摩纳哥\",\"tr\":\"Monako\"}',43.73333333,7.40000000,'','U+1F1F2 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q235'),
(146,'Mongolia','MNG','496','MN','976','Ulan Bator','MNT','Mongolian tögrög','₮','.mn','Монгол улс','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Choibalsan\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CHOT\",\"tzName\":\"Choibalsan Standard Time\"},{\"zoneName\":\"Asia/Hovd\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"HOVT\",\"tzName\":\"Hovd Time\"},{\"zoneName\":\"Asia/Ulaanbaatar\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"ULAT\",\"tzName\":\"Ulaanbaatar Standard Time\"}]','{\"kr\":\"몽골\",\"br\":\"Mongólia\",\"pt\":\"Mongólia\",\"nl\":\"Mongolië\",\"hr\":\"Mongolija\",\"fa\":\"مغولستان\",\"de\":\"Mongolei\",\"es\":\"Mongolia\",\"fr\":\"Mongolie\",\"ja\":\"モンゴル\",\"it\":\"Mongolia\",\"cn\":\"蒙古\",\"tr\":\"Moğolistan\"}',46.00000000,105.00000000,'','U+1F1F2 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q711'),
(147,'Montenegro','MNE','499','ME','382','Podgorica','EUR','Euro','€','.me','Црна Гора','Europe','Southern Europe','[{\"zoneName\":\"Europe/Podgorica\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"몬테네그로\",\"br\":\"Montenegro\",\"pt\":\"Montenegro\",\"nl\":\"Montenegro\",\"hr\":\"Crna Gora\",\"fa\":\"مونته‌نگرو\",\"de\":\"Montenegro\",\"es\":\"Montenegro\",\"fr\":\"Monténégro\",\"ja\":\"モンテネグロ\",\"it\":\"Montenegro\",\"cn\":\"黑山\",\"tr\":\"Karadağ\"}',42.50000000,19.30000000,'','U+1F1F2 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q236'),
(148,'Montserrat','MSR','500','MS','+1-664','Plymouth','XCD','Eastern Caribbean dollar','$','.ms','Montserrat','Americas','Caribbean','[{\"zoneName\":\"America/Montserrat\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"몬트세랫\",\"br\":\"Montserrat\",\"pt\":\"Monserrate\",\"nl\":\"Montserrat\",\"hr\":\"Montserrat\",\"fa\":\"مایوت\",\"de\":\"Montserrat\",\"es\":\"Montserrat\",\"fr\":\"Montserrat\",\"ja\":\"モントセラト\",\"it\":\"Montserrat\",\"cn\":\"蒙特塞拉特\",\"tr\":\"Montserrat\"}',16.75000000,-62.20000000,'','U+1F1F2 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(149,'Morocco','MAR','504','MA','212','Rabat','MAD','Moroccan dirham','DH','.ma','المغرب','Africa','Northern Africa','[{\"zoneName\":\"Africa/Casablanca\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WEST\",\"tzName\":\"Western European Summer Time\"}]','{\"kr\":\"모로코\",\"br\":\"Marrocos\",\"pt\":\"Marrocos\",\"nl\":\"Marokko\",\"hr\":\"Maroko\",\"fa\":\"مراکش\",\"de\":\"Marokko\",\"es\":\"Marruecos\",\"fr\":\"Maroc\",\"ja\":\"モロッコ\",\"it\":\"Marocco\",\"cn\":\"摩洛哥\",\"tr\":\"Fas\"}',32.00000000,-5.00000000,'','U+1F1F2 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1028'),
(150,'Mozambique','MOZ','508','MZ','258','Maputo','MZN','Mozambican metical','MT','.mz','Moçambique','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Maputo\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"모잠비크\",\"br\":\"Moçambique\",\"pt\":\"Moçambique\",\"nl\":\"Mozambique\",\"hr\":\"Mozambik\",\"fa\":\"موزامبیک\",\"de\":\"Mosambik\",\"es\":\"Mozambique\",\"fr\":\"Mozambique\",\"ja\":\"モザンビーク\",\"it\":\"Mozambico\",\"cn\":\"莫桑比克\",\"tr\":\"Mozambik\"}',-18.25000000,35.00000000,'','U+1F1F2 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1029'),
(151,'Myanmar','MMR','104','MM','95','Nay Pyi Taw','MMK','Burmese kyat','K','.mm','မြန်မာ','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Yangon\",\"gmtOffset\":23400,\"gmtOffsetName\":\"UTC+06:30\",\"abbreviation\":\"MMT\",\"tzName\":\"Myanmar Standard Time\"}]','{\"kr\":\"미얀마\",\"br\":\"Myanmar\",\"pt\":\"Myanmar\",\"nl\":\"Myanmar\",\"hr\":\"Mijanmar\",\"fa\":\"میانمار\",\"de\":\"Myanmar\",\"es\":\"Myanmar\",\"fr\":\"Myanmar\",\"ja\":\"ミャンマー\",\"it\":\"Birmania\",\"cn\":\"缅甸\",\"tr\":\"Myanmar\"}',22.00000000,98.00000000,'','U+1F1F2 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q836'),
(152,'Namibia','NAM','516','NA','264','Windhoek','NAD','Namibian dollar','$','.na','Namibia','Africa','Southern Africa','[{\"zoneName\":\"Africa/Windhoek\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"WAST\",\"tzName\":\"West Africa Summer Time\"}]','{\"kr\":\"나미비아\",\"br\":\"Namíbia\",\"pt\":\"Namíbia\",\"nl\":\"Namibië\",\"hr\":\"Namibija\",\"fa\":\"نامیبیا\",\"de\":\"Namibia\",\"es\":\"Namibia\",\"fr\":\"Namibie\",\"ja\":\"ナミビア\",\"it\":\"Namibia\",\"cn\":\"纳米比亚\",\"tr\":\"Namibya\"}',-22.00000000,17.00000000,'','U+1F1F3 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1030'),
(153,'Nauru','NRU','520','NR','674','Yaren','AUD','Australian dollar','$','.nr','Nauru','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Nauru\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"NRT\",\"tzName\":\"Nauru Time\"}]','{\"kr\":\"나우루\",\"br\":\"Nauru\",\"pt\":\"Nauru\",\"nl\":\"Nauru\",\"hr\":\"Nauru\",\"fa\":\"نائورو\",\"de\":\"Nauru\",\"es\":\"Nauru\",\"fr\":\"Nauru\",\"ja\":\"ナウル\",\"it\":\"Nauru\",\"cn\":\"瑙鲁\",\"tr\":\"Nauru\"}',-0.53333333,166.91666666,'','U+1F1F3 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q697'),
(154,'Nepal','NPL','524','NP','977','Kathmandu','NPR','Nepalese rupee','₨','.np','नपल','Asia','Southern Asia','[{\"zoneName\":\"Asia/Kathmandu\",\"gmtOffset\":20700,\"gmtOffsetName\":\"UTC+05:45\",\"abbreviation\":\"NPT\",\"tzName\":\"Nepal Time\"}]','{\"kr\":\"네팔\",\"br\":\"Nepal\",\"pt\":\"Nepal\",\"nl\":\"Nepal\",\"hr\":\"Nepal\",\"fa\":\"نپال\",\"de\":\"Népal\",\"es\":\"Nepal\",\"fr\":\"Népal\",\"ja\":\"ネパール\",\"it\":\"Nepal\",\"cn\":\"尼泊尔\",\"tr\":\"Nepal\"}',28.00000000,84.00000000,'','U+1F1F3 U+1F1F5','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q837'),
(155,'Bonaire, Sint Eustatius and Saba','BES','535','BQ','599','Kralendijk','USD','United States dollar','$','.an','Caribisch Nederland','Americas','Caribbean','[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"보네르 섬\",\"br\":\"Bonaire\",\"pt\":\"Bonaire\",\"fa\":\"بونیر\",\"de\":\"Bonaire, Sint Eustatius und Saba\",\"fr\":\"Bonaire, Saint-Eustache et Saba\",\"it\":\"Bonaire, Saint-Eustache e Saba\",\"cn\":\"博内尔岛、圣尤斯特歇斯和萨巴岛\",\"tr\":\"Karayip Hollandasi\"}',12.15000000,-68.26666700,'','U+1F1E7 U+1F1F6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q27561'),
(156,'Netherlands','NLD','528','NL','31','Amsterdam','EUR','Euro','€','.nl','Nederland','Europe','Western Europe','[{\"zoneName\":\"Europe/Amsterdam\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"네덜란드 \",\"br\":\"Holanda\",\"pt\":\"Países Baixos\",\"nl\":\"Nederland\",\"hr\":\"Nizozemska\",\"fa\":\"پادشاهی هلند\",\"de\":\"Niederlande\",\"es\":\"Países Bajos\",\"fr\":\"Pays-Bas\",\"ja\":\"オランダ\",\"it\":\"Paesi Bassi\",\"cn\":\"荷兰\",\"tr\":\"Hollanda\"}',52.50000000,5.75000000,'','U+1F1F3 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q55'),
(157,'New Caledonia','NCL','540','NC','687','Noumea','XPF','CFP franc','₣','.nc','Nouvelle-Calédonie','Oceania','Melanesia','[{\"zoneName\":\"Pacific/Noumea\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"NCT\",\"tzName\":\"New Caledonia Time\"}]','{\"kr\":\"누벨칼레도니\",\"br\":\"Nova Caledônia\",\"pt\":\"Nova Caledónia\",\"nl\":\"Nieuw-Caledonië\",\"hr\":\"Nova Kaledonija\",\"fa\":\"کالدونیای جدید\",\"de\":\"Neukaledonien\",\"es\":\"Nueva Caledonia\",\"fr\":\"Nouvelle-Calédonie\",\"ja\":\"ニューカレドニア\",\"it\":\"Nuova Caledonia\",\"cn\":\"新喀里多尼亚\",\"tr\":\"Yeni Kaledonya\"}',-21.50000000,165.50000000,'','U+1F1F3 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(158,'New Zealand','NZL','554','NZ','64','Wellington','NZD','New Zealand dollar','$','.nz','New Zealand','Oceania','Australia and New Zealand','[{\"zoneName\":\"Pacific/Auckland\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"NZDT\",\"tzName\":\"New Zealand Daylight Time\"},{\"zoneName\":\"Pacific/Chatham\",\"gmtOffset\":49500,\"gmtOffsetName\":\"UTC+13:45\",\"abbreviation\":\"CHAST\",\"tzName\":\"Chatham Standard Time\"}]','{\"kr\":\"뉴질랜드\",\"br\":\"Nova Zelândia\",\"pt\":\"Nova Zelândia\",\"nl\":\"Nieuw-Zeeland\",\"hr\":\"Novi Zeland\",\"fa\":\"نیوزیلند\",\"de\":\"Neuseeland\",\"es\":\"Nueva Zelanda\",\"fr\":\"Nouvelle-Zélande\",\"ja\":\"ニュージーランド\",\"it\":\"Nuova Zelanda\",\"cn\":\"新西兰\",\"tr\":\"Yeni Zelanda\"}',-41.00000000,174.00000000,'','U+1F1F3 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q664'),
(159,'Nicaragua','NIC','558','NI','505','Managua','NIO','Nicaraguan córdoba','C$','.ni','Nicaragua','Americas','Central America','[{\"zoneName\":\"America/Managua\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"}]','{\"kr\":\"니카라과\",\"br\":\"Nicarágua\",\"pt\":\"Nicarágua\",\"nl\":\"Nicaragua\",\"hr\":\"Nikaragva\",\"fa\":\"نیکاراگوئه\",\"de\":\"Nicaragua\",\"es\":\"Nicaragua\",\"fr\":\"Nicaragua\",\"ja\":\"ニカラグア\",\"it\":\"Nicaragua\",\"cn\":\"尼加拉瓜\",\"tr\":\"Nikaragua\"}',13.00000000,-85.00000000,'','U+1F1F3 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q811'),
(160,'Niger','NER','562','NE','227','Niamey','XOF','West African CFA franc','CFA','.ne','Niger','Africa','Western Africa','[{\"zoneName\":\"Africa/Niamey\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"니제르\",\"br\":\"Níger\",\"pt\":\"Níger\",\"nl\":\"Niger\",\"hr\":\"Niger\",\"fa\":\"نیجر\",\"de\":\"Niger\",\"es\":\"Níger\",\"fr\":\"Niger\",\"ja\":\"ニジェール\",\"it\":\"Niger\",\"cn\":\"尼日尔\",\"tr\":\"Nijer\"}',16.00000000,8.00000000,'','U+1F1F3 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1032'),
(161,'Nigeria','NGA','566','NG','234','Abuja','NGN','Nigerian naira','₦','.ng','Nigeria','Africa','Western Africa','[{\"zoneName\":\"Africa/Lagos\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WAT\",\"tzName\":\"West Africa Time\"}]','{\"kr\":\"나이지리아\",\"br\":\"Nigéria\",\"pt\":\"Nigéria\",\"nl\":\"Nigeria\",\"hr\":\"Nigerija\",\"fa\":\"نیجریه\",\"de\":\"Nigeria\",\"es\":\"Nigeria\",\"fr\":\"Nigéria\",\"ja\":\"ナイジェリア\",\"it\":\"Nigeria\",\"cn\":\"尼日利亚\",\"tr\":\"Nijerya\"}',10.00000000,8.00000000,'','U+1F1F3 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1033'),
(162,'Niue','NIU','570','NU','683','Alofi','NZD','New Zealand dollar','$','.nu','Niuē','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Niue\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"NUT\",\"tzName\":\"Niue Time\"}]','{\"kr\":\"니우에\",\"br\":\"Niue\",\"pt\":\"Niue\",\"nl\":\"Niue\",\"hr\":\"Niue\",\"fa\":\"نیووی\",\"de\":\"Niue\",\"es\":\"Niue\",\"fr\":\"Niue\",\"ja\":\"ニウエ\",\"it\":\"Niue\",\"cn\":\"纽埃\",\"tr\":\"Niue\"}',-19.03333333,-169.86666666,'','U+1F1F3 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q34020'),
(163,'Norfolk Island','NFK','574','NF','672','Kingston','AUD','Australian dollar','$','.nf','Norfolk Island','Oceania','Australia and New Zealand','[{\"zoneName\":\"Pacific/Norfolk\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"NFT\",\"tzName\":\"Norfolk Time\"}]','{\"kr\":\"노퍽 섬\",\"br\":\"Ilha Norfolk\",\"pt\":\"Ilha Norfolk\",\"nl\":\"Norfolkeiland\",\"hr\":\"Otok Norfolk\",\"fa\":\"جزیره نورفک\",\"de\":\"Norfolkinsel\",\"es\":\"Isla de Norfolk\",\"fr\":\"Île de Norfolk\",\"ja\":\"ノーフォーク島\",\"it\":\"Isola Norfolk\",\"cn\":\"诺福克岛\",\"tr\":\"Norfolk Adasi\"}',-29.03333333,167.95000000,'','U+1F1F3 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(164,'Northern Mariana Islands','MNP','580','MP','+1-670','Saipan','USD','United States dollar','$','.mp','Northern Mariana Islands','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Saipan\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"ChST\",\"tzName\":\"Chamorro Standard Time\"}]','{\"kr\":\"북마리아나 제도\",\"br\":\"Ilhas Marianas\",\"pt\":\"Ilhas Marianas\",\"nl\":\"Noordelijke Marianeneilanden\",\"hr\":\"Sjevernomarijanski otoci\",\"fa\":\"جزایر ماریانای شمالی\",\"de\":\"Nördliche Marianen\",\"es\":\"Islas Marianas del Norte\",\"fr\":\"Îles Mariannes du Nord\",\"ja\":\"北マリアナ諸島\",\"it\":\"Isole Marianne Settentrionali\",\"cn\":\"北马里亚纳群岛\",\"tr\":\"Kuzey Mariana Adalari\"}',15.20000000,145.75000000,'','U+1F1F2 U+1F1F5','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(165,'Norway','NOR','578','NO','47','Oslo','NOK','Norwegian krone','kr','.no','Norge','Europe','Northern Europe','[{\"zoneName\":\"Europe/Oslo\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"노르웨이\",\"br\":\"Noruega\",\"pt\":\"Noruega\",\"nl\":\"Noorwegen\",\"hr\":\"Norveška\",\"fa\":\"نروژ\",\"de\":\"Norwegen\",\"es\":\"Noruega\",\"fr\":\"Norvège\",\"ja\":\"ノルウェー\",\"it\":\"Norvegia\",\"cn\":\"挪威\",\"tr\":\"Norveç\"}',62.00000000,10.00000000,'','U+1F1F3 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q20'),
(166,'Oman','OMN','512','OM','968','Muscat','OMR','Omani rial','.ع.ر','.om','عمان','Asia','Western Asia','[{\"zoneName\":\"Asia/Muscat\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GST\",\"tzName\":\"Gulf Standard Time\"}]','{\"kr\":\"오만\",\"br\":\"Omã\",\"pt\":\"Omã\",\"nl\":\"Oman\",\"hr\":\"Oman\",\"fa\":\"عمان\",\"de\":\"Oman\",\"es\":\"Omán\",\"fr\":\"Oman\",\"ja\":\"オマーン\",\"it\":\"oman\",\"cn\":\"阿曼\",\"tr\":\"Umman\"}',21.00000000,57.00000000,'','U+1F1F4 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q842'),
(167,'Pakistan','PAK','586','PK','92','Islamabad','PKR','Pakistani rupee','₨','.pk','Pakistan','Asia','Southern Asia','[{\"zoneName\":\"Asia/Karachi\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"PKT\",\"tzName\":\"Pakistan Standard Time\"}]','{\"kr\":\"파키스탄\",\"br\":\"Paquistão\",\"pt\":\"Paquistão\",\"nl\":\"Pakistan\",\"hr\":\"Pakistan\",\"fa\":\"پاکستان\",\"de\":\"Pakistan\",\"es\":\"Pakistán\",\"fr\":\"Pakistan\",\"ja\":\"パキスタン\",\"it\":\"Pakistan\",\"cn\":\"巴基斯坦\",\"tr\":\"Pakistan\"}',30.00000000,70.00000000,'','U+1F1F5 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q843'),
(168,'Palau','PLW','585','PW','680','Melekeok','USD','United States dollar','$','.pw','Palau','Oceania','Micronesia','[{\"zoneName\":\"Pacific/Palau\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"PWT\",\"tzName\":\"Palau Time\"}]','{\"kr\":\"팔라우\",\"br\":\"Palau\",\"pt\":\"Palau\",\"nl\":\"Palau\",\"hr\":\"Palau\",\"fa\":\"پالائو\",\"de\":\"Palau\",\"es\":\"Palau\",\"fr\":\"Palaos\",\"ja\":\"パラオ\",\"it\":\"Palau\",\"cn\":\"帕劳\",\"tr\":\"Palau\"}',7.50000000,134.50000000,'','U+1F1F5 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q695'),
(169,'Palestinian Territory Occupied','PSE','275','PS','970','East Jerusalem','ILS','Israeli new shekel','₪','.ps','فلسطين','Asia','Western Asia','[{\"zoneName\":\"Asia/Gaza\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Asia/Hebron\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"팔레스타인 영토\",\"br\":\"Palestina\",\"pt\":\"Palestina\",\"nl\":\"Palestijnse gebieden\",\"hr\":\"Palestina\",\"fa\":\"فلسطین\",\"de\":\"Palästina\",\"es\":\"Palestina\",\"fr\":\"Palestine\",\"ja\":\"パレスチナ\",\"it\":\"Palestina\",\"cn\":\"巴勒斯坦\",\"tr\":\"Filistin\"}',31.90000000,35.20000000,'','U+1F1F5 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(170,'Panama','PAN','591','PA','507','Panama City','PAB','Panamanian balboa','B/.','.pa','Panamá','Americas','Central America','[{\"zoneName\":\"America/Panama\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]','{\"kr\":\"파나마\",\"br\":\"Panamá\",\"pt\":\"Panamá\",\"nl\":\"Panama\",\"hr\":\"Panama\",\"fa\":\"پاناما\",\"de\":\"Panama\",\"es\":\"Panamá\",\"fr\":\"Panama\",\"ja\":\"パナマ\",\"it\":\"Panama\",\"cn\":\"巴拿马\",\"tr\":\"Panama\"}',9.00000000,-80.00000000,'','U+1F1F5 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q804'),
(171,'Papua new Guinea','PNG','598','PG','675','Port Moresby','PGK','Papua New Guinean kina','K','.pg','Papua Niugini','Oceania','Melanesia','[{\"zoneName\":\"Pacific/Bougainville\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"BST\",\"tzName\":\"Bougainville Standard Time[6\"},{\"zoneName\":\"Pacific/Port_Moresby\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"PGT\",\"tzName\":\"Papua New Guinea Time\"}]','{\"kr\":\"파푸아뉴기니\",\"br\":\"Papua Nova Guiné\",\"pt\":\"Papua Nova Guiné\",\"nl\":\"Papoea-Nieuw-Guinea\",\"hr\":\"Papua Nova Gvineja\",\"fa\":\"پاپوآ گینه نو\",\"de\":\"Papua-Neuguinea\",\"es\":\"Papúa Nueva Guinea\",\"fr\":\"Papouasie-Nouvelle-Guinée\",\"ja\":\"パプアニューギニア\",\"it\":\"Papua Nuova Guinea\",\"cn\":\"巴布亚新几内亚\",\"tr\":\"Papua Yeni Gine\"}',-6.00000000,147.00000000,'','U+1F1F5 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q691'),
(172,'Paraguay','PRY','600','PY','595','Asuncion','PYG','Paraguayan guarani','₲','.py','Paraguay','Americas','South America','[{\"zoneName\":\"America/Asuncion\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"PYST\",\"tzName\":\"Paraguay Summer Time\"}]','{\"kr\":\"파라과이\",\"br\":\"Paraguai\",\"pt\":\"Paraguai\",\"nl\":\"Paraguay\",\"hr\":\"Paragvaj\",\"fa\":\"پاراگوئه\",\"de\":\"Paraguay\",\"es\":\"Paraguay\",\"fr\":\"Paraguay\",\"ja\":\"パラグアイ\",\"it\":\"Paraguay\",\"cn\":\"巴拉圭\",\"tr\":\"Paraguay\"}',-23.00000000,-58.00000000,'','U+1F1F5 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q733'),
(173,'Peru','PER','604','PE','51','Lima','PEN','Peruvian sol','S/.','.pe','Perú','Americas','South America','[{\"zoneName\":\"America/Lima\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"PET\",\"tzName\":\"Peru Time\"}]','{\"kr\":\"페루\",\"br\":\"Peru\",\"pt\":\"Peru\",\"nl\":\"Peru\",\"hr\":\"Peru\",\"fa\":\"پرو\",\"de\":\"Peru\",\"es\":\"Perú\",\"fr\":\"Pérou\",\"ja\":\"ペルー\",\"it\":\"Perù\",\"cn\":\"秘鲁\",\"tr\":\"Peru\"}',-10.00000000,-76.00000000,'','U+1F1F5 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q419'),
(174,'Philippines','PHL','608','PH','63','Manila','PHP','Philippine peso','₱','.ph','Pilipinas','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Manila\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"PHT\",\"tzName\":\"Philippine Time\"}]','{\"kr\":\"필리핀\",\"br\":\"Filipinas\",\"pt\":\"Filipinas\",\"nl\":\"Filipijnen\",\"hr\":\"Filipini\",\"fa\":\"جزایر الندفیلیپین\",\"de\":\"Philippinen\",\"es\":\"Filipinas\",\"fr\":\"Philippines\",\"ja\":\"フィリピン\",\"it\":\"Filippine\",\"cn\":\"菲律宾\",\"tr\":\"Filipinler\"}',13.00000000,122.00000000,'','U+1F1F5 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q928'),
(175,'Pitcairn Island','PCN','612','PN','870','Adamstown','NZD','New Zealand dollar','$','.pn','Pitcairn Islands','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Pitcairn\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"}]','{\"kr\":\"핏케언 제도\",\"br\":\"Ilhas Pitcairn\",\"pt\":\"Ilhas Picárnia\",\"nl\":\"Pitcairneilanden\",\"hr\":\"Pitcairnovo otočje\",\"fa\":\"پیتکرن\",\"de\":\"Pitcairn\",\"es\":\"Islas Pitcairn\",\"fr\":\"Îles Pitcairn\",\"ja\":\"ピトケアン\",\"it\":\"Isole Pitcairn\",\"cn\":\"皮特凯恩群岛\",\"tr\":\"Pitcairn Adalari\"}',-25.06666666,-130.10000000,'','U+1F1F5 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(176,'Poland','POL','616','PL','48','Warsaw','PLN','Polish złoty','zł','.pl','Polska','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Warsaw\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"폴란드\",\"br\":\"Polônia\",\"pt\":\"Polónia\",\"nl\":\"Polen\",\"hr\":\"Poljska\",\"fa\":\"لهستان\",\"de\":\"Polen\",\"es\":\"Polonia\",\"fr\":\"Pologne\",\"ja\":\"ポーランド\",\"it\":\"Polonia\",\"cn\":\"波兰\",\"tr\":\"Polonya\"}',52.00000000,20.00000000,'','U+1F1F5 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q36'),
(177,'Portugal','PRT','620','PT','351','Lisbon','EUR','Euro','€','.pt','Portugal','Europe','Southern Europe','[{\"zoneName\":\"Atlantic/Azores\",\"gmtOffset\":-3600,\"gmtOffsetName\":\"UTC-01:00\",\"abbreviation\":\"AZOT\",\"tzName\":\"Azores Standard Time\"},{\"zoneName\":\"Atlantic/Madeira\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"},{\"zoneName\":\"Europe/Lisbon\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"}]','{\"kr\":\"포르투갈\",\"br\":\"Portugal\",\"pt\":\"Portugal\",\"nl\":\"Portugal\",\"hr\":\"Portugal\",\"fa\":\"پرتغال\",\"de\":\"Portugal\",\"es\":\"Portugal\",\"fr\":\"Portugal\",\"ja\":\"ポルトガル\",\"it\":\"Portogallo\",\"cn\":\"葡萄牙\",\"tr\":\"Portekiz\"}',39.50000000,-8.00000000,'','U+1F1F5 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q45'),
(178,'Puerto Rico','PRI','630','PR','+1-787 and 1-939','San Juan','USD','United States dollar','$','.pr','Puerto Rico','Americas','Caribbean','[{\"zoneName\":\"America/Puerto_Rico\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"푸에르토리코\",\"br\":\"Porto Rico\",\"pt\":\"Porto Rico\",\"nl\":\"Puerto Rico\",\"hr\":\"Portoriko\",\"fa\":\"پورتو ریکو\",\"de\":\"Puerto Rico\",\"es\":\"Puerto Rico\",\"fr\":\"Porto Rico\",\"ja\":\"プエルトリコ\",\"it\":\"Porto Rico\",\"cn\":\"波多黎各\",\"tr\":\"Porto Riko\"}',18.25000000,-66.50000000,'','U+1F1F5 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(179,'Qatar','QAT','634','QA','974','Doha','QAR','Qatari riyal','ق.ر','.qa','قطر','Asia','Western Asia','[{\"zoneName\":\"Asia/Qatar\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"카타르\",\"br\":\"Catar\",\"pt\":\"Catar\",\"nl\":\"Qatar\",\"hr\":\"Katar\",\"fa\":\"قطر\",\"de\":\"Katar\",\"es\":\"Catar\",\"fr\":\"Qatar\",\"ja\":\"カタール\",\"it\":\"Qatar\",\"cn\":\"卡塔尔\",\"tr\":\"Katar\"}',25.50000000,51.25000000,'','U+1F1F6 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q846'),
(180,'Reunion','REU','638','RE','262','Saint-Denis','EUR','Euro','€','.re','La Réunion','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Reunion\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"RET\",\"tzName\":\"Réunion Time\"}]','{\"kr\":\"레위니옹\",\"br\":\"Reunião\",\"pt\":\"Reunião\",\"nl\":\"Réunion\",\"hr\":\"Réunion\",\"fa\":\"رئونیون\",\"de\":\"Réunion\",\"es\":\"Reunión\",\"fr\":\"Réunion\",\"ja\":\"レユニオン\",\"it\":\"Riunione\",\"cn\":\"留尼汪岛\",\"tr\":\"Réunion\"}',-21.15000000,55.50000000,'','U+1F1F7 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(181,'Romania','ROU','642','RO','40','Bucharest','RON','Romanian leu','lei','.ro','România','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Bucharest\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"루마니아\",\"br\":\"Romênia\",\"pt\":\"Roménia\",\"nl\":\"Roemenië\",\"hr\":\"Rumunjska\",\"fa\":\"رومانی\",\"de\":\"Rumänien\",\"es\":\"Rumania\",\"fr\":\"Roumanie\",\"ja\":\"ルーマニア\",\"it\":\"Romania\",\"cn\":\"罗马尼亚\",\"tr\":\"Romanya\"}',46.00000000,25.00000000,'','U+1F1F7 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q218'),
(182,'Russia','RUS','643','RU','7','Moscow','RUB','Russian ruble','₽','.ru','Россия','Europe','Eastern Europe','[{\"zoneName\":\"Asia/Anadyr\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"ANAT\",\"tzName\":\"Anadyr Time[4\"},{\"zoneName\":\"Asia/Barnaul\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Chita\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Irkutsk\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"IRKT\",\"tzName\":\"Irkutsk Time\"},{\"zoneName\":\"Asia/Kamchatka\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"PETT\",\"tzName\":\"Kamchatka Time\"},{\"zoneName\":\"Asia/Khandyga\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Krasnoyarsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Magadan\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"MAGT\",\"tzName\":\"Magadan Time\"},{\"zoneName\":\"Asia/Novokuznetsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"KRAT\",\"tzName\":\"Krasnoyarsk Time\"},{\"zoneName\":\"Asia/Novosibirsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"NOVT\",\"tzName\":\"Novosibirsk Time\"},{\"zoneName\":\"Asia/Omsk\",\"gmtOffset\":21600,\"gmtOffsetName\":\"UTC+06:00\",\"abbreviation\":\"OMST\",\"tzName\":\"Omsk Time\"},{\"zoneName\":\"Asia/Sakhalin\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SAKT\",\"tzName\":\"Sakhalin Island Time\"},{\"zoneName\":\"Asia/Srednekolymsk\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SRET\",\"tzName\":\"Srednekolymsk Time\"},{\"zoneName\":\"Asia/Tomsk\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"MSD+3\",\"tzName\":\"Moscow Daylight Time+3\"},{\"zoneName\":\"Asia/Ust-Nera\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"VLAT\",\"tzName\":\"Vladivostok Time\"},{\"zoneName\":\"Asia/Vladivostok\",\"gmtOffset\":36000,\"gmtOffsetName\":\"UTC+10:00\",\"abbreviation\":\"VLAT\",\"tzName\":\"Vladivostok Time\"},{\"zoneName\":\"Asia/Yakutsk\",\"gmtOffset\":32400,\"gmtOffsetName\":\"UTC+09:00\",\"abbreviation\":\"YAKT\",\"tzName\":\"Yakutsk Time\"},{\"zoneName\":\"Asia/Yekaterinburg\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"YEKT\",\"tzName\":\"Yekaterinburg Time\"},{\"zoneName\":\"Europe/Astrakhan\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Kaliningrad\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Kirov\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Moscow\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Samara\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Saratov\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MSD\",\"tzName\":\"Moscow Daylight Time+4\"},{\"zoneName\":\"Europe/Ulyanovsk\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SAMT\",\"tzName\":\"Samara Time\"},{\"zoneName\":\"Europe/Volgograd\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Standard Time\"}]','{\"kr\":\"러시아\",\"br\":\"Rússia\",\"pt\":\"Rússia\",\"nl\":\"Rusland\",\"hr\":\"Rusija\",\"fa\":\"روسیه\",\"de\":\"Russland\",\"es\":\"Rusia\",\"fr\":\"Russie\",\"ja\":\"ロシア連邦\",\"it\":\"Russia\",\"cn\":\"俄罗斯联邦\",\"tr\":\"Rusya\"}',60.00000000,100.00000000,'','U+1F1F7 U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q159'),
(183,'Rwanda','RWA','646','RW','250','Kigali','RWF','Rwandan franc','FRw','.rw','Rwanda','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Kigali\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"르완다\",\"br\":\"Ruanda\",\"pt\":\"Ruanda\",\"nl\":\"Rwanda\",\"hr\":\"Ruanda\",\"fa\":\"رواندا\",\"de\":\"Ruanda\",\"es\":\"Ruanda\",\"fr\":\"Rwanda\",\"ja\":\"ルワンダ\",\"it\":\"Ruanda\",\"cn\":\"卢旺达\",\"tr\":\"Ruanda\"}',-2.00000000,30.00000000,'','U+1F1F7 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q1037'),
(184,'Saint Helena','SHN','654','SH','290','Jamestown','SHP','Saint Helena pound','£','.sh','Saint Helena','Africa','Western Africa','[{\"zoneName\":\"Atlantic/St_Helena\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"세인트헬레나\",\"br\":\"Santa Helena\",\"pt\":\"Santa Helena\",\"nl\":\"Sint-Helena\",\"hr\":\"Sveta Helena\",\"fa\":\"سنت هلنا، اسنشن و تریستان دا کونا\",\"de\":\"Sankt Helena\",\"es\":\"Santa Helena\",\"fr\":\"Sainte-Hélène\",\"ja\":\"セントヘレナ・アセンションおよびトリスタンダクーニャ\",\"it\":\"Sant\'Elena\",\"cn\":\"圣赫勒拿\",\"tr\":\"Saint Helena\"}',-15.95000000,-5.70000000,'','U+1F1F8 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(185,'Saint Kitts And Nevis','KNA','659','KN','+1-869','Basseterre','XCD','Eastern Caribbean dollar','$','.kn','Saint Kitts and Nevis','Americas','Caribbean','[{\"zoneName\":\"America/St_Kitts\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"세인트키츠 네비스\",\"br\":\"São Cristóvão e Neves\",\"pt\":\"São Cristóvão e Neves\",\"nl\":\"Saint Kitts en Nevis\",\"hr\":\"Sveti Kristof i Nevis\",\"fa\":\"سنت کیتس و نویس\",\"de\":\"St. Kitts und Nevis\",\"es\":\"San Cristóbal y Nieves\",\"fr\":\"Saint-Christophe-et-Niévès\",\"ja\":\"セントクリストファー・ネイビス\",\"it\":\"Saint Kitts e Nevis\",\"cn\":\"圣基茨和尼维斯\",\"tr\":\"Saint Kitts Ve Nevis\"}',17.33333333,-62.75000000,'','U+1F1F0 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q763'),
(186,'Saint Lucia','LCA','662','LC','+1-758','Castries','XCD','Eastern Caribbean dollar','$','.lc','Saint Lucia','Americas','Caribbean','[{\"zoneName\":\"America/St_Lucia\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"세인트루시아\",\"br\":\"Santa Lúcia\",\"pt\":\"Santa Lúcia\",\"nl\":\"Saint Lucia\",\"hr\":\"Sveta Lucija\",\"fa\":\"سنت لوسیا\",\"de\":\"Saint Lucia\",\"es\":\"Santa Lucía\",\"fr\":\"Saint-Lucie\",\"ja\":\"セントルシア\",\"it\":\"Santa Lucia\",\"cn\":\"圣卢西亚\",\"tr\":\"Saint Lucia\"}',13.88333333,-60.96666666,'','U+1F1F1 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:32:07',1,'Q760'),
(187,'Saint Pierre and Miquelon','SPM','666','PM','508','Saint-Pierre','EUR','Euro','€','.pm','Saint-Pierre-et-Miquelon','Americas','Northern America','[{\"zoneName\":\"America/Miquelon\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"PMDT\",\"tzName\":\"Pierre & Miquelon Daylight Time\"}]','{\"kr\":\"생피에르 미클롱\",\"br\":\"Saint-Pierre e Miquelon\",\"pt\":\"São Pedro e Miquelon\",\"nl\":\"Saint Pierre en Miquelon\",\"hr\":\"Sveti Petar i Mikelon\",\"fa\":\"سن پیر و میکلن\",\"de\":\"Saint-Pierre und Miquelon\",\"es\":\"San Pedro y Miquelón\",\"fr\":\"Saint-Pierre-et-Miquelon\",\"ja\":\"サンピエール島・ミクロン島\",\"it\":\"Saint-Pierre e Miquelon\",\"cn\":\"圣皮埃尔和密克隆\",\"tr\":\"Saint Pierre Ve Miquelon\"}',46.83333333,-56.33333333,'','U+1F1F5 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:32:07',1,NULL),
(188,'Saint Vincent And The Grenadines','VCT','670','VC','+1-784','Kingstown','XCD','Eastern Caribbean dollar','$','.vc','Saint Vincent and the Grenadines','Americas','Caribbean','[{\"zoneName\":\"America/St_Vincent\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"세인트빈센트 그레나딘\",\"br\":\"São Vicente e Granadinas\",\"pt\":\"São Vicente e Granadinas\",\"nl\":\"Saint Vincent en de Grenadines\",\"hr\":\"Sveti Vincent i Grenadini\",\"fa\":\"سنت وینسنت و گرنادین‌ها\",\"de\":\"Saint Vincent und die Grenadinen\",\"es\":\"San Vicente y Granadinas\",\"fr\":\"Saint-Vincent-et-les-Grenadines\",\"ja\":\"セントビンセントおよびグレナディーン諸島\",\"it\":\"Saint Vincent e Grenadine\",\"cn\":\"圣文森特和格林纳丁斯\",\"tr\":\"Saint Vincent Ve Grenadinler\"}',13.25000000,-61.20000000,'','U+1F1FB U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q757'),
(189,'Saint-Barthelemy','BLM','652','BL','590','Gustavia','EUR','Euro','€','.bl','Saint-Barthélemy','Americas','Caribbean','[{\"zoneName\":\"America/St_Barthelemy\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"생바르텔레미\",\"br\":\"São Bartolomeu\",\"pt\":\"São Bartolomeu\",\"nl\":\"Saint Barthélemy\",\"hr\":\"Saint Barthélemy\",\"fa\":\"سن-بارتلمی\",\"de\":\"Saint-Barthélemy\",\"es\":\"San Bartolomé\",\"fr\":\"Saint-Barthélemy\",\"ja\":\"サン・バルテルミー\",\"it\":\"Antille Francesi\",\"cn\":\"圣巴泰勒米\",\"tr\":\"Saint Barthélemy\"}',18.50000000,-63.41666666,'','U+1F1E7 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(190,'Saint-Martin (French part)','MAF','663','MF','590','Marigot','EUR','Euro','€','.mf','Saint-Martin','Americas','Caribbean','[{\"zoneName\":\"America/Marigot\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"세인트마틴 섬\",\"br\":\"Saint Martin\",\"pt\":\"Ilha São Martinho\",\"nl\":\"Saint-Martin\",\"hr\":\"Sveti Martin\",\"fa\":\"سینت مارتن\",\"de\":\"Saint Martin\",\"es\":\"Saint Martin\",\"fr\":\"Saint-Martin\",\"ja\":\"サン・マルタン（フランス領）\",\"it\":\"Saint Martin\",\"cn\":\"密克罗尼西亚\",\"tr\":\"Saint Martin\"}',18.08333333,-63.95000000,'','U+1F1F2 U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(191,'Samoa','WSM','882','WS','685','Apia','WST','Samoan tālā','SAT','.ws','Samoa','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Apia\",\"gmtOffset\":50400,\"gmtOffsetName\":\"UTC+14:00\",\"abbreviation\":\"WST\",\"tzName\":\"West Samoa Time\"}]','{\"kr\":\"사모아\",\"br\":\"Samoa\",\"pt\":\"Samoa\",\"nl\":\"Samoa\",\"hr\":\"Samoa\",\"fa\":\"ساموآ\",\"de\":\"Samoa\",\"es\":\"Samoa\",\"fr\":\"Samoa\",\"ja\":\"サモア\",\"it\":\"Samoa\",\"cn\":\"萨摩亚\",\"tr\":\"Samoa\"}',-13.58333333,-172.33333333,'','U+1F1FC U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q683'),
(192,'San Marino','SMR','674','SM','378','San Marino','EUR','Euro','€','.sm','San Marino','Europe','Southern Europe','[{\"zoneName\":\"Europe/San_Marino\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"산마리노\",\"br\":\"San Marino\",\"pt\":\"São Marinho\",\"nl\":\"San Marino\",\"hr\":\"San Marino\",\"fa\":\"سان مارینو\",\"de\":\"San Marino\",\"es\":\"San Marino\",\"fr\":\"Saint-Marin\",\"ja\":\"サンマリノ\",\"it\":\"San Marino\",\"cn\":\"圣马力诺\",\"tr\":\"San Marino\"}',43.76666666,12.41666666,'','U+1F1F8 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q238'),
(193,'Sao Tome and Principe','STP','678','ST','239','Sao Tome','STD','Dobra','Db','.st','São Tomé e Príncipe','Africa','Middle Africa','[{\"zoneName\":\"Africa/Sao_Tome\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"상투메 프린시페\",\"br\":\"São Tomé e Príncipe\",\"pt\":\"São Tomé e Príncipe\",\"nl\":\"Sao Tomé en Principe\",\"hr\":\"Sveti Toma i Princip\",\"fa\":\"کواترو دو فرویرو\",\"de\":\"São Tomé und Príncipe\",\"es\":\"Santo Tomé y Príncipe\",\"fr\":\"Sao Tomé-et-Principe\",\"ja\":\"サントメ・プリンシペ\",\"it\":\"São Tomé e Príncipe\",\"cn\":\"圣多美和普林西比\",\"tr\":\"Sao Tome Ve Prinsipe\"}',1.00000000,7.00000000,'','U+1F1F8 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1039'),
(194,'Saudi Arabia','SAU','682','SA','966','Riyadh','SAR','Saudi riyal','﷼','.sa','المملكة العربية السعودية','Asia','Western Asia','[{\"zoneName\":\"Asia/Riyadh\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"사우디아라비아\",\"br\":\"Arábia Saudita\",\"pt\":\"Arábia Saudita\",\"nl\":\"Saoedi-Arabië\",\"hr\":\"Saudijska Arabija\",\"fa\":\"عربستان سعودی\",\"de\":\"Saudi-Arabien\",\"es\":\"Arabia Saudí\",\"fr\":\"Arabie Saoudite\",\"ja\":\"サウジアラビア\",\"it\":\"Arabia Saudita\",\"cn\":\"沙特阿拉伯\",\"tr\":\"Suudi Arabistan\"}',25.00000000,45.00000000,'','U+1F1F8 U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q851'),
(195,'Senegal','SEN','686','SN','221','Dakar','XOF','West African CFA franc','CFA','.sn','Sénégal','Africa','Western Africa','[{\"zoneName\":\"Africa/Dakar\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"세네갈\",\"br\":\"Senegal\",\"pt\":\"Senegal\",\"nl\":\"Senegal\",\"hr\":\"Senegal\",\"fa\":\"سنگال\",\"de\":\"Senegal\",\"es\":\"Senegal\",\"fr\":\"Sénégal\",\"ja\":\"セネガル\",\"it\":\"Senegal\",\"cn\":\"塞内加尔\",\"tr\":\"Senegal\"}',14.00000000,-14.00000000,'','U+1F1F8 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1041'),
(196,'Serbia','SRB','688','RS','381','Belgrade','RSD','Serbian dinar','din','.rs','Србија','Europe','Southern Europe','[{\"zoneName\":\"Europe/Belgrade\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"세르비아\",\"br\":\"Sérvia\",\"pt\":\"Sérvia\",\"nl\":\"Servië\",\"hr\":\"Srbija\",\"fa\":\"صربستان\",\"de\":\"Serbien\",\"es\":\"Serbia\",\"fr\":\"Serbie\",\"ja\":\"セルビア\",\"it\":\"Serbia\",\"cn\":\"塞尔维亚\",\"tr\":\"Sirbistan\"}',44.00000000,21.00000000,'','U+1F1F7 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q403'),
(197,'Seychelles','SYC','690','SC','248','Victoria','SCR','Seychellois rupee','SRe','.sc','Seychelles','Africa','Eastern Africa','[{\"zoneName\":\"Indian/Mahe\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"SCT\",\"tzName\":\"Seychelles Time\"}]','{\"kr\":\"세이셸\",\"br\":\"Seicheles\",\"pt\":\"Seicheles\",\"nl\":\"Seychellen\",\"hr\":\"Sejšeli\",\"fa\":\"سیشل\",\"de\":\"Seychellen\",\"es\":\"Seychelles\",\"fr\":\"Seychelles\",\"ja\":\"セーシェル\",\"it\":\"Seychelles\",\"cn\":\"塞舌尔\",\"tr\":\"Seyşeller\"}',-4.58333333,55.66666666,'','U+1F1F8 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1042'),
(198,'Sierra Leone','SLE','694','SL','232','Freetown','SLL','Sierra Leonean leone','Le','.sl','Sierra Leone','Africa','Western Africa','[{\"zoneName\":\"Africa/Freetown\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"시에라리온\",\"br\":\"Serra Leoa\",\"pt\":\"Serra Leoa\",\"nl\":\"Sierra Leone\",\"hr\":\"Sijera Leone\",\"fa\":\"سیرالئون\",\"de\":\"Sierra Leone\",\"es\":\"Sierra Leone\",\"fr\":\"Sierra Leone\",\"ja\":\"シエラレオネ\",\"it\":\"Sierra Leone\",\"cn\":\"塞拉利昂\",\"tr\":\"Sierra Leone\"}',8.50000000,-11.50000000,'','U+1F1F8 U+1F1F1','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1044'),
(199,'Singapore','SGP','702','SG','65','Singapur','SGD','Singapore dollar','$','.sg','Singapore','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Singapore\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"SGT\",\"tzName\":\"Singapore Time\"}]','{\"kr\":\"싱가포르\",\"br\":\"Singapura\",\"pt\":\"Singapura\",\"nl\":\"Singapore\",\"hr\":\"Singapur\",\"fa\":\"سنگاپور\",\"de\":\"Singapur\",\"es\":\"Singapur\",\"fr\":\"Singapour\",\"ja\":\"シンガポール\",\"it\":\"Singapore\",\"cn\":\"新加坡\",\"tr\":\"Singapur\"}',1.36666666,103.80000000,'','U+1F1F8 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q334'),
(200,'Slovakia','SVK','703','SK','421','Bratislava','EUR','Euro','€','.sk','Slovensko','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Bratislava\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"슬로바키아\",\"br\":\"Eslováquia\",\"pt\":\"Eslováquia\",\"nl\":\"Slowakije\",\"hr\":\"Slovačka\",\"fa\":\"اسلواکی\",\"de\":\"Slowakei\",\"es\":\"República Eslovaca\",\"fr\":\"Slovaquie\",\"ja\":\"スロバキア\",\"it\":\"Slovacchia\",\"cn\":\"斯洛伐克\",\"tr\":\"Slovakya\"}',48.66666666,19.50000000,'','U+1F1F8 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q214'),
(201,'Slovenia','SVN','705','SI','386','Ljubljana','EUR','Euro','€','.si','Slovenija','Europe','Southern Europe','[{\"zoneName\":\"Europe/Ljubljana\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"슬로베니아\",\"br\":\"Eslovênia\",\"pt\":\"Eslovénia\",\"nl\":\"Slovenië\",\"hr\":\"Slovenija\",\"fa\":\"اسلوونی\",\"de\":\"Slowenien\",\"es\":\"Eslovenia\",\"fr\":\"Slovénie\",\"ja\":\"スロベニア\",\"it\":\"Slovenia\",\"cn\":\"斯洛文尼亚\",\"tr\":\"Slovenya\"}',46.11666666,14.81666666,'','U+1F1F8 U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q215'),
(202,'Solomon Islands','SLB','090','SB','677','Honiara','SBD','Solomon Islands dollar','Si$','.sb','Solomon Islands','Oceania','Melanesia','[{\"zoneName\":\"Pacific/Guadalcanal\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"SBT\",\"tzName\":\"Solomon Islands Time\"}]','{\"kr\":\"솔로몬 제도\",\"br\":\"Ilhas Salomão\",\"pt\":\"Ilhas Salomão\",\"nl\":\"Salomonseilanden\",\"hr\":\"Solomonski Otoci\",\"fa\":\"جزایر سلیمان\",\"de\":\"Salomonen\",\"es\":\"Islas Salomón\",\"fr\":\"Îles Salomon\",\"ja\":\"ソロモン諸島\",\"it\":\"Isole Salomone\",\"cn\":\"所罗门群岛\",\"tr\":\"Solomon Adalari\"}',-8.00000000,159.00000000,'','U+1F1F8 U+1F1E7','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q685'),
(203,'Somalia','SOM','706','SO','252','Mogadishu','SOS','Somali shilling','Sh.so.','.so','Soomaaliya','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Mogadishu\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"소말리아\",\"br\":\"Somália\",\"pt\":\"Somália\",\"nl\":\"Somalië\",\"hr\":\"Somalija\",\"fa\":\"سومالی\",\"de\":\"Somalia\",\"es\":\"Somalia\",\"fr\":\"Somalie\",\"ja\":\"ソマリア\",\"it\":\"Somalia\",\"cn\":\"索马里\",\"tr\":\"Somali\"}',10.00000000,49.00000000,'','U+1F1F8 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1045'),
(204,'South Africa','ZAF','710','ZA','27','Pretoria','ZAR','South African rand','R','.za','South Africa','Africa','Southern Africa','[{\"zoneName\":\"Africa/Johannesburg\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]','{\"kr\":\"남아프리카 공화국\",\"br\":\"República Sul-Africana\",\"pt\":\"República Sul-Africana\",\"nl\":\"Zuid-Afrika\",\"hr\":\"Južnoafrička Republika\",\"fa\":\"آفریقای جنوبی\",\"de\":\"Republik Südafrika\",\"es\":\"República de Sudáfrica\",\"fr\":\"Afrique du Sud\",\"ja\":\"南アフリカ\",\"it\":\"Sud Africa\",\"cn\":\"南非\",\"tr\":\"Güney Afrika Cumhuriyeti\"}',-29.00000000,24.00000000,'','U+1F1FF U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q258'),
(205,'South Georgia','SGS','239','GS','500','Grytviken','GBP','British pound','£','.gs','South Georgia','Americas','South America','[{\"zoneName\":\"Atlantic/South_Georgia\",\"gmtOffset\":-7200,\"gmtOffsetName\":\"UTC-02:00\",\"abbreviation\":\"GST\",\"tzName\":\"South Georgia and the South Sandwich Islands Time\"}]','{\"kr\":\"사우스조지아\",\"br\":\"Ilhas Geórgias do Sul e Sandwich do Sul\",\"pt\":\"Ilhas Geórgia do Sul e Sanduíche do Sul\",\"nl\":\"Zuid-Georgia en Zuidelijke Sandwicheilanden\",\"hr\":\"Južna Georgija i otočje Južni Sandwich\",\"fa\":\"جزایر جورجیای جنوبی و ساندویچ جنوبی\",\"de\":\"Südgeorgien und die Südlichen Sandwichinseln\",\"es\":\"Islas Georgias del Sur y Sandwich del Sur\",\"fr\":\"Géorgie du Sud-et-les Îles Sandwich du Sud\",\"ja\":\"サウスジョージア・サウスサンドウィッチ諸島\",\"it\":\"Georgia del Sud e Isole Sandwich Meridionali\",\"cn\":\"南乔治亚\",\"tr\":\"Güney Georgia\"}',-54.50000000,-37.00000000,'','U+1F1EC U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(206,'South Sudan','SSD','728','SS','211','Juba','SSP','South Sudanese pound','£','.ss','South Sudan','Africa','Middle Africa','[{\"zoneName\":\"Africa/Juba\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"남수단\",\"br\":\"Sudão do Sul\",\"pt\":\"Sudão do Sul\",\"nl\":\"Zuid-Soedan\",\"hr\":\"Južni Sudan\",\"fa\":\"سودان جنوبی\",\"de\":\"Südsudan\",\"es\":\"Sudán del Sur\",\"fr\":\"Soudan du Sud\",\"ja\":\"南スーダン\",\"it\":\"Sudan del sud\",\"cn\":\"南苏丹\",\"tr\":\"Güney Sudan\"}',7.00000000,30.00000000,'','U+1F1F8 U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q958'),
(207,'Spain','ESP','724','ES','34','Madrid','EUR','Euro','€','.es','España','Europe','Southern Europe','[{\"zoneName\":\"Africa/Ceuta\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"},{\"zoneName\":\"Atlantic/Canary\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"WET\",\"tzName\":\"Western European Time\"},{\"zoneName\":\"Europe/Madrid\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"스페인\",\"br\":\"Espanha\",\"pt\":\"Espanha\",\"nl\":\"Spanje\",\"hr\":\"Španjolska\",\"fa\":\"اسپانیا\",\"de\":\"Spanien\",\"es\":\"España\",\"fr\":\"Espagne\",\"ja\":\"スペイン\",\"it\":\"Spagna\",\"cn\":\"西班牙\",\"tr\":\"İspanya\"}',40.00000000,-4.00000000,'','U+1F1EA U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q29'),
(208,'Sri Lanka','LKA','144','LK','94','Colombo','LKR','Sri Lankan rupee','Rs','.lk','śrī laṃkāva','Asia','Southern Asia','[{\"zoneName\":\"Asia/Colombo\",\"gmtOffset\":19800,\"gmtOffsetName\":\"UTC+05:30\",\"abbreviation\":\"IST\",\"tzName\":\"Indian Standard Time\"}]','{\"kr\":\"스리랑카\",\"br\":\"Sri Lanka\",\"pt\":\"Sri Lanka\",\"nl\":\"Sri Lanka\",\"hr\":\"Šri Lanka\",\"fa\":\"سری‌لانکا\",\"de\":\"Sri Lanka\",\"es\":\"Sri Lanka\",\"fr\":\"Sri Lanka\",\"ja\":\"スリランカ\",\"it\":\"Sri Lanka\",\"cn\":\"斯里兰卡\",\"tr\":\"Sri Lanka\"}',7.00000000,81.00000000,'','U+1F1F1 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q854'),
(209,'Sudan','SDN','729','SD','249','Khartoum','SDG','Sudanese pound','.س.ج','.sd','السودان','Africa','Northern Africa','[{\"zoneName\":\"Africa/Khartoum\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EAT\",\"tzName\":\"Eastern African Time\"}]','{\"kr\":\"수단\",\"br\":\"Sudão\",\"pt\":\"Sudão\",\"nl\":\"Soedan\",\"hr\":\"Sudan\",\"fa\":\"سودان\",\"de\":\"Sudan\",\"es\":\"Sudán\",\"fr\":\"Soudan\",\"ja\":\"スーダン\",\"it\":\"Sudan\",\"cn\":\"苏丹\",\"tr\":\"Sudan\"}',15.00000000,30.00000000,'','U+1F1F8 U+1F1E9','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1049'),
(210,'Suriname','SUR','740','SR','597','Paramaribo','SRD','Surinamese dollar','$','.sr','Suriname','Americas','South America','[{\"zoneName\":\"America/Paramaribo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"SRT\",\"tzName\":\"Suriname Time\"}]','{\"kr\":\"수리남\",\"br\":\"Suriname\",\"pt\":\"Suriname\",\"nl\":\"Suriname\",\"hr\":\"Surinam\",\"fa\":\"سورینام\",\"de\":\"Suriname\",\"es\":\"Surinam\",\"fr\":\"Surinam\",\"ja\":\"スリナム\",\"it\":\"Suriname\",\"cn\":\"苏里南\",\"tr\":\"Surinam\"}',4.00000000,-56.00000000,'','U+1F1F8 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q730'),
(211,'Svalbard And Jan Mayen Islands','SJM','744','SJ','47','Longyearbyen','NOK','Norwegian Krone','kr','.sj','Svalbard og Jan Mayen','Europe','Northern Europe','[{\"zoneName\":\"Arctic/Longyearbyen\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"스발바르 얀마옌 제도\",\"br\":\"Svalbard\",\"pt\":\"Svalbard\",\"nl\":\"Svalbard en Jan Mayen\",\"hr\":\"Svalbard i Jan Mayen\",\"fa\":\"سوالبارد و یان ماین\",\"de\":\"Svalbard und Jan Mayen\",\"es\":\"Islas Svalbard y Jan Mayen\",\"fr\":\"Svalbard et Jan Mayen\",\"ja\":\"スヴァールバル諸島およびヤンマイエン島\",\"it\":\"Svalbard e Jan Mayen\",\"cn\":\"斯瓦尔巴和扬马延群岛\",\"tr\":\"Svalbard Ve Jan Mayen\"}',78.00000000,20.00000000,'','U+1F1F8 U+1F1EF','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(212,'Swaziland','SWZ','748','SZ','268','Mbabane','SZL','Lilangeni','E','.sz','Swaziland','Africa','Southern Africa','[{\"zoneName\":\"Africa/Mbabane\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"SAST\",\"tzName\":\"South African Standard Time\"}]','{\"kr\":\"에스와티니\",\"br\":\"Suazilândia\",\"pt\":\"Suazilândia\",\"nl\":\"Swaziland\",\"hr\":\"Svazi\",\"fa\":\"سوازیلند\",\"de\":\"Swasiland\",\"es\":\"Suazilandia\",\"fr\":\"Swaziland\",\"ja\":\"スワジランド\",\"it\":\"Swaziland\",\"cn\":\"斯威士兰\",\"tr\":\"Esvatini\"}',-26.50000000,31.50000000,'','U+1F1F8 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1050'),
(213,'Sweden','SWE','752','SE','46','Stockholm','SEK','Swedish krona','kr','.se','Sverige','Europe','Northern Europe','[{\"zoneName\":\"Europe/Stockholm\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"스웨덴\",\"br\":\"Suécia\",\"pt\":\"Suécia\",\"nl\":\"Zweden\",\"hr\":\"Švedska\",\"fa\":\"سوئد\",\"de\":\"Schweden\",\"es\":\"Suecia\",\"fr\":\"Suède\",\"ja\":\"スウェーデン\",\"it\":\"Svezia\",\"cn\":\"瑞典\",\"tr\":\"İsveç\"}',62.00000000,15.00000000,'','U+1F1F8 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q34'),
(214,'Switzerland','CHE','756','CH','41','Bern','CHF','Swiss franc','CHf','.ch','Schweiz','Europe','Western Europe','[{\"zoneName\":\"Europe/Zurich\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"스위스\",\"br\":\"Suíça\",\"pt\":\"Suíça\",\"nl\":\"Zwitserland\",\"hr\":\"Švicarska\",\"fa\":\"سوئیس\",\"de\":\"Schweiz\",\"es\":\"Suiza\",\"fr\":\"Suisse\",\"ja\":\"スイス\",\"it\":\"Svizzera\",\"cn\":\"瑞士\",\"tr\":\"İsviçre\"}',47.00000000,8.00000000,'','U+1F1E8 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q39'),
(215,'Syria','SYR','760','SY','963','Damascus','SYP','Syrian pound','LS','.sy','سوريا','Asia','Western Asia','[{\"zoneName\":\"Asia/Damascus\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"시리아\",\"br\":\"Síria\",\"pt\":\"Síria\",\"nl\":\"Syrië\",\"hr\":\"Sirija\",\"fa\":\"سوریه\",\"de\":\"Syrien\",\"es\":\"Siria\",\"fr\":\"Syrie\",\"ja\":\"シリア・アラブ共和国\",\"it\":\"Siria\",\"cn\":\"叙利亚\",\"tr\":\"Suriye\"}',35.00000000,38.00000000,'','U+1F1F8 U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q858'),
(216,'Taiwan','TWN','158','TW','886','Taipei','TWD','New Taiwan dollar','$','.tw','臺灣','Asia','Eastern Asia','[{\"zoneName\":\"Asia/Taipei\",\"gmtOffset\":28800,\"gmtOffsetName\":\"UTC+08:00\",\"abbreviation\":\"CST\",\"tzName\":\"China Standard Time\"}]','{\"kr\":\"대만\",\"br\":\"Taiwan\",\"pt\":\"Taiwan\",\"nl\":\"Taiwan\",\"hr\":\"Tajvan\",\"fa\":\"تایوان\",\"de\":\"Taiwan\",\"es\":\"Taiwán\",\"fr\":\"Taïwan\",\"ja\":\"台湾（中華民国）\",\"it\":\"Taiwan\",\"cn\":\"中国台湾\",\"tr\":\"Tayvan\"}',23.50000000,121.00000000,'','U+1F1F9 U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q865'),
(217,'Tajikistan','TJK','762','TJ','992','Dushanbe','TJS','Tajikistani somoni','SM','.tj','Тоҷикистон','Asia','Central Asia','[{\"zoneName\":\"Asia/Dushanbe\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TJT\",\"tzName\":\"Tajikistan Time\"}]','{\"kr\":\"타지키스탄\",\"br\":\"Tajiquistão\",\"pt\":\"Tajiquistão\",\"nl\":\"Tadzjikistan\",\"hr\":\"Tađikistan\",\"fa\":\"تاجیکستان\",\"de\":\"Tadschikistan\",\"es\":\"Tayikistán\",\"fr\":\"Tadjikistan\",\"ja\":\"タジキスタン\",\"it\":\"Tagikistan\",\"cn\":\"塔吉克斯坦\",\"tr\":\"Tacikistan\"}',39.00000000,71.00000000,'','U+1F1F9 U+1F1EF','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q863'),
(218,'Tanzania','TZA','834','TZ','255','Dodoma','TZS','Tanzanian shilling','TSh','.tz','Tanzania','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Dar_es_Salaam\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"탄자니아\",\"br\":\"Tanzânia\",\"pt\":\"Tanzânia\",\"nl\":\"Tanzania\",\"hr\":\"Tanzanija\",\"fa\":\"تانزانیا\",\"de\":\"Tansania\",\"es\":\"Tanzania\",\"fr\":\"Tanzanie\",\"ja\":\"タンザニア\",\"it\":\"Tanzania\",\"cn\":\"坦桑尼亚\",\"tr\":\"Tanzanya\"}',-6.00000000,35.00000000,'','U+1F1F9 U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q924'),
(219,'Thailand','THA','764','TH','66','Bangkok','THB','Thai baht','฿','.th','ประเทศไทย','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Bangkok\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]','{\"kr\":\"태국\",\"br\":\"Tailândia\",\"pt\":\"Tailândia\",\"nl\":\"Thailand\",\"hr\":\"Tajland\",\"fa\":\"تایلند\",\"de\":\"Thailand\",\"es\":\"Tailandia\",\"fr\":\"Thaïlande\",\"ja\":\"タイ\",\"it\":\"Tailandia\",\"cn\":\"泰国\",\"tr\":\"Tayland\"}',15.00000000,100.00000000,'','U+1F1F9 U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q869'),
(220,'Togo','TGO','768','TG','228','Lome','XOF','West African CFA franc','CFA','.tg','Togo','Africa','Western Africa','[{\"zoneName\":\"Africa/Lome\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"토고\",\"br\":\"Togo\",\"pt\":\"Togo\",\"nl\":\"Togo\",\"hr\":\"Togo\",\"fa\":\"توگو\",\"de\":\"Togo\",\"es\":\"Togo\",\"fr\":\"Togo\",\"ja\":\"トーゴ\",\"it\":\"Togo\",\"cn\":\"多哥\",\"tr\":\"Togo\"}',8.00000000,1.16666666,'','U+1F1F9 U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q945'),
(221,'Tokelau','TKL','772','TK','690','','NZD','New Zealand dollar','$','.tk','Tokelau','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Fakaofo\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"TKT\",\"tzName\":\"Tokelau Time\"}]','{\"kr\":\"토켈라우\",\"br\":\"Tokelau\",\"pt\":\"Toquelau\",\"nl\":\"Tokelau\",\"hr\":\"Tokelau\",\"fa\":\"توکلائو\",\"de\":\"Tokelau\",\"es\":\"Islas Tokelau\",\"fr\":\"Tokelau\",\"ja\":\"トケラウ\",\"it\":\"Isole Tokelau\",\"cn\":\"托克劳\",\"tr\":\"Tokelau\"}',-9.00000000,-172.00000000,'','U+1F1F9 U+1F1F0','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(222,'Tonga','TON','776','TO','676','Nuku\'alofa','TOP','Tongan paʻanga','$','.to','Tonga','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Tongatapu\",\"gmtOffset\":46800,\"gmtOffsetName\":\"UTC+13:00\",\"abbreviation\":\"TOT\",\"tzName\":\"Tonga Time\"}]','{\"kr\":\"통가\",\"br\":\"Tonga\",\"pt\":\"Tonga\",\"nl\":\"Tonga\",\"hr\":\"Tonga\",\"fa\":\"تونگا\",\"de\":\"Tonga\",\"es\":\"Tonga\",\"fr\":\"Tonga\",\"ja\":\"トンガ\",\"it\":\"Tonga\",\"cn\":\"汤加\",\"tr\":\"Tonga\"}',-20.00000000,-175.00000000,'','U+1F1F9 U+1F1F4','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q678'),
(223,'Trinidad And Tobago','TTO','780','TT','+1-868','Port of Spain','TTD','Trinidad and Tobago dollar','$','.tt','Trinidad and Tobago','Americas','Caribbean','[{\"zoneName\":\"America/Port_of_Spain\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"트리니다드 토바고\",\"br\":\"Trinidad e Tobago\",\"pt\":\"Trindade e Tobago\",\"nl\":\"Trinidad en Tobago\",\"hr\":\"Trinidad i Tobago\",\"fa\":\"ترینیداد و توباگو\",\"de\":\"Trinidad und Tobago\",\"es\":\"Trinidad y Tobago\",\"fr\":\"Trinité et Tobago\",\"ja\":\"トリニダード・トバゴ\",\"it\":\"Trinidad e Tobago\",\"cn\":\"特立尼达和多巴哥\",\"tr\":\"Trinidad Ve Tobago\"}',11.00000000,-61.00000000,'','U+1F1F9 U+1F1F9','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q754'),
(224,'Tunisia','TUN','788','TN','216','Tunis','TND','Tunisian dinar','ت.د','.tn','تونس','Africa','Northern Africa','[{\"zoneName\":\"Africa/Tunis\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"튀니지\",\"br\":\"Tunísia\",\"pt\":\"Tunísia\",\"nl\":\"Tunesië\",\"hr\":\"Tunis\",\"fa\":\"تونس\",\"de\":\"Tunesien\",\"es\":\"Túnez\",\"fr\":\"Tunisie\",\"ja\":\"チュニジア\",\"it\":\"Tunisia\",\"cn\":\"突尼斯\",\"tr\":\"Tunus\"}',34.00000000,9.00000000,'','U+1F1F9 U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q948'),
(225,'Turkey','TUR','792','TR','90','Ankara','TRY','Turkish lira','₺','.tr','Türkiye','Asia','Western Asia','[{\"zoneName\":\"Europe/Istanbul\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"터키\",\"br\":\"Turquia\",\"pt\":\"Turquia\",\"nl\":\"Turkije\",\"hr\":\"Turska\",\"fa\":\"ترکیه\",\"de\":\"Türkei\",\"es\":\"Turquía\",\"fr\":\"Turquie\",\"ja\":\"トルコ\",\"it\":\"Turchia\",\"cn\":\"土耳其\",\"tr\":\"Türkiye\"}',39.00000000,35.00000000,'','U+1F1F9 U+1F1F7','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q43'),
(226,'Turkmenistan','TKM','795','TM','993','Ashgabat','TMT','Turkmenistan manat','T','.tm','Türkmenistan','Asia','Central Asia','[{\"zoneName\":\"Asia/Ashgabat\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"TMT\",\"tzName\":\"Turkmenistan Time\"}]','{\"kr\":\"투르크메니스탄\",\"br\":\"Turcomenistão\",\"pt\":\"Turquemenistão\",\"nl\":\"Turkmenistan\",\"hr\":\"Turkmenistan\",\"fa\":\"ترکمنستان\",\"de\":\"Turkmenistan\",\"es\":\"Turkmenistán\",\"fr\":\"Turkménistan\",\"ja\":\"トルクメニスタン\",\"it\":\"Turkmenistan\",\"cn\":\"土库曼斯坦\",\"tr\":\"Türkmenistan\"}',40.00000000,60.00000000,'','U+1F1F9 U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q874'),
(227,'Turks And Caicos Islands','TCA','796','TC','+1-649','Cockburn Town','USD','United States dollar','$','.tc','Turks and Caicos Islands','Americas','Caribbean','[{\"zoneName\":\"America/Grand_Turk\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"}]','{\"kr\":\"터크스 케이커스 제도\",\"br\":\"Ilhas Turcas e Caicos\",\"pt\":\"Ilhas Turcas e Caicos\",\"nl\":\"Turks- en Caicoseilanden\",\"hr\":\"Otoci Turks i Caicos\",\"fa\":\"جزایر تورکس و کایکوس\",\"de\":\"Turks- und Caicosinseln\",\"es\":\"Islas Turks y Caicos\",\"fr\":\"Îles Turques-et-Caïques\",\"ja\":\"タークス・カイコス諸島\",\"it\":\"Isole Turks e Caicos\",\"cn\":\"特克斯和凯科斯群岛\",\"tr\":\"Turks Ve Caicos Adalari\"}',21.75000000,-71.58333333,'','U+1F1F9 U+1F1E8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(228,'Tuvalu','TUV','798','TV','688','Funafuti','AUD','Australian dollar','$','.tv','Tuvalu','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Funafuti\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"TVT\",\"tzName\":\"Tuvalu Time\"}]','{\"kr\":\"투발루\",\"br\":\"Tuvalu\",\"pt\":\"Tuvalu\",\"nl\":\"Tuvalu\",\"hr\":\"Tuvalu\",\"fa\":\"تووالو\",\"de\":\"Tuvalu\",\"es\":\"Tuvalu\",\"fr\":\"Tuvalu\",\"ja\":\"ツバル\",\"it\":\"Tuvalu\",\"cn\":\"图瓦卢\",\"tr\":\"Tuvalu\"}',-8.00000000,178.00000000,'','U+1F1F9 U+1F1FB','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q672'),
(229,'Uganda','UGA','800','UG','256','Kampala','UGX','Ugandan shilling','USh','.ug','Uganda','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Kampala\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"EAT\",\"tzName\":\"East Africa Time\"}]','{\"kr\":\"우간다\",\"br\":\"Uganda\",\"pt\":\"Uganda\",\"nl\":\"Oeganda\",\"hr\":\"Uganda\",\"fa\":\"اوگاندا\",\"de\":\"Uganda\",\"es\":\"Uganda\",\"fr\":\"Uganda\",\"ja\":\"ウガンダ\",\"it\":\"Uganda\",\"cn\":\"乌干达\",\"tr\":\"Uganda\"}',1.00000000,32.00000000,'','U+1F1FA U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q1036'),
(230,'Ukraine','UKR','804','UA','380','Kiev','UAH','Ukrainian hryvnia','₴','.ua','Україна','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Kiev\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Simferopol\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"MSK\",\"tzName\":\"Moscow Time\"},{\"zoneName\":\"Europe/Uzhgorod\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"},{\"zoneName\":\"Europe/Zaporozhye\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"EET\",\"tzName\":\"Eastern European Time\"}]','{\"kr\":\"우크라이나\",\"br\":\"Ucrânia\",\"pt\":\"Ucrânia\",\"nl\":\"Oekraïne\",\"hr\":\"Ukrajina\",\"fa\":\"وکراین\",\"de\":\"Ukraine\",\"es\":\"Ucrania\",\"fr\":\"Ukraine\",\"ja\":\"ウクライナ\",\"it\":\"Ucraina\",\"cn\":\"乌克兰\",\"tr\":\"Ukrayna\"}',49.00000000,32.00000000,'','U+1F1FA U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q212'),
(231,'United Arab Emirates','ARE','784','AE','971','Abu Dhabi','AED','United Arab Emirates dirham','إ.د','.ae','دولة الإمارات العربية المتحدة','Asia','Western Asia','[{\"zoneName\":\"Asia/Dubai\",\"gmtOffset\":14400,\"gmtOffsetName\":\"UTC+04:00\",\"abbreviation\":\"GST\",\"tzName\":\"Gulf Standard Time\"}]','{\"kr\":\"아랍에미리트\",\"br\":\"Emirados árabes Unidos\",\"pt\":\"Emirados árabes Unidos\",\"nl\":\"Verenigde Arabische Emiraten\",\"hr\":\"Ujedinjeni Arapski Emirati\",\"fa\":\"امارات متحده عربی\",\"de\":\"Vereinigte Arabische Emirate\",\"es\":\"Emiratos Árabes Unidos\",\"fr\":\"Émirats arabes unis\",\"ja\":\"アラブ首長国連邦\",\"it\":\"Emirati Arabi Uniti\",\"cn\":\"阿拉伯联合酋长国\",\"tr\":\"Birleşik Arap Emirlikleri\"}',24.00000000,54.00000000,'','U+1F1E6 U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q878'),
(232,'United Kingdom','GBR','826','GB','44','London','GBP','British pound','£','.uk','United Kingdom','Europe','Northern Europe','[{\"zoneName\":\"Europe/London\",\"gmtOffset\":0,\"gmtOffsetName\":\"UTC±00\",\"abbreviation\":\"GMT\",\"tzName\":\"Greenwich Mean Time\"}]','{\"kr\":\"영국\",\"br\":\"Reino Unido\",\"pt\":\"Reino Unido\",\"nl\":\"Verenigd Koninkrijk\",\"hr\":\"Ujedinjeno Kraljevstvo\",\"fa\":\"بریتانیای کبیر و ایرلند شمالی\",\"de\":\"Vereinigtes Königreich\",\"es\":\"Reino Unido\",\"fr\":\"Royaume-Uni\",\"ja\":\"イギリス\",\"it\":\"Regno Unito\",\"cn\":\"英国\",\"tr\":\"Birleşik Krallik\"}',54.00000000,-2.00000000,'','U+1F1EC U+1F1E7','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q145'),
(233,'United States','USA','840','US','1','Washington','USD','United States dollar','$','.us','United States','Americas','Northern America','[{\"zoneName\":\"America/Adak\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"HST\",\"tzName\":\"Hawaii–Aleutian Standard Time\"},{\"zoneName\":\"America/Anchorage\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Boise\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Chicago\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Denver\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Detroit\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Indianapolis\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Knox\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Marengo\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Petersburg\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Tell_City\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Vevay\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Vincennes\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Indiana/Winamac\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Juneau\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Kentucky/Louisville\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Kentucky/Monticello\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Los_Angeles\",\"gmtOffset\":-28800,\"gmtOffsetName\":\"UTC-08:00\",\"abbreviation\":\"PST\",\"tzName\":\"Pacific Standard Time (North America\"},{\"zoneName\":\"America/Menominee\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Metlakatla\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/New_York\",\"gmtOffset\":-18000,\"gmtOffsetName\":\"UTC-05:00\",\"abbreviation\":\"EST\",\"tzName\":\"Eastern Standard Time (North America\"},{\"zoneName\":\"America/Nome\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/North_Dakota/Beulah\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/North_Dakota/Center\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/North_Dakota/New_Salem\",\"gmtOffset\":-21600,\"gmtOffsetName\":\"UTC-06:00\",\"abbreviation\":\"CST\",\"tzName\":\"Central Standard Time (North America\"},{\"zoneName\":\"America/Phoenix\",\"gmtOffset\":-25200,\"gmtOffsetName\":\"UTC-07:00\",\"abbreviation\":\"MST\",\"tzName\":\"Mountain Standard Time (North America\"},{\"zoneName\":\"America/Sitka\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"America/Yakutat\",\"gmtOffset\":-32400,\"gmtOffsetName\":\"UTC-09:00\",\"abbreviation\":\"AKST\",\"tzName\":\"Alaska Standard Time\"},{\"zoneName\":\"Pacific/Honolulu\",\"gmtOffset\":-36000,\"gmtOffsetName\":\"UTC-10:00\",\"abbreviation\":\"HST\",\"tzName\":\"Hawaii–Aleutian Standard Time\"}]','{\"kr\":\"미국\",\"br\":\"Estados Unidos\",\"pt\":\"Estados Unidos\",\"nl\":\"Verenigde Staten\",\"hr\":\"Sjedinjene Američke Države\",\"fa\":\"ایالات متحده آمریکا\",\"de\":\"Vereinigte Staaten von Amerika\",\"es\":\"Estados Unidos\",\"fr\":\"États-Unis\",\"ja\":\"アメリカ合衆国\",\"it\":\"Stati Uniti D\'America\",\"cn\":\"美国\",\"tr\":\"Amerika\"}',38.00000000,-97.00000000,'','U+1F1FA U+1F1F8','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q30'),
(234,'United States Minor Outlying Islands','UMI','581','UM','1','','USD','United States dollar','$','.us','United States Minor Outlying Islands','Americas','Northern America','[{\"zoneName\":\"Pacific/Midway\",\"gmtOffset\":-39600,\"gmtOffsetName\":\"UTC-11:00\",\"abbreviation\":\"SST\",\"tzName\":\"Samoa Standard Time\"},{\"zoneName\":\"Pacific/Wake\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"WAKT\",\"tzName\":\"Wake Island Time\"}]','{\"kr\":\"미국령 군소 제도\",\"br\":\"Ilhas Menores Distantes dos Estados Unidos\",\"pt\":\"Ilhas Menores Distantes dos Estados Unidos\",\"nl\":\"Kleine afgelegen eilanden van de Verenigde Staten\",\"hr\":\"Mali udaljeni otoci SAD-a\",\"fa\":\"جزایر کوچک حاشیه‌ای ایالات متحده آمریکا\",\"de\":\"Kleinere Inselbesitzungen der Vereinigten Staaten\",\"es\":\"Islas Ultramarinas Menores de Estados Unidos\",\"fr\":\"Îles mineures éloignées des États-Unis\",\"ja\":\"合衆国領有小離島\",\"it\":\"Isole minori esterne degli Stati Uniti d\'America\",\"cn\":\"美国本土外小岛屿\",\"tr\":\"Abd Küçük Harici Adalari\"}',0.00000000,0.00000000,'','U+1F1FA U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(235,'Uruguay','URY','858','UY','598','Montevideo','UYU','Uruguayan peso','$','.uy','Uruguay','Americas','South America','[{\"zoneName\":\"America/Montevideo\",\"gmtOffset\":-10800,\"gmtOffsetName\":\"UTC-03:00\",\"abbreviation\":\"UYT\",\"tzName\":\"Uruguay Standard Time\"}]','{\"kr\":\"우루과이\",\"br\":\"Uruguai\",\"pt\":\"Uruguai\",\"nl\":\"Uruguay\",\"hr\":\"Urugvaj\",\"fa\":\"اروگوئه\",\"de\":\"Uruguay\",\"es\":\"Uruguay\",\"fr\":\"Uruguay\",\"ja\":\"ウルグアイ\",\"it\":\"Uruguay\",\"cn\":\"乌拉圭\",\"tr\":\"Uruguay\"}',-33.00000000,-56.00000000,'','U+1F1FA U+1F1FE','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q77'),
(236,'Uzbekistan','UZB','860','UZ','998','Tashkent','UZS','Uzbekistani soʻm','лв','.uz','O‘zbekiston','Asia','Central Asia','[{\"zoneName\":\"Asia/Samarkand\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"UZT\",\"tzName\":\"Uzbekistan Time\"},{\"zoneName\":\"Asia/Tashkent\",\"gmtOffset\":18000,\"gmtOffsetName\":\"UTC+05:00\",\"abbreviation\":\"UZT\",\"tzName\":\"Uzbekistan Time\"}]','{\"kr\":\"우즈베키스탄\",\"br\":\"Uzbequistão\",\"pt\":\"Usbequistão\",\"nl\":\"Oezbekistan\",\"hr\":\"Uzbekistan\",\"fa\":\"ازبکستان\",\"de\":\"Usbekistan\",\"es\":\"Uzbekistán\",\"fr\":\"Ouzbékistan\",\"ja\":\"ウズベキスタン\",\"it\":\"Uzbekistan\",\"cn\":\"乌兹别克斯坦\",\"tr\":\"Özbekistan\"}',41.00000000,64.00000000,'','U+1F1FA U+1F1FF','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q265'),
(237,'Vanuatu','VUT','548','VU','678','Port Vila','VUV','Vanuatu vatu','VT','.vu','Vanuatu','Oceania','Melanesia','[{\"zoneName\":\"Pacific/Efate\",\"gmtOffset\":39600,\"gmtOffsetName\":\"UTC+11:00\",\"abbreviation\":\"VUT\",\"tzName\":\"Vanuatu Time\"}]','{\"kr\":\"바누아투\",\"br\":\"Vanuatu\",\"pt\":\"Vanuatu\",\"nl\":\"Vanuatu\",\"hr\":\"Vanuatu\",\"fa\":\"وانواتو\",\"de\":\"Vanuatu\",\"es\":\"Vanuatu\",\"fr\":\"Vanuatu\",\"ja\":\"バヌアツ\",\"it\":\"Vanuatu\",\"cn\":\"瓦努阿图\",\"tr\":\"Vanuatu\"}',-16.00000000,167.00000000,'','U+1F1FB U+1F1FA','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q686'),
(238,'Vatican City State (Holy See)','VAT','336','VA','379','Vatican City','EUR','Euro','€','.va','Vaticano','Europe','Southern Europe','[{\"zoneName\":\"Europe/Vatican\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"바티칸 시국\",\"br\":\"Vaticano\",\"pt\":\"Vaticano\",\"nl\":\"Heilige Stoel\",\"hr\":\"Sveta Stolica\",\"fa\":\"سریر مقدس\",\"de\":\"Heiliger Stuhl\",\"es\":\"Santa Sede\",\"fr\":\"voir Saint\",\"ja\":\"聖座\",\"it\":\"Santa Sede\",\"cn\":\"梵蒂冈\",\"tr\":\"Vatikan\"}',41.90000000,12.45000000,'','U+1F1FB U+1F1E6','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q237'),
(239,'Venezuela','VEN','862','VE','58','Caracas','VEF','Bolívar','Bs','.ve','Venezuela','Americas','South America','[{\"zoneName\":\"America/Caracas\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"VET\",\"tzName\":\"Venezuelan Standard Time\"}]','{\"kr\":\"베네수엘라\",\"br\":\"Venezuela\",\"pt\":\"Venezuela\",\"nl\":\"Venezuela\",\"hr\":\"Venezuela\",\"fa\":\"ونزوئلا\",\"de\":\"Venezuela\",\"es\":\"Venezuela\",\"fr\":\"Venezuela\",\"ja\":\"ベネズエラ・ボリバル共和国\",\"it\":\"Venezuela\",\"cn\":\"委内瑞拉\",\"tr\":\"Venezuela\"}',8.00000000,-66.00000000,'','U+1F1FB U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q717'),
(240,'Vietnam','VNM','704','VN','84','Hanoi','VND','Vietnamese đồng','₫','.vn','Việt Nam','Asia','South-Eastern Asia','[{\"zoneName\":\"Asia/Ho_Chi_Minh\",\"gmtOffset\":25200,\"gmtOffsetName\":\"UTC+07:00\",\"abbreviation\":\"ICT\",\"tzName\":\"Indochina Time\"}]','{\"kr\":\"베트남\",\"br\":\"Vietnã\",\"pt\":\"Vietname\",\"nl\":\"Vietnam\",\"hr\":\"Vijetnam\",\"fa\":\"ویتنام\",\"de\":\"Vietnam\",\"es\":\"Vietnam\",\"fr\":\"Viêt Nam\",\"ja\":\"ベトナム\",\"it\":\"Vietnam\",\"cn\":\"越南\",\"tr\":\"Vietnam\"}',16.16666666,107.83333333,'','U+1F1FB U+1F1F3','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q881'),
(241,'Virgin Islands (British)','VGB','092','VG','+1-284','Road Town','USD','United States dollar','$','.vg','British Virgin Islands','Americas','Caribbean','[{\"zoneName\":\"America/Tortola\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"영국령 버진아일랜드\",\"br\":\"Ilhas Virgens Britânicas\",\"pt\":\"Ilhas Virgens Britânicas\",\"nl\":\"Britse Maagdeneilanden\",\"hr\":\"Britanski Djevičanski Otoci\",\"fa\":\"جزایر ویرجین بریتانیا\",\"de\":\"Britische Jungferninseln\",\"es\":\"Islas Vírgenes del Reino Unido\",\"fr\":\"Îles Vierges britanniques\",\"ja\":\"イギリス領ヴァージン諸島\",\"it\":\"Isole Vergini Britanniche\",\"cn\":\"圣文森特和格林纳丁斯\",\"tr\":\"Britanya Virjin Adalari\"}',18.43138300,-64.62305000,'','U+1F1FB U+1F1EC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(242,'Virgin Islands (US)','VIR','850','VI','+1-340','Charlotte Amalie','USD','United States dollar','$','.vi','United States Virgin Islands','Americas','Caribbean','[{\"zoneName\":\"America/St_Thomas\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"미국령 버진아일랜드\",\"br\":\"Ilhas Virgens Americanas\",\"pt\":\"Ilhas Virgens Americanas\",\"nl\":\"Verenigde Staten Maagdeneilanden\",\"fa\":\"جزایر ویرجین آمریکا\",\"de\":\"Amerikanische Jungferninseln\",\"es\":\"Islas Vírgenes de los Estados Unidos\",\"fr\":\"Îles Vierges des États-Unis\",\"ja\":\"アメリカ領ヴァージン諸島\",\"it\":\"Isole Vergini americane\",\"cn\":\"维尔京群岛（美国）\",\"tr\":\"Abd Virjin Adalari\"}',18.34000000,-64.93000000,'','U+1F1FB U+1F1EE','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(243,'Wallis And Futuna Islands','WLF','876','WF','681','Mata Utu','XPF','CFP franc','₣','.wf','Wallis et Futuna','Oceania','Polynesia','[{\"zoneName\":\"Pacific/Wallis\",\"gmtOffset\":43200,\"gmtOffsetName\":\"UTC+12:00\",\"abbreviation\":\"WFT\",\"tzName\":\"Wallis & Futuna Time\"}]','{\"kr\":\"왈리스 푸투나\",\"br\":\"Wallis e Futuna\",\"pt\":\"Wallis e Futuna\",\"nl\":\"Wallis en Futuna\",\"hr\":\"Wallis i Fortuna\",\"fa\":\"والیس و فوتونا\",\"de\":\"Wallis und Futuna\",\"es\":\"Wallis y Futuna\",\"fr\":\"Wallis-et-Futuna\",\"ja\":\"ウォリス・フツナ\",\"it\":\"Wallis e Futuna\",\"cn\":\"瓦利斯群岛和富图纳群岛\",\"tr\":\"Wallis Ve Futuna\"}',-13.30000000,-176.20000000,'','U+1F1FC U+1F1EB','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(244,'Western Sahara','ESH','732','EH','212','El-Aaiun','MAD','Moroccan Dirham','MAD','.eh','الصحراء الغربية','Africa','Northern Africa','[{\"zoneName\":\"Africa/El_Aaiun\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"WEST\",\"tzName\":\"Western European Summer Time\"}]','{\"kr\":\"서사하라\",\"br\":\"Saara Ocidental\",\"pt\":\"Saara Ocidental\",\"nl\":\"Westelijke Sahara\",\"hr\":\"Zapadna Sahara\",\"fa\":\"جمهوری دموکراتیک عربی صحرا\",\"de\":\"Westsahara\",\"es\":\"Sahara Occidental\",\"fr\":\"Sahara Occidental\",\"ja\":\"西サハラ\",\"it\":\"Sahara Occidentale\",\"cn\":\"西撒哈拉\",\"tr\":\"Bati Sahra\"}',24.50000000,-13.00000000,'','U+1F1EA U+1F1ED','2018-07-21 01:11:03','2022-05-21 15:39:27',1,NULL),
(245,'Yemen','YEM','887','YE','967','Sanaa','YER','Yemeni rial','﷼','.ye','اليَمَن','Asia','Western Asia','[{\"zoneName\":\"Asia/Aden\",\"gmtOffset\":10800,\"gmtOffsetName\":\"UTC+03:00\",\"abbreviation\":\"AST\",\"tzName\":\"Arabia Standard Time\"}]','{\"kr\":\"예멘\",\"br\":\"Iêmen\",\"pt\":\"Iémen\",\"nl\":\"Jemen\",\"hr\":\"Jemen\",\"fa\":\"یمن\",\"de\":\"Jemen\",\"es\":\"Yemen\",\"fr\":\"Yémen\",\"ja\":\"イエメン\",\"it\":\"Yemen\",\"cn\":\"也门\",\"tr\":\"Yemen\"}',15.00000000,48.00000000,'','U+1F1FE U+1F1EA','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q805'),
(246,'Zambia','ZMB','894','ZM','260','Lusaka','ZMW','Zambian kwacha','ZK','.zm','Zambia','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Lusaka\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"잠비아\",\"br\":\"Zâmbia\",\"pt\":\"Zâmbia\",\"nl\":\"Zambia\",\"hr\":\"Zambija\",\"fa\":\"زامبیا\",\"de\":\"Sambia\",\"es\":\"Zambia\",\"fr\":\"Zambie\",\"ja\":\"ザンビア\",\"it\":\"Zambia\",\"cn\":\"赞比亚\",\"tr\":\"Zambiya\"}',-15.00000000,30.00000000,'','U+1F1FF U+1F1F2','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q953'),
(247,'Zimbabwe','ZWE','716','ZW','263','Harare','ZWL','Zimbabwe Dollar','$','.zw','Zimbabwe','Africa','Eastern Africa','[{\"zoneName\":\"Africa/Harare\",\"gmtOffset\":7200,\"gmtOffsetName\":\"UTC+02:00\",\"abbreviation\":\"CAT\",\"tzName\":\"Central Africa Time\"}]','{\"kr\":\"짐바브웨\",\"br\":\"Zimbabwe\",\"pt\":\"Zimbabué\",\"nl\":\"Zimbabwe\",\"hr\":\"Zimbabve\",\"fa\":\"زیمباوه\",\"de\":\"Simbabwe\",\"es\":\"Zimbabue\",\"fr\":\"Zimbabwe\",\"ja\":\"ジンバブエ\",\"it\":\"Zimbabwe\",\"cn\":\"津巴布韦\",\"tr\":\"Zimbabve\"}',-20.00000000,30.00000000,'','U+1F1FF U+1F1FC','2018-07-21 01:11:03','2022-05-21 15:39:27',1,'Q954'),
(248,'Kosovo','XKX','926','XK','383','Pristina','EUR','Euro','€','.xk','Republika e Kosovës','Europe','Eastern Europe','[{\"zoneName\":\"Europe/Belgrade\",\"gmtOffset\":3600,\"gmtOffsetName\":\"UTC+01:00\",\"abbreviation\":\"CET\",\"tzName\":\"Central European Time\"}]','{\"kr\":\"코소보\",\"cn\":\"科索沃\",\"tr\":\"Kosova\"}',42.56129090,20.34030350,'','U+1F1FD U+1F1F0','2020-08-15 20:33:50','2022-05-21 15:39:27',1,'Q1246'),
(249,'Curaçao','CUW','531','CW','599','Willemstad','ANG','Netherlands Antillean guilder','ƒ','.cw','Curaçao','Americas','Caribbean','[{\"zoneName\":\"America/Curacao\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"퀴라소\",\"br\":\"Curaçao\",\"pt\":\"Curaçao\",\"nl\":\"Curaçao\",\"fa\":\"کوراسائو\",\"de\":\"Curaçao\",\"fr\":\"Curaçao\",\"it\":\"Curaçao\",\"cn\":\"库拉索\",\"tr\":\"Curaçao\"}',12.11666700,-68.93333300,'','U+1F1E8 U+1F1FC','2020-10-25 19:54:20','2022-05-21 15:39:27',1,'Q25279'),
(250,'Sint Maarten (Dutch part)','SXM','534','SX','1721','Philipsburg','ANG','Netherlands Antillean guilder','ƒ','.sx','Sint Maarten','Americas','Caribbean','[{\"zoneName\":\"America/Anguilla\",\"gmtOffset\":-14400,\"gmtOffsetName\":\"UTC-04:00\",\"abbreviation\":\"AST\",\"tzName\":\"Atlantic Standard Time\"}]','{\"kr\":\"신트마르턴\",\"br\":\"Sint Maarten\",\"pt\":\"São Martinho\",\"nl\":\"Sint Maarten\",\"fa\":\"سینت مارتن\",\"de\":\"Sint Maarten (niederl. Teil)\",\"fr\":\"Saint Martin (partie néerlandaise)\",\"it\":\"Saint Martin (parte olandese)\",\"cn\":\"圣马丁岛（荷兰部分）\",\"tr\":\"Sint Maarten\"}',18.03333300,-63.05000000,'','U+1F1F8 U+1F1FD','2020-12-05 18:03:39','2022-05-21 15:39:27',1,'Q26273');
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `coupons`
--

DROP TABLE IF EXISTS `coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `coupons` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  `events` varchar(255) DEFAULT NULL,
  `start_date` varchar(255) NOT NULL,
  `end_date` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `coupons`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `coupons` WRITE;
/*!40000 ALTER TABLE `coupons` DISABLE KEYS */;
INSERT INTO `coupons` VALUES
(8,'GUEST','guestlist','percentage','100','[\"135\"]','2025-12-28','2026-01-01','2025-12-29 01:16:57','2025-12-29 01:16:57');
/*!40000 ALTER TABLE `coupons` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
  `provider` varchar(255) DEFAULT NULL,
  `provider_id` varchar(255) DEFAULT NULL,
  `firebase_uid` varchar(255) DEFAULT NULL,
  `fname` varchar(255) NOT NULL,
  `lname` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `is_private` tinyint(1) NOT NULL DEFAULT 0,
  `email_verified_at` varchar(255) DEFAULT NULL,
  `verification_token` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `phone_verified_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=185 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES
(43,NULL,NULL,NULL,NULL,'Giancarlos','Valdez','gian@monkey.com.do','gianvald','699602cfbbc0a.jpeg',NULL,'8493538839','Calle 1','Republica Dominicana',NULL,'Santo Domingo',NULL,'$2y$10$9.bm/AF16ExwriOd/CjFJOCAzLSjWPfhDfLZk.tFkuQ7gY77NVft6',1,0,'2025-12-06 03:22:52',NULL,'2025-12-06 05:35:28','2026-02-18 18:19:59',NULL),
(44,NULL,NULL,NULL,NULL,'Davila Esperanza','Paulino Ramos','daavilaramos@gmail.com','davila',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$O4od7awIRFwRYvWj5cVETOoIZHqOpjLyE4s43zZ3uM/5NmCdKOVvG',1,0,'2025-12-15 12:28:31',NULL,'2025-12-15 16:25:05','2026-01-03 02:58:49',NULL),
(45,NULL,NULL,NULL,NULL,'Milauri','Paulino','milipaulino4@gmail.com','Venicebxtch20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$PqRyx61/CGBY0TQkkLoG6.jh8r.y2l9oDmZom1kAs.uIJDvlJmbDm',1,0,'2025-12-16 15:38:39',NULL,'2025-12-16 19:38:14','2025-12-16 19:38:39',NULL),
(46,NULL,NULL,NULL,NULL,'Adrian','Torres','adrian50-50@hotmail.com','PilitaDobleA',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$hTZNth5zmkQLbBeaD1ftn.AK4D8KUpfHSJ70e51dBPuR8Gsuj42OS',1,0,'2025-12-16 15:54:07',NULL,'2025-12-16 19:52:58','2025-12-16 19:54:07',NULL),
(47,NULL,NULL,NULL,NULL,'Dilencio','Vargas','dilenciovarlirz@gmail.com','dilencioangel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$V9ze2Uj1SazRcrYU7OhXaefn9/Hafp.p6YPI6Rkl0ipKhGHwVKy8W',1,0,'2025-12-16 21:08:24',NULL,'2025-12-17 01:07:27','2025-12-17 01:08:24',NULL),
(48,NULL,NULL,NULL,NULL,'Jeffrey','Ynoa','jeeffydn@gmail.com','Kamaru',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$WRk8YvOSxVNPxGxxuVwc5uAlzTFv4.M2/6lfAgCPP14/WJuw6kXDa',1,0,'2025-12-16 19:39:55',NULL,'2025-12-16 23:39:45','2026-01-03 03:08:19',NULL),
(49,NULL,NULL,NULL,NULL,'Edgar','Garcia','edgar255075@gmail.com','Eddddd25',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$3OReZpDPOrJPWjTP8ZtfVeQDFTD0.gRg3l66LJQY87acS3LX7uqyG',1,0,'2025-12-20 20:04:36',NULL,'2025-12-21 00:03:20','2025-12-21 00:04:36',NULL),
(50,NULL,NULL,NULL,NULL,'Juan Diego Perez','De Los Santos','juandiego05@gmail.com','juandiego05',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$JnRp7q1nfApzoZ1UJE1bQuamuV8QCWZ5KoSZtoChdYBFOtUOXlNoe',1,0,'2025-12-26 16:52:18',NULL,'2025-12-26 20:51:58','2025-12-26 20:52:18',NULL),
(51,NULL,NULL,NULL,NULL,'Ivan','Noboa','ivan.noboa@gmail.com','ivannoboa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$d3MTcEvfMQMMfcMtQ4RIL.CPu66Icyxof04qEGneXvjpCZ5ifkUO6',1,0,'2025-12-27 17:16:00',NULL,'2025-12-27 21:15:46','2025-12-27 21:16:00',NULL),
(52,NULL,NULL,NULL,NULL,'Erick','Benjamín','erick.benjamin.leon@gmail.com','Peluche',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$jC936d4rOggS9SFUm2n3v.TqYxhXYtXbbFRoGfDu1n1fUUhGEPtAu',1,0,'2025-12-28 20:42:42',NULL,'2025-12-29 00:42:24','2025-12-29 00:42:42',NULL),
(53,NULL,NULL,NULL,NULL,'Maxwell','Morrison','maxflips16@gmail.com','Maxflips16',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$Y/38JpPfiLY4HlyCjEvLg.dfgrVuGrKIguXPMBRCmgxGaiqiWK3g2',1,0,'2025-12-30 21:15:32',NULL,'2025-12-31 01:08:45','2025-12-31 01:15:32',NULL),
(54,NULL,NULL,NULL,NULL,'Jeremy','Caro','espiritado.innato9j@icloud.com','jrmycr',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$miTVJZInvgXak.eKLSUA2ePUYBDxQAR6mOWVn430fufSWviCVxVgG',1,0,'2025-12-31 07:45:24',NULL,'2025-12-31 11:45:05','2025-12-31 11:45:24',NULL),
(55,NULL,NULL,NULL,NULL,'Victor','Hurtado','victor.hurtadomena@gmail.com','victorhurtado',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$9VI8ZEBKu0Eza.9ygYILauJgz2tGBfYTBXDy72RwSfcSVcuTIYlL.',1,0,'2025-12-31 09:26:09',NULL,'2025-12-31 13:25:54','2025-12-31 13:26:09',NULL),
(56,NULL,NULL,NULL,NULL,'Martina','Occhi','martina.occhi2@unibo.it','Martiocchi',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$gwDvub.ZdM1Mnbksna..Cez674/WmB22OSvHKlU69WNw3WoSsWm.y',1,0,'2025-12-31 09:47:56',NULL,'2025-12-31 13:47:39','2025-12-31 13:47:56',NULL),
(57,NULL,NULL,NULL,NULL,'Junior','Santana','juniorwkx@gmail.com','Robwkx',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$VnzfHWbSZjAJ8TPb4SOZIOPiHWNyN5iYRs585dI1nWpZasyCWsZPC',1,0,'2025-12-31 11:03:16',NULL,'2025-12-31 15:02:48','2025-12-31 15:07:04',NULL),
(58,NULL,NULL,NULL,NULL,'Ramses','Sultan','suhl.tnbookings@gmail.com','beatbysultan',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$w1GMloQ1Jm42yIjdT3DtxegAnvhrnbwpEgYPdyvJUPTQKTM6Powte',1,0,'2025-12-31 11:21:24',NULL,'2025-12-31 15:20:49','2025-12-31 15:21:24',NULL),
(59,NULL,NULL,NULL,NULL,'Yamilet J.','Terrero Batista','yamilettb20@gmail.com','Yjam',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$eD7y8grv.totRHUabXB7V.Lqtzz8S7moosIAuEDxQJk8CPFwwxat6',1,0,'2025-12-31 12:40:28',NULL,'2025-12-31 16:40:11','2025-12-31 16:40:28',NULL),
(60,NULL,NULL,NULL,NULL,'Alberto','Parada','saulalbertoparada@gmail.com','Albertoparada',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$9ZC6LwNXP0XOOWR9TTtbCeVtaZETQO9FXzCF3UpkrCdGhtDqUpWcK',1,0,'2025-12-31 12:58:56',NULL,'2025-12-31 16:58:30','2025-12-31 16:58:56',NULL),
(61,NULL,NULL,NULL,NULL,'Christ Austin','Lamour','Christaustinlamour@gmail.com','Tovsky',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$cdqcxZw1ePoSABbKbnQZyOe1C4iAybMuhVt2ox3QSNeiKpMH9LJPW',1,0,'2025-12-31 13:50:21',NULL,'2025-12-31 17:48:36','2025-12-31 17:50:21',NULL),
(62,NULL,NULL,NULL,NULL,'Génesis','Blanco','genesisvanessablanco@gmail.com','Genesis31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$ap8Dyli0qs8OXY5YUythce6OrI/kqQQRnV6OiWR9EnlnNpB8Xw8xK',1,0,'2025-12-31 14:27:19',NULL,'2025-12-31 18:26:38','2025-12-31 18:27:19',NULL),
(63,NULL,NULL,NULL,NULL,'Braulio','Paulino','braulioap1998@gmail.com','Gonter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$sPTDFl2u/3tLJJf49orTiufHR4teSZIrv7tZSBKBd1hpJvuMrRWHO',1,0,'2025-12-31 16:30:31',NULL,'2025-12-31 20:30:01','2025-12-31 20:30:31',NULL),
(64,NULL,NULL,NULL,NULL,'Joel','Morillo','daesolucioneselectro@gmail.com','joelmorillo2319',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$jf9OD7BT5n1kUD0UFwcSiOaJ9katnqxrMCl/jcgpGJfVHVJYUbn/O',1,0,'2025-12-31 18:35:57',NULL,'2025-12-31 22:32:17','2026-01-03 16:51:51',NULL),
(65,NULL,NULL,NULL,NULL,'Roy','van der Steen','royvandersteen82@gmail.com','Roys',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$ByvP0swFTanKh7x89Ca64eG0aeTaE3/ismee.w/ejwp9icqASqP62',1,0,'2025-12-31 18:36:03',NULL,'2025-12-31 22:35:53','2025-12-31 22:36:03',NULL),
(66,NULL,NULL,NULL,NULL,'caleb','deriel','jonathanjoestar775@hotmail.com','calebderi',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$gX4Qkc08eSrQYsfdV3bnReJCljRfETkB56rSXVSjNi/XAU8aC6F5u',1,0,'2025-12-31 18:40:38',NULL,'2025-12-31 22:39:54','2025-12-31 22:40:38',NULL),
(67,NULL,NULL,NULL,NULL,'Massiel','Tejeda','themazzy27@gmail.com','Massieltho',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$K3knC2bDBzYU0zAsosJ./O.j4cV6IWg7aTiWUfBqIe24OeIqnj2.G',1,0,'2025-12-31 18:51:18',NULL,'2025-12-31 22:51:01','2025-12-31 22:51:18',NULL),
(68,NULL,NULL,NULL,NULL,'Jeffry','Zabala Ramirez','jefffcito@gmail.com','Jefffcito',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$TsK4jp9rPqtPTcUhIFzUVecAB6t8t/M3GpbKQNWRY/l4A7fulyXWe',1,0,'2025-12-31 19:06:05',NULL,'2025-12-31 23:05:33','2025-12-31 23:06:05',NULL),
(69,NULL,NULL,NULL,NULL,'Roberto','Rojas','angelfitdash@gmail.com','MrSimple',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$7N1vCzIBU6LJlyyH0V3.muBeuCf52Njv5qFsedKlsmIdoGgFp7xHS',1,0,'2025-12-31 19:09:27',NULL,'2025-12-31 23:08:38','2026-01-03 04:19:31',NULL),
(70,NULL,NULL,NULL,NULL,'Zion','Lowe','zionlowe7@gmail.com','112lion',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$n2xeXKEO8ZIXleiSajQhLOwIr8MUdkLvAjoBq6QvrvKccSDSL8kXW',1,0,'2025-12-31 19:19:37',NULL,'2025-12-31 23:19:21','2025-12-31 23:19:37',NULL),
(71,NULL,NULL,NULL,NULL,'Brainer','Espinal Aquino','drbrainer156@gmail.com','Jimmy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$8PZi9xUqgmlyi5D8wg2RceAyymhEgZQP8uJ42I.PlRupc1MlqN052',1,0,'2025-12-31 19:35:20',NULL,'2025-12-31 23:35:03','2025-12-31 23:35:20',NULL),
(72,NULL,NULL,NULL,NULL,'Emanuel','Duarte','durtanu@gmail.com','Durtanu',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$sfY.JUaw71O8yFRugb6OhO2/nlFbSIVDykM3vptXSKRq69j84qyrO',1,0,'2025-12-31 19:44:51',NULL,'2025-12-31 23:44:17','2025-12-31 23:44:51',NULL),
(73,NULL,NULL,NULL,NULL,'Daniel Antonio','De león Javier','daniel_d01@outlook.com','Daniel_d01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$d8OM4FwAFW.rG4wOS6OdBuh8mCAgijxuIczXFHqG3jQf8TJRwzDvS',1,0,'2025-12-31 20:13:11',NULL,'2026-01-01 00:05:25','2026-01-03 03:05:42',NULL),
(74,NULL,NULL,NULL,NULL,'Louis','Pedrito','louispedrito111@gmail.com','509Pedrito',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$QPT5wnOBsic6GP69MeZFXOukvLSXrYDLUpT5lRm4kOzhAPRogUXBC',1,0,'2025-12-31 20:16:05',NULL,'2026-01-01 00:15:47','2026-01-01 00:16:05',NULL),
(75,NULL,NULL,NULL,NULL,'Jonathan','Demosthene','jonathandemosthene50@gmail.com','509Angel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$IOv5EJj82URCnP8tJxDob.wxmmjoaQF4F3y6hDyJ0NMkMCWjVCViu',1,0,'2025-12-31 20:25:56',NULL,'2026-01-01 00:25:40','2026-01-01 00:25:56',NULL),
(76,NULL,NULL,NULL,NULL,'Jeison','Torres','jasontorreslapaix@gmail.com','jasontorreslapaix',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$N00f8Dor8KS6k6LOHMKjUOYDo59GyQuApySKW9tVGVxqJ9YJjz5Fy',1,0,'2025-12-31 20:36:55',NULL,'2026-01-01 00:36:30','2026-01-01 00:36:55',NULL),
(77,NULL,NULL,NULL,NULL,'Robert','Leclerc','robertleclerc18@gmail.com','Robertleclercp',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$KdUz5UrpoGv6tkcT3O3o3esWiZRQQGth.n7Ks0GX/bcLMnaZL2kFC',1,0,'2025-12-31 22:01:46',NULL,'2026-01-01 02:01:30','2026-01-01 02:01:46',NULL),
(78,NULL,NULL,NULL,NULL,'Jorge Luis','Alejo Herrera','jorgeluisalejoherrera120@gmail.com','Jorgealejo190',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$YF8ZUM63nECNwnZXLF4jzu6YezvU8.mapB2n5OW7O4EnOAqHwCaTu',1,0,'2026-01-01 03:25:34',NULL,'2026-01-01 07:25:23','2026-01-01 07:25:34',NULL),
(79,NULL,NULL,NULL,NULL,'Jean carlos','Jimenez','jean.abreuj@gmail.com','Jeanc',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$B4Y0/iKX42smjSBgrKF9suJCQ8NnJrgvxqaVeCZFea4zt8Eaf8i/a',1,0,'2026-01-01 03:26:30',NULL,'2026-01-01 07:26:14','2026-01-01 07:26:30',NULL),
(80,NULL,NULL,NULL,NULL,'John','Lugo','johnldiaz07@gmail.com','Pepper',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$AB.lKw2fpRSVFdHoWS0ibOLu/hQUbZ.ZM0vtnNoMMYKzhG/3bx8xS',1,0,'2026-01-02 22:58:02',NULL,'2026-01-03 02:54:55','2026-01-03 02:58:02',NULL),
(81,NULL,NULL,NULL,NULL,'Joel Francisco','Ramirez alvarez','alvarezjoel923@gmail.com','Joel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$5TFoo/dCLGeFoSqMM1pHTukG89PWrWNGmwCO47ofkBPUXCHWAeUiq',1,0,'2026-01-02 22:55:38',NULL,'2026-01-03 02:55:10','2026-01-03 02:55:38',NULL),
(82,NULL,NULL,NULL,NULL,'Diego','Rojas','diegoguillen0105@gmail.com','Diegs02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$JgIc1RbH75IR4v3/Rfq5BOBEQWgRqUDBQjf2xk.qnsINptRo9SpDm',1,0,'2026-01-02 22:56:29',NULL,'2026-01-03 02:56:13','2026-01-03 02:56:29',NULL),
(83,NULL,NULL,NULL,NULL,'sebastián','marmolejos','sbmarmolejos@gmail.com','sbmarmolejos0101',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$aZReBF.J5eGHDmQqy1wpoO96HBAxZ0SiwakKSM139FB3aj3FWQrhi',1,0,'2026-01-02 22:56:39',NULL,'2026-01-03 02:56:14','2026-01-03 02:56:39',NULL),
(84,NULL,NULL,NULL,NULL,'Miguel angel','Del valle bruno','m8498478202@gmail.com','Miguelbroh',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$YlXuWZG5efmjjrazj/P14.0uM12aFNQrtr3iqjUiGt9rO25eoHz.W',1,0,'2026-01-02 23:00:44',NULL,'2026-01-03 03:00:26','2026-01-03 03:00:44',NULL),
(85,NULL,NULL,NULL,NULL,'Luis','M','beltre90@gmail.com','Beltr31993',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$K6XYnAN6J.joB22sQ.csG.HbbFsmVPdPdeZ26ZD3bW3PChcIwjSAC',1,0,'2026-01-02 23:05:14',NULL,'2026-01-03 03:05:03','2026-01-03 03:05:14',NULL),
(86,NULL,NULL,NULL,NULL,'Stefano','Amador','amador.stefano15@gmail.com','Stef101674',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$/w2oL7KzmQLHxoqLbcJgauBNvOZiYUqheFdI7nTRsmUFUQdCwZW0i',1,0,NULL,'e41f89325e05d5603c71e2e1635c8928','2026-01-03 03:05:40','2026-01-03 03:05:40',NULL),
(87,NULL,NULL,NULL,NULL,'Patricia','Garcia','patriciag8002@gmail.com','PatriciaG',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$b3sMXjeDn495iwRJLF8X5OzNs2ev7U4WKCPafD1wu6CUvIpxd8r5.',1,0,'2026-01-02 23:06:24',NULL,'2026-01-03 03:06:04','2026-01-03 03:06:24',NULL),
(88,NULL,NULL,NULL,NULL,'Luz','Castillo','luzmariamarte849@gmail.com','Luma',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$CqAqhUqyVw2FHpUQ5l7BCeZ6XqbWf.leDh3rdVNpKxkkg8YcDzcgy',1,0,NULL,'9d5de6e77e558938e8d2566130d954bf','2026-01-03 03:08:29','2026-01-03 03:08:29',NULL),
(89,NULL,NULL,NULL,NULL,'Luz','Castillo','luzmariacastillomarte13@gmail.com','Luz',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$bBGDGZ73w8ZQ50RQLXU2L.4IwPmKLQrLlegnKjUY3IuOEYgznCCw.',1,0,'2026-01-02 23:14:54',NULL,'2026-01-03 03:12:17','2026-01-03 03:14:54',NULL),
(90,NULL,NULL,NULL,NULL,'Denis','Rivera','omegadr@yahoo.com','driverae',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$jBeGo24cV./LaioaVTggkOlt2qnuSuzZpLViSxhGG1NeOM69qAetS',1,0,'2026-01-02 23:21:02',NULL,'2026-01-03 03:16:59','2026-01-03 03:21:02',NULL),
(91,NULL,NULL,NULL,NULL,'Emil','Fernandez','emileduardofernandezarias@gmail.com','EmilFdez',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$VAOCZc1quB8GoYXdrW.wIukGGB7F6YqKHfPuuY3mA2da0Y/yO1skm',1,0,'2026-01-02 23:18:11',NULL,'2026-01-03 03:17:54','2026-01-03 03:18:11',NULL),
(92,NULL,NULL,NULL,NULL,'Joel','Peralta','joel.peralta1696@gmail.com','Jperalta1606',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$fHKQbgmZIyNSqtlz8PwQVubn6l3n8NHTnbr6O9zd8BBRSDMiPKGw6',1,0,'2026-01-02 23:19:41',NULL,'2026-01-03 03:19:25','2026-01-03 03:19:41',NULL),
(93,NULL,NULL,NULL,NULL,'Juan','Toribio Lied','jtoribiolied@gmail.com','tainordico',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$DWyiqPnBXnAN0AyCMqhgQ.QmTnrL0vf8rSKRVw1r91ouijap.Vv/a',1,0,'2026-01-02 23:28:57',NULL,'2026-01-03 03:28:08','2026-01-03 03:28:57',NULL),
(94,NULL,NULL,NULL,NULL,'Isaías','Paredes','isaiasdelorbeparedes@gmail.com','Isaadark',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$hRlVlk.CvRyMDMJy2rBmcO.agTHcC.tfplHwNZOLUnOKk01rWvd9q',1,0,'2026-01-02 23:32:28',NULL,'2026-01-03 03:31:04','2026-01-03 03:32:28',NULL),
(95,NULL,NULL,NULL,NULL,'anthony','peguero','anthonpguero@gmail.com','kgre',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$/HbH0u322Kgc1XNyqZhjyOaKi1GAmlHLIOHPj4FGH0z7xBNB5Y1au',1,0,'2026-01-02 23:37:22',NULL,'2026-01-03 03:35:44','2026-01-03 03:37:22',NULL),
(96,NULL,NULL,NULL,NULL,'Step','Vazquez','johannavazquez7@gmail.com','StepVz',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$Ik9hk160.lQ/WA7IbxqgUOPPJiOv1dq0R3n4I4tM8bWOqgp9EPtNa',1,0,'2026-01-02 23:37:37',NULL,'2026-01-03 03:37:20','2026-01-03 03:37:37',NULL),
(97,NULL,NULL,NULL,NULL,'MATEO','VASQUEZ','mathimparable@hotmail.com','MateoVaLo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$/zvNPug/ecqVnNIe/Fzg2eq9AzMuAIP2cOz/DENLAxNowggRlSTlW',1,0,'2026-01-02 23:52:15',NULL,'2026-01-03 03:52:02','2026-01-03 03:52:15',NULL),
(98,NULL,NULL,NULL,NULL,'Hamlet','Almonte','hamlet.almonte@gmail.com','Hamletalmonte',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$K/fj8M4ByFDIzuOMCmfEh.y1XgGqBJXDxiwiq7M5vw/uR/5LmD4f2',1,0,'2026-01-03 00:22:53',NULL,'2026-01-03 04:22:31','2026-01-03 04:22:53',NULL),
(99,NULL,NULL,NULL,NULL,'pablo','reyes','pablojosereyescalderon92@gmail.com','pablor',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$RCVBBUIbjMLssZdoAlWk7urb6eKD7DQvT0CdG53S7HstrSx3ImP9m',1,0,NULL,'c19754356dc9dc1ed0813426c9ad65af','2026-01-03 04:27:01','2026-01-03 04:27:01',NULL),
(100,NULL,NULL,NULL,NULL,'Jini','Luciano','jini_2d@hotmail.com','jinitalol',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$mFKlbpOeCe2FK6K5jNwn3uYgl1gBtfaiYrXIDkQk/9NgWzuHqzbWC',1,0,'2026-01-03 00:29:29',NULL,'2026-01-03 04:28:56','2026-01-03 04:29:29',NULL),
(101,NULL,NULL,NULL,NULL,'Kelvin','Ortiz gonzalez','mj3817133@gmail.com','KingKush10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$iWtDrsmN/trGVESMH6DCcOrAyO8oH7T6gCA1VK4Fo8lr9kci6sBK6',1,0,'2026-01-03 00:31:35',NULL,'2026-01-03 04:31:18','2026-01-03 04:31:35',NULL),
(102,NULL,NULL,NULL,NULL,'Jhon','Chalinger','patax22mh@gmail.com','Patanx22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$wbE4gqjMFlJ2bFT0LrVh3utcMygIr.aWcriN80ZpFz4sBhvxRcqLe',1,0,'2026-01-03 00:32:27',NULL,'2026-01-03 04:32:04','2026-01-03 04:32:27',NULL),
(103,NULL,NULL,NULL,NULL,'Juharin','Payano','jamespayano@gmail.com','Jamesjames',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$8kJuD59k6atGG1Qwzz/xVOyb.gBzTHabfk7padFgBdM271Qz2w9.6',1,0,NULL,'8d2d31b320eed05e0eb595c61903d6e6','2026-01-03 04:38:43','2026-01-03 04:38:43',NULL),
(104,NULL,NULL,NULL,NULL,'Aaron','Chan','aaronchanaybar@gmail.com','Aaronchanay',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$XEkCr0bSk91ts8ouoqVbNeHdy8.5wmPjtUPpc.sWBSUX0908szd9O',1,0,NULL,'3fb654d19e63c429b722cf29e8f9d074','2026-01-03 04:40:22','2026-01-03 04:40:22',NULL),
(105,NULL,NULL,NULL,NULL,'Green','Muñoz','greenmunoz61@gmail.com','Greemfiesta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$WhGEPa39pPW.r75Ua2Nbtu319M2wfEH9fd97AwWGcQb4pI2B3TMia',1,0,'2026-01-03 00:44:13',NULL,'2026-01-03 04:44:01','2026-01-03 04:44:13',NULL),
(106,NULL,NULL,NULL,NULL,'Angel','Pereyra','angelpereyra1307@gmail.com','angelop130',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$F.IN1Ami0R2KwMkckjg4COoPkHXI/bxQvdKApG45L.GRG90xuVVsa',1,0,'2026-01-03 00:51:24',NULL,'2026-01-03 04:51:11','2026-01-03 04:51:24',NULL),
(107,NULL,NULL,NULL,NULL,'pablo','reyes','pablojosereyescalderon@gmail.com','pabloreye',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$v8zKPp5Mu10xPVdkqqVklOTeHwTQ5BIC53KXlNyNtYwaugu7wpty6',1,0,NULL,'c65a357ff7497c5a3644addf052f77f0','2026-01-03 04:55:36','2026-01-03 04:55:36',NULL),
(108,NULL,NULL,NULL,NULL,'Juairin','Payano','ko8361907@gmail.com','Kingjames',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$RBd.FULOwkK6BJzaN1q9WuQr9rnOucktielFkoVyhPAcnPikwlMhy',1,0,'2026-01-03 00:57:16',NULL,'2026-01-03 04:56:56','2026-01-03 04:57:16',NULL),
(109,NULL,NULL,NULL,NULL,'Roberson','Jose','josebaez1988@hotmail.com','Roberson',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$FUV6USGsvAjn2jDR.OI5U./QwIGeeOiKst/OvhVKZzaAu/KOZi2mK',1,0,'2026-01-03 01:02:12',NULL,'2026-01-03 05:00:39','2026-01-03 05:02:12',NULL),
(110,NULL,NULL,NULL,NULL,'Diego Alberto','De los Santos suero','diegoadls04@gmail.com','Dieg0229',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$satFoMid6cfuqZsQdPSc0.Pbr.PhBLG8SpDj0K.Zkp6z/4ibyR/ry',1,0,NULL,'83ee2736b0ac99fc2391f48f44e9e66b','2026-01-03 05:02:22','2026-01-03 05:02:22',NULL),
(111,NULL,NULL,NULL,NULL,'Olga','Mendez','olgamendez03@gmail.com','Olgaolga',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$3OoaMLujO9yHuzVsUULZXuH/rkwsFWyhHZ4DAus3XPI2uJ12BfaIG',1,0,'2026-01-03 01:10:18',NULL,'2026-01-03 05:09:23','2026-01-03 05:10:18',NULL),
(112,NULL,NULL,NULL,NULL,'Angey','Antigua','angieantigua15@gmail.com','itslele',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$/cGyjbTa3VkkLF9jpc6P8.aPZXyEF2UFQT2tyKR1igGYfB/Y1TcjS',1,0,'2026-01-03 01:31:33',NULL,'2026-01-03 05:31:12','2026-01-03 05:31:33',NULL),
(113,NULL,NULL,NULL,NULL,'Cesar Soto','soto','cesarsotoortega@icloud.com','cesarsotoortega',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$eoDuCEOliCi1uHaXGMYzLO72eGaRKKVT/JbmSWyBuUseLkKN0zBHu',1,0,NULL,'a39fdfc75022d01360ac4a01fe2b0f60','2026-01-03 05:40:29','2026-01-03 05:40:29',NULL),
(114,NULL,NULL,NULL,NULL,'Fairam','Castillo','fairam.louis@gmail.com','fairxm',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$hRkElBFL2EhO30uCOQIxceD2Kdt2EQILZresBUj1tSNz8xs5XWSRK',1,0,'2026-01-03 03:51:54',NULL,'2026-01-03 07:51:25','2026-01-03 07:51:54',NULL),
(115,NULL,NULL,NULL,NULL,'Fausto','Marte','faustopena170@gmail.com','Fauma',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$1JC6K75SW616UXxxu3J7dO7sbzoAOVUsQjvXdyOtHnfXMIZJ6dYMy',1,0,'2026-01-03 09:12:23',NULL,'2026-01-03 13:12:08','2026-01-03 13:12:23',NULL),
(116,NULL,NULL,NULL,NULL,'Josue','Valentin Villa','datjoshie@gmail.com','DatJoshie',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$.AF/sc6h37MNVWg.eh6GMupWP0hT5jNWUVOcZZR3AlTdsgz/KXLoG',1,0,'2026-01-03 10:29:29',NULL,'2026-01-03 14:02:54','2026-01-03 14:29:29',NULL),
(117,NULL,NULL,NULL,NULL,'Aider','Kun','aidersupp30@gmail.com','AiderKun',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$R48ghXp3oIlowPHlZQm1e.h7RJ4Xe0zqGxM.EgvQ2gcHIGW4D4vbq',1,0,'2026-01-03 10:42:40',NULL,'2026-01-03 14:41:15','2026-01-03 14:42:40',NULL),
(118,NULL,NULL,NULL,NULL,'Rafael','Romero','678tasha678@gmail.com','Rafarom666',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$qGZuszZmRLoMeVEWmMdo6eHDS3Zsi4fsNSzO.olTZZfDTJeWGnbCO',1,0,'2026-01-03 11:28:31',NULL,'2026-01-03 15:23:52','2026-01-03 15:28:31',NULL),
(119,NULL,NULL,NULL,NULL,'Luis','Perez','lbpm9513@gmail.com','Lbpm9513',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$oC6ZzXw6KUzeJGADC1qrkO6y8T.Cw5dmEur3RERWiI5aHj16SwqaS',1,0,'2026-01-03 11:55:12',NULL,'2026-01-03 15:54:36','2026-01-03 15:55:12',NULL),
(120,NULL,NULL,NULL,NULL,'Joan','Pérez Pujols','joanp1994@hotmail.com','Joanperezrd',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$zU/3FrdyzPxPB5xu0W5Laeqn.dmr7amOAwPFsnI2/jqt1JqIVEyme',1,0,'2026-01-03 11:58:03',NULL,'2026-01-03 15:57:26','2026-01-03 15:58:03',NULL),
(121,NULL,NULL,NULL,NULL,'janiel','acosta','janielacostarealestate@gmail.com','janielacosta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$CVRlGfdWXXrH2jEh0mf1S.mX.X0H9bM/OdTiHShH1TV2iqZ22.gZW',1,0,'2026-01-03 11:58:17',NULL,'2026-01-03 15:58:03','2026-01-03 15:58:17',NULL),
(122,NULL,NULL,NULL,NULL,'Stefano','Amador','amadorstefano15@gmail.com','Amadior2000',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$lmryeHkMY7pdLG49fTBYNOf4moNABQVjX4FQhbegjtZfSGla4mc1e',1,0,'2026-01-03 12:00:06',NULL,'2026-01-03 15:59:06','2026-01-03 16:00:06',NULL),
(123,NULL,NULL,NULL,NULL,'Pavel','Calderon','stefano.amador@gmail.com','Paverusk',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$aADqgtpCC3lAaBNkTaHiHuwdVaR6mh0jv12rWItEPGO2yy4J1.HC.',1,0,'2026-01-03 12:06:47',NULL,'2026-01-03 16:06:27','2026-01-03 16:06:47',NULL),
(124,NULL,NULL,NULL,NULL,'Dulce','Wiese','dulcewiese18@gmail.com','Dulcewiese_1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$5Z2LK8MU0rTUPjZiiEbfQOv7Iuy1s8VpGZ3yRsdp8Ry7aG7xGGFz.',1,0,'2026-01-03 12:13:13',NULL,'2026-01-03 16:12:17','2026-01-03 16:13:13',NULL),
(125,NULL,NULL,NULL,NULL,'Mary','De León','marygdeleonf@gmail.com','Marydeleon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$yvM44zhMNGJUVXQTDZv8MuQ1QHcRS2JFdzH2PuCBIFF5Dni3a/a6i',1,0,'2026-01-03 12:14:14',NULL,'2026-01-03 16:13:34','2026-01-03 16:14:14',NULL),
(126,NULL,NULL,NULL,NULL,'Lotty','Cardenas','lottycardenas25@gmail.com','Lotty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$jDHNEl2d/LPIMixCk3C/buTqEegY5J3R6LlVrl0HDQVpM.V5z3DiO',1,0,'2026-01-03 20:21:22',NULL,'2026-01-03 16:30:45','2026-01-04 00:21:22',NULL),
(127,NULL,NULL,NULL,NULL,'Salimah','Veras','salimahveras@gmail.com','sali_veras',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$6yLw3VrAXAhzzNcltVXQMOw4p51TwyNMDVbksFOPLQmWUkZxOgydK',1,0,'2026-01-03 12:42:36',NULL,'2026-01-03 16:40:07','2026-01-03 16:42:36',NULL),
(128,NULL,NULL,NULL,NULL,'Luis Angel','Tavarez Taveras','angel.tvrzs@gmail.com','Radhame',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$JNRtuwjnLZHVSTdkXOzrEOs5Cwsjhl4IbpQr7rBc8pgMSzooq/r3W',1,0,'2026-01-03 12:40:53',NULL,'2026-01-03 16:40:15','2026-01-03 16:40:53',NULL),
(129,NULL,NULL,NULL,NULL,'Yefry','Batista','yeffjesus08@gmail.com','YeffB',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$HjrIWx2G3gM08kFUJG9rM.WmiYac2rHJWMcjHhvpPMv5X6NgnhXn.',1,0,'2026-01-03 12:48:36',NULL,'2026-01-03 16:48:14','2026-01-03 18:08:41',NULL),
(130,NULL,NULL,NULL,NULL,'Aubrey','Fernández','aubreyfer02@gmail.com','Aubrey',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$5hzNi09cZ8lZPR5lScLBce9h4B2DcCsqbMom7VldaQV8hgqZbAJIS',1,0,'2026-01-03 14:34:33',NULL,'2026-01-03 16:51:43','2026-01-03 18:34:33',NULL),
(131,NULL,NULL,NULL,NULL,'Ana rosa','Mondesi','irisbaez1024@gmail.com','Aaaamor',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$fdywIcVAe9m3lP/U7g.XLeUpp5tVeddtpG9PifCwzr4G/hBRj8ZAG',1,0,NULL,'3b38ae741fd9247e87fb68bf219658d0','2026-01-03 16:53:21','2026-01-03 16:53:21',NULL),
(132,NULL,NULL,NULL,NULL,'Damaris','Martinez','reddame72@gmail.com','Damaris',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$U95QtBNdyNUNg2pfzDK3beXh8gLhq7DQMxXaI8AKeU3FfWAtGO6Hi',1,0,'2026-01-03 13:16:15',NULL,'2026-01-03 16:54:11','2026-01-03 17:16:15',NULL),
(133,NULL,NULL,NULL,NULL,'Raúl','Cabrera','rau0809@gmail.com','Raul',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$QcjD9FBhwvFxTHDq2RxHJeQHU6nPrBiI8OKrFOT2AeV3Szdu9RRra',1,0,'2026-01-03 13:00:08',NULL,'2026-01-03 16:59:56','2026-01-03 17:00:08',NULL),
(134,NULL,NULL,NULL,NULL,'Marcos','De Leon','mrskaos101@gmail.com','Javi31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$8hs.XyQjcBZqrf1ytrrwYOcDd4mKd.03L7Zl5oCwGO6noH0JCVJzS',1,0,NULL,'0765d63ed982f0ea859abf6de2c038e9','2026-01-03 17:01:56','2026-01-03 17:01:56',NULL),
(135,NULL,NULL,NULL,NULL,'Jordi Rafael','Ramos Ventura','jordi.ramos.1990@gmail.com','jramos90',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$bly/GiwMKUxIhoXKHNaeEudMvJChrU3jYFK.WQeAMr115dMg9nnwm',1,0,'2026-01-03 13:04:15',NULL,'2026-01-03 17:03:43','2026-01-03 17:04:15',NULL),
(136,NULL,NULL,NULL,NULL,'Vishnu','Fernández','vishnufernandez@icloud.com','Vishnu',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$QLgNSXH251nYUE3a1vXwfOGIrgPLs2CFvPGI.in/wvRucKjJNY6Tq',1,0,'2026-01-03 13:11:41',NULL,'2026-01-03 17:11:06','2026-01-03 17:11:41',NULL),
(137,NULL,NULL,NULL,NULL,'Gino','Carezzano','gino.carezzano@gmail.com','ginocarezzano',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$mcArz/zvN7Yhl9mBJ1V/MOV7wampimz7.ciu32047vQB58Tt5.Bfe',1,0,'2026-01-03 13:18:21',NULL,'2026-01-03 17:18:04','2026-01-03 17:18:21',NULL),
(138,NULL,NULL,NULL,NULL,'jandro','polanco','jandr4xxx@gmail.com','jandro',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$iPhSL0I5H1vAixvBCEnB6.tBArXXsDx6pNcC/GU.K9l/uSTiBBjH.',1,0,'2026-01-03 13:44:00',NULL,'2026-01-03 17:43:38','2026-01-03 17:44:00',NULL),
(139,NULL,NULL,NULL,NULL,'Alexa','Reyes','cheetah106@gmail.com','reyesa',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$0Ya0kj1n/usESPYSYbFP4elbY82O8LY.ur7ASMJKdSPRA/imy6Ixq',1,0,NULL,'3dad5267d30f963c9747ab7edfcc932a','2026-01-03 17:49:07','2026-01-03 17:49:07',NULL),
(140,NULL,NULL,NULL,NULL,'Ramnerys','Mena De la Cruz','ramnerysmena@gmail.com','Bert',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$fakW6CcO7HfsNEI4OFtRY.KgwlJnufcNOu6DrVVNGqTXkODBlja.C',1,0,'2026-01-03 13:56:43',NULL,'2026-01-03 17:56:30','2026-01-03 17:56:43',NULL),
(141,NULL,NULL,NULL,NULL,'Jose','Pena','jose.pena@email.com','josefpena',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$KuSLj4JZ4YWMCin5//c./O.TAr3wOYesaiWKofXBCX5ZvRwn7faY6',1,0,NULL,'c667566504037d0401924dc5404569f2','2026-01-03 18:36:40','2026-01-03 18:40:15',NULL),
(142,NULL,NULL,NULL,NULL,'Aimee','Morel','aimeemorel04@icloud.com','Aimeemorel04',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$UemQDGKue2yWz/3RsMCzf.GAw/zwZk5RUi2K1GGLXFrPPOmdUL2ZK',1,0,'2026-01-03 14:38:13',NULL,'2026-01-03 18:37:41','2026-01-03 18:38:13',NULL),
(143,NULL,NULL,NULL,NULL,'Jose','Pena','josefelinopenasegura@gmail.com','josefelinopenasegura',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$Z4jm4TiC5RwabAKxa3HNB.RLkc91EdLMuMB633SrDYSIWE2Nec45W',1,0,NULL,'2f230754dc720ddcc29a99d7978fb586','2026-01-03 18:44:27','2026-01-03 18:44:27',NULL),
(144,NULL,NULL,NULL,NULL,'Marcos','De Leon','marcosjavierdeleon31@gmail.com','Marcos31',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$5LV2gzVkdWpgxOvMYl8NdeMHNx7pUWBzH5c1YSMujHT.rtaAjZAWm',1,0,'2026-01-03 15:01:34',NULL,'2026-01-03 19:01:23','2026-01-03 19:01:34',NULL),
(145,NULL,NULL,NULL,NULL,'Rafael','Bueno','rafaelbueno1923@hotmail.com','imrafaelbueno',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$F0nrDRi.4SJLbwbBdxFReeNNWX0NWJ1gcy801T/aN6bMxy/bwJ2WS',1,0,'2026-01-03 15:32:02',NULL,'2026-01-03 19:31:26','2026-01-03 19:32:02',NULL),
(146,NULL,NULL,NULL,NULL,'Sebastian','Suriel','ssuriel16@hotmail.com','sebashanj',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$QrE7DG1IMxSNLZI7juBYgeahjRi4J8RydPD7rTt5kFgp3jf7sXLc6',1,0,'2026-01-03 15:36:58',NULL,'2026-01-03 19:36:44','2026-01-03 19:36:58',NULL),
(147,NULL,NULL,NULL,NULL,'Yeralqui','Frias','yeralquialexander@gmail.com','alexander98',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$e.KyhBLcXWZuL9O1dReHmeqiPQBnJSZjd5UsXJcVjUEkJW7xAHmRG',1,0,'2026-01-03 16:02:01',NULL,'2026-01-03 20:01:07','2026-01-03 20:02:01',NULL),
(148,NULL,NULL,NULL,NULL,'Jerry Steven','Reyes Veloz','jeesreve@gmail.com','Jreyes',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$0VPfGts0BNHDmSnbOG8H9u.lnRDLczyIMHi8xQ4u0PUkviR3kdF02',1,0,'2026-01-03 16:25:08',NULL,'2026-01-03 20:24:56','2026-01-03 20:25:08',NULL),
(149,NULL,NULL,NULL,NULL,'Rosy','Villa','rosyxvilla@gmail.com','rosyxvilla',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$xdhtJEDQp.fuS4bm3xnt9uB/TIwQtt/.biD8Rxh3hDOe6q6y49AdC',1,0,'2026-01-03 16:30:20',NULL,'2026-01-03 20:30:09','2026-01-03 20:30:20',NULL),
(150,NULL,NULL,NULL,NULL,'NAIROBI','HERNANDEZ GOMEZ','nairobihgomez.2010@gmail.com','Niicenaii',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$tzLNAgFGaBfd3.rzYVx/1.dZe3NLLdpyFXatm9On81ECKyY3Ba4uG',1,0,'2026-01-03 17:11:54',NULL,'2026-01-03 21:11:32','2026-01-03 21:11:54',NULL),
(151,NULL,NULL,NULL,NULL,'Emilis','Castillo','emily.garrix@gmail.com','castleemmy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$Lul8FciSiV45WlNdKu2wGu.Aweua.YreCM.IVZIhcnuGfcUDYMkxG',1,0,'2026-01-03 17:45:19',NULL,'2026-01-03 21:43:16','2026-01-03 21:45:19',NULL),
(152,NULL,NULL,NULL,NULL,'Erick','Hiciano','hiciano.envio@gmail.com','Pawter',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$4/kTxAbXKLlbNGjx/fW/h.8C8h37S3XqxTITI11w3UGDZNnd2r0YC',1,0,'2026-01-03 17:46:10',NULL,'2026-01-03 21:45:17','2026-01-03 21:46:10',NULL),
(153,NULL,NULL,NULL,NULL,'Alexander','Suarez','ALEXSUAREZMEN27@GMAIL.COM','Alexsm27',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$VxZcgxjFikHrOzQbmmRQ7e0XpVZWR3WQtTqvdyCGos2env26oGBYi',1,0,'2026-01-03 17:45:54',NULL,'2026-01-03 21:45:27','2026-01-03 21:45:54',NULL),
(154,NULL,NULL,NULL,NULL,'Franchel','Velázquez','franchard7@gmail.com','Franchard7',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$U3xk9aD8ecWyFJ8Duk7ux.RaP.g62irZ//EvdLKtiysEYLsZWTPaC',1,0,'2026-01-03 17:50:12',NULL,'2026-01-03 21:49:33','2026-01-03 21:50:12',NULL),
(155,NULL,NULL,NULL,NULL,'Eduardo','Cruz','eduardocruzcastillo07@gmail.com','EduardoCruz_',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$HfhXQUoxN3Xeveh0pMXOm.Z1ceCgiTi6DPyJGrNvqFvgot1UOYXBe',1,0,'2026-01-03 18:00:56',NULL,'2026-01-03 22:00:22','2026-01-03 22:00:56',NULL),
(156,NULL,NULL,NULL,NULL,'Krysht','Fernández','krysht.13@gmail.com','Krysht',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$1r18JxzeIhnaQpndjW7yAeCZMOvNyHR/RaT9yMFCY/qg.KRp9VJ1m',1,0,'2026-01-03 18:17:45',NULL,'2026-01-03 22:16:09','2026-01-03 22:17:45',NULL),
(157,NULL,NULL,NULL,NULL,'Alexander','Mueses','yeralquialexander@hotmail.com','yeral98',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$9dkPumEbw2cdgaQjLMSpr.qWPNkDQeV72xD1MpE703EUMsq3z74X.',1,0,'2026-01-03 18:21:54',NULL,'2026-01-03 22:21:16','2026-01-03 22:21:54',NULL),
(158,NULL,NULL,NULL,NULL,'Ninoska','Mejia','ninoskamejia16@gmail.com','ninoskamejia',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$kgVKvkXdK14u4XXKnH3abuj7SNbRRBaUxaOovC/WQhIUj356yR482',1,0,NULL,'3de65590f4f1da68a1a7457e09050f20','2026-01-03 22:26:39','2026-01-03 22:26:39',NULL),
(159,NULL,NULL,NULL,NULL,'Gabriella','Medina','gabriella.carmin@gmail.com','carmin',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$AsFVupNW3Fb17F/yBPtjwuju87AC4SvgDvzabrCsME9goaCrkOqRq',1,0,'2026-01-03 18:31:47',NULL,'2026-01-03 22:30:26','2026-01-03 22:31:47',NULL),
(160,NULL,NULL,NULL,NULL,'Jesús','Mora','jesusricoso17@gmail.com','Jesusito',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$ELC/.Lc5gx7lUuw4Uwb1O.4dpvmZ3d9e9EsggtZ6aS981ruYgzZm2',1,0,'2026-01-03 18:44:40',NULL,'2026-01-03 22:42:44','2026-01-03 22:44:40',NULL),
(161,NULL,NULL,NULL,NULL,'Kiara','Hernandez','hernandezkiara88@gmail.com','Kikiisakitty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$0BuX2B4E0RZ85AvnDaDho.v4XhYOAyX2xQiJlmvugYmqm5jnWZZAy',1,0,'2026-01-03 18:43:25',NULL,'2026-01-03 22:43:15','2026-01-03 22:43:25',NULL),
(162,NULL,NULL,NULL,NULL,'Brenda','Méndez','brendayis2211@gmail.com','thattbibi',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$yaHIaP4C2YOYSiE88ekQmeUF5LgkFjYNiYfAXx5gqoSUxJ2IsVkvy',1,0,'2026-01-03 19:20:54',NULL,'2026-01-03 22:48:00','2026-01-03 23:20:54',NULL),
(163,NULL,NULL,NULL,NULL,'Jassel','Santana','jasselenrique@gmail.com','Jassel',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$oTrUiCTFj2iKWkMB.VVEv.nDmeq6j5G0Cjyu0mygRmNPjX6N/SxJC',1,0,'2026-01-03 19:05:53',NULL,'2026-01-03 23:05:37','2026-01-03 23:05:53',NULL),
(164,NULL,NULL,NULL,NULL,'Jean','Diaz','jeancarlosdiazrod@gmail.com','Jeanpapis02',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$x7NIQ1siPoGQX5GM/S8PZ.7SSORbNbQ.5VcSbM49Mcl1b2l/Leg/q',1,0,'2026-01-03 19:09:28',NULL,'2026-01-03 23:09:06','2026-01-03 23:09:28',NULL),
(165,NULL,NULL,NULL,NULL,'Luigi','Montaño Laureano','luigimontano1@gmail.com','Luigim10',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$aaO/YojYc12qpG7x/ZQu1ee74D2WW2OuqMajicrmXUVBMI5fDTZlK',1,0,'2026-01-03 19:13:18',NULL,'2026-01-03 23:09:49','2026-01-03 23:13:18',NULL),
(166,NULL,NULL,NULL,NULL,'Alexis','Contreras','onlyalex85@gmail.com','alexiscontreras',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$qar91DjLNA3UJ8f.pEYkmeZGpHhvP6Hfclm3TN0W0OhqPPoQad3u2',1,0,'2026-01-03 19:13:17',NULL,'2026-01-03 23:12:48','2026-01-03 23:13:17',NULL),
(167,NULL,NULL,NULL,NULL,'Eduardo','Cruz','cruzcastilloeduardo@gmail.com','EduardoRoller_',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$tFg14zPkm1sdsw6P8nTPFenJvV0H6k/QhNknTF2qyMlbM965NUfga',1,0,NULL,'7f0cea01c838adb6ddf0f127ab1273d2','2026-01-03 23:32:33','2026-01-03 23:32:33',NULL),
(168,NULL,NULL,NULL,NULL,'Lara','Denisse','lara.yasiris15@gmail.com','Laradeni',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$hLS8a1DHJLqFwHCqo5PvpeiZ.9NYF83rpH9BXFiDsPbefmru.HrsS',1,0,'2026-01-03 19:55:14',NULL,'2026-01-03 23:54:07','2026-01-03 23:55:14',NULL),
(169,NULL,NULL,NULL,NULL,'Julio Antonio','Marcano arvelo','marcanojulio55@gmail.com','Juliomarcano',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$nuhkaDN2QdmFSoiM0mvxaOi1DTKMTx70Bm05iYUIUW9LdTFYUltzG',1,0,'2026-01-04 00:16:28',NULL,'2026-01-04 00:34:13','2026-01-04 04:16:28',NULL),
(170,NULL,NULL,NULL,NULL,'Diego Alberto','De los Santos suero','arcs_revers.5m@icloud.com','Diegfeliz',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$CHFP5rla7IwR6xAKix3mzOpJ0Ei2Jf0x0pIrbYYQACIzl3s5PCI9O',1,0,'2026-01-03 21:05:02',NULL,'2026-01-04 01:04:24','2026-01-04 01:05:02',NULL),
(171,NULL,NULL,NULL,NULL,'Kevin','Lopez','kevinlopezb1321@gmail.com','Klo',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$mZ3DVhZR7iyvFYHQKBYSeO7i1/maP9ac0jkrL8uJyDtCKDrRpQ2iK',1,0,'2026-01-03 21:53:22',NULL,'2026-01-04 01:51:12','2026-01-04 01:53:22',NULL),
(172,NULL,NULL,NULL,NULL,'Anderson','Peña','andersonpenacoach@icloud.com','Afcreador',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$FpG1otUZ63UsUWJYxk/9y.NfGD7gMou1c69jV7ITjDvyawRy.iqK6',1,0,NULL,'ddbe09aa98cef6212b1422f88ecd8905','2026-01-04 02:11:34','2026-01-04 02:11:34',NULL),
(173,NULL,NULL,NULL,NULL,'Ruth','Vasquez','michvs1202@gmail.com','Michvs',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$f0yyuZhh9Xcj7XR0L44U1eEnz2Fc13dTKtenb6WEGqhKvMNLCCV.G',1,0,'2026-01-03 22:51:54',NULL,'2026-01-04 02:38:50','2026-01-04 02:51:54',NULL),
(174,NULL,NULL,NULL,NULL,'Bernis','Mendez','bernisthomoe@gmail.com','BernisMéndez',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$idoYQQHc4eFmNCe4sQuAPe.CVHRgoSCZnTcVjcpr9c4oWae0J6MfK',1,0,'2026-01-03 22:43:34',NULL,'2026-01-04 02:40:50','2026-01-04 02:43:34',NULL),
(175,NULL,NULL,NULL,NULL,'Danisa','Berigüete','danisaberiguete47@gmail.com','Danisa_30',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$VlTEDplmWGPqmlb5jq1tjeyXQ8WvWsH7t21YkWwKo2FryOcB3f6jq',1,0,'2026-01-03 22:44:58',NULL,'2026-01-04 02:44:08','2026-01-04 02:44:58',NULL),
(176,NULL,NULL,NULL,NULL,'Ana rosa','Mondesi','ripok943@stayhome.li','Aaaamor2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$hmFLW6bn31zzB8t9DDihp.NfHrbRtrwWUM/0YL1fnaKOFSs6O.Uaa',1,0,'2026-01-03 22:49:20',NULL,'2026-01-04 02:49:03','2026-01-04 02:49:20',NULL),
(177,NULL,NULL,NULL,NULL,'adenis','paniagua','adenispaniaguacisd@gmail.com','adenis22',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$q.Rb59xI11wh2FLSZM7wV.dJ3aDpsxx2OrLyyPM5Hl1R0j0cRzTOu',1,0,'2026-01-03 22:50:49',NULL,'2026-01-04 02:49:13','2026-01-04 02:50:49',NULL),
(178,NULL,NULL,NULL,NULL,'Loren','Ramos','Nerolramos@hotmail.com','nerolsomar',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$qLvOc7ZRvtYXzDBbn5Q1gO0D8qUbFZcwUgmHDr4RmwJY.XOEsBnBO',1,0,'2026-01-03 22:53:06',NULL,'2026-01-04 02:51:21','2026-01-04 02:53:06',NULL),
(179,NULL,NULL,NULL,NULL,'Nicole','Santana Rojas','nicolesantanarojas@gmail.com','Niicolesr',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$PVsYh93159IfFjCbhglhMuvUHICJKToKuRj3HpT5QKinJte904.4q',1,0,'2026-01-03 23:03:21',NULL,'2026-01-04 03:03:08','2026-01-04 03:03:21',NULL),
(180,NULL,NULL,NULL,NULL,'Yoan','Perez','yoanrayo@gmail.com','Yon',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$WRnvk9UCUU6E7fgu1n/XA.P4Uz8B2GApQ7YwqI69OgMr4rtSjjEf6',1,0,'2026-01-03 23:27:17',NULL,'2026-01-04 03:26:03','2026-01-04 03:27:17',NULL),
(181,NULL,NULL,NULL,NULL,'Hector','Avellaneda','havellanedapineda@gmail.com','Hectoravell17',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$YgW6IM1Wi7j6I/pjdsWdkuoX6DcVNHtK7gRsiecl/nlgBdMGIUzQ.',1,0,'2026-01-04 00:05:33',NULL,'2026-01-04 04:01:13','2026-01-04 04:05:33',NULL),
(182,NULL,NULL,NULL,NULL,'Angie','Gaona','angievalentinagaonasierra@gmail.com','Vgsangie123',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$LNoQGYoB7xyA0uiR5jWX3..AFztfArXRbap5R5Y7iKEs7mzGhuNVq',1,0,'2026-01-04 00:41:18',NULL,'2026-01-04 04:14:55','2026-01-04 04:41:18',NULL),
(183,NULL,NULL,NULL,NULL,'Emanuel','Barrios','rolfcast@gmail.com','Rolfcast',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$pd0Mfdua/hmK14m4KyYAju/PS5qVYiZk.RHIBz2F1qm66QYB5d1CC',1,0,'2026-01-04 00:38:45',NULL,'2026-01-04 04:37:23','2026-01-04 04:38:45',NULL),
(184,NULL,NULL,NULL,NULL,'Yimmy','Pinales','ynew1775@gmail.com','Ynew',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'$2y$10$g2XTw7ynOnjysg4/AvXVbObafKJ.i0TOXtHZ5bFEp93LT5.1m/UXe',1,0,NULL,'e1b1a9cbd8e9adcb33ed388f4e8cafeb','2026-01-04 04:37:50','2026-01-04 04:37:50',NULL);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `earnings`
--

DROP TABLE IF EXISTS `earnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `earnings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `total_revenue` float(8,2) DEFAULT 0.00,
  `total_earning` double(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `earnings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `earnings` WRITE;
/*!40000 ALTER TABLE `earnings` DISABLE KEYS */;
INSERT INTO `earnings` VALUES
(1,39560.00,1140.00,'2023-04-30 10:35:51','2026-02-19 03:23:56');
/*!40000 ALTER TABLE `earnings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_artist`
--

DROP TABLE IF EXISTS `event_artist`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_artist` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) unsigned NOT NULL,
  `artist_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `event_artist_event_id_foreign` (`event_id`),
  KEY `event_artist_artist_id_foreign` (`artist_id`),
  CONSTRAINT `event_artist_artist_id_foreign` FOREIGN KEY (`artist_id`) REFERENCES `artists` (`id`) ON DELETE CASCADE,
  CONSTRAINT `event_artist_event_id_foreign` FOREIGN KEY (`event_id`) REFERENCES `events` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_artist`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_artist` WRITE;
/*!40000 ALTER TABLE `event_artist` DISABLE KEYS */;
/*!40000 ALTER TABLE `event_artist` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_categories`
--

DROP TABLE IF EXISTS `event_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `language_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0,
  `serial_number` mediumint(9) NOT NULL,
  `is_featured` char(4) NOT NULL DEFAULT 'no',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_categories` WRITE;
/*!40000 ALTER TABLE `event_categories` DISABLE KEYS */;
INSERT INTO `event_categories` VALUES
(33,'Party',8,'69402fd06e2ac.jpg','party',1,0,'yes','2025-12-15 15:57:04','2025-12-15 15:57:04');
/*!40000 ALTER TABLE `event_categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_cities`
--

DROP TABLE IF EXISTS `event_cities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_cities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) DEFAULT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_cities`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_cities` WRITE;
/*!40000 ALTER TABLE `event_cities` DISABLE KEYS */;
INSERT INTO `event_cities` VALUES
(14,8,1,1,'New York','new-york','1',1,'2025-08-11 03:57:59','2025-08-11 03:58:23'),
(15,8,3,2,'London','london','1',2,'2025-08-11 03:58:46','2025-08-11 03:58:46'),
(16,8,5,3,'Toronto','toronto','1',3,'2025-08-11 03:59:04','2025-08-11 03:59:04'),
(17,8,7,4,'Sydney','sydney','1',4,'2025-08-11 03:59:17','2025-08-11 03:59:17'),
(18,8,7,4,'Berlin','berlin','1',5,'2025-08-11 03:59:32','2025-11-04 02:24:41'),
(19,22,10,16,'برلين','برلين','1',5,'2025-08-11 04:12:07','2025-08-11 11:41:01'),
(20,22,8,15,'سيدني','سيدني','1',4,'2025-08-11 04:12:32','2025-08-11 11:40:55'),
(21,22,6,14,'تورنتو','تورنتو','1',3,'2025-08-11 04:12:51','2025-08-11 11:40:48'),
(22,22,4,13,'لندن','لندن','1',2,'2025-08-11 04:13:07','2025-08-11 11:40:41'),
(23,22,2,12,'نيويورك','نيويورك','1',1,'2025-08-11 04:13:25','2025-08-11 11:40:35'),
(24,8,11,23,'Zona Colonial','zona-colonial','1',0,'2025-12-15 15:54:09','2025-12-15 15:54:09');
/*!40000 ALTER TABLE `event_cities` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_contents`
--

DROP TABLE IF EXISTS `event_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `city_id` bigint(20) DEFAULT NULL,
  `state_id` bigint(20) DEFAULT NULL,
  `language_id` int(11) NOT NULL,
  `event_category_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `meta_description` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `address` text DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `google_calendar_id` varchar(255) DEFAULT NULL,
  `refund_policy` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_contents` WRITE;
/*!40000 ALTER TABLE `event_contents` DISABLE KEYS */;
INSERT INTO `event_contents` VALUES
(236,134,11,24,23,8,33,'B-Side: Session','b-side:-session','<p><strong>Entrada online:</strong> RD$400<br /><strong>Puerta:</strong> RD$800</p>\n<p><strong>Comunidad Hidden:</strong><br />50% OFF → <strong>RD$200</strong><br />Cupón exclusivo vía <strong>WhatsApp Comunidad Hidden</strong><br />Códigos válidos hasta <strong>1 día antes del evento</strong></p>\n<p>Compra con cupón sin pertenecer al grupo = <strong>pago de diferencia en puerta (RD$600)<br /><br />Únete aquí<br /><a class=\"decorated-link\" href=\"https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H\">https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H</a><br /></strong></p>',NULL,NULL,'2025-12-15 16:07:14','2025-12-15 16:07:14','C. Jose Gabriel Garcia 317',NULL,NULL,NULL,'10210',NULL,NULL),
(237,135,NULL,24,NULL,8,33,'KARMA : New Year’s Eve','karma-:-new-year’s-eve','<p><strong>KARMA</strong><br />New Year’s Eve</p>\n<p><strong>31 de diciembre | 10:00 PM – 7:00 AM</strong></p>\n<p>Este fin de año no celebramos el caos.<br />Celebramos la intención.</p>\n<p>KARMA es una experiencia para cerrar ciclos, soltar lo que pesa y empezar el año desde un lugar limpio.</p>\n<p>Lo que das, vuelve.<br />La energía que eliges, se queda.</p>\n<p>Una noche larga.<br />Un amanecer distinto.<br />Un nuevo comienzo.</p>\n<p>LINEUP</p>\n<p>- Oscar Garcia<br />- YJam<br />- Sultan<br />- Santana<br />- West Indies<br />- Gianvald<br />- Manuel Miller</p>\n<p>Un viaje musical continuo del cierre a la renovación.</p>\n<p>DONDE?</p>\n<p>Los Reales Colonial<br />C. Mercedes 154, Zona Colonial, Santo Domingo</p>\n<p>Historia, ritmo y amanecer en el corazón de la ciudad.</p>\n<p>No es solo una fiesta.<br />Es un reset.</p>\n<p>Entramos al 2026 con la energía correcta.</p>\n<p><strong>Para mas informacion unete a nuestro grupo de whastapp</strong><br /><strong><a class=\"decorated-link\" href=\"https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H\">https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H</a></strong></p>','KARMA : New Year’s Eve','31 de diciembre | 10:00 PM – 7:00 AM\r\nLos Reales Colonial\r\nC. Mercedes 154, Zona Colonial, Santo Domingo','2025-12-26 09:01:07','2025-12-26 17:54:49','C. Mercedes 154, Zona Colonial, Santo Domingo',NULL,NULL,NULL,NULL,NULL,NULL),
(238,136,NULL,24,NULL,8,33,'Moon @  Los Reales Colonial','moon-@-los-reales-colonial','<p> MOON<br />When the moon rises, we move.</p>\n<p>Este sábado 3 de enero la ciudad se alinea con el ritmo.<br />Antiguos creían que esta luna abría caminos.<br />Nosotros abrimos la pista.</p>\n<p>Line-up:<br />Angie Rey<br />Cesar Soto<br />Manuel Miller</p>\n<p>Los Reales Colonial, Zona Colonial, Santo Domingo<br />Guestlist vía DUTY</p>\n<p>La primera luna llena marca el pulso del año.<br />Nosotros seguimos el ritmo. </p>',NULL,NULL,'2026-01-03 02:48:48','2026-01-03 04:21:40','Los Reales Colonial',NULL,NULL,NULL,NULL,NULL,NULL),
(239,139,NULL,24,NULL,8,33,'GIANVALD - 28 FEBRERO','gianvald---28-febrero','<p>La ciudad guarda secretos…<br />y este <strong>28 de febrero</strong> uno de ellos sale a la luz. </p>\n<p><strong>HIDDEN in the City</strong> presenta:<br /><strong>GIANVALD</strong><br />Una noche donde el ritmo se apodera del espacio y la energía no se negocia.</p>\n<p>Host: <strong>Matheo</strong></p>\n<p>Warm-up:<br /><strong>Leonardo Camilo · Fernan Bruno · Submoi</strong></p>\n<p>En Colaboracion con:<br /><strong>Street manners | Cuer* | Oju | LocalBeats</strong></p>\n<p>Nos vemos donde solo los que saben llegan. </p>\n<p>#HiddenInTheCity #Gianvald #StreetManners #ElectronicMusic #ColonialNights #HiddenCommunity</p>','GIANVALD - 28 FEBRERO @ Los Reales Colonial','La ciudad guarda secretos…\r\ny este 28 de febrero uno de ellos sale a la luz.','2026-02-07 23:44:52','2026-02-08 00:07:12','C. Mercedes 154, Santo Domingo 10210',NULL,NULL,NULL,'10210',NULL,NULL),
(240,140,NULL,24,NULL,8,33,'YJAM @ Perpetual Lab','yjam-@-perpetual-lab','<p>Yjam<br />Perpetual Lab<br />Domingo · 1 de marzo</p>\n<p>Una experiencia musical íntima.</p>\n<p>Sonido curado, coctelería de autor<br />y propuestas saludables.<br />Arte en vivo<br />como parte de la atmósfera.</p>\n<p>Tickets en Duty.</p>','YJAM @ Perpetual Lab','Domingo · 1 de marzo\r\n\r\nUna experiencia musical íntima.\r\n\r\nSonido curado, coctelería de autor\r\ny propuestas saludables.\r\nArte en vivo\r\ncomo parte de la atmósfera.\r\n\r\nTickets en Duty.','2026-02-12 00:56:19','2026-02-12 00:56:19','C. Arzobispo Portes 156,  Zona Colonial, Santo Domingo',NULL,NULL,NULL,'10201',NULL,NULL);
/*!40000 ALTER TABLE `event_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_countries`
--

DROP TABLE IF EXISTS `event_countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_countries` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `unquid` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_countries`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_countries` WRITE;
/*!40000 ALTER TABLE `event_countries` DISABLE KEYS */;
INSERT INTO `event_countries` VALUES
(1,'8','USA','usa','1',0,NULL,'2025-08-11 03:33:39','2025-12-15 15:53:12'),
(2,'22','الولايات المتحدة الأمريكية','الولايات-المتحدة-الأمريكية','1',1,NULL,'2025-08-11 03:33:51','2025-08-11 11:37:09'),
(4,'22','المملكة المتحدة','المملكة-المتحدة','1',2,NULL,'2025-08-11 03:34:09','2025-08-11 11:36:59'),
(6,'22','كندا','كندا','1',3,NULL,'2025-08-11 03:34:28','2025-08-11 11:36:51'),
(8,'22','أستراليا','أستراليا','1',4,NULL,'2025-08-11 03:34:48','2025-08-11 11:36:45'),
(10,'22','ألمانيا','ألمانيا','1',5,NULL,'2025-08-11 03:35:06','2025-08-11 11:36:37'),
(11,'8','Republica Dominicana','republica-dominicana','1',1,NULL,'2025-12-15 15:52:59','2025-12-15 15:52:59');
/*!40000 ALTER TABLE `event_countries` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_dates`
--

DROP TABLE IF EXISTS `event_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_dates` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) DEFAULT NULL,
  `start_date` varchar(255) DEFAULT NULL,
  `start_time` varchar(255) DEFAULT NULL,
  `end_date` varchar(255) DEFAULT NULL,
  `end_time` varchar(255) DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  `start_date_time` varchar(255) DEFAULT NULL,
  `end_date_time` datetime DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=59 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_dates`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_dates` WRITE;
/*!40000 ALTER TABLE `event_dates` DISABLE KEYS */;
INSERT INTO `event_dates` VALUES
(16,64,'2023-03-27','14:59','2023-03-28','14:59','1d ','2023-03-27 14:59:00','2023-03-28 14:59:00','2023-03-27 08:59:45','2023-04-30 06:05:39'),
(17,64,'2023-03-30','14:01','2023-03-31','14:59','1d 58m','2023-03-30 14:01:00','2023-03-31 14:59:00','2023-03-27 08:59:45','2023-04-30 06:05:39'),
(18,64,'2023-04-03','14:01','2023-04-06','14:00','2d 23h 59m','2023-04-03 14:01:00','2023-04-06 14:00:00','2023-03-27 08:59:45','2023-04-30 06:05:39'),
(19,65,'2023-03-30','11:39','2023-03-31','11:40','1d 1m','2023-03-30 11:39:00','2023-03-31 11:40:00','2023-03-28 05:41:51','2023-04-30 11:30:28'),
(20,65,'2023-04-01','11:40','2023-04-02','01:40','14h ','2023-04-01 11:40:00','2023-04-02 01:40:00','2023-03-28 05:41:51','2023-04-30 11:30:28'),
(23,65,'2023-04-30','17:32','2023-05-30','17:32','1mo 30d ','2023-04-30 17:32:00','2023-05-30 17:32:00','2023-04-30 11:30:28','2023-04-30 11:30:28'),
(24,67,'2023-05-01','11:51','2023-05-10','11:52','9d 1m','2023-05-01 11:51:00','2023-05-10 11:52:00','2023-05-01 05:53:43','2023-05-01 15:20:47'),
(25,67,'2023-05-11','23:52','2023-05-22','11:53','10d 12h 1m','2023-05-11 23:52:00','2023-05-22 11:53:00','2023-05-01 05:53:43','2023-05-01 15:20:47'),
(26,69,'2023-05-01','12:22','2023-05-10','13:22','9d 1h ','2023-05-01 12:22:00','2023-05-10 13:22:00','2023-05-01 06:24:39','2023-05-01 15:19:33'),
(27,69,'2023-05-12','12:26','2023-05-22','17:22','10d 4h 56m','2023-05-12 12:26:00','2023-05-22 17:22:00','2023-05-01 06:24:39','2023-05-01 15:19:33'),
(36,94,'2025-01-18','17:30','2025-01-20','20:30','2d 3h ','2025-01-18 17:30:00','2025-01-20 20:30:00','2023-05-06 11:28:41','2025-08-11 04:18:04'),
(49,112,'2023-05-09','17:09','2023-06-03','17:09','25d ','2023-05-09 17:09:00','2023-06-03 17:09:00','2023-05-08 11:12:59','2023-05-08 11:12:59'),
(50,112,'2023-05-10','17:10','2024-05-23','17:11','1y 379d 1m','2023-05-10 17:10:00','2024-05-23 17:11:00','2023-05-08 11:12:59','2023-05-08 11:12:59'),
(55,104,'2026-01-02','11:33','2030-08-27','11:31','4y 7mo 1697d 23h 58m','2026-01-02 11:33:00','2030-08-27 11:31:00','2023-05-15 05:29:01','2025-11-10 08:02:27'),
(57,116,'2023-09-22','03:11','2023-09-23','14:30','1d 11h 19m','2023-09-22 03:11:00','2023-09-23 14:30:00','2023-09-24 08:13:35','2024-08-24 21:55:02'),
(58,116,'2023-09-26','14:15','2023-09-27','14:16','1d 1m','2023-09-26 14:15:00','2023-09-27 14:16:00','2023-09-24 08:13:35','2024-08-24 21:55:02');
/*!40000 ALTER TABLE `event_dates` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_feature_sections`
--

DROP TABLE IF EXISTS `event_feature_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_feature_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_feature_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_feature_sections` WRITE;
/*!40000 ALTER TABLE `event_feature_sections` DISABLE KEYS */;
INSERT INTO `event_feature_sections` VALUES
(1,8,'Evento Features','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt','2022-06-06 23:24:33','2023-05-11 05:38:44'),
(2,9,'test arabic sdf','text arabic fdsa','2022-06-06 23:25:08','2022-06-06 23:25:16'),
(3,17,'ميزة الأحداث الرائعة','صفحة التي يقرأها. ولذلك يتم استخدام طريقة لوريم إيبسوم لأنها تعطي توزيعاَ طبيعياَ -إلى حد ما- للأحرف عوضاً عن استخدام','2023-01-31 05:48:01','2023-01-31 05:48:01'),
(4,22,'ميزات إيفينتو','ل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سق','2023-05-07 11:41:58','2023-05-11 05:38:35');
/*!40000 ALTER TABLE `event_feature_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_features`
--

DROP TABLE IF EXISTS `event_features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_features` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_features`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_features` WRITE;
/*!40000 ALTER TABLE `event_features` DISABLE KEYS */;
INSERT INTO `event_features` VALUES
(4,8,'fas fa-globe','Online Events','While lorem ipsum\'s still resembles classical Latin, it has no meaning whatsoever.',1,'2022-06-07 00:14:56','2023-05-11 05:25:09'),
(6,8,'fas fa-map-marked','Venue Events','Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing.',2,'2022-06-07 00:16:30','2023-05-11 05:24:27'),
(11,8,'fas fa-ticket-alt','Ticket Variations','Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing',3,'2023-05-07 11:48:45','2023-05-11 05:24:02'),
(12,8,'fas fa-qrcode','PWA Ticket Scanner','Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero.',5,'2023-05-07 11:51:56','2023-05-11 05:29:09'),
(13,8,'fas fa-headset','Support Tickets','Lorem ipsum is mostly a part of a Latin text by the classical author and philosopher Cicero.',6,'2023-05-07 11:54:11','2023-05-11 05:28:52'),
(17,8,'fas fa-hand-holding-usd','Low Commission Rate','Lorem ipsum dolor sit amet consectetur adipisicing elit. Praesentium vero eligendi nihil.',4,'2023-05-11 05:27:00','2023-05-11 05:29:00');
/*!40000 ALTER TABLE `event_features` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_images`
--

DROP TABLE IF EXISTS `event_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) DEFAULT NULL,
  `image` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=277 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_images`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_images` WRITE;
/*!40000 ALTER TABLE `event_images` DISABLE KEYS */;
INSERT INTO `event_images` VALUES
(9,NULL,'62b98c589565d.jpg','2022-06-27 04:54:16','2022-06-27 04:54:16'),
(10,NULL,'62b98c589565a.jpg','2022-06-27 04:54:16','2022-06-27 04:54:16'),
(11,NULL,'62b98c58c13ab.jpg','2022-06-27 04:54:16','2022-06-27 04:54:16'),
(12,NULL,'62b98c58c634d.jpg','2022-06-27 04:54:16','2022-06-27 04:54:16'),
(13,NULL,'62b98c5900f81.jpg','2022-06-27 04:54:17','2022-06-27 04:54:17'),
(14,NULL,'62b98c59019ad.jpg','2022-06-27 04:54:17','2022-06-27 04:54:17'),
(15,NULL,'62b98c5928677.jpg','2022-06-27 04:54:17','2022-06-27 04:54:17'),
(16,NULL,'62b98c592ec8f.jpg','2022-06-27 04:54:17','2022-06-27 04:54:17'),
(17,NULL,'62b98c594e479.jpg','2022-06-27 04:54:17','2022-06-27 04:54:17'),
(23,12,'62db792a6c818.jpg','2022-07-22 22:29:30','2022-07-22 22:32:20'),
(24,12,'62db792a6c7f1.jpg','2022-07-22 22:29:30','2022-07-22 22:32:20'),
(25,13,'62db7a63df567.jpg','2022-07-22 22:34:43','2022-07-22 22:37:47'),
(26,13,'62db7a63df622.jpg','2022-07-22 22:34:43','2022-07-22 22:37:47'),
(27,13,'62db7a64130ce.jpg','2022-07-22 22:34:44','2022-07-22 22:37:47'),
(28,14,'62db7eb7a2b9d.jpg','2022-07-22 22:53:11','2022-07-22 22:55:03'),
(29,14,'62db7eb7a4c84.jpg','2022-07-22 22:53:11','2022-07-22 22:55:03'),
(30,14,'62db7eb7cf18c.jpg','2022-07-22 22:53:11','2022-07-22 22:55:03'),
(46,NULL,'63b26d14b0745.jpg','2023-01-02 05:35:16','2023-01-02 05:35:16'),
(50,NULL,'63b417430d8bb.jpg','2023-01-03 11:53:39','2023-01-03 11:53:39'),
(51,NULL,'63b417df970ab.jpg','2023-01-03 11:56:15','2023-01-03 11:56:15'),
(57,NULL,'63b66899aeb4e.jpg','2023-01-05 06:05:13','2023-01-05 06:05:13'),
(119,NULL,'63d24331e3b98.jpg','2023-01-26 09:09:05','2023-01-26 09:09:05'),
(120,NULL,'63d24331e6257.jpg','2023-01-26 09:09:05','2023-01-26 09:09:05'),
(210,NULL,'6456350644d9b.jpg','2023-05-06 11:07:50','2023-05-06 11:07:50'),
(211,NULL,'6456350644d9b.jpg','2023-05-06 11:07:50','2023-05-06 11:07:50'),
(252,NULL,'68981fcfc6f9b.jpg','2025-08-09 22:27:59','2025-08-09 22:27:59'),
(257,NULL,'68e0c34cea7ec.jpg','2025-10-04 00:48:44','2025-10-04 00:48:44'),
(259,NULL,'68e0cb18d9019.jpg','2025-10-04 01:22:00','2025-10-04 01:22:00'),
(260,NULL,'690730714c408.jpg','2025-11-02 05:20:33','2025-11-02 05:20:33'),
(271,134,'694030a554abf.jpg','2025-12-15 16:00:37','2025-12-15 16:07:14'),
(272,NULL,'694e495cd2ef0.jpg','2025-12-26 08:37:48','2025-12-26 08:37:48'),
(273,135,'694e4e5144535.jpg','2025-12-26 08:58:57','2025-12-26 09:01:07'),
(274,136,'6958828f6a5b0.jpg','2026-01-03 02:44:31','2026-01-03 02:48:48'),
(275,139,'6987ca962c910.jpg','2026-02-07 23:28:22','2026-02-07 23:44:52'),
(276,140,'698d252d7d167.jpg','2026-02-12 00:56:13','2026-02-12 00:56:19');
/*!40000 ALTER TABLE `event_images` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `event_states`
--

DROP TABLE IF EXISTS `event_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `event_states` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) DEFAULT NULL,
  `country_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `event_states`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `event_states` WRITE;
/*!40000 ALTER TABLE `event_states` DISABLE KEYS */;
INSERT INTO `event_states` VALUES
(1,8,1,'New York','new-york','1',1,'2025-08-11 03:36:38','2025-08-11 11:39:42'),
(2,8,3,'Greater London','greater-london','1',2,'2025-08-11 03:36:57','2025-08-11 03:36:57'),
(3,8,5,'Ontario','ontario','1',3,'2025-08-11 03:37:09','2025-08-11 03:37:09'),
(4,8,7,'New South Wales','new-south-wales','1',4,'2025-08-11 03:37:26','2025-08-11 03:37:26'),
(5,8,9,'Berlin','berlin','1',5,'2025-08-11 03:37:45','2025-08-11 03:37:45'),
(6,8,9,'Bavaria','bavaria','1',6,'2025-08-11 04:00:28','2025-08-11 04:00:28'),
(7,8,9,'Hamburg','hamburg','1',7,'2025-08-11 04:00:40','2025-08-11 04:00:40'),
(8,8,3,'Scotland','scotland','1',8,'2025-08-11 04:01:02','2025-08-11 04:01:02'),
(9,8,1,'Texas','texas','1',9,'2025-08-11 04:01:25','2025-08-11 04:01:25'),
(12,22,2,'نيويورك','نيويورك','1',1,'2025-08-11 03:36:38','2025-08-11 11:40:16'),
(13,22,4,'لندن الكبرى','لندن-الكبرى','1',2,'2025-08-11 03:36:57','2025-08-11 11:38:40'),
(14,22,6,'أونتاريو','أونتاريو','1',3,'2025-08-11 03:37:09','2025-08-11 11:38:33'),
(15,22,8,'نيو ساوث ويلز','نيو-ساوث-ويلز','1',4,'2025-08-11 03:37:26','2025-08-11 11:38:26'),
(16,22,10,'برلين','برلين','1',5,'2025-08-11 03:37:45','2025-08-11 11:38:18'),
(17,22,10,'بافاريا','بافاريا','1',6,'2025-08-11 04:00:28','2025-08-11 11:38:12'),
(18,22,10,'هامبورغ','هامبورغ','1',7,'2025-08-11 04:00:40','2025-08-11 11:38:05'),
(19,22,4,'اسكتلندا','اسكتلندا','1',8,'2025-08-11 04:01:02','2025-08-11 11:37:56'),
(20,22,2,'تكساس','تكساس','1',9,'2025-08-11 04:01:25','2025-08-11 11:37:48'),
(21,22,6,'نوفا سكوشا','نوفا-سكوشا','1',10,'2025-08-11 04:01:50','2025-08-11 11:37:43'),
(22,22,6,'كيبيك','كيبيك','1',11,'2025-08-11 04:02:10','2025-08-11 11:37:22'),
(23,8,11,'Santo Domingo','santo-domingo','1',0,'2025-12-15 15:53:52','2025-12-15 15:53:52');
/*!40000 ALTER TABLE `event_states` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `events` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `organizer_id` bigint(20) DEFAULT NULL,
  `venue_id` bigint(20) unsigned DEFAULT NULL,
  `owner_identity_id` bigint(20) unsigned DEFAULT NULL,
  `venue_identity_id` bigint(20) unsigned DEFAULT NULL,
  `thumbnail` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT '1',
  `age_limit` int(11) NOT NULL DEFAULT 0 COMMENT '0 means all ages',
  `date_type` varchar(20) DEFAULT NULL,
  `countdown_status` int(11) DEFAULT 1,
  `start_date` date DEFAULT NULL,
  `start_time` varchar(255) DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `end_time` varchar(255) DEFAULT NULL,
  `end_date_time` datetime DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `is_featured` varchar(255) NOT NULL DEFAULT 'no',
  `latitude` varchar(255) DEFAULT NULL,
  `longitude` varchar(255) DEFAULT NULL,
  `instructions` text DEFAULT NULL,
  `meeting_url` varchar(255) DEFAULT NULL,
  `ticket_logo` varchar(255) DEFAULT NULL,
  `ticket_image` text DEFAULT NULL,
  `ticket_slot_image` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `events_venue_id_foreign` (`venue_id`),
  KEY `events_owner_identity_id_index` (`owner_identity_id`),
  KEY `events_venue_identity_id_index` (`venue_identity_id`),
  CONSTRAINT `events_owner_identity_id_foreign` FOREIGN KEY (`owner_identity_id`) REFERENCES `identities` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_venue_id_foreign` FOREIGN KEY (`venue_id`) REFERENCES `venues` (`id`) ON DELETE SET NULL,
  CONSTRAINT `events_venue_identity_id_foreign` FOREIGN KEY (`venue_identity_id`) REFERENCES `identities` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=141 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
INSERT INTO `events` VALUES
(129,31,NULL,NULL,NULL,'1765814610.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:03:30','2025-12-15 16:03:30','venue','yes','18.4681175','-69.8896409',NULL,NULL,NULL,NULL,NULL),
(130,31,NULL,NULL,NULL,'1765814695.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:04:55','2025-12-15 16:04:55','venue','yes','18.4681175','-69.8896409',NULL,NULL,NULL,NULL,NULL),
(131,31,NULL,NULL,NULL,'1765814700.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:05:00','2025-12-15 16:05:00','venue','yes','18.4681175','-69.8896409',NULL,NULL,NULL,NULL,NULL),
(132,31,NULL,NULL,NULL,'1765814717.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:05:17','2025-12-15 16:05:17','venue','yes','18.4681175','-69.8896409',NULL,NULL,NULL,NULL,NULL),
(133,31,NULL,NULL,NULL,'1765814727.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:05:27','2025-12-15 16:05:27','venue','yes','18.4681175','-69.8896409',NULL,NULL,NULL,NULL,NULL),
(134,31,NULL,NULL,NULL,'1765814834.jpg','1',0,'single',1,'2025-12-20','20:00','8h ','2025-12-21','04:00','2025-12-21 04:00:00','2025-12-15 16:07:14','2025-12-15 17:02:11','venue','yes','18.4681175','-69.8896409','<p><strong>Comunidad Hidden – Acceso y Beneficios</strong></p>\n<ul>\n<li>\n<p>Entrada online: <strong>RD$400</strong></p>\n</li>\n<li>\n<p>Entrada en puerta: <strong>RD$800</strong></p>\n</li>\n</ul>\n<p><strong>Miembros Comunidad Hidden</strong><br>50% OFF → <strong>RD$200</strong></p>\n<p>El código de descuento:</p>\n<ul>\n<li>\n<p>Se <strong>actualiza diariamente</strong></p>\n</li>\n<li>\n<p>Se publica <strong>exclusivamente</strong> en el grupo privado de WhatsApp</p>\n</li>\n<li>\n<p>Deja de funcionar <strong>viernes 19</strong></p>\n</li>\n</ul>\n<p> Acceso al grupo habilitado <strong>hasta el día antes del evento</strong></p>\n<p> Únete aquí:<br><a class=\"decorated-link\" href=\"https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H\">https://chat.whatsapp.com/EdqwxrqbFVt0qtYRL8rz3H</a></p>\n<p> Compra con cupón sin estar en el grupo = <strong>pago de diferencia en puerta (RD$600)</strong></p>',NULL,'1765818131941.png','1765818131583.jpg',NULL),
(135,31,NULL,NULL,NULL,'1766739667.png','1',0,'single',1,'2025-12-31','22:00','9h ','2026-01-01','07:00','2026-01-01 07:00:00','2025-12-26 09:01:07','2025-12-29 01:14:21','venue','yes','18.475163','-69.885985','',NULL,'1766969657392.jpg','1766970861688.png',NULL),
(136,31,NULL,NULL,NULL,'1767408528.jpeg','1',0,'single',1,'2026-01-03','20:00','8h ','2026-01-04','04:00','2026-01-04 04:00:00','2026-01-03 02:48:48','2026-01-03 16:56:29','venue','yes','18.4751562','-69.8859758','',NULL,'1767414238655.jpg','1767409417664.jpeg',NULL),
(137,31,NULL,NULL,NULL,'1770507854.png','1',0,'single',1,'2026-02-28','20:00','7h ','2026-03-01','03:00','2026-03-01 03:00:00','2026-02-07 23:44:14','2026-02-07 23:44:14','venue','yes','18.4750884','-69.8859278',NULL,NULL,NULL,NULL,NULL),
(138,31,NULL,NULL,NULL,'1770507866.png','1',0,'single',1,'2026-02-28','20:00','7h ','2026-03-01','03:00','2026-03-01 03:00:00','2026-02-07 23:44:26','2026-02-07 23:44:26','venue','yes','18.4750884','-69.8859278',NULL,NULL,NULL,NULL,NULL),
(139,31,NULL,NULL,NULL,'1770507892.png','1',0,'single',1,'2026-02-28','20:00','7h ','2026-03-01','03:00','2026-03-01 03:00:00','2026-02-07 23:44:52','2026-02-08 00:07:12','venue','yes','18.4750884','-69.8859278',NULL,NULL,NULL,NULL,NULL),
(140,31,NULL,NULL,NULL,'1770857779.jpg','1',0,'single',1,'2026-03-01','17:00','6h 59m','2026-03-01','23:59','2026-03-01 23:59:00','2026-02-12 00:56:19','2026-02-12 00:56:19','venue','yes','18.469624','-69.886372',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `faqs`
--

DROP TABLE IF EXISTS `faqs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `faqs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL,
  `serial_number` mediumint(8) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `faqs_language_id_foreign` (`language_id`),
  CONSTRAINT `faqs_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faqs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `faqs` WRITE;
/*!40000 ALTER TABLE `faqs` DISABLE KEYS */;
INSERT INTO `faqs` VALUES
(5,8,'What is an event management and ticket selling system?','An event management and ticket selling system is a software platform that helps event organizers manage all aspects of their events, including ticket sales, registration, marketing, and logistics.',1,'2021-06-26 00:35:52','2023-05-08 06:08:55'),
(6,8,'How does an event management and ticket selling system work?','An event management and ticket selling system typically allows event organizers to create event pages, sell tickets online, track registration and attendance, collect payments, and communicate with attendees through email or social media.',2,'2021-06-26 00:38:14','2023-05-08 06:09:12'),
(7,8,'What are the benefits of using an event management and ticket selling system?','The benefits of using an event management and ticket selling system include increased efficiency, reduced administrative workload, improved attendee experience, better data management, and increased revenue potential.',3,'2021-06-26 00:39:02','2023-05-08 06:09:28'),
(16,8,'What types of events can be managed with an event management and ticket selling system?','An event management and ticket selling system can be used for a wide range of events, including conferences, trade shows, concerts, festivals, sports games, and fundraising events.',4,'2021-06-26 00:35:52','2023-05-08 06:09:43'),
(17,8,'How can event organizers promote their events using an event management and ticket selling system?','Event organizers can promote their events using an event management and ticket selling system by creating customized event pages, sending targeted emails to potential attendees, and leveraging social media to reach a wider audience.',5,'2021-06-26 00:38:14','2023-05-08 06:10:00'),
(18,8,'How can attendees purchase tickets through an event management and ticket selling system?','Attendees can purchase tickets through an event management and ticket selling system by visiting the event page, selecting the desired ticket type and quantity, and completing the checkout process online.',6,'2021-06-26 00:39:02','2023-05-08 06:10:14'),
(22,8,'What payment methods are typically accepted by an event management and ticket selling system?','An event management and ticket selling system may accept various payment methods, such as credit cards, debit cards, PayPal, or other online payment systems.',7,'2023-05-08 06:10:29','2023-05-08 06:10:29'),
(23,8,'Can an event management and ticket selling system help manage event logistics, such as venue setup and staffing?','Yes, some event management and ticket selling systems offer features to help event organizers manage logistics, such as creating seating charts, assigning staff roles, and tracking equipment rentals.',8,'2023-05-08 06:10:44','2023-05-08 06:10:44'),
(24,8,'How can event organizers use data collected through an event management and ticket selling system?','Event organizers can use data collected through an event management and ticket selling system to analyze attendance patterns, track marketing effectiveness, and make informed decisions about future events.',9,'2023-05-08 06:10:57','2023-05-08 06:10:57'),
(25,8,'Are there any drawbacks to using an event management and ticket selling system?','Some potential drawbacks of using an event management and ticket selling system include upfront costs, ongoing fees, potential technical issues, and the need for staff training to use the system effectively.',10,'2023-05-08 06:11:09','2023-05-08 06:11:09');
/*!40000 ALTER TABLE `faqs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `fcm_tokens`
--

DROP TABLE IF EXISTS `fcm_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `fcm_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `message_title` varchar(255) DEFAULT NULL,
  `message_description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `booking_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fcm_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `fcm_tokens` WRITE;
/*!40000 ALTER TABLE `fcm_tokens` DISABLE KEYS */;
INSERT INTO `fcm_tokens` VALUES
(1,NULL,NULL,NULL,NULL,NULL,'2025-10-18 07:22:51','2025-10-18 07:22:51',NULL),
(2,33,NULL,'web','Paymant status','Payment Success','2025-10-18 07:29:16','2025-10-18 07:29:16',NULL),
(3,NULL,NULL,NULL,NULL,NULL,'2025-10-27 02:07:28','2025-10-27 02:07:43',NULL),
(4,33,NULL,NULL,NULL,NULL,'2025-10-27 02:07:59','2025-10-27 02:08:11',NULL),
(5,NULL,NULL,'web','Payment Status Updated','Your current payment status completed','2025-10-28 00:37:03','2025-10-28 00:37:03',NULL),
(7,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:46:20','2025-10-28 00:46:20',NULL),
(8,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:48:05','2025-10-28 00:48:05',NULL),
(9,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:50:00','2025-10-28 00:50:00',NULL),
(10,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:52:48','2025-10-28 00:52:48',NULL),
(11,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:53:31','2025-10-28 00:53:31',NULL),
(12,NULL,'44','web','Payment Status Updated','Your current payment status completed','2025-10-28 00:54:44','2025-10-28 00:54:44',NULL),
(13,33,'123456',NULL,NULL,NULL,'2025-10-28 05:03:30','2025-10-28 05:03:30',NULL),
(14,33,'123456','web','Event Booking Complete','Your current payment status pending','2025-11-03 03:28:02','2025-11-03 05:22:38',NULL),
(15,33,'123456','web','Event Booking Complete','Your current payment status completed','2025-11-03 03:29:02','2025-11-03 05:22:38',NULL),
(16,33,'12345655',NULL,NULL,NULL,'2025-11-03 05:22:45','2025-11-03 05:22:45',NULL),
(17,33,'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU','web','Event Booking Complete','Your current payment status pending','2025-11-03 06:27:12','2025-11-03 06:27:12',190),
(18,33,'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU','web','Payment Status Updated','Your current payment status completed','2025-11-03 06:31:47','2025-11-03 06:31:47',190),
(19,33,'cfkl1p3WT7ywTI3qsF2tdD:APA91bEMUg675BbgYa2lF36KcWlryCtO8Cb7CJyvLrrD3dqyDGXGBB5_CzQG7L_K6EI715h8M6mof_ADzuHnYI2LuQuUIouGENjX5VaU6jIw2gvPo6lhTJU','web','Payment Status Updated','Your current payment status completed','2025-11-03 06:34:25','2025-11-03 06:34:25',190),
(20,NULL,'cElZtOzGSXaMiWgB1EdijH:APA91bElA4Ok4-PNuzILSOSD1LsrkMHjuDD9qSgk0agd5U1wUTl4RMcFPAg9jCxDDioop8WSEJEl9nRoXhnAlpXaKi6ttnBP0Xxf4ex0qUbGYNb88bmWVB8',NULL,NULL,NULL,'2025-12-17 06:59:08','2025-12-17 06:59:08',NULL),
(21,NULL,'dReT7xy4TGWna_Z_PScm2c:APA91bGChGDYquJFl3Vp0ZuyfaD0rZXhyIS2PlrzgQ5rIKDwdWo-47KlVWuEtMNjyM6p0hQQkf8dKUHYaB-1MFWZTiiK1WGCY8k4T2bdGT9pS_PI8GlYz4w',NULL,NULL,NULL,'2025-12-17 07:28:22','2025-12-17 07:28:22',NULL),
(22,43,'dReT7xy4TGWna_Z_PScm2c:APA91bGChGDYquJFl3Vp0ZuyfaD0rZXhyIS2PlrzgQ5rIKDwdWo-47KlVWuEtMNjyM6p0hQQkf8dKUHYaB-1MFWZTiiK1WGCY8k4T2bdGT9pS_PI8GlYz4w','web','Event Booking Complete','Your current payment status pending','2025-12-17 07:50:27','2025-12-17 07:50:27',215),
(23,NULL,'fFcVSVi0QCyWixYAAU5sYd:APA91bH1iQIeP38jw2o8LVdLUqf5wTF8ffb-kXsOr-oWB2uEPN8ryxFZ1LfVCDeas7KNCzfMJzuueDzPu083klka9z1zXFXMYcnhEvQ5byKDIyEgUtuQWxs',NULL,NULL,NULL,'2025-12-17 08:04:49','2025-12-17 08:04:49',NULL),
(24,NULL,'fOr1WtM4QrC00ic3ec9hZA:APA91bHikucEHeaGU17FC7UqaGhB5Dyp9rpNvqEO2OvLR9Hsvel-VQnFqPI0EwrlrOkwwb7WzCQEVKhiME72Cb-RjGdvPLbX8VU0EdU24my8b4x_Utyz0fI',NULL,NULL,NULL,'2025-12-17 08:12:09','2025-12-17 08:12:09',NULL),
(25,43,'fPDCeI37pUEjoAkFXvX0pO:APA91bEkmV_mZ5py7U4Q-3HSwofjacQu61kGfI1nm8AXG4ESQdp1CP-00Afq9ejK8aBai6Tm_z05hREtpSi9i2BsgDubSJekY4iI5owp5zfA95ncFVHEmzc','ios',NULL,NULL,'2026-02-26 04:48:45','2026-02-26 04:48:45',NULL);
/*!40000 ALTER TABLE `fcm_tokens` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `features`
--

DROP TABLE IF EXISTS `features`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `features` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `background_color` varchar(255) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `text` text NOT NULL,
  `serial_number` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `features`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `features` WRITE;
/*!40000 ALTER TABLE `features` DISABLE KEYS */;
INSERT INTO `features` VALUES
(6,8,'0066FF','fas fa-book-reader','Highly Qualified Mentors & Instructors','See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.',3,'2021-10-11 00:11:50','2022-05-15 00:03:40'),
(7,8,'8976FF','fas fa-book','Quizzes, Videos, Code Snippets & More','See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.',2,'2021-10-11 00:13:02','2022-05-15 00:02:41'),
(8,8,'30BCFF','fas fa-chalkboard-teacher','Course Completion Certificate','See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.',1,'2021-10-11 00:13:44','2022-05-15 00:01:54'),
(12,8,'2ECC71',NULL,'Drag & Drop Lesson Contents Decoration','See the E Learning Tools your competitors are already using - Start Now! Get App helps more than 800k businesses find the best software for their needs.',4,'2022-05-15 00:05:22','2022-05-15 00:06:29');
/*!40000 ALTER TABLE `features` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `followers`
--

DROP TABLE IF EXISTS `followers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `followers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) unsigned NOT NULL,
  `following_id` bigint(20) unsigned NOT NULL,
  `following_type` varchar(255) NOT NULL,
  `organizer_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `followers_customer_id_organizer_id_unique` (`customer_id`,`organizer_id`),
  KEY `followers_organizer_id_foreign` (`organizer_id`),
  CONSTRAINT `followers_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `followers_organizer_id_foreign` FOREIGN KEY (`organizer_id`) REFERENCES `organizers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `followers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `followers` WRITE;
/*!40000 ALTER TABLE `followers` DISABLE KEYS */;
/*!40000 ALTER TABLE `followers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `footer_contents`
--

DROP TABLE IF EXISTS `footer_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `footer_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `footer_background_color` varchar(255) DEFAULT NULL,
  `about_company` text DEFAULT NULL,
  `copyright_text` text DEFAULT NULL,
  `footer_logo` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `footer_texts_language_id_foreign` (`language_id`),
  CONSTRAINT `footer_texts_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `footer_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `footer_contents` WRITE;
/*!40000 ALTER TABLE `footer_contents` DISABLE KEYS */;
INSERT INTO `footer_contents` VALUES
(1,8,'000000','<p>.</p>','<p>Copyright ©{year}. All Rights Reserved.</p>','1765000986.png','2021-06-19 05:57:47','2025-12-15 16:19:22');
/*!40000 ALTER TABLE `footer_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `fun_fact_sections`
--

DROP TABLE IF EXISTS `fun_fact_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `fun_fact_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `background_image` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fun_fact_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `fun_fact_sections` WRITE;
/*!40000 ALTER TABLE `fun_fact_sections` DISABLE KEYS */;
INSERT INTO `fun_fact_sections` VALUES
(3,8,'61befc8312cee.jpg','Some Fun Facts from Us','2021-10-07 03:23:12','2021-12-19 03:33:55');
/*!40000 ALTER TABLE `fun_fact_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `gooogle_calendar_infos`
--

DROP TABLE IF EXISTS `gooogle_calendar_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `gooogle_calendar_infos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `google_calendar_event_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gooogle_calendar_infos`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `gooogle_calendar_infos` WRITE;
/*!40000 ALTER TABLE `gooogle_calendar_infos` DISABLE KEYS */;
/*!40000 ALTER TABLE `gooogle_calendar_infos` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `guests`
--

DROP TABLE IF EXISTS `guests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `guests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `endpoint` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=91 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guests`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `guests` WRITE;
/*!40000 ALTER TABLE `guests` DISABLE KEYS */;
INSERT INTO `guests` VALUES
(7,'https://fcm.googleapis.com/fcm/send/diZDc7939-k:APA91bFXdlYgz6msLEKBUM3NaoM1fdH1Z7rURz[…]KOTBNqZbKyaPJ-Qjn9JpOLzVasqpIIonOPiQHp3YiV540-UJNhvh1LSdyi8','2025-10-29 07:41:19','2025-10-29 07:41:19'),
(8,'https://fcm.googleapis.com/fcm/send/dPnvaQfjZmY:APA91bFKyN3JcgGME6ZrIMuxy1b6H1L2TCG9N2lfBI6lcogRmeziZtfB2fOCOW7NJG6HcPk2lMu0xnnye1wqYtoBl5bvekqIY9KNH-RToHeTXQ6gIaZ9S3lkTuWrDMQYRcWUfUiOmhaI','2025-10-29 07:44:42','2025-10-29 07:44:42'),
(9,'https://fcm.googleapis.com/fcm/send/eUF90OisF2U:APA91bHloRcT7GAh0i6GWngRhJIh-OHUXCIqLowa-HAdvxu2XpZTgdfzCPHzYM7pJK5wwTufedyGm2ocjLkNfSPtk3toEa5nrsMcbmZUVaXdAzXNnzU4mNq4zVlpYtt1B0E9f_Y3RFDB','2025-11-02 05:06:11','2025-11-02 05:06:11'),
(10,'https://fcm.googleapis.com/fcm/send/faKkK9nx67A:APA91bERXmwrqZivBOcIjz1OlixofdUiikI0Qh9dkzOW2S51FI0Y76Akf70KX0P64sgvefAKL_ggFVlBhN29J89dwjvFc53jP1mqN45MG7LEIej4suEL-t48_Z09e6rpLX-Jlttneygu','2025-11-03 03:27:11','2025-11-03 03:27:11'),
(11,'https://fcm.googleapis.com/fcm/send/fDXXEc0DzIY:APA91bGWBfzFjM7p1YD9SuhF8DvJsVdwRYGhFer21viIJhCmfVFNsYlHSlV61Xi8D0GWKA84naNFTE3nkg7D8CIzhFQAad_RoRu8wuLWhoJYYzYDa7g45VAF-jZJeUMxtJV49c97bt6K','2025-11-06 03:53:06','2025-11-06 03:53:06'),
(12,'https://fcm.googleapis.com/fcm/send/d_wJzTj2InY:APA91bGkg9h1l2rvZKqtKwszwCSRsUg5byk2vJT_wnkHOfJ5W5oEu5kc6w5QhmgfgJBptACpYlU9mOpwzsuWJkd3ypGb5qIi15h55DTn6Em3vR_eW8FnnQjh6CHb1I_PYzd6uJisx89l','2025-11-08 01:28:56','2025-11-08 01:28:56'),
(13,'https://fcm.googleapis.com/fcm/send/eEVDuoYjbyw:APA91bE69Dvppa8x8H7MLm_sAXW-CeA3lv2hwKRU9KWQew2OoTnTvtgB2SSe_bp-7b6YdJ_L0tyVDAPVR-cvpiiN9ivyU5sfZZaYb2B1sU7J7YeY6zV6uOPU66lzi43OVfrR3pPdRi3Y','2025-11-08 04:37:29','2025-11-08 04:37:29'),
(14,'https://fcm.googleapis.com/fcm/send/fyqQImbJth8:APA91bHmbK6jxzev-d7dEc12xuTHkgZZIEP96fndr0tomw8PfZDzPBrTJnx6qY0XAjbjv9zZbXoAlf3EK7x8OGv_QCyfJWFzWgAYO9XcqMRJ-KCvU7bbtTY6XAVRHbujL7qJSeJo1yC1','2025-11-08 07:28:28','2025-11-08 07:28:28'),
(15,'https://fcm.googleapis.com/fcm/send/cEjVVc6iP54:APA91bFzWtZ5M77jyBwiYKbQQus6RIYUyZjuQ68wIekQOdRpAIhpV6LAVWsc1rkpokRdya2tU-2NFjzxek3yQTKi1StM-ae2bVfOOJL-4ezoDDcM_pai5ZuvgV8EXndSKjxjeYJQT1tU','2025-11-08 07:54:17','2025-11-08 07:54:17'),
(16,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAiUTQvCUbu8U3EWwLPf0peJgy0D4GzQ0gZZrWHVWPZmEcSEs7R1kZwipD2hCWETCZGJTtGD1IIzb8IYYNGpqOgTcfXa3xOzP3A9VKMP092Zl4znSvLaEPp6d%2bWGKFI2jbZrwbzDxnY%2fce318Uit3UyAFCW5BIGfGJeVBa8oldx9A4RaepWUsnq7GuYNiszvO2u4SzLVnz3ysYs9YLPqYjdGSG92%2b7amowcsV3fEC%2bTpSdtWDf9VM%2bacl3rSK41%2fAP6E6NCYt5sKg%2bHefXZrNLgVL69S%2bIdxDmpl4lRy5%2fzLxwSnTdsGla7wnYNGlL%2bIhI%3d','2025-12-15 14:50:23','2025-12-15 14:50:23'),
(17,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAOoAkAPjDOr6S6oJgJfPO6c3pj1JDZeL3Fv5cRN5%2fehGHw%2bYketKe%2fLgHoGytVa7eaMW8Y6xpFwZmUL%2bl5Qu4aKNnBM4Ae%2bC5iw74KFUx%2fICulyBrqpe4oWehdxOIKs5IT0sS0XPYyl5fbS8u0IfZR6BmQL55RBl5SOijpO%2fUjExUgVW%2bAa2GI5jiEBn2RYMGalV8dQIYTSH%2bpWdIdpx1DXYgNz2QuKBhD6Bud9BJXhD4jG5ZL0igz9OsC72SnBdeVRuUzansrZ8Sq%2bfqZPklIGc1qhtd4ePAJw5FA9f8FnfQTEjHI39fznD4JN1yRgNU%3d','2025-12-15 14:52:06','2025-12-15 14:52:06'),
(18,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAADpOw5xd2ml%2f9dIf4v2VzyFPfRCh%2bALBiWn%2fqNu5hX6R7eC78ErGne%2bQWSVDXnm2PUeGF6%2fIBk7IOw9YBDDvNryox%2fntl4%2froXPGLiwSXV7DEnaxrDSHLS7p3%2f%2bLAGsDhn84veRmlSb3vkhSqqmWZBkLYBr1RcPvmLfDwzexAbjwyj1kjRneGXp3Lbw%2fhHzlbSBw6joPLdG3hZ%2bOdrbWdYPNqmPQPeG7dtnBxSubf4LAvtGvUWUv%2f2%2b945f4AWAvkbG0JjAfQgcVu6XERunUxrfDpl4xtSGAmXK7WQ2Q5rZqpFGal86MOc4Y7QbpjmFlKE%3d','2025-12-15 16:07:39','2025-12-15 16:07:39'),
(19,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAuYSzc2M5bnf6egZ8r7s5y%2fdORMDfNInSh3nfk85KH5M4iLpunduXYhMGuSt%2bJ0NpNVW9e1jtxL05ejMtppLLGiVkGEEhkQF%2b2mCPWg8Pt83qDcKWLXtsSvFRDWYdXugpXuV2kcxwmhcRRPEY23IoX6GR%2fLo%2b7qoGHI2nZriGSYa48LP8AOfu%2f7DH%2b9usB4ptPvdAik%2f9Lfvi%2fEmSc4JxC4Xvns2fm90PLSLudbT22v28H3iUUV9ngbjh6zHVeG3uVWZUlGM3uBAlRRTSHh0w0RROECpBY26GjTSrS3PlkLF0iMRnU53N30X8u7YeZSEE%3d','2025-12-15 16:33:01','2025-12-15 16:33:01'),
(20,'https://fcm.googleapis.com/fcm/send/f7KK0BvXNIU:APA91bGLv7UHYrT3PoL1I7IsJLWx-NPk78AidiaokO77UgrD9m7c8WjYmp04SHpmMJjX0QLQrhT75UzYZ0Yb3S7X0phQkoAJZ0O6cAJLiqTUn2uBD0Cw1kdEn6gnjwK9PMquVCcDCrdY','2025-12-15 17:55:33','2025-12-15 17:55:33'),
(21,'https://fcm.googleapis.com/fcm/send/fZ93na6oN80:APA91bE-dyEufA2v1-Plyd_ZOIxim_KST9Z5c7kwgqZjR7f1Ua-YEpctqezQyCg8c-zpuCTeiNZt9MxT378LDypwL1BOcGtkEdzMKIuGRcmQtsK2UDy-XPyZDOvIln_JmwNe118FKRRH','2025-12-15 17:56:07','2025-12-15 17:56:07'),
(22,'https://fcm.googleapis.com/fcm/send/fWv6yCXKBn0:APA91bF71mYhYvlywW0afoeycaRg_7ZiZ42X4WsyycnmujzNscUm3PPTLfdqROQZ5YEIsg-EZtlf6xZ-VD9RY8CWAjmy6lQXRtVJZV5ZXNf9XfQPhizZmHXdWrKbbhn7uCtgmKTW0JF8','2025-12-15 17:56:36','2025-12-15 17:56:36'),
(23,'https://fcm.googleapis.com/fcm/send/e-WyZH4hyIQ:APA91bG8mHycrgSadIqU5AQ4Y7oYdVojfItWV3oHwP-qNjH0D3Ss6HdQYiwIStf7FhVPhcy5C4xa6ehUM7EKwkrbMHt4IIGPHOtZ4LHdNQ7plnSeeI4WtZvYWDDbdMGgO3ZvFCOeGe-b','2025-12-15 17:56:44','2025-12-15 17:56:44'),
(24,'https://fcm.googleapis.com/fcm/send/dQ2-cuK65DI:APA91bHv78tupqMgevWUuNrYgovRJR4AsSKYlAo-qZBp1ThOAynEKq5jRJhaDLWIU-w6tzyhD2OPunjY3k2RRLfGKTwzwQB44PZD1EgBRkJtbdnmFhDIRhmDti4SYmjkURhPQYOKVIO2','2025-12-15 17:59:16','2025-12-15 17:59:16'),
(25,'https://fcm.googleapis.com/fcm/send/efZgJ93ZkhI:APA91bH_RNNEAE4sHsj_RBEp2BBYjPq-fmDEyOxSJvCxg3-K5DmrenZQkZB1OShSsKQSdUht_ipdZKIwqDgyyrYR03OzWG1aQOzAiHWn_9EjV-zVQxkIkzZbWowgIoslp5ACJqX8dwj_','2025-12-15 19:05:52','2025-12-15 19:05:52'),
(26,'https://fcm.googleapis.com/fcm/send/fjEmK3l61LU:APA91bFwPpNpbwehjSz5Yy3-oeDVdGHggXKXyNARFKl8XNlXs-AOTdpPDjoy9fmUw6QLo7fWLbqUi6L9yICF8NGwsqTQ1C06fqDhy2tHwMtpSvwLl-2Zfng064z0suVIeb3nbiIDTgTs','2025-12-15 19:06:47','2025-12-15 19:06:47'),
(27,'https://fcm.googleapis.com/fcm/send/d7paDujYMMg:APA91bGQaTkKUjdsTrEXNRFY9aOu5pBHcwPL19Mo3tJi9s4vf4Il9jETLo1HHwylnhzjDiigW4_T9UKElznCqkkTJsLZErPZdLdQEezMwV3cJMTSYqedmecOHztVCUToqj4QRppmj8sr','2025-12-16 18:51:40','2025-12-16 18:51:40'),
(28,'https://fcm.googleapis.com/fcm/send/fOJhs4Dc2h4:APA91bGNTtNwMn6gEZxqtibG7jXDs-MS-9OH6EgFLTXaDgyBMjzV4gDY5H4_jLwy4PrvOaPw5fAwBNv5C-l82onCmmadTvQYr23d88-9kCj4M1oCIBQVH1KfW_DBureLqmkK5BWMgp1z','2025-12-16 19:19:11','2025-12-16 19:19:11'),
(29,'https://fcm.googleapis.com/fcm/send/eJhI0emfUKM:APA91bEjm1weYGP_SogfQy3R20aehYcscvdimhCQwoOCFMTRKkDAeW2kSPtaV2pWbBc8ymbL2Cx63SEkFZZq8vU-DFHZghYi7GAtpWj1zyilLPLJ-xkA7lzDAJVeTkR7LOBJveKajY0p','2025-12-16 19:33:19','2025-12-16 19:33:19'),
(30,'https://fcm.googleapis.com/fcm/send/cdyn6ssgWfU:APA91bF3zWmeeklCK77GWNZYm-2Y59oZ4m3gYNa3wPorn-salj0ZNb_YNn-USFAwKbRZtP06UUSpImp7CvaDqbSeizGm6zQMkgCAyg3HMEWPQ7DsGnkR8WCDy3bOVrQ0iNA6BZNe57p-','2025-12-16 19:57:53','2025-12-16 19:57:53'),
(31,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAABNyLhWxoFGZEiUiCd9UhCbhskRJB4%2f%2fBcsDFLrVFSKdGrazXNf18Ww2zqE0dbTM8rXiNzWIb0CUDHoe4%2fAqtTxQsEfJexhzxYMDJWopnrrC%2b%2fh01ArcI3rOdTa8pLUsgh47mBdx82hrqtBwJWpZXljrKA%2b5J3TE6v4gkT1uypF1tZOXCn0kAcModWIkcLG%2btKks8NHW4UT78Vj26KSNcc%2bjNznG%2fZWZE1OkLWudXfQxCEe3tXnGO5nmVbO9GvInJZDmjLIRxOu2lBA5oJjxoLRol6P6UQP9YhKsHr%2fj37Kxa4yaPh522FoCdZ%2b6G%2bCCbI%3d','2025-12-17 06:29:28','2025-12-17 06:29:28'),
(32,'https://fcm.googleapis.com/fcm/send/dXQjWNIDBfE:APA91bEYDy0pMeMZXm7EefRgpb1YPKRs0ioW5Hp1-VmpTx3S-4rbhI2pIDkxm1zF_cHNVPB1Yv1j2ZAXKt5l4EV0nkXQK8n6mIJOmuA412J-NVOuGU-sKk6xRsOm8E96zvwThIhlXNIS','2025-12-20 00:45:53','2025-12-20 00:45:53'),
(33,'https://fcm.googleapis.com/fcm/send/dpU7V2AhSMw:APA91bHsoYewTK1PzdWILSeXbQE5oCE80PpwcjkToEgoMJndNjDSh8gpzcOp6zVOROIHFDTfUBK-Z25WiNR_C9KLM3CoUPMhBCyWsBeeDY7gBNJgk3bVtW6cGkT-PlBJWG-WeSEB5lTg','2025-12-20 05:14:15','2025-12-20 05:14:15'),
(34,'https://fcm.googleapis.com/fcm/send/cgehezkBlCA:APA91bGBgnc9QnsM5pPI2x97iWMS52jQugTvdCWnAO64Soh6CLrqPk8n2CBPoo9EPL2ILSdOBemXPEH3lcWKP6Ez6N_Wqj7eVo0maUlLjowS-KWP7oSP-OrsukKPfj51MRdgXQpzqtDT','2025-12-20 17:33:29','2025-12-20 17:33:29'),
(35,'https://fcm.googleapis.com/fcm/send/ehQqCf68qr8:APA91bGSxdWCcuYmw0yKVkP-StToZlRe9l5HqSf2sTOWuTb7DXdU7UGkLCZhr8xw31j3PuhBIq_DoJEonGBK8mFLSUvM7nrjK6fysM2AMsfEAoKGYFegrQO5D6OezQGtykGvlBNpgfqg','2025-12-21 15:17:58','2025-12-21 15:17:58'),
(36,'https://fcm.googleapis.com/fcm/send/cBVP9wf89Bg:APA91bGexLzWzVunKYKY6EuFz2kD99vBJxDjog6V-ZWTZlbEFXqqlGNNvoErIzP76SYIbUeBszLRKQ5VQPaDGQMx8KOY1IQfRctcfH-8BVCAs8cuR6H6NVAVdXN9maIedKWKmJW3KQYG','2025-12-23 04:34:43','2025-12-23 04:34:43'),
(37,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAClifkTPi9AF89O7FakoTawhi7UjUD3dOEa9thdGuhDFNRYlIiqB4XpfSVMd5aCzoejBh6uPOvfTRmLvtavNAK2q1qgH0oQn2xGIK0hehGq7wAiWUYfTSWH%2b1fL%2fM4bUSvB%2bBcEiC8pR4f6EV5jSfnPtcjCpQgJrd77s2p%2bLpfmuHHKUfdkhrS8eCNgG81rlG2H4iGg3UKWrdLokRrIMhTiiUsJnQXk3vN86XblQ5xEbhiyVjfXQ8Fns5MlGVoYm%2fZKnDCixT7XquqJXW5kswceiGRajIDO40PEF5L9qtMC0w0wuGmUpdS%2bvg2Mqbs0ilY%3d','2025-12-26 09:01:18','2025-12-26 09:01:18'),
(38,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAACeSwFY55xpvqveH7VmeZ%2b5CCy63QQ%2fI9lyiCufOfmsO1PPidZAvJVCwlcJNSGL9%2ff5hj4eZ%2fFoUvc0Z9bNN4k4UUo%2bp8W8HaybfBfpvvbKKF5jml0tj4WnfDWdLG0LjkD4qSprT2j9197bcDr9%2f44NtyL18lBfPHjlFxg8P1huQ1RVnRjf6O0Oc9jMsmEeAIQkJce9iaa%2fl4Wslqa4IOUh3ZsQe5arqb%2bGLyoi6W3YRlxTttsGT014RNcQJME5xolkf%2fFCR2pZXvC4Vtyp0VO7LznlX3loAs9%2f8f5DGJtYW7ywwBtbDvkRRj9iOxykWL4%3d','2025-12-26 09:15:58','2025-12-26 09:15:58'),
(39,'https://fcm.googleapis.com/fcm/send/eNbNWY6d5Co:APA91bHViy5RVB1EpS5H7v2kkRrTe6Fg9aG30HSVOOQFAmdMZmuwyi8eVWYqRRFJe240Q17KiS6CP-L7Ei6oWBOZSwVCsY0LIPEx0nhRv04QSbkosR3EKix9aWDNJGxkQJHfHbSawA6K','2025-12-26 19:07:25','2025-12-26 19:07:25'),
(40,'https://fcm.googleapis.com/fcm/send/dVI6XUMP35A:APA91bG0ADdnVbtrRKSMCvVto3oqsn2hSa_ObIx4s3MjV0Ca1aCb_GznwOxvZ54X0g46jiHk7Wa_ObHZubu6ayWtIPMmIevwggjrPQuKoPS01ZH8cMNTIs-A5SSYWVjvKcYkQYGa4aAg','2025-12-26 19:07:30','2025-12-26 19:07:30'),
(41,'https://fcm.googleapis.com/wp/e9xiJA2Z5So:APA91bGug_EIoNgW-2kh2Z7T7YfZ5EIdFYPSkPWcumrTB_HiXTP0FAS1fMfiiqxHV-6MG-iStoXl6hZpCx5qX0GfqqAWO9IoJOf0k6mp2EKPr3OrF2kyJQuRgpk5NFWvbHvn6niixS0z','2025-12-26 19:11:52','2025-12-26 19:11:52'),
(42,'https://fcm.googleapis.com/wp/evbqo7AhQOc:APA91bG2lVdHsEyPUDZNuZt87VglSDgX5yPNl3HOGXHhvtp8qsZKJJhvJ_7TSEX7OhYP-kn1iAIbsdMx3BxBpNIhRmIsoJPhoL7XlPjg_1raeadZuEpyqq-MCPdttxZgw3PBFsnSrzKd','2025-12-26 19:12:08','2025-12-26 19:12:08'),
(43,'https://fcm.googleapis.com/fcm/send/dcvDZCn-aPE:APA91bFteOisD-_u41-A4AEqXmWA7pY_zSiDYQvGoBmaVWmQ4uz8Bpe5V_7CQh_bvsax9kmU-1iCYeTI6aKXxTjJ3lcIHj7tmWcG0j19n2HLJhQviQmT74YxlPHWt_O1I-xRw1MfrtUx','2025-12-26 20:50:50','2025-12-26 20:50:50'),
(44,'https://fcm.googleapis.com/fcm/send/dIGOdjitKrU:APA91bHfa1U-4IPaCgVyOcXk4slAlf7YJ2Zy-IhZ9W6o5wgOokSf7pLNbIVv9T_0x3WNSkhcZUy8_0zLcvlMPm4GWalgsXvs79HzOhGIU-ROBi-l15lN2YGB5pMNwxRLHsGYrljaKqBA','2025-12-26 20:51:06','2025-12-26 20:51:06'),
(45,'https://fcm.googleapis.com/fcm/send/drOZ2FxiX7g:APA91bE92voPZFuavwU0J4I-HNrizd4a2UMWBFNQJot8arjPG7C9nx9LkN7dhlVKM6kUzpft-AVb5OT9txz9pmQONgKTEYii13FZRr7EEfW3vTKu3OTk9iljhI1R6JItocdxDoSU3ns2','2025-12-26 20:51:32','2025-12-26 20:51:32'),
(46,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAIYPUNRQEVwFmB%2fGWS8Tj7OeHGKXGSnnIh9Qx13y3rGVMSylDQo5C4HmWUFN4TiFecpqLDOtsiEyWv0ZWa4QbeCjTYk1YXoV1BdoZ2Axcs7JUAUDviM3ThD5v%2bRHHPA1tDWwcgTsYahi7JiLZIgi6soH1sGAbLaps%2bRRW2tOZURX6sgyCya5H55NtfsBrfkX8cWx0x%2bb0%2fRfdlj%2f0JPSB5EcldE756SIfwHKzXD7dBI42bCmWGjwnK%2bqoT7TNrhbA1Q9CpheHS2RLZdBC%2bdM6Z3k38tZq%2bPSOEY9gMNc3r89WfQ%2bA9rVjAq%2fWGDR3xV4Q%3d','2025-12-28 19:08:18','2025-12-28 19:08:18'),
(47,'https://fcm.googleapis.com/fcm/send/f65xyCd8fdk:APA91bHZmADa1fU0sRIT8uZxCE393zGq0WLQm3-LLglVNFq1_LS5Vj-AySLtwW0_bHyS47Q6CEe54SYmFmlNgwR8JQKNk5TYbORTQlpcl3zxK53N521hITQARS-4qkgXP22T3e1IrXwK','2025-12-29 00:43:06','2025-12-29 00:43:06'),
(48,'https://fcm.googleapis.com/fcm/send/e6lAVpNSjyA:APA91bEsE1cpOH0Yi_VJs9-1qYRrlCjxq2pC33TWfAn8R_jx_BxiuZtPeJqOIY_6hGZ2DgF-RBDyNvjosaJX99c74mg45giJLVW_q-gVaHVtbxdS9_lTan__YC3yZw-Ex7gLXwYOQjgX','2025-12-29 22:07:28','2025-12-29 22:07:28'),
(49,'https://fcm.googleapis.com/fcm/send/cc4BFCW9N4I:APA91bGmUkoJ3Dozp3t9t_kttc6fEnZTeTMCcHyTQeSPBA3nTULh2QAainxh10fafMcVnrYxvJ_jSnIqBGIppulLyaJwEaWFJrI3GqwgLsSA6JTnldpCEmPCHwlSDp5A4fvK0EPqKlDW','2025-12-31 05:39:22','2025-12-31 05:39:22'),
(50,'https://fcm.googleapis.com/fcm/send/e5U46nBTIWs:APA91bFUPeBlYjWOmZ-kRXf7mi480TP6TbVAk2mpI_RymqlW9RgvM_NI1aaFxxf_STRP6-CK3eM5aWj9QOfLKOINugJFLWashKLrbjZfhKrphKCvOnEvgxcwNz5i4Tttt6u5cGH0vIk1','2025-12-31 16:08:25','2025-12-31 16:08:25'),
(51,'https://fcm.googleapis.com/fcm/send/f35sTB-cy2c:APA91bHHUuAbY-LEBQPGd97uiKYA70FEO4XvP1IpQaerupPQIb0oGek1k1-G9zFJKSzjcaE3F0Va9IMmXTm-rSyMzXzUk20vdDY2hl6JcnrTY9i6gBhP6KrwFNb6vsUXPOutzFMegJ8v','2025-12-31 23:38:23','2025-12-31 23:38:23'),
(52,'https://fcm.googleapis.com/fcm/send/d1VnVTM83PI:APA91bEzqlpfWkXUUc426y4d26SzADSoMUUClLwh1ftMoxHpycKrxUoPj75AjpWSvrtA2LZaHdDImpI7IEZ2Ur4vevQu0R88Lwg7aYauqauyAL198On2_9Hr6KYlclOdUse_EmvleXO_','2026-01-01 00:18:01','2026-01-01 00:18:01'),
(53,'https://fcm.googleapis.com/fcm/send/dpWztfYAym0:APA91bFeRMPVU-lrnOQK4P-AVhSte9ZuO_yIosOFSjv1iXIIwfwYz0EBpTDfyyM5vKml6js8ZlQIPLmhIz4fwuay_2PsOjz72Kh9FcD4Bq3h3hhCARR5XqSgFaPskOLjGsBB9ukJljPB','2026-01-01 07:25:39','2026-01-01 07:25:39'),
(54,'https://fcm.googleapis.com/fcm/send/fQJX7ZxTSsE:APA91bGmloKuSq_tkm8etEfVdEbdkxozQrL5Zhbht_Jz1J6P69A78WcFzo0KQjxRecgcg68fOSlsuVI05xEI4hai-ujLlNXZyDSEySSWfCsbkVvQWWas6xEdrEHbCepPDM8-ZocFg07O','2026-01-03 02:52:34','2026-01-03 02:52:34'),
(55,'https://fcm.googleapis.com/fcm/send/eoNR8hSMtkU:APA91bEQKtOMnEhA_uzij2Lfv2TP-9PvXXcSkj_nwjIFhm5X3qJ7FR_wgBXBX4oNHiVbO3vqbW6VhgK-tIH6P0RXYNgTb8nYEnkrPQl0zSaPsOG0U7Mac5h2SePqu6MyotCeY_P-hTZi','2026-01-03 02:52:39','2026-01-03 02:52:39'),
(56,'https://fcm.googleapis.com/fcm/send/d-NXlQ4WF54:APA91bExfbCRDTTDOhWsmhPNJghcNRPOM0JnwApzmXC2dxSJp-61blMv0LgL0vbLiOf-vG7upKgS5HGQydhaG6YibXhJ8KdMyi6ojQsNNUof9SuNJABuXLkW3j-SguxtWDtCTkmtNi02','2026-01-03 02:53:16','2026-01-03 02:53:16'),
(57,'https://fcm.googleapis.com/fcm/send/cRKS621iUyM:APA91bEGoAoHCEn4hGDai1jdzbuWTIkQrw43GzwWKudbNhOVT7SIfWWg5rGNdzZoMuBwbKDM1GVFUku-pB_YPCYz84E1Pexazeg6cPwmq_vuJrw0f_eteMoO9ysq4KlKHqluaV-As8_V','2026-01-03 02:54:01','2026-01-03 02:54:01'),
(58,'https://fcm.googleapis.com/fcm/send/fI3ltJ7udVM:APA91bHrhYqlcUPfoAFDnSUXJSZOiDPAtcRSR3-cFozo-XdF-WrUkn6e27R9nbRmvFYQ6kJ7BIx5Set_Q1bwz1e1LpKkhq-6VD0tUykMxweXBnE5D5qX06mpShBz-QlwdF6y9SQYCc5o','2026-01-03 03:01:33','2026-01-03 03:01:33'),
(59,'https://fcm.googleapis.com/fcm/send/eguxovJA4Ew:APA91bFQom5Mf7Z80L-Ifj0agCnAHVsmNXC1XXbNO3dPIKmNM1uB6oCaaGOtw9o6zdZnpeVUsfIRQODUC0nqGXTQ3HthEzJtFsM3NKtpLLNlhFPst7vhKwIbT6GStCjitG8WEfpkgbox','2026-01-03 03:16:41','2026-01-03 03:16:41'),
(60,'https://fcm.googleapis.com/fcm/send/ezeHQlpFr-s:APA91bGAfMesCxe_UxU9y8g9w9i19r8Gc0X0Dw_mTQvWwoEJvGKb0dkHse5yzS-ByX4JIx4RJ4pJtaAZbWBPVd8UEPxqx45XFW4RAxLWJRvwn5lrt7Sh5PfPOOX4-jKJiXxEhhbmIPA8','2026-01-03 04:31:40','2026-01-03 04:31:40'),
(61,'https://fcm.googleapis.com/fcm/send/diGHLSjHu1A:APA91bEDNMYqFamo2802wOdsnWXw0eIgPJa-bljXDdq1tYHgSG2V8I45My0OlEkAFVrQhgC5DxNTmSxSphWEi1x0IxWLzVPU9pSK75KO-NE1xo5iZ0Ejj9q2ueyEGCjUAm9nrUqPmdEv','2026-01-03 04:31:57','2026-01-03 04:31:57'),
(62,'https://fcm.googleapis.com/fcm/send/e8EorkxKWQI:APA91bG4U0TTFpbM2H64EB8f9aVJepA603u-phgbvCQi6QdUxcw3a8v5giRs6GgabR6xQtQpoPDihPY7KktTKNNIvxH2O3lmDSUtsrprElVJ1_jslkdb62YwtNsKoGsJx5iowOTlclHl','2026-01-03 04:32:12','2026-01-03 04:32:12'),
(63,'https://fcm.googleapis.com/fcm/send/eC4gNo5WmSc:APA91bGYq5S9Tp-cp6Oze88j-d1MHj1__aVHepA0JNsipxc9vnaY_YmwgvHeHIuUpl6hcyPMMzpvF2O1K47lHqsDdktyK5LW4LmN2AYyYws1T2wjE9SYJ54-kmxup4BxbHlC_nL7E5Bv','2026-01-03 16:29:56','2026-01-03 16:29:56'),
(64,'https://fcm.googleapis.com/wp/esrii3Qyq94:APA91bGBbga1sg3skx7Wq2TjKRtNNTcvsdsC3UO3qccqpb_FVsOOZwl3pD9GLgkMmHTtnE7bl2kYzqpUcGev-8-KhnISd-S9tpIRCYlm3yDeml_aQG-7NwvYotsiL7lq8x7MvufemZQD','2026-01-03 16:51:31','2026-01-03 16:51:31'),
(65,'https://fcm.googleapis.com/fcm/send/cE5E38IFWcY:APA91bHQJIXzGOKxYLNhinley6V1Xd1jS71dSOiDFwwjw51diHNJN_MgvxBXOHyBIFu6eaMTjMywqaWz2T9Hnin5H1DmYbI6Gim5gcCzjT7XV8_v7jMakW6VFi0S8jv-9vhAJOMsz-Tc','2026-01-03 16:56:26','2026-01-03 16:56:26'),
(66,'https://fcm.googleapis.com/wp/exurmhPo8qU:APA91bG0TYGMX7T1wkzZ1CBorVTZyOcXIfanM1VrDFL3Vg9fjaGRKNAp4dyoXMbAsbLNsaklvVrME8ohff5bWECOI6tbZxo2c6w5FY8C0ikuDfe2TlYGSbJ-w-l0UnxJStnScGjD6nqV','2026-01-03 16:56:52','2026-01-03 16:56:52'),
(67,'https://fcm.googleapis.com/fcm/send/eEiAhjg77ns:APA91bHtikOK4w4S1wKMxI16NWv8d33bE6AHQ57xHez7B9qrEEII4dMGAJHgKzu2yqXe0hlt-sRNaRK5vvgkI8Eu2pxvV6a3zPVwYYLoq6HRmsWNca-hbS7NlfwHlzM_R9Q79FXiwRsJ','2026-01-03 17:35:31','2026-01-03 17:35:31'),
(68,'https://fcm.googleapis.com/fcm/send/eR4mO8weAvI:APA91bGYGfh7NdLDAxrAni-JD_MMXygo8ha0iA3D5xvzij1XLZIiN83c05Y7oGqQobdnPyNIBySyQNH4asl5awsXw-SQTbzDC8HdD9WCTCdguNXZiU73i_76Y4GNoVswDxp7MzOdnyK7','2026-01-03 17:47:06','2026-01-03 17:47:06'),
(69,'https://fcm.googleapis.com/fcm/send/cO9636UELvg:APA91bHqoUL2RcZiELn5qnNPB6gFo306quyVyRhNfUfXAlQBPubvsj1QajtK5F4E_TYxKCyrDZD8Z-OLZ0EKVNUWqsXRZMms-zTLzwsv49wta3kU2K0aIj8CYVRSropaTUF8lW2pM58k','2026-01-03 22:12:34','2026-01-03 22:12:34'),
(70,'https://fcm.googleapis.com/fcm/send/dn1jfnAoVJY:APA91bFX5WIZ9lhJPERWF3Dn7DwDlSiU5hBWMV0JsVWpkjSFwZbyRK7s1-oC4S9yW4_68ovVRmNNy_UL0t6_wSZmsva7BknlgU0Q6lU6D7PluzpYyhZLz2q0D_O71hAqtNLseqNnLaC6','2026-01-03 22:12:43','2026-01-03 22:12:43'),
(71,'https://fcm.googleapis.com/fcm/send/cbL9OeVzUhM:APA91bFGebD6N8jJ_NCMvDFk7aMhY6OATuncBIjUn07U5sPayCbDdIjMf01kcHfOtaDojby-uiYpukF0qJgLXHI-MubV4yKS2tEYakOcmS-cGrGXMzxIvLtPevx_cMMwFT-zcgUaNOy8','2026-01-03 22:18:28','2026-01-03 22:18:28'),
(72,'https://fcm.googleapis.com/fcm/send/dFNPl0hYPKI:APA91bGspPhm4fg-WetR88NToWySWJslJNNuuCuaaKB13QwKcUbRwzgx5wFpV3lJH-XQjUJwFkyXXNUWosxoiOHga4WzYsVYgVA5QQCnju_0e_pn1vHB8JrxrT_wxmXElrDDA4AnLy9n','2026-01-03 22:31:51','2026-01-03 22:31:51'),
(73,'https://fcm.googleapis.com/fcm/send/epuW2_Owc5o:APA91bEgas-0GERSV7rLwP-u_5LA9J1OtEEXp4vwxuAeOFFrSiZ9cnfeU4qcTUYymZc0lApH3oc6tcPcdq5L7truckd88rbmORvP01iDjz5k-4NI2eZfm1H9Kd7VPbTX02jFuC-R09eq','2026-01-03 22:31:53','2026-01-03 22:31:53'),
(74,'https://fcm.googleapis.com/fcm/send/fRuMAIZ-GOA:APA91bFcgCzY_wVVUQNFLsErhI5fYQFopsX8Aruykv-NHMrgCjaDBUQVnDR1QyW0zzSFgZrcc5_95Jw2I2gRMJQOnkCaCvcXAr_GLU7oiePmVXbGMj7lhtQDeTh5mXUd4cqJWho3QK6T','2026-01-03 22:32:02','2026-01-03 22:32:02'),
(75,'https://fcm.googleapis.com/fcm/send/dKkLvrTM7wU:APA91bHbx7gW32oVUt3-4d0lYnrtcdslGWG0a0hMnQ0-ApKBotf2DiQqHwwVVr-RWGoPtg6kZzTg4xkd9Jr9AbezGgWG1Agf7FwyXYLnw2lQy4ZwNgE-YfMhWeCihBoz9OK8Fy8-Zbx2','2026-01-03 22:49:42','2026-01-03 22:49:42'),
(76,'https://fcm.googleapis.com/fcm/send/fgm5Q13e7rs:APA91bFt4Muruwo0JIS3Ty75M8VeN8up_EfQij0A8gFv-awz24EkVqTOOLbctGp_4hCQWIMUKQaHv-B4h-q5Iu7DcTQczFGb7f9IosWFj4JV2UPMRWPQy11y1ynH2DHpzxei8HBQBMmg','2026-01-03 22:50:09','2026-01-03 22:50:09'),
(77,'https://fcm.googleapis.com/fcm/send/eI7UlSldzLk:APA91bENE7bT11rboT9LClgnjrLQfzH9Kjy8G_C-6Ms0ayKhzk_p6dcmcgNBUtFpBkwep7t4JP5pZ-TNwbjz--EjUPWpsQot3GYGjHUuDoqRtZ-w7Lt9-YIClrHNcyCxL3rwgDJtTL9C','2026-01-03 22:50:58','2026-01-03 22:50:58'),
(78,'https://fcm.googleapis.com/fcm/send/eh1chZXjmvA:APA91bHe2J3S6Rs_kpseYJkv2J6lfJfnCE5T95IiAEsv6dS0ZGFSI-1Zk0TqSac9IiWo8ljyLtlD1Q3wUF7A9cUj5ogYESHRJrXu7IMW_XQmqye6E_ptKiPE00zVWfMx-ckT8hXlNdVi','2026-01-03 23:55:50','2026-01-03 23:55:50'),
(79,'https://fcm.googleapis.com/fcm/send/eDKM7f2yWm4:APA91bHE37uyPOdtELTlcG1LJdOEkxbKn6UoOe7avSbPtqh7poyQu3ImOoRf64DV9wWfXHw-ajFF-a8_xLlY8J6zbtAP3_4CydidQP_PzYv3y8F2x8oOT5oijqnHJ2sNkBmfFefNNAsu','2026-01-04 00:05:46','2026-01-04 00:05:46'),
(80,'https://fcm.googleapis.com/fcm/send/dxwakHIZV3Y:APA91bFcNwj044XPDeW2nr5B1YlzM2lX-Qu6vp4cIfqAMRWW9RZGz1iCDVpNDfS7xBYUZdgQByOoofKKzQT_r09eVc9IzQGoyRRlsb1KxyGRUhTKPj0GBNZmLLk0DAQv0TG8s9kvcM9f','2026-01-04 00:21:37','2026-01-04 00:21:37'),
(81,'https://fcm.googleapis.com/fcm/send/eqIq8NfLvG0:APA91bEXRaq7h1_8tH3CJh6P0VFHtKJTEno2ufHaQw71IH6Oou1XLUy1Ge5jOAzByaKqiwfaZBG7hd-UPZ78rO7nXExIA68IVS0U8BP-HxSY1CgBIWmpvX09pQDhVoiasesk5ZJwd1OT','2026-01-04 00:31:45','2026-01-04 00:31:45'),
(82,'https://fcm.googleapis.com/fcm/send/dR266uTCggw:APA91bGNWzFPwvEIrwKbqGl-NSY7NWLZK7RdZ3X2ZukOIjY78s-fZQ58cljwDGwXarZwxO9KEoyiBst9g8641uyMWZYLWa2lLkznApMMuTWIKtaqcvWlDEUsgpopybkDmfrT-tUxwEfT','2026-01-04 00:33:12','2026-01-04 00:33:12'),
(83,'https://fcm.googleapis.com/fcm/send/f_XOxQ9zjMM:APA91bHhKR_4qmLN4urawZB-EeR3Ist__N_bvMjGVCvw50oTcmR1-jxcAWBCYbQVc2x-tnt84wWcdv2Z5xXNboPROJoJ8B8G7vS-SU7LBFmYATdDFZoXB0WqGse8s15nUu7tU6nJK-Nw','2026-01-04 03:17:44','2026-01-04 03:17:44'),
(84,'https://fcm.googleapis.com/fcm/send/ej5YIH9zOOY:APA91bFkxjJnnSh7p0v2zpzEfuf6G14aWIu1-F-9EInRZNllke0sw_p5pdYBj8qWYeSLRtjicfVo-z0-eoDQ3VN01e7uEp5zZVA4iIJslLUffX0u-s6X8mZR3z_rRnX68LufgHLCUQiJ','2026-01-04 03:17:52','2026-01-04 03:17:52'),
(85,'https://fcm.googleapis.com/fcm/send/dlk3CMFoAls:APA91bHIc1_JPsnTXBVZ1AoovQf9Lv4WK-0ALOoCUA-0bJVnFOqyiZd2T6mdEwMdMCLsojjsarN8Vervnk2AovjtrMRGWzMLS58XPr9fjgQSymJhAXF35r_3LGH-pBpC7WT-SjtTUONh','2026-01-04 03:27:45','2026-01-04 03:27:45'),
(86,'https://fcm.googleapis.com/fcm/send/epv8prbCbAQ:APA91bG3drMHKei3WsGFbZ59ZmF0gDguVKrsRKUvEkf-EPdA6bRLREWie1lcqQd-bB4HuY3YolfVm8ZoOrpD8hLALpDzARRo6kpg5vc4l1rPoB2Vox1Nmn86m0Wi1bUgX5k9kNEONWCb','2026-01-04 04:35:17','2026-01-04 04:35:17'),
(87,'https://fcm.googleapis.com/fcm/send/eyUixbbBzDQ:APA91bHqgEnwbGmZ_PpTrRzF2rpKJ1pv9wvHtVJh0-Ppqysq3bNlLOzki3E5YL8HlNX8W-x1_Stvr4pKohmT3YmO9tt9hcc9xobGEix0oDrGH5OVx5p6RamMOZZG2QcL2x757UlBaFYV','2026-01-04 04:35:25','2026-01-04 04:35:25'),
(88,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAABaBJYTnkrfin4AOGf4R6d75rYZikaI5V327eMJ68Ut0OdK7qAFkZ8m0img5y2zHD7bWvwWh4TOof0OLhvXGFbGUuzKuoOSe5CK7s%2fLTSq54cV1lKCl66DgStPVzYJJnS%2bBB79Kfzfe3QUpHggg5zlaMHtaMb3qaz9CXZ62luf1TgrVOh2dlVe3i70%2byeVLBQx2HjtnLqYD6sJ1ojNY38INNpffQ0oiTxNpsu9tTZp1vxo8UZNadiSeHF8yhE8KgxToBc%2bXSfm2qOxqPIpo0B8464eLrdRpvxWCnTXsfrHMWg4ErJTAfMHbZscL6g0K3ZU%3d','2026-02-08 00:01:02','2026-02-08 00:01:02'),
(89,'https://fcm.googleapis.com/fcm/send/dzyFQDQbTZI:APA91bGd_ydHF7MOTl0hGIBLszxaVrzO1f3uZFwu4B2qv8ltnIO3zQWe1iBqu9iJ7TLC_10bEDra0YQq4lkrcjW4jer3yb3UCurs09B3rBdC-AoTrxoLCfu3_SVJQLskcIaQMiwdbq9C','2026-02-17 18:08:50','2026-02-17 18:08:50'),
(90,'https://fcm.googleapis.com/fcm/send/c_SlS6OcWNg:APA91bHNv8XPIjAgK-Cg2jwiFdt1Kj_axgrrCDcjWdnKBi1SQlMZQ0OGLtFyV92GRDiewWMKJVmJViKF2giqmk7VrPo-m9RoFOU8rZ7oiYtNhk8VpdG-aTbii5hTymOfdGF1A9hxBa7v','2026-02-17 18:22:15','2026-02-17 18:22:15');
/*!40000 ALTER TABLE `guests` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `hero_sections`
--

DROP TABLE IF EXISTS `hero_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `hero_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
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
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hero_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `hero_sections` WRITE;
/*!40000 ALTER TABLE `hero_sections` DISABLE KEYS */;
INSERT INTO `hero_sections` VALUES
(2,8,'6940338242012.jpg',NULL,NULL,'Find Events','https://codecanyon.kreativdev.com/coursela/courses','Meet Instructors','https://codecanyon.kreativdev.com/coursela/instructors',NULL,'61bda9c61892c.png','2021-11-30 22:30:04','2025-12-15 16:12:50');
/*!40000 ALTER TABLE `hero_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `how_work_items`
--

DROP TABLE IF EXISTS `how_work_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `how_work_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `serial_number` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `how_work_items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `how_work_items` WRITE;
/*!40000 ALTER TABLE `how_work_items` DISABLE KEYS */;
INSERT INTO `how_work_items` VALUES
(1,8,'fas fa-user-plus','Register your account','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.',1,'2022-06-07 00:45:47','2023-05-07 12:01:00'),
(2,8,'fas fa-plus','Create your events','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam .',2,'2022-06-07 00:48:26','2023-05-07 12:01:45'),
(3,8,'fas fa-cart-arrow-down','Sell tickets & get paid','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.',3,'2022-06-07 00:49:09','2023-05-07 12:09:09'),
(4,8,'fas fa-wallet','Withdraw','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam.',4,'2022-06-07 00:49:38','2023-05-07 12:02:56');
/*!40000 ALTER TABLE `how_work_items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `how_works`
--

DROP TABLE IF EXISTS `how_works`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `how_works` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `how_works`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `how_works` WRITE;
/*!40000 ALTER TABLE `how_works` DISABLE KEYS */;
INSERT INTO `how_works` VALUES
(1,8,'how does it work','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt','2022-06-07 00:42:14','2022-06-07 00:58:43');
/*!40000 ALTER TABLE `how_works` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `identities`
--

DROP TABLE IF EXISTS `identities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `identities` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `type` enum('personal','organizer','venue','artist') NOT NULL,
  `status` enum('active','pending','rejected','suspended') NOT NULL DEFAULT 'pending',
  `owner_user_id` bigint(20) unsigned NOT NULL,
  `display_name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `meta` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`meta`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identities_slug_unique` (`slug`),
  KEY `identities_owner_user_id_foreign` (`owner_user_id`),
  CONSTRAINT `identities_owner_user_id_foreign` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identities`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `identities` WRITE;
/*!40000 ALTER TABLE `identities` DISABLE KEYS */;
INSERT INTO `identities` VALUES
(1,'personal','active',9,'Saeed Mahmud','saeed-mahmud','{\"country\":\"BD\",\"city\":\"Dhaka\"}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(2,'personal','active',10,'Samiul Pratik','samiul-pratik','{\"country\":\"Bangladesh\",\"city\":\"Dhaka\"}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(3,'personal','active',11,'rynupyzan','rynupyzan','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(4,'personal','active',12,'Fahad Hossain','fahad-hossain','{\"country\":\"Bangladesh\",\"city\":\"Dhaka\"}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(5,'personal','active',13,'Giancarlos Valdez','giancarlos-valdez','{\"country\":\"Republica Dominicana\",\"city\":\"Santo Domingo\"}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(6,'personal','active',14,'Davila Esperanza Paulino Ramos','davila-esperanza-paulino-ramos','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(7,'personal','active',15,'Milauri Paulino','milauri-paulino','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(8,'personal','active',16,'Adrian Torres','adrian-torres','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(9,'personal','active',17,'Dilencio Vargas','dilencio-vargas','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(10,'personal','active',18,'Jeffrey Ynoa','jeffrey-ynoa','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(11,'personal','active',19,'Edgar Garcia','edgar-garcia','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(12,'personal','active',20,'Juan Diego Perez De Los Santos','juan-diego-perez-de-los-santos','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(13,'personal','active',21,'Ivan Noboa','ivan-noboa','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(14,'personal','active',22,'Erick Benjamín','erick-benjamin','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(15,'personal','active',23,'Maxwell Morrison','maxwell-morrison','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(16,'personal','active',24,'Jeremy Caro','jeremy-caro','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(17,'personal','active',25,'Victor Hurtado','victor-hurtado','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(18,'personal','active',26,'Martina Occhi','martina-occhi','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(19,'personal','active',27,'Junior Santana','junior-santana','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(20,'personal','active',28,'Ramses Sultan','ramses-sultan','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(21,'personal','active',29,'Yamilet J. Terrero Batista','yamilet-j-terrero-batista','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(22,'personal','active',30,'Alberto Parada','alberto-parada','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(23,'personal','active',31,'Christ Austin Lamour','christ-austin-lamour','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(24,'personal','active',32,'Génesis Blanco','genesis-blanco','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(25,'personal','active',33,'Braulio Paulino','braulio-paulino','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(26,'personal','active',34,'Joel Morillo','joel-morillo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(27,'personal','active',35,'Roy van der Steen','roy-van-der-steen','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(28,'personal','active',36,'caleb deriel','caleb-deriel','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(29,'personal','active',37,'Massiel Tejeda','massiel-tejeda','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(30,'personal','active',38,'Jeffry Zabala Ramirez','jeffry-zabala-ramirez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(31,'personal','active',39,'Roberto Rojas','roberto-rojas','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(32,'personal','active',40,'Zion Lowe','zion-lowe','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(33,'personal','active',41,'Brainer Espinal Aquino','brainer-espinal-aquino','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(34,'personal','active',42,'Emanuel Duarte','emanuel-duarte','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(35,'personal','active',43,'Daniel Antonio De león Javier','daniel-antonio-de-leon-javier','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(36,'personal','active',44,'Louis Pedrito','louis-pedrito','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(37,'personal','active',45,'Jonathan Demosthene','jonathan-demosthene','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(38,'personal','active',46,'Jeison Torres','jeison-torres','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(39,'personal','active',47,'Robert Leclerc','robert-leclerc','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(40,'personal','active',48,'Jorge Luis Alejo Herrera','jorge-luis-alejo-herrera','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(41,'personal','active',49,'Jean carlos Jimenez','jean-carlos-jimenez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(42,'personal','active',50,'John Lugo','john-lugo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(43,'personal','active',51,'Joel Francisco Ramirez alvarez','joel-francisco-ramirez-alvarez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(44,'personal','active',52,'Diego Rojas','diego-rojas','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(45,'personal','active',53,'sebastián marmolejos','sebastian-marmolejos','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(46,'personal','active',54,'Miguel angel Del valle bruno','miguel-angel-del-valle-bruno','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(47,'personal','active',55,'Luis M','luis-m','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(48,'personal','active',56,'Stefano Amador','stefano-amador','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(49,'personal','active',57,'Patricia Garcia','patricia-garcia','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(50,'personal','active',58,'Luz Castillo','luz-castillo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(51,'personal','active',59,'Luz Castillo','luz-castillo-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(52,'personal','active',60,'Denis Rivera','denis-rivera','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(53,'personal','active',61,'Emil Fernandez','emil-fernandez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(54,'personal','active',62,'Joel Peralta','joel-peralta','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(55,'personal','active',63,'Juan Toribio Lied','juan-toribio-lied','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(56,'personal','active',64,'Isaías Paredes','isaias-paredes','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(57,'personal','active',65,'anthony peguero','anthony-peguero','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(58,'personal','active',66,'Step Vazquez','step-vazquez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(59,'personal','active',67,'MATEO VASQUEZ','mateo-vasquez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(60,'personal','active',68,'Hamlet Almonte','hamlet-almonte','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(61,'personal','active',69,'pablo reyes','pablo-reyes','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(62,'personal','active',70,'Jini Luciano','jini-luciano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(63,'personal','active',71,'Kelvin Ortiz gonzalez','kelvin-ortiz-gonzalez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(64,'personal','active',72,'Jhon Chalinger','jhon-chalinger','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(65,'personal','active',73,'Juharin Payano','juharin-payano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(66,'personal','active',74,'Aaron Chan','aaron-chan','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(67,'personal','active',75,'Green Muñoz','green-munoz','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(68,'personal','active',76,'Angel Pereyra','angel-pereyra','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(69,'personal','active',77,'pablo reyes','pablo-reyes-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(70,'personal','active',78,'Juairin Payano','juairin-payano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(71,'personal','active',79,'Roberson Jose','roberson-jose','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(72,'personal','active',80,'Diego Alberto De los Santos suero','diego-alberto-de-los-santos-suero','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(73,'personal','active',81,'Olga Mendez','olga-mendez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(74,'personal','active',82,'Angey Antigua','angey-antigua','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(75,'personal','active',83,'Cesar Soto soto','cesar-soto-soto','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(76,'personal','active',84,'Fairam Castillo','fairam-castillo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(77,'personal','active',85,'Fausto Marte','fausto-marte','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(78,'personal','active',86,'Josue Valentin Villa','josue-valentin-villa','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(79,'personal','active',87,'Aider Kun','aider-kun','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(80,'personal','active',88,'Rafael Romero','rafael-romero','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(81,'personal','active',89,'Luis Perez','luis-perez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(82,'personal','active',90,'Joan Pérez Pujols','joan-perez-pujols','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(83,'personal','active',91,'janiel acosta','janiel-acosta','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(84,'personal','active',92,'Stefano Amador','stefano-amador-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(85,'personal','active',93,'Pavel Calderon','pavel-calderon','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(86,'personal','active',94,'Dulce Wiese','dulce-wiese','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(87,'personal','active',95,'Mary De León','mary-de-leon','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(88,'personal','active',96,'Lotty Cardenas','lotty-cardenas','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(89,'personal','active',97,'Salimah Veras','salimah-veras','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(90,'personal','active',98,'Luis Angel Tavarez Taveras','luis-angel-tavarez-taveras','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(91,'personal','active',99,'Yefry Batista','yefry-batista','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(92,'personal','active',100,'Aubrey Fernández','aubrey-fernandez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(93,'personal','active',101,'Ana rosa Mondesi','ana-rosa-mondesi','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(94,'personal','active',102,'Damaris Martinez','damaris-martinez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(95,'personal','active',103,'Raúl Cabrera','raul-cabrera','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(96,'personal','active',104,'Marcos De Leon','marcos-de-leon','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(97,'personal','active',105,'Jordi Rafael Ramos Ventura','jordi-rafael-ramos-ventura','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(98,'personal','active',106,'Vishnu Fernández','vishnu-fernandez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(99,'personal','active',107,'Gino Carezzano','gino-carezzano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(100,'personal','active',108,'jandro polanco','jandro-polanco','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(101,'personal','active',109,'Alexa Reyes','alexa-reyes','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(102,'personal','active',110,'Ramnerys Mena De la Cruz','ramnerys-mena-de-la-cruz','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(103,'personal','active',111,'Jose Pena','jose-pena','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(104,'personal','active',112,'Aimee Morel','aimee-morel','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(105,'personal','active',113,'Jose Pena','jose-pena-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(106,'personal','active',114,'Marcos De Leon','marcos-de-leon-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(107,'personal','active',115,'Rafael Bueno','rafael-bueno','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(108,'personal','active',116,'Sebastian Suriel','sebastian-suriel','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(109,'personal','active',117,'Yeralqui Frias','yeralqui-frias','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(110,'personal','active',118,'Jerry Steven Reyes Veloz','jerry-steven-reyes-veloz','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(111,'personal','active',119,'Rosy Villa','rosy-villa','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(112,'personal','active',120,'NAIROBI HERNANDEZ GOMEZ','nairobi-hernandez-gomez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(113,'personal','active',121,'Emilis Castillo','emilis-castillo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(114,'personal','active',122,'Erick Hiciano','erick-hiciano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(115,'personal','active',123,'Alexander Suarez','alexander-suarez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(116,'personal','active',124,'Franchel Velázquez','franchel-velazquez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(117,'personal','active',125,'Eduardo Cruz','eduardo-cruz','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(118,'personal','active',126,'Krysht Fernández','krysht-fernandez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(119,'personal','active',127,'Alexander Mueses','alexander-mueses','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(120,'personal','active',128,'Ninoska Mejia','ninoska-mejia','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(121,'personal','active',129,'Gabriella Medina','gabriella-medina','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(122,'personal','active',130,'Jesús Mora','jesus-mora','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(123,'personal','active',131,'Kiara Hernandez','kiara-hernandez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(124,'personal','active',132,'Brenda Méndez','brenda-mendez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(125,'personal','active',133,'Jassel Santana','jassel-santana','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(126,'personal','active',134,'Jean Diaz','jean-diaz','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(127,'personal','active',135,'Luigi Montaño Laureano','luigi-montano-laureano','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(128,'personal','active',136,'Alexis Contreras','alexis-contreras','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(129,'personal','active',137,'Eduardo Cruz','eduardo-cruz-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(130,'personal','active',138,'Lara Denisse','lara-denisse','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(131,'personal','active',139,'Julio Antonio Marcano arvelo','julio-antonio-marcano-arvelo','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(132,'personal','active',140,'Diego Alberto De los Santos suero','diego-alberto-de-los-santos-suero-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(133,'personal','active',141,'Kevin Lopez','kevin-lopez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(134,'personal','active',142,'Anderson Peña','anderson-pena','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(135,'personal','active',143,'Ruth Vasquez','ruth-vasquez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(136,'personal','active',144,'Bernis Mendez','bernis-mendez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(137,'personal','active',145,'Danisa Berigüete','danisa-beriguete','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(138,'personal','active',146,'Ana rosa Mondesi','ana-rosa-mondesi-1','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(139,'personal','active',147,'adenis paniagua','adenis-paniagua','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(140,'personal','active',148,'Loren Ramos','loren-ramos','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(141,'personal','active',149,'Nicole Santana Rojas','nicole-santana-rojas','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(142,'personal','active',150,'Yoan Perez','yoan-perez','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(143,'personal','active',151,'Hector Avellaneda','hector-avellaneda','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(144,'personal','active',152,'Angie Gaona','angie-gaona','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(145,'personal','active',153,'Emanuel Barrios','emanuel-barrios','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(146,'personal','active',154,'Yimmy Pinales','yimmy-pinales','{\"country\":null,\"city\":null}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(147,'organizer','pending',27,'juniorwkx','juniorwkx','{\"id\":32,\"photo\":null,\"email\":\"juniorwkx@gmail.com\",\"phone\":null,\"username\":\"juniorwkx\",\"password\":\"$2y$10$3.B1RCsk0dqFLmnKLnF4fer.lEsV7sRQ83yFikJY8iyL..UGRXiQK\",\"status\":\"0\",\"amount\":null,\"email_verified_at\":\"2025-12-31 10:56:57\",\"facebook\":null,\"twitter\":null,\"linkedin\":null,\"created_at\":\"2025-12-31T14:54:24.000000Z\",\"updated_at\":\"2025-12-31T14:56:57.000000Z\",\"theme_version\":\"light\"}','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(148,'organizer','pending',138,'Lara','lara-1','{\"id\":34,\"photo\":null,\"email\":\"lara.yasiris15@gmail.com\",\"phone\":null,\"username\":\"Lara\",\"password\":\"$2y$10$lPg6asRdvDLCzIk3B0LhBuiMt2HvEhYLoVkk6rdSbJUGkybh\\/H0fi\",\"status\":\"0\",\"amount\":null,\"email_verified_at\":\"2026-01-03 19:20:22\",\"facebook\":null,\"twitter\":null,\"linkedin\":null,\"created_at\":\"2026-01-03T23:02:55.000000Z\",\"updated_at\":\"2026-01-03T23:20:22.000000Z\",\"theme_version\":\"light\"}','2026-02-26 04:42:03','2026-02-26 04:42:03');
/*!40000 ALTER TABLE `identities` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `identity_members`
--

DROP TABLE IF EXISTS `identity_members`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `identity_members` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `identity_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `role` enum('owner','admin','manager','staff','scanner','pos_operator') NOT NULL DEFAULT 'staff',
  `permissions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`permissions`)),
  `status` enum('active','invited','removed') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identity_members_identity_id_user_id_unique` (`identity_id`,`user_id`),
  KEY `identity_members_user_id_foreign` (`user_id`),
  CONSTRAINT `identity_members_identity_id_foreign` FOREIGN KEY (`identity_id`) REFERENCES `identities` (`id`) ON DELETE CASCADE,
  CONSTRAINT `identity_members_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=149 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `identity_members`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `identity_members` WRITE;
/*!40000 ALTER TABLE `identity_members` DISABLE KEYS */;
INSERT INTO `identity_members` VALUES
(1,1,9,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(2,2,10,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(3,3,11,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(4,4,12,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(5,5,13,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(6,6,14,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(7,7,15,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(8,8,16,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(9,9,17,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(10,10,18,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(11,11,19,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(12,12,20,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(13,13,21,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(14,14,22,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(15,15,23,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(16,16,24,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(17,17,25,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(18,18,26,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(19,19,27,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(20,20,28,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(21,21,29,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(22,22,30,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(23,23,31,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(24,24,32,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(25,25,33,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(26,26,34,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(27,27,35,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(28,28,36,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(29,29,37,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(30,30,38,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(31,31,39,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(32,32,40,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(33,33,41,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(34,34,42,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(35,35,43,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(36,36,44,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(37,37,45,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(38,38,46,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(39,39,47,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(40,40,48,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(41,41,49,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(42,42,50,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(43,43,51,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(44,44,52,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(45,45,53,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(46,46,54,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(47,47,55,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(48,48,56,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(49,49,57,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(50,50,58,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(51,51,59,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(52,52,60,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(53,53,61,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(54,54,62,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(55,55,63,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(56,56,64,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(57,57,65,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(58,58,66,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(59,59,67,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(60,60,68,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(61,61,69,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(62,62,70,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(63,63,71,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(64,64,72,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(65,65,73,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(66,66,74,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(67,67,75,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(68,68,76,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(69,69,77,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(70,70,78,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(71,71,79,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(72,72,80,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(73,73,81,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(74,74,82,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(75,75,83,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(76,76,84,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(77,77,85,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(78,78,86,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(79,79,87,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(80,80,88,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(81,81,89,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(82,82,90,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(83,83,91,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(84,84,92,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(85,85,93,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(86,86,94,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(87,87,95,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(88,88,96,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(89,89,97,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(90,90,98,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(91,91,99,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(92,92,100,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(93,93,101,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(94,94,102,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(95,95,103,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(96,96,104,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(97,97,105,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(98,98,106,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(99,99,107,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(100,100,108,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(101,101,109,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(102,102,110,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(103,103,111,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(104,104,112,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(105,105,113,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(106,106,114,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(107,107,115,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(108,108,116,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(109,109,117,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(110,110,118,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(111,111,119,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(112,112,120,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(113,113,121,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(114,114,122,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(115,115,123,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(116,116,124,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(117,117,125,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(118,118,126,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(119,119,127,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(120,120,128,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(121,121,129,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(122,122,130,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(123,123,131,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(124,124,132,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(125,125,133,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(126,126,134,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(127,127,135,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(128,128,136,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(129,129,137,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(130,130,138,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(131,131,139,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(132,132,140,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(133,133,141,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(134,134,142,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(135,135,143,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(136,136,144,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(137,137,145,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(138,138,146,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(139,139,147,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(140,140,148,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(141,141,149,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(142,142,150,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(143,143,151,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(144,144,152,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(145,145,153,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(146,146,154,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(147,147,27,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03'),
(148,148,138,'owner',NULL,'active','2026-02-26 04:42:03','2026-02-26 04:42:03');
/*!40000 ALTER TABLE `identity_members` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=112 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `languages`
--

DROP TABLE IF EXISTS `languages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `languages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `code` char(255) NOT NULL,
  `direction` tinyint(4) NOT NULL,
  `is_default` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `languages`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `languages` WRITE;
/*!40000 ALTER TABLE `languages` DISABLE KEYS */;
INSERT INTO `languages` VALUES
(8,'English','en',0,1,'2021-05-31 05:58:22','2024-08-31 06:37:26');
/*!40000 ALTER TABLE `languages` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `mail_templates`
--

DROP TABLE IF EXISTS `mail_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `mail_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `mail_type` varchar(50) NOT NULL,
  `mail_subject` varchar(255) NOT NULL,
  `mail_body` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_templates`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `mail_templates` WRITE;
/*!40000 ALTER TABLE `mail_templates` DISABLE KEYS */;
INSERT INTO `mail_templates` VALUES
(4,'verify_email','Verify Your Email Address','<p>Hi <b>{username}</b>,</p><p>We just need to verify your email address before you can access to your dashboard.</p><p>Verify your email address, {verification_link}.</p><p>Thank you.<br />{website_title}</p><p><br /></p>'),
(5,'reset_password','Recover Password of Your Account','<p>Hi {customer_name},</p><p>We have received a request to reset your password. If you did not make the request, just ignore this email. Otherwise, you can reset your password using this below link.</p><p>{password_reset_link}</p><p>Thanks,<br>{website_title}</p>'),
(9,'event_booking','Event Confirmation','<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p>\r\n<p>You have successfully enrol in the following event.</p>\r\n<p>Booking Id: #{order_id}<br />Event: {title}</p>\r\n<p>Also, we have attached an invoice in this mail.</p>\r\n<p>Meeting Link :{meeting_url}</p>\r\n<p>Best regards.<br />{website_title}</p>'),
(10,'event_booking_approved','Approval of Event Booking','<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your payment is completed, and we have approved your booking for the following evnent.</p><p>Booking Id: #{order_id}<br /></p><p>Event : {title}</p><p>Also, we have attached an invoice in this mail.</p><p>Best regards.<br />{website_title}</p>'),
(11,'event_booking_rejected','Rejection of Event Booking','<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your payment is not completed, thus we have rejected your Booking for the following Event.</p><p>Booking Id: #{order_id}<br /></p><p>Event : {title}</p><p>For further information, please do not hesitate to contact us.<br />{website_title}</p>'),
(12,'product_order','Order Confirmation','<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your Order  has been  successfully Placed.</p><p>Order Id: #{order_id}<br /></p><p>Also, we have attached an invoice in this mail.</p><p>Best regards.<br />{website_title}</p>'),
(13,'withdraw_approve','Confirmation of Withdraw Approve','<p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Hi {organizer_username},</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">This email confirms that your withdrawal request  {withdraw_id} is approved. </p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Your current balance is {current_balance}, withdraw amount {withdraw_amount}, charge : {charge},payable amount {payable_amount}</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">withdraw method : {withdraw_method}. The transaction id is {transaction_id}.</p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\"><br /></p><p style=\"font-family:Lato, sans-serif;font-size:14px;line-height:1.82;color:rgb(0,0,0);font-style:normal;font-weight:400;text-align:left;\">Best Regards.<br />{website_title}</p>'),
(14,'withdraw_rejected','Withdraw Request Rejected','<p>Hi {organizer_username},</p><p>This email confirms that your withdrawal request  {withdraw_id} is rejected and the balance added to your account. </p><p>Your current balance is {current_balance}</p><p><br /></p><p>Best Regards.<br />{website_title}</p>'),
(15,'balance_add','Balance Add','<p>Hi {username}</p><p>{amount} added to your account.</p><p>Your current balance is {current_balance}. </p><p>The transaction id is {transaction_id}.<br /></p><p><br /></p><p>Best Regards.<br />{website_title}<br /></p>'),
(16,'balance_subtract','Balance Subtract','<p>Hi {username}</p><p>{amount} subtract from your account.</p><p>Your current balance is {current_balance}.</p><p>The transaction id is {transaction_id}.<br /></p><p><br /></p><p>Best Regards.<br />{website_title}</p>'),
(17,'product_shipping','Product Shipping Status','<p>Hi <span style=\"font-weight:600;\">{customer_name}</span>,</p><p>Your order shipping status is {status}.</p><p>Order Id: #{order_id}</p><p>Best regards.<br />{website_title}</p>');
/*!40000 ALTER TABLE `mail_templates` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `menu_builders`
--

DROP TABLE IF EXISTS `menu_builders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `menu_builders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `menus` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menu_builders`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `menu_builders` WRITE;
/*!40000 ALTER TABLE `menu_builders` DISABLE KEYS */;
INSERT INTO `menu_builders` VALUES
(2,8,'[{\"text\":\"Home\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"home\"},{\"text\":\"Events\",\"href\":\"events\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"events\"},{\"text\":\"Contact\",\"href\":\"\",\"icon\":\"empty\",\"target\":\"_self\",\"title\":\"\",\"type\":\"contact\"}]','2021-12-01 05:32:09','2026-01-03 16:38:34');
/*!40000 ALTER TABLE `menu_builders` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=124 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES
(3,'2023_03_04_134315_drop_secondary_color_from_basic_settings_table',1),
(6,'2023_03_05_152403_add_tax_commission_percentage_column_to_bookings_table',2),
(9,'2023_03_22_115828_add_column_to_conversations_table',3),
(10,'2023_05_11_150902_create_ticket_contents_table',4),
(14,'2023_05_13_124521_create_variation_contents_table',5),
(15,'2023_05_20_154216_add_about_page_title_column_to_page_headings_table',6),
(16,'2023_05_20_154329_add_meta_keyword_description_column_to_seos_table',6),
(17,'2023_07_30_094527_add_scan_status_column_to_bookings_table',7),
(18,'2023_09_30_162759_add_tax_percentage_column_to_product_orders_table',8),
(21,'2023_11_16_062730_add_event_guest_checkout_status_to_basic_settings_table',9),
(22,'2023_11_23_034714_add_scanned_tickets_column_to_bookings_table',10),
(23,'2024_02_07_055018_add_midtrans_payment_gateway_row_to_online_gateways_table',11),
(26,'2024_02_07_172740_add_iyzico_payment_gateway_into_online_gateways_table',12),
(32,'2024_02_10_105443_add_toyyibpay_payment_gateway_into_online_gateways',14),
(35,'2024_02_10_122829_add_phonepe_payment_gateway_into_online_gateways_table',15),
(37,'2024_02_10_152845_add_yoco_payment_gateway_into_online_gateways',16),
(39,'2024_02_10_172724_add_xindit_payment_gateway_into_online_gateways',17),
(44,'2021_02_01_030511_create_payment_invoices_table',18),
(45,'2024_02_11_143939_add_myfatoorah_payment_gateway_into_online_gateways',18),
(46,'2024_02_12_120007_add_conversation_id_to_event_bookings_table',19),
(47,'2024_02_12_162617_add_conversation_id_to_product_orders_table',20),
(49,'2024_02_08_153546_add_paytabs_payment_gateway_into_online_gateways',21),
(51,'2024_02_14_112643_add_perfect_money_payment_gateway_into_online_gateways_table',22),
(52,'2024_08_24_050913_add_ticket_header_image_ticket_background_color_instructiob_to_events_table',23),
(53,'2024_08_24_075435_theme_version_add_to_organizers_table',23),
(54,'2024_08_25_033713_meeting_url_add_to_events_table',24),
(55,'2024_08_27_062045_ticket_logo_add_to_events_table',25),
(56,'2024_08_29_034732_ticket_image_add_to_events_table',26),
(57,'2024_10_23_054145_add_scanned_tickets_colum_in_the_bookings_table',27),
(58,'2025_03_05_023749_add_a_colum_to_basic_settings',28),
(60,'2025_08_06_045540_add_column_into_basic_settings_table',29),
(61,'2025_08_06_065645_create_event_countries_table',30),
(62,'2025_08_06_083111_create_event_states_table',31),
(63,'2025_08_06_100543_create_event_cities_table',32),
(64,'2025_08_09_101952_add_column_into_event_contents_table',33),
(65,'2025_09_29_100732_create_slot_seats_table',34),
(66,'2025_09_29_100848_create_slot_images_table',34),
(67,'2025_09_29_102256_add_column_to_slot_column',34),
(68,'2025_09_29_114230_create_slots_table',35),
(69,'2025_09_30_092809_add_column_to_slot_free',36),
(70,'2019_12_14_000001_create_personal_access_tokens_table',37),
(72,'2025_10_14_065846_add_column_mobile_app',38),
(73,'2025_10_15_082023_add_column_to_mobile_interface',39),
(74,'2025_10_15_084350_add_row_create_to_online_payment_gateway',40),
(75,'2025_10_15_091301_add_row_create_to_online_payment_gateway_now_payment',41),
(76,'2025_10_15_110548_add_column_firebase_admin_json_to_basic_settings',42),
(77,'2025_10_18_124132_create_fcm_tokens_table',43),
(78,'2025_10_19_081020_add_column_fcm_token_to_bookings',44),
(79,'2025_10_19_112931_add_column_name_ticeket_seat_min_price_tickets',45),
(80,'2025_10_27_073616_add_column_message_title_message_description',46),
(81,'2025_10_28_103324_add_column_primary_colour_to_basic_settings',47),
(82,'2025_10_29_103618_add_coloumn_ticket_slot_image_to_events',48),
(85,'2025_11_03_094910_add_column_booking_id_to_fcm_tokens',50),
(87,'2025_11_04_054320_add_column_app_google_map_status_to_basic_settings',51),
(88,'2025_11_10_123600_add_column_mobile_interface_section_title',52),
(89,'2026_02_19_013616_add_order_number_to_bookings_table',53),
(90,'2026_02_19_183730_create_wallets_table',53),
(91,'2026_02_19_183733_create_wallet_transactions_table',53),
(92,'2026_02_19_235808_create_wallet_holds_table',53),
(93,'2026_02_20_004930_create_payment_methods_table',53),
(94,'2026_02_20_004932_add_stripe_customer_id_to_users_table',53),
(95,'2026_02_20_014606_add_marketplace_fields_to_bookings_table',53),
(96,'2026_02_20_014610_create_ticket_transfers_table',53),
(97,'2026_02_20_020000_create_pos_terminals_table',53),
(98,'2026_02_20_020001_create_pos_transactions_table',53),
(99,'2026_02_20_020002_create_nfc_tokens_table',53),
(100,'2026_02_20_020133_create_withdrawal_requests_table',53),
(101,'2026_02_20_030000_create_subscription_plans_table',53),
(102,'2026_02_20_030001_create_subscriptions_table',53),
(103,'2026_02_20_092921_add_firebase_fields_to_customers_table',53),
(104,'2026_02_20_094038_drop_foreign_key_from_wallets',53),
(105,'2026_02_20_195645_add_phone_verified_at_to_customers_table',53),
(106,'2026_02_21_141046_add_date_of_birth_to_customers_and_age_limit_to_events',53),
(107,'2026_02_21_170057_add_marketplace_commission_to_basic_settings',53),
(108,'2026_02_23_000000_create_followers_table',53),
(109,'2026_02_23_212648_create_chats_table',53),
(110,'2026_02_23_212650_create_chat_messages_table',53),
(111,'2026_02_24_030145_add_stripe_customer_id_to_customers_table',53),
(112,'2026_02_24_110500_add_audit_fields_to_wallet_transactions',53),
(113,'2026_02_25_000000_create_venues_table',53),
(114,'2026_02_25_000001_add_venue_id_to_events',53),
(115,'2026_02_25_010000_create_artists_table',53),
(116,'2026_02_25_010001_update_venues_table_auth',53),
(117,'2026_02_25_010002_make_followers_polymorphic',53),
(118,'2026_02_25_013739_create_event_artist_table',54),
(119,'2026_02_25_014031_add_role_ids_to_transactions_and_withdraws_tables',54),
(120,'2026_02_25_093850_add_is_private_to_customers_table',54),
(121,'2026_02_26_100000_create_identities_table',54),
(122,'2026_02_26_100001_create_identity_members_table',54),
(123,'2026_02_26_100002_add_identity_columns_to_events_table',54);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `nfc_tokens`
--

DROP TABLE IF EXISTS `nfc_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `nfc_tokens` (
  `id` char(36) NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `uid_hash` varchar(255) NOT NULL,
  `pin_hash` varchar(255) DEFAULT NULL,
  `status` enum('active','locked','lost','expired') NOT NULL DEFAULT 'active',
  `daily_limit` decimal(10,2) NOT NULL DEFAULT 5000.00,
  `daily_spent` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `nfc_tokens_uid_hash_unique` (`uid_hash`),
  KEY `nfc_tokens_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nfc_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `nfc_tokens` WRITE;
/*!40000 ALTER TABLE `nfc_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `nfc_tokens` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `offline_gateways`
--

DROP TABLE IF EXISTS `offline_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `offline_gateways` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `short_description` text DEFAULT NULL,
  `instructions` blob DEFAULT NULL,
  `status` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 -> gateway is deactive, 1 -> gateway is active.',
  `has_attachment` tinyint(1) NOT NULL COMMENT '0 -> do not need attachment, 1 -> need attachment.',
  `serial_number` mediumint(8) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `offline_gateways`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `offline_gateways` WRITE;
/*!40000 ALTER TABLE `offline_gateways` DISABLE KEYS */;
/*!40000 ALTER TABLE `offline_gateways` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `online_gateways`
--

DROP TABLE IF EXISTS `online_gateways`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `online_gateways` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `keyword` varchar(255) NOT NULL,
  `information` mediumtext NOT NULL,
  `status` tinyint(3) unsigned NOT NULL,
  `mobile_status` tinyint(4) NOT NULL DEFAULT 0,
  `mobile_information` longtext DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `online_gateways`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `online_gateways` WRITE;
/*!40000 ALTER TABLE `online_gateways` DISABLE KEYS */;
INSERT INTO `online_gateways` VALUES
(1,'PayPal','paypal','{\"sandbox_status\":\"0\",\"client_id\":\"AVYKFEw63FtDt9aeYOe9biyifNI56s2Hc2F1Us11hWoY5GMuegipJRQBfWLiIKNbwQ5tmqKSrQTU3zB3\",\"client_secret\":\"EJY0qOKliVg7wKsR3uPN7lngr9rL1N7q4WV0FulT1h4Fw3_e5Itv1mxSdbtSUwAaQoXQFgq-RLlk_sQu\"}',0,0,'{\"sandbox_status\":\"0\",\"client_id\":\"rr\",\"client_secret\":\"rr\"}'),
(2,'Instamojo','instamojo','{\"sandbox_status\":\"0\",\"key\":\"rr6\",\"token\":\"rr6\"}',0,0,NULL),
(3,'Paystack','paystack','{\"key\":\"rr\"}',0,0,'{\"key\":\"rr\"}'),
(4,'Flutterwave','flutterwave','{\"public_key\":\"rr6\",\"secret_key\":\"rr6\"}',0,0,'{\"public_key\":\"rr\",\"secret_key\":\"rr\"}'),
(5,'Razorpay','razorpay','{\"key\":\"rr\",\"secret\":\"rr\"}',0,0,'{\"key\":\"rr\",\"secret\":\"rr\"}'),
(6,'MercadoPago','mercadopago','{\"sandbox_status\":\"0\",\"token\":\"rr6\"}',0,0,'{\"sandbox_status\":\"0\",\"token\":\"rr\"}'),
(7,'Mollie','mollie','{\"key\":\"rr6\"}',0,0,'{\"key\":\"rr\"}'),
(8,'Stripe','stripe','{\"key\":\"pk_live_51J0c0WL4AZYkD20iZ317UPxM35SKKmepSmQ7Em4vsLQ0VG29ePVBIwfP227Nuyp6FLeUu4vCLvrIsrVcaoaBenxz00o1xDiu00\",\"secret\":\"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\"}',1,1,'{\"key\":\"pk_live_51J0c0WL4AZYkD20iZ317UPxM35SKKmepSmQ7Em4vsLQ0VG29ePVBIwfP227Nuyp6FLeUu4vCLvrIsrVcaoaBenxz00o1xDiu00\",\"secret\":\"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\"}'),
(9,'Paytm','paytm','{\"environment\":\"production\",\"merchant_key\":\"rr6\",\"merchant_mid\":\"rr6\",\"merchant_website\":\"rr6\",\"industry_type\":\"rr6\"}',0,0,NULL),
(10,'Midtrans','midtrans','{\"is_production\":\"0\",\"server_key\":\"rr6\"}',0,0,'{\"is_production\":\"0\",\"server_key\":\"rr\"}'),
(13,'Iyzico','iyzico','{\"sandbox_status\":\"0\",\"api_key\":\"rr6\",\"secret_key\":\"rr6\"}',0,0,NULL),
(19,'Toyyibpay','toyyibpay','{\"sandbox_status\":\"0\",\"secret_key\":\"rr6\",\"category_code\":\"rr6\"}',0,0,'{\"sandbox_status\":\"0\",\"secret_key\":\"rr\",\"category_code\":\"rr\"}'),
(22,'Phonepe','phonepe','{\"merchant_id\":\"rr6\",\"sandbox_status\":\"0\",\"salt_key\":\"rr6\",\"salt_index\":\"6\"}',0,0,'{\"merchant_id\":\"rr\",\"sandbox_status\":\"0\",\"salt_key\":\"rr\",\"salt_index\":\"1\"}'),
(24,'Yoco','yoco','{\"secret_key\":\"rr6\"}',0,0,NULL),
(26,'Xendit','xendit','{\"secret_key\":\"rr6\"}',0,0,'{\"secret_key\":\"rr\"}'),
(29,'Myfatoorah','myfatoorah','{\"token\":\"rr\",\"sandbox_status\":\"0\"}',0,0,'{\"token\":\"rr\",\"sandbox_status\":\"0\"}'),
(30,'Paytabs','paytabs','{\"server_key\":\"rr6\",\"profile_id\":\"rr6\",\"country\":\"global\",\"api_endpoint\":\"rr6\"}',0,0,NULL),
(32,'Perfect Money','perfect_money','{\"perfect_money_wallet_id\":\"rr6\"}',0,0,NULL),
(33,'Authorize.net','authorize.net','',0,0,''),
(34,'Monnify','monnify','',0,0,'{\"sandbox_status\":\"0\",\"api_key\":\"rr\",\"secret_key\":\"rr\",\"wallet_account_number\":\"1\"}'),
(35,'NowPayments','now_payments','',0,0,'{\"api_key\":\"rr\"}');
/*!40000 ALTER TABLE `online_gateways` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `order_items` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_order_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `sku` varchar(255) DEFAULT NULL,
  `qty` varchar(255) DEFAULT NULL,
  `category` varchar(255) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `summery` text DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `previous_price` decimal(8,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `organizer_infos`
--

DROP TABLE IF EXISTS `organizer_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizer_infos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) DEFAULT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `details` longtext DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizer_infos`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `organizer_infos` WRITE;
/*!40000 ALTER TABLE `organizer_infos` DISABLE KEYS */;
INSERT INTO `organizer_infos` VALUES
(2,8,20,'Hossain','Bangladesh','Dhaka','North Carolina','1230','House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh','Hi there! I\'m ChatSonic, an AI Chatbot that uses the latest and most advanced natural language processing technology to answer your questions accurately and informatively. I\'m here to help you with your questions about yourself. Here is a list of 101 facts about myself: I love to start numbering from zero instead of one, I love to take photographs wherever I go, I love harmony, I love martial arts, I can eat same food, day-in-day-out and not get bored, I can listen to same song non-stop in loop for days and still enjoy it, I can\'t live without access to my linux box,','fsadfaf','2023-01-09 12:01:26','2023-01-12 06:07:10'),
(3,17,20,'Hossain','Bangladesh','Dhaka','North Carolina','1230','House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh','Hi there! I\'m ChatSonic, an AI Chatbot that uses the latest and most advanced natural language processing technology to answer your questions accurately and informatively. I\'m here to help you with your questions about yourself. Here is a list of 101 facts about myself: I love to start numbering from zero instead of one, I love to take photographs wherever I go, I love harmony, I love martial arts, I can eat same food, day-in-day-out and not get bored, I can listen to same song non-stop in loop for days and still enjoy it, I can\'t live without access to my linux box,','fsadfaf','2023-01-09 12:33:08','2023-01-12 06:07:10'),
(4,8,18,'Fahad Ahmad Shemul','Bangladesh','Dhaka','North Carolina','1230','House no 3, Road 5/c, sector 11, Uttara','opt to that kind of lifestyle, I would rather sit alone on my a$$ with a book than booze and party, I would rather play exhausting sport than sit on my a$$ and read a book, I love the fragrance of wet mud, I like to dream, I am a teetotaler, and this bugs a lot of my buddies, If God gave me the power to remove any 3 vices from the world, I would remove: Politicians/Politics Greed and Jealousy, In my view breathing techniques, are the most advanced form of exercises. I have been trained in a few of these techniques, and someday I\'ll learn and','fsadfaf','2023-01-12 06:07:40','2023-01-21 10:34:33'),
(5,17,18,'Fahad Ahmad Shemul','Bangladesh','Dhaka','North Carolina','1230','House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh','opt to that kind of lifestyle, I would rather sit alone on my a$$ with a book than booze and party, I would rather play exhausting sport than sit on my a$$ and read a book, I love the fragrance of wet mud, I like to dream, I am a teetotaler, and this bugs a lot of my buddies, If God gave me the power to remove any 3 vices from the world, I would remove: Politicians/Politics Greed and Jealousy, In my view breathing techniques, are the most advanced form of exercises. I have been trained in a few of these techniques, and someday I\'ll learn and','fsadfaf','2023-01-12 06:07:40','2023-01-21 10:34:47'),
(6,8,21,'Lamar Wilder','Dolore quibusdam aut','Omnis sit voluptas m','Et dolor eiusmod eni','93092','Autem id in aliqua','Culpa dolore velit','Ut veniam et dolore','2023-01-21 06:59:11','2023-01-21 06:59:11'),
(7,17,21,'Lamar Wilder','Dolore quibusdam aut','Omnis sit voluptas m','Et dolor eiusmod eni','93092','Autem id in aliqua','Culpa dolore velit','Ut veniam et dolore','2023-01-21 06:59:11','2023-01-21 06:59:11'),
(8,8,22,'Talon Beard',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2023-05-01 09:03:40','2023-05-01 09:03:40'),
(9,8,23,'Robert J. Murray','United States','Readsboro','North Carolina','05350','Readsboro, North Carolina, United States','Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups','Chief executive officer','2023-05-02 09:50:29','2023-05-07 11:03:02'),
(10,22,23,'جوناس','الولايات المتحدة الأمريكية','ريدسبورو','نورث كارولينا','05350','ريدسبورو ، نورث كارولينا ، الولايات المتحدة','من بفرض يتعلّق فعل, كل جهة هامش مارد وإقامة. أم بلا وبعد يقوم ومضى, خطّة لعدم ا\r\nلأحمر وفي أي, كُلفة أفريقيا بمعارضة نفس قد. دول تم إعلان الأمم الإقتصادية, مايو أهّل استطاعوا قام كل. أخر قد وحتى أطراف الجنوب.','الرئيس التنفيذي','2023-05-02 09:51:44','2023-05-07 11:03:02'),
(11,27,23,'Fahad Ahmad Shemul','Bangladesh','Dhaka','North Carolina','1230','House no 3, Road 5/c, sector 11, Uttara, Dhaka, Bangladesh',NULL,'fsadfaf','2023-05-02 09:51:44','2023-05-02 09:51:44'),
(12,8,24,'Ken Champlin','Australia','Sydney','New South Wales','59154','Elizabeth Bay NSW 2011, Sydney, Australia','While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.','ceo of abc','2023-05-07 10:53:07','2023-05-11 05:45:20'),
(13,22,24,'ماجي برينس','أستراليا','سيدني','نيو ساوث ويلز','59154','إليزابيث باي نيو ساوث ويلز 2011, سيدني, أستراليا','إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.','الرئيس التنفيذي لشركة عمار','2023-05-07 10:53:07','2023-05-07 10:53:07'),
(14,8,25,'Ambrose Thiel','United States','Columbus','Ohio','24855','Columbus, Ohio, United States','While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn\'t contain the letters K, W, or Z, alien to latin, these, and others are often inserted randomly to mimic the typographic appearence of European languages, as are digraphs not to be found in the original.','Executive','2023-05-07 10:57:11','2023-05-11 05:44:46'),
(15,22,25,'جوسلين كاش','الولايات المتحدة الأمريكية','كولومبوس','أوهايو','24855','كولومبوس ، أوهايو ، الولايات المتحدة','وبغطاء الثقيلة الإكتفاء بال كل, ٣٠ انه الهادي محاولات الأهداف. ساعة بمباركة اليابان، أما من, وسفن ليبين المضي قام مع. حتى في بأضرار باستحداث. بحق وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا حيث بل, يقوم قائمة العظمى لمّ ان, مما أي دفّة وحتّى.','تنفيذي','2023-05-07 10:57:11','2023-05-07 10:57:11'),
(16,8,26,'Amber Cannon','United States','Tonopah','North Carolina','69114','Tonopah, North Carolina, United States','Lorem ipsum is a pseudo-Latin text used in web design, typography, layout, and printing in place of English to emphasise design elements over content. It\'s also called placeholder (or filler) text. It\'s a convenient tool for mock-ups. It helps to outline the visual elements of a document or presentation, eg typography, font, or layout.','Chief marketing officer','2023-05-07 11:01:23','2023-05-07 11:01:23'),
(17,22,26,'مدفع العنبر','الولايات المتحدة الأمريكية','تونوباه','نورث كارولينا','69114','تونوباه ، كارولاينا الشمالية ، الولايات المتحدة','إبّان شواطيء سنغافورة أي ذلك, بل ومن الهادي واشتدّت, فكانت السادس الأراضي فصل ان. قد كان لغزو كنقطة بالرّغم, أن سقوط إحكام ويتّفق بين, أم جُل النفط والإتحاد التغييرات. عل فقد لليابان الأوروبية،, ودول كانت واحدة أم لكل, لم به، تحرير المنتصر. حصدت بالرغم وأكثرها حيث ان, عل فقد اوروبا والديون. مكن أم وبدأت ا استطاعوا, ثم كانت مهمّات بعض. بـ يتمكن الإمداد به،, أم ولم واستمرت المتساقطة،, شدّت لدحر تكبّد عل أما.','الرئيس التنفيذي للتسويق','2023-05-07 11:01:23','2023-05-07 11:01:23'),
(18,8,27,'Burke Watts',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2023-05-11 05:59:10','2023-05-11 05:59:10'),
(19,8,27,'Magee Hernandez',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-05 07:10:02','2025-11-05 07:10:02'),
(20,8,28,'Kelly Gregory',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-05 07:10:21','2025-11-05 07:10:21'),
(21,8,29,'Xander Workman',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-05 07:12:57','2025-11-05 07:12:57'),
(22,8,30,'Caldwell Taylor',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-11-06 00:59:45','2025-11-06 00:59:45'),
(23,8,31,'Hidden Events',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-06 06:21:26','2025-12-06 06:21:26'),
(24,8,32,'Robert',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2025-12-31 14:54:24','2025-12-31 14:54:24'),
(25,8,33,'Juharin payano',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-03 04:43:47','2026-01-03 04:43:47'),
(26,8,34,'Dennise',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-01-03 23:02:55','2026-01-03 23:02:55'),
(27,8,35,'Pedro Angel Mata Paukino',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-02-12 15:00:37','2026-02-12 15:00:37');
/*!40000 ALTER TABLE `organizer_infos` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `organizers`
--

DROP TABLE IF EXISTS `organizers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `organizers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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
  `theme_version` varchar(255) DEFAULT 'light',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `organizers` WRITE;
/*!40000 ALTER TABLE `organizers` DISABLE KEYS */;
INSERT INTO `organizers` VALUES
(31,'6933cb663f418.jpg','info@hidden.do',NULL,'hidden','$2y$10$VMY/I8hvzSLnOrSIbz.8UOnVkmkRWonj2HZgFjMwhSDvdeAkL0f2e','1',38420,'2025-12-06 06:21:26',NULL,NULL,NULL,'2025-12-06 06:21:26','2026-02-19 03:23:56','light'),
(32,NULL,'juniorwkx@gmail.com',NULL,'juniorwkx','$2y$10$3.B1RCsk0dqFLmnKLnF4fer.lEsV7sRQ83yFikJY8iyL..UGRXiQK','0',NULL,'2025-12-31 14:56:57',NULL,NULL,NULL,'2025-12-31 14:54:24','2025-12-31 14:56:57','light'),
(33,NULL,'el_juarin_15@hotmail.com',NULL,'Jamesjames','$2y$10$GgtIe8TLLx8WNBOGSnnwu.aLLg4bkClQcPVSHn.Y82dLbwpiOPFOS','0',NULL,'2026-01-03 04:52:51',NULL,NULL,NULL,'2026-01-03 04:43:47','2026-01-03 04:52:51','light'),
(34,NULL,'lara.yasiris15@gmail.com',NULL,'Lara','$2y$10$lPg6asRdvDLCzIk3B0LhBuiMt2HvEhYLoVkk6rdSbJUGkybh/H0fi','0',NULL,'2026-01-03 23:20:22',NULL,NULL,NULL,'2026-01-03 23:02:55','2026-01-03 23:20:22','light'),
(35,NULL,'pedroangel642@gmail.com',NULL,'Pedrowsky','$2y$10$3/ocJgHh7gkUAWbH.HowgesHbsbwkyxPAu9oQsCdUx4fVH2QSonUK','0',NULL,'2026-02-12 15:01:00',NULL,NULL,NULL,'2026-02-12 15:00:37','2026-02-12 15:01:00','light');
/*!40000 ALTER TABLE `organizers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `page_contents`
--

DROP TABLE IF EXISTS `page_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `page_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `page_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` blob NOT NULL,
  `meta_keywords` varchar(255) DEFAULT NULL,
  `meta_description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `page_contents_language_id_foreign` (`language_id`),
  KEY `page_contents_page_id_foreign` (`page_id`),
  CONSTRAINT `page_contents_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `page_contents_page_id_foreign` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `page_contents` WRITE;
/*!40000 ALTER TABLE `page_contents` DISABLE KEYS */;
INSERT INTO `page_contents` VALUES
(30,8,14,'Terms & Conditions','terms-&-conditions','<p style=\"color:#747474;font-family:Rubik, sans-serif;\">Welcome to Evento. These terms and conditions outline the rules and regulations for the use of our website.</p>\n      \n      <h5>1. Acceptance of Terms</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">By accessing and using our website, you agree to be bound by these terms and conditions. If you do not agree to these terms and conditions, you should not use our website.</p>\n      \n      <h5>2. Intellectual Property</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">All intellectual property rights in the website and the content published on it, including but not limited to copyright and trademarks, are owned by us or our licensors. You may not use any of our intellectual property without our prior written consent.</p>\n      \n      <h5>3. User Content</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">By submitting any content to our website, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, distribute, and display such content in any media formats and through any media channels.</p>\n      \n      <h5>4. Disclaimer of Warranties</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">Our website and the content published on it are provided on an \"as is\" and \"as available\" basis. We do not make any warranties, express or implied, regarding the website, including but not limited to the accuracy, reliability, or suitability of the content for any particular purpose.</p>\n      \n      <h5>5. Limitation of Liability</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">We shall not be liable for any damages, including but not limited to direct, indirect, incidental, punitive, and consequential damages, arising from the use or inability to use our website or the content published on it.</p>\n      \n      <h5>6. Modifications to Terms and Conditions</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">We reserve the right to modify these terms and conditions at any time without prior notice. Your continued use of our website after any such modifications indicates your acceptance of the modified terms and conditions.</p>\n      \n      <h5>7. Governing Law and Jurisdiction</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">These terms and conditions shall be governed by and construed in accordance with the laws of the jurisdiction in which we operate, without giving effect to any principles of conflicts of law. Any legal proceedings arising out of or in connection with these terms and conditions shall be brought solely in the courts located in the jurisdiction in which we operate.</p>\n      \n      <h5>8. Termination</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">We may terminate or suspend your access to our website immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach these terms and conditions.</p>\n      \n      <h5>9. Contact Information</h5>\n      <p style=\"color:#747474;font-family:Rubik, sans-serif;\">If you have any questions or comments about these terms and conditions, please contact us at info@evento.com.</p>','terms','Unless otherwise stated, Evento and/or its licensors own the intellectual property rights for all material on Evento. All intellectual property rights are reserved. You may access this from Evento for your own personal use subjected to restrictions set in these terms and conditions.','2021-10-18 02:33:45','2023-05-18 08:11:05'),
(39,8,16,'Privacy Policy','privacy-policy','<p>Privacy Policy</p>\r\n<p>This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.</p>\r\n<p>We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy. </p>\r\n<h4>Interpretation</h4>\r\n<p>The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.</p>\r\n<h4>Definitions</h4>\r\n<p>For the purposes of this Privacy Policy:</p>\r\n<ul>\r\n<li>\r\n<p><strong>Account</strong> means a unique account created for You to access our Service or parts of our Service.</p>\r\n</li>\r\n<li>\r\n<p><strong>Affiliate</strong> means an entity that controls, is controlled by or is under common control with a party, where \"control\" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.</p>\r\n</li>\r\n<li>\r\n<p><strong>Company</strong> (referred to as either \"the Company\", \"We\", \"Us\" or \"Our\" in this Agreement) refers to Evento.</p>\r\n</li>\r\n<li>\r\n<p><strong>Cookies</strong> are small files that are placed on Your computer, mobile device or any other device by a website, containing the details of Your browsing history on that website among its many uses.</p>\r\n</li>\r\n<li>\r\n<p><strong>Country</strong> refers to: Alaska, United States</p>\r\n</li>\r\n<li>\r\n<p><strong>Device</strong> means any device that can access the Service such as a computer, a cellphone or a digital tablet.</p>\r\n</li>\r\n<li>\r\n<p><strong>Personal Data</strong> is any information that relates to an identified or identifiable individual.</p>\r\n</li>\r\n<li>\r\n<p><strong>Service</strong> refers to the Website.</p>\r\n</li>\r\n<li>\r\n<p><strong>Service Provider</strong> means any natural or legal person who processes the data on behalf of the Company. It refers to third-party companies or individuals employed by the Company to facilitate the Service, to provide the Service on behalf of the Company, to perform services related to the Service or to assist the Company in analyzing how the Service is used.</p>\r\n</li>\r\n<li>\r\n<p><strong>Third-party Social Media Service</strong> refers to any website or any social network website through which a User can log in or create an account to use the Service.</p>\r\n</li>\r\n<li>\r\n<p><strong>Usage Data</strong> refers to data collected automatically, either generated by the use of the Service or from the Service infrastructure itself (for example, the duration of a page visit).</p>\r\n</li>\r\n<li>\r\n<p><strong>Website</strong> refers to Evento, accessible from <a href=\"https://codecanyon8.kreativdev.com/evento\">https://codecanyon8.kreativdev.com/evento</a></p>\r\n</li>\r\n<li>\r\n<p><strong>You</strong> means the individual accessing or using the Service, or the company, or other legal entity on behalf of which such individual is accessing or using the Service, as applicable.</p>\r\n</li>\r\n</ul>\r\n<p>Collecting and Using Your Personal Data</p>\r\n<p> </p>\r\n<h4><span style=\"font-size:1.0375rem;font-weight:bold;\">Personal Data</span></h4>\r\n<p>While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:</p>\r\n<ul>\r\n<li>\r\n<p>Email address</p>\r\n</li>\r\n<li>\r\n<p>First name and last name</p>\r\n</li>\r\n<li>\r\n<p>Phone number</p>\r\n</li>\r\n<li>\r\n<p>Address, State, Province, ZIP/Postal code, City</p>\r\n</li>\r\n<li>\r\n<p>Usage Data</p>\r\n</li>\r\n</ul>\r\n<h4>Usage Data</h4>\r\n<p>Usage Data is collected automatically when using the Service.</p>\r\n<p>Usage Data may include information such as Your Device\'s Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that You visit, the time and date of Your visit, the time spent on those pages, unique device identifiers and other diagnostic data.</p>\r\n<p>When You access the Service by or through a mobile device, We may collect certain information automatically, including, but not limited to, the type of mobile device You use, Your mobile device unique ID, the IP address of Your mobile device, Your mobile operating system, the type of mobile Internet browser You use, unique device identifiers and other diagnostic data.</p>\r\n<p>We may also collect information that Your browser sends whenever You visit our Service or when You access the Service by or through a mobile device.</p>\r\n<h4>Information from Third-Party Social Media Services</h4>\r\n<p>The Company allows You to create an account and log in to use the Service through the following Third-party Social Media Services:</p>\r\n<ul>\r\n<li>Google</li>\r\n<li>Facebook</li>\r\n</ul>\r\n<p>If You decide to register through or otherwise grant us access to a Third-Party Social Media Service, We may collect Personal data that is already associated with Your Third-Party Social Media Service\'s account, such as Your name, Your email address, Your activities or Your contact list associated with that account.</p>\r\n<p>You may also have the option of sharing additional information with the Company through Your Third-Party Social Media Service\'s account. If You choose to provide such information and Personal Data, during registration or otherwise, You are giving the Company permission to use, share, and store it in a manner consistent with this Privacy Policy.</p>\r\n<h4>Tracking Technologies and Cookies</h4>\r\n<p>We use Cookies and similar tracking technologies to track the activity on Our Service and store certain information. Tracking technologies used are beacons, tags, and scripts to collect and track information and to improve and analyze Our Service. The technologies We use may include:</p>\r\n<ul>\r\n<li><strong>Cookies or Browser Cookies.</strong> A cookie is a small file placed on Your Device. You can instruct Your browser to refuse all Cookies or to indicate when a Cookie is being sent. However, if You do not accept Cookies, You may not be able to use some parts of our Service. Unless you have adjusted Your browser setting so that it will refuse Cookies, our Service may use Cookies.</li>\r\n<li><strong>Web Beacons.</strong> Certain sections of our Service and our emails may contain small electronic files known as web beacons (also referred to as clear gifs, pixel tags, and single-pixel gifs) that permit the Company, for example, to count users who have visited those pages or opened an email and for other related website statistics (for example, recording the popularity of a certain section and verifying system and server integrity).</li>\r\n</ul>\r\n<p>Cookies can be \"Persistent\" or \"Session\" Cookies. Persistent Cookies remain on Your personal computer or mobile device when You go offline, while Session Cookies are deleted as soon as You close Your web browser. Learn more about cookies on the <a href=\"https://www.freeprivacypolicy.com/blog/sample-privacy-policy-template/#Use_Of_Cookies_And_Tracking\">Free Privacy Policy website</a> article.</p>\r\n<p>We use both Session and Persistent Cookies for the purposes set out below:</p>\r\n<ul>\r\n<li>\r\n<p><strong>Necessary / Essential Cookies</strong></p>\r\n<p>Type: Session Cookies</p>\r\n<p>Administered by: Us</p>\r\n<p>Purpose: These Cookies are essential to provide You with services available through the Website and to enable You to use some of its features. They help to authenticate users and prevent fraudulent use of user accounts. Without these Cookies, the services that You have asked for cannot be provided, and We only use these Cookies to provide You with those services.</p>\r\n</li>\r\n<li>\r\n<p><strong>Cookies Policy / Notice Acceptance Cookies</strong></p>\r\n<p>Type: Persistent Cookies</p>\r\n<p>Administered by: Us</p>\r\n<p>Purpose: These Cookies identify if users have accepted the use of cookies on the Website.</p>\r\n</li>\r\n<li>\r\n<p><strong>Functionality Cookies</strong></p>\r\n<p>Type: Persistent Cookies</p>\r\n<p>Administered by: Us</p>\r\n<p>Purpose: These Cookies allow us to remember choices You make when You use the Website, such as remembering your login details or language preference. The purpose of these Cookies is to provide You with a more personal experience and to avoid You having to re-enter your preferences every time You use the Website.</p>\r\n</li>\r\n</ul>\r\n<p>For more information about the cookies we use and your choices regarding cookies, please visit our Cookies Policy or the Cookies section of our Privacy Policy.</p>\r\n<h4>Use of Your Personal Data</h4>\r\n<p>The Company may use Personal Data for the following purposes:</p>\r\n<ul>\r\n<li>\r\n<p><strong>To provide and maintain our Service</strong>, including to monitor the usage of our Service.</p>\r\n</li>\r\n<li>\r\n<p><strong>To manage Your Account:</strong> to manage Your registration as a user of the Service. The Personal Data You provide can give You access to different functionalities of the Service that are available to You as a registered user.</p>\r\n</li>\r\n<li>\r\n<p><strong>For the performance of a contract:</strong> the development, compliance and undertaking of the purchase contract for the products, items or services You have purchased or of any other contract with Us through the Service.</p>\r\n</li>\r\n<li>\r\n<p><strong>To contact You:</strong> To contact You by email, telephone calls, SMS, or other equivalent forms of electronic communication, such as a mobile application\'s push notifications regarding updates or informative communications related to the functionalities, products or contracted services, including the security updates, when necessary or reasonable for their implementation.</p>\r\n</li>\r\n<li>\r\n<p><strong>To provide You</strong> with news, special offers and general information about other goods, services and events which we offer that are similar to those that you have already purchased or enquired about unless You have opted not to receive such information.</p>\r\n</li>\r\n<li>\r\n<p><strong>To manage Your requests:</strong> To attend and manage Your requests to Us.</p>\r\n</li>\r\n<li>\r\n<p><strong>For business transfers:</strong> We may use Your information to evaluate or conduct a merger, divestiture, restructuring, reorganization, dissolution, or other sale or transfer of some or all of Our assets, whether as a going concern or as part of bankruptcy, liquidation, or similar proceeding, in which Personal Data held by Us about our Service users is among the assets transferred.</p>\r\n</li>\r\n<li>\r\n<p><strong>For other purposes</strong>: We may use Your information for other purposes, such as data analysis, identifying usage trends, determining the effectiveness of our promotional campaigns and to evaluate and improve our Service, products, services, marketing and your experience.</p>\r\n</li>\r\n</ul>\r\n<p>We may share Your personal information in the following situations:</p>\r\n<ul>\r\n<li><strong>With Service Providers:</strong> We may share Your personal information with Service Providers to monitor and analyze the use of our Service, to contact You.</li>\r\n<li><strong>For business transfers:</strong> We may share or transfer Your personal information in connection with, or during negotiations of, any merger, sale of Company assets, financing, or acquisition of all or a portion of Our business to another company.</li>\r\n<li><strong>With Affiliates:</strong> We may share Your information with Our affiliates, in which case we will require those affiliates to honor this Privacy Policy. Affiliates include Our parent company and any other subsidiaries, joint venture partners or other companies that We control or that are under common control with Us.</li>\r\n<li><strong>With business partners:</strong> We may share Your information with Our business partners to offer You certain products, services or promotions.</li>\r\n<li><strong>With other users:</strong> when You share personal information or otherwise interact in the public areas with other users, such information may be viewed by all users and may be publicly distributed outside. If You interact with other users or register through a Third-Party Social Media Service, Your contacts on the Third-Party Social Media Service may see Your name, profile, pictures and description of Your activity. Similarly, other users will be able to view descriptions of Your activity, communicate with You and view Your profile.</li>\r\n<li><strong>With Your consent</strong>: We may disclose Your personal information for any other purpose with Your consent.</li>\r\n</ul>\r\n<h4>Retention of Your Personal Data</h4>\r\n<p>The Company will retain Your Personal Data only for as long as is necessary for the purposes set out in this Privacy Policy. We will retain and use Your Personal Data to the extent necessary to comply with our legal obligations (for example, if we are required to retain your data to comply with applicable laws), resolve disputes, and enforce our legal agreements and policies.</p>\r\n<p>The Company will also retain Usage Data for internal analysis purposes. Usage Data is generally retained for a shorter period of time, except when this data is used to strengthen the security or to improve the functionality of Our Service, or We are legally obligated to retain this data for longer time periods.</p>\r\n<h4>Transfer of Your Personal Data</h4>\r\n<p>Your information, including Personal Data, is processed at the Company\'s operating offices and in any other places where the parties involved in the processing are located. It means that this information may be transferred to — and maintained on — computers located outside of Your state, province, country or other governmental jurisdiction where the data protection laws may differ than those from Your jurisdiction.</p>\r\n<p>Your consent to this Privacy Policy followed by Your submission of such information represents Your agreement to that transfer.</p>\r\n<p>The Company will take all steps reasonably necessary to ensure that Your data is treated securely and in accordance with this Privacy Policy and no transfer of Your Personal Data will take place to an organization or a country unless there are adequate controls in place including the security of Your data and other personal information.</p>\r\n<h4>Delete Your Personal Data</h4>\r\n<p>You have the right to delete or request that We assist in deleting the Personal Data that We have collected about You.</p>\r\n<p>Our Service may give You the ability to delete certain information about You from within the Service.</p>\r\n<p>You may update, amend, or delete Your information at any time by signing in to Your Account, if you have one, and visiting the account settings section that allows you to manage Your personal information. You may also contact Us to request access to, correct, or delete any personal information that You have provided to Us.</p>\r\n<p>Please note, however, that We may need to retain certain information when we have a legal obligation or lawful basis to do so.</p>\r\n<h4><span style=\"font-size:1.1625rem;\">Business Transactions</span></h4>\r\n<p>If the Company is involved in a merger, acquisition or asset sale, Your Personal Data may be transferred. We will provide notice before Your Personal Data is transferred and becomes subject to a different Privacy Policy.</p>\r\n<h4>Law enforcement</h4>\r\n<p>Under certain circumstances, the Company may be required to disclose Your Personal Data if required to do so by law or in response to valid requests by public authorities (e.g. a court or a government agency).</p>\r\n<h4>Other legal requirements</h4>\r\n<p>The Company may disclose Your Personal Data in the good faith belief that such action is necessary to:</p>\r\n<ul>\r\n<li>Comply with a legal obligation</li>\r\n<li>Protect and defend the rights or property of the Company</li>\r\n<li>Prevent or investigate possible wrongdoing in connection with the Service</li>\r\n<li>Protect the personal safety of Users of the Service or the public</li>\r\n<li>Protect against legal liability</li>\r\n</ul>\r\n<h4>Security of Your Personal Data</h4>\r\n<p>The security of Your Personal Data is important to Us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While We strive to use commercially acceptable means to protect Your Personal Data, We cannot guarantee its absolute security.</p>\r\n<p>Children\'s Privacy</p>\r\n<p>Our Service does not address anyone under the age of 13. We do not knowingly collect personally identifiable information from anyone under the age of 13. If You are a parent or guardian and You are aware that Your child has provided Us with Personal Data, please contact Us. If We become aware that We have collected Personal Data from anyone under the age of 13 without verification of parental consent, We take steps to remove that information from Our servers.</p>\r\n<p>If We need to rely on consent as a legal basis for processing Your information and Your country requires consent from a parent, We may require Your parent\'s consent before We collect and use that information.</p>\r\n<p>Links to Other Websites</p>\r\n<p>Our Service may contain links to other websites that are not operated by Us. If You click on a third party link, You will be directed to that third party\'s site. We strongly advise You to review the Privacy Policy of every site You visit.</p>\r\n<p>We have no control over and assume no responsibility for the content, privacy policies or practices of any third party sites or services.</p>\r\n<p>Changes to this Privacy Policy</p>\r\n<p>We may update Our Privacy Policy from time to time. We will notify You of any changes by posting the new Privacy Policy on this page.</p>\r\n<p>We will let You know via email and/or a prominent notice on Our Service, prior to the change becoming effective and update the \"Last updated\" date at the top of this Privacy Policy.</p>\r\n<p>You are advised to review this Privacy Policy periodically for any changes. Changes to this Privacy Policy are effective when they are posted on this page.</p>\r\n<p>Contact Us</p>\r\n<p>If you have any questions about this Privacy Policy, You can contact us:</p>',NULL,NULL,'2023-05-20 04:53:32','2023-05-20 12:01:50');
/*!40000 ALTER TABLE `page_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `page_headings`
--

DROP TABLE IF EXISTS `page_headings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `page_headings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned DEFAULT NULL,
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
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `page_headings_language_id_foreign` (`language_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `page_headings`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `page_headings` WRITE;
/*!40000 ALTER TABLE `page_headings` DISABLE KEYS */;
INSERT INTO `page_headings` VALUES
(4,8,'Blog','Blog Details','Contact','About Us','Our Events','Shop','Cart','Event  Details','FAQ','Forget Password','Forget Password','Organizer','Customer Login','Customer Signup','Organizer Login','Organizer Signup','Dashboard','My Bookings','Booking Details','My Orders','Order Details','My Wishlists','Support Tickets','Create a Support Ticket','Support Ticket Details','Edit Profile','Change Password','2021-10-14 02:42:42','2023-05-20 09:48:27');
/*!40000 ALTER TABLE `page_headings` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `status` tinyint(3) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES
(14,1,'2021-10-18 02:33:45','2021-10-18 02:33:45'),
(16,1,'2023-05-20 04:53:32','2023-05-20 04:53:32');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `partner_sections`
--

DROP TABLE IF EXISTS `partner_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `partner_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partner_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `partner_sections` WRITE;
/*!40000 ALTER TABLE `partner_sections` DISABLE KEYS */;
INSERT INTO `partner_sections` VALUES
(1,8,'Our Partner','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt','2022-06-07 21:53:57','2022-06-07 21:53:57'),
(2,9,'شريكنا','خدمتنا مجانية للمستخدمين لأن البائعين يدفعون لنا عندما يتلقون زيارات على شبكة','2022-06-07 21:54:13','2022-07-16 22:56:35'),
(3,17,'شريكنا','الأحرف. خمسة قرون من الزمن لم تقضي على هذا النص، بل انه حتى صار','2023-01-31 05:52:18','2023-01-31 05:52:18');
/*!40000 ALTER TABLE `partner_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `partners`
--

DROP TABLE IF EXISTS `partners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `partners` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `image` varchar(255) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `serial_number` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `partners`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `partners` WRITE;
/*!40000 ALTER TABLE `partners` DISABLE KEYS */;
INSERT INTO `partners` VALUES
(7,'645879b813135.png','example.com','1','2022-06-07 03:06:07','2023-05-08 04:25:28'),
(8,'645878ede2556.png','example.com','2','2022-06-07 03:06:16','2023-05-08 04:22:05'),
(9,'645879c4e8561.png','example.com','3','2023-05-08 04:25:40','2023-05-08 04:25:40'),
(10,'645879d17fb68.png','example.com','4','2023-05-08 04:25:53','2023-05-08 04:25:53');
/*!40000 ALTER TABLE `partners` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `password_resets`
--

DROP TABLE IF EXISTS `password_resets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  KEY `password_resets_email_index` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_resets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `password_resets` WRITE;
/*!40000 ALTER TABLE `password_resets` DISABLE KEYS */;
INSERT INTO `password_resets` VALUES
('fahadahmadshemul@gmail.com','5ffRsAn2iFAOtkFkJVuTicgt2OL3Hv2h',NULL),
('fahadahmadshemul@gmail.com','MofULe7iGv69cBBtn8WEprM0G73m3Vte',NULL),
('fahadahmadshemul@gmail.com','wLZLzqpItzNrGkg6A3HPu6naSi7h8hN9',NULL),
('fahadahmadshemul@gmail.com','2ckcECbtz9aDkUIP1NaRka0k6FYC6cOU',NULL),
('fahadahmadshemul@gmail.com','z4DS2ezbNaAPPDykmZlC22FlKIWzhSoE',NULL),
('fahadahmadshemul@gmail.com','jDM2Ak7oXiTxnD6bLOp3ABjrYGGIm0qK',NULL),
('fahadahmadshemul@gmail.com','hteh4kg4180Lm2EMM9su205LzosT9z7G',NULL),
('azimahmed11041@gmail.com','76oktXOsiLEjZHosFRiwT0FQa1XhOiwm',NULL),
('azimahmed11041@gmail.com','gCCJ0Eq89hSbYC5FfEAoWfeOYwOzPrk9',NULL),
('azimahmed11041@gmail.com','HVJq3vkfpWo0utGb1BvAmyCDs6L8kV39',NULL),
('azimahmed11041@gmail.com','ikDwaz58Gnvu9aXT2OI5WMz5bhjVpr0x',NULL),
('azimahmed11041@gmail.com','P4NHQSghVyYsdDxw6MOnAQDO60EMQniE',NULL),
('azimahmed11041@gmail.com','xROVrvqPpq3l9hIcr8uIS3u7Ba8AR5DM',NULL),
('azimahmed11041@gmail.com','OcqFf6pJXIXUyEeftH2lB9O32Ii28MvM',NULL),
('azimahmed11041@gmail.com','wgQyOzq4BEBV805C0xLjxgm9IGRQsOs0',NULL),
('azimahmed11041@gmail.com','W6ER6gTl3oDzHKQPrPoGPAGRC6O33apb',NULL),
('azimahmed11041@gmail.com','KFh3PtHmvxTz9hzm5K3XzocMSHj2wIMY',NULL),
('azimahmed11041@gmail.com','OMNZpQc7sTpvnCGfLPhdWD0SGGJLvUdh',NULL),
('azimahmed11041@gmail.com','Bs1q0lBbKUM0a0siD5xXRD0nAEot8wXb',NULL),
('azimahmed11041@gmail.com','F9WDH2kaPJLqJDKG7xmYzToMBBO5fTpw',NULL),
('azimahmed11041@gmail.com','gcmVlQNRKFKsFkEB3FndVw5ucIzlYH4B',NULL),
('azimahmed11041@gmail.com','VZuVu7c0iDf2d6SOaFNZWp7xD6WYF8Mn',NULL),
('azimahmed11041@gmail.com','AFY0WxtG7x1sOX1J90v8z2yGsApwM9dL',NULL),
('metewa8928@fintehs.com','bduwYIdsoDUfSdbR7hQikKdpa2L2IY2j',NULL),
('metewa8928@fintehs.com','cxgkh3X99D0W2R3R36hraiC9zM8vWhEt',NULL),
('metewa8928@fintehs.com','ddfvucZgc8EiMEATN1m5tMNNIBa5yysl',NULL),
('metewa8928@fintehs.com','PE0eIlt6fGZniHe9yMOGdbszOquHDdV6',NULL),
('metewa8928@fintehs.com','awqSYGZTM2ezfH15jrZ5oIKOMbWiMHte',NULL),
('metewa8928@fintehs.com','w8JXb3O48WkjmtMZtCI2eLwO42NX2aJs',NULL),
('woxad75234@fanlvr.com','$2y$10$oDfdo.zH4PpMZ03iAfQgI.kg7WkPB98jNoXJQVM/RSf9Fsof/0rd2','2025-10-14 00:36:13'),
('woxad75234@fanlvr.com','Z5ZsRNd7uggKB7rW4AiueejJnCWE4pJ8',NULL),
('woxad75234@fanlvr.com','RxmdmgI1vAylGNqc6NBrXZCdywjqfGkG',NULL),
('goutams1048@gmail.com','$2y$10$o6AH2eLB63aLyfj47Nw1pePCT6Dj/D4KCh0oCU2WMq0JnqsrSzQlW','2025-10-14 06:06:55'),
('juniorwkx@gmail.com','EL86AFAJHZbsvNKNeNrrXKTLUFkkI5Jp',NULL),
('daavilaramos@gmail.com','8sgtHI7EdlP3zHUlC3i9nzqoMy7YCIWr',NULL),
('daniel_d01@outlook.com','Dohr3e7BxJkVobsXTAimwurrRIViE736',NULL),
('jeeffydn@gmail.com','nDPIdXk8qeAKE042b8GA8imdKEbF1qzT',NULL),
('jeeffydn@gmail.com','It8BCEqlqI0yBADKp9FHE9RfBbJ5j01W',NULL),
('angelfitdash@gmail.com','CCvC7myttjwSTRJTlSkpKBX7Bydvceoz',NULL),
('angelfitdash@gmail.com','5yq6c5wQMyGBzVDuBe9ERrDPlsglopr5',NULL),
('daesolucioneselectro@gmail.com','vPa5nr2uwHXLpSXcARGUdmy1VdZsyhj4',NULL),
('daesolucioneselectro@gmail.com','ZeGjInvYLrm8uFq60rTtAMsjmo4NRcHg',NULL),
('aubreyfer02@gmail.com','Wuq46mATGp8ZmdfclDZScuuFUeUfR7rC',NULL),
('aubreyfer02@gmail.com','vuuoeHZ2EFqByzaBKv79WiXy0dbigJpM',NULL),
('yeffjesus08@gmail.com','46EZlPEm4ldwsevq6ZYAr7HfGFVHgALN',NULL),
('yeffjesus08@gmail.com','3ttLtOt9pMXOA9sdN8UscRl5ZGLErQfu',NULL),
('aubreyfer02@gmail.com','Ti5eHggwgje4TIOuaHUhSHrV5IQ3m5Gy',NULL),
('aubreyfer02@gmail.com','dPd4bRe84zSGyoNWE09Idc0KV6tsja4P',NULL),
('aubreyfer02@gmail.com','6O2yiaJbKG55TR11MTZGYXyYTa83kbr3',NULL),
('jose.pena@email.com','V6f5QrwGk5C0b0aa3mpUfAhEPcjosQaR',NULL),
('jose.pena@email.com','VstvKF28L3t04gtgpuUofxAI6zQuGMJ2',NULL),
('brendayis2211@gmail.com','ZppSix5YQcPJ33l8DRNJIbykOGDNEoDB',NULL);
/*!40000 ALTER TABLE `password_resets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `payment_invoices`
--

DROP TABLE IF EXISTS `payment_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_invoices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `order_id` bigint(20) unsigned NOT NULL,
  `client_id` bigint(20) unsigned NOT NULL,
  `InvoiceId` bigint(20) unsigned NOT NULL,
  `InvoiceStatus` varchar(255) NOT NULL,
  `InvoiceValue` varchar(255) NOT NULL,
  `Currency` varchar(255) NOT NULL,
  `InvoiceDisplayValue` varchar(255) NOT NULL,
  `TransactionId` bigint(20) unsigned NOT NULL,
  `TransactionStatus` varchar(255) NOT NULL,
  `PaymentGateway` varchar(255) NOT NULL,
  `PaymentId` bigint(20) unsigned NOT NULL,
  `CardNumber` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_invoices`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `payment_invoices` WRITE;
/*!40000 ALTER TABLE `payment_invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_invoices` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `payment_methods`
--

DROP TABLE IF EXISTS `payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `payment_methods` (
  `id` char(36) NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `stripe_payment_method_id` varchar(255) NOT NULL,
  `brand` varchar(255) DEFAULT NULL,
  `last4` varchar(4) DEFAULT NULL,
  `exp_month` int(11) DEFAULT NULL,
  `exp_year` int(11) DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  `status` enum('active','revoked') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_methods_stripe_payment_method_id_unique` (`stripe_payment_method_id`),
  KEY `payment_methods_user_id_index` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_methods`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `payment_methods` WRITE;
/*!40000 ALTER TABLE `payment_methods` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=106 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES
(32,'App\\Models\\Customer',35,'customer-login','df5b17f9c4040c895e12672f2a1e8c23511d04f5e25c20fc0b9842725e7ad332','[\"*\"]','2025-10-14 01:56:17',NULL,'2025-10-14 01:17:29','2025-10-14 01:56:17'),
(50,'App\\Models\\Customer',34,'customer-login','74cf8cd001ec7c1c309f8b350a784b22222a683eb9ed6740a39ba1964dac14f1','[\"*\"]','2025-10-19 06:11:07',NULL,'2025-10-19 03:27:13','2025-10-19 06:11:07'),
(55,'App\\Models\\Customer',33,'rr','45b64822b35b3de8c003653d47b849dcfa5f19777e8eecaba8e73075d5621d18','[\"*\"]','2025-10-27 04:25:27',NULL,'2025-10-27 04:24:50','2025-10-27 04:25:27'),
(56,'App\\Models\\Customer',33,'evento-android-mhg59kow-u0rldd','afbbdc3b16fd717c86dc46342df7ac65286fc2eab2de45bafcc4f387a34dfb99','[\"*\"]','2025-11-03 06:27:36',NULL,'2025-11-03 06:27:35','2025-11-03 06:27:36'),
(57,'App\\Models\\Customer',33,'evento-android-mhg59kow-u0rldd','6768045cadb62c5c9d59ff6e545c2b68a31ca780a30f1738621339e6af61d458','[\"*\"]','2025-11-03 06:27:51',NULL,'2025-11-03 06:27:42','2025-11-03 06:27:51'),
(58,'App\\Models\\Customer',33,'rr','4df4016712a6bc156c03a7db1485001cb70f67658fec44f501ddc74b89248877','[\"*\"]','2025-11-04 05:48:42',NULL,'2025-11-04 05:42:37','2025-11-04 05:48:42'),
(59,'App\\Models\\Customer',43,'unknown-device','b1efa1baa8214f9ada521c607d43d8b01d22b424530bbf1f03bb7a4a66207263','[\"*\"]',NULL,NULL,'2025-12-17 07:16:00','2025-12-17 07:16:00'),
(60,'App\\Models\\Customer',43,'unknown-device','62f6df55324a974b5bfe6340c2e9150d8f99876ea328f66988db1794a84102d0','[\"*\"]',NULL,NULL,'2025-12-17 07:48:54','2025-12-17 07:48:54'),
(61,'App\\Models\\Customer',43,'unknown-device','f7940d27325431fcce6fb2e06c35e5be19b8d55d46d3212c15e04af712baad99','[\"*\"]',NULL,NULL,'2025-12-17 07:49:04','2025-12-17 07:49:04'),
(62,'App\\Models\\Customer',43,'unknown-device','bd75ffc9de692f38ae1541c2d18d14da7081dbce1a25fdd32d54050bd5c0ea61','[\"*\"]',NULL,NULL,'2025-12-17 07:49:57','2025-12-17 07:49:57'),
(63,'App\\Models\\Customer',43,'unknown-device','f5ee11090be39b2cebcc7ba3456c349cec4c73c0e5714c402dd5b1a4b239f153','[\"*\"]',NULL,NULL,'2025-12-17 07:50:18','2025-12-17 07:50:18'),
(64,'App\\Models\\Customer',43,'unknown-device','74764ef2ba35293756f21eb9547f7d5e879bddcd4f282ebfb83abc341fb3582f','[\"*\"]',NULL,NULL,'2025-12-17 07:50:49','2025-12-17 07:50:49'),
(65,'App\\Models\\Customer',43,'unknown-device','ba58822b1e8279aeacff3f0e930a4e4b8769bf8367c58751b446815f436171db','[\"*\"]',NULL,NULL,'2025-12-17 07:50:58','2025-12-17 07:50:58'),
(66,'App\\Models\\Customer',43,'unknown-device','516efaea5511f04941d7395165bd246c889d7806c542aaed8302753225b4cd96','[\"*\"]',NULL,NULL,'2025-12-17 07:51:10','2025-12-17 07:51:10'),
(67,'App\\Models\\Customer',43,'unknown-device','e40477db6c863922694a4683885cf03a461783719d0a3aeb38d77ca41bc5b902','[\"*\"]',NULL,NULL,'2025-12-17 07:51:21','2025-12-17 07:51:21'),
(68,'App\\Models\\Customer',43,'unknown-device','06d45fb4720767895ba6788fb8eaa2761708a61ac1d4d21e3cafbc9d913dd2c5','[\"*\"]',NULL,NULL,'2025-12-17 07:53:07','2025-12-17 07:53:07'),
(69,'App\\Models\\Customer',43,'unknown-device','2fe93b31313188944f7db86167ae80c21db0d1faee20a9688f9acd811bbf9e44','[\"*\"]',NULL,NULL,'2025-12-17 07:54:28','2025-12-17 07:54:28'),
(70,'App\\Models\\Customer',43,'unknown-device','bf811e048b54d2c8c5d178f1421bf04915d07258b02257d5cab6a8a229321cdb','[\"*\"]',NULL,NULL,'2025-12-17 07:56:33','2025-12-17 07:56:33'),
(71,'App\\Models\\Customer',43,'unknown-device','73dc8f9546588ee58a99e0432a43442f8f8c41b957313c015ceff07fc404b487','[\"*\"]',NULL,NULL,'2025-12-17 07:56:54','2025-12-17 07:56:54'),
(72,'App\\Models\\Customer',43,'unknown-device','8ecaa65f2b4a404cc720bb943a37f2bf9647fdb4fb3af9da75c8f87c0ef4157d','[\"*\"]',NULL,NULL,'2025-12-17 07:57:08','2025-12-17 07:57:08'),
(73,'App\\Models\\Customer',43,'unknown-device','adf0f49d3ed923ff05b354df1c2bb9ffcaa66781d1996f2d4ea1e7ba2551c5f6','[\"*\"]',NULL,NULL,'2025-12-17 07:57:10','2025-12-17 07:57:10'),
(74,'App\\Models\\Customer',43,'unknown-device','b4e7462ebb6bd9f85931b60270350f5137a3c1e4dfa4da33cbab1990b56c53b4','[\"*\"]',NULL,NULL,'2025-12-17 07:57:11','2025-12-17 07:57:11'),
(75,'App\\Models\\Customer',43,'unknown-device','094430c9e55001cc46e9dc46cf28409a6d2d7d2d43112080ec19d8422d2eba17','[\"*\"]',NULL,NULL,'2025-12-17 07:57:16','2025-12-17 07:57:16'),
(76,'App\\Models\\Customer',43,'unknown-device','1ae478bcf97b1e1b82ffc6b094c8c4daa84e2ec8a83a6d0ef192c14424d95f01','[\"*\"]',NULL,NULL,'2025-12-17 07:57:20','2025-12-17 07:57:20'),
(77,'App\\Models\\Customer',43,'unknown-device','59d6a73fb39400da62e48ae0ad2a9291f9d0f575d60c78205117a24f95e2f15f','[\"*\"]',NULL,NULL,'2025-12-17 07:57:35','2025-12-17 07:57:35'),
(78,'App\\Models\\Customer',43,'unknown-device','e93d70f6d242f6aae4059d9bf6df4413b988d28ff4f5a8a1dfcab580b02b414b','[\"*\"]',NULL,NULL,'2025-12-17 08:05:04','2025-12-17 08:05:04'),
(79,'App\\Models\\Customer',43,'unknown-device','076ec4cc814ce41c63c3489b36151c8ec11a70e4b8597ac87aaf2fffcda9d98b','[\"*\"]',NULL,NULL,'2025-12-17 08:09:20','2025-12-17 08:09:20'),
(80,'App\\Models\\Customer',43,'unknown-device','9aded379a3b398eb0d1c241f5b7c45cf900b926ae0990b04b464e1a6d90af79c','[\"*\"]',NULL,NULL,'2025-12-17 08:09:27','2025-12-17 08:09:27'),
(81,'App\\Models\\Customer',43,'unknown-device','6fe09653ac92150c924dc06dcc5dd0bb7a8f7c077e7336dbc5729537a05afbaf','[\"*\"]',NULL,NULL,'2025-12-17 08:09:41','2025-12-17 08:09:41'),
(82,'App\\Models\\Customer',43,'unknown-device','37e0b9d31d8ac4a11c33739426f935a6b4ea07d48790e65b5fcf30dce4b10804','[\"*\"]',NULL,NULL,'2025-12-17 08:11:46','2025-12-17 08:11:46'),
(83,'App\\Models\\Customer',43,'unknown-device','9808f03485148e3f02d7a509e93b93a7a505b9ebb4892e510f25aea66485864b','[\"*\"]',NULL,NULL,'2025-12-17 08:12:22','2025-12-17 08:12:22'),
(84,'App\\Models\\Customer',43,'unknown-device','4ba11ab1c7ae79871a987c222004643a9c1dfbe0af5068d84c139bde1a0d11a7','[\"*\"]',NULL,NULL,'2025-12-17 08:12:53','2025-12-17 08:12:53'),
(85,'App\\Models\\Admin',3,'android_16jg6i14zo83hroy','ea612eeffd0712d153d1d56551d44a7578c4c94339682fd6256bb075499e179c','[\"*\"]',NULL,NULL,'2025-12-28 18:27:03','2025-12-28 18:27:03'),
(88,'App\\Models\\Organizer',31,'android_16jg6i14zo83hroy','bf6694531b4842a9efd3cce36f6ba61af6e646d0a674e569e5ee67686e9fbb60','[\"*\"]',NULL,NULL,'2025-12-28 19:11:48','2025-12-28 19:11:48'),
(89,'App\\Models\\Organizer',31,'android_8xvggddmc7x8lqca','1906374b62dafec8c1302c8eaf932237975ec7ac2414de1eb237e31c22d59e92','[\"*\"]',NULL,NULL,'2025-12-29 00:36:09','2025-12-29 00:36:09'),
(90,'App\\Models\\Customer',43,'unknown-device','8f6b07a946ef245d0e45b3083a4915e1c397599a0f892d6a40d3dcd8d955771f','[\"*\"]',NULL,NULL,'2026-02-14 05:11:49','2026-02-14 05:11:49'),
(91,'App\\Models\\Customer',43,'unknown-device','55170129e253a9eb048bccefb80e1d8003de5eab1d2b35b95e6dfc6852722c20','[\"*\"]',NULL,NULL,'2026-02-14 05:12:31','2026-02-14 05:12:31'),
(92,'App\\Models\\Customer',43,'unknown-device','ad9c369b970e1fe4ee2a5d769a8a3fd605f1350a70ef143c8ca194bf2184511d','[\"*\"]',NULL,NULL,'2026-02-14 05:27:02','2026-02-14 05:27:02'),
(93,'App\\Models\\Customer',43,'unknown-device','0b7e1c49952b8af9350145a0cf9a6fdf7ff285eb87d0d2ae4c428e791a6bb253','[\"*\"]',NULL,NULL,'2026-02-14 05:27:47','2026-02-14 05:27:47'),
(94,'App\\Models\\Customer',43,'unknown-device','3aacf706f54d5fb2ca46d520514d7f4246d4330fbc6b8ca7bb27c48d2c7371a5','[\"*\"]',NULL,NULL,'2026-02-14 05:46:54','2026-02-14 05:46:54'),
(95,'App\\Models\\Customer',43,'unknown-device','57a35594d8460ceb0986e9a17e87b5fe105f538116f41b4cfaa7bae7c3f30b58','[\"*\"]',NULL,NULL,'2026-02-18 02:01:49','2026-02-18 02:01:49'),
(96,'App\\Models\\Customer',43,'unknown-device','de9985ee098a6c70c5c6a577366e56a450338d5b2ff388f95808f7d055fbc7bb','[\"*\"]',NULL,NULL,'2026-02-18 18:18:10','2026-02-18 18:18:10'),
(97,'App\\Models\\Customer',43,'unknown-device','4952c86a98921f9954781324b50c6336614ecb0a6c5652be856668509abbebb4','[\"*\"]',NULL,NULL,'2026-02-18 18:32:09','2026-02-18 18:32:09'),
(98,'App\\Models\\Customer',43,'unknown-device','0d1c90f51168f006953a53fa3acfcea87b25587482ab72b680d8df6cf1b0f0f0','[\"*\"]',NULL,NULL,'2026-02-18 18:32:18','2026-02-18 18:32:18'),
(99,'App\\Models\\Customer',43,'unknown-device','c6608be4bf123001769bf4040a4b2ca7866db70c6629dd3ac2284bf2f377a2b0','[\"*\"]',NULL,NULL,'2026-02-18 18:32:56','2026-02-18 18:32:56'),
(100,'App\\Models\\Customer',43,'unknown-device','baf7ff9b952762ac91df7213023b0d2da9ce0a8d32dbca4bb30618a778cb17aa','[\"*\"]',NULL,NULL,'2026-02-18 18:56:08','2026-02-18 18:56:08'),
(101,'App\\Models\\Customer',43,'unknown-device','1e6b55b4c2372601e00c67050cfc91a7b9669fcf0c2152df799a6336854ebed0','[\"*\"]',NULL,NULL,'2026-02-18 19:21:33','2026-02-18 19:21:33'),
(102,'App\\Models\\Customer',43,'unknown-device','8bea56d81469c73e8a6c9e75c485c142460a7034dff0742dcf409a19568a35c7','[\"*\"]',NULL,NULL,'2026-02-18 19:51:19','2026-02-18 19:51:19'),
(103,'App\\Models\\Customer',43,'unknown-device','42c88775c63f15f32780f8f9dc0850e615f3b08059d880324888d20c5b9732e1','[\"*\"]',NULL,NULL,'2026-02-18 20:01:24','2026-02-18 20:01:24'),
(104,'App\\Models\\Customer',43,'unknown-device','1d97cd6a12fe3e1b2944b22e9a4383a2bc9d33377a7adf2b0ca8fd33e653bd4f','[\"*\"]',NULL,NULL,'2026-02-18 20:10:37','2026-02-18 20:10:37'),
(105,'App\\Models\\Customer',43,'unknown-device','2c8f7365ddea6a270a13989df4ad8771053f850d8aa00715b35957f4cba188d3','[\"*\"]',NULL,NULL,'2026-02-19 02:03:56','2026-02-19 02:03:56');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `popups`
--

DROP TABLE IF EXISTS `popups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `popups` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `type` smallint(5) unsigned NOT NULL,
  `image` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `background_color_opacity` decimal(3,2) unsigned DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `button_text` varchar(255) DEFAULT NULL,
  `button_color` varchar(255) DEFAULT NULL,
  `button_url` varchar(255) DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `delay` int(10) unsigned NOT NULL COMMENT 'value will be in milliseconds',
  `serial_number` mediumint(8) unsigned NOT NULL,
  `status` tinyint(3) unsigned NOT NULL DEFAULT 1 COMMENT '0 => deactive, 1 => active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `popups_language_id_foreign` (`language_id`),
  CONSTRAINT `popups_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `popups`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `popups` WRITE;
/*!40000 ALTER TABLE `popups` DISABLE KEYS */;
INSERT INTO `popups` VALUES
(7,8,1,'64577a7c2cee5.png','Black Friday',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1500,1,0,'2021-08-10 05:05:12','2023-05-07 10:17:45'),
(8,8,2,'64577ac23d6b5.png','Month End Sale','2079FF',0.80,'ENJOY 10% OFF','Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.','Book Now','2079FF','https://codecanyon8.kreativdev.com/evento',NULL,NULL,2000,2,0,'2021-08-10 05:07:11','2025-02-27 03:19:17'),
(10,8,3,'64577b1c72c92.png','Summer Sale','2079FF',0.70,'Newsletter','Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.','Subscribe','2079FF',NULL,NULL,NULL,2000,3,0,'2021-08-11 05:42:11','2023-05-09 11:07:35'),
(11,8,4,'64577cffd4533.png','Winter Offer',NULL,NULL,'Get 10% off your first order','Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt','Book Now','2079FF','https://codecanyon8.kreativdev.com/evento',NULL,NULL,1500,4,0,'2021-08-11 06:38:08','2023-05-07 10:41:01'),
(14,8,7,'64577d4bcea74.png','Flash Sale','2079FF',NULL,'Hurry, Sale Ends This Friday','This is your last chance to save 30%','Yes, I Want to Save 30%','2079FF','https://codecanyon8.kreativdev.com/evento','2026-05-07','12:00:00',1500,5,0,'2021-08-11 07:15:16','2023-05-07 10:40:53'),
(20,8,5,'64577d6d84030.png','Email Popup',NULL,NULL,'Get 10% off your first order','Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt','Subscribe','2079FF',NULL,NULL,NULL,1500,2,0,'2022-05-17 08:08:14','2023-05-07 10:29:24'),
(21,8,6,'64577d905ecf9.png','Countdown Popup',NULL,NULL,'Hurry, Sale Ends This Friday','This is your last chance to save 30%','Yes,I Want to Save 30%','2079FF','https://codecanyon8.kreativdev.com/evento','2025-05-16','12:00:00',1000,1,0,'2022-05-17 08:10:41','2025-12-06 05:54:02');
/*!40000 ALTER TABLE `popups` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pos_terminals`
--

DROP TABLE IF EXISTS `pos_terminals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_terminals` (
  `id` char(36) NOT NULL,
  `organizer_id` bigint(20) unsigned NOT NULL,
  `terminal_uuid` varchar(255) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `status` enum('active','revoked') NOT NULL DEFAULT 'active',
  `last_active_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pos_terminals_terminal_uuid_unique` (`terminal_uuid`),
  KEY `pos_terminals_organizer_id_index` (`organizer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pos_terminals`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pos_terminals` WRITE;
/*!40000 ALTER TABLE `pos_terminals` DISABLE KEYS */;
/*!40000 ALTER TABLE `pos_terminals` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `pos_transactions`
--

DROP TABLE IF EXISTS `pos_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `pos_transactions` (
  `id` char(36) NOT NULL,
  `pos_terminal_id` char(36) NOT NULL,
  `wallet_transaction_id` char(36) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'DOP',
  `status` enum('success','failed','refunded') NOT NULL DEFAULT 'success',
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`metadata`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `pos_transactions_wallet_transaction_id_unique` (`wallet_transaction_id`),
  KEY `pos_transactions_pos_terminal_id_index` (`pos_terminal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pos_transactions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `pos_transactions` WRITE;
/*!40000 ALTER TABLE `pos_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `pos_transactions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `product_categories`
--

DROP TABLE IF EXISTS `product_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '1-yes, 0-no',
  `is_feature` int(11) NOT NULL DEFAULT 0 COMMENT '1-yes, 0-no',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_categories`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `product_categories` WRITE;
/*!40000 ALTER TABLE `product_categories` DISABLE KEYS */;
INSERT INTO `product_categories` VALUES
(2,'Electronic  Accessories','Electronic-Accessories',8,1,1,'2023-05-07 08:55:58','2023-05-07 09:01:02'),
(3,'Fashion & Beauty','Fashion-&-Beauty',8,1,1,'2023-05-07 08:58:15','2023-05-07 08:59:34'),
(4,'Home Appliances','home-appliances',8,1,1,'2023-05-07 08:58:42','2023-05-07 08:58:52'),
(5,'Books','Books',8,1,1,'2023-05-07 08:59:58','2023-05-07 09:02:49'),
(6,'الملحقات الإلكترونية','الملحقات-الإلكترونية',22,1,1,'2023-05-07 09:01:30','2023-05-07 09:03:28'),
(7,'الموضة والجمال','الموضة-والجمال',22,1,1,'2023-05-07 09:02:00','2023-05-07 09:03:27'),
(8,'المنزليه','المنزليه',22,1,1,'2023-05-07 09:02:20','2023-05-07 09:03:25'),
(9,'الكتب','الكتب',22,1,1,'2023-05-07 09:02:55','2023-05-07 09:03:23');
/*!40000 ALTER TABLE `product_categories` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `product_contents`
--

DROP TABLE IF EXISTS `product_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `slug` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `tags` text DEFAULT NULL,
  `summary` text DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `meta_keywords` text DEFAULT NULL,
  `meta_description` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `product_contents` WRITE;
/*!40000 ALTER TABLE `product_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `product_images`
--

DROP TABLE IF EXISTS `product_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_images`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `product_images` WRITE;
/*!40000 ALTER TABLE `product_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_images` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `product_orders`
--

DROP TABLE IF EXISTS `product_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_orders` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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
  `tax_percentage` double(8,2) DEFAULT 0.00,
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
  `conversation_id` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_orders`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `product_orders` WRITE;
/*!40000 ALTER TABLE `product_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_orders` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `product_reviews`
--

DROP TABLE IF EXISTS `product_reviews`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `product_reviews` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `review` float DEFAULT NULL,
  `comment` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_reviews`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `product_reviews` WRITE;
/*!40000 ALTER TABLE `product_reviews` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_reviews` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `products` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
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
  `download_link` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `push_subscriptions`
--

DROP TABLE IF EXISTS `push_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `push_subscriptions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `subscribable_type` varchar(255) NOT NULL,
  `subscribable_id` bigint(20) unsigned NOT NULL,
  `endpoint` varchar(500) NOT NULL,
  `public_key` varchar(255) DEFAULT NULL,
  `auth_token` varchar(255) DEFAULT NULL,
  `content_encoding` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `push_subscriptions_endpoint_unique` (`endpoint`),
  KEY `push_subscriptions_subscribable_type_subscribable_id_index` (`subscribable_type`,`subscribable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=90 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_subscriptions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `push_subscriptions` WRITE;
/*!40000 ALTER TABLE `push_subscriptions` DISABLE KEYS */;
INSERT INTO `push_subscriptions` VALUES
(7,'App\\Models\\Guest',8,'https://fcm.googleapis.com/fcm/send/dPnvaQfjZmY:APA91bFKyN3JcgGME6ZrIMuxy1b6H1L2TCG9N2lfBI6lcogRmeziZtfB2fOCOW7NJG6HcPk2lMu0xnnye1wqYtoBl5bvekqIY9KNH-RToHeTXQ6gIaZ9S3lkTuWrDMQYRcWUfUiOmhaI','BFqvV_X7wkJCjnZzEQwdn2AKIdxMJ5ARuG14a2oYNCsWw86ByIRXEJMC7LgMQvpqA6E6s5_8E12Hp0MH4AmEeJI','aRpGEzfh-gvLgh4OiA0vvQ',NULL,'2025-10-29 07:44:42','2025-10-29 07:44:42'),
(8,'App\\Models\\Guest',9,'https://fcm.googleapis.com/fcm/send/eUF90OisF2U:APA91bHloRcT7GAh0i6GWngRhJIh-OHUXCIqLowa-HAdvxu2XpZTgdfzCPHzYM7pJK5wwTufedyGm2ocjLkNfSPtk3toEa5nrsMcbmZUVaXdAzXNnzU4mNq4zVlpYtt1B0E9f_Y3RFDB','BNivTmt7ovwVLlGnXvkd4gXsn29D1BfETYlz_VS19A8IpuqxQYZV0XEfU8voThR4bmkymsBk3VDwAF6OmfJ0Fcw','b8VNRVcT4hw9NqskTstB6A',NULL,'2025-11-02 05:06:11','2025-11-02 05:06:11'),
(9,'App\\Models\\Guest',10,'https://fcm.googleapis.com/fcm/send/faKkK9nx67A:APA91bERXmwrqZivBOcIjz1OlixofdUiikI0Qh9dkzOW2S51FI0Y76Akf70KX0P64sgvefAKL_ggFVlBhN29J89dwjvFc53jP1mqN45MG7LEIej4suEL-t48_Z09e6rpLX-Jlttneygu','BOpBGn-ypFZO_sYCJuv7v2qhfHT6KkEm22YEZFV-c0vwsLTr8r_P-1LvGxn7IPx6Mw_YhwB4uo0i68dw2Mf9pOo','-dQKK-GmQs0noP08096GNQ',NULL,'2025-11-03 03:27:11','2025-11-05 00:50:40'),
(10,'App\\Models\\Guest',11,'https://fcm.googleapis.com/fcm/send/fDXXEc0DzIY:APA91bGWBfzFjM7p1YD9SuhF8DvJsVdwRYGhFer21viIJhCmfVFNsYlHSlV61Xi8D0GWKA84naNFTE3nkg7D8CIzhFQAad_RoRu8wuLWhoJYYzYDa7g45VAF-jZJeUMxtJV49c97bt6K','BC-TUfzh04kDvupVDbJg4enNWR4TkJuULZFcZQ6BYNdZvcs8aGACUVWrflEX3ay_JlaesCTNeQo9BNdcF8BZyyo','3c20gFMyJUAmXFnKPji5gg',NULL,'2025-11-06 03:53:06','2025-11-06 03:53:06'),
(11,'App\\Models\\Guest',12,'https://fcm.googleapis.com/fcm/send/d_wJzTj2InY:APA91bGkg9h1l2rvZKqtKwszwCSRsUg5byk2vJT_wnkHOfJ5W5oEu5kc6w5QhmgfgJBptACpYlU9mOpwzsuWJkd3ypGb5qIi15h55DTn6Em3vR_eW8FnnQjh6CHb1I_PYzd6uJisx89l','BBAAoWfBYUIZVCfioVYASjtK-aEJg-T9owcM7drqMCLDIYb_dqLw9JR2SN7QPnzITQB06uoCz2M95y3i64lfgOA','6TTsTi0GN8jOvX0Zf2uXIA',NULL,'2025-11-08 01:28:56','2025-11-08 01:28:56'),
(12,'App\\Models\\Guest',13,'https://fcm.googleapis.com/fcm/send/eEVDuoYjbyw:APA91bE69Dvppa8x8H7MLm_sAXW-CeA3lv2hwKRU9KWQew2OoTnTvtgB2SSe_bp-7b6YdJ_L0tyVDAPVR-cvpiiN9ivyU5sfZZaYb2B1sU7J7YeY6zV6uOPU66lzi43OVfrR3pPdRi3Y','BFbOLrnj2KHLb9g_RyZkM_vwxg24QESoR4hHP5_bBWq80gY3RBys16tpRDcOtqDC8tB2b0EpOBXqzXiI7YBnNNE','F_aqdRZPKgz5s4Uj6j-XvA',NULL,'2025-11-08 04:37:29','2025-11-08 04:37:29'),
(13,'App\\Models\\Guest',14,'https://fcm.googleapis.com/fcm/send/fyqQImbJth8:APA91bHmbK6jxzev-d7dEc12xuTHkgZZIEP96fndr0tomw8PfZDzPBrTJnx6qY0XAjbjv9zZbXoAlf3EK7x8OGv_QCyfJWFzWgAYO9XcqMRJ-KCvU7bbtTY6XAVRHbujL7qJSeJo1yC1','BCDMHhfvYJBO5Dsh4a0OauV27GQXHrNqvNHxB2ol3eoKXGSGDM-Zz6liOiTo8wXbNBqmDpFcLcNdLqksnyhAZrM','RhPKWPyRQkeYGTF6HUM7PQ',NULL,'2025-11-08 07:28:28','2025-11-08 07:28:28'),
(14,'App\\Models\\Guest',15,'https://fcm.googleapis.com/fcm/send/cEjVVc6iP54:APA91bFzWtZ5M77jyBwiYKbQQus6RIYUyZjuQ68wIekQOdRpAIhpV6LAVWsc1rkpokRdya2tU-2NFjzxek3yQTKi1StM-ae2bVfOOJL-4ezoDDcM_pai5ZuvgV8EXndSKjxjeYJQT1tU','BDip2r0utkG8PZIQVlt7tD_k9RUrcwOUhxNFv9zRcOkvL6IZKyHUl4HIzjv-fnDpsQ-5rtnoWFcMa6ld-a5uW7o','mcsQIEZQQTfe-_9CQw8flg',NULL,'2025-11-08 07:54:17','2025-11-08 07:54:17'),
(15,'App\\Models\\Guest',16,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAiUTQvCUbu8U3EWwLPf0peJgy0D4GzQ0gZZrWHVWPZmEcSEs7R1kZwipD2hCWETCZGJTtGD1IIzb8IYYNGpqOgTcfXa3xOzP3A9VKMP092Zl4znSvLaEPp6d%2bWGKFI2jbZrwbzDxnY%2fce318Uit3UyAFCW5BIGfGJeVBa8oldx9A4RaepWUsnq7GuYNiszvO2u4SzLVnz3ysYs9YLPqYjdGSG92%2b7amowcsV3fEC%2bTpSdtWDf9VM%2bacl3rSK41%2fAP6E6NCYt5sKg%2bHefXZrNLgVL69S%2bIdxDmpl4lRy5%2fzLxwSnTdsGla7wnYNGlL%2bIhI%3d','BKjrHX8dytO02oSPTDv9qToOQjTopa4ZBlBHLcWexqGpO1TmU3MBXpIInaFuBmCIzFHy1uaGse-4I4ySKvzaYJw','8QfiJtL8jGba3qTJ9DVReA',NULL,'2025-12-15 14:50:23','2025-12-15 14:50:23'),
(16,'App\\Models\\Guest',17,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAOoAkAPjDOr6S6oJgJfPO6c3pj1JDZeL3Fv5cRN5%2fehGHw%2bYketKe%2fLgHoGytVa7eaMW8Y6xpFwZmUL%2bl5Qu4aKNnBM4Ae%2bC5iw74KFUx%2fICulyBrqpe4oWehdxOIKs5IT0sS0XPYyl5fbS8u0IfZR6BmQL55RBl5SOijpO%2fUjExUgVW%2bAa2GI5jiEBn2RYMGalV8dQIYTSH%2bpWdIdpx1DXYgNz2QuKBhD6Bud9BJXhD4jG5ZL0igz9OsC72SnBdeVRuUzansrZ8Sq%2bfqZPklIGc1qhtd4ePAJw5FA9f8FnfQTEjHI39fznD4JN1yRgNU%3d','BCwKaDxE4hmEQPPeXtHFiJhNdkc9c1DiUPBYAUt8HTjL5laG4fpKeQXq16Lqj7keYAmmYxVnhO1YLW48umuYAAQ','OnyB3pcq02yDQbFAR0DdQw',NULL,'2025-12-15 14:52:06','2025-12-15 14:52:06'),
(17,'App\\Models\\Guest',18,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAADpOw5xd2ml%2f9dIf4v2VzyFPfRCh%2bALBiWn%2fqNu5hX6R7eC78ErGne%2bQWSVDXnm2PUeGF6%2fIBk7IOw9YBDDvNryox%2fntl4%2froXPGLiwSXV7DEnaxrDSHLS7p3%2f%2bLAGsDhn84veRmlSb3vkhSqqmWZBkLYBr1RcPvmLfDwzexAbjwyj1kjRneGXp3Lbw%2fhHzlbSBw6joPLdG3hZ%2bOdrbWdYPNqmPQPeG7dtnBxSubf4LAvtGvUWUv%2f2%2b945f4AWAvkbG0JjAfQgcVu6XERunUxrfDpl4xtSGAmXK7WQ2Q5rZqpFGal86MOc4Y7QbpjmFlKE%3d','BPH2Xusdyfsc1-XMLK6eH-wBakfsO8uwPeOHZYhF89zJVuADH8DMDXuBXQbs9d7mSyx_Td059wjvbc3rD3REHZs','tLZq683ay0WgvEPSvHuQnQ',NULL,'2025-12-15 16:07:39','2025-12-15 16:07:39'),
(18,'App\\Models\\Guest',19,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAuYSzc2M5bnf6egZ8r7s5y%2fdORMDfNInSh3nfk85KH5M4iLpunduXYhMGuSt%2bJ0NpNVW9e1jtxL05ejMtppLLGiVkGEEhkQF%2b2mCPWg8Pt83qDcKWLXtsSvFRDWYdXugpXuV2kcxwmhcRRPEY23IoX6GR%2fLo%2b7qoGHI2nZriGSYa48LP8AOfu%2f7DH%2b9usB4ptPvdAik%2f9Lfvi%2fEmSc4JxC4Xvns2fm90PLSLudbT22v28H3iUUV9ngbjh6zHVeG3uVWZUlGM3uBAlRRTSHh0w0RROECpBY26GjTSrS3PlkLF0iMRnU53N30X8u7YeZSEE%3d','BDGaULiNovIsaMFPYutXWt4YMflGnciW1h7xbFlkHS-2MeMq_Lt7xtNqNG-5y-AEE5b4-mCiOIunBDwFffN5tM8','qu_fcnvC_OTKVW3XOVUHwA',NULL,'2025-12-15 16:33:01','2025-12-15 16:33:01'),
(19,'App\\Models\\Guest',20,'https://fcm.googleapis.com/fcm/send/f7KK0BvXNIU:APA91bGLv7UHYrT3PoL1I7IsJLWx-NPk78AidiaokO77UgrD9m7c8WjYmp04SHpmMJjX0QLQrhT75UzYZ0Yb3S7X0phQkoAJZ0O6cAJLiqTUn2uBD0Cw1kdEn6gnjwK9PMquVCcDCrdY','BDGrkgfOre9pOs8-k-s34zyHf6P6jWsDBug8QBBaxc1i_cdTRW4x8j17nhJ3tjQlFeQv4Fr4JRyiyg_lfbAyKMQ','UOHeBgXwxxFM28ahf7mMaA',NULL,'2025-12-15 17:55:33','2025-12-15 17:55:33'),
(20,'App\\Models\\Guest',21,'https://fcm.googleapis.com/fcm/send/fZ93na6oN80:APA91bE-dyEufA2v1-Plyd_ZOIxim_KST9Z5c7kwgqZjR7f1Ua-YEpctqezQyCg8c-zpuCTeiNZt9MxT378LDypwL1BOcGtkEdzMKIuGRcmQtsK2UDy-XPyZDOvIln_JmwNe118FKRRH','BOIzDC4tO9WRw3pKFscNel93rj3WqUACQ2uY0gxLmQBTA3_70Yz7zaHyKMjmgiPYRS5rLWzm1WeURz9IXBWnhdA','6ojFmgk80WpHd433OD4b5g',NULL,'2025-12-15 17:56:07','2025-12-15 17:56:07'),
(21,'App\\Models\\Guest',22,'https://fcm.googleapis.com/fcm/send/fWv6yCXKBn0:APA91bF71mYhYvlywW0afoeycaRg_7ZiZ42X4WsyycnmujzNscUm3PPTLfdqROQZ5YEIsg-EZtlf6xZ-VD9RY8CWAjmy6lQXRtVJZV5ZXNf9XfQPhizZmHXdWrKbbhn7uCtgmKTW0JF8','BDZAHN7oMcXuewUqvz7kj2-8RNEeJ3PgRQg1p2zriHjIDgYVz-zS0EiZoNfzqqBXn9msDdyWb4O61uVWXqIr4Uk','oXk51sBxsyDUyMAZzPjOYQ',NULL,'2025-12-15 17:56:36','2025-12-15 17:56:36'),
(22,'App\\Models\\Guest',23,'https://fcm.googleapis.com/fcm/send/e-WyZH4hyIQ:APA91bG8mHycrgSadIqU5AQ4Y7oYdVojfItWV3oHwP-qNjH0D3Ss6HdQYiwIStf7FhVPhcy5C4xa6ehUM7EKwkrbMHt4IIGPHOtZ4LHdNQ7plnSeeI4WtZvYWDDbdMGgO3ZvFCOeGe-b','BFBDcQugxR2sZFd5c5yerzjnGnQXXJZ45xQXDbTKDJNJ80-8Y9xCyjiTwdn_s8gjH-eOG40D3HU-_OOhJqEVfDA','2lhxjUm4dtASWcDSdtIVxQ',NULL,'2025-12-15 17:56:44','2025-12-15 17:56:44'),
(23,'App\\Models\\Guest',24,'https://fcm.googleapis.com/fcm/send/dQ2-cuK65DI:APA91bHv78tupqMgevWUuNrYgovRJR4AsSKYlAo-qZBp1ThOAynEKq5jRJhaDLWIU-w6tzyhD2OPunjY3k2RRLfGKTwzwQB44PZD1EgBRkJtbdnmFhDIRhmDti4SYmjkURhPQYOKVIO2','BOfnqNLpP56ZJeoU_U0SCg2sMjrWsioM1NfcH15QIbXAG9NyO1Rq7WaJZ-qUmWd_pfHk7sLH5BQDnJeMgW9DIag','ZtuvcWZD2Hep21ROjb1mFg',NULL,'2025-12-15 17:59:16','2025-12-15 17:59:16'),
(24,'App\\Models\\Guest',25,'https://fcm.googleapis.com/fcm/send/efZgJ93ZkhI:APA91bH_RNNEAE4sHsj_RBEp2BBYjPq-fmDEyOxSJvCxg3-K5DmrenZQkZB1OShSsKQSdUht_ipdZKIwqDgyyrYR03OzWG1aQOzAiHWn_9EjV-zVQxkIkzZbWowgIoslp5ACJqX8dwj_','BPMRxpgaCFbaJWr8OD9jp-jkAnNKHlMJj8RlSVGYa9LsbiPo1ZsPqbkRvEH2gG9Qesv9tukjkre2ltsMknkIliU','aixFAyNSHahjb_EeJxGdFQ',NULL,'2025-12-15 19:05:52','2025-12-15 19:05:52'),
(25,'App\\Models\\Guest',26,'https://fcm.googleapis.com/fcm/send/fjEmK3l61LU:APA91bFwPpNpbwehjSz5Yy3-oeDVdGHggXKXyNARFKl8XNlXs-AOTdpPDjoy9fmUw6QLo7fWLbqUi6L9yICF8NGwsqTQ1C06fqDhy2tHwMtpSvwLl-2Zfng064z0suVIeb3nbiIDTgTs','BDGYtQgZONJxrdARX-zF5VLd-nlLRVgQHe2vAi69t8KJbkHilQwnn2sbUAhIu1K4isH2HOv50CF0t6MW4n55vtY','YiMZZQqAEISAJCwAI8LXNQ',NULL,'2025-12-15 19:06:47','2025-12-15 19:06:47'),
(26,'App\\Models\\Guest',27,'https://fcm.googleapis.com/fcm/send/d7paDujYMMg:APA91bGQaTkKUjdsTrEXNRFY9aOu5pBHcwPL19Mo3tJi9s4vf4Il9jETLo1HHwylnhzjDiigW4_T9UKElznCqkkTJsLZErPZdLdQEezMwV3cJMTSYqedmecOHztVCUToqj4QRppmj8sr','BP8E-Nb1S6rDVD-lvwKymTjVA9gXUEhKBJoxzNpXjf66_F34w1rkR-BPb1ZStX5TrEwX2Yrr2kuWSvhnKLgmdNQ','kUMfCfq8Sv6_uu0TGf51FQ',NULL,'2025-12-16 18:51:40','2025-12-16 18:51:40'),
(27,'App\\Models\\Guest',28,'https://fcm.googleapis.com/fcm/send/fOJhs4Dc2h4:APA91bGNTtNwMn6gEZxqtibG7jXDs-MS-9OH6EgFLTXaDgyBMjzV4gDY5H4_jLwy4PrvOaPw5fAwBNv5C-l82onCmmadTvQYr23d88-9kCj4M1oCIBQVH1KfW_DBureLqmkK5BWMgp1z','BNUYE_aBHffTR6ce9s_QdoyhnHJb0T1kxsF0R5cPDgky9KBFbjCYGzzOKIOA9KJ6OBaVhq576rnlHfR9WffpiFw','jjaQUWDlSvJ2u0BZFbYZyg',NULL,'2025-12-16 19:19:11','2025-12-16 19:19:11'),
(28,'App\\Models\\Guest',29,'https://fcm.googleapis.com/fcm/send/eJhI0emfUKM:APA91bEjm1weYGP_SogfQy3R20aehYcscvdimhCQwoOCFMTRKkDAeW2kSPtaV2pWbBc8ymbL2Cx63SEkFZZq8vU-DFHZghYi7GAtpWj1zyilLPLJ-xkA7lzDAJVeTkR7LOBJveKajY0p','BKJukUAUTFUFSOWr-mKEEiyrFtwe5Da_FYuShBaWn-f4wpB2Lrvp7BZLTYpWPit8Tm3JdawF-EcdrDkiTPigVwQ','mAGYjPoRRsEIElccTjlzug',NULL,'2025-12-16 19:33:19','2025-12-16 19:33:19'),
(29,'App\\Models\\Guest',30,'https://fcm.googleapis.com/fcm/send/cdyn6ssgWfU:APA91bF3zWmeeklCK77GWNZYm-2Y59oZ4m3gYNa3wPorn-salj0ZNb_YNn-USFAwKbRZtP06UUSpImp7CvaDqbSeizGm6zQMkgCAyg3HMEWPQ7DsGnkR8WCDy3bOVrQ0iNA6BZNe57p-','BD9_U9-LNxz-4oD5x6Xa1WRt4hPAh2stu0ZkO8IfNcIzTu07FXjozmLaEEXeDOwe2UekLGg78EbjC6CBA0nt6m8','uIx9E4p-cwe47tRSy72Zeg',NULL,'2025-12-16 19:57:53','2025-12-16 19:57:53'),
(30,'App\\Models\\Guest',31,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAABNyLhWxoFGZEiUiCd9UhCbhskRJB4%2f%2fBcsDFLrVFSKdGrazXNf18Ww2zqE0dbTM8rXiNzWIb0CUDHoe4%2fAqtTxQsEfJexhzxYMDJWopnrrC%2b%2fh01ArcI3rOdTa8pLUsgh47mBdx82hrqtBwJWpZXljrKA%2b5J3TE6v4gkT1uypF1tZOXCn0kAcModWIkcLG%2btKks8NHW4UT78Vj26KSNcc%2bjNznG%2fZWZE1OkLWudXfQxCEe3tXnGO5nmVbO9GvInJZDmjLIRxOu2lBA5oJjxoLRol6P6UQP9YhKsHr%2fj37Kxa4yaPh522FoCdZ%2b6G%2bCCbI%3d','BP-nhkNAvGFprkJrp_lNomTp_js__PlR0BvYb7yr0seildYcYnRet9KGpmzMtk17up4DScN2q9x9wpH0f1QYFng','hIaSq8Pel28Eieg_KCt-_g',NULL,'2025-12-17 06:29:28','2025-12-17 06:29:28'),
(31,'App\\Models\\Guest',32,'https://fcm.googleapis.com/fcm/send/dXQjWNIDBfE:APA91bEYDy0pMeMZXm7EefRgpb1YPKRs0ioW5Hp1-VmpTx3S-4rbhI2pIDkxm1zF_cHNVPB1Yv1j2ZAXKt5l4EV0nkXQK8n6mIJOmuA412J-NVOuGU-sKk6xRsOm8E96zvwThIhlXNIS','BI9JcE3kMJjR6ruveysjmXOTI4h2ITwuE9p5kKbyDm8FBF1KJhgF7-mj_3wjC2juC7j95L1Ss2aakoUuSg2efCI','ISD_IZG6V2FypQxP81hRWw',NULL,'2025-12-20 00:45:53','2025-12-20 00:45:53'),
(32,'App\\Models\\Guest',33,'https://fcm.googleapis.com/fcm/send/dpU7V2AhSMw:APA91bHsoYewTK1PzdWILSeXbQE5oCE80PpwcjkToEgoMJndNjDSh8gpzcOp6zVOROIHFDTfUBK-Z25WiNR_C9KLM3CoUPMhBCyWsBeeDY7gBNJgk3bVtW6cGkT-PlBJWG-WeSEB5lTg','BL1nOOO0Cl--tpWbufmJoSvLvt7rQorG7SFacvMNVsVrk2UbYFmihljKKY_LWpvSuxGqVOmHEf78rhHo6k-xOVc','SrH_Ch-2TWJ41_NHxPO9SA',NULL,'2025-12-20 05:14:15','2025-12-20 05:14:15'),
(33,'App\\Models\\Guest',34,'https://fcm.googleapis.com/fcm/send/cgehezkBlCA:APA91bGBgnc9QnsM5pPI2x97iWMS52jQugTvdCWnAO64Soh6CLrqPk8n2CBPoo9EPL2ILSdOBemXPEH3lcWKP6Ez6N_Wqj7eVo0maUlLjowS-KWP7oSP-OrsukKPfj51MRdgXQpzqtDT','BP0eKnEHXq2K0m_Q410IJapWd2UgkWMBgwr1G-f8NbofMXWtHTsxDrxkwTlX2NYYZMh8E-Pu49N5_Q-93N844eM','wf5Mh1q0iiMY26MoJF8kuw',NULL,'2025-12-20 17:33:29','2025-12-20 17:33:29'),
(34,'App\\Models\\Guest',35,'https://fcm.googleapis.com/fcm/send/ehQqCf68qr8:APA91bGSxdWCcuYmw0yKVkP-StToZlRe9l5HqSf2sTOWuTb7DXdU7UGkLCZhr8xw31j3PuhBIq_DoJEonGBK8mFLSUvM7nrjK6fysM2AMsfEAoKGYFegrQO5D6OezQGtykGvlBNpgfqg','BNW9_ZedRukZlgWD_4qGGfcxN7v58DnC1f1dLO6bkYHAkILjgMP82cveUs3ZAip5lOaaWcqRR0gTpeF8j2aLuzU','3fainiwfo0gz9-MMRGo4_w',NULL,'2025-12-21 15:17:58','2025-12-21 15:17:58'),
(35,'App\\Models\\Guest',36,'https://fcm.googleapis.com/fcm/send/cBVP9wf89Bg:APA91bGexLzWzVunKYKY6EuFz2kD99vBJxDjog6V-ZWTZlbEFXqqlGNNvoErIzP76SYIbUeBszLRKQ5VQPaDGQMx8KOY1IQfRctcfH-8BVCAs8cuR6H6NVAVdXN9maIedKWKmJW3KQYG','BCxzP-GGtWj51C4gCmXVHCINRX4rIjjDu-dVhL59-O4SuAV7gvExksvvihw3r1VPu_3qzQ0De3pyH0zke7uX_Z0','JSYQcITZ2PftcvT9xQyvtw',NULL,'2025-12-23 04:34:43','2025-12-23 04:34:43'),
(36,'App\\Models\\Guest',37,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAClifkTPi9AF89O7FakoTawhi7UjUD3dOEa9thdGuhDFNRYlIiqB4XpfSVMd5aCzoejBh6uPOvfTRmLvtavNAK2q1qgH0oQn2xGIK0hehGq7wAiWUYfTSWH%2b1fL%2fM4bUSvB%2bBcEiC8pR4f6EV5jSfnPtcjCpQgJrd77s2p%2bLpfmuHHKUfdkhrS8eCNgG81rlG2H4iGg3UKWrdLokRrIMhTiiUsJnQXk3vN86XblQ5xEbhiyVjfXQ8Fns5MlGVoYm%2fZKnDCixT7XquqJXW5kswceiGRajIDO40PEF5L9qtMC0w0wuGmUpdS%2bvg2Mqbs0ilY%3d','BKzCcUfvfYEIcGwk_ib4c94mBu_wOzS50s0VnbVOZISuPsifa2ctEmulqGipAnwNFp3LZusvnKJDPoTGYCU1Rmw','WQZL70OHJ6ab1Css9I4t1w',NULL,'2025-12-26 09:01:18','2025-12-26 09:01:18'),
(37,'App\\Models\\Guest',38,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAACeSwFY55xpvqveH7VmeZ%2b5CCy63QQ%2fI9lyiCufOfmsO1PPidZAvJVCwlcJNSGL9%2ff5hj4eZ%2fFoUvc0Z9bNN4k4UUo%2bp8W8HaybfBfpvvbKKF5jml0tj4WnfDWdLG0LjkD4qSprT2j9197bcDr9%2f44NtyL18lBfPHjlFxg8P1huQ1RVnRjf6O0Oc9jMsmEeAIQkJce9iaa%2fl4Wslqa4IOUh3ZsQe5arqb%2bGLyoi6W3YRlxTttsGT014RNcQJME5xolkf%2fFCR2pZXvC4Vtyp0VO7LznlX3loAs9%2f8f5DGJtYW7ywwBtbDvkRRj9iOxykWL4%3d','BJzeuLu3-ogBHHBld0ouKLq8tgksKuHJyukUDZlea_ygeneoKYnql0Goaqc03hnddbFxAre_Z8sfSslEyG5ocog','1AXZhASuWelgZ4h9N0zujQ',NULL,'2025-12-26 09:15:58','2025-12-26 09:15:58'),
(38,'App\\Models\\Guest',39,'https://fcm.googleapis.com/fcm/send/eNbNWY6d5Co:APA91bHViy5RVB1EpS5H7v2kkRrTe6Fg9aG30HSVOOQFAmdMZmuwyi8eVWYqRRFJe240Q17KiS6CP-L7Ei6oWBOZSwVCsY0LIPEx0nhRv04QSbkosR3EKix9aWDNJGxkQJHfHbSawA6K','BMeDjMzfL0ezzd4qii8percnlNuXfZu5Qn4dW2yPMZS3GyoiUgS7aLBPO_NOuJR1MJm2t9ZlRe4LVSq0ssQUvDE','MB7ReR-su_cp9zr1dVLALw',NULL,'2025-12-26 19:07:25','2025-12-26 19:07:25'),
(39,'App\\Models\\Guest',40,'https://fcm.googleapis.com/fcm/send/dVI6XUMP35A:APA91bG0ADdnVbtrRKSMCvVto3oqsn2hSa_ObIx4s3MjV0Ca1aCb_GznwOxvZ54X0g46jiHk7Wa_ObHZubu6ayWtIPMmIevwggjrPQuKoPS01ZH8cMNTIs-A5SSYWVjvKcYkQYGa4aAg','BEEqWWL-HG6Z14Kx-jyoDok_v_r--n6vq9zg8sFNc-3Is3-EFRW9QW1nMAxD1dGTJj56Da_LQ7rpojlXatOaljs','Ts6QmFaMarR6C4RwN-1VAA',NULL,'2025-12-26 19:07:30','2025-12-26 19:07:30'),
(40,'App\\Models\\Guest',41,'https://fcm.googleapis.com/wp/e9xiJA2Z5So:APA91bGug_EIoNgW-2kh2Z7T7YfZ5EIdFYPSkPWcumrTB_HiXTP0FAS1fMfiiqxHV-6MG-iStoXl6hZpCx5qX0GfqqAWO9IoJOf0k6mp2EKPr3OrF2kyJQuRgpk5NFWvbHvn6niixS0z','BE_Gxab0RbnfarxvFkCfj-Tfi0vpSQO4u050YuU7K7dpk9FbNgUQ93LAcpltI7qa8gox_R-Iorwf_xW7yzowL1M','mgE8gYVS6y-fyVptbMjXkQ',NULL,'2025-12-26 19:11:52','2025-12-26 19:11:52'),
(41,'App\\Models\\Guest',42,'https://fcm.googleapis.com/wp/evbqo7AhQOc:APA91bG2lVdHsEyPUDZNuZt87VglSDgX5yPNl3HOGXHhvtp8qsZKJJhvJ_7TSEX7OhYP-kn1iAIbsdMx3BxBpNIhRmIsoJPhoL7XlPjg_1raeadZuEpyqq-MCPdttxZgw3PBFsnSrzKd','BMSZdmr8VXrGlU9rHq04l4nCk55zEoSPZM1th2ZrdvBu7XQpiVb-CfgJ4FwK4v6vFpfM55sBcligePJx-D5ZU98','0o9y4D-22J_v-tx1VibMjw',NULL,'2025-12-26 19:12:08','2025-12-26 19:12:08'),
(42,'App\\Models\\Guest',43,'https://fcm.googleapis.com/fcm/send/dcvDZCn-aPE:APA91bFteOisD-_u41-A4AEqXmWA7pY_zSiDYQvGoBmaVWmQ4uz8Bpe5V_7CQh_bvsax9kmU-1iCYeTI6aKXxTjJ3lcIHj7tmWcG0j19n2HLJhQviQmT74YxlPHWt_O1I-xRw1MfrtUx','BHiNHFfldAAjq2KSz17C_KXrcrf5evRFSBy0BzqXX9i5P_g11TgDp-IVacXhFtSSdyek1ErGa6NwUFNrYVYaig4','E7esfDFw-0KfnVlJhLa6yQ',NULL,'2025-12-26 20:50:50','2025-12-26 20:50:50'),
(43,'App\\Models\\Guest',44,'https://fcm.googleapis.com/fcm/send/dIGOdjitKrU:APA91bHfa1U-4IPaCgVyOcXk4slAlf7YJ2Zy-IhZ9W6o5wgOokSf7pLNbIVv9T_0x3WNSkhcZUy8_0zLcvlMPm4GWalgsXvs79HzOhGIU-ROBi-l15lN2YGB5pMNwxRLHsGYrljaKqBA','BN6bN-OuWR_phQk-GO6He2VKlnn0VJkRpwKyD5cxUp87K9xbc7dgyYwvBLz7gD1t-w6VfpCUd5GNlk8CaXoRX54','HkNfc09shAhIEfW6Fcw4Aw',NULL,'2025-12-26 20:51:06','2025-12-26 20:51:06'),
(44,'App\\Models\\Guest',45,'https://fcm.googleapis.com/fcm/send/drOZ2FxiX7g:APA91bE92voPZFuavwU0J4I-HNrizd4a2UMWBFNQJot8arjPG7C9nx9LkN7dhlVKM6kUzpft-AVb5OT9txz9pmQONgKTEYii13FZRr7EEfW3vTKu3OTk9iljhI1R6JItocdxDoSU3ns2','BPEvA3o7y0ohcn2JsDHCuWWX69P41rueYqBQKIYIPvAQZYg1JqxqrzrHl67zaGFWBCnwaj729sjnJUGderJqaYE','xl1_6Mvepf8slIW8IMg0Lg',NULL,'2025-12-26 20:51:32','2025-12-26 20:51:32'),
(45,'App\\Models\\Guest',46,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAAAIYPUNRQEVwFmB%2fGWS8Tj7OeHGKXGSnnIh9Qx13y3rGVMSylDQo5C4HmWUFN4TiFecpqLDOtsiEyWv0ZWa4QbeCjTYk1YXoV1BdoZ2Axcs7JUAUDviM3ThD5v%2bRHHPA1tDWwcgTsYahi7JiLZIgi6soH1sGAbLaps%2bRRW2tOZURX6sgyCya5H55NtfsBrfkX8cWx0x%2bb0%2fRfdlj%2f0JPSB5EcldE756SIfwHKzXD7dBI42bCmWGjwnK%2bqoT7TNrhbA1Q9CpheHS2RLZdBC%2bdM6Z3k38tZq%2bPSOEY9gMNc3r89WfQ%2bA9rVjAq%2fWGDR3xV4Q%3d','BLI_QqI3bl0zxLgPdzfjg6UD2CyAzssNEEXK61lD2ozjSQ7rG4Ius5SdzAsrpY8ITEJ3DySYMN-7-zV08O9GQ1I','sZ3Eu6cal3MGZtKAIcvABg',NULL,'2025-12-28 19:08:19','2025-12-28 19:08:19'),
(46,'App\\Models\\Guest',47,'https://fcm.googleapis.com/fcm/send/f65xyCd8fdk:APA91bHZmADa1fU0sRIT8uZxCE393zGq0WLQm3-LLglVNFq1_LS5Vj-AySLtwW0_bHyS47Q6CEe54SYmFmlNgwR8JQKNk5TYbORTQlpcl3zxK53N521hITQARS-4qkgXP22T3e1IrXwK','BA5nxoji6A1XWaW84BIRYdpWySx0uAYGFB_1KURWiBN2sxoxfz56HcGINV7EvbRnY2LH_Sqi0b3EGUe3Tr8y93o','cf8efFs1XwHXF5ojsmY52A',NULL,'2025-12-29 00:43:06','2025-12-29 00:43:06'),
(47,'App\\Models\\Guest',48,'https://fcm.googleapis.com/fcm/send/e6lAVpNSjyA:APA91bEsE1cpOH0Yi_VJs9-1qYRrlCjxq2pC33TWfAn8R_jx_BxiuZtPeJqOIY_6hGZ2DgF-RBDyNvjosaJX99c74mg45giJLVW_q-gVaHVtbxdS9_lTan__YC3yZw-Ex7gLXwYOQjgX','BKxOmNSwB2B56Jn6le35WHwbgtObX4-p1zqx5M9K3mrSQlMwUsIpG5R1Q4OCto_HSuhPXv1vQP67fpMp1wuxmyA','bFyRK-AHvgH4mmpY5woopg',NULL,'2025-12-29 22:07:28','2025-12-29 22:07:28'),
(48,'App\\Models\\Guest',49,'https://fcm.googleapis.com/fcm/send/cc4BFCW9N4I:APA91bGmUkoJ3Dozp3t9t_kttc6fEnZTeTMCcHyTQeSPBA3nTULh2QAainxh10fafMcVnrYxvJ_jSnIqBGIppulLyaJwEaWFJrI3GqwgLsSA6JTnldpCEmPCHwlSDp5A4fvK0EPqKlDW','BAStIDVC83fPUnUM_f-TDYWCaHHOGUXkQ20kdDGTHYknwbkisKXm0bWzXBz3WtcDHVeMzN7p2CrekFqwyrTUYMw','WUZLUeRep58WuSdBZOPnUw',NULL,'2025-12-31 05:39:22','2025-12-31 05:39:22'),
(49,'App\\Models\\Guest',50,'https://fcm.googleapis.com/fcm/send/e5U46nBTIWs:APA91bFUPeBlYjWOmZ-kRXf7mi480TP6TbVAk2mpI_RymqlW9RgvM_NI1aaFxxf_STRP6-CK3eM5aWj9QOfLKOINugJFLWashKLrbjZfhKrphKCvOnEvgxcwNz5i4Tttt6u5cGH0vIk1','BGBLfhUwxP5nZTJ_LZxyX8zoPEdoJUVxb5pm_P0Gulb-OGFdaexPZYrQpSw42Mnu8KnBsnVMStF9F2lVDuIvJMU','gVXbCue0wEZgyz0XrKW9lA',NULL,'2025-12-31 16:08:25','2025-12-31 16:08:25'),
(50,'App\\Models\\Guest',51,'https://fcm.googleapis.com/fcm/send/f35sTB-cy2c:APA91bHHUuAbY-LEBQPGd97uiKYA70FEO4XvP1IpQaerupPQIb0oGek1k1-G9zFJKSzjcaE3F0Va9IMmXTm-rSyMzXzUk20vdDY2hl6JcnrTY9i6gBhP6KrwFNb6vsUXPOutzFMegJ8v','BG0FOn_aAsYlH-_DHfz031_x2aVL_mPUFBDdctwEsAW57Jwf9W_jqaNPnvoG9KqkfqfJYKl4hsaCowW36h0iu1M','Rsl0-dQAVPrGviDmAZbklA',NULL,'2025-12-31 23:38:23','2025-12-31 23:38:23'),
(51,'App\\Models\\Guest',52,'https://fcm.googleapis.com/fcm/send/d1VnVTM83PI:APA91bEzqlpfWkXUUc426y4d26SzADSoMUUClLwh1ftMoxHpycKrxUoPj75AjpWSvrtA2LZaHdDImpI7IEZ2Ur4vevQu0R88Lwg7aYauqauyAL198On2_9Hr6KYlclOdUse_EmvleXO_','BExP_0dv1mBhOqXFaVFeBrWRERpWRo0tJq9lzHmBnEH-MBJX6K0Cdpqw_7OZszYKS3uVbxRqbdFyxKotCJ2eRO8','ZT9KsvAf2Hcjp0lHABqZOQ',NULL,'2026-01-01 00:18:01','2026-01-01 00:18:01'),
(52,'App\\Models\\Guest',53,'https://fcm.googleapis.com/fcm/send/dpWztfYAym0:APA91bFeRMPVU-lrnOQK4P-AVhSte9ZuO_yIosOFSjv1iXIIwfwYz0EBpTDfyyM5vKml6js8ZlQIPLmhIz4fwuay_2PsOjz72Kh9FcD4Bq3h3hhCARR5XqSgFaPskOLjGsBB9ukJljPB','BAxz2b_vSvN7tO5uETorlmguWU1_HGPnNUUydxZT_Pwyb9ZfN258_dmnbO1XEoT319b2SnJxnlRYxjd_VG7W-ZE','sGXnl9hTL074qXH9ADx5mQ',NULL,'2026-01-01 07:25:39','2026-01-01 07:25:39'),
(53,'App\\Models\\Guest',54,'https://fcm.googleapis.com/fcm/send/fQJX7ZxTSsE:APA91bGmloKuSq_tkm8etEfVdEbdkxozQrL5Zhbht_Jz1J6P69A78WcFzo0KQjxRecgcg68fOSlsuVI05xEI4hai-ujLlNXZyDSEySSWfCsbkVvQWWas6xEdrEHbCepPDM8-ZocFg07O','BJ9bPLoEIAxmP2y-GNDPm2-HcmPMMHF0AFyNNvmdp8y8sGxUqI9_S9pc37NBshEtCE9n4QFikW5fexxHHgaP4dM','1Gs0iyvtbYxJZv3SLK7K_w',NULL,'2026-01-03 02:52:34','2026-01-03 02:52:34'),
(54,'App\\Models\\Guest',55,'https://fcm.googleapis.com/fcm/send/eoNR8hSMtkU:APA91bEQKtOMnEhA_uzij2Lfv2TP-9PvXXcSkj_nwjIFhm5X3qJ7FR_wgBXBX4oNHiVbO3vqbW6VhgK-tIH6P0RXYNgTb8nYEnkrPQl0zSaPsOG0U7Mac5h2SePqu6MyotCeY_P-hTZi','BNNe_tjKqJpHXDfvPJblAkZMRb2BlW_QkP3uvmmsE0yxqKd4CCoqij3sHBf05vDUUouKlb88VxgwGibOqBSO7WE','BZnby6lKlynHu7odyj3C4Q',NULL,'2026-01-03 02:52:39','2026-01-03 02:52:39'),
(55,'App\\Models\\Guest',56,'https://fcm.googleapis.com/fcm/send/d-NXlQ4WF54:APA91bExfbCRDTTDOhWsmhPNJghcNRPOM0JnwApzmXC2dxSJp-61blMv0LgL0vbLiOf-vG7upKgS5HGQydhaG6YibXhJ8KdMyi6ojQsNNUof9SuNJABuXLkW3j-SguxtWDtCTkmtNi02','BF7gN8tlyLgLPY18sKU-uA_YKlra5OW_0c7U5p3WbnBQ-_bk4y_FKl87tcZwX7Xr3j10iPdmp1JNN_HCP5RBykw','VOAFhwF-_PiyHLwxqoTgRQ',NULL,'2026-01-03 02:53:16','2026-01-03 02:53:16'),
(56,'App\\Models\\Guest',57,'https://fcm.googleapis.com/fcm/send/cRKS621iUyM:APA91bEGoAoHCEn4hGDai1jdzbuWTIkQrw43GzwWKudbNhOVT7SIfWWg5rGNdzZoMuBwbKDM1GVFUku-pB_YPCYz84E1Pexazeg6cPwmq_vuJrw0f_eteMoO9ysq4KlKHqluaV-As8_V','BLvkefVJ73ug08u54C-n5UpDcvCKmJYDXBlDWszZcWTOvcco_VOV_wCChLGSWo7JXaIsFLcDXdteFi61rarIwNU','ir0Cynue8IwaRtvREYQnUA',NULL,'2026-01-03 02:54:01','2026-01-03 02:54:01'),
(57,'App\\Models\\Guest',58,'https://fcm.googleapis.com/fcm/send/fI3ltJ7udVM:APA91bHrhYqlcUPfoAFDnSUXJSZOiDPAtcRSR3-cFozo-XdF-WrUkn6e27R9nbRmvFYQ6kJ7BIx5Set_Q1bwz1e1LpKkhq-6VD0tUykMxweXBnE5D5qX06mpShBz-QlwdF6y9SQYCc5o','BGS61p4XhhKxoeMjSxxoAUclPMnb_cM1uusLFt3N5wwurB7xtmdTTojJcQom0yIUsbCWEEqVnLWgr9Lcd82-PRA','SxNQqg4fdmE1s3OZrsQWfA',NULL,'2026-01-03 03:01:33','2026-01-03 03:01:33'),
(58,'App\\Models\\Guest',59,'https://fcm.googleapis.com/fcm/send/eguxovJA4Ew:APA91bFQom5Mf7Z80L-Ifj0agCnAHVsmNXC1XXbNO3dPIKmNM1uB6oCaaGOtw9o6zdZnpeVUsfIRQODUC0nqGXTQ3HthEzJtFsM3NKtpLLNlhFPst7vhKwIbT6GStCjitG8WEfpkgbox','BDcBkzIJGy_oApETdbLpQVM8cwmizMwLhoRShyU4wtgGm6fqPE2L58tmlUn9G6SQKnMNpeYIftPOeKzuIX-PMLI','4tC72x6sMLCFCtoTgYfPrQ',NULL,'2026-01-03 03:16:41','2026-01-03 03:16:41'),
(59,'App\\Models\\Guest',60,'https://fcm.googleapis.com/fcm/send/ezeHQlpFr-s:APA91bGAfMesCxe_UxU9y8g9w9i19r8Gc0X0Dw_mTQvWwoEJvGKb0dkHse5yzS-ByX4JIx4RJ4pJtaAZbWBPVd8UEPxqx45XFW4RAxLWJRvwn5lrt7Sh5PfPOOX4-jKJiXxEhhbmIPA8','BBUjb6aC_QK-hiBOpMhb7tYMIbgj96ckx0E5C01URnwH44oyfaAvbRUi0WGTViwMDC7ntwrf-qoWC-sAdsCwU14','RUZu9DkVHX8yrQI-P7_91g',NULL,'2026-01-03 04:31:40','2026-01-03 04:31:40'),
(60,'App\\Models\\Guest',61,'https://fcm.googleapis.com/fcm/send/diGHLSjHu1A:APA91bEDNMYqFamo2802wOdsnWXw0eIgPJa-bljXDdq1tYHgSG2V8I45My0OlEkAFVrQhgC5DxNTmSxSphWEi1x0IxWLzVPU9pSK75KO-NE1xo5iZ0Ejj9q2ueyEGCjUAm9nrUqPmdEv','BKs2JjezcrnLGLd4nI8iBoWDLlp7mWm0UK-ZoD7V-OABVam0i9EEYyjfCNOQdGM5Ey6Dhpuqd4Ltignpy4f9y1Y','vZPfs9HqKs5yja9Tp8vXag',NULL,'2026-01-03 04:31:57','2026-01-03 04:31:57'),
(61,'App\\Models\\Guest',62,'https://fcm.googleapis.com/fcm/send/e8EorkxKWQI:APA91bG4U0TTFpbM2H64EB8f9aVJepA603u-phgbvCQi6QdUxcw3a8v5giRs6GgabR6xQtQpoPDihPY7KktTKNNIvxH2O3lmDSUtsrprElVJ1_jslkdb62YwtNsKoGsJx5iowOTlclHl','BJNAHyqQylcGt5JMZDT7q0nV4nJiQK6WF4GOscP_1m7mk_USCKxGI_40eJDA8K0tNkXE8YYOnhqk4B25EHcyky8','O-vGfD-mAjHmn-SROU_dIQ',NULL,'2026-01-03 04:32:12','2026-01-03 04:32:12'),
(62,'App\\Models\\Guest',63,'https://fcm.googleapis.com/fcm/send/eC4gNo5WmSc:APA91bGYq5S9Tp-cp6Oze88j-d1MHj1__aVHepA0JNsipxc9vnaY_YmwgvHeHIuUpl6hcyPMMzpvF2O1K47lHqsDdktyK5LW4LmN2AYyYws1T2wjE9SYJ54-kmxup4BxbHlC_nL7E5Bv','BKZZxV_x53_lGM2SY7vunpVozdB7NMTXjRglfXCuMfRKK0LMtt1MFRNbD-SXb-2bDbq4L5niXBofJ-PiEEOu34w','ogRpCuAc9j6rX-QrtSH22g',NULL,'2026-01-03 16:29:56','2026-01-03 16:29:56'),
(63,'App\\Models\\Guest',64,'https://fcm.googleapis.com/wp/esrii3Qyq94:APA91bGBbga1sg3skx7Wq2TjKRtNNTcvsdsC3UO3qccqpb_FVsOOZwl3pD9GLgkMmHTtnE7bl2kYzqpUcGev-8-KhnISd-S9tpIRCYlm3yDeml_aQG-7NwvYotsiL7lq8x7MvufemZQD','BFSNhCG1gqhGeJ1DeQzVykjv16ku2BfcebetzFxWSRrgpw1TrsL0_61dZHwNFnteZweziil6Pz2c7Yc6XTDzHTo','YAEfLPk6d3FMonB2Z4qtjA',NULL,'2026-01-03 16:51:31','2026-01-03 16:51:31'),
(64,'App\\Models\\Guest',65,'https://fcm.googleapis.com/fcm/send/cE5E38IFWcY:APA91bHQJIXzGOKxYLNhinley6V1Xd1jS71dSOiDFwwjw51diHNJN_MgvxBXOHyBIFu6eaMTjMywqaWz2T9Hnin5H1DmYbI6Gim5gcCzjT7XV8_v7jMakW6VFi0S8jv-9vhAJOMsz-Tc','BLEenHAexvaexGPulbcPmN-CbycSZEYO8z7J57wh6cuIs5AFCS73KOMclefN8LWmbFUVPrpFR7kfdF3gQo2c9V8','a4vZTImtZV8vXJiZVIqkwg',NULL,'2026-01-03 16:56:26','2026-01-03 16:56:26'),
(65,'App\\Models\\Guest',66,'https://fcm.googleapis.com/wp/exurmhPo8qU:APA91bG0TYGMX7T1wkzZ1CBorVTZyOcXIfanM1VrDFL3Vg9fjaGRKNAp4dyoXMbAsbLNsaklvVrME8ohff5bWECOI6tbZxo2c6w5FY8C0ikuDfe2TlYGSbJ-w-l0UnxJStnScGjD6nqV','BE37a3q9uHizGsZCVvCrkx82nyO_LOToc9WMwtxxfMq_6nds9r4Etv1QSvqjpUGFybwWe3NdyE0tEV7fyBm1foU','e3nvkQLXK2LKu4RlWs21rA',NULL,'2026-01-03 16:56:52','2026-01-03 16:56:52'),
(66,'App\\Models\\Guest',67,'https://fcm.googleapis.com/fcm/send/eEiAhjg77ns:APA91bHtikOK4w4S1wKMxI16NWv8d33bE6AHQ57xHez7B9qrEEII4dMGAJHgKzu2yqXe0hlt-sRNaRK5vvgkI8Eu2pxvV6a3zPVwYYLoq6HRmsWNca-hbS7NlfwHlzM_R9Q79FXiwRsJ','BDRxV3uATDte3Obt6VVbZTB5auXVpNVzFtgjpLGfVIyPZ81-x36lTMjj6uGoO2X6kdC-3YG1hTiOBm1tM1rGrm4','d-PG-gHylOfJZrGnsXk4jA',NULL,'2026-01-03 17:35:31','2026-01-03 17:35:31'),
(67,'App\\Models\\Guest',68,'https://fcm.googleapis.com/fcm/send/eR4mO8weAvI:APA91bGYGfh7NdLDAxrAni-JD_MMXygo8ha0iA3D5xvzij1XLZIiN83c05Y7oGqQobdnPyNIBySyQNH4asl5awsXw-SQTbzDC8HdD9WCTCdguNXZiU73i_76Y4GNoVswDxp7MzOdnyK7','BIDL634WebsCffWS_83lDgSrwAeI8izBQr8R2bzp_tgF0_PtsFONV-AAk5DX-SJLHKtXi2mMDbhAnIPSjZSm3cY','qSCtXK_qF9oKpOfKaj2owQ',NULL,'2026-01-03 17:47:06','2026-01-03 17:47:06'),
(68,'App\\Models\\Guest',69,'https://fcm.googleapis.com/fcm/send/cO9636UELvg:APA91bHqoUL2RcZiELn5qnNPB6gFo306quyVyRhNfUfXAlQBPubvsj1QajtK5F4E_TYxKCyrDZD8Z-OLZ0EKVNUWqsXRZMms-zTLzwsv49wta3kU2K0aIj8CYVRSropaTUF8lW2pM58k','BAtElUT2HO13-2K4B6MvtHu29EZ7-ndkw-7aU66HwQVUB_XRNRCGOFwZfWrsdKJg2h1ND9UJ3p1h1ysqylwS3NQ','rXNDlja8s8zhkNYn-Ry_eg',NULL,'2026-01-03 22:12:34','2026-01-03 22:12:34'),
(69,'App\\Models\\Guest',70,'https://fcm.googleapis.com/fcm/send/dn1jfnAoVJY:APA91bFX5WIZ9lhJPERWF3Dn7DwDlSiU5hBWMV0JsVWpkjSFwZbyRK7s1-oC4S9yW4_68ovVRmNNy_UL0t6_wSZmsva7BknlgU0Q6lU6D7PluzpYyhZLz2q0D_O71hAqtNLseqNnLaC6','BNRFIf-eiSyTN-7qqXkoWj5xAYjPLvnDz2bqSb4FXWDZA43jYgV_dzyBEM5GMi6HTTuO0M8Jiu4r_vTedUmdOq0','6bvXpax3-fT0loQCfydPMA',NULL,'2026-01-03 22:12:43','2026-01-03 22:12:43'),
(70,'App\\Models\\Guest',71,'https://fcm.googleapis.com/fcm/send/cbL9OeVzUhM:APA91bFGebD6N8jJ_NCMvDFk7aMhY6OATuncBIjUn07U5sPayCbDdIjMf01kcHfOtaDojby-uiYpukF0qJgLXHI-MubV4yKS2tEYakOcmS-cGrGXMzxIvLtPevx_cMMwFT-zcgUaNOy8','BIOM0x6iZpmHtn1nQJBHZWaSG54VpXNjo-tL3KdVUcYoncxJXL1Uhp4nxzZuOrxv_s4ZpQ5PYVAwOSJLidKck4g','tjDWibTDNyq5Dxkj0C4-UA',NULL,'2026-01-03 22:18:28','2026-01-03 22:18:28'),
(71,'App\\Models\\Guest',72,'https://fcm.googleapis.com/fcm/send/dFNPl0hYPKI:APA91bGspPhm4fg-WetR88NToWySWJslJNNuuCuaaKB13QwKcUbRwzgx5wFpV3lJH-XQjUJwFkyXXNUWosxoiOHga4WzYsVYgVA5QQCnju_0e_pn1vHB8JrxrT_wxmXElrDDA4AnLy9n','BCFYMi2w_ktfK_ZuCIkHG7oMZQQk3Aa92ktgWDQG-H3YTiDMOKboifQuEBPI_-fdiCOJORAHxPneWeRIWbHksl0','JJvp0qB9D1szIpb8J_OfFQ',NULL,'2026-01-03 22:31:51','2026-01-03 22:31:51'),
(72,'App\\Models\\Guest',73,'https://fcm.googleapis.com/fcm/send/epuW2_Owc5o:APA91bEgas-0GERSV7rLwP-u_5LA9J1OtEEXp4vwxuAeOFFrSiZ9cnfeU4qcTUYymZc0lApH3oc6tcPcdq5L7truckd88rbmORvP01iDjz5k-4NI2eZfm1H9Kd7VPbTX02jFuC-R09eq','BKt8haqXBQSAvleVWAxNq0YTUwbIUBgullvTf54LWEWd0x9Ivyzuuz3ShnVsozXfb82WiGq1CIAgWlYPGywz53E','8myfmeRoTU1w2oWgmL_Jiw',NULL,'2026-01-03 22:31:53','2026-01-03 22:31:53'),
(73,'App\\Models\\Guest',74,'https://fcm.googleapis.com/fcm/send/fRuMAIZ-GOA:APA91bFcgCzY_wVVUQNFLsErhI5fYQFopsX8Aruykv-NHMrgCjaDBUQVnDR1QyW0zzSFgZrcc5_95Jw2I2gRMJQOnkCaCvcXAr_GLU7oiePmVXbGMj7lhtQDeTh5mXUd4cqJWho3QK6T','BKBgh4Ta9kT_xAqQrH4KZjD5Okh7OYsq5NaB4s2hHmq0GqJzvrhFz_mbwOrtrXbV9Dej4kg3D_12sish_bEmBWk','BELUpjTMYgo6XOJ5l7En4Q',NULL,'2026-01-03 22:32:02','2026-01-03 22:32:02'),
(74,'App\\Models\\Guest',75,'https://fcm.googleapis.com/fcm/send/dKkLvrTM7wU:APA91bHbx7gW32oVUt3-4d0lYnrtcdslGWG0a0hMnQ0-ApKBotf2DiQqHwwVVr-RWGoPtg6kZzTg4xkd9Jr9AbezGgWG1Agf7FwyXYLnw2lQy4ZwNgE-YfMhWeCihBoz9OK8Fy8-Zbx2','BC9g-gpNhBnCe3m84N3llubR-4C-oqyTg0CLEXVntMxJbR7LFYm6opsSfiaafjbV-Gk72N33Wpze-8327zTLOuQ','m1nFI2B4kY-gFWZRDlaKfQ',NULL,'2026-01-03 22:49:42','2026-01-03 22:49:42'),
(75,'App\\Models\\Guest',76,'https://fcm.googleapis.com/fcm/send/fgm5Q13e7rs:APA91bFt4Muruwo0JIS3Ty75M8VeN8up_EfQij0A8gFv-awz24EkVqTOOLbctGp_4hCQWIMUKQaHv-B4h-q5Iu7DcTQczFGb7f9IosWFj4JV2UPMRWPQy11y1ynH2DHpzxei8HBQBMmg','BEQQz2ggII9jsGzqQXzabqzNbUgYsPR99iVa2NCMKcT67nzEO-kIaKAK9-kEk39ErOvL7MjNEH94zg0WD6vvsZI','eGBLFrZHJFWPYQam6aWpbw',NULL,'2026-01-03 22:50:09','2026-01-03 22:50:09'),
(76,'App\\Models\\Guest',77,'https://fcm.googleapis.com/fcm/send/eI7UlSldzLk:APA91bENE7bT11rboT9LClgnjrLQfzH9Kjy8G_C-6Ms0ayKhzk_p6dcmcgNBUtFpBkwep7t4JP5pZ-TNwbjz--EjUPWpsQot3GYGjHUuDoqRtZ-w7Lt9-YIClrHNcyCxL3rwgDJtTL9C','BJd3l_BGwo78GLBdpZ_YWjFikT-Kk2Yjtrcs7k-uU1U3kvd_SmqmyUPdSn7k-bK1fqyLJ93FbckwoCwJix_uQjc','i7z8LvdJnBHVl5I6NnNl6A',NULL,'2026-01-03 22:50:58','2026-01-03 22:50:58'),
(77,'App\\Models\\Guest',78,'https://fcm.googleapis.com/fcm/send/eh1chZXjmvA:APA91bHe2J3S6Rs_kpseYJkv2J6lfJfnCE5T95IiAEsv6dS0ZGFSI-1Zk0TqSac9IiWo8ljyLtlD1Q3wUF7A9cUj5ogYESHRJrXu7IMW_XQmqye6E_ptKiPE00zVWfMx-ckT8hXlNdVi','BPxViKPx8YyBDXsVo4cm62ChkA1VAIuN2FPioP9z4F5OWEZEafdemIANDCLwwHWh5lXLP3pb3aNm1Bza2qVFAqg','a_WUAlJnDUfrhwxjibJyBg',NULL,'2026-01-03 23:55:50','2026-01-03 23:55:50'),
(78,'App\\Models\\Guest',79,'https://fcm.googleapis.com/fcm/send/eDKM7f2yWm4:APA91bHE37uyPOdtELTlcG1LJdOEkxbKn6UoOe7avSbPtqh7poyQu3ImOoRf64DV9wWfXHw-ajFF-a8_xLlY8J6zbtAP3_4CydidQP_PzYv3y8F2x8oOT5oijqnHJ2sNkBmfFefNNAsu','BGRM-eGMyETPmK0tQNcHvYPgf2bhyPjaWymJi5PR5V-LKU32-eVgPhj1jhgxrIYnXY_3GMix_mJLTgW_oAKxaPk','CPox2_Klr5aN-NE0UdC8Hw',NULL,'2026-01-04 00:05:46','2026-01-04 00:05:46'),
(79,'App\\Models\\Guest',80,'https://fcm.googleapis.com/fcm/send/dxwakHIZV3Y:APA91bFcNwj044XPDeW2nr5B1YlzM2lX-Qu6vp4cIfqAMRWW9RZGz1iCDVpNDfS7xBYUZdgQByOoofKKzQT_r09eVc9IzQGoyRRlsb1KxyGRUhTKPj0GBNZmLLk0DAQv0TG8s9kvcM9f','BIrwIMzkVvKaGgi2zxUpz-AwU05MgdNzj8P43fx-q5iePMHnaOJYRuPiKjYqfE-ON-GmJcOOoxBE4aZ2h-0krYM','HCBGI0LP1MbIEBQl5XMrlg',NULL,'2026-01-04 00:21:37','2026-01-04 00:21:37'),
(80,'App\\Models\\Guest',81,'https://fcm.googleapis.com/fcm/send/eqIq8NfLvG0:APA91bEXRaq7h1_8tH3CJh6P0VFHtKJTEno2ufHaQw71IH6Oou1XLUy1Ge5jOAzByaKqiwfaZBG7hd-UPZ78rO7nXExIA68IVS0U8BP-HxSY1CgBIWmpvX09pQDhVoiasesk5ZJwd1OT','BFULpuxu5e3DGOqN25AItxVDUlGTw4TsaRplD0Arho3uZTdTYjOaaAZZt0glXzRyqAHLr38w-h2SBg1HqIjLC1Y','LnjIIyhhCu4S7RYZ1rJx1Q',NULL,'2026-01-04 00:31:45','2026-01-04 00:31:45'),
(81,'App\\Models\\Guest',82,'https://fcm.googleapis.com/fcm/send/dR266uTCggw:APA91bGNWzFPwvEIrwKbqGl-NSY7NWLZK7RdZ3X2ZukOIjY78s-fZQ58cljwDGwXarZwxO9KEoyiBst9g8641uyMWZYLWa2lLkznApMMuTWIKtaqcvWlDEUsgpopybkDmfrT-tUxwEfT','BLcZ0ksOk3W3ke7ksACFkyGpJrKZHyb6Yd2yYxLioljbkpgjPRmu5t2VEjOITTKcodT7LK2ULkoKIJLoKxrz-DY','AZEzw5YB9CM8yVnELYQc-Q',NULL,'2026-01-04 00:33:12','2026-01-04 00:33:12'),
(82,'App\\Models\\Guest',83,'https://fcm.googleapis.com/fcm/send/f_XOxQ9zjMM:APA91bHhKR_4qmLN4urawZB-EeR3Ist__N_bvMjGVCvw50oTcmR1-jxcAWBCYbQVc2x-tnt84wWcdv2Z5xXNboPROJoJ8B8G7vS-SU7LBFmYATdDFZoXB0WqGse8s15nUu7tU6nJK-Nw','BFli2_9_iSzrUNgmI-5cHw-UaYJMOaQzncGa3ted_Av-tBXn9X2Rd2HdCToI0Y9C5-_IwJNWfZkqgpTXfzF_ZZc','ClM3raICNaQNt_56jbkr-A',NULL,'2026-01-04 03:17:44','2026-01-04 03:17:44'),
(83,'App\\Models\\Guest',84,'https://fcm.googleapis.com/fcm/send/ej5YIH9zOOY:APA91bFkxjJnnSh7p0v2zpzEfuf6G14aWIu1-F-9EInRZNllke0sw_p5pdYBj8qWYeSLRtjicfVo-z0-eoDQ3VN01e7uEp5zZVA4iIJslLUffX0u-s6X8mZR3z_rRnX68LufgHLCUQiJ','BMFSl29SzNlEH7AewxUpQSBemHdU_vYNj0OuvkQHfWwF-hTcR2Tpt1QPEcJ6-PqKZbmnPF3Vs5YwsH2PKsoaIVA','dP0sMcGrZQxwsr8rqGe26Q',NULL,'2026-01-04 03:17:52','2026-01-04 03:17:52'),
(84,'App\\Models\\Guest',85,'https://fcm.googleapis.com/fcm/send/dlk3CMFoAls:APA91bHIc1_JPsnTXBVZ1AoovQf9Lv4WK-0ALOoCUA-0bJVnFOqyiZd2T6mdEwMdMCLsojjsarN8Vervnk2AovjtrMRGWzMLS58XPr9fjgQSymJhAXF35r_3LGH-pBpC7WT-SjtTUONh','BARvLytjIWhcugCyli-7RevlTnhorM1ISQzAiZhqsuCmPe5ymnqLUpVFT7UmRP3tn-4DdbELjwsFh3KsShgbxEc','EnkQB_jIgEML_i1oxTJA5w',NULL,'2026-01-04 03:27:45','2026-01-04 03:27:45'),
(85,'App\\Models\\Guest',86,'https://fcm.googleapis.com/fcm/send/epv8prbCbAQ:APA91bG3drMHKei3WsGFbZ59ZmF0gDguVKrsRKUvEkf-EPdA6bRLREWie1lcqQd-bB4HuY3YolfVm8ZoOrpD8hLALpDzARRo6kpg5vc4l1rPoB2Vox1Nmn86m0Wi1bUgX5k9kNEONWCb','BD2_qYnum5zKTwVN9jjSzMD_vqNq1wUtN3nQHysokRu8TszN7Vv9G3Lr9VdNpKY3Gtpe82vzbBqVNqyMvur-mzI','2jG5OsGZMvN8paY0AN6wUA',NULL,'2026-01-04 04:35:17','2026-01-04 04:35:17'),
(86,'App\\Models\\Guest',87,'https://fcm.googleapis.com/fcm/send/eyUixbbBzDQ:APA91bHqgEnwbGmZ_PpTrRzF2rpKJ1pv9wvHtVJh0-Ppqysq3bNlLOzki3E5YL8HlNX8W-x1_Stvr4pKohmT3YmO9tt9hcc9xobGEix0oDrGH5OVx5p6RamMOZZG2QcL2x757UlBaFYV','BF4U7iWAYx4qTESlHCza1WjrEJjWGo_Qul8X-1pqt9XUqyBA4iCERBcagAkkkJl0eLrhYGdzdObp0B4dJHDPz5U','rxHGKjyvMg2_IfoE5QF9NA',NULL,'2026-01-04 04:35:25','2026-01-04 04:35:25'),
(87,'App\\Models\\Guest',88,'https://wns2-bl2p.notify.windows.com/w/?token=BQYAAABaBJYTnkrfin4AOGf4R6d75rYZikaI5V327eMJ68Ut0OdK7qAFkZ8m0img5y2zHD7bWvwWh4TOof0OLhvXGFbGUuzKuoOSe5CK7s%2fLTSq54cV1lKCl66DgStPVzYJJnS%2bBB79Kfzfe3QUpHggg5zlaMHtaMb3qaz9CXZ62luf1TgrVOh2dlVe3i70%2byeVLBQx2HjtnLqYD6sJ1ojNY38INNpffQ0oiTxNpsu9tTZp1vxo8UZNadiSeHF8yhE8KgxToBc%2bXSfm2qOxqPIpo0B8464eLrdRpvxWCnTXsfrHMWg4ErJTAfMHbZscL6g0K3ZU%3d','BNAS-NW1dd4SrO7tRJkW08PHttAjg2xRyGMvryUPhm2n_WxVqIhwoXC7T6lnq1rKOCm55MXv-qNt8nfpzmufbuc','xFM88sKNUXyqi4tZM_38-A',NULL,'2026-02-08 00:01:02','2026-02-08 00:01:02'),
(88,'App\\Models\\Guest',89,'https://fcm.googleapis.com/fcm/send/dzyFQDQbTZI:APA91bGd_ydHF7MOTl0hGIBLszxaVrzO1f3uZFwu4B2qv8ltnIO3zQWe1iBqu9iJ7TLC_10bEDra0YQq4lkrcjW4jer3yb3UCurs09B3rBdC-AoTrxoLCfu3_SVJQLskcIaQMiwdbq9C','BGAY_RGU9HB2Ofa4mu6Z-Mt1r_DOrWnq8kiF24ILupw75m_W_u6Xsc1j26F6BVUYBmCAL0FP9yvTdvXn9z8ECTQ','sc8FvrsPFYdYZRmotZ3Jtg',NULL,'2026-02-17 18:08:50','2026-02-17 18:08:50'),
(89,'App\\Models\\Guest',90,'https://fcm.googleapis.com/fcm/send/c_SlS6OcWNg:APA91bHNv8XPIjAgK-Cg2jwiFdt1Kj_axgrrCDcjWdnKBi1SQlMZQ0OGLtFyV92GRDiewWMKJVmJViKF2giqmk7VrPo-m9RoFOU8rZ7oiYtNhk8VpdG-aTbii5hTymOfdGF1A9hxBa7v','BECHyxcPB3XPsSvikjiBggsugxNNjgrDDMA1PUNWSwq2m_ZsVGwP__lidzBygTz-KNKY088h3UAtDaFoQeW4yoU','M3oAeRDM6qveiRGNR9izPQ',NULL,'2026-02-17 18:22:15','2026-02-17 18:22:15');
/*!40000 ALTER TABLE `push_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `quick_links`
--

DROP TABLE IF EXISTS `quick_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `quick_links` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `title` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `serial_number` smallint(5) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `quick_links_language_id_foreign` (`language_id`),
  CONSTRAINT `quick_links_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `quick_links`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `quick_links` WRITE;
/*!40000 ALTER TABLE `quick_links` DISABLE KEYS */;
INSERT INTO `quick_links` VALUES
(14,8,'Links','#',1,'2025-12-06 06:23:03','2025-12-06 06:23:03');
/*!40000 ALTER TABLE `quick_links` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `permissions` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES
(4,'Admin','[\"Admin Management\",\"Basic Settings\",\"Payment Gateways\",\"Push Notification\",\"Subscribers\",\"Announcement Popups\",\"Advertise\",\"FAQ Management\",\"Blog Management\",\"Custom Pages\",\"Footer\",\"Home Page\",\"Support Ticket\",\"Customer Management\",\"Organizer Mangement\",\"Event Management\",\"Withdraw Method\",\"Menu Builder\",\"Lifetime Earning\",\"Total Profit\"]','2021-08-06 22:42:38','2023-05-03 12:55:43'),
(6,'Moderator','[\"Support Ticket\"]','2021-08-07 22:14:34','2023-05-03 12:59:16'),
(14,'Supervisor','[\"Mobile Interface\"]','2021-11-24 22:48:53','2025-10-28 04:55:58'),
(15,'Scanner','[\"Admin Management\",\"Language Management\",\"PWA Settings\",\"Basic Settings\",\"Payment Gateways\",\"Push Notification\",\"Subscribers\",\"Announcement Popups\",\"Advertise\",\"Contact Page\",\"FAQ Management\",\"Blog Management\",\"Custom Pages\",\"Footer\",\"Home Page\",\"Shop Management\",\"Support Ticket\",\"Customer Management\",\"Organizer Mangement\",\"Transaction\",\"Event Management\",\"Event Bookings\",\"Withdraw Method\",\"Menu Builder\",\"Lifetime Earning\",\"Total Profit\",\"Mobile Interface\"]','2025-12-28 18:04:18','2025-12-28 18:06:09');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `section_titles`
--

DROP TABLE IF EXISTS `section_titles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `section_titles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
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
  `features_title` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `section_titles`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `section_titles` WRITE;
/*!40000 ALTER TABLE `section_titles` DISABLE KEYS */;
INSERT INTO `section_titles` VALUES
(1,8,'Explore Our Events','Explore Category','Our Instructors','Customer Feedbacks','Our Features','Latest Blog','2021-10-05 03:30:05','2025-12-17 07:00:35','Category','Upcoming Event','Features');
/*!40000 ALTER TABLE `section_titles` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `categories_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `about_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `featured_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `features_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `how_work_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `testimonials_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `partner_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `footer_section_status` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES
(1,0,0,1,0,0,0,0,1,'2021-12-11 00:55:13','2025-12-15 16:22:00');
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `seos`
--

DROP TABLE IF EXISTS `seos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `seos` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `meta_keyword_home` varchar(255) DEFAULT NULL,
  `meta_description_home` text DEFAULT NULL,
  `meta_keyword_event` varchar(255) DEFAULT NULL,
  `meta_description_event` text DEFAULT NULL,
  `meta_keyword_organizer` varchar(255) DEFAULT NULL,
  `meta_description_organizer` text DEFAULT NULL,
  `meta_keyword_shop` varchar(255) DEFAULT NULL,
  `meta_description_shop` text DEFAULT NULL,
  `meta_keyword_blog` varchar(255) DEFAULT NULL,
  `meta_description_blog` text DEFAULT NULL,
  `meta_keyword_faq` varchar(255) DEFAULT NULL,
  `meta_description_faq` text DEFAULT NULL,
  `meta_keyword_contact` varchar(255) DEFAULT NULL,
  `meta_description_contact` text DEFAULT NULL,
  `meta_description_about` varchar(255) DEFAULT NULL,
  `meta_keyword_about` varchar(255) DEFAULT NULL,
  `meta_keyword_customer_login` varchar(255) DEFAULT NULL,
  `meta_description_customer_login` text DEFAULT NULL,
  `meta_keyword_customer_signup` varchar(255) DEFAULT NULL,
  `meta_description_customer_signup` text DEFAULT NULL,
  `meta_keyword_organizer_login` varchar(255) DEFAULT NULL,
  `meta_description_organizer_login` text DEFAULT NULL,
  `meta_keyword_organizer_signup` varchar(255) DEFAULT NULL,
  `meta_description_organizer_signup` text DEFAULT NULL,
  `meta_keyword_customer_forget_password` varchar(255) DEFAULT NULL,
  `meta_description_customer_forget_password` text DEFAULT NULL,
  `meta_keyword_organizer_forget_password` varchar(255) DEFAULT NULL,
  `meta_description_organizer_forget_password` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `seos_language_id_foreign` (`language_id`),
  CONSTRAINT `seos_language_id_foreign` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `seos`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `seos` WRITE;
/*!40000 ALTER TABLE `seos` DISABLE KEYS */;
INSERT INTO `seos` VALUES
(2,8,'home','Home Description','Events','Event  Description','Organizer','Organizer Description','Shop','Shop Description','blog','Blog Description','faq','FAQ Description','contact','Contact Description','about us descriptions','about,us','login','Login Description','signup','Signup Description','organizer_login','Organizer Login Description','Organizer_signup','Organizer Signup Page','forget password','Forget Password Description','Organizer_forget','Organizer forget password','2021-07-30 05:57:39','2023-05-20 09:50:11');
/*!40000 ALTER TABLE `seos` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `shipping_charges`
--

DROP TABLE IF EXISTS `shipping_charges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shipping_charges` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `language_id` int(11) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL,
  `days` varchar(255) DEFAULT NULL,
  `charge` decimal(11,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shipping_charges`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `shipping_charges` WRITE;
/*!40000 ALTER TABLE `shipping_charges` DISABLE KEYS */;
INSERT INTO `shipping_charges` VALUES
(7,'Method Two',8,'Method Two Shipping Charge',NULL,10.00,'2022-06-26 00:31:09','2023-05-06 10:40:35'),
(11,'Method One',8,'Method One shipping charge',NULL,12.00,'2022-07-01 23:06:39','2023-05-06 10:40:16');
/*!40000 ALTER TABLE `shipping_charges` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `shop_coupons`
--

DROP TABLE IF EXISTS `shop_coupons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `shop_coupons` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `code` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `value` decimal(11,2) DEFAULT NULL,
  `start_date` varchar(255) DEFAULT NULL,
  `end_date` varchar(255) DEFAULT NULL,
  `minimum_spend` decimal(11,2) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shop_coupons`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `shop_coupons` WRITE;
/*!40000 ALTER TABLE `shop_coupons` DISABLE KEYS */;
INSERT INTO `shop_coupons` VALUES
(5,'999','999','percentage',10.00,'03/23/2023','04/29/2026',100.00,'2022-06-26 03:18:09','2023-09-30 10:20:31'),
(7,'Hot 11','hot11','fixed',10.00,'05/06/2023','04/29/2026',100.00,'2023-05-07 07:48:18','2023-05-07 07:48:18'),
(8,'HIDDEN','BSIDE-D1','percentage',50.00,'12/15/2025','12/16/2025',NULL,'2025-12-15 17:18:22','2025-12-15 17:18:37');
/*!40000 ALTER TABLE `shop_coupons` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `slot_images`
--

DROP TABLE IF EXISTS `slot_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `slot_images` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) unsigned NOT NULL,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `slot_unique_id` bigint(20) unsigned NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `slot_images_event_id_index` (`event_id`),
  KEY `slot_images_ticket_id_index` (`ticket_id`),
  KEY `slot_images_slot_unique_id_index` (`slot_unique_id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slot_images`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `slot_images` WRITE;
/*!40000 ALTER TABLE `slot_images` DISABLE KEYS */;
INSERT INTO `slot_images` VALUES
(1,105,164,708424,'68dbbe12f2bab.jpg','2025-09-30 04:42:23','2025-09-30 05:25:06'),
(2,105,164,756471,'68dcc0c71ab7f.jpg','2025-09-30 23:48:55','2025-09-30 23:48:55'),
(6,105,185,192783,'68e6559574956.jpg','2025-10-08 08:14:13','2025-10-08 08:14:13'),
(8,105,186,583008,'68f716254778a.jpg','2025-10-21 01:12:05','2025-10-21 01:12:05'),
(9,105,187,485878,'68f71ad0401ee.jpg','2025-10-21 01:32:00','2025-10-21 01:32:00'),
(10,105,188,363827,'68f71cc0b2662.jpg','2025-10-21 01:40:16','2025-10-21 01:40:16'),
(12,105,189,671518,'68f731c7f2c34.jpg','2025-10-21 03:10:00','2025-10-21 03:10:00'),
(13,105,190,436376,'68f73234e3cc4.jpg','2025-10-21 03:11:48','2025-10-21 03:11:48'),
(14,105,191,898428,'6900c02aac6e5.jpg','2025-10-21 05:27:35','2025-10-28 08:07:54'),
(15,103,192,162478,'68f8c4154c3ef.jpg','2025-10-22 07:46:29','2025-10-22 07:46:29'),
(17,125,194,564966,'690ae1f1deecd.jpg','2025-11-05 00:34:41','2025-11-05 00:34:41'),
(22,126,199,236612,'690c817f0baeb.jpg','2025-11-06 06:07:43','2025-11-06 06:07:43'),
(23,127,200,688688,'690edabcc7844.jpg','2025-11-08 00:53:00','2025-11-08 00:53:00'),
(24,127,201,428313,'690f0309a0193.jpg','2025-11-08 03:44:57','2025-11-08 03:44:57'),
(25,128,202,971199,'690f327f7327e.jpg','2025-11-08 06:46:03','2025-11-08 07:07:27');
/*!40000 ALTER TABLE `slot_images` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `slot_seats`
--

DROP TABLE IF EXISTS `slot_seats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `slot_seats` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `slot_id` int(10) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `price` decimal(8,2) NOT NULL DEFAULT 0.00,
  `is_deactive` tinyint(4) NOT NULL DEFAULT 0,
  `is_booked` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `slot_seats_slot_id_index` (`slot_id`)
) ENGINE=InnoDB AUTO_INCREMENT=580 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slot_seats`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `slot_seats` WRITE;
/*!40000 ALTER TABLE `slot_seats` DISABLE KEYS */;
INSERT INTO `slot_seats` VALUES
(155,13,'A1-01',0.00,0,0),
(156,14,'A2-01',0.00,0,0),
(157,14,'A2-02',0.00,0,0),
(160,16,'RR-01',10.00,0,0),
(161,16,'RR-02',10.00,0,0),
(162,16,'RR-03',10.00,0,0),
(163,16,'RR-04',10.00,0,0),
(164,16,'RR-05',10.00,0,0),
(165,17,'R3-01',10.00,0,0),
(166,17,'R3-02',20.00,0,0),
(167,17,'R3-03',30.00,0,0),
(168,17,'R3-04',40.00,0,0),
(169,17,'R3-05',50.00,0,0),
(170,17,'R3-06',60.00,0,0),
(173,19,'R-01',1.25,0,0),
(174,19,'R-02',1.25,0,0),
(175,19,'R-03',1.25,0,0),
(176,19,'R-04',1.25,0,0),
(177,19,'R-05',1.25,0,0),
(178,19,'R-06',1.25,0,0),
(179,19,'R-07',1.25,0,0),
(180,19,'R-08',1.25,0,0),
(181,19,'R-09',1.25,0,0),
(182,19,'R-10',1.25,0,0),
(183,19,'R-11',1.25,0,0),
(184,19,'R-12',1.25,0,0),
(185,20,'B2-01',0.00,0,0),
(186,20,'B2-02',0.00,0,0),
(187,20,'B2-03',0.00,0,0),
(188,20,'B2-04',0.00,0,0),
(189,20,'B2-05',0.00,0,0),
(190,20,'B2-06',0.00,0,0),
(191,20,'B2-07',0.00,0,0),
(192,20,'B2-08',0.00,0,0),
(193,20,'B2-09',0.00,0,0),
(194,20,'B2-10',0.00,0,0),
(195,21,'B2-01',2.00,0,0),
(196,21,'B2-02',2.00,0,0),
(197,21,'B2-03',2.00,0,0),
(198,21,'B2-04',2.00,0,0),
(199,21,'B2-05',2.00,0,0),
(200,22,'RR-01',2.00,0,0),
(201,22,'RR-02',2.00,0,0),
(202,22,'RR-03',2.00,0,0),
(203,22,'RR-04',2.00,0,0),
(204,22,'RR-05',2.00,0,0),
(205,23,'B2-01',100.00,0,0),
(206,23,'B2-02',50.00,0,0),
(207,23,'B2-03',60.00,0,0),
(208,23,'B2-04',80.00,0,0),
(209,23,'B2-05',5.00,1,0),
(235,24,'x-01',80.00,1,0),
(236,24,'x-02',10.00,1,0),
(247,27,'A1-01',0.00,0,0),
(248,27,'A1-02',0.00,0,0),
(249,27,'A1-03',0.00,0,0),
(250,27,'A1-04',0.00,0,0),
(251,27,'A1-05',0.00,0,0),
(252,27,'A1-06',0.00,0,0),
(253,27,'A1-07',0.00,0,0),
(254,27,'A1-08',0.00,0,0),
(255,27,'A1-09',0.00,0,0),
(256,27,'A1-10',0.00,0,0),
(257,28,'RR-01',10.00,0,0),
(268,30,'RR-01',0.00,0,0),
(269,30,'RR-02',0.00,0,0),
(270,30,'RR-03',0.00,0,0),
(271,30,'RR-04',0.00,0,0),
(272,30,'RR-05',0.00,0,0),
(273,30,'RR-06',0.00,0,0),
(274,30,'RR-07',0.00,0,0),
(275,30,'RR-08',0.00,0,0),
(276,30,'RR-09',0.00,0,0),
(277,30,'RR-10',0.00,0,0),
(278,31,'B2-01',100.00,0,0),
(279,31,'B2-02',3.00,0,0),
(280,31,'B2-03',100.00,0,0),
(281,31,'B2-04',100.00,0,0),
(282,31,'B2-05',100.00,0,0),
(283,31,'B2-06',100.00,0,0),
(284,31,'B2-07',100.00,0,0),
(285,31,'B2-08',100.00,0,0),
(286,31,'B2-09',100.00,0,0),
(287,31,'B2-10',100.00,0,0),
(288,32,'1x-01',100.00,0,0),
(289,32,'1x-02',100.00,0,0),
(290,32,'1x-03',100.00,0,0),
(291,32,'1x-04',100.00,0,0),
(292,32,'1x-05',100.00,0,0),
(293,32,'1x-06',100.00,0,0),
(294,32,'1x-07',100.00,0,0),
(295,32,'1x-08',100.00,0,0),
(296,32,'1x-09',100.00,0,0),
(297,32,'1x-10',100.00,0,0),
(298,33,'RR-01',1.00,0,0),
(299,33,'RR-02',1.00,0,0),
(300,33,'RR-03',1.00,0,0),
(301,33,'RR-04',1.00,0,0),
(302,33,'RR-05',1.00,0,0),
(303,33,'RR-06',1.00,0,0),
(304,33,'RR-07',1.00,0,0),
(305,33,'RR-08',1.00,0,0),
(306,33,'RR-09',1.00,0,0),
(307,33,'RR-10',1.00,0,0),
(308,34,'55-01',100.00,0,0),
(309,34,'55-02',5.00,0,0),
(310,34,'55-03',0.00,0,0),
(311,34,'55-04',0.00,0,0),
(312,34,'55-05',0.00,0,0),
(313,34,'55-06',0.00,0,0),
(314,34,'55-07',0.00,0,0),
(315,34,'55-08',0.00,0,0),
(316,34,'55-09',0.00,0,0),
(317,34,'55-10',0.00,0,0),
(318,35,'Test Slot-01',10.00,1,0),
(319,35,'Test Slot-02',10.00,1,0),
(320,35,'Test Slot-03',10.00,0,0),
(321,35,'Test Slot-04',10.00,0,0),
(322,35,'Test Slot-05',10.00,0,0),
(323,35,'Test Slot-06',10.00,0,0),
(324,35,'Test Slot-07',10.00,0,0),
(325,35,'Test Slot-08',10.00,0,0),
(326,35,'Test Slot-09',10.00,0,0),
(327,35,'Test Slot-10',10.00,0,0),
(328,36,'5-01',100.00,1,0),
(329,36,'5-02',200.00,1,0),
(330,36,'5-03',300.00,1,0),
(331,36,'5-04',0.00,0,0),
(332,36,'5-05',0.00,0,0),
(333,37,'TR-01',2.00,0,0),
(334,37,'TR-02',2.00,0,0),
(335,37,'TR-03',2.00,0,0),
(336,37,'TR-04',2.00,0,0),
(337,37,'TR-05',2.00,0,0),
(350,40,'B2-01',0.00,0,0),
(351,40,'B2-02',0.00,0,0),
(352,41,'b4-01',0.00,0,0),
(353,41,'b4-02',0.00,0,0),
(395,50,'NZ-Second-01',10.00,0,0),
(396,50,'NZ-Second-02',20.00,0,0),
(397,50,'NZ-Second-03',30.00,0,0),
(398,50,'NZ-Second-04',40.00,0,0),
(399,50,'NZ-Second-05',50.00,0,0),
(400,50,'NZ-Second-06',20.00,0,0),
(401,51,'NZ-Third-01',100.00,0,0),
(402,51,'NZ-Third-02',200.00,0,0),
(403,51,'NZ-Third-03',30.00,0,0),
(404,51,'NZ-Third-04',30.00,0,0),
(405,51,'NZ-Third-05',20.00,0,0),
(406,51,'NZ-Third-06',21.00,0,0),
(417,53,'EZ-Sceond-01',10.00,0,0),
(418,53,'EZ-Sceond-02',10.00,0,0),
(419,53,'EZ-Sceond-03',10.00,0,0),
(420,53,'EZ-Sceond-04',9.00,0,0),
(421,53,'EZ-Sceond-05',10.00,0,0),
(422,53,'EZ-Sceond-06',10.00,0,0),
(423,53,'EZ-Sceond-07',10.00,0,0),
(424,53,'EZ-Sceond-08',10.00,0,0),
(425,53,'EZ-Sceond-09',10.00,0,0),
(426,53,'EZ-Sceond-10',10.00,0,0),
(432,55,'SZ-Second-01',50.00,0,0),
(433,55,'SZ-Second-02',70.00,0,0),
(434,55,'SZ-Second-03',80.00,0,0),
(435,56,'SZ-Third-01',20.00,0,0),
(436,56,'SZ-Third-02',20.00,0,0),
(437,56,'SZ-Third-03',30.00,0,0),
(438,56,'SZ-Third-04',20.00,0,0),
(439,56,'SZ-Third-05',20.00,0,0),
(445,58,'WZ-Scond-01',60.00,0,0),
(446,58,'WZ-Scond-02',70.00,0,0),
(447,58,'WZ-Scond-03',60.00,0,0),
(448,58,'WZ-Scond-04',60.00,0,0),
(449,58,'WZ-Scond-05',60.00,0,0),
(450,59,'Couple-01',54.00,0,0),
(451,59,'Couple-02',54.00,0,0),
(452,60,'Couple-2-01',25.00,0,0),
(453,60,'Couple-2-02',25.00,0,0),
(454,61,'A1-01',5.00,0,0),
(455,62,'A2-01',5.00,0,0),
(456,63,'Couple-3-01',0.00,0,0),
(457,63,'Couple-3-02',0.00,0,0),
(458,64,'couple-5-01',5.00,0,0),
(459,64,'couple-5-02',5.00,0,0),
(460,65,'B1-01',10.00,0,0),
(461,66,'B2-01',12.00,0,0),
(462,67,'B3-01',15.00,0,0),
(463,68,'B4-01',60.00,0,0),
(464,69,'B5-01',10.00,0,0),
(465,70,'B6-01',15.00,0,0),
(466,71,'B6-01',1.43,0,0),
(467,71,'B6-02',1.43,0,0),
(468,71,'B6-03',1.43,0,0),
(469,71,'B6-04',1.43,0,0),
(470,71,'B6-05',1.43,0,0),
(471,71,'B6-06',1.43,0,0),
(472,71,'B6-07',1.42,0,0),
(474,73,'B9-01',110.00,0,0),
(475,74,'B10-01',0.00,0,0),
(476,75,'Gold Class-01',12.00,0,0),
(477,75,'Gold Class-02',12.00,0,0),
(478,75,'Gold Class-03',12.00,0,0),
(479,75,'Gold Class-04',12.00,0,0),
(480,75,'Gold Class-05',12.00,0,0),
(481,76,'Platinum-01',20.00,0,0),
(482,76,'Platinum-02',20.00,0,0),
(483,76,'Platinum-03',20.00,0,0),
(484,76,'Platinum-04',20.00,1,0),
(485,76,'Platinum-05',20.00,1,0),
(486,76,'Platinum-06',20.00,1,0),
(487,76,'Platinum-07',20.00,0,0),
(488,77,'D1-01',10.00,0,0),
(489,78,'D2-01',10.00,0,0),
(490,79,'D3-01',50.00,0,0),
(491,80,'D4-01',20.00,0,0),
(492,81,'D5-01',10.00,0,0),
(493,82,'D6-01',150.00,0,0),
(494,83,'D7-01',15.71,0,0),
(495,83,'D7-02',15.71,0,0),
(496,83,'D7-03',15.71,0,0),
(497,83,'D7-04',15.71,0,0),
(498,83,'D7-05',15.71,0,0),
(499,83,'D7-06',15.71,0,0),
(500,83,'D7-07',15.74,0,0),
(501,84,'D8-01',110.00,0,0),
(502,85,'E1-01',10.00,0,0),
(503,86,'E2-01',0.00,0,0),
(504,87,'E3-01',10.00,0,0),
(505,88,'E4-01',10.00,0,0),
(506,89,'E6-01',0.00,0,0),
(507,90,'E7-01',0.00,0,0),
(508,91,'E8-01',10.00,0,0),
(509,92,'Test Slot-01',0.00,0,0),
(510,92,'Test Slot-02',0.00,0,0),
(511,93,'A1-01',10.00,0,0),
(512,94,'Executive VIP-01',0.00,1,0),
(513,94,'Executive VIP-02',0.00,1,0),
(514,94,'Executive VIP-03',0.00,1,0),
(515,94,'Executive VIP-04',0.00,1,0),
(516,94,'Executive VIP-05',0.00,0,0),
(517,94,'Executive VIP-06',0.00,0,0),
(518,94,'Executive VIP-07',0.00,0,0),
(519,94,'Executive VIP-08',0.00,0,0),
(520,94,'Executive VIP-09',0.00,0,0),
(521,94,'Executive VIP-10',0.00,0,0),
(522,95,'Elite Business-01',0.00,0,0),
(523,95,'Elite Business-02',0.00,0,0),
(524,95,'Elite Business-03',0.00,0,0),
(525,95,'Elite Business-04',0.00,0,0),
(526,95,'Elite Business-05',0.00,0,0),
(527,96,'D-01',0.00,0,0),
(528,97,'D2-01',0.00,0,0),
(529,98,'G1-01',0.00,0,0),
(530,99,'G1-01',0.00,0,0),
(531,100,'G2-01',0.00,0,0),
(532,101,'G4-01',0.00,0,0),
(533,102,'G5-01',0.00,0,0),
(534,103,'G6-01',0.00,0,0),
(535,104,'G7-01',0.00,0,0),
(536,105,'G8-01',0.00,0,0),
(537,106,'G8-01',0.00,0,0),
(538,107,'Couple-01',0.00,0,0),
(539,107,'Couple-02',0.00,0,0),
(540,108,'Group Seat-01',0.00,0,0),
(541,108,'Group Seat-02',0.00,0,0),
(542,108,'Group Seat-03',0.00,0,0),
(543,108,'Group Seat-04',0.00,0,0),
(544,108,'Group Seat-05',0.00,0,0),
(545,109,'Group - Person -7-01',0.00,0,0),
(546,109,'Group - Person -7-02',0.00,0,0),
(547,109,'Group - Person -7-03',0.00,0,0),
(548,109,'Group - Person -7-04',0.00,0,0),
(549,109,'Group - Person -7-05',0.00,0,0),
(550,109,'Group - Person -7-06',0.00,0,0),
(551,109,'Group - Person -7-07',0.00,0,0),
(552,110,'General Access-01',0.00,0,0),
(553,110,'General Access-02',0.00,0,0),
(554,110,'General Access-03',0.00,0,0),
(555,110,'General Access-04',0.00,0,0),
(556,110,'General Access-05',0.00,0,0),
(557,110,'General Access-06',0.00,0,0),
(558,110,'General Access-07',0.00,0,0),
(559,110,'General Access-08',0.00,0,0),
(560,111,'Student Pass-01',0.00,0,0),
(561,111,'Student Pass-02',0.00,0,0),
(562,111,'Student Pass-03',0.00,0,0),
(563,111,'Student Pass-04',0.00,0,0),
(564,111,'Student Pass-05',0.00,0,0),
(565,111,'Student Pass-06',0.00,0,0),
(566,111,'Student Pass-07',0.00,0,0),
(567,111,'Student Pass-08',0.00,0,0),
(568,111,'Student Pass-09',0.00,0,0),
(569,111,'Student Pass-10',0.00,0,0),
(570,112,'Media Seat-01',0.00,0,0),
(571,112,'Media Seat-02',0.00,0,0),
(572,112,'Media Seat-03',0.00,0,0),
(573,112,'Media Seat-04',0.00,0,0),
(574,112,'Media Seat-05',0.00,0,0),
(575,112,'Media Seat-06',0.00,0,0),
(576,112,'Media Seat-07',0.00,0,0),
(577,112,'Media Seat-08',0.00,0,0),
(578,112,'Media Seat-09',0.00,0,0),
(579,112,'Media Seat-10',0.00,0,0);
/*!40000 ALTER TABLE `slot_seats` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `slots`
--

DROP TABLE IF EXISTS `slots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `slots` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` bigint(20) unsigned NOT NULL,
  `ticket_id` bigint(20) unsigned NOT NULL,
  `pricing_type` varchar(255) DEFAULT NULL,
  `slot_enable` tinyint(4) NOT NULL DEFAULT 0,
  `slot_unique_id` bigint(20) unsigned NOT NULL,
  `type` tinyint(4) NOT NULL COMMENT '1= slot with manual select seat 2 = slot auto manual select seats',
  `number_of_seat` int(11) NOT NULL,
  `pos_x` double NOT NULL,
  `pos_y` double NOT NULL,
  `width` double NOT NULL,
  `height` double NOT NULL,
  `round` int(11) NOT NULL DEFAULT 0,
  `price` decimal(8,2) NOT NULL DEFAULT 0.00,
  `name` varchar(255) DEFAULT NULL,
  `rotate` double(8,2) DEFAULT NULL,
  `background_color` varchar(255) DEFAULT NULL,
  `border_color` varchar(255) DEFAULT NULL,
  `font_size` double(8,2) NOT NULL DEFAULT 14.00,
  `is_deactive` tinyint(4) NOT NULL DEFAULT 0,
  `is_booked` tinyint(4) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `slots_event_id_index` (`event_id`),
  KEY `slots_ticket_id_index` (`ticket_id`),
  KEY `slots_slot_unique_id_index` (`slot_unique_id`),
  KEY `slots_type_index` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slots`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `slots` WRITE;
/*!40000 ALTER TABLE `slots` DISABLE KEYS */;
INSERT INTO `slots` VALUES
(13,105,164,'free',1,708424,2,1,190,286.84375,30,30,10,0.00,'A1',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-04 07:07:34','2025-10-11 08:49:11'),
(14,105,164,'free',1,708424,1,2,261,294.84375,30,30,10,0.00,'A2',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-04 07:07:57','2025-10-11 08:49:11'),
(16,105,164,'normal',1,756471,2,5,192,284.84375,30,30,10,50.00,'RR',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-04 07:10:21','2025-10-11 08:50:12'),
(17,105,164,'normal',1,756471,1,6,252,285.84375,30,30,65,10.00,'R3',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-04 07:10:55','2025-10-11 08:50:12'),
(19,105,164,'variation',0,231988,2,12,244,285.84375,30,30,49,15.00,'R',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-04 23:51:16','2025-10-21 01:11:42'),
(20,105,185,'free',1,192783,2,10,189,284.84375,30,30,10,0.00,'B2',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-08 08:14:25','2025-10-20 08:00:40'),
(21,105,164,'normal',1,756471,2,5,455.2325439453125,285.0762939453125,30,30,10,10.00,'B2',10.00,'#00e5b5',NULL,14.00,0,0,'2025-10-09 08:07:41','2025-10-11 08:50:12'),
(22,105,164,'variation',0,231988,2,5,299,285.84375,30,30,10,10.00,'RR',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-14 05:45:23','2025-10-21 01:11:42'),
(23,105,164,'variation',0,231988,1,5,416,283.84375,30,30,10,5.00,'B2',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-14 05:45:54','2025-10-21 01:11:42'),
(24,105,164,'variation',0,231988,1,2,479,289.84375,30,30,10,10.00,'x',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-14 05:47:41','2025-10-21 01:11:42'),
(27,105,187,'free',0,485878,2,10,213,289.84375,30,30,10,0.00,'A1',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 01:32:50','2025-10-21 01:32:50'),
(28,105,188,'normal',0,363827,2,1,203.6231689453125,297.4669189453125,30,30,10,10.00,'RR',10.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 01:40:45','2025-10-21 01:41:01'),
(30,105,189,'free',1,671518,2,10,193,288.84375,30,30,10,0.00,'RR',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 03:10:15','2025-12-06 05:58:01'),
(31,105,190,'normal',1,436376,1,10,404.6231689453125,294.4669189453125,30,30,10,3.00,'B2',10.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 03:12:00','2025-12-06 05:58:01'),
(32,105,188,'variation',0,300460,1,10,535,42.84375,30,30,10,100.00,'1x',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 03:16:35','2025-10-29 05:52:54'),
(33,105,190,'normal',1,436376,2,10,263,292.84375,30,30,10,10.00,'RR',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 04:29:19','2025-11-02 06:47:46'),
(34,105,190,'normal',1,436376,1,10,247,367.84375,30,30,10,0.00,'55',0.00,'#00e5b5',NULL,14.00,1,0,'2025-10-21 04:39:45','2025-10-21 05:08:34'),
(35,105,191,'normal',0,898428,2,10,193,281.84375,30,30,10,100.00,'Test Slot',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-21 06:23:32','2025-10-29 03:15:42'),
(36,105,191,'normal',0,898428,1,5,297.8419189453125,282.6856689453125,30,30,10,0.00,'5',10.00,'#00e5b5',NULL,14.00,1,0,'2025-10-21 06:28:04','2025-10-29 03:15:42'),
(37,103,192,'normal',0,162478,2,5,190,288.84375,30,30,10,10.00,'TR',0.00,'#00e5b5',NULL,14.00,0,0,'2025-10-22 07:46:47','2025-10-25 01:36:38'),
(40,125,194,'free',1,564966,1,2,97,359.84375,180,80,10,0.00,'B2',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-05 00:35:10','2025-11-06 01:13:22'),
(41,125,194,'free',1,564966,1,2,475,286.84375,30,30,10,0.00,'b4',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-05 01:30:38','2025-11-05 02:12:38'),
(50,126,198,'variation',1,659237,1,6,313,115.8125,83,66,7,10.00,'NZ-Second',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-06 04:46:55','2025-12-06 05:57:05'),
(51,126,198,'variation',1,659237,1,6,405,116.828125,83,66,8,20.00,'NZ-Third',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-06 04:49:15','2025-11-10 06:31:18'),
(53,126,198,'variation',1,470615,1,10,492,255.8125,66,128,8,9.00,'EZ-Sceond',0.00,'#00e5b5',NULL,17.00,0,0,'2025-11-06 04:58:35','2025-12-06 05:58:01'),
(55,126,198,'variation',1,412059,1,3,311,317.84375,83,66,10,50.00,'SZ-Second',0.00,'#00e5b5',NULL,16.00,0,0,'2025-11-06 05:05:36','2025-11-10 06:31:18'),
(56,126,198,'variation',1,412059,1,5,402,317,83,66,8,20.00,'SZ-Third',0.00,'#00e5b5',NULL,16.00,0,0,'2025-11-06 05:09:37','2025-11-10 06:31:18'),
(58,126,198,'variation',1,982246,1,5,143,256,66,128,9,60.00,'WZ-Second',0.00,'#00e5b5',NULL,17.00,0,0,'2025-11-06 05:14:55','2025-11-10 06:31:18'),
(59,127,200,'normal',1,688688,2,2,106,307.84375,105,51,10,108.00,'Couple-1',0.00,'#7ee600',NULL,14.00,0,0,'2025-11-08 00:54:03','2025-11-08 07:51:52'),
(60,127,200,'normal',1,688688,2,2,220,306.84375,104,50,10,50.00,'Couple-2',0.00,'#7ee600',NULL,14.00,1,0,'2025-11-08 00:57:13','2025-11-08 07:51:52'),
(61,127,200,'normal',1,688688,2,1,333,308.84375,50,50,57,5.00,'A2',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 00:58:43','2025-11-08 07:51:52'),
(62,127,200,'normal',1,688688,2,1,392,309.84375,50,50,61,5.00,'A2',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 00:59:51','2025-11-08 07:51:52'),
(63,127,200,'normal',1,688688,2,2,450,307.84375,107,50,10,0.00,'Couple-3',0.00,'#7ee600',NULL,14.00,0,0,'2025-11-08 01:00:24','2025-11-08 07:51:52'),
(64,127,200,'normal',1,688688,2,2,565,307.84375,110,50,10,10.00,'couple-5',0.00,'#7ee600',NULL,14.00,1,0,'2025-11-08 01:01:54','2025-11-08 07:51:52'),
(65,127,200,'normal',1,688688,2,1,105,377.84375,50,50,51,10.00,'B1',0.00,'#af640d',NULL,14.00,1,0,'2025-11-08 01:02:49','2025-11-08 07:51:52'),
(66,127,200,'normal',1,688688,2,1,169,378.84375,50,50,61,12.00,'B2',0.00,'#af640d',NULL,14.00,1,0,'2025-11-08 01:03:45','2025-11-08 07:51:52'),
(67,127,200,'normal',1,688688,2,1,233,377.84375,50,50,71,15.00,'B3',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:04:38','2025-11-08 07:51:52'),
(68,127,200,'normal',1,688688,2,1,297,375.84375,50,50,60,60.00,'B4',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:05:19','2025-11-08 07:51:52'),
(69,127,200,'normal',1,688688,2,1,360,377.84375,50,50,61,10.00,'B5',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:07:12','2025-11-08 07:51:52'),
(70,127,200,'normal',1,688688,2,1,427,377.84375,50,50,61,15.00,'B6',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:08:33','2025-11-08 07:51:52'),
(71,127,200,'normal',1,688688,2,7,489,378.84375,50,50,50,10.00,'B7',0.00,'#af640d',NULL,14.00,1,0,'2025-11-08 01:16:24','2025-11-08 07:51:52'),
(73,127,200,'normal',1,688688,2,1,552,377.84375,50,50,66,110.00,'B9',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:19:06','2025-11-08 07:51:52'),
(74,127,200,'normal',1,688688,2,1,619,379.84375,50,50,50,0.00,'B10',0.00,'#af640d',NULL,14.00,0,0,'2025-11-08 01:19:46','2025-11-08 07:51:52'),
(75,127,200,'normal',1,688688,1,5,104,448.84375,277,49,6,12.00,'Gold Class',0.00,'#ffd000',NULL,25.00,0,0,'2025-11-08 01:23:47','2025-11-08 07:51:52'),
(76,127,200,'normal',1,688688,1,7,396,446.84375,274,51,7,20.00,'Platinum',0.00,'#ffd000',NULL,22.00,0,0,'2025-11-08 01:25:59','2025-11-08 07:51:52'),
(77,127,200,'normal',1,688688,2,1,92,629.84375,50,50,50,10.00,'D1',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:28:22','2025-11-08 07:51:52'),
(78,127,200,'normal',1,688688,2,1,171,628.84375,50,50,50,10.00,'D2',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:30:04','2025-11-08 07:51:52'),
(79,127,200,'normal',1,688688,2,1,247,628.84375,50,50,50,50.00,'D3',0.00,'#a9610d',NULL,14.00,1,0,'2025-11-08 01:31:04','2025-11-08 07:51:52'),
(80,127,200,'normal',1,688688,2,1,324,629.84375,50,50,50,20.00,'D4',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:32:19','2025-11-08 07:51:52'),
(81,127,200,'normal',1,688688,2,1,401,629.84375,50,50,50,10.00,'D5',0.00,'#a9610d',NULL,14.00,1,0,'2025-11-08 01:33:29','2025-11-08 07:51:52'),
(82,127,200,'normal',1,688688,2,1,479,629.84375,50,50,50,150.00,'D6',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:34:17','2025-11-08 07:51:52'),
(83,127,200,'normal',1,688688,2,7,556,629.84375,50,50,50,110.00,'D7',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:35:01','2025-11-08 07:51:52'),
(84,127,200,'normal',1,688688,2,1,634,626.84375,50,50,50,110.00,'D8',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:35:48','2025-11-08 07:51:52'),
(85,127,200,'normal',1,688688,2,1,130,695.84375,50,50,50,10.00,'E1',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:38:24','2025-11-08 07:51:52'),
(86,127,200,'normal',1,688688,2,1,208,695.84375,50,50,50,0.00,'E2',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:39:03','2025-11-08 07:51:52'),
(87,127,200,'normal',1,688688,2,1,285,694.84375,50,50,50,10.00,'E3',0.00,'#a9610d',NULL,14.00,1,0,'2025-11-08 01:39:46','2025-11-08 07:51:52'),
(88,127,200,'normal',1,688688,2,1,364,696.84375,50,50,74,10.00,'E4',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:41:04','2025-11-08 07:51:52'),
(89,127,200,'normal',1,688688,2,1,441,696.84375,50,50,50,0.00,'E6',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:41:37','2025-11-08 07:51:52'),
(90,127,200,'normal',1,688688,2,1,519,697.84375,50,50,50,0.00,'E7',0.00,'#a9610d',NULL,14.00,0,0,'2025-11-08 01:42:44','2025-11-08 07:51:52'),
(91,127,200,'normal',1,688688,2,1,592,696.84375,50,50,50,10.00,'E8',0.00,'#a25a09',NULL,14.00,1,0,'2025-11-08 01:43:30','2025-11-08 07:51:52'),
(92,127,201,'normal',0,428313,2,2,209,571.84375,30,30,10,0.00,'Test Slot',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 03:45:15','2025-11-08 03:45:15'),
(93,127,201,'normal',0,428313,2,1,433,566.84375,30,30,10,10.00,'A1',0.00,'#00e5b5',NULL,14.00,1,0,'2025-11-08 03:45:30','2025-11-08 03:45:51'),
(94,128,202,'free',1,971199,1,10,88,302.84375,204,50,6,0.00,'Executive VIP',0.00,'#67e600',NULL,16.00,0,0,'2025-11-08 07:09:22','2025-11-08 07:58:29'),
(95,128,202,'free',1,971199,1,5,408,304.84375,205,50,6,0.00,'Elite Business',0.00,'#67e600',NULL,16.00,0,0,'2025-11-08 07:11:26','2025-11-08 07:58:29'),
(96,128,202,'free',1,971199,2,1,297,306.84375,50,50,78,0.00,'D1',0.00,'#bf00e6',NULL,14.00,1,0,'2025-11-08 07:12:13','2025-11-08 07:58:29'),
(97,128,202,'free',1,971199,2,1,355,306.84375,50,50,50,0.00,'D2',0.00,'#bf00e6',NULL,14.00,0,0,'2025-11-08 07:12:50','2025-11-08 07:58:29'),
(98,128,202,'free',1,971199,2,1,93,368.84375,50,50,50,0.00,'G1',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:14:19','2025-11-08 07:58:29'),
(99,128,202,'free',1,971199,2,1,150,368.84375,50,50,50,0.00,'G2',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:14:39','2025-11-08 07:58:29'),
(100,128,202,'free',1,971199,2,1,210,370.84375,50,50,50,0.00,'G3',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:15:09','2025-11-08 07:58:29'),
(101,128,202,'free',1,971199,2,1,268,367.84375,50,50,50,0.00,'G4',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:15:35','2025-11-08 07:58:29'),
(102,128,202,'free',1,971199,2,1,325,366.84375,50,50,50,0.00,'G5',0.00,'#00e5b5',NULL,14.00,1,0,'2025-11-08 07:16:13','2025-11-08 07:58:29'),
(103,128,202,'free',1,971199,2,1,385,367.84375,50,50,50,0.00,'G6',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:16:51','2025-12-06 05:58:01'),
(104,128,202,'free',1,971199,2,1,440,368.84375,50,50,50,0.00,'G7',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:17:17','2025-12-06 05:58:01'),
(105,128,202,'free',1,971199,2,1,500,366.84375,50,50,50,0.00,'G8',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:17:48','2025-11-08 07:58:29'),
(106,128,202,'free',1,971199,2,1,558,366.84375,50,50,50,0.00,'G8',0.00,'#00e5b5',NULL,14.00,0,0,'2025-11-08 07:18:38','2025-11-08 07:58:29'),
(107,128,202,'free',1,971199,2,2,94,438.84375,168,50,6,0.00,'Couple A',0.00,'#cb2a98',NULL,19.00,1,0,'2025-11-08 07:19:59','2025-11-08 07:58:29'),
(108,128,202,'free',1,971199,2,5,269,436.84375,164,50,5,0.00,'Group -Person - 5',0.00,'#cb2a98',NULL,19.00,0,0,'2025-11-08 07:21:39','2025-11-08 07:58:29'),
(109,128,202,'free',1,971199,2,7,442,435.84375,165,50,6,0.00,'Group - Person -7',0.00,'#cb2a98',NULL,19.00,0,0,'2025-11-08 07:23:38','2025-11-08 07:58:29'),
(110,128,202,'free',1,971199,1,8,93,502.84375,167,50,10,0.00,'General Access',0.00,'#c4b721',NULL,19.00,0,0,'2025-11-08 07:25:22','2025-11-08 07:58:29'),
(111,128,202,'free',1,971199,1,10,270,504.84375,165,50,6,0.00,'Student Pass',0.00,'#c4b721',NULL,19.00,0,0,'2025-11-08 07:26:33','2025-11-08 07:58:29'),
(112,128,202,'free',1,971199,1,10,442,504.84375,167,50,6,0.00,'Media Seat',0.00,'#c4b721',NULL,18.00,1,0,'2025-11-08 07:27:36','2025-11-08 07:58:29');
/*!40000 ALTER TABLE `slots` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `social_medias`
--

DROP TABLE IF EXISTS `social_medias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `social_medias` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `icon` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `serial_number` mediumint(8) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `social_medias`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `social_medias` WRITE;
/*!40000 ALTER TABLE `social_medias` DISABLE KEYS */;
/*!40000 ALTER TABLE `social_medias` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `states`
--

DROP TABLE IF EXISTS `states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `states` (
  `id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `country_id` mediumint(8) unsigned NOT NULL,
  `country_code` char(2) NOT NULL,
  `fips_code` varchar(255) DEFAULT NULL,
  `iso2` varchar(255) DEFAULT NULL,
  `type` varchar(191) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `flag` tinyint(1) NOT NULL DEFAULT 1,
  `wikiDataId` varchar(255) DEFAULT NULL COMMENT 'Rapid API GeoDB Cities',
  PRIMARY KEY (`id`),
  KEY `country_region` (`country_id`),
  CONSTRAINT `country_region_final` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5089 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci ROW_FORMAT=COMPACT;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `states`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `states` WRITE;
/*!40000 ALTER TABLE `states` DISABLE KEYS */;
/*!40000 ALTER TABLE `states` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `subscribers`
--

DROP TABLE IF EXISTS `subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscribers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `email_id` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subscribers_email_id_unique` (`email_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscribers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `subscribers` WRITE;
/*!40000 ALTER TABLE `subscribers` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscribers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `subscription_plans`
--

DROP TABLE IF EXISTS `subscription_plans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscription_plans` (
  `id` char(36) NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `currency` varchar(3) NOT NULL DEFAULT 'DOP',
  `stripe_price_id` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') NOT NULL DEFAULT 'active',
  `features` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`features`)),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subscription_plans_stripe_price_id_unique` (`stripe_price_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscription_plans`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `subscription_plans` WRITE;
/*!40000 ALTER TABLE `subscription_plans` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscription_plans` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `subscriptions` (
  `id` char(36) NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `subscription_plan_id` char(36) NOT NULL,
  `stripe_subscription_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'active',
  `starts_at` timestamp NULL DEFAULT NULL,
  `ends_at` timestamp NULL DEFAULT NULL,
  `canceled_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `subscriptions_stripe_subscription_id_unique` (`stripe_subscription_id`),
  KEY `subscriptions_user_id_index` (`user_id`),
  KEY `subscriptions_subscription_plan_id_index` (`subscription_plan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `support_ticket_statuses`
--

DROP TABLE IF EXISTS `support_ticket_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_ticket_statuses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `support_ticket_status` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_ticket_statuses`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `support_ticket_statuses` WRITE;
/*!40000 ALTER TABLE `support_ticket_statuses` DISABLE KEYS */;
INSERT INTO `support_ticket_statuses` VALUES
(1,'active','2022-06-25 03:52:18','2023-01-29 10:07:53');
/*!40000 ALTER TABLE `support_ticket_statuses` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `support_tickets`
--

DROP TABLE IF EXISTS `support_tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `support_tickets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `user_type` varchar(20) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `ticket_number` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `attachment` varchar(255) DEFAULT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '1-pending, 2-open, 3-closed',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `last_message` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `support_tickets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `support_tickets` WRITE;
/*!40000 ALTER TABLE `support_tickets` DISABLE KEYS */;
/*!40000 ALTER TABLE `support_tickets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `testimonial_sections`
--

DROP TABLE IF EXISTS `testimonial_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `testimonial_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `text` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `review_text` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testimonial_sections`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `testimonial_sections` WRITE;
/*!40000 ALTER TABLE `testimonial_sections` DISABLE KEYS */;
INSERT INTO `testimonial_sections` VALUES
(3,8,'What Our Clients Say about Us','Morbi volutpat luctus mauris id placerat. Aenean sit amet tincidunt quam. Aenean pretium euismod ligula, quis suscipit dui.','629f26d7b602d.jpg','12k Clients reviews','2022-06-07 04:22:15','2022-06-07 04:24:54'),
(4,9,'gdfsas','sdfa','629f2792b156e.jpg','sfdaf','2022-06-07 04:25:22','2022-06-07 04:25:22'),
(5,17,'ما يقوله عملائنا عنا','الأحرف. خمسة قرون من الزمن لم تقضي على هذا النص، بل انه حتى صار','63d8ad0181103.png','2k','2023-01-31 05:54:09','2023-01-31 05:54:09'),
(6,22,'ماذا يقول عملاؤنا عنا','وقبل وفنلندا اقتصادية كل, تسبب الأوربيين كلا كل. تطوير الساحة ا','64587a5803048.jpg','ألف مراجعات العملاء','2023-05-08 04:28:08','2023-05-08 04:29:14');
/*!40000 ALTER TABLE `testimonial_sections` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `testimonials`
--

DROP TABLE IF EXISTS `testimonials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `testimonials` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) unsigned NOT NULL,
  `image` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `occupation` varchar(255) NOT NULL,
  `rating` int(11) DEFAULT 0,
  `comment` text NOT NULL,
  `serial_number` int(10) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `testimonials`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `testimonials` WRITE;
/*!40000 ALTER TABLE `testimonials` DISABLE KEYS */;
INSERT INTO `testimonials` VALUES
(6,8,'6345065d82969.jpg','Jane Doe','Chief marketing officer',5,'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not just those that pay us',1,'2021-10-11 03:21:50','2023-05-08 04:41:31'),
(9,8,'63450650b0f0a.jpg','Jef Hardy','Chief executive officer (CEO)',4,'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not  justfdfdhghdd ghdfghdfdg',2,'2021-12-15 03:38:04','2023-05-08 04:41:20'),
(10,8,'63450657af7b1.jpg','Matt Hardy','Manager',5,'Our service is free to users because vendors pay us when they receive web traffic. We list all vendors - not  just those that pay us',3,'2021-12-15 03:40:37','2023-05-08 04:41:04'),
(15,8,'64587ddb29fdc.jpg','Patty O’Furniture','Chief financial officer',4,'While lorem ipsum\'s still resembles classical Latin, it actually has no meaning whatsoever. As Cicero\'s text doesn',4,'2023-05-08 04:43:07','2023-05-08 04:43:59');
/*!40000 ALTER TABLE `testimonials` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ticket_contents`
--

DROP TABLE IF EXISTS `ticket_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) DEFAULT NULL,
  `ticket_id` bigint(20) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=123 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ticket_contents` WRITE;
/*!40000 ALTER TABLE `ticket_contents` DISABLE KEYS */;
INSERT INTO `ticket_contents` VALUES
(1,8,155,'Toyota Starlet',NULL,'2023-05-13 11:17:48','2023-05-13 11:17:48'),
(2,22,155,'Toyota Starlet',NULL,'2023-05-13 11:17:48','2023-05-13 11:17:48'),
(3,8,154,'fdsaf',NULL,'2023-05-13 11:20:35','2023-05-13 11:20:35'),
(4,22,154,'fdsaf',NULL,'2023-05-13 11:20:35','2023-05-13 11:20:35'),
(5,8,113,'Early bird discount ticket(fixed)',NULL,'2023-05-14 04:18:02','2023-05-14 04:18:02'),
(6,22,113,'تذكرة خصم مبكرة (ثابتة)',NULL,'2023-05-14 04:18:02','2023-05-14 04:18:02'),
(7,8,156,'Variation Wise Tickets',NULL,'2023-05-14 04:35:53','2023-05-14 04:35:53'),
(8,22,156,'تذاكر التغيير الحكيم',NULL,'2023-05-14 04:35:53','2023-05-14 04:35:53'),
(9,8,157,'Normal Ticket',NULL,'2023-05-14 04:50:48','2023-05-14 04:50:48'),
(10,22,157,'تذكرة عادية',NULL,'2023-05-14 04:50:48','2023-05-14 04:50:48'),
(11,8,158,'Free Ticket',NULL,'2023-05-14 05:18:02','2023-05-14 05:18:02'),
(12,22,158,'بطاقة مجانية',NULL,'2023-05-14 05:18:02','2023-05-14 05:18:02'),
(13,8,159,'Limited ticket',NULL,'2023-05-14 05:24:51','2023-05-14 05:24:51'),
(14,22,159,'تذكرة محدودة',NULL,'2023-05-14 05:24:51','2023-05-14 05:24:51'),
(15,8,160,'Normal Ticket (fixed discount)',NULL,'2023-05-14 05:28:23','2023-05-14 05:28:23'),
(16,22,160,'تذكرة عادية (خصم ثابت)',NULL,'2023-05-14 05:28:23','2023-05-14 05:28:23'),
(17,8,161,'Normal Ticket(percentage discount)',NULL,'2023-05-14 05:29:29','2023-05-14 05:29:29'),
(18,22,161,'تذكرة عادية (خصم بنسبة مئوية)',NULL,'2023-05-14 05:29:29','2023-05-14 05:29:29'),
(25,8,166,'Free Ticket',NULL,'2023-05-14 09:22:52','2023-05-14 09:22:52'),
(26,22,166,'بطاقة مجانية',NULL,'2023-05-14 09:22:52','2023-05-14 09:22:52'),
(27,8,167,'Normal Ticket',NULL,'2023-05-14 09:23:26','2023-05-14 09:23:26'),
(28,22,167,'تذكرة عادية',NULL,'2023-05-14 09:23:26','2023-05-14 09:23:26'),
(29,8,168,'Variation Wise',NULL,'2023-05-14 09:24:29','2023-05-14 09:24:29'),
(30,22,168,'الاختلاف الحكيم',NULL,'2023-05-14 09:24:29','2023-05-14 09:24:29'),
(31,8,169,'Normal Discount',NULL,'2023-05-14 09:25:20','2023-05-14 09:25:20'),
(32,22,169,'خصم عادي',NULL,'2023-05-14 09:25:20','2023-05-14 09:25:20'),
(33,8,170,'Variation Discount',NULL,'2023-05-14 09:26:25','2023-05-14 09:26:25'),
(34,22,170,'خصم التغيير',NULL,'2023-05-14 09:26:25','2023-05-14 09:26:25'),
(35,8,175,'Test Ticket','Test Ticket description','2023-11-18 00:20:10','2023-11-18 00:20:10'),
(36,22,175,'Test Ticket','Test Ticket description','2023-11-18 00:20:10','2023-11-18 00:20:10'),
(37,8,176,'Without Variation test ticket','Without Variation test ticket description','2023-11-18 00:21:38','2023-11-18 00:21:38'),
(38,22,176,'Without Variation test ticket','Without Variation test ticket description','2023-11-18 00:21:38','2023-11-18 00:21:38'),
(39,8,177,'Free ticket','free ticket description','2023-11-18 00:26:42','2023-11-18 00:26:42'),
(40,22,177,'Free ticket','free ticket description','2023-11-18 00:26:42','2023-11-18 00:26:42'),
(41,8,178,'Without varitaion ticket','Without variation ticket description','2023-11-18 00:28:56','2023-11-18 00:28:56'),
(42,22,178,'Without varitaion ticket','Without variation ticket description','2023-11-18 00:28:56','2023-11-18 00:28:56'),
(43,8,179,'Variation wise','Variation wise description','2023-11-18 00:47:32','2023-11-18 00:47:32'),
(44,22,179,'Variation wise','Variation wise description','2023-11-18 00:47:32','2023-11-18 00:47:32'),
(45,8,180,'sdafadf','asdfdasfdaf','2023-11-18 01:03:31','2023-11-18 01:03:31'),
(46,22,180,'sdafadf','asdfdasfdaf','2023-11-18 01:03:31','2023-11-18 01:03:31'),
(59,8,188,'Sydnee Neal','Laboris voluptatem','2025-10-21 01:38:19','2025-10-21 01:38:19'),
(60,22,188,'العيش عند مدخل لا شيء على الإطلاق.','11','2025-10-21 01:38:19','2025-10-21 01:38:19'),
(61,8,189,'Evergreen Hospital','rr','2025-10-21 03:09:33','2025-10-21 03:09:33'),
(62,22,189,'rr','rrrrrr','2025-10-21 03:09:33','2025-10-21 03:09:33'),
(63,8,190,'I will create any kind of graphic design with idea','11','2025-10-21 03:11:23','2025-10-21 03:11:23'),
(64,22,190,'I will create any kind of graphic design with idea','11','2025-10-21 03:11:23','2025-10-21 03:11:23'),
(65,8,191,'Dana Faulkner','Eaque ea nostrum eu','2025-10-21 05:19:37','2025-10-21 05:25:27'),
(66,22,191,'Dana Faulkner','Evergreen Hospital','2025-10-21 05:19:37','2025-10-21 05:25:27'),
(69,8,193,'I will create any kind of graphic design with idea','1223','2025-11-02 06:04:01','2025-11-02 06:04:01'),
(70,22,193,'العيش عند مدخل لا شيء على الإطلاق.','6333333333','2025-11-02 06:04:01','2025-11-02 06:04:01'),
(71,8,194,'Tech Innovators Conference 2025','Join us at the Tech Innovators Conference 2025, where visionaries, developers, and industry leaders come together to shape the future of technology. This year’s theme, “Bridging Ideas with Innovation,” focuses on emerging trends in AI, Web Development, Cloud Computing, and Cybersecurity.','2025-11-05 00:34:23','2025-11-05 00:34:23'),
(72,22,194,'Tech Innovators Conference 2025','Join us at the Tech Innovators Conference 2025, where visionaries, developers, and industry leaders come together to shape the future of technology. This year’s theme, “Bridging Ideas with Innovation,” focuses on emerging trends in AI, Web Development, Cloud Computing, and Cybersecurity.','2025-11-05 00:34:23','2025-11-05 00:34:23'),
(73,8,195,'All Tickets',NULL,'2025-11-06 01:17:05','2025-11-06 01:17:05'),
(74,22,195,'جميع التذاكر',NULL,'2025-11-06 01:17:05','2025-11-06 01:17:05'),
(75,8,196,'Normal Ticket',NULL,'2025-11-06 01:17:46','2025-11-06 01:17:46'),
(76,22,196,'تذكرة عادية',NULL,'2025-11-06 01:17:46','2025-11-06 01:17:46'),
(77,8,197,'Free Ticket (limited)',NULL,'2025-11-06 01:18:13','2025-11-06 01:18:13'),
(78,22,197,'بطاقة مجانية',NULL,'2025-11-06 01:18:13','2025-11-06 01:18:13'),
(79,8,198,'First Stage',NULL,'2025-11-06 03:52:33','2025-11-06 03:52:33'),
(80,22,198,'المرحلة الأولى',NULL,'2025-11-06 03:52:33','2025-11-06 03:52:33'),
(83,8,200,'Seat Ticket',NULL,'2025-11-08 00:52:38','2025-11-08 07:49:29'),
(84,22,200,'تذكرة فيلم',NULL,'2025-11-08 00:52:38','2025-11-08 00:52:38'),
(87,8,202,'Seat Ticket',NULL,'2025-11-08 06:45:39','2025-11-08 07:48:25'),
(88,22,202,'تذكرة مجانية',NULL,'2025-11-08 06:45:39','2025-11-08 06:45:39'),
(89,8,203,'Stranding Ticket',NULL,'2025-11-08 07:47:59','2025-11-08 07:47:59'),
(90,22,203,'تذكرة جنوح',NULL,'2025-11-08 07:47:59','2025-11-08 07:47:59'),
(91,8,204,'Standing Ticket',NULL,'2025-11-08 07:49:49','2025-11-08 07:49:49'),
(92,22,204,'تذكرة جنوح',NULL,'2025-11-08 07:49:49','2025-11-08 07:49:49'),
(93,8,205,'Standing Ticket',NULL,'2025-11-08 07:53:38','2025-11-08 07:53:38'),
(94,22,205,'تذكرة جنوح',NULL,'2025-11-08 07:53:38','2025-11-08 07:53:38'),
(101,8,209,'rr',NULL,'2025-11-10 06:15:55','2025-11-10 06:15:55'),
(102,22,209,'rr',NULL,'2025-11-10 06:15:55','2025-11-10 06:15:55'),
(103,8,210,'General',NULL,'2025-12-15 16:32:37','2025-12-15 16:32:37'),
(105,8,212,'General',NULL,'2025-12-26 09:07:27','2025-12-26 09:07:27'),
(109,8,216,'Guestlist',NULL,'2025-12-31 14:05:04','2025-12-31 14:05:04'),
(110,8,217,'Guestlist - Santana',NULL,'2025-12-31 15:04:34','2025-12-31 15:04:34'),
(111,8,218,'Guestlist - Sultan',NULL,'2025-12-31 15:23:03','2025-12-31 15:23:03'),
(117,8,224,'GUESTLIST',NULL,'2026-01-03 16:59:22','2026-01-03 16:59:22'),
(118,8,225,'Early Hidden',NULL,'2026-02-07 23:52:52','2026-02-07 23:52:52'),
(119,8,226,'Hidden - Phase 1',NULL,'2026-02-08 00:00:02','2026-02-08 00:00:02'),
(120,8,227,'Hidden - Phase 2',NULL,'2026-02-08 00:00:29','2026-02-08 00:00:29'),
(121,8,228,'Hidden - Phase 3',NULL,'2026-02-08 00:01:37','2026-02-08 00:01:37'),
(122,8,229,'General',NULL,'2026-02-12 01:03:06','2026-02-12 01:03:06');
/*!40000 ALTER TABLE `ticket_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `ticket_transfers`
--

DROP TABLE IF EXISTS `ticket_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_transfers` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `booking_id` bigint(20) unsigned NOT NULL,
  `from_customer_id` bigint(20) unsigned NOT NULL,
  `to_customer_id` bigint(20) unsigned NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ticket_transfers_booking_id_foreign` (`booking_id`),
  KEY `ticket_transfers_from_customer_id_foreign` (`from_customer_id`),
  KEY `ticket_transfers_to_customer_id_foreign` (`to_customer_id`),
  CONSTRAINT `ticket_transfers_booking_id_foreign` FOREIGN KEY (`booking_id`) REFERENCES `bookings` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_transfers_from_customer_id_foreign` FOREIGN KEY (`from_customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_transfers_to_customer_id_foreign` FOREIGN KEY (`to_customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_transfers`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ticket_transfers` WRITE;
/*!40000 ALTER TABLE `ticket_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `ticket_transfers` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `event_id` int(11) NOT NULL,
  `event_type` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `ticket_available_type` varchar(255) DEFAULT NULL,
  `ticket_available` int(11) DEFAULT NULL,
  `max_ticket_buy_type` varchar(255) DEFAULT NULL,
  `max_buy_ticket` int(11) DEFAULT NULL,
  `description` longtext DEFAULT NULL,
  `pricing_type` varchar(255) DEFAULT NULL,
  `price` varchar(255) DEFAULT NULL,
  `f_price` float DEFAULT NULL,
  `early_bird_discount` varchar(255) NOT NULL DEFAULT 'disable',
  `early_bird_discount_amount` varchar(255) DEFAULT NULL,
  `early_bird_discount_type` varchar(255) DEFAULT NULL,
  `early_bird_discount_date` varchar(255) DEFAULT NULL,
  `early_bird_discount_time` varchar(255) DEFAULT NULL,
  `variations` longtext DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `normal_ticket_slot_enable` tinyint(4) NOT NULL DEFAULT 0,
  `normal_ticket_slot_unique_id` int(11) DEFAULT NULL,
  `free_tickete_slot_enable` tinyint(4) NOT NULL DEFAULT 0,
  `free_tickete_slot_unique_id` int(11) DEFAULT NULL,
  `slot_seat_min_price` decimal(8,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=230 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES
(210,134,'venue',NULL,'limited',73,'limited',4,NULL,'normal','400',400,'disable',NULL,'fixed',NULL,NULL,NULL,'2025-12-15 16:32:37','2025-12-21 04:57:39',0,187266,0,256921,0.00),
(212,135,'venue',NULL,'limited',5,'unlimited',NULL,NULL,'normal','1000',1000,'enable','300','fixed','2025-12-31','22:00',NULL,'2025-12-26 09:07:27','2026-01-01 07:31:41',0,94695,0,595673,0.00),
(224,136,'venue',NULL,'limited',20,'limited',2,NULL,'free','0',NULL,'disable',NULL,'fixed',NULL,NULL,NULL,'2026-01-03 16:59:22','2026-01-04 04:44:11',0,826664,0,332638,0.00),
(225,139,'venue',NULL,'limited',46,'limited',5,NULL,'normal','500',500,'disable','50','percentage','2026-02-14','01:00',NULL,'2026-02-07 23:52:52','2026-02-19 02:04:21',0,30731,0,861493,0.00),
(226,139,'venue',NULL,'limited',50,'limited',5,NULL,'normal','650',650,'disable',NULL,'fixed',NULL,NULL,NULL,'2026-02-08 00:00:02','2026-02-08 00:07:16',0,554101,0,407416,0.00),
(227,139,'venue',NULL,'limited',50,'limited',5,NULL,'normal','800',800,'disable',NULL,'fixed',NULL,NULL,NULL,'2026-02-08 00:00:29','2026-02-08 00:00:59',0,360348,0,729115,0.00),
(228,139,'venue',NULL,'limited',50,'limited',5,NULL,'normal','1000',1000,'disable',NULL,'fixed',NULL,NULL,NULL,'2026-02-08 00:01:37','2026-02-08 00:07:16',0,584129,0,240235,0.00),
(229,140,'venue',NULL,'unlimited',-2,'unlimited',NULL,NULL,'normal','300',300,'disable',NULL,'fixed',NULL,NULL,NULL,'2026-02-12 01:03:06','2026-02-19 03:23:55',0,965086,0,349697,0.00);
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `timezones`
--

DROP TABLE IF EXISTS `timezones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `timezones` (
  `country_code` char(3) NOT NULL,
  `timezone` varchar(125) NOT NULL DEFAULT '',
  `gmt_offset` float(10,2) DEFAULT NULL,
  `dst_offset` float(10,2) DEFAULT NULL,
  `raw_offset` float(10,2) DEFAULT NULL,
  PRIMARY KEY (`country_code`,`timezone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `timezones`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `timezones` WRITE;
/*!40000 ALTER TABLE `timezones` DISABLE KEYS */;
INSERT INTO `timezones` VALUES
('AD','Europe/Andorra',1.00,2.00,1.00),
('AE','Asia/Dubai',4.00,4.00,4.00),
('AF','Asia/Kabul',4.50,4.50,4.50),
('AG','America/Antigua',-4.00,-4.00,-4.00),
('AI','America/Anguilla',-4.00,-4.00,-4.00),
('AL','Europe/Tirane',1.00,2.00,1.00),
('AM','Asia/Yerevan',4.00,4.00,4.00),
('AO','Africa/Luanda',1.00,1.00,1.00),
('AQ','Antarctica/Casey',8.00,8.00,8.00),
('AQ','Antarctica/Davis',7.00,7.00,7.00),
('AQ','Antarctica/DumontDUrville',10.00,10.00,10.00),
('AQ','Antarctica/Mawson',5.00,5.00,5.00),
('AQ','Antarctica/McMurdo',13.00,12.00,12.00),
('AQ','Antarctica/Palmer',-3.00,-4.00,-4.00),
('AQ','Antarctica/Rothera',-3.00,-3.00,-3.00),
('AQ','Antarctica/South_Pole',13.00,12.00,12.00),
('AQ','Antarctica/Syowa',3.00,3.00,3.00),
('AQ','Antarctica/Vostok',6.00,6.00,6.00),
('AR','America/Argentina/Buenos_Aires',-3.00,-3.00,-3.00),
('AR','America/Argentina/Catamarca',-3.00,-3.00,-3.00),
('AR','America/Argentina/Cordoba',-3.00,-3.00,-3.00),
('AR','America/Argentina/Jujuy',-3.00,-3.00,-3.00),
('AR','America/Argentina/La_Rioja',-3.00,-3.00,-3.00),
('AR','America/Argentina/Mendoza',-3.00,-3.00,-3.00),
('AR','America/Argentina/Rio_Gallegos',-3.00,-3.00,-3.00),
('AR','America/Argentina/Salta',-3.00,-3.00,-3.00),
('AR','America/Argentina/San_Juan',-3.00,-3.00,-3.00),
('AR','America/Argentina/San_Luis',-3.00,-3.00,-3.00),
('AR','America/Argentina/Tucuman',-3.00,-3.00,-3.00),
('AR','America/Argentina/Ushuaia',-3.00,-3.00,-3.00),
('AS','Pacific/Pago_Pago',-11.00,-11.00,-11.00),
('AT','Europe/Vienna',1.00,2.00,1.00),
('AU','Antarctica/Macquarie',11.00,11.00,11.00),
('AU','Australia/Adelaide',10.50,9.50,9.50),
('AU','Australia/Brisbane',10.00,10.00,10.00),
('AU','Australia/Broken_Hill',10.50,9.50,9.50),
('AU','Australia/Currie',11.00,10.00,10.00),
('AU','Australia/Darwin',9.50,9.50,9.50),
('AU','Australia/Eucla',8.75,8.75,8.75),
('AU','Australia/Hobart',11.00,10.00,10.00),
('AU','Australia/Lindeman',10.00,10.00,10.00),
('AU','Australia/Lord_Howe',11.00,10.50,10.50),
('AU','Australia/Melbourne',11.00,10.00,10.00),
('AU','Australia/Perth',8.00,8.00,8.00),
('AU','Australia/Sydney',11.00,10.00,10.00),
('AW','America/Aruba',-4.00,-4.00,-4.00),
('AX','Europe/Mariehamn',2.00,3.00,2.00),
('AZ','Asia/Baku',4.00,5.00,4.00),
('BA','Europe/Sarajevo',1.00,2.00,1.00),
('BB','America/Barbados',-4.00,-4.00,-4.00),
('BD','Asia/Dhaka',6.00,6.00,6.00),
('BE','Europe/Brussels',1.00,2.00,1.00),
('BF','Africa/Ouagadougou',0.00,0.00,0.00),
('BG','Europe/Sofia',2.00,3.00,2.00),
('BH','Asia/Bahrain',3.00,3.00,3.00),
('BI','Africa/Bujumbura',2.00,2.00,2.00),
('BJ','Africa/Porto-Novo',1.00,1.00,1.00),
('BL','America/St_Barthelemy',-4.00,-4.00,-4.00),
('BM','Atlantic/Bermuda',-4.00,-3.00,-4.00),
('BN','Asia/Brunei',8.00,8.00,8.00),
('BO','America/La_Paz',-4.00,-4.00,-4.00),
('BQ','America/Kralendijk',-4.00,-4.00,-4.00),
('BR','America/Araguaina',-3.00,-3.00,-3.00),
('BR','America/Bahia',-3.00,-3.00,-3.00),
('BR','America/Belem',-3.00,-3.00,-3.00),
('BR','America/Boa_Vista',-4.00,-4.00,-4.00),
('BR','America/Campo_Grande',-3.00,-4.00,-4.00),
('BR','America/Cuiaba',-3.00,-4.00,-4.00),
('BR','America/Eirunepe',-5.00,-5.00,-5.00),
('BR','America/Fortaleza',-3.00,-3.00,-3.00),
('BR','America/Maceio',-3.00,-3.00,-3.00),
('BR','America/Manaus',-4.00,-4.00,-4.00),
('BR','America/Noronha',-2.00,-2.00,-2.00),
('BR','America/Porto_Velho',-4.00,-4.00,-4.00),
('BR','America/Recife',-3.00,-3.00,-3.00),
('BR','America/Rio_Branco',-5.00,-5.00,-5.00),
('BR','America/Santarem',-3.00,-3.00,-3.00),
('BR','America/Sao_Paulo',-2.00,-3.00,-3.00),
('BS','America/Nassau',-5.00,-4.00,-5.00),
('BT','Asia/Thimphu',6.00,6.00,6.00),
('BW','Africa/Gaborone',2.00,2.00,2.00),
('BY','Europe/Minsk',3.00,3.00,3.00),
('BZ','America/Belize',-6.00,-6.00,-6.00),
('CA','America/Atikokan',-5.00,-5.00,-5.00),
('CA','America/Blanc-Sablon',-4.00,-4.00,-4.00),
('CA','America/Cambridge_Bay',-7.00,-6.00,-7.00),
('CA','America/Creston',-7.00,-7.00,-7.00),
('CA','America/Dawson',-8.00,-7.00,-8.00),
('CA','America/Dawson_Creek',-7.00,-7.00,-7.00),
('CA','America/Edmonton',-7.00,-6.00,-7.00),
('CA','America/Glace_Bay',-4.00,-3.00,-4.00),
('CA','America/Goose_Bay',-4.00,-3.00,-4.00),
('CA','America/Halifax',-4.00,-3.00,-4.00),
('CA','America/Inuvik',-7.00,-6.00,-7.00),
('CA','America/Iqaluit',-5.00,-4.00,-5.00),
('CA','America/Moncton',-4.00,-3.00,-4.00),
('CA','America/Montreal',-5.00,-4.00,-5.00),
('CA','America/Nipigon',-5.00,-4.00,-5.00),
('CA','America/Pangnirtung',-5.00,-4.00,-5.00),
('CA','America/Rainy_River',-6.00,-5.00,-6.00),
('CA','America/Rankin_Inlet',-6.00,-5.00,-6.00),
('CA','America/Regina',-6.00,-6.00,-6.00),
('CA','America/Resolute',-6.00,-5.00,-6.00),
('CA','America/St_Johns',-3.50,-2.50,-3.50),
('CA','America/Swift_Current',-6.00,-6.00,-6.00),
('CA','America/Thunder_Bay',-5.00,-4.00,-5.00),
('CA','America/Toronto',-5.00,-4.00,-5.00),
('CA','America/Vancouver',-8.00,-7.00,-8.00),
('CA','America/Whitehorse',-8.00,-7.00,-8.00),
('CA','America/Winnipeg',-6.00,-5.00,-6.00),
('CA','America/Yellowknife',-7.00,-6.00,-7.00),
('CC','Indian/Cocos',6.50,6.50,6.50),
('CD','Africa/Kinshasa',1.00,1.00,1.00),
('CD','Africa/Lubumbashi',2.00,2.00,2.00),
('CF','Africa/Bangui',1.00,1.00,1.00),
('CG','Africa/Brazzaville',1.00,1.00,1.00),
('CH','Europe/Zurich',1.00,2.00,1.00),
('CI','Africa/Abidjan',0.00,0.00,0.00),
('CK','Pacific/Rarotonga',-10.00,-10.00,-10.00),
('CL','America/Santiago',-3.00,-4.00,-4.00),
('CL','Pacific/Easter',-5.00,-6.00,-6.00),
('CM','Africa/Douala',1.00,1.00,1.00),
('CN','Asia/Chongqing',8.00,8.00,8.00),
('CN','Asia/Harbin',8.00,8.00,8.00),
('CN','Asia/Kashgar',8.00,8.00,8.00),
('CN','Asia/Shanghai',8.00,8.00,8.00),
('CN','Asia/Urumqi',8.00,8.00,8.00),
('CO','America/Bogota',-5.00,-5.00,-5.00),
('CR','America/Costa_Rica',-6.00,-6.00,-6.00),
('CU','America/Havana',-5.00,-4.00,-5.00),
('CV','Atlantic/Cape_Verde',-1.00,-1.00,-1.00),
('CW','America/Curacao',-4.00,-4.00,-4.00),
('CX','Indian/Christmas',7.00,7.00,7.00),
('CY','Asia/Nicosia',2.00,3.00,2.00),
('CZ','Europe/Prague',1.00,2.00,1.00),
('DE','Europe/Berlin',1.00,2.00,1.00),
('DE','Europe/Busingen',1.00,2.00,1.00),
('DJ','Africa/Djibouti',3.00,3.00,3.00),
('DK','Europe/Copenhagen',1.00,2.00,1.00),
('DM','America/Dominica',-4.00,-4.00,-4.00),
('DO','America/Santo_Domingo',-4.00,-4.00,-4.00),
('DZ','Africa/Algiers',1.00,1.00,1.00),
('EC','America/Guayaquil',-5.00,-5.00,-5.00),
('EC','Pacific/Galapagos',-6.00,-6.00,-6.00),
('EE','Europe/Tallinn',2.00,3.00,2.00),
('EG','Africa/Cairo',2.00,2.00,2.00),
('EH','Africa/El_Aaiun',0.00,0.00,0.00),
('ER','Africa/Asmara',3.00,3.00,3.00),
('ES','Africa/Ceuta',1.00,2.00,1.00),
('ES','Atlantic/Canary',0.00,1.00,0.00),
('ES','Europe/Madrid',1.00,2.00,1.00),
('ET','Africa/Addis_Ababa',3.00,3.00,3.00),
('FI','Europe/Helsinki',2.00,3.00,2.00),
('FJ','Pacific/Fiji',13.00,12.00,12.00),
('FK','Atlantic/Stanley',-3.00,-3.00,-3.00),
('FM','Pacific/Chuuk',10.00,10.00,10.00),
('FM','Pacific/Kosrae',11.00,11.00,11.00),
('FM','Pacific/Pohnpei',11.00,11.00,11.00),
('FO','Atlantic/Faroe',0.00,1.00,0.00),
('FR','Europe/Paris',1.00,2.00,1.00),
('GA','Africa/Libreville',1.00,1.00,1.00),
('GB','Europe/London',0.00,1.00,0.00),
('GD','America/Grenada',-4.00,-4.00,-4.00),
('GE','Asia/Tbilisi',4.00,4.00,4.00),
('GF','America/Cayenne',-3.00,-3.00,-3.00),
('GG','Europe/Guernsey',0.00,1.00,0.00),
('GH','Africa/Accra',0.00,0.00,0.00),
('GI','Europe/Gibraltar',1.00,2.00,1.00),
('GL','America/Danmarkshavn',0.00,0.00,0.00),
('GL','America/Godthab',-3.00,-2.00,-3.00),
('GL','America/Scoresbysund',-1.00,0.00,-1.00),
('GL','America/Thule',-4.00,-3.00,-4.00),
('GM','Africa/Banjul',0.00,0.00,0.00),
('GN','Africa/Conakry',0.00,0.00,0.00),
('GP','America/Guadeloupe',-4.00,-4.00,-4.00),
('GQ','Africa/Malabo',1.00,1.00,1.00),
('GR','Europe/Athens',2.00,3.00,2.00),
('GS','Atlantic/South_Georgia',-2.00,-2.00,-2.00),
('GT','America/Guatemala',-6.00,-6.00,-6.00),
('GU','Pacific/Guam',10.00,10.00,10.00),
('GW','Africa/Bissau',0.00,0.00,0.00),
('GY','America/Guyana',-4.00,-4.00,-4.00),
('HK','Asia/Hong_Kong',8.00,8.00,8.00),
('HN','America/Tegucigalpa',-6.00,-6.00,-6.00),
('HR','Europe/Zagreb',1.00,2.00,1.00),
('HT','America/Port-au-Prince',-5.00,-4.00,-5.00),
('HU','Europe/Budapest',1.00,2.00,1.00),
('ID','Asia/Jakarta',7.00,7.00,7.00),
('ID','Asia/Jayapura',9.00,9.00,9.00),
('ID','Asia/Makassar',8.00,8.00,8.00),
('ID','Asia/Pontianak',7.00,7.00,7.00),
('IE','Europe/Dublin',0.00,1.00,0.00),
('IL','Asia/Jerusalem',2.00,3.00,2.00),
('IM','Europe/Isle_of_Man',0.00,1.00,0.00),
('IN','Asia/Kolkata',5.50,5.50,5.50),
('IO','Indian/Chagos',6.00,6.00,6.00),
('IQ','Asia/Baghdad',3.00,3.00,3.00),
('IR','Asia/Tehran',3.50,4.50,3.50),
('IS','Atlantic/Reykjavik',0.00,0.00,0.00),
('IT','Europe/Rome',1.00,2.00,1.00),
('JE','Europe/Jersey',0.00,1.00,0.00),
('JM','America/Jamaica',-5.00,-5.00,-5.00),
('JO','Asia/Amman',2.00,3.00,2.00),
('JP','Asia/Tokyo',9.00,9.00,9.00),
('KE','Africa/Nairobi',3.00,3.00,3.00),
('KG','Asia/Bishkek',6.00,6.00,6.00),
('KH','Asia/Phnom_Penh',7.00,7.00,7.00),
('KI','Pacific/Enderbury',13.00,13.00,13.00),
('KI','Pacific/Kiritimati',14.00,14.00,14.00),
('KI','Pacific/Tarawa',12.00,12.00,12.00),
('KM','Indian/Comoro',3.00,3.00,3.00),
('KN','America/St_Kitts',-4.00,-4.00,-4.00),
('KP','Asia/Pyongyang',9.00,9.00,9.00),
('KR','Asia/Seoul',9.00,9.00,9.00),
('KW','Asia/Kuwait',3.00,3.00,3.00),
('KY','America/Cayman',-5.00,-5.00,-5.00),
('KZ','Asia/Almaty',6.00,6.00,6.00),
('KZ','Asia/Aqtau',5.00,5.00,5.00),
('KZ','Asia/Aqtobe',5.00,5.00,5.00),
('KZ','Asia/Oral',5.00,5.00,5.00),
('KZ','Asia/Qyzylorda',6.00,6.00,6.00),
('LA','Asia/Vientiane',7.00,7.00,7.00),
('LB','Asia/Beirut',2.00,3.00,2.00),
('LC','America/St_Lucia',-4.00,-4.00,-4.00),
('LI','Europe/Vaduz',1.00,2.00,1.00),
('LK','Asia/Colombo',5.50,5.50,5.50),
('LR','Africa/Monrovia',0.00,0.00,0.00),
('LS','Africa/Maseru',2.00,2.00,2.00),
('LT','Europe/Vilnius',2.00,3.00,2.00),
('LU','Europe/Luxembourg',1.00,2.00,1.00),
('LV','Europe/Riga',2.00,3.00,2.00),
('LY','Africa/Tripoli',2.00,2.00,2.00),
('MA','Africa/Casablanca',0.00,0.00,0.00),
('MC','Europe/Monaco',1.00,2.00,1.00),
('MD','Europe/Chisinau',2.00,3.00,2.00),
('ME','Europe/Podgorica',1.00,2.00,1.00),
('MF','America/Marigot',-4.00,-4.00,-4.00),
('MG','Indian/Antananarivo',3.00,3.00,3.00),
('MH','Pacific/Kwajalein',12.00,12.00,12.00),
('MH','Pacific/Majuro',12.00,12.00,12.00),
('MK','Europe/Skopje',1.00,2.00,1.00),
('ML','Africa/Bamako',0.00,0.00,0.00),
('MM','Asia/Rangoon',6.50,6.50,6.50),
('MN','Asia/Choibalsan',8.00,8.00,8.00),
('MN','Asia/Hovd',7.00,7.00,7.00),
('MN','Asia/Ulaanbaatar',8.00,8.00,8.00),
('MO','Asia/Macau',8.00,8.00,8.00),
('MP','Pacific/Saipan',10.00,10.00,10.00),
('MQ','America/Martinique',-4.00,-4.00,-4.00),
('MR','Africa/Nouakchott',0.00,0.00,0.00),
('MS','America/Montserrat',-4.00,-4.00,-4.00),
('MT','Europe/Malta',1.00,2.00,1.00),
('MU','Indian/Mauritius',4.00,4.00,4.00),
('MV','Indian/Maldives',5.00,5.00,5.00),
('MW','Africa/Blantyre',2.00,2.00,2.00),
('MX','America/Bahia_Banderas',-6.00,-5.00,-6.00),
('MX','America/Cancun',-6.00,-5.00,-6.00),
('MX','America/Chihuahua',-7.00,-6.00,-7.00),
('MX','America/Hermosillo',-7.00,-7.00,-7.00),
('MX','America/Matamoros',-6.00,-5.00,-6.00),
('MX','America/Mazatlan',-7.00,-6.00,-7.00),
('MX','America/Merida',-6.00,-5.00,-6.00),
('MX','America/Mexico_City',-6.00,-5.00,-6.00),
('MX','America/Monterrey',-6.00,-5.00,-6.00),
('MX','America/Ojinaga',-7.00,-6.00,-7.00),
('MX','America/Santa_Isabel',-8.00,-7.00,-8.00),
('MX','America/Tijuana',-8.00,-7.00,-8.00),
('MY','Asia/Kuala_Lumpur',8.00,8.00,8.00),
('MY','Asia/Kuching',8.00,8.00,8.00),
('MZ','Africa/Maputo',2.00,2.00,2.00),
('NA','Africa/Windhoek',2.00,1.00,1.00),
('NC','Pacific/Noumea',11.00,11.00,11.00),
('NE','Africa/Niamey',1.00,1.00,1.00),
('NF','Pacific/Norfolk',11.50,11.50,11.50),
('NG','Africa/Lagos',1.00,1.00,1.00),
('NI','America/Managua',-6.00,-6.00,-6.00),
('NL','Europe/Amsterdam',1.00,2.00,1.00),
('NO','Europe/Oslo',1.00,2.00,1.00),
('NP','Asia/Kathmandu',5.75,5.75,5.75),
('NR','Pacific/Nauru',12.00,12.00,12.00),
('NU','Pacific/Niue',-11.00,-11.00,-11.00),
('NZ','Pacific/Auckland',13.00,12.00,12.00),
('NZ','Pacific/Chatham',13.75,12.75,12.75),
('OM','Asia/Muscat',4.00,4.00,4.00),
('PA','America/Panama',-5.00,-5.00,-5.00),
('PE','America/Lima',-5.00,-5.00,-5.00),
('PF','Pacific/Gambier',-9.00,-9.00,-9.00),
('PF','Pacific/Marquesas',-9.50,-9.50,-9.50),
('PF','Pacific/Tahiti',-10.00,-10.00,-10.00),
('PG','Pacific/Port_Moresby',10.00,10.00,10.00),
('PH','Asia/Manila',8.00,8.00,8.00),
('PK','Asia/Karachi',5.00,5.00,5.00),
('PL','Europe/Warsaw',1.00,2.00,1.00),
('PM','America/Miquelon',-3.00,-2.00,-3.00),
('PN','Pacific/Pitcairn',-8.00,-8.00,-8.00),
('PR','America/Puerto_Rico',-4.00,-4.00,-4.00),
('PS','Asia/Gaza',2.00,3.00,2.00),
('PS','Asia/Hebron',2.00,3.00,2.00),
('PT','Atlantic/Azores',-1.00,0.00,-1.00),
('PT','Atlantic/Madeira',0.00,1.00,0.00),
('PT','Europe/Lisbon',0.00,1.00,0.00),
('PW','Pacific/Palau',9.00,9.00,9.00),
('PY','America/Asuncion',-3.00,-4.00,-4.00),
('QA','Asia/Qatar',3.00,3.00,3.00),
('RE','Indian/Reunion',4.00,4.00,4.00),
('RO','Europe/Bucharest',2.00,3.00,2.00),
('RS','Europe/Belgrade',1.00,2.00,1.00),
('RU','Asia/Anadyr',12.00,12.00,12.00),
('RU','Asia/Irkutsk',9.00,9.00,9.00),
('RU','Asia/Kamchatka',12.00,12.00,12.00),
('RU','Asia/Khandyga',10.00,10.00,10.00),
('RU','Asia/Krasnoyarsk',8.00,8.00,8.00),
('RU','Asia/Magadan',12.00,12.00,12.00),
('RU','Asia/Novokuznetsk',7.00,7.00,7.00),
('RU','Asia/Novosibirsk',7.00,7.00,7.00),
('RU','Asia/Omsk',7.00,7.00,7.00),
('RU','Asia/Sakhalin',11.00,11.00,11.00),
('RU','Asia/Ust-Nera',11.00,11.00,11.00),
('RU','Asia/Vladivostok',11.00,11.00,11.00),
('RU','Asia/Yakutsk',10.00,10.00,10.00),
('RU','Asia/Yekaterinburg',6.00,6.00,6.00),
('RU','Europe/Kaliningrad',3.00,3.00,3.00),
('RU','Europe/Moscow',4.00,4.00,4.00),
('RU','Europe/Samara',4.00,4.00,4.00),
('RU','Europe/Volgograd',4.00,4.00,4.00),
('RW','Africa/Kigali',2.00,2.00,2.00),
('SA','Asia/Riyadh',3.00,3.00,3.00),
('SB','Pacific/Guadalcanal',11.00,11.00,11.00),
('SC','Indian/Mahe',4.00,4.00,4.00),
('SD','Africa/Khartoum',3.00,3.00,3.00),
('SE','Europe/Stockholm',1.00,2.00,1.00),
('SG','Asia/Singapore',8.00,8.00,8.00),
('SH','Atlantic/St_Helena',0.00,0.00,0.00),
('SI','Europe/Ljubljana',1.00,2.00,1.00),
('SJ','Arctic/Longyearbyen',1.00,2.00,1.00),
('SK','Europe/Bratislava',1.00,2.00,1.00),
('SL','Africa/Freetown',0.00,0.00,0.00),
('SM','Europe/San_Marino',1.00,2.00,1.00),
('SN','Africa/Dakar',0.00,0.00,0.00),
('SO','Africa/Mogadishu',3.00,3.00,3.00),
('SR','America/Paramaribo',-3.00,-3.00,-3.00),
('SS','Africa/Juba',3.00,3.00,3.00),
('ST','Africa/Sao_Tome',0.00,0.00,0.00),
('SV','America/El_Salvador',-6.00,-6.00,-6.00),
('SX','America/Lower_Princes',-4.00,-4.00,-4.00),
('SY','Asia/Damascus',2.00,3.00,2.00),
('SZ','Africa/Mbabane',2.00,2.00,2.00),
('TC','America/Grand_Turk',-5.00,-4.00,-5.00),
('TD','Africa/Ndjamena',1.00,1.00,1.00),
('TF','Indian/Kerguelen',5.00,5.00,5.00),
('TG','Africa/Lome',0.00,0.00,0.00),
('TH','Asia/Bangkok',7.00,7.00,7.00),
('TJ','Asia/Dushanbe',5.00,5.00,5.00),
('TK','Pacific/Fakaofo',13.00,13.00,13.00),
('TL','Asia/Dili',9.00,9.00,9.00),
('TM','Asia/Ashgabat',5.00,5.00,5.00),
('TN','Africa/Tunis',1.00,1.00,1.00),
('TO','Pacific/Tongatapu',13.00,13.00,13.00),
('TR','Europe/Istanbul',2.00,3.00,2.00),
('TT','America/Port_of_Spain',-4.00,-4.00,-4.00),
('TV','Pacific/Funafuti',12.00,12.00,12.00),
('TW','Asia/Taipei',8.00,8.00,8.00),
('TZ','Africa/Dar_es_Salaam',3.00,3.00,3.00),
('UA','Europe/Kiev',2.00,3.00,2.00),
('UA','Europe/Simferopol',2.00,4.00,4.00),
('UA','Europe/Uzhgorod',2.00,3.00,2.00),
('UA','Europe/Zaporozhye',2.00,3.00,2.00),
('UG','Africa/Kampala',3.00,3.00,3.00),
('UM','Pacific/Johnston',-10.00,-10.00,-10.00),
('UM','Pacific/Midway',-11.00,-11.00,-11.00),
('UM','Pacific/Wake',12.00,12.00,12.00),
('US','America/Adak',-10.00,-9.00,-10.00),
('US','America/Anchorage',-9.00,-8.00,-9.00),
('US','America/Boise',-7.00,-6.00,-7.00),
('US','America/Chicago',-6.00,-5.00,-6.00),
('US','America/Denver',-7.00,-6.00,-7.00),
('US','America/Detroit',-5.00,-4.00,-5.00),
('US','America/Indiana/Indianapolis',-5.00,-4.00,-5.00),
('US','America/Indiana/Knox',-6.00,-5.00,-6.00),
('US','America/Indiana/Marengo',-5.00,-4.00,-5.00),
('US','America/Indiana/Petersburg',-5.00,-4.00,-5.00),
('US','America/Indiana/Tell_City',-6.00,-5.00,-6.00),
('US','America/Indiana/Vevay',-5.00,-4.00,-5.00),
('US','America/Indiana/Vincennes',-5.00,-4.00,-5.00),
('US','America/Indiana/Winamac',-5.00,-4.00,-5.00),
('US','America/Juneau',-9.00,-8.00,-9.00),
('US','America/Kentucky/Louisville',-5.00,-4.00,-5.00),
('US','America/Kentucky/Monticello',-5.00,-4.00,-5.00),
('US','America/Los_Angeles',-8.00,-7.00,-8.00),
('US','America/Menominee',-6.00,-5.00,-6.00),
('US','America/Metlakatla',-8.00,-8.00,-8.00),
('US','America/New_York',-5.00,-4.00,-5.00),
('US','America/Nome',-9.00,-8.00,-9.00),
('US','America/North_Dakota/Beulah',-6.00,-5.00,-6.00),
('US','America/North_Dakota/Center',-6.00,-5.00,-6.00),
('US','America/North_Dakota/New_Salem',-6.00,-5.00,-6.00),
('US','America/Phoenix',-7.00,-7.00,-7.00),
('US','America/Shiprock',-7.00,-6.00,-7.00),
('US','America/Sitka',-9.00,-8.00,-9.00),
('US','America/Yakutat',-9.00,-8.00,-9.00),
('US','Pacific/Honolulu',-10.00,-10.00,-10.00),
('UY','America/Montevideo',-2.00,-3.00,-3.00),
('UZ','Asia/Samarkand',5.00,5.00,5.00),
('UZ','Asia/Tashkent',5.00,5.00,5.00),
('VA','Europe/Vatican',1.00,2.00,1.00),
('VC','America/St_Vincent',-4.00,-4.00,-4.00),
('VE','America/Caracas',-4.50,-4.50,-4.50),
('VG','America/Tortola',-4.00,-4.00,-4.00),
('VI','America/St_Thomas',-4.00,-4.00,-4.00),
('VN','Asia/Ho_Chi_Minh',7.00,7.00,7.00),
('VU','Pacific/Efate',11.00,11.00,11.00),
('WF','Pacific/Wallis',12.00,12.00,12.00),
('WS','Pacific/Apia',14.00,13.00,13.00),
('YE','Asia/Aden',3.00,3.00,3.00),
('YT','Indian/Mayotte',3.00,3.00,3.00),
('ZA','Africa/Johannesburg',2.00,2.00,2.00),
('ZM','Africa/Lusaka',2.00,2.00,2.00),
('ZW','Africa/Harare',2.00,2.00,2.00);
/*!40000 ALTER TABLE `timezones` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `transcation_id` varchar(255) DEFAULT NULL,
  `booking_id` varchar(255) DEFAULT NULL,
  `transcation_type` int(11) DEFAULT NULL COMMENT '1=event, 2=product, 3= withdraw, 4= balance add, 5 = balance subtract',
  `customer_id` bigint(20) DEFAULT NULL,
  `organizer_id` bigint(20) DEFAULT NULL,
  `venue_id` bigint(20) unsigned DEFAULT NULL,
  `artist_id` bigint(20) unsigned DEFAULT NULL,
  `payment_status` varchar(255) DEFAULT NULL,
  `payment_method` varchar(255) DEFAULT NULL,
  `grand_total` double(8,2) DEFAULT NULL,
  `commission` float(8,2) DEFAULT 0.00,
  `tax` float(8,2) DEFAULT 0.00,
  `pre_balance` float(8,2) DEFAULT 0.00,
  `after_balance` float(8,2) DEFAULT 0.00,
  `gateway_type` varchar(255) DEFAULT NULL,
  `currency_symbol` varchar(255) DEFAULT NULL,
  `currency_symbol_position` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=519 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES
(473,'1765914495','206',1,45,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,0.00,380.00,'online','$','left','2025-12-16 19:48:15','2025-12-16 19:48:15'),
(474,'1765915217','207',1,NULL,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,380.00,760.00,'online','$','left','2025-12-17 01:00:17','2025-12-17 01:00:17'),
(475,'1765915790','208',1,46,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,760.00,1140.00,'online','$','left','2025-12-16 20:09:50','2025-12-16 20:09:50'),
(476,'1765928508','209',1,48,31,NULL,NULL,'1','Stripe',600.00,30.00,60.00,1140.00,1710.00,'online','$','left','2025-12-16 23:41:49','2025-12-16 23:41:49'),
(477,'1765932240','210',1,NULL,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,1710.00,2090.00,'online','$','left','2025-12-17 00:44:00','2025-12-17 00:44:00'),
(478,'1765933186','211',1,47,31,NULL,NULL,'1','Stripe',200.00,10.00,20.00,2090.00,2280.00,'online','$','left','2025-12-17 00:59:46','2025-12-17 00:59:46'),
(479,'1765936779','212',1,NULL,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,2280.00,2660.00,'online','$','left','2025-12-17 01:59:39','2025-12-17 01:59:39'),
(480,'1765952920','213',1,43,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,2660.00,3040.00,'online','$','left','2025-12-17 06:28:40','2025-12-17 06:28:40'),
(481,'1765952922','214',1,43,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,3040.00,3420.00,'online','$','left','2025-12-17 06:28:42','2025-12-17 06:28:42'),
(482,'1766110017','216',1,NULL,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,3420.00,3800.00,'online','$','left','2025-12-19 02:06:57','2025-12-19 02:06:57'),
(483,'1766246278','217',1,NULL,31,NULL,NULL,'1','Stripe',800.00,40.00,80.00,3800.00,4560.00,'online','$','left','2025-12-20 15:57:58','2025-12-20 15:57:58'),
(484,'1766259294','218',1,45,31,NULL,NULL,'1','Stripe',800.00,40.00,80.00,4560.00,5320.00,'online','$','left','2025-12-20 19:34:54','2025-12-20 19:34:54'),
(485,'1766271320','219',1,NULL,31,NULL,NULL,'1','Stripe',800.00,40.00,80.00,5320.00,6080.00,'online','$','left','2025-12-20 22:55:20','2025-12-20 22:55:20'),
(486,'1766287175','220',1,NULL,31,NULL,NULL,'1','Stripe',400.00,20.00,40.00,6080.00,6460.00,'online','$','left','2025-12-21 03:19:35','2025-12-21 03:19:35'),
(487,'1766293060','221',1,NULL,31,NULL,NULL,'1','Stripe',800.00,40.00,80.00,6460.00,7220.00,'online','$','left','2025-12-21 04:57:40','2025-12-21 04:57:40'),
(488,'1766775352','222',1,NULL,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,7220.00,7920.00,'online','RD$','left','2025-12-26 18:55:52','2025-12-26 18:55:52'),
(489,'1766782423','223',1,50,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,7920.00,8620.00,'online','RD$','left','2025-12-26 20:53:43','2025-12-26 20:53:43'),
(490,'1766870399','224',1,51,31,NULL,NULL,'1','Stripe',2800.00,0.00,0.00,8620.00,11420.00,'online','RD$','left','2025-12-27 21:19:59','2025-12-27 21:19:59'),
(491,'1767108238','229',1,49,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,11420.00,12820.00,'online','RD$','left','2025-12-30 15:23:58','2025-12-30 15:23:58'),
(492,'1767144199','230',1,53,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,12820.00,13520.00,'online','RD$','left','2025-12-31 01:23:19','2025-12-31 01:23:19'),
(493,'1767187815','231',1,55,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,13520.00,14920.00,'online','RD$','left','2025-12-31 13:30:15','2025-12-31 13:30:15'),
(494,'1767200547','235',1,60,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,14920.00,15620.00,'online','RD$','left','2025-12-31 17:02:27','2025-12-31 17:02:27'),
(495,'1767204639','236',1,61,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,15620.00,17020.00,'online','RD$','left','2025-12-31 18:10:39','2025-12-31 18:10:39'),
(496,'1767204756','237',1,56,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,17020.00,18420.00,'online','RD$','left','2025-12-31 18:12:36','2025-12-31 18:12:36'),
(497,'1767213187','241',1,63,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,18420.00,19820.00,'online','RD$','left','2025-12-31 20:33:07','2025-12-31 20:33:07'),
(498,'1767213813','242',1,54,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,19820.00,20520.00,'online','RD$','left','2025-12-31 20:43:33','2025-12-31 20:43:33'),
(499,'1767217522','243',1,45,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,20520.00,21220.00,'online','RD$','left','2025-12-31 21:45:22','2025-12-31 21:45:22'),
(500,'1767221126','245',1,66,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,21220.00,22620.00,'online','RD$','left','2025-12-31 22:45:26','2025-12-31 22:45:26'),
(501,'1767221565','246',1,67,31,NULL,NULL,'1','Stripe',2100.00,0.00,0.00,22620.00,24720.00,'online','RD$','left','2025-12-31 22:52:45','2025-12-31 22:52:45'),
(502,'1767221579','247',1,49,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,24720.00,25420.00,'online','RD$','left','2025-12-31 22:52:59','2025-12-31 22:52:59'),
(503,'1767222472','248',1,68,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,25420.00,26120.00,'online','RD$','left','2025-12-31 23:07:52','2025-12-31 23:07:52'),
(504,'1767223431','249',1,69,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,26120.00,26820.00,'online','RD$','left','2025-12-31 23:23:51','2025-12-31 23:23:51'),
(505,'1767223537','250',1,70,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,26820.00,28220.00,'online','RD$','left','2025-12-31 23:25:37','2025-12-31 23:25:37'),
(506,'1767224900','251',1,71,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,28220.00,28920.00,'online','RD$','left','2025-12-31 23:48:20','2025-12-31 23:48:20'),
(507,'1767225187','252',1,72,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,28920.00,30320.00,'online','RD$','left','2025-12-31 23:53:07','2025-12-31 23:53:07'),
(508,'1767226634','253',1,73,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,30320.00,31020.00,'online','RD$','left','2026-01-01 00:17:14','2026-01-01 00:17:14'),
(509,'1767227186','254',1,66,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,31020.00,31720.00,'online','RD$','left','2026-01-01 00:26:26','2026-01-01 00:26:26'),
(510,'1767229714','255',1,76,31,NULL,NULL,'1','Stripe',1400.00,0.00,0.00,31720.00,33120.00,'online','RD$','left','2026-01-01 01:08:34','2026-01-01 01:08:34'),
(511,'1767230970','256',1,76,31,NULL,NULL,'1','Stripe',700.00,0.00,0.00,33120.00,33820.00,'online','RD$','left','2026-01-01 01:29:30','2026-01-01 01:29:30'),
(512,'1767252498','257',1,78,31,NULL,NULL,'1','Stripe',1000.00,0.00,0.00,33820.00,34820.00,'online','RD$','left','2026-01-01 07:28:18','2026-01-01 07:28:18'),
(513,'1767252702','258',1,79,31,NULL,NULL,'1','Stripe',1000.00,0.00,0.00,34820.00,35820.00,'online','RD$','left','2026-01-01 07:31:42','2026-01-01 07:31:42'),
(514,'1771428798','357',1,NULL,31,NULL,NULL,'1','stripe',500.00,0.00,0.00,35820.00,36320.00,'online','RD$','left','2026-02-18 15:33:18','2026-02-18 15:33:18'),
(515,'1771428987','358',1,NULL,31,NULL,NULL,'1','stripe',500.00,0.00,0.00,36320.00,36820.00,'online','RD$','left','2026-02-18 15:36:27','2026-02-18 15:36:27'),
(516,'1771429004','359',1,NULL,31,NULL,NULL,'1','stripe',500.00,0.00,0.00,36820.00,37320.00,'online','RD$','left','2026-02-18 15:36:44','2026-02-18 15:36:44'),
(517,'1771466662','360',1,NULL,31,NULL,NULL,'1','stripe',500.00,0.00,0.00,37320.00,37820.00,'online','RD$','left','2026-02-19 02:04:22','2026-02-19 02:04:22'),
(518,'1771471436','361',1,NULL,31,NULL,NULL,'1','stripe',600.00,0.00,0.00,37820.00,38420.00,'online','RD$','left','2026-02-19 03:23:56','2026-02-19 03:23:56');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `stripe_customer_id` varchar(255) DEFAULT NULL,
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
  `status` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '0 -> banned or deactive, 1 -> active',
  `verification_token` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `edit_profile_status` tinyint(3) unsigned NOT NULL DEFAULT 0 COMMENT '0 -> not edited user profile, 1 -> edited user profile',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_username_unique` (`username`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES
(9,NULL,'Saeed','Mahmud','1636607574.png','saeed','geniustest11@gmail.com','2021-12-13 02:35:32','$2a$12$T9Z/6tQKjnW8bQdmgNW70eEGuum0f69NUAJ2wQsGqBx6UoJ/bU0Qa','+132456789','Mirpur 12','Dhaka',NULL,'BD',1,NULL,NULL,1,'2021-11-04 03:31:44','2021-12-23 05:00:40'),
(10,NULL,'Samiul','Pratik',NULL,'pratik','pratik.anwar@gmail.com','2022-04-26 02:14:48','$2a$12$ID6qjVPRRIE7m3YwbkAZ1eCFBc1uBvtA2pcnY.oArzBklxwx1a7Uq','+132456789','House - 44, Road, - 3, Sector - 11, Uttara, Dhaka','Dhaka','Dhaka','Bangladesh',1,NULL,NULL,1,'2022-04-26 02:14:29','2022-04-26 02:15:46'),
(11,NULL,NULL,NULL,NULL,'rynupyzan','user@gmail.com',NULL,'$2y$10$bRif2OK0/gzPRTYMODqAFOL4DVFk8Uvrr7p3ZsQ.1BIqEqozSvYvC',NULL,NULL,NULL,NULL,NULL,0,'8cc2740a37e351c21d8798de23ced22c',NULL,0,'2022-06-14 04:13:58','2022-06-14 04:13:58'),
(12,NULL,'Fahad','Hossain','62a9725fd40d8.jpg','fahadahmadshemul','fahadahmadshemul@gmail.com',NULL,'$2y$10$sUWgkndzQpWxjy5PmF0RqO1h1Wp3CpkeXcb/hyJF6ak9TL0YFyrLy','0123982109','Dhaka, Bangladesh','Dhaka','N/A','Bangladesh',1,NULL,NULL,1,'2022-06-14 23:44:29','2022-12-17 23:14:59'),
(13,NULL,'Giancarlos','Valdez',NULL,'gianvald','gian@monkey.com.do','2025-12-06 07:22:52','$2y$10$9.bm/AF16ExwriOd/CjFJOCAzLSjWPfhDfLZk.tFkuQ7gY77NVft6','8493538839','Calle 1','Santo Domingo',NULL,'Republica Dominicana',1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(14,NULL,'Davila Esperanza','Paulino Ramos',NULL,'davila','daavilaramos@gmail.com','2025-12-15 16:28:31','$2y$10$O4od7awIRFwRYvWj5cVETOoIZHqOpjLyE4s43zZ3uM/5NmCdKOVvG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(15,NULL,'Milauri','Paulino',NULL,'Venicebxtch20','milipaulino4@gmail.com','2025-12-16 19:38:39','$2y$10$PqRyx61/CGBY0TQkkLoG6.jh8r.y2l9oDmZom1kAs.uIJDvlJmbDm',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(16,NULL,'Adrian','Torres',NULL,'PilitaDobleA','adrian50-50@hotmail.com','2025-12-16 19:54:07','$2y$10$hTZNth5zmkQLbBeaD1ftn.AK4D8KUpfHSJ70e51dBPuR8Gsuj42OS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(17,NULL,'Dilencio','Vargas',NULL,'dilencioangel','dilenciovarlirz@gmail.com','2025-12-17 01:08:24','$2y$10$V9ze2Uj1SazRcrYU7OhXaefn9/Hafp.p6YPI6Rkl0ipKhGHwVKy8W',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(18,NULL,'Jeffrey','Ynoa',NULL,'Kamaru','jeeffydn@gmail.com','2025-12-16 23:39:55','$2y$10$WRk8YvOSxVNPxGxxuVwc5uAlzTFv4.M2/6lfAgCPP14/WJuw6kXDa',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(19,NULL,'Edgar','Garcia',NULL,'Eddddd25','edgar255075@gmail.com','2025-12-21 00:04:36','$2y$10$3OReZpDPOrJPWjTP8ZtfVeQDFTD0.gRg3l66LJQY87acS3LX7uqyG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(20,NULL,'Juan Diego Perez','De Los Santos',NULL,'juandiego05','juandiego05@gmail.com','2025-12-26 20:52:18','$2y$10$JnRp7q1nfApzoZ1UJE1bQuamuV8QCWZ5KoSZtoChdYBFOtUOXlNoe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(21,NULL,'Ivan','Noboa',NULL,'ivannoboa','ivan.noboa@gmail.com','2025-12-27 21:16:00','$2y$10$d3MTcEvfMQMMfcMtQ4RIL.CPu66Icyxof04qEGneXvjpCZ5ifkUO6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(22,NULL,'Erick','Benjamín',NULL,'Peluche','erick.benjamin.leon@gmail.com','2025-12-29 00:42:42','$2y$10$jC936d4rOggS9SFUm2n3v.TqYxhXYtXbbFRoGfDu1n1fUUhGEPtAu',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(23,NULL,'Maxwell','Morrison',NULL,'Maxflips16','maxflips16@gmail.com','2025-12-31 01:15:32','$2y$10$Y/38JpPfiLY4HlyCjEvLg.dfgrVuGrKIguXPMBRCmgxGaiqiWK3g2',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(24,NULL,'Jeremy','Caro',NULL,'jrmycr','espiritado.innato9j@icloud.com','2025-12-31 11:45:24','$2y$10$miTVJZInvgXak.eKLSUA2ePUYBDxQAR6mOWVn430fufSWviCVxVgG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(25,NULL,'Victor','Hurtado',NULL,'victorhurtado','victor.hurtadomena@gmail.com','2025-12-31 13:26:09','$2y$10$9VI8ZEBKu0Eza.9ygYILauJgz2tGBfYTBXDy72RwSfcSVcuTIYlL.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(26,NULL,'Martina','Occhi',NULL,'Martiocchi','martina.occhi2@unibo.it','2025-12-31 13:47:56','$2y$10$gwDvub.ZdM1Mnbksna..Cez674/WmB22OSvHKlU69WNw3WoSsWm.y',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(27,NULL,'Junior','Santana',NULL,'Robwkx','juniorwkx@gmail.com','2025-12-31 15:03:16','$2y$10$VnzfHWbSZjAJ8TPb4SOZIOPiHWNyN5iYRs585dI1nWpZasyCWsZPC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(28,NULL,'Ramses','Sultan',NULL,'beatbysultan','suhl.tnbookings@gmail.com','2025-12-31 15:21:24','$2y$10$w1GMloQ1Jm42yIjdT3DtxegAnvhrnbwpEgYPdyvJUPTQKTM6Powte',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(29,NULL,'Yamilet J.','Terrero Batista',NULL,'Yjam','yamilettb20@gmail.com','2025-12-31 16:40:28','$2y$10$eD7y8grv.totRHUabXB7V.Lqtzz8S7moosIAuEDxQJk8CPFwwxat6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(30,NULL,'Alberto','Parada',NULL,'Albertoparada','saulalbertoparada@gmail.com','2025-12-31 16:58:56','$2y$10$9ZC6LwNXP0XOOWR9TTtbCeVtaZETQO9FXzCF3UpkrCdGhtDqUpWcK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(31,NULL,'Christ Austin','Lamour',NULL,'Tovsky','Christaustinlamour@gmail.com','2025-12-31 17:50:21','$2y$10$cdqcxZw1ePoSABbKbnQZyOe1C4iAybMuhVt2ox3QSNeiKpMH9LJPW',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(32,NULL,'Génesis','Blanco',NULL,'Genesis31','genesisvanessablanco@gmail.com','2025-12-31 18:27:19','$2y$10$ap8Dyli0qs8OXY5YUythce6OrI/kqQQRnV6OiWR9EnlnNpB8Xw8xK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(33,NULL,'Braulio','Paulino',NULL,'Gonter','braulioap1998@gmail.com','2025-12-31 20:30:31','$2y$10$sPTDFl2u/3tLJJf49orTiufHR4teSZIrv7tZSBKBd1hpJvuMrRWHO',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(34,NULL,'Joel','Morillo',NULL,'joelmorillo2319','daesolucioneselectro@gmail.com','2025-12-31 22:35:57','$2y$10$jf9OD7BT5n1kUD0UFwcSiOaJ9katnqxrMCl/jcgpGJfVHVJYUbn/O',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(35,NULL,'Roy','van der Steen',NULL,'Roys','royvandersteen82@gmail.com','2025-12-31 22:36:03','$2y$10$ByvP0swFTanKh7x89Ca64eG0aeTaE3/ismee.w/ejwp9icqASqP62',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(36,NULL,'caleb','deriel',NULL,'calebderi','jonathanjoestar775@hotmail.com','2025-12-31 22:40:38','$2y$10$gX4Qkc08eSrQYsfdV3bnReJCljRfETkB56rSXVSjNi/XAU8aC6F5u',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(37,NULL,'Massiel','Tejeda',NULL,'Massieltho','themazzy27@gmail.com','2025-12-31 22:51:18','$2y$10$K3knC2bDBzYU0zAsosJ./O.j4cV6IWg7aTiWUfBqIe24OeIqnj2.G',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(38,NULL,'Jeffry','Zabala Ramirez',NULL,'Jefffcito','jefffcito@gmail.com','2025-12-31 23:06:05','$2y$10$TsK4jp9rPqtPTcUhIFzUVecAB6t8t/M3GpbKQNWRY/l4A7fulyXWe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(39,NULL,'Roberto','Rojas',NULL,'MrSimple','angelfitdash@gmail.com','2025-12-31 23:09:27','$2y$10$7N1vCzIBU6LJlyyH0V3.muBeuCf52Njv5qFsedKlsmIdoGgFp7xHS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(40,NULL,'Zion','Lowe',NULL,'112lion','zionlowe7@gmail.com','2025-12-31 23:19:37','$2y$10$n2xeXKEO8ZIXleiSajQhLOwIr8MUdkLvAjoBq6QvrvKccSDSL8kXW',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(41,NULL,'Brainer','Espinal Aquino',NULL,'Jimmy','drbrainer156@gmail.com','2025-12-31 23:35:20','$2y$10$8PZi9xUqgmlyi5D8wg2RceAyymhEgZQP8uJ42I.PlRupc1MlqN052',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(42,NULL,'Emanuel','Duarte',NULL,'Durtanu','durtanu@gmail.com','2025-12-31 23:44:51','$2y$10$sfY.JUaw71O8yFRugb6OhO2/nlFbSIVDykM3vptXSKRq69j84qyrO',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(43,NULL,'Daniel Antonio','De león Javier',NULL,'Daniel_d01','daniel_d01@outlook.com','2026-01-01 00:13:11','$2y$10$d8OM4FwAFW.rG4wOS6OdBuh8mCAgijxuIczXFHqG3jQf8TJRwzDvS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(44,NULL,'Louis','Pedrito',NULL,'509Pedrito','louispedrito111@gmail.com','2026-01-01 00:16:05','$2y$10$QPT5wnOBsic6GP69MeZFXOukvLSXrYDLUpT5lRm4kOzhAPRogUXBC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(45,NULL,'Jonathan','Demosthene',NULL,'509Angel','jonathandemosthene50@gmail.com','2026-01-01 00:25:56','$2y$10$IOv5EJj82URCnP8tJxDob.wxmmjoaQF4F3y6hDyJ0NMkMCWjVCViu',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(46,NULL,'Jeison','Torres',NULL,'jasontorreslapaix','jasontorreslapaix@gmail.com','2026-01-01 00:36:55','$2y$10$N00f8Dor8KS6k6LOHMKjUOYDo59GyQuApySKW9tVGVxqJ9YJjz5Fy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(47,NULL,'Robert','Leclerc',NULL,'Robertleclercp','robertleclerc18@gmail.com','2026-01-01 02:01:46','$2y$10$KdUz5UrpoGv6tkcT3O3o3esWiZRQQGth.n7Ks0GX/bcLMnaZL2kFC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(48,NULL,'Jorge Luis','Alejo Herrera',NULL,'Jorgealejo190','jorgeluisalejoherrera120@gmail.com','2026-01-01 07:25:34','$2y$10$YF8ZUM63nECNwnZXLF4jzu6YezvU8.mapB2n5OW7O4EnOAqHwCaTu',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(49,NULL,'Jean carlos','Jimenez',NULL,'Jeanc','jean.abreuj@gmail.com','2026-01-01 07:26:30','$2y$10$B4Y0/iKX42smjSBgrKF9suJCQ8NnJrgvxqaVeCZFea4zt8Eaf8i/a',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(50,NULL,'John','Lugo',NULL,'Pepper','johnldiaz07@gmail.com','2026-01-03 02:58:02','$2y$10$AB.lKw2fpRSVFdHoWS0ibOLu/hQUbZ.ZM0vtnNoMMYKzhG/3bx8xS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(51,NULL,'Joel Francisco','Ramirez alvarez',NULL,'Joel','alvarezjoel923@gmail.com','2026-01-03 02:55:38','$2y$10$5TFoo/dCLGeFoSqMM1pHTukG89PWrWNGmwCO47ofkBPUXCHWAeUiq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(52,NULL,'Diego','Rojas',NULL,'Diegs02','diegoguillen0105@gmail.com','2026-01-03 02:56:29','$2y$10$JgIc1RbH75IR4v3/Rfq5BOBEQWgRqUDBQjf2xk.qnsINptRo9SpDm',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(53,NULL,'sebastián','marmolejos',NULL,'sbmarmolejos0101','sbmarmolejos@gmail.com','2026-01-03 02:56:39','$2y$10$aZReBF.J5eGHDmQqy1wpoO96HBAxZ0SiwakKSM139FB3aj3FWQrhi',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(54,NULL,'Miguel angel','Del valle bruno',NULL,'Miguelbroh','m8498478202@gmail.com','2026-01-03 03:00:44','$2y$10$YlXuWZG5efmjjrazj/P14.0uM12aFNQrtr3iqjUiGt9rO25eoHz.W',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(55,NULL,'Luis','M',NULL,'Beltr31993','beltre90@gmail.com','2026-01-03 03:05:14','$2y$10$K6XYnAN6J.joB22sQ.csG.HbbFsmVPdPdeZ26ZD3bW3PChcIwjSAC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(56,NULL,'Stefano','Amador',NULL,'Stef101674','amador.stefano15@gmail.com',NULL,'$2y$10$/w2oL7KzmQLHxoqLbcJgauBNvOZiYUqheFdI7nTRsmUFUQdCwZW0i',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(57,NULL,'Patricia','Garcia',NULL,'PatriciaG','patriciag8002@gmail.com','2026-01-03 03:06:24','$2y$10$b3sMXjeDn495iwRJLF8X5OzNs2ev7U4WKCPafD1wu6CUvIpxd8r5.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(58,NULL,'Luz','Castillo',NULL,'Luma','luzmariamarte849@gmail.com',NULL,'$2y$10$CqAqhUqyVw2FHpUQ5l7BCeZ6XqbWf.leDh3rdVNpKxkkg8YcDzcgy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(59,NULL,'Luz','Castillo',NULL,'Luz','luzmariacastillomarte13@gmail.com','2026-01-03 03:14:54','$2y$10$bBGDGZ73w8ZQ50RQLXU2L.4IwPmKLQrLlegnKjUY3IuOEYgznCCw.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(60,NULL,'Denis','Rivera',NULL,'driverae','omegadr@yahoo.com','2026-01-03 03:21:02','$2y$10$jBeGo24cV./LaioaVTggkOlt2qnuSuzZpLViSxhGG1NeOM69qAetS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(61,NULL,'Emil','Fernandez',NULL,'EmilFdez','emileduardofernandezarias@gmail.com','2026-01-03 03:18:11','$2y$10$VAOCZc1quB8GoYXdrW.wIukGGB7F6YqKHfPuuY3mA2da0Y/yO1skm',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(62,NULL,'Joel','Peralta',NULL,'Jperalta1606','joel.peralta1696@gmail.com','2026-01-03 03:19:41','$2y$10$fHKQbgmZIyNSqtlz8PwQVubn6l3n8NHTnbr6O9zd8BBRSDMiPKGw6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(63,NULL,'Juan','Toribio Lied',NULL,'tainordico','jtoribiolied@gmail.com','2026-01-03 03:28:57','$2y$10$DWyiqPnBXnAN0AyCMqhgQ.QmTnrL0vf8rSKRVw1r91ouijap.Vv/a',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(64,NULL,'Isaías','Paredes',NULL,'Isaadark','isaiasdelorbeparedes@gmail.com','2026-01-03 03:32:28','$2y$10$hRlVlk.CvRyMDMJy2rBmcO.agTHcC.tfplHwNZOLUnOKk01rWvd9q',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(65,NULL,'anthony','peguero',NULL,'kgre','anthonpguero@gmail.com','2026-01-03 03:37:22','$2y$10$/HbH0u322Kgc1XNyqZhjyOaKi1GAmlHLIOHPj4FGH0z7xBNB5Y1au',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(66,NULL,'Step','Vazquez',NULL,'StepVz','johannavazquez7@gmail.com','2026-01-03 03:37:37','$2y$10$Ik9hk160.lQ/WA7IbxqgUOPPJiOv1dq0R3n4I4tM8bWOqgp9EPtNa',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(67,NULL,'MATEO','VASQUEZ',NULL,'MateoVaLo','mathimparable@hotmail.com','2026-01-03 03:52:15','$2y$10$/zvNPug/ecqVnNIe/Fzg2eq9AzMuAIP2cOz/DENLAxNowggRlSTlW',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(68,NULL,'Hamlet','Almonte',NULL,'Hamletalmonte','hamlet.almonte@gmail.com','2026-01-03 04:22:53','$2y$10$K/fj8M4ByFDIzuOMCmfEh.y1XgGqBJXDxiwiq7M5vw/uR/5LmD4f2',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(69,NULL,'pablo','reyes',NULL,'pablor','pablojosereyescalderon92@gmail.com',NULL,'$2y$10$RCVBBUIbjMLssZdoAlWk7urb6eKD7DQvT0CdG53S7HstrSx3ImP9m',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(70,NULL,'Jini','Luciano',NULL,'jinitalol','jini_2d@hotmail.com','2026-01-03 04:29:29','$2y$10$mFKlbpOeCe2FK6K5jNwn3uYgl1gBtfaiYrXIDkQk/9NgWzuHqzbWC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(71,NULL,'Kelvin','Ortiz gonzalez',NULL,'KingKush10','mj3817133@gmail.com','2026-01-03 04:31:35','$2y$10$iWtDrsmN/trGVESMH6DCcOrAyO8oH7T6gCA1VK4Fo8lr9kci6sBK6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(72,NULL,'Jhon','Chalinger',NULL,'Patanx22','patax22mh@gmail.com','2026-01-03 04:32:27','$2y$10$wbE4gqjMFlJ2bFT0LrVh3utcMygIr.aWcriN80ZpFz4sBhvxRcqLe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(73,NULL,'Juharin','Payano',NULL,'Jamesjames','jamespayano@gmail.com',NULL,'$2y$10$8kJuD59k6atGG1Qwzz/xVOyb.gBzTHabfk7padFgBdM271Qz2w9.6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(74,NULL,'Aaron','Chan',NULL,'Aaronchanay','aaronchanaybar@gmail.com',NULL,'$2y$10$XEkCr0bSk91ts8ouoqVbNeHdy8.5wmPjtUPpc.sWBSUX0908szd9O',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(75,NULL,'Green','Muñoz',NULL,'Greemfiesta','greenmunoz61@gmail.com','2026-01-03 04:44:13','$2y$10$WhGEPa39pPW.r75Ua2Nbtu319M2wfEH9fd97AwWGcQb4pI2B3TMia',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(76,NULL,'Angel','Pereyra',NULL,'angelop130','angelpereyra1307@gmail.com','2026-01-03 04:51:24','$2y$10$F.IN1Ami0R2KwMkckjg4COoPkHXI/bxQvdKApG45L.GRG90xuVVsa',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(77,NULL,'pablo','reyes',NULL,'pabloreye','pablojosereyescalderon@gmail.com',NULL,'$2y$10$v8zKPp5Mu10xPVdkqqVklOTeHwTQ5BIC53KXlNyNtYwaugu7wpty6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(78,NULL,'Juairin','Payano',NULL,'Kingjames','ko8361907@gmail.com','2026-01-03 04:57:16','$2y$10$RBd.FULOwkK6BJzaN1q9WuQr9rnOucktielFkoVyhPAcnPikwlMhy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(79,NULL,'Roberson','Jose',NULL,'Roberson','josebaez1988@hotmail.com','2026-01-03 05:02:12','$2y$10$FUV6USGsvAjn2jDR.OI5U./QwIGeeOiKst/OvhVKZzaAu/KOZi2mK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(80,NULL,'Diego Alberto','De los Santos suero',NULL,'Dieg0229','diegoadls04@gmail.com',NULL,'$2y$10$satFoMid6cfuqZsQdPSc0.Pbr.PhBLG8SpDj0K.Zkp6z/4ibyR/ry',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(81,NULL,'Olga','Mendez',NULL,'Olgaolga','olgamendez03@gmail.com','2026-01-03 05:10:18','$2y$10$3OoaMLujO9yHuzVsUULZXuH/rkwsFWyhHZ4DAus3XPI2uJ12BfaIG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(82,NULL,'Angey','Antigua',NULL,'itslele','angieantigua15@gmail.com','2026-01-03 05:31:33','$2y$10$/cGyjbTa3VkkLF9jpc6P8.aPZXyEF2UFQT2tyKR1igGYfB/Y1TcjS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(83,NULL,'Cesar Soto','soto',NULL,'cesarsotoortega','cesarsotoortega@icloud.com',NULL,'$2y$10$eoDuCEOliCi1uHaXGMYzLO72eGaRKKVT/JbmSWyBuUseLkKN0zBHu',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(84,NULL,'Fairam','Castillo',NULL,'fairxm','fairam.louis@gmail.com','2026-01-03 07:51:54','$2y$10$hRkElBFL2EhO30uCOQIxceD2Kdt2EQILZresBUj1tSNz8xs5XWSRK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(85,NULL,'Fausto','Marte',NULL,'Fauma','faustopena170@gmail.com','2026-01-03 13:12:23','$2y$10$1JC6K75SW616UXxxu3J7dO7sbzoAOVUsQjvXdyOtHnfXMIZJ6dYMy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(86,NULL,'Josue','Valentin Villa',NULL,'DatJoshie','datjoshie@gmail.com','2026-01-03 14:29:29','$2y$10$.AF/sc6h37MNVWg.eh6GMupWP0hT5jNWUVOcZZR3AlTdsgz/KXLoG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(87,NULL,'Aider','Kun',NULL,'AiderKun','aidersupp30@gmail.com','2026-01-03 14:42:40','$2y$10$R48ghXp3oIlowPHlZQm1e.h7RJ4Xe0zqGxM.EgvQ2gcHIGW4D4vbq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(88,NULL,'Rafael','Romero',NULL,'Rafarom666','678tasha678@gmail.com','2026-01-03 15:28:31','$2y$10$qGZuszZmRLoMeVEWmMdo6eHDS3Zsi4fsNSzO.olTZZfDTJeWGnbCO',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(89,NULL,'Luis','Perez',NULL,'Lbpm9513','lbpm9513@gmail.com','2026-01-03 15:55:12','$2y$10$oC6ZzXw6KUzeJGADC1qrkO6y8T.Cw5dmEur3RERWiI5aHj16SwqaS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(90,NULL,'Joan','Pérez Pujols',NULL,'Joanperezrd','joanp1994@hotmail.com','2026-01-03 15:58:03','$2y$10$zU/3FrdyzPxPB5xu0W5Laeqn.dmr7amOAwPFsnI2/jqt1JqIVEyme',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(91,NULL,'janiel','acosta',NULL,'janielacosta','janielacostarealestate@gmail.com','2026-01-03 15:58:17','$2y$10$CVRlGfdWXXrH2jEh0mf1S.mX.X0H9bM/OdTiHShH1TV2iqZ22.gZW',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(92,NULL,'Stefano','Amador',NULL,'Amadior2000','amadorstefano15@gmail.com','2026-01-03 16:00:06','$2y$10$lmryeHkMY7pdLG49fTBYNOf4moNABQVjX4FQhbegjtZfSGla4mc1e',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(93,NULL,'Pavel','Calderon',NULL,'Paverusk','stefano.amador@gmail.com','2026-01-03 16:06:47','$2y$10$aADqgtpCC3lAaBNkTaHiHuwdVaR6mh0jv12rWItEPGO2yy4J1.HC.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(94,NULL,'Dulce','Wiese',NULL,'Dulcewiese_1','dulcewiese18@gmail.com','2026-01-03 16:13:13','$2y$10$5Z2LK8MU0rTUPjZiiEbfQOv7Iuy1s8VpGZ3yRsdp8Ry7aG7xGGFz.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(95,NULL,'Mary','De León',NULL,'Marydeleon','marygdeleonf@gmail.com','2026-01-03 16:14:14','$2y$10$yvM44zhMNGJUVXQTDZv8MuQ1QHcRS2JFdzH2PuCBIFF5Dni3a/a6i',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(96,NULL,'Lotty','Cardenas',NULL,'Lotty','lottycardenas25@gmail.com','2026-01-04 00:21:22','$2y$10$jDHNEl2d/LPIMixCk3C/buTqEegY5J3R6LlVrl0HDQVpM.V5z3DiO',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(97,NULL,'Salimah','Veras',NULL,'sali_veras','salimahveras@gmail.com','2026-01-03 16:42:36','$2y$10$6yLw3VrAXAhzzNcltVXQMOw4p51TwyNMDVbksFOPLQmWUkZxOgydK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(98,NULL,'Luis Angel','Tavarez Taveras',NULL,'Radhame','angel.tvrzs@gmail.com','2026-01-03 16:40:53','$2y$10$JNRtuwjnLZHVSTdkXOzrEOs5Cwsjhl4IbpQr7rBc8pgMSzooq/r3W',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(99,NULL,'Yefry','Batista',NULL,'YeffB','yeffjesus08@gmail.com','2026-01-03 16:48:36','$2y$10$HjrIWx2G3gM08kFUJG9rM.WmiYac2rHJWMcjHhvpPMv5X6NgnhXn.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(100,NULL,'Aubrey','Fernández',NULL,'Aubrey','aubreyfer02@gmail.com','2026-01-03 18:34:33','$2y$10$5hzNi09cZ8lZPR5lScLBce9h4B2DcCsqbMom7VldaQV8hgqZbAJIS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(101,NULL,'Ana rosa','Mondesi',NULL,'Aaaamor','irisbaez1024@gmail.com',NULL,'$2y$10$fdywIcVAe9m3lP/U7g.XLeUpp5tVeddtpG9PifCwzr4G/hBRj8ZAG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(102,NULL,'Damaris','Martinez',NULL,'Damaris','reddame72@gmail.com','2026-01-03 17:16:15','$2y$10$U95QtBNdyNUNg2pfzDK3beXh8gLhq7DQMxXaI8AKeU3FfWAtGO6Hi',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(103,NULL,'Raúl','Cabrera',NULL,'Raul','rau0809@gmail.com','2026-01-03 17:00:08','$2y$10$QcjD9FBhwvFxTHDq2RxHJeQHU6nPrBiI8OKrFOT2AeV3Szdu9RRra',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(104,NULL,'Marcos','De Leon',NULL,'Javi31','mrskaos101@gmail.com',NULL,'$2y$10$8hs.XyQjcBZqrf1ytrrwYOcDd4mKd.03L7Zl5oCwGO6noH0JCVJzS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(105,NULL,'Jordi Rafael','Ramos Ventura',NULL,'jramos90','jordi.ramos.1990@gmail.com','2026-01-03 17:04:15','$2y$10$bly/GiwMKUxIhoXKHNaeEudMvJChrU3jYFK.WQeAMr115dMg9nnwm',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(106,NULL,'Vishnu','Fernández',NULL,'Vishnu','vishnufernandez@icloud.com','2026-01-03 17:11:41','$2y$10$QLgNSXH251nYUE3a1vXwfOGIrgPLs2CFvPGI.in/wvRucKjJNY6Tq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(107,NULL,'Gino','Carezzano',NULL,'ginocarezzano','gino.carezzano@gmail.com','2026-01-03 17:18:21','$2y$10$mcArz/zvN7Yhl9mBJ1V/MOV7wampimz7.ciu32047vQB58Tt5.Bfe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(108,NULL,'jandro','polanco',NULL,'jandro','jandr4xxx@gmail.com','2026-01-03 17:44:00','$2y$10$iPhSL0I5H1vAixvBCEnB6.tBArXXsDx6pNcC/GU.K9l/uSTiBBjH.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(109,NULL,'Alexa','Reyes',NULL,'reyesa','cheetah106@gmail.com',NULL,'$2y$10$0Ya0kj1n/usESPYSYbFP4elbY82O8LY.ur7ASMJKdSPRA/imy6Ixq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(110,NULL,'Ramnerys','Mena De la Cruz',NULL,'Bert','ramnerysmena@gmail.com','2026-01-03 17:56:43','$2y$10$fakW6CcO7HfsNEI4OFtRY.KgwlJnufcNOu6DrVVNGqTXkODBlja.C',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(111,NULL,'Jose','Pena',NULL,'josefpena','jose.pena@email.com',NULL,'$2y$10$KuSLj4JZ4YWMCin5//c./O.TAr3wOYesaiWKofXBCX5ZvRwn7faY6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(112,NULL,'Aimee','Morel',NULL,'Aimeemorel04','aimeemorel04@icloud.com','2026-01-03 18:38:13','$2y$10$UemQDGKue2yWz/3RsMCzf.GAw/zwZk5RUi2K1GGLXFrPPOmdUL2ZK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(113,NULL,'Jose','Pena',NULL,'josefelinopenasegura','josefelinopenasegura@gmail.com',NULL,'$2y$10$Z4jm4TiC5RwabAKxa3HNB.RLkc91EdLMuMB633SrDYSIWE2Nec45W',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(114,NULL,'Marcos','De Leon',NULL,'Marcos31','marcosjavierdeleon31@gmail.com','2026-01-03 19:01:34','$2y$10$5LV2gzVkdWpgxOvMYl8NdeMHNx7pUWBzH5c1YSMujHT.rtaAjZAWm',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(115,NULL,'Rafael','Bueno',NULL,'imrafaelbueno','rafaelbueno1923@hotmail.com','2026-01-03 19:32:02','$2y$10$F0nrDRi.4SJLbwbBdxFReeNNWX0NWJ1gcy801T/aN6bMxy/bwJ2WS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(116,NULL,'Sebastian','Suriel',NULL,'sebashanj','ssuriel16@hotmail.com','2026-01-03 19:36:58','$2y$10$QrE7DG1IMxSNLZI7juBYgeahjRi4J8RydPD7rTt5kFgp3jf7sXLc6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(117,NULL,'Yeralqui','Frias',NULL,'alexander98','yeralquialexander@gmail.com','2026-01-03 20:02:01','$2y$10$e.KyhBLcXWZuL9O1dReHmeqiPQBnJSZjd5UsXJcVjUEkJW7xAHmRG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(118,NULL,'Jerry Steven','Reyes Veloz',NULL,'Jreyes','jeesreve@gmail.com','2026-01-03 20:25:08','$2y$10$0VPfGts0BNHDmSnbOG8H9u.lnRDLczyIMHi8xQ4u0PUkviR3kdF02',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(119,NULL,'Rosy','Villa',NULL,'rosyxvilla','rosyxvilla@gmail.com','2026-01-03 20:30:20','$2y$10$xdhtJEDQp.fuS4bm3xnt9uB/TIwQtt/.biD8Rxh3hDOe6q6y49AdC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(120,NULL,'NAIROBI','HERNANDEZ GOMEZ',NULL,'Niicenaii','nairobihgomez.2010@gmail.com','2026-01-03 21:11:54','$2y$10$tzLNAgFGaBfd3.rzYVx/1.dZe3NLLdpyFXatm9On81ECKyY3Ba4uG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(121,NULL,'Emilis','Castillo',NULL,'castleemmy','emily.garrix@gmail.com','2026-01-03 21:45:19','$2y$10$Lul8FciSiV45WlNdKu2wGu.Aweua.YreCM.IVZIhcnuGfcUDYMkxG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(122,NULL,'Erick','Hiciano',NULL,'Pawter','hiciano.envio@gmail.com','2026-01-03 21:46:10','$2y$10$4/kTxAbXKLlbNGjx/fW/h.8C8h37S3XqxTITI11w3UGDZNnd2r0YC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(123,NULL,'Alexander','Suarez',NULL,'Alexsm27','ALEXSUAREZMEN27@GMAIL.COM','2026-01-03 21:45:54','$2y$10$VxZcgxjFikHrOzQbmmRQ7e0XpVZWR3WQtTqvdyCGos2env26oGBYi',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(124,NULL,'Franchel','Velázquez',NULL,'Franchard7','franchard7@gmail.com','2026-01-03 21:50:12','$2y$10$U3xk9aD8ecWyFJ8Duk7ux.RaP.g62irZ//EvdLKtiysEYLsZWTPaC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(125,NULL,'Eduardo','Cruz',NULL,'EduardoCruz_','eduardocruzcastillo07@gmail.com','2026-01-03 22:00:56','$2y$10$HfhXQUoxN3Xeveh0pMXOm.Z1ceCgiTi6DPyJGrNvqFvgot1UOYXBe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(126,NULL,'Krysht','Fernández',NULL,'Krysht','krysht.13@gmail.com','2026-01-03 22:17:45','$2y$10$1r18JxzeIhnaQpndjW7yAeCZMOvNyHR/RaT9yMFCY/qg.KRp9VJ1m',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(127,NULL,'Alexander','Mueses',NULL,'yeral98','yeralquialexander@hotmail.com','2026-01-03 22:21:54','$2y$10$9dkPumEbw2cdgaQjLMSpr.qWPNkDQeV72xD1MpE703EUMsq3z74X.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(128,NULL,'Ninoska','Mejia',NULL,'ninoskamejia','ninoskamejia16@gmail.com',NULL,'$2y$10$kgVKvkXdK14u4XXKnH3abuj7SNbRRBaUxaOovC/WQhIUj356yR482',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(129,NULL,'Gabriella','Medina',NULL,'carmin','gabriella.carmin@gmail.com','2026-01-03 22:31:47','$2y$10$AsFVupNW3Fb17F/yBPtjwuju87AC4SvgDvzabrCsME9goaCrkOqRq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(130,NULL,'Jesús','Mora',NULL,'Jesusito','jesusricoso17@gmail.com','2026-01-03 22:44:40','$2y$10$ELC/.Lc5gx7lUuw4Uwb1O.4dpvmZ3d9e9EsggtZ6aS981ruYgzZm2',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(131,NULL,'Kiara','Hernandez',NULL,'Kikiisakitty','hernandezkiara88@gmail.com','2026-01-03 22:43:25','$2y$10$0BuX2B4E0RZ85AvnDaDho.v4XhYOAyX2xQiJlmvugYmqm5jnWZZAy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(132,NULL,'Brenda','Méndez',NULL,'thattbibi','brendayis2211@gmail.com','2026-01-03 23:20:54','$2y$10$yaHIaP4C2YOYSiE88ekQmeUF5LgkFjYNiYfAXx5gqoSUxJ2IsVkvy',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(133,NULL,'Jassel','Santana',NULL,'Jassel','jasselenrique@gmail.com','2026-01-03 23:05:53','$2y$10$oTrUiCTFj2iKWkMB.VVEv.nDmeq6j5G0Cjyu0mygRmNPjX6N/SxJC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(134,NULL,'Jean','Diaz',NULL,'Jeanpapis02','jeancarlosdiazrod@gmail.com','2026-01-03 23:09:28','$2y$10$x7NIQ1siPoGQX5GM/S8PZ.7SSORbNbQ.5VcSbM49Mcl1b2l/Leg/q',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(135,NULL,'Luigi','Montaño Laureano',NULL,'Luigim10','luigimontano1@gmail.com','2026-01-03 23:13:18','$2y$10$aaO/YojYc12qpG7x/ZQu1ee74D2WW2OuqMajicrmXUVBMI5fDTZlK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(136,NULL,'Alexis','Contreras',NULL,'alexiscontreras','onlyalex85@gmail.com','2026-01-03 23:13:17','$2y$10$qar91DjLNA3UJ8f.pEYkmeZGpHhvP6Hfclm3TN0W0OhqPPoQad3u2',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(137,NULL,'Eduardo','Cruz',NULL,'EduardoRoller_','cruzcastilloeduardo@gmail.com',NULL,'$2y$10$tFg14zPkm1sdsw6P8nTPFenJvV0H6k/QhNknTF2qyMlbM965NUfga',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(138,NULL,'Lara','Denisse',NULL,'Laradeni','lara.yasiris15@gmail.com','2026-01-03 23:55:14','$2y$10$hLS8a1DHJLqFwHCqo5PvpeiZ.9NYF83rpH9BXFiDsPbefmru.HrsS',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(139,NULL,'Julio Antonio','Marcano arvelo',NULL,'Juliomarcano','marcanojulio55@gmail.com','2026-01-04 04:16:28','$2y$10$nuhkaDN2QdmFSoiM0mvxaOi1DTKMTx70Bm05iYUIUW9LdTFYUltzG',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(140,NULL,'Diego Alberto','De los Santos suero',NULL,'Diegfeliz','arcs_revers.5m@icloud.com','2026-01-04 01:05:02','$2y$10$CHFP5rla7IwR6xAKix3mzOpJ0Ei2Jf0x0pIrbYYQACIzl3s5PCI9O',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(141,NULL,'Kevin','Lopez',NULL,'Klo','kevinlopezb1321@gmail.com','2026-01-04 01:53:22','$2y$10$mZ3DVhZR7iyvFYHQKBYSeO7i1/maP9ac0jkrL8uJyDtCKDrRpQ2iK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(142,NULL,'Anderson','Peña',NULL,'Afcreador','andersonpenacoach@icloud.com',NULL,'$2y$10$FpG1otUZ63UsUWJYxk/9y.NfGD7gMou1c69jV7ITjDvyawRy.iqK6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(143,NULL,'Ruth','Vasquez',NULL,'Michvs','michvs1202@gmail.com','2026-01-04 02:51:54','$2y$10$f0yyuZhh9Xcj7XR0L44U1eEnz2Fc13dTKtenb6WEGqhKvMNLCCV.G',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(144,NULL,'Bernis','Mendez',NULL,'BernisMéndez','bernisthomoe@gmail.com','2026-01-04 02:43:34','$2y$10$idoYQQHc4eFmNCe4sQuAPe.CVHRgoSCZnTcVjcpr9c4oWae0J6MfK',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(145,NULL,'Danisa','Berigüete',NULL,'Danisa_30','danisaberiguete47@gmail.com','2026-01-04 02:44:58','$2y$10$VlTEDplmWGPqmlb5jq1tjeyXQ8WvWsH7t21YkWwKo2FryOcB3f6jq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(146,NULL,'Ana rosa','Mondesi',NULL,'Aaaamor2','ripok943@stayhome.li','2026-01-04 02:49:20','$2y$10$hmFLW6bn31zzB8t9DDihp.NfHrbRtrwWUM/0YL1fnaKOFSs6O.Uaa',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(147,NULL,'adenis','paniagua',NULL,'adenis22','adenispaniaguacisd@gmail.com','2026-01-04 02:50:49','$2y$10$q.Rb59xI11wh2FLSZM7wV.dJ3aDpsxx2OrLyyPM5Hl1R0j0cRzTOu',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(148,NULL,'Loren','Ramos',NULL,'nerolsomar','Nerolramos@hotmail.com','2026-01-04 02:53:06','$2y$10$qLvOc7ZRvtYXzDBbn5Q1gO0D8qUbFZcwUgmHDr4RmwJY.XOEsBnBO',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(149,NULL,'Nicole','Santana Rojas',NULL,'Niicolesr','nicolesantanarojas@gmail.com','2026-01-04 03:03:21','$2y$10$PVsYh93159IfFjCbhglhMuvUHICJKToKuRj3HpT5QKinJte904.4q',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(150,NULL,'Yoan','Perez',NULL,'Yon','yoanrayo@gmail.com','2026-01-04 03:27:17','$2y$10$WRnvk9UCUU6E7fgu1n/XA.P4Uz8B2GApQ7YwqI69OgMr4rtSjjEf6',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(151,NULL,'Hector','Avellaneda',NULL,'Hectoravell17','havellanedapineda@gmail.com','2026-01-04 04:05:33','$2y$10$YgW6IM1Wi7j6I/pjdsWdkuoX6DcVNHtK7gRsiecl/nlgBdMGIUzQ.',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(152,NULL,'Angie','Gaona',NULL,'Vgsangie123','angievalentinagaonasierra@gmail.com','2026-01-04 04:41:18','$2y$10$LNoQGYoB7xyA0uiR5jWX3..AFztfArXRbap5R5Y7iKEs7mzGhuNVq',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(153,NULL,'Emanuel','Barrios',NULL,'Rolfcast','rolfcast@gmail.com','2026-01-04 04:38:45','$2y$10$pd0Mfdua/hmK14m4KyYAju/PS5qVYiZk.RHIBz2F1qm66QYB5d1CC',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03'),
(154,NULL,'Yimmy','Pinales',NULL,'Ynew','ynew1775@gmail.com',NULL,'$2y$10$g2XTw7ynOnjysg4/AvXVbObafKJ.i0TOXtHZ5bFEp93LT5.1m/UXe',NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,'2026-02-26 04:42:03','2026-02-26 04:42:03');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `variation_contents`
--

DROP TABLE IF EXISTS `variation_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `variation_contents` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `language_id` bigint(20) DEFAULT NULL,
  `ticket_id` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `key` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=865 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `variation_contents`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `variation_contents` WRITE;
/*!40000 ALTER TABLE `variation_contents` DISABLE KEYS */;
INSERT INTO `variation_contents` VALUES
(33,8,155,'234','0','2023-05-13 11:17:48','2023-05-13 11:17:48'),
(34,8,155,'2323','1','2023-05-13 11:17:48','2023-05-13 11:17:48'),
(35,22,155,'ewwerwer','0','2023-05-13 11:17:48','2023-05-13 11:17:48'),
(36,22,155,'234234','1','2023-05-13 11:17:48','2023-05-13 11:17:48'),
(37,8,154,'VIP en','0','2023-05-13 11:20:35','2023-05-13 11:20:35'),
(38,22,154,'VIP ar','0','2023-05-13 11:20:35','2023-05-13 11:20:35'),
(39,8,156,'Economy','0','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(40,8,156,'Business','1','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(41,8,156,'First','2','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(42,22,156,'اقتصاد','0','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(43,22,156,'عمل','1','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(44,22,156,'أولاً','2','2023-05-14 04:35:53','2023-05-14 04:35:53'),
(51,8,168,'Vip','0','2023-05-14 09:24:29','2023-05-14 09:24:29'),
(52,8,168,'Normal','1','2023-05-14 09:24:29','2023-05-14 09:24:29'),
(53,22,168,'كبار الشخصيات','0','2023-05-14 09:24:29','2023-05-14 09:24:29'),
(54,22,168,'طبيعي','1','2023-05-14 09:24:29','2023-05-14 09:24:29'),
(67,8,170,'Premium','0','2023-05-14 09:37:08','2023-05-14 09:37:08'),
(68,8,170,'First','1','2023-05-14 09:37:08','2023-05-14 09:37:08'),
(69,22,170,'غالي','0','2023-05-14 09:37:08','2023-05-14 09:37:08'),
(70,22,170,'أولاً','1','2023-05-14 09:37:08','2023-05-14 09:37:08'),
(81,8,179,'VIP en','0','2023-11-18 00:51:38','2023-11-18 00:51:38'),
(82,8,179,'Fahad en','1','2023-11-18 00:51:38','2023-11-18 00:51:38'),
(83,22,179,'VIP ar','0','2023-11-18 00:51:38','2023-11-18 00:51:38'),
(84,22,179,'dfsafaf','1','2023-11-18 00:51:38','2023-11-18 00:51:38'),
(85,8,178,'VIP en','0','2023-11-18 01:00:31','2023-11-18 01:00:31'),
(86,22,178,'VIP ar','0','2023-11-18 01:00:31','2023-11-18 01:00:31'),
(89,8,180,'fdasfasf','0','2023-11-18 01:03:46','2023-11-18 01:03:46'),
(90,22,180,'fdasfasf','0','2023-11-18 01:03:46','2023-11-18 01:03:46'),
(635,8,191,'rr44','0','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(636,8,191,'Economy','1','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(637,8,191,'tick 3 en','2','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(638,22,191,'4444','0','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(639,22,191,'اقتصاد','1','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(640,22,191,'4444','2','2025-10-21 07:25:53','2025-10-21 07:25:53'),
(643,8,188,'Economy','0','2025-10-29 05:52:54','2025-10-29 05:52:54'),
(644,22,188,'اقتصاد','0','2025-10-29 05:52:54','2025-10-29 05:52:54'),
(657,8,193,'Economy','0','2025-11-03 06:59:49','2025-11-03 06:59:49'),
(658,22,193,'4444','0','2025-11-03 06:59:49','2025-11-03 06:59:49'),
(659,8,195,'Economy','0','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(660,8,195,'Business','1','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(661,8,195,'First','2','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(662,22,195,'اقتصاد','0','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(663,22,195,'عمل','1','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(664,22,195,'أولاً','2','2025-11-06 01:17:05','2025-11-06 01:17:05'),
(707,8,205,'Economy','0','2025-11-08 07:55:07','2025-11-08 07:55:07'),
(708,8,205,'Standard','1','2025-11-08 07:55:07','2025-11-08 07:55:07'),
(709,22,205,'اقتصاد','0','2025-11-08 07:55:07','2025-11-08 07:55:07'),
(710,22,205,'معيار','1','2025-11-08 07:55:07','2025-11-08 07:55:07'),
(849,8,198,'North Preferred','0','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(850,8,198,'East Preferred','1','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(851,8,198,'West Preferred','2','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(852,8,198,'South Preferred','3','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(853,22,198,'الغرب المفضل','0','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(854,22,198,'الشرق المفضل','1','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(855,22,198,'الشمال المفضل','2','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(856,22,198,'الجنوب المفضل','3','2025-11-10 06:31:18','2025-11-10 06:31:18'),
(861,8,209,'Economy','0','2025-11-10 06:32:23','2025-11-10 06:32:23'),
(862,8,209,'Economy','1','2025-11-10 06:32:23','2025-11-10 06:32:23'),
(863,22,209,'الغرب المفضل','0','2025-11-10 06:32:23','2025-11-10 06:32:23'),
(864,22,209,'الغرب المفضل','1','2025-11-10 06:32:23','2025-11-10 06:32:23');
/*!40000 ALTER TABLE `variation_contents` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `venues`
--

DROP TABLE IF EXISTS `venues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `venues` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `address` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `zip_code` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,8) DEFAULT NULL,
  `longitude` decimal(11,8) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `amount` decimal(20,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `venues_slug_unique` (`slug`),
  UNIQUE KEY `venues_username_unique` (`username`),
  UNIQUE KEY `venues_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venues`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `venues` WRITE;
/*!40000 ALTER TABLE `venues` DISABLE KEYS */;
/*!40000 ALTER TABLE `venues` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wallet_holds`
--

DROP TABLE IF EXISTS `wallet_holds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_holds` (
  `id` char(36) NOT NULL,
  `wallet_id` char(36) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `expires_at` timestamp NOT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `status` enum('active','released','consumed') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wallet_holds_wallet_id_foreign` (`wallet_id`),
  CONSTRAINT `wallet_holds_wallet_id_foreign` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_holds`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wallet_holds` WRITE;
/*!40000 ALTER TABLE `wallet_holds` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallet_holds` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wallet_transactions`
--

DROP TABLE IF EXISTS `wallet_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallet_transactions` (
  `id` char(36) NOT NULL,
  `wallet_id` char(36) NOT NULL,
  `type` enum('credit','debit','hold_release','admin_adjustment') NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` varchar(255) DEFAULT NULL,
  `idempotency_key` varchar(255) NOT NULL,
  `status` enum('pending','completed','failed','reversed') NOT NULL DEFAULT 'completed',
  `created_by` bigint(20) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `wallet_transactions_idempotency_key_unique` (`idempotency_key`),
  KEY `wallet_transactions_wallet_id_foreign` (`wallet_id`),
  CONSTRAINT `wallet_transactions_wallet_id_foreign` FOREIGN KEY (`wallet_id`) REFERENCES `wallets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_transactions`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wallet_transactions` WRITE;
/*!40000 ALTER TABLE `wallet_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallet_transactions` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wallets`
--

DROP TABLE IF EXISTS `wallets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wallets` (
  `id` char(36) NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `balance` decimal(10,2) NOT NULL DEFAULT 0.00,
  `currency` char(3) NOT NULL DEFAULT 'DOP',
  `status` enum('active','frozen') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `wallets_user_id_foreign` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallets`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wallets` WRITE;
/*!40000 ALTER TABLE `wallets` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallets` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `wishlists`
--

DROP TABLE IF EXISTS `wishlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `wishlists` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) NOT NULL,
  `event_id` int(11) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=53 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wishlists`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `wishlists` WRITE;
/*!40000 ALTER TABLE `wishlists` DISABLE KEYS */;
/*!40000 ALTER TABLE `wishlists` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `withdraw_method_inputs`
--

DROP TABLE IF EXISTS `withdraw_method_inputs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdraw_method_inputs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `withdraw_payment_method_id` int(11) NOT NULL,
  `type` tinyint(4) DEFAULT NULL COMMENT '1-text, 2-select, 3-checkbox, 4-textarea, 5-datepicker, 6-timepicker, 7-number',
  `label` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `placeholder` varchar(255) DEFAULT NULL,
  `required` tinyint(4) NOT NULL DEFAULT 0 COMMENT '1-required, 0- optional',
  `order_number` int(11) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdraw_method_inputs`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `withdraw_method_inputs` WRITE;
/*!40000 ALTER TABLE `withdraw_method_inputs` DISABLE KEYS */;
INSERT INTO `withdraw_method_inputs` VALUES
(15,4,7,'Contact Number','Contact_Number','Enter Contact Number',1,1,'2023-01-17 10:52:21','2025-11-01 00:23:24'),
(16,5,1,'Account No','Account_No','Enter Account Number',1,1,'2023-01-21 06:37:04','2023-01-21 06:37:04'),
(17,4,1,'Address','Address','ADDRESS',1,2,'2025-10-08 00:30:29','2025-11-01 00:23:24'),
(18,6,4,'Address','Address','Enter Address',1,1,'2025-10-08 00:31:47','2025-10-08 00:31:47');
/*!40000 ALTER TABLE `withdraw_method_inputs` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `withdraw_method_options`
--

DROP TABLE IF EXISTS `withdraw_method_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdraw_method_options` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `withdraw_method_input_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdraw_method_options`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `withdraw_method_options` WRITE;
/*!40000 ALTER TABLE `withdraw_method_options` DISABLE KEYS */;
/*!40000 ALTER TABLE `withdraw_method_options` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `withdraw_payment_methods`
--

DROP TABLE IF EXISTS `withdraw_payment_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdraw_payment_methods` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `fixed_charge` float(8,2) DEFAULT 0.00,
  `percentage_charge` float DEFAULT 0,
  `min_limit` varchar(255) NOT NULL,
  `max_limit` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdraw_payment_methods`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `withdraw_payment_methods` WRITE;
/*!40000 ALTER TABLE `withdraw_payment_methods` DISABLE KEYS */;
INSERT INTO `withdraw_payment_methods` VALUES
(4,10.00,20,'50','1000','Bitcoin',1,'2023-01-05 10:52:20','2023-05-06 10:31:42'),
(5,3.00,4,'10','100','Perfect Money',1,'2023-01-05 11:02:57','2023-01-05 11:02:57'),
(6,0.00,5,'63','400','Louis Copeland',1,'2025-10-08 00:30:18','2025-10-08 00:33:42');
/*!40000 ALTER TABLE `withdraw_payment_methods` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `withdrawal_requests`
--

DROP TABLE IF EXISTS `withdrawal_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdrawal_requests` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint(20) unsigned NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `method` varchar(255) NOT NULL,
  `payment_details` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`payment_details`)),
  `status` enum('pending','approved','rejected','completed') NOT NULL DEFAULT 'pending',
  `admin_notes` text DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `withdrawal_requests_customer_id_foreign` (`customer_id`),
  CONSTRAINT `withdrawal_requests_customer_id_foreign` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdrawal_requests`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `withdrawal_requests` WRITE;
/*!40000 ALTER TABLE `withdrawal_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `withdrawal_requests` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;

--
-- Table structure for table `withdraws`
--

DROP TABLE IF EXISTS `withdraws`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `withdraws` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `organizer_id` int(11) NOT NULL,
  `venue_id` bigint(20) unsigned DEFAULT NULL,
  `artist_id` bigint(20) unsigned DEFAULT NULL,
  `withdraw_id` varchar(255) DEFAULT NULL,
  `method_id` int(11) NOT NULL,
  `amount` varchar(255) NOT NULL,
  `payable_amount` float(8,2) DEFAULT 0.00,
  `total_charge` float(8,2) DEFAULT 0.00,
  `additional_reference` longtext DEFAULT NULL,
  `feilds` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0-pending, 1-approved, 2-decline',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `withdraws`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `withdraws` WRITE;
/*!40000 ALTER TABLE `withdraws` DISABLE KEYS */;
/*!40000 ALTER TABLE `withdraws` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-02-26  0:54:09
