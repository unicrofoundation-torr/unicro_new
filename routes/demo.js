const express = require('express');
const router = express.Router();

// Demo data for testing without database
const demoPages = [
  {
    id: 1,
    title: 'Home',
    slug: 'home',
    content: '<h1>Welcome to Unicro Foundation - The One Rupee Revolution</h1><p>We are dedicated to making a positive impact in the world through our charitable initiatives.</p>',
    meta_description: 'Homepage of Unicro Foundation charity organization',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 2,
    title: 'About Us',
    slug: 'about',
    content: '<h1>About Unicro Foundation</h1><p>Learn more about our mission, vision, and the people behind our organization.</p>',
    meta_description: 'About Unicro Foundation charity organization',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 3,
    title: 'Events',
    slug: 'events',
    content: '<h1>Our Events</h1><p>Join us in our upcoming events and fundraising activities.</p>',
    meta_description: 'Upcoming events and activities',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 4,
    title: 'Blog',
    slug: 'blog',
    content: '<h1>Our Blog</h1><p>Read our latest news, stories, and updates from the field.</p>',
    meta_description: 'Latest blog posts and news',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 5,
    title: 'Gallery',
    slug: 'gallery',
    content: '<h1>Photo Gallery</h1><p>See the impact we are making through our photos and videos.</p>',
    meta_description: 'Photo gallery of our activities',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 6,
    title: 'Donate Now',
    slug: 'donate',
    content: '<h1>Make a Donation</h1><p>Your contribution can make a real difference in someone\'s life.</p>',
    meta_description: 'Donate to support our cause',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 7,
    title: 'Shortcodes',
    slug: 'shortcodes',
    content: '<h1>Shortcodes</h1><p>Useful shortcodes and tools for our website.</p>',
    meta_description: 'Shortcodes and tools',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  },
  {
    id: 8,
    title: 'Contact Us',
    slug: 'contact',
    content: '<h1>Get in Touch</h1><p>Contact us for more information or to get involved.</p>',
    meta_description: 'Contact information and form',
    is_published: true,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString()
  }
];

const demoNavigationLinks = [
  { id: 1, title: 'HOME', url: '/home', page_id: 1, is_external: false, sort_order: 1, is_active: true, page_title: 'Home', page_slug: 'home' },
  { id: 2, title: 'ABOUT', url: '/about', page_id: 2, is_external: false, sort_order: 2, is_active: true, page_title: 'About Us', page_slug: 'about' },
  { id: 3, title: 'EVENTS', url: '/events', page_id: 3, is_external: false, sort_order: 3, is_active: true, page_title: 'Events', page_slug: 'events' },
  { id: 4, title: 'BLOG', url: '/blog', page_id: 4, is_external: false, sort_order: 4, is_active: true, page_title: 'Blog', page_slug: 'blog' },
  { id: 5, title: 'GALLERY', url: '/gallery', page_id: 5, is_external: false, sort_order: 5, is_active: true, page_title: 'Gallery', page_slug: 'gallery' },
  { id: 6, title: 'DONATE NOW', url: '/donate', page_id: 6, is_external: false, sort_order: 6, is_active: true, page_title: 'Donate Now', page_slug: 'donate' },
  { id: 7, title: 'SHORTCODES', url: '/shortcodes', page_id: 7, is_external: false, sort_order: 7, is_active: true, page_title: 'Shortcodes', page_slug: 'shortcodes' },
  { id: 8, title: 'CONTACT', url: '/contact', page_id: 8, is_external: false, sort_order: 8, is_active: true, page_title: 'Contact Us', page_slug: 'contact' }
];

// Get all pages
router.get('/pages', (req, res) => {
  res.json(demoPages);
});

// Get page by slug
router.get('/pages/:slug', (req, res) => {
  const page = demoPages.find(p => p.slug === req.params.slug);
  if (!page) {
    return res.status(404).json({ error: 'Page not found' });
  }
  res.json(page);
});

// Get navigation links
router.get('/navigation', (req, res) => {
  res.json(demoNavigationLinks);
});

// Demo admin login (always works)
router.post('/admin/login', (req, res) => {
  const { username, password } = req.body;
  
  if (username === 'admin' && password === 'admin123') {
    const token = 'demo-token-' + Date.now();
    res.json({
      token,
      user: {
        id: 1,
        username: 'admin',
        email: 'admin@unicrofoundation.org',
        role: 'admin'
      }
    });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Demo admin verify
router.get('/admin/verify', (req, res) => {
  res.json({ valid: true, user: { id: 1, username: 'admin', role: 'admin' } });
});

// Demo admin pages
router.get('/admin/pages', (req, res) => {
  res.json(demoPages);
});

// Demo admin navigation
router.get('/admin/navigation', (req, res) => {
  res.json(demoNavigationLinks);
});

// Demo pages dropdown
router.get('/admin/pages/dropdown', (req, res) => {
  const dropdown = demoPages.map(p => ({ id: p.id, title: p.title, slug: p.slug }));
  res.json(dropdown);
});

module.exports = router;
