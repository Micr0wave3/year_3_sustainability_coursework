%% ========================================================================
%  RUN_MODEL.m
%  Main script for Polestar VC150SDD Insulation Analysis
%  Thermal Resistance Network - Steady State
%
%  Group 3: Fraser, Sasha, Georgio, Amelia
%  ========================================================================
clear; clc; close all;

%% ========================================================================
%  1. LOAD MATERIAL PROPERTIES
%  ========================================================================
mat = material_library();

% Build a list of available insulation materials for the menus
insul_fields = {'PU_foam', 'VIP', 'aerogel', 'EPS', 'cork', 'hemp', 'sheep_wool'};
insul_display = cell(size(insul_fields));
for i = 1:length(insul_fields)
    insul_display{i} = mat.(insul_fields{i}).name;
end

%% ========================================================================
%  2. WELCOME SCREEN
%  ========================================================================
fprintf('\n');
fprintf('  ============================================================\n');
fprintf('    POLESTAR VC150SDD INSULATION THERMAL MODEL\n');
fprintf('    Group 3: Fraser, Sasha, Georgio, Amelia\n');
fprintf('    Steady-State Thermal Resistance Network\n');
fprintf('  ============================================================\n');
fprintf('\n');

%% ========================================================================
%  3. SIMULATION MODE
%  ========================================================================
fprintf('  What would you like to simulate?\n');
fprintf('    [1] Single wall analysis\n');
fprintf('    [2] Full fridge (6 walls)\n');
fprintf('    [3] Full material comparison (tests all materials automatically)\n');
fprintf('\n');
mode = get_valid_input('  Select mode (1/2/3): ', 1, 3);

%% ========================================================================
%  4. OPERATING CONDITIONS
%  ========================================================================
fprintf('\n  --- Operating Conditions ---\n');
fprintf('  WHO PQS hot zone test: 43 deg C ambient, +2 to +8 deg C internal\n\n');

use_defaults = get_yes_no('  Use default temperatures (43 deg C ambient, 5 deg C internal)? (y/n): ');

if use_defaults
    T_ambient  = 43;
    T_internal = 5;
else
    T_ambient  = get_valid_number('  Enter ambient temperature [deg C]: ', -20, 60);
    T_internal = get_valid_number('  Enter internal target temperature [deg C]: ', -30, 20);
end

fprintf('  >> Ambient: %.1f deg C | Internal: %.1f deg C | dT = %.1f K\n', ...
    T_ambient, T_internal, T_ambient - T_internal);

%% ========================================================================
%  5. CONVECTION COEFFICIENTS
%  ========================================================================
fprintf('\n  --- Convection Coefficients ---\n');
fprintf('  Defaults: h_outer = 10 W/(m^2 K), h_inner = 5 W/(m^2 K)\n');

use_default_h = get_yes_no('  Use default convection coefficients? (y/n): ');

if use_default_h
    h_outer = 10;
    h_inner = 5;
else
    h_outer = get_valid_number('  Enter outer convection coefficient h_outer [W/(m^2 K)]: ', 1, 100);
    h_inner = get_valid_number('  Enter inner convection coefficient h_inner [W/(m^2 K)]: ', 1, 100);
end

%% ========================================================================
%  6. FRIDGE GEOMETRY
%  ========================================================================
fprintf('\n  --- Fridge Geometry ---\n');
fprintf('  Default: 150L internal volume (0.75 x 0.50 x 0.40 m)\n');

use_default_dims = get_yes_no('  Use default internal dimensions? (y/n): ');

if use_default_dims
    internal_L = 0.75;
    internal_W = 0.50;
    internal_H = 0.40;
else
    internal_L = get_valid_number('  Enter internal length [m]: ', 0.1, 3);
    internal_W = get_valid_number('  Enter internal width [m]: ', 0.1, 3);
    internal_H = get_valid_number('  Enter internal height [m]: ', 0.1, 3);
end

vol_L = internal_L * internal_W * internal_H * 1000;
fprintf('  >> Internal volume: %.1f L\n', vol_L);

%% ========================================================================
%  7. STRUCTURAL LAYERS
%  ========================================================================
fprintf('\n  --- Structural Layers ---\n');
fprintf('  Default: 0.8mm galvanised steel outer, 0.5mm aluminium inner\n');

use_default_struct = get_yes_no('  Use default structural layers? (y/n): ');

if use_default_struct
    outer_mat   = mat.steel;
    outer_thick = 0.8e-3;
    inner_mat   = mat.aluminium;
    inner_thick = 0.5e-3;
