%
% Name
%   MrErrorLogger
%
% Purpose
%   Write text and error messages into a log file.
%
% Properties
%   ALERT               Flag to alert user of errors.
%   DELETE_ON_DESTROY   Delete the log file after object is destroyed.
%   FILEID              File identifier of the log file.
%   FILENAME            Name of the log file.
%   IMMEDIATE           Flush the file buffer immediately after writing.
%   LASTMESSAGE         The last message written to the log file.
%   NOCLUTTER           Always destroy log file and always display text.
%   STATUS              Status of the error logger.
%                         0 - waiting
%                         1 - Normal operation (log file will  be deleted if DELETE_ON_DESTROY)
%                         2 - Error operation  (log file won't be deleted if DELETE_ON_DESTROY)
%   TRACEBACK           Include the stack traceback.
%
% See Also:
%   mrstdout, mrstderr, mrstdlog, mrfprintf
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-20      Written by Matthew Argall
%   2015-08-07      Added NOCLUTTER property. Implemented ALERT and
%                     STATUS properties.  - MRA
%   2015-08-08      Added callstack, stderr, and stdout methods. Added
%                     additional parameters to AddText method. - MRA
%
classdef MrErrorLogger < handle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object Properties \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	properties
		alert              % Flag to provide user alert messages
		delete_on_destroy  % Delete the log file when object is destroyed
		filename           % Name of the log file
		fileID             % File ID of the log file
		immediate          % Flush the file buffer immediately
		lastmessage        % Last error message
		noclutter          % Always delete log file, always alert user
		status             % Current status of the error logger
		traceback          % Flag to include traceback reports in error/warning messages.
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Static Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods (Static)
		%
		% Get the call stack and calling program.
		%
		% Calling Sequence
		%   STACK = obj.traceback()
		%     Return the traceback report STACK, one cell element per
		%     level.
		%
		%   STACK = obj.traceback(LEVEL)
		%     Specify number of levels up from the current position
		%     in the callstack, LEVEL, at which the report should
		%     begin. If LEVEL=1, then the report will begin here,
		%     with MrErrorLogger.TRACEBACK.
		%
		%   [STACK, CALLER] = obj.traceback(__)
		%     Return the colling program CALLER. The calling program
		%     will be the program one level up from LEVEL within the
		%     callstack.
		%
		% Parameters
		%   LEVEL           in, optional, type=integer, defualt=1
		%
		% Returns
		%   STACK           out, required, type=cell
		%   CALLER          out, optional, type=char
		%
		function [stack, caller] = callstack(level)
			% Default level
			if nargin < 1
				level = 1;
			end

			% Get the stack
			theStack = dbstack();
			
			% Add calling routine
			%   - The calling routine is one up from here
			caller = theStack(level).name;
			
			% Do not count mrfprintf, either.
			%   - Special case for sister program
			if strcmp(caller, 'mrfprintf')
				level = level + 1;
				caller = theStack(level).name;
			end
			
			% Write the callstack
			theStack = theStack(level:end);

			% Extract the line numbers and program names
			line_numbers = cellfun(@num2str, { theStack.line }, 'UniformOutput', false );
			stack        = strcat('    In', {' '}, { theStack.name }, {' at (line '}, line_numbers, ')' );
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%
		% Purpose
		%   Instatiate a MrErrorLogger object.
		%
		% Calling Sequence
		%   OBJ = MrErrorLogger()
		%     Create an object handle OBJ to a MrErrorLogger object.
		%
		%   OBJ = MrErrorLogger(FILENAME)
		%     Messages will be written to a file with name FILENAME.
		%
		%   OBJ = MrErrorLogger(__, 'ParamName', ParamValue)
		%     Any of the parameter name-value pairs listed below.
		%
		% Parameters
		%   FILENAME:       in, optional, type=char, default='error_logger_yyyymmddHHMMSS_######.log'
		%   'Alert'         in, optional, type=boolean, default=false
		%                   Alert user by printing message to command window.
		%   'Delete'        in, optional, type=boolean, default=false
		%                   Delete the log file after the object is destroyed.
		%   'Status'        in, optional, type=integer, default=0
		%                   Status of the logger file.
		%   'Timestamp'     in, optional, type=boolean, default=false
		%                   Append a timestamp to the file name. If FILENAME is not
		%                     given, the default file will include a timestamp.
		%   'Traceback'     in, optional, type=boolean, default=true
		%                   Include the traceback report with each logged message.
		%
		% Returns
		%   OBJ             out, required, type=structure
		%
		function obj = MrErrorLogger(varargin)
			% Defaults
			alert             = false;
			delete_on_destroy = false;
			immediate         = true;
			noclutter         = false;
			status            = uint8(1);
			timestamp         = false;
			traceback         = true;
			
			% Default filename
			if mod(nargin, 2) == 0
				logFile  = fullfile( pwd(), ...
				                     [ 'error_logger_' ...
				                       datestr(now(), 'yyyymmddHHMMSS') '_' ...
				                       num2str( randi([1e5, 999999], 1, 'uint32') ) '.log' ] );
				timestamp = false;
			else
				logFile  = varargin{1};
				varargin = varargin(2:end);
			end

			% Number of optional arguments
			nOptArgs = length(varargin);
			for ii = 1 : 2 : nOptArgs
				switch varargin{ii}
					case 'Alert'
						alert = varargin{ii+1};
					case 'Delete'
						delete_on_destroy = varargin{ii+1};
					case 'Status'
						status = varargin{ii+1};
					case 'Timestamp'
						timestamp = varargin{ii+1};
					case 'Traceback'
						traceback = varargin{ii+1};
					otherwise
						error(['Unknown input parameter "' varargin{ii} '".']);
				end
			end
			
			% Relative name given? -- Make fully qualified.
			[pathstr, name, ext] = fileparts(logFile);
			if ~isempty(ext)
				name = [name ext];
			end
			if strcmp(name, logFile)
				logFile = fullfile( pwd(), logFile );
			end
			
			% Noclutter?
			if noclutter
				alert             = true;
				delete_on_destroy = true;
			end
			
			% Add a timestamp to the file name?
			if timestamp
				% Separate file parts
				[pathstr, name, ext] = fileparts(logFile);
				
				% Create time stamp
				tstamp = [ datestr(date(), 'yyyymmddHHMMSS') '_' ...
				           num2str( randi([1e5, 999999], 1, 'uint32') ) ];
				
				% Append time stamp
				logFile = fullfile( pathstr, [name '_' tstamp] );
				if ~isempty(ext)
					logFile = [logFile ext];
				end
			end
			
			%
			% The log file is opened (and created) upon first use.
			% See AddText for details.
			%
			
			% Set object properties
			obj.alert             = alert;
			obj.delete_on_destroy = delete_on_destroy;
			obj.filename          = logFile;
			obj.traceback         = traceback;
			obj.noclutter         = noclutter;
			obj.status            = status;       % Must come after NOCLUTTER
		end
		
		
		%
		% Class deconstructor.
		%
		% Calling Sequence
		%   obj.delete
		%     Cleanup after the MrErrorlogger object is deleted.
		%
		function [] = delete(obj)
			% Close the file
			obj.close();
			
			% Delete the log file
			%   - Never delete if we are in error mode.
			if obj.delete_on_destroy && obj.status ~= 2
				if exist( obj.filename, 'file' ) == 2
					delete, obj.filename
				end
			end
		end
		
		
		%
		% Flust buffer to file
		%
		% Calling Sequence
		%   obj.flush
		%     Flush the file buffer.
		%
		function [] = flush(obj)
			%
			% Apparently, FPRINTF() and FWRITE() flush the buffer
			% immediately after each call. I leave this method
			% here in case I am wrong.
			%
		end
		
		
		%
		% Display the last message
		%
		% Calling Sequence
		%   obj.dispLastMessage
		%     Display the last error message.
		%
		function [] = dispLastMessage(obj)
			lastMessage = obj.lastMessage
			for ii = 1 : length(lastMessage)
				disp( lastMessage{ii} );
			end
		end
		
		
		%
		% Open the log file
		%
		% Calling Sequence
		%   open(OBJ, NEWLOGFILE) --- or --- obj.open(NEWLOGFILE)
		%     Open a new log file named NEWLOGFILE.
		%
		%   open(OBJ, NEWLOGFILE, DELETE_CURRENT)
		%     Indicate that the current log file should be deleted.
		%
		% Parameters
		%   NEWLOGFILE:     in, required, type=char
		%   DELETE_CURRENT: in, optional, type=boolean, default=false
		%
		function status = open(obj, newLogFile, delete_current)
			% Assume we are unsuccessful
			success = false;
			
			% Delete the current file
			if nargin < 3
				delete_current = false;
			end

			% Check if given directory exists
			[pathstr, name, ext] = fileparts(newLogFile);
			assert( exist(pathstr, 'dir') == 7, ...
			        ['Directory does not exist: "' pathstr '".'] );

			% Close the current file
			obj.close
			
			% Delete the current file, if it exists
			if delete_current && exist( obj.filename, 'file') == 2
				delete, obj.filename
			end
			
			% Open the new file for writing
			try
				fileID       = fopen( newLogFile, 'w' );
				obj.fileID   = fileID;
				obj.filename = newLogFile;
			catch ME
				if exist( newLogFile, 'file' ) == 7
					delete, newLogFile
				end
				rethrow(ME);
			end
			
			% Write header
			fprintf(obj.fileID, 'Error log file created %s', datestr( now(), 'yyyy-mm-dd HH:MM:SS\n\n' ));
			
			% Success opening file.
			status = true;
		end
		
		
		%
		% Close the log file
		%
		% Calling Sequence
		%   obj.close
		%     Close the log file.
		%
		function [] = close(obj)
			if ~isempty(obj.fileID)
				fclose(obj.fileID);
				obj.fileID = [];
			end
		end
		
		
		%
		% Clear the log file
		%
		% Calling Sequence
		%   obj.clear
		%     Clear the log file.
		%
		function [] = clear(obj)
			% Close the log file
			obj.close();
			
			% Delete the log file
			if exist(obj.filename, 'file') == 2
				delete, obj.filename
			end
			
			% Open a file with the same name
			obj.open( obj.filename );
			
			% Set status to waiting
			obj.status = 0;
		end
		
		
		%
		% Write text to standard out. The stdout file identifer is
		% determined by mrstdout, which defaults to 1, the MATLAB
		% default stdout destination. MATLAB stdout outputs to the
		% command window.
		%
		% Calling Sequence
		%   obj.stdout(TEXT)
		%     Write text TEXT to standard output.
		%
		% Parameters
		%   TEXT            in, required, type=char/cell
		%
		function [] = stdout(obj, text)
			% Get the file identifier of stdout
			fileID = mrstdout();
			
			% Add text to stdout
			obj.AddText(fileID, text);
		end
		
		
		%
		% Write text to standard error. The stderr file identifer is
		% determined by mrstderr, which defaults to 2, the MATLAB
		% default stderr destination. MATLAB stderr outputs to the
		% command window.
		%
		% Calling Sequence
		%   obj.stderr(TEXT)
		%     Write text TEXT to standard error output.
		%
		% Parameters
		%   TEXT            in, required, type=char/cell
		%
		function [] = stderr(obj, text)
			% Get the file identifier of stdout
			fileID = mrstderr();
			
			% Add text to stdout
			obj.AddText(fileID, text, 'AddCaller', true, 'Level', 4);
		end
		
		
		%
		% Add text to the log file
		%
		% Calling Sequence
		%   obj.AddText(TEXT)
		%     Add text to the log file.
		%
		%   obj.AddText(FILEID, TEXT)
		%     Add text to the file with file identifier FILEID.
		%
		%   obj.AddText(__, 'ParamName', ParamValue)
		%     Any parameter name-value pair given below.
		%
		% Parameters
		%   FILEID:         in, optional, type=integer, default=log file
		%   TEXT:           in, required, type=char/cell
		%   'Display':      in, optional, type=boolean, default=false
		%                   Display the text to the command window as well.
		%   'AddCaller':    in, optional, type=boolean, default=false
		%                   Add the calling program to the text.
		%   'AddTraceback': in, optional, type=boolean, default=false
		%                   Add the traceback report to the text.
		%   'Level':        in, optional, type=boolean, default=3
		%                   Level in the traceback at which to start reporting.
		%                     The default (3) will start one level up from AddText.
		%                     Setting 'Level' automatically sets 'AddTraceback' true.
		%
		function [] = AddText(obj, arg1, arg2, varargin)
			% Check if a file identifier was given
			if isnumeric(arg1)
				fileID = arg1;
				text   = arg2;
			else
				% Open the log file on first sue
				if isempty(obj.fileID)
					obj.open(obj.filename);
				end
			
				% Set the fileID and message string
				fileID   = obj.fileID;
				text     = arg1;
				
				% Combine the second argument is an optional parameter
				if nargin > 2
					varargin = [ arg2 varargin ];
				end
			end

			if ~(ischar(text) || iscell(text))
				keyboard
			end

			% Ensure strings were given
			assert( ischar(text) || iscell(text), 'A string or cell array of strings must be given.' );
			if iscell(text)
				assert( max( cellfun(@ischar, text) ) == 1, 'Cell arrays must contain strings.');
			else
				text = { text };
			end
			
			% Defaults
			display    = false;
			add_caller = false;
			add_trace  = false;
			level      = [];
		
			% Check optional arguments
			nOptArgs = length(varargin);
			for ii = 1 : 2 : nOptArgs
				switch varargin{ii}
					case 'Display'
						display = varargin{ii+1};
					case 'AddCaller'
						add_caller = varargin{ii+1};
					case 'AddTraceback'
						add_trace = varargin{ii+1};
					case 'Level'
						level = varargin{ii+1};
					otherwise
						error( ['Unknown parameter: "' varargin{ii} '".'] );
				end
			end
			
			% Turn traceback on if level was given
			%   1. obj.traceback
			%   2. obj.AddText
			%   3. calling program
			if isempty(level)
				level = 3;
			else
				add_trace = true;
			end
			
			% Get the callstack
			if add_caller || add_trace
				[stk, caller] = obj.callstack(level);
			end
			
			% Add the calling function
			if add_caller
				text{1} = [ caller, ': ' text{1} ];
			end
			
			% Add the traceback
			if add_trace
				text = { text{:} stk{:} };
			end
			
			% Open the log file, if necessary
%			if isempty(obj.fileID)
%				success = obj.open( obj.filename );
%				assert( success, ['Cannot open log file: "' obj.filename '".'] );
%			end
			
			% Write to file (and display).
			nLines = length(text);
			for ii = 1 : nLines
				fprintf( fileID, [ text{ii} '\n' ] );
				if display
					fprintf( [ text{ii} '\n' ] );
				end
			end
			
			% Add an empty line
			fprintf( fileID, '\n' );
			if display
				fprintf( '\n' );
			end
			
			% Flush buffer to file
			if obj.immediate
				obj.flush();
			end
			
			% Set the status
			%   - Allows us to add text whenever we like
			%   - If called from AddError, we return there and change
			%     the status to 2.
			obj.status = 1;
			
			% Save the text
			obj.lastmessage = text;
		end
		
		
		%
		% Add warning to the log file
		%
		% Calling Sequence
		%   obj.AddWarning(text)
		%     Add a warning message to the log file.
		%
		%   obj.AddWarning(text, textID)
		%     Add a warning message to the log file and assign it a message ID.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%
		function [] = AddWarning(obj, arg1, arg2)
			% Check inputs
			if nargin == 3
				textID = arg1;
				text   = arg2;
			elseif nargin == 2
				textID = '';
				text   = arg1;
			elseif nargin == 1
				[text, textID] = lastwarn();
			end
			
			% Get the stack
			%   1 = obj.callstack
			%   2 = obj.AddWarning
			%   3 = calling program
			[stk, caller] = obj.callstack(3);
			
			% Append "Warning: " and " (caller)"
			text = ['Warning: ' text ' (' caller ')'];

			% Write the error message
			obj.AddText(text, 'Display', obj.alert);
			
			% Write the callstack
			if obj.traceback
				obj.AddText( stk, 'Display', obj.alert );
			end
			
			% Update the warning message and ID
			lastwarn(text, textID);
			
			% Normal operation.
			if obj.status ~= 2
				obj.status = 1;
			end
		end
		
		
		%
		% Add error to the log file
		%
		% Calling Sequence
		%   obj.AddText(text)
		%     Add an error message to the log file.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%
		function [] = AddError(obj, text)
			% Get the error message
			if nargin() < 2
				err  = lasterror();
				text = err.message;
				stk  = err.stack;
			else
				stk = dbstack();
			end
		
			% Get callstack and calling program
			%   1 = obj.callstack
			%   2 = obj.AddError
			%   3 = calling program
			[stk, caller] = obj.callstack(3);
			
			% Add calling program to text.
			text   = [caller ': ' text];

			% Write the callstack
			if obj.traceback
				text = [ text stk ];
			end
			
			% Write the error message
			obj.AddText(text, 'Display', obj.alert);
			
			% Logging an error
			obj.status = 2;
		end
	
	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function obj = set.alert(obj, alert)
			obj.alert = alert;
		end
		function obj = set.delete_on_destroy(obj, delete_on_destroy)
			obj.delete_on_destroy = delete_on_destroy;
		end
		function obj = set.filename(obj, filename)
			obj.filename = filename;
		end
		function obj = set.immediate(obj, immediate)
			obj.immediate = immediate;
		end
		function obj = set.lastmessage(obj, lastmessage)
			obj.lastmessage = lastmessage;
		end
		function obj = set.noclutter(obj, noclutter)
			obj.noclutter = noclutter;
			if noclutter
				obj.alert             = true;
				obj.delete_on_destroy = true;
			end
		end
		function obj = set.status(obj, status)
			% With NOCLUTTER, we always want to delete the file.
			% If STATUS = 2, the log file will not be destroyed
			% by default because an error has occurred. We want
			% to over-ride this by preventing STATUS=2.
			if obj.noclutter && status == 2
				obj.status = 1;
			else
				assert(status >= 0 && status <= 2, 'Status must be 0, 1, 2.')
				obj.status = status;
			end
		end
		function obj = set.traceback(obj, traceback)
			obj.traceback = traceback;
		end

	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Get Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function alert = get.alert(obj)
			alert = obj.alert;
		end
		function delete_on_destroy = get.delete_on_destroy(obj)
			delete_on_destroy = obj.delete_on_destroy;
		end
		function filename = get.filename(obj)
			filename = obj.filename;
		end
		function immediate = get.immediate(obj)
			immediate = obj.immediate;
		end
		function lastmessage = get.lastmessage(obj)
			lastmessage = obj.lastmessage;
		end
		function noclutter = get.noclutter(obj)
			noclutter = obj.noclutter;
		end
		function status = get.status(obj)
			status = obj.status;
		end
		function traceback = get.traceback(obj)
			traceback = obj.traceback;
		end
	end
end

