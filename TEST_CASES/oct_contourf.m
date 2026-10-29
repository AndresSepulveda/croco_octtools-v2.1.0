function varargout=oct_contourf(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_CONTOURF  contourf that does not stop when no contour level is
%                inside the range of the data: Octave 8 then fails with
%                "'cont_lev' undefined" (Matlab draws nothing); here a
%                warning is given and nothing is drawn, so that the rest
%                of the figure is made. Same arguments and outputs as
%                contourf.
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
try
  [c,h]=contourf(varargin{:});
catch err
  if isempty(strfind(err.message,'cont_lev')), rethrow(err); end
  warning('oct_contourf: no contour level inside the range of the data: nothing drawn');
  c=[]; h=[];
end
if nargout>0, varargout{1}=c; end
if nargout>1, varargout{2}=h; end
return
