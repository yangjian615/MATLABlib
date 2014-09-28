% Uses the data that is left in the workspace after FG_SC_MERGE finishes
data_dir = '/Users/argall/Documents/Work/Data/20011001_083000_103000/';
mission = 'C';
sc = '3';
date = '20011001';
tstart = '090000';
tend = '095200';

range = [hms_to_ssm(str2double(tstart)), hms_to_ssm(str2double(tend))];
irange = zeros(2,1);
irange(1) = find(t_merge >= range(1), 1);
irange(2) = find(t_merge <= range(2), 1, 'last');


fid = fopen([data_dir, mission, sc, '_Merged_', ...
             date, '_', tstart, '_', tend, '.txt'], 'w');

fprintf(fid, '%8s %14s %14s %14s \n', 't', 'B(x)', 'B(y)', 'B(z)');

for ii = irange(1):irange(2)
    fprintf(fid, '%13.7f %14.6f %14.6f %14.6f \n', ...
            t_merge(ii), b_merge(ii,1), b_merge(ii,2), b_merge(ii,3));
end

fclose(fid);
disp('Done Writing!')
clear fid ii range irange