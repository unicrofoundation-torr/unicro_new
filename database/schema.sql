-- Create database
CREATE DATABASE IF NOT EXISTS charity_website;
USE charity_website;

-- Create pages table
CREATE TABLE IF NOT EXISTS pages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    content TEXT,
    meta_description TEXT,
    is_published BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create navigation_links table
CREATE TABLE IF NOT EXISTS navigation_links (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    url VARCHAR(500) NOT NULL,
    page_id INT,
    is_external BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (page_id) REFERENCES pages(id) ON DELETE SET NULL
);

-- Create admin_users table
CREATE TABLE IF NOT EXISTS admin_users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'editor') DEFAULT 'editor',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create site_settings table
CREATE TABLE IF NOT EXISTS site_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('text', 'image', 'boolean') DEFAULT 'text',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default pages
INSERT INTO pages (title, slug, content, meta_description) VALUES
('Home', 'home', '<h1>Welcome to Unicro Foundation - The One Rupee Revolution</h1><p>We are dedicated to making a positive impact in the world through our charitable initiatives.</p>', 'Homepage of Unicro Foundation charity organization'),
('About Us', 'about', '<h1>About Unicro Foundation</h1><p>Learn more about our mission, vision, and the people behind our organization.</p>', 'About Unicro Foundation charity organization'),
('Events', 'events', '<h1>Our Events</h1><p>Join us in our upcoming events and fundraising activities.</p>', 'Upcoming events and activities'),
('Blog', 'blog', '<h1>Our Blog</h1><p>Read our latest news, stories, and updates from the field.</p>', 'Latest blog posts and news'),
('Gallery', 'gallery', '<h1>Photo Gallery</h1><p>See the impact we are making through our photos and videos.</p>', 'Photo gallery of our activities'),
('Donate Now', 'donate', '<h1>Make a Donation</h1><p>Your contribution can make a real difference in someone\'s life.</p>', 'Donate to support our cause'),
('Shortcodes', 'shortcodes', '<h1>Shortcodes</h1><p>Useful shortcodes and tools for our website.</p>', 'Shortcodes and tools'),
('Contact Us', 'contact', '<h1>Get in Touch</h1><p>Contact us for more information or to get involved.</p>', 'Contact information and form');

-- Insert default navigation links
INSERT INTO navigation_links (title, url, page_id, sort_order) VALUES
('HOME', '/home', 1, 1),
('ABOUT', '/about', 2, 2),
('EVENTS', '/events', 3, 3),
('BLOG', '/blog', 4, 4),
('GALLERY', '/gallery', 5, 5),
('DONATE NOW', '/donate', 6, 6),
('SHORTCODES', '/shortcodes', 7, 7),
('CONTACT', '/contact', 8, 8);

-- Create slider_images table
CREATE TABLE IF NOT EXISTS slider_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    button_text VARCHAR(100),
    button_url VARCHAR(500),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default slider images
INSERT INTO slider_images (title, description, image_url, button_text, button_url, sort_order) VALUES
('Making a Difference', 'Join us in our mission to create positive change in communities worldwide', '/images/slider1.jpg', 'Learn More', '/about', 1),
('Education for All', 'Providing quality education and opportunities to children in need', '/images/slider2.jpg', 'Donate Now', '/donate', 2),
('Community Support', 'Building stronger communities through compassion and action', '/images/slider3.jpg', 'Get Involved', '/contact', 3);

-- Insert default admin user (password: admin123)
INSERT INTO admin_users (username, email, password, role) VALUES
('admin', 'admin@unicrofoundation.org', '$2a$10$DR3XS6oJeJ/7aW361R7//eycPNebZb3HBaSLAU47BPbLWxsxDxRBq', 'admin');

-- Create footer_settings table
CREATE TABLE IF NOT EXISTS footer_settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type ENUM('text', 'url', 'email', 'phone', 'address') DEFAULT 'text',
    section VARCHAR(50) NOT NULL,
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default site settings
INSERT INTO site_settings (setting_key, setting_value, setting_type, description) VALUES
('site_logo', '/images/logo.png', 'image', 'Main site logo image'),
('site_name', 'UNICRO FOUNDATION', 'text', 'Main site name/title'),
('site_tagline', 'THE ONE RUPEE REVOLUTION', 'text', 'Site tagline or subtitle'),
('site_description', 'Charity organization dedicated to making a positive impact through the power of one rupee donations', 'text', 'Site description for SEO'),
('contact_email', 'info@unicrofoundation.org', 'text', 'Contact email address'),
('contact_phone', '+1 (555) 123-4567', 'text', 'Contact phone number');

