const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  reporterId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  reportedUserId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  reason: {
    type: String,
    enum: [
      'spam',
      'comportament_abuziv',
      'continut_inadecvat',
      'identitate_falsa',
      'continut_sexual_explicit',
      'hartuire',
      'altele',
    ],
    required: true,
  },
  details: {
    type: String,
    maxlength: 1000,
    default: '',
  },
  status: {
    type: String,
    enum: ['pending', 'reviewed', 'resolved'],
    default: 'pending',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('Report', reportSchema);
