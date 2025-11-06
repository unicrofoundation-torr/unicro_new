-- MySQL dump 10.13  Distrib 8.0.37, for Win64 (x86_64)
--
-- Host: localhost    Database: charity_website
-- ------------------------------------------------------
-- Server version	8.0.37

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admin_users`
--

DROP TABLE IF EXISTS `admin_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_users` (
  `id` int NOT NULL AUTO_INCREMENT,
  `username` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` enum('admin','editor') DEFAULT 'editor',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admin_users`
--

LOCK TABLES `admin_users` WRITE;
/*!40000 ALTER TABLE `admin_users` DISABLE KEYS */;
INSERT INTO `admin_users` VALUES (3,'admin','admin@unicrofoundation.org','$2a$10$DR3XS6oJeJ/7aW361R7//eycPNebZb3HBaSLAU47BPbLWxsxDxRBq','admin','2025-10-16 07:34:33','2025-10-16 11:05:47');
/*!40000 ALTER TABLE `admin_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `blogs`
--

DROP TABLE IF EXISTS `blogs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `blogs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` text,
  `content` text NOT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `image_alt` varchar(255) DEFAULT NULL,
  `author` varchar(100) DEFAULT 'Admin',
  `is_published` tinyint(1) DEFAULT '1',
  `sort_order` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `blogs`
--

LOCK TABLES `blogs` WRITE;
/*!40000 ALTER TABLE `blogs` DISABLE KEYS */;
INSERT INTO `blogs` VALUES (1,'The One Rupee Revolution — 20‑Stage Chain Donation Roadmap','the-one-rupee-revolution-20stage-chain-donation-roadmap','The Unicro Growth Model shows how just ₹1/day, multiplied through community participation (3x at every level), can fund everything from the first cup of tea for a community worker to national-scale education, healthcare, and clean energy programs. Starting with one donor and growing to 140 crore, this vision proves that collective micro-giving can create massive social impact — one rupee, one person, one story at a time.','<h2 data-start=\"439\" data-end=\"466\"><strong data-start=\"442\" data-end=\"466\">Stage 1 &mdash; Seed Spark</strong></h2>\r\n<p data-start=\"467\" data-end=\"578\"><strong data-start=\"467\" data-end=\"492\">People in this stage:</strong> 1<br data-start=\"494\" data-end=\"497\"><strong data-start=\"497\" data-end=\"519\">Cumulative People:</strong> 1<br data-start=\"521\" data-end=\"524\"><strong data-start=\"524\" data-end=\"543\">Daily Donation:</strong> ₹1<br data-start=\"546\" data-end=\"549\"><strong data-start=\"549\" data-end=\"572\">Monthly Equivalent:</strong> ₹30</p>\r\n<p data-start=\"580\" data-end=\"745\"><strong data-start=\"580\" data-end=\"600\">What we will do:</strong><br data-start=\"600\" data-end=\"603\">Use ₹1/day to publish an inspirational post and run a micro-campaign.<br data-start=\"672\" data-end=\"675\">Buy tea/refreshment for a community worker &mdash; document the first spark.</p>\r\n<hr data-start=\"747\" data-end=\"750\">\r\n<h2 data-start=\"752\" data-end=\"783\"><strong data-start=\"755\" data-end=\"783\">Stage 2 &mdash; Local Mobilise</strong></h2>\r\n<p data-start=\"784\" data-end=\"864\"><strong data-start=\"784\" data-end=\"795\">People:</strong> 3<br data-start=\"797\" data-end=\"800\"><strong data-start=\"800\" data-end=\"815\">Cumulative:</strong> 4<br data-start=\"817\" data-end=\"820\"><strong data-start=\"820\" data-end=\"839\">Daily Donation:</strong> ₹4<br data-start=\"842\" data-end=\"845\"><strong data-start=\"845\" data-end=\"857\">Monthly:</strong> ₹120</p>\r\n<p data-start=\"866\" data-end=\"1014\"><strong data-start=\"866\" data-end=\"886\">What we will do:</strong><br data-start=\"886\" data-end=\"889\">Provide stationery for 2&ndash;3 children in a government school.<br data-start=\"948\" data-end=\"951\">Start a local WhatsApp group for coordination and storytelling.</p>\r\n<hr data-start=\"1016\" data-end=\"1019\">\r\n<h2 data-start=\"1021\" data-end=\"1056\"><strong data-start=\"1024\" data-end=\"1056\">Stage 3 &mdash; Health &amp; First Aid</strong></h2>\r\n<p data-start=\"1057\" data-end=\"1139\"><strong data-start=\"1057\" data-end=\"1068\">People:</strong> 9<br data-start=\"1070\" data-end=\"1073\"><strong data-start=\"1073\" data-end=\"1088\">Cumulative:</strong> 13<br data-start=\"1091\" data-end=\"1094\"><strong data-start=\"1094\" data-end=\"1113\">Daily Donation:</strong> ₹13<br data-start=\"1117\" data-end=\"1120\"><strong data-start=\"1120\" data-end=\"1132\">Monthly:</strong> ₹390</p>\r\n<p data-start=\"1141\" data-end=\"1231\"><strong data-start=\"1141\" data-end=\"1161\">What we will do:</strong><br data-start=\"1161\" data-end=\"1164\">Purchase first-aid kits and supplies for a community health worker.</p>\r\n<hr data-start=\"1233\" data-end=\"1236\">\r\n<h2 data-start=\"1238\" data-end=\"1269\"><strong data-start=\"1241\" data-end=\"1269\">Stage 4 &mdash; Community Meal</strong></h2>\r\n<p data-start=\"1270\" data-end=\"1355\"><strong data-start=\"1270\" data-end=\"1281\">People:</strong> 27<br data-start=\"1284\" data-end=\"1287\"><strong data-start=\"1287\" data-end=\"1302\">Cumulative:</strong> 40<br data-start=\"1305\" data-end=\"1308\"><strong data-start=\"1308\" data-end=\"1327\">Daily Donation:</strong> ₹40<br data-start=\"1331\" data-end=\"1334\"><strong data-start=\"1334\" data-end=\"1346\">Monthly:</strong> ₹1,200</p>\r\n<p data-start=\"1357\" data-end=\"1450\"><strong data-start=\"1357\" data-end=\"1377\">What we will do:</strong><br data-start=\"1377\" data-end=\"1380\">Sponsor community meals for ~40 people weekly via a community kitchen.</p>\r\n<hr data-start=\"1452\" data-end=\"1455\">\r\n<h2 data-start=\"1457\" data-end=\"1493\"><strong data-start=\"1460\" data-end=\"1493\">Stage 5 &mdash; School Support Pack</strong></h2>\r\n<p data-start=\"1494\" data-end=\"1581\"><strong data-start=\"1494\" data-end=\"1505\">People:</strong> 81<br data-start=\"1508\" data-end=\"1511\"><strong data-start=\"1511\" data-end=\"1526\">Cumulative:</strong> 121<br data-start=\"1530\" data-end=\"1533\"><strong data-start=\"1533\" data-end=\"1552\">Daily Donation:</strong> ₹121<br data-start=\"1557\" data-end=\"1560\"><strong data-start=\"1560\" data-end=\"1572\">Monthly:</strong> ₹3,630</p>\r\n<p data-start=\"1583\" data-end=\"1726\"><strong data-start=\"1583\" data-end=\"1603\">What we will do:</strong><br data-start=\"1603\" data-end=\"1606\">Provide uniforms and learning kits for 20&ndash;30 underprivileged children.<br data-start=\"1676\" data-end=\"1679\">Host monthly storytelling and reading sessions.</p>\r\n<hr data-start=\"1728\" data-end=\"1731\">\r\n<h2 data-start=\"1733\" data-end=\"1768\"><strong data-start=\"1736\" data-end=\"1768\">Stage 6 &mdash; Clean Water Access</strong></h2>\r\n<p data-start=\"1769\" data-end=\"1858\"><strong data-start=\"1769\" data-end=\"1780\">People:</strong> 243<br data-start=\"1784\" data-end=\"1787\"><strong data-start=\"1787\" data-end=\"1802\">Cumulative:</strong> 364<br data-start=\"1806\" data-end=\"1809\"><strong data-start=\"1809\" data-end=\"1828\">Daily Donation:</strong> ₹364<br data-start=\"1833\" data-end=\"1836\"><strong data-start=\"1836\" data-end=\"1848\">Monthly:</strong> ₹10,920</p>\r\n<p data-start=\"1860\" data-end=\"1961\"><strong data-start=\"1860\" data-end=\"1880\">What we will do:</strong><br data-start=\"1880\" data-end=\"1883\">Install 1&ndash;2 water purifiers in villages; fund initial maintenance and filters.</p>\r\n<hr data-start=\"1963\" data-end=\"1966\">\r\n<h2 data-start=\"1968\" data-end=\"2011\"><strong data-start=\"1971\" data-end=\"2011\">Stage 7 &mdash; Women Hygiene &amp; Livelihood</strong></h2>\r\n<p data-start=\"2012\" data-end=\"2105\"><strong data-start=\"2012\" data-end=\"2023\">People:</strong> 729<br data-start=\"2027\" data-end=\"2030\"><strong data-start=\"2030\" data-end=\"2045\">Cumulative:</strong> 1,093<br data-start=\"2051\" data-end=\"2054\"><strong data-start=\"2054\" data-end=\"2073\">Daily Donation:</strong> ₹1,093<br data-start=\"2080\" data-end=\"2083\"><strong data-start=\"2083\" data-end=\"2095\">Monthly:</strong> ₹32,790</p>\r\n<p data-start=\"2107\" data-end=\"2253\"><strong data-start=\"2107\" data-end=\"2127\">What we will do:</strong><br data-start=\"2127\" data-end=\"2130\">Distribute menstrual hygiene kits and seed funds for women&rsquo;s self-help groups.<br data-start=\"2208\" data-end=\"2211\">Run quarterly vocational training batches.</p>\r\n<hr data-start=\"2255\" data-end=\"2258\">\r\n<h2 data-start=\"2260\" data-end=\"2302\"><strong data-start=\"2263\" data-end=\"2302\">Stage 8 &mdash; Mobile Library &amp; Learning</strong></h2>\r\n<p data-start=\"2303\" data-end=\"2398\"><strong data-start=\"2303\" data-end=\"2314\">People:</strong> 2,187<br data-start=\"2320\" data-end=\"2323\"><strong data-start=\"2323\" data-end=\"2338\">Cumulative:</strong> 3,280<br data-start=\"2344\" data-end=\"2347\"><strong data-start=\"2347\" data-end=\"2366\">Daily Donation:</strong> ₹3,280<br data-start=\"2373\" data-end=\"2376\"><strong data-start=\"2376\" data-end=\"2388\">Monthly:</strong> ₹98,400</p>\r\n<p data-start=\"2400\" data-end=\"2483\"><strong data-start=\"2400\" data-end=\"2420\">What we will do:</strong><br data-start=\"2420\" data-end=\"2423\">Launch a mobile library van serving several villages weekly.</p>\r\n<hr data-start=\"2485\" data-end=\"2488\">\r\n<h2 data-start=\"2490\" data-end=\"2531\"><strong data-start=\"2493\" data-end=\"2531\">Stage 9 &mdash; Primary Healthcare Camps</strong></h2>\r\n<p data-start=\"2532\" data-end=\"2629\"><strong data-start=\"2532\" data-end=\"2543\">People:</strong> 6,561<br data-start=\"2549\" data-end=\"2552\"><strong data-start=\"2552\" data-end=\"2567\">Cumulative:</strong> 9,841<br data-start=\"2573\" data-end=\"2576\"><strong data-start=\"2576\" data-end=\"2595\">Daily Donation:</strong> ₹9,841<br data-start=\"2602\" data-end=\"2605\"><strong data-start=\"2605\" data-end=\"2617\">Monthly:</strong> ₹2,95,230</p>\r\n<p data-start=\"2631\" data-end=\"2727\"><strong data-start=\"2631\" data-end=\"2651\">What we will do:</strong><br data-start=\"2651\" data-end=\"2654\">Organize monthly healthcare camps covering vaccination and maternal care.</p>\r\n<hr data-start=\"2729\" data-end=\"2732\">\r\n<h2 data-start=\"2734\" data-end=\"2777\"><strong data-start=\"2737\" data-end=\"2777\">Stage 10 &mdash; Micro-Scholarship Program</strong></h2>\r\n<p data-start=\"2778\" data-end=\"2878\"><strong data-start=\"2778\" data-end=\"2789\">People:</strong> 19,683<br data-start=\"2796\" data-end=\"2799\"><strong data-start=\"2799\" data-end=\"2814\">Cumulative:</strong> 29,524<br data-start=\"2821\" data-end=\"2824\"><strong data-start=\"2824\" data-end=\"2843\">Daily Donation:</strong> ₹29,524<br data-start=\"2851\" data-end=\"2854\"><strong data-start=\"2854\" data-end=\"2866\">Monthly:</strong> ₹8,85,720</p>\r\n<p data-start=\"2880\" data-end=\"2971\"><strong data-start=\"2880\" data-end=\"2900\">What we will do:</strong><br data-start=\"2900\" data-end=\"2903\">Provide scholarships and digital devices for ~200 students annually.</p>\r\n<hr data-start=\"2973\" data-end=\"2976\">\r\n<h2 data-start=\"2978\" data-end=\"3014\"><strong data-start=\"2981\" data-end=\"3014\">Stage 11 &mdash; Clean Energy Pilot</strong></h2>\r\n<p data-start=\"3015\" data-end=\"3116\"><strong data-start=\"3015\" data-end=\"3026\">People:</strong> 59,049<br data-start=\"3033\" data-end=\"3036\"><strong data-start=\"3036\" data-end=\"3051\">Cumulative:</strong> 88,573<br data-start=\"3058\" data-end=\"3061\"><strong data-start=\"3061\" data-end=\"3080\">Daily Donation:</strong> ₹88,573<br data-start=\"3088\" data-end=\"3091\"><strong data-start=\"3091\" data-end=\"3103\">Monthly:</strong> ₹26,57,190</p>\r\n<p data-start=\"3118\" data-end=\"3207\"><strong data-start=\"3118\" data-end=\"3138\">What we will do:</strong><br data-start=\"3138\" data-end=\"3141\">Install solar microgrids and solar street lighting in rural areas.</p>\r\n<hr data-start=\"3209\" data-end=\"3212\">\r\n<h2 data-start=\"3214\" data-end=\"3256\"><strong data-start=\"3217\" data-end=\"3256\">Stage 12 &mdash; Water &amp; Sanitation Drive</strong></h2>\r\n<p data-start=\"3257\" data-end=\"3364\"><strong data-start=\"3257\" data-end=\"3268\">People:</strong> 1,77,147<br data-start=\"3277\" data-end=\"3280\"><strong data-start=\"3280\" data-end=\"3295\">Cumulative:</strong> 2,65,720<br data-start=\"3304\" data-end=\"3307\"><strong data-start=\"3307\" data-end=\"3326\">Daily Donation:</strong> ₹2,65,720<br data-start=\"3336\" data-end=\"3339\"><strong data-start=\"3339\" data-end=\"3351\">Monthly:</strong> ₹79,71,600</p>\r\n<p data-start=\"3366\" data-end=\"3462\"><strong data-start=\"3366\" data-end=\"3386\">What we will do:</strong><br data-start=\"3386\" data-end=\"3389\">Build community toilets, fix handpumps, and run hygiene awareness drives.</p>\r\n<hr data-start=\"3464\" data-end=\"3467\">\r\n<h2 data-start=\"3469\" data-end=\"3507\"><strong data-start=\"3472\" data-end=\"3507\">Stage 13 &mdash; Telemedicine Network</strong></h2>\r\n<p data-start=\"3508\" data-end=\"3617\"><strong data-start=\"3508\" data-end=\"3519\">People:</strong> 5,31,441<br data-start=\"3528\" data-end=\"3531\"><strong data-start=\"3531\" data-end=\"3546\">Cumulative:</strong> 7,97,161<br data-start=\"3555\" data-end=\"3558\"><strong data-start=\"3558\" data-end=\"3577\">Daily Donation:</strong> ₹7,97,161<br data-start=\"3587\" data-end=\"3590\"><strong data-start=\"3590\" data-end=\"3602\">Monthly:</strong> ₹2,39,14,830</p>\r\n<p data-start=\"3619\" data-end=\"3722\"><strong data-start=\"3619\" data-end=\"3639\">What we will do:</strong><br data-start=\"3639\" data-end=\"3642\">Set up telemedicine kiosks and connect local health workers with remote doctors.</p>\r\n<hr data-start=\"3724\" data-end=\"3727\">\r\n<h2 data-start=\"3729\" data-end=\"3766\"><strong data-start=\"3732\" data-end=\"3766\">Stage 14 &mdash; Regional Skill Hubs</strong></h2>\r\n<p data-start=\"3767\" data-end=\"3879\"><strong data-start=\"3767\" data-end=\"3778\">People:</strong> 15,94,323<br data-start=\"3788\" data-end=\"3791\"><strong data-start=\"3791\" data-end=\"3806\">Cumulative:</strong> 23,91,484<br data-start=\"3816\" data-end=\"3819\"><strong data-start=\"3819\" data-end=\"3838\">Daily Donation:</strong> ₹23,91,484<br data-start=\"3849\" data-end=\"3852\"><strong data-start=\"3852\" data-end=\"3864\">Monthly:</strong> ₹7,17,44,520</p>\r\n<p data-start=\"3881\" data-end=\"4019\"><strong data-start=\"3881\" data-end=\"3901\">What we will do:</strong><br data-start=\"3901\" data-end=\"3904\">Create regional skill-training hubs in digital, agri-tech, and crafts.<br data-start=\"3974\" data-end=\"3977\">Support micro-enterprises with mentorship.</p>\r\n<hr data-start=\"4021\" data-end=\"4024\">\r\n<h2 data-start=\"4026\" data-end=\"4075\"><strong data-start=\"4029\" data-end=\"4075\">Stage 15 &mdash; Maternal &amp; Child Health Program</strong></h2>\r\n<p data-start=\"4076\" data-end=\"4189\"><strong data-start=\"4076\" data-end=\"4087\">People:</strong> 47,82,969<br data-start=\"4097\" data-end=\"4100\"><strong data-start=\"4100\" data-end=\"4115\">Cumulative:</strong> 71,74,453<br data-start=\"4125\" data-end=\"4128\"><strong data-start=\"4128\" data-end=\"4147\">Daily Donation:</strong> ₹71,74,453<br data-start=\"4158\" data-end=\"4161\"><strong data-start=\"4161\" data-end=\"4173\">Monthly:</strong> ₹21,52,33,590</p>\r\n<p data-start=\"4191\" data-end=\"4293\"><strong data-start=\"4191\" data-end=\"4211\">What we will do:</strong><br data-start=\"4211\" data-end=\"4214\">Support maternal and neonatal health, ambulance services, and midwife training.</p>\r\n<hr data-start=\"4295\" data-end=\"4298\">\r\n<h2 data-start=\"4300\" data-end=\"4351\"><strong data-start=\"4303\" data-end=\"4351\">Stage 16 &mdash; School &amp; Community Digitalisation</strong></h2>\r\n<p data-start=\"4352\" data-end=\"4471\"><strong data-start=\"4352\" data-end=\"4363\">People:</strong> 1,43,48,907<br data-start=\"4375\" data-end=\"4378\"><strong data-start=\"4378\" data-end=\"4393\">Cumulative:</strong> 2,15,23,360<br data-start=\"4405\" data-end=\"4408\"><strong data-start=\"4408\" data-end=\"4427\">Daily Donation:</strong> ₹2,15,23,360<br data-start=\"4440\" data-end=\"4443\"><strong data-start=\"4443\" data-end=\"4455\">Monthly:</strong> ₹64,57,00,800</p>\r\n<p data-start=\"4473\" data-end=\"4570\"><strong data-start=\"4473\" data-end=\"4493\">What we will do:</strong><br data-start=\"4493\" data-end=\"4496\">Deploy digital classrooms and teacher training across hundreds of schools.</p>\r\n<hr data-start=\"4572\" data-end=\"4575\">\r\n<h2 data-start=\"4577\" data-end=\"4632\"><strong data-start=\"4580\" data-end=\"4632\">Stage 17 &mdash; Rural Electrification &amp; Solar Farming</strong></h2>\r\n<p data-start=\"4633\" data-end=\"4754\"><strong data-start=\"4633\" data-end=\"4644\">People:</strong> 4,30,46,721<br data-start=\"4656\" data-end=\"4659\"><strong data-start=\"4659\" data-end=\"4674\">Cumulative:</strong> 6,45,70,081<br data-start=\"4686\" data-end=\"4689\"><strong data-start=\"4689\" data-end=\"4708\">Daily Donation:</strong> ₹6,45,70,081<br data-start=\"4721\" data-end=\"4724\"><strong data-start=\"4724\" data-end=\"4736\">Monthly:</strong> ₹1,93,71,02,430</p>\r\n<p data-start=\"4756\" data-end=\"4846\"><strong data-start=\"4756\" data-end=\"4776\">What we will do:</strong><br data-start=\"4776\" data-end=\"4779\">Invest in community solar farms and energy-for-livelihood programs.</p>\r\n<hr data-start=\"4848\" data-end=\"4851\">\r\n<h2 data-start=\"4853\" data-end=\"4905\"><strong data-start=\"4856\" data-end=\"4905\">Stage 18 &mdash; Large-scale Livelihoods Initiative</strong></h2>\r\n<p data-start=\"4906\" data-end=\"5030\"><strong data-start=\"4906\" data-end=\"4917\">People:</strong> 12,91,40,163<br data-start=\"4930\" data-end=\"4933\"><strong data-start=\"4933\" data-end=\"4948\">Cumulative:</strong> 19,37,10,244<br data-start=\"4961\" data-end=\"4964\"><strong data-start=\"4964\" data-end=\"4983\">Daily Donation:</strong> ₹19,37,10,244<br data-start=\"4997\" data-end=\"5000\"><strong data-start=\"5000\" data-end=\"5012\">Monthly:</strong> ₹5,81,13,07,320</p>\r\n<p data-start=\"5032\" data-end=\"5133\"><strong data-start=\"5032\" data-end=\"5052\">What we will do:</strong><br data-start=\"5052\" data-end=\"5055\">Launch national livelihood programs with training and microenterprise funding.</p>\r\n<hr data-start=\"5135\" data-end=\"5138\">\r\n<h2 data-start=\"5140\" data-end=\"5186\"><strong data-start=\"5143\" data-end=\"5186\">Stage 19 &mdash; Public Health Infrastructure</strong></h2>\r\n<p data-start=\"5187\" data-end=\"5312\"><strong data-start=\"5187\" data-end=\"5198\">People:</strong> 38,74,20,489<br data-start=\"5211\" data-end=\"5214\"><strong data-start=\"5214\" data-end=\"5229\">Cumulative:</strong> 58,11,30,733<br data-start=\"5242\" data-end=\"5245\"><strong data-start=\"5245\" data-end=\"5264\">Daily Donation:</strong> ₹58,11,30,733<br data-start=\"5278\" data-end=\"5281\"><strong data-start=\"5281\" data-end=\"5293\">Monthly:</strong> ₹17,43,39,21,990</p>\r\n<p data-start=\"5314\" data-end=\"5410\"><strong data-start=\"5314\" data-end=\"5334\">What we will do:</strong><br data-start=\"5334\" data-end=\"5337\">Build and operate primary health centers and emergency response networks.</p>\r\n<hr data-start=\"5412\" data-end=\"5415\">\r\n<h2 data-start=\"5417\" data-end=\"5464\"><strong data-start=\"5420\" data-end=\"5464\">Stage 20 &mdash; National-scale Transformation</strong></h2>\r\n<p data-start=\"5465\" data-end=\"5596\"><strong data-start=\"5465\" data-end=\"5476\">People:</strong> 1,16,22,61,467<br data-start=\"5491\" data-end=\"5494\"><strong data-start=\"5494\" data-end=\"5509\">Cumulative:</strong> 1,40,00,00,000<br data-start=\"5524\" data-end=\"5527\"><strong data-start=\"5527\" data-end=\"5546\">Daily Donation:</strong> ₹1,40,00,00,000<br data-start=\"5562\" data-end=\"5565\"><strong data-start=\"5565\" data-end=\"5577\">Monthly:</strong> ₹42,00,00,00,000</p>\r\n<p data-start=\"5598\" data-end=\"5770\"><strong data-start=\"5598\" data-end=\"5618\">What we will do:</strong><br data-start=\"5618\" data-end=\"5621\">Fund nationwide education, renewable energy, healthcare, and clean water programs &mdash; creating impact at the scale of a national non-profit consortium.</p>\r\n<hr data-start=\"5772\" data-end=\"5775\">\r\n<h2 data-start=\"5777\" data-end=\"5800\"><strong data-start=\"5780\" data-end=\"5800\">How You Can Help</strong></h2>\r\n<ul data-start=\"5801\" data-end=\"6088\">\r\n<li data-start=\"5801\" data-end=\"5877\">\r\n<p data-start=\"5803\" data-end=\"5877\">🌟 <strong data-start=\"5806\" data-end=\"5833\">Become the first spark:</strong> Start by donating and inviting 3 friends.</p>\r\n</li>\r\n<li data-start=\"5878\" data-end=\"5938\">\r\n<p data-start=\"5880\" data-end=\"5938\">📢 <strong data-start=\"5883\" data-end=\"5901\">Share stories:</strong> Spread small wins on social media.</p>\r\n</li>\r\n<li data-start=\"5939\" data-end=\"6015\">\r\n<p data-start=\"5941\" data-end=\"6015\">🤝 <strong data-start=\"5944\" data-end=\"5966\">Volunteer locally:</strong> Help amplify project delivery and build trust.</p>\r\n</li>\r\n<li data-start=\"6016\" data-end=\"6088\">\r\n<p data-start=\"6018\" data-end=\"6088\">💧 <strong data-start=\"6021\" data-end=\"6042\">Contribute daily:</strong> Even ₹1/day can build a movement of change.</p>\r\n</li>\r\n</ul>','/uploads/blogs/image-1762415018037-310476965.png',NULL,'Unicro Foundation',1,0,'2025-11-06 07:43:38','2025-11-06 07:46:51');
/*!40000 ALTER TABLE `blogs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_messages`
--

DROP TABLE IF EXISTS `contact_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contact_messages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) DEFAULT '',
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_messages`
--

LOCK TABLES `contact_messages` WRITE;
/*!40000 ALTER TABLE `contact_messages` DISABLE KEYS */;
INSERT INTO `contact_messages` VALUES (1,'kanishk raj singh dodiya','k@GMAIL.COM','DEMO','HHRU','2025-10-30 11:58:53');
/*!40000 ALTER TABLE `contact_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `donations`
--

