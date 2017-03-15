%
% Name
%   MrLayout
%
% Purpose
%   Calculate the inner and outer positions for plots within a given layout. The
%   difference between inner and outer positions is illustrated in the MATLAB help
%   for axes::
%
%     http://www.mathworks.com/help/matlab/creating_plots/automatic-axes-resize.html
%
% Examples
%   Example 1:
%     >> layout = [2,2];
%     >> MrLayout(layout, 'Demo', true, 'OXMargin', [2,2], 'OYMargin', [2,2], 'XGap', 2, 'YGap', 2);
%
%   Example 2: Reporduce Example 1
%     >> layout = [2,2];
%     >> [inPos, outPos] = MrLayout(layout, 
%                                   'OXMargin', [2, 2], ...
%                                   'OYMargin', [2, 2], ...
%                                   'XGap',     2,      ...
%                                   'YGap',     2 );
%     >> for ii = 1 : size(inPos, 1)
%     >>   subplot( layout(1), layout(2), ii,      ...
%                   'OuterPosition', outPos(ii,:), ...
%                   'Position', inPos(ii,:) );
%     >>   h = plot([0,1], [0,1], 'LineStyle', 'none');
%     >>   title(sprintf('Plot %i', ii));
%     >>   xlabel('x');
%     >>   ylabel('y');
%     >> end
%
% Calling Sequence
%   INPOSITIONS = MrLayout(LAYOUT)
%     Determine the inner plot positions, INPOSITIONS, for all plots within a given LAYOUT.
%     LAYOUT should specify the number of columns and rows, [nCols, nRows], within the
%     desired plotting layout.
%
%   [INPOSITIONS, OUTPOSITIONS] = MrLayout(LAYOUT)
%     Return the outer positions for each plot within the given layout.
%
%   [__] = MrLayout(LAYOUT, LOCATION)
%     Return the inner (and outer) position of the plot located at LOCATION. LOCATION
%     can be specified as the [column, row] of the position to be returned, or as the
%     plot index, increasing from right-to-left then top-to-bottom within the layout
%     provided.
%
%   [__] = MrLayout(__, 'ParamName', ParamValue)
%     Any parameter name-value pair indicated below may be used.
%
% Parameters
%   LAYOUT:         in, required, type=integer
%   LOCATION:       in, optional, type=integer
%   'Aspect':       in, optional, type=float
%                   Aspect ratio of the plot positions.
%   'Demo':         in, optional, type=boolean, defualt=false
%                   If true. the results will be demonstrated in a new figure.
%   'Figure':       in, optional, type=float, default=gcf()
%                   The figure for which plot positions are determined.
%   'IXMargin':     in, optional, type=integer, default=[7,1]
%                   X-margin size, in character units, between the outer plot positions
%                     and the inner plot positions. Given as [bottom, top].
%   'IYMargin':     in, optional, type=integer, default=[3,2]
%                   Y-margin size, in character units, between the outer plot positions
%                     and the inner plot positions. Given as [bottom, top].
%   'OXMargin':     in, optional, type=integer, default=[0,0]
%                   X-margin size, in character units, between the outer boundaries
%                     of the figure and outer positions of the adjacent plots. Given
%                     as [left, right].
%   'OYMargin':     in, optional, type=integer, default=[0,0]
%                   Y-margin size, in character units, between the outer boundaries
%                     of the figure and outer positions of the adjacent plots. Given
%                     as [bottom, top].
%   'Square':       in, optional, type=boolean, default=false
%                   If true, `Aspect` will be set to 1.0.
%   'Units':        in, optional, type=char, default='normalized'
%                   Units of the output positions. Options are {'pixels' | 'normalized'}.
%   'XGap':         in, optional, type=float
%                   X-gap between outer plot position, in character units.
%   'YGap':         in, optional, type=float
%                   Y-gap between outer plot positions, in character units.
%
% Returns
%   INPOSITION:     out, required, type=1XN cell
%   OUTPOSITION:    out, optional, type=integer
%
% MATLAB release(s) 9.0.0.341360 (R2016a)
% Required Products None
%
% History:
%   2016-09-12      Written by Matthew Argall
%
function [inPositions, outPositions] = MrLayout(layout, location, varargin)
	
