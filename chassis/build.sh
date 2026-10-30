#!/bin/sh
# Сборка STL и превью. Нужен openscad (xvfb-run — только если нет экрана).
cd "$(dirname "$0")"
mkdir -p stl
for p in plate clamp mast sensor sensor_servo; do
  xvfb-run -a openscad -D "part=\"$p\"" -o stl/$p.stl aiai_chassis.scad || exit 1
done
xvfb-run -a openscad -D 'part="assembly"' --imgsize=1600,1100 --camera=0,0,20,60,0,55,520 \
  --autocenter --viewall --colorscheme=Tomorrow -o preview.png aiai_chassis.scad