-- Insert default footer settings
INSERT INTO footer_settings (setting_key, setting_value, setting_type, section, sort_order, description) VALUES
-- Foundation Info Section
('footer_description', 'Empowering change through the power of small donations. Every ₹1 makes a difference in creating a better world for all.', 'text', 'foundation', 1, 'Foundation description text'),
('show_footer_description', 'true', 'text', 'foundation', 2, 'Show/hide foundation description'),

-- Newsletter Section
('newsletter_title', 'Stay Updated', 'text', 'newsletter', 1, 'Newsletter signup title'),
('newsletter_placeholder', 'Enter your email', 'text', 'newsletter', 2, 'Newsletter input placeholder'),
('newsletter_button', 'Subscribe', 'text', 'newsletter', 3, 'Newsletter subscribe button text'),
('show_newsletter', 'true', 'text', 'newsletter', 4, 'Show/hide newsletter signup section'),

-- Contact Information
('footer_address_line1', '123 Charity Street', 'text', 'contact', 1, 'Address line 1'),
('footer_address_line2', 'Community District', 'text', 'contact', 2, 'Address line 2'),
('footer_address_line3', 'Mumbai, Maharashtra 400001', 'text', 'contact', 3, 'Address line 3'),
('footer_email', 'info@unicrofoundation.org', 'email', 'contact', 4, 'Footer contact email'),
('footer_phone', '+91-98765-43210', 'phone', 'contact', 5, 'Footer contact phone'),
('show_contact_info', 'true', 'text', 'contact', 6, 'Show/hide contact information section'),

-- Social Media Links
('social_twitter', 'https://twitter.com/unicrofoundation', 'url', 'social', 1, 'Twitter profile URL'),
('show_social_twitter', 'true', 'text', 'social', 2, 'Show/hide Twitter link'),
('social_facebook', 'https://facebook.com/unicrofoundation', 'url', 'social', 3, 'Facebook profile URL'),
('show_social_facebook', 'true', 'text', 'social', 4, 'Show/hide Facebook link'),
('social_pinterest', 'https://pinterest.com/unicrofoundation', 'url', 'social', 5, 'Pinterest profile URL'),
('show_social_pinterest', 'true', 'text', 'social', 6, 'Show/hide Pinterest link'),
('social_instagram', 'https://instagram.com/unicrofoundation', 'url', 'social', 7, 'Instagram profile URL'),
('show_social_instagram', 'true', 'text', 'social', 8, 'Show/hide Instagram link'),

-- Footer Links
('footer_volunteer_link', '/volunteer', 'url', 'links', 1, 'Volunteer page link'),
('show_volunteer_link', 'true', 'text', 'links', 2, 'Show/hide volunteer link'),
('footer_privacy_link', '/privacy', 'url', 'links', 3, 'Privacy policy page link'),
('show_privacy_link', 'true', 'text', 'links', 4, 'Show/hide privacy policy link'),
('footer_terms_link', '/terms', 'url', 'links', 5, 'Terms of service page link'),
('show_terms_link', 'true', 'text', 'links', 6, 'Show/hide terms of service link'),

-- Footer Text
('footer_copyright', '© {year} Unicro Foundation. All rights reserved. | The One Rupee Revolution', 'text', 'copyright', 1, 'Copyright text (use {year} for dynamic year)'),
('footer_made_with', 'Made with ❤️ for humanity', 'text', 'copyright', 2, 'Made with love text'),
('show_copyright', 'true', 'text', 'copyright', 3, 'Show/hide copyright text'),
('show_made_with', 'true', 'text', 'copyright', 4, 'Show/hide made with love text');