%------------------------------------%
% Inputs                             %
%------------------------------------%
	% Check for a valid location
	if nargin > 1
		if strcmp(class(location), 'char')
			varargin = [ location varargin ];
			location = [];
		end
	else
		location = [];
	end
	
	% Defaults
	aspect   = [];
	demo     = false;
	ixmargin = [7, 1];
	iymargin = [3, 2];
	oxmargin = [0, 0];
	oymargin = [0, 0];
	square   = false;
	theFig   = [];
	units    = 'normalized';
	xgap     = 0;
	ygap     = 0;
	
	% Check optional arguments
	nOptArgs = length(varargin);
	for ii = 1 : 2 : nOptArgs
		switch varargin{ii}
			case 'Aspect'
				aspect = varargin{ii+1};
			case 'Demo'
				demo = varargin{ii+1};
			case 'Figure'
				theFig = varargin{ii+1};
			case 'IXMargin'
				ixmargin = varargin{ii+1};
			case 'IYMargin'
				iymargin = varargin{ii+1};
			case 'OXMargin'
				oxmargin = varargin{ii+1};
			case 'OYMargin'
				oymargin = varargin{ii+1};
			case 'Square'
				square = varargin{ii+1};
			case 'Units'
				units = varargin{ii+1};
			case 'XGap'
				xgap = varargin{ii+1};
			case 'YGap'
				ygap = varargin{ii+1};
			otherwise
				error( ['Invalid optional parameter: "' varargin{ii} '".'] );
		end
	end
	
	% Dependencies
	if square
		aspect = 1.0;
	end
	
	% Make assertions
	assert( numel(layout) == 2, 'LAYOUT must have 2 elements: [nRows, nCols].')
	assert( numel(location)  < 3, 'LOCATION must have < 3 elements.')
	assert( ismember(units, {'pixels', 'normalized'}), 'UNITS must be "pixels" or "normalized".' )
	
	
	% Convert LOCATION to a plot index if necessary
	if numel(location) == 2
		iLoc = location(2) + (location(1)-1)*layout(2);
	else
		iLoc = location;
	end

%------------------------------------%
% Unit Conversions                   %
%------------------------------------%

	% Start by getting the current figure
	if isempty(theFig)
		theFig    = gcf();
	end
	fig_units = get(theFig, 'Units');
	
	% Figure size in pixels
	set( theFig, 'Units', 'pixels' );
	fig_size_pix = get( theFig, 'Position' );
	
	% Figure size in characters
	set( theFig, 'Units', 'characters' );
	fig_size_char = get( theFig, 'Position' );
	
	% Return to the original units
	set( theFig, 'Units', fig_units );
	
	% Conversion from characters to pixels
	fig_size_char = fig_size_char(3:4);
	fig_size_pix  = fig_size_pix(3:4);
	char2pix      = fig_size_pix ./ fig_size_char;
	
