%
% Name
%   mrquaternion_power
%
% Purpose
%   Raise quaternion Q to the "power" POW.
%
% Description
%   This function raises a quaterion Q to the power P.  The
%   operation 
%
%      QNEW = QTPOW(Q, POW)
%
%   is equivalent to
%
%      QNEW = QTEXP( POW * QTLOG(Q))
%
%   which is the same as the definition of raising a real number to
%   any power (however, QTPOW is faster than using QTLOG and QTEXP).
%
%   For integer values of POW, this form of exponentiation is also
%   directly equivalent to the multiplication of that many Q's
%   together.
%
%   Geometrically, raising Q to any power between 0 and 1 realizes a
%   rotation that smoothly interpolates between the identity
%   quaternion and Q.  Thus, QTPOW is useful for interpolation of
%   quaternions or SLERPing (spherical linear interpolation).
%
%   When raising more than one quaternion to a power at a time, the
%   number of quaternions and powers must be equal.
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
%   QNEW = mrquaternion_power(Q, P)
%     Compute QNEW, the value of Q raised to the P power.
%
% Parameters
%   Q               in, required, type=4xN float
%
% Returns
%   QINV            out, required, type=4xN float
%
% Example
%   % Form a rotation quaternion of 45 degrees about the X axis.
%   Q = qtcompose([1 0 0], pi/4);
%
%   % Raise to power of 0.3.
%   QNEW = mrquaternion_power(Q, 0.3)
%      0.117537397457838   0   0   0.993068456954926
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
function Qnew = mrquaternion_power(Q, P)
	if nargin == 0
	  error( 'Usage: QNEW = mrquaternion_invert(Q, P)' );
	end

	% Check size
	szQ = size(Q);
	assert( szQ(1) == 4 || szQ(2) == 4, 'Q must be 4xN or Nx4.' );
	
	% Turn into 4xN
	%   - 4x4 considered Nx4, to transpose it.
	if szQ(2) == 4
		Q = Q';
	end
	
	% Number of quaternions and powers
	nQ = size(Q, 2);
	nP = length(P);
	assert(nQ == 1 || nP == 1 || nQ == nP, 'Incompatible number of quaternions and powers.' );
	
	%
	% Get the vector and its magnitude
	%   - Q(1) = Vx * sinTheta
	%   - Q(2) = Vy * sinTheta
	%   - Q(3) = Vz * sinTheta
	%   - Q(4) = cosTheta
	%
	% Since |v| = 1, the magnetitude of Q(1:3) gives sinTheta.
	%
	v        = Q(1:3,:);
	sinTheta = sqrt( sum(v.^2, 1) );
	theta    = atan( sinTheta ./ Q(4,:) );
	
	% Watch for singularities
	rat = zeros(1, nQ);
	ii  = find( sinTheta ~= 0 );
	if ~isempty(ii)
		sinPTheta = sin( P .* theta );
		rat(ii)   = sinPTheta(ii) ./ sinTheta(ii);
	end

	% Calculate the result.
	N         = max( [nQ, nP] );
	Qnew      = zeros( 4, N );
	Qnew(4,:) = cos( theta .* P );
	if nQ == 1 && nP > 1
		Qnew(1:3,:) = repmat(rat, 3, N) .* repmat(v, 1, N);
	else
		Qnew(1:3,:) = repmat(rat, 3, 1) .* v;
	end
	
	% Return Nx4 if Nx4 was given
	if szQ(2) == 4
		Qnew = Qnew';
	end
end