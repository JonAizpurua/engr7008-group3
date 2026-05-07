%% ========================================================================
%  PLOT_SUSPENSION_COMPARISON.m
%  ========================================================================
%  Plots 3D overlay of 2025 and 2026 suspension geometry for visual
%  comparison. Front and rear in separate figures.
%
%  Input:  Cinematica_Suspension.xlsx      (sheets: 'Front 2025', 'Rear 2025')
%          Cinematica_Suspension_2026.xlsx  (sheets: 'Front 2026', 'Rear 2026')
%
%  Oxford Brookes University - ENGR7008 Assignment 2
%  ========================================================================
clear; clc; close all;

%% ======================= READ ALL DATA ==================================
[F25, F25_names] = read_hp('Cinematica_Suspension.xlsx',      'Front 2025');
[F26, F26_names] = read_hp('Cinematica_Suspension_2026.xlsx', 'Front 2026');
[R25, R25_names] = read_hp('Cinematica_Suspension.xlsx',      'Rear 2025');
[R26, R26_names] = read_hp('Cinematica_Suspension_2026.xlsx', 'Rear 2026');

%% ======================= FRONT COMPARISON ===============================
figure('Name', 'Front Suspension: 2025 vs 2026', ...
       'Position', [50 50 1100 750], 'Color', 'w');

plot_one_suspension(F25, F25_names, 'front', [0.0 0.4 0.8], '-',  2.0);  % Blue  = 2025
plot_one_suspension(F26, F26_names, 'front', [0.9 0.2 0.1], '--', 1.5);  % Red   = 2026

title('Front Suspension — 2025 (blue) vs 2026 (red)', 'FontSize', 14);
format_axes();
add_legend();

%% ======================= REAR COMPARISON ================================
figure('Name', 'Rear Suspension: 2025 vs 2026', ...
       'Position', [100 80 1100 750], 'Color', 'w');

plot_one_suspension(R25, R25_names, 'rear', [0.0 0.4 0.8], '-',  2.0);
plot_one_suspension(R26, R26_names, 'rear', [0.9 0.2 0.1], '--', 1.5);

title('Rear Suspension — 2025 (blue) vs 2026 (red)', 'FontSize', 14);
format_axes();
add_legend();

%% ========================================================================
%                          FUNCTIONS
%% ========================================================================

function [hp, names] = read_hp(file, sheet)
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
end

function idx = find_idx(names, name)
    idx = find(strcmp(names, name), 1);
    if isempty(idx), error('Point "%s" not found.', name); end
end

function p = pt(hp, names, name)
    % Returns left-side point [X, Y, Z]
    p = hp(find_idx(names, name), 1:3);
end

