// ============================================================
//  aiai-car — кузов «суперкар» (клин, как Lamborghini / McLaren) для шасси aiai_chassis.scad
//  OpenSCAD 2021.01+
//  Оси те же, что в шасси: X — вперёд, Y — влево, Z — вверх, низ платы z = 0.
//  Кузов — тонкая оболочка (стенка 2 мм), надевается на плиту сверху. Ширина ~236 мм
//  (широкие крылья закрывают колёса), длина ~242 мм, поэтому он печатается 4 частями
//  (по четвертям) + крыло. Части склеиваются: у стыков есть «язычки» (нахлёст).
//
//  Деталь выбирается параметром part:
//    "fl"  — передняя левая четверть     "fr"  — передняя правая
//    "rl"  — задняя левая четверть       "rr"  — задняя правая
//    "wing"— большое заднее крыло на высоких стойках (печатать вверх ногами, как в STL)
//    "whole" — весь кузов одним куском (только для просмотра, на стол не влезет)
//    "assembly" — кузов на шасси, для картинки
// ============================================================
use <aiai_chassis.scad>

part = "assembly";
body_alpha = 1.0;           // прозрачность кузова на картинке
body_color = "orangered";   // цвет кузова на картинке
show_glass = true;          // тёмное стекло кабины (только на картинке)

/* ---------- ДОЛЖНО СОВПАДАТЬ С aiai_chassis.scad ---------- */
plate_t = 3.5;   // толщина плиты, мм
axle_x  = 60;    // оси колёс по X = ±axle_x, мм
axis_z  = 18.5;  // высота оси колёс над низом плиты, мм
corner_hole = [97, 77]; // угловые отверстия M3 в плите (±X, ±Y), мм
corner_c    = [95, 75]; // центр скругления угла плиты (радиус 10), мм

/* ---------- КУЗОВ ---------- */
wall     = 2;      // толщина стенки, мм
zb       = plate_t;// нижний край кузова (стоит на плите), мм
split_x  = 17;     // где делится кузов на перед/зад (X), мм
lip_len  = 5;      // длина «язычка» на стыке, мм
skin     = 1.0;    // наружный слой у стыка, мм (язычок тоньше стенки: 2 − 1 − 0,2 = 0,8)

/* ---------- КРЫЛЬЯ И АРКИ ---------- */
arch_r     = 36;   // радиус выреза арки (колесо 32,5 + зазор), мм
arch_y0    = 86.2; // с какого Y вырез арки идёт наружу (колесо начинается с 87), мм

/* ---------- ОТВЕРСТИЯ ---------- */
eye_d      = 18.4; // отверстия под «глазки» HC-SR04, мм
eye_dy     = 13;   // расстояние от оси до центра глазка, мм
eye_z      = 25.5; // высота центра глазков, мм
cav_end    = 102;  // до какого X внутри кузова полость; дальше нос сплошной (слайсер заполнит его редко), мм

cam_win    = [14.4, 33]; // окно камеры: X × Y, мм
cam_win_x  = 71.8; // начало окна камеры по X, мм
screw_hole = 2.6;  // отверстие самореза M3 в столбике, мм
col_d      = 9;    // диаметр крепёжных столбиков, мм

/* ---------- КРЫЛО (СПОЙЛЕР) ---------- */
wg_x     = -100;  // X центра крыла, мм
wg_chord = 28;    // хорда, мм
wg_span  = 176;   // размах, мм
wg_t     = 3;     // толщина крыла, мм
wg_top   = 70;    // верх крыла над низом плиты, мм
st_x     = -96;   // X стоек (в пазах на крышке), мм
st_y     = 35;    // стойки по Y (±), мм

$fn = 32;

// ---------------- ключевые сечения: [X, полуширина, высота плеча, полуширина крыши, высота крыши] ----------------
tail = [for (x = [-107.4, -107, -106.4, -105.6, -104.6, -103.4, -102, -100, -98])
          let (t = (x + 107.4) / 10.4)
          [x, corner_c[1] + sqrt(12.4 * 12.4 - (x + corner_c[0]) * (x + corner_c[0])),
           22 + 8 * t, 52 + 14 * t, 32 + 6 * t]];
