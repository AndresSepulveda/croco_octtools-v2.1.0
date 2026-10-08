function [files,times] = oct_r2r_parent_files(par_dir,par_files,par_file,bry_type)
%
%  [files,times] = oct_r2r_parent_files(par_dir,par_files,par_file,bry_type)
%
%  List of the parent files used by oct_make_r2r and time of their records.
%
%  par_files : file name, cell array of file names, or patterns with '*'
%              (e.g. 'croco_avg.nc', {'croco_his.nc','croco_his_2.nc'},
%              'croco_avg.*.nc'), relative to par_dir. Patterns are
%              expanded in alphabetical order.
%              If empty: [par_file '_' bry_type '.nc'] (e.g. croco_avg.nc)
%  files     : cell array of full file names
%  times     : cell array, time of the records of each file (seconds;
%              scrum_time, time or ocean_time)
%
%  Octave version (Oct-2026). Function (not script): a variable called
%  "dir" in the workspace cannot shadow dir().
%
if isempty(par_files)
  par_files = {[par_file,'_',bry_type,'.nc']};
end
if ischar(par_files)
  par_files = {par_files};
end
files = {};
for k = 1:numel(par_files)
  name = par_files{k};
  if any(name=='*') || any(name=='?')
    d = dir(fullfile(par_dir,name));
    names = sort({d.name});
    if isempty(names)
      error(['oct_make_r2r: no parent file matches ',fullfile(par_dir,name)])
    end
    files = [files, fullfile(par_dir,names)];
  else
    f = fullfile(par_dir,name);
    if ~exist(f,'file')
      error(['oct_make_r2r: parent file not found: ',f])
    end
    files{end+1} = f;
  end
end
times = cell(size(files));
for k = 1:numel(files)
  nc = netcdf.open(files{k},'NC_NOWRITE');
  t = [];
  for nm = {'scrum_time','time','ocean_time'}
    try
      t = double(netcdf.getVar(nc,netcdf.inqVarID(nc,nm{1})));
      break
    end
  end
  netcdf.close(nc);
  if isempty(t)
    error(['oct_make_r2r: no time variable (scrum_time, time or ocean_time) in ',files{k}])
  end
  times{k} = t(:)';
end
return
