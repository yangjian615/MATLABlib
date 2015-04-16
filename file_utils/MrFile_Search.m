%
% Name
%   MrFile_Search
%
% Purpose
%   Find files on the file system. Filter by time interval and version.
%
% Calling Sequence
%   FILES = MrFile_Search(FILENAME)
%     Find all files with name matching FILENAME. FILENAME can include a
%     directory path as well as any token recognized by MrToken.
%
%     Note that the "%(" and "%)" tokens can be used, for example, to
%     include additional regular expressions that help to narrow the
%     search.
%
%   [__, NFILES] = MrFile_Search(FILENAME)
%     Return the number of files found.
%
%   [__] = MrFile_Search(__, 'ParamName', ParamValue)
%     Filter results using any of the parameter name-value pairs below.
%
% Parameters
%   FILENAME        in, required, type = char
%   'Closest'       in, optional, type = boolean, default = false
%                   Find the nearest file with a start time <= TStart.
%                     This option is ignored unless TStart is specified.
%                     TEnd is also given, the file that starts <= TEnd
%                     will serve as the upper limit of files times. All
%                     files within the range are returned.
%   'Directory'     in, optional, type = char, default = pwd()
%                   Look in this directory instead of the present working
%                     directory. The directory path may include tokens
%                     recognized by MrTokens.m. If FILENAME includes a
%                     directory path, this value will replace it.
%   'TEnd'          in, optional, type = char, default = ''
%                   An ISO-8601 string specifying the end of an interval
%                     of interest. Any file containing this end time will
%                     be included in the results. If this parameter is
%                     provided, FILENAME must contain time tokens. If
%                     FILENAME does not contain both a start and end time
%                     outlining the data interval contained in the file,
%                     the search results may include files that do not
%                     contain TEnd.
%   'TimeOrder'     in, optional, type = char, default = '%Y%M%d%H%m%S'
%                   Filtering files by time with 'TStart' and 'TEnd' is
%                     done by converting dates to integers and performing
%                     math operations. As such, the times in FILENAME and
%                     in 'TStart' and 'TEnd' must be converted into a
%                     format where the slowest (fastest) changing time
%                     element is to the left (right). If FILENAME, 'TStart'
%                     and 'TEnd' are not already in such a format, set this
%                     parameter to a token pattern recognized by
%                     MrTimeParser so that they can be rearranged.
%   'TStart'        in, optional, type = char, default = ''
%                   An ISO-8601 string specifying the start of an interval
%                     of interest. Any file containing this start time will
%                     be included in the results. If this parameter is
%                     provided, FILENAME must contain time tokens. If
%                     FILENAME does not contain both a start and end time
%                     outlining the data interval contained in the file,
%                     the search results may include files that do not
%                     contain TStart.
%   'TPattern'      in, optional, type = char, default = '%Y-%M-%dT%H:%m:%S'
%                   If 'TStart' and 'TEnd' are not ISO-8601 format, then
%                     use this parameter to specify their token pattern.
%                     Note that this pattern must be able to be broken down
%                     into 'TimeOrder'.
%   'Newest'        in, optional, type = boolean
%                   Return only the newest version of each file found.
%                     If neither 'Version' and 'Newest' are specified, then
%                     'Newest' will be set to true.
%   'Version'       in, optional, type = char, default = '([0-9]+)\.([0-9]+)\.([0-9]+)'
%                   Return a specific version of a files.
%   'VersionRegex'  in, optional, type = char, default = ''
%                   Specify how the version can be dissected. See
%                     MrFile_VersionCompare.m for more details.
%
% Returns:
%   FILES           out, required, type = cell
%
% Examples
%
%-------------------------------%
%   CLUSTER data example:       %
%-------------------------------%
%
%   Given the directory and file names
%     >> directory = '/Users/argall/Documents/Work/Data/Cluster/20010705_060000_070000';
%     >> fname     = 'C1_CP_CIS-CODIF_HS_H1_MOMENTS__20010705_060000_20010705_070000_V080206.cdf';
%
%   Create a directory, file name, and version pattern
%     >> dpattern = '/Users/argall/Documents/Work/Data/Cluster/%Y%M%d_%H%m%S_%H%m%S';
%     >> fpattern = 'C1_CP_CIS-CODIF_HS_H1_MOMENTS__%Y%M%d_%H%m%S_%Y%M%d_%H%m%S_V*.cdf';
%     >> vRegex   = 'V([0-9]{2})([0-9]{2})([0-9]{2})';
%     >> pattern  = fullfile(dpattern, fpattern);
%
%   The possible files to find are::
%     /Users/argall/Documents/Work/Data/Cluster/20010705_060000_070000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20010705_060000_20010705_070000_V080206.cdf
%     /Users/argall/Documents/Work/Data/Cluster/20020318_143000_153000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20020318_143000_20020318_153000_V080213.cdf
%     /Users/argall/Documents/Work/Data/Cluster/20040325_073000_090000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040325_073000_20040325_090000_V080213.cdf
%     /Users/argall/Documents/Work/Data/Cluster/20040406_030000_060000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040406_030000_20040406_060000_V080213.cdf
%
%   1. Find the newest verion of each file
%     >> files   = MrFile_Search(pattern, ...
%                                'VersionRegex', vRegex);
%     >> vertcat(files{:})
%       /Users/argall/Documents/Work/Data/Cluster/20010705_060000_070000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20010705_060000_20010705_070000_V080206.cdf
%       /Users/argall/Documents/Work/Data/Cluster/20020318_143000_153000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20020318_143000_20020318_153000_V080213.cdf
%       /Users/argall/Documents/Work/Data/Cluster/20040325_073000_090000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040325_073000_20040325_090000_V080213.cdf
%       /Users/argall/Documents/Work/Data/Cluster/20040406_030000_060000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040406_030000_20040406_060000_V080213.cdf
%
%   2. Find files that begin at or before 2004-03-25T07:30:00Z
%     >> files   = MrFile_Search(pattern,                                ...
%                                'TStart',       '2004-03-25T07:30:00Z', ...
%                                'VersionRegex', vRegex);;
%     >> vertcat(files{:})
%       /Users/argall/Documents/Work/Data/Cluster/20010705_060000_070000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20010705_060000_20010705_070000_V080206.cdf
%       /Users/argall/Documents/Work/Data/Cluster/20020318_143000_153000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20020318_143000_20020318_153000_V080213.cdf
%       /Users/argall/Documents/Work/Data/Cluster/20040325_073000_090000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040325_073000_20040325_090000_V080213.cdf
%
%   3. Also exclude files that end before 2004-03-26T00:00:00Z
%     >> files   = MrFile_Search(pattern,                                ...
%                                'TStart',       '2004-03-25T07:30:00Z', ...
%                                'TEnd',         '2004-03-26T00:00:00Z', ...
%                                'VersionRegex', vRegex);
%     >> vertcat(files{:})
%       /Users/argall/Documents/Work/Data/Cluster/20040325_073000_090000/C1_CP_CIS-CODIF_HS_H1_MOMENTS__20040325_073000_20040325_090000_V080213.cdf
%
%-------------------------------%
%   MMS data example:           %
%-------------------------------%
%
%   Given the directory and file names
%    >> directory = '/Users/argall/Documents/Work/Data/MMS/DFG/';
%    >> fname     = 'mms2_dfg_f128_l1a_20150317_v0.3.1.cdf';
%
%  Create the directory and file name token patterns
%    >> dpattern = directory;
%    >> fpattern = 'mms2_dfg_f128_l1a_%Y%M%d_v*.cdf';
%    >> pattern = fullfile(dpattern, fpattern);
%
%  1. Find all files
%    >> files = MrFile_Search(pattern, 'Newest', false);
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.0.3.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.3.1.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150319_v0.3.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150320_v0.2.0.cdf
%
%  2. Select only the most recent versions of the files
%    >> files = MrFile_Search(pattern);
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.3.1.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150319_v0.3.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150320_v0.2.0.cdf
%
%  3. Select version v0.2.0
%    >> files = MrFile_Search(pattern, 'Version', 'v0.2.0');
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150320_v0.2.0.cdf
%
%  4. Filter by time interval with TStart. Because there is no end-time in the
%     file name, this will return all files that start at or before 'TStart'.
%     Also, the file name contains only year, month, and day, so 'TimeOrder'
%     must be changed.
%    >> files = MrFile_Search(pattern, ...
%                             'TStart',    '2015-03-18T04:00:00Z', ...
%                             'TimeOrder', '%Y%M%d');
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.3.1.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%
%  5. Pick the file that starts closest to TStart
%    >> files = MrFile_Search(pattern, ...
%                             'Closest',   true, ...
%                             'TStart',    '2015-03-18T04:00:00Z', ...
%                             'TimeOrder', '%Y%M%d');
%    >> files
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%
%  6. Filter by TStart and TEnd. Again, because the file name did not
%     include an end time, the filter returns all files for which
%     there is a possibility of containing data, i.e. those for which
%     the start time occurs before both TStart and TEnd (see comments in code).
%    >> files = MrFile_Search(pattern, ...
%                             'TStart',    '2015-03-18T04:00:00Z', ...
%                             'TEnd',      '2015-03-19T11:00:00Z', ...
%                             'TimeOrder', '%Y%M%d');
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.3.1.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150319_v0.3.0.cdf
%
%  7. Specify 'Closest' with TStart and TEnd. This time, files are
%     filtered by the closest file start <= TStart and the closest
%     file start <= TEnd. All files between the two are returned.
%     Note that if TEnd = '2015-03-19T00:00:00Z' and you wanted
%     data only until 11:59:59.999 on 2015-03-18, the file for
%     2015-03-19 would still be returned. Time intervals are
%     inclusive on both ends to account for date rounding in file.
%     names.
%    >> files = MrFile_Search(pattern, ...
%                             'Closest',   true, ...
%                             'TStart',    '2015-03-18T04:00:00Z', ...
%                             'TEnd',      '2015-03-19T11:00:00Z', ...
%                             'TimeOrder', '%Y%M%d');
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150319_v0.3.0.cdf
%
%  8. Filter by TStart and TEnd. Specify a time pattern. Note how 'TPattern'
%     has all components necessary to form 'TimeOrder'. If this were not
%     the case, an error would occur.
%    >> files = MrFile_Search(pattern, ...
%                             'TStart',    '2015-078T00:00:00Z', ...
%                             'TEnd',      '2015-079T00:00:00Z', ...
%                             'TPattern'   '%Y-%DT%H:%m:%S', ...
%                             'TimeOrder', '%Y%M%d');
%    >> vertcat(files{:})
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150317_v0.3.1.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150318_v0.2.0.cdf
%      /Users/argall/Documents/Work/Data/MMS/DFG/mms2_dfg_f128_l1a_20150319_v0.3.0.cdf
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-08      Written by Matthew Argall
%   2015-04-10      Changed TStart and TEnd filter to be inclusive on both
%                     ends of the interval in case file times round. - MRA
%   2015-04-12      Modified the behavior of 'Closest' to incorporate 'TEnd'.
%                     added MMS example to show functionality. - MRA
%   2015-04-13      Return a string if only 1 file is found. Added nFiles as
%                     output argument. - MRA
%   2015-04-14      Prevent errors if 0 files are found. - MRA
%
function [filesFound, nFiles] = MrFile_Search(filename, varargin)

	[inDir, inFile, inExt] = fileparts(filename);
	inFile                 = [inFile inExt];

