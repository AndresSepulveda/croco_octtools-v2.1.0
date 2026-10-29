function oct_set_color(h,c,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_SET_COLOR  set(h,'color',c,...) also for contour objects: in Octave
%                 the colour of the contour lines is the 'linecolor'
%                 property of the contour group (no 'color' property)
%  Part of the Octave port of the plotting scripts of the CROCO TEST_CASES.
%
%  This file is part of CROCOTOOLS
%
%  CROCOTOOLS is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published
%  by the Free Software Foundation; either version 2 of the License,
%  or (at your option) any later version.
%
%  CROCOTOOLS is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  Copyright (c) 2026 by Andres Sepulveda
%  Andres Sepulveda 2026 - Octave adaptations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for k=1:numel(h)
  if strcmp(get(h(k),'type'),'hggroup') && isprop(h(k),'linecolor')
    set(h(k),'linecolor',c,varargin{:});
  else
    set(h(k),'color',c,varargin{:});
  end
end
return
