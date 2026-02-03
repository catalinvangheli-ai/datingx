const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  senderId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  receiverId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  adId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ad',
    required: true
  },
  text: {
    type: String,
    required: true,
    maxlength: 1000
  },
  read: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: true
});

// Indexes pentru căutări rapide
messageSchema.index({ senderId: 1, receiverId: 1, createdAt: -1 });
messageSchema.index({ receiverId: 1, read: 1 });

module.exports = mongoose.model('Message', messageSchema);