%------------------------------------%
% Inputs                             %
%------------------------------------%
	
	% Defaults
	closest   = false;
	newest    = [];
	directory = '';
	timeOrder = '%Y%M%d%H%m%S';
	tstart    = '';
	tend      = '';
	tpattern  = '%Y-%M-%dT%H:%m:%S';
	version   = '';
	vRegex    = '([0-9]+)\.([0-9]+)\.([0-9]+)';

	% Check for optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2: nOptArgs
		switch varargin{ii}
			case 'Closest'
				closest   = varargin{ii+1};
			case 'Directory'
				directory = varargin{ii+1};
			case 'TEnd'
				tend      = varargin{ii+1};
			case 'TimeOrder'
				timeOrder = varargin{ii+1};
			case 'TStart'
				tstart    = varargin{ii+1};
			case 'TPattern'
				tpattern  = varargin{ii+1};
			case 'Newest'
				newest    = varargin{ii+1};
			case 'Version'
				version   = varargin{ii+1};
			case 'VersionRegex'
				vRegex    = varargin{ii+1};
			otherwise
				error( ['Unknown parameter "' varargin{ii} '".'] );
		end
	end
	
	% Directory
	%   - Use the given directory or the pwd()
	if isempty(directory)
		if isempty(inDir)
			directory = pwd();
		else
			directory = inDir;
		end
	end
	
	% If a specific version is not specified, choose the newest
	if isempty(version) && isempty(newest)
		newest = true;
	else
		newest = false;
	end
	
	% Newest and Version are mutually exclusive.
	%   - One or both must not be set.
	assert( isempty(version) || ~newest,  'Version and Newest are mutually exclusive.' );

