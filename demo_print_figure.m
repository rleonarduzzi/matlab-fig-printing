% Demo script to illustrate the use of print_figures.
%
% See the different subfunctions in the file to see different use cases.
% Requires the file batman.m.
%
% RFL
% July 2016

function demo_print_figure (SELECT_EXAMPLE)

    if nargin < 1
        SELECT_EXAMPLE = 1;
    end

    switch SELECT_EXAMPLE
      case 1
        % Basic example
        example_1 ()
      case 2
        % More advanced example
        example_2 ()
      case 3
        % Example with subplots
        example_3 ()
      case 4
        % Example with images
        example_4 ()
      case 5
        % Example printing a separate label
        example_5 ()
    end

end
%-------------------------------------------------------------------------------
function example_1 ()
% Basic example.

    N = 1000;  % number of points
    [xx, yyu, yyl] = batman (N);

    %- Make plot:
    figure (1)
    plot (xx, yyu, 'b', xx, yyl, 'b')
    grid on
    title ('Batman function')
    xlabel ('x')
    ylabel ('y')

    %- Figure size in centimeters
    %- (it can be included in the paper without stretching):
    width = 7;
    height = 5;

    %- Figure name:
    filename = 'figure1.pdf';

    %- Activate removal of margins (off by default)
    remove_margin = true;

    print_figure (filename, width, height, 'RemoveMargin', remove_margin)
end
%-------------------------------------------------------------------------------
function example_2 ()
% More advanced example.
% Change fontsize, specify format explicitly.

    N = 1000;  % number of points
    [xx, yyu, yyl] = batman (N);

    %- Make plot:
    figure (1)
    plot (xx, yyu, 'b', xx, yyl, 'b')
    grid on
    title ('Batman function')
    xlabel ('x')
    ylabel ('y')


    width = 18;
    height = 10;
    filename = 'figure2';

    %- Font size for all objects with the text property (the default is 8)
    fontsize = 14;

    %- File format driver to be used by matlab (see doc print):
    fformat = '-depsc2';

    print_figure (filename, width, height, ...
                  'FontSize', fontsize, ...
                  'FileFormat', fformat, ...
                  'RemoveMargin', true)

end
%-------------------------------------------------------------------------------
function example_3 ()
% Example with subplots
% DO NOT activate the RemoveMargin option when using subplots.

    N = 1000;  % number of points
    [xx, yyu, yyl] = batman (N);

    figure (1)
    for i = 1 : 4
        subplot (2, 2, i)
        plot (xx, yyu, 'b', xx, yyl, 'b')
        xlabel ('x')
        ylabel (sprintf ('y_%-i', i))
    end

    width = 14;
    height = 10;
    filename = 'figure3.pdf';

    print_figure (filename, width, height)

end
%-------------------------------------------------------------------------------
function example_4 ()
% Print an image using the opengl renderer.

    N = 1000;  % number of points
    [xx, yyu, yyl] = batman (N);

    figure (1)
    area (xx, yyu, 'FaceColor', 'k', 'ShowBaseline', 'off')
    hold on
    area (xx, yyl, 'FaceColor', 'k', 'ShowBaseline', 'off')
    hold off
    set (gca, 'Color', 'y', ...
              'XTick', [], 'Ytick', [])
    width = 14;
    height = 10;
    filename = 'figure4.pdf';
    print_figure (filename, width, height, ...
                  'Renderer', 'opengl', ...
                  'Resolution', 600, ...
                  'FigureColor', 0.4 * [1 1 1])
end
%-------------------------------------------------------------------------------
function example_5 ()
% Print a plot and the legend in a separate file.
    N = 1000;  % number of points
    [xx, yyu, yyl] = batman (N);

    markers = {'b', 'r'};
    leg_text = {'upper half', 'lower half'};

    %- Make plot:
    figure (1)
    plot (xx, yyu, markers{1})
    hold on
    plot (xx, yyl, markers{2})
    grid on
    title ('Batman function')
    xlabel ('x')
    ylabel ('y')

    width = 7;  % cm
    height = 5; % cm

    filename_fig = 'figure5.pdf';
    filename_leg = 'legend_figure_5.pdf';

    % Print figure
    print_figure (filename_fig, width, height, 'RemoveMargin', true)

    % Build and print legend:
    solo_legend (markers, leg_text, 'Orientation', 'horizontal')
    print_figure (filename_leg, 8, 1.5)

end
%-------------------------------------------------------------------------------