%------------------------------------%
% Figure Margins and Areas           %
%------------------------------------%
	nRows   = layout(1);
	nCols   = layout(2);
	nPanels = nRows * nCols;

	% Convert from character units to pixels
	ixmargin = ixmargin * char2pix(1);
	iymargin = iymargin * char2pix(2);
	oxmargin = oxmargin * char2pix(1);
	oymargin = oymargin * char2pix(2);
	xgap     = xgap     * char2pix(1);
	ygap     = ygap     * char2pix(2);

	% Calculate the area of the region in which plots will be drawn.
	%   - [left, bottom, top, right]
	p_region = [oxmargin(1), oymargin(1), fig_size_pix(1) - oxmargin(2), fig_size_pix(2) - oymargin(2)];

	% Calculate the plot dimensions
	plot_width  = (p_region(3) - p_region(1) - xgap*(nCols-1) ) / nCols;
	plot_height = (p_region(4) - p_region(2) - ygap*(nRows-1) ) / nRows;

	% Offset between upper left corner of p_region and lower right corner of
	% the plot area of each plot.
	xoffset = plot_width  .* [1:nCols] + xgap .* [0:nCols-1];
	yoffset = plot_height .* [1:nRows] + ygap .* [0:nRows-1];

	% Calculate the areas in which the plots will be created.
	outPositions = zeros(nRows, nCols, 4);
	for ii = 1 : nCols
		for jj = 1 : nRows
			outPositions(jj,ii,3) = p_region(1) + xoffset(ii);
			outPositions(jj,ii,2) = p_region(4) - yoffset(jj);
			outPositions(jj,ii,1) = outPositions(jj,ii,3) - plot_width;
			outPositions(jj,ii,4) = outPositions(jj,ii,2) + plot_height;
		end
	end

%------------------------------------%
% Outer & Inner Positions            %
%------------------------------------%
	% Subtract the inner margin to create the plot position
	inPositions = zeros(nRows, nCols, 4);
	inPositions(:,:,1) = outPositions(:,:,1) + ixmargin(1);
	inPositions(:,:,3) = outPositions(:,:,3) - ixmargin(2);
	inPositions(:,:,2) = outPositions(:,:,2) + iymargin(1);
	inPositions(:,:,4) = outPositions(:,:,4) - iymargin(2);
	
	% Reform into a 4xnCols*nRows array
	%   - MATLAB® numbers its subplots by row, such that the first subplot is the first
	%     column of the first row, the second subplot is the second column of the first
	%     row, and so on.
	%   - To make this happen, we must interchange rows and columns before reshaping
	%     so that columns are reference first.
	inPositions  = reshape( permute(inPositions,  [2,1,3]), nRows*nCols, 4);
	outPositions = reshape( permute(outPositions, [2,1,3]), nRows*nCols, 4);
	
%------------------------------------%
% Aspect Ratio                       %
%------------------------------------%
	if ~isempty(aspect) && aspect > 0
		% Loop through all of the plots
		for ii = 1 : nCols*nRows
			pWidth  = inPositions(ii,3) - inPositions(ii,1);
			pHeight = inPositions(ii,4) - inPositions(ii,2);
		
			% Make sure the scaled dimension becomes smaller
			newPWidth  = pWidth;
			newPHeight = newPWidth * aspect;
			if newPHeight > pHeight
				newPHeight = pHeight;
				newPWidth = newPHeight / aspect;
			end
		
			% Center the new position within its old position
			inPositions(ii,1) = inPositions(ii,1) + (pWidth  - newPWidth)  / 2;
			inPositions(ii,2) = inPositions(ii,2) + (pHeight - newPHeight) / 2;
			inPositions(ii,3) = inPositions(ii,1) + newPWidth;
			inPositions(ii,4) = inPositions(ii,2) + newPHeight;
		end
	end
	
%------------------------------------%
% Rearrange                          %
%------------------------------------%
	%
	% Recalculate
	%   [left, bottom, right, top] -> [left, bottom, width, height]
	%
	
	% Inner position
	inPositions(:,3) = inPositions(:,3) - inPositions(:,1);
	inPositions(:,4) = inPositions(:,4) - inPositions(:,2);
	
	% Outer Position
	outPositions(:,3) = outPositions(:,3) - outPositions(:,1);
	outPositions(:,4) = outPositions(:,4) - outPositions(:,2);
	
