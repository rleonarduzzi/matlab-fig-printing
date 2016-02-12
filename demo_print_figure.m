%---
% Demo script to illustrate the use of print_figures.
%
% RFL
% February 2016


SELECT_EXAMPLE = 1;
switch SELECT_EXAMPLE
  case 1
    %- Example 1
    %- Default parameters
    xx = 0 : 0.001 : 6*pi;
    yy = sin (xx);

    %- Make plot:
    figure (1)
    plot (xx, yy)
    grid on
    title ('Some title')
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

  case 2
    %- Example 2
    xx = 0 : 0.001 : 6*pi;
    yy = sin (xx);

    %- Make plot:
    figure (1)
    plot (xx, yy)
    grid on
    title ('Some title')
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
                  'FontSize', fontsize, 'FileFormat', fformat)

  case 3
    %- Example 3: subplots
    xx = 0 : 0.001 : 6*pi;
    yy = sin (xx);

    figure (1)
    for i = 1 : 4
        subplot (2, 2, i)
        plot (xx, i*yy)
        xlabel ('x')
        ylabel (sprintf ('y_%-i', i))
    end

    width = 14;
    height = 10;
    filename = 'figure3.pdf';

    print_figure (filename, width, height)

  case 4
    %- Example 4: print image using opengl renderer

    figure (1)
    imagesc (randn (512))
    width = 14;
    height = 10;
    filename = 'figure4bis.pdf';
    print_figure (filename, width, height, 'Renderer', 'painters', ...
                  'Resolution', 600)

end