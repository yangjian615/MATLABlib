% Uses the data that is left in the workspace after FG_SC_MERGE finishes
data_dir = '/Users/argall/Documents/Work/Data/20121114/';
mission = 'RBSP';
sc = 'A';
date = '20121114';
tstart = '000000';
tend = '235959';

range = [hms_to_ssm(str2double(tstart)), hms_to_ssm(str2double(tend))];
irange = zeros(2,1);
irange(1) = find(fgm.t >= range(1), 1);
irange(2) = find(fgm.t <= range(2), 1, 'last');


fid = fopen([data_dir, mission, sc, '_FGM_', ...
             date, '_', tstart, '_', tend, '.txt'], 'w');

fprintf(fid, '%8s %14s %14s %14s \n', 't', 'B(x)', 'B(y)', 'B(z)');

for ii = irange(1):irange(2)
    fprintf(fid, '%13.7f %14.6f %14.6f %14.6f \n', ...
            fgm.t(ii), fgm.b(ii,1), fgm.b(ii,2), fgm.b(ii,3));
end

fclose(fid);
disp('Done Writing!')
clear fid ii range irange