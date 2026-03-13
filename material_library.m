function materials = material_library()
% MATERIAL_LIBRARY Returns a struct containing thermal properties of
% insulation and structural materials for the Polestar fridge model.
%
% Each material has:
%   k       - Thermal conductivity [W/(m*K)]
%   rho     - Density [kg/m^3]
%   cp      - Specific heat capacity [J/(kg*K)]
%   name    - Display name
%   type    - 'insulation' or 'structural'
%
% Usage:
%   materials = material_library();
%   pu = materials.PU_foam;
%   fprintf('PU foam conductivity: %.4f W/(m*K)\n', pu.k);

    %% ====================================================================
    %  INSULATION MATERIALS
    %  ====================================================================

    % --- Baseline: Polyurethane (PU) Foam (cyclopentane-blown) ---
    materials.PU_foam.k       = 0.024;      % W/(m*K)
    materials.PU_foam.rho     = 35;         % kg/m^3
    materials.PU_foam.cp      = 1400;       % J/(kg*K)
    materials.PU_foam.name    = 'PU Foam (Baseline)';
    materials.PU_foam.type    = 'insulation';

    % --- Vacuum Insulation Panels (VIPs) ---
    materials.VIP.k           = 0.005;      % W/(m*K) - fumed silica core
    materials.VIP.rho         = 190;        % kg/m^3
    materials.VIP.cp          = 800;        % J/(kg*K)
    materials.VIP.name        = 'Vacuum Insulation Panel (VIP)';
    materials.VIP.type        = 'insulation';

    % --- Silica Aerogel ---
    materials.aerogel.k       = 0.015;      % W/(m*K)
    materials.aerogel.rho     = 120;        % kg/m^3
    materials.aerogel.cp      = 1000;       % J/(kg*K)
    materials.aerogel.name    = 'Silica Aerogel';
    materials.aerogel.type    = 'insulation';

    % --- Expanded Polystyrene (EPS) ---
    materials.EPS.k           = 0.036;      % W/(m*K)
    materials.EPS.rho         = 25;         % kg/m^3
    materials.EPS.cp          = 1300;       % J/(kg*K)
    materials.EPS.name        = 'Expanded Polystyrene (EPS)';
    materials.EPS.type        = 'insulation';

    % --- Cork ---
    materials.cork.k          = 0.042;      % W/(m*K)
    materials.cork.rho        = 120;        % kg/m^3
    materials.cork.cp         = 1500;       % J/(kg*K)
    materials.cork.name       = 'Cork (Bio-based)';
    materials.cork.type       = 'insulation';

    % --- Hemp Fibre ---
    materials.hemp.k          = 0.040;      % W/(m*K)
    materials.hemp.rho        = 35;         % kg/m^3
    materials.hemp.cp         = 1600;       % J/(kg*K)
    materials.hemp.name       = 'Hemp Fibre (Bio-based)';
    materials.hemp.type       = 'insulation';

    % --- Sheep's Wool ---
    materials.sheep_wool.k    = 0.038;      % W/(m*K)
    materials.sheep_wool.rho  = 25;         % kg/m^3
    materials.sheep_wool.cp   = 1700;       % J/(kg*K)
    materials.sheep_wool.name = 'Sheep''s Wool (Sustainable)';
    materials.sheep_wool.type = 'insulation';

    %% ====================================================================
    %  STRUCTURAL MATERIALS
    %  ====================================================================

    % --- Galvanised Steel (outer casing) ---
    materials.steel.k         = 50;         % W/(m*K)
    materials.steel.rho       = 7850;       % kg/m^3
    materials.steel.cp        = 500;        % J/(kg*K)
    materials.steel.name      = 'Galvanised Steel';
    materials.steel.type      = 'structural';

    % --- Aluminium (inner liner) ---
    materials.aluminium.k     = 205;        % W/(m*K)
    materials.aluminium.rho   = 2700;       % kg/m^3
    materials.aluminium.cp    = 900;        % J/(kg*K)
    materials.aluminium.name  = 'Aluminium';
    materials.aluminium.type  = 'structural';

    % --- Stainless Steel (alternative inner liner) ---
    materials.stainless.k     = 16;         % W/(m*K)
    materials.stainless.rho   = 8000;       % kg/m^3
    materials.stainless.cp    = 500;        % J/(kg*K)
    materials.stainless.name  = 'Stainless Steel';
    materials.stainless.type  = 'structural';

end
