function [t_ssm] = hms_to_ssm(t_hms)
    
    % Start by dissecting the time
    if ischar(t_hms) || iscell(t_hms)
        [hour, minute, second, milli, micro, nano, pico] = dissect_time(t_hms, 'double');
        second = second + milli*1e-3 + micro*1e-6 + nano*1e-9 + pico*1e-12;
    else
        hour   = floor(t_hms / 10000);
        minute = floor((t_hms - hour*10000)/100);
        second = mod(t_hms, 100.0);
    end

    t_ssm = hour*3600 + minute*60 + second;
        
end  

