%% ========================================================================
%  EXTRACT_KINEMATICS_2025.m  (v2 - Corrected)
%  ========================================================================
%  Extracts suspension kinematic characteristics from 2025 F1 hardpoints.
%  Computes static kinematic properties with verified equations.
%
%  Calculated properties:
%    - Camber, Toe, Caster, KPI (Kingpin Inclination)
%    - Front/Side View Instant Centers (FVIC, SVIC)
%    - Roll Center Height
%    - Anti-dive (front), Anti-squat (rear)
%    - Mechanical Trail, Scrub Radius
%    - Motion Ratio (rocker geometry)
%
%  Input:  Cinematica_Suspension.xlsx (sheets: 'Front 2025', 'Rear 2025')
%  Output: kinematics_2025.mat
%          Console printout of all properties
%          3D visualisation of suspension geometry
%
%  Oxford Brookes University - ENGR7008 Assignment 2
%  Vehicle Dynamics Section
%  ========================================================================
clear; clc; close all;

%% ======================= USER PARAMETERS ================================
excel_file = 'Cinematica_Suspension.xlsx';
wheelbase  = 3600;   % mm (2025 regulation maximum)
cg_height  = 300;    % mm (estimated, typical F1)
brake_bias = 0.60;   % front brake proportion (typical F1)

%% ======================= READ HARDPOINTS ================================
fprintf('=============================================================\n');
fprintf('  F1 SUSPENSION KINEMATIC ANALYSIS - 2025 SPECIFICATION\n');
fprintf('=============================================================\n\n');

[F, front_hp, front_names] = load_suspension(excel_file, 'Front 2025', 'front');
[R, rear_hp,  rear_names]  = load_suspension(excel_file, 'Rear 2025',  'rear');

%% ======================= FRONT SUSPENSION ANALYSIS ======================
fprintf('\n===================== FRONT SUSPENSION =====================\n');

% Basic dimensions
fprintf('\nDimensions:\n');
fprintf('  Half-track (wheel center Y):  %.2f mm\n', F.wheel_center(2));
fprintf('  Full track:                   %.2f mm\n', 2*F.wheel_center(2));
fprintf('  Loaded tyre radius:           %.2f mm\n', ...
    F.wheel_center(3) - F.contact_patch(3));

% Wheel angles
[F_angles] = compute_wheel_angles(F);
fprintf('\nWheel Alignment Angles:\n');
fprintf('  Camber:     %+.4f deg\n', F_angles.camber);
fprintf('  Caster:     %+.4f deg\n', F_angles.caster);
fprintf('  KPI:        %+.4f deg\n', F_angles.kpi);

% Instant centers
[F_ic] = compute_instant_centers(F);
fprintf('\nInstant Centers:\n');
fprintf('  FVIC (Y, Z):  [%.2f, %.2f] mm\n', F_ic.fvic_y, F_ic.fvic_z);
fprintf('  SVIC (X, Z):  [%.2f, %.2f] mm\n', F_ic.svic_x, F_ic.svic_z);
fprintf('  FVSA length:   %.2f mm\n', F_ic.fvsa_length);
fprintf('  SVSA length:   %.2f mm\n', F_ic.svsa_length);

% Roll center
fprintf('\nRoll Center:\n');
fprintf('  RC Height:  %.4f mm\n', F_ic.rc_height);

% Anti-features
F_anti = compute_anti_dive(F, wheelbase, cg_height, brake_bias);
fprintf('\nAnti-Dive:\n');
fprintf('  SVIC angle from ground:  %.4f deg\n', F_anti.angle);
fprintf('  Anti-dive:               %.2f %%\n', F_anti.percentage);

% Trail and scrub
[F_trail] = compute_trail_scrub(F);
fprintf('\nTrail and Scrub Radius:\n');
fprintf('  Mechanical trail:  %.2f mm\n', F_trail.mech_trail);
fprintf('  Scrub radius:      %.2f mm\n', F_trail.scrub_radius);

% Motion ratio
F_mr = compute_motion_ratio(F);
fprintf('\nMotion Ratio (rocker lever):  %.4f\n', F_mr);

