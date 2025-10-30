const mysql = require('mysql2');
const fs = require('fs');
const path = require('path');

// Database configuration
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || 'root123',
  multipleStatements: true
};

async function setupDatabase() {
  console.log('Setting up database...');
  
  try {
    // Create connection
    const connection = mysql.createConnection(dbConfig);
    
    // Read and execute schema
    const schemaPath = path.join(__dirname, 'database', 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    await connection.promise().query(schema);
    console.log('✅ Database schema created successfully!');
    
    connection.end();
  } catch (error) {
    console.error('❌ Error setting up database:', error.message);
    process.exit(1);
  }
}

async function createEnvFile() {
  const envPath = path.join(__dirname, '.env');
  
  if (!fs.existsSync(envPath)) {
    const envContent = `DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=charity_website
JWT_SECRET=your_jwt_secret_key_here_${Math.random().toString(36).substring(2, 15)}
PORT=5000`;
    
    fs.writeFileSync(envPath, envContent);
    console.log('✅ .env file created! Please update the database credentials.');
  } else {
    console.log('ℹ️  .env file already exists.');
  }
}

async function main() {
  console.log('🚀 Setting up Charity Website...\n');
  
  await createEnvFile();
  await setupDatabase();
  
  console.log('\n🎉 Setup completed successfully!');
  console.log('\nNext steps:');
  console.log('1. Update the .env file with your database credentials');
  console.log('2. Run: npm install');
  console.log('3. Run: cd client && npm install');
  console.log('4. Run: npm run dev:full');
  console.log('\nAdmin credentials:');
  console.log('Username: admin');
  console.log('Password: admin123');
}

main().catch(console.error);
