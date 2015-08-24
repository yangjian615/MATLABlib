%
% Name
%   MrHermite
%
% Purpose
%   To compute Hermite spline interpolation of a tabulated function.
%
% Method
%   Hermite interpolation computes the cubic polynomial that agrees with 
%   the tabulated function and its derivative at the two nearest 
%   tabulated points.  It may be preferable to Lagrangian interpolation 
%   (QUADTERP) when either (1) the first derivatives are known, or (2)
%   one desires continuity of the first derivative of the interpolated
%   values.  HERMITE() will numerically compute the necessary
%   derivatives, if they are not supplied.
%
% Calling Sequence
%   G = MrHermite( X, F, Y )
%     Interpolate the function f(x), F, and return the function g(y),
%     G, known at locations Y.
%
%   G = MrHermite( X, F, Y, DF )
%     Provide the derivative of f(x) [f'(x)], DF at locations X. If
%     not provided, a centered difference derivative will be computed
%     from the values of X and F.
%
%   [G, DG] = MrHermite( __ )
%     Return the derivative g'(y), DG, of the interpolated function
%     g(y), G.
%
%   [__] = MrHermite( __, 'extrap' )
%     Extrapolate beyond the tabulated function f(x). The 'extrap'
%     option can be provided with any of the calling sequences above.
%     If not given, an error will occur if values of Y lie outside
%     the range of X.
%
% Parameters
%   X               in, required, type = float
%   F               in, required, type = float
%   Y               in, required, type = float
%   DF              in, optional, type = float
%   'extrap'        in, optional, type = char
%
% Returns
%   G               out, required, type=float
%   DG              out, required, type=float
%
% Examples
%   Interpolate the function f(x) = 1/x at the point y = 0.45,
%   where x is evenly spaced from 0 to 2.0 in increments of 0.1.
%     >> x = 0.1 : 0.1 : 2.0;
%     >> f = 1.0 ./ x;
%     >> g = mrhermite( x, f, 0.45 )
%       g = 2.218750000000000
%
%   For the example above, we know what the derivative is:
%     f'(x) = -1/x^2.
%   We can use this to improve our results.
%     >> x  = 0.1 : 0.1 : 2.0;
%     >> f  =  1.0 ./ x;
%     >> df = -1.0 ./ x.^2;
%     >> g = mrhermite( x, f, 0.45, df )
%       g = 2.221875000000000
%
%   The real value of f(0.45) is 2.222222222222222
%
% Notes
%   The algorithm here is based on the FORTRAN code discussed by 
%   Hill, G. 1982, Publ Dom. Astrophys. Obs., 16, 67. The original 
%   FORTRAN source is U.S. Airforce. Surveys in Geophysics No 272.
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-21      Written by Matthew Argall Adapted from Wayne Landsman's
%                     IDL program "hermite.pro".
%
function [g, dg] = mrhermite(x, f, y, varargin)

%------------------------------------%
% Inputs                             %
%------------------------------------%
	% Defaults
	extrapolate = false;
	df          = [];
	
	if nargin == 5
		% Must be MrHermite(X, F, Y, DF, 'extrap')
		assert( ischar(varargin{2}) && strcmp(varargin{2}, 'extrap'), ...
		        sprintf( 'Fourth parameter was %s, expected "extrap".', varargin{2} ) );
		assert( isfloat(varargin{1}), ...
		        sprintf( 'Third parameter must be float. Given %s.', class(varargin{1}) ) );
		
		extrapolate = true;
		df          = varargin{1};
	
	elseif nargin == 4
		% Must be
		%   a) MrHermite(X, F, Y, 'extrap')
		%   b) MrHermite(X, F, Y, DF)
		if ischar(varargin{1})
			assert( strcmp(varargin{1}, 'extrap'), ...
			        'Third parameter was %s, expected "extrap".', varargin{1} );
			extrapolate = true;
		elseif isfloat(varargin{1})
			df = varargin{1};
		else
			error( 'Third argument should be string or float, not "%s".', class(varargin{ii}) );
		end
	end
	
	% Number of elements in and out
	nx = length(x);
	ny = length(y);
	
	% Locate Y within X
	iy = MrValue_Locate(x, y);
	if extrapolate
		iy( y < x(1)   ) = 1;
		iy( y > x(end) ) = nx - 2;
	end
	iy( y == x(end) ) = nx - 1;
	
	% Any bad values?
	ibad = find( iy == 0 );
	assert( isempty(ibad), sprintf('Valid interpolation range is %f to %f. Range given is [%f, %f]', ...
	                               x(1), x(end), y(1), y(end)) );

%------------------------------------%
% Derivative                         %
%------------------------------------%

	% Indices for cubic interpolation & centered difference
	iyp1 = iy + 1;                        % Neighbor 1 ahead
	iyp2 = iy + 2;                        % Neighbor 2 ahead
	iym1 = iy - 1;                        % Neighbor 1 behind
	h1   = 1.0 ./ ( x(iy) - x(iyp1) );    % Denominator of backward deriv: (y0 - y1) / (x0 - x1)
	h2   = -h1;                           % Denominator of forward  deriv: (y1 - y0) / (x1 - x0)
	
	% Compute the derivative
	if isempty(df)
		f1 = zeros(1, ny);
		f2 = zeros(1, ny);
		for ii = 1 : ny
			% First point
			if iy(ii) == 0
				f1(ii) = (f(2) - f(1)) ./ (x(2) - x(1));
				f2(ii) = (f(3) - f(1)) ./ (x(3) - x(1));
				
			else
				% Last point
				if iy(ii) == nx
					f2(ii) = ( f(nx) - f(nx-1) ) ./ ( x(nx) - x(nx-1) );
				else
					f2(ii) = ( f(iyp2(ii)) - f(iy(ii)) ) ./ ( x(iyp2(ii)) - x(iy(ii)) );
				end
				
				f1(ii) = ( f(iyp1(ii)) - f(iym1(ii)) ) ./ ( x(iyp1(ii)) - x(iym1(ii)) );
			end
		end
		
	% Derivative given
	else
		f1 = df(iy);          % Derivative at grid point
		f2 = df(iyp1);        % Derivative at adjacent grid point
	end

%------------------------------------%
% Interpolate                        %
%------------------------------------%
	
	dy1 = y - x(iyp1);        % ( y0 - x1 )
	dy2 = y - x(iy);          % ( y0 - x0 )
	s1  = dy1 .* h1;          % ( y0 - x1 ) / ( x0 - x1 )
	s2  = dy2 .* h2;          % ( y0 - x0 ) / ( x1 - x0 )
	
	% Hermite interpolation formula
	g = ( f(iy)   .* (1.0 - 2.0.*h1.*dy2) + f1.*dy2 ) .* s1 .* s1 + ...
	    ( f(iyp1) .* (1.0 - 2.0.*h2.*dy1) + f2.*dy1 ) .* s2 .* s2;

	% Derivative of Hermite interpolation
	dg = ( f(iy)   .* (-2.0*h1) + f1 ) .* s1 .* s1 + ...
	     ( f(iy)   .* (1.0 - 2.0.*h1.*dy2) + f1.*dy2 ) .* 2.0 .* dy1 .* h1 .* h1 + ...
	     ( f(iyp1) .* (-2.0*h2) + f2 ) .* s2 .* s2 + ...
	     ( f(iyp1) .* (1.0 - 2.0.*h2.*dy1) + f2.*dy1 ) .* 2.0 .* dy2 .* h2 .* h2;
end