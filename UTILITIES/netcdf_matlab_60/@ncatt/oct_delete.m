function theResult = oct_delete(varargin_id)

% ncatt/oct_delete -- Delete a NetCDF attribute.
%  oct_delete(self) deletes the NetCDF attribute associated
%   with self, an "ncatt" object, and returns [] if
%   successful.  Otherwise, it returns self.
%  oct_delete(att1, att2, ...) deletes the given attributes
%   and the results in a list.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 07-Aug-1997 15:43:32.

if nargin < 1, help(mfilename), return, end

% If not all arguments are "ncatt" objects,
%  let the the "oct_netcdf" oct_parent inherit.

if nargin > 1
   all_ncatt = 1;
   for i = 1:length(varargin_id)
      switch ncclass(varargin_id{i})
      case 'ncatt'
      otherwise
         all_ncatt = 0; break
      end
   end
   if ~all_ncatt
      self = varargin_id{1};
      theParent = oct_parent(oct_parent(self));
      result = oct_delete(theParent, varargin_id{:});
      if nargout > 0, theResult = result; end
      return
   end
end

self = varargin_id;
status = zeros(size(varargin_id));

for i = 1:length(varargin_id)
   theAtt = varargin_id{i};
   status(i) = ncmex('attdel', ncid(theAtt), varid(theAtt), name(theAtt));
   if status(i) < 0
      theParent = oct_parent(oct_parent(theAtt));
      theParent = redef(theParent);
      if ~isempty(theParent)
         status(i) = ncmex('attdel', ncid(theAtt), varid(theAtt), name(theAtt));
      end
   end
   if status(i) > 0, self{i} = []; end
end

if length(varargin_id) == 1, self = self{1}; end

if all(status >= 0)
   result = [];
  else
   result = self;
end

if nargout > 0
   theResult = result;
end
