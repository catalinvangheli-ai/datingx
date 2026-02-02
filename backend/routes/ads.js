const express = require('express');
const Ad = require('../models/Ad');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Get all my ads
router.get('/my-ads', authMiddleware, async (req, res) => {
  try {
    const ads = await Ad.find({ userId: req.userId, active: true })
      .sort({ createdAt: -1 }) // Cele mai noi primele
      .select('-__v');
    
    res.json({
      success: true,
      ads,
      count: ads.length
    });
  } catch (error) {
    console.error('Get my ads error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea anunțurilor.'
    });
  }
});

// Get specific ad
router.get('/:adId', async (req, res) => {
  try {
    const ad = await Ad.findById(req.params.adId);
    
    if (!ad || !ad.active) {
      return res.status(404).json({
        success: false,
        message: 'Anunț negăsit.'
      });
    }
    
    // Incrementează views
    ad.views += 1;
    await ad.save();
    
    res.json({
      success: true,
      ad
    });
  } catch (error) {
    console.error('Get ad error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea anunțului.'
    });
  }
});

// Create new ad
router.post('/', authMiddleware, async (req, res) => {
  try {
    console.log('📥 Creating ad:', req.body);
    
    const adData = {
      userId: req.userId,
      ...req.body,
      active: true
    };
    
    const ad = await Ad.create(adData);
    
    console.log('✅ Ad created:', ad._id);
    
    res.json({
      success: true,
      message: 'Anunț postat cu succes!',
      ad
    });
  } catch (error) {
    console.error('Create ad error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Eroare la postarea anunțului.'
    });
  }
});

// Update ad
router.put('/:adId', authMiddleware, async (req, res) => {
  try {
    const ad = await Ad.findOne({ _id: req.params.adId, userId: req.userId });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Anunț negăsit sau nu ai permisiuni.'
      });
    }
    
    Object.assign(ad, req.body);
    ad.updatedAt = new Date();
    await ad.save();
    
    res.json({
      success: true,
      message: 'Anunț actualizat cu succes!',
      ad
    });
  } catch (error) {
    console.error('Update ad error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la actualizarea anunțului.'
    });
  }
});

// Delete ad (soft delete - setează active = false)
router.delete('/:adId', authMiddleware, async (req, res) => {
  try {
    const ad = await Ad.findOne({ _id: req.params.adId, userId: req.userId });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Anunț negăsit sau nu ai permisiuni.'
      });
    }
    
    ad.active = false;
    await ad.save();
    
    res.json({
      success: true,
      message: 'Anunț șters cu succes.'
    });
  } catch (error) {
    console.error('Delete ad error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la ștergerea anunțului.'
    });
  }
});

// Search ads (public - no auth required)
router.post('/search', async (req, res) => {
  try {
    const {
      gender,
      minAge,
      maxAge,
      relationshipType,
      country,
      city,
      interests
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
      active: true,
      gender: new RegExp(`^${gender}$`, 'i'),
      age: { $gte: minAge, $lte: maxAge },
      relationshipType: new RegExp(relationshipType, 'i')
    };

    // Add optional filters
    if (country) query.country = new RegExp(country, 'i');
    if (city) query.city = new RegExp(city, 'i');
    
    // Interests matching
    if (interests && interests.length > 0) {
      query.interests = { $in: interests };
    }

    const results = await Ad.find(query)
      .sort({ createdAt: -1 })
      .limit(50);

    res.json({
      success: true,
      ads: results,
      count: results.length
    });
  } catch (error) {
    console.error('Search ads error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la căutarea anunțurilor.'
    });
  }
});

module.exports = router;