%------------------------------------%
% Find Files                         %
%------------------------------------%
	
	% Fully qualify the file path (i.e. add DIRECTORY)
	test_file = fullfile(directory, inFile);

	% Search for the files.
	[allFiles, nFiles] = MrFile_Finder(test_file);

%------------------------------------%
% Find Copies                        %
%------------------------------------%

	%
	% Copies differ only in their version numbers.
	%
	
	% Remove the directory
	[allDirs, allFiles, allExt] = cellfun(@fileparts, allFiles, 'UniformOutput', false);
	allFiles                    = strcat(allFiles, allExt);
	
	% Allocate memory to output
	filesFound = allFiles;
	dirsFound  = allDirs;

%------------------------------------%
% Filter by Version                  %
%------------------------------------%
	if nFiles > 0 && newest || ~isempty(version)
		% Replace the version number with the empty string
		regex_cell      = cell(1, nFiles);
		rep_cell        = cell(1, nFiles);
		regex_cell(:)   = { vRegex };
		rep_cell(:)     = { '' };
		files_noversion = cellfun(@regexprep, allFiles, regex_cell, rep_cell, 'UniformOutput', false);

		% Sort the results
		%   - FUNIQUE(IUNIQ) reproduces FILE_NOVERSION, so IUNIQ maps the
		%     elements of FILE_NOVERSION onto the unique elements in FUNIQUE.
		%     So, to look for copies in FILES, we look for repeated indices in
		%     IUNIQ.
		%   - IBASE is the unique elements of FILE_NOVERSION, so contains the
		%     maximum number of elements we must search through.
		[fUnique, ibase, iuniq] = unique(files_noversion);
		nUnique                 = length(fUnique);

		% Allocate output
		filesFound = cell(1, nUnique);
		dirsFound  = cell(1, nUnique);

	%------------------------------------%
	% Filter by Version -- Newest        %
	%------------------------------------%
		if newest
			% Search through all of the uniq elements
			for ii = 1 : length(ibase)

				% Pick out copies of the current file
				iCopies = find(ibase(iuniq) == ibase(ii));
				nCopies = length(iCopies);

				% We only need to compare if nCopies > 1
				newestVersion = allFiles{ iCopies(1) };
				newestDir     = allDirs{ iCopies(1) };

				% Step through all copies
				for jj = 2 : nCopies

					% Compare copies and keep the newest version.
					if MrFile_VersionCompare( allFiles{ iCopies(jj) }, newestVersion, vRegex ) == 1
						newestVersion = allFiles{ iCopies(jj) };
						newestDir     = allDirs{ iCopies(jj) };
					end
				end

				% Keep the newest
				filesFound{ii} = newestVersion;
				dirsFound{ii}  = newestDir;
			end

	%------------------------------------%
	% Filter by Version -- Specific      %
	%------------------------------------%
		elseif ~isempty(version)
			% Search through all of the uniq elements
			for ii = 1 : length(ibase)

				% Pick out copies of the current file
				iCopies = find(ibase(iuniq) == ibase(ii));
				nCopies = length(iCopies);

				% Erase the element if versions do not match.
				thisVersion = [];
				thisDir     = [];

				% Step through copies until we find a match.
				jj = 1;
				while isempty(thisVersion) && jj <= nCopies
					% Compare copies and keep a matching version.
					if MrFile_VersionCompare( allFiles{ iCopies(jj) }, version ) == 0
						thisVersion = allFiles{ iCopies(jj) };
						thisDir     = allDirs{ iCopies(jj) };
					end
					
					jj = jj + 1;
				end

				% Keep the matching version
				filesFound{ii} = thisVersion;
				dirsFound{ii}  = thisDir;
			end
		end
	end

