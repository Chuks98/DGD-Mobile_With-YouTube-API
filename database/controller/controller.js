const moment = require('moment-timezone');
const User = require('../models/user_model');
const Devotion = require('../models/devotion_model');
const bcrypt = require('bcrypt');
var { devotionThumbnail } = require('../config/multer_config');


const register = async (req, res) => {
  try {
    const { email, username, password } = req.body;
    console.log(req.body);

    // Check if email already exists
    const emailExists = await User.findOne({ email });
    if (emailExists) {
      return res.status(400).json({ message: 'Email already exists' });
    }

    // Check if username already exists
    const usernameExists = await User.findOne({ username });
    if (usernameExists) {
      return res.status(400).json({ message: 'Username already exists' });
    }

    // Hash password before saving
    const hashedPassword = await bcrypt.hash(password, 10);

    const user = new User({
      email,
      username,
      password: hashedPassword,
    });

    await user.save();

    res.status(201).json({ message: 'Registration successful' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Internal server error' });
  }
};







const login = async (req, res) => {
  const { username, password } = req.body;
  console.log(req.body);

  try {
    // Find the user by username
    const user = await User.findOne({ username });

    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Compare the password with the stored hash
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid password' });
    }

    // If credentials are correct, send a success response
    res.json({ message: 'Login successful' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error' });
  }
};








const createDevotion = async (req, res) => {
  console.log(req.body);

  // Check for existing devotion with the same topic
  const existingDevotion = await Devotion.findOne({ topic: req.body.topic });

  if (existingDevotion) {
    return res.status(302).json({ message: 'Devotion with this topic already exists' });
  }

  // Parse and set the time zone for the selectedDate
  const selectedDate = moment.tz(req.body.selectedDate, 'MMM D, YYYY', 'UTC').startOf('day').toDate();

  // Devotion doesn't exist, proceed with saving
  const newDevotion = new Devotion({
    topic: req.body.topic,
    description: req.body.description,
    youtubeLink: req.body.youtubeLink,
    reviews: req.body.reviews, // Assuming reviews is included in request (optional)
    selectedDate: selectedDate,
    thumbnail: req.body.thumbnail, // Assuming thumbnail is included in request (optional)
  });

  try {
    const savedDevotion = await newDevotion.save();
    res.status(201).json(savedDevotion); // Created (201) status with saved devotion data
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Error saving devotion' }); // Internal Server Error (500)
  }
};




const uploadThumbnail = (req, res) => {
  // Assuming you have a field named 'audio' in your form
  devotionThumbnail.single('thumbnail')(req, res, (err) => {
    if (err) {
      // Handle Multer error (e.g., file type not allowed)
      console.error('Error uploading thumbnail:', err);
      return res.status(400).send('Error uploading thumbnail');
    }

    // The file has been uploaded successfully
    console.log('Thumbnail uploaded successfully NYAN:', req.file);

    // Now, you can continue with other logic or send a response
    res.status(200).send('Thumbnail uploaded successfully');
  });
};




const getAllDevotions = async (req, res) => {
  try {
    const devotions = await Devotion.find(); // Fetch all devotions
    res.status(200).json(devotions); // Send devotions data as JSON response
    console.log('Devotions retrieved successfully');
  } catch (error) {
    console.error('Error fetching devotions:', error);
    res.status(500).send('Error retrieving devotions');
  }
};





const getSingleDevotion = async (req, res) => {
  try {
    const { id } = req.query;

    if (!id) {
      return res.status(400).json({ message: 'ID is required' });
    }

    const devotion = await Devotion.findOne({ _id: id });

    if (devotion) {
      console.log(devotion);
      res.status(200).json(devotion);
    } else {
      console.log('Devotion not found')
      res.status(404).json({ message: 'Devotion not found' });
    }
  } catch (error) {
    console.log('Server error', error)
    res.status(500).json({ message: 'Server error', error });
  }
};




const getDevotionByDate = async (req, res) => {
  const { date } = req.query;
  console.log(date);

  try {
    // Find all devotions.
    const devotions = await Devotion.find({});

    // Find devotion with matching formatted date and convert it to (Jan 1, 2024) before comparison.
    const matchingDevotion = devotions.find(devotion => {
      const dbFormattedDate = new Date(devotion.selectedDate).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
      return dbFormattedDate == date;
    });

    if (matchingDevotion) {
      res.status(200).json(matchingDevotion);
      console.log("Successfully returned the date from the database.");
    } else {
      console.log("No devotion available.");
      res.status(404).json({ message: 'No devotion available.' });
    }
  } catch (error) {
    res.status(500).json({ message: error.message });
    console.error(error);
  }
};






const updateSingleDevotion = async (req, res) => {
  const { id } = req.query;
  const updates = { ...req.body };

  // Log incoming data
  console.log("Incoming request for updating devotion:", id, updates);

  // Check and parse the selectedDate if it exists in the updates
  if (updates.selectedDate) {
    updates.selectedDate = moment.tz(updates.selectedDate, 'MMM D, YYYY', 'UTC').startOf('day').toDate();
  }

  try {
    const updatedDevotion = await Devotion.findByIdAndUpdate(id, updates, { new: true });

    if (!updatedDevotion) {
      console.log("Tried to update devotion but devotion was not found");
      return res.status(404).send({ message: 'Devotion not found' });
    }

    console.log('Devotion updated successfully');
    return res.status(200).send({ message: 'Devotion updated successfully', devotion: updatedDevotion });
  } catch (error) {
    console.error('Error updating devotion:', error);
    res.status(500).send({ message: 'Internal server error' });
  }
};





const deleteSingleDevotion = async (req, res) => {
  try {
    const { id } = req.params;
    const deletedDevotion = await Devotion.findByIdAndDelete(id);

    if (!deletedDevotion) {
      return res.status(404).send({ message: 'Devotion not found' });
    }

    res.status(200).send({ message: 'Devotion deleted successfully' });
  } catch (error) {
    res.status(500).send({ message: 'Server error', error });
  }
};

// const sendAudio = (req, res) => {
//   // Assuming you have a field named 'audio' in your form
//   devotionAudio.single('audio')(req, res, (err) => {
//     if (err) {
//       console.log("This is the request", req)
//       // Handle Multer error (e.g., file type not allowed)
//       console.error('Error uploading the mafisticated nonsensicated audio:', err);
//       return res.status(400).send('Error uploading audio');
//     }

//     // The file has been uploaded successfully
//     console.log('Audio uploaded successfully:', req.file);

//     // Now, you can continue with other logic or send a response
//     res.status(200).send('Audio uploaded successfully');
//   });
// };

module.exports = { register, login, createDevotion, uploadThumbnail, getAllDevotions, getSingleDevotion, getDevotionByDate, updateSingleDevotion, deleteSingleDevotion };
