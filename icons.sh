#!/bin/bash

RES=app/src/main/res/mipmap

declare -A icon

icon[48]='mdpi'
icon[72]='hdpi'
icon[96]='xhdpi'
icon[144]='xxhdpi'
icon[192]='xxxhdpi'

for foo in "${!icon[@]}"
do
  magick test-tube-circle.png -resize ${foo}x${foo} ${RES}-${icon[$foo]}/ic_launcher.png
  magick test-tube-circle.png -resize ${foo}x${foo} ${RES}-${icon[$foo]}/ic_launcher_round.png
done
