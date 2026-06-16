const express = require('express');
const Report = require('../models/Report');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// POST /api/reports — Raportează un utilizator
router.post('/', authMiddleware, async (req, res) => {
  try {
    const { reportedUserId, reason, details } = req.body;

    if (!reportedUserId || !reason) {
      return res.status(400).json({
        success: false,
        message: 'reportedUserId și reason sunt obligatorii',
      });
    }

    // Nu te poți raporta pe tine însuți
    if (reportedUserId === req.userId) {
      return res.status(400).json({
        success: false,
        message: 'Nu poți raporta propriul cont',
      });
    }

    const report = new Report({
      reporterId: req.userId,
      reportedUserId,
      reason,
      details: details || '',
    });

    await report.save();

    res.status(201).json({
      success: true,
      message: 'Raportul a fost trimis. Mulțumim că ne ajuți să menținem comunitatea sigură.',
    });
  } catch (error) {
    console.error('Error creating report:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare internă la trimiterea raportului',
    });
  }
});

module.exports = router;
