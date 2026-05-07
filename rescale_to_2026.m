%% ========================================================================
%  RESCALE_TO_2026.m  (v2 - Corrected)
%  ========================================================================
%  Rescales 2025 F1 suspension hardpoints to 2026 regulations, preserving
%  all static kinematic characteristics.
%
%  Scaling strategy:
%    X (longitudinal) *= wheelbase_2026 / wheelbase_2025
%    Y (lateral)      *= track_2026 / track_2025  (different front/rear)
%    Z (vertical)     *= 1.0  (unchanged)
%
%  This preserves:
%    - Camber (depends on Y/Z ratio -> both scaled or unchanged)
%    - KPI (depends on Y/Z ratio of kingpin -> same reasoning)
%    - Caster (depends on X/Z ratio of kingpin -> both scaled or unchanged)
%    - RC Height (scales with Y -> RC moves proportionally)
%    - Anti-dive/squat (depends on X/Z and wheelbase -> ratio preserved)
%
%  Output: Cinematica_Suspension_2026.xlsx with symmetric left/right
%          Comparison table of all kinematic properties
%
%  Oxford Brookes University - ENGR7008 Assignment 2
%  ========================================================================
clear; clc; close all;

%% ======================= REGULATION PARAMETERS ==========================
fprintf('=============================================================\n');
fprintf('  F1 SUSPENSION RESCALING: 2025 -> 2026\n');
fprintf('=============================================================\n\n');

% 2025 Specifications
wb_2025 = 3600;          % mm - wheelbase
width_2025 = 2000;       % mm - max overall width
tyre_F_w_2025 = 305;     % mm - front tyre width
tyre_R_w_2025 = 405;     % mm - rear tyre width
tyre_F_d_2025 = 720;     % mm - front tyre diameter
tyre_R_d_2025 = 720;     % mm - rear tyre diameter

% 2026 Specifications
wb_2026 = 3400;          % mm - wheelbase
width_2026 = 1900;       % mm - max overall width
tyre_F_w_2026 = 280;     % mm - front tyre width
tyre_R_w_2026 = 375;     % mm - rear tyre width
tyre_F_d_2026 = 705;     % mm - front tyre diameter
tyre_R_d_2026 = 710;     % mm - rear tyre diameter

cg_height  = 300;        % mm (estimated)
brake_bias = 0.60;       % front brake proportion

%% ======================= READ 2025 DATA =================================
excel_in = 'Cinematica_Suspension.xlsx';
fprintf('Reading 2025 hardpoints from %s...\n', excel_in);

[F25, front_hp_25, front_names] = load_suspension(excel_in, 'Front 2025', 'front');
[R25, rear_hp_25,  rear_names]  = load_suspension(excel_in, 'Rear 2025',  'rear');

%% ======================= CURRENT DIMENSIONS =============================
front_track_25 = 2 * F25.wheel_center(2);
rear_track_25  = 2 * R25.wheel_center(2);

fprintf('\n2025 Dimensions:\n');
fprintf('  Wheelbase:     %d mm\n', wb_2025);
fprintf('  Front track:   %.1f mm\n', front_track_25);
fprintf('  Rear track:    %.1f mm\n', rear_track_25);

%% ======================= COMPUTE 2026 TARGETS ===========================
% Track reduction: proportional to overall width reduction (100mm total)
delta_width = width_2025 - width_2026;  % 100 mm
front_track_26 = front_track_25 - delta_width;
rear_track_26  = rear_track_25  - delta_width;

fprintf('\n2026 Targets:\n');
fprintf('  Wheelbase:     %d mm  (delta: %d mm)\n', wb_2026, wb_2026-wb_2025);
fprintf('  Front track:   %.1f mm  (delta: %.1f mm)\n', front_track_26, -delta_width);
fprintf('  Rear track:    %.1f mm  (delta: %.1f mm)\n', rear_track_26, -delta_width);

%% ======================= SCALE FACTORS ==================================
sx = wb_2026 / wb_2025;
sy_F = front_track_26 / front_track_25;
sy_R = rear_track_26  / rear_track_25;
sz = 1.0;