% Link lengths
F_links = compute_link_lengths(F);
fprintf('\nLink Lengths:\n');
fprintf('  LCA (front arm): %.2f mm\n', F_links.lca_front);
fprintf('  LCA (rear arm):  %.2f mm\n', F_links.lca_rear);
fprintf('  UCA (front arm): %.2f mm\n', F_links.uca_front);
fprintf('  UCA (rear arm):  %.2f mm\n', F_links.uca_rear);
fprintf('  Tie rod:         %.2f mm\n', F_links.tierod);
fprintf('  Pushrod:         %.2f mm\n', F_links.pushrod);

%% ======================= REAR SUSPENSION ANALYSIS =======================
fprintf('\n\n===================== REAR SUSPENSION ======================\n');

fprintf('\nDimensions:\n');
fprintf('  Half-track (wheel center Y):  %.2f mm\n', R.wheel_center(2));
fprintf('  Full track:                   %.2f mm\n', 2*R.wheel_center(2));
fprintf('  Loaded tyre radius:           %.2f mm\n', ...
    R.wheel_center(3) - R.contact_patch(3));

[R_angles] = compute_wheel_angles(R);
fprintf('\nWheel Alignment Angles:\n');
fprintf('  Camber:     %+.4f deg\n', R_angles.camber);
fprintf('  Caster:     %+.4f deg\n', R_angles.caster);
fprintf('  KPI:        %+.4f deg\n', R_angles.kpi);

[R_ic] = compute_instant_centers(R);
fprintf('\nInstant Centers:\n');
fprintf('  FVIC (Y, Z):  [%.2f, %.2f] mm\n', R_ic.fvic_y, R_ic.fvic_z);
fprintf('  SVIC (X, Z):  [%.2f, %.2f] mm\n', R_ic.svic_x, R_ic.svic_z);
fprintf('  FVSA length:   %.2f mm\n', R_ic.fvsa_length);
fprintf('  SVSA length:   %.2f mm\n', R_ic.svsa_length);

fprintf('\nRoll Center:\n');
fprintf('  RC Height:  %.4f mm\n', R_ic.rc_height);

R_anti = compute_anti_squat(R, wheelbase, cg_height);
fprintf('\nAnti-Squat:\n');
fprintf('  SVIC angle from ground:  %.4f deg\n', R_anti.angle);
fprintf('  Anti-squat:              %.2f %%\n', R_anti.percentage);

[R_trail] = compute_trail_scrub(R);
fprintf('\nTrail and Scrub Radius:\n');
fprintf('  Mechanical trail:  %.2f mm\n', R_trail.mech_trail);
fprintf('  Scrub radius:      %.2f mm\n', R_trail.scrub_radius);

R_mr = compute_motion_ratio(R);
fprintf('\nMotion Ratio (rocker lever):  %.4f\n', R_mr);

R_links = compute_link_lengths(R);
fprintf('\nLink Lengths:\n');
fprintf('  LCA (front arm): %.2f mm\n', R_links.lca_front);
fprintf('  LCA (rear arm):  %.2f mm\n', R_links.lca_rear);
fprintf('  UCA (front arm): %.2f mm\n', R_links.uca_front);
fprintf('  UCA (rear arm):  %.2f mm\n', R_links.uca_rear);
fprintf('  Tie rod:         %.2f mm\n', R_links.tierod);
fprintf('  Pushrod:         %.2f mm\n', R_links.pushrod);

%% ======================= VISUALISATION ==================================
plot_suspension_3d(F, 'Front 2025');
plot_suspension_3d(R, 'Rear 2025');
plot_front_view(F, F_ic, 'Front 2025');
plot_front_view(R, R_ic, 'Rear 2025');

%% ======================= SAVE RESULTS ===================================
results.wheelbase    = wheelbase;
results.cg_height    = cg_height;
results.brake_bias   = brake_bias;
results.front.hp     = front_hp;
results.front.names  = front_names;
results.front.points = F;
results.front.angles = F_angles;
results.front.ic     = F_ic;
results.front.anti   = F_anti;
results.front.trail  = F_trail;
results.front.mr     = F_mr;
results.front.links  = F_links;
results.rear.hp      = rear_hp;
results.rear.names   = rear_names;
results.rear.points  = R;
results.rear.angles  = R_angles;
results.rear.ic      = R_ic;
results.rear.anti    = R_anti;
results.rear.trail   = R_trail;
results.rear.mr      = R_mr;
results.rear.links   = R_links;

save('kinematics_2025.mat', 'results');
fprintf('\n\nResults saved to kinematics_2025.mat\n');
fprintf('=============================================================\n');