else
    fprintf('\n  Select OUTER casing material:\n');
    fprintf('    [1] Galvanised Steel\n');
    fprintf('    [2] Stainless Steel\n');
    fprintf('    [3] Aluminium\n');
    outer_choice = get_valid_input('  Select (1/2/3): ', 1, 3);
    switch outer_choice
        case 1; outer_mat = mat.steel;
        case 2; outer_mat = mat.stainless;
        case 3; outer_mat = mat.aluminium;
    end
    outer_thick = get_valid_number('  Enter outer layer thickness [mm]: ', 0.1, 10) / 1000;

    fprintf('\n  Select INNER liner material:\n');
    fprintf('    [1] Aluminium\n');
    fprintf('    [2] Stainless Steel\n');
    fprintf('    [3] Galvanised Steel\n');
    inner_choice = get_valid_input('  Select (1/2/3): ', 1, 3);
    switch inner_choice
        case 1; inner_mat = mat.aluminium;
        case 2; inner_mat = mat.stainless;
        case 3; inner_mat = mat.steel;
    end
    inner_thick = get_valid_number('  Enter inner layer thickness [mm]: ', 0.1, 10) / 1000;
end

%% ========================================================================
%  8. BRANCH BASED ON MODE
%  ========================================================================

if mode == 3
    %% ====================================================================
    %  MODE 3: FULL MATERIAL COMPARISON
    %  ====================================================================
    fprintf('\n  --- Insulation Setup for Comparison ---\n');
    insul_thick = get_valid_number('  Enter insulation thickness for ALL materials [mm]: ', 5, 200) / 1000;

    fprintf('\n  Running comparison across all %d materials at %.0f mm...\n', ...
        length(insul_fields), insul_thick*1000);

    % Storage for comparison
    comp_labels = {};
    comp_Q      = [];
    comp_U      = [];
    comp_status = {};

    for i = 1:length(insul_fields)
        fridge.internal_length = internal_L;
        fridge.internal_width  = internal_W;
        fridge.internal_height = internal_H;
        fridge.outer_material  = outer_mat;
        fridge.outer_thick     = outer_thick;
        fridge.insul1_material = mat.(insul_fields{i});
        fridge.insul1_thick    = insul_thick;
        fridge.inner_material  = inner_mat;
        fridge.inner_thick     = inner_thick;
        fridge.h_outer         = h_outer;
        fridge.h_inner         = h_inner;

        res = simulate_fridge(fridge, T_ambient, T_internal);

        comp_labels{end+1} = mat.(insul_fields{i}).name; %#ok<SAGROW>
        comp_Q(end+1)      = res.Q_total; %#ok<SAGROW>
        comp_U(end+1)      = res.U_effective; %#ok<SAGROW>

        if res.compressor.sufficient
            comp_status{end+1} = sprintf('PASS (%.1f%% margin)', res.compressor.margin_pct); %#ok<SAGROW>
        else
            comp_status{end+1} = sprintf('FAIL (%.1f%% over)', res.compressor.margin_pct); %#ok<SAGROW>
        end

        display_results(res, sprintf('Full Fridge: %s (%.0fmm)', ...
            mat.(insul_fields{i}).name, insul_thick*1000));
    end

    % Print summary table
    fprintf('\n');
    fprintf('  ================================================================\n');
    fprintf('  COMPARISON SUMMARY - All materials at %.0f mm\n', insul_thick*1000);
    fprintf('  Ambient: %.0f deg C | Internal: %.0f deg C | BD35K capacity: 64 W\n', T_ambient, T_internal);
    fprintf('  ================================================================\n');
    fprintf('  %-30s  %8s  %10s  %s\n', 'Material', 'Q [W]', 'U [W/m2K]', 'Compressor');
    fprintf('  %-30s  %8s  %10s  %s\n', '--------', '-----', '---------', '----------');
    for i = 1:length(comp_labels)
        fprintf('  %-30s  %8.2f  %10.4f  %s\n', ...
            comp_labels{i}, comp_Q(i), comp_U(i), comp_status{i});
    end
    fprintf('\n');

    % Bar charts
    plot_comparison(comp_labels, comp_Q, comp_U, insul_thick, T_ambient);

