require('dotenv').config();
const axios = require('axios');

const CONFIG = {
  lastfmUsername: process.env.LASTFM_USERNAME,
  lastfmApiKey: process.env.LASTFM_API_KEY,
  discordToken: process.env.DISCORD_BOT_TOKEN,
  appId: process.env.APPLICATION_ID,
  userId: process.env.DISCORD_USER_ID,
  syncIntervalMs: 30 * 1000
};

for (const [key, value] of Object.entries(CONFIG)) {
  if (!value) {
    console.error(`Missing configuration for "${key}" in your .env file`);
    process.exit(1);
  }
}

CONFIG.userId = CONFIG.userId.replace(/\D/g, '');

async function fetchLastFMData() {
  console.log(`Fetching live tracking & profile stats for: ${CONFIG.lastfmUsername}...`);

  try {
    const infoUrl = `https://ws.audioscrobbler.com/2.0/?method=user.getinfo&user=${CONFIG.lastfmUsername}&api_key=${CONFIG.lastfmApiKey}&format=json`;
    const tracksUrl = `https://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=${CONFIG.lastfmUsername}&api_key=${CONFIG.lastfmApiKey}&limit=1&format=json`;
    const topTracksUrl = `https://ws.audioscrobbler.com/2.0/?method=user.gettoptracks&user=${CONFIG.lastfmUsername}&api_key=${CONFIG.lastfmApiKey}&limit=1&period=overall&format=json`;
    const topArtistsUrl = `https://ws.audioscrobbler.com/2.0/?method=user.gettopartists&user=${CONFIG.lastfmUsername}&api_key=${CONFIG.lastfmApiKey}&limit=1&period=overall&format=json`;

    const [infoRes, tracksRes, topTracksRes, topArtistsRes] = await Promise.all([
      axios.get(infoUrl),
      axios.get(tracksUrl),
      axios.get(topTracksUrl),
      axios.get(topArtistsUrl)
    ]);

    const userProfile = infoRes.data?.user || {};
    const recentTracks = tracksRes.data?.recenttracks?.track || [];

    const totalScrobbles = String(userProfile.playcount || "0");
    const latestTrack = Array.isArray(recentTracks) ? recentTracks[0] : recentTracks;
    const isNowPlaying = latestTrack?.['@attr']?.nowplaying === 'true';

    const globalTopTrack = topTracksRes.data?.toptracks?.track?.[0]?.name || "None";
    const globalTopArtist = topArtistsRes.data?.topartists?.artist?.[0]?.name || "None";

    const userAvatar = userProfile.image?.[3]?.['#text'] || userProfile.image?.[0]?.['#text'] || "";

    let currentStatus = "Paused / Idle";
    let albumArtUrl = userAvatar;
    let trackName = "None";
    let artistName = "None";
    let albumName = "None";
    let liveState = "Idle";

    if (isNowPlaying && latestTrack) {
      trackName = latestTrack.name || "Unknown Track";
      artistName = latestTrack.artist?.['#text'] || "Unknown Artist";
      albumName = latestTrack.album?.['#text'] || "Single / Unknown Album";
      currentStatus = `${trackName} - ${artistName}`;
      liveState = "Live";

      if (latestTrack.image && latestTrack.image.length > 0) {
        const foundArt = latestTrack.image[3]?.['#text'] || latestTrack.image[latestTrack.image.length - 1]?.['#text'] || "";
        if (foundArt.trim() !== "") {
          albumArtUrl = foundArt;
        }
      }
    }

    return {
      username: userProfile.name || CONFIG.lastfmUsername,
      status: currentStatus,
      scrobbles: totalScrobbles,
      coverArt: albumArtUrl,
      track: trackName,
      artist: artistName,
      album: albumName,
      liveState: liveState,
      topTrack: globalTopTrack,
      topArtist: globalTopArtist
    };

  } catch (error) {
    throw new Error(`Last.fm Data Sync Failed: ${error.message}`);
  }
}

async function pushDataToDiscordWidget(stats) {
  console.log('Sending updated data to layout slots...');

  const payload = {
    username: stats.username,
    data: {
      image: stats.coverArt || null,
      dynamic: [
        { type: 1, name: 'nowplaying', value: stats.status },
        { type: 1, name: 'Artist', value: stats.artist },
        { type: 1, name: 'Album', value: stats.album },
        { type: 1, name: 'Scrobbles', value: stats.scrobbles },
        { type: 1, name: 'Status', value: stats.liveState },
        { type: 1, name: 'TopTracks', value: stats.topTrack },
        { type: 1, name: 'TopArtists', value: stats.topArtist }
      ]
    }
  };

  try {
    const discordUrl = `https://discord.com/api/v9/applications/${CONFIG.appId}/users/${CONFIG.userId}/identities/0/profile`;

    await axios.patch(discordUrl, payload, {
      headers: {
        'Authorization': `Bot ${CONFIG.discordToken}`,
        'Content-Type': 'application/json',
        'User-Agent': 'DiscordBot (https://github.com/node-axios, 1.0.0)'
      }
    });

    console.log('All vinyl dashboard fields active.');
  } catch (error) {
    const errorDetails = error.response?.data ? JSON.stringify(error.response.data) : error.message;
    console.error(`Discord API error: ${errorDetails}`);
  }
}

async function runMusicPipeline() {
  console.log('\n----------------------------------------');
  console.log(`[${new Date().toLocaleTimeString()}] Updating layout data...`);
  try {
    const musicStats = await fetchLastFMData();
    await pushDataToDiscordWidget(musicStats);
  } catch (error) {
    console.error(`Pipeline failure: ${error.message}`);
  }
}

runMusicPipeline();
setInterval(runMusicPipeline, CONFIG.syncIntervalMs);