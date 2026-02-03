const express = require('express');
const Message = require('../models/Message');
const Ad = require('../models/Ad');
const authMiddleware = require('../middleware/auth');

const router = express.Router();

// Get user's conversations (lista de persoane cu care ai conversații)
router.get('/conversations', authMiddleware, async (req, res) => {
  try {
    // Găsește toate mesajele unde user-ul este sender sau receiver
    const messages = await Message.find({
      $or: [
        { senderId: req.userId },
        { receiverId: req.userId }
      ]
    })
    .populate('senderId', 'email')
    .populate('receiverId', 'email')
    .populate('adId', 'title photos name')
    .sort({ createdAt: -1 });

    // Grupează mesajele după conversație (cu cine vorbești)
    const conversationsMap = new Map();
    
    messages.forEach(msg => {
      const otherUserId = msg.senderId._id.toString() === req.userId 
        ? msg.receiverId._id.toString() 
        : msg.senderId._id.toString();
      
      if (!conversationsMap.has(otherUserId)) {
        const otherUser = msg.senderId._id.toString() === req.userId 
          ? msg.receiverId 
          : msg.senderId;
        
        const unreadCount = messages.filter(m => 
          m.senderId._id.toString() === otherUserId && 
          m.receiverId._id.toString() === req.userId && 
          !m.read
        ).length;

        conversationsMap.set(otherUserId, {
          userId: otherUser._id,
          userEmail: otherUser.email,
          adId: msg.adId._id,
          adTitle: msg.adId.title,
          adName: msg.adId.name,
          adPhoto: msg.adId.photos?.[0]?.url || null,
          lastMessage: msg.text,
          lastMessageTime: msg.createdAt,
          unreadCount: unreadCount,
          isLastMessageFromMe: msg.senderId._id.toString() === req.userId
        });
      }
    });

    const conversations = Array.from(conversationsMap.values());

    res.json({
      success: true,
      conversations,
      count: conversations.length
    });
  } catch (error) {
    console.error('Get conversations error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea conversațiilor.'
    });
  }
});

// Get messages with a specific user about a specific ad
router.get('/chat/:otherUserId/:adId', authMiddleware, async (req, res) => {
  try {
    const { otherUserId, adId } = req.params;

    // Găsește toate mesajele dintre cei 2 utilizatori pentru acest anunț
    const messages = await Message.find({
      adId: adId,
      $or: [
        { senderId: req.userId, receiverId: otherUserId },
        { senderId: otherUserId, receiverId: req.userId }
      ]
    })
    .sort({ createdAt: 1 }); // Ordine cronologică

    // Marchează ca citite mesajele primite
    await Message.updateMany(
      {
        adId: adId,
        senderId: otherUserId,
        receiverId: req.userId,
        read: false
      },
      { $set: { read: true } }
    );

    res.json({
      success: true,
      messages,
      count: messages.length
    });
  } catch (error) {
    console.error('Get chat messages error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea mesajelor.'
    });
  }
});

// Send a message
router.post('/send', authMiddleware, async (req, res) => {
  try {
    const { receiverId, adId, text } = req.body;

    if (!receiverId || !adId || !text || text.trim().length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Destinatar, anunț și text sunt obligatorii.'
      });
    }

    // Verifică că nu trimiți mesaj către tine
    if (receiverId === req.userId) {
      return res.status(400).json({
        success: false,
        message: 'Nu poți trimite mesaj către tine însuți.'
      });
    }

    // Verifică că anunțul există
    const ad = await Ad.findOne({ _id: adId, active: true });
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Anunț negăsit sau inactiv.'
      });
    }

    const message = await Message.create({
      senderId: req.userId,
      receiverId: receiverId,
      adId: adId,
      text: text.trim()
    });

    res.json({
      success: true,
      message: message,
      messageText: 'Mesaj trimis cu succes!'
    });
  } catch (error) {
    console.error('Send message error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la trimiterea mesajului.'
    });
  }
});

// Get unread messages count
router.get('/unread-count', authMiddleware, async (req, res) => {
  try {
    const count = await Message.countDocuments({
      receiverId: req.userId,
      read: false
    });

    res.json({
      success: true,
      unreadCount: count
    });
  } catch (error) {
    console.error('Get unread count error:', error);
    res.status(500).json({
      success: false,
      message: 'Eroare la obținerea numărului de mesaje necitite.'
    });
  }
});

module.exports = router;
