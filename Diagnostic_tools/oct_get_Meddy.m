%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  oct_get_Meddy: Get the variance for each month.
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
%  Copyright (c) 2005-2006 by Patrick Marchesiello and Pierrick Penven 
%  e-mail:Pierrick.Penven@ird.fr  
%
%  Updated    10-Sep-2006 by Pierrick Penven
%  Updated    24-Oct-2006 by Pierrick Penven (generalisation to all CROCO
%                                             variables)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%%%%%%%%%%%%%%%%%%%% USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%%
%
crocotools_param
%
% Directory and file names
%
directory=[RUN_dir,'SCRATCH/'];
model='croco';
Ymin=4;
Ymax=10;
Mmin=1;
Mmax=12;
filetype='avg';
nonseannal=0; % 1: compute a "non-seasonnal" mean 
%                 (i.e. remove the monthly instead of the annual mean to
%                  get the anomalies)
%
Yorig=nan; %nan: climatolgy run%
%
% CROCO files
%
avgfile=[directory,model,'_',filetype,'_Y',num2str(Ymin),'M',num2str(Mmax),'.nc'];
if nonseannal==0
  eddyfile=[directory,model,'_Meddy.nc'];
  meanfile=[directory,model,'_Smean.nc'];
else
  eddyfile=[directory,model,'_Meddy_ns.nc'];
  meanfile=[directory,model,'_Mmean.nc'];
end
%
%%%%%%%%%%%%%%%%%%% END USERS DEFINED VARIABLES %%%%%%%%%%%%%%%%%%%%%%%
%
% Create the file
%
system([' ',DIAG_dir,'copycdf.csh ',avgfile,' ',eddyfile,' "CROCO monthly eddy file"'])
%
% Initialisation
%
ncid = netcdf.open(avgfile, 'NC_NOWRITE');
[~,L]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'xi_rho'));
[~,M]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'eta_rho'));
[~,N]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 's_rho'));
theta_s=ncid.theta_s(:);
rutgers=0;
if (isempty(theta_s))
%  disp('Rutgers version')
  rutgers=1;   
  theta_s=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_s'));
  theta_b=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'theta_b'));
  Tcline=netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'Tcline'));
end
[n3dvars,varcell,L,M,N]=oct_get_3dvars(ncid);
netcdf.close(ncid);
%
% Initialisation
%
for i=1:n3dvars
  if N(i)==1
    eval(['m',char(varcell(i)),'2=zeros(12,',...
              num2str(M(i)),',',num2str(L(i)),');'])
  else
    eval(['m',char(varcell(i)),'2=zeros(12,',num2str(N(i)),...
          ',',num2str(M(i)),',',num2str(L(i)),');'])
  end
end
nstep=0*(1:12);
%
%
%
nmean_id = netcdf.open(meanfile, 'NC_NOWRITE');
for Y=Ymin:Ymax
  if Y==Ymin 
    mo_min=Mmin;
  else
    mo_min=1;
  end
  if Y==Ymax
    mo_max=Mmax;
  else
    mo_max=12;
  end  
  for M=mo_min:mo_max
    fname=[directory,model,'_',filetype,'_Y',num2str(Y),'M',num2str(M),'.nc'];
    disp(['Opening : ',fname])
    ncid = netcdf.open(fname, 'NC_NOWRITE');
    [~,ntime]=netcdf.inqDim(ncid, netcdf.inqDimID(ncid, 'time'));
    if (filetype=='his' & ~(Y==Ymin & M==Mmin))
      nstart=2;
    else
      nstart=1;
    end
%
% loop on the time indexes in the file 
%
    for tindex=nstart:ntime
      [day,month,year,imonth,thedate]=oct_get_date(fname,tindex,Yorig);
      if nonseannal==0
        avgindex=5;
      else
        avgindex=imonth;
      end
      nstep(imonth)=nstep(imonth)+1;
      for i=1:n3dvars
        if N(i)==1
          eval(['m',char(varcell(i)),'2(imonth,:,:)=squeeze(m',char(varcell(i)),...
	        '2(imonth,:,:))+((netcdf.getVar(ncid, netcdf.inqVarID(ncid, ''',char(varcell(i)),'''))-nmean{''',...
		char(varcell(i)),'''}(avgindex,:,:)).^2);'])		
        else
          eval(['m',char(varcell(i)),'2(imonth,:,:,:)=squeeze(m',char(varcell(i)),...
	        '2(imonth,:,:,:))+((netcdf.getVar(ncid, netcdf.inqVarID(ncid, ''',char(varcell(i)),'''))-nmean{''',...
		char(varcell(i)),'''}(avgindex,:,:,:)).^2);'])		
        end
      end
    end
    netcdf.close(ncid);
  end
end
netcdf.close(nmean_id);
%
% Write it down
%
disp('Write in the file...')
ncid = netcdf.open(eddyfile, 'NC_WRITE');
if rutgers==1
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_s'), theta_s);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'theta_b'), theta_b);
  netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'Tcline'), Tcline);
end
for imonth=1:12
  cff=1./nstep(imonth);
  if rutgers==1
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'ocean_time'), imonth-1, 1, (imonth-0.5)*30*24*3600);  % [conv] 0-based
  else
    netcdf.putVar(ncid, netcdf.inqVarID(ncid, 'scrum_time'), imonth-1, 1, (imonth-0.5)*30*24*3600);  % [conv] 0-based
  end
  for i=1:n3dvars
    if N(i)==1
      eval(['netcdf.getVar(ncid, netcdf.inqVarID(ncid, ''',char(varcell(i)),'''))=cff*squeeze(m',...
            char(varcell(i)),'2(imonth,:,:));'])
    else
      eval(['netcdf.getVar(ncid, netcdf.inqVarID(ncid, ''',char(varcell(i)),'''))=cff*squeeze(m',...
            char(varcell(i)),'2(imonth,:,:,:));'])
    end
  end
end
netcdf.close(ncid);
