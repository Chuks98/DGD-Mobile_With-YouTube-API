// const mongoose = require('mongoose');

// const uri = "mongodb+srv://litTec:Litt.6862@cluster0.mspul5w.mongodb.net/Daily_Grace_Devotional?retryWrites=true&w=majority";

// mongoose.connect(uri, {
//   useNewUrlParser: true,
//   socketTimeoutMS: 120000, // Set the socket timeout to 60 seconds (adjust as needed)
// });

// const db = mongoose.connection;

// db.on('error', console.error.bind(console, 'MongoDB connection error:'));
// db.once('open', () => {
//   console.log('Connected to MongoDB')
// });

// module.exports = db;





















const mongoose = require('mongoose');

try {
  mongoose.connect('mongodb://127.0.0.1:27017/Daily_Devotion_Mobile', {
    useNewUrlParser: true,
  });

  const db = mongoose.connection;
  
  db.on('error', (error) => {
    console.error('MongoDB connection error:', error);
    // Handle the error or perform any necessary actions.
  });

  db.once('open', () => {
    console.log('Connected to MongoDB');
  });

  module.exports = db;
} catch (error) {
  console.error('Error connecting to MongoDB:');
}




