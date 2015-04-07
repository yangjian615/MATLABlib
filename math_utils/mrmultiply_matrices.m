%
% Name
%   mrvector_rotate
%
% Purpose
%   Multiply a matrix by another matrix.
%
% Calling Sequence
%   MATOUT = mrmatrix_multiply(MAT1, MAT2).
%     Rotate an array of 3x3 matrices MAT1 on the right by another array of
%     3x3 matrices, MAT2 -- MAT1 * MAT2 along dimension 3.
%
% Parameters
%   MAT1           in, required, type=3x3xN double
%   MAT2           in, required, type=3x3xN double
%
% Returns
%   MATOUT         out, required, type=3x3xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-07      Written by Matthew Argall
%
function matout = mrmultiply_matrices(mat1, mat2)

	% Size of the inputs
	mat1_size = size(mat1);
	mat2_size = size(mat2);
	mat1_dims = length(mat1_size);
	mat2_dims = length(mat2_size);
	
	% Allocate memory to output
	matout = zeros(mat1_size);
	
	% 3x3xN * 3x3xN
	if min(mat1_size == mat2_size)
		
		% Column 1
		matout(1,1,:) = mat1(1,1,:) .* mat2(1,1,:) + ...
		                mat1(1,2,:) .* mat2(2,1,:) + ...
		                mat1(1,3,:) .* mat2(3,1,:);
		matout(2,1,:) = mat1(2,1,:) .* mat2(1,1,:) + ...
		                mat1(2,2,:) .* mat2(2,1,:) + ...
		                mat1(2,3,:) .* mat2(3,1,:);
		matout(3,1,:) = mat1(3,1,:) .* mat2(1,1,:) + ...
		                mat1(3,2,:) .* mat2(2,1,:) + ...
		                mat1(3,3,:) .* mat2(3,1,:);
		
		% Column 2
		matout(1,2,:) = mat1(1,1,:) .* mat2(1,2,:) + ...
		                mat1(1,2,:) .* mat2(2,2,:) + ...
		                mat1(1,3,:) .* mat2(3,2,:);
		matout(2,2,:) = mat1(2,1,:) .* mat2(1,2,:) + ...
		                mat1(2,2,:) .* mat2(2,2,:) + ...
		                mat1(2,3,:) .* mat2(3,2,:);
		matout(3,2,:) = mat1(3,1,:) .* mat2(1,2,:) + ...
		                mat1(3,2,:) .* mat2(2,2,:) + ...
		                mat1(3,3,:) .* mat2(3,2,:);
		
		% Column 3
		matout(1,3,:) = mat1(1,1,:) .* mat2(1,3,:) + ...
		                mat1(1,2,:) .* mat2(2,3,:) + ...
		                mat1(1,3,:) .* mat2(3,3,:);
		matout(2,3,:) = mat1(2,1,:) .* mat2(1,3,:) + ...
		                mat1(2,2,:) .* mat2(2,3,:) + ...
		                mat1(2,3,:) .* mat2(3,3,:);
		matout(3,3,:) = mat1(3,1,:) .* mat2(1,3,:) + ...
		                mat1(3,2,:) .* mat2(2,3,:) + ...
		                mat1(3,3,:) .* mat2(3,3,:);
	else
		error( 'The matrices are not suitable for multiplying.' )
	end

end