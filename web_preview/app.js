// WalkMate Interactive Web Prototype
// Pure Client-side Logic mirroring Flutter WalkMate

(function() {
  'use strict';

  // --- State Variables ---
  const state = {
    weightKg: 70.0,
    weightUnit: 'kg', // 'kg' or 'lbs'
    status: 'idle', // 'idle' | 'tracking' | 'paused' | 'summary'
    cumulativeDistanceMeters: 0.0,
    currentSpeedKmh: 0.0,
    durationSeconds: 0,
    caloriesBurned: 0.0,
    isSimulating: true, // Auto-simulates realistic walking
    strideInterval: null,
    tickerInterval: null,
    milestonesPassed: new Set(),
    selectedPhotoUrl: null,
    selectedPhrase: "A gentle step forward 🌱",
    customNote: "",
    lastPosition: null,
    geolocationWatchId: null,
  };

  // --- 500m Milestone Content ---
  const milestoneMap = {
    500: {
      title: "0.5 km done 🌱",
      message: "Nice start! Taking the first step is always the hardest, and you did it.",
      insight: "Your breathing and heart are settling into a warm, natural stride.",
      emoji: "🌱"
    },
    1000: {
      title: "1.0 km achieved 🌿",
      message: "A full kilometer! Feel the earth gently supporting every step you take.",
      insight: "Circulation is gently improving, bringing fresh oxygen to your mind.",
      emoji: "🌿"
    },
    1500: {
      title: "1.5 km unlocked 🍃",
      message: "You've settled into a lovely rhythm. Notice the quiet around you.",
      insight: "Your shoulders and neck naturally drop tension as you keep moving.",
      emoji: "🍃"
    },
    2000: {
      title: "2.0 km reached ✨",
      message: "Two kilometers of pure self-care. Notice how your thoughts clear.",
      insight: "Burned ~100 kcal: like recharging your brain's internal focus battery.",
      emoji: "✨"
    },
    2500: {
      title: "2.5 km milestone 🌸",
      message: "Halfway to five! Walk at your own gentle pace—there is no rush.",
      insight: "Movement boosts serotonin, providing a steady feeling of calm.",
      emoji: "🌸"
    },
    3000: {
      title: "3.0 km passed 🌾",
      message: "Three full kilometers. Beautiful dedication to your well-being.",
      insight: "Your leg muscles and core are happily engaging without strain.",
      emoji: "🌾"
    },
    4000: {
      title: "4.0 km completed 🌲",
      message: "Four kilometers! Over 5,000 gentle, mindful footprints left behind.",
      insight: "Your cardiovascular system is thanking you for this steady endurance.",
      emoji: "🌲"
    },
    5000: {
      title: "5.0 km champion 🌟",
      message: "Five whole kilometers of peaceful walking! Celebrate this moment.",
      insight: "You've given your heart, mind, and spirit a wonderful, lasting gift.",
      emoji: "🌟"
    }
  };

  const insightsList = [
    { emoji: "🌿", title: "Mind Clearing", desc: "A gentle walking pace stimulates blood flow to the hippocampus, boosting creative focus." },
    { emoji: "🌱", title: "Gentle Metabolism", desc: "Walking activates slow-twitch muscle fibers that steadily burn lipids without straining joints." },
    { emoji: "🍃", title: "Resting Harmony", desc: "Taking a short pause regulates heart rate recovery and resets breathing cadence." },
    { emoji: "✨", title: "Post-Walk Glow", desc: "Just 20 minutes of movement releases gentle mood-elevating neurotransmitters." },
    { emoji: "🔋", title: "Cellular Energy", desc: "Every 50 kcal burned powers the equivalent of an hour of uninterrupted cognitive focus." }
  ];

  // --- DOM Elements ---
  const els = {
    screenHome: document.getElementById('screenHome'),
    screenActive: document.getElementById('screenActive'),
    screenSummary: document.getElementById('screenSummary'),
    phoneFrame: document.getElementById('phoneFrame'),
    statusClock: document.getElementById('statusClock'),
    homeGreeting: document.getElementById('homeGreeting'),
    homeWeightDisplay: document.getElementById('homeWeightDisplay'),
    weightChipBtn: document.getElementById('weightChipBtn'),
    startWalkBtn: document.getElementById('startWalkBtn'),
    lifetimeWalks: document.getElementById('lifetimeWalks'),
    lifetimeDist: document.getElementById('lifetimeDist'),
    lifetimeCals: document.getElementById('lifetimeCals'),
    recentWalksList: document.getElementById('recentWalksList'),

    // Active
    walkStatusIndicator: document.getElementById('walkStatusIndicator'),
    walkStatusText: document.getElementById('walkStatusText'),
    breathingHalo: document.getElementById('breathingHalo'),
    liveDistance: document.getElementById('liveDistance'),
    livePace: document.getElementById('livePace'),
    liveDuration: document.getElementById('liveDuration'),
    liveSpeed: document.getElementById('liveSpeed'),
    liveCalories: document.getElementById('liveCalories'),
    liveMeters: document.getElementById('liveMeters'),
    activeInsightCard: document.getElementById('activeInsightCard'),
    insightIcon: document.getElementById('insightIcon'),
    insightTitle: document.getElementById('insightTitle'),
    insightDesc: document.getElementById('insightDesc'),
    pauseResumeBtn: document.getElementById('pauseResumeBtn'),
    pauseResumeIcon: document.getElementById('pauseResumeIcon'),
    pauseResumeLabel: document.getElementById('pauseResumeLabel'),
    finishWalkBtn: document.getElementById('finishWalkBtn'),
    closeActiveWalkBtn: document.getElementById('closeActiveWalkBtn'),
    milestoneToast: document.getElementById('milestoneToast'),
    milestoneEmoji: document.getElementById('milestoneEmoji'),
    milestoneTitle: document.getElementById('milestoneTitle'),
    milestoneMsg: document.getElementById('milestoneMsg'),
    milestoneInsight: document.getElementById('milestoneInsight'),
    dismissMilestoneBtn: document.getElementById('dismissMilestoneBtn'),

    // Summary
    walkMemoryCard: document.getElementById('walkMemoryCard'),
    cardDate: document.getElementById('cardDate'),
    cardTime: document.getElementById('cardTime'),
    cardUserPhoto: document.getElementById('cardUserPhoto'),
    cardPhotoFallback: document.getElementById('cardPhotoFallback'),
    cardArtTitle: document.getElementById('cardArtTitle'),
    cardPhraseText: document.getElementById('cardPhraseText'),
    cardNoteDisplay: document.getElementById('cardNoteDisplay'),
    cardDistVal: document.getElementById('cardDistVal'),
    cardDurationVal: document.getElementById('cardDurationVal'),
    cardCalVal: document.getElementById('cardCalVal'),
    cardSpeedVal: document.getElementById('cardSpeedVal'),
    photoFileInput: document.getElementById('photoFileInput'),
    removePhotoBtn: document.getElementById('removePhotoBtn'),
    phraseChipsContainer: document.getElementById('phraseChipsContainer'),
    customNoteInput: document.getElementById('customNoteInput'),
    downloadCardBtn: document.getElementById('downloadCardBtn'),
    shareCardBtn: document.getElementById('shareCardBtn'),
    doneWalkBtn: document.getElementById('doneWalkBtn'),
    summaryCloseBtn: document.getElementById('summaryCloseBtn'),

    // Modal
    weightModal: document.getElementById('weightModal'),
    weightNumericInput: document.getElementById('weightNumericInput'),
    unitKgBtn: document.getElementById('unitKgBtn'),
    unitLbsBtn: document.getElementById('unitLbsBtn'),
    saveWeightModalBtn: document.getElementById('saveWeightModalBtn'),
    closeWeightModalBtn: document.getElementById('closeWeightModalBtn'),

    // Top Controls
    toggleDeviceFrameBtn: document.getElementById('toggleDeviceFrameBtn'),
    gpsSimulateWalkBtn: document.getElementById('gpsSimulateWalkBtn'),
    jump500mBtn: document.getElementById('jump500mBtn'),
  };

  // --- Initialize App ---
  function init() {
    loadSavedSettings();
    updateClock();
    setInterval(updateClock, 1000);
    renderHomeView();
    bindEvents();
  }

  function updateClock() {
    const now = new Date();
    let hours = now.getHours();
    const minutes = now.getMinutes().toString().padLeft ? now.getMinutes().toString().padStart(2, '0') : now.getMinutes();
    els.statusClock.textContent = `${hours}:${minutes}`;

    // Update greeting
    if (hours < 12) {
      els.homeGreeting.textContent = "Good morning 🌱";
    } else if (hours < 17) {
      els.homeGreeting.textContent = "Peaceful afternoon 🍃";
    } else {
      els.homeGreeting.textContent = "Tranquil evening ✨";
    }
  }

  function loadSavedSettings() {
    const savedWeight = localStorage.getItem('walkmate_weight_kg');
    if (savedWeight) {
      state.weightKg = parseFloat(savedWeight);
    }
    const savedUnit = localStorage.getItem('walkmate_weight_unit');
    if (savedUnit) {
      state.weightUnit = savedUnit;
    }
    updateWeightDisplay();
  }

  function updateWeightDisplay() {
    let displayVal = state.weightKg;
    if (state.weightUnit === 'lbs') {
      displayVal = Math.round(state.weightKg * 2.20462);
    } else {
      displayVal = Math.round(state.weightKg);
    }
    els.homeWeightDisplay.textContent = `${displayVal} ${state.weightUnit}`;
  }

  // --- MET Calorie Calculation Engine ---
  function getMetForSpeed(speedKmh, isPaused) {
    if (isPaused) return 1.2;
    if (speedKmh <= 0.5) return 1.3;
    if (speedKmh < 2.5) return 2.0; // Strolling
    if (speedKmh < 3.5) return 2.8; // Relaxed
    if (speedKmh < 4.5) return 3.3; // Moderate
    if (speedKmh < 5.5) return 3.8; // Brisk
    if (speedKmh < 6.5) return 4.3; // Very brisk
    return 5.0; // Fast
  }

  function calculateIncrementalCalories(speedKmh, isPaused) {
    const met = getMetForSpeed(speedKmh, isPaused);
    // Calories/sec = ((MET * 3.5 * weightKg) / 200) / 60
    return ((met * 3.5 * state.weightKg) / 200.0) / 60.0;
  }

  // --- Walk Session Lifecycle ---
  function startWalk() {
    state.status = 'tracking';
    state.cumulativeDistanceMeters = 0.0;
    state.durationSeconds = 0;
    state.caloriesBurned = 0.0;
    state.currentSpeedKmh = state.isSimulating ? 4.7 : 0.0;
    state.milestonesPassed.clear();
    state.lastPosition = null;

    showScreen(els.screenActive);
    updateActiveView();

    // 1-second timer tick
    clearInterval(state.tickerInterval);
    state.tickerInterval = setInterval(onSecondTick, 1000);

    // Stride simulator or browser geolocation
    if (state.isSimulating) {
      clearInterval(state.strideInterval);
      state.strideInterval = setInterval(simulateStepDelta, 1000);
    } else {
      startRealGeolocation();
    }
  }

  function onSecondTick() {
    if (state.status === 'tracking') {
      state.durationSeconds++;
      state.caloriesBurned += calculateIncrementalCalories(state.currentSpeedKmh, false);
      updateActiveView();

      // Cycle insight every 60 seconds
      if (state.durationSeconds % 60 === 0) {
        const idx = Math.floor(state.durationSeconds / 60) % insightsList.length;
        const ins = insightsList[idx];
        els.insightIcon.textContent = ins.emoji;
        els.insightTitle.textContent = ins.title;
        els.insightDesc.textContent = ins.desc;
      }
    } else if (state.status === 'paused') {
      state.caloriesBurned += calculateIncrementalCalories(0, true);
      updateActiveView();
    }
  }

  function simulateStepDelta() {
    if (state.status !== 'tracking') return;
    // Normal walking pace: ~4.5 to 5.2 km/h -> ~1.25 to 1.45 meters/sec
    const jitter = (Math.random() * 0.4) - 0.2; // +/- 0.2 km/h
    state.currentSpeedKmh = Math.max(3.8, Math.min(5.6, 4.8 + jitter));
    const deltaMeters = (state.currentSpeedKmh * 1000.0) / 3600.0;

    const previousDistance = state.cumulativeDistanceMeters;
    state.cumulativeDistanceMeters += deltaMeters;

    checkMilestones(previousDistance, state.cumulativeDistanceMeters);
  }

  function checkMilestones(prevMeters, curMeters) {
    const prev500 = Math.floor(prevMeters / 500);
    const cur500 = Math.floor(curMeters / 500);

    if (cur500 > prev500 && cur500 > 0) {
      const milestoneDistance = cur500 * 500;
      if (!state.milestonesPassed.has(milestoneDistance)) {
        state.milestonesPassed.add(milestoneDistance);
        triggerMilestone(milestoneDistance);
      }
    }
  }

  function triggerMilestone(meters) {
    const info = milestoneMap[meters] || {
      title: `${(meters / 1000).toFixed(1)} km done 🌱`,
      message: "Continuing strong with grace and care. Be proud of each mindful step.",
      insight: "Every stride supports your vitality and inner calm.",
      emoji: "🌱"
    };

    els.milestoneEmoji.textContent = info.emoji;
    els.milestoneTitle.textContent = info.title;
    els.milestoneMsg.textContent = info.message;
    els.milestoneInsight.textContent = info.insight;
    els.milestoneToast.classList.remove('hidden');

    // Auto-dismiss toast after 9 seconds
    setTimeout(() => {
      els.milestoneToast.classList.add('hidden');
    }, 9000);
  }

  function togglePauseWalk() {
    if (state.status === 'tracking') {
      state.status = 'paused';
      state.currentSpeedKmh = 0.0;
      els.walkStatusIndicator.classList.add('paused');
      els.walkStatusText.textContent = "Walk Paused • Resting";
      els.pauseResumeIcon.textContent = "▶";
      els.pauseResumeLabel.textContent = "Resume";
      els.breathingHalo.classList.add('paused');

      els.insightIcon.textContent = "🍵";
      els.insightTitle.textContent = "Restful Pause";
      els.insightDesc.textContent = "Taking a breather helps lower cortisol and regulates your pulse back to normal.";
    } else if (state.status === 'paused') {
      state.status = 'tracking';
      state.currentSpeedKmh = 4.8;
      els.walkStatusIndicator.classList.remove('paused');
      els.walkStatusText.textContent = "Active Walk • Mindful Pace";
      els.pauseResumeIcon.textContent = "⏸";
      els.pauseResumeLabel.textContent = "Pause";
      els.breathingHalo.classList.remove('paused');
    }
  }

  function finishWalk() {
    state.status = 'summary';
    clearInterval(state.tickerInterval);
    clearInterval(state.strideInterval);
    if (state.geolocationWatchId) {
      navigator.geolocation.clearWatch(state.geolocationWatchId);
      state.geolocationWatchId = null;
    }

    renderSummaryView();
    showScreen(els.screenSummary);
  }

  // --- View Rendering ---
  function showScreen(targetScreen) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    targetScreen.classList.add('active');
  }

  function updateActiveView() {
    const km = (state.cumulativeDistanceMeters / 1000.0).toFixed(2);
    els.liveDistance.textContent = km;
    els.liveMeters.textContent = Math.round(state.cumulativeDistanceMeters);
    els.liveDuration.textContent = formatDuration(state.durationSeconds);
    els.liveSpeed.textContent = state.currentSpeedKmh.toFixed(1);
    els.liveCalories.textContent = Math.round(state.caloriesBurned);
    els.livePace.textContent = calculatePace(state.cumulativeDistanceMeters, state.durationSeconds);
  }

  function renderSummaryView() {
    const now = new Date();
    const dateOptions = { weekday: 'long', year: 'numeric', month: 'short', day: 'numeric' };
    const timeOptions = { hour: 'numeric', minute: '2-digit', hour12: true };

    els.cardDate.textContent = now.toLocaleDateString('en-US', dateOptions);
    els.cardTime.textContent = now.toLocaleTimeString('en-US', timeOptions);

    const km = (state.cumulativeDistanceMeters / 1000.0).toFixed(2);
    els.cardDistVal.textContent = km;
    els.cardDurationVal.textContent = formatDuration(state.durationSeconds);
    els.cardCalVal.textContent = Math.round(state.caloriesBurned);

    const totalHours = state.durationSeconds / 3600.0;
    const avgSpeed = (totalHours > 0 && state.cumulativeDistanceMeters > 0)
      ? ((state.cumulativeDistanceMeters / 1000.0) / totalHours).toFixed(1)
      : "0.0";
    els.cardSpeedVal.textContent = avgSpeed;

    els.cardArtTitle.textContent = `${km} km Mindful Walk`;
    els.cardPhraseText.textContent = state.selectedPhrase;

    // Reset photo
    if (!state.selectedPhotoUrl) {
      els.cardUserPhoto.classList.add('hidden');
      els.cardPhotoFallback.classList.remove('hidden');
    }

    saveSessionToHistory({
      date: now.toISOString(),
      distanceKm: km,
      duration: formatDuration(state.durationSeconds),
      calories: Math.round(state.caloriesBurned),
      phrase: state.selectedPhrase
    });
  }

  function renderHomeView() {
    const history = getSessionHistory();
    els.lifetimeWalks.textContent = history.length;

    let totalKm = 0;
    let totalCals = 0;
    history.forEach(item => {
      totalKm += parseFloat(item.distanceKm || 0);
      totalCals += parseInt(item.calories || 0);
    });

    els.lifetimeDist.textContent = `${totalKm.toFixed(1)} km`;
    els.lifetimeCals.textContent = `${totalCals} kcal`;

    if (history.length === 0) {
      els.recentWalksList.innerHTML = `<div class="empty-state"><p>No walks yet today. Take your first gentle step!</p></div>`;
    } else {
      els.recentWalksList.innerHTML = history.slice(0, 4).map(item => `
        <div class="recent-card">
          <div class="recent-icon-wrap">🌿</div>
          <div class="recent-details">
            <h4>${item.distanceKm} km Mindful Walk</h4>
            <p>${item.duration} • ${item.calories} kcal • ${item.phrase}</p>
          </div>
        </div>
      `).join('');
    }
  }

  function saveSessionToHistory(session) {
    const history = getSessionHistory();
    history.unshift(session);
    localStorage.setItem('walkmate_history', JSON.stringify(history.slice(0, 20)));
  }

  function getSessionHistory() {
    try {
      return JSON.parse(localStorage.getItem('walkmate_history')) || [];
    } catch (e) {
      return [];
    }
  }

  // --- Utilities ---
  function formatDuration(totalSeconds) {
    const mins = Math.floor(totalSeconds / 60);
    const secs = totalSeconds % 60;
    const hours = Math.floor(mins / 60);
    if (hours > 0) {
      const remMins = mins % 60;
      return `${hours}:${remMins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
    }
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  }

  function calculatePace(meters, seconds) {
    const km = meters / 1000.0;
    if (km < 0.05 || seconds < 10) return "--'--\" /km";
    const minutes = seconds / 60.0;
    const pace = minutes / km;
    if (pace > 60 || pace < 3) return "--'--\" /km";
    const pMin = Math.floor(pace);
    const pSec = Math.round((pace - pMin) * 60).toString().padStart(2, '0');
    return `${pMin}'${pSec}" /km`;
  }

  // --- Real Geolocation Handler ---
  function startRealGeolocation() {
    if (!navigator.geolocation) {
      alert("Geolocation is not supported in this browser. Falling back to simulation.");
      state.isSimulating = true;
      return;
    }

    state.geolocationWatchId = navigator.geolocation.watchPosition(
      pos => {
        const { latitude, longitude, speed } = pos.coords;
        if (state.lastPosition) {
          const delta = haversineDistance(
            state.lastPosition.lat, state.lastPosition.lng,
            latitude, longitude
          );

          if (delta > 2 && delta < 30) { // filter noise & jumps
            const prev = state.cumulativeDistanceMeters;
            state.cumulativeDistanceMeters += delta;
            state.currentSpeedKmh = speed ? (speed * 3.6) : (delta * 3.6);
            checkMilestones(prev, state.cumulativeDistanceMeters);
          }
        }
        // Immediately drop old reference
        state.lastPosition = { lat: latitude, lng: longitude };
      },
      err => {
        console.warn("GPS error:", err);
      },
      { enableHighAccuracy: true, maximumAge: 2000, timeout: 5000 }
    );
  }

  function haversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371e3; // Earth radius in meters
    const toRad = x => (x * Math.PI) / 180;
    const dLat = toRad(lat2 - lat1);
    const dLon = toRad(lon2 - lon1);
    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
              Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
              Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  // --- Photo & Memory Card Export ---
  function handlePhotoUpload(file) {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = function(e) {
      state.selectedPhotoUrl = e.target.result;
      els.cardUserPhoto.src = state.selectedPhotoUrl;
      els.cardUserPhoto.classList.remove('hidden');
      els.cardPhotoFallback.classList.add('hidden');
      els.removePhotoBtn.classList.remove('hidden');
    };
    reader.readAsDataURL(file);
  }

  function downloadCardAsPng() {
    if (typeof html2canvas === 'undefined') {
      alert("Canvas library loading, please try again in a moment.");
      return;
    }

    els.downloadCardBtn.disabled = true;
    els.downloadCardBtn.textContent = "Rendering Card...";

    html2canvas(els.walkMemoryCard, {
      scale: 3, // High quality 3x DPI
      useCORS: true,
      backgroundColor: null
    }).then(canvas => {
      const dataUrl = canvas.toDataURL('image/png');
      const link = document.createElement('a');
      link.download = `WalkMate_Memory_${Date.now()}.png`;
      link.href = dataUrl;
      link.click();

      els.downloadCardBtn.disabled = false;
      els.downloadCardBtn.innerHTML = `<span>📥 Download Card (PNG)</span>`;
    }).catch(err => {
      console.error("html2canvas error:", err);
      els.downloadCardBtn.disabled = false;
      els.downloadCardBtn.innerHTML = `<span>📥 Download Card (PNG)</span>`;
    });
  }

  function shareMemory() {
    const shareText = `I completed a peaceful ${(state.cumulativeDistanceMeters / 1000).toFixed(2)} km walk with WalkMate 🌱`;
    if (navigator.share) {
      navigator.share({
        title: "WalkMate Memory",
        text: shareText,
        url: window.location.href
      }).catch(() => {});
    } else {
      navigator.clipboard.writeText(shareText);
      alert("Walk summary copied to clipboard! Ready to paste into WhatsApp, Instagram, or messages. 🌸");
    }
  }

  // --- Event Bindings ---
  function bindEvents() {
    // Navigation
    els.startWalkBtn.addEventListener('click', startWalk);
    els.pauseResumeBtn.addEventListener('click', togglePauseWalk);
    els.finishWalkBtn.addEventListener('click', finishWalk);
    els.closeActiveWalkBtn.addEventListener('click', finishWalk);
    els.doneWalkBtn.addEventListener('click', () => {
      renderHomeView();
      showScreen(els.screenHome);
    });
    els.summaryCloseBtn.addEventListener('click', () => {
      renderHomeView();
      showScreen(els.screenHome);
    });

    // Milestone Toast dismiss
    els.dismissMilestoneBtn.addEventListener('click', () => {
      els.milestoneToast.classList.add('hidden');
    });

    // Weight Modal
    els.weightChipBtn.addEventListener('click', () => {
      els.weightNumericInput.value = Math.round(state.weightUnit === 'lbs' ? state.weightKg * 2.20462 : state.weightKg);
      els.weightModal.classList.remove('hidden');
    });

    els.closeWeightModalBtn.addEventListener('click', () => {
      els.weightModal.classList.add('hidden');
    });

    els.unitKgBtn.addEventListener('click', () => {
      els.unitKgBtn.classList.add('active');
      els.unitLbsBtn.classList.remove('active');
      const cur = parseFloat(els.weightNumericInput.value);
      if (cur) els.weightNumericInput.value = Math.round(cur / 2.20462);
    });

    els.unitLbsBtn.addEventListener('click', () => {
      els.unitLbsBtn.classList.add('active');
      els.unitKgBtn.classList.remove('active');
      const cur = parseFloat(els.weightNumericInput.value);
      if (cur) els.weightNumericInput.value = Math.round(cur * 2.20462);
    });

    els.saveWeightModalBtn.addEventListener('click', () => {
      const val = parseFloat(els.weightNumericInput.value);
      const isLbs = els.unitLbsBtn.classList.contains('active');
      if (val && val >= 25 && val <= 300) {
        state.weightUnit = isLbs ? 'lbs' : 'kg';
        state.weightKg = isLbs ? (val / 2.20462) : val;
        localStorage.setItem('walkmate_weight_kg', state.weightKg.toString());
        localStorage.setItem('walkmate_weight_unit', state.weightUnit);
        updateWeightDisplay();
        els.weightModal.classList.add('hidden');
      } else {
        alert("Please enter a valid weight between 25 and 300.");
      }
    });

    // Photo Upload
    els.photoFileInput.addEventListener('change', (e) => {
      if (e.target.files && e.target.files[0]) {
        handlePhotoUpload(e.target.files[0]);
      }
    });

    els.removePhotoBtn.addEventListener('click', () => {
      state.selectedPhotoUrl = null;
      els.cardUserPhoto.src = '';
      els.cardUserPhoto.classList.add('hidden');
      els.cardPhotoFallback.classList.remove('hidden');
      els.removePhotoBtn.classList.add('hidden');
      els.photoFileInput.value = '';
    });

    // Phrase Chips
    els.phraseChipsContainer.addEventListener('click', (e) => {
      const chip = e.target.closest('.phrase-chip');
      if (!chip) return;
      document.querySelectorAll('.phrase-chip').forEach(c => c.classList.remove('active'));
      chip.classList.add('active');
      state.selectedPhrase = chip.dataset.phrase;
      els.cardPhraseText.textContent = state.selectedPhrase;
    });

    // Custom Note
    els.customNoteInput.addEventListener('input', (e) => {
      const val = e.target.value.trim();
      if (val) {
        els.cardNoteDisplay.textContent = `“${val}”`;
        els.cardNoteDisplay.classList.remove('hidden');
      } else {
        els.cardNoteDisplay.classList.add('hidden');
      }
    });

    // Card Export
    els.downloadCardBtn.addEventListener('click', downloadCardAsPng);
    els.shareCardBtn.addEventListener('click', shareMemory);

    // Top Preview Controls
    els.toggleDeviceFrameBtn.addEventListener('click', () => {
      els.phoneFrame.classList.toggle('fullscreen-mode');
      const isFull = els.phoneFrame.classList.contains('fullscreen-mode');
      els.toggleDeviceFrameBtn.textContent = isFull ? "💻 Expanded View" : "📱 Phone Frame";
    });

    els.gpsSimulateWalkBtn.addEventListener('click', () => {
      state.isSimulating = !state.isSimulating;
      els.gpsSimulateWalkBtn.textContent = state.isSimulating
        ? "🚶 Simulate Stride (4.8 km/h)"
        : "📍 Real GPS Mode";
      els.gpsSimulateWalkBtn.classList.toggle('accent', state.isSimulating);
    });

    // Instant 500m Milestone Trigger
    els.jump500mBtn.addEventListener('click', () => {
      if (state.status !== 'tracking' && state.status !== 'paused') {
        startWalk();
      }
      const prev = state.cumulativeDistanceMeters;
      state.cumulativeDistanceMeters += 500;
      state.durationSeconds += 375; // ~6.2 minutes of walking
      state.caloriesBurned += calculateIncrementalCalories(4.8, false) * 375;
      updateActiveView();
      checkMilestones(prev, state.cumulativeDistanceMeters);
    });
  }

  // Run on page load
  document.addEventListener('DOMContentLoaded', init);
})();
