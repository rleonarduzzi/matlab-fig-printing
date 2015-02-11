function test_file_formats()
% Function to test that print_figures works for all specified file-formats.
% 
% RFL,
% February 2015

addpath ..
    
% Save output files in output_dir.
% Create if it doesn't exist
output_dir = '~/tmp';
flag_delete_output_dir = false;
if ~exist (output_dir, 'dir')
    mkdir (output_dir);
    flag_delete_output_dir = true;
end

base_filename = strcat ('tst_print_figure_', date);

% The last one should test the default case.
wanted_extensions = { 'pdf'
                    'bmp',
                    'eps',
                    'hdf',
                    'jpg',
                    'jpeg',
                    'pgm',
                    'png',
                    'ppm',
                    'tiff',
                    'tif',
                    'sarasa'
                    };

wanted_formats = {  '-dpdf',
                    '-dbmp',
                    '-depsc2',
                    '-dhdf',
                    '-djpeg',
                    '-djpeg'
                    '-dpgm',
                    '-dpng',
                    '-dppm',
                    '-dtiff',
                    '-dtiff'
                    '-dpdf',
                 };

% Extensions that matlab appends to each format:
automatic_extensions = { 'pdf',
                         'bmp',
                         'eps',
                         'hdf',
                         'jpg',
                         'jpg',
                         'pgm',
                         'png',
                         'ppm',
                         'tif',   
                         'tif',   
                         'pdf',
                   };

% Data to be plotted
xx = 0 : 0.01 : 10 * pi;
yy = sin (xx);

width = 7; 
height = 5;

%-------------------------------------------------------------------------------
wanted_mime_types = {};
gotten_mime_types = {};
idx_error = [];
for ie = 1 : length (wanted_extensions)
    % First print forcing the file format and verify the mime type
    figure
    plot (xx, yy)
    xlabel ('x')
    ylabel ('y')
    title ('title')
    filename = fullfile (output_dir, ...
                         strcat (base_filename));
    print_figure (filename, width, height, [], 'FileFormat', ...
                  wanted_formats{ie})
    filename = strcat (filename, '.', automatic_extensions{ie});
    wanted_mime_types{ie} = get_mime_type (filename);

    system (sprintf ('rm %s', filename));
    
    % Then print providing the extension and get mime type
    figure
    plot (xx, yy)
    xlabel ('x')
    ylabel ('y')
    title ('title')
    filename = fullfile (output_dir, ...
                         strcat (base_filename, '.', wanted_extensions{ie}));
    print_figure (filename, width, height)
    gotten_mime_types{ie} = get_mime_type (filename);
    
    system (sprintf ('rm %s', filename));
end

if flag_delete_output_dir
    system (sprintf ('rmdir %s', filename));
end

%-------------------------------------------------------------------------------
% Now compare the mime types
error_msg = '';
for ie = 1 : length (wanted_extensions)
    if ~strcmp (gotten_mime_types{ie}, wanted_mime_types{ie})
        tmp = sprintf (['------------\n' ...
                        'There were errors in extension %s.\n' ...
                        'Wanted MIME %s.\n' ...
                        'Gotten MIME %s.\n'], wanted_extensions{ie}, ...
                       wanted_mime_types{ie}, gotten_mime_types{ie});
        error_msg = strcat (error_msg, tmp);
    end
end

if numel (error_msg) == 0
    fprintf ('\ntest_file_formats: There were NO errors.\n\n')
else
    fprintf ('\ntest_file_formats: found %i errors. Transcript:\n\n%s\n', ...
             numel (error_msg), error_msg)
end

end  % function test_file_formats
    
function [mime] = get_mime_type (file)
    cmd = sprintf ('file -I %s', file);
    [~, output] = system (cmd);
    tok = regexp (output, '.*:\s*(.*);', 'tokens');
    assert (numel (tok) == 1)
    mime = tok{1};
end