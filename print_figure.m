function imprimirFigura( nombre, width, height, fighan, varargin )
% Imprime la figura actual en formato pdf.
% Entradas:
%          nombre: nombre del archivo con formato pdf que se genera.
%          height: altura de la figura en cm
%          width:  ancho de la figura en cm
%          fighan: handle de la figura a imprimir
%
% v03
%
% Roberto Fabio Leonarduzzi
% Abril de 2013

if nargin < 4 || numel (fighan) ~= 1
    fighan = gcf;
end

% Parámetros por defecto:
use_box = 'on';
fontSize = 8;

iarg=1;
while iarg < length(varargin)
    if strcmpi (varargin{iarg}, 'Box') && strcmpi (varargin{iarg + 1}, 'off')
        use_box = 'off';
        iarg = iarg + 2;
    elseif strcmpi (varargin{iarg}, 'FontSize') 
        if ~isscalar (varargin{iarg+1})
            error ('FontSize debe ser un número.');
        end
        fontSize = varargin{iarg+1};
        iarg = iarg + 2;
    else
        iarg = iarg + 1;
    end    
end

% TODO Pasar más de este tipo de cosas como parámetro, con la sintaxis 
% 'clave', valor de matlab.


% Guardo los límites del axes para restablecerlos después.
% Esto supone que la figura tiene un solo axes.
limix = get (gca, 'XLim');
limiy = get (gca, 'YLim');

set (fighan, 'Color', [1 1 1])

% FIXME Verificar que los hijos de una figura sean sólo ejes, o en su
% defecto cosas con las propiedades Box 
axesHijos = findall(fighan, 'type', 'axes');
set (axesHijos, 'Box', use_box )
    set (axesHijos, 'FontUnits', 'points', 'FontSize', fontSize )

% Cambio la fuente de todos los hijos con propiedad texto.
set (findall(fighan, 'type', 'text'), 'FontSize', fontSize)

% Fijo las unidades en centímetros para las medidas siguientes
set (fighan, 'Units', 'centimeters')

%get(fighan, 'Position') % para debugging
% Fijo la posición y tamaño de la figura en la ventana
set( fighan, 'Position', [ 0 0 width height] )

%get(fighan, 'Position') % para debugging

% Con esto el tamaño de la figura en el papel será igual que en la pantalla.
set( fighan, 'PaperPositionMode', 'auto' )


posPantalla = get( fighan, 'Position' );
posPantalla(1:2) = [1 1];
set( fighan, 'PaperUnits', get(fighan, 'Units'), ...
          'PaperSize', posPantalla(3:4) )

% Subo un poquito el axes porque si no matlab siempre corta el xlabel.
axes_pos = get (gca, 'Position');
%axes_pos(2) = axes_pos(2) + 0.05 * axes_pos(4);
set (gca, 'Position', axes_pos)

% Después de los cambios de tamaño, restablezco los limites del axes, en caso
% de que matlab los haya cambiado
set (gca, 'XLim', limix, 'YLim', limiy)


% Guardo la figura en formato pdf
print( '-dpdf', '-loose', nombre )

close( fighan )

return
%---------------------------------------------
% Ahora cambio el título del pdf para que salga el nombre del archivo. Por
% defecto sale el nombre de un archivo temporal fiero.

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
