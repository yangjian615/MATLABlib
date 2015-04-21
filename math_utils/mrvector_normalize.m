%
% Name
%   mrvector_normalize
%
% Purpose
%   Create a unit vector out of a 3-component vector. Arrays
%   of vectors are also handled.
%
% Calling Sequence
%   VUNIT = mrvector_normalize(VEC).
%     Turn a 3-component vector VEC into a unit vector VUNIT.
%     VEC can be 3xN or Nx3 arrays of vectors. VUNIT will be
%     the same size as VEC.
%
% Parameters
%   VEC             in, required, type=3xN or Nx3 double
%
% Returns
%   VUNIT           out, required, type=3xN or Nx3 double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-13      Written by Matthew Argall
%
function vunit = mrvector_normalize(vec)

	% Size of the vector
	vecsz = size(vec);

	% Magnitude of the vector
	vmag = mrvector_magnitude(vec);

%------------------------------------%
% 3xN                                %
%------------------------------------%
	if vecsz(1) == 3
		vunit(1,:) = vec(1,:) ./ vmag;
		vunit(2,:) = vec(2,:) ./ vmag;
		vunit(3,:) = vec(3,:) ./ vmag;

%------------------------------------%
% Nx3                                %
%------------------------------------%
	elseif vecsz(2) == 3
		vunit(:,1) = vec(:,1) ./ vmag;
		vunit(:,2) = vec(:,2) ./ vmag;
		vunit(:,3) = vec(:,3) ./ vmag;
	
	else
		error( 'Cannot normalize VEC. Improper size.' );
	end
end