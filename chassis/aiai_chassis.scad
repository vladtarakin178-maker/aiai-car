// ============================================================
//  aiai-car — параметрическое шасси 4WD для печати из PLA-CF / PETG-CF
//  OpenSCAD 2021.01+
//  Оси: X — вперёд (нос машинки), Y — влево, Z — вверх.
//  Центр платы в точке (0,0), низ платы на z = 0 (стол принтера).
//
//  Какую деталь выгрузить в STL — задаётся параметром part:
//    openscad -D 'part="plate"' -o plate.stl aiai_chassis.scad
//  Детали: plate, clamp, mast, sensor, sensor_servo, assembly (только для просмотра)
// ============================================================

/* ---------- ЧТО РИСОВАТЬ ---------- */
part = "assembly";        // "plate" основа | "clamp" скоба мотора (печатать 8 шт.) | "mast" мачта камеры
                          // | "sensor" держатель HC-SR04 | "sensor_servo" голова датчика на сервоприводе
                          // | "assembly" вся машинка для просмотра
use_servo = false;        // true — спереди вместо фиксированного датчика ставится сервопривод SG90
show_electronics = true;  // в режиме assembly показывать «призраки» плат, моторов и колёс

/* ---------- ОСНОВНАЯ ПЛАТА ---------- */
plate_L   = 210;   // длина платы по X, мм (стол 220 — остаётся по 5 мм запаса)
plate_W   = 170;   // ширина платы по Y, мм
plate_t   = 3.5;   // толщина плиты, мм (3–4 мм)
corner_r  = 10;    // радиус скругления углов, мм
rim_w     = 2.4;   // толщина бортика по периметру, мм (3 прохода сопла 0.8 не нужно, хватит 6 по 0.4)
rim_h     = 6;     // высота бортика над плитой, мм
rib_w     = 2.4;   // толщина рёбер жёсткости, мм
rib_h     = 5;     // высота рёбер жёсткости над плитой, мм
rib_y     = 29.5;  // положение продольных рёбер по Y (±), мм

/* ---------- МОТОРЫ 25GA (редукторные, диаметр 25 мм) ---------- */
motor_d      = 25;   // диаметр мотора, мм
motor_len    = 50;   // длина корпуса от торца редуктора до задней крышки (без вала), мм — ПРОВЕРЬ СВОЙ!
motor_tol    = 0.3;  // зазор на посадку, мм
motor_floor  = 2.5;  // толщина «пола» под мотором, мм
motor_wall   = 7;    // боковая стенка седла (в ней винт M3), мм
stop_t       = 4;    // толщина упорной стенки у редуктора, мм
boss_d       = 14;   // диаметр выреза под бобышку/вал в упорной стенке, мм
axle_x       = 60;   // колёсная база: оси передних/задних колёс на X = ±axle_x, мм
clamp_w      = 14;   // ширина одной скобы по Y, мм
clamp_off    = [3, 33]; // где стоят две скобы: расстояние от торца редуктора, мм
clamp_wall   = 3.5;  // толщина стенки скобы над мотором, мм
wheel_d      = 65;   // диаметр колёс, мм (нужен только для расчёта клиренса и просмотра)
wheel_w      = 27;   // ширина колеса, мм (только для просмотра)
shaft_len    = 12;   // длина вала, торчащего наружу, мм (только для просмотра)

/* ---------- КРЕПЁЖ ---------- */
m3_clear = 3.4;  // отверстие под M3 «свободно», мм
m3_tap   = 2.6;  // отверстие под M3 саморез в пластик, мм
m25_tap  = 2.2;  // отверстие под M2.5 в стойке (саморез/резьба), мм
m2_tap   = 2.2;  // отверстие под M2 (камера), мм

/* ---------- RASPBERRY PI 4 ---------- */
pi_x       = 30;     // X центра рисунка отверстий Pi, мм
pi_hx      = 58;     // расстояние между отверстиями по длине, мм
pi_hy      = 49;     // расстояние между отверстиями по ширине, мм
pi_stand_h = 26;     // высота стоек Pi над плитой, мм (под ней стоит батарейный отсек 19 мм)
stand_d    = 6;      // диаметр стоек, мм
pi_len     = 85;     // размеры платы Pi (для просмотра), мм
pi_wid     = 56;
pi_off     = -10;    // сдвиг центра платы относительно центра отверстий по X (порты назад), мм