-- Create our_work table
CREATE TABLE IF NOT EXISTS our_work (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    before_image_url VARCHAR(500),
    after_image_url VARCHAR(500),
    before_image_alt VARCHAR(255),
    after_image_alt VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default our work entries
INSERT INTO our_work (title, description, before_image_url, after_image_url, before_image_alt, after_image_alt, sort_order) VALUES
('Community Development Project', 'Transforming a neglected community space into a vibrant learning center for children and families.', '/images/our-work/before-1.jpg', '/images/our-work/after-1.jpg', 'Before: Empty community space', 'After: Vibrant learning center', 1),
('School Renovation Initiative', 'Complete renovation of a dilapidated school building, providing modern facilities for quality education.', '/images/our-work/before-2.jpg', '/images/our-work/after-2.jpg', 'Before: Dilapidated school building', 'After: Modern school facilities', 2),
('Water Well Installation', 'Installing clean water wells in remote villages, bringing safe drinking water to hundreds of families.', '/images/our-work/before-3.jpg', '/images/our-work/after-3.jpg', 'Before: Villagers walking long distances for water', 'After: Clean water well in village', 3);

-- Create gallery table
CREATE TABLE IF NOT EXISTS gallery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500) NOT NULL,
    image_alt VARCHAR(255),
    category VARCHAR(100) DEFAULT 'general',
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert default gallery entries
INSERT INTO gallery (title, description, image_url, image_alt, category, sort_order) VALUES
('Community Event', 'Annual community gathering bringing families together for celebration and connection.', '/images/gallery/event-1.jpg', 'Community event with families gathered', 'events', 1),
('Volunteer Work', 'Dedicated volunteers working together to make a positive impact in the community.', '/images/gallery/volunteer-1.jpg', 'Volunteers working on community project', 'volunteers', 2),
('School Program', 'Educational programs providing learning opportunities for children in underserved areas.', '/images/gallery/education-1.jpg', 'Children participating in school program', 'education', 3),
('Food Distribution', 'Organized food distribution ensuring families have access to nutritious meals.', '/images/gallery/food-1.jpg', 'Food distribution to families in need', 'food', 4),
('Medical Camp', 'Free medical camps providing healthcare services to community members.', '/images/gallery/medical-1.jpg', 'Medical camp providing healthcare services', 'healthcare', 5),
('Infrastructure Project', 'Building essential infrastructure to improve community living conditions.', '/images/gallery/infrastructure-1.jpg', 'Infrastructure development project', 'infrastructure', 6);

-- Create blogs table
CREATE TABLE IF NOT EXISTS blogs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content TEXT NOT NULL,
    image_url VARCHAR(500),
    image_alt VARCHAR(255),
    author VARCHAR(100) DEFAULT 'Admin',
    is_published BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert default blog entries
INSERT INTO blogs (title, slug, excerpt, content, image_url, image_alt, author, sort_order) VALUES
('The Power of One Rupee', 'power-of-one-rupee', 'Discover how small donations are creating big changes in communities around the world.', '<h2>Introduction</h2><p>Every single rupee you give holds the power to create a smile. Your ₹1 can bring warmth, hope, and happiness to a child who dreams of a better tomorrow.</p><h2>The Impact</h2><p>Through our transparent donation system, we ensure that every contribution, no matter how small, reaches those who need it most. Together, we are building a movement of compassion and change.</p>', '/images/blog/blog-1.jpg', 'The Power of One Rupee', 'Admin', 1),
('Community Spotlight: Stories of Hope', 'community-spotlight', 'Meet the volunteers, donors, and community members who are making a difference every day.', '<h2>Volunteer Stories</h2><p>Our volunteers are the heart of our organization. They dedicate their time, energy, and compassion to make a real difference in people\'s lives.</p><h2>Donor Impact</h2><p>Every donor, whether giving ₹1 or ₹1000, plays a crucial role in our mission. Your support enables us to reach more communities and create lasting change.</p>', '/images/blog/blog-2.jpg', 'Community Spotlight', 'Admin', 2),
('Impact Reports: Measuring Our Success', 'impact-reports', 'Stay updated with our quarterly impact reports, showcasing the measurable difference we\'re making.', '<h2>Quarterly Highlights</h2><p>This quarter, we\'ve reached over 10,000 families across 50 communities, providing essential support and resources.</p><h2>Looking Forward</h2><p>With your continued support, we aim to expand our reach and impact even more communities in the coming months.</p>', '/images/blog/blog-3.jpg', 'Impact Reports', 'Admin', 3);
