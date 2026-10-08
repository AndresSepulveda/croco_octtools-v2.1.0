function theResult = oct_ncmovie(theNetCDF, theMovieName, theMovieSpeed)

% oct_ncmovie -- Play a NetCDF/Matlab movie file.
%  oct_ncmovie('theNetCDF', 'theMovieName') opens 'theNetCDF' file
%   and plays 'theMovieName' (default = 'movie') at theMovieSpeed
%   (frames/s; default = 4).  This routine calls "movie1" to play
%   frame-by-frame.  A more sophisticated scheme would load several
%   frames at a time.
 
% Copyright (C) 1999 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 10-Nov-1999 08:49:47.
% Updated    10-Nov-1999 09:06:49.

if nargout > 0, theResult = []; end

if nargin < 1
	help(mfilename)
	theNetCDF = '*';
end

if nargin < 2, theMovieName = 'movie'; end
if nargin < 3, theMovieSpeed = 4; end

ncid = netcdf.open(theNetCDF, 'NC_NOWRITE');
if isempty(ncid), return, end

theMovie = ncid{theMovieName};

if isempty(theMovie)
	disp([' ## No such movie: ' theMovieName])
	netcdf.close(ncid);
	return
end

[m, nFrames] = size(theMovie);

for frame = 1:nFrames
	theFrame = theMovie(:, frame);
	movie1(theFrame, theMovieSpeed)
end

netcdf.close(ncid);
