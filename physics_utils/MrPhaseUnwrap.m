%
% Name
%   MrPhaseUnwap
%
% Purpose
%   Unwrap phase. This is similar to MATLAB's unwrap() function, but accepts an arbitrary
%   phase length and tolerance. It is based off of Craig Markwardt's phunwrap.pro, which
%   can be found on his website: http://cow.physics.wisc.edu/~craigm/idl/idl.html
%
%   NOTE: the unwrapping process can be ambiguous if there is a phase
%   jump of more than a half cycle in the series.  For example, if the
%   phase changes by ~0.5 cycles, it is not possible to distinguish
%   whether there wasa +0.5 cycle or -0.5 cycle jump.  The most
%   accurate unwrapping can be performed if the PHASE series is nearly
%   continuous and does not have rapid phase changes.
%
% Calling Sequence
%   PHUNWRAP = MrPhaseUnwap(PHASE)
%     Unwrap a phase that repeats every 2 pi radians.
%
%   PHUNWRAP = MrPhaseUnwap(PHASE, MAXVAL)
%     Specify the maximum value at which the phase repeats. Typical values are
%     2*pi (radians), 1 (cycle), and 360 (degrees).
%
%   PHUNWRAP = MrPhaseUnwap(PHASE, MAXVAL, TOLERANCE)
%     A phase change by more than TOLERANCE triggers a cycle jump.
%
% Parameters
%   PHASE           in, required, type=1xN double
%   MAXVAL          in, optional, type=double, default=2*pi
%   TOLERANCE       in, optional, type=double, default=0.5*maxval
%
% Returns
%   PHASEOUT        out, required, type=1xM double
%
% Examples
%   Unwrap a signal with three cycles of length 2*pi
%     >> phase = repmat(0:pi/4:7*pi/4, 1, 3);
%        phase = 0    0.7854    1.5708    2.3562    3.1416    3.9270    4.7124    5.4978
%                0    0.7854    1.5708    2.3562    3.1416    3.9270    4.7124    5.4978
%                0    0.7854    1.5708    2.3562    3.1416    3.9270    4.7124    5.4978
%     >> phunwrap = MrPhaseUnwrap(phase);
%        phunwrap =  0         0.7854    1.5708    2.3562    3.1416    3.9270    4.7124    5.4978
%                    6.2832    7.0686    7.8540    8.6394    9.4248   10.2102   10.9956   11.7810
%                   12.5664   13.3518   14.1372   14.9226   15.7080   16.4934   17.2788   18.0642
%
%   Unwrap a signal with three cycles of length 360
%     >> phase = repmat(0:-45:-315, 1, 3);
%        phase = 0   -45   -90  -135  -180  -225  -270  -315
%                0   -45   -90  -135  -180  -225  -270  -315
%                0   -45   -90  -135  -180  -225  -270  -315
%     >> phunwrap = MrPhaseUnwrap(phase, 360.0);
%        phunwrap =    0   -45   -90  -135  -180  -225  -270  -315
%                   -360  -405  -450  -495  -540  -585  -630  -675
%                   -720  -765  -810  -855  -900  -945  -990 -1035
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-04-11      Written by Matthew Argall.
%
function phunwrap = MrPhaseUnwap(phase, maxval, tolerance)
	
	% Default to a phase range of [0, 2*pi]
	if nargin < 2
		maxval = 2 * pi;
	end
	
	% Default tolerance of half the maximum value
	if nargin < 3
		tol = maxval / 2.0;
	else
		tol = tolerance * maxval;
	end
	
	% Take the difference between elements to get the phase change
	dPhase = [ 0 diff(phase) ];
	
	% Find when the phase cycles back to starting point.
	%   - Phase jumps > abs(tol) get set equal to maxval
	%   - A phase jump from  maxval -> 0 will make dPhase negative ==> Add +maxval to keep phase positive
	%   - A phase jump from -maxval -> 0 will make dPhase positive ==> Add -maxval to keep phase negative
	phaseCycle = maxval * ( ((dPhase < -tol) == 1) - ((dPhase > tol) == 1) );
	
	% Accumulate all of the cycle switches so that, e.g. cycle 3 is offset from cycle 1
	% by two cycles.
	totPhase = cumsum(phaseCycle);

	% Add the cycles to the phase
	phunwrap = phase + totPhase;
end