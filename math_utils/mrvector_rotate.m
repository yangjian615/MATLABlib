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
% Examples
%   Create a vector that points to (1,1,0) (i.e. 45 degrees). Rotate the
%   coordinate system by +45 degrees about the z-axis to align the x-axis
%   with the vector.
%     >> v    = [sqrt(2)/2 sqrt(2)/2 0];
%     >> rotm = [  cosd(45)  sind(45)  0;
%                 -sind(45)  cosd(45)  0;
%                     0         0      1];
%     >> rotv = mrvector_rotate(rotm, v)
%        rotv = 1     0     0
%
%   Use the same vector above, but in column vector form. Rotate
%   the CS by -45 degrees to align the y-axis with the vector.
%     >> v    = [sqrt(2)/2; sqrt(2)/2; 0];
%     >> rotm = [  cosd(-45)  sind(-45)  0;
%                 -sind(-45)  cosd(-45)  0;
%                     0         0        1];
%     >> rotv = mrvector_rotate(rotm, v)
%        rotv = 0
%               1
%               0
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

%------------------------------------%
% 3x3xN * 1x3 or 3x1                 %
%------------------------------------%
	if matdims == 3 && matdims == 3 && ( vecsize(1) == 1 || vecsize(2) == 1 )
		% Must permute the dimensions first
		mat = permute(mat, [1,3,2]);

		% Multiply
		rotvec      = zeros(3, matsize(3));
		rotvec(1,:) = mat(1,:,1) .* vec(1) + mat(1,:,2) .* vec(2) + mat(1,:,3) .* vec(3);
		rotvec(2,:) = mat(2,:,1) .* vec(1) + mat(2,:,2) .* vec(2) + mat(2,:,3) .* vec(3);
		rotvec(3,:) = mat(3,:,1) .* vec(1) + mat(3,:,2) .* vec(2) + mat(3,:,3) .* vec(3);

%------------------------------------%
% 3x3xN * 3xN                        %
%------------------------------------%
	elseif matdims == 3 && matsize(1) == 3 && matsize(2) == 3 && matsize(3) == vecsize(2) && vecsize(1) == 3
		% Must permute the dimensions first
		mat = permute(mat, [1,3,2]);
		
		% Multiply
		rotvec      = zeros( vecsize );
		rotvec(1,:) = mat(1,:,1) .* vec(1,:) + mat(1,:,2) .* vec(2,:) + mat(1,:,3) .* vec(3,:);
		rotvec(2,:) = mat(2,:,1) .* vec(1,:) + mat(2,:,2) .* vec(2,:) + mat(2,:,3) .* vec(3,:);
		rotvec(3,:) = mat(3,:,1) .* vec(1,:) + mat(3,:,2) .* vec(2,:) + mat(3,:,3) .* vec(3,:);

%------------------------------------%
% 3x3xN * Nx3                        %
%------------------------------------%
	elseif matdims == 3 && matsize(1) == 3 && matsize(2) == 3 && matsize(3) == vecsize(1) && vecsize(2) == 3
		% Must permute the dimensions first
		mat = permute(mat, [3,1,2]);
		
		% Multiply
		rotvec      = zeros( vecsize );
		rotvec(:,1) = mat(:,1,1) .* vec(:,1) + mat(:,1,2) .* vec(:,2) + mat(:,1,3) .* vec(:,2);
		rotvec(:,2) = mat(:,2,1) .* vec(:,1) + mat(:,2,2) .* vec(:,2) + mat(:,2,3) .* vec(:,2);
		rotvec(:,3) = mat(:,3,1) .* vec(:,1) + mat(:,3,2) .* vec(:,2) + mat(:,3,3) .* vec(:,2);
	
%------------------------------------%
% 3x3 * 3xN                          %
%------------------------------------%
	elseif matsize(1) == 3 && matsize(2) == 3 && matdims == 2 && vecsize(1) == 3
		rotvec      = zeros( vecsize );
		rotvec(1,:) = mat(1,1) .* vec(1,:) + mat(1,2) .* vec(2,:) + mat(1,3) .* vec(3,:);
		rotvec(2,:) = mat(2,1) .* vec(1,:) + mat(2,2) .* vec(2,:) + mat(2,3) .* vec(3,:);
		rotvec(3,:) = mat(3,1) .* vec(1,:) + mat(3,2) .* vec(2,:) + mat(3,3) .* vec(3,:);

%------------------------------------%
% 3x3 * Nx3                          %
%------------------------------------%
	elseif matsize(1) == 3 && matsize(2) == 3 && matdims == 2 && vecsize(2) == 3
		rotvec      = zeros( vecsize );
		rotvec(:,1) = mat(1,1) .* vec(:,1) + mat(1,2) .* vec(:,2) + mat(1,3) .* vec(:,3);
		rotvec(:,2) = mat(2,1) .* vec(:,1) + mat(2,2) .* vec(:,2) + mat(2,3) .* vec(:,3);
		rotvec(:,3) = mat(3,1) .* vec(:,1) + mat(3,2) .* vec(:,2) + mat(3,3) .* vec(:,3);
	
	% Otherwise
	else
		error( 'The matrix and vector are not suitable for multiplying.' )
	end

end