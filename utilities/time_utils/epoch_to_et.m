function [et, epoch_type] = epoch_to_et(t_epoch, varargin)
    %
    % Convert CDF_EPOCH, CDF_EPOCH16 or CDF_TT2000 to Ephemeris Time (ET).
    %
    % METHOD
    %   'Gregorian' - Convert to a Gregorian time string and use cspice_str2et()
    %
    %      This is used for CDF_EPOCH and CDF_EPOCH16. Standard epoch strings returned
    %
    % FUTURE METHODS
    %   'Julian'    - Convert to a Julain Date string and use cspice_str2et()
    %   'DeltaET'   - For TT2000 only; Convert to UTC, add cspice_deltet()
    %
    % This requires the JPL's SPICE toolkit
    %   http://naif.jpl.nasa.gov/naif/toolkit.html
    %
    % For important information (and sources) about time conversion, see
    %   cspice_time_notes.m
    %   cdf_epoch_type.m
    %

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check Inputs \\\\\\\\\\\\\\\\%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    inputs = inputParser;
    inputs.addRequired('t_epoch');
    inputs.addParamValue('kernel', '');
    
    inputs.parse(t_epoch, varargin{:});
    
    inputs = inputs.Results;
    t_epoch = inputs.t_epoch;
    kernel = inputs.kernel;
    clear inputs

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE WHICH EPOCH WAS GIVE \\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Load the kernel if one was given.
    if ~strcmp(kernel, '')
        cspice_furnsh(kernel);
    end

    % Determine CDF Epoch Type
    epoch_type = cdf_epoch_type(t_epoch(1,:));
    
    % Breakdown the given epoch time.
    switch epoch_type
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TREAT CDF_EPOCH \\\\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_EPOCH'
            % Create a Gregorian date string from the CDF EPOCH value.
            epoch_string = parse_cdf_epoch(t_epoch);
            
            % Convert the date string to ET
            et = cspice_str2et(epoch_string);
            
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TREAT CDF_EPOCH16 \\\\\\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_EPOCH16'
            % Create a Gregorian date string from the CDF EPOCH value.
            epoch_string = parse_cdf_epoch(t_epoch);
            
            % Convert the date string to ET
            et = cspice_str2et(epoch_string);
            
            
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % TREAT CDF_TIME_TT2000 \\\\\\ %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        case 'CDF_TIME_TT2000'
            % Breakdown the time in order to find the number of leap seconds
            time = breakdowntt2000(t_epoch);
            nleaps = read_leapseconds_table(time(1,1), time(2,1), time(3,1));
            
            % Convert from TT000 to UTC. Take the transpose of t_epoch because SPICE wants
            % 1xN arrays
            time_UTC = double(t_epoch)'*1e-9 - nleaps - 32.184;
            
            % Convert to ET by adding the difference between ET and UTC    
            t_deltaET = cspice_deltet(time_UTC, 'UTC');
            et = time_UTC + t_deltaET;
        otherwise
            error('t_epoch is not a recognized CDF EPOCH time type.')
    end
    
    % Unload the kernel if one was given.
    if ~strcmp(kernel, '')
        cspice_unload(kernel);
    end


end