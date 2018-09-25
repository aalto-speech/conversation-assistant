#!/bin/bash

export GST_PLUGIN_PATH=/l/asr/gst-kaldi-nnet2-online/src

sudo python kaldigstserver/master_server.py --port=80