function plot_one_suspension(hp, names, type, col, ls, lw)
    hold on;
    
    % --- Extract key points (left side) ---
    lca_f_ch = pt(hp, names, 'Chassis LCA Mount Front');
    lca_r_ch = pt(hp, names, 'Chassis LCA Mount Rear');
    uca_f_ch = pt(hp, names, 'Chassis UCA Mount Front');
    uca_r_ch = pt(hp, names, 'Chassis UCA Mount Rear');
    lca_upr  = pt(hp, names, 'Upright Lower Ball Mount');
    uca_upr  = pt(hp, names, 'Upright Upper Ball Mount');
    wc       = pt(hp, names, 'Wheel Center');
    cp       = pt(hp, names, 'Wheel Contact Patch');
    push_out = pt(hp, names, 'PushPullrod Outer Mount');
    rk_pivot = pt(hp, names, 'Rocker Chassis Mount');
    rk_push  = pt(hp, names, 'Rocker PushPullrod Mount');
    rk_damp  = pt(hp, names, 'Rocker Damper Mount');
    damp_ch  = pt(hp, names, 'Chassis Damper Mount');
    
    if strcmp(type, 'front')
        tr_ch  = pt(hp, names, 'Centerlink Tierod Mount');
    else
        tr_ch  = pt(hp, names, 'Chassis Track Rod Mount');
    end
    tr_upr = pt(hp, names, 'Outer Tierod Mount');
    
    % --- LCA (two arms: front-chassis -> upright, rear-chassis -> upright) ---
    draw_link(lca_f_ch, lca_upr, col, ls, lw);
    draw_link(lca_r_ch, lca_upr, col, ls, lw);
    
    % LCA chassis axis (dashed thin)
    draw_link(lca_f_ch, lca_r_ch, col, ':', lw*0.5);
    
    % --- UCA ---
    draw_link(uca_f_ch, uca_upr, col, ls, lw);
    draw_link(uca_r_ch, uca_upr, col, ls, lw);
    
    % UCA chassis axis
    draw_link(uca_f_ch, uca_r_ch, col, ':', lw*0.5);
    
    % --- Tie rod ---
    draw_link(tr_ch, tr_upr, col, ls, lw*0.8);
    
    % --- Kingpin axis (upright: lower ball -> upper ball) ---
    draw_link(lca_upr, uca_upr, col*0.6, ls, lw*1.3);
    
    % --- Pushrod ---
    draw_link(push_out, rk_push, col, ls, lw*0.7);
    
    % --- Rocker triangle ---
    draw_link(rk_pivot, rk_push, col*0.8, ls, lw*0.6);
    draw_link(rk_pivot, rk_damp, col*0.8, ls, lw*0.6);
    draw_link(rk_push,  rk_damp, col*0.8, ls, lw*0.6);
    
    % --- Damper ---
    draw_link(rk_damp, damp_ch, col, ls, lw*0.7);
    
    % --- Wheel center to contact patch (vertical reference) ---
    draw_link(wc, cp, col, ':', lw*0.4);
    
    % --- Ball joints (filled circles) ---
    chassis_pts = [lca_f_ch; lca_r_ch; uca_f_ch; uca_r_ch; tr_ch; damp_ch];
    upright_pts = [lca_upr; uca_upr; tr_upr];
    rocker_pts  = [rk_pivot; rk_push; rk_damp];
    
    plot3(chassis_pts(:,1), chassis_pts(:,2), chassis_pts(:,3), ...
          'o', 'Color', col, 'MarkerSize', 5, ...
          'MarkerFaceColor', col, 'HandleVisibility', 'off');
    
    plot3(upright_pts(:,1), upright_pts(:,2), upright_pts(:,3), ...
          's', 'Color', col, 'MarkerSize', 7, ...
          'MarkerFaceColor', col, 'HandleVisibility', 'off');
    
    plot3(rocker_pts(:,1), rocker_pts(:,2), rocker_pts(:,3), ...
          'd', 'Color', col, 'MarkerSize', 5, ...
          'MarkerFaceColor', col, 'HandleVisibility', 'off');
    
    % --- Wheel center (big marker) ---
    plot3(wc(1), wc(2), wc(3), 'o', 'Color', col, ...
          'MarkerSize', 10, 'MarkerFaceColor', col, ...
          'HandleVisibility', 'off');
    
    % --- Contact patch (cross on ground) ---
    plot3(cp(1), cp(2), cp(3), 'x', 'Color', col, ...
          'MarkerSize', 12, 'LineWidth', 2, ...
          'HandleVisibility', 'off');
    
    % --- Simple wheel circle (in YZ plane at wheel center X) ---
    loaded_r = wc(3) - cp(3);
    theta = linspace(0, 2*pi, 60);
    wy = wc(2) + loaded_r * 0.15 * cos(theta);  % Slight ellipse for 3D effect
    wz = wc(3) + loaded_r * sin(theta);
    wx = wc(1) * ones(size(theta));
    plot3(wx, wy, wz, ls, 'Color', [col, 0.5], 'LineWidth', lw*0.8, ...
          'HandleVisibility', 'off');
end

function draw_link(p1, p2, col, ls, lw)
    plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], ...
          ls, 'Color', col, 'LineWidth', lw, 'HandleVisibility', 'off');
end

function format_axes()
    xlabel('X [mm] (+ forward)', 'FontSize', 16);
    ylabel('Y [mm] (+ left)',    'FontSize', 16);
    zlabel('Z [mm] (+ up)',      'FontSize', 16);
    grid on; axis equal;
    view([-42, 22]);
    set(gca, 'FontSize', 25);
    
    % Light gray ground plane at approximate ground level
    ax = gca;
    xl = ax.XLim; yl = ax.YLim;
    ground_z = -30;
    patch([xl(1) xl(2) xl(2) xl(1)], ...
          [yl(1) yl(1) yl(2) yl(2)], ...
          [ground_z ground_z ground_z ground_z], ...
          [0.9 0.9 0.9], 'FaceAlpha', 0.15, 'EdgeColor', 'none', ...
          'HandleVisibility', 'off');
end

function add_legend()
    % Invisible dummy lines for legend
    h1 = plot3(NaN, NaN, NaN, '-',  'Color', [0.0 0.4 0.8], 'LineWidth', 2);
    h2 = plot3(NaN, NaN, NaN, '--', 'Color', [0.9 0.2 0.1], 'LineWidth', 1.5);
    legend([h1, h2], {'2025', '2026'}, 'FontSize', 12, 'Location', 'northeast');
end
