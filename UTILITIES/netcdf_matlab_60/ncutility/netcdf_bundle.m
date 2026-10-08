function netcdf_bundle

% netcdf_bundle -- Bundle the NetCDF Toolbox.
%  netcdf_bundle (no argument) bundles the NetCDF Toolbox
%   to produce the installer "nc_install.m".
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Jun-2001 16:56:19.
% Updated    04-Oct-2001 15:38:44.

theClasses = {
	'listpick'
	'ncatt'
	'oct_ncbrowser'
	'ncdim'
	'ncitem'
	'ncrec'
	'oct_ncvar'
	'oct_netcdf'
};

for i = 1:length(theClasses)
	newversion(theClasses{i})
end

theDirs = cell(size(theClasses));

theDirs = {
	'oct_netcdf'
	'oct_netcdf:ncfiles'
	'oct_netcdf:nctype'
	'oct_netcdf:ncutility'
};
for i = 1:size(theClasses)
	theDirs{end+1} = ['oct_netcdf:@'theClasses{i}];
end

theTypes = {
	'ncbyte'
	'ncchar'
	'ncshort'
	'nclong'
	'ncint'
	'ncfloat'
	'ncdouble'
	'nctype'
	'ncsetstr'
};

theUtilities = {
	mfilename
	'begets'
	'busy'
	'fcopy'
	'filesafe'
	'findpt'
	'getinfo'
	'geturl'
	'geturl.mac'
	'guido'
	'idle.m'
	'labelsafe'
	'maprect'
	'mapsubs'
	'oct_mat2nc'
	'mexcdf.m'
	'modplot'
	'movie1'
	'oct_nc2mat'
	'ncans'
	'oct_ncbevent'
	'oct_nccat'
	'nccheck'
	'ncclass'
	'ncclear'
	'ncclose'
	'oct_ncdimadd'
	'oct_ncdump'
	'oct_ncdumpd'
	'oct_ncdumph'
	'oct_ncexample'
	'ncextract'
	'oct_ncfillvalues'
	'ncillegal'
	'ncind2slab'
	'ncind2sub'
	'oct_ncload'
	'oct_ncmemory'
	'ncmex'
	'oct_ncmkmask'
	'oct_ncmovie'
	'ncnames'
	'ncpath'
	'ncquiet'
	'ncrecget'
	'ncrecinq'
	'ncrecput'
	'ncrectest'
	'oct_ncsave'
	'ncsize'
	'ncstartup'
	'oct_ncswap'
	'oct_nctrim'
	'ncutility'
	'ncverbose'
	'ncversion'
	'ncweb'
	'ncwhatsnew'
	'numel_default'
	'rbrect'
	'setinfo'
	'stackplot'
	'super'
	'tmexcdf'
	'tnc4ml5'
	'oct_tncbig'
	'oct_tncdotted'
	'tncmex'
	'oct_tnetcdf'
	'oct_tscalar'
	'uilayout'
	'var2str'
	'vargstr'
	'zoomsafe'
};

theMessages = {
	' '
	' ## Adjust the Matlab path to include, relative to Current Directory:'
	' ##    "oct_netcdf"'
	' ##    "oct_netcdf:ncfiles"'
	' ##    "oct_netcdf:nctype"'
	' ##    "oct_netcdf:ncutility"'
	' ## Then, restart Matlab and execute'
	' ##    "oct_tnetcdf" at the Matlab prompt.'
};

theClasses = sort(theClasses);
theTypes = sort(theTypes);
theUtilities = sort(theUtilities);

at(mfilename)

oldPWD = pwd;

bund new oct_netcdf
bund setdir oct_netcdf
bund('class', theClasses)
bund setdir ncutility
bund('mfile', theUtilities)
bund cd ..
bund setdir nctype
bund('mfile', theTypes)
bund cd ..
bund setdir ncfiles
bund cd ..
bund cd ..
bund('message', theMessages)
bund close

cd(oldPWD)
