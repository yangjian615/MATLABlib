function test_count_file_lines(filename)
    %
    % Test various methods for reading the number of lines in a file.
    %
    
    % METHOD 1: 
    %   Use the OS to do it.
    %
    %   a) Use the UNIX file system to count the number of lines.
    tic
    [~, result] = system( ['wc -l ', filename] );
    [nlines1, ~] = strtok(result, ' ');
    elapsedTime1 = toc;

    % METHOD 2:
    %   Read 1MB chunks
    %
    %   a) Read a file in 1Mb chunks
    %   b) Count the number of new line characters in the 1MB chunk
    %   c) If the end of file is reached or the chunk is empty, stop counting.
    tic
    fid = fopen(filename, 'r');
    chunksize = 1e6; % read chuncks of 1MB at a time
    nlines2 = 0;
    while ~feof(fid)
        chunk = fread(fid, chunksize, '*uchar');
        if isempty(chunk)
            break
        end
        nlines2 = nlines2 + sum(chunk == sprintf('\n'));
    end
    fclose(fid);
    elapsedTime2 = toc;
    
    % METHOD 3:
    %   Read an entire line.
    %
    %   a) Use 'fgets' to read an entire line of data (with newline character)
    %   b) While there is still text, count the number of lines.
    %   *) Read "Testing for EOF with 'fgets' and 'fgetl'. Possibility of reducing loop
    %      count by 1
    %       http://www.mathworks.com/help/matlab/import_export/import-text-data-files-with-low-level-io.html#br4ssin
    tic
    fid = fopen(filename,'rt');
    nlines3 = 0;
    while (fgets(fid) ~= -1)
      nlines3 = nlines3+1;
    end
    fclose(fid);
    elapsedTime3 = toc;
    
    % METHOD 4:
    %   Read the whole file at once, but only one character per line ('textread' not
    %   recommended by MatLab. Use 'textscan' instead).
    %
    %   a) Search for [single-character]+[any number of characters]+[newline].
    %   b) Do that for the entire file.
    %   c) Count how many matches there were.
    tic
    nlines4 = numel(textread(filename,'%1c%*[^\n]'));
    elapsedTime4 = toc;
        
    % METHOD 5:
    %   Same as method 4, but with 'textscan'
    tic
    fid = fopen(filename, 'r');
    nlines5 = numel(cell2mat(textscan(fid,'%1c%*[^\n]')));

    fclose(fid);
    elapsedTime5 = toc;
    
    % METHOD 6:
    %   Return the length of the file in bytes.
    %
    %   a) Move directly to the end of the file
    %   b) Get the number of bytes into the file of the current position (e.g. eof) 
    tic
    fid = fopen(filename);
    fseek(fid, 0, 'eof');
    nbytes6 = ftell(fid);
    fclose(fid);
    elapsedTime6 = toc;

    % Print the results
    results = char(['Method 1: nlines = ' num2str(nlines1) ' Elapsed Time = ' num2str(elapsedTime1)], ...
                   ['Method 2: nlines = ' num2str(nlines2) ' Elapsed Time = ' num2str(elapsedTime2)], ...
                   ['Method 3: nlines = ' num2str(nlines3) ' Elapsed Time = ' num2str(elapsedTime3)], ...
                   ['Method 4: nlines = ' num2str(nlines4) ' Elapsed Time = ' num2str(elapsedTime4)], ...
                   ['Method 5: nlines = ' num2str(nlines5) ' Elapsed Time = ' num2str(elapsedTime5)], ...
                   ['Method 6: nbytes = ' num2str(nbytes6) ' Elapsed Time = ' num2str(elapsedTime6)]);
    disp(results)
end