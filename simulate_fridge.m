function results = simulate_fridge(fridge, T_ambient, T_internal)
% SIMULATE_FRIDGE Performs steady-state thermal analysis on a complete
% 6-wall refrigerator (chest-type) using a thermal resistance network.
%
% All six walls share the same construction (material layers and
% thicknesses) but have dimensions derived from the internal cavity size.
%
% INPUTS:
%   fridge - Struct with fields:
%     .internal_length  - Internal cavity length [m]
%     .internal_width   - Internal cavity width [m]
%     .internal_height  - Internal cavity height [m]
%     .outer_material   - Outer metal struct (from material_library)
%     .outer_thick      - Outer metal thickness [m]
%     .insul1_material  - Insulation layer 1 struct
%     .insul1_thick     - Insulation layer 1 thickness [m]
%     .insul2_material  - (OPTIONAL) Insulation layer 2 struct
%     .insul2_thick     - (OPTIONAL) Insulation layer 2 thickness [m]
%     .inner_material   - Inner metal struct
%     .inner_thick      - Inner metal thickness [m]
%     .h_outer          - External convection coefficient [W/(m^2*K)]
%     .h_inner          - Internal convection coefficient [W/(m^2*K)]
%   T_ambient  - External ambient temperature [°C]
%   T_internal - Target internal fridge temperature [°C]
%
% OUTPUTS:
%   results - Struct containing:
%     .walls            - 6x1 struct array with per-wall results
%     .wall_names       - Cell array of wall names
%     .Q_total          - Total heat ingress into the fridge [W]
%     .R_total_parallel - Equivalent parallel resistance of all walls [K/W]
%     .U_effective      - Effective overall U-value [W/(m^2*K)]
%     .A_total          - Total internal surface area [m^2]
%     .internal_volume  - Internal volume [m^3] / [litres]
%     .external_dims    - External dimensions [m]
%     .compressor_check - Whether a constant cooling power can maintain temp

    % --- Internal dimensions ---
    L = fridge.internal_length;
    W = fridge.internal_width;
    H = fridge.internal_height;

    % --- Define the 6 wall faces (width x height for each) ---
    % For a chest-type fridge:
    wall_dims = struct( ...
        'name',   {'Front',  'Back',   'Left Side', 'Right Side', 'Bottom', 'Top (Lid)'}, ...
        'width',  { L,        L,        W,            W,            L,        L          }, ...
        'height', { H,        H,        H,            H,            W,        W          });

    wall_names = {wall_dims.name};

    % --- Calculate total insulation thickness for external dimensions ---
    total_wall_thick = fridge.outer_thick + fridge.insul1_thick + fridge.inner_thick;
    if isfield(fridge, 'insul2_thick') && ~isempty(fridge.insul2_thick)
        total_wall_thick = total_wall_thick + fridge.insul2_thick;
    end

    ext_L = L + 2 * total_wall_thick;
    ext_W = W + 2 * total_wall_thick;
    ext_H = H + total_wall_thick;   % Chest fridge: lid on top only, bottom has wall too
    % Actually both top and bottom have a wall, so:
    ext_H = H + 2 * total_wall_thick;

    % --- Simulate each wall ---
    Q_total = 0;
    R_inv_sum = 0;      % Sum of 1/R for parallel resistance calculation
    A_total = 0;

    for i = 1:6
        % Build wall struct for this face
        w.width          = wall_dims(i).width;
        w.height         = wall_dims(i).height;
        w.outer_material = fridge.outer_material;
        w.outer_thick    = fridge.outer_thick;
        w.insul1_material= fridge.insul1_material;
        w.insul1_thick   = fridge.insul1_thick;
        w.inner_material = fridge.inner_material;
        w.inner_thick    = fridge.inner_thick;
        w.h_outer        = fridge.h_outer;
        w.h_inner        = fridge.h_inner;

        % Optional second insulation layer
        if isfield(fridge, 'insul2_material') && isfield(fridge, 'insul2_thick') ...
                && ~isempty(fridge.insul2_material) && fridge.insul2_thick > 0
            w.insul2_material = fridge.insul2_material;
            w.insul2_thick    = fridge.insul2_thick;
        end

        % Run single wall simulation
        wall_result = simulate_single_wall(w, T_ambient, T_internal);

        % Store results
        walls(i) = wall_result; %#ok<AGROW>

        % Accumulate totals
        Q_total   = Q_total + wall_result.Q_dot;
        R_inv_sum = R_inv_sum + (1 / wall_result.R_total);
        A_total   = A_total + wall_result.wall_area;
    end

    % --- Equivalent parallel resistance ---
    R_total_parallel = 1 / R_inv_sum;

    % --- Effective U-value for the whole fridge ---
    dT = T_ambient - T_internal;
    U_effective = Q_total / (A_total * dT);

    % --- Internal volume ---
    V_internal = L * W * H;    % [m^3]

    % --- Compressor check ---
    % BD35K at 2000 rpm, evaporating at -5°C: ~64 W cooling capacity (EN 12900)
    % This is a simplified constant value as requested
    Q_compressor = 64;  % [W] - from SECOP BD35K data sheet at 2000 rpm, -5°C evap
    if Q_total <= Q_compressor
        compressor_ok = true;
        margin_pct = (1 - Q_total / Q_compressor) * 100;
    else
        compressor_ok = false;
        margin_pct = (Q_total / Q_compressor - 1) * 100;
    end

    % --- Pack results ---
    results.walls              = walls;
    results.wall_names         = wall_names;
    results.Q_total            = Q_total;
    results.R_total_parallel   = R_total_parallel;
    results.U_effective        = U_effective;
    results.A_total            = A_total;
    results.internal_volume_m3 = V_internal;
    results.internal_volume_L  = V_internal * 1000;
    results.external_dims      = [ext_L, ext_W, ext_H];

    results.compressor.Q_capacity   = Q_compressor;
    results.compressor.Q_demand     = Q_total;
    results.compressor.sufficient   = compressor_ok;
    results.compressor.margin_pct   = margin_pct;

end
