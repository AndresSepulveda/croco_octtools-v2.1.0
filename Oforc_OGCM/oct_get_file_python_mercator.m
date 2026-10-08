function outname = oct_get_file_python_mercator(pathCMC,...
                                            product_id,...
                                            vars,...
                                            geom,date,...
                                            info,outname)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Extract a subgrid from MERCATOR to get a CROCO forcing
%     (Store that into monthly files.
%      Take care of the Greenwitch Meridian.)
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
%  Copyright (c) 2006 by Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr
%
%  Updated   12-Feb-2016 by P. Marchesiello
%  Updated   26-Nov-2020 by G. Cambon
%  Updated   22-Feb-2024 by G. Cambon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Informations : 
% => https://help.marine.copernicus.eu/en/collections/4060068-copernicus-marine-toolbox
% => https://help.marine.copernicus.eu/en/articles/8206131-how-to-download-a-copernicus-marine-toolbox-request-in-matlab
%
if exist(outname,'file'), delete(outname); end
disp([' '])
disp(['Extraction of product: ', product_id])
disp([' '])
command = {  sprintf('export PYTHONWARNINGS="ignore"; ')
             sprintf('%s',pathCMC)
             sprintf(' subset')
             sprintf(' --username %s --password %s',info{1},info{2})
             sprintf(' -i %s',product_id)
             sprintf(' -t %s -T %s',['"',date{1},'"'],['"',date{2},'"'])
             sprintf(' -x %f -X %f',geom(1),geom(2))
             sprintf(' -y %f -Y %f',geom(3),geom(4))
             sprintf(' -z %f -Z %f',geom(5),geom(6))
             sprintf(' -o ./')
             sprintf(' -f %s',outname)};

if isa(vars,'cell')
 for k =1:size(vars,2)
     command{end+1}=sprintf(' -v %s',vars{k});
 end
end

disp([command{:}])
system([command{:}]);


