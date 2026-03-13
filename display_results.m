function display_results(results, wall_name)
% DISPLAY_RESULTS Prints a formatted summary of single wall or fridge results.
%
% INPUTS:
%   results   - Output struct from simulate_single_wall or simulate_fridge
%   wall_name - (Optional) Label for the wall/configuration being displayed

    if nargin < 2
        wall_name = 'Wall';
    end

    fprintf('\n');
    fprintf('============================================================\n');
    fprintf('  %s - Steady-State Results\n', wall_name);
    fprintf('============================================================\n');

    % --- Check if this is a single wall or full fridge result ---
    if isfield(results, 'walls')
        % FULL FRIDGE RESULTS
        fprintf('  Internal Volume:     %.1f L  (%.4f m^3)\n', ...
            results.internal_volume_L, results.internal_volume_m3);
        fprintf('  External Dimensions: %.3f x %.3f x %.3f m\n', ...
            results.external_dims(1), results.external_dims(2), results.external_dims(3));
        fprintf('  Total Surface Area:  %.4f m^2\n', results.A_total);
        fprintf('------------------------------------------------------------\n');

        % Per-wall breakdown
        fprintf('  %-14s  %10s  %10s  %10s\n', 'Wall', 'Area [m^2]', 'R [K/W]', 'Q [W]');
        fprintf('  %-14s  %10s  %10s  %10s\n', '----', '---------', '------', '-----');
        for i = 1:length(results.walls)
            fprintf('  %-14s  %10.4f  %10.4f  %10.3f\n', ...
                results.wall_names{i}, ...
                results.walls(i).wall_area, ...
                results.walls(i).R_total, ...
                results.walls(i).Q_dot);
        end

        fprintf('------------------------------------------------------------\n');
        fprintf('  TOTAL Heat Ingress:       %8.3f W\n', results.Q_total);
        fprintf('  Parallel Resistance:      %8.4f K/W\n', results.R_total_parallel);
        fprintf('  Effective U-value:        %8.4f W/(m^2*K)\n', results.U_effective);
        fprintf('------------------------------------------------------------\n');

        % Compressor check
        fprintf('  COMPRESSOR CHECK (BD35K @ 2000 rpm, -5°C evap)\n');
        fprintf('    Cooling Capacity:       %8.1f W\n', results.compressor.Q_capacity);
        fprintf('    Heat Demand:            %8.1f W\n', results.compressor.Q_demand);
        if results.compressor.sufficient
            fprintf('    Status:                 PASS (%.1f%% margin)\n', results.compressor.margin_pct);
        else
            fprintf('    Status:                 FAIL (%.1f%% over capacity)\n', results.compressor.margin_pct);
        end

    else
        % SINGLE WALL RESULTS
        fprintf('  Wall Area:           %.4f m^2\n', results.wall_area);
        fprintf('  Temperature Diff:    %.1f K\n', results.dT);
        fprintf('------------------------------------------------------------\n');

        % Resistance breakdown
        Rb = results.R_breakdown;
        fprintf('  Resistance Breakdown:\n');
        fprintf('    Outer convection:  %10.4f K/W\n', Rb.conv_outer);
        fprintf('    Outer metal:       %10.6f K/W\n', Rb.metal_outer);
        fprintf('    Insulation 1:      %10.4f K/W\n', Rb.insul1);
        if Rb.insul2 > 0
            fprintf('    Insulation 2:      %10.4f K/W\n', Rb.insul2);
        end
        fprintf('    Inner metal:       %10.6f K/W\n', Rb.metal_inner);
        fprintf('    Inner convection:  %10.4f K/W\n', Rb.conv_inner);
        fprintf('    TOTAL:             %10.4f K/W\n', results.R_total);

        fprintf('------------------------------------------------------------\n');
        fprintf('  Heat Flow (Q):       %8.3f W\n', results.Q_dot);
        fprintf('  Heat Flux (q):       %8.3f W/m^2\n', results.q_dot);
        fprintf('  U-value:             %8.4f W/(m^2*K)\n', results.U_value);

        % Temperature profile
        fprintf('------------------------------------------------------------\n');
        fprintf('  Temperature Profile Through Wall:\n');
        for j = 1:length(results.T_profile)
            if ~strcmp(results.interface_labels{j}, '(No Layer 2)')
                fprintf('    %-35s  %6.2f °C\n', results.interface_labels{j}, results.T_profile(j));
            end
        end
    end

    fprintf('============================================================\n\n');

end
