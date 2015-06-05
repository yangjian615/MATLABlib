%
% Name
%   MrFile_Read_Ascii
%
% Purpose
%   Read a file, automatically skipping over header information and
%   determining the datatypes of each column.
%
%   NOTE:
%     Determining header information works if the delimiter between
%     words in the header (whitespace) is the same as the delimiter between
%     columns (again, whitespace). If this is not the case, specify
%     'nHeader' or 'DataStart' along with 'ColumnNames', 'ColumnTypes',
%     and/or 'Groups'.
%
%     The footer is removed after reading through to the end of the file.
%     This could cause problems.
%
% Calling Sequence
%   DATA = MrFile_Read_Ascii(FILENAME)
%     Read all data within the ASCII file FILENAME. Data is returned in a
%     structure, one field per column, with field names Column#, where #
%     represents the column number of the data file. Header information is
%     determined by reading the file until 10 consecutive lines with the
%     same number of columns are found. Data types are determined by
%     splitting a line of data and looking for numbers, letters, etc.
%
%   [DATA, FILE_INFO] = MrFile_Read_Ascii(FILENAME)
%     Return information about file.
%
%   [__] = MrFile_Read_Ascii(FILENAME, 'ParamName', ParamValue)
%     Use any of the parameter name-value pairs listed below.
%
% Parameters
%   FILENAME        in, required, type=char
%   'ColumnNames'   in, optional, type=char/cell, default='Column#'
%                   Names that represent the data in each column. These
%                     will become the fields in the output data structure.
%                     If fields are grouped together, repeat the column
%                     name for each column in the group.
%   'ColumnTypes'   in, optional, type=char/cell, default='double'
%                   The MATLAB datatype representing each column. E.g.
%                     'char', 'double', 'int32'.
%   'DataStart'     in, optional, type=integer, default=nHeader+1
%                   The line at which to begin reading data. It serves as
%                     an alternate means of setting 'nHeader'.
%   'nHeader'       in, optional, type=integer, default=0
%                   Number of header lines in the file. It is assumed that
%                     nHeader = DataStart - 1;
%   'nFooter'       in, optional, type=integer, default=0
%                   Number of footer lines in the file. Footer lines are
%                     removed from the data AFTER reading to the end of the
%                     file. This may or may not cause problems.
%   'Delimiter'     in, optional, type=char, default='\n,\b, '
%                   A comma-separated list of characters that represent
%                     delimiters between data columns.
%   'Groups'        in, optional, type=integer, default=1:1:nColumns
%                   The group number to which each column belongs. Columns
%                     that share a group will be concatenated together. To
%                     group two or more columns together, assign them the
%                     same group number.
%
% Returns
%   DATAOUT         out, required, type=structure
%   FILE_INFO       out, optional, type=structure
%
% Examples
%   Using the file
%     >> filename = fullfile(root, 'MMS2_DEFATT_2015079_2015080.V00');
%
%   The data has 49 header lines and the data looks like:
%     COMMENT   Time (UTC)    Elapsed Sec      q1       q2       q3       qc     wX     wY     wZ   w-Phase   Z-RA    Z-Dec Z-Phase   L-RA    L-Dec L-Phase   P-RA    P-Dec P-Phase    Nut    QF
%     2015-079T00:59:04.312 1805504379.312  0.26383  0.21707 -0.58189  0.73802  0.000  0.000 18.000 284.283 271.192  50.044 284.283 271.188  50.045 284.283 271.183  50.046 284.283   0.003  CNV
%
%   1. Read all records
%     >> data = MrFile_Read_Ascii(filename)
%       data      1x1             116452106  struct
%       data =      Column1:  {{1x274637 cell}}
%                   Column2:  {[1x274637 double]}
%                   Column3:  {[1x274637 double]}
%                   Column4:  {[1x274637 double]}
%                   Column5:  {[1x274637 double]}
%                   Column6:  {[1x274637 double]}
%                   Column7:  {[1x274637 double]}
%                   Column8:  {[1x274637 double]}
%                   Column9:  {[1x274637 double]}
%                   Column10: {[1x274637 double]}
%                   Column11: {[1x274637 double]}
%                   Column12: {[1x274637 double]}
%                   Column13: {[1x274637 double]}
%                   Column14: {[1x274637 double]}
%                   Column15: {[1x274637 double]}
%                   Column16: {[1x274637 double]}
%                   Column17: {[1x274637 double]}
%                   Column18: {[1x274637 double]}
%                   Column19: {[1x274637 double]}
%                   Column20: {[1x274637 double]}
%                   Column21: {{1x274637 cell}}
%
%   2. Specify Groups
%     >> groups = [1,2,3,3,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,9];
%     >> data = MrFile_Read_Ascii(filename, 'Groups', groups)
%      data =     Column1: {1x274637 cell}
%                 Column2: [1x274637 double]
%                 Column3: [4x274637 double]
%                 Column4: [4x274637 double]
%                 Column5: [3x274637 double]
%                 Column6: [3x274637 double]
%                 Column7: [3x274637 double]
%                 Column8: [1x274637 double]
%                 Column9: {1x274637 cell}
%
%   3. Specify names
%     >> column_names = {'UTC', 'TAI', 'q', 'q', 'q', 'q', 'w', 'w', 'w', 'w', ...
%                        'z', 'z', 'z', 'L', 'L', 'L', 'P', 'P', 'P', 'Nut', 'QF'}
%     >> data = MrFile_Read_Ascii(filename, 'ColumnNames', column_names)
%      data =    UTC: {1x274637 cell}
%                TAI: [1x274637 double]
%                  q: [4x274637 double]
%                  w: [4x274637 double]
%                  z: [3x274637 double]
%                  L: [3x274637 double]
%                  P: [3x274637 double]
%                Nut: [1x274637 double]
%                 QF: {1x274637 cell}
%
%   4. Specify data types
%     >> column_names = {'UTC', 'TAI', 'q', 'q', 'q', 'q', 'w', 'w', 'w', 'w', ...
%                        'z', 'z', 'z', 'L', 'L', 'L', 'P', 'P', 'P', 'Nut', 'QF'}
%     >> column_types = {'char', 'double', 'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', 'char'}
%     >> data = MrFile_Read_Ascii(filename, 'ColumnNames', column_names)
%      data =    UTC: {{274637x1 cell}}
%                TAI: {[274637x1 double]}
%                  q: {[274637x4 single]}
%                  w: {[274637x4 single]}
%                  z: {[274637x3 single]}
%                  L: {[274637x3 single]}
%                  P: {[274637x3 single]}
%                Nut: {[274637x1 single]}
%                 QF: {{274637x1 cell}}
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-09      Written by Matthew Argall
%   2015-04-10      Field names are returned in same order as column names. - MRA
%   2015-04-11      Changed INFO variable to FILE_INFO to avoid conflict
%                     with MATLAB's info() [ and finfo() ] function. - MRA
%   2015-06-03      Return row vectors. Three grouped columns become 3xN array. - MRA
%
function [dataOut, file_info] = MrFile_Read_Ascii(filename, varargin)

	% Make sure the file exists
	assert(exist(filename, 'file') == 2, ['File does not exist: "' filename '".'] )

	% Defaults
	column_names = [];
	column_types = [];
	comment      = '';
	data_start   = [];
	delimiter    = '\t, ,\b';
	fmt          = '';
	groups       = [];
	nFooter      = 0;
	nHeader      = [];
	file_info    = [];

	% Check for optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2: nOptArgs
		switch varargin{ii}
			case 'ColumnNames'
				column_names = varargin{ii+1};
			case 'ColumnTypes'
				column_types = varargin{ii+1};
			case 'CommentSymbol'
				comment      = varargin{ii+1};
			case 'DataStart'
				data_start   = varargin{ii+1};
			case 'Delimiter'
				delimiter    = varargin{ii+1};
			case 'FormatSpec'
				fmt          = varargin{ii+1};
			case 'Groups'
				groups       = varargin{ii+1};
			case 'nFooter'
				nFooter      = varargin{ii+1};
			case 'nHeader'
				nHeader      = varargin{ii+1};
			otherwise
				error( ['Unknown parameter "' varargin{ii} '".'] );
		end
	end
	
	% Number of columns
	if isempty(column_names)
		if isempty(column_types)
			% Groups
			if isempty(groups)
				nColumns = 0;
			else
				nColumns = length(groups);
			end
		% Column types
		else
			if ischar(column_types)
				nColumns = 1;
			else
				nColumns = length(column_types);
			end
		end
	% Column names
	else
		if ischar(column_names)
			nColumns = 1;
		else
			nColumns = length(column_names);
		end
	end
	
	% Get information about the file. Read info if we need
	%   - Output
	%   - Number of columns
	%   - Number of lines
	%   - Number of header lines
	%   - Data types of each column
	if nColumns == 0 || ( isempty(data_start) && isempty(nHeader) ) || isempty(column_types)
		file_info = MrFile_Read_Ascii_Info(filename, delimiter, nHeader);
		
		% Number of header lines
		if ( isempty(data_start) && isempty(nHeader) )
			nHeader = file_info.nHeader;
		end
		
		% Number of columns
		if nColumns == 0
			nColumns = file_info.nColumns;
		end
		
		% Type of data in each column
		if isempty(column_types)
			column_types = file_info.ColumnTypes;
		end
		
		% Clear the info structure
		if nargout < 2
			clear file_info
		end
	end
	
	% Was data_start given instead?
	if isempty(nHeader)
		nHeader = data_start - 1;
	end
	
	% Number of columns
	assert( nColumns > 0, 'Cannot determine the number of data columns.' );
  
	if nHeader < 0
		warning( 'MrFile_Read:HeaderInfo', 'Cannot determine number of header lines. Assuming nHeader = 0.')
		nHeader    = 0;
	end
	
	% Column types
	if isempty(column_types)
		column_types    = repmat('', 1, nColumns);
		column_types{:} = 'double';
	end

