%
% Name
%   mrquaternion_interp
%
% Purpose
%   Smoothly interpolate from a grid of quaternions (spline or slerp).
%
% Description
%  This function is used to interplate from a set of known unit
%  quaternions specified on a grid of independent values, to a new set
%  of independent values.  For example, given a set of quaternions at
%  specified key times, QTERP can interpolate at any points between
%  those times.  This has applications for computer animation and
%  spacecraft attitude control.
%
%  The "grid" of quaternions can be regularly or irregularly sampled.
%  The new values can also be regularly or irregularly sampled.
%
%  The simplest case comes when one wants to interpolate between two
%  quaternions Q1 and Q2.  In that case the user should specify the
%  gridded quaterion as QGRID = [[Q1], [Q2]], with grid points at
%  TGRID = [0d, 1d].  Then the user can sample any intermediate
%  orientation by specifying TNEW anywhere between 0 and 1.
%
%  The user has the option of performing pure spline interpolation of
%  the quaternion components (the default technique).  The resulting
%  interpolants are normalized to be unit quaternions.  This option is
%  useful for fast interpolation of quaternions, but suffers if the
%  grid is not well sampled enough.  Spline interpolation will not
%  strictly find the shortest path between two orientations.
%
%  The second option is to use Spherical Linear IntERPolation, or
%  SLERPing, to interpolate between quaternions (by specifying the
%  SLERP keyword).  This technique is guaranteed to find the shortest
%  path between two orientations, but is somewhat slower than spline
%  interpolation.  This approach involves computing a finite
%  difference of the data.  To avoid repeated computation of the
%  difference on every call, users can pass a named variable in the
%  QDIFF keyword.  This value can be reset with the RESET keyword.
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
%   Q_NEW = mrquaternion_interp(Q, T, T_NEW)
%     Interpolate quaternions Q from grid T onto a new grid T_NEW.
%     Cubic spline interpolataion is used.
%
%   Q_NEW = mrquaternion_interp(Q, t, t_new, 'slerp')
%     Use Spherical Linear intERPolation (SLERPing)
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
%   This example starts with two quaternions representing rotations of
%   0 degrees and 45 degrees, and forms 1001 quaternions which are
%   smooth interpolations between 0 and 45 degrees.
%
%   ;; Create a grid of two quaternions at times 0 and 1
%   Q0 = mrquaternion_compose([1 0 0], 0);
%   T0 = 0.0;
%   Q1 = mrquaternion_compose([1 0 0], pi/4);
%   T1 = 1.0;
%
%   ;; Put the grid elements into an array
%   TGRID = [T0  T1];
%   QGRID = [Q0; Q1];
%
%   ;; Make an array of 11 values smoothly varying from 0 to 1
%   TNEW = 0:0.1:1;
%
%   ;; Perform spherical linear interpolation
%   QNEW = mrquaternion_interp(TGRID, QGRID, TNEW, 'slerp')
%       0.0000000       0.0000000       0.0000000       1.0000000
%     0.039259816       0.0000000       0.0000000      0.99922904
%     0.078459096       0.0000000       0.0000000      0.99691733
%      0.11753740       0.0000000       0.0000000      0.99306846
%      0.15643447       0.0000000       0.0000000      0.98768834
%      0.19509032       0.0000000       0.0000000      0.98078528
%      0.23344536       0.0000000       0.0000000      0.97236992
%      0.27144045       0.0000000       0.0000000      0.96245524
%      0.30901699       0.0000000       0.0000000      0.95105652
%      0.34611706       0.0000000       0.0000000      0.93819134
%      0.38268343       0.0000000       0.0000000      0.92387953
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
function Q_new = mrquaternion_interp(t, Q, t_new, arg4)
	% Defaults
	dQ       = [];
	tf_slerp = false;
	
	% Check inputs
	if nargin == 0
		error( 'Usage: VNEW = mrquaternion_interp(Q, T, T_NEW)' );
	end
	if nargin == 4
		assert( strcmp(arg4, 'slerp'), 'Unknown fourth parameter.' )
		tf_slerp = true;
	end

	% Check size
	szQ = size(Q);
	assert( szQ(1) == 4 || szQ(2) == 4, 'Q must be 4xN or Nx4.' );
	if szQ(1) == 4 && szQ(2) == 4
		warning( 'MrQuaternion:Interp', 'Q is 4x4. Treating as Nx4.' );
	end
	
	% Make sure we have 4xN
	%   - 4x4 is treated as Nx4, so transpose it.
	if szQ(2) == 4
		Q = Q';
	end
	
	% Number of quaternions in and out
	nQ = size(Q, 2);
	N  = length(t_new);
	
	% REPLICATE
	if nQ == 1
		% If only one quaternion was given, replicate it.
		Q_NEW = repmat(Q, 1, length(t_new));
	
	% SLERP
	elseif tf_slerp
		if isempty(dQ) || tf_reset
			% Find the derivative of Q (??)
			dQ = mrquaternion_multiply( Q(:,1:end-1), Q(:,2:end), 'InvertQ1' );
			
			% Normalize the quaternions to get the smallest path
			idx = find( dQ(4,:) < 0 );
			if ~isempty( idx )
				dQ(4,idx) = -dQ(4,idx);
			end
		end
		
		% Locate T within T_NEW
		%   - HISTC() requires the following
		assert(issorted(t) && issorted(t_new), 'T and T_NEW must be monotonically increasing.');
		assert( ~isa(t, 'int64') && ~isa(t_new, 'int64'), 'T and T_NEW cannot be int64.');
		[~, ii] = histc(t_new, t);
		
		% Adjust values that are outside the existing data range.
		ii( ii == 0 )    = 1;
		ii( ii >  nQ-1 ) = nQ - 1;
		
		% Assuming T_NEW is less course than T
		%   - Normalize the relative distance between time points
		hh = ( t_new - t(ii) ) ./ ( t(ii+1) - t(ii) );

		% Smoothly interpolate
		Q_pow = mrquaternion_power( dQ(:,ii), hh );
		Q_new = mrquaternion_multiply( Q(:,ii),  Q_pow );

	% SPLINE
	else
		% Interpolate
		Q_new = zeros(4, N);
		for ii = 1 : 4
			Q_new(ii,:) = spline(t, Q(ii,:), t_new);
		end

		% Normalize the vector
		mag = sqrt( sum(Q_new.^2, 1) );
		for ii = 1 : 4
			Q_new(ii,:) = Q_new(ii,:) ./ mag;
		end
	end
	
	% If Nx4 was given, return Mx4
	if szQ(2) == 4
		Q_new = Q_new';
	end
end