%
% Name
%   mrstdlog
%
% Purpose
%   Create or retrieve a standard logger object.
%
%   To close the stdlog file and return output to the consol,
%   set FILENAME = '', 'stdout', or 'stderr'.
%
% Calling Sequence
%   FILEID = mrstdlog()
%     Return the MrLogFile object assigned to stdlog output.
%
%   mrstdlog(FILENAME)
%     Send log output to the file named FILENAME.
%     Non-standard options are::
%       ''       - output to stderr
%       'stderr' - output to stderr
%       'stdout' - output to stdout
%     For MATLAB, stderr and stdout are the console.
%
%   mrstdlog(FILEID)
%     Set log output to the file with identifier FILEID.
%     Non-standard options are::
%       1 - output to stdout
%       2 - output to stderr
%     For MATLAB, stderr and stdout are the console.
%
%   mrstdlog(FILE_OBJ)
%     Use the given MrLogFile object FILE_OBJ as the logging object.
%
%   mrstdlog(..., [MrLogFile PARAMS])
%     Include any additional parameter accepted by MrLogFile.
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
%   2015-08-11      A FILEID can be given. - MRA
%   2015-08-21      If FILE not given, check if old object is valid. - MRA
%
function logfile = mrstdlog( file, varargin )

	% Establish global variables
	global stdlog
	
	% Check if stdlog exists
	%   - If stdlog does not exist, GLOBAL will create it
	%     and set stdlog = []
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
		
		% Is the log file valid?
		if ~stdlog.isvalid()
			stdlog = MrLogFile('');
		end

		logfile = stdlog;
	
%------------------------------------%
% Use File Name                      %
%------------------------------------%
	elseif ischar( file )
		% Create a new error logger object
		%   - ''       outputs to stderr
		%   - 'stderr' outputs to stderr
		%   - 'stdout' outputs to stdout
		%   - If old log file is open, it will be closed internally
		if tf_exist
			stdlog.filename = file;
			logfile         = stdlog;
		else
			logfile = MrLogFile( file );
		end
	
%------------------------------------%
% Use Existing File ID               %
%------------------------------------%
	elseif isnumeric( file )
		% Create a new error logger object
		%   - 1 outputs to stdout
		%   - 2 outputs to stderr
		%   - If old log file is open, it will be closed internally
		if tf_exist
			stdlog.fileID = file;
			logfile       = stdlog;
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
	
%------------------------------------%
% Otherwise                          %
%------------------------------------%
	else
		error( 'FILE must be a filename (string), file ID (integer), or MrLogFile object.' );
	end
	
	% Set the standard error file ID.
	stdlog = logfile;
end