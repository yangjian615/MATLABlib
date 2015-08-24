%
% Name
%   MrQuaternion_Rotate
%
% Purpose
%   Apply quaternion rotation to a 3-vector.
%
% Description
%   This function QTVROT applies a quaternion rotation (or its inverse)
%   to a 3-vector V to produce a new vector VNEW.
%
%   If both V and VNEW are vector components measured in the same
%   inertial coordinate system, then VNEW returns the components of
%   the vector V rotated by quaternion Q.  I.e., the AXES stay fixed
%   and the VECTOR rotates.  Replace Q by QTINV(Q) in the case of
%   /INVERT.
%
%   If V are components of a vector measured in the "body" coordinate
%   frame, and Q represents the orientation of the body frame
%   w.r.t. the inertial frame, then VNEW are the components of the
%   same vector in the inertial frame.  I.e., the VECTOR stays fixed
%   and the AXES rotate.  For /INVERT, the coordinate transformation
%   is from inertial frame to body frame.
%
%   If either Q is a single quaternion, or V is a single 3-vector,
%   then QTVROT will expand the single to the number of elements of
%   the other operand.  Otherwise, the number of quaternions and
%   vectors must be equal.
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
%   VNEW = MrQuaternionRotate(V, Q)
%     Rotate the 3-vector V by using the quaternion Q. If V and Q are
%     in the inertial coordinate system, then V is rotated by Q and
%     the axes remain fixed. If V is in the body frame and Q in the
%     inertial frame, then the coordinate system is rotated by Q and
%     V remains fixed.
%
%   VNEW = MrQuaternionRotate(V, Q, INVERSE)
%     If INVERSE is true, the inverse rotataion will be applied.
%
% Parameters
%   V               in, required, type=3xN float
%   Q               in, required, type=4xN float
%   INVERSE         in, required, type=boolean, default=false
%
% Returns
%   VNEW            out, required, type=3xN float
%
% Example
%
%   Q1 = mrquaternion_compose([0 0 1],  32 * pi/180);
%   Q2 = mrquaternion_compose([1 0 0], 116 * pi/180);
%   Q  = mrquaternion_multiply(Q1, Q2);
%
%   V = [ [1 0 0]; [0 1 0]; [0 0 1] ];
%
%   >> vnew = mrquaternion_rotate(V, Q)
%       0.848048096156426   0.529919264233205                   0
%       0.232301315567534  -0.371759816444386   0.898794046299167
%       0.476288279712040  -0.762220579800739  -0.438371146789078
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-13      Written by Matthew Argall. Adapted from qtvrot,
%                     and IDL program by Craig B. Markwardt. See
%                     his webpage for details:
%                       http://cow.physics.wisc.edu/~craigm/idl/idl.html
%
function vnew = mrquaternion_rotate(V, Q, invert)
	% Check inputs
	if nargin == 0
		error( 'Usage: VNEW = MrQuaternion_Rotate(V, Q)' );
	end
	if nargin < 3
		invert = false;
	end
	
	% Check sizes
	szV = size(V);
	szQ = size(Q);
	assert( szV(1) == 3 || szV(2) == 3, 'V must be 3xN or Nx3.' );
	assert( szQ(1) == 4 || szQ(2) == 4, 'Q must be 4xN or Nx4.' );
	
	% Treat 3x3 (4x4) as Nx3 (Nx4)
	if szV(1) == 3 && szV(2) == 3
		warning( 'V is 3x3. Treating as Nx3.' );
	end
	if szQ(1) == 4 && szQ(2) == 4
		warning( 'Q is 4x4. Treating as Nx4' );
	end
	
	% Make sure we have 4xN
	if szV(2) == 3
		V = V';
	end
	if szQ(2) == 4
		Q = Q';
	end
	
	% Check number of vectors and quaternions.
	nV = size(V, 2);
	nQ = size(Q, 2);
	assert( nV == 1 || nQ == 1 || nV == nQ, 'Incompatible number of quaternions and vectors.' );

	% Allocate memory
	vnew = zeros( 3, max( [nV,nQ] ) );
	
	% INVERSE Transform
	if invert
		vnew(1,:) = ( Q(1,:).*Q(1,:) - Q(2,:).*Q(2,:) - Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(1,:) ...
		            + 2.0 * ( Q(1,:).*Q(2,:) + Q(3,:).*Q(4,:) ) .* V(2,:) ...
		            + 2.0 * ( Q(1,:).*Q(3,:) - Q(2,:).*Q(4,:) ) .* V(3,:);
		            
		vnew(2,:) =   2.0 * ( Q(1,:).*Q(2,:) - Q(3,:).*Q(4,:) ) .* V(1,:) ...
		            + ( -Q(1,:).*Q(1,:) + Q(2,:).*Q(2,:) - Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(2,:) ...
		            + 2.0 * ( Q(2,:).*Q(3,:) + Q(1,:).*Q(4,:) ) .* V(3,:);
		            
		vnew(2,:) =   2.0 * ( Q(1,:).*Q(3,:) + Q(2,:).*Q(4,:) ) .* V(1,:) ...
		            + 2.0 * ( Q(2,:).*Q(3,:) - Q(1,:).*Q(4,:) ) .* V(2,:) ...
		            + ( -Q(1,:).*Q(1,:) - Q(2,:).*Q(2,:) + Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(3,:);
	
	% FORWARD Transform
	else
		vnew(1,:) = ( Q(1,:).*Q(1,:) - Q(2,:).*Q(2,:) - Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(1,:) ...
		            + 2.0 * ( Q(1,:).*Q(2,:) - Q(3,:).*Q(4,:) ) .* V(2,:) ...
		            + 2.0 * ( Q(1,:).*Q(3,:) + Q(2,:).*Q(4,:) ) .* V(3,:);
		            
		vnew(2,:) =   2.0 * ( Q(1,:).*Q(2,:) + Q(3,:).*Q(4,:) ) .* V(1,:) ...
		            + ( -Q(1,:).*Q(1,:) + Q(2,:).*Q(2,:) - Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(2,:) ...
		            + 2.0 * ( Q(2,:).*Q(3,:) - Q(1,:).*Q(4,:) ) .* V(3,:);
		            
		vnew(3,:) =   2.0 * ( Q(1,:).*Q(3,:) - Q(2,:).*Q(4,:) ) .* V(1,:) ...
		            + 2.0 * ( Q(2,:).*Q(3,:) + Q(1,:).*Q(4,:) ) .* V(2,:) ...
		            + ( -Q(1,:).*Q(1,:) - Q(2,:).*Q(2,:) + Q(3,:).*Q(3,:) + Q(4,:).*Q(4,:) ) .* V(3,:);
	end

	% Return Nx3 of Nx3 was given
	if szV(2) == 3
		vnew = vnew';
	end
end
