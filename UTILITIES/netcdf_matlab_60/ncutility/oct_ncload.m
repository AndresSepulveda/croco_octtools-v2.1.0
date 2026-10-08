function theResult = oct_ncload(theNetCDFFile, varargin_id)

% oct_ncload -- Load NetCDF variables.
%  oct_ncload('theNetCDFFile', 'var1', 'var2', ...) loads the
%   given variables of 'theNetCDFFile' into the Matlab
%   workspace of the "caller" of this routine.  If no names
%   are given, all variables are loaded.  The names of the
%   loaded variables are returned or assigned to "ans".
%   No attributes are loaded.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Aug-1997 10:13:57.

if nargin < 1, help(mfilename), return, end

result = [];
if nargout > 0, theResult = result; end

f_id = netcdf.open(theNetCDFFile, 'NC_NOWRITE');
if isempty(f_id), return, end

if isempty(varargin_id), varargin_id = ncnames(var(f_id)); end

for i = 1:length(varargin_id)
   if ~isstr(varargin_id{i}), varargin_id{i} = inputname(i+1); end
   assignin('caller', varargin_id{i}, f_id{varargin_id{i}}(:))
end

result = varargin_id;

netcdf.close(f_id);

if nargout > 0
   theResult = result
else
   ncans(result)
end
