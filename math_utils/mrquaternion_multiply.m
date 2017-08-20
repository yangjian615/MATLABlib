%
% Name
%   mrquaternion_multiply
%
% Purpose
%   Convert a rotation angle and axis into quaternion.
%
% Description
%
%   This function performs multiplication of quaternions.
%   Quaternion multiplication is not component-by-component, but
%   rather represents the composition of two rotations, namely Q2
%   followed by Q1.
%
%   More than one multiplication can be performed at one time if Q1
%   and Q2 are 4xN arrays.  In that case both input arrays must be of
%   the same dimension.
%
%   If INV1 is set, then the inverse of Q1 is used.  This is a
%   convenience, to avoid the call QTINV(Q1).  Of course, INV2 can
%   be set to use the inverse of Q2.
%
%   Note that quaternion multiplication is not commutative.
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
%   Q = mrquaternion_multiply(Q1, Q2);
%     Compute the product Q of two quaternions Q1 and Q2. If either
%     Q1 or Q2 are 4x4, they will be treated as Nx4 quaternions.
%
%   Q = mrquaternion_multiply(__, 'InvertQ1');
%     Use the inverse of Q1 instead of Q1.
%
%   Q = mrquaternion_multiply(__, 'InvertQ2');
%     Use the inverse of Q2 instead of Q2.
%
% Parameters
%   Q1              in, required, type=4xN or Nx4 float
%   Q2              in, required, type=4xN or Nx4 float
%
% Returns
%   Q               out, required, type=4xN float if Q1 is 4xN
%                                       Nx4 float if Q1 is Nx4 (or 4x4)
%
% Example
%   Form a rotation quaternion of 32 degrees around the Z axis, and 
%   116 degrees around the X axis, then multiply the two quaternions.
%
%     >> Q1 = mrquaternion_compose( [0 0 1],  32 * pi/180 );
%     >> Q2 = mrquaternion_compose( [1 0 0], 116 * pi/180 );
%     >> Q  = mrquaternion_multiply(Q1, Q2)
%          0.815196151148589   0.233753734830198   0.146065544789730   0.509391090647197
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-13      Written by Matthew Argall. Adapted from QTCOMPOSE,
%                     an IDL program by Craig B. Markwardt. See
%                     his webpage for details:
%                       http://cow.physics.wisc.edu/~craigm/idl/idl.html
%   2015-08-29      Fixed typos in multiplication step. - MRA
%
function Q = mrquaternion_multiply(Q1, Q2, arg3, arg4)

% THIS ROUTINE MULTIPLIES QUATERNIONS
% CQT CORRESPONDS TO THE ROTATION AQT FOLLOWED BY BQT
% ASSUMING S/C COORDINATES ARE INITIALLY ALIGN WITH INERTIAL COORD.
% THEN ROTATION AQT DESCRIBES ROTATION SUCH THAT THE SUBROUTINE
%   QTXRA GIVES THE INERTIAL COORDINATES OF THE S/C X-AXIS
%   THE FIRST 3 COMPONENTS OF AQT GIVE THE EIGENAXIS EXPRESSED
%   IN S/C COORDINATES BEFORE THE ROTATION (=INTERTIAL COORD.).
% THE BQT ROTATION FOLLOWS THE AQT ROTATION. CQT THEN DESCRIBES
%   THIS COMBINATION SUCH THAT QTXRA GIVES THE INERTIAL COORDINATES
%   OF THE S/C X-AXIS AFTER BOTH ROTATIONS. 
%   THE FIRST 3 COMPONENTS OF BQT GIVE THE EIGENAXIS EXPRESSED
%   IN S/C COORDINATES AFTER THE AQT ROTATION.

	% Invert?
	tf_invert_q1 = false;
	tf_invert_q2 = false;

	% Check arguments
	if nargin == 0
		error( 'Usage: Q = mrquaternion_multiply(Q1, Q2)' );
	end
	if nargin > 2
		switch arg3
			case 'InvertQ1'
				tf_invert_q1 = true;
			case 'InvertQ2'
				tf_invert_q2 = true;
			otherwise
				error( 'Invalid third argument.' )
		end
	end
	if nargin == 4
		switch arg4
			case 'InvertQ1'
				tf_invert_q1 = true;
			case 'InvertQ2'
				tf_invert_q2 = true;
			otherwise
				error( 'Invalid fourth argument.' )
		end
	end
	
	% Check sizes
	sz1 = size(Q1);
	sz2 = size(Q2);
	assert( sz1(1) == 4 || sz1(2) == 4, 'Q1 must be 4xN or Nx4.');
	assert( sz2(1) == 4 || sz2(2) == 4, 'Q2 must be 4xN or Nx4.');
	if sz1(1) == 4 && sz1(2) == 4
		warning( 'Q1 is 4x4. Treating as Nx4.');
	end
	if sz2(1) == 4 && sz2(2) == 4
		warning( 'Q2 is 4x4. Treating as Nx4.');
	end

	% Number of quaternions given
	n1 = sz1(1)*sz1(2) / 4;
	n2 = sz2(1)*sz2(2) / 4;
	assert( n1 == 1 || n2 == 1 || n1 == n2, ...
	        'Q1 and Q1 must have one or the same number of quaternions.' );
	
	% Ensure both are Nx4
	if sz1(1) == 4 && sz1(2) ~= 4
		Q1 = Q1';
	end
	if sz2(1) == 4 && sz2(2) ~= 4
		Q2 = Q2';
	end
	
	% Invert quaternions
	if tf_invert_q1
		Q1(:,1:3) = -Q1(:,1:3);
	end
	if tf_invert_q2
		Q2(:,1:3) = -Q2(:,1:3);
	end
	
	% Compute the quaternion
	Q      = zeros( max([n1 n2]), 4 );
	Q(:,1) =  Q1(:,1).*Q2(:,4) + Q1(:,2).*Q2(:,3) - Q1(:,3).*Q2(:,2) + Q1(:,4).*Q2(:,1);
	Q(:,2) = -Q1(:,1).*Q2(:,3) + Q1(:,2).*Q2(:,4) + Q1(:,3).*Q2(:,1) + Q1(:,4).*Q2(:,2);
	Q(:,3) =  Q1(:,1).*Q2(:,2) - Q1(:,2).*Q2(:,1) + Q1(:,3).*Q2(:,4) + Q1(:,4).*Q2(:,3);
	Q(:,4) = -Q1(:,1).*Q2(:,1) - Q1(:,2).*Q2(:,2) - Q1(:,3).*Q2(:,3) + Q1(:,4).*Q2(:,4);

	% Return 4xN if Q1 was 4xN
	if sz1(1) == 4 && sz1(2) ~= 3
		Q = Q';
	end
end