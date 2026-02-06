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
  
  // CRITERII OPȚIONALE NOI
  // 1. Copii
  hasChildren: { type: String }, // "Da", "Nu", "Prefer să nu spun"
  wantsChildren: { type: String }, // "Da", "Nu", "Poate", "Deja am"
  
  // 2. Educație
  education: { type: String }, // "Liceu", "Facultate", "Masterat", "Doctorat", "Altele"
  
  // 3. Înălțime
  height: { type: Number }, // cm (ex: 175)
  
  // 4. Stil de viață
  smoking: { type: String }, // "Nu", "Ocazional", "Da"
  drinking: { type: String }, // "Nu consum", "Ocazional", "Social", "Frecvent"
  
  // 5. Religie
  religion: { type: String }, // "Creștin-Ortodox", "Catolic", "Protestant", "Muslim", etc.
  
  // 6. Limbi vorbite
  languages: [String], // Array: ["Română", "Engleză", "Italiană", etc.]
  
  // 7. Tip corp
  bodyType: { type: String }, // "Athletic", "Slim", "Average", "Curvy", "Plus Size"
  
  // 8. Status relație
  relationshipStatus: { type: String }, // "Necăsătorit(ă)", "Divorțat(ă)", "Văduv(ă)"
  
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
adSchema.index({ city: 1, active: 1 }); // Pentru căutare după oraș
adSchema.index({ height: 1, education: 1, active: 1 }); // Pentru filtrare după înălțime/educație
adSchema.index({ hasChildren: 1, wantsChildren: 1, active: 1 }); // Pentru criterii copii
adSchema.index({ createdAt: -1 }); // Pentru sortare după data postării

module.exports = mongoose.model('Ad', adSchema);
