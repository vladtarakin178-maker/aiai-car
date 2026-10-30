// ============================================================
//  aiai-car — кузов «спорткар» для шасси aiai_chassis.scad
//  OpenSCAD 2021.01+
//  Оси те же, что в шасси: X — вперёд, Y — влево, Z — вверх, низ платы z = 0.
//  Кузов — тонкая оболочка (стенка 2 мм), надевается на плиту сверху и стоит на ней
//  своим нижним краем (z = 3,5), обхватывая бортик плиты снаружи.
//
//  Деталь выбирается параметром part:
//    "front"   — передняя половина кузова (печатать)
//    "rear"    — задняя половина кузова (печатать)
//    "whole"   — кузов целиком (влезает на стол 220×220 впритык, лучше печатать половинами)
//    "spoiler" — спойлер (печатать вверх ногами, как в STL)
//    "assembly"— кузов на шасси, для картинки
// ============================================================
use <aiai_chassis.scad>

part = "assembly";
body_alpha = 1.0;        // прозрачность кузова на картинке (1 — сплошной)
body_color = "crimson";  // цвет кузова на картинке

/* ---------- ДОЛЖНО СОВПАДАТЬ С aiai_chassis.scad ---------- */
plate_L = 210;   // длина плиты, мм
plate_W = 170;   // ширина плиты, мм
plate_t = 3.5;   // толщина плиты, мм
axle_x  = 60;    // оси колёс по X = ±axle_x, мм
axis_z  = 18.5;  // высота оси колёс над низом плиты, мм
wheel_d = 65;    // диаметр колёс, мм
mast_x  = 77;    // X мачты камеры, мм
sens_x  = 98;    // X держателя датчика, мм
corner_hole = [97, 77]; // угловые отверстия M3 в плите (±X, ±Y), мм

/* ---------- КУЗОВ ---------- */
wall     = 2;      // толщина стенки, мм
fit_gap  = 0.4;    // зазор между кузовом и бортиком плиты, мм
zb       = plate_t;// нижний край кузова (стоит на плите), мм
split_x  = 17;     // где делится кузов на две половины (X), мм
lip_len  = 5;      // длина «нахлёста» между половинами, мм

/* ---------- ПОДКРЫЛКИ / АРКИ ---------- */
pod_r      = 38.5;  // внешний радиус крыла вокруг колеса, мм
arch_r     = 35;   // радиус выреза арки (колесо 32,5 + зазор), мм
pod_y_out  = 100;  // насколько крыло выступает по Y наружу (ширина кузова 2×100), мм
pod_y_in   = 62;   // где крыло начинает подниматься из боковины, мм

/* ---------- ОТВЕРСТИЯ ---------- */
eye_d      = 18.4; // отверстия под «глазки» HC-SR04, мм
eye_dx     = 13;   // расстояние от оси до центра глазка, мм
eye_z      = 25.5; // высота центра глазков над низом плиты, мм
cam_win    = [14.4, 33]; // окно камеры: X × Y, мм
cam_win_x  = 71.8; // начало окна камеры по X, мм
screw_hole = 2.6;  // отверстие самореза M3 в столбике, мм
col_d      = 9;    // диаметр крепёжных столбиков, мм

/* ---------- СПОЙЛЕР ---------- */
sp_x     = -94;   // X центра спойлера, мм
sp_chord = 22;    // ширина крыла (хорда), мм
sp_span  = 130;   // размах, мм
sp_t     = 2.6;   // толщина крыла, мм
sp_z     = 53;    // высота крыла над низом плиты, мм
sp_pyl_y = 35;    // стойки спойлера по Y (±), мм

$fn = 40;

// ---------------- ключевые сечения: [X, полуширина, высота верха] ----------------
base = [
 [-107.4, 56, 27], [-105.5, 72, 29.5], [-103, 82, 31], [-99, 87.4, 33],
 [-80, 87.4, 36], [-60, 87.4, 39], [-40, 87.4, 42], [-20, 87.4, 44.5], [0, 87.4, 46],
 [30, 87.4, 47], [60, 87.4, 46.5], [76, 87.4, 45], [90, 87.4, 44], [100, 87.4, 43],
 [104, 85, 42.5], [107, 78, 41.5], [109, 66, 39.5], [110, 50, 36.5]
];
cabin = [
 [-74, 28, 40], [-60, 44, 47], [-42, 55, 53.5], [-18, 61, 58], [22, 61, 58],
 [46, 58, 56.5], [60, 52, 52], [67, 42, 47.5]
];

// ---------------- построение оболочки ----------------
module sec2d(hw, h, r) {
    hull() {
        translate([-hw, -10]) square([2 * hw, 1]);
        for (s = [-1, 1]) translate([s * (hw - r), h - r]) circle(r = r, $fn = 28);
    }
}
module slice(k, g, rsh) {
    r0 = min(rsh, k[2] - zb - 3, k[1] - 1);
    r  = max(1, r0 + g);
    translate([k[0], 0, 0]) rotate([90, 0, 90]) linear_extrude(0.02) sec2d(k[1] + g, k[2] + g, r);
}
module loft(keys, g, rsh) {
    for (i = [0 : len(keys) - 2]) hull() { slice(keys[i], g, rsh); slice(keys[i + 1], g, rsh); }
}
module yrod(y0, y1, r) {   // цилиндр вокруг оси колеса вдоль Y
    translate([0, y0, axis_z]) rotate([-90, 0, 0]) cylinder(r = r, h = y1 - y0, $fn = 56);
}
module pod(ax, s, g) {     // крыло над колесом
    translate([ax, 0, 0]) mirror([0, s > 0 ? 0 : 1, 0])
        hull() {
            yrod(pod_y_in, pod_y_in + 0.02, 30 + g);
            yrod(84, 84.02, pod_r + g);
            yrod(84, pod_y_out + g, pod_r + g);
        }
}
module outer(g) {
    loft(base, g, 22);
    loft(cabin, g, 24);
    for (ax = [axle_x, -axle_x], s = [1, -1]) pod(ax, s, g);
}
module clipz() { translate([-300, -300, zb]) cube([600, 600, 300]); }
module S_o(g = 0) { intersection() { outer(g); clipz(); } }

