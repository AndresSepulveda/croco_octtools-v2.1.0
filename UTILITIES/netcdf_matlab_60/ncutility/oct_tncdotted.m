function oct_tncdotted(whichOne)

% oct_tncdotted -- Test of dotted and dashed NetCDF names.
%  oct_tncdotted('whichOne') exercizes dotted and/or dashed
%   NetCDF names.  If this function fails, then no such
%   names can be created on the present system, though
%   it may still be possible to read or write to them.
%   It is best to avoid such names altogether.
%
%   The 'whichOne' is one of: 'dotted', '.', 'dashed',
%   '-', or 'both'.  By default, whichOne = 'both'.
%
%   Statements using names with dots, dashes or other
%   Matlab operators must not violate Matlab syntax.
%   The Matlab parser does its work first, then the
%   NetCDF language is invoked if deemed appropriate.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 11-Feb-1998 09:33:14.

if nargin < 1, whichOne = 'both'; end
if isempty(whichOne), whichOne = 'both'; end

help(mfilename)

theNetCDFFile = 'tncdashed.nc';

USE_OLD = 0;

% Test dashed names: fails on some systems.

switch whichOne
case {'dotted', '.', 'both'}
    disp(' ')
    disp(' ## Testing dotted NetCDF names.')
    disp(' ## If this fails, then dotted names are not allowed.')
    f_id = netcdf.create(theNetCDFFile, 'NC_CLOBBER');
    f_id.a.dotted.name = 'a dotted global attribute name';
    did_a_dotted_name = netcdf.defDim(f_id, 'a.dotted.name', length('a dotted variable name'));
    vid_a_dotted_name = netcdf.defVar(f_id, 'a.dotted.name', 'NC_CHAR', did_a_dotted_name);
    netcdf.getAtt(f_id, netcdf.inqVarID(f_id, 'a.dotted.name'), 'a').dotted.name = 'a dotted variable attribute name';
    netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'a.dotted.name'), 'a dotted variable name');
    disp(' ## Test of dotted names SUCCESSFUL.')
    netcdf.close(f_id);
    USE_OLD = 1;
end

% Test dashed names: fails on some systems.

switch whichOne
case {'dashed', '-', 'both'}
    disp(' ')
    disp(' ## Testing dashed NetCDF names.')
    disp(' ## If this fails, then dashed names are not allowed.')
    if USE_OLD
        f_id = netcdf.open(theNetCDFFile, 'NC_WRITE');
    else
        f_id = netcdf.create(theNetCDFFile, 'NC_CLOBBER');
    end
    ncatt('a-dashed-name', 'a dashed global attribute name', f_id)
    did_a_dashed_name = netcdf.defDim(f_id, 'a-dashed-name', length('a dashed variable name'));
    vid_a_dashed_name = netcdf.defVar(f_id, 'a-dashed-name', 'NC_CHAR', did_a_dashed_name);
    v = f_id{'a-dashed-name'};
    ncatt('a-dashed-name', 'a dashed global attribute name', v)
    netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'a-dashed-name'), 'a dashed variable name');
    netcdf.close(f_id);
    disp(' ## Test of dashed names SUCCESSFUL.')
end

oct_ncdump(theNetCDFFile)
