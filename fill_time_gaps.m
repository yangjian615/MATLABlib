function [filled_time] = fill_time_gaps(time, dt_min, dt_max)

% only fill the data gaps if they are small; i.e., 2*dt < gap < 6*dt
if nargin == 1
    dt_min = 1.5;
    dt_max = 6;
end

% calculate the time interval between each point
% take the mode as being the desired time interval
dt = diff(time);
dt_mode = mode(dt);

% find data gaps the lie within the specified range
gap_list = find(dt >= dt_mode*dt_min & dt < dt_max*dt_mode);
n_gaps = length(gap_list);

% make an editable copy of the time array
filled_time = time;
n_filled = 0;


for i=1:n_gaps
    fill = filled_time(gap_list(i)):dt_mode:filled_time(gap_list(i)+1);
    n_fill = length(fill) - 2;
    
    filled_time = [filled_time(1:gap_list(i)-1); fill'; filled_time(gap_list(i)+2:end)];
    
    if i < n_gaps
        gap_list(i+1:end) = gap_list(i+1:end) + n_fill;
    end
end

return, filled_time