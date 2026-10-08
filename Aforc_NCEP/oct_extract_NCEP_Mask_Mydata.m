function oct_extract_NCEP_Mask_Mydata(NCEP_dir,url,fname,...
				  year,month,...
				  lon,lat,level,...
				  i1min,i1max,i2min,i2max,i3min,i3max,...
				  jmin,jmax,Get_My_Data)

%
% Get 'Land'/mask
%
disp(['Get land for year ',num2str(year),' - month ',num2str(month)])
%
% Get the variable 2D subset (take care of greenwitch)
%
ncid = netcdf.open([url,fname,'.nc'], 'NC_NOWRITE');
if ~isempty(i1min)
  var1=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'land')));
else
  var1=[];
end
%
if ~isempty(i2min)
  var2=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'land')));
else
  var2=[];
end
if ~isempty(i3min)
  var3=squeeze(netcdf.getVar(ncid, netcdf.inqVarID(ncid, 'land')));
else
  var3=[];
end
%  
var=cat(2,var1,var2,var3);

netcdf.close(ncid);

ncid = netcdf.open([url,fname,'.nc'], 'NC_NOWRITE');
add_offset=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'land'), 'add_offset');
if isempty(add_offset)
  add_offset=0;    
end
scale_factor=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'land'), 'scale_factor');
if isempty(scale_factor)
  scale_factor=1
end
missing_value=netcdf.getAtt(ncid, netcdf.inqVarID(ncid, 'land'), 'missing_value');
if isempty(missing_value)
  missing_value=-99999;
end

%
% Correct the variable
%
var(var==missing_value)=NaN;
var=add_offset+var.*scale_factor;
%
%
% Write it in a file
%
oct_write_NCEP_Mask([NCEP_dir,'land_Y',num2str(year),'M',num2str(month),'.nc'],...
		'land',lon,lat,var)
%
return
