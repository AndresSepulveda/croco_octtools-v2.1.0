function [varargout] = oct_nccat(theDestinationFile, varargin_id)

% oct_nccat -- Concatenate two netCDF files.
%  oct_nccat(theDestinationFile, theSourceFile1, theSourceFile2, ...)
%   concatenates theSourceFile1, ... onto theDestinationFile.  This
%   routine behaves like the "oct_nccat" C-language program, which
%   concatenates record-variables, but no other entities.  The files
%   must have the same record structure.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

varargout = cell(1, nargout);

if nargin < 2, help oct_nccat, return, end

if isa(theDestinationFile, 'oct_netcdf')
   f_id = theDestinationFile;
elseif ischar(theDestinationFile)
   f_id = netcdf.open(theDestinationFile, 'NC_WRITE');
else
   error(' ## ')
end

if isempty(f_id), return, end

for j = 1:length(varargin_id)
   theSourceFile = varargin_id{j};
   if isa(theSourceFile, 'oct_netcdf')
      g_id = theSourceFile;
   elseif ischar(theSourceFile)
      g_id = netcdf.open(theSourceFile, 'NC_NOWRITE');
   else
      error(' ## ')
   end
   if isempty(g_id), break, end
   v = recvar(g_id)
   for i = 1:length(v)
      u = f_id{name(v{i})};
      if i == 1, a = size(u); end
      b = size(v{i});
      u(a(1)+1:a(1)+b(1), :) = v{i}(1:b(1), :);
  end
  if ischar(theSourceFile)
      g_id = close(g_id);
   end
end

if ischar(theSourceFile)
   f_id = close(f_id);
end
