
window.getScreenShareForLocalParticipant = function(localParticipant) {
  // TODO: Handle the situation where getDisplayMedia is not available.
  // displayMediaStream = await html.window.navigator.getUserMedia(video: {'mediaSource': 'screen'}, audio: false);

  return navigator.mediaDevices.getDisplayMedia({
    audio: false,
    video: {
      frameRate: 10,
    },
  }).then(stream => {
      var screenTrack = new Twilio.Video.LocalVideoTrack(stream.getTracks()[0], {name: 'screen-share'},);
      return screenTrack;
  });
};

window.playVideoJs = function(videoId, url, urlType, autoplay, showControls, posterUrl, onEnded, onError, onReady) {
    var video = videojs(videoId, {
      fill: true,
      autoplay: autoplay,
      controlBar: {
        fullscreenToggle: false,
        pictureInPictureToggle: false,
        progressControl: {
          seekBar: showControls
        },
      }
    });
    if (posterUrl) {
      video.poster(posterUrl);
    }
    video.src({
      type: urlType,
      src: url
    });
    video.ready(function(){
      var player = this;

      console.log('dispatching ready event to parent');
      onReady();

      player.on('ended', function() {
        console.log('dispatching ended event to parent');
        onEnded();
      });

      player.on('error', function() {
        console.log('dispatching error event to parent');
        onError();
      });
    });
};

window.useFirebaseEmulators = function() {
  console.log('using firebase emulators');
  firebase.auth().useEmulator("http://localhost:9099");
  firebase.firestore().useEmulator("localhost", 8080);
}

window.checkCanAutoplay = function() {
  if (typeof canAutoplay === 'undefined') return Promise.resolve(false);

  return Promise.all([
    canAutoplay.video(),
    canAutoplay.audio()
  ]).then((results) => {
    for(let result of results) {
      console.log(`result: ${JSON.stringify(result)}`);
    }
    return results.every((r) => r.result === true);
  });
}

window.pickMedia = function(parameters, onResult) {
    // Parameters list
    // https://cloudinary.com/documentation/upload_widget_reference#parameters
    return cloudinary.openUploadWidget(
        parameters,
        (error, result) => {
            // Always `stream` the result to Dart
            onResult(JSON.stringify(error), JSON.stringify(result))
        });
}

window.playVimeoVideo = function(div, vimeoId, onEnded) {
    var player = new Vimeo.Player(div, {
      id: vimeoId,
      responsive: true,
      controls: true,
    });

    try {
      player.play();
    } catch (e) {
      console.log(e);
    }

    player.on('ended', function() {
      console.log('video ended');
      onEnded();
    });
}