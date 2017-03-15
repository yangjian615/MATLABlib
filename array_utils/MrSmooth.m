%
% Name
%   MrSmooth
%
% Purpose
%   Smooth input data with a boxcar moving average.
%
% Calling Sequence
%   XOUT = MrSmooth( X )
%     Smooth the input vector X with a 3-point moving boxcar average.
%
%   XOUT = MrSmooth( X, N )
%     Smooth the input vector X with an N-point moving boxcar average.
%
%   XOUT = MrSmooth( X, N, METHOD )
%     Specify how edge points are handled. Values for METHOD are:
%         'zeros'     -  Pad the ends with zeros
%         'truncate'  -  Pad the ends with X(1) and X(end)
%         'wrap'      -  Pad the ends by wraping X(1) to X(end+1), ... X(end) to X(-1), ...
%         'mirror'    -  Pad the ends by mirroring X(1) to X(-1), ..., X(end) to X(end+1), ...
%
% Inputs
%   X           in, required, type=numeric
%   N           in, optional, type=integer, default=3
%   METHOD      in, optional, type=char, default='zeros'
%
% Outputs
%   XOUT        out, required, type=numeric
%
% MATLAB release(s) MATLAB 9.0.0.341360 (R2016a)
% Required Products None
%
% History:
%   2017-02-16      Written by Matthew Argall
%
%***************************************************************************
function xout = MrSmooth(x, n1, method)
	
	% X
	assert( isrow(x), 'X must be a 1xN row vector.' )
	
	% N1
	if nargin() < 2
		n1 = 3;
	else
		assert( mod(n1, 2) == 1, 'N1 must be an odd integer.' )
	end
	
	% Method
	if nargin() < 3
		method = 'zeros';
	else
		assert( ischar(method), 'METHOD must be a character vector.' )
	end

%------------------------------------%
% Pad Data                           %
%------------------------------------%
	switch method
		case 'truncate'
			l_pad = repmat( x(1),   1, (n1-1)/2 );
			r_pad = repmat( x(end), 1, (n1-1)/2 );
		
		case 'zeros'
			l_pad = zeros(1, (n1-1)/2);
			r_pad = zeros(1, (n1-1)/2);
		
		case 'wrap'
			l_pad = n1(end-(n1-1)/2:end);
			r_pad = n1(1:(n1-1)/2);
		
		case 'mirror'
			l_pad = fliplr( n1(1:(n1-1)/2) );
			r_pad = fliplr( n1(end-(n1-1)/2:end) );
		
		otherwise
			error( ['Invalid value for METHOD: "' method '".'] )
	end

	% Pad the data
	x_pad = [ l_pad x r_pad ];

%------------------------------------%
% Smooth                             %
%------------------------------------%
	% Create the kernel
	kernel = ones(1,n1) / n1;
	
	% Smooth the data
	xout = conv( x_pad, kernel, 'valid' );
end

