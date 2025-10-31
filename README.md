# Charity Website - Humanity: The Ray of Hope

A full-stack charity/NGO website built with React.js frontend and Node.js backend, featuring a dynamic navigation system and admin panel for content management.

## Features

- **Dynamic Navigation Bar**: Navigation links are fetched from the database and can be managed through the admin panel
- **Admin Panel**: Complete content management system for pages and navigation links
- **Responsive Design**: Mobile-friendly design that matches the charity website aesthetic
- **Page Management**: Create, edit, and delete pages with rich content
- **Navigation Management**: Add, edit, and reorder navigation links
- **Authentication**: Secure admin login system
- **Database Integration**: MySQL database for storing pages and navigation data

## Technology Stack

### Backend
- Node.js with Express.js
- MySQL database
- JWT authentication
- RESTful API endpoints

### Frontend
- React.js with React Router
- Axios for API calls
- Responsive CSS design
- Component-based architecture

## Installation & Setup

### Prerequisites
- Node.js (v14 or higher)
- MySQL database
- npm or yarn package manager

### 1. Clone the Repository
```bash
git clone <repository-url>
cd charity-website
```

### 2. Install Backend Dependencies
```bash
npm install
```

### 3. Install Frontend Dependencies
```bash
cd client
npm install
cd ..
```

### 4. Database Setup

1. Create a MySQL database named `charity_website`
2. Import the database schema:
```bash
mysql -u your_username -p charity_website < database/schema.sql
```

### 5. Environment Configuration

Create a `.env` file in the root directory:
```env
DB_HOST=localhost
DB_USER=your_mysql_username
DB_PASSWORD=your_mysql_password
DB_NAME=charity_website
JWT_SECRET=your_jwt_secret_key_here
PORT=5000
```

### 6. Start the Application

#### Development Mode (Both Frontend and Backend)
```bash
npm run dev:full
```

#### Or Start Separately:

Backend only:
```bash
npm run dev
```

Frontend only:
```bash
npm run client
```

### 7. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:5000
- **Admin Panel**: http://localhost:3000/admin/login

## Default Admin Credentials

- **Username**: admin
- **Password**: admin123

## Project Structure

```
charity-website/
├── client/                 # React frontend
│   ├── src/
│   │   ├── components/     # React components
│   │   │   ├── Navigation.js
│   │   │   ├── Navigation.css
│   │   │   ├── PageViewer.js
│   │   │   └── admin/      # Admin components
│   │   ├── pages/          # Page components
│   │   ├── services/       # API services
│   │   └── App.js
├── config/                 # Database configuration
├── database/               # Database schema
├── routes/                 # API routes
│   ├── pages.js
│   ├── navigation.js
│   └── admin.js
├── server.js              # Main server file
└── package.json
```

## API Endpoints

### Public Endpoints
- `GET /api/pages` - Get all published pages
- `GET /api/pages/:slug` - Get page by slug
- `GET /api/navigation` - Get navigation links

### Admin Endpoints
- `POST /api/admin/login` - Admin login
- `GET /api/admin/verify` - Verify admin token
- `GET /api/admin/pages` - Get all pages (admin)
- `POST /api/pages` - Create new page
- `PUT /api/pages/:id` - Update page
- `DELETE /api/pages/:id` - Delete page
- `GET /api/admin/navigation` - Get all navigation links (admin)
- `POST /api/navigation` - Create navigation link
- `PUT /api/navigation/:id` - Update navigation link
- `DELETE /api/navigation/:id` - Delete navigation link

## Usage

### Admin Panel Features

1. **Page Management**:
   - Create new pages with title, slug, content, and meta description
   - Edit existing pages
   - Publish/unpublish pages
   - Delete pages

2. **Navigation Management**:
   - Add new navigation links
   - Edit link titles, URLs, and settings
   - Set sort order for link arrangement
   - Mark links as external or internal
   - Activate/deactivate links

### Frontend Features

1. **Dynamic Navigation**: Navigation bar automatically updates when changes are made in the admin panel
2. **Page Routing**: All pages are dynamically routed based on database content
3. **Responsive Design**: Works on desktop, tablet, and mobile devices
4. **SEO Friendly**: Meta descriptions and proper page structure

## Customization

### Styling
- Modify `client/src/components/Navigation.css` for navigation bar styling
- Update `client/src/App.css` for global styles
- Customize page components in `client/src/pages/`

### Database
- Add new fields to the database schema in `database/schema.sql`
- Update API endpoints in `routes/` directory
- Modify React components to handle new data

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support or questions, please contact the development team or create an issue in the repository.
