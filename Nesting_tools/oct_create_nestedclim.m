function ncidclim=oct_create_nestedclim(climfile,gridfile,parentfile,title,...
				  theta_s,theta_b,Tcline,N,...
				  ttime,stime,utime,vtime,sshtime,...
				  tcycle,scycle,ucycle,vcycle,sshcycle,...
                  tbiol, cbiol,tpisces,cpisces,...
                  clobber,...    
				  biol,pisces,timebiol,cyclebiol,timepisces,cyclepisces, ...
                  namebiol,namepisces,unitbiol,unitpisces,hc,vtransform,Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  function ncclim=oct_create_climfile(climfile,gridfile,theta_s,...
%                  theta_b,Tcline,N,...
%            ttime,stime,utime,vtime,sshtime,...
%            tcycle,scycle,ucycle,vcycle,sshcycle,...
%                  clobber) 
%
%   This function create the header of a Netcdf climatology 
%   file.
%
%   Input: 
%
%   climfile     Netcdf climatology file name (character string)
%   gridfile     Netcdf grid file name (character string).
%   theta_s      S-coordinate surface control parameter.(Real)
%   theta_b      S-coordinate bottom control parameter.(Real)
%   Tcline       Width (m) of surface or bottom boundary layer
%                where higher vertical resolution is required 
%                during stretching.(Real)
%   N            Number of vertical levels.(Integer)
%   ttime        Temperature climatology time.(vector) 
%   stime        Salinity climatology time.(vector)
%   utime        Velocity climatology time.(vector)
%   cycle        Length (days) for cycling the climatology.(Real)
%   clobber      Switch to allow or not writing over an existing
%                file.(character string)
%
%   Output
%
%   ncclim       Output netcdf object.
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
%  Copyright (c) 2004-2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): kept for compatibility. The file is now
%  created with the structure of the parent file by oct_create_nestedfile
%  (the previous automatic conversion had broken the variable
%  definitions and lost many attributes). The nesting routines call
%  oct_nested_file directly.
%
oct_create_nestedfile(parentfile,climfile,gridfile,title)
ncidclim = netcdf.open(climfile, 'NC_WRITE');
return
