function oct_tnetcdf(nRecords)

% oct_tnetcdf -- NetCDF Toolbox test.
%  oct_tnetcdf(nRecords) tests the NetCDF Toolbox,
%   including an exercize with nRecords (default = 2).
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.

% Version of 13-Mar-1997 00:00:00.
% Updated    04-Oct-2001 15:34:15.

% Check the Matlab path.

a = {'ncutility',
     'nctype',
     'oct_netcdf/oct_netcdf',
     'ncitem/ncitem',
     'ncdim/ncdim',
     'oct_ncvar/oct_ncvar',
     'ncatt/ncatt',
     'ncrec/ncrec',
     'oct_ncbrowser/oct_ncbrowser',
     'listpick/listpick'};
	 
okay = 1;
for i = 1:length(a)
   if isempty(which(a{i}))
      disp([' ## Unable to find: ' a{i}])
      okay = 0;
   end
end

if ~okay
   disp([' ## Please adjust your Matlab path,'])
   disp([' ##  then restart Matlab and'])
   disp([' ##  execute "oct_tnetcdf" again.'])
   disp([' ##  See "ncstartup" for instructions.'])
   return
end

ncversion

if nargin < 1, nRecords = 2; end
if ischar(nRecords), nRecords = eval(nRecords); end

filename = 'foo.nc';

disp(' ')
disp([' ## TNETCDF: Using file "' filename '"']);

oldOptions = options(ncitem, 0);   % Quiet mode.
ncquiet

for i = 0:3
   status = ncmex('close', i);
end

f_id = netcdf.create(filename, 'NC_CLOBBER');

if isempty(f_id)
   disp(' ## NetCDF test file not created.')
   return
end

% Preamble.

netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'Description', 'Test file.');
netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'Author', 'Dr. Charles R. Denham, ZYDECO.');
netcdf.putAtt(f_id, netcdf.getConstant('NC_GLOBAL'), 'Created', datestr(now));

did_time = netcdf.defDim(f_id, 'time', netcdf.getConstant('NC_UNLIMITED'));
did_lat = netcdf.defDim(f_id, 'lat', 10);
did_lon = netcdf.defDim(f_id, 'lon', 5);
did_elapsed_time = netcdf.defDim(f_id, 'elapsed_time', 100);
did_horse_number = netcdf.defDim(f_id, 'horse_number', 5);

vid_time = netcdf.defVar(f_id, 'time', 'NC_INT', did_time);
vid_lat = netcdf.defVar(f_id, 'lat', 'NC_INT', did_lat);
vid_lon = netcdf.defVar(f_id, 'lon', 'NC_INT', did_lon);
vid_elapsed_time = netcdf.defVar(f_id, 'elapsed_time', 'NC_DOUBLE', did_elapsed_time);
vid_horse_number = netcdf.defVar(f_id, 'horse_number', 'NC_INT', did_horse_number);
vid_speed = netcdf.defVar(f_id, 'speed', 'NC_DOUBLE', [did_horse_number, did_elapsed_time]);

dims = {'time'; 'lat'; 'lon'};

vid_z = netcdf.defVar(f_id, 'z', 'NC_INT', did_dims);
vid_t = netcdf.defVar(f_id, 't', 'NC_INT', did_dims);
vid_p = netcdf.defVar(f_id, 'p', 'NC_INT', did_dims);
vid_rh = netcdf.defVar(f_id, 'rh', 'NC_INT', did_dims);

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'time'), 'units', 'seconds');

% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
% [conv] línea ncchar duplicada omitida
netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'lat'), 'units', 'degrees_north');

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'lon'), 'units', 'degrees_east');

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'z'), 'units', 'meters');
% [conv] línea ncchar duplicada omitida

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'p'), 'FillValue_', NaN);
netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'p'), 'FillValue_', Inf);
netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'p'), 'FillValue_', -Inf);
netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'p'), 'FillValue_', -1);

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'rh'), 'FillValue_', -1);

netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'elapsed_time'), 'units', 'fortnights');
netcdf.putAtt(f_id, netcdf.inqVarID(f_id, 'speed'), 'units', 'furlongs/fortnight');

if (1)   % Disabled = 0.

