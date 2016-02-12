function print_figure (filename, width, height, varargin)
% function print_figure (name, width, height, 'OptionName', option)
% Prints a figure to a given format so that it has:
%    - The desired width and height (in centimeters)
%    - A fixed fontsize in all text.
%    - No white margin around the figure.
%
% Inputs:
%         - filename: target filename. Extension determines format.
%         - width:  figure widht in centimeters
%         - height: figure height in centimeters
%
% Optional inputs (key value pairs):
%         - 'FontSize': fixed font size to be used by all objects
%         with a text property. Values: numer (default 8)
%         - 'Box': set the box of the axes on or off. Values: 'on', 'off'
%         (default off)
%         - 'Handle': handle of the figure to print. Values: valid figure
%         handle (default gcf).
%         - 'FileFormat': format to be used when printing. Values: string
%         with valid matlab driver. If not specified, it is determined from
%         the extension on filename. If this fails, the default is '-dpdf'.
%
% Get the newest version from:
%     https://github.com/rleonarduzzi/matlab-fig-printing
%
% Copyright Roberto Fabio Leonarduzzi, February 2015

%-------------------------------------------------------------------------------
% Default parameters
fighan = gcf;
use_box = 'on';
font_size = 8;
renderer = '-painters';
resolution = [];

%-------------------------------------------------------------------------------
% Determine file format from input name
% This is overriden if format is explicitly provided.

idx_ext = find (filename == '.', 1, 'last') + 1 : length (filename);
extension = filename (idx_ext);
flag_using_default_file_format = false;
switch extension
  case 'pdf'
    file_format = '-dpdf';
  case 'bmp'
    file_format = '-dbmp';
  case 'eps'
    file_format = '-depsc2';
  case 'hdf'
    file_format = '-dhdf';
  case {'jpg', 'jpeg'}
    file_format = '-djpeg';
  case 'pgm'
    file_format = '-dpgm';
  case 'png'
    file_format = '-dpng';
  case 'ppm'
    file_format = '-dppm';
  case {'tiff', 'tif'}
    file_format = '-dtiff';
  otherwise
    flag_using_default_file_format = true;
    file_format = '-dpdf';
end
%-------------------------------------------------------------------------------
% Input parsing

iarg = 1;
while iarg < length (varargin)
    if strcmpi (varargin{iarg}, 'Box') && strcmpi (varargin{iarg + 1}, 'off')
        use_box = 'off';
        iarg = iarg + 2;
    elseif strcmpi (varargin{iarg}, 'FontSize') 
        if ~isscalar (varargin{iarg+1})
            error ('Font size must be a number.');
        end
        font_size = varargin{iarg+1};
        iarg = iarg + 2;
    elseif strcmpi (varargin{iarg}, 'FileFormat') 
        if ~ischar (varargin{iarg+1})
            error ('FileFormat a string.');
        end
        file_format = varargin{iarg+1};
        flag_using_default_file_format = false;
        iarg = iarg + 2;
    elseif strcmpi (varargin{iarg}, 'Handle')
        if ~isscalar (varargin{iarg+1})
            error ('Figure handle must be a number.');
        end
        fighan = varargin{iarg+1};
        iarg = iarg + 2;
    elseif strcmpi (varargin{iarg}, 'Renderer')
        if ~ischar (varargin{iarg + 1})
            error ('Renderer must be a string')
        end
        renderer = varargin{iarg + 1};
        iarg = iarg + 2;
        if renderer(1) ~= '-'
            renderer = strcat ('-', renderer);
        end
        if ~strcmp (renderer, '-painters') && ~strcmp (renderer, '-opengl')
            error ('Renderer must be either ''painters'' or ''opengl''')
        end
    elseif strcmpi (varargin{iarg}, 'Resolution')
        if ~isscalar (varargin{iarg + 1})
            error ('Resolution must be a scalar')
        end
        resolution = sprintf ('-r%i', varargin{iarg + 1});
        iarg = iarg + 2;
    else
        iarg = iarg + 1;
    end    
end

