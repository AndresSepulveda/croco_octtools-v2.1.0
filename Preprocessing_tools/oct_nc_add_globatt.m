function oct_nc_add_globatt(filename,Yorig,Mmin,Dmin,Hmin,Min_min,Smin,product)
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
% Add global attribute with :
% - origin_date
% - product name
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
if nargin < 8
    product = 'unknown';
end
%
% datetime() does not exist in Octave: use datenum/datestr
%
origin_date = datestr(datenum(Yorig,Mmin,Dmin,Hmin,Min_min,Smin),'yyyy-mm-dd HH:MM:SS');
%
% New attributes: the file must be put back in define mode
%
ncid = netcdf.open(filename, 'NC_WRITE');
netcdf.reDef(ncid);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'origin_date', origin_date);
netcdf.putAtt(ncid, netcdf.getConstant('NC_GLOBAL'), 'product', product);
netcdf.endDef(ncid);
netcdf.close(ncid);
