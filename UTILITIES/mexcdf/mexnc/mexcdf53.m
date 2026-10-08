function [varargout] = mexcdf53 ( varargin )
% MEXCDF53:  wrapper routine to call oct_mexnc.
%
% Provided for backwards compatibility.  "mexcdf53" is no longer the 
% name of the underlying mexfile.

if nargout > 0
	varargout = cell(1, nargout);
	[varargout{:}] = feval('oct_mexnc', varargin{:});
else
	feval('oct_mexnc', varargin{:});
end

