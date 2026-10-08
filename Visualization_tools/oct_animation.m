function oct_animation(handles)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_animation(handles)
%
%  Create an oct_animation from a CROCO netcdf file
%
%  Switch to enable fli animations and/or mpeg animations 
%
%  Further Information:  
%  http://www.croco-ocean.org
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
%  You should have received a copy of the GNU General Public License
%  along with this program; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston,
%  MA  02111-1307  USA
%
%  Copyright (c) 2002-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated 02-Nov-2006 by Pierrick Penven (Yorig)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): the FLI/MPEG tools (ppmtompeg, fli) are
%  replaced by PNG frames written in <vname>_z<level>_frames/, an
%  animated GIF (imwrite) and, if ffmpeg is installed, an MP4 movie.
%
vn=handles.vname;
vn(vn=='*')=''; vn=regexprep(vn,'[^\w\-\.]','');
moviename=[vn,'_z',num2str(handles.vlevel)];
framedir=[moviename,'_frames'];
if ~exist(framedir,'dir'), mkdir(framedir); end
%
% Number of records
%
ncid = netcdf.open(handles.hisfile, 'NC_NOWRITE');
ntime=0;
for tn={'time','tclm_time','time_counter','ocean_time'}
  try
    [~,ntime]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, tn{1}));
  end
  if ntime>0, break, end
end
netcdf.close(ncid);
if ntime==0
  error('No time dimension found')
end
skip=max(1,handles.skipanim);
fr=0;
gifname=[moviename,'.gif'];
for tindex=1:skip:ntime
  fr=fr+1;
  fig=figure(1);
  clf
  oct_horizslice(handles.hisfile,handles.vname,tindex,...
         handles.vlevel,handles.rempts,handles.coef,handles.gridlevs,...
         handles.colmin,handles.colmax,handles.lonmin,handles.lonmax,...
         handles.latmin,handles.latmax,handles.ncol,...
         handles.pltstyle,handles.isobath,handles.cstep,...
         handles.cscale,handles.cunit,handles.coastfile,...
         handles.townfile,handles.gridfile,[],[],...
         handles.Yorig)
  drawnow
  png=fullfile(framedir,sprintf('frame_%04d.png',fr));
  print(fig,'-dpng','-r100',png);
  try
    rgb=imread(png);
    q=floor(double(rgb)/256*6);                  % 6x6x6 colour cube
    im=uint8(q(:,:,1)*36+q(:,:,2)*6+q(:,:,3));
    [r,g,b]=ndgrid(0:5,0:5,0:5);
    map=([b(:) g(:) r(:)]+0.5)/6;
    if fr==1
      imwrite(im,map,gifname,'gif','DelayTime',0.5,'LoopCount',Inf);
    else
      imwrite(im,map,gifname,'gif','WriteMode','append','DelayTime',0.5);
    end
  catch err
    if fr==1, disp(['No animated GIF: ',err.message]); end
  end
  disp(['Frame ',num2str(fr),' (time index ',num2str(tindex),')'])
end
disp(['PNG frames in ',framedir,'/  -  animated GIF: ',gifname])
[st,~]=system('which ffmpeg');
if st==0
  cmd=['ffmpeg -y -loglevel error -framerate 2 -i ',framedir,'/frame_%04d.png ',...
       '-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -pix_fmt yuv420p ',moviename,'.mp4'];
  if system(cmd)==0
    disp(['MP4 movie: ',moviename,'.mp4'])
  end
end
return
