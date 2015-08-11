%
% Name
%   mrstdout
%
% Purpose
%   Open or assign a file to stdout.. To close the stdout file, do
%   one of the following:
%     >> mrstdout('');
%     >> mrstdout('stdout');
%     >> mrstdout(1);
%
% Calling Sequence
%   FILEID = mrstdout()
%     Return the file ID of the file assigned to stdout output.
%
%   mrstdout(FILENAME)
%     Assign standard output to the file named FILENAME.
%     Additional options are::
%       ''       - MATLAB'S stdout (console)
%       'stdout' - MATLAB'S stdout (console)
%
%   mrstdout(FILEID)
%     Assign the file ID, FILEID, to stdout output. If FILEID = 1,
%     output will be directed to MATLAB's standard output (i.e. the
%     console).
%
%   mrstdout(..., KEEP_OPEN)
%     Keep the old stdout file open. The default is to close the previous file.
%
%   FILEID = mrstdout(__)
%     Return the file ID of the file assigned to stdout output.
%
% Parameters
%   FILENAME     in, optional, type=char
%   FILEID       in, optional, type=integer, default=1
%   KEEP_OPEN    in, optional, type=boolean, default=false
%
% Returns
%   FILEID       out, optional, type=integer
%
% Global Variables
%   STDOUT       File ID of the stdout file.
%
% See Also:
%   mrfprintf, mrstderr, mrstdlog, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-07      Written by Matthew Argall
%
function fileID = mrstdout( file, keep_open )

	% Establish global variables
	global stdout
	
	% Close previous stdout file?
	if nargin < 2
		keep_open = false;
	end
	
	% Check if stderr exists and is valid
	%   - If stdout does not exist, GLOBAL will create it
	%     and set stdout = []
	tf_exist = ~isempty(stdout)

%------------------------------------%
% Get Current stderr File ID         %
%------------------------------------%
	if nargin == 0
		
		% Default stdout
		%   - If it does not exist, is empty, or is less than zero.
		if ~tf_exist || isempty(stdout) || stdout < 0
			stdout = 1;
		end
		
		% Select the current stdout file.
		fileID = stdout;

%------------------------------------%
% Open A File                        %
%------------------------------------%
	elseif ischar( file )
		%
		% TODO:
		%   Determine if the file name is the one already in use.
		%     - Watch out for relative paths
		%     - fopen(stderr) will return the name current file.
		%
		
		% Close the previous file
		if ~keep_open && tf_exist && ~isempty(stdout) && stdout > 2
			% Indicate which file we are closing
			old_fname = fopen(stdout);
			fprintf( ['mrstdout: Closing stdout file "' old_fname '".\n'] );
			
			% Close the file
			fclose(stdout);
		end
		
		% Open the new file.
		if isempty(file) || strcmp(file, 'stdout')
			fileID = 1;
		else
			fileID = fopen( file, 'w' );
		end
		
		% Make sure the file could be opened
		if fileID == -1
			error( ['Could not open file for writing: "' file '".'] );
		end

%------------------------------------%
% Use File ID                        %
%------------------------------------%
	else
		% Check if file ID is valid.
		assert( isnumeric(file), 'FILE must be a file ID returned by fopen.' );
		assert( file == 1 || file > 2, 'FILE must be a file ID > 2' );
		
		% Close the previous file
		if ~keep_open && tf_exist && ~isempty(stdout) && stdout ~= file && file > 2
			% Indicate which file we are closing
			old_fname = fopen(stdout);
			fprintf( ['mrstdout: Closing stdout file "' old_fname '".\n'] );
			
			% Close the file
			fclose(stdout);
		end
		
		% Assign the new fileID.
		fileID = file;
	end
	
	% Set the standard error file ID.
	stdout = fileID;
end