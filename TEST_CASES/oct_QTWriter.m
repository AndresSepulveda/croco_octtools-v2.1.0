classdef oct_QTWriter < handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_QTWRITER  Replaces QTWriter (Matlab File Exchange) in the
%                TEST_CASES plots: the frames are written as PNG files
%                and assembled with ffmpeg when the writer is closed
%
%  movObj = oct_QTWriter('movie.mov');
%  movObj.FrameRate = 5;
%  writeMovie(movObj,getframe(hf));
%  movObj.Loop = 'loop';             % ignored
%  close(movObj);                    % movie written with ffmpeg (H.264)
%
%  Without ffmpeg the PNG frames are kept in the folder <name>_frames.
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
  properties
    FileName='';
    FrameRate=5;
    Loop='';
    Quality=[];
    nframes=0;
    dir='';
    sz=[];
  end
  methods
    function obj=oct_QTWriter(fname,varargin)
      obj.FileName=fname;
      [p,n]=fileparts(fname);
      if isempty(p), p=pwd; end
      obj.dir=fullfile(p,[n,'_frames']);
      if ~exist(obj.dir,'dir'), mkdir(obj.dir); end
      d=dir(fullfile(obj.dir,'f_*.png'));
      for k=1:numel(d), delete(fullfile(obj.dir,d(k).name)); end
      for k=1:2:numel(varargin)
        if isprop(obj,varargin{k}), obj.(varargin{k})=varargin{k+1}; end
      end
    end
    function writeMovie(obj,fr)
      if isstruct(fr), img=fr.cdata; else, img=fr; end
      if isempty(obj.sz)
        obj.sz=2*floor([size(img,1) size(img,2)]/2);     % even size (H.264)
      end
      s=obj.sz;
      im=zeros(s(1),s(2),3,class(img));
      n1=min(s(1),size(img,1)); n2=min(s(2),size(img,2));
      im(1:n1,1:n2,:)=img(1:n1,1:n2,1:3);
      obj.nframes=obj.nframes+1;
      imwrite(im,fullfile(obj.dir,sprintf('f_%05d.png',obj.nframes)));
    end
    function close(obj)
      if obj.nframes==0, return, end
      [st,~]=system('ffmpeg -version');
      if st~=0
        disp(['oct_QTWriter: ffmpeg not found, the PNG frames are in ',obj.dir]); return
      end
      cmd=sprintf('ffmpeg -y -loglevel error -framerate %g -i "%s" -c:v libx264 -pix_fmt yuv420p "%s"',...
                  obj.FrameRate,fullfile(obj.dir,'f_%05d.png'),obj.FileName);
      [st,out]=system(cmd);
      if st==0
        d=dir(fullfile(obj.dir,'f_*.png'));
        for k=1:numel(d), delete(fullfile(obj.dir,d(k).name)); end
        try, rmdir(obj.dir); end
        disp(sprintf('oct_QTWriter: %d frames written in %s',obj.nframes,obj.FileName));
      else
        disp(['oct_QTWriter: ffmpeg error (',strtrim(out),'), the PNG frames are in ',obj.dir]);
      end
    end
  end
end