%% ========================================================================
%                      FUNCTION DEFINITIONS
%% ========================================================================

function [S, hp, names] = load_suspension(file, sheet, type)
    % Read hardpoints and extract named points
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
    
    % Extract key points (left side: columns 1:3)
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
    
    % Tie rod name differs between front and rear
    if strcmp(type, 'front')
        S.tierod_chassis = get_pt(hp, names, 'Centerlink Tierod Mount');
        S.tierod_upright = get_pt(hp, names, 'Outer Tierod Mount');
    else
        S.tierod_chassis = get_pt(hp, names, 'Chassis Track Rod Mount');
        S.tierod_upright = get_pt(hp, names, 'Outer Tierod Mount');
    end
    
    S.type = type;
end

function pt = get_pt(hp, names, name)
    idx = find(strcmp(names, name), 1);
    if isempty(idx)
        error('Hardpoint "%s" not found.', name);
    end
    pt = hp(idx, 1:3);  % Left side [X, Y, Z]
end

%% ===================== WHEEL ANGLE CALCULATIONS =========================

function angles = compute_wheel_angles(S)
    % CAMBER: inclination of wheel from vertical in front view (YZ plane)
    % Measured from the wheel center - contact patch line.
    % Convention: negative camber = top of wheel leans inward.
    % For left side: if WC_y < CP_y, wheel leans in = negative camber.
    %
    % camber = atan2(-(WC_y - CP_y), (WC_z - CP_z))
    % The negative sign on dY gives: WC inboard of CP -> positive angle
    % which we then negate for standard convention (inboard = negative camber)
    
    wc = S.wheel_center;
    cp = S.contact_patch;
    dy = wc(2) - cp(2);  % lateral offset (negative = WC inboard of CP)
    dz = wc(3) - cp(3);  % vertical (loaded radius)
    
    % Camber: positive = top of wheel tilted outward
    % For left wheel: dy < 0 means WC is inboard -> negative camber
    angles.camber = atand(dy / dz);
    
    % KINGPIN AXIS: from lower ball joint to upper ball joint
    kp = S.uca_upright - S.lca_upright;
    
    % CASTER: angle of kingpin in side view (XZ plane)
    % Positive caster = kingpin tilts backward (upper pivot behind lower)
    % kp(1) < 0 means upper is behind lower -> positive caster
    angles.caster = atand(-kp(1) / kp(3));
    
    % KPI (Kingpin Inclination): angle of kingpin in front view (YZ plane)
    % Positive KPI = kingpin tilts inward at top
    % For left side: kp(2) < 0 means upper is inboard of lower -> positive KPI
    angles.kpi = atand(-kp(2) / kp(3));
end

%% ===================== INSTANT CENTER CALCULATIONS ======================

function ic = compute_instant_centers(S)
    % FRONT VIEW INSTANT CENTER (FVIC)
    % Found by intersecting the LCA and UCA lines in the YZ plane
    % Each line goes from the chassis pivot axis (projected to wheel X)
    % to the respective ball joint on the upright
    
    x_ref = S.wheel_center(1);  % Project at wheel center X
    
    % LCA chassis pivot axis
    lca_axis = S.lca_rear_chassis - S.lca_front_chassis;
    lca_proj = project_to_x(S.lca_front_chassis, lca_axis, x_ref);
    
    % UCA chassis pivot axis
    uca_axis = S.uca_rear_chassis - S.uca_front_chassis;
    uca_proj = project_to_x(S.uca_front_chassis, uca_axis, x_ref);
    
    % Intersect in YZ plane
    % Line 1: lca_proj(Y,Z) -> lca_upright(Y,Z)
    % Line 2: uca_proj(Y,Z) -> uca_upright(Y,Z)
    fvic = intersect_2d_lines( ...
        [lca_proj(2), lca_proj(3)], [S.lca_upright(2), S.lca_upright(3)], ...
        [uca_proj(2), uca_proj(3)], [S.uca_upright(2), S.uca_upright(3)]);
    
    ic.fvic_y = fvic(1);
    ic.fvic_z = fvic(2);
    
    % FVSA length: distance from wheel center to FVIC in YZ plane
    ic.fvsa_length = sqrt((fvic(1) - S.wheel_center(2))^2 + ...
                          (fvic(2) - S.wheel_center(3))^2);
    
    % ROLL CENTER HEIGHT
    % Line from contact patch to FVIC, find where it crosses Y=0 (car centerline)
    cp_y = S.contact_patch(2);
    cp_z = S.contact_patch(3);
    
    if abs(fvic(1) - cp_y) > 1e-6
        slope = (fvic(2) - cp_z) / (fvic(1) - cp_y);
        ic.rc_height = cp_z + slope * (0 - cp_y);
    else
        ic.rc_height = fvic(2);
    end
    
    % SIDE VIEW INSTANT CENTER (SVIC)
    % Intersect LCA and UCA in XZ plane (projected at wheel Y)
    y_ref = S.wheel_center(2);
    
    lca_sv = project_to_y(S.lca_front_chassis, lca_axis, y_ref);
    uca_sv = project_to_y(S.uca_front_chassis, uca_axis, y_ref);
    
    svic = intersect_2d_lines( ...
        [lca_sv(1), lca_sv(3)], [S.lca_upright(1), S.lca_upright(3)], ...
        [uca_sv(1), uca_sv(3)], [S.uca_upright(1), S.uca_upright(3)]);
    
    ic.svic_x = svic(1);
    ic.svic_z = svic(2);
    
    % SVSA length
    ic.svsa_length = sqrt((svic(1) - S.wheel_center(1))^2 + ...
                          (svic(2) - S.wheel_center(3))^2);
