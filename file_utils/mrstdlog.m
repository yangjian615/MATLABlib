%
% Name
%   mrstdlog
%
% Purpose
%   Create or retrieve a standard logger object.
%
%   To close the stdlog file, set FILENAME = ''.
%
% Calling Sequence
%   FILEID = mrstdlog()
%     Return the MrLogFile object assigned to stdlog output.
%
%   mrstdlog(FILENAME)
%     Open file named FILENAME and assign its file ID to 
%     stdout output.
%
%   mrstdlog(FILE_OBJ)
%     Use the given MrLogFile object FILE_OBJ as the logging object.
%
%   mrstdlog(..., [MrLogFile PARAMS])
%     Include any additional parameter accepted by MrErrorLogger.
%
%   LOGFILE = mrstdlog(__)
%     Return the logger file object assigned to stdlog output.
%
% Parameters
%   FILENAME     in, optional, type=char
%
% Returns
%   LOGFILE      out, optional, type=object
%
% Global Variables
%   STDLOG       Error logging object assigned to stdlog.
%
% See Also:
%   mrfprintf, mrstdout, mrstderr, MrErrorLogger
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-07      Written by Matthew Argall
%   2015-08-08      Default output to stderr. Accept MrLogFile object
%                     as input. - MRA
%
function logfile = mrstdlog( file, varargin )

	% Establish global variables
	global stdlog
	
	% Check if stderr exists
	%   - GLOBAL creates an empty variable.
	tf_exist = ~isempty(stdlog);

%------------------------------------%
% Return Current LogFile             %
%------------------------------------%
	if nargin == 0
		% Create a default logger object that directs output
		% to stderr -- the console.
		if ~tf_exist
			stdlog = MrLogFile('');
		end

		logfile = stdlog;
	
%------------------------------------%
% Open a File                        %
%------------------------------------%
	elseif ischar( file )
		% Create a new error logger object
		%   - An empty string will result in output to 'stderr' (console).
		%   - Old log file will be closed internally
		if tf_exist
			stdlog.filename = file;
			logfile         = stdlog;
		else
			logfile = MrLogFile( file );
		end
	
%------------------------------------%
% Use Existing Object                %
%------------------------------------%
	elseif isobject( file )
		% Must be a MrLogFile
		assert( isa(file, 'MrLogFile'), 'Input must be a MrLogFile object.' );
	
		% Close the previous
		if tf_exist && ~isempty(stdlog.filename)
			% Get the file name so we can notify that it was closed.
			if ~isempty(stdlog.filename)
				old_fname = stdlog.filename;
			else
				old_fname = '';
			end
			
			% Delete the old object
			stdlog.delete;
		end
		
		% Assign the new log object
		logfile = file;
		
		% Indicate that an old log file was closed.
		if ~isempty(old_fname)
			logfile.AddText( ['Closing old log file "' old_fname '".'] );
		end
	
	% Use the given file ID
	else
		error( 'FILENAME must be a character array.' );
	end
	
	% Set the standard error file ID.
	stdlog = logfile;
end