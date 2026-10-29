function oct_export_fig(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_EXPORT_FIG  Replaces export_fig (Matlab File Exchange) in the
%                  TEST_CASES plots: saves the current figure with print
%
%  oct_export_fig -transparent -pdf file.pdf     (command syntax)
%  oct_export_fig('file.png','-png','-r150')
%
%  Format from the flags -pdf, -png, -eps, -jpg (or from the file
%  extension); -rNNN: resolution (default 150 dpi). Other export_fig
%  flags (-transparent, -painters ...) are ignored.
%
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
fname=''; fmt=''; res='-r150';
for k=1:numel(varargin)
  a=varargin{k};
  if ~ischar(a), continue, end
  if a(1)=='-'
    f=lower(a(2:end));
    if any(strcmp(f,{'pdf','png','eps','jpg','jpeg','tif','tiff','svg'})), fmt=f; end
    if numel(f)>1 && f(1)=='r' && all(isstrprop(f(2:end),'digit')), res=a; end
  else
    fname=a;
  end
end
if isempty(fname), fname='export_fig_out'; end
[p,n,e]=fileparts(fname);
if isempty(fmt), fmt=lower(strrep(e,'.','')); end
if isempty(fmt), fmt='png'; end
if strcmp(fmt,'jpg'), fmt='jpeg'; end
if strcmp(fmt,'tif'), fmt='tiff'; end
if strcmp(fmt,'eps'), dev='-depsc2'; else, dev=['-d',fmt]; end
if isempty(e), fname=fullfile(p,[n,'.',strrep(fmt,'jpeg','jpg')]); end
print(gcf,dev,res,fname);
disp(['Figure saved: ',fname])
return
