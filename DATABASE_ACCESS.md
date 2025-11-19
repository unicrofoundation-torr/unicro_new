# Database Access Guide for cPanel

## How to Access Your Database on cPanel

### Method 1: Using phpMyAdmin (Recommended)

1. **Login to cPanel**
   - Go to: `https://theonerupeerevolution.org:2083` (or your cPanel URL)
   - Login with your cPanel credentials

2. **Open phpMyAdmin**
   - In cPanel, look for the **"Databases"** section
   - Click on **"phpMyAdmin"** icon
   - This will open phpMyAdmin in a new tab/window

3. **Select Your Database**
   - In the left sidebar, look for your database name
   - Database name is likely: `theomkiq_charity_website` or `theomkiq_unicro` (cPanel usually prefixes with username)
   - Click on the database name to expand it

4. **View/Edit Tables**
   - You'll see all tables: `pages`, `navigation_links`, `site_settings`, `slider_images`, `footer_settings`, `our_work`, `gallery`, `blogs`, `donors`, `donations`, `newsletter_subscribers`, `contact_messages`, `admin_users`, etc.
   - Click on any table to view/edit data
   - Click **"Browse"** to see all records
   - Click **"Edit"** (pencil icon) to edit a record
   - Click **"Insert"** to add a new record
   - Click **"Delete"** (trash icon) to delete a record

### Method 2: Using cPanel MySQL Databases

1. **Login to cPanel**
   - Go to: `https://theonerupeerevolution.org:2083`

2. **Find MySQL Databases**
   - In cPanel, look for **"Databases"** section
   - Click on **"MySQL Databases"**

3. **View Database Information**
   - You'll see your database name (usually prefixed with your cPanel username)
   - You can see database users and their permissions
   - You can create/modify databases here

### Method 3: Using Admin Panel (Easier - Recommended for Most Changes)

**For most database changes, you can use the website's Admin Panel instead:**

1. **Access Admin Panel**
   - Go to: `https://theonerupeerevolution.org/admin/login`
   - Login with: username: `admin`, password: `admin123`

2. **Manage Content via Admin Panel**
   - **Site Settings**: Edit logo, site name, tagline, contact info, etc.
   - **Pages**: Create/edit pages
   - **Navigation**: Manage navigation links
   - **Slider Management**: Manage home page slider
   - **Footer Management**: Manage footer content
   - **Our Work**: Manage before/after images
   - **Gallery**: Manage gallery images/videos
   - **Blog Management**: Manage blog posts
   - **Newsletter**: View/export subscribers
   - **Contact Messages**: View/delete/export messages

### Common Database Tables and What They Store

| Table Name | What It Stores |
|------------|----------------|
| `site_settings` | Logo, site name, tagline, contact info, page content |
| `navigation_links` | Navigation menu links |
| `pages` | Dynamic pages content |
| `slider_images` | Home page slider images |
| `footer_settings` | Footer content and links |
| `our_work` | Before/after images for "Our Work" section |
| `gallery` | Gallery images and videos |
| `blogs` | Blog posts |
| `admin_users` | Admin login credentials |
| `donors` | Donor information |
| `donations` | Donation records |
| `newsletter_subscribers` | Newsletter email subscribers |
| `contact_messages` | Contact form submissions |

### Important Notes

⚠️ **Before Making Direct Database Changes:**
- Always backup your database first (cPanel → phpMyAdmin → Export)
- Be careful when editing - incorrect data can break the website
- For most changes, use the Admin Panel instead (safer and easier)

✅ **Recommended Approach:**
- Use **Admin Panel** for content changes (Site Settings, Pages, Navigation, etc.)
- Use **phpMyAdmin** only for:
  - Bulk data imports/exports
  - Complex queries
  - Database structure changes
  - Emergency fixes

### Finding Your Database Name

If you're not sure of your database name:
1. Check your `.env` file (local) - it has `DB_NAME=charity_website`
2. In cPanel, the database name is usually: `[cpanel_username]_charity_website`
3. In phpMyAdmin, look in the left sidebar for databases starting with your cPanel username

### Database Credentials

Your database credentials are stored in:
- Local: `.env` file in project root
- Production: cPanel MySQL Databases section

**To find production credentials:**
1. Login to cPanel
2. Go to **"MySQL Databases"**
3. You'll see:
   - Database name
   - Database users
   - You can reset passwords here if needed



