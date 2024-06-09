const mongoose = require('mongoose');

const devotionSchema = new mongoose.Schema({
  topic: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  youtubeLink: {
    type: String,
    required: true,
  },
  reviews: {
    type: Number,
    default: 0,
  },
  selectedDate: {
    type: Date,
  },
  thumbnail: {
    type: String,
    default: null,
  },
});

const Devotion = mongoose.model('Devotion', devotionSchema);
module.exports = Devotion;
