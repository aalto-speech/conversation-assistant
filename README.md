# Conversation Assistant

Conversation Assistant iOS app and ASR server

### AR Conversation Assistant iOS app

The *ConvAssistantAR* folder provides the full Xcode project and source code for the application. The Apple [ARKit](https://developer.apple.com/arkit/) is used for the "AR" functionality.


### Speech recognition server

We are using the [Kaldi GStreamer server](https://github.com/alumae/kaldi-gstreamer-server) with the [kaldinnet2onlinedecoder](https://github.com/alumae/gst-kaldi-nnet2-online) plugin. It is included here with our minor modifications and scripts. The app and server communicate using the WebSocket protocol.

Added:
- Block all worker connections not coming from our own server
- Modified post-processing so we can get all partial results from the server 
- Scripts for starting the master server and workers with a SSL certificate