DROP TABLE IF EXISTS `donations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `donor_id` int NOT NULL,
  `amount` int NOT NULL,
  `currency` varchar(10) DEFAULT 'INR',
  `purpose` varchar(255) DEFAULT '',
  `note` varchar(255) DEFAULT '',
  `cf_order_id` varchar(100) DEFAULT NULL,
  `cf_order_token` varchar(255) DEFAULT NULL,
  `cf_payment_id` varchar(100) DEFAULT NULL,
  `status` enum('created','paid','failed','refunded') DEFAULT 'created',
  `metadata` json DEFAULT NULL,
  `receipt_number` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `donor_id` (`donor_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donations`
--

LOCK TABLES `donations` WRITE;
/*!40000 ALTER TABLE `donations` DISABLE KEYS */;
INSERT INTO `donations` VALUES (1,1,5000,'INR','','india',NULL,NULL,NULL,'created','{}',NULL,'2025-10-30 13:15:57','2025-10-30 13:15:57'),(2,2,10000,'INR','','india',NULL,NULL,NULL,'created','{}',NULL,'2025-10-30 13:20:05','2025-10-30 13:20:05');
/*!40000 ALTER TABLE `donations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `donors`
--

DROP TABLE IF EXISTS `donors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `donors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `phone` varchar(50) DEFAULT '',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `donors`
--