base = concat(tail, [
 [-97, 87.4, 30, 66, 38], [-70, 87.4, 33, 66, 42], [-40, 87.4, 35, 64, 46],
 [-10, 87.4, 36, 62, 48], [25, 87.4, 36, 62, 48], [62, 87.4, 35, 63, 46],
 [85, 87.4, 33, 63, 42.5], [104, 87.4, 31, 62, 40],
 // длинный острый нос-клин: плавно спускается почти до плиты
 [112, 80, 27, 52, 32], [122, 62, 20, 40, 22.5], [132, 45, 13, 26, 15], [141, 28, 8, 14, 9.5]
]);
// крылья-«плечи»: [X, Y внутри, Y снаружи, высота плеча, Y верха снаружи, высота гребня, Y верха внутри, высота у кузова]
fender = [
 [-104, 40, 82, 28, 78, 38, 62, 38], [-95, 40, 104, 30, 98, 50, 70, 46], [-82, 40, 116, 34, 108, 60, 80, 54],
 [-60, 40, 118, 36, 108, 63, 82, 56], [-40, 40, 116, 36, 106, 61, 80, 54], [-22, 40, 102, 34, 96, 52, 76, 48],
 [-6, 40, 92, 33, 88, 48, 72, 46], [10, 40, 93, 33, 89, 48, 72, 46], [28, 40, 108, 34, 100, 55, 78, 50],
 [45, 40, 117, 36, 108, 59, 82, 54], [60, 40, 118, 36, 108, 59, 82, 54], [76, 40, 117, 35, 107, 57, 80, 52],
 [92, 40, 110, 34, 102, 51, 78, 48], [101, 40, 99, 32, 93, 44, 74, 43], [110, 40, 86, 30, 82, 36, 68, 36]
];
cabin = [
 [-78, 40, 40, 26, 43], [-52, 50, 46, 34, 52], [-24, 56, 50, 36, 58], [14, 56, 50, 36, 58],
 [40, 54, 48, 33, 56], [58, 48, 45, 28, 51], [72, 38, 42, 18, 44.5]
];

// ---------------- построение оболочки ----------------
function interp(keys, x) =
    let (i = max([for (j = [0 : len(keys) - 2]) if (keys[j][0] <= x) j]))
    let (a = keys[i], b = keys[i + 1], t = (x - a[0]) / (b[0] - a[0]))
    concat([x], [for (m = [1 : len(a) - 1]) a[m] + (b[m] - a[m]) * t]);
// для внутренней полости концы сдвигаем на толщину стенки — получаются торцевые стенки
function innerkeys(k) =
    let (x0 = k[0][0], x1 = k[len(k) - 1][0])
    concat([interp(k, x0 + wall)],
           [for (q = k) if (q[0] > x0 + wall + 0.01 && q[0] < x1 - wall - 0.01) q],
           [interp(k, x1 - wall)]);

