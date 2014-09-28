
fid = fopen([myObj.data_dir, myObj.mission, '_Merged_', ...
            myObj.sc, '_', myObj.date, '_', myObj.tstart, '_', ...
            myObj.tend, '.txt'], 'w');

fprintf(fid, '%8s %14s %14s %14s \n', 't', 'Bu', 'Bv', 'Bw');

nlines = length(myObj.t_scm);
for ii = 1:nlines
    if mod(ii, 10000) == 0
        disp(['Printing line ', num2str(ii), ' of ', num2str(nlines), '. ', ...
              'Lines remaining: ', num2str(nlines-ii)])
    end
    
    fprintf(fid, '%13.7f %14.6f %14.6f %14.6f \n', ...
            myObj.t_scm(ii), myObj.b_spun(ii,1), myObj.b_spun(ii,2), myObj.b_spun(ii,3));
end

fclose(fid);