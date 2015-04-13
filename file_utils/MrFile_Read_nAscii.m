%
% Name
%   MrFile_Read_nAscii
%
% Purpose
%   A wrapper for MrFile_Read_Ascii. Read any number of ASCII files and
%   append data in like-columns. All files must have the same header,
%   footer, formatting, and number of columns as the first file given.
%
% Calling Sequence
%   DATA = MrFile_Read_Ascii(FILENAMES)
%     Read date from files FILENAMES into a data structure DATA.
%
% Parameters
%   FILENAMES       in, required, type=char/cell
%   'ParamName'     in, optional, type=depends
%                   Any parameter name-value pair accepted by
%                     MrFile_Read_Ascii.m
%
% Returns
%   DATA            out, required, type=structure
%
% Examples
%   Given the files
%     >> file1 = 'MMS2_DEFATT_2015078_2015079.V00');
%     >> file2 = 'MMS2_DEFATT_2015079_2015080.V00');
%     >> files = {file1 file2};
%
%   With column names
%     >> column_names = {'UTC', 'TAI', 'q', 'q', 'q', 'q', 'w', 'w', 'w', 'w', ...
%                        'z', 'z', 'z', 'L', 'L', 'L', 'P', 'P', 'P', 'Nut', 'QF'};
%
%   Read data from both files
%     >> data = MrFile_Read_nAscii(files, ..
%                                  'ColumnNames', column_names, ...
%                                  'nFooter',     1);
%       data = UTC: {543839x1 cell}
%              TAI: [543839x1 double]
%                q: [1367747x4 double]
%                w: [1367747x4 double]
%                z: [1093111x3 double]
%                L: [1093111x3 double]
%                P: [1093111x3 double]
%              Nut: [543839x1 double]
%               QF: {543839x1 cell}
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-10      Written by Matthew Argall
%
function data = MrFile_Read_nAscii(filenames, varargin)

	% Number of files given
	if ischar(filenames)
		filenames = { filenames };
		nFiles = 1;
	else
		nFiles = length(filenames);
	end
	
	% Start by reading the first file
	[data, file_info] = MrFile_Read_Ascii(filenames{1}, varargin{:});

	% Now loop though all other files
	for ii = 2 : nFiles
		% Read the data file
		%   - By supplying the "info" information, MrFile_Read_Ascii
		%     will not have to search for the information within the file
		%     before rewinding and reading the data.
		temp = MrFile_Read_Ascii(filenames{ii}, ...
		                         'ColumnNames', file_info.ColumnNames, ...
		                         'nHeader',     file_info.nHeader, ...
		                         'nFooter',     file_info.nFooter, ...
		                         'ColumnTypes', file_info.ColumnTypes);
		
		% Append data
		%   - MrFile_Read_Ascii concatenates along the first dimension.
		for jj = 1 : file_info.nCols
			data.( file_info.ColumnNames{jj} ) ...
				= vertcat( data.( file_info.ColumnNames{jj} ), temp.( file_info.ColumnNames{jj} ) );
		end
	end
end
