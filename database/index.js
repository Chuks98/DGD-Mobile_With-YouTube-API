const express = require('express');
const cors = require('cors');
const Admin = require('./models/admin_model')
const routers = require('./router/router');
const bcrypt = require('bcrypt');
require('dotenv').config();
const path = require('path');
require('./connection');

const app = express();
app.use(cors());
app.use(express.json()); // Do this So that my server can accept json
app.use(express.urlencoded({ extended: true }));



// Router for my routing, uploads and stuffs
app.use('/', routers);

// app.use('/devotion_thumbnail', express.static(path.join(__dirname, '../react/build/devotion_thumbnail')));
// app.use('/devotion_audio', express.static(path.join(__dirname, '../react/build/devotion_audio')));


// const strength = 10; // Higher number is higher hashing strength
// const password = 'Devotion@2024';

// (async () => {
//   try {
//     const hashedPassword = await bcrypt.hash(password, strength);

//     const userData = {
//       username: 'admin',
//       password: hashedPassword,
//     };

//     const newAdmin = new Admin(userData);
//     const savedAdmin = await newAdmin.save();

//     console.log('User record successfully saved:', savedAdmin);
//   } catch (error) {
//     console.error(error);
//   }
// })();

const PORT = process.env.PORT;

app.listen(PORT, () => {
  console.log(`NODEJS server listening on port ${PORT}`);
});