LOCK TABLES `donors` WRITE;
/*!40000 ALTER TABLE `donors` DISABLE KEYS */;
INSERT INTO `donors` VALUES (1,'kanishkraj','kanishk@gmail.com','8103316602','2025-10-30 13:15:57'),(2,'kaniskhraj','k@gamil.com','8103316602','2025-10-30 13:20:05');
/*!40000 ALTER TABLE `donors` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `footer_settings`
--

DROP TABLE IF EXISTS `footer_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `footer_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `setting_type` enum('text','url','email','phone','address') DEFAULT 'text',
  `section` varchar(50) NOT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `footer_settings`
--

LOCK TABLES `footer_settings` WRITE;
/*!40000 ALTER TABLE `footer_settings` DISABLE KEYS */;
INSERT INTO `footer_settings` VALUES (1,'footer_description','Empowering change through the power of small donations. Every ₹1 makes a difference in creating a better world for all.','text','foundation',1,1,'Foundation description text','2025-10-16 11:24:59','2025-10-30 10:45:08'),(2,'newsletter_title','Stay Updated','text','newsletter',1,1,'Newsletter signup title','2025-10-16 11:24:59','2025-10-30 10:45:08'),(3,'newsletter_placeholder','Enter your email','text','newsletter',2,1,'Newsletter input placeholder','2025-10-16 11:24:59','2025-10-30 10:45:08'),(4,'newsletter_button','Subscribe','text','newsletter',3,1,'Newsletter subscribe button text','2025-10-16 11:24:59','2025-10-30 10:45:08'),(5,'footer_address_line1','88,choudhary colony,','text','contact',1,1,'Address line 1','2025-10-16 11:24:59','2025-10-30 10:45:08'),(6,'footer_address_line2',' Nai Abadi ','text','contact',2,1,'Address line 2','2025-10-16 11:24:59','2025-10-30 10:45:08'),(7,'footer_address_line3','Mandsaur 458001 (M.P.)','text','contact',3,1,'Address line 3','2025-10-16 11:24:59','2025-10-30 10:45:08'),(8,'footer_email','info@unicrofoundation.org','email','contact',4,1,'Footer contact email','2025-10-16 11:24:59','2025-10-30 10:45:08'),(9,'footer_phone','','phone','contact',5,1,'Footer contact phone','2025-10-16 11:24:59','2025-10-30 10:45:08'),(10,'social_twitter','https://twitter.com/unicrofoundation','url','social',1,1,'Twitter profile URL','2025-10-16 11:24:59','2025-10-30 10:45:08'),(11,'social_facebook','https://facebook.com/unicrofoundation','url','social',2,1,'Facebook profile URL','2025-10-16 11:24:59','2025-10-30 10:45:08'),(12,'social_pinterest','https://pinterest.com/unicrofoundation','url','social',3,1,'Pinterest profile URL','2025-10-16 11:24:59','2025-10-30 10:45:08'),(13,'social_instagram','https://instagram.com/unicrofoundation','url','social',4,1,'Instagram profile URL','2025-10-16 11:24:59','2025-10-30 10:45:08'),(14,'footer_volunteer_link','/volunteer','url','links',1,1,'Volunteer page link','2025-10-16 11:24:59','2025-10-30 10:45:08'),(15,'footer_privacy_link','/privacy','url','links',2,1,'Privacy policy page link','2025-10-16 11:24:59','2025-10-30 10:45:08'),(16,'footer_terms_link','/terms','url','links',3,1,'Terms of service page link','2025-10-16 11:24:59','2025-10-30 10:45:08'),(17,'footer_copyright','© {year} Unicro Foundation. All rights reserved. | The One Rupee Revolution','text','copyright',1,1,'Copyright text (use {year} for dynamic year)','2025-10-16 11:24:59','2025-10-30 10:45:08'),(18,'footer_made_with','Made with ?? for humanity','text','copyright',2,1,'Made with love text','2025-10-16 11:24:59','2025-10-30 10:45:08'),(19,'show_footer_description','true','text','foundation',2,1,'Show/hide foundation description','2025-10-16 11:39:27','2025-10-30 10:45:08'),(20,'show_newsletter','true','text','newsletter',4,1,'Show/hide newsletter signup section','2025-10-16 11:39:27','2025-10-30 10:45:08'),(21,'show_contact_info','true','text','contact',6,1,'Show/hide contact information section','2025-10-16 11:39:27','2025-10-30 10:45:08'),(22,'show_social_twitter','true','text','social',2,1,'Show/hide Twitter link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(23,'show_social_facebook','true','text','social',4,1,'Show/hide Facebook link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(24,'show_social_pinterest','true','text','social',6,1,'Show/hide Pinterest link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(25,'show_social_instagram','true','text','social',8,1,'Show/hide Instagram link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(26,'show_volunteer_link','true','text','links',2,1,'Show/hide volunteer link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(27,'show_privacy_link','true','text','links',4,1,'Show/hide privacy policy link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(28,'show_terms_link','true','text','links',6,1,'Show/hide terms of service link','2025-10-16 11:39:27','2025-10-30 10:45:08'),(29,'show_copyright','true','text','copyright',3,1,'Show/hide copyright text','2025-10-16 11:39:27','2025-10-30 10:45:08'),(30,'show_made_with','true','text','copyright',4,1,'Show/hide made with love text','2025-10-16 11:39:27','2025-10-30 10:45:08');
/*!40000 ALTER TABLE `footer_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `gallery`
--

DROP TABLE IF EXISTS `gallery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gallery` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `image_url` varchar(500) NOT NULL,
  `file_type` enum('image','video') DEFAULT 'image',
  `image_alt` varchar(255) DEFAULT NULL,
  `category` varchar(100) DEFAULT 'general',
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `gallery`
--

LOCK TABLES `gallery` WRITE;
/*!40000 ALTER TABLE `gallery` DISABLE KEYS */;
INSERT INTO `gallery` VALUES (3,'School Cleaning Initiative','cleaning  initivative in a govt girls school  ','/uploads/gallery/image-1761545067430-3733912.jpeg','image','Children participating in school program','general',3,1,'2025-10-27 05:55:49','2025-10-27 06:04:27'),(7,'WhatsApp Image 2025-10-27 at 11.18.47','','/uploads/gallery/image-1761545603468-563504159.jpeg','image','WhatsApp Image 2025-10-27 at 11.18.47','general',8,1,'2025-10-27 06:13:23','2025-10-27 06:13:23'),(10,'WhatsApp Image 2025-10-27 at 11.18.27','','/uploads/gallery/image-1761545646206-885731558.jpeg','image','WhatsApp Image 2025-10-27 at 11.18.27','general',11,1,'2025-10-27 06:14:06','2025-10-27 06:14:06'),(13,'WhatsApp Image 2025-10-27 at 11.23.07','','/uploads/gallery/image-1761549838260-292817717.jpeg','image','WhatsApp Image 2025-10-27 at 11.23.07','general',6,1,'2025-10-27 07:23:58','2025-10-27 07:23:58'),(14,'WhatsApp Image 2025-10-27 at 11.23.09','','/uploads/gallery/image-1761549838247-895066506.jpeg','image','WhatsApp Image 2025-10-27 at 11.23.09','general',4,1,'2025-10-27 07:23:58','2025-10-27 07:23:58'),(15,'WhatsApp Image 2025-10-27 at 11.22.39','','/uploads/gallery/image-1761549838267-777150561.jpeg','image','WhatsApp Image 2025-10-27 at 11.22.39','general',7,1,'2025-10-27 07:23:58','2025-10-27 07:23:58'),(16,'WhatsApp Image 2025-10-27 at 11.23.08','','/uploads/gallery/image-1761549838283-97900579.jpeg','image','WhatsApp Image 2025-10-27 at 11.23.08','general',5,1,'2025-10-27 07:23:58','2025-10-27 07:23:58'),(17,'Food Distribution','','/uploads/gallery/file-1761553878966-389787429.mp4','video','','general',0,1,'2025-10-27 08:31:19','2025-10-27 08:34:12'),(18,'School cleaning','','/uploads/gallery/file-1761553994467-847974385.mp4','video','','general',0,1,'2025-10-27 08:33:14','2025-10-27 08:33:14'),(19,'Food distribution to needy ones ','','/uploads/gallery/file-1761554443908-558969165.mp4','video','','food',0,1,'2025-10-27 08:40:43','2025-10-27 08:40:43'),(20,'donate','','/uploads/gallery/file-1761808433805-270845969.jpg','image','','general',0,0,'2025-10-30 07:13:53','2025-10-30 07:13:53');
/*!40000 ALTER TABLE `gallery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `navigation_links`
--

DROP TABLE IF EXISTS `navigation_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `navigation_links` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `url` varchar(500) NOT NULL,
  `page_id` int DEFAULT NULL,
  `is_external` tinyint(1) DEFAULT '0',
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `page_id` (`page_id`),
  CONSTRAINT `navigation_links_ibfk_1` FOREIGN KEY (`page_id`) REFERENCES `pages` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `navigation_links`
--

LOCK TABLES `navigation_links` WRITE;
/*!40000 ALTER TABLE `navigation_links` DISABLE KEYS */;
INSERT INTO `navigation_links` VALUES (1,'HOME','/home',1,0,1,1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(2,'ABOUT','/about',2,0,2,1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(3,'EVENTS','/events',3,0,3,1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(5,'GALLERY','/gallery',5,0,5,1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(6,'DONATE NOW','/donate',6,0,6,1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(8,'CONTACT','/contact',8,0,8,1,'2025-10-16 06:17:43','2025-10-16 06:17:43');
/*!40000 ALTER TABLE `navigation_links` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `newsletter_subscribers`
--

DROP TABLE IF EXISTS `newsletter_subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletter_subscribers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `newsletter_subscribers`
--

LOCK TABLES `newsletter_subscribers` WRITE;
/*!40000 ALTER TABLE `newsletter_subscribers` DISABLE KEYS */;
INSERT INTO `newsletter_subscribers` VALUES (1,'kanishkraj7799@gmail.com','2025-10-30 11:18:34');
/*!40000 ALTER TABLE `newsletter_subscribers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `our_work`
--

DROP TABLE IF EXISTS `our_work`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `our_work` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `before_image_url` varchar(500) DEFAULT NULL,
  `after_image_url` varchar(500) DEFAULT NULL,
  `before_image_alt` varchar(255) DEFAULT NULL,
  `after_image_alt` varchar(255) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `our_work`
--

LOCK TABLES `our_work` WRITE;
/*!40000 ALTER TABLE `our_work` DISABLE KEYS */;
INSERT INTO `our_work` VALUES (2,'School Renovation Initiative','Complete renovation of a dilapidated school building, providing modern facilities for quality education.','/uploads/our-work/before_image-1761553397884-613423149.jpeg','/uploads/our-work/after_image-1761553397887-60432303.jpeg','','',2,1,'2025-10-27 05:38:32','2025-10-27 08:23:17');
/*!40000 ALTER TABLE `our_work` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pages`
--

DROP TABLE IF EXISTS `pages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pages` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `content` text,
  `meta_description` text,
  `is_published` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pages`
--

LOCK TABLES `pages` WRITE;
/*!40000 ALTER TABLE `pages` DISABLE KEYS */;
INSERT INTO `pages` VALUES (1,'Home','home','<h1>Welcome to Unicro Foundation - The One Rupee Revolution</h1><p>We are dedicated to making a positive impact in the world through our charitable initiatives.</p>','Homepage of Unicro Foundation charity organization',1,'2025-10-16 06:17:43','2025-10-16 11:05:47'),(2,'About Us','about','<h1>About Unicro Foundation</h1><p>Learn more about our mission, vision, and the people behind our organization.</p>','About Unicro Foundation charity organization',1,'2025-10-16 06:17:43','2025-10-16 11:05:47'),(3,'Events','events','<h1>Our Events</h1><p>Join us in our upcoming events and fundraising activities.</p>','Upcoming events and activities',1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(4,'Blog','blog','<h1>Our Blog</h1><p>Read our latest news, stories, and updates from the field.</p>','Latest blog posts and news',1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(5,'Gallery','gallery','<h1>Photo Gallery</h1><p>See the impact we are making through our photos and videos.</p>','Photo gallery of our activities',1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(6,'Donate Now','donate','<h1>Make a Donation</h1><p>Your contribution can make a real difference in someone\'s life.</p>','Donate to support our cause',1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(7,'Shortcodes','shortcodes','<h1>Shortcodes</h1><p>Useful shortcodes and tools for our website.</p>','Shortcodes and tools',1,'2025-10-16 06:17:43','2025-10-16 06:17:43'),(8,'Contact Us','contact','<h1>Get in Touch</h1><p>Contact us for more information or to get involved.</p>','Contact information and form',1,'2025-10-16 06:17:43','2025-10-16 06:17:43');
/*!40000 ALTER TABLE `pages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_settings`
--

DROP TABLE IF EXISTS `site_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `site_settings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text,
  `setting_type` enum('text','image','boolean') DEFAULT 'text',
  `description` text,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `setting_key` (`setting_key`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_settings`
--

LOCK TABLES `site_settings` WRITE;
/*!40000 ALTER TABLE `site_settings` DISABLE KEYS */;
INSERT INTO `site_settings` VALUES (1,'site_logo','/uploads/logo-1760602707648-414861542.png','image','Main site logo image','2025-10-16 08:15:10','2025-10-16 08:18:27'),(2,'site_name','UNICRO FOUNDATION','text','Main site name/title','2025-10-16 08:15:10','2025-10-16 08:19:01'),(3,'site_tagline','THE ONE RUPEE REVOLUTION','text','Site tagline or subtitle','2025-10-16 08:15:10','2025-10-16 11:05:47'),(4,'site_description','Charity organization dedicated to making a positive impact through the power of one rupee donations','text','Site description for SEO','2025-10-16 08:15:10','2025-10-16 11:05:47'),(5,'contact_email','info@unicrofoundation.org','text','Contact email address','2025-10-16 08:15:10','2025-10-16 11:05:47'),(8,'Donate',' /uploads/gallery/file-1761808433805-270845969.jpg \n','text','','2025-10-30 07:17:01','2025-10-30 07:50:03'),(12,'donate_content','Every single rupee you give holds the power to create a smile. Your ₹1 can bring warmth, hope, and happiness to a child who dreams of a brighter tomorrow. It’s not about how much you give — it’s about the love and compassion behind it. Together, we can turn small contributions into big changes, one smile at a time. ','text','','2025-10-30 08:05:05','2025-10-30 08:05:22'),(13,'privacy_policy_content','<h1 data-start=\"180\" data-end=\"205\">🌍 <strong data-start=\"185\" data-end=\"203\">Privacy Policy</strong></h1>\n<p data-start=\"206\" data-end=\"395\"><strong data-start=\"206\" data-end=\"228\">Organization Name:</strong> <em data-start=\"229\" data-end=\"248\">Unicro Foundation</em><br data-start=\"248\" data-end=\"251\"><strong data-start=\"251\" data-end=\"263\">Website:</strong> <a class=\"decorated-link\" href=\"https://onerupeerevolution.org\" target=\"_new\" rel=\"noopener\" data-start=\"264\" data-end=\"328\">https://onerupeerevolution.org</a><br data-start=\"328\" data-end=\"331\"><strong data-start=\"331\" data-end=\"353\">Registered Entity:</strong> <em data-start=\"354\" data-end=\"393\">Section 8 Company (Non-Profit), India</em></p>\n<hr data-start=\"397\" data-end=\"400\">\n<h3 data-start=\"402\" data-end=\"424\"><strong data-start=\"406\" data-end=\"422\">Introduction</strong></h3>\n<p data-start=\"425\" data-end=\"750\">Unicro Foundation (&ldquo;we,&rdquo; &ldquo;our,&rdquo; &ldquo;us&rdquo;) respects your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you visit our website or make donations to support our cause &mdash; providing basic human necessities such as <strong data-start=\"677\" data-end=\"716\">food, water, shelter, and education</strong> through collective social action.</p>\n<hr data-start=\"752\" data-end=\"755\">\n<h3 data-start=\"757\" data-end=\"789\"><strong data-start=\"761\" data-end=\"787\">Information We Collect</strong></h3>\n<p data-start=\"790\" data-end=\"842\">We may collect the following types of information:</p>\n<p data-start=\"844\" data-end=\"873\"><strong data-start=\"844\" data-end=\"871\">1. Personal Information</strong></p>\n<ul data-start=\"874\" data-end=\"964\">\n<li data-start=\"874\" data-end=\"964\">\n<p data-start=\"876\" data-end=\"964\">Name, email address, contact number, and payment details when you donate or subscribe.</p>\n</li>\n</ul>\n<p data-start=\"966\" data-end=\"999\"><strong data-start=\"966\" data-end=\"997\">2. Non-Personal Information</strong></p>\n<ul data-start=\"1000\" data-end=\"1103\">\n<li data-start=\"1000\" data-end=\"1103\">\n<p data-start=\"1002\" data-end=\"1103\">Browser type, device information, IP address, and usage patterns collected through analytics tools.</p>\n</li>\n</ul>\n<p data-start=\"1105\" data-end=\"1121\"><strong data-start=\"1105\" data-end=\"1119\">3. Cookies</strong></p>\n<ul data-start=\"1122\" data-end=\"1190\">\n<li data-start=\"1122\" data-end=\"1190\">\n<p data-start=\"1124\" data-end=\"1190\">Used to enhance your experience and improve website performance.</p>\n</li>\n</ul>\n<hr data-start=\"1192\" data-end=\"1195\">\n<h3 data-start=\"1197\" data-end=\"1234\"><strong data-start=\"1201\" data-end=\"1232\">How We Use Your Information</strong></h3>\n<p data-start=\"1235\" data-end=\"1264\">We use your information to:</p>\n<ul data-start=\"1265\" data-end=\"1479\">\n<li data-start=\"1265\" data-end=\"1296\">\n<p data-start=\"1267\" data-end=\"1296\">Process donations securely.</p>\n</li>\n<li data-start=\"1297\" data-end=\"1355\">\n<p data-start=\"1299\" data-end=\"1355\">Send donation receipts and updates about our projects.</p>\n</li>\n<li data-start=\"1356\" data-end=\"1411\">\n<p data-start=\"1358\" data-end=\"1411\">Improve our website, campaigns, and communications.</p>\n</li>\n<li data-start=\"1412\" data-end=\"1479\">\n<p data-start=\"1414\" data-end=\"1479\">Comply with legal and regulatory requirements under Indian law.</p>\n</li>\n</ul>\n<hr data-start=\"1481\" data-end=\"1484\">\n<h3 data-start=\"1486\" data-end=\"1509\"><strong data-start=\"1490\" data-end=\"1507\">Data Security</strong></h3>\n<p data-start=\"1510\" data-end=\"1555\">We follow strict data protection standards.</p>\n<ul data-start=\"1556\" data-end=\"1770\">\n<li data-start=\"1556\" data-end=\"1667\">\n<p data-start=\"1558\" data-end=\"1667\">All transactions are <strong data-start=\"1579\" data-end=\"1596\">SSL-encrypted</strong> and processed through secure, government-compliant payment gateways.</p>\n</li>\n<li data-start=\"1668\" data-end=\"1770\">\n<p data-start=\"1670\" data-end=\"1770\">We <strong data-start=\"1673\" data-end=\"1703\">never sell, rent, or share</strong> your personal data with any third party for commercial purposes.</p>\n</li>\n</ul>\n<hr data-start=\"1772\" data-end=\"1775\">\n<h3 data-start=\"1777\" data-end=\"1808\"><strong data-start=\"1781\" data-end=\"1806\">Donation Transparency</strong></h3>\n<p data-start=\"1809\" data-end=\"1848\">As part of our public accountability:</p>\n<ul data-start=\"1849\" data-end=\"2013\">\n<li data-start=\"1849\" data-end=\"1915\">\n<p data-start=\"1851\" data-end=\"1915\">Aggregated donation and impact data may be published publicly.</p>\n</li>\n<li data-start=\"1916\" data-end=\"2013\">\n<p data-start=\"1918\" data-end=\"2013\">Your personal details will remain confidential unless you voluntarily consent to be featured.</p>\n</li>\n</ul>\n<hr data-start=\"2015\" data-end=\"2018\">\n<h3 data-start=\"2020\" data-end=\"2041\"><strong data-start=\"2024\" data-end=\"2039\">Your Rights</strong></h3>\n<p data-start=\"2042\" data-end=\"2052\">You may:</p>\n<ul data-start=\"2053\" data-end=\"2200\">\n<li data-start=\"2053\" data-end=\"2092\">\n<p data-start=\"2055\" data-end=\"2092\">Request access to your stored data.</p>\n</li>\n<li data-start=\"2093\" data-end=\"2157\">\n<p data-start=\"2095\" data-end=\"2157\">Request correction or deletion of your personal information.</p>\n</li>\n<li data-start=\"2158\" data-end=\"2200\">\n<p data-start=\"2160\" data-end=\"2200\">Opt-out of our communications anytime.</p>\n</li>\n</ul>\n<p data-start=\"2202\" data-end=\"2276\">To exercise these rights, contact us at <strong data-start=\"2242\" data-end=\"2273\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"2244\" data-end=\"2271\">info@onerupeerevolution.org</a></strong>.</p>\n<hr data-start=\"2278\" data-end=\"2281\">\n<h3 data-start=\"2283\" data-end=\"2315\"><strong data-start=\"2287\" data-end=\"2313\">Updates to This Policy</strong></h3>\n<p data-start=\"2316\" data-end=\"2438\">We may update this Privacy Policy periodically. Any changes will be posted on this page with the revised effective date.</p>\n<hr data-start=\"2440\" data-end=\"2443\">\n<h1 data-start=\"2445\" data-end=\"2474\">⚖️ <strong data-start=\"2450\" data-end=\"2472\">Terms &amp; Conditions</strong></h1>\n<h3 data-start=\"2476\" data-end=\"2533\"><strong data-start=\"2480\" data-end=\"2531\">Welcome to The One Rupee Revolution Foundation!</strong></h3>\n<p data-start=\"2534\" data-end=\"2613\">By accessing or donating through our website, you agree to the following terms:</p>\n<hr data-start=\"2615\" data-end=\"2618\">\n<h3 data-start=\"2620\" data-end=\"2640\"><strong data-start=\"2624\" data-end=\"2638\">1. Purpose</strong></h3>\n<p data-start=\"2641\" data-end=\"2903\">The One Rupee Revolution Foundation is a <strong data-start=\"2682\" data-end=\"2712\">non-profit social movement</strong> that collects voluntary contributions of ₹1 (or more) from individuals to collectively support humanity &mdash; ensuring that <strong data-start=\"2833\" data-end=\"2878\">basic needs like food, water, and shelter</strong> are accessible to all.</p>\n<hr data-start=\"2905\" data-end=\"2908\">\n<h3 data-start=\"2910\" data-end=\"2937\"><strong data-start=\"2914\" data-end=\"2935\">2. Use of Website</strong></h3>\n<p data-start=\"2938\" data-end=\"3117\">You agree to use this website only for lawful purposes and in a way that respects others&rsquo; rights and privacy.<br data-start=\"3047\" data-end=\"3050\">You shall not misuse the site or engage in fraudulent activities.</p>\n<hr data-start=\"3119\" data-end=\"3122\">\n<h3 data-start=\"3124\" data-end=\"3146\"><strong data-start=\"3128\" data-end=\"3144\">3. Donations</strong></h3>\n<ul data-start=\"3147\" data-end=\"3362\">\n<li data-start=\"3147\" data-end=\"3202\">\n<p data-start=\"3149\" data-end=\"3202\">All donations are <strong data-start=\"3167\" data-end=\"3199\">voluntary and non-refundable</strong>.</p>\n</li>\n<li data-start=\"3203\" data-end=\"3292\">\n<p data-start=\"3205\" data-end=\"3292\">Donations are used transparently for charitable projects as described on the website.</p>\n</li>\n<li data-start=\"3293\" data-end=\"3362\">\n<p data-start=\"3295\" data-end=\"3362\">Donors will receive a confirmation and digital receipt via email.</p>\n</li>\n</ul>\n<hr data-start=\"3364\" data-end=\"3367\">\n<h3 data-start=\"3369\" data-end=\"3403\"><strong data-start=\"3373\" data-end=\"3401\">4. Intellectual Property</strong></h3>\n<p data-start=\"3404\" data-end=\"3595\">All website content &mdash; including <strong data-start=\"3436\" data-end=\"3483\">text, videos, logos, designs, and campaigns</strong> &mdash; is owned by <em data-start=\"3498\" data-end=\"3535\">The One Rupee Revolution Foundation</em>. Unauthorized use or reproduction is strictly prohibited.</p>\n<hr data-start=\"3597\" data-end=\"3600\">\n<h3 data-start=\"3602\" data-end=\"3638\"><strong data-start=\"3606\" data-end=\"3636\">5. Limitation of Liability</strong></h3>\n<p data-start=\"3639\" data-end=\"3789\">The Foundation shall not be liable for any indirect, incidental, or consequential damages arising from your use of this website or linked resources.</p>\n<hr data-start=\"3791\" data-end=\"3794\">\n<h3 data-start=\"3796\" data-end=\"3829\"><strong data-start=\"3800\" data-end=\"3827\">6. Links to Other Sites</strong></h3>\n<p data-start=\"3830\" data-end=\"3991\">Our website may contain links to third-party platforms (e.g., payment gateways, social media).<br data-start=\"3924\" data-end=\"3927\">We are not responsible for their content or privacy practices.</p>\n<hr data-start=\"3993\" data-end=\"3996\">\n<h3 data-start=\"3998\" data-end=\"4024\"><strong data-start=\"4002\" data-end=\"4022\">7. Governing Law</strong></h3>\n<p data-start=\"4025\" data-end=\"4209\">These Terms are governed by and interpreted in accordance with the <strong data-start=\"4092\" data-end=\"4109\">laws of India</strong>.<br data-start=\"4110\" data-end=\"4113\">Any disputes shall be subject to the jurisdiction of the <strong data-start=\"4170\" data-end=\"4206\">courts in Indore, Madhya Pradesh</strong>.</p>\n<hr data-start=\"4211\" data-end=\"4214\">\n<h3 data-start=\"4216\" data-end=\"4236\"><strong data-start=\"4220\" data-end=\"4234\">8. Contact</strong></h3>\n<p data-start=\"4237\" data-end=\"4302\">For any questions, email us at <strong data-start=\"4268\" data-end=\"4299\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"4270\" data-end=\"4297\">info@onerupeerevolution.org</a></strong>.</p>\n<hr data-start=\"4304\" data-end=\"4307\">\n<h1 data-start=\"4309\" data-end=\"4330\">📞 <strong data-start=\"4314\" data-end=\"4328\">Contact Us</strong></h1>\n<p data-start=\"4332\" data-end=\"4461\">We&rsquo;d love to hear from you! Whether you want to collaborate, volunteer, or share ideas for positive change &mdash; reach out anytime.</p>\n<p data-start=\"4463\" data-end=\"4613\"><strong data-start=\"4463\" data-end=\"4488\">📍 Registered Office:</strong><br data-start=\"4488\" data-end=\"4491\"><em data-start=\"4491\" data-end=\"4528\">The One Rupee Revolution Foundation</em><br data-start=\"4528\" data-end=\"4531\">88, Choudhary Colony, Nai Abadi, Mandsaur &ndash; 458001 (M.P.), Madhya Pradesh, India</p>\n<p data-start=\"4615\" data-end=\"4630\"><strong data-start=\"4615\" data-end=\"4628\">📧 Email:</strong></p>\n<ul data-start=\"4631\" data-end=\"4800\">\n<li data-start=\"4631\" data-end=\"4685\">\n<p data-start=\"4633\" data-end=\"4685\">General Inquiries: <strong data-start=\"4652\" data-end=\"4683\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"4654\" data-end=\"4681\">info@onerupeerevolution.org</a></strong></p>\n</li>\n<li data-start=\"4686\" data-end=\"4748\">\n<p data-start=\"4688\" data-end=\"4748\">Media / Collaborations: <strong data-start=\"4712\" data-end=\"4746\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"4714\" data-end=\"4744\">contact@onerupeerevolution.org</a></strong></p>\n</li>\n<li data-start=\"4749\" data-end=\"4800\">\n<p data-start=\"4751\" data-end=\"4800\">Legal / Policy: <strong data-start=\"4767\" data-end=\"4798\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"4769\" data-end=\"4796\">info@onerupeerevolution.org</a></strong></p>\n</li>\n</ul>\n<p data-start=\"4802\" data-end=\"4936\"><strong data-start=\"4802\" data-end=\"4822\">📱 Social Media:</strong><br data-start=\"4822\" data-end=\"4825\">Follow us &rarr; <em data-start=\"4837\" data-end=\"4849\">Instagram:</em> <a class=\"decorated-link\" href=\"https://instagram.com/onerupeeguy\" target=\"_new\" rel=\"noopener\" data-start=\"4850\" data-end=\"4899\">@onerupeeguy</a><br data-start=\"4899\" data-end=\"4902\">Facebook | YouTube | X (Twitter)</p>\n<p data-start=\"4938\" data-end=\"5000\"><strong data-start=\"4938\" data-end=\"4958\">🕒 Office Hours:</strong><br data-start=\"4958\" data-end=\"4961\">Monday &ndash; Saturday: <strong data-start=\"4980\" data-end=\"5000\">10 AM &ndash; 6 PM IST</strong></p>\n<hr data-start=\"5002\" data-end=\"5005\">\n<h1 data-start=\"5007\" data-end=\"5030\">💬 <strong data-start=\"5012\" data-end=\"5028\">Support Page</strong></h1>\n<h3 data-start=\"5032\" data-end=\"5070\"><strong data-start=\"5036\" data-end=\"5068\">Need Help or Have Questions?</strong></h3>\n<p data-start=\"5071\" data-end=\"5235\">We&rsquo;re here to assist you! Whether it&rsquo;s donation-related, technical support, or partnership inquiries, our team ensures that every query gets a <strong data-start=\"5214\" data-end=\"5232\">human response</strong>.</p>\n<hr data-start=\"5237\" data-end=\"5240\">\n<h3 data-start=\"5242\" data-end=\"5273\"><strong data-start=\"5246\" data-end=\"5271\">Common Support Topics</strong></h3>\n<ul data-start=\"5274\" data-end=\"5442\">\n<li data-start=\"5274\" data-end=\"5302\">\n<p data-start=\"5276\" data-end=\"5302\">Trouble making a payment</p>\n</li>\n<li data-start=\"5303\" data-end=\"5336\">\n<p data-start=\"5305\" data-end=\"5336\">Requesting a donation receipt</p>\n</li>\n<li data-start=\"5337\" data-end=\"5368\">\n<p data-start=\"5339\" data-end=\"5368\">Reporting a technical issue</p>\n</li>\n<li data-start=\"5369\" data-end=\"5406\">\n<p data-start=\"5371\" data-end=\"5406\">Partnership or CSR collaborations</p>\n</li>\n<li data-start=\"5407\" data-end=\"5442\">\n<p data-start=\"5409\" data-end=\"5442\">Volunteer or ambassador program</p>\n</li>\n</ul>\n<hr data-start=\"5444\" data-end=\"5447\">\n<h3 data-start=\"5449\" data-end=\"5479\"><strong data-start=\"5453\" data-end=\"5477\">How to Reach Support</strong></h3>\n<p data-start=\"5480\" data-end=\"5645\"><strong data-start=\"5480\" data-end=\"5493\">📧 Email:</strong> <a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"5494\" data-end=\"5524\">support@onerupeerevolution.org</a><br data-start=\"5524\" data-end=\"5527\"><strong data-start=\"5527\" data-end=\"5547\">⏱ Response Time:</strong> Within <strong data-start=\"5555\" data-end=\"5578\">24&ndash;48 working hours</strong><br data-start=\"5578\" data-end=\"5581\"><strong data-start=\"5581\" data-end=\"5609\">📞 Emergency Assistance:</strong> WhatsApp Helpline <em data-start=\"5628\" data-end=\"5643\">(Coming Soon)</em></p>\n<hr data-start=\"5647\" data-end=\"5650\">\n<p data-start=\"5652\" data-end=\"5816\"><strong data-start=\"5652\" data-end=\"5682\">Your contribution matters.</strong><br data-start=\"5682\" data-end=\"5685\">Every rupee you give is a <strong data-start=\"5711\" data-end=\"5741\">voice of hope for humanity</strong> &mdash; and we&rsquo;re here to make sure that voice reaches where it&rsquo;s needed most.</p>\n<hr data-start=\"5818\" data-end=\"5821\">\n<p data-start=\"5823\" data-end=\"5981\" data-is-last-node=\"\" data-is-only-node=\"\">&nbsp;</p>','text','','2025-10-30 08:46:06','2025-10-30 10:38:32'),(14,'refund_policy_content','<h1 data-start=\"200\" data-end=\"237\">💰 <strong data-start=\"205\" data-end=\"237\">Refund &amp; Cancellation Policy</strong></h1>\n<hr data-start=\"239\" data-end=\"242\">\n<h3 data-start=\"244\" data-end=\"266\"><strong data-start=\"248\" data-end=\"264\">Introduction</strong></h3>\n<p data-start=\"267\" data-end=\"562\">The <strong data-start=\"271\" data-end=\"306\">One Rupee Revolution Foundation</strong> (&ldquo;we,&rdquo; &ldquo;our,&rdquo; &ldquo;us&rdquo;) deeply values every contribution made by donors toward our mission to ensure <strong data-start=\"404\" data-end=\"449\">food, water, shelter, and dignity for all</strong>.<br data-start=\"450\" data-end=\"453\">As a non-profit organization, we uphold full <strong data-start=\"498\" data-end=\"533\">transparency and accountability</strong> in the usage of all funds.</p>\n<p data-start=\"564\" data-end=\"677\">This <strong data-start=\"569\" data-end=\"601\">Refund &amp; Cancellation Policy</strong> explains the conditions under which donations may be refunded or cancelled.</p>\n<hr data-start=\"679\" data-end=\"682\">\n<h3 data-start=\"684\" data-end=\"716\"><strong data-start=\"688\" data-end=\"714\">1. Donations Are Final</strong></h3>\n<p data-start=\"717\" data-end=\"965\">All donations made to <strong data-start=\"739\" data-end=\"760\">Unicro Foundation</strong> are <strong data-start=\"765\" data-end=\"816\">voluntary, non-refundable, and non-transferable</strong>.<br data-start=\"817\" data-end=\"820\">Once a donation is received, it is immediately allocated toward ongoing and upcoming welfare projects aimed at <strong data-start=\"931\" data-end=\"964\">uplifting the underprivileged</strong>.</p>\n<hr data-start=\"967\" data-end=\"970\">\n<h3 data-start=\"972\" data-end=\"1007\"><strong data-start=\"976\" data-end=\"1005\">2. Exceptions for Refunds</strong></h3>\n<p data-start=\"1008\" data-end=\"1087\">Refunds may only be considered under the following exceptional circumstances:</p>\n<ul data-start=\"1089\" data-end=\"1426\">\n<li data-start=\"1089\" data-end=\"1192\">\n<p data-start=\"1091\" data-end=\"1192\"><strong data-start=\"1091\" data-end=\"1114\">Duplicate Donation:</strong> If the donor accidentally makes more than one payment for the same purpose.</p>\n</li>\n<li data-start=\"1193\" data-end=\"1313\">\n<p data-start=\"1195\" data-end=\"1313\"><strong data-start=\"1195\" data-end=\"1217\">Transaction Error:</strong> If a technical issue or payment gateway malfunction results in an incorrect or excess charge.</p>\n</li>\n<li data-start=\"1314\" data-end=\"1426\">\n<p data-start=\"1316\" data-end=\"1426\"><strong data-start=\"1316\" data-end=\"1345\">Unauthorized Transaction:</strong> If a donation is made fraudulently using your payment details without consent.</p>\n</li>\n</ul>\n<p data-start=\"1428\" data-end=\"1574\">To request a refund, donors must send a <strong data-start=\"1468\" data-end=\"1485\">written email</strong> to <strong data-start=\"1489\" data-end=\"1523\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"1491\" data-end=\"1521\">support@onerupeerevolution.org</a></strong> within <strong data-start=\"1531\" data-end=\"1541\">7 days</strong> of the transaction, including:</p>\n<ul data-start=\"1576\" data-end=\"1705\">\n<li data-start=\"1576\" data-end=\"1589\">\n<p data-start=\"1578\" data-end=\"1589\">Full Name</p>\n</li>\n<li data-start=\"1590\" data-end=\"1626\">\n<p data-start=\"1592\" data-end=\"1626\">Transaction ID / Payment Receipt</p>\n</li>\n<li data-start=\"1627\" data-end=\"1646\">\n<p data-start=\"1629\" data-end=\"1646\">Donation Amount</p>\n</li>\n<li data-start=\"1647\" data-end=\"1675\">\n<p data-start=\"1649\" data-end=\"1675\">Date and Mode of Payment</p>\n</li>\n<li data-start=\"1676\" data-end=\"1705\">\n<p data-start=\"1678\" data-end=\"1705\">Reason for Refund Request</p>\n</li>\n</ul>\n<p data-start=\"1707\" data-end=\"1852\">After verification, refunds (if applicable) will be processed within <strong data-start=\"1776\" data-end=\"1798\">10&ndash;15 working days</strong> and credited back to the <strong data-start=\"1824\" data-end=\"1851\">original payment source</strong>.</p>\n<hr data-start=\"1854\" data-end=\"1857\">\n<h3 data-start=\"1859\" data-end=\"1887\"><strong data-start=\"1863\" data-end=\"1885\">3. No Cash Refunds</strong></h3>\n<p data-start=\"1888\" data-end=\"2070\">All approved refunds will be processed <strong data-start=\"1927\" data-end=\"1945\">electronically</strong> to the same account or card used for the original transaction.<br data-start=\"2008\" data-end=\"2011\">No <strong data-start=\"2014\" data-end=\"2030\">cash refunds</strong> will be issued under any circumstances.</p>\n<hr data-start=\"2072\" data-end=\"2075\">\n<h3 data-start=\"2077\" data-end=\"2125\"><strong data-start=\"2081\" data-end=\"2123\">4. Cancellation of Recurring Donations</strong></h3>\n<p data-start=\"2126\" data-end=\"2319\">If you have set up a <strong data-start=\"2147\" data-end=\"2177\">recurring (monthly/annual)</strong> donation, you may cancel it anytime by emailing <strong data-start=\"2226\" data-end=\"2260\"><a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"2228\" data-end=\"2258\">support@onerupeerevolution.org</a></strong> at least <strong data-start=\"2270\" data-end=\"2287\">7 days before</strong> the next scheduled transaction.</p>\n<hr data-start=\"2321\" data-end=\"2324\">\n<h3 data-start=\"2326\" data-end=\"2361\"><strong data-start=\"2330\" data-end=\"2359\">5. Tax Exemption Receipts</strong></h3>\n<p data-start=\"2362\" data-end=\"2597\">Currently, we are <strong data-start=\"2380\" data-end=\"2415\">not providing any tax exemption</strong> to anyone.<br data-start=\"2426\" data-end=\"2429\">Once applicable, if a donation has been issued a <strong data-start=\"2478\" data-end=\"2543\">tax exemption receipt under Section 80G of the Income Tax Act</strong>, <strong data-start=\"2545\" data-end=\"2575\">no refund can be processed</strong> for that transaction.</p>\n<hr data-start=\"2599\" data-end=\"2602\">\n<h3 data-start=\"2604\" data-end=\"2643\"><strong data-start=\"2608\" data-end=\"2641\">6. Contact for Refund Queries</strong></h3>\n<p data-start=\"2644\" data-end=\"2705\">For any refund or payment-related concerns, please contact:</p>\n<p data-start=\"2707\" data-end=\"2805\">📧 <strong data-start=\"2710\" data-end=\"2720\">Email:</strong> <a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"2721\" data-end=\"2751\">support@onerupeerevolution.org</a><br data-start=\"2751\" data-end=\"2754\">⏱ <strong data-start=\"2756\" data-end=\"2774\">Response Time:</strong> Within <strong data-start=\"2782\" data-end=\"2805\">24&ndash;48 working hours</strong></p>\n<hr data-start=\"2807\" data-end=\"2810\">\n<h3 data-start=\"2812\" data-end=\"2847\"><strong data-start=\"2816\" data-end=\"2845\">7. Changes to This Policy</strong></h3>\n<p data-start=\"2848\" data-end=\"3033\">We may update this policy periodically to comply with revised laws, guidelines, or internal procedures.<br data-start=\"2951\" data-end=\"2954\">All updates will be published on this page with the <strong data-start=\"3006\" data-end=\"3032\">revised effective date</strong>.</p>\n<hr data-start=\"3035\" data-end=\"3038\">\n<h3 data-start=\"3040\" data-end=\"3063\">🙏 <strong data-start=\"3047\" data-end=\"3061\">Final Note</strong></h3>\n<p data-start=\"3064\" data-end=\"3262\">Every rupee donated to <strong data-start=\"3087\" data-end=\"3126\">The One Rupee Revolution Foundation</strong> carries the <strong data-start=\"3139\" data-end=\"3165\">hope of a better world</strong>.<br data-start=\"3166\" data-end=\"3169\">We sincerely thank you for your <strong data-start=\"3201\" data-end=\"3262\">trust, generosity, and belief in collective human change.</strong></p>','text','','2025-10-30 08:55:56','2025-10-30 10:40:59'),(16,'terms_of_service_content','<h1 data-start=\"294\" data-end=\"319\">⚖️ <strong data-start=\"299\" data-end=\"319\">Terms of Service</strong></h1>\n<hr data-start=\"321\" data-end=\"324\">\n<h3 data-start=\"326\" data-end=\"351\"><strong data-start=\"330\" data-end=\"349\">1. Introduction</strong></h3>\n<p data-start=\"352\" data-end=\"712\">Welcome to <strong data-start=\"363\" data-end=\"402\">The One Rupee Revolution Foundation</strong> (&ldquo;we,&rdquo; &ldquo;our,&rdquo; &ldquo;us&rdquo;).<br data-start=\"423\" data-end=\"426\">By accessing, browsing, or making a donation through our website &mdash; <a class=\"decorated-link\" href=\"https://onerupeerevolution.org\" target=\"_new\" rel=\"noopener\" data-start=\"493\" data-end=\"557\">https://onerupeerevolution.org</a> &mdash; you agree to comply with and be bound by these <strong data-start=\"607\" data-end=\"627\">Terms of Service</strong>.<br data-start=\"628\" data-end=\"631\">Please read them carefully before using our website or contributing to our cause.</p>\n<hr data-start=\"714\" data-end=\"717\">\n<h3 data-start=\"719\" data-end=\"740\"><strong data-start=\"723\" data-end=\"738\">2. About Us</strong></h3>\n<p data-start=\"741\" data-end=\"1052\">The One Rupee Revolution Foundation is a <strong data-start=\"782\" data-end=\"822\">Section 8 Non-Profit Company (India)</strong>, operating under the name <strong data-start=\"849\" data-end=\"870\">Unicro Foundation</strong>.<br data-start=\"871\" data-end=\"874\">Our mission is to unite individuals through small contributions (as little as ₹1) to collectively provide <strong data-start=\"980\" data-end=\"1028\">food, water, shelter, education, and dignity</strong> to the underprivileged.</p>\n<hr data-start=\"1054\" data-end=\"1057\">\n<h3 data-start=\"1059\" data-end=\"1091\"><strong data-start=\"1063\" data-end=\"1089\">3. Acceptance of Terms</strong></h3>\n<p data-start=\"1092\" data-end=\"1348\">By visiting our website, registering, or donating, you acknowledge that you have read, understood, and agree to these Terms, our <strong data-start=\"1221\" data-end=\"1239\">Privacy Policy</strong>, and our <strong data-start=\"1249\" data-end=\"1281\">Refund &amp; Cancellation Policy</strong>.<br data-start=\"1282\" data-end=\"1285\">If you do not agree, please do not use our website or services.</p>\n<hr data-start=\"1350\" data-end=\"1353\">\n<h3 data-start=\"1355\" data-end=\"1377\"><strong data-start=\"1359\" data-end=\"1375\">4. Donations</strong></h3>\n<ul data-start=\"1378\" data-end=\"1861\">\n<li data-start=\"1378\" data-end=\"1529\">\n<p data-start=\"1380\" data-end=\"1529\">All donations made to <strong data-start=\"1402\" data-end=\"1423\">Unicro Foundation</strong> are <strong data-start=\"1428\" data-end=\"1460\">voluntary and non-refundable</strong>, except in cases outlined in our <strong data-start=\"1494\" data-end=\"1526\">Refund &amp; Cancellation Policy</strong>.</p>\n</li>\n<li data-start=\"1530\" data-end=\"1617\">\n<p data-start=\"1532\" data-end=\"1617\">Donations are used exclusively for charitable purposes as described on the website.</p>\n</li>\n<li data-start=\"1618\" data-end=\"1715\">\n<p data-start=\"1620\" data-end=\"1715\">Donors will receive an email confirmation and digital receipt after a successful transaction.</p>\n</li>\n<li data-start=\"1716\" data-end=\"1861\">\n<p data-start=\"1718\" data-end=\"1861\">Currently, we <strong data-start=\"1732\" data-end=\"1768\">do not provide any tax exemption</strong> under Section 80G. Once applicable, such receipts will be issued as per government approval.</p>\n</li>\n</ul>\n<hr data-start=\"1863\" data-end=\"1866\">\n<h3 data-start=\"1868\" data-end=\"1895\"><strong data-start=\"1872\" data-end=\"1893\">5. Use of Website</strong></h3>\n<p data-start=\"1896\" data-end=\"2002\">You agree to use our website only for <strong data-start=\"1934\" data-end=\"1973\">lawful, ethical, and non-commercial</strong> purposes.<br data-start=\"1983\" data-end=\"1986\">You shall not:</p>\n<ul data-start=\"2003\" data-end=\"2214\">\n<li data-start=\"2003\" data-end=\"2061\">\n<p data-start=\"2005\" data-end=\"2061\">Engage in any fraudulent or unauthorized transactions.</p>\n</li>\n<li data-start=\"2062\" data-end=\"2140\">\n<p data-start=\"2064\" data-end=\"2140\">Disrupt or interfere with website functionality, security, or other users.</p>\n</li>\n<li data-start=\"2141\" data-end=\"2214\">\n<p data-start=\"2143\" data-end=\"2214\">Copy, modify, or redistribute any content without written permission.</p>\n</li>\n</ul>\n<p data-start=\"2216\" data-end=\"2291\">Any misuse may lead to restricted access or legal action as per Indian law.</p>\n<hr data-start=\"2293\" data-end=\"2296\">\n<h3 data-start=\"2298\" data-end=\"2339\"><strong data-start=\"2302\" data-end=\"2337\">6. Intellectual Property Rights</strong></h3>\n<p data-start=\"2340\" data-end=\"2654\">All materials on this website &mdash; including but not limited to <strong data-start=\"2401\" data-end=\"2458\">logos, designs, text, videos, graphics, and campaigns</strong> &mdash; are the <strong data-start=\"2469\" data-end=\"2553\">intellectual property of The One Rupee Revolution Foundation (Unicro Foundation)</strong>.<br data-start=\"2554\" data-end=\"2557\">You may not reproduce, modify, or use them for commercial purposes without prior written consent.</p>\n<hr data-start=\"2656\" data-end=\"2659\">\n<h3 data-start=\"2661\" data-end=\"2690\"><strong data-start=\"2665\" data-end=\"2688\">7. Payment Security</strong></h3>\n<p data-start=\"2691\" data-end=\"2967\">All online donations are processed through <strong data-start=\"2734\" data-end=\"2783\">secure, government-compliant payment gateways</strong>.<br data-start=\"2784\" data-end=\"2787\">We use <strong data-start=\"2794\" data-end=\"2812\">SSL encryption</strong> to protect your transaction details and donor data.<br data-start=\"2864\" data-end=\"2867\">However, we are not responsible for any unauthorized access or breach beyond our reasonable control.</p>\n<hr data-start=\"2969\" data-end=\"2972\">\n<h3 data-start=\"2974\" data-end=\"3004\"><strong data-start=\"2978\" data-end=\"3002\">8. Third-Party Links</strong></h3>\n<p data-start=\"3005\" data-end=\"3293\">Our website may contain links to third-party platforms (such as payment gateways or social media pages).<br data-start=\"3109\" data-end=\"3112\">We are <strong data-start=\"3119\" data-end=\"3138\">not responsible</strong> for the content, policies, or security practices of those websites.<br data-start=\"3206\" data-end=\"3209\">Users are encouraged to review their respective privacy policies before interaction.</p>\n<hr data-start=\"3295\" data-end=\"3298\">\n<h3 data-start=\"3300\" data-end=\"3336\"><strong data-start=\"3304\" data-end=\"3334\">9. Limitation of Liability</strong></h3>\n<p data-start=\"3337\" data-end=\"3606\">The Foundation shall not be liable for any <strong data-start=\"3380\" data-end=\"3429\">indirect, incidental, or consequential losses</strong> arising from the use of our website, donation platforms, or any associated services.<br data-start=\"3514\" data-end=\"3517\">All activities on this platform are undertaken at your own discretion and responsibility.</p>\n<hr data-start=\"3608\" data-end=\"3611\">\n<h3 data-start=\"3613\" data-end=\"3652\"><strong data-start=\"3617\" data-end=\"3650\">10. Termination or Suspension</strong></h3>\n<p data-start=\"3653\" data-end=\"3826\">We reserve the right to <strong data-start=\"3677\" data-end=\"3708\">suspend or terminate access</strong> to our website or services at any time without prior notice, if we detect misuse, fraud, or violation of these Terms.</p>\n<hr data-start=\"3828\" data-end=\"3831\">\n<h3 data-start=\"3833\" data-end=\"3877\"><strong data-start=\"3837\" data-end=\"3875\">11. Governing Law and Jurisdiction</strong></h3>\n<p data-start=\"3878\" data-end=\"4072\">These Terms shall be governed by and construed in accordance with the <strong data-start=\"3948\" data-end=\"3965\">laws of India</strong>.<br data-start=\"3966\" data-end=\"3969\">Any dispute shall be subject to the <strong data-start=\"4005\" data-end=\"4071\">exclusive jurisdiction of the courts in Indore, Madhya Pradesh</strong>.</p>\n<hr data-start=\"4074\" data-end=\"4077\">\n<h3 data-start=\"4079\" data-end=\"4119\"><strong data-start=\"4083\" data-end=\"4117\">12. Modifications to the Terms</strong></h3>\n<p data-start=\"4120\" data-end=\"4381\">We may update or revise these Terms periodically to reflect legal, operational, or organizational changes.<br data-start=\"4226\" data-end=\"4229\">The revised version will be posted on this page with the updated <strong data-start=\"4294\" data-end=\"4312\">effective date</strong>. Continued use of our website after such updates implies acceptance.</p>\n<hr data-start=\"4383\" data-end=\"4386\">\n<h3 data-start=\"4388\" data-end=\"4421\"><strong data-start=\"4392\" data-end=\"4419\">13. Contact Information</strong></h3>\n<p data-start=\"4422\" data-end=\"4506\">For any questions or clarifications regarding these Terms, please reach out to us:</p>\n<p data-start=\"4508\" data-end=\"4700\">📧 <strong data-start=\"4511\" data-end=\"4521\">Email:</strong> <a class=\"decorated-link cursor-pointer\" rel=\"noopener\" data-start=\"4522\" data-end=\"4549\">info@onerupeerevolution.org</a><br data-start=\"4549\" data-end=\"4552\">📍 <strong data-start=\"4555\" data-end=\"4577\">Registered Office:</strong><br data-start=\"4577\" data-end=\"4580\">The One Rupee Revolution Foundation<br data-start=\"4615\" data-end=\"4618\">88, Choudhary Colony, Nai Abadi, Mandsaur &ndash; 458001 (M.P.), Madhya Pradesh, India</p>\n<hr data-start=\"4702\" data-end=\"4705\">\n<h3 data-start=\"4707\" data-end=\"4730\">🙏 <strong data-start=\"4714\" data-end=\"4728\">Final Note</strong></h3>\n<p data-start=\"4731\" data-end=\"4950\">Your trust powers our mission.<br data-start=\"4761\" data-end=\"4764\">Every rupee you contribute builds a stronger, kinder, and more compassionate society.<br data-start=\"4849\" data-end=\"4852\">Thank you for being a part of <strong data-start=\"4882\" data-end=\"4910\">The One Rupee Revolution</strong> &mdash; where <strong data-start=\"4919\" data-end=\"4949\">every ₹1 creates one smile</strong>.</p>','text','','2025-10-30 10:43:32','2025-10-30 10:43:56'),(17,'contact_address','88,choudhary colony,\nNai Abadi\nMandsaur 458001 (M.P.)','text','','2025-10-30 12:18:41','2025-11-06 09:48:11'),(21,'contact_address_line1','88,choudhary colony,','text','','2025-11-06 09:49:45','2025-11-06 09:49:45'),(22,'contact_address_line2','Nai Abadi','text','','2025-11-06 09:50:04','2025-11-06 09:50:04'),(23,'contact_address_line3','Mandsaur 458001 (M.P.)','text','','2025-11-06 09:50:24','2025-11-06 09:50:24');
/*!40000 ALTER TABLE `site_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `slider_images`
--

DROP TABLE IF EXISTS `slider_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `slider_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `image_url` varchar(500) NOT NULL,
  `button_text` varchar(100) DEFAULT NULL,
  `button_url` varchar(500) DEFAULT NULL,
  `sort_order` int DEFAULT '0',
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `slider_images`
--

LOCK TABLES `slider_images` WRITE;
/*!40000 ALTER TABLE `slider_images` DISABLE KEYS */;
INSERT INTO `slider_images` VALUES (1,'Making a Difference','Join us in our mission to create positive change in communities worldwide','/uploads/slider-1760607676270-46676797.jpg','Learn More','/about',1,1,'2025-10-16 09:33:10','2025-10-16 09:41:16'),(2,'Education for All','Providing quality education and opportunities to children in need','https://images.pexels.com/photos/5212317/pexels-photo-5212317.jpeg','Donate Now','/donate',2,1,'2025-10-16 09:33:10','2025-10-16 09:36:11'),(3,'Community Support','Building stronger communities through compassion and action','https://images.pexels.com/photos/4386464/pexels-photo-4386464.jpeg','Get Involved','/contact',3,1,'2025-10-16 09:33:10','2025-10-16 09:36:11');
/*!40000 ALTER TABLE `slider_images` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2025-11-06 15:56:40
