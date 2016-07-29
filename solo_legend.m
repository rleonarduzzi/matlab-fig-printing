function [fig_han] = solo_legend (markers, labels, varargin)
% function [hf] = solo_legend (markers, labels, varargin)
%
% Builds a figure containing only a legend with the specified markers and
% labels. 
%
% It is useful when several printed figures with the same legend are needed.
%
% RFL, 23/01/2015

% Display warning if version is larger than 9.0 (2016a)
% Since strcmp returns a logical in matlab, use a workaround to do a
% lexicographical comparison:
tmp = sort ({version, '9.0'});
if strcmp (tmp{1}, '9.0')
    warning ('This function does not work properly in Matlab 2016 or later')
end


% Default values for optional parameters:
orientation = 'horizontal';
box = 'on';
linewidth = 0.5;
interpreter = 'tex';
% Input argument parsing:
ii = 1;
indiv_prop = [];
while ii < length (varargin)
    if strcmpi (varargin{ii}, 'Orientation')
        orientation = varargin{ii + 1};
        ii = ii + 1;
    elseif strcmpi (varargin{ii}, 'Box')
        box = varargin{ii + 1};
        ii = ii + 1;
    elseif strcmpi (varargin{ii}, 'LineWidth')
        linewidth = varargin{ii + 1};
        ii = ii + 1;
    elseif strcmpi (varargin{ii}, 'Interpreter')
        interpreter = varargin{ii + 1};
        ii = ii + 1;
    elseif strcmpi (varargin{ii}, 'IndivProp')
        % varargin{ii + 1}: property name
        % varargin{ii + 2}: cell array of values for each marker
        indiv_prop = [indiv_prop ; 
                      {varargin{ii + 1}} {varargin{ii+2}}];
        ii = ii + 2;
    end
    ii = ii + 1;
end

hf = figure;

% Build dummy plots with given markers, then make invisible
hold on
for ii = 1 : length (markers)
    extra_opt = {};
    for io = 1 : size (indiv_prop, 1)
        extra_opt(:, io) = {indiv_prop{io, 1} ; indiv_prop{io, 2}{ii}};
    end
    plot ([0 0], [1 1], markers{ii}, 'LineWidth', linewidth, extra_opt{:})
end
hold off
hl = legend (labels, 'Orientation', orientation, 'Interpreter', interpreter);
set (hl, 'Box', box)

% Make the axis and drawings invisible
set (get (gca, 'Children'), 'Visible', 'off')
axis off

% Change figure size according to legend
set (hl, 'Units', 'pixels')
set (hf, 'Units', 'pixels')

% Legends in Matlab 2014b don't have OuterPosition
if verLessThan ('matlab', '8.4')
    posleg = get (hl, 'OuterPosition');
else
    posleg = get (hl, 'Position');
end
posfig = get (hf, 'Position');
posleg(1 : 2) = [1 1];
posfig(3 : 4) = posleg(3 : 4);

% KLUDGE: For some reason I still don't understand, printing cuts off the 
% beggining of the legend. I add some margin to avoid this.
margin = [5 5];
posfig(3 : 4) = posfig(3 : 4) + margin;
posleg(1 : 2) = posleg(1 : 2) + margin;

set (hl, 'Position', posleg)
set (hf, 'Position', posfig)

if nargout >= 1
    fig_han = hf;
end