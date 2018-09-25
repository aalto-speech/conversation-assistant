#!/bin/bash

export GST_PLUGIN_PATH=/l/asr/gst-kaldi-nnet2-online/src
python kaldigstserver/worker.py -u ws://localhost:80/worker/ws/speech -c malli_peter.yaml
