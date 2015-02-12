%---
% Demo script to illustrate the use of print_figures.
%
% RFL
% February 2015

xx = 0 : 0.001 : 6*pi;
yy = sin (xx);

%-------------------------------------------------------------------------------
% Example 1
% Default parameters

% Make plot:
figure (1)
plot (xx, yy)
grid on
title ('Some title')
xlabel ('x')
ylabel ('y')

% Figure size in centimeters
% (it can be included in the paper without stretching):
width = 7;
height = 5;

% Figure name:
filename = 'figure1.pdf';

print_figure (filename, width, height)

%-------------------------------------------------------------------------------
% Example 2

% Make plot:
figure (1)
plot (xx, yy)
grid on
title ('Some title')
xlabel ('x')
ylabel ('y')


width = 18;
height = 10;
filename = 'figure2';

% Font size for all objects with the text property (the default is 8)
fontsize = 12;

% File format driver to be used by matlab (see doc print):
fformat = '-depsc2';

print_figure (filename, width, height, ...
              'FontSize', fontsize, 'FileFormat', fformat)

%-------------------------------------------------------------------------------
% Example 3: subplots

figure (1)
for i = 1 : 4
    subplot (2, 2, i)
    plot (xx, i*yy)
    xlabel ('x')
    ylabel (sprintf ('y_%i', i))
end

width = 14;
height = 10;
filename = 'figure3.pdf';

print_figure (filename, width, height)