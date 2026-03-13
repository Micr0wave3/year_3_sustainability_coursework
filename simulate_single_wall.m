function results = simulate_single_wall(wall, T_ambient, T_internal)
% SIMULATE_SINGLE_WALL Performs steady-state thermal analysis on a single
% composite refrigerator wall.
%
% INPUTS:
%   wall       - Wall struct (see wall_thermal_resistance for required fields)
%   T_ambient  - External ambient temperature [°C]
%   T_internal - Internal fridge temperature [°C]
%
% OUTPUTS:
%   results - Struct containing:
%     .R_total       - Total thermal resistance [K/W]
%     .R_breakdown   - Individual layer resistances [K/W]
%     .Q_dot         - Steady-state heat flow through wall [W]
%     .q_dot         - Heat flux [W/m^2]
%     .U_value       - Overall heat transfer coefficient [W/(m^2*K)]
%     .T_profile     - Temperature at each interface [°C]
%     .interface_labels - Labels for each interface
%     .wall_area     - Wall area [m^2]

    % --- Validate inputs ---
    if T_ambient <= T_internal
        warning('Ambient temperature (%.1f°C) is not higher than internal (%.1f°C). Heat flow will be into the fridge only if T_ambient > T_internal.', T_ambient, T_internal);
    end

    % --- Calculate thermal resistance ---
    [R_total, R_breakdown] = wall_thermal_resistance(wall);

    % --- Temperature difference ---
    dT = T_ambient - T_internal;    % [K] (same magnitude in °C and K)

    % --- Wall area ---
    A = wall.width * wall.height;

    % --- Steady-state heat flow ---
    Q_dot = dT / R_total;           % [W]
    q_dot = Q_dot / A;              % [W/m^2]

    % --- Overall U-value ---
    U_value = 1 / (R_total * A);    % [W/(m^2*K)]

    % --- Temperature profile at each interface ---
    % Moving from ambient to internal: T drops by Q_dot * R_layer
    T = zeros(1, 7);
    T(1) = T_ambient;                                       % Ambient air
    T(2) = T(1) - Q_dot * R_breakdown.conv_outer;           % Outer surface
    T(3) = T(2) - Q_dot * R_breakdown.metal_outer;          % After outer metal
    T(4) = T(3) - Q_dot * R_breakdown.insul1;               % After insulation 1
    T(5) = T(4) - Q_dot * R_breakdown.insul2;               % After insulation 2
    T(6) = T(5) - Q_dot * R_breakdown.metal_inner;          % Inner surface
    T(7) = T(6) - Q_dot * R_breakdown.conv_inner;           % Internal air

    labels = {'Ambient Air', 'Outer Surface', ...
              'Outer Metal / Insul-1 Interface', ...
              'Insul-1 / Insul-2 Interface', ...
              'Insul-2 / Inner Metal Interface', ...
              'Inner Surface', 'Internal Air'};

    % If no second insulation layer, adjust labels
    if R_breakdown.insul2 == 0
        labels{4} = 'Insul-1 / Inner Metal Interface';
        labels{5} = '(No Layer 2)';
    end

    % --- Pack results ---
    results.R_total         = R_total;
    results.R_breakdown     = R_breakdown;
    results.Q_dot           = Q_dot;
    results.q_dot           = q_dot;
    results.U_value         = U_value;
    results.T_profile       = T;
    results.interface_labels = labels;
    results.wall_area       = A;
    results.dT              = dT;

end
