function  oct_create_runoff(runoffname,grdname,title,...
    qbart,qbarc,rivername,rivernumber,...
    runoffname_StrLen,dir,psource_ncfile_ts,...
    biol,pisces,quota, Yorig)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% 	Create an empty netcdf runoff file
%       runoffname: name of the runoff file
%       grdname: name of the grid file
%       title: title in the netcdf file
%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Octave version (Sep-2026): netcdf.* API of the octave-netcdf package.
%  Dimensions are given to netcdf.defVar in Fortran order, so that the
%  file stores Qbar(n_qbar,qbar_time) and runoff_name(n_qbar,runoffname_StrLen)
%  as CROCO expects. The long_name/units attributes lost in the previous
%  automatic conversion have been restored.
%
timeref = 1 ;
if nargin < 14
  disp([' No Yorig parameter found'])
  disp([' No time reference'])
  timeref = 0 ;
end
if timeref == 1
  time_unit_att = ['days since ',sprintf('%04d', Yorig),'-01-01 00:00:00'];
  calendar_att = 'proleptic_gregorian' ;
else
  time_unit_att = ['days'];
  calendar_att = 'climatological year' ;
end
%
% Create the file (define mode)
%
nw_id = netcdf.create(runoffname, 'NC_CLOBBER');
did_qbar_time = netcdf.defDim(nw_id, 'qbar_time', length(qbart));
did_n_qbar = netcdf.defDim(nw_id, 'n_qbar', rivernumber);
did_StrLen = netcdf.defDim(nw_id, 'runoffname_StrLen', runoffname_StrLen);
did_one = netcdf.defDim(nw_id, 'one', 1);
did_two = netcdf.defDim(nw_id, 'two', 2);
%
% Time variables: {name, long_name, cycle_length}
%
tvars = {'qbar_time', 'runoff time', qbarc};
if psource_ncfile_ts
  tvars(end+1,:) = {'temp_src_time', 'runoff temperature time', qbarc};
  tvars(end+1,:) = {'salt_src_time', 'runoff salinity time', qbarc};
  if biol
    tvars(end+1,:) = {'no3_src_time', 'runoff no3 time', 360};
    if pisces
      tvars(end+1,:) = {'po4_src_time',  'runoff po4 time', 360};
      tvars(end+1,:) = {'si_src_time',   'runoff si time', 360};
      tvars(end+1,:) = {'dic_src_time',  'runoff dic time', 360};
      tvars(end+1,:) = {'doc_src_time',  'runoff doc time', 360};
      tvars(end+1,:) = {'talk_src_time', 'runoff talk time', 360};
      if quota
        tvars(end+1,:) = {'don_src_time', 'runoff don time', 360};
        tvars(end+1,:) = {'dop_src_time', 'runoff dop time', 360};
      end
    end
  end
end
for k=1:size(tvars,1)
  id = netcdf.defVar(nw_id, tvars{k,1}, 'NC_DOUBLE', did_qbar_time);
  netcdf.putAtt(nw_id, id, 'long_name', tvars{k,2});
  netcdf.putAtt(nw_id, id, 'units', time_unit_att);
  netcdf.putAtt(nw_id, id, 'calendar', calendar_att);
  netcdf.putAtt(nw_id, id, 'cycle_length', tvars{k,3});
end
%
% River names: runoff_name(n_qbar,runoffname_StrLen)
%
id = netcdf.defVar(nw_id, 'runoff_name', 'NC_CHAR', [did_StrLen, did_n_qbar]);
netcdf.putAtt(nw_id, id, 'long_name', 'runoff name');
%
% Discharge and tracers: VAR(n_qbar,qbar_time) -> Fortran order [qbar_time n_qbar]
% {name, long_name, units}
%
dvars = {'Qbar', 'runoff discharge', 'm3.s-1'};
if psource_ncfile_ts
  dvars(end+1,:) = {'temp_src', 'runoff temperature', 'Degrees Celcius'};
  dvars(end+1,:) = {'salt_src', 'runoff salinity', 'psu'};
  if biol
    dvars(end+1,:) = {'NO3_src', 'runoff no3 conc.', 'mmol.m-3'};
    if pisces
      dvars(end+1,:) = {'PO4_src',  'runoff po4 conc.',  'mmol.m-3'};
      dvars(end+1,:) = {'Si_src',   'runoff si conc.',   'mmol.m-3'};
      dvars(end+1,:) = {'DIC_src',  'runoff dic conc.',  'mmol.m-3'};
      dvars(end+1,:) = {'DOC_src',  'runoff doc conc.',  'mmol.m-3'};
      dvars(end+1,:) = {'TALK_src', 'runoff talk conc.', 'mmol.m-3'};
      if quota
        dvars(end+1,:) = {'DON_src', 'runoff don conc.', 'mmol.m-3'};
        dvars(end+1,:) = {'DOP_src', 'runoff dop conc.', 'mmol.m-3'};
      end
    end
  end
end
for k=1:size(dvars,1)
  id = netcdf.defVar(nw_id, dvars{k,1}, 'NC_DOUBLE', [did_qbar_time, did_n_qbar]);
  netcdf.putAtt(nw_id, id, 'long_name', dvars{k,2});
  netcdf.putAtt(nw_id, id, 'units', dvars{k,3});
end
%
% Global attributes
%
gid = netcdf.getConstant('NC_GLOBAL');
netcdf.putAtt(nw_id, gid, 'title', title);
netcdf.putAtt(nw_id, gid, 'date', date);
netcdf.putAtt(nw_id, gid, 'grd_file', grdname);
netcdf.putAtt(nw_id, gid, 'type', 'CROCO runoff file');
%
% Leave define mode and write the time variables and river names
%
netcdf.endDef(nw_id);
for k=1:size(tvars,1)
  netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, tvars{k,1}), qbart);
end
rivername=char(rivername);
names=repmat(' ',rivernumber,runoffname_StrLen);
for k=1:rivernumber
  nk=min(runoffname_StrLen,size(rivername,2));
  names(k,1:nk)=rivername(k,1:nk);
end
% (n_qbar,StrLen) in memory -> (StrLen,n_qbar) for netcdf.putVar
netcdf.putVar(nw_id, netcdf.inqVarID(nw_id, 'runoff_name'), names.');
netcdf.close(nw_id);
return
