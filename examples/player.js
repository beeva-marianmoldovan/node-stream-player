const StreamPlayer = require('../lib/stream-player');
const player = new StreamPlayer();

// Events
player.on('error', function (err) {
    console.log(err);
});
player.on('add', function (url) {
    console.log('=> add : ' + url);
});
player.on('playing', function (song) {
    console.log('=> start : ' + song.id);
});
player.on('paused', function (state) {
    console.log('=> paused : ' + state);
});
player.on('ended', function (song) {
    console.log('=> end : ' + song.id);
});

// Add songs url to the queue
player.add('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', {id: 1});
player.add('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', {id: 2});
player.add('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', {id: 3});

// Check my queue
console.log(player.getQueue());

// Remove a song with this id
player.remove(2);
console.log(player.getQueue());

// First play
player.play();

let wait = 1500;
setTimeout(() => {
    console.log('=> Pause / play');
    console.log('-> pause');
    player.pause(() => {
        console.log('-> realy paused');
        setTimeout(() => {
            console.log('-> resume');
            player.resume();
        }, 500);
    });
}, wait);

setTimeout(() => {
    console.log('=> Volume 50%');
    player.volume(0.5);
}, 3 * wait);

setTimeout(() => {
    console.log('=> Next');
    player.next();
}, 4 * wait);

setTimeout(() => {
    console.log('=> Next');
    player.next();
}, 6 * wait);