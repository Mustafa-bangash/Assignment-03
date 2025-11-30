// Simple REST API for SmartTracker
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(bodyParser.json({limit: '50mb'})); 

let activities = []; // In-memory storage

// GET: Fetch history
app.get('/api/activities', (req, res) => {
    res.json(activities);
});

// POST: Add new activity
app.post('/api/activities', (req, res) => {
    const newActivity = { id: Date.now().toString(), ...req.body };
    activities.unshift(newActivity); // Add to top
    res.json(newActivity);
});

// DELETE: Remove activity
app.delete('/api/activities/:id', (req, res) => {
    activities = activities.filter(a => a.id !== req.params.id);
    res.json({ success: true });
});

app.listen(3000, () => console.log('Server running on port 3000'));