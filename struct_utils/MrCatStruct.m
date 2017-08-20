%
% Name
%   MrCatStruct
%
% Purpose
%   Concatenate two structures by consolidating structure fields, or elements
%   of a structure array by concatenating structure elements along a given
%   dimension.
%
% Calling Sequence
%   SOUT = MrCatStruct(STRUCT1, STRUCT2)
%     Consolidate the fields of two scalar structures, STRUCT1 and STRUCT2, into
%     a single structure, SOUT.
%
%   SOUT = MrCatStruct(STRUCT1)
%     All elements of each field of the structure array STRUCT1 will be concatenated
%     horizontally.
%
%   SOUT = MrCatStruct(STRUCT1, 'horzcat')
%     All elements of each field of the structure array STRUCT1 will be concatenated
%     horizontally.
%
%   SOUT = MrCatStruct(STRUCT1, 'vertcat')
%     All elements of each field of the structure array STRUCT1 will be concatenated
%     vertically.
%
%   SOUT = MrCatStruct(STRUCT1, DIM)
%     All elements of each field of the structure array STRUCT1 will be concatenated
%     along dimension DIM. DIM may be an array the same length as the number of fields
%     in STRUCT1. If DIM=0, a single structure element of the corresponding field will
%     be copied, and no concatenation will be performed. A negative value for DIM will
%     skip a field.
%
% Parameters
%   STRUCT1         in, required, type = struct/structarr
%   STRUCT2         in, optional, type = struct
%   DIM             in, optional, type = int/intarr/char
%
% Returns
%   SOUT            out, required, type=struct
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2016-06-09      Written by Matthew Argall
%
function sout = MrCatStruct(struct1, arg2)

	assert( isstruct(struct1), 'STRUCT1 must be a structure.' );
	
	if nargin < 2
		arg2 = 2;
	end
	
	if isstruct(arg2)
		sout = structcat1(arg2);
	else
		sout = structarrcat(arg2);
	end
	
%*****************************************************************************************
	%
	% Name
	%   MrCatStruct
	%
	% Purpose
	%   Concatenate two structures by consolidating structure fields, or elements
	%   of a structure array by concatenating structure elements along a given
	%   dimension.
	%
	% Calling Sequence
	%   SOUT = MrCatStruct(STRUCT1, STRUCT2)
	%     Consolidate the fields of two scalar structures, STRUCT1 and STRUCT2, into
	%     a single structure, SOUT. STRUCT1 should be defined in the parent function.
	%
	% Parameters
	%   STRUCT1         in, required, type = struct/structarr
	%   STRUCT2         in, required, type = struct
	%
	% Returns
	%   SOUT            out, required, type=struct
	%
	% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
	% Required Products None
	%
	% History:
	%   2016-06-09      Written by Matthew Argall
	%
	function struct1 = structcat1(struct2)
		% Names of fields in ARG2
		names  = fieldnames(struct2);
	
		% Copy each name to STRUCT1
		for ii = 1 : length(names)
			struct1.(names{ii}) = struct2.(names{ii});
		end
	end

%*****************************************************************************************

	%
	% Name
	%   MrCatStruct
	%
	% Purpose
	%   Concatenate elements of a structure array by concatenating structure elements
	%   along a given dimension.
	%
	% Calling Sequence
	%
	%   SOUT = MrCatStruct(DIM)
	%     All elements of each field of the structure array STRUCT1, defined as a variable
	%     inherited from the parent function, will be concatenated along dimension DIM.
	%     DIM may be an array the same length as the number of fields in STRUCT1. If
	%     DIM=0, a single structure element of the corresponding field will be copied, and
	%     no concatenation will be performed. A negative value for DIM will skip a field.
	%
	%   SOUT = MrCatStruct('horzcat')
	%     All elements of each field of the structure array STRUCT1 will be concatenated
	%     horizontally.
	%
	%   SOUT = MrCatStruct('vertcat')
	%     All elements of each field of the structure array STRUCT1 will be concatenated
	%     vertically.
	%
	% Parameters
	%   DIM             in, required, type = int/intarr/char
	%
	% Returns
	%   SOUT            out, required, type=struct
	%
	% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
	% Required Products None
	%
	% History:
	%   2016-06-09      Written by Matthew Argall
	%
	function sout = structarrcat(dim);
	%------------------------------------%
	% Check Inputs                       %
	%------------------------------------%
		% Concatenate over which dimension?
		if ischar(dim)
			if strcmp(dim, 'horzcat')
				dim = 2;
			elseif strcmp(dim, 'vertcat')
				dim = 1;
			else
				error('DIM must be "horzcat" or "vertcat".')
			end
		elseif ~isnumeric(dim)
			error('Value for DIM not recognized.')
		end
	
		% Structure fields
		names  = fieldnames(struct1);
		nNames = length(names);
	
		% Make sure we have the correct number of dimensions.
		if isscalar(dim)
			dim = repmat(dim, 1, nNames);
		else
			assert( length(dim) == nNames, 'DIM must have one elements per structure field.' );
		end
	
	%------------------------------------%
	% Concatenate Fields                 %
	%------------------------------------%
		for ii = 1 : length( names )
		
			% Concatenate across all structure elements
			if dim(ii) > 0
				sout.(names{ii}) = cat( dim(ii), struct1.(names{ii}) );
			
			% Copy a single structure element
			elseif dim(ii) == 0
				sout.(names{ii}) = struct1(1).(names{ii});
			end
		
			% Remove the field from the input structure to free space
			struct1 = rmfield(struct1, names{ii});
		end
	end
end