end

function proj = project_to_x(origin, direction, x_target)
    % Project a line (origin + t*direction) to plane X = x_target
    if abs(direction(1)) > 1e-6
        t = (x_target - origin(1)) / direction(1);
        proj = origin + t * direction;
    else
        proj = origin;  % Line parallel to YZ plane
    end
end

function proj = project_to_y(origin, direction, y_target)
    % Project a line (origin + t*direction) to plane Y = y_target
    if abs(direction(2)) > 1e-6
        t = (y_target - origin(2)) / direction(2);
        proj = origin + t * direction;
    else
        proj = origin;
    end
end

%% ===================== ANTI-DIVE / ANTI-SQUAT ===========================

function anti = compute_anti_dive(S, wheelbase, cg_h, brake_f)
    % Anti-dive for FRONT suspension
    % The SVIC defines the virtual reaction line.
    % Anti-dive% = tan(theta_svic) / tan(theta_ideal) * 100
    % where theta_svic = angle from contact patch to SVIC
    %       theta_ideal = (CG_height * brake_proportion) / wheelbase
    
    ic = compute_instant_centers(S);
    cp = S.contact_patch;
    
    % Angle of line from contact patch to SVIC
    dx = ic.svic_x - cp(1);   % longitudinal distance
    dz = ic.svic_z - cp(3);   % vertical distance
    
    % For front anti-dive, the SVIC should be behind and above the contact patch
    % The virtual reaction line angle from horizontal
    if abs(dx) > 1e-6
        tan_theta = dz / abs(dx);
    else
        tan_theta = 0;
    end
    
    % Ideal angle for 100% anti-dive
    tan_ideal = (cg_h * brake_f) / wheelbase;
    
    anti.angle = atand(tan_theta);
    anti.percentage = (tan_theta / tan_ideal) * 100;
end

function anti = compute_anti_squat(S, wheelbase, cg_h)
    % Anti-squat for REAR suspension (RWD)
    ic = compute_instant_centers(S);
    cp = S.contact_patch;
    
    dx = ic.svic_x - cp(1);
    dz = ic.svic_z - cp(3);
    
    if abs(dx) > 1e-6
        tan_theta = dz / abs(dx);
    else
        tan_theta = 0;
    end
    
    % For rear: ideal = cg_h / wheelbase (100% drive on rear)
    tan_ideal = cg_h / wheelbase;
    
    anti.angle = atand(tan_theta);
    anti.percentage = (tan_theta / tan_ideal) * 100;
end

%% ===================== TRAIL AND SCRUB RADIUS ===========================

