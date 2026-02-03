const express = require('express');
const FavoriteAd = require('../models/FavoriteAd');
const Ad = require('../models/Ad');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Get user's favorite ads
router.get('/my-favorites', authMiddleware, async (req, res) => {
  try {
    const favorites = await FavoriteAd.find({ userId: req.userId })
      .populate({
        path: 'adId',
        match: { active: true }, // Doar anunțuri active
        select: '-__v'
      })
      .sort({ createdAt: -1 });

    // Filtrează null-urile (anunțuri șterse)
    const activeFavorites = favorites
      .filter(f => f.adId != null)
      .map(f => f.adId);

    res.json({
      success: true,
      favorites: activeFavorites,
      count: activeFavorites.length
    });
  } catch (error) {
    console.error('Get favorites error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea anunțurilor favorite.'
    });
  }
});

// Check if ad is favorited
router.get('/check/:adId', authMiddleware, async (req, res) => {
  try {
    const favorite = await FavoriteAd.findOne({
      userId: req.userId,
      adId: req.params.adId
    });

    res.json({
      success: true,
      isFavorite: !!favorite
    });
  } catch (error) {
    console.error('Check favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la verificarea favorit.'
    });
  }
});

// Add ad to favorites
router.post('/add/:adId', authMiddleware, async (req, res) => {
  try {
    const adId = req.params.adId;

    // Verifică dacă anunțul există și este activ
    const ad = await Ad.findOne({ _id: adId, active: true });
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Anunț negăsit sau inactiv.'
      });
    }

    // Nu poți salva propriul anunț
    if (ad.userId.toString() === req.userId) {
      return res.status(400).json({
        success: false,
        message: 'Nu poți salva propriul anunț.'
      });
    }

    // Verifică dacă deja este favorit
    const existing = await FavoriteAd.findOne({
      userId: req.userId,
      adId: adId
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Anunțul este deja în favorite.'
      });
    }

    // Adaugă la favorite
    await FavoriteAd.create({
      userId: req.userId,
      adId: adId
    });

    res.json({
      success: true,
      message: 'Anunț adăugat la favorite!'
    });
  } catch (error) {
    console.error('Add favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la adăugarea în favorite.'
    });
  }
});

// Remove ad from favorites
router.delete('/remove/:adId', authMiddleware, async (req, res) => {
  try {
    const result = await FavoriteAd.deleteOne({
      userId: req.userId,
      adId: req.params.adId
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        success: false,
        message: 'Anunțul nu este în favorite.'
      });
    }

    res.json({
      success: true,
      message: 'Anunț eliminat din favorite.'
    });
  } catch (error) {
    console.error('Remove favorite error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la eliminarea din favorite.'
    });
  }
});

module.exports = router;