else
    %% ====================================================================
    %  MODE 1 or 2: SINGLE WALL / FULL FRIDGE
    %  ====================================================================

    % --- Insulation layer count ---
    fprintf('\n  --- Insulation Configuration ---\n');
    fprintf('    [1] Single insulation layer\n');
    fprintf('    [2] Two insulation layers (sandwich)\n');
    num_layers = get_valid_input('  How many insulation layers? (1/2): ', 1, 2);

    % --- Layer 1 ---
    fprintf('\n  --- Insulation Layer 1 ---\n');
    insul1_mat   = select_insulation(insul_fields, insul_display, mat, 1);
    insul1_thick = get_valid_number('  Enter Layer 1 thickness [mm]: ', 1, 200) / 1000;

    % --- Layer 2 (if selected) ---
    if num_layers == 2
        fprintf('\n  --- Insulation Layer 2 ---\n');
        insul2_mat   = select_insulation(insul_fields, insul_display, mat, 2);
        insul2_thick = get_valid_number('  Enter Layer 2 thickness [mm]: ', 1, 200) / 1000;
    end

    % --- Build and run ---
    if mode == 1
        % SINGLE WALL
        fprintf('\n  --- Single Wall Dimensions ---\n');
        fprintf('  (This is one face of the fridge)\n');
        wall_w = get_valid_number('  Enter wall width [m]: ', 0.05, 3);
        wall_h = get_valid_number('  Enter wall height [m]: ', 0.05, 3);

        wall.width          = wall_w;
        wall.height         = wall_h;
        wall.outer_material = outer_mat;
        wall.outer_thick    = outer_thick;
        wall.insul1_material= insul1_mat;
        wall.insul1_thick   = insul1_thick;
        wall.inner_material = inner_mat;
        wall.inner_thick    = inner_thick;
        wall.h_outer        = h_outer;
        wall.h_inner        = h_inner;

        if num_layers == 2
            wall.insul2_material = insul2_mat;
            wall.insul2_thick    = insul2_thick;
        end

        res = simulate_single_wall(wall, T_ambient, T_internal);

        label = sprintf('Single Wall: %s (%.0fmm)', insul1_mat.name, insul1_thick*1000);
        if num_layers == 2
            label = sprintf('Single Wall: %s (%.0fmm) + %s (%.0fmm)', ...
                insul1_mat.name, insul1_thick*1000, insul2_mat.name, insul2_thick*1000);
        end
        display_results(res, label);

        % Plot temperature profile
        plot_temperature_profile(res, label);

    else
        % FULL FRIDGE (mode == 2)
        fridge.internal_length = internal_L;
        fridge.internal_width  = internal_W;
        fridge.internal_height = internal_H;
        fridge.outer_material  = outer_mat;
        fridge.outer_thick     = outer_thick;
        fridge.insul1_material = insul1_mat;
        fridge.insul1_thick    = insul1_thick;
        fridge.inner_material  = inner_mat;
        fridge.inner_thick     = inner_thick;
        fridge.h_outer         = h_outer;
        fridge.h_inner         = h_inner;

        if num_layers == 2
            fridge.insul2_material = insul2_mat;
            fridge.insul2_thick    = insul2_thick;
        end

        res = simulate_fridge(fridge, T_ambient, T_internal);

        label = sprintf('Full Fridge: %s (%.0fmm)', insul1_mat.name, insul1_thick*1000);
        if num_layers == 2
            label = sprintf('Full Fridge: %s (%.0fmm) + %s (%.0fmm)', ...
                insul1_mat.name, insul1_thick*1000, insul2_mat.name, insul2_thick*1000);
        end
        display_results(res, label);
    end
end

%% ========================================================================
%  RUN AGAIN?
%  ========================================================================
fprintf('\n');
run_again = get_yes_no('  Run another simulation? (y/n): ');
if run_again
    run('run_model.m');
end

fprintf('\n  === Simulation Complete ===\n\n');


%% ========================================================================
%  LOCAL HELPER FUNCTIONS
%  ========================================================================

function choice = get_valid_input(prompt, min_val, max_val)
% GET_VALID_INPUT Repeatedly prompts until user enters an integer in range.
    while true
        raw = input(prompt);
        if isnumeric(raw) && isscalar(raw) && raw >= min_val && raw <= max_val && raw == floor(raw)
            choice = raw;
            return;
        end
        fprintf('  !! Please enter a whole number between %d and %d.\n', min_val, max_val);
    end
end

function val = get_valid_number(prompt, min_val, max_val)
% GET_VALID_NUMBER Repeatedly prompts until user enters a number in range.
    while true
        raw = input(prompt);
        if isnumeric(raw) && isscalar(raw) && raw >= min_val && raw <= max_val
            val = raw;
            return;
        end
        fprintf('  !! Please enter a number between %.1f and %.1f.\n', min_val, max_val);
    end
end