%------------------------------------%
% Filter by Time                     %
%------------------------------------%
	% Was a time interval given?
	tf_tstart = ~isempty(tstart);
	tf_tend   = ~isempty(tend);
	
	% Filter files
	if nFiles > 0 && (tf_tstart || tf_tend)
		%
		% Does the file name include TStart and TEnd?
		%   - Assume TEnd takes the same form as TStart.
		%   - Assume TStart does not repeat tokens.
		%   - See if the first token is repeated.
		%
		% Times are put into TimeOrder and converted to integers. This allows
		% for easy comparison. 
		%
		
		% Extract tokens
		[tokens, tokStart] = MrTokens_Extract(inFile);
		nTokens            = length(tokens);
		
		% Look for repeats
		if nTokens > 1
			tok_cell  = repmat(tokens(1), 1, nTokens-1);
			tf_repeat = cellfun(@strmatch, tok_cell, tokens(2:end), 'UniformOutput', false);
			
			% Find repeats
			iRepeat = find( ~cellfun(@isempty, tf_repeat), 1, 'first') + 1;
		else
			iRepeat = [];
		end
		
		% Extract the time intervals from the file names.
		%   - timeOrder will assemble the times in majority order and without
		%     delimiters so that times can be compared numerically.
		if isempty(iRepeat)
			fStart  = MrTimeParser(filesFound, inFile, timeOrder);
			fEnd    = [];
			tf_fend = false;
		else
			fStart = MrTimeParser(filesFound, inFile(1:tokStart(iRepeat)-1), timeOrder);
			fEnd   = MrTimeParser(filesFound, inFile(tokStart(iRepeat):end), timeOrder);
			
			% Convert fEnd to an integer
			fEnd    = cellfun(@str2num, strcat( {'int64('}, fEnd,   {')'} ) );
			tf_fend = true;
		end
		
		% Convert fStart to integers
		fStart = cellfun(@str2num, strcat( {'int64('}, fStart, {')'} ) );
		
		% Convert interval to integers
		if tf_tstart
			tstart = MrTimeParser(tstart, tpattern, timeOrder);
			tstart = str2num( ['int64(' tstart ')'] );
		end
		
		if tf_tend
			tend = MrTimeParser(tend, tpattern, timeOrder);
			tend = str2num( ['int64(' tend   ')'] );
		end

	%------------------------------------%
	% File Name NOT Include End Time     %
	%------------------------------------%
		%
		% We decide which files to keep by first considering what happens when
		% we have all information: tstart, tend, fStart, and fEnd. In this
		% case, we want to choose any files that contains any portion of the
		% time interval [tstart, tend]. 
		%
		%                    |----Time Interval----|
		%   [--File Interval--]        ....       [--File Interval--]
		%
		% This means any interval such that
		%   ( (tstart >= fStart) & (tstart <  fEnd) )
		% OR
		%   ( (tend   >  fStart) & (tend   <= fEnd) )
		%
		% If we have less information, we simply remove the clause containing
		% the missing information.
		%
		if tf_fend
			switch 1
				case tf_tstart && tf_tend
					tf_keep = ( (tstart >= fStart) & (tstart <= fEnd) ) | ...
					          ( (tend   >= fStart) & (tend   <= fEnd) );

				case tf_tstart
					tf_keep = (tstart >= fStart) & (tstart <= fEnd);

				case tf_tend
					tf_keep = (tend >= fStart) & (tend <= fEnd);
			end

	%------------------------------------%
	% File Name Includes End Time        %
	%------------------------------------%
		else
			switch 1
				case tf_tstart && tf_tend
					tf_keep = (tstart >= fStart) | (tend >= fStart);

				case tf_tstart
					tf_keep = tstart >= fStart;

				case tf_tend
					tf_keep = tend >= fStart;
			end
		end
		
		% Pick out matching data
		filesFound = filesFound( tf_keep );
		dirsFound  = dirsFound( tf_keep );
		fStart     = fStart( tf_keep );

		if tf_fend
			fEnd = fEnd( tf_keep );
		end
	
	%------------------------------------%
	% Closest Time                       %
	%------------------------------------%
		%
		% We want to find the closes time to 'TStart'
		%   - If the file has both a start and end time, there is
		%     sufficient information to select the appropriate files.
		%     We do not need to check anything.
		%   - If only a start time exists in the file name, then the
		%     selection process above may be too liberal. Find the
		%     file that starts at or just before 'TStart'.
		%   - If 'TEnd' was also given, find the file that starts
		%     just before 'TEnd', and select all files between
		%     'TStart' and 'TEnd'. Otherwise, just pick the file
		%     associated with 'TStart.
		%
		if closest && ~tf_fend && length(filesFound) > 1
			%
			% Find the file that starts closest to TSTART
			%

			% Take the smallest difference in start times.
			iStart = find( fStart <= tstart, 1, 'last' );
			
			% If 'TEnd' was given, find a range of files.
			%   - Otherwise, just pick the closest.
			if tf_tend && ~tf_fend
				iEnd = find( fStart <= tend, 1, 'last' );
			else
				iEnd = iStart;
			end

			% Select only that one file
			filesFound = filesFound( iStart:iEnd );
			dirsFound  = dirsFound( iStart:iEnd );
			fStart     = fStart( iStart:iEnd );

			if ~isempty(fEnd)
				fEnd = fEnd( iStart:iEnd );
			end
		end
	end
		
%------------------------------------%
% Directory                          %
%------------------------------------%
	nFiles = length(filesFound);
	
	% Append directory;
	if nFiles > 0
		filesFound  = cellfun(@fullfile, dirsFound, filesFound, 'UniformOutput', false);
	end
	
	% Return a string if only 1 file.
	if nFiles == 1
		filesFound = filesFound{1};
	end
end