%------------------------------------%
% Read the File                      %
%------------------------------------%
	
	% Convert types to a format string
	if isempty(fmt)
		for ii = 1 : nColumns
			switch lower(column_types{ii})
				case 'char'
					fmt = [fmt '%s '];
				case 'double'
					fmt = [fmt '%f64 '];
				case 'single'
					fmt = [fmt '%f32 '];
				case 'uint'
					fmt = [fmt '%u8 '];
				case 'uint16'
					fmt = [fmt '%u16 '];
				case 'uint32'
					fmt = [fmt '%u32 '];
				case 'uint64'
					fmt = [fmt '%u64 '];
				case 'int'
					fmt = [fmt '%d8 '];
				case 'int16'
					fmt = [fmt '%d16 '];
				case 'int32'
					fmt = [fmt '%d32 '];
				case 'int64'
					fmt = [fmt '%d64 '];
				otherwise
					error( ['Data type not supported: "' column_types{ii} '".'] )
			end
		end
	end
	
	%
	% NOTE:
	%   It may be faster to read each line individually. I have not figured
	%   out how to do that. My attempts to use fscanf() failed because it
	%   requires the format spec to be exactly the same as the data and, as
	%   far as I can tell, does not permit multiple data types.
	%
	%   MrFile_Read_Ascii_Info() contains a code block to determine the total
	%   number of lines. 'nLines' can be an optional parameter name. If not
	%   given, MrFile_Read_Ascii_Info will determine it. Then, with nHeader,
	%   nLines, and nFooter, all data can be captured.
	%
	%   See MrFile_Read_Ascii_GetData (below) for my latest attempt.
	%
	
	% Open the file
	fileID = fopen(filename);

	% Read the data
	%   - Data is returned in column vectors. Will transpose later.
	data = textscan(fileID, fmt,                     ...
	               'CommentStyle',        comment,   ...
	               'Delimiter',           delimiter, ...
	               'HeaderLines',         nHeader,   ...
	               'MultipleDelimsAsOne', true);

	% Close the file
	fclose(fileID);

