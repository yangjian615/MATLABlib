%
% Name
%   mrvector_rotate
%
% Purpose
%   Multiply a matrix by a vector.
%
% Calling Sequence
%   ROTVEC = mrvector_rotate(MAT, VEC).
%     Rotate a vector or sequence of vectors, VEC, by a matrix or sequence
%     of matrices, MAT.
%
% Parameters
%   MAT             in, required, type=3x3 or 3x3xN double
%   VEC             in, required, type=3x1 or 3xN double
%
% Returns
%   ROTVEC          out, required, type=3x1 or 3xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-30      Written by Matthew Argall
%
function rotvec = mrvector_rotate(mat, vec)

	% Size of the inputs
	matsize = size(mat);
	vecsize = size(vec);
	matdims = length(matsize);
	vecdims = length(vecsize);
	
	% Allocate memory to output
	rotvec = zeros(vecsize);
	
	% 3x3xN * 3xN
	if matdims == 3 && vecdims == 2 && matsize(3) == vecsize(2)
		% Must permute the dimensions first
		mat = permute(mat, [1,3,2]);
		
		% Multiply
		rotvec(1,:) = mat(1,:,1) .* vec(1,:) + mat(1,:,2) .* vec(2,:) + mat(1,:,3) .* vec(3,:);
		rotvec(2,:) = mat(2,:,1) .* vec(1,:) + mat(2,:,2) .* vec(2,:) + mat(2,:,3) .* vec(3,:);
		rotvec(3,:) = mat(3,:,1) .* vec(1,:) + mat(3,:,2) .* vec(2,:) + mat(3,:,3) .* vec(3,:);
	
	% 3x3 * 3xN
	elseif matdims == 2 && vecdims == 2 && vecsize(1) == 3
		rotvec(1,:) = mat(1,1) .* vec(1,:) + mat(1,2) .* vec(2,:) + mat(1,3) .* vec(3,:);
		rotvec(2,:) = mat(2,1) .* vec(1,:) + mat(2,2) .* vec(2,:) + mat(2,3) .* vec(3,:);
		rotvec(3,:) = mat(3,1) .* vec(1,:) + mat(3,2) .* vec(2,:) + mat(3,3) .* vec(3,:);
	
	% Otherwise
	else
		error( 'The matrix and vector are not suitable for multiplying.' )
	end

end