function [R_total, R_breakdown] = wall_thermal_resistance(wall)
% WALL_THERMAL_RESISTANCE Calculates the total thermal resistance of a
% composite refrigerator wall using a series resistance network.
%
% The wall is modelled as:
%   [Ambient] --conv_outer-- [Steel] --insul_1-- (insul_2) --[Inner metal]-- conv_inner-- [Internal]
%
% INPUTS:
%   wall - struct with the following fields:
%     .width          - Wall width [m]
%     .height         - Wall height [m]
%     .outer_material - Struct with .k, .name fields (from material_library)
%     .outer_thick    - Outer metal thickness [m]
%     .insul1_material- Struct with .k, .name fields
%     .insul1_thick   - Insulation layer 1 thickness [m]
%     .insul2_material- (OPTIONAL) Struct with .k, .name fields
%     .insul2_thick   - (OPTIONAL) Insulation layer 2 thickness [m]
%     .inner_material - Struct with .k, .name fields
%     .inner_thick    - Inner metal thickness [m]
%     .h_outer        - External convection coefficient [W/(m^2*K)]
%     .h_inner        - Internal convection coefficient [W/(m^2*K)]
%
% OUTPUTS:
%   R_total     - Total thermal resistance [K/W]
%   R_breakdown - Struct with individual resistances [K/W]:
%                 .conv_outer, .metal_outer, .insul1, .insul2,
%                 .metal_inner, .conv_inner
%
% THERMAL RESISTANCE FORMULAE:
%   Convection:  R = 1 / (h * A)
%   Conduction:  R = L / (k * A)

    % --- Calculate wall area ---
    A = wall.width * wall.height;   % [m^2]

    % --- Convection resistances ---
    R_breakdown.conv_outer  = 1 / (wall.h_outer * A);
    R_breakdown.conv_inner  = 1 / (wall.h_inner * A);

    % --- Conduction through outer metal ---
    R_breakdown.metal_outer = wall.outer_thick / (wall.outer_material.k * A);

    % --- Conduction through insulation layer 1 ---
    R_breakdown.insul1      = wall.insul1_thick / (wall.insul1_material.k * A);

    % --- Conduction through insulation layer 2 (if present) ---
    if isfield(wall, 'insul2_material') && isfield(wall, 'insul2_thick') ...
            && ~isempty(wall.insul2_material) && wall.insul2_thick > 0
        R_breakdown.insul2  = wall.insul2_thick / (wall.insul2_material.k * A);
    else
        R_breakdown.insul2  = 0;
    end

    % --- Conduction through inner metal ---
    R_breakdown.metal_inner = wall.inner_thick / (wall.inner_material.k * A);

    % --- Total resistance (series network) ---
    R_total = R_breakdown.conv_outer  + ...
              R_breakdown.metal_outer + ...
              R_breakdown.insul1      + ...
              R_breakdown.insul2      + ...
              R_breakdown.metal_inner + ...
              R_breakdown.conv_inner;

end
