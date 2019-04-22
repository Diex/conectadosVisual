#!/bin/bash
echo "estimotes server"
cd /Users/sulky/Documents/estimotes/conectadosVisual/
pushd processing/visualization_01/application.macosx/
open ./visualization_01.app
popd
python ./server.py 

