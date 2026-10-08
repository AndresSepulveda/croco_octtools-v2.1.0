function oct_ncbevent(theEvent)

% oct_ncbevent -- Dispatch an NCBrowser event.
%  oct_ncbevent('theEvent') dispatches theEvent to
%   the "oct_ncbevent" method of the NCBrowser that
%   owns the current window.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Apr-1997 09:23:56.

self = get(gcf, 'UserData');

if isa(self, 'oct_ncbrowser')
   if nargin < 1
      oct_ncbevent(self)
   else
      oct_ncbevent(self, theEvent)
   end
end
