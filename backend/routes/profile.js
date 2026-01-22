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

module.exports = router;