// ---------------- отверстия ----------------
module cuts() {
    // глазки HC-SR04 в бампере
    for (sy = [-1, 1]) translate([92, sy * eye_dx, eye_z]) rotate([0, 90, 0]) cylinder(d = eye_d, h = 30, $fn = 48);
    // решётка под бампером
    for (z = [8.5, 13]) translate([100, -30, z]) cube([20, 60, 2.6]);
    // окно камеры в капоте (мачта с камерой выходит наружу)
    translate([cam_win_x, -cam_win[1] / 2, 36]) linear_extrude(40) offset(r = 3) offset(delta = -3) square([cam_win[0], cam_win[1]]);
    // вентиляция Raspberry Pi: щели в крыше
    for (x = [-11, -4, 3, 10], c = [-16, 16])
        translate([x - 1.6, c - 12, 48]) cube([3.2, 24, 20]);
    // боковые воздухозаборники
    for (s = [-1, 1], z = [13, 18, 23, 28])
        translate([-12, s > 0 ? 76 : -96, z]) cube([22, 20, 3]);
    // арки колёс
    for (ax = [axle_x, -axle_x], s = [-1, 1])
        translate([ax, s * 95.5, axis_z]) rotate([90, 0, 0]) cylinder(r = arch_r, h = 13, center = true, $fn = 64);
    // корма: разъём DC и USB Arduino, зарядка, выключатель
    translate([-120, -19.6 - 6, 10.5]) cube([30, 12, 12.5]);          // питание Arduino (DC)
    translate([-120, 12 - 7, 10.5])    cube([30, 14, 12.5]);          // USB Arduino
    translate([-120, -42 - 8, 10]) cube([30, 16, 10]);                // зарядка аккумуляторов
    translate([-120, 38, 18]) rotate([0, 90, 0]) cylinder(d = 12.2, h = 30, $fn = 32); // выключатель
    // пазы под стойки спойлера
    for (sy = [-1, 1]) translate([sp_x - 5.7, sy * sp_pyl_y - 1.7, 20]) cube([11.4, 3.4, 30]);
}

// ---------------- крепёжные столбики ----------------
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
    difference() {
        union() {
            difference() { S_o(); outer(-wall); cuts(); }
            columns();
        }
        screw_holes();
    }
}

// ---------------- половинки с нахлёстом ----------------
skin = 1.0;            // наружный слой у стыка, мм
module slab(x0, x1) { translate([x0, -300, -50]) cube([x1 - x0, 600, 400]); }

module rear_half() {
    union() {
        intersection() { body_full(); slab(-300, split_x); }
        // язычок: внутренний слой стенки заходит под наружный слой передней половины
        difference() {
            intersection() { S_o(-skin - 0.2); slab(split_x - 0.01, split_x + lip_len); }
            outer(-wall); cuts();
        }
    }
}
module front_half() {
    difference() {
        intersection() { body_full(); slab(split_x, 300); }
        intersection() { S_o(-skin); slab(split_x - 0.01, split_x + lip_len + 0.3); }
    }
}

// ---------------- спойлер ----------------
module spoiler() {
    zt = sp_z + sp_t;
    // крыло с закруглёнными кромками
    hull() for (dx = [-1, 1])
        translate([sp_x + dx * (sp_chord / 2 - 1.3), -sp_span / 2, sp_z + 1.3]) rotate([-90, 0, 0])
            cylinder(r = 1.3, h = sp_span, $fn = 16);
    // боковые шайбы (уходят вниз от крыла)
    for (sy = [-1, 1])
        translate([sp_x - sp_chord / 2 - 1, sy * sp_span / 2 - (sy > 0 ? 2.4 : 0), 42]) cube([sp_chord + 4, 2.4, zt - 42]);
    // стойки со шипами
    for (sy = [-1, 1]) {
        translate([sp_x - 6, sy * sp_pyl_y - 1.8, 34.8]) cube([12, 3.6, sp_z - 34.8 + 0.5]);
        translate([sp_x - 5.5, sy * sp_pyl_y - 1.5, 28]) cube([11, 3, 7]);
    }
}
module spoiler_print() { translate([0, 0, 0]) rotate([180, 0, 0]) translate([0, 0, -(sp_z + sp_t)]) spoiler(); }

// ---------------- картинка ----------------
module car_preview() {
    assembly();   // шасси из aiai_chassis.scad
    // для картинки берём готовый STL (так нет «мерцания» граней в предпросмотре)
    color(body_color, body_alpha) translate([0, 0, zb]) import("stl/body_whole.stl");
    color(body_color, body_alpha) spoiler();
}

if (part == "front") translate([0, 0, -zb]) front_half();
else if (part == "rear") translate([0, 0, -zb]) rear_half();
else if (part == "whole") translate([0, 0, -zb]) body_full();
else if (part == "spoiler") spoiler_print();
else car_preview();