% Test dotted names: fails on some systems.

if (1)
   did_a_dotted_name = netcdf.defDim(f_id, 'a.dotted.name', length('a dotted variable name'));
   f_id.a.dotted.name = 'a dotted global attribute name';
   vid_a_dotted_name = netcdf.defVar(f_id, 'a.dotted.name', 'NC_CHAR', did_a_dotted_name);
   netcdf.getAtt(f_id, netcdf.inqVarID(f_id, 'a.dotted.name'), 'a').dotted.name = 'a dotted variable attribute name';
   netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'a.dotted.name'), 'a dotted variable name');
end

% Test dashed names: fails on some systems.

if (1)
   did_a_dashed_name = netcdf.defDim(f_id, 'a-dashed-name', length('a dashed variable name'));
   ncatt('a-dashed-name', 'a dashed global attribute name', f_id)
   did_a_dashed_name = netcdf.defDim(f_id, 'a-dashed-name', length('a dashed variable name'));
   vid_a_dashed_name = netcdf.defVar(f_id, 'a-dashed-name', 'NC_CHAR', did_a_dashed_name);
   v = f_id{'a-dashed-name'};
   ncatt('a-dashed-name', 'a dashed variable attribute name', v)
   netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'a-dashed-name'), 'a dashed variable name');
end

else
   disp(' ## After "oct_tnetcdf", run "oct_tncdotted" to check')
   disp(' ##  whether dotted and/or dashed NetCDF names')
   disp(' ##  can be created on this machine.')
end

f_id = close(f_id);

f_id = netcdf.open(filename, 'NC_WRITE');

if isempty(f_id)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

lat = [0 10 20 30 40 50 60 70 80 90].';   % Column-vectors.
lon = [-140 -118 -96 -84 -52].';

for i = 1:length(lat), netcdf.getVar(f_id, netcdf.inqVarID(f_id, 'lat')) = lat(i); end

value = netcdf.getVar(f_id, netcdf.inqVarID(f_id, 'lat'));

if ~isequal(value, lat)
	original_lat = lat, retrieved_lat = value
	warning(' ## Bad retrieval of lat data #1.')
end

netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'lat'), 1:2:10-1, 1, lat(1:2:10));  % [conv] 0-based

value = netcdf.getVar(f_id, netcdf.inqVarID(f_id, 'lat'));
if ~isequal(value, lat), warning(' ## Bad retrieval of lat data #2.'), end

value = netcdf.getVar(f_id, netcdf.inqVarID(f_id, 'lat'));
if ~isequal(value, lat(1:2:10)), warning(' ## Bad retrieval of lat data #3.'), end

netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'lon'), lon);

theSize = [prod(size(f_id{'elapsed_time'})) 1];
theDistance = sort(rand(theSize));
netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'elapsed_time'), theDistance);
netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'horse_number'), [2; 5; 27; 100; 125]);
theSpeed = rand(size(f_id{'speed'}));
for j = 1:size(theSpeed, 2)
   theSpeed(:, j) = filter(theSpeed(:, j), ones(1, 5), 1) + ...
                       sin(2*pi*theDistance) + 1;
end
netcdf.putVar(f_id, netcdf.inqVarID(f_id, 'speed'), theSpeed);

f_id = close(f_id);

oct_ncdump(filename)

f_id = netcdf.open(filename, 'NC_WRITE');

if isempty(f_id)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

% Re-write the scale_factor and add_offset
%  two different ways.

if (1)
	% [conv] línea ncchar duplicada omitida
	% [conv] línea ncchar duplicada omitida
	netcdf.getAtt(f_id, netcdf.inqVarID(f_id, 'lat'), 'scale_factor') = 1;
	netcdf.getAtt(f_id, netcdf.inqVarID(f_id, 'lat'), 'add_offset') = 0;
end

f_id = close(f_id);

% Test of functions dealing with copying.

