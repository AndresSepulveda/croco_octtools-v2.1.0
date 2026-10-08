function theResult = oct_ncsave(theNetCDFFile, varargin_id)

% oct_ncsave -- Save NetCDF variables.
%  oct_ncsave('theNetCDFFile', 'var1', 'var2', ...) saves the
%   given variables in 'theNetCDFFile'.  The variables must
%   already have been defined in the file, and the output
%   data must be properly sized.  This routine does not
%   alter the structure of the file itself; only the
%   given variables are updated.  If no variables are
%   given, the caller's entire workspace is attempted.
%   No attributes are updated.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 18-Aug-1997 10:19:05.

if nargin < 1, help(mfilename), return, end

result = [];
if nargout > 0, theResult = result; end

f_id = netcdf.open(theNetCDFFile, 'NC_WRITE');
if isempty(f_id), return, end

if length(varargin_id) < 1
   varargin_id = evalin('caller', 'who', '{}');
end

result = cell(1, length(varargin_id));
for i = 1:length(varargin_id)
   theName = varargin_id{i};
   if ~isstr(theName), theName = inputname(i+1); end
   result{i} = '';
   okay = 1;
   x = evalin('caller', theName, 'okay = 0; [];');
   if okay
      switch class(x)
      case {'char', 'double', 'uint8'}
         v = f_id{theName};
         if ~isempty(v) & prod(size(v)) == prod(size(x))
            v(:) = x;
            result{i} = theName;
         end
      otherwise
      end
   end
end

netcdf.close(f_id);

if nargout > 0
   theResult = result;
else
   ncans(result)
end