%------------------------------------%
% Group Columns                      %
%------------------------------------%
	
	% If neither names nor groups were given
	%   - Put everything in its own group.
	if isempty(column_names) && isempty(groups)
		groups = 1:1:nColumns;
	end
	
	% If column names were not given
	%   - Use the group number as the column identifier.
	%   - At this stage, both groups and names cannot be empty because of the
	%     last step.
	if isempty(column_names)
		column_names = num2cell( groups );
		fmt_cell     = repmat({'%d'}, 1, nColumns);
		column_names = strcat('Column', cellfun(@num2str, column_names, fmt_cell, 'UniformOutput', false) );
	end
	
	% If names were given, but not groups
	%   - Create groups from the unique column names.
	if isempty(groups)
		% Find unique columns
		%   - UNAMES( ICOL ) reproduces COLUMN_NAMES (unsorted).
		%   - COLUMN_NAMES( IUNIQ ) reporduces UNAMES (sorted).
		%   - COLUMN_NAMES( IUNIQ ( ICOL ) ) reproduces COLUMN_NAMES (unsorted)
		[~, iUniq, iCol] = unique(column_names);
		
		% Keep output order the same as input order.
		%   - IUNIQ are indices of the unique, sorted elements of COLUMN_NAMES.
		%   - Sort IUNIQ to return to unsorted order
		siUniq = sort(iUniq);
		
		% Step through each unique value
		groups = zeros(1, nColumns);
		for ii = 1 : length(iUniq)
			groups( iUniq(iCol) == siUniq(ii) ) = ii;
		end
	end