module sec2d(k, g) {
    offset(delta = g) offset(r = 2.5) offset(delta = -2.5)
        polygon([[-k[1], -10], [k[1], -10], [k[1], k[2]], [k[3], k[4]], [-k[3], k[4]], [-k[1], k[2]]]);
}
module slice(k, g) { translate([k[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.02) sec2d(k, g); }
module loft(keys, g) {
    ks = g < 0 ? innerkeys(keys) : keys;
    for (i = [0 : len(ks) - 2]) hull() { slice(ks[i], g); slice(ks[i + 1], g); }
}
module fsec(k, g) {
    offset(delta = g) offset(r = 2.5) offset(delta = -2.5)
        polygon([[k[1], -10], [k[2], -10], [k[2], k[3]], [k[4], k[5]], [k[6], k[5]], [k[1], k[7]]]);
}
module fslice(k, g) { translate([k[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.02) fsec(k, g); }
module floft(g) {
    ks = g < 0 ? innerkeys(fender) : fender;
    for (s = [0, 1]) mirror([0, s, 0])
        for (i = [0 : len(ks) - 2]) hull() { fslice(ks[i], g); fslice(ks[i + 1], g); }
}
module outer(g) {
    loft(base, g);
    loft(cabin, g);
    floft(g);
}
module clipz() { translate([-300, -300, zb]) cube([600, 600, 300]); }
module S_o(g = 0) { intersection() { outer(g); clipz(); } }

// ---------------- вырезы ----------------
module cuts() {
    // глазки HC-SR04: каналы в носу (открыты сверху, чтобы луч шёл вперёд свободно)
    for (sy = [-1, 1]) translate([90, sy * eye_dy, 0]) hull() {
        translate([0, 0, eye_z]) rotate([0, 90, 0]) cylinder(d = eye_d, h = 70, $fn = 48);
        translate([0, 0, 70]) rotate([0, 90, 0]) cylinder(d = eye_d, h = 70, $fn = 48);
    }
    // окно камеры в капоте: мачта с камерой выходит наружу
    translate([cam_win_x, -cam_win[1] / 2, 30]) linear_extrude(50) offset(r = 3) offset(delta = -3) square([cam_win[0], cam_win[1]]);
    // вентиляция Raspberry Pi: щели в крыше кабины
    for (x = [-11, -4, 3, 10], c = [-16, 16])
        translate([x - 1.6, c - 12, 50]) cube([3.2, 24, 20]);
    // острые боковые воздухозаборники (по 3 щели в скошенном треугольном окне)
    for (s = [-1, 1]) for (b = [[12, 17], [19, 24], [26, 31]])
        intersection() {
            translate([0, s > 0 ? 82 : -96, 0]) rotate([90, 0, 0]) mirror([0, 0, 1])
                linear_extrude(14) polygon([[-30, 12], [-30, 33], [24, 21], [24, 12]]);
            translate([-40, -100, b[0]]) cube([80, 200, b[1] - b[0]]);
        }
    // арки колёс: колесо видно сбоку, крыло прикрывает его сверху
    for (ax = [axle_x, -axle_x], s = [-1, 1])
        translate([ax, s > 0 ? arch_y0 : -arch_y0 - 50, axis_z]) rotate([-90, 0, 0]) cylinder(r = arch_r, h = 50, $fn = 72);
    // корма: USB и разъём питания Arduino, зарядка, выключатель
    translate([-125, -19.6 - 6, 10.5]) cube([40, 12, 12.5]);          // питание Arduino (DC)
    translate([-125, 12 - 7, 10.5])    cube([40, 14, 12.5]);          // USB Arduino
    translate([-125, -42 - 8, 10.5]) cube([40, 16, 10]);              // зарядка аккумуляторов
    translate([-125, 38, 18]) rotate([0, 90, 0]) cylinder(d = 12.2, h = 40, $fn = 32); // выключатель
    // «диффузор»: вертикальные щели по краям кормы
    for (s = [-1, 1], y = [57, 63, 69]) translate([-125, s * y - 1.5, 9]) cube([30, 3, 15]);
    // пазы под стойки крыла
    for (sy = [-1, 1]) translate([st_x - 6.2, sy * st_y - 1.9, 20]) cube([12.4, 3.8, 40]);
}

// ---------------- оболочка ----------------
module cavity() { intersection() { S_o(-wall); translate([-300, -300, -50]) cube([300 + cav_end, 600, 400]); } }
module skin_shell(go = 0) {
    difference() { S_o(go); cavity(); cuts(); }
}
module columns() {
    intersection() {
        S_o();
        union() for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * corner_hole[0], sy * corner_hole[1], zb]) cylinder(d = col_d, h = 60, $fn = 32);
    }
}
module screw_holes() {
    for (sx = [-1, 1], sy = [-1, 1])
        translate([sx * corner_hole[0], sy * corner_hole[1], zb - 1]) cylinder(d = screw_hole, h = 22, $fn = 24);
}
module body_full() {
    difference() { union() { skin_shell(0); columns(); } screw_holes(); }
}

// ---------------- четверти с «язычками» ----------------
module box(x0, x1, y0, y1) { translate([x0, y0, -50]) cube([x1 - x0, y1 - y0, 400]); }
function xr(sx) = sx > 0 ? [split_x, 300] : [-300, split_x];
function yr(sy) = sy > 0 ? [0, 300] : [-300, 0];

module quarter(sx, sy) {
    X = xr(sx); Y = yr(sy);
    difference() {
        union() {
            intersection() { body_full(); box(X[0], X[1], Y[0], Y[1]); }
            // задние четверти вставляют язычок в передние (по X)
            if (sx < 0) intersection() {
                difference() { S_o(-skin - 0.2); cavity(); cuts(); }
                box(split_x - 0.01, split_x + lip_len, Y[0], Y[1]);
            }
            // левые четверти вставляют язычок в правые (по Y)
            if (sy > 0) intersection() {
                difference() { S_o(-skin - 0.2); cavity(); cuts(); }
                box(sx > 0 ? split_x + lip_len + 0.3 : -300, sx > 0 ? 300 : split_x, -lip_len, 0.01);
            }
        }
        // передние четверти: выбираем внутреннюю часть стенки под язычок
        if (sx > 0) intersection() { S_o(-skin); box(split_x - 0.01, split_x + lip_len + 0.3, -300, 300); }
        if (sy < 0) intersection() { S_o(-skin); box(-300, 300, -lip_len - 0.3, 0.01); }
    }
}

// ---------------- большое заднее крыло на высоких стойках ----------------
module wing() {
    zt = wg_top;
    // профиль крыла со скруглёнными кромками
    hull() for (dx = [-1, 1])
        translate([wg_x + dx * (wg_chord / 2 - 1.5), -wg_span / 2 + 1, zt - 1.5]) rotate([-90, 0, 0])
            cylinder(r = 1.5, h = wg_span - 2, $fn = 16);
    // боковые шайбы — наклонные, уходят вниз от крыла
    for (sy = [-1, 1])
        translate([0, sy * wg_span / 2 + (sy > 0 ? -2.4 : 0), 0]) rotate([90, 0, 0]) mirror([0, 0, 1])
            linear_extrude(2.4) polygon([[wg_x + wg_chord / 2 + 2, zt], [wg_x + wg_chord / 2 + 2, zt - 12],
                                         [wg_x - wg_chord / 2 - 5, zt - 26], [wg_x - wg_chord / 2 - 5, zt]]);
    // высокие стойки со шипами
    for (sy = [-1, 1]) {
        translate([st_x - 6, sy * st_y - 1.8, 38 - 0.01]) cube([12, 3.6, zt - 38]);          // сама стойка
        translate([st_x - 6, sy * st_y - 1.5, 30]) cube([12, 3, 8.02]);                        // шип в паз
    }
}
module wing_print() { rotate([180, 0, 0]) translate([0, 0, -wg_top]) wing(); }

// ---------------- картинка ----------------
module glass() {   // тёмное стекло: только для картинки
    color("#10141c", 0.95) {
        intersection() { loft(cabin, 0.35); translate([37, -80, 40]) cube([40, 160, 40]); }            // лобовое
        for (s = [-1, 1]) intersection() {                                                               // боковые окна
            loft(cabin, 0.35);
            translate([-6, s > 0 ? 36 : -80, 49.2]) cube([54, 44, 30]);
        }
    }
}
module car_preview() {
    assembly();   // шасси из aiai_chassis.scad
    for (n = ["fl", "fr", "rl", "rr"])
        color(body_color, body_alpha) translate([0, 0, zb]) import(str("stl/body_", n, ".stl"));
    color("#222222") wing();
    if (show_glass) glass();
}

if (part == "fl") translate([0, 0, -zb]) quarter(1, 1);
else if (part == "fr") translate([0, 0, -zb]) quarter(1, -1);
else if (part == "rl") translate([0, 0, -zb]) quarter(-1, 1);
else if (part == "rr") translate([0, 0, -zb]) quarter(-1, -1);
else if (part == "whole") body_full();
else if (part == "wing") wing_print();
else car_preview();