if (1)
	disp(' ')
	disp(' ## TNETCDF: Copy-testing...')
	theOriginal_id = netcdf.open(filename, 'NC_NOWRITE');
	if isempty(theOriginal_id)
	   disp(' ## NetCDF test file not opened for "read".')
	   return
	end
	theCopy_id = netcdf.create([filename '.copy'], 'NC_CLOBBER');
	if isempty(theCopy_id)
	   disp(' ## NetCDF destination file not created.')
	   return
	end
	theCopy_id < theOriginal_id;
	theCopy_id
	theCopy_id = close(theCopy_id);
	theOriginal_id = close(theOriginal_id);
	disp(' ## TNETCDF: Copy-testing done.')
end

% Test of functions dealing with records.

disp(' ')
disp(' ## TNETCDF: Record-testing...')

f_id = netcdf.open(filename, 'NC_WRITE');

if isempty(f_id)
   disp(' ## NetCDF test file not opened for "write".')
   return
end

record = f_id(0);
recdata = record(0);
goodRecords = 0;
iRec = nRecords:-1:1;
for i = iRec
   disp([' ## Record: ' int2str(i)])
   recdata = record(0);
   recdata.time = i;
   recdata.z = fix(rand(size(recdata.z))*100);
   recdata.t = fix(rand(size(recdata.t))*100);
   recdata.p = fix(rand(size(recdata.p))*100);
   recdata.rh = fix(rand(size(recdata.rh))*100);
   record(i) = recdata;
   recdata1 = record(i);
   record(i) = recdata1;   % Round-trip.
   recdata2 = record(i);
   goodRecords = goodRecords + isequal(recdata1, recdata2);
end
f_id = close(f_id);

theOptions = options(ncitem, oldOptions);

if goodRecords == nRecords
   disp(' ## TNETCDF: Record-testing successful.')
  else
   disp(' ## TNETCDF: Record-testing not successful.')
   disp([' ## Good Records: ' int2str(goodRecords) ' of ' int2str(nRecords) '.'])
end

% Test of virtual variables.
	
disp(' ')
disp(' ## TNETCDF: Virtual-variable test...')
f_id = netcdf.open(filename, 'NC_WRITE');
rh = f_id{'rh'};
a = rh;
b = orient(rh, [3 1 2]);
aa = permute(a(:), [3 1 2]);   % WetCDF gets "oct_ncvar/subsref" warning here. ***
b(:) = aa;   % Put-back.
aa = a(:);   % Get again.
bb = ipermute(b(:), [3 1 2]);   % But not here. ***
f_id = close(f_id);

if isequal(aa, bb)
   disp(' ## TNETCDF: Virtual-variable test successful.')
else
	aa, bb
   disp(' ## TNETCDF: Virtual-variable test NOT successful.')
end

% Test of composite variables.

% Note: our use of "orient" here malfunctions
%  when we attempt to use [-1], rather than [+1].

disp(' ')
disp(' ## TNETCDF: Composite-variable test...')
f_id = netcdf.open(filename, 'NC_WRITE');
lat = f_id{'lat'};
m = ncsize(lat, 1);
v = var(lat, {':'}, {1:m, 1}, ...
        orient(lat, [+1]), {':'}, {1:m, 2});   % Was orient(lat, [-1]).
		
x1 = v(:);
v(:) = flipud(x1);
x2 = v(:);
v(:) = flipud(x2);
x3 = v(:);
f_id = close(f_id);

if isequal(x1, x3)
   disp(' ## TNETCDF: Composite-variable test successful.')
else
   disp(' ## TNETCDF: Composite-variable test NOT successful.')
end

% Test of "quick" input/output.

disp(' ')
disp(' ## TNETCDF: Input/output in "quick-mode"...')
f_id = netcdf.open(filename, 'NC_WRITE');
v = f_id{'speed'};
theSize = size(v);
v = quick(v, 0);
ntimes = 20;
for k = 1:2
	tic
	for i = 1:ntimes
		x = v(1:theSize(1), 1:theSize(2));
	end
	elapsed(k) = toc;
	v = quick(v, 1);
end
netcdf.close(f_id);
theSpeedFactor = elapsed(1) ./ elapsed(2)

% Browser.

if (1)
   disp(' ')
   disp(' ## TNETCDF: Browse test-file...')
   disp(' ')
   oct_ncbrowser foo.nc nowrite
end

disp(' ')
disp(' ## TNETCDF: Done.')
