%
% Name
%   mreul2rotm
%
% Purpose
%   Helper routine for mreul2rotm.m. Create an euler rotation matrix to
%   rotate a coordinate system about a particular axis.
%
%   IMPORTANT:
%     MATLAB's eul2rotm function is designed to rotate vectors, not
%     coordinate systems. To reproduce the functionality of eul2rotm,
%     negate the EUL vector.
%
% Calling Sequence
%   ROTM = mreul2rotm(EUL);
%     Create a rotation matrix ROTM from an array of euler angles EUL
%     (radians) applied in the sequence 'ZYX'. A sequence of 'ZYX' is
%     equivalient to  ROTM = Az * Ay * Ax
%
%   ROTM = mreul2rotm(EUL, SEQUENCE);
%     Secify the axis rotation sequence SEQUENCE
%
%   ROTM = mreul2rotm(EUL, SEQUENCE, 'Degrees', TF);
%     Indicate that the euler angles were given in units of degrees.
%
% Parameters
%   EUL             in, required, type=double
%   SEQUENCE        in, required, type=char,    defualt='ZYX'
%   'Degrees'       in, optional, type=boolean, defualt=false
%
% Examples:
%  Compare these examples to eul2rotm: http://www.mathworks.com/help/robotics/ref/eul2rotm.html
%    >> rotmZYX = mreul2rotm([0 -pi/2 0])
%       rotmZYX =
%                   6.1232e-17   0            1
%                   0            1            0
%                  -1            0   6.1232e-17
%
%    >> rotmZYZ = mreul2rotm([0 -pi/2 -pi/2], 'ZYZ')
%       rotmZYX =
%                   3.7494e-33   -6.1232e-17   1
%                   1             6.1232e-17   0
%                   -6.1232e-17   1            6.1232e-17
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-22      Written by Matthew Argall
%
function rotm = mreul2rotm(eul, varargin)
	
	degrees = false;
	
	% Optional parameters -- Sequence
	nOptArgs = length(varargin);
	if mod(nOptArgs, 2) == 1
		sequence    = varargin{1};
		nOptArgs    = nOptArgs - 1;
		varargin(1) = [];
	else
		sequence = 'ZYX';
	end
	
	% Other optional arguments
	if nOptArgs > 1
		if strcmp(varargin{1}, 'Degrees')
			degrees = varargin{2};
		else
			error( ['Argument not recognized "' varargin{1} '".'] );
		end
	elseif nOptArgs ~= 0
		error( 'Incorrect number of arguments.' );
	end
	
	% Must have same number of elements
	assert( length(eul) == length(sequence), ...
	        'Inputs must have same number of elements.' );
	
	% EUL are given in angles
	if degrees
		eul = eul * pi / 180.0;
	end

	% Loop through all angles
	nAngles = length(eul);
	rotm    = eye(3);
	for ii = nAngles : -1 : 1
		% Skip over 0 angles
		if eul(ii) == 0
			continue
		end
		
		% Apply the sequence of rotations
		temp_rotm = mreul2rotm_create(eul(ii), sequence(ii));
		rotm      = temp_rotm * rotm;
	end
end


%
% Name
%   mreul2rotm_create
%
% Purpose
%   Helper routine for mreul2rotm.m. Create an euler rotation matrix to
%   rotate a coordinate system about a particular axis.
%
% Calling Sequence
%   ROTM = mreul2rotm_create(ANGLE, AXIS);
%     Using an angle (radians) ANGLE, create an euler rotation matrix that
%     rotates a coordinate system about the axis specified by AXIS.
%     Possible values for AXIS are 'X', 'Y', or 'Z'.
%
% Parameters
%   ANGLE           in, required, type=double
%   AXIS            in, required, type=char
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-22      Written by Matthew Argall
%
function rotm = mreul2rotm_create(angle, axis)

	% Create the rotation matrix
	switch upper(axis)
		case 'X'
			rotm = [ 1       0           0; ...
			         0   cos(angle)  sin(angle); ...
			         0  -sin(angle)  cos(angle)];
		
		case 'Y'
			rotm = [ cos(angle)   0  -sin(angle); ...
			             0        1       0; ...
			         sin(angle)   0   cos(angle)];
		
		case 'Z'
			rotm = [  cos(angle)  sin(angle)  0; ...
			         -sin(angle)  cos(angle)  0; ...
			              0           0       1];

		otherwise
			error( ['Unknown axis "' axis '".'] );
	end
end