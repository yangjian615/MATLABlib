%
% Name
%   mrquaternion_invert
%
% Purpose
%   Compute inverse of a quaternion.
%
% Description
%   This function computes the inverse of the quaternion Q.  The
%   inverse of a quaternion is equivalent to a rotation about the same
%   axis but the opposite direction.
%
%   The inverse is also defined mathematically such that
%
%     QTMULT( Q, QTINV(Q) )   
%
%   becomes [0, 0, 0, 1], which is the identity quaternion.
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
%   QINV = MrQuaternion_Invert(Q)
%     Compute QINV, the inverse of quaternion Q.
%
% Parameters
%   Q               in, required, type=4xN float
%
% Returns
%   QINV            out, required, type=4xN float
%
% Example
%   >> mrquaternion_compose([0 1 0], pi/4)
%         0    0.3827         0    0.9239
%   >> mrquaternion_invert(mrquaternion_compose([0,1,0], pi/4))
%         0   -0.3827         0    0.9239
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-13      Written by Matthew Argall. Adapted from QTINV,
%                     an IDL program by Craig B. Markwardt. See
%                     his webpage for details:
%                       http://cow.physics.wisc.edu/~craigm/idl/idl.html
%
function qinv = mrquaternion_invert(Q)
	if nargin == 0
	  error( 'Usage: QINV = mrquaternion_invert(Q)' );
	end

	% Compute the inverse
	szQ = size(Q);
	if szQ(1) == 4
		qinv = [ -Q(1:3,:); Q(4,:) ];
	elseif szQ(2) == 4
		qinv = [ -Q(:,1:3) Q(:,4) ];
	else
		error( 'Q must be 4xN or Nx4.' );
	end
end