function trail = compute_trail_scrub(S)
    % Mechanical trail: distance at ground level between kingpin axis
    % intersection with ground and the contact patch center (in side view)
    %
    % Scrub radius: same but in front view (lateral offset at ground)
    
    upper = S.uca_upright;
    lower = S.lca_upright;
    kp = upper - lower;  % Kingpin direction vector
    
    cp = S.contact_patch;
    ground_z = cp(3);
    
    % Find where kingpin axis meets the ground plane (Z = ground_z)
    if abs(kp(3)) > 1e-6
        t = (ground_z - lower(3)) / kp(3);
        kp_ground = lower + t * kp;  % [X, Y, Z] of kingpin at ground
    else
        kp_ground = lower;
    end
    
    % Mechanical trail: X_cp - X_kp_ground (positive = contact patch behind)
    trail.mech_trail = cp(1) - kp_ground(1);
    
    % Scrub radius: Y_cp - Y_kp_ground (positive = contact patch outboard)
    trail.scrub_radius = cp(2) - kp_ground(2);
end

%% ===================== MOTION RATIO =====================================

function mr = compute_motion_ratio(S)
    % Approximate motion ratio from rocker geometry
    % MR = (rocker arm to damper) / (rocker arm to pushrod)
    r_push = norm(S.rocker_pushrod - S.rocker_pivot);
    r_damp = norm(S.rocker_damper  - S.rocker_pivot);
    
    if r_push > 1e-6
        mr = r_damp / r_push;
    else
        mr = 1.0;
    end
end

%% ===================== LINK LENGTHS =====================================

function links = compute_link_lengths(S)
    links.lca_front = norm(S.lca_upright - S.lca_front_chassis);
    links.lca_rear  = norm(S.lca_upright - S.lca_rear_chassis);
    links.uca_front = norm(S.uca_upright - S.uca_front_chassis);
    links.uca_rear  = norm(S.uca_upright - S.uca_rear_chassis);
    links.tierod    = norm(S.tierod_upright - S.tierod_chassis);
    links.pushrod   = norm(S.pushrod_outer  - S.rocker_pushrod);
end

%% ===================== 2D LINE INTERSECTION =============================

function p_int = intersect_2d_lines(p1, p2, p3, p4)
    % Intersection of line through p1,p2 and line through p3,p4
    % All inputs are [a, b] 2D points
    d1 = p2 - p1;
    d2 = p4 - p3;
    
    denom = d1(1)*d2(2) - d1(2)*d2(1);
    
    if abs(denom) < 1e-10
        % Lines are parallel
        p_int = [NaN, NaN];
        warning('Parallel lines detected in instant center calculation.');
        return;
    end
    
    dp = p3 - p1;
    t = (dp(1)*d2(2) - dp(2)*d2(1)) / denom;
    p_int = p1 + t * d1;
end

%% ===================== VISUALISATION ====================================

