const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  url: { type: String, required: true },
  cloudinaryId: { type: String, required: true },
  uploadedAt: { type: Date, default: Date.now }
});

const adSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  
  // Informații anunț
  title: { type: String, required: true },
  bio: { type: String, required: true },
  
  // Date personale
  name: { type: String, required: true },
  age: { type: Number, required: true },
  gender: { type: String, required: true },
  country: { type: String, required: true },
  city: { type: String },
  phoneNumber: { type: String, required: true },
  
  // Căutare
  relationshipType: { type: String, required: true },
  interests: [String],
  
  // Poze
  photos: [photoSchema],
  
  // Status
  active: { type: Boolean, default: true },
  views: { type: Number, default: 0 },
  
  // Metadata
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
}, {
  timestamps: true
});

// Indexuri pentru căutare
adSchema.index({ userId: 1, active: 1 });
adSchema.index({ gender: 1, age: 1, country: 1, relationshipType: 1, active: 1 });
adSchema.index({ createdAt: -1 }); // Pentru sortare după data postării

module.exports = mongoose.model('Ad', adSchema);
