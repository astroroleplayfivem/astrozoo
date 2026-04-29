const app = document.getElementById('app');
app.classList.add('hidden');

let currentPenKey = null;
const $ = (id) => document.getElementById(id);

function setBar(id, val) {
    const el = $(id);
    if (!el) return;
    el.style.width = `${Math.max(0, Math.min(100, val || 0))}%`;
}

function fill(details) {
    currentPenKey = details.key;
    $('title').textContent = `Astro Zoo - ${details.label}`;
    $('subtitle').textContent = 'Enclosure Board';
    $('species').textContent = details.species;
    $('summaryText').textContent = details.summary;
    $('habitat').textContent = details.habitat;
    $('diet').textContent = details.diet;
    $('temperament').textContent = details.temperament;
    $('danger').textContent = details.danger;
    $('status').textContent = details.stats.isEscaped ? 'Escaped / Returning' : (details.stats.status || 'Stable');
    $('moodLabel').textContent = `${details.stats.mood}%`;
    $('hungerValue').textContent = `${details.stats.hunger}%`;
    $('hydrationValue').textContent = `${details.stats.hydration}%`;
    $('cleanlinessValue').textContent = `${details.stats.cleanliness}%`;
    $('stimulationValue').textContent = `${details.stats.stimulation}%`;
    $('escapeValue').textContent = `${details.stats.escapeRisk}%`;
    setBar('moodBar', details.stats.mood);
    setBar('hungerBar', details.stats.hunger);
    setBar('hydrationBar', details.stats.hydration);
    setBar('cleanlinessBar', details.stats.cleanliness);
    setBar('stimulationBar', details.stats.stimulation);
    setBar('escapeBar', details.stats.escapeRisk);
    const facts = $('facts');
    facts.innerHTML = '';
    (details.facts || []).forEach((f) => {
        const li = document.createElement('li');
        li.textContent = f;
        facts.appendChild(li);
    });
}
window.addEventListener('message', (e) => {
    const d = e.data;
    if (d.action === 'open') {
        app.classList.remove('hidden');
        fill(d.details);
    } else if (d.action === 'update') {
        fill(d.details);
    } else if (d.action === 'close') {
        app.classList.add('hidden');
    } else if (d.action === 'ambientMusicStart') {
        startAmbientMusic(d.music || {});
    } else if (d.action === 'ambientMusicStop') {
        stopAmbientMusic();
    }
});


const ambientPlayerHost = document.getElementById('ambientPlayer');
let youtubePlayer = null;
let youtubeReady = false;
let youtubeScriptRequested = false;
let currentMusicConfig = null;
let directAudio = null;

function ensureDirectAudio() {
    if (directAudio) return directAudio;
    directAudio = document.createElement('audio');
    directAudio.loop = true;
    directAudio.preload = 'auto';
    directAudio.style.display = 'none';
    ambientPlayerHost.appendChild(directAudio);
    return directAudio;
}

function loadYouTubeApi() {
    if (youtubeScriptRequested) return;
    youtubeScriptRequested = true;
    const tag = document.createElement('script');
    tag.src = 'https://www.youtube.com/iframe_api';
    document.head.appendChild(tag);
}

window.onYouTubeIframeAPIReady = function () {
    youtubeReady = true;
    if (currentMusicConfig && currentMusicConfig.sourceType === 'youtube') {
        buildYouTubePlayer(currentMusicConfig);
    }
};

function buildYouTubePlayer(cfg) {
    if (!cfg.youtubeId || !youtubeReady) return;
    ambientPlayerHost.innerHTML = '<div id="yt-ambient-frame"></div>';
    youtubePlayer = new YT.Player('yt-ambient-frame', {
        height: '1',
        width: '1',
        videoId: cfg.youtubeId,
        playerVars: {
            autoplay: 1,
            controls: 0,
            disablekb: 1,
            fs: 0,
            iv_load_policy: 3,
            modestbranding: 1,
            playsinline: 1,
            rel: 0,
            loop: 1,
            playlist: cfg.youtubeId
        },
        events: {
            onReady: function (event) {
                event.target.setVolume(Math.max(0, Math.min(100, cfg.volume || 10)));
                event.target.playVideo();
            },
            onStateChange: function (event) {
                if (event.data === YT.PlayerState.ENDED) {
                    event.target.playVideo();
                }
            }
        }
    });
}

function startAmbientMusic(cfg) {
    currentMusicConfig = cfg || {};
    if ((cfg.sourceType || 'youtube') === 'direct' && cfg.directUrl) {
        const audio = ensureDirectAudio();
        if (audio.src !== cfg.directUrl) audio.src = cfg.directUrl;
        audio.volume = Math.max(0, Math.min(1, (cfg.volume || 10) / 100));
        audio.play().catch(() => {});
        return;
    }
    loadYouTubeApi();
    if (youtubeReady) {
        if (!youtubePlayer) {
            buildYouTubePlayer(cfg);
        } else {
            try {
                youtubePlayer.setVolume(Math.max(0, Math.min(100, cfg.volume || 10)));
                youtubePlayer.playVideo();
            } catch (e) {}
        }
    }
}

function stopAmbientMusic() {
    if (directAudio) {
        directAudio.pause();
    }
    if (youtubePlayer) {
        try { youtubePlayer.pauseVideo(); } catch (e) {}
    }
}
function post(action) {
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ penKey: currentPenKey })
    });
}
$('close').onclick = () => post('close');
$('observeBtn').onclick = () => post('observe');
$('feedBtn').onclick = () => post('feed');
$('cleanBtn').onclick = () => post('clean');
$('detailsBtn').onclick = () => post('observe');
document.addEventListener('keyup', (e) => { if (e.key === 'Escape') post('close'); });