%------------------------------------%
% Parse the Columns                  %
%------------------------------------%
	% Find groups
	[~, iUniq, iGroup] = unique(groups);
	nUniq              = length(iUniq);

	% Concatenate the data into their groups.
	dataOut = struct();
	for ii = 1 : nUniq
		iThisGroup = find( iUniq(iGroup) == iUniq(ii) );
		thisName   = column_names{ iUniq(ii) };
		
		% Concatenate the groups together
		%    - Save columns as row vectors -- 3 grouped columns becomes 3xN array
		dataOut.( thisName ) = [ data{ iThisGroup } ]';
		
		% Footer?
		if nFooter > 0
			dataOut.(thisName) = dataOut.(thisName)(:, 1:end-nFooter);
		end
		
		% Get rid of old data
		data( iThisGroup ) = { [] };
	end

%------------------------------------%
% Return Info About File             %
%------------------------------------%
	if nargout > 1
		if isempty(file_info)
			file_info = struct( 'header',      [],               ...
			                    'nCols',       nColumns,         ...
			                    'nHeader',     nHeader,          ...
			                    'nFooter',     nFooter,          ...
			                    'ColumnNames', { column_names }, ...
			                    'ColumnTypes', { column_types } );
		else
			file_info.nHeader         = nHeader;
			file_info.nCols           = nColumns;
			file_info.ColumnTypes     = column_types;
			file_info.('ColumnNames') = column_names;
			file_info.('nFooter')     = nFooter;
		end
	end
end


