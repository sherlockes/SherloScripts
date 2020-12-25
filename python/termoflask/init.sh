#!/bin/bash
cd SherloScripts/python/termoflask
export FLASK_APP=run.py
export FLASK_ENV=development
python3 -m flask run --host 0.0.0.0 --port 5000
