%
% Name
%   mrquaternion_compose
%
% Purpose
%   Convert a rotation angle and axis into quaternion.
%
% Description
%
%  This function accepts a unit vector rotation axis VAXIS
%  and a rotation angle PHI, and returns the corresponding quaternion.
%
%  The user must take care to pass the same number of axes as rotation
%  angles.
%
%  Use QTAXIS and QTANG to extract the properties of an existing
%  quaternion.  Use QTCOMPOSE to combine a rotation axis and angle
%  into a new quaternion.
%
%  Conventions for storing quaternions vary in the literature and from
%  library to library.  This library uses the convention that the
%  first three components of each quaternion are the 3-vector axis of
%  rotation, and the 4th component is the rotation angle.  Expressed
%  in formulae, a single quaternion is given by:
%
%     Q(0:2) = [VX, VY, VZ]*SIN(PHI/2)
%     Q(3)   =              COS(PHI/2)
%
%  where PHI is the rotation angle, and VAXIS = [VX, VY, VZ] is the
%  rotation eigen axis expressed as a unit vector.  This library
%  accepts quaternions of both signs, but by preference returns
%  quaternions with a positive 4th component.
%
% Calling Sequence
%   Q = MrQuaternion_Compose(VAXIS, PHI)
%     Create a quaternion Q that will rotate a vector about the axis
%     VAXIS by an angle PHI.
%
% Parameters
%   VAXIS           in, required, type=3xN or Nx3 float
%   PHI             in, required, type=1xN or Nx1 float
%
% Returns
%   Q               out, required, type=4xN float if VAXIS is 3xN
%                                       Nx4 float if VAXIS is Nx3 (or 3x3)
%
% Example
%   >> mrquaternion_compose([0; 1; 0], pi/4)
%          0              0.38268343       0              0.92387953
%
%   Prints the quaternion composed of a rotation of !dpi/4 radians
%   around the axis [0,1,0]
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-13      Written by Matthew Argall. Adapted from QTCOMPOSE,
%                     an IDL program by Craig B. Markwardt. See
%                     his webpage for details:
%                       http://cow.physics.wisc.edu/~craigm/idl/idl.html
%
function Q = mrquaternion_compose(vaxis, phi)
	if nargin == 0
		error( 'Usage: Q = mrquaternion_compose(VAXIS, PHI)' );
	end

	% Check sizes
	szVax = size(vaxis);
	assert( szVax(1) == 3 || szVax(2) == 3, 'VAXIS must be 3xN or Nx3.' );
	assert( isrow(phi)    || iscolumn(phi), 'PHI must be 1xN or Nx1.' );
	if szVax(1) == 3 && szVax(2) == 3
		warning( 'MrQuaternion:Compose', 'VAXIS is 3x3. Treating as Nx3.');
	end
	
	% Sine and Cosine of the rotation angle
	nphi   = length(phi);
	sinPhi = sin(phi/2.0);
	cosPhi = cos(phi/2.0);
	
	%
	% Compute the quaternion
	%

	% 3x1 * 1x1
	if iscolumn(vaxis) && isscalar(phi)
		Q = [vaxis*sinPhi; cosPhi];
	
	% 1x3 * 1x1
	elseif isrow(vaxis) && isscalar(phi)
		Q = [vaxis*sinPhi cosPhi];

	% 3x1 * 1xN
	% 3x1 * Nx1
	% 1x3 * 1xN
	% 1x3 * Nx1
	elseif ( iscolumn(vaxis) || isrow(vaxis) ) && ( isrow(phi) || iscolumn(phi) )
		% Compute Q
		Q      = zeros(4, nphi);
		Q(1,:) = vaxis(1) * sinPhi;
		Q(2,:) = vaxis(2) * sinPhi;
		Q(3,:) = vaxis(3) * sinPhi;
		Q(4,:) = cosPhi;
		
		% Return Nx4 if VAXIS is 1x3
		if isrow(vaxis)
			Q = Q';
		end
		
	% Nx3 * 1x1
	%   - Put this before 3xN
	%   - 3x3 will be treated as Nx3
	elseif szVax(2) == 3 && isscalar(phi)
		Q        = zeros(szVax(1),4);
		Q(:,1:3) = vaxis * sinPhi;
		Q(:,4)   = cosPhi;
		
	% 3xN * 1x1
	elseif szVax(1) == 3 && isscalar(phi)
		Q        = zeros(4, szVax(2));
		Q(1:3,:) = vaxis * sinPhi;
		Q(4,:)   = cosPhi;
	
	% Nx3 * 1xN
	% Nx3 * Nx1
	%   - Put this before 3xN
	%   - 3x3 will be treated as Nx3
	elseif szVax(2) == 3 && szVax(1) == nphi
		Q = zeros(szVax(1), 4);
		if isrow(phi)
			Q(:,1:3) = vaxis .* repmat(sinPhi', 1, 3);
		else
			Q(:,1:3) = vaxis .* repmat(sinPhi, 1, 3);
		end
		Q(:,4)   = cosPhi;
	
	% 3xN * 1xN
	elseif szVax(1) == 3 && szVax(2) == nphi
		Q = zeros(4, szVax(2));
		if isrow(phi)
			Q(1:3,:) = vaxis .* repmat(sinPhi, 3, 1);
		else
			Q(1:3,:) = vaxis .* repmat(sinPhi', 3, 1);
		end
		Q(4,:)   = cosPhi;
	else
		error( 'Number of axes and angles do not match' );
	end
end