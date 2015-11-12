%
% Name
%   MrLogFile
%
% Purpose
%   Write text, warning, and error messages into a log file. By default, a log file
%   is created. If the filename is changed to '' (the empty string), 'stdout', or
%   'stderr; or if the fileID is changed to 1 or 2, then messages will be directed
%   to MATLAB's standard out and standard error outputs (which both happen to be the
%   console).
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
%                     additional parameters to AddText method. Output
%                     can be directed to MATLAB's stdout or stderr
%                     (i.e. the console). Renamed from MrErrorLogger
%                     to MrLogFile. - MRA
%   2015-08-11      Fixed bug in callstack when MrLogFile used from main
%                     level. Delete method can now delete log file. - MRA
%   2015-08-21      Filename of '' did not direct to stderr. Fixed. - MRA
%
classdef MrLogFile < handle

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
		traceback          % Flag to include traceback reports in error messages.
		warn_traceback     % Flag to include traceback reports in warning messages.
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
		%     with MrLogFile.TRACEBACK.
		%
		%   [STACK, CALLER] = obj.traceback(__)
		%     Return the colling program CALLER. The calling program
		%     is identified by LEVEL within the callstack.
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
			nStack   = length( theStack );

			% If LEVEL is greater than the number of elements in the stack, then
			%   a) MrLogFile was called from the command line.
			%   b) LEVEL is too large and we need to throw an error.
			if level == nStack + 1
				% If we are at the command line, the last entry in the stack
				% will be from a method internal to MrLogFile.
				if isempty( regexp( theStack(end).name, 'MrLogFile', 'once' ) )
					error( 'LEVEL > stack depth.' );
				else
					caller = 'Main';
					stack  = {''};
				end
			
			% LEVEL is ok
			elseif level <= nStack
				% Add calling routine
				%   - The calling routine is one up from here
				caller = theStack(level).name;

				% Do not count mrfprintf, either.
				%   - Special case for sister program
				if strcmp(caller, 'mrfprintf')
					% Was mrfprintf called from Main?
					if level + 1 > nStack
						caller   = 'Main';
						stack    = {''};
						theStack = [];
					else
						level    = level + 1;
						caller   = theStack(level).name;
						theStack = theStack(level:end);
					end
				else
					theStack = theStack(level:end);
				end

				% Convert the callstack to a cell array of strings
				%   - Extract the line numbers and program names
				if ~isempty(theStack)
					line_numbers = cellfun(@num2str, { theStack.line }, 'UniformOutput', false );
					stack        = strcat('    In', {' '}, { theStack.name }, {' at (line '}, line_numbers, ')' );
				end
				
			% LEVEL > depth
			else
				error( 'LEVEL > stack depth' );
			end
		end
	end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Normal Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	methods
		%
		% Purpose
		%   Instatiate a MrLogFile object.
		%
		% Calling Sequence
		%   OBJ = MrLogFile()
		%     Create an object handle OBJ to a MrLogFile object.
		%
		%   OBJ = MrLogFile(FILENAME)
		%     Messages will be written to a file with name FILENAME.
		%     Non-standard options are::
		%       ''       - output to stderr
		%       'stderr' - output to stderr
		%       'stdout' - output to stdout
		%     For MATLAB, stderr and stdout are the console.
		%
		%   OBJ = MrLogFile(FILEID)
		%     Messages will be written to the file with identifier
		%     FILEID. Non-standard options are::
		%       1 - output to stdout
		%       2 - output to stderr
		%     For MATLAB, stderr and stdout are the console.
		%
		%   OBJ = MrLogFile(__, 'ParamName', ParamValue)
		%     Any of the parameter name-value pairs listed below.
		%
		% Parameters
		%   FILENAME:       in, optional, type=char, default='MrLogFile_yyyymmddHHMMSS_######.log'
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
		function obj = MrLogFile(varargin)
			% Defaults
			alert             = false;
			delete_on_destroy = false;
			immediate         = true;
			noclutter         = false;
			status            = uint8(1);
			timestamp         = false;
			traceback         = true;
			warn_traceback    = false;
			
			% Default filename
			%   - FILENAME is the only parameter that is not a
			%     'ParamName' ParamValue pair.
			if mod(nargin, 2) == 0
				logFile  = fullfile( pwd(), ...
				                     [ 'MrLogFile_' ...
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
					case 'WarnTraceback'
						warn_traceback = varargin{ii+1};
					otherwise
						error(['Unknown input parameter "' varargin{ii} '".']);
				end
			end
			
			% If a file ID was given, get the file name
			if isnumeric(logFile)
				fileID  = logFile;
				logFile = fopen(fileID);
			else
				fileID = [];
			end

			% Filename given?
			%   - Ignore '', 'stdout', and 'stderr' as filenames
			if isempty(fileID) && sum( ismember({'', 'stdout', 'stderr'}, logFile) ) == 0
				% Relative name given? -- Make fully qualified.
				%   - Relative if only the NAME was given, not PATHSTR
				[pathstr, name, ext] = fileparts(logFile);
				if ~isempty(ext)
					name = [name ext];
				end
				if strcmp(name, logFile)
					logFile = fullfile( pwd(), logFile );
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
			end
			
			% Noclutter?
			if noclutter
				alert             = true;
				delete_on_destroy = true;
			end
			
			%
			% The log file is opened (and created) upon first use.
			% See AddText for details.
			%
			
			% Set object properties
			obj.alert             = alert;
			obj.delete_on_destroy = delete_on_destroy;
			obj.noclutter         = noclutter;
			obj.status            = status;       % Must come after NOCLUTTER
			                                      % Set method depend on one another
			obj.traceback         = traceback;
			obj.warn_traceback    = warn_traceback;
			
			% Set the output destination
			%   - Do not set both. One will take care of the other.
			if isempty(fileID)
				obj.filename = logFile;
			else
				obj.fileID = fileID;
			end
		end
		
		
		%
		% Class deconstructor.
		%
		% Calling Sequence
		%   obj.delete
		%     Cleanup after the MrLogFile object is deleted.
		%
		function [] = delete(obj)
			% Close the file
			obj.close();

			% Delete the log file
			%   - Except if we are in error mode.
			if obj.delete_on_destroy && obj.status ~= 2
				if exist( obj.filename, 'file' ) == 2
					delete(obj.filename);
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
			status = false;
			
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
			if ~isempty(obj.fileID) && obj.fileID > 2
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
			%
			% TODO:
			%   Make as robust as AddError
			%     - Accept MExceptions
			%     - check lasterror
			%
		
			% Get the file identifier of stdout
			fileID = mrstderr();
			
			% Add text to stdout
			obj.AddText(fileID, text, ...
			            'AddCaller',    true, ...
			            'AddTraceback', true, ...
			            'Level',        4);
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
				text = [ text stk ];
			end

			% Write to file (and display).
			nLines = length(text);
			for ii = 1 : nLines
				fprintf( fileID, [ text{ii} '\n' ] );
				if display
					fprintf( [ text{ii} '\n' ] );
				end
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
		%   obj.AddWarning()
		%     Write the last warning, returned by MATLAB's lastwarn() function,
		%     to the log file.
		%
		%   obj.AddWarning(MSG)
		%     Add a warning message to the log file.
		%
		%   obj.AddWarning(MSGID, MSG)
		%     Add a warning message to the log file and assign it a message ID.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%
		function [] = AddWarning(obj, arg1, arg2)
			% Check inputs
			if nargin == 3
				msgID = arg1;
				msg   = arg2;
			elseif nargin == 2
				msgID = '';
				msg   = arg1;
			elseif nargin == 1
				[msg, msgID] = lastwarn();
			end
			
			% Error text must be a character array
			assert( ischar(msg) && isrow(msg), 'MSG must be a scalar string.' );
			
			% Alert user
			if obj.alert
				warning(msgID, msg);
			% Update the warning message and ID
			else
				lastwarn(msg, msgID);
			end
			
			% Get the stack
			%   1 = obj.callstack
			%   2 = obj.AddWarning
			%   3 = calling program
			[stk, caller] = obj.callstack(3);
			
			% Append "Warning: " and " (caller)"
			msg = ['Warning: ' msg ' (' caller ')'];
			
			% Write the callstack
			%   - Add a blank line after the warning.
			%   - AddText will append "\n" to '', thereby adding a blank line.
			if obj.warn_traceback
				msg = [ msg stk {''} ];
			end

			% Write the warning message
			obj.AddText( msg );
			
			% Normal operation.
			if obj.status ~= 2
				obj.status = 1;
			end
		end
		
		
		%
		% Add error to the log file
		%
		% Calling Sequence
		%   obj.AddError()
		%     Write the last error, returned by MATLAB's lasterror() function,
		%     to the log file.
		%
		%   obj.AddError(ERRTEXT)
		%     Add an error message to the log file.
		%
		%   obj.AddError(EXCEPTION)
		%     Add an MATLAB Exception, EXCEPTION, to the log file.
		%
		% Parameters
		%   ERRTEXT:        in, optional, type=char
		%   EXCEPTION:      in, optional, type=object
		%
		function [] = AddError(obj, arg1)
			% Get the error message
			if nargin() < 2
				err     = lasterror();
				errText = err.message;
				stk     = err.stack;
			else
				% MATLAB Exception
				if isobject(arg1)
					% Error message
					ME      = arg1;
					assert( isa( ME, 'MException'), 'EXCEPTION must be a MException object.' );
					errText = sprintf('%s', ME.message);
					
					% Program that generated the error
					caller = ME.stack(1).name;

					% Build the stack
					stk    = cell( 1, length(ME.stack) );
					stk{1} = sprintf('  Error using %s (line %d)', ME.stack(1).name, ME.stack(1).line);
					for ii = 2: length(ME.stack)
						stk{ii} = sprintf('      %s (line %d)', ME.stack(ii).name, ME.stack(ii).line);
					end

				% Error Text
				else
					% Must be a character array
					errText = arg1;
					assert( ischar(errText) && isrow(errText), 'ERRTEXT must be a scalar string.' );
					
					% Get callstack and calling program
					%   1 = obj.callstack
					%   2 = obj.AddError
					%   3 = calling program
					[stk, caller] = obj.callstack(3);
				end
			end
			
			% Add calling program to text.
			errText   = [caller ': ' errText];

			% Write the callstack
			%   - Add an empty line after the error.
			%   - AddText will print '' on a new line, then print, "\n"
			if obj.traceback
				errText = [ errText stk {''} ];
			else
				errText = { errText '' };
			end
			
			% Write the error message
			obj.AddText(errText, 'Display', obj.alert);
			
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
		
		
		%
		% Purpose
		%   Set the name of the log file. Note that setting the
		%   filename will automatically update the object's file ID. It is
		%   unwise for the user to set both.
		%
		% Calling Sequence
		%   obj.filename(FILENAME)
		%     Messages will be written to a file with name FILENAME.
		%     Non-standard options are::
		%       ''       - output to stderr
		%       'stderr' - output to stderr
		%       'stdout' - output to stdout
		%     For MATLAB, stderr and stdout are the console.
		%
		% Parameters
		%   FILENAME        in, required, type=char
		%
		function obj = set.filename(obj, filename)
			% A string must be given
			assert( ischar(filename) && ( isempty(filename) || isrow(filename) ), ...
			        'FILENAME must be an empty or scalar string.' )

			%
			% TODO: Check if filename has changed. Would have to consider
			%       relative file names.
			%

			% Notify user that an old file is being closed
%			if ~isempty(obj.filename)
%				fprintf( ['Closing log file: "' obj.filename '".\n'] );
%			end
			
			% Close the old file
			obj.close;
			
			% Set the file identifier
			switch filename
				case ''
					obj.fileID = 2;
				case 'stderr'
					obj.fileID = 2;
				case 'stdout'
					obj.fileID = 1;
				otherwise
					obj.fileID = [];
			end
			
			% Set the filename
			%   - File will not be opened until first call to AddText
			%   - FILEID will be assigned at that time.
			obj.filename = filename;
		end
		
		
		%
		% Set the file identifier of the log file. Note that setting the
		% file ID will automatically update the object's filename. It is
		% unwise for the user to set both at once.
		%
		% Calling Sequence
		%   obj.fileID(FILEID)
		%     Messages will be written to the file with identifier
		%     FILEID. Non-standard options are::
		%       1 - output to stdout
		%       2 - output to stderr
		%     For MATLAB, stderr and stdout are the console.
		%
		% Parameters
		%   FILEID          in, required, type=integer
		%
		function obj = set.fileID(obj, fileID)
			% A scalar integer must be given
			assert( isempty(fileID) || ( isnumeric(fileID) && isscalar(fileID) && fileID > 1 ), ...
			        'FILEID must be a scalar integer > 1.' )

			% Empty file ID
			%  - set.filename will temporarily make the fileID empty.
			%  - The new file will be opened upon the first call to AddText.
			if isempty(fileID)
				%
				% TODO: Allow empty file IDs from only set.filename and obj.close.
				%
				obj.fileID = [];
				
			% Set the file ID
			%   - If obj.fileID is empty, we are waiting for AddText
			%     to open the file and assign a fileID.
			%   - This occurs because set.filename closed the old
			%     file and unset the file ID.
			elseif isempty(obj.fileID)
				obj.fileID = fileID;
			
			% Change the file ID
			%   - The only way that fileID and obj.fileID can both
			%     not be empty is if a log file is already open
			%     and the user wants to make a different file the
			%     target of log messages.
			%   - In this case, calling set.filename will close the
			%     old file, update the file name. We then set the
			%     new fileID.
			elseif fileID ~= obj.fileID
				% Get the name of the file
				%   - set.filename will close the old file
				obj.filename = fopen(fileID);
				
				% Set the file ID
				obj.fileID   = fileID;
			end
		end
		
		
		function obj = set.immediate(obj, immediate)
			obj.immediate = immediate;
		end
		function obj = set.lastmessage(obj, lastmessage)
			obj.lastmessage = lastmessage;
		end
		
		
		%
		% NOCLUTTER means the log file will always be deleted
		% when the object is destroyed.
		%
		function obj = set.noclutter(obj, noclutter)
			obj.noclutter = noclutter;
			if noclutter
				obj.alert             = true;
				obj.delete_on_destroy = true;
			end
		end
		
		%
		% Set the operation status of the object
		%
		% Calling Sequence
		%   obj.status = STATUS
		%     Set the operating status, STATUS, of the object. Possible
		%     values are::
		%       1 - Waiting for input.
		%       2 - Normal operations (log file is deleted when object is destroyed).
		%       3 - Error operations (prevents file from being deleted).
		%
		% Parameters
		%   STATUS          in, required, type=integer
		%
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
		function obj = set.warn_traceback(obj, warn_traceback)
			obj.warn_traceback = warn_traceback;
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
		function warn_traceback = get.warn_traceback(obj)
			warn_traceback = obj.warn_traceback;
		end
	end
end

