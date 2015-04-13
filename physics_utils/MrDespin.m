%
% Name
%   MrDespin
%
% Purpose
%   Transform a vector field from a spinning frame to a despun frame.
%
% Calling Sequence
%   DESPUN = MrDespin(DATA, TIME, T_PHASE)
%     Take a vector field DATA as a function of time TIME in a spinning
%     reference frame and transform it into DESPUN, the vector field in a
%     despun coordinate system. Spin phase is determined by using the
%     T_PHASE, the time at which each phase begins, as bin edges of a histogram.
%     TIME falls into bins marked by the closest T_DSS T_PHASE down from
%     TIME. The spin phase, then, is 2 * pi / ( TIME - T_PHASE(iBin) ).
%
%   DESPUN = MrDespin(__, PHASE)
%     Provide the phase at each T_PHASE. If the length of T_PHASE is the same as
%     TIME, PHASE will be unwrapped and interpolated to TIME.
%
%   [DESPUN] = mms_dss_despin(__, 'ParamName', ParamValue)
%     Use any of the parameter name-value pairs listed below.
%
% Parameters
%   DATA            in, required, type=3xN double
%   TIME            in, required, type=1xN double
%   T_PHASE:        in, required, type=1xM double
%   PHASE:          in, optional, type=1xM double
%   'Offset'        in, optional, type=double, default=0.0
%                   A constant angular offset in radians to be added to the
%                     despinning rotation.
%   'Omega'         in, optional, type=double, default=mean(diff(T_DSS))
%                   Spin frequency of the data. Ignored if PHASE is given.
%
% Returns
%   DESPUN          out, required, type=3xN double
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-12      Written by Matthew Argall
%
function despun = MrDespin(data, time, t_phase, varargin)

	% Defaults
	omega  = [];
	offset = 0.0;
	phase  = [];
	smooth = false;

	% Was the phase given?
	nOptArgs = length(varargin);
	if mod(nOptArgs, 2) == 1
		phase       = varargin{1};
		varargin(1) = [];
		nOptArgs    = nOptArgs - 1;
	end
	
	% Step through name-value pairs
	for ii = 1 : 2: nOptArgs
		switch varargin{ii}
			case 'Omega'
				omega = varargin{ii+1};
			case 'Offset'
				offset = varargin{ii+1};
			otherwise
				error( ['Unknown parameter "' varargin{ii} '".'] );
		end
	end
	
	% Number of points to despin
	npts = length(time);
	
%------------------------------------%
% Determine Phase                    %
%------------------------------------%
	if isempty(phase)
		% Spin frequency
		if isempty(omega)
			omega = 2 * pi / mean(diff(t_phase));
		end
	
		%
		% Create bins
		%   - If TIME begins before or ends after T_PHASE, histc() will
		%     return an invalid index for all values outside the range of
		%     T_PHASE. 
		%   - Extend T_PHASE one spin period before and after TIME
		%
		
		% Spin period
		T_spin = 2 * pi / omega
		
		% Extend before
		if t_phase(1) > time(1)
			t_phase = [ t_phase(1):-T_spin:time(1)-T_spin t_phase ];
		end
		
		% Extend after
		if t_phase(end) < time(end)
			t_phase = [ t_phase (t_phase(end)+T_spin):T_spin:(time(end)+T_spin) ];
		end
	
		% Histogram data times using sunpulse times as bin edges.
		[~, inds] = histc(t_sec, t_sec_dss);
	
		% Radians into the spin
		phase = omega .* ( time - t_phase(inds) );
	
%------------------------------------%
% Unwarp and Interpolate Phase       %
%------------------------------------%
	else
		% Unwrap the phase
		phunwrap = MrPhaseUnwrap(phase)
		
		% Interpolate
		phase = interp1(t_phase, phunwrap, time)
	end
	
%------------------------------------%
% Apply Offset                       %
%------------------------------------%
	
	% Add the offset
	if offset ~= 0
		phase = phase + offset;
	end
	
%------------------------------------%
% Despin                             %
%------------------------------------%
	% Create the rotation matrix to despin the data.
	%    |  cos(omega)  sin(omega)  0  |
	%    | -sin(omega)  cos(omega)  0  |
	%    |      0           0       1  |
	spin2despun        =  zeros(3, 3, npts);
	spin2despun(1,1,:) =  cos(phase);
	spin2despun(2,1,:) =  sin(phase);
	spin2despun(1,2,:) = -sin(phase);
	spin2despun(2,2,:) =  cos(phase);
	spin2despun(3,3,:) =  1;
	
	% Despin each vector
	despun = mrvector_rotate(spin2despun, data);
end