const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Demo routes (no database required)
app.use('/api', require('./routes/demo'));

// Serve static files from React app in production
if (process.env.NODE_ENV === 'production') {
  app.use(express.static(path.join(__dirname, 'client/build')));
  
  app.get('*', (req, res) => {
    res.sendFile(path.join(__dirname, 'client/build', 'index.html'));
  });
}

app.listen(PORT, () => {
  console.log(`🚀 Demo server is running on port ${PORT}`);
  console.log(`📱 Frontend: http://localhost:3000`);
  console.log(`🔧 Backend API: http://localhost:5000/api`);
  console.log(`👤 Admin Panel: http://localhost:3000/admin/login`);
  console.log(`🔑 Admin Login: username: admin, password: admin123`);
  console.log(`\n✨ This is a DEMO version - no database required!`);
});
