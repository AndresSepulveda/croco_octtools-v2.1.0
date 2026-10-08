function [varargout] = mexcdf60 ( varargin )
% MEXCDF60:  wrapper routine to call oct_mexnc.
%
% Provided for backwards compatibility.  "mexcdf60" is no longer a 
% name for the underlying mexfile.

if nargout > 0
	varargout = cell(1, nargout);
	[varargout{:}] = feval('oct_mexnc', varargin{:});
else
	feval('oct_mexnc', varargin{:});
end
