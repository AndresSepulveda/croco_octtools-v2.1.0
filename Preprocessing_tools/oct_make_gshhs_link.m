%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Link the GSHHS datasets : coastline (+ borders + rivers)
%  at crude, low, intermediate, high and full resolution 
%        
%
%  Updated    February 2025 by Gildas Cambon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

crocotools_param ; 
warning off ; 
isoctave=(exist('OCTAVE_VERSION','builtin')~=0);

r = 'n';

if (isoctave == 0)
    disp(' ')
    r = input([' Do you want to link the GSHHS data coastlines (+ borders and rivers) ? : ', COASTFILE_DIR, ...
                   '\n into m_map1.x private directory of CROCOTOOLS : ', CROCOTOOLS_dir, ...
               'UTILITIES/m_map1.4h/private/? y/[n] : '], 's');
end

if strcmp(r, 'y')
    %
    disp('')
    disp([' Note : by default the m_map version 1.4h is considered.', ...
          ' Adapt if needed with the version of m_map you use (1.4f, 1.4g, ..)'])
    disp('...')

    if (isoctave == 0)
        system(['ln -sf ', COASTFILE_DIR, '* ', CROCOTOOLS_dir, 'UTILITIES/m_map1.4h/private/'])
    else
        eval(['ln -sf ', COASTFILE_DIR, '* ', CROCOTOOLS_dir, 'UTILITIES/m_map1.4h/private/'])
    end
end