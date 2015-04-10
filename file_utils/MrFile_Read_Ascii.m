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
%     'nHeader' or 'DataStart'.
%
%     If the file has a footer, it is not removed from the data.
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
%   [DATA, INFO] = MrFile_Read_Ascii(FILENAME)
%     Return information about
%
%   DATA = MrFile_Read_Ascii(FILENAME, 'ParamName', ParamValue)
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
%       data =      Column1:  {{274637x1 cell}}
%                   Column2:  {[274637x1 double]}
%                   Column3:  {[274637x1 double]}
%                   Column4:  {[274637x1 double]}
%                   Column5:  {[274637x1 double]}
%                   Column6:  {[274637x1 double]}
%                   Column7:  {[274637x1 double]}
%                   Column8:  {[274637x1 double]}
%                   Column9:  {[274637x1 double]}
%                   Column10: {[274637x1 double]}
%                   Column11: {[274637x1 double]}
%                   Column12: {[274637x1 double]}
%                   Column13: {[274637x1 double]}
%                   Column14: {[274637x1 double]}
%                   Column15: {[274637x1 double]}
%                   Column16: {[274637x1 double]}
%                   Column17: {[274637x1 double]}
%                   Column18: {[274637x1 double]}
%                   Column19: {[274637x1 double]}
%                   Column20: {[274637x1 double]}
%                   Column21: {{274637x1 cell}}
%
%   2. Specify Groups
%     >> groups = [1,2,3,3,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,9];
%     >> data   = MrFile_Read_Ascii(filename, 'Groups', groups)
%      data = Column1:  {{274637x1 cell}}
%             Column2:  {[274637x1 double]}
%             Column6:  {[274637x4 double]}
%             Column10: {[274637x4 double]}
%             Column13: {[274637x3 double]}
%             Column16: {[274637x3 double]}
%             Column19: {[274637x3 double]}
%             Column20: {[274637x1 double]}
%             Column21: {{274637x1 cell}}
%
%   3. Specify names
%     >> column_names = {'UTC', 'TAI', 'q', 'q', 'q', 'q', 'w', 'w', 'w', 'w', ...
%                        'z', 'z', 'z', 'L', 'L', 'L', 'P', 'P', 'P', 'Nut', 'QF'}
%     >> data   = MrFile_Read_Ascii(filename, 'ColumnNames', column_names)
%      data =           L: {[274637x3 double]}
%                     Nut: {[274637x1 double]}
%                       P: {[274637x3 double]}
%                      QF: {{274637x1 cell}}
%                     TAI: {[274637x1 double]}
%                     UTC: {{274637x1 cell}}
%                       q: {[274637x4 double]}
%                       w: {[274637x4 double]}
%                       z: {[274637x3 double]}
%
%   4. Specify data types
%     >> column_names = {'UTC', 'TAI', 'q', 'q', 'q', 'q', 'w', 'w', 'w', 'w', ...
%                        'z', 'z', 'z', 'L', 'L', 'L', 'P', 'P', 'P', 'Nut', 'QF'}
%     >> column_types = {'char', 'double', 'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', 'single', 'single', ...
%                        'single', 'single', 'single', 'single', 'char'}
%     >> data = MrFile_Read_Ascii(filename, 'ColumnNames', column_names)
%      data =      L: {[274637x3 single]}
%                Nut: {[274637x1 single]}
%                  P: {[274637x3 single]}
%                 QF: {{274637x1 cell}}
%                TAI: {[274637x1 double]}
%                UTC: {{274637x1 cell}}
%                  q: {[274637x4 single]}
%                  w: {[274637x4 single]}
%                  z: {[274637x3 single]}
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-09      Written by Matthew Argall
%
function [dataOut, info] = MrFile_Read_Ascii(filename, varargin)

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
	nHeader      = [];
	nFooter      = 0;

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
				nHeader      = varargin{ii+1};
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
	
	% Get information about the file.
	if nargout > 1 || nColumns == 0 || ( isempty(data_start) && isempty(nHeader) ) || isempty(column_types)
		info = MrFile_Read_Ascii_Info(filename, delimiter, nHeader);
		
		% Number of header lines
		if ( isempty(data_start) && isempty(nHeader) )
			nHeader = info.nHeader;
		end
		
		% Number of columns
		if nColumns == 0
			nColumns = info.nCols;
		end
		
		% Type of data in each column
		if isempty(column_types)
			column_types = info.class;
		end
		
		% Clear the info structure
		if nargout < 2
			clear info
		end
	end
	
	% Check header and data information
	%   - If nHeader and data_start were omitted, assume no header
	%   - Otherwise
	%       nHeader    = data_start + 1
	%       data_start = nHeader    - 1
	if isempty(data_start);
		data_start = nHeader + 1;
	elseif isempty(nHeader)
		nHeader = data_start - 1;
	end
	
	% Number of columns
	assert( nColumns > 0, 'Cannot determine the number of data columns.' );
  
	if nHeader < 0
		warning( 'MrFile_Read:HeaderInfo', 'Cannot determine number of header lines. Assuming nHeader = 0.')
		nHeader    = 0;
		data_start = 1;
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
	
	% Open the file
	fileID = fopen(filename);

	% Read the data
	data = textscan(fileID, fmt,                      ...
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
		[~, iUniq, iCol] = unique(column_names);
		
		% Step through each unique value
		groups = zeros(1, nColumns);
		for ii = 1 : length(iUniq)
			groups( iUniq(iCol) == iUniq(ii) ) = ii;
		end
	end

%------------------------------------%
% Parse the Columns                  %
%------------------------------------%
	% Find groups
	[~, iUniq, iGroup] = unique(groups);
	nUniq              = length(iUniq);
	
	dataOut = struct();
	for ii = 1 : nUniq
		iThisGroup = find( iUniq(iGroup) == iUniq(ii) );
		thisName   = column_names{ iUniq(ii) };
		
		% Concatenate the groups together
		dataOut.( thisName ) = { [ data{ iThisGroup } ] };
		
		% Get rid of old data
		data( iThisGroup ) = { [] };
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
%                     'class'    Class of each column (double, integer, char)
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-09      Written by Matthew Argall
%
function info = MrFile_Read_Ascii_Info(filename, delimiter, nLines)

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
	parts = regexp(line, delimiter, 'split');
	nCols = length(parts);

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
		if nNew == nCols
			count = count + 1;
		else
			count = 0;
		end
		
		% Move to the next line
		header{ii} = line;
		nCols      = nNew;
		ii         = ii + 1;
	end
	
	% Close the file
	fclose(fileID);

%------------------------------------%
% Interpret Results                  %
%------------------------------------%
	% Did we succeed in finding the data?
	if count == nRepeat
		% Number of header lines
		%   ii is 1 + the total number of lines read (loop +1 on exit)
		%   nRepeat + 1 extra lines -- nRepeat matches + 1 initial line
		nHeader = ii - nRepeat - 2;
		header  = header(1:nHeader);
	else
		nHeader = -1;
		nCols   = 0;
		header  = [];
	end

%------------------------------------%
% Determine Field Types              %
%------------------------------------%
	type = cell(1, nCols);

	% Step through each column to determine its type
	for ii = 1 : nCols
		
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
	info = struct( 'header',  { header },  ...
	               'nHeader', nHeader, ...
		             'nCols',   nCols,   ...
								 'class',   { type } );
end