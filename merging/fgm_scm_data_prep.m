function [t, b, fgm, scm] = fgm_scm_merge(mission, sc, date, tstart, tend, varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\ CHECK INPUTS \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Check the inputs. In none were given, fg_sc_check_inputs will
    % generate a GUI and ask for them.
    if nargin == 0
        inputs = fgm_scm_check_inputs();
    else
        inputs = fgm_scm_check_inputs(mission, sc, date, tstart, tend, varargin{:});
    end
    
    % Transfer all inputs to the workspace.
    mission = inputs.mission;
    sc = inputs.sc;
    date = inputs.date;
    tstart = inputs.tstart;
    tend = inputs.tend;
    f_min = inputs.f_min;
    f_max = inputs.f_max;
    n_min = inputs.n_min;
    n_max = inputs.n_max;
    multiplier = inputs.multiplier;
    coord_sys = inputs.coord_sys;
    ref_time = inputs.ref_time;
    fgm_data_dir = inputs.fgm_data_dir;
    scm_data_dir = inputs.scm_data_dir;
    TransfrFn_dir = inputs.TransfrFn_dir;

    %
    % The remainder of the optional arguments are used to despin and rotate spacecraft
    % data to another coordinate system, a process that is mission- and spacecraft-
    % specific. As such, the arguments to the necessary programs will be specified
    % differently for each mission. See 'fgm_scm_scs2gse.m' and 'fgm_scm_despin.m' for
    % more details.
    %

    % Optional Inputs to fgm_scm_despin and fgm_scm_scs2gse.
    switch mission
        case 'C'
            optArg1 = inputs.attitude_dir;
            optArg2 = inputs.srt_dir;
            optArg3 = char(zeros(0,1));
        case 'RBSP'
            optArg1 = inputs.date;
            optArg2 = inputs.n_sec;
            optArg3 = inputs.spice_kernel;
        otherwise
            if ~strcmp(coord_sys, 'SPIN')
                error('Mission %s does not have Despinning/Coord Transform implemented', mission)
            end
    end
    clear inputs
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% \\\\\\\\\\\\\\\\\ GET DATA \\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Create a [mission]_data_merge object for FGM
    disp('Getting FGM data...')
    fgm = get_inst_obj(mission);
    fgm.get_data('FGM', sc, date, tstart, tend, ...
                 'fgm_data_dir', fgm_data_dir, ...
                 'scm_data_dir', scm_data_dir, ...
                 'TransfrFn_dir', TransfrFn_dir);
    
    % Create a [mission]_data_merge object for SCM
    disp('Getting SCM data...')
    scm = get_inst_obj(mission);
    scm.get_data('SCM', sc, date, tstart, tend, ...
                 'fgm_data_dir', fgm_data_dir, ...
                 'scm_data_dir', scm_data_dir, ...
                 'TransfrFn_dir', TransfrFn_dir);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECK REFERENCE TIME \\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % If "ref_time" is < 0, then it indicates an index into SCM
    % time array. Convert it to a number, get the time, then
    % convert the time to a string in the form 'HHMMSS'.
    if strcmp(ref_time(1), '-')
        ref_index = abs(str2double(ref_time));
        ref_time = scm.t(ref_index);
        ref_time = ssm_to_hms(ref_time, 'to_string', true);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FIND MERGING INTERVALS \\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % find data gaps of 6 data points or more
    fgm_major_gaps = find_gaps(fgm.t, n_max, inf);
    scm_major_gaps = find_gaps(scm.t, n_max, inf);

    % Transfer the whole data interval into the global variables t_fgm and
    % t_scm for safe keeping.
    % Find the intervals where merging can take place
    disp('Finding intervals to merge...')
    t_fgm = fgm.t;
    t_scm = scm.t;
    [fgm_intervals, scm_intervals] = find_merge_intervals(t_fgm, t_scm, ...
                                                          fgm_major_gaps, ...
                                                          scm_major_gaps);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FILL MINOR DATA GAPS \\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %
    % The minor data gaps between each major data gap must then be
    % filled in before beginning the merging process. This is for
    % two reasons: 1) to create a continuous data product, 2) so that the
    % reference interval may be determined before any of the
    % merging takes place.
    %
    % The motivation for this was that Cluster has many data gaps that are
    % 5 samples long.
    %

    % Fill in the minor data gap
    disp('Finding data gaps...')
    [t_fgm, b_fgm, fgm_intervals] = fill_gaps(t_fgm, fgm.b, n_min, n_max, fgm_intervals);
    [t_scm, b_scm, scm_intervals] = fill_gaps(t_scm, scm.b, n_min, n_max, scm_intervals);
    n_intervals = length(fgm_intervals(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINE A SYNCHRONOUS START INDEX FOR THE QUIET INTERVAL %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    [ref_istart_fgm, ref_istart_scm] = get_start_ind(t_fgm, t_scm, ref_time);
    
    save, mission, sc, date, tstart, tend, f_min, f_max, n_min, n_max, ...
          multiplier, coord_sys, ref_time, ...
          fgm_data_dir, scm_data_dir, optArg1, optArg2, optArg3, ...
          fgm, t_fgm, ref_istart_fgm, fgm_intervals, ...
          scm, t_scm, ref_istart_scm, scm_intervals, ...
          n_intervals, filename='fgm_scm_merge_data.mat'
end