%------------------------------------%
% Units                              %
%------------------------------------%
	if strcmp(units, 'normalized')
		inPositions(:,[1,3]) = inPositions(:,[1,3]) / fig_size_pix(1);
		inPositions(:,[2,4]) = inPositions(:,[2,4]) / fig_size_pix(2);
		
		p_region([1,3]) = p_region([1,3]) / fig_size_pix(1);
		p_region([2,4]) = p_region([2,4]) / fig_size_pix(2);
		
		outPositions(:,[1,3]) = outPositions(:,[1,3]) / fig_size_pix(1);
		outPositions(:,[2,4]) = outPositions(:,[2,4]) / fig_size_pix(2);

	% Create integer values pixel coordinates.
	elseif strcmp(units, 'pixels')
		inPositions(:,[1,2]) = floor( inPositions(:,[1,2]) );
		inPositions(:,[3,4]) = ceil(  inPositions(:,[3,4]) );
	
		p_region([1,2]) = floor( p_region([1,2]) );
		p_region([2,3]) = ceil(  p_region([3,4]) );
	
		outPositions(:,[1,2]) = floor( outPositions(:,[1,2]) );
		outPositions(:,[3,4]) = ceil(  outPositions(:,[3,4]) );
	else
		error( ['Invalid value for "Units": "' units '".'] );
	end
	
%------------------------------------%
% Get a Specific Location            %
%------------------------------------%
	if ~isempty(iLoc)
		inPosition  = inPosition(iLoc,:);
		outPosition = outPosition(iLoc,:);
	end

	if demo
		MrLayout_Demo(layout, inPositions, outPositions, theFig);
	end
end


%
% Name
%   MrLayout_Demo
%
% Purpose
%   Create a figure and outline the positions indicated by MrLayout
%
% Calling Sequence
%   [] = MrLayout_Demo()
%     Calculate plot positions and outline them in a figure.
%
% Parameters
%
% Returns
%
% MATLAB release(s) 9.0.0.341360 (R2016a)
% Required Products None
%
% History:
%   2016-09-12      Written by Matthew Argall
%
function [] = MrLayout_Demo(layout, inPos, outPos, theFig)

	% Outline the plot positions
	for ii = 1 : size(outPos, 1)
		subplot( layout(1), layout(2), ii, 'OuterPosition', outPos(ii,:), 'Position', inPos(ii,:) );
		h = plot([0,1], [0,1], 'LineStyle', 'none');
		title(sprintf('Plot %i', ii));
		xlabel('x');
		ylabel('y');

		% Outer positions
		annotation( 'line', [outPos(ii,1)              outPos(ii,1)+outPos(ii,3)], [outPos(ii,2)              outPos(ii,2)             ], 'LineStyle', '--', 'Color', 'b' );
		annotation( 'line', [outPos(ii,1)+outPos(ii,3) outPos(ii,1)+outPos(ii,3)], [outPos(ii,2)              outPos(ii,2)+outPos(ii,4)], 'LineStyle', '--', 'Color', 'b' );
		annotation( 'line', [outPos(ii,1)+outPos(ii,3) outPos(ii,1)             ], [outPos(ii,2)+outPos(ii,4) outPos(ii,2)+outPos(ii,4)], 'LineStyle', '--', 'Color', 'b' );
		annotation( 'line', [outPos(ii,1)              outPos(ii,1)             ], [outPos(ii,2)+outPos(ii,4) outPos(ii,2)             ], 'LineStyle', '--', 'Color', 'b' );
		
		% Inner positions
		annotation( 'line', [inPos(ii,1)             inPos(ii,1)+inPos(ii,3)], [inPos(ii,2)             inPos(ii,2)            ], 'LineStyle', '-.', 'Color', 'r' );
		annotation( 'line', [inPos(ii,1)+inPos(ii,3) inPos(ii,1)+inPos(ii,3)], [inPos(ii,2)             inPos(ii,2)+inPos(ii,4)], 'LineStyle', '-.', 'Color', 'r' );
		annotation( 'line', [inPos(ii,1)+inPos(ii,3) inPos(ii,1)            ], [inPos(ii,2)+inPos(ii,4) inPos(ii,2)+inPos(ii,4)], 'LineStyle', '-.', 'Color', 'r' );
		annotation( 'line', [inPos(ii,1)             inPos(ii,1)            ], [inPos(ii,2)+inPos(ii,4) inPos(ii,2)            ], 'LineStyle', '-.', 'Color', 'r' );
	end
end