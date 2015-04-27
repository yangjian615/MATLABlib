%
% Name
%   MrLine3D
%
% Purpose
%   Find point that lie along a straight line in 3D.
%
% Calling Sequence
%   LINE = MrLine3D(R0, R1)
%     Create a line in 3D that connects the point R0 to R1.
%
%   LINE = MrLine3D(..., NPOINTS)
%     The line will have NPOINTS number of vertices.
%
% Parameters
%   R0              in, required, type = 1x3 double
%   R1              in, required, type = 1x3 double
%   NPOINTS         in, required, type = integer, default = 100
%
% Returns
%   LINE            out, required, type=3xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-26      Written by Matthew Argall
%
function line = MrLine3D(r0, r1, nPoints)

	%Defaults
	if nargin < 3
		nPoints = 100
	end

	%
	% Knowing two vectors that point from the origin to two points in space
	%   r0 = (x0, y0, z0)
	%   r1 = (x1, y1, z1)
	%
	% A vector, v, parallel to the vector a, which connects r0 to r1, can be formed
	%   v = r1 - r0
	%     = (x1 - x0, y1 - y0, z1 - z0)
	%     = (a, b, c)
	%
	% A vector from the origin to any other point on the line  can be formed by adding some
	% multiplicative factor, t, of v to r0
	%   r = r0 + vt
	%
	% It follows that
	%   x = x0 + at
	%   y = y0 + bt
	%   z = z0 + ct
	%
	% Or
	%   t = (x - x0) / a
	%     = (y - y0) / b
	%     = (z - z0) / c
	%
	% Given two points, then vectors r0 and v are known. Any other point can be found
	% by choosing x and computing y and z:
	%   x = known
	%   v = (a, b, c) = known
	%   t = (x - x0) / a
	%   y = y0 + b*t
	%   z = z0 + c*t
	%

	% Create v
	v = r1 - r0

	% One of v=(a,b,c) must not be zero.
	switch 1
		% dx > 0
		case v(0) ~= 0
			% Compute x and t
			x = r0(0) + (r1(0) - r0(0)) .* (0:1:nPoints-1)/(nPoints-1)
			t = (x - r0(0)) / v(0)

			% Compute y and z
			y = r0(1) + v(1)*t
			z = r0(2) + v(2)*t
	
		%dy > 0
		case v(1) ~= 0
			%Compute y and t
			y = r0(1) + (r1(1) - r0(1)) .* (0:1:nPoints-1)/(nPoints-1)
			t = (x - r0(1)) / v(1)

			%Compute x and z
			x = r0(0) + v(0)*t
			z = r0(2) + v(2)*t
	
		%dz > 0
		case v(2) ~= 0
			%Compute z and t
			z = r0(2) + (r1(2) - r0(2)) .* (0:1:nPoints-1)/(nPoints-1)
			t = (z - r0(2)) / v(2)

			%Compute y and z
			x = r0(0) + v(0)*t
			y = r0(1) + v(1)*t
	
		%Line of zero length
		otherwise
			nPoints = 1
			x = r0(0)
			y = r0(1)
			z = r0(2)
	end

	%Form the line
	line      = zeros(3, nPoints)
	line(0,*) = x
	line(1,*) = y
	line(2,*) = z
end