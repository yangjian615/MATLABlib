% Uses the data that is left in the workspace after FG_SC_MERGE finishes
data_dir = '/Users/argall/Documents/Work/Data/20121001/';
mission = 'RBSP';
sc = 'A';
date = '20121001';
% tstart = '000000';
% tend = '080000';
% 
% range = [hms_to_ssm(str2double(tstart)), hms_to_ssm(str2double(tend))];
% irange = zeros(2,1);
% irange(1) = find(t_splice >= range(1), 1);
% irange(2) = find(t_splice <= range(2), 1, 'last');


fid = fopen([data_dir, mission, sc, '_Spliced_', ...
             date, '_', tstart, '_', tend, '.txt'], 'w');

fprintf(fid, '%8s %14s %14s %14s \n', 't', 'B(x)', 'B(y)', 'B(z)');

for ii = 1:length(t_splice)%irange(1):irange(2)
    fprintf(fid, '%13.7f %14.6f %14.6f %14.6f \n', ...
            t_splice(ii), b_splice(ii,1), b_splice(ii,2), b_splice(ii,3));
end

fclose(fid);
disp('Done Writing!')
clear fid ii range irange