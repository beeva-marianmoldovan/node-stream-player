Speaker = require('speaker')
lame = require('lame')
request = require('request')
events = require('events')
fs = require('fs')
mpg123Util = require('node-mpg123-util')

# http://stackoverflow.com/a/646643
String::startsWith ?= (s) -> @slice(0, s.length) == s
String::endsWith   ?= (s) -> s == '' or @slice(-s.length) == s

audioOptions = {
  channels: 2,
  bitDepth: 16,
  sampleRate: 44100,
  mode: lame.STEREO
}

self = null

class StreamPlayer extends events.EventEmitter

  constructor: () ->
    events.EventEmitter.call(this)
    self = this
    @queue = []
    @trackInfo = []
    @currentSong = null
    @playing = false
    @startTime = 0
    @speaker = null
    @speakerState = null
    @decoder = null
    @getVolume = 1

  # Play the next song in the queue if it exists
  play: () ->
    if @currentSong != null
      @resume()
    else if @queue.length > 0 && !@playing
      @getStream(@queue[0], @playStream)
      @playing = true
      @emit('paused', false)
      @queue.shift()
      @currentSong = self.trackInfo.shift()
    else if @playing
      @emit('error', 'already_playing')
    else
      @emit('error', 'empty_queue')

  # Pause the current playing audio stream
  pause: (callback) ->
    if !@playing
      if callback
        return callback()
      return
    @speaker.removeAllListeners 'close'
    @speaker.end()
    @speaker.once 'close', () =>
      @playing = false
      @emit('paused', true)
      if callback
        return callback()

  # Pipe the decoded audio stream back to a speaker
  resume: () ->
    if @playing
      return
    @speaker = new Speaker(audioOptions)
    @decoder.pipe(@speaker)
    @playing = true
    @emit('paused', false)
    @speaker.once 'close', () ->
      loadNextSong()

  # Next song
  next: () ->
    if @queue.length == 0
      @emit('error', 'empty_queue')
      return 
    @pause(=>
      @currentSong = null
      @play()
    )

  # Remove a song with the given id metadata attribute
  remove: (id) ->
    index = @trackInfo.map( (info) -> return info.id ).indexOf(parseInt(id, 10))
    @trackInfo.splice(index, 1)
    @queue.splice(index, 1)


  # Add a song and metadata to the queue
  add: (url, track) ->
    @queue.push(url)
    @trackInfo.push(track)
    @emit('add', url, track)

  # Set volume
  volume: (v) ->
    if v > 1
      v = 1
    else if v < 0
      v = 0
    if self.decoder && self.decoder.mh 
      mpg123Util.setVolume(self.decoder.mh, v)
    @getVolume = v

  # Returns the metadata for the song that is currently playing
  nowPlaying: () ->
    if @playing
      return {track: @currentSong, timestamp: @startTime}
    else
      return false

  # Returns if there is a song currently playing
  isPlaying: () ->
    return @playing

  # Returns the metadata for the songs that are in the queue
  getQueue: () ->
    return @trackInfo

  # Get the audio stream
  getStream: (url, callback) ->
    if url.startsWith('http')
      request.get(url).on 'response', (res) ->
        if res.headers['content-type'] == 'audio/mpeg'
          callback(res)
        else
          self.emit('invalid url', url)
          loadNextSong()
    else
      stream = fs.createReadStream(url)
      callback(stream)


  # Decode the stream and pipe it to our speakers
  playStream: (stream) ->
    self.decoder = new lame.Decoder()
    self.speaker = new Speaker(audioOptions)
    stream.pipe(self.decoder).once 'format', () ->
      mpg123Util.setVolume(self.decoder.mh, self.getVolume)
      self.decoder.pipe(self.speaker)
      self.startTime = Date.now();
      self.emit('playing', self.currentSong)
      self.speaker.once 'close', () ->
        loadNextSong()


# Load the next song in the queue if there is one
loadNextSong = () ->
  self.emit('ended', self.currentSong)
  self.next()


module.exports = StreamPlayer
