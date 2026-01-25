const express = require('express');
const Profile = require('../models/Profile');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Get user profile
router.get('/', authMiddleware, async (req, res) => {
  try {
    const profile = await Profile.findOne({ userId: req.userId });
    
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Profil negăsit.'
      });
    }
    
    res.json({
      success: true,
      profile
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea profilului.'
    });
  }
});

// Create or update profile
router.post('/', authMiddleware, async (req, res) => {
  try {
    const profileData = {
      userId: req.userId,
      ...req.body,
      lastUpdated: new Date()
    };
    
    // Check if all required fields are present
    const requiredFields = ['name', 'age', 'gender', 'country'];
    const hasAllFields = requiredFields.every(field => profileData[field]);
    
    if (hasAllFields) {
      profileData.profileComplete = true;
    }
    
    // Update or create profile
    const profile = await Profile.findOneAndUpdate(
      { userId: req.userId },
      profileData,
      { new: true, upsert: true }
    );
    
    res.json({
      success: true,
      message: 'Profil salvat cu succes!',
      profile
    });
  } catch (error) {
    console.error('Save profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la salvarea profilului.'
    });
  }
});

// Delete profile (soft delete - keeps user account)
router.delete('/', authMiddleware, async (req, res) => {
  try {
    await Profile.findOneAndDelete({ userId: req.userId });
    
    res.json({
      success: true,
      message: 'Profil șters cu succes.'
    });
  } catch (error) {
    console.error('Delete profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la ștergerea profilului.'
    });
  }
});

// Get potential matches (basic implementation)
router.get('/matches', authMiddleware, async (req, res) => {
  try {
    const userProfile = await Profile.findOne({ userId: req.userId });
    
    if (!userProfile) {
      return res.status(404).json({
        success: false,
        message: 'Profil negăsit. Completează profilul mai întâi.'
      });
    }
    
    // Find matches based on partner criteria
    const matches = await Profile.find({
      userId: { $ne: req.userId },
      profileComplete: true,
      gender: userProfile.partnerGender || { $exists: true },
      age: {
        $gte: userProfile.partnerAgeMin || 18,
        $lte: userProfile.partnerAgeMax || 100
      }
    }).limit(20);
    
    res.json({
      success: true,
      matches
    });
  } catch (error) {
    console.error('Get matches error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea match-urilor.'
    });
  }
});

// Search profiles with criteria (NO AUTH REQUIRED - public search)
router.post('/search', async (req, res) => {
  try {
    const {
      gender,
      minAge,
      maxAge,
      relationshipType,
      country,
      city,
      minHeight,
      maxHeight,
      education,
      occupation,
      interests,
      smoking,
      drinking
    } = req.body;

    // Validate required fields
    if (!gender || !minAge || !maxAge || !relationshipType) {
      return res.status(400).json({
        success: false,
        message: 'Genul, vârsta și tipul de relație sunt obligatorii pentru căutare.'
      });
    }

    // Build search query
    const query = {
      profileComplete: true,
      gender: new RegExp(`^${gender}$`, 'i'), // Case-insensitive exact match
      age: { $gte: minAge, $lte: maxAge },
      relationshipType: new RegExp(relationshipType, 'i') // Required relationship type match
    };

    // Add optional filters
    if (country) query.country = new RegExp(country, 'i');
    if (city) query.city = new RegExp(city, 'i');
    if (minHeight && maxHeight) {
      query.height = { $gte: minHeight, $lte: maxHeight };
    }
    if (education) query.education = education;
    if (occupation) query.occupation = new RegExp(occupation, 'i');
    if (smoking) query.smoking = smoking;
    if (drinking) query.drinking = drinking;
    
    // Interests matching (at least one common interest)
    if (interests && interests.length > 0) {
      query.interests = { $in: interests };
    }

    // Execute search - returnează TOATE câmpurile pentru vizualizare completă
    const results = await Profile.find(query)
      .select('-userId -__v') // Exclude doar userId și versioning
      .limit(50);

    res.json({
      success: true,
      results,
      count: results.length
    });
  } catch (error) {
    console.error('Search profiles error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la căutarea profilurilor.'
    });
  }
});

module.exports = router;
