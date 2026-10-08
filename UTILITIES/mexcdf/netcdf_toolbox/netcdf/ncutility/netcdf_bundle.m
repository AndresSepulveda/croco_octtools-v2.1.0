function netcdf_bundle

% netcdf_bundle -- Bundle the NetCDF Toolbox.
%  netcdf_bundle (no argument) bundles the NetCDF Toolbox
%   to produce the installer "nc_install.m".
 
% Copyright (C) 2001 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 15-Jun-2001 16:56:19.
% Updated    25-Apr-2003 11:58:00.

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
	theDirs{end+1} = ['oct_netcdf:@' theClasses{i}];
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
    'oct_nc2cdl'
	'oct_nc2mat'
	'ncans'
	'oct_ncbevent'
	'oct_nccat'
	'nccheck'
	'ncclass'
	'ncclear'
	'ncclose'
	'oct_ncdimadd'
	'oct_ncdim2rec'
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
    'switchsafe'
	'super'
	'tmexcdf'
	'tnc4ml5'
	'oct_tncbig'
	'oct_tncdotted'
    'oct_tncorder'
	'tncmex'
	'oct_tnetcdf'
	'oct_tscalar'
	'uilayout'
	'var2str'
	'vargstr'
	'zoomsafe'
};

theSources = {
    'mexcdf.h'
    'mexcdf53.c'
    'make_mexcdf53.m'
};

theMessages = {
	' '
	' ## Adjust the Matlab path to include, relative to Current Directory:'
	' ##    "oct_netcdf"'
	' ##    "oct_netcdf:ncfiles"'
	' ##    "oct_netcdf:nctype"'
	' ##    "oct_netcdf:ncutility"'
	' ## Make sure the Matlab path knows where the'
	' ##    "mexcdf53" Mex-file and (PCWIN only)'
	' ##    "netcdf.dll" are located.'
	' ## Restart Matlab.'
	' ## Execute "rehash toolboxcache", then'
	' ##    "oct_tnetcdf" at the Matlab prompt.'
};

theClasses = sort(theClasses);
theTypes = sort(theTypes);
theUtilities = sort(theUtilities);
theSources = sort(theSources);

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

tempPWD = pwd;
cd ..
cd ncsource
bund setdir ncsource
bund('text', theSources)
bund cd ..
cd(tempPWD)

bund setdir ncfiles
bund cd ..

bund cd ..

bund('message', theMessages)

bund close

cd(oldPWD)
