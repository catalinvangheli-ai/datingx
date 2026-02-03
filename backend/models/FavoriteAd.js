const mongoose = require('mongoose');

const favoriteAdSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  adId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Ad',
    required: true,
    index: true
  }
}, {
  timestamps: true
});

// Index compus pentru a preveni duplicatele și pentru căutări rapide
favoriteAdSchema.index({ userId: 1, adId: 1 }, { unique: true });

module.exports = mongoose.model('FavoriteAd', favoriteAdSchema);
