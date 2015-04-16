%
% Name
%   MrValue_Locate
%
% Purpose
%   The VALUE_LOCATE function finds the intervals within a given
%   monotonic vector that brackets a given set of one or more
%   search values. This function is useful for interpolation and
%   table-lookup.
%
%   This is a MATLAB version of IDL's Value_Locate() function
%     http://exelisvis.com/docs/VALUE_LOCATE.html
%   that makes use of MATLAB's histc() function to the same end.
%
% Calling Sequence
%   INDS = MrValue_Locate(VECTOR, VALUE)
%     Determine the indices INDS in VECTOR to which each element
%     of VALUE is located.
%
% Parameters
%   VECTOR          in, required, type = 1xN array
%   VALUES          in, required, type = 1xM array
%   'RoundUp'       in, optional, type = boolean, default = false
%                   Make VALUES that fall outside the first interval
%                     be located in the first interval.
%   'RoundDown'     in, optional, type = boolean, default = true
%                   Make VALUES that fall outside the last interval
%                     be located in the last interval.
%
% Returns
%   INDS            out, required, type=1xM integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-14      Written by Matthew Argall
%
function inds = MrValue_Locate(vector, value, varargin)

	% Make sure the vector is sorted
	assert(issorted(vector), 'Vector must be monotonically increasing.')
	assert( ~isa(vector, 'int64'), 'Datatype int64 not accepted.')
	assert( ~isa(value,  'int64'), 'Datatype int64 not accepted.')

	% Defaults
	roundup   = false;
	rounddown = true;

	% Check for optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'RoundUp'
				roundup   = varargin{ii+1};
			case 'RoundDown'
				rounddown = varargin{ii+1};
			otherwise
				error( ['Unknown parameter "' varargin{ii} '".'] );
		end
	end

	% Bind the data
	[~, inds] = histc(value, vector);
	
	% Out of bounds high
	%  - All points in VALUE that occur after VECTOR(end) will
	%    have an index of 0 because there is no right-edge to
	%    the last histogram bin.
	%  - Force all of those points to fall into the last bin,
	%    essentially making the bin extend to infinity.
	%  - In all cases, we are rounding VALUE down to the
	%    nearest element in VECTOR.
	if rounddown
		inds( value > vector(end) ) = length(vector);
	end
	
	% Out of bounds low
	%  - All points in VALUE that occur before VECTOR(1) will
	%    similarly have an index of 0 because they fall below
	%    the left-edge of the first histogram bin.
	%  - Retain an index of 0
	if roundup
		inds( value < vector(1) ) = 1;
	end
end