/* ---------- ARDUINO UNO ---------- */
uno_x0      = -96;   // X левого нижнего угла платы Uno (USB-разъём смотрит назад), мм
uno_stand_h = 6;     // высота стоек Uno, мм
uno_len     = 68.6;
uno_wid     = 53.3;
// отверстия Uno от угла платы, мм (стандарт: 0.55",0.1" / 0.6",2.0" / 2.6",0.3" / 2.6",1.4")
uno_holes = [[13.97, 2.54], [15.24, 50.8], [66.04, 7.62], [66.04, 35.56]];

/* ---------- БАТАРЕЙНЫЙ ОТСЕК 2×18650 ---------- */
bat_l     = 77;    // длина отсека, мм
bat_w     = 41;    // ширина отсека, мм
bat_h     = 19;    // высота отсека, мм
bat_x     = 30;    // X центра отсека (стоит под Raspberry Pi), мм
bat_stop  = 3;     // толщина упоров по краям, мм
bat_tie_dx = 12;   // стяжки: смещение по X от центра, мм
bat_tie_y  = 23;   // стяжки: положение по Y (±), мм

/* ---------- МАЧТА КАМЕРЫ (Pi Camera Module 3) ---------- */
mast_x   = 77;     // X мачты, мм
mast_w   = 28;     // ширина пластины мачты, мм
mast_t   = 4;      // толщина, мм
mast_h   = 55;     // высота мачты над плитой, мм
socket_h = 10;     // глубина гнезда в плите, мм
cam_hx   = 21;     // расстояние между отверстиями камеры по горизонтали, мм
cam_hy   = 12.5;   // по вертикали, мм
cam_lens = 14;     // отверстие под объектив, мм

/* ---------- ДАТЧИК HC-SR04 ---------- */
sens_x   = 98;     // X гнезда фиксированного датчика, мм
sens_w   = 52;     // ширина пластины-держателя, мм
sens_t   = 3.2;    // толщина, мм
sens_hole_d  = 16.4; // отверстие под «глазок» датчика, мм
sens_hole_dx = 13;   // расстояние от центра до центра «глазка», мм
sens_h   = 34;     // высота пластины вместе с глубиной гнезда, мм

/* ---------- СЕРВОПРИВОД SG90 (по желанию) ---------- */
servo_x     = 96;    // X оси вала сервопривода, мм
servo_body  = [22.8, 12.6]; // вырез под корпус по Y × X, мм
servo_shaft = 5.9;   // вал от края корпуса вдоль Y, мм
servo_ear   = 14.1;  // отверстия ушек от центра выреза по Y (±), мм
servo_pad_h = 8;     // высота площадки под ушки, мм
sh_blade_w  = 54;    // ширина головы датчика, мм

/* ---------- КАБЕЛИ ---------- */
cable_slot_x = 84.5; // щель для шлейфа камеры и проводов датчика (между мачтой и носом), мм

$fn = 48;

// ---------------- производные величины ----------------
motor_r  = motor_d / 2;
axis_z   = plate_t + motor_floor + motor_r;   // высота оси колёс над столом
y_face   = plate_W / 2 - stop_t;              // Y торца редуктора
sad_w    = motor_d + 2 * motor_wall;          // ширина седла
screw_dx = motor_r + motor_wall / 2;          // положение винтов скобы
clearance = wheel_d / 2 - axis_z;             // клиренс под платой

// ---------------- вспомогательные модули ----------------
module rrect(l, w, r) {
    offset(r = r) square([l - 2 * r, w - 2 * r], center = true);
}

module standoff(h, d, hole, depth = 10) {
    difference() {
        union() {
            cylinder(d = d, h = h);
            cylinder(d1 = d + 5, d2 = d, h = 3);  // конус у основания — прочнее
        }
        translate([0, 0, h - depth]) cylinder(d = hole, h = depth + 1, $fn = 24);
    }
}

// ---------------- седло мотора ----------------
module saddle(y0) {
    difference() {
        translate([-sad_w / 2, y0, 0]) cube([sad_w, clamp_w, axis_z]);
        translate([0, y0 - 1, axis_z]) rotate([-90, 0, 0])
            cylinder(d = motor_d + motor_tol, h = clamp_w + 2);
        for (sx = [-1, 1])
            translate([sx * screw_dx, y0 + clamp_w / 2, axis_z - 12])
                cylinder(d = m3_tap, h = 13, $fn = 24);
    }
}

