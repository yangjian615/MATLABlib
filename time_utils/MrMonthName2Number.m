%
% Name
%   MrMonthName2Number
%
% Purpose
%   Convert a month name to a 2-digit month number.
%
% Calling Sequence
%   NUMBER = MrMonthName2Number(NAME)
%     Convert a month name, NAME, provided as a complete month name (e.g.
%     January) to a 2-digit month number, NUMBER (e.g., '01'). NUMBER is
%     output as a string with a leading '0' for months 1-9. If NAME is a
%     cell array of names, NUMBER is also a cell array of month numbers.
%
%   NUMBER = MrMonthName2Number(NAME, ABBREVIATED)
%     Indicate that NAME is given as a 3-character abbreviate month name
%     (e.g. 'Jan').
%
% Parameters
%   NAME              in, required, type = char or cell
%   ABBREVIATED       in, optional, type = boolean, default = false
%
% Returns
%   NUMBER            out, required, type = char or cell
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function number = MrMonthName2Number(name, abbreviated)

	% Abbreviate month names?
	if nargin < 2
		abbreviated = false;
	end
	
	% Month names
	if abbreviated
		month_names = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
			             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
	else
		month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
			             'July', 'August', 'September', 'October', 'November', 'December'};
	end
	
	% Number of names given
	if iscell(name)
		nNames = length(name);
	else
		assert(isrow(name), 'NAME must be a single name or a cell array of names.')
		nNames = 1;
	end

	% The index will be the month number;
	%   - Make the comparison case-insensitive.
	%   - Make sure all input months match to a valid month name.
	[tf_month, iMonth] = ismember( upper(name), upper(month_names) );
	assert( min(tf_month) == 1, 'Invalid month names provided.' );

	% Create a cell array of strings as the output.
	number      = num2cell(iMonth);
	fmt_cell    = cell(1, nNames);
	fmt_cell(:) = {'%02d'};
	number      = cellfun(@num2str, number, fmt_cell, 'UniformOutput', false);
	
	% Was a single name given?
	if nNames == 1
		number = number{1};
	end
end
