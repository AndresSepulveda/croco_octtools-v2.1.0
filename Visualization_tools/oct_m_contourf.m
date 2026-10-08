function [cs,h]=oct_m_contourf(long,lat,data,varargin);
%  M_CONTOURF Adds filled contours to a map
%    M_CONTOURF(LONG,LAT,DATA,...) is the same as M_CONTOUR except
%    that contours are filled. Areas of data above a given level are
%    filled, areas below are left blank or are filled by a lower level.
%    NaN's in the data leave holes in the filled plot/
%
%    [CS,H] = M_CONTOURF(...) returns contour matrix C as described in 
%    CONTOURC and a vector H of handles to PATCH objects (for use by
%    CLABEL).
%
%    See also M_CONTOUR, CONTOURF

% Rich Pawlowicz (rich@ocgy.ubc.ca) 17/Jan/1998
%
% This software is provided "as is" without warranty of any kind. But
% it's mine, so you can't sell it.

% 19/02/98 - type - should have been 'clip','patch', rather than 'off'.
%  9/12/98 - handle all-NaN plots without letting contour crash.
% 6/Nov/00 - eliminate returned stuff if ';' neglected (thx to D Byrne)
% Apr/06  - workaround for v7 bug in contourf.


global MAP_PROJECTION 

% Have to have initialized a map first

if isempty(MAP_PROJECTION),
  disp('No Map Projection initialized - call M_PROJ first!');
  return;
end;

if min(size(long))==1 & min(size(lat))==1,
 [long,lat]=meshgrid(long,lat);
end;

[X,Y]=m_ll2xy(long,lat,'clip','on');  %First find the points outside

i=isnan(X);      % For these we set the *data* to NaN...
data(i)=NaN;

                 % And then recompute positions without clipping. THis
                 % is necessary otherwise contouring fails (X/Y with NaN
                 % is a no-no. Note that this only clips properly down
                 % columns of long/lat - not across rows. In general this
                 % means patches may nto line up properly a right/left edges.
if any(i(:)), [X,Y]=m_ll2xy(long,lat,'clip','patch'); end;  

if any(~i(:)),
%
% Octave: contourf of a field with NaN (land) gives wrong filled
% polygons. The NaN are filled with the neighbour values and the land is
% masked afterwards with a white surface.
%
 isoct=(exist('OCTAVE_VERSION','builtin')~=0);
 land=isnan(data);
 if isoct && any(land(:)) && any(~land(:))
   data=fill_nan(data);
 end
 if isoct && ~isempty(varargin) && isnumeric(varargin{1}) && numel(varargin{1})>1
%  levels equal to a constant part of the field (plateau) give degenerate
%  polygons in Octave: shift the levels by a negligible amount
   lev=varargin{1};
   varargin{1}=lev-1e-7*(max(lev)-min(lev));
 end
 try
   [cs,h]=contourf(X,Y,data,varargin{:});
 catch
%  Octave contourf can fail (e.g. no level inside the data range):
%  add the data extrema to the levels, else use pcolor
   try
     lev=varargin{1};
     dmin=min(data(:)); dmax=max(data(:));
     lev=unique([lev(lev>dmin & lev<dmax) dmin+1e-7*(dmax-dmin)]);
     [cs,h]=contourf(X,Y,data,lev,varargin{2:end});
   catch
     h=pcolor(X,Y,data); shading flat; cs=[];
   end
 end
 set(h,'tag','m_contourf');
 if isoct && any(land(:))
   Zl=zeros(size(data)); Zl(~land)=NaN;
   hold_state=ishold; hold on
   surface(X,Y,Zl,'FaceColor',[1 1 1],'EdgeColor','none','tag','m_contourf_land');
   if ~hold_state, hold off; end
 end
else
  cs=[];h=[];
end;
if nargout==0,
 clear cs h
end;
%
%----------------------------------------------------------------------
%
function d=fill_nan(d)
%
% Fill the NaN of a 2D field with the mean of the valid neighbours
% (iterative, from the valid points)
%
[M,L]=size(d);
for iter=1:max(M,L)
  bad=isnan(d);
  if ~any(bad(:)), break, end
  p=NaN(M+2,L+2); p(2:end-1,2:end-1)=d;
  nb=cat(3,p(1:end-2,2:end-1),p(3:end,2:end-1),p(2:end-1,1:end-2),p(2:end-1,3:end));
  n=sum(~isnan(nb),3); nb(isnan(nb))=0;
  m=sum(nb,3)./n;
  new=bad & n>0;
  d(new)=m(new);
end
d(isnan(d))=mean(d(~isnan(d)));
return
