%
% Name:
%   MrIntervalsXY
%
% Purpose:
%   Find continuous, overlapping segments of data among two monotonic,
%   uniformly spaced datasets.
%
% Calling Sequence:
%   [IX, IY] = MrIntervalsXY( X, Y )
%     Given two monotonic, uniformly spaced vectors, X and Y, find
%     continuous intervals in X that overlap with continuous intervals of
%     Y. IX (IY) represents the start and end index Values of each interval
%     in X (Y).
%
%   [__] = MrIntervalsXY(__, 'ParamName', ParamValue)
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
%   2015-10-26      Added the "Sync" option. - MRA
%
function [ix iy] = MrIntervalsXY(X, Y, varargin)


	% Defaults
	tf_remove = false;
	tf_sync   = false;

	% Step through each ParamName-ParamValue pair.
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		% Pick out valid parameters
		switch varargin{ii}
			case 'Remove'
				tf_remove = varargin{ii+1};
			case 'Sync'
				tf_sync = varargin{ii+1};
			otherwise
				error( ['Unknown parameter name "' varargin{ii} '".'] )
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
		[ix, iy] = MrIntervalsXY_Sync( X, Y, ix, iy  );
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


%
% Name:
%   MrIntervalsXY_Sync
%
% Purpose:
%   Synchronize overlapping, continuous intervals within two monotonically
%   increasing arrays.
%
% Calling Sequence:
%   [OX, OY] = fsm_intervals_remove(X, Y, IX, IY, X, Y);
%       IX and IY are indices into two different monotonic, evenly spaced
%       arrays, X and Y, that define the start IX(1,:) and end IX(2,:) of
%       continuous subsets of data. The start and end indices within IX
%       and IY will be adjusted so that the intervals are as close to
%       synchronized as possible.
%
% Parameters:
%   X:            in, required, type = 2xN array
%   Y:            in, required, type = 2xN array
%   IX:           in, required, type = 2xN integer
%   IY:           in, required, type = 2xN integer
%
% Returns:
%   OX:           out, required, type = 2xN integer
%   OY:           out, required, type = 2xN integer
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
function [ox, oy] = MrIntervalsXY_Sync(x, y, ix, iy)

	% Check inputs
	Nx = length(x);
	Ny = length(y);
	nx = size( ix, 2 );
	ny = size( iy, 2 );
	n  = max( [nx, ny] );
	
	% Output index arrays will have the same number of intervals.
	ox = zeros(2, n);
	oy = zeros(2, n);
	ox(:,1) = ix(:,1);
	oy(:,1) = iy(:,1);

	% Step through each interval of X.
	for ii = 1 : n
		% Which interval starts/ends first
		[tfirst, ifirst] = max( [x(ox(1,ii)), y(oy(1,ii))] );
		[tlast,  ilast]  = min( [x(ox(2,ii)), y(oy(2,ii))] );
		
	%------------------------------------%
	% X Starts First                     %
	%------------------------------------%
		if ifirst == 1
			% Keep the start index for X
			ix0 = ox(1,ii);
			
			% Search for the closest starting point in Y
			%   - First point >= X
			iy0 = find(y >= x(ix0), 1, 'first');
			
			% Check if the previous point is closer
			if iy0 ~= 1 && abs(y(iy0-1) - x(ix0)) < abs(y(iy0) - x(ix0))
				iy0 = iy0 - 1;
			end
		
	%------------------------------------%
	% Y Starts First                     %
	%------------------------------------%
		else
			% Keep the start index for X
			iy0 = oy(1,ii);
			
			% Search for the closes starting point in Y
			%   - First point >= X
			ix0 = find(x >= y(iy0), 1, 'first');
			
			% Check if the previous point is closer
			if ix0 ~= 1 && abs(x(ix0-1) - y(iy0)) < abs(x(ix0) - y(iy0))
				ix0 = ix0 - 1;
			end
		end
		
	%------------------------------------%
	% X Ends First                       %
	%------------------------------------%
		if ilast == 1
			% Keep the end index for X
			ix1 = ox(2,ii);
			
			% Search for the closest ending point in Y
			%   - First point >= X
			iy1 = find(y >= x(ix1), 1, 'first');
		
			% Check if the previous point is closer
			if abs(y(iy1-1) - x(ix1)) < abs(y(iy1) - x(ix1))
				iy1 = iy1 - 1;
			end
		
	%------------------------------------%
	% Y Ends First                       %
	%------------------------------------%
		else
			% Keep the end index for X
			iy1 = oy(2,ii);
			
			% Search for the closest ending point in X
			%   - First point >= X
			ix1 = find(x >= y(iy1), 1, 'first');

			% Check if the previous point is closer
			if abs(x(ix1-1) - y(iy1)) < abs(x(ix1) - y(iy1))
				ix1 = ix1 - 1;
			end
		end
		
	%------------------------------------%
	% Store the Synchronized Interval    %
	%------------------------------------%
		ox(:,ii) = [ix0, ix1];
		oy(:,ii) = [iy0, iy1];
		
	%------------------------------------%
	% Identify Next Interval             %
	%------------------------------------%
		if ii < n
			% If there are no intervals remaining, then the remaining
			% points constitutes the next interval.
			if ii >= nx
				ox(:,ii+1) = [ix1+1, Nx];
			else
				ox(:,ii+1) = ix(:,ii+1);
			end
		
			% If there are no intervals remaining, then the remaining
			% points constitutes the next interval.
			if ii >= ny
				oy(:,ii+1) = [iy1+1, Ny];
			else
				oy(:,ii+1) = iy(:,ii+1);
			end
		end
	end
end
