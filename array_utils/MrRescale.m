%
% Name
%   MrRescale
%
% Purpose
%   Linearly rescale data to a new data range. A variable x with min and max
%   [min0, max0] can be rescaled to the range [min1 max1] by the following
%   formula:
%
%     ( (max1 - min1) / (max0 - min0) ) * (x - max0) + max1
%
%   OR
%
%     ( (max0 - min0) / (max1 - min1) ) * (x - min0) + min1
%
%   The former equation reduces to the equation used.
%     http://stats.stackexchange.com/questions/25894/changing-the-scale-of-a-variable-to-0-100
%
% Calling Sequence
%   SCALED_VECTOR = MrValue_Locate(VECTOR)
%     Scale a numeric array VECTOR so that its new range is [0, 1].
%
%   SCALED_VECTOR = MrValue_Locate(VECTOR, MINRANGE)
%     Scale a numeric array VECTOR so that its new range is [MINRANGE, 1].
%     If MINRANGE > 1.0, then the range will be [MINRANGE, MINRANGE*1.1].
%
%   SCALED_VECTOR = MrValue_Locate(VECTOR, MINRANGE, MAXRANGE)
%     Scale a numeric array VECTOR so that its new range is [MINRANGE, MAXRANGE].
%
%   SCALED_VECTOR = MrValue_Locate(__, 'ParamName', ParamValue)
%     Specify any of the parameter name-value pairs given below.
%     
%
% Parameters
%   MINRANGE        in, optional, type = 1x1 numeric, default = 0.0
%   MAXRANGE        in, optional, type = 1x1 numeric, default = 1.0
%   'MaxValue'      in, optional, type = 1x1 numeric
%                   Values within VECTOR >= MAXVALUE will be scaled to MAXRANGE.
%   'MinValue'      in, optional, type = 1x1 numeric
%                   Values within VECTOR <= MINVALUE will be scaled to MINRANGE.
%   'Class'         in, optional, type = char
%
% Returns
%   INDS            out, required, type=1xM integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-14      Written by Matthew Argall
%   2017-02-14      Documented. Was not applying scale factors to the correct array. Fixed. - MRA
%
function result = MrRescale(vector, varargin)

	% Defaults
	minRange  = 0.0;
	maxRange  = 1.0;
	dataclass = class(vector);
	minValue  = [];
	maxValue  = [];

%------------------------------------%
% Parameters                         %
%------------------------------------%
	if nargin() > 1
		if ischar(varargin{1})
			minRange = 0.0;
			maxRange = 1.0;
		else
			minRange    = varargin{1};
			varargin(1) = [];
		end
	end
	if nargin() > 2
		if ischar(varargin{1})
			maxRange = max( 1.0, minRange*1.1 );
		else
			maxRange    = varargin{1};
			varargin(1) = [];
		end
	end

%------------------------------------%
% Optional Parameters                %
%------------------------------------%
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'MinValue'
				minValue = varargin{ii+1};
			case 'MaxValue'
				maxValue = varargin{ii+1};
			case 'Class'
				dataclass = varargin{ii+1};
			otherwise
				error( ['Unknown optional parameter: "' varargin{ii} '".'] );
		end
	end

%------------------------------------%
% Check Inputs                       %
%------------------------------------%
	
	if isempty(minValue)
		minValue = min( vector(:) );
	end
	if isempty(maxValue)
		maxValue = max( vector(:) );
	end

	assert(minValue ~= maxValue, 'MinValue and MaxValue are coincident.');

%------------------------------------%
% Scale The Vector                   %
%------------------------------------%
	% Must do math with floats
	if isinteger(vector)
		result   = double(vector);
		minValue = double(minValue);
		maxValue = double(maxValue);
	else
		result = vector;
	end
	
	if isinteger(minRange)
		minRange = double(minRange);
		maxRange = double(maxRange);
	end

	% Force into data range
	result( result < minValue ) = minValue;
	result( result > maxValue ) = maxValue;

	% Scaling Factors
	scaleFactor = [ ( (minRange*maxValue) - (maxRange*minValue) ) / (maxValue - minValue) ...
	                (maxRange - minRange) / (maxValue - minValue) ];
	
	% Results
	result = scaleFactor(1) + scaleFactor(2)*result;
	
	% Change data class
	if ~strcmp(class(result), dataclass)
		result = cast(result, dataclass);
	end
end