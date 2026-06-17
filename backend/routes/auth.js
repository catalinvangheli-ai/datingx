const express = require('express');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const { body, validationResult } = require('express-validator');
const User = require('../models/User');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Register
router.post('/register',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 6 })
  ],
  async (req, res) => {
    try {
      // Validate input
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Date invalide.',
          errors: errors.array()
        });
      }
      
      const { email, password } = req.body;
      
      // Check if user exists
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Email deja înregistrat.'
        });
      }
      
      // Create new user
      const user = new User({ email, password });
      await user.save();
      
      // Generate JWT token
      const token = jwt.sign(
        { userId: user._id },
        process.env.JWT_SECRET,
        { expiresIn: '30d' }
      );
      
      res.status(201).json({
        success: true,
        message: 'Cont creat cu succes!',
        token,
        user: {
          id: user._id,
          email: user.email
        }
      });
    } catch (error) {
      console.error('Register error:', error);
      res.status(500).json({
        success: false,
        message: 'Eroare la înregistrare.'
      });
    }
  }
);

// Login
router.post('/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').exists()
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({
          success: false,
          message: 'Date invalide.'
        });
      }
      
      const { email, password } = req.body;
      
      // Find user
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(401).json({
          success: false,
          message: 'Email sau parolă incorectă.'
        });
      }
      
      // Check password
      const isMatch = await user.comparePassword(password);
      if (!isMatch) {
        return res.status(401).json({
          success: false,
          message: 'Email sau parolă incorectă.'
        });
      }
      
      // Update last login
      user.lastLogin = new Date();
      await user.save();
      
      // Generate token
      const token = jwt.sign(
        { userId: user._id },
        process.env.JWT_SECRET,
        { expiresIn: '30d' }
      );
      
      res.json({
        success: true,
        message: 'Autentificare reușită!',
        token,
        user: {
          id: user._id,
          email: user.email
        }
      });
    } catch (error) {
      console.error('Login error:', error);
      res.status(500).json({
        success: false,
        message: 'Eroare la autentificare.'
      });
    }
  }
);

// Get current user
router.get('/me', authMiddleware, async (req, res) => {
  try {
    const user = await User.findById(req.userId).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'Utilizator negăsit.'
      });
    }
    
    res.json({
      success: true,
      user: {
        id: user._id,
        email: user.email
      }
    });
  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea datelor.'
    });
  }
});

// Delete account
router.delete('/account', authMiddleware, async (req, res) => {
  try {
    await User.findByIdAndDelete(req.userId);
    
    res.json({
      success: true,
      message: 'Cont șters cu succes.'
    });
  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la ștergerea contului.'
    });
  }
});

// Forgot password - trimite cod pe email
router.post('/forgot-password',
  [body('email').isEmail().normalizeEmail()],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, message: 'Email invalid.' });
      }

      const { email } = req.body;
      const user = await User.findOne({ email });

      // Răspundem mereu cu succes (securitate - nu dezvăluim dacă emailul există)
      if (!user) {
        return res.json({ success: true, message: 'Dacă emailul există, vei primi un cod.' });
      }

      // Generează cod 6 cifre
      const code = crypto.randomInt(100000, 999999).toString();
      const codeHash = crypto.createHash('sha256').update(code).digest('hex');

      user.resetPasswordToken = codeHash;
      user.resetPasswordExpires = new Date(Date.now() + 60 * 60 * 1000); // 1 oră
      await user.save();

      // Trimite email
      const transporter = nodemailer.createTransport({
        service: 'gmail',
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      await transporter.sendMail({
        from: `"DatingX" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: 'Resetare parolă DatingX',
        html: `
          <div style="font-family:Segoe UI,Arial,sans-serif;max-width:500px;margin:0 auto;padding:32px;background:#f7f8fb;border-radius:12px;">
            <h2 style="color:#e11d48;text-align:center;">DatingX</h2>
            <p style="font-size:16px;">Ai solicitat resetarea parolei. Folosește codul de mai jos în aplicație:</p>
            <div style="text-align:center;margin:32px 0;">
              <span style="font-size:40px;font-weight:bold;letter-spacing:10px;color:#1f2937;background:#ffffff;padding:16px 24px;border-radius:8px;border:2px solid #e5e7eb;">${code}</span>
            </div>
            <p style="color:#6b7280;font-size:14px;">Codul este valabil <strong>1 oră</strong>. Dacă nu ai solicitat resetarea parolei, ignoră acest email.</p>
          </div>
        `,
      });

      res.json({ success: true, message: 'Dacă emailul există, vei primi un cod.' });
    } catch (error) {
      console.error('Forgot password error:', error);
      res.status(500).json({ success: false, message: 'Eroare la trimiterea emailului.' });
    }
  }
);

// Reset password - validează codul și setează parola nouă
router.post('/reset-password',
  [
    body('email').isEmail().normalizeEmail(),
    body('code').isLength({ min: 6, max: 6 }).isNumeric(),
    body('password').isLength({ min: 6 }),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ success: false, message: 'Date invalide.' });
      }

      const { email, code, password } = req.body;
      const codeHash = crypto.createHash('sha256').update(code).digest('hex');

      const user = await User.findOne({
        email,
        resetPasswordToken: codeHash,
        resetPasswordExpires: { $gt: new Date() },
      });

      if (!user) {
        return res.status(400).json({ success: false, message: 'Cod invalid sau expirat.' });
      }

      user.password = password;
      user.resetPasswordToken = undefined;
      user.resetPasswordExpires = undefined;
      await user.save();

      res.json({ success: true, message: 'Parola a fost resetată cu succes!' });
    } catch (error) {
      console.error('Reset password error:', error);
      res.status(500).json({ success: false, message: 'Eroare la resetarea parolei.' });
    }
  }
);

module.exports = router;
