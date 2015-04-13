%
% Name
%   mrvector_magnitude
%
% Purpose
%   Find the magntidue of a vector or array of fectors.
%   A wrapper for the norm(vec, 2) function that handles
%   arrays of vectors.
%
% Calling Sequence
%   VMAG = mrvector_magnitude(VEC).
%     Find the magnitude of a 3-component vector VEC. VEC can
%     be 3xN or Nx3. The result will be an 1xN array of scalar
%     magnitudes.
%
% Parameters
%   VEC             in, required, type=3xN or Nx3 double
%
% Returns
%   VMAG            out, required, type=3xN or Nx3 double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-13      Written by Matthew Argall
%
function vmag = mrvector_magnitude(vec)

	% Size of the inputs
	vecsz = size(vec);
	
	%
	% Treating 3x3 as 3xN occurs by placing all
	% 3xN clauses before Nx3 clauses.
	%
	if vecsz(1) == 3 && vecsz(2) == 3
		warning('mrvector_magnitude:size', 'Vec is 3x3. Treating as 3xN.')
	end

%------------------------------------%
% 3x1 or 1x3                         %
%------------------------------------%
	if iscolumn(vec) || isrow(vec)
		vmag = norm( vec );

%------------------------------------%
% 3xN                                %
%------------------------------------%
	elseif vecsz(1) == 3
		vmag = sqrt( sum( vec.^2, 1 ) );

%------------------------------------%
% Nx3                                %
%------------------------------------%
	elseif vecsz(2) == 3
		vmag = sqrt( sum( vec.^2, 2 ) );
		
	% Otherwise
	else
		error( 'Cannot determine magnitude of Vec. Incorrect size.' )
	end
end