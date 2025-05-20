const express = require('express');
const { createEvent, getEvents, eventDetails, 
    getMyEvent, UpdateEvent, deleteEvent, 
    getMostNearUpcomingEvent, userLike,
    getEventAttendeeCount, 
    approveOrRejectEvent} = require('../controllers/eventController');
const verifyToken = require('../middlewares/verifyToken');
const checkRole = require('../middlewares/checkRole');
const router = express.Router();
const upload=require('../utils/multer')

router.post('/creatEvent',   upload, createEvent);
router.get('/getEvent',  getEvents);
router.get('/nearUpcoming', getMostNearUpcomingEvent);
router.put("/:eventId/status", approveOrRejectEvent);
router.get('/myEvent', verifyToken, checkRole('organizer'), getMyEvent);
router.get('/:id', eventDetails);
router.put('/update/:id', verifyToken, checkRole('organizer'), UpdateEvent);
router.delete('/delete/:id', verifyToken, checkRole('organizer','admin'), deleteEvent);
router.post('/userLike/:eventId', verifyToken, userLike);
router.get('/:eventId/attendeeCount', getEventAttendeeCount);


module.exports = router;
