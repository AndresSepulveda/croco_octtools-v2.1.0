clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Add biological parameters to CROCO input files
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
%  Copyright (c) 2003-2006 by Pierrick Penven
%  e-mail:Pierrick.Penven@ird.fr
%
%  Contributions of P. Marchesiello (IRD)
%
%  Updated    1-Sep-2006 by Pierrick Penven
%  Updated    11-Oct-2013 by Elodie Gutknecht
%  Updated    23-Oct-2013 by Gildas Cambon
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Common parameters
%
crocotools_param
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------
% Climatological file
%----------------------------------------------------------------------
if (makeclim)
   disp('===========================================================')
   disp('Climatology for the biogeochemical model')
   if (makenpzd)
      disp('========================')
      disp('Climatology for NPZD variables')
      oct_make_clim_npzd
   end
   if (makebioebus)
      disp('========================')
      disp('Climatology for BioEBUS variables')
      oct_make_clim_bioebus
   end
   if (makepisces)
      disp('========================')
      disp('Climatology for PISCES variables')
      oct_make_clim_pisces
      disp('------------------------')
      disp('Iron deposition file')
      oct_make_dust
      disp('------------------------')
      disp('Nitrogen deposition')
      oct_make_ndepo
   end

end

%----------------------------------------------------------------------
% Bry file
%----------------------------------------------------------------------
if (makebry)
   disp('===========================================================')
   disp('Bry for the biogeochemical model')
   if (makenpzd)
      disp('========================')
      disp('Bry for NPZD variables')
      oct_make_bry_npzd
   end
   if (makebioebus)
      disp('========================')
      disp('Bry for BioEBUS variables')
      oct_make_bry_bioebus
   end
   if (makepisces)
      disp('========================')
      disp('Bry for PISCES variables')
      oct_make_bry_pisces
      disp('------------------------')
      disp('Iron deposition file')
      oct_make_dust
      disp('------------------------')
      disp('Nitrogen deposition')
      oct_make_ndepo
   end

end

%----------------------------------------------------------------------
% Initial file
%----------------------------------------------------------------------

if (makeini)
   disp('===========================================================')
   disp('Initial variables for the biogeochemical model')
   if (makenpzd)
      disp('========================')
      disp('Initial NPZD variables')
      oct_make_ini_npzd
   end
   if (makebioebus)
      disp('========================')
      disp('Initial BioEBUS variables')
      oct_make_ini_bioebus
   end
   if (makepisces)
      disp('========================')
      disp('Initial PISCES variables')
      oct_make_ini_pisces
   end
end

%----------------------------------------------------------------------
% N2O in BioEBUS
%----------------------------------------------------------------------

if (makebioebus)
   disp('========================')
   disp('Input values for N2O in BioEBUS')
   oct_make_n2o_bioebus
end



