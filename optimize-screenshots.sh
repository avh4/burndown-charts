#!/bin/bash

set -euo pipefail

# make animated gifs
colors=64
for i in *-1.png; do
    name="${i%-1.png}"
    lastframe=$(ls "$name"-*.png | sed -e "s/^${name}-//;s/\\.png$//" | sort -n | tail -n1)
    size=$(identify -format '%wx%h' "$name"-"$lastframe".png)

    # make a palette that is forced to include #f8f8f8 (for the gridlines)
    convert "$name"-"$lastframe".png -colors $(($colors - 1)) -unique-colors _palette.png
    convert _palette.png -background '#f8f8f8' -extent "$colors"x1 _p2.png
    mv _p2.png _palette.png

    # create the gif
    convert -delay 80 -loop 0 +dither -remap _palette.png -extent "$size" "$name"-?.png "$name"-??.png _.gif

    # optimize the gif
    gifsicle --optimize=3 _.gif -o "$name".gif

    # remove temp files
    rm "$name"-*.png _palette.png _.gif
done

# optimize pngs
for i in *.png; do
    pngcrush -brute -reduce -ow "$i"
done

ls -lh *.png *.gif
