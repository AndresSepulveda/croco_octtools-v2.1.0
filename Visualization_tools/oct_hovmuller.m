function oct_hovmuller(hisfile,gridfile,lonsec,latsec,vname,tindices,vlevel,...
                   coef,colmin,colmax,ncol,xmin,xmax,tmin,tmax,pltstyle)
% OCT_HOVMULLER: copy of hovmuller using oct_ helpers

if nargin < 1
  error('You must specify a file name')
end
if nargin < 2
  gridfile=hisfile;
end
if nargin < 3
  lonsec=[];
end
if nargin < 4
  latsec=[];
end
if nargin < 5
  vname='temp';
end
if nargin < 6
  tindices=[1:4];
end
if nargin < 7
  vlevel=-10;
end
if nargin < 8
  coef=1;
end
if nargin < 9
  colmin=[];
end
if nargin < 10
  colmax=[];
end
if nargin < 11
  ncol=10;
end
if nargin < 12
  xmin=[];
end
if nargin < 13
  xmax=[];
end
if nargin < 14
  tmin=[];
end
if nargin < 15
  tmax=[];
end
if nargin < 16
  pltstyle=1;
end

% Get default values
if isempty(gridfile)
  gridfile=hisfile;
end
if isempty(lonsec) | isempty(latsec)
  [lat,lon,mask]=oct_read_latlonmask(gridfile,'r');
  latsec=mean(mean(lat));
  lonsec=[min(min(lon)) max(max(lon))];
end
if isempty(vlevel)
 vlevel=-10;
end

% Get the section using oct_ version of oct_get_xt
[x,t,var]=oct_get_xt(hisfile,gridfile,lonsec,latsec,...
                   vname,tindices,vlevel);

% Colors
maxvar=max(max(var));
minvar=min(min(var));
if isempty(colmin)
  colmin=minvar;
end
if isempty(colmax)
  colmax=maxvar;
end

% Domain size
if isempty(xmin)
  xmin=min(min(x));
end
if isempty(xmax)
  xmax=max(max(x));
end
% Time
if isempty(tmin)
  tmin=min(min(t));
end
if isempty(tmax)
  tmax=max(max(t));
end
% Do the contours (same as hovmuller)
if maxvar>minvar
  if pltstyle==1
    pcolor(x,t,var);
    ncol=128;
  elseif pltstyle==2
    contourf(x,t,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax]);
  elseif pltstyle==3
    [C,h1]=contour(x,t,var,...
    [colmin:(colmax-colmin)...
    /ncol:colmax],'k');
     clabel(C,h1,'LabelSpacing',1000,'Rotation',0)
  elseif pltstyle==4
    dcol=(colmax-colmin)/ncol;
    if minvar <0 
      [C11,h11]=contourf(x,t,var,[minvar 0]);
       caxis([minvar 0]);
    end
    if colmin < 0
      if minvar < 0 
        hold on
      end
      val=[colmin:dcol:min([colmax -dcol])];
      if length(val)<2
        val=[colmin colmin];
      end  
      [C12,h12]=contour(x,t,var,val,'k');
      if ~isempty(h12)
        clabel(C12,h12,'LabelSpacing',1000,'Rotation',0)
        set(h12,'LineStyle',':')
      end
      hold off
    end
    if colmax > 0
      if colmin < 0 | minvar < 0
        hold on
      end
      val=[max([dcol colmin]):dcol:colmax];
      if length(val)<2
        val=[colmax colmax];
      end  
      [C13,h13]=contour(x,t,var,val,'k');
      if ~isempty(h13)
        clabel(C13,h13,'LabelSpacing',1000,'Rotation',0)
      end
      hold off 
    end
    hold on
    [C10,h10]=contour(x,t,var,[0 0],'k');
    if ~isempty(h10)
      clabel(C10,h10,'LabelSpacing',1000,'Rotation',0)
      set(h10,'LineWidth',1.2)
    end
    hold off
    map=0.9+zeros(64,3);
    map2=1+zeros(32,3);
    map(33:64,:)=map2;
    colormap(map)
  end
  if pltstyle<=2
    caxis([colmin colmax])
    shading flat
    colormap(jet)
    colorbar
  end
  axis([xmin xmax tmin tmax])
end
xlabel('Position along the section [km]')
ylabel('Time [days]')
title([vname])

oct_savefig('install',gcf);   % File > Save (As): extension follows the format
return
