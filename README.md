# node-stream-player
[![npm version](https://badge.fury.io/js/stream-player.svg)](http://badge.fury.io/js/stream-player)

For all of your mp3 streaming needs. Queue mp3 streams and play them through your computers speakers.

## Installation
```
$ npm install stream-player
```

## Migration 0.3.0 > 0.3.1
### Events  
'play start' to 'playing'  
'play end' to 'ended'  
'song added' to 'add'  

## Example
```javascript
var StreamPlayer = require('stream-player');
var player = new StreamPlayer();

// Add a song url to the queue
player.add('http://path-to-mp3.com/example.mp3');

// Add a song url to the queue along with some metadata about the song
// Metadata can be any object that you want in any format you want
var metadata = {
  "id": 1
  "title": "Some song",
  "artist": "Some artist",
  "duration": 234000,
  "humanTime": "3:54"
};
player.add('http://path-to-mp3.com/example.mp3', metadata);

// Remove a song, don't forget to add song with metaData id for this.
player.remove(metadata.id);

// Start playing all songs added to the queue (FIFO)
player.play();

// Pause the song
player.pause();

// Next song on the queue
player.next();

// Set the player volume (0 to 1)
player.volume(0.5)

// Get the metadata for the current playing song and a time stamp when it started playing
player.nowPlaying();

// Get an array of metadata for the songs in the queue (excludes the current playing song)
player.getQueue();

// Get if the player is currently playing
player.isPlaying()


// EMIT EVENTS

player.on('playing', function(song) {
  // Code here is executed every time a song starts playing
});

player.on('paused', function (state) {
  // Code here is executed at every state change
});

player.on('ended', function(song) {
  // Code here is executed every time a song ends
});

player.on('add', function(url) {
  // Code here is executed every time a song is added to the queue
});

player.on('error', function(err) {
  // Code here is executed at every error
  // err = empty_queue | already_playing
});

```
Look in the examples folder for a complete case.

## Methods
### `add(url, metadata)`
Adds the mp3 stream located at `url` to the queue. The optional metadata parameter can be any JS object that holds information about the song. If no metadata is given then it will be `undefined` when referenced.  
Don't forget to add id key on metadata if you want to remove it later
### `remove(id)`
Remove a song from the queue with this id (passed in the metadata)
### `play()`
Starts playing the next song in the queue out of the speakers.
### `pause(callback)`
Pause the current playing sound. Call `play()` or `resume()` to resume.  
The callback is fired when the song is realy paused. Speaker can take 500-1000ms to realy stop. Or wait for event 'paused'.
### `resume()`
Resume the current sound.
### `next()`
Next queue song
### `volume()`
Set the player volume (0 to 1)
### `getQueue()`
Returns an array of song metadata in the queue.
### `isPlaying()`
Returns true if a song is currently playing and false otherwise.
### `nowPlaying()`
Returns an object containing the current playing song's metadata and the Unix time stamp of when the song started playing.
###### Example
```javascript
{
  track: {
    title: "Some song",
    artist: "Some artist"
  },
  timestamp: 1438489161
}
```



### Roadmap
- Support for more audio file types
