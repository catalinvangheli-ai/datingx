const express = require('express');
const multer = require('multer');
const Profile = require('../models/Profile');
const { uploadImage, deleteImage } = require('../config/cloudinary');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Configure multer for memory storage
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Doar imagini sunt acceptate!'), false);
    }
  }
});

// Upload photo
router.post('/upload', authMiddleware, upload.single('photo'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Nicio imagine încărcată.'
      });
    }
    
    // Upload to Cloudinary
    const result = await uploadImage(
      req.file.buffer,
      `datingx/users/${req.userId}`
    );
    
    // Add photo to profile
    const profile = await Profile.findOne({ userId: req.userId });
    
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Profil negăsit. Creează profilul mai întâi.'
      });
    }
    
    // Check photo limit (max 6 photos)
    if (profile.photos.length >= 6) {
      // Delete uploaded image from Cloudinary
      await deleteImage(result.public_id);
      
      return res.status(400).json({
        success: false,
        message: 'Poți avea maxim 6 fotografii.'
      });
    }
    
    // Add photo to profile
    profile.photos.push({
      url: result.secure_url,
      cloudinaryId: result.public_id
    });
    
    await profile.save();
    
    res.json({
      success: true,
      message: `Fotografie adăugată: ${req.file.originalname}`,
      photo: {
        url: result.secure_url,
        cloudinaryId: result.public_id
      }
    });
  } catch (error) {
    console.error('Upload photo error:', error);
    res.status(500).json({
      success: false,
      message: error.message || 'Eroare la încărcarea fotografiei.'
    });
  }
});

// Delete photo
router.delete('/:cloudinaryId', authMiddleware, async (req, res) => {
  try {
    const { cloudinaryId } = req.params;
    
    // Remove from profile
    const profile = await Profile.findOne({ userId: req.userId });
    
    if (!profile) {
      return res.status(404).json({
        success: false,
        message: 'Profil negăsit.'
      });
    }
    
    // Find and remove photo
    const photoIndex = profile.photos.findIndex(
      p => p.cloudinaryId === cloudinaryId
    );
    
    if (photoIndex === -1) {
      return res.status(404).json({
        success: false,
        message: 'Fotografie negăsită.'
      });
    }
    
    // Delete from Cloudinary
    await deleteImage(cloudinaryId);
    
    // Remove from profile
    profile.photos.splice(photoIndex, 1);
    await profile.save();
    
    res.json({
      success: true,
      message: 'Fotografie ștearsă cu succes.'
    });
  } catch (error) {
    console.error('Delete photo error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la ștergerea fotografiei.'
    });
  }
});

module.exports = router;