function yes = get_yes_no(prompt)
% GET_YES_NO Repeatedly prompts until user enters 'y' or 'n'.
    while true
        raw = input(prompt, 's');
        raw = lower(strtrim(raw));
        if strcmp(raw, 'y') || strcmp(raw, 'yes')
            yes = true;
            return;
        elseif strcmp(raw, 'n') || strcmp(raw, 'no')
            yes = false;
            return;
        end
        fprintf('  !! Please enter y or n.\n');
    end
end

function selected = select_insulation(fields, display_names, mat, layer_num)
% SELECT_INSULATION Displays a numbered menu of insulation materials and
% returns the selected material struct.
    fprintf('  Available insulation materials for Layer %d:\n', layer_num);
    for i = 1:length(fields)
        m = mat.(fields{i});
        fprintf('    [%d] %-30s  (k = %.3f W/(m K))\n', i, m.name, m.k);
    end
    fprintf('\n');
    idx = get_valid_input(sprintf('  Select material for Layer %d (1-%d): ', layer_num, length(fields)), ...
        1, length(fields));
    selected = mat.(fields{idx});
    fprintf('  >> Selected: %s\n', selected.name);
end

function plot_temperature_profile(res, label)
% PLOT_TEMPERATURE_PROFILE Creates a plot of temperature at each interface.
    valid = ~strcmp(res.interface_labels, '(No Layer 2)');
    T_valid = res.T_profile(valid);
    labels_valid = res.interface_labels(valid);

    figure('Name', 'Temperature Profile', 'Position', [100 100 800 450]);
    plot(1:length(T_valid), T_valid, '-o', 'LineWidth', 2, 'MarkerSize', 8, ...
        'MarkerFaceColor', [0.2 0.5 0.8], 'Color', [0.2 0.5 0.8]);

    % Shade the vaccine safe zone
    hold on;
    yline(2, 'b--', '+2 deg C (min safe)', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
    yline(8, 'r--', '+8 deg C (max safe)', 'LineWidth', 1, 'LabelHorizontalAlignment', 'left');
    patch([0.5 length(T_valid)+0.5 length(T_valid)+0.5 0.5], [2 2 8 8], ...
        'g', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    hold off;

    set(gca, 'XTick', 1:length(T_valid), 'XTickLabel', labels_valid, ...
        'XTickLabelRotation', 25, 'FontSize', 9);
    ylabel('Temperature [deg C]');
    title(label);
    grid on;

    saveas(gcf, 'temperature_profile.png');
    fprintf('\n  Figure saved: temperature_profile.png\n');
end

function plot_comparison(labels, Q_totals, U_values, insul_thick, T_ambient)
% PLOT_COMPARISON Creates bar charts comparing all materials.
    bar_colors = [0.2 0.6 0.8;
                  0.1 0.3 0.7;
                  0.4 0.2 0.7;
                  0.8 0.5 0.2;
                  0.6 0.4 0.2;
                  0.3 0.7 0.3;
                  0.8 0.8 0.3];

    % Extend colours if more materials than colours
    while size(bar_colors,1) < length(labels)
        bar_colors = [bar_colors; rand(1,3)]; %#ok<AGROW>
    end

    % Heat ingress chart
    figure('Name', 'Material Comparison - Heat Ingress', 'Position', [100 100 900 500]);
    b = bar(Q_totals, 'FaceColor', 'flat');
    for k = 1:length(Q_totals)
        b.CData(k,:) = bar_colors(k,:);
    end
    hold on;
    yline(64, 'r--', 'LineWidth', 2, 'Label', 'BD35K Capacity (64 W)', ...
        'LabelHorizontalAlignment', 'left', 'FontSize', 10);
    hold off;
    set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('Total Heat Ingress Q_{total} [W]');
    title(sprintf('Full Fridge Heat Ingress by Material (%.0f mm, T_{amb}=%.0f deg C)', ...
        insul_thick*1000, T_ambient));
    grid on;
    saveas(gcf, 'material_comparison.png');
    fprintf('  Figure saved: material_comparison.png\n');

    % U-value chart
    figure('Name', 'Material Comparison - U-value', 'Position', [100 650 900 400]);
    b2 = bar(U_values, 'FaceColor', 'flat');
    for k = 1:length(U_values)
        b2.CData(k,:) = bar_colors(k,:);
    end
    set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 30, 'FontSize', 9);
    ylabel('Effective U-value [W/(m^2 K)]');
    title('Effective U-value by Insulation Material');
    grid on;
    saveas(gcf, 'u_value_comparison.png');
    fprintf('  Figure saved: u_value_comparison.png\n');
end
