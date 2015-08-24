%
% Name
%   mrvector_dot
%
% Purpose
%   Dot two vectors. A wrapper for the dot() function. Handles
%   different sized vectors.
%
% Calling Sequence
%   VCROSS = mrvector_dot(V1, V2).
%     Dot vector V1 with vector V2. V1 and V2 can be 3xN or Nx3.
%     If V1 has three rows (columns), then VCROSS will also have
%     three rows (columns). 3x3 vectors are considered 3xN.
%
% Parameters
%   V1              in, required, type=3xN or Nx3 double
%   V2              in, required, type=3xN or Nx3 double
%
% Returns
%   VDOT            out, required, type=3xN or Nx3 double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-13      Written by Matthew Argall
%
function vdot = mrvector_dot(v1, v2)

	% Size of the inputs
	v1size = size(v1);
	v2size = size(v2);
	
	v1colrow = isrow(v1) || iscolumn(v1);
	v2colrow = isrow(v2) || iscolumn(v2);
	
	%
	% Treating 3x3 as 3xN occurs by placing all
	% 3xN clauses before Nx3 clauses.
	%
	if v1size(1) == 3 && v1size(2) == 3
		warning('mrvector_dot:size', 'V1 is 3x3. Treating as 3xN.');
	end
	
	if v2size(1) == 3 && v2size(2) == 3
		warning('mrvector_dot:size', 'V2 is 3x3. Treating as 3xN.');
	end

%------------------------------------%
% Dot 3x1 or 1x3                     %
%------------------------------------%
	if v1colrow && v2colrow
		vdot = dot( v1, v2 );

%------------------------------------%
% 3x1 or 1x3 dot 3xN                 %
%------------------------------------%
	elseif v1colrow && v2size(1) == 3
		vdot = v1(1) * v2(1,:) + ...
		       v1(2) * v2(2,:) + ...
		       v1(3) * v2(3,:);

%------------------------------------%
% 3x1 or 1x3 dot Nx3                 %
%------------------------------------%
	elseif v1colrow && v2size(2) == 3
		vdot = v1(1) * v2(:,1) + ...
		       v1(2) * v2(:,2) + ...
		       v1(3) * v2(:,3);

%------------------------------------%
% 3xN dot 3x1 or 1x3                 %
%------------------------------------%
	elseif v1size(1) == 3 && v2colrow
		vdot = v1(1,:) * v2(1) + ...
		       v1(2,:) * v2(2) + ...
		       v1(3,:) * v2(3);

%------------------------------------%
% Nx3 dot 3x1 or 1x3                 %
%------------------------------------%
	elseif v1size(1) == 3 && v2colrow
		vdot = v1(:,1) * v2(1) + ...
		       v1(:,2) * v2(2) + ...
		       v1(:,3) * v2(3);

%------------------------------------%
% 3xN dot 3xN                        %
%------------------------------------%
	elseif v1size(1) == 3 && v2size(1) == 3
		vdot = dot(v1, v2, 1);

%------------------------------------%
% Nx3 dot Nx3                        %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(2) == 3
		vdot = dot(v1, v2, 2);

%------------------------------------%
% Nx3 dot 3xN                        %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(1) == 3
		vdot = dot(v1, v2', 2);

%------------------------------------%
% 3xN dot Nx3                        %
%------------------------------------%
	elseif v1size(2) == 3 && v2size(1) == 3
		vdot = dot(v1, v2', 1);
		
	% Otherwise
	else
		error( 'Cannot dot v1 with v2. Incorrect sizes.' )
	end
end