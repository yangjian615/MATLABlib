%
% Name:
%   fsm_intervals
%
% Purpose:
%   Find continuous, overlapping segments of data among two monotonic,
%   uniformly spaced datasets.
%
% Calling Sequence:
%   [IX, IY] = fsm_data_intervals( X, Y )
%     Given two monotonic, uniformly spaced vectors, X and Y, find
%     continuous intervals in X that overlap with continuous intervals of
%     Y. IX (IY) represents the start and end index Values of each interval
%     in X (Y).
%
%   [__] = fsm_find_closes(__, 'ParamName', ParamValue)
%       Supply any of the ParamName-ParamValue pairs below.
%
% Parameters:
%   X:              in, required, type = 1xN double
%   Y:              in, required, type = 1xN double
%   'Remove'        in, optional, type = boolean
%                   If true, non-overlapping intervals are removed.
%   'Sync'          in, optional, type = boolean
%                   If true, the start and stop index of each interval will
%                     be adjusted so that the corresponding values in X and
%                     Y are as close as possible.
%   'Tolerance'     in, optional, type = boolean
%                   If true, and 'Sync' is in use, specify the number of
%                     look-ahead and look-behind points.
%
% Returns:
%   IX:             out, required, type = 2xN integer array
%   IY:             out, required, type = 2xN integer array
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-26      Written by Matthew Argall
%
function [ix iy] = MrIntervalsXY(X, Y, varargin)


	% Defaults
	tf_remove = false;
	tf_sync   = false;

	% Optional arguments?
	nOptArgs = length(varargin);
	if nOptArgs > 0
		
		% Step through each ParamName-ParamValue pair.
		for ii = 1 : 2 : nOptArgs
			% Pick out valid parameters
			switch varargin{ii}
				case 'Remove'
					tf_remove = varargin{ii+1};
				case 'Sync'
					error( 'The Sync parameter has not been implemented.' )
				case 'Tolerance'
					error( 'The Tolerance parameter has not been implemented.' )
				otherwise
					error( ['Unknown parameter name "' varargin{ii} '".'] )
			end
		end
	end


%------------------------------------%
% Time and Sampling Intervals        %
%------------------------------------%

	% Find indices within the time arrays that bracket continuous data
	% intervals.
	ix = MrIntervalsX( X );
	iy = MrIntervalsX( Y );

%------------------------------------%
% Remove Intervals                   %
%------------------------------------%

	% Remove from FGM
	if tf_remove
		% Extract the data values the define the interval
		xx = X(ix);
		yy = Y(iy);
		
		% Check for 2x1 and transpose the results
		%   If IX is 2x1, then X(ix) will return 1x2
		%   ........ 2xN ....................... 2xN
		xdims = size(xx);
		if xdims(1) == 1
			xx = xx';
		end
		
		% Same for Y
		ydims = size(yy);
		if ydims(1) == 1
			yy = yy';
		end
		
		% Remove intervals
		ix = MrIntervalsXY_Remove( ix, iy, xx, yy );
		iy = MrIntervalsXY_Remove( iy, ix, xx, yy );
	end

%------------------------------------%
% Sync Times                         %
%------------------------------------%

	% Remove from FGM
	if tf_sync
		ix = MrIntervalsXY_Sync( ix, iy, X(ix), Y(iy), 'Tol', tf_fuzzy );
		iy = MrIntervalsXY_Sync( iy, ix, Y(iy), X(ix) );
	end
end


%
% Name:
%   MrIntervalsXY_Remove
%
% Purpose:
%   Find continuous data intervals within an evenly spaced, monotonic
%   vector of points.
%
% Calling Sequence:
%   IX = fsm_intervals_remove(IX, IY, X, Y);
%       IX and IY are indices into two different monotonic, evenly spaced
%       arrays, A and B, that define the start IX(1,:) and end IX(2,:) of
%       continuous subsets of data. X and Y are the values of A and B at
%       indices IX and IY. Intervals in X that fall entirely between
%       intervals in Y, so that there is no overlapping data, are removed
%       from X.
%
% Parameters:
%   IX:           in, required, type = 2xN double
%   IY:           in, required, type = 2xN double
%   X:            in, required, type = 2xN double
%   Y:            in, required, type = 2xN double
%
% Returns:
%   IX_OUT:       out, required, type = 2xN double array
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
function ix = MrIntervalsXY_Remove(ix, iy, x, y)

	nx = length( ix(1, :) );
	ny = length( iy(1, :) );

	% Remove FGM intervals that fall entirely within an Y data gap (and
	% vice versa).
	ii = 1;
	jj = 1;
	while ii <= nx && jj <= ny
		% After which interval in Y does X begin?
		ibegin = find( x(1, ii) > y(2, jj:end), 1, 'first' );
		
		% If the X interval ends before the next SCM interval begins, junk.
		if ~isempty(ibegin)
			if x(2, ii) < y(1, jj+ibegin)
				x(:, ii)  = [];
				ix(:, ii) = [];
				nx        = nx - 1;
			else
				ii = ii + 1;
			end
		
			% Push ahead in Y.
			jj = jj + ibegin;
		else
			ii = ii + 1;
		end
	end
end
