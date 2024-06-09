const mongoose = require('mongoose');

const subscribeSchema = new mongoose.Schema({
    email: {
        type: String,
        required: true,
        unique: true,
    }
});

const Subscribe = mongoose.model('Subscribers', subscribeSchema);
module.exports = Subscribe;
