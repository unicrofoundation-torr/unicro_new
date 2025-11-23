const express = require('express');
const cors = require('cors');
const path = require('path');
const multer = require('multer');
require('dotenv').config();

// Test database connection
const db = require('./config/database');

const app = express();
const PORT = process.env.PORT || 5000;

// Test database connection on startup
async function testDatabaseConnection() {
  try {
    await db.execute('SELECT 1');
    console.log('✅ Database connection successful');
  } catch (error) {
    console.error('❌ Database connection failed:', error.message);
    console.log('🔧 Make sure MySQL is running and credentials are correct');
    console.log('⚠️ App will continue but database operations may fail');
    // Don't exit - let Passenger handle it, or app will crash loop
    // process.exit(1); // Removed to prevent crash loop
  }
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'client/public/uploads/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|gif|svg/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'));
    }
  }
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files
app.use('/uploads', express.static(path.join(__dirname, 'client/public/uploads')));

// Routes
app.use('/api/pages', require('./routes/pages'));
app.use('/api/navigation', require('./routes/navigation'));
const { router: adminRouter } = require('./routes/admin');
app.use('/api/admin', adminRouter);
app.use('/api/settings', require('./routes/siteSettings'));
app.use('/api/slider', require('./routes/slider'));
app.use('/api/footer', require('./routes/footer'));
app.use('/api/our-work', require('./routes/ourWork'));
app.use('/api/gallery', require('./routes/gallery'));
app.use('/api/newsletter', require('./routes/newsletter'));
app.use('/api/contact', require('./routes/contact'));
app.use('/api/donations', require('./routes/donations'));
app.use('/api/blogs', require('./routes/blogs'));

// Serve static files from React app in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'client/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'client/build', 'index.html'));
  });
}

// Test database connection (non-blocking)
testDatabaseConnection().catch(err => {
  console.error('Database connection test failed:', err.message);
});

// Always export app for Passenger (cPanel)
// Passenger requires module.exports = app
module.exports = app;

// For local development: Start server with app.listen()
if (require.main === module) {
  async function startServer() {
    await testDatabaseConnection();
    
    app.listen(PORT, () => {
      console.log(`🚀 Server is running on port ${PORT}`);
      console.log(`📱 Frontend: http://localhost:3000`);
      console.log(`🔧 Backend API: http://localhost:5000/api`);
      console.log(`👤 Admin Panel: http://localhost:3000/admin/login`);
      console.log(`🔑 Admin Login: username: admin, password: admin123`);
    });
  }

  startServer().catch(error => {
    console.error('Failed to start server:', error);
    process.exit(1);
  });
}