% If resolution was specified and renderer is painters, change it to opengl
if ~isempty (resolution) && strcmp (renderer, '-painters')
    warning (['Resolution was specified but renderer is painters. ' ...
              'I''m changing it to opengl'])
    renderer = '-opengl';
end

if flag_using_default_file_format
    warning (['File extension not recognized and file format not specified.'...
              ' Using default: pdf'])
end

% TODO add more supported figures properties as key-value pairs

%-------------------------------------------------------------------------------
% Get handle to children axes.
children_axes = findall(fighan, 'type', 'axes');
nchildren = length (children_axes);

% Store children axes' limits. Later they will be restored because shrinking 
% the figure sometimes changes the limits.
for ich = length (children_axes) : -1 : 1
    limix(ich, :) = get (children_axes(ich), 'XLim');
    limiy(ich, :) = get (children_axes(ich), 'YLim');
end

set (fighan, 'Color', [1 1 1])

% Change box and fontsize of children axes
set (children_axes, 'Box', use_box )
set (children_axes, 'FontUnits', 'points', 'FontSize', font_size )

% Fix fontsize of all children with text property.
set (findall (fighan, 'type', 'text'), 'FontSize', font_size)

% Use cm as the unit for all what follows.
set (fighan, 'Units', 'centimeters')

%get(fighan, 'Position') % debugging
% Fix size and position
set (fighan, 'Position', [ 0 0 width height])

%get(fighan, 'Position') %  debugging

% Make figure size in paper the same than on the screen
set (fighan, 'PaperPositionMode', 'auto')

screen_pos = get (fighan, 'Position');
screen_pos(1:2) = [1 1];
set (fighan, 'PaperUnits', get(fighan, 'Units'), ...
             'PaperSize', screen_pos(3:4))

% Restore axes limits in case they have been changed.
for ich = 1 : nchildren
    set (children_axes(ich), 'XLim', limix(ich,:), 'YLim', limiy(ich, :))
end

% Save the figure in pdf format
print_params = {file_format, renderer, resolution, '-loose', filename};
print (print_params{:})

close (fighan)

return
%---------------------------------------------
% KLUDGE matlab2010-11 in linux uses an ugly temporal name as the pdf title.
% Try to use pdftk to use filename as title.

% TODO verificar si pdftk está instalado
try
    % Quito la ruta del nombre:
    titulo = nombre(find (nombre == '/', 1, 'last') + 1 : end);

    % Obtengo los metadatos del pdf:
    % Tengo que limpiar la variable LD_LIBRARY_PATH porque matlab la llena con
    % sus direcciones y eso hace que pdftk intente usar la libstdc de matlab, que
    % en algunas versiones produce un error. El cambio debería ser local al shell
    % temporal que abre la función unix y no debería afectar otras cosas.
    cmd = sprintf ('LD_LIBRARY_PATH=""; pdftk %s dump_data', nombre);
    [status, result] = unix (cmd);
    %result

    % Busco la posición del nombre viejo y la reemplazo por título
    [tokext] = regexp (result, ...
                       'InfoKey: Title\nInfoValue: ([^\n]+)\n', ...
                       'tokenExtents');
    result = strcat (result(1 : tokext{1}(1) - 1), ...
                     titulo, ...
                     result(tokext{1}(2) + 1  : end));
%- result(ini : fin) = [];
%- 
%- % Escribo el nombre nuevo (tengo que usar sprintf para que interprete los \n):
%- result = sprintf ('%sInfoBegin\nInfoKey: Title\nInfoValue: %s\n', result, titulo);
%- %result

    % Guardo los metadatos y modifico el pdf
    fid = fopen ('tmp_info_pdf.txt', 'w');
    fwrite (fid, result);
    fclose (fid);


    cmd = sprintf (['LD_LIBRARY_PATH="";' ...
                    'pdftk %s update_info tmp_info_pdf.txt '...
                    'output tmp_salida.pdf'], nombre);
    system (cmd);
    system (sprintf ('mv tmp_salida.pdf %s', nombre));
    system ('rm tmp_info_pdf.txt');
end
