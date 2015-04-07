%
% Name
%   MrMonthNumber2Name
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
%   NUMBER            in, required, type = number, char, cell
%   ABBREVIATED       in, optional, type = boolean, default = false
%
% Returns
%   NAME              out, required, type = char or cell
%
% Examples
%   Return the month names for an array of month numbers.
%     >> MrMonthNumber2Name(int16( [1, 3, 12, 4, 2, 2, 6, 7] ))
%       'January' 'March' 'December' 'April' 'February' 'February' 'June' 'July'
%
%   Return the abbreviated month names for an array of month numbers.
%     >> MrMonthNumber2Name(int16( [1, 3, 12, 4, 2, 2, 6, 7] ), true)
%       'Jan'  'Mar'  'Dec'  'Apr'  'Feb'  'Feb'  'Jun'  'Jul'
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-06      Written by Matthew Argall
%
function name = MrMonthNumber2Name(number, abbreviated)

	% Default to complete month names
	if nargin < 2
		abbreviated = false;
	end

	% Make sure integers were given
	%   - Convert cell array of strings, character array, and non-integer
	%     numbers.
	if iscell(number)
		iMonth = cellfun(@str2num, strcat( {'int16('}, number, {')'} ) );
	elseif ischar(number) || ~isinteger(number)
		iMonth = int16(number);
	else
		iMonth = number;
	end
	
	% Month names
	if abbreviated
		month_names = {'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
			             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'};
	else
		month_names = {'January', 'February', 'March', 'April', 'May', 'June', ...
			             'July', 'August', 'September', 'October', 'November', 'December'};
	end
	
	% Treat the month number as an index
	name = month_names(iMonth);
	
	% If a single month was input, return a string.
	if length(name) == 1
		name = name{1};
	end
end