%
% Name
%   MrFile_Read_Ascii_Info
%
% Purpose
%   Get information about a file.
%
% Calling Sequence
%   FILE_INFO = MrFile_Read_Ascii_Info(FILENAME)
%     Obtain information about the ASCII file with name FILENAME. Return a
%     structure with tags indicated below.
%
%   FILE_INFO = MrFile_Read_Ascii_Info(FILENAME, DELIMITER)
%     Indicate fields are separated by DELIMITER.
%
%   FILE_INFO = MrFile_Read_Ascii_Info(FILENAME, DELIMITER, NLINES)
%     Maximum number of lines to search for data.
%
% Parameters
%   FILENAME        in, required, type=char
%   DELIMITER       in, optional, type=char, default='\n,\b, '
%   NLINES          in, optional, type=integer, default=100
%
% Returns
%   FILE_INFO       out, required, type=structure
%                   Has fields
%                     'ColumnTypes' Class of each column (double, integer, char)
%                     'header'      The file header, one line per cell.
%                     'nColumns'    Number of data columns
%                     'nHeader'     Number of header lines
%                     'nLines'      Number of lines in the file
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-09      Written by Matthew Argall
%
function file_info = MrFile_Read_Ascii_Info(filename, delimiter, nLines)

	if nargin < 3 || isempty(nLines)
		nLines = 100;
	end
	
	if nargin < 2 || isempty(delimiter)
		delimiter = '\n,\b, ';
	end
	
	% Number of lines required to repeat before we say that we have found the
	% data.
	nRepeat = 10;
	
	% Create a regular expression from the delimiters
	%   - Matches any sequency of one or more delimiters
	delimiter = [ '[' regexprep(delimiter, ',', '|') ']+' ];

%------------------------------------%
% Find Start of Data                 %
%------------------------------------%
	
	% Store each line of the header
	header = cell(1, nLines);
	
	% Open the file
	fileID = fopen(filename);
	
	% Read the first line of the file
	line      = fgetl(fileID);
	header{1} = line;

	% Find how many columns (words) the line has
	parts    = regexp(line, delimiter, 'split');
	nColumns = length(parts);

	% Start reading files
	%   - Search for nRepeat consecutive lines with the same number of words.
	ii    = 2;
	count = 0;
	while count < nRepeat && ii <= nLines && ~feof(fileID)
		% Get another line
		line = fgetl(fileID);

		% Find how many words the line has
		parts = regexp(line, delimiter, 'split');
		nNew  = length(parts);
		
		% Same number of words?
		if nNew == nColumns
			count = count + 1;
		else
			count = 0;
		end
		
		% Move to the next line
		header{ii} = line;
		nColumns   = nNew;
		ii         = ii + 1;
	end
	
	% Save the line number for later.
	lineNumber = ii;

%------------------------------------%
% Number of Lines in the File        %
%------------------------------------%
	%
	% Adds significant time to process
	%
	nTotal = [];

% 	% Count the number of lines
% 	if ~feof(fileID)
% 		while ~feof(fileID)
% 			line = fgetl(fileID);
% 			ii = ii + 1;
% 		end
% 	end
% 	
% 	% Close the file
% 	fclose(fileID);
% 	
% 	% Number of lines in the file
% 	nTotal = ii - 1;

%------------------------------------%
% Interpret Results                  %
%------------------------------------%
	% Did we succeed in finding the data?
	if count == nRepeat
		% Number of header lines
		%   lineNumber is 1 + the number of lines read during the header search
		%   nRepeat + 1 extra lines -- nRepeat matches + 1 initial line
		nHeader = lineNumber - nRepeat - 2;
		header  = header(1:nHeader);
	else
		nHeader  = -1;
		nColumns = 0;
		header   = [];
	end

%------------------------------------%
% Determine Field Types              %
%------------------------------------%
	type = cell(1, nColumns);

	% Step through each column to determine its type
	for ii = 1 : nColumns
		
		% Integer
		%   (+-) #####
		if ~isempty(regexp(parts{ii}, '^(+|-)?[0-9]+$', 'once'))
			type{ii} = 'int32';
			
		% Float
		%   (+-) #####(.#####) (eE (+-) ####(.####))
		%   This will capture integers, too, so check integers first!
		elseif ~isempty(regexp(parts{ii}, '^(+|-)?[0-9]+(\.[0-9]*)?(e|E)?((?<=[eE])[+-]?[0-9]+(\.[0-9]*)?)?$', 'once'))
			type{ii} = 'double';
			
		% Character
		else
			type{ii} = 'char';
		end
	end

