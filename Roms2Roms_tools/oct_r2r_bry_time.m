function oct_r2r_bry_time(np,nd,par_tind,chd_tind)
%
%  Copy the time of the parent records par_tind (scrum_time, time or
%  ocean_time, in seconds) into bry_time (days) of the child boundary
%  file at the records chd_tind.  Octave version (Oct-2026).
%
time = [];
for nm = {'scrum_time','time','ocean_time'}
  try
    vid = netcdf.inqVarID(np,nm{1});
    time = double(netcdf.getVar(np,vid,par_tind(1)-1,numel(par_tind)));
    break
  end
end
if isempty(time)
  error('No time variable (scrum_time, time or ocean_time) in the parent file')
end
vid = netcdf.inqVarID(nd,'bry_time');
for k = 1:numel(chd_tind)
  netcdf.putVar(nd,vid,chd_tind(k)-1,1,time(k)/(3600*24.));
end
return
