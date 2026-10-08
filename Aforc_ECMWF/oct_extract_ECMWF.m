function var = oct_extract_ECMWF(ifile,fname,year,month,...
                      tndx,...
                      i1min,i1max,i2min,i2max,i3min,i3max,...
                      jmin,jmax)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Extract a subset from ECMWF
% 
% From oct_extract_NCEP
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Get the variable name
%
disp(['Get ',fname,' for year ',num2str(year),...
      ' - month ',num2str(month)])
%
% Get the variable 2D subset (take care of greenwitch)
%
ncid = netcdf.open(ifile, 'NC_NOWRITE');
numdimvar0=length((netcdf.inqVar(ncid, netcdf.inqVarID(ncid, fname)))  % [conv] ncsize→inqVar ndims);
numdimvar=length(numdimvar0);
if ~isempty(i1min)
    if ( numdimvar > 3 )
      var1=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));
    else
      var1=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));
    end
else
    var1=[];
end
%
if ~isempty(i2min)
    if ( numdimvar > 3 )
      var2=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));
    else
      var2=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));
    end
else
    var2=[];
end
%  
if ~isempty(i3min)
    if ( numdimvar > 3 )
      var3=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));  
    else
      var3=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, fname)));    
    end
else
    var3=[];
end
%
var=cat(3,var1,var2,var3);
%
% North-South inversion
%
if (length(size(var))==2)
    var=flip(var,1);
elseif (length(size(var))==3)
    var=flip(var,2);
end
%
add_offset=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, fname), 'add_offset');
if isempty(add_offset)
    add_offset=0;    
end
scale_factor=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, fname), 'scale_factor');
if isempty(scale_factor)
    scale_factor=1;
end
missing_value=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, fname), 'missing_value');
if isempty(missing_value)
    missing_value=-99999;
end
netcdf.close(ncid);
%
% Correct the variable
%
var(var==missing_value)=NaN;
var=add_offset+var.*scale_factor;


return

