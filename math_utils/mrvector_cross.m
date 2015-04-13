%
% Name
%   mrvector_cross
%
% Purpose
%   Cross two vectors. A wrapper for the cross() function. Handles
%   different sized vectors.
%
% Calling Sequence
%   VCROSS = mrvector_cross(V1, V2).
%     Cross vector V1 with vector V2. V1 and V2 can be 3xN or Nx3.
%     If V1 has three rows (columns), then VCROSS will also have
%     three rows (columns). 3x3 vectors are considered 3xN.
%
% Parameters
%   V1              in, required, type=3xN or Nx3 double
%   V2              in, required, type=3xN or Nx3 double
%
% Returns
%   VCROSS          out, required, type=3xN or Nx3 double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-13      Written by Matthew Argall
%
function vcross = mrvector_cross(v1, v2)

	% Size of the inputs
	v1size = size(v1);
	v2size = size(v2);
	
	v1colrow = isrow(v1) || iscolumn(v1);
	v2colrow = isrow(v2) || iscolumn(v2);
	
	if v1size(1) == 3 && v1size(2) == 3
		warning('mrvector_cross:size', 'V1 is 3x3. Treating as 3xN.');
	end
	
	if v2size(1) == 3 && v2size(2) == 3
		warning('mrvector_cross:size', 'V2 is 3x3. Treating as 3xN.');
	end

%------------------------------------%
% Cross 3x1 or 1x3                   %
%------------------------------------%
	if v1colrow && v2colrow
		vcross = cross( v1, v2 );
		
		if iscolumn(v1)
			vcross = vcross';
		end

%------------------------------------%
% 3x1 or 1x3 cross 3xN               %
%------------------------------------%
	elseif v1colrow && v2size(1) == 3
		vcross      = zeros( v2size );
		vcross(1,:) = v1(2) * v2(3,:) - v1(3) * v2(2,:);
		vcross(2,:) = v1(3) * v2(1,:) - v1(1) * v2(3,:);
		vcross(3,:) = v1(1) * v2(2,:) - v1(2) * v2(1,:);
		
		if iscolumn(v1)
			vcross = vcross';
		end

%------------------------------------%
% 3x1 or 1x3 cross Nx3               %
%------------------------------------%
	elseif v1colrow && v2size(2) == 3
		vcross      = zeros( v2size );
		vcross(:,1) = v1(2) * v2(:,3) - v1(3) * v2(:,2);
		vcross(:,2) = v1(3) * v2(:,1) - v1(1) * v2(:,3);
		vcross(:,3) = v1(1) * v2(:,2) - v1(2) * v2(:,1);
		
		if iscolumn(v1)
			vcross = vcross';
		end

%------------------------------------%
% 3xN cross 3x1 or 1x3               %
%------------------------------------%
	elseif v1size(1) == 3 && v2colrow
		vcross      = zeros( v1size );
		vcross(1,:) = v1(2,:) * v2(3) - v1(3,:) * v2(2);
		vcross(2,:) = v1(3,:) * v2(1) - v1(1,:) * v2(3);
		vcross(3,:) = v1(1,:) * v2(2) - v1(2,:) * v2(1);

%------------------------------------%
% Nx3 cross 3x1 or 1x3               %
%------------------------------------%
	elseif v1size(1) == 3 && v2colrow
		vcross      = zeros( v1size );
		vcross(:,1) = v1(:,2) * v2(3) - v1(:,3) * v2(2);
		vcross(:,2) = v1(:,3) * v2(1) - v1(:,1) * v2(3);
		vcross(:,3) = v1(:,1) * v2(2) - v1(:,2) * v2(1);

%------------------------------------%
% 3xN cross 3xN                      %
%------------------------------------%
	elseif v1size(1) == 3 && v2size(1) == 3
		vcross = cross(v1, v2, 1);

%------------------------------------%
% Nx3 cross Nx3                      %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(2) == 3
		vcross = cross(v1, v2, 2);

%------------------------------------%
% Nx3 cross 3xN                      %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(1) == 3
		vcross = cross(v1, v2', 2);

%------------------------------------%
% 3xN cross Nx3                      %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(1) == 3
		vcross = cross(v1, v2', 1);
		
	% Otherwise
	else
		error( 'Cannot cross v1 with v2. Incorrect sizes.' )
	end
end