function plot_suspension_3d(S, label)
    figure('Name', [label ' - 3D View'], 'Position', [100 100 800 600]);
    hold on; grid on; axis equal;
    
    % LCA
    plot3([S.lca_front_chassis(1), S.lca_upright(1)], ...
          [S.lca_front_chassis(2), S.lca_upright(2)], ...
          [S.lca_front_chassis(3), S.lca_upright(3)], 'b-', 'LineWidth', 2);
    plot3([S.lca_rear_chassis(1), S.lca_upright(1)], ...
          [S.lca_rear_chassis(2), S.lca_upright(2)], ...
          [S.lca_rear_chassis(3), S.lca_upright(3)], 'b-', 'LineWidth', 2);
    
    % UCA
    plot3([S.uca_front_chassis(1), S.uca_upright(1)], ...
          [S.uca_front_chassis(2), S.uca_upright(2)], ...
          [S.uca_front_chassis(3), S.uca_upright(3)], 'r-', 'LineWidth', 2);
    plot3([S.uca_rear_chassis(1), S.uca_upright(1)], ...
          [S.uca_rear_chassis(2), S.uca_upright(2)], ...
          [S.uca_rear_chassis(3), S.uca_upright(3)], 'r-', 'LineWidth', 2);
    
    % Tie rod
    plot3([S.tierod_chassis(1), S.tierod_upright(1)], ...
          [S.tierod_chassis(2), S.tierod_upright(2)], ...
          [S.tierod_chassis(3), S.tierod_upright(3)], 'g-', 'LineWidth', 2);
    
    % Upright (kingpin axis)
    plot3([S.lca_upright(1), S.uca_upright(1)], ...
          [S.lca_upright(2), S.uca_upright(2)], ...
          [S.lca_upright(3), S.uca_upright(3)], 'k-', 'LineWidth', 3);
    
    % Pushrod
    plot3([S.pushrod_outer(1), S.rocker_pushrod(1)], ...
          [S.pushrod_outer(2), S.rocker_pushrod(2)], ...
          [S.pushrod_outer(3), S.rocker_pushrod(3)], 'm-', 'LineWidth', 1.5);
    
    % Wheel center
    plot3(S.wheel_center(1), S.wheel_center(2), S.wheel_center(3), ...
          'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'k');
    
    % Contact patch
    plot3(S.contact_patch(1), S.contact_patch(2), S.contact_patch(3), ...
          'rs', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
    
    % Ball joints
    pts = [S.lca_front_chassis; S.lca_rear_chassis; ...
           S.uca_front_chassis; S.uca_rear_chassis; ...
           S.lca_upright; S.uca_upright; ...
           S.tierod_chassis; S.tierod_upright];
    plot3(pts(:,1), pts(:,2), pts(:,3), 'ko', 'MarkerSize', 5, ...
          'MarkerFaceColor', [0.5 0.5 0.5]);
    
    xlabel('X [mm] (+ forward)');
    ylabel('Y [mm] (+ left)');
    zlabel('Z [mm] (+ up)');
    title([label ' Suspension - 3D View']);
    legend('LCA', '', 'UCA', '', 'Tie Rod', 'Kingpin', 'Pushrod', ...
           'Wheel Center', 'Contact Patch', 'Location', 'best');
    view([-37.5, 30]);
end

function plot_front_view(S, ic, label)
    figure('Name', [label ' - Front View'], 'Position', [200 200 700 500]);
    hold on; grid on;
    
    % Ground line
    plot([-100 S.contact_patch(2)+100], ...
         [S.contact_patch(3) S.contact_patch(3)], 'k-', 'LineWidth', 0.5);
    
    % LCA line (projected to front view)
    lca_axis = S.lca_rear_chassis - S.lca_front_chassis;
    lca_proj = project_to_x(S.lca_front_chassis, lca_axis, S.wheel_center(1));
    plot([lca_proj(2), S.lca_upright(2)], ...
         [lca_proj(3), S.lca_upright(3)], 'b-', 'LineWidth', 2);
    
    % UCA line (projected)
    uca_axis = S.uca_rear_chassis - S.uca_front_chassis;
    uca_proj = project_to_x(S.uca_front_chassis, uca_axis, S.wheel_center(1));
    plot([uca_proj(2), S.uca_upright(2)], ...
         [uca_proj(3), S.uca_upright(3)], 'r-', 'LineWidth', 2);
    
    % FVIC
    if ~isnan(ic.fvic_y)
        plot(ic.fvic_y, ic.fvic_z, 'gp', 'MarkerSize', 12, ...
             'MarkerFaceColor', 'g');
        
        % Line from CP to FVIC (extended to centerline)
        plot([0, S.contact_patch(2), ic.fvic_y], ...
             [ic.rc_height, S.contact_patch(3), ic.fvic_z], ...
             'g--', 'LineWidth', 1);
    end
    
    % RC point
    plot(0, ic.rc_height, 'mp', 'MarkerSize', 15, 'MarkerFaceColor', 'm');
    
    % Kingpin
    plot([S.lca_upright(2), S.uca_upright(2)], ...
         [S.lca_upright(3), S.uca_upright(3)], 'k-', 'LineWidth', 2.5);
    
    % Wheel center and contact patch
    plot(S.wheel_center(2), S.wheel_center(3), 'ko', 'MarkerSize', 8, ...
         'MarkerFaceColor', 'k');
    plot(S.contact_patch(2), S.contact_patch(3), 'rs', 'MarkerSize', 8, ...
         'MarkerFaceColor', 'r');
    
    % Centerline
    plot([0, 0], [S.contact_patch(3)-50, max(S.uca_upright(3), ic.fvic_z)+50], ...
         'k:', 'LineWidth', 0.5);
    
    xlabel('Y [mm] (lateral)');
    ylabel('Z [mm] (vertical)');
    title(sprintf('%s - Front View | RC Height = %.2f mm', label, ic.rc_height));
    legend('Ground', 'LCA', 'UCA', 'FVIC', 'CP-to-FVIC line', ...
           'Roll Center', 'Kingpin', 'Location', 'best');
    axis equal;
end