module stop_wall() {
    difference() {
        translate([-sad_w / 2, y_face, 0]) cube([sad_w, stop_t, axis_z]);
        translate([0, y_face - 1, axis_z]) rotate([-90, 0, 0])
            cylinder(d = boss_d, h = stop_t + 2);
    }
}

module motor_station(ax, side) {   // side = +1 (левый борт) или -1 (правый)
    translate([ax, 0, 0]) mirror([0, side > 0 ? 0 : 1, 0]) {
        stop_wall();
        for (o = clamp_off) saddle(y_face - o - clamp_w);
    }
}

// ---------------- скоба мотора (печатать плоской стороной вниз) ----------------
module clamp() {
    difference() {
        translate([-sad_w / 2, 0, 0]) cube([sad_w, clamp_w, motor_r + clamp_wall]);
        translate([0, -1, 0]) rotate([-90, 0, 0])
            cylinder(d = motor_d + motor_tol, h = clamp_w + 2);
        for (sx = [-1, 1]) translate([sx * screw_dx, clamp_w / 2, -1]) {
            cylinder(d = m3_clear, h = motor_r + clamp_wall + 2, $fn = 24);
            translate([0, 0, motor_r + clamp_wall - 2.5]) cylinder(d = 6.4, h = 4, $fn = 24); // под головку
        }
    }
}

// ---------------- гнездо для вертикальной пластины ----------------
module socket_block(bw, bt) {   // блок стоит на плите, X-центр в 0, пластина стоит поперёк X
    wall = 3.2;
    difference() {
        translate([-(bt + 2 * wall) / 2, -(bw + 8) / 2, plate_t - 0.01])
            cube([bt + 2 * wall, bw + 8, socket_h + 0.01]);
        translate([-(bt + 0.3) / 2, -(bw + 0.4) / 2, plate_t])
            cube([bt + 0.3, bw + 0.4, socket_h + 1]);
        for (sy = [-1, 1])
            translate([-10, sy * (bw / 2 - 5), plate_t + socket_h / 2]) rotate([0, 90, 0])
                cylinder(d = m3_tap, h = 20, $fn = 24);
    }
}
module socket_holes(bw) {      // отверстия самореза в пластине
    for (sy = [-1, 1])
        translate([0, sy * (bw / 2 - 5), 5]) children();
}

// ---------------- ОСНОВНАЯ ПЛИТА ----------------
module plate() {
    difference() {
        union() {
            // плита
            linear_extrude(plate_t) rrect(plate_L, plate_W, corner_r);
            // бортик по периметру
            linear_extrude(plate_t + rim_h) difference() {
                rrect(plate_L, plate_W, corner_r);
                rrect(plate_L - 2 * rim_w, plate_W - 2 * rim_w, corner_r - rim_w);
            }
            // продольные рёбра
            for (sy = [-1, 1])
                translate([-plate_L / 2 + 1, sy * rib_y - rib_w / 2, 0])
                    cube([plate_L - 2, rib_w, plate_t + rib_h]);
            // поперечные рёбра (между Arduino и Pi, и за Arduino)
            for (cx = [-26, -66])
                translate([cx - rib_w / 2, -rib_y, 0]) cube([rib_w, 2 * rib_y, plate_t + rib_h]);
            // диагональные рёбра в углах носа и кормы
            for (sx = [-1, 1], sy = [-1, 1])
                hull() {
                    translate([sx * (plate_L / 2 - 14), sy * (plate_W / 2 - 14), 0]) cylinder(d = rib_w, h = plate_t + rib_h, $fn = 12);
                    translate([sx * 90, sy * rib_y, 0]) cylinder(d = rib_w, h = plate_t + rib_h, $fn = 12);
                }
            // седла моторов
            for (ax = [axle_x, -axle_x], s = [1, -1]) motor_station(ax, s);
            // стойки Raspberry Pi
            for (sx = [-1, 1], sy = [-1, 1])
                translate([pi_x + sx * pi_hx / 2, sy * pi_hy / 2, plate_t - 0.01])
                    standoff(pi_stand_h, stand_d, m25_tap);
            // стойки Arduino Uno
            for (h = uno_holes)
                translate([uno_x0 + h[0], -uno_wid / 2 + h[1], plate_t - 0.01])
                    standoff(uno_stand_h, stand_d, m3_tap, 6);
            // упоры батарейного отсека
            for (sx = [-1, 1])
                translate([bat_x + sx * (bat_l / 2 + 0.5 + bat_stop / 2) - bat_stop / 2, -bat_w / 2, plate_t - 0.01])
                    cube([bat_stop, bat_w, 8]);
            // гнездо мачты
            translate([mast_x, 0, 0]) socket_block(mast_w, mast_t);
            // датчик спереди: гнездо или площадка под сервопривод
            if (!use_servo) translate([sens_x, 0, 0]) socket_block(sens_w, sens_t);
            else servo_pad();
        }

        // --- вырезы ---
        // щель для шлейфа камеры и проводов датчика
        translate([cable_slot_x, -24, -1]) cube([3.4, 48, plate_t + 2]);
        // окно в бортике сзади под USB/питание Arduino
        translate([-plate_L / 2 - 1, -20, plate_t]) cube([rim_w + 2, 40, rim_h + 1]);
        // отверстия под провода моторов (у задних торцов моторов)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (axle_x + 12), sy * 24, -1]) cylinder(d = 8, h = plate_t + 2);
        // щель под кабели между Arduino и Pi
        translate([-21.5, -12, -1]) cube([6, 24, plate_t + 2]);
        // отверстия под стяжки батарейного отсека
        for (sx = [-1, 1], sy = [-1, 1])
            translate([bat_x + sx * bat_tie_dx - 2.25, sy * bat_tie_y - 1, -1]) cube([4.5, 2, plate_t + 2]);
        // служебные отверстия для крепления верхней платы/бампера в углах (M3)
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx * (plate_L / 2 - 8), sy * (plate_W / 2 - 8), -1]) cylinder(d = m3_clear, h = plate_t + 2, $fn = 24);
        // отверстия сервопривода
        if (use_servo) servo_cut();
    }
}

// ---------------- сервопривод ----------------
servo_cy = -(servo_body[0] / 2 - servo_shaft);   // центр выреза по Y, чтобы вал стоял на Y = 0
module servo_pad() {
    translate([servo_x - 9, servo_cy - 19.5, plate_t - 0.01]) cube([18, 39, servo_pad_h]);
}
module servo_cut() {
    translate([servo_x - servo_body[1] / 2, servo_cy - servo_body[0] / 2, -1])
        cube([servo_body[1], servo_body[0], plate_t + servo_pad_h + 2]);
    for (s = [-1, 1])
        translate([servo_x, servo_cy + s * servo_ear, plate_t]) cylinder(d = 2.2, h = servo_pad_h + 1, $fn = 16);
    // окно в бортике спереди (голова датчика выступает за плиту)
    translate([plate_L / 2 - rim_w - 1, servo_cy - 22, plate_t]) cube([rim_w + 2, 44, rim_h + 1]);
}

// ---------------- мачта камеры (печатать плашмя) ----------------
module mast() {
    H = socket_h + mast_h;
    yc = H - 13;               // высота центра камеры
    difference() {
        linear_extrude(mast_t) hull() {
            translate([-mast_w / 2, 0]) square([mast_w, 1]);
            translate([-mast_w / 2 + 4, H - 4]) circle(r = 4);
            translate([ mast_w / 2 - 4, H - 4]) circle(r = 4);
        }
        translate([0, 0, -1]) {
            for (sy = [-1, 1]) translate([sy * (mast_w / 2 - 5), 5]) cylinder(d = m3_tap, h = mast_t + 2, $fn = 24);
            translate([0, yc]) cylinder(d = cam_lens, h = mast_t + 2);
            for (sx = [-1, 1], sz = [-1, 1])
                translate([sx * cam_hx / 2, yc + sz * cam_hy / 2]) cylinder(d = m2_tap, h = mast_t + 2, $fn = 20);
            translate([-9, yc - 14.5]) cube([18, 2.6, mast_t + 2]);   // щель под шлейф камеры
        }
    }
}

// ---------------- держатель датчика HC-SR04 (фиксированный, печатать плашмя) ----------------
module sensor() {
    difference() {
        linear_extrude(sens_t) hull() {
            translate([-sens_w / 2, 0]) square([sens_w, 1]);
            translate([-sens_w / 2 + 4, sens_h - 4]) circle(r = 4);
            translate([ sens_w / 2 - 4, sens_h - 4]) circle(r = 4);
        }
        translate([0, 0, -1]) {
            for (sy = [-1, 1]) translate([sy * (sens_w / 2 - 5), 5]) cylinder(d = m3_tap, h = sens_t + 2, $fn = 24);
            for (sx = [-1, 1]) translate([sx * sens_hole_dx, socket_h + 12]) cylinder(d = sens_hole_d, h = sens_t + 2);
        }
    }
}

// ---------------- голова датчика на сервоприводе (платформа вниз) ----------------
module sensor_servo() {
    t = 3; bh = 26; d_blade = 14;      // блок стоит на горне: вал в точке (0,0)
    difference() {
        union() {
            // платформа
            translate([8, -sh_blade_w / 2, 0]) cube([d_blade + sens_t - 8, sh_blade_w, t]);
            translate([-9, -11, 0]) cube([18, 22, t]);
            // пластина с «глазками»
            translate([d_blade, -sh_blade_w / 2, 0]) cube([sens_t, sh_blade_w, bh]);
            // косынки по краям (плату не задевают)
            for (sy = [-1, 1]) hull() {
                translate([d_blade - 6, sy * (sh_blade_w / 2 - 1.5) - 1.5, 0]) cube([6, 3, t]);
                translate([d_blade - 0.01, sy * (sh_blade_w / 2 - 1.5) - 1.5, 0]) cube([0.01, 3, 14]);
            }
        }
        // отверстия под горн сервопривода: центральный винт + два по краям
        translate([0, 0, -1]) cylinder(d = 4.5, h = t + 2, $fn = 24);
        for (s = [-1, 1]) translate([0, s * 8, -1]) cylinder(d = 2, h = t + 2, $fn = 16);
        // «глазки» HC-SR04
        for (sx = [-1, 1])
            translate([d_blade - 1, sx * sens_hole_dx, t + 10]) rotate([0, 90, 0]) cylinder(d = sens_hole_d, h = sens_t + 2);
    }
}

// ---------------- просмотр: модели «призраки» ----------------
module ghost_electronics() {
    // Raspberry Pi 4
    color("green", 0.6) translate([pi_x + pi_off - pi_len / 2 + 0, -pi_wid / 2, plate_t + pi_stand_h])
        translate([0, 0, 0]) cube([pi_len, pi_wid, 1.6]);
    // Arduino Uno
    color("deepskyblue", 0.6) translate([uno_x0, -uno_wid / 2, plate_t + uno_stand_h]) cube([uno_len, uno_wid, 1.6]);
    // аккумуляторный отсек
    color("dimgray", 0.8) translate([bat_x - bat_l / 2, -bat_w / 2, plate_t]) cube([bat_l, bat_w, bat_h]);
    // моторы, колёса
    for (ax = [axle_x, -axle_x], s = [1, -1]) translate([ax, 0, 0]) mirror([0, s > 0 ? 0 : 1, 0]) {
        color("silver", 0.9) translate([0, y_face - motor_len, axis_z]) rotate([-90, 0, 0]) cylinder(d = motor_d, h = motor_len);
        color("silver") translate([0, y_face, axis_z]) rotate([-90, 0, 0]) cylinder(d = 4, h = stop_t + shaft_len);
        color("black", 0.8) translate([0, y_face + stop_t + 2, axis_z]) rotate([-90, 0, 0]) cylinder(d = wheel_d, h = wheel_w);
        // скобы
        color("orange") for (o = clamp_off) translate([0, y_face - o - clamp_w, axis_z]) clamp();
    }
    // камера
    color("darkgreen") translate([mast_x + mast_t / 2 + 0.5, -12.5, plate_t + socket_h + mast_h - 13 - 12]) cube([1.5, 25, 24]);
    // HC-SR04
    if (!use_servo) color("royalblue") translate([sens_x - sens_t / 2 - 2 - 1.6, -22.5, plate_t + socket_h + 2]) cube([1.6, 45, 20]);
}

module assembly() {
    color("dimgray") plate();
    color("goldenrod") translate([mast_x - mast_t / 2, 0, plate_t]) rotate([90, 0, 90]) mast();
    if (!use_servo) color("goldenrod") translate([sens_x - sens_t / 2, 0, plate_t]) rotate([90, 0, 90]) sensor();
    else color("goldenrod") translate([servo_x, 0, plate_t + servo_pad_h + 6.8 + 3.5]) sensor_servo();
    if (show_electronics) ghost_electronics();
}

// ---------------- выбор детали ----------------
if (part == "plate") plate();
else if (part == "clamp") clamp();
else if (part == "mast") mast();
else if (part == "sensor") sensor();
else if (part == "sensor_servo") sensor_servo();
else assembly();

echo(str("Плита: ", plate_L, " x ", plate_W, " x ", plate_t, " мм; клиренс под платой ≈ ", clearance, " мм; ось колёс на высоте ", axis_z, " мм"));
