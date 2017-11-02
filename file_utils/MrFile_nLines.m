%
% Name
%   MrFile_nLines
%
% Purpose
%   Determine the number of lines in a file.
%
% Calling Sequence
%   NLINES = MrFile_nLines(FILENAME)
%     Count the number of lines NLINES in the file FILENAME.
%
%   NLINES = MrFile_nLines(FILEID)
%     Count the number of lines from the current position in the file to
%     the end of the file. Upon exit, the file position is returned to its
%     original location.
%
% Parameters
%   FILE            in, required, type=char/integer
%
% Returns
%   NLINES          out, required, type=integer
%
% See Also:
%   test_count_file_lines.m has faster methods.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-10      Written by Matthew Argall
%
function nLines = MrFile_nLines(file)
	% Open the file
	if ischar(file)
		fileID = fopen(file);
		curPos = -1;
	else
		fileID = file;
		curPos = ftell(fileID);
		assert(curPos >= 0, 'Could not determine file position.')
	end
	
	% Number of lines
	nLines = 0;
	line   = '';

	while ~feof(fileID) %ischar(line)
		line   = fgetl(fileID);
		nLines = nLines + 1;
	end

	% Close or rewind the file
	if curPos == -1
		fclose(fileID);
	elseif curPos == 0
		frewind(fileID);
	else
		fseek(fileID, curPos, 'bof');
	end
end