fprintf('\nScale Factors:\n');
fprintf('  X (wheelbase):   %.6f\n', sx);
fprintf('  Y front (track): %.6f\n', sy_F);
fprintf('  Y rear (track):  %.6f\n', sy_R);
fprintf('  Z (vertical):    %.6f  (unchanged)\n', sz);

%% ======================= APPLY SCALING ==================================
front_hp_26 = scale_hp(front_hp_25, sx, sy_F, sz);
rear_hp_26  = scale_hp(rear_hp_25,  sx, sy_R, sz);

% Enforce perfect symmetry: Right side = [X_left, -Y_left, Z_left]
front_hp_26 = enforce_symmetry(front_hp_26);
rear_hp_26  = enforce_symmetry(rear_hp_26);

%% ======================= ADJUST TYRE RADIUS =============================
% Update wheel center Z for new tyre loaded radius
% (Contact patch Z stays the same - it's on the ground)

% Front
f_cp_idx = find_idx(front_names, 'Wheel Contact Patch');
f_wc_idx = find_idx(front_names, 'Wheel Center');
r_cp_idx = find_idx(rear_names,  'Wheel Contact Patch');
r_wc_idx = find_idx(rear_names,  'Wheel Center');

lr_F_25 = front_hp_25(f_wc_idx, 3) - front_hp_25(f_cp_idx, 3);
lr_R_25 = rear_hp_25(r_wc_idx, 3)  - rear_hp_25(r_cp_idx, 3);

lr_F_26 = lr_F_25 * (tyre_F_d_2026 / tyre_F_d_2025);
lr_R_26 = lr_R_25 * (tyre_R_d_2026 / tyre_R_d_2025);

fprintf('\nTyre Loaded Radius:\n');
fprintf('  Front: %.2f -> %.2f mm (delta: %.2f mm)\n', lr_F_25, lr_F_26, lr_F_26-lr_F_25);
fprintf('  Rear:  %.2f -> %.2f mm (delta: %.2f mm)\n', lr_R_25, lr_R_26, lr_R_26-lr_R_25);

% Apply: WC_z = CP_z + loaded_radius (both left and right)
front_hp_26(f_wc_idx, 3) = front_hp_26(f_cp_idx, 3) + lr_F_26;
front_hp_26(f_wc_idx, 6) = front_hp_26(f_cp_idx, 6) + lr_F_26;

rear_hp_26(r_wc_idx, 3) = rear_hp_26(r_cp_idx, 3) + lr_R_26;
rear_hp_26(r_wc_idx, 6) = rear_hp_26(r_cp_idx, 6) + lr_R_26;

%% ======================= VERIFY DIMENSIONS ==============================
fprintf('\n2026 Achieved Dimensions:\n');
fprintf('  Front track: %.1f mm (target: %.1f mm) - %s\n', ...
    2*front_hp_26(f_wc_idx, 2), front_track_26, ...
    check_match(2*front_hp_26(f_wc_idx, 2), front_track_26));
fprintf('  Rear track:  %.1f mm (target: %.1f mm) - %s\n', ...
    2*rear_hp_26(r_wc_idx, 2), rear_track_26, ...
    check_match(2*rear_hp_26(r_wc_idx, 2), rear_track_26));

%% ======================= WRITE OUTPUT EXCEL =============================
output_file = 'Cinematica_Suspension_2026.xlsx';
fprintf('\nWriting to %s...\n', output_file);
write_hp(output_file, 'Front 2026', front_hp_26, front_names);
write_hp(output_file, 'Rear 2026',  rear_hp_26,  rear_names);
fprintf('Done.\n');

%% ======================= KINEMATIC COMPARISON ===========================
fprintf('\n=============================================================\n');
fprintf('  KINEMATIC COMPARISON: 2025 vs 2026\n');
fprintf('=============================================================\n');

% Load 2026 structures
[F26, ~, ~] = load_suspension_from_hp(front_hp_26, front_names, 'front');
[R26, ~, ~] = load_suspension_from_hp(rear_hp_26,  rear_names,  'rear');

% Compute all properties
F25_a = compute_wheel_angles(F25);
F26_a = compute_wheel_angles(F26);
F25_ic = compute_instant_centers(F25);
F26_ic = compute_instant_centers(F26);
F25_ad = compute_anti_dive(F25, wb_2025, cg_height, brake_bias);
F26_ad = compute_anti_dive(F26, wb_2026, cg_height, brake_bias);
F25_t  = compute_trail_scrub(F25);
F26_t  = compute_trail_scrub(F26);

R25_a = compute_wheel_angles(R25);
R26_a = compute_wheel_angles(R26);
R25_ic = compute_instant_centers(R25);
R26_ic = compute_instant_centers(R26);
R25_as = compute_anti_squat(R25, wb_2025, cg_height);
R26_as = compute_anti_squat(R26, wb_2026, cg_height);
R25_t  = compute_trail_scrub(R25);
R26_t  = compute_trail_scrub(R26);

% Print comparison table
fprintf('\n%-25s  %12s  %12s  %12s\n', 'FRONT SUSPENSION', '2025', '2026', 'Delta');
fprintf('%-25s  %12s  %12s  %12s\n', repmat('-',1,25), repmat('-',1,12), repmat('-',1,12), repmat('-',1,12));
print_row('Camber [deg]',      F25_a.camber,     F26_a.camber);
print_row('Caster [deg]',      F25_a.caster,     F26_a.caster);
print_row('KPI [deg]',         F25_a.kpi,        F26_a.kpi);
print_row('RC Height [mm]',    F25_ic.rc_height, F26_ic.rc_height);
print_row('FVSA length [mm]',  F25_ic.fvsa_length, F26_ic.fvsa_length);
print_row('SVSA length [mm]',  F25_ic.svsa_length, F26_ic.svsa_length);
print_row('Anti-dive [%]',     F25_ad.percentage, F26_ad.percentage);
print_row('Mech. Trail [mm]',  F25_t.mech_trail,  F26_t.mech_trail);
print_row('Scrub Radius [mm]', F25_t.scrub_radius, F26_t.scrub_radius);
print_row('Motion Ratio [-]',  compute_motion_ratio(F25), compute_motion_ratio(F26));

fprintf('\n%-25s  %12s  %12s  %12s\n', 'REAR SUSPENSION', '2025', '2026', 'Delta');
fprintf('%-25s  %12s  %12s  %12s\n', repmat('-',1,25), repmat('-',1,12), repmat('-',1,12), repmat('-',1,12));
print_row('Camber [deg]',      R25_a.camber,     R26_a.camber);
print_row('Caster [deg]',      R25_a.caster,     R26_a.caster);
print_row('KPI [deg]',         R25_a.kpi,        R26_a.kpi);
print_row('RC Height [mm]',    R25_ic.rc_height, R26_ic.rc_height);
print_row('FVSA length [mm]',  R25_ic.fvsa_length, R26_ic.fvsa_length);
print_row('SVSA length [mm]',  R25_ic.svsa_length, R26_ic.svsa_length);
print_row('Anti-squat [%]',    R25_as.percentage, R26_as.percentage);
print_row('Mech. Trail [mm]',  R25_t.mech_trail,  R26_t.mech_trail);
print_row('Scrub Radius [mm]', R25_t.scrub_radius, R26_t.scrub_radius);
print_row('Motion Ratio [-]',  compute_motion_ratio(R25), compute_motion_ratio(R26));

%% ======================= VISUALISATION ==================================
% Overlay front view: 2025 vs 2026
plot_front_view_comparison(F25, F26, compute_instant_centers(F25), ...
    compute_instant_centers(F26), 'Front');
plot_front_view_comparison(R25, R26, compute_instant_centers(R25), ...
    compute_instant_centers(R26), 'Rear');

fprintf('\n=============================================================\n');
fprintf('  Rescaling complete. Output: %s\n', output_file);
fprintf('=============================================================\n');

%% ========================================================================
%                      FUNCTION DEFINITIONS
%% ========================================================================

function hp_out = scale_hp(hp_in, sx, sy, sz)
    hp_out = hp_in;
    hp_out(:, 1) = hp_in(:, 1) * sx;   % X_L
    hp_out(:, 2) = hp_in(:, 2) * sy;   % Y_L
    hp_out(:, 3) = hp_in(:, 3) * sz;   % Z_L
    hp_out(:, 4) = hp_in(:, 4) * sx;   % X_R
    hp_out(:, 5) = hp_in(:, 5) * sy;   % Y_R
    hp_out(:, 6) = hp_in(:, 6) * sz;   % Z_R
end

function hp_out = enforce_symmetry(hp_in)
    % Force Right = [X_left, -Y_left, Z_left]
    hp_out = hp_in;
    hp_out(:, 4) = hp_in(:, 1);    % X_R = X_L
    hp_out(:, 5) = -hp_in(:, 2);   % Y_R = -Y_L
    hp_out(:, 6) = hp_in(:, 3);    % Z_R = Z_L
end

function idx = find_idx(names, name)
    idx = find(strcmp(names, name), 1);
    if isempty(idx), error('Point "%s" not found.', name); end
end

function s = check_match(actual, target)
    if abs(actual - target) < 0.1
        s = 'OK';
    else
        s = sprintf('MISMATCH (%.2f)', actual - target);
    end
end

function print_row(name, v25, v26)
    fprintf('%-25s  %12.4f  %12.4f  %12.4f\n', name, v25, v26, v26-v25);
end

function write_hp(file, sheet, hp, names)
    n = size(hp, 1);
    data = cell(n, 8);
    for i = 1:n
        data{i, 1} = names{i};
        for j = 1:6
            data{i, j+1} = hp(i, j);
        end
        data{i, 8} = 'mm';
    end
    writecell(data, file, 'Sheet', sheet);
end

%% ======== LOAD SUSPENSION (from Excel) ==========

function [S, hp, names] = load_suspension(file, sheet, type)
    [~, ~, raw] = xlsread(file, sheet);
    n = size(raw, 1);
    names = cell(n, 1);
    hp = zeros(n, 6);
    for i = 1:n
        names{i} = raw{i, 1};
        for j = 1:6
            hp(i, j) = raw{i, j+1};
        end
    end
    S = build_struct(hp, names, type);
end

%% ======== LOAD SUSPENSION (from HP matrix) ==========

function [S, hp, names] = load_suspension_from_hp(hp, names, type)
    S = build_struct(hp, names, type);
end

function S = build_struct(hp, names, type)
    S.lca_front_chassis = get_pt(hp, names, 'Chassis LCA Mount Front');
    S.lca_rear_chassis  = get_pt(hp, names, 'Chassis LCA Mount Rear');
    S.uca_front_chassis = get_pt(hp, names, 'Chassis UCA Mount Front');
    S.uca_rear_chassis  = get_pt(hp, names, 'Chassis UCA Mount Rear');
    S.lca_upright       = get_pt(hp, names, 'Upright Lower Ball Mount');
    S.uca_upright       = get_pt(hp, names, 'Upright Upper Ball Mount');
    S.contact_patch     = get_pt(hp, names, 'Wheel Contact Patch');
    S.wheel_center      = get_pt(hp, names, 'Wheel Center');
    S.damper_chassis    = get_pt(hp, names, 'Chassis Damper Mount');
    S.pushrod_outer     = get_pt(hp, names, 'PushPullrod Outer Mount');
    S.rocker_pivot      = get_pt(hp, names, 'Rocker Chassis Mount');
    S.rocker_axis       = get_pt(hp, names, 'Rocker Chassis Axis');
    S.rocker_damper     = get_pt(hp, names, 'Rocker Damper Mount');
    S.rocker_pushrod    = get_pt(hp, names, 'Rocker PushPullrod Mount');
    if strcmp(type, 'front')
        S.tierod_chassis = get_pt(hp, names, 'Centerlink Tierod Mount');
    else
        S.tierod_chassis = get_pt(hp, names, 'Chassis Track Rod Mount');
    end
    S.tierod_upright = get_pt(hp, names, 'Outer Tierod Mount');
    S.type = type;
end

function pt = get_pt(hp, names, name)
    idx = find(strcmp(names, name), 1);
    if isempty(idx), error('Point "%s" not found.', name); end
    pt = hp(idx, 1:3);
end

%% ======== KINEMATIC CALCULATIONS (shared with Script 1) =========

function angles = compute_wheel_angles(S)
    wc = S.wheel_center;
    cp = S.contact_patch;
    dy = wc(2) - cp(2);
    dz = wc(3) - cp(3);
    angles.camber = atand(dy / dz);
    
    kp = S.uca_upright - S.lca_upright;
    angles.caster = atand(-kp(1) / kp(3));
    angles.kpi    = atand(-kp(2) / kp(3));
end

function ic = compute_instant_centers(S)
    x_ref = S.wheel_center(1);
    lca_axis = S.lca_rear_chassis - S.lca_front_chassis;
    uca_axis = S.uca_rear_chassis - S.uca_front_chassis;
    
    lca_proj = project_to_x(S.lca_front_chassis, lca_axis, x_ref);
    uca_proj = project_to_x(S.uca_front_chassis, uca_axis, x_ref);
    
    fvic = intersect_2d_lines( ...
        [lca_proj(2), lca_proj(3)], [S.lca_upright(2), S.lca_upright(3)], ...
        [uca_proj(2), uca_proj(3)], [S.uca_upright(2), S.uca_upright(3)]);
    
    ic.fvic_y = fvic(1);
    ic.fvic_z = fvic(2);
    ic.fvsa_length = sqrt((fvic(1)-S.wheel_center(2))^2 + (fvic(2)-S.wheel_center(3))^2);
    
    cp_y = S.contact_patch(2); cp_z = S.contact_patch(3);
    if abs(fvic(1) - cp_y) > 1e-6
        slope = (fvic(2) - cp_z) / (fvic(1) - cp_y);
        ic.rc_height = cp_z + slope * (0 - cp_y);
    else
        ic.rc_height = fvic(2);
    end
    
    y_ref = S.wheel_center(2);
    lca_sv = project_to_y(S.lca_front_chassis, lca_axis, y_ref);
    uca_sv = project_to_y(S.uca_front_chassis, uca_axis, y_ref);
    
    svic = intersect_2d_lines( ...
        [lca_sv(1), lca_sv(3)], [S.lca_upright(1), S.lca_upright(3)], ...
        [uca_sv(1), uca_sv(3)], [S.uca_upright(1), S.uca_upright(3)]);
    
    ic.svic_x = svic(1);
    ic.svic_z = svic(2);
    ic.svsa_length = sqrt((svic(1)-S.wheel_center(1))^2 + (svic(2)-S.wheel_center(3))^2);
end

function anti = compute_anti_dive(S, wb, cg_h, brake_f)
    ic = compute_instant_centers(S);
    cp = S.contact_patch;
    dx = ic.svic_x - cp(1);
    dz = ic.svic_z - cp(3);
    if abs(dx) > 1e-6
        tan_theta = dz / abs(dx);
    else
        tan_theta = 0;
    end
    tan_ideal = (cg_h * brake_f) / wb;
    anti.angle = atand(tan_theta);
    anti.percentage = (tan_theta / tan_ideal) * 100;
end

function anti = compute_anti_squat(S, wb, cg_h)
    ic = compute_instant_centers(S);
    cp = S.contact_patch;
    dx = ic.svic_x - cp(1);
    dz = ic.svic_z - cp(3);
    if abs(dx) > 1e-6
        tan_theta = dz / abs(dx);
    else
        tan_theta = 0;
    end
    tan_ideal = cg_h / wb;
    anti.angle = atand(tan_theta);
    anti.percentage = (tan_theta / tan_ideal) * 100;
end

function trail = compute_trail_scrub(S)
    kp = S.uca_upright - S.lca_upright;
    cp = S.contact_patch;
    if abs(kp(3)) > 1e-6
        t = (cp(3) - S.lca_upright(3)) / kp(3);
        kp_ground = S.lca_upright + t * kp;
    else
        kp_ground = S.lca_upright;
    end
    trail.mech_trail = cp(1) - kp_ground(1);
    trail.scrub_radius = cp(2) - kp_ground(2);
end

function mr = compute_motion_ratio(S)
    r_push = norm(S.rocker_pushrod - S.rocker_pivot);
    r_damp = norm(S.rocker_damper  - S.rocker_pivot);
    if r_push > 1e-6, mr = r_damp / r_push; else, mr = 1.0; end
end

function proj = project_to_x(origin, direction, x_target)
    if abs(direction(1)) > 1e-6
        t = (x_target - origin(1)) / direction(1);
        proj = origin + t * direction;
    else
        proj = origin;
    end
end

function proj = project_to_y(origin, direction, y_target)
    if abs(direction(2)) > 1e-6
        t = (y_target - origin(2)) / direction(2);
        proj = origin + t * direction;
    else
        proj = origin;
    end
end

function p_int = intersect_2d_lines(p1, p2, p3, p4)
    d1 = p2 - p1;
    d2 = p4 - p3;
    denom = d1(1)*d2(2) - d1(2)*d2(1);
    if abs(denom) < 1e-10
        p_int = [NaN, NaN];
        return;
    end
    dp = p3 - p1;
    t = (dp(1)*d2(2) - dp(2)*d2(1)) / denom;
    p_int = p1 + t * d1;
end

%% ======== COMPARISON VISUALISATION =========

function plot_front_view_comparison(S25, S26, ic25, ic26, label)
    figure('Name', [label ' Front View: 2025 vs 2026'], ...
           'Position', [100 100 900 600]);
    hold on; grid on;
    
    ground_z = S25.contact_patch(3);
    
    % 2025 (blue)
    lca25 = project_to_x(S25.lca_front_chassis, ...
        S25.lca_rear_chassis - S25.lca_front_chassis, S25.wheel_center(1));
    uca25 = project_to_x(S25.uca_front_chassis, ...
        S25.uca_rear_chassis - S25.uca_front_chassis, S25.wheel_center(1));
    
    plot([lca25(2), S25.lca_upright(2)], [lca25(3), S25.lca_upright(3)], ...
         'b-', 'LineWidth', 2, 'DisplayName', '2025 LCA');
    plot([uca25(2), S25.uca_upright(2)], [uca25(3), S25.uca_upright(3)], ...
         'b--', 'LineWidth', 2, 'DisplayName', '2025 UCA');
    plot(S25.wheel_center(2), S25.wheel_center(3), 'bo', 'MarkerSize', 8, ...
         'MarkerFaceColor', 'b', 'DisplayName', '2025 WC');
    plot(0, ic25.rc_height, 'bp', 'MarkerSize', 12, 'MarkerFaceColor', 'b', ...
         'DisplayName', sprintf('2025 RC (%.1fmm)', ic25.rc_height));
    
    % 2026 (red)
    lca26 = project_to_x(S26.lca_front_chassis, ...
        S26.lca_rear_chassis - S26.lca_front_chassis, S26.wheel_center(1));
    uca26 = project_to_x(S26.uca_front_chassis, ...
        S26.uca_rear_chassis - S26.uca_front_chassis, S26.wheel_center(1));
    
    plot([lca26(2), S26.lca_upright(2)], [lca26(3), S26.lca_upright(3)], ...
         'r-', 'LineWidth', 2, 'DisplayName', '2026 LCA');
    plot([uca26(2), S26.uca_upright(2)], [uca26(3), S26.uca_upright(3)], ...
         'r--', 'LineWidth', 2, 'DisplayName', '2026 UCA');
    plot(S26.wheel_center(2), S26.wheel_center(3), 'ro', 'MarkerSize', 8, ...
         'MarkerFaceColor', 'r', 'DisplayName', '2026 WC');
    plot(0, ic26.rc_height, 'rp', 'MarkerSize', 12, 'MarkerFaceColor', 'r', ...
         'DisplayName', sprintf('2026 RC (%.1fmm)', ic26.rc_height));
    
    % Ground
    plot([-50, max(S25.contact_patch(2), S26.contact_patch(2))+50], ...
         [ground_z, ground_z], 'k-', 'LineWidth', 0.5, 'HandleVisibility', 'off');
    
    % Centerline
    plot([0, 0], [ground_z-30, 500], 'k:', 'LineWidth', 0.5, 'HandleVisibility', 'off');
    
    xlabel('Y [mm] (lateral)');
    ylabel('Z [mm] (vertical)');
    title(sprintf('%s Suspension - Front View Comparison', label));
    legend('Location', 'best');
    axis equal;
end
