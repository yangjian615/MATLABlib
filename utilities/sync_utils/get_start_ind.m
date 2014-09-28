
function [istart_fgm, istart_scm] = get_start_ind(t_fgm, t_scm, ref_time)
    %
    % Synchronize FGM and SCM to the input time, given in 'HHMMSS' format,
    % and return the indices that correspond to that time-stamp.
    %
    
    % convert the time so seconds since midnight
    ref_ssm = hms_to_ssm(str2double(ref_time));

    % ensure that the reference time is within the data interval.
    assert(ref_ssm > t_fgm(1) & ref_ssm < t_fgm(end), ...
           'The reference time is outside the data interval')

    % Find the closest time in the FGM data to the reference time
    % then sync it with SCM. The stop index will at the end of one
    % full FFT
    [~, ref_index] = min(abs(t_fgm - ref_ssm));
    [istart_fgm, istart_scm] = sync_t(t_fgm, t_scm, ref_index, 'BOTH');
end