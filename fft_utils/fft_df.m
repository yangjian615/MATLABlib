function [df] = merge_df(dt, clen)
    %
    % Get the frequencies if the FFT bins. We want the width of the
    % frequency bins (df) as well as the length of the FFT interval
    % in the time domain to be equal for the two instruments.
    %
    % If we take the ratio of dt_fgm with dt_staff to get a
    % rational number:
    %
    %       dt_fgm / dt_scm = n[umerator] / d[enominator]
    %
    % where n and d are integers, then the number of points
    % points required to make the time intervals equal is
    %
    %       d * dt_fgm = n * dt_scm
    %
    % n and d can be multiplied by an integer (m) to include
    % multiple periods in the same interval.
    %
    %       m * (d * dt_fgm) = m * (n * dt_scm)
    %
    % The length of the fft interval is then
    %
    %       len_fgm = m * d
    %       len_scm = m * n
    %
    % The width of the frequecy bins, then, is just the inverse of
    % each relationship
    %
    %       df_fgm = 1 / (len_fgm * dt_fgm)
    %       df_scm = 1 / (len_scm * dt_scm)
    %
    %       df_fgm = df_scm
    %
    df = 1 ./ (dt * clen);
end