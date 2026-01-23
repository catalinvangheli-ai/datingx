const mongoose = require('mongoose');

const photoSchema = new mongoose.Schema({
  url: { type: String, required: true },
  cloudinaryId: { type: String, required: true },
  uploadedAt: { type: Date, default: Date.now }
});

const profileSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  
  // Basic Identity
  name: { type: String },
  age: { type: Number, required: true },
  gender: { type: String, required: true },
  country: { type: String, required: true },
  city: { type: String },
  occupation: { type: String },
  phoneNumber: { type: String }, // Opțional - pentru contact
  
  // Lifestyle
  smokingHabit: String,
  drinkingHabit: String,
  fitnessLevel: String,
  diet: String,
  petPreference: String,
  
  // Personality
  introvertExtrovert: String,
  spontaneousPlanned: String,
  creativeAnalytical: String,
  
  // Values
  relationshipType: String,
  wantsChildren: String,
  religionImportance: String,
  politicalAlignment: String,
  
  // Interests
  interests: [String],
  
  // Photos
  photos: [photoSchema],
  
  // Partner Criteria
  partnerAgeMin: Number,
  partnerAgeMax: Number,
  partnerGender: String,
  dealBreakers: [String],
  
  // Auto-generated Bio
  bio: { type: String },
  
  // Metadata
  profileComplete: { type: Boolean, default: false },
  lastUpdated: { type: Date, default: Date.now }
}, {
  timestamps: true
});

// Index for searching
profileSchema.index({ userId: 1 });
profileSchema.index({ gender: 1, age: 1, country: 1 });

module.exports = mongoose.model('Profile', profileSchema);