%------------------------------------%
% Fill the Output Structure          %
%------------------------------------%
	file_info = struct( 'header',      { header },  ...
	                    'nColumns',    nColumns,    ...
	                    'nHeader',     nHeader,     ...
	                    'nLines',      nTotal,      ...
	                    'ColumnTypes', { type } );
end


%
% Name
%   MrFile_Read_Ascii_Info
%
% Purpose
%   Get information about a file.
%
% Calling Sequence
%   INFO = MrFile_Read_Ascii_Info(FILENAME)
%     Obtain information about the ASCII file with name FILENAME. Return a
%     structure with tags indicated below.
%
%   INFO = MrFile_Read_Ascii_Info(FILENAME, DELIMITER)
%     Indicate fields are separated by DELIMITER.
%
%   INFO = MrFile_Read_Ascii_Info(FILENAME, DELIMITER, NLINES)
%     Maximum number of lines to search for data.
%
% Parameters
%   FILENAME        in, required, type=char
%   DELIMITER       in, optional, type=char, default='\n,\b, '
%   NLINES          in, optional, type=integer, default=100
%
% Returns
%   INFO            out, required, type=structure
%                   Has fields
%                     'nCols'    Number of data columns
%                     'nHeader'  Number of header lines
%                     'nLines'   Number of lines in the file
%                     'class'    Class of each column (double, integer, char)
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-09      Written by Matthew Argall
%
function info = MrFile_Read_Ascii_GetData(fileID, nLines, type, group, nHeader, nFooter)

	nColumns = length(group);
	
	% Convert types to a format string
	for ii = 1 : nColumns
		switch lower(type{ii})
			case 'char'
				fmt = [fmt '%s '];
			case 'double'
				fmt = [fmt '%f64 '];
			case 'single'
				fmt = [fmt '%f32 '];
			case 'uint'
				fmt = [fmt '%u8 '];
			case 'uint16'
				fmt = [fmt '%u16 '];
			case 'uint32'
				fmt = [fmt '%u32 '];
			case 'uint64'
				fmt = [fmt '%u64 '];
			case 'int'
				fmt = [fmt '%d8 '];
			case 'int16'
				fmt = [fmt '%d16 '];
			case 'int32'
				fmt = [fmt '%d32 '];
			case 'int64'
				fmt = [fmt '%d64 '];
			otherwise
				error( ['Data type not supported: "' type{ii} '".'] )
		end
	end
	
	% Find unique groups
	[~, iUniq, igroup] = unique(group);
	nUniq = length(iUniq);
	
	% Information about the groups
	%   - Indices of each group
	%   - Number of copies in each group
	%   - Datatype of each group
	%   - Cell for each group of data
	iGroup = cell(1, nUniq);
	nGroup = zeros(1, nUniq);
	gType  = cell(1, nUniq);
	data   = cell(1, nUniq);
	
	% Get the information
	for ii = 1 : nUniq
		iGroup{ii} = find( iUniq(igroup) == iUniq(ii) );
		nGroup(ii) = length( igroup{ii} );
		gType{ii}  = type{ iUniq(ii) };
		gName{ii}  = name{ iUniq(ii) };
		
		% Allocate data
		if lower(gType{ii}, 'char')
			data{ii} = cell(nGroup(ii), nLines);
		else
			data{ii} = zeros(nGroup(ii), nLines, gType{ii});
		end
	end
	
	% Skip over the header
	line = '';
	for ii = 1 : nHeader
		line = fgetl(fileID);
	end
	
	% Read the data
	%   - fscanf() appears to require an exact format code and for all data
	%     to be of the same class.
	%   - fgetl() reads a line which can be broken into parts with regexp()
	%     and DELIMITER. The result is a cell array for every line, and
	%     formatting that would be a lot of work.
	for ii = 1 : nLines
		% Read one line of data
		line1 = fscanf(fileID, fmt);
		
		% Parse the line
		line2 = fgetl(fileID);
		parts = regexp(line2, delimiter, 'split');
		
	end
end