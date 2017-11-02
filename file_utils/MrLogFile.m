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
%   DELETE_ON_DESTROY   Delete the log file if status ~= 0 when destroyed.
%   FILEID              File identifier of the log file.
%   FILENAME            Name of the log file.
%   IMMEDIATE           Flush the file buffer immediately after writing.
%   LASTMESSAGE         The last message written to the log file.
%   NOCLUTTER           Delete the log file if status = 0 when destroyed.
%   STATUS              Status of the error logger.
%                         0     - OK
%                         1-255 - Error
%   TRACEBACK           Include the stack traceback.
%   WARN_TRACEBACK      Include the stack traceback for warning messages.
%
% See Also:
%   mrstdout, mrstderr, mrstdlog, mrfprintf
%
% MATLAB release(s) MATLAB 9.0.0.341360 (R2016a)
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
%   2017-03-20      The status property can take on values from 0-255.
%                     Status can be set from the AddError and AddWarning
%                     methods. DELETE_ON_DESTROY and NOCLUTTER have new,
%                     more intuitive meanings. Option to append to file. - MRA
%
classdef MrLogFile < handle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Object Properties \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%
	% AbortSet is required so that set.filename and set.fileID
	% do not enter infinite loops.
	%
	properties (AbortSet = true)
		alert                   % Flag to provide user alert messages
		delete_on_destroy       % Delete the log file when object is destroyed
		fileID                  % File ID of the log file.
		filename                % Name of the log file.
		immediate               % Flush the file buffer immediately
		noclutter               % Always delete log file, always alert user
		status                  % Current status of the error logger
		traceback               % Flag to include traceback reports in error messages.
		warn_traceback          % Flag to include traceback reports in warning messages.
	end
	
	properties (SetAccess = private)
		lastmessage             % Last error message
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
		%   'NoClutter'     in, optional, type=boolean, default=false
		%                   Delete the log file after the object is destroyed but only.
		%                     if no error has occurred.
		%   'Status'        in, optional, type=integer, default=0
		%                   Status of the logger file.
		%   'Timestamp'     in, optional, type=boolean, default=false
		%                   Append a timestamp to the file name. If FILENAME is not
		%                     given, the default file will include a timestamp.
		%   'Traceback'     in, optional, type=boolean, default=true
		%                   Include the traceback report with each error message.
		%   'WarnTraceback' in, optional, type=boolean, default=false
		%                   Include the traceback report with each warning message.
		%
		% Returns
		%   OBJ             out, required, type=structure
		%
		function obj = MrLogFile(varargin)
		
		%------------------------------------%
		% Defaults                           %
		%------------------------------------%
			alert             = false;
			delete_on_destroy = false;
			immediate         = true;
			noclutter         = false;
			permission        = 'w';
			status            = uint8(0);
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
		
		%------------------------------------%
		% Check Inputs                       %
		%------------------------------------%

			% Number of optional arguments
			nOptArgs = length(varargin);
			for ii = 1 : 2 : nOptArgs
				switch varargin{ii}
					case 'Alert'
						alert = varargin{ii+1};
					case 'Delete'
						delete_on_destroy = varargin{ii+1};
					case 'NoClutter'
						noclutter = varargin{ii+1};
					case 'Permission'
						permission = varargin{ii+1};
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
		
		%------------------------------------%
		% File Name or ID?                   %
		%------------------------------------%
			
			% Set the output destination
			%   - Do not set both. One will take care of the other.
			if isnumeric(logFile)
				fileID   = logFile;
				filename = ''
			else
				fileID   = [];
				filename = logFile;
			end
		
		%------------------------------------%
		% Fix-Up File Name                   %
		%------------------------------------%

			% Filename given?
			%   - Ignore '', 'stdout', '"stdout"', 'stderr', '"stderr"' as filenames
			%   - fopen(1) and fopen(2) return '"stdout"' and '"stderr"', respectively
			if isempty(fileID) && ~ismember(logFile, {'', 'stdout', '"stdout"', 'stderr', '"stderr"'})
				
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
		
		%------------------------------------%
		% Set Properties                     %
		%------------------------------------%
			
			% Set the output destination
			%   - Do not set both. One will take care of the other.
			if isnumeric(logFile)
				obj.fileID = logFile;
			else
				obj.open(logFile, permission);
			end
		
		%------------------------------------%
		% Set Properties                     %
		%------------------------------------%
			
			%
			% The log file is opened (and created) upon first use.
			% See AddText for details.
			%
			
			% Set object properties
			obj.alert             = alert;
			obj.delete_on_destroy = delete_on_destroy;
			obj.noclutter         = noclutter;
			obj.status            = status;
			obj.traceback         = traceback;
			obj.warn_traceback    = warn_traceback;
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
			if obj.delete_on_destroy
				if exist( obj.filename, 'file' ) == 2
					delete(obj.filename);
				end
			end
			
			% Delete the log file if no error
			if obj.noclutter
				if obj.status == 0 && exist( obj.filename, 'file' ) == 2
					delete(obj.filename);
				end
			end
		end
		
		
		%
		% Add error to the log file
		%
		% Calling Sequence
		%   obj.AddError()
		%   obj.AddError( [] )
		%     Write the last error, returned by MATLAB's lasterror() function,
		%     to the log file.
		%
		%   obj.AddError(ERRTEXT)
		%     Add an error message to the log file.
		%
		%   obj.AddError(MSGID, ERRTEXT)
		%     Message identifier following the convention component:mnemonic.
		%
		%   obj.AddError(EXCEPTION)
		%     Add an MATLAB Exception, EXCEPTION, to the log file.
		%
		%   obj.AddError(__, STATUS)
		%     Declare the error status associated with the error.
		%
		%   obj.AddError(__, STATUS, LEVEL)
		%     Declare the level in the stack at which to begin reporting. The
		%       default is 3, equivalent to the routine that called AddError.
		%
		% Parameters
		%   ERRTEXT:        in, optional, type=char
		%   EXCEPTION:      in, optional, type=object
		%
		function [] = AddError2(obj, varargin)
			
			% STATUS
			%   - Default to leaving the status unchanged.
			if isnumeric(varargin{end})
				status        = varargin{end};
				varargin(end) = [];
			else
				status = [];
			end
		
		%------------------------------------%
		% Get Error Message                  %
		%------------------------------------%
			% obj.AddText( );
			if nargin == 1 || isempty(varargin{1})
				err     = lasterror();
				errText = err.message;
				errID   = err.identifier;
				stk     = err.stack;
				
				if nargin > 1
					varargin{1} = [];
				end
		
		%------------------------------------%
		% MException                         %
		%------------------------------------%
			% obj.AddText( ME );
			elseif nargin() > 1 && isobject(varargin{1})
				% Error message
				ME          = varargin{1};
				assert( isa( ME, 'MException'), 'EXCEPTION must be a MException object.' );
				varargin{1} = [];
				
				% Program that generated the error
				errText = sprintf('%s', ME.message);
				caller  = ME.stack(1).name;

				% Build the stack
				stk    = cell( 1, length(ME.stack) );
				stk{1} = sprintf('  Error using %s (line %d)', ME.stack(1).name, ME.stack(1).line);
				for ii = 2: length(ME.stack)
					stk{ii} = sprintf('      %s (line %d)', ME.stack(ii).name, ME.stack(ii).line);
				end
		
		%------------------------------------%
		% Error Text                         %
		%------------------------------------%
			% obj.AddText( ErrText );
			% obj.AddText( ErrID, ErrText );
			elseif nargin > 1 && ischar(varargin{1})
				
				% obj.AddText( ErrID, ErrText );
				if nargin > 2 && ischar(varargin{2})
					errID         = varargin{1};
					errText       = varargin{2};
					varargin(1:2) = [];
					
				% obj.AddText( ErrText );
				else
					errID       = '';
					errText     = varargin{1};
					varargin(1) = [];
				end
				
				assert( isrow(errText), 'ERRTEXT must be a scalar string.' );
				
				% Get callstack and calling program
				%   1 = obj.callstack
				%   2 = obj.AddError
				%   3 = calling program
				[stk, caller] = obj.callstack(3);
				
				% Update the error message
				lasterror( struct('message', errText, 'identifier', errID) );
			end
		
		%------------------------------------%
		% Write Error                        %
		%------------------------------------%
			
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
			obj.status = status;
		end
		
		
		%
		% Add error to the log file
		%
		% Calling Sequence
		%   obj.AddError()
		%   obj.AddError( [] )
		%     Write the last error, returned by MATLAB's lasterror() function,
		%     to the log file.
		%
		%   obj.AddError(ERRTEXT)
		%     Add an error message to the log file.
		%
		%   obj.AddError(MSGID, ERRTEXT)
		%     Message identifier following the convention component:mnemonic.
		%
		%   obj.AddError(EXCEPTION)
		%     Add an MATLAB Exception, EXCEPTION, to the log file.
		%
		%   obj.AddError(__, STATUS)
		%     Declare the error status associated with the error.
		%
		%   obj.AddError(__, STATUS, LEVEL)
		%     Declare the level in the stack at which to begin reporting. The
		%       default is 3, equivalent to the routine that called AddError.
		%
		% Parameters
		%   MSGID:          in, optional, type=char
		%   ERRTEXT:        in, optional, type=char
		%   EXCEPTION:      in, optional, type=object
		%   STATUS:         in, optional, type=numeric, default=1
		%   LEVEL:          in, optional, type=numeric, default=3
		%
		function [] = AddError(obj, varargin)
			
			% Defaults
			status = 1;
			level  = 3;
		
		%------------------------------------%
		% Status & Level                     %
		%------------------------------------%
			if nargin >= 3
				% obj.AddErr( [__], STATUS, LEVEL );
				if isnumeric(varargin{end-1})
					status = varargin{end-1};
					level  = varargin{end};
				
				% obj.AddErr( [__], STATUS );
				elseif isnumeric(varargin{end})
					status = varargin{end};
				end
				
			% obj.AddErr( [__], STATUS );
			elseif nargin >= 2
				if isnumeric(varargin{end})
					status = varargin{end};
				end
			end
		
		%------------------------------------%
		% Get Error Message                  %
		%------------------------------------%
			% obj.AddErr( );
			% obj.AddErr( [], ... );
			if nargin == 1 || isempty(varargin{1})
				err     = lasterror();
				errText = err.message;
				errID   = err.identifier;
				stk     = err.stack;
		
		%------------------------------------%
		% Parse Error Message                %
		%------------------------------------%
			elseif nargin >= 2
				% MATLAB Exception
				%   - obj.AddErr( ME, ... );
				if isobject(varargin{1})
					% Error message
					ME      = varargin{1};
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
				%   - obj.AddErr( ErrText, ... );
				%   - obj.AddErr( ErrID, ErrText, ... );
				elseif ischar(varargin{1})
					
					% obj.AddErr( ErrID, ErrText, ... );
					if nargin >= 3 && ischar(varargin{2})
						errID   = varargin{1};
						errText = varargin{2};
						
					% obj.AddErr( ErrText, ... );
					else
						errText = varargin{1};
						errID   = '';
					end
					assert( isempty(errID) || isrow(errID), 'ERRID must be a scalar string.' );
					assert( isrow(errText),                 'ERRTEXT must be a scalar string.' );
					
					% Get callstack and calling program
					%   1 = obj.callstack
					%   2 = obj.AddError
					%   3 = calling program
					[stk, caller] = obj.callstack(level);
					
					% Update the error message
					lasterror( struct('message', errText, 'identifier', errID) );
				end
			end
		
		%------------------------------------%
		% Write Error                        %
		%------------------------------------%
			
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
			obj.status = status;
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
				fprintf( fileID, '%s\n', text{ii} );
				if display
					sprintf( '%s\n', text{ii} );
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
		%   obj.AddWarning( [] )
		%     Write the last warning, returned by MATLAB's lastwarn() function,
		%     to the log file.
		%
		%   obj.AddWarning(MSG)
		%     Add a warning message to the log file.
		%
		%   obj.AddWarning(MSGID, MSG)
		%     Add a warning message to the log file and assign it a message ID.
		%
		%   obj.AddWarning(__, STATUS)
		%     Declare the error status associated with the warning.
		%
		% Parameters
		%   TEXT:           in, required, type=char/cell
		%
		function [] = AddWarning(obj, varargin)
			
			% STATUS
			%   - Default to leaving the status unchanged.
			if isnumeric(varargin{end})
				status        = varargin{end}
				varargin(end) = [];
			else
				status = [];
			end
			
			% MSGID & MSG
			nArgs = length(varargin);
			if nArgs == 2
				msgID = varargin{1};
				msg   = varargin{2};
			elseif nArgs == 1
				msgID = '';
				msg   = varargin{1};
			elseif nArgs == 1
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
			
			% Update the status.
			obj.status = status;
		end
		
		
		%
		% Close the log file
		%
		% Calling Sequence
		%   obj.close
		%     Close the log file.
		%
		function [] = close(obj)
			% Close the file
			%   - When the object is first created, the fileID property is empty & cannot be closed
			%   - stdout & stderr cannot be closed
			%   - If a fileID refers to a closed file, it cannot be closed again
			if ~isempty(obj.fileID) && obj.fileID > 2 && ~isempty( fopen(obj.fileID) )
				fclose(obj.fileID);
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
		% Open the log file
		%
		% Calling Sequence
		%   open(OBJ, NEWLOGFILE) --- or --- obj.open(NEWLOGFILE)
		%     Open a new log file named NEWLOGFILE.
		%
		%   open(..., PERMISSION)
		%     Write-access to be granted to the file. Choos 'w' for write
		%     and 'a' for append.
		%
		%   open(..., DELETE_CURRENT)
		%     Indicate that the current log file should be deleted.
		%
		%   success = open(__)
		%     Returns true if the file was opened successfully and false.
		%       otherwise. If not returned and the operation fails, an
		%       error will be thrown.
		%
		% Parameters
		%   NEWLOGFILE:     in, required, type=char
		%   DELETE_CURRENT: in, optional, type=boolean, default=false
		%
		% Returns
		%   SUCCESS:        out, optional, type=boolean
		%
		function success = open(obj, filename, permission, delete_current)
		
		%------------------------------------%
		% Check Inputs                       %
		%------------------------------------%
			% Assume we are unsuccessful
			success = false;
			
			% PERMISSION
			if nargin < 3
				permission = 'w';
			else
				assert( isscalar(permission) && ismember(permission, {'w', 'a'}), ...
				        'PERMISSIONS must be {"w" | "a"}' );
			end
			
			% DELETE_CURRENT
			if nargin < 4
				delete_current = false;
			else
				assert( strcmp(delete_current, 'delete'), 'Invalid fourth parameter.' );
				delete_current = true;
			end

		%------------------------------------%
		% Close Current File                 %
		%------------------------------------%

			% Close the current file
			obj.close();
			
			% Delete the current file, if it exists
			if delete_current && exist( obj.filename, 'file') == 2
				delete(obj.filename);
			end

		%------------------------------------%
		% Open New Log File                  %
		%------------------------------------%
			%
			% Set only the fileID. The filename will be set automatically
			% by the set.fileID method.
			%
			
			
			switch filename
				% STDOUT
				%   - fopen(1) returns "stdout" (with double quotes)
				case {'stdout', '"stdout"'}
%					obj.filename = 'stdout';
					obj.fileID   = 1;
					success      = true;
				
				% STDERR
				%   - fopen(2) returns "stderr" (with double quotes)
				case {'', 'stderr', '"stderr"'}
%					obj.filename = 'stderr';
					obj.fileID   = 2;
					success      = true;
				
				% FILENAME
				otherwise
					try
%						% Check if given directory exists
%						[pathstr, name, ext] = fileparts(filename);
%						assert( exist(pathstr, 'dir') == 7, ...
%						        ['Directory does not exist: "' pathstr '".'] );
						
						% Open the new file for writing
						fileID = fopen( filename, permission );
			
						% Write header
						fprintf(fileID, 'Error log file created %s', datestr( now(), 'yyyy-mm-dd HH:MM:SS\n\n' ));
				
						% SUCCESS!
%						obj.filename = filename;
						obj.fileID   = fileID;
						success      = true;
			
					catch ME
						% Delete the file
						if exist( filename, 'file' ) == 7 && ~strcmp(permission, 'a')
							delete(filename);
						end
						
						% Throw an error if no output variable is present.
						if nargout == 0
							rethrow(ME);
						end
					end
			end
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
		
		
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Set Methods \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		function obj = set.alert(obj, alert)
			obj.alert = alert;
		end
		
		
		%
		% DELETE_ON_DESTROY means the log file will be delete when
		% the object is destroyed. Setting this property to TRUE
		% automatically sets NOCLUTTER to FALSE.
		%
		function obj = set.delete_on_destroy(obj, delete_on_destroy)
			obj.delete_on_destroy = delete_on_destroy;
			
			% Do not allow both DELETE_ON_DESTROY and NOCLUTTER
			if delete_on_destroy
				obj.noclutter = false;
			end
		end
		
		
		%
		% Purpose
		%   Set the name of the log file.
		%
		%   To publicly set the file name, the Open method must be called.
		%   This is to minimize circular setting of both the FILENAME and
		%   FILEID properties.
		%
		function obj = set.filename(obj, filename)
			assert( ischar(filename) && isrow(filename), 'FILENAME must be a character row vector.' );
			
			% Determine the current name
			fname = fopen(obj.fileID);
			
			% If the FILEID name matches FILENAME
			%   - [(open | close) ->] set.fileID -> Here
			%   - FILENAME must be unaltered from when FILEID was obtained via FOPEN.
			if strcmp( fname, filename )
				obj.filename = filename;
			
			% Allow '"stdout"' and '"stderr"' to match 'stdout' and 'stderr'
			elseif ( strcmp(fname, '"stdout"') && strcmp(filename, 'stdout') ) || ...
			       ( strcmp(fname, '"stderr"') && strcmp(filename, 'stderr') )
				obj.filename = filename;
			
			% Open the file
			%   - The FILENAME property was set directly
			%   - Open:
			%     1) Close current file
			%     2) Open file & obtain new file ID
			%     3) Set file ID --> sets file name in "if" case above
			else
				obj.open(filename);
			end
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
			assert( isscalar(fileID) && isnumeric(fileID) && fileID >= 1, ...
			        'FILEID must be a scalar integer >= 1.' );
			
			% Close the current file
			%   - A closed file returns ''
			%   - fileID 1 or 2 returns '"stdout"', '"stderr"'
			obj.close();
			
			% Pick the appropriate file name
			switch fileID
				case 1
					filename = 'stdout';
				case 2
					filename = 'stderr';
				otherwise
					% Get the file name
					filename = fopen(fileID);
					assert( ~isempty(filename), 'FILEID must refer to an open file.' );
			end
			
			% Set the file ID
			obj.fileID   = fileID;
			obj.filename = filename;
		end
		
		
		%
		% Set the file identifier of the log file.
		%
		% To publicly set the fileID, the setFileID method must be called.
		% This is to minimize circular setting of both the FILENAME and
		% FILEID properties.
		%
		function obj = set.immediate(obj, immediate)
			obj.immediate = immediate;
		end
		function obj = set.lastmessage(obj, lastmessage)
			obj.lastmessage = lastmessage;
		end
		
		
		%
		% NOCLUTTER means the log file will be delete if no
		% error has occurred. Setting this property to TRUE
		% automatically sets DELETE_ON_DESTROY to FALSE.
		%
		function obj = set.noclutter(obj, noclutter)
			obj.noclutter = noclutter;
			
			% Do not allow both NOCLUTTER & DELETE_ON_DESTROY
			if noclutter
				obj.delete_on_destroy = false;
			end
		end
		
		
		%
		% Set the operation status of the object
		%
		% Calling Sequence
		%   obj.status = STATUS
		%     Set the operating status, STATUS, of the object. Possible
		%     values are::
		%       0     - OK.
		%       1-255 - Error
		%
		% Parameters
		%   STATUS          in, required, type=integer
		%
		function obj = set.status(obj, status)
			if ~isempty(status)
				obj.status = uint8(status);
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
		function fileID = get.fileID(obj)
			fileID = obj.fileID;
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

