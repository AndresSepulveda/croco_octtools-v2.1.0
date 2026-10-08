function theResult = oct_ncbevent(self_id, theEvent)

% NCBrowser/Event -- Event handler.
%  NCBrowser/Event(self, 'theEvent') handles 'theEvent'
%   sent to self, an NCBrowser object, by the "gcbo".
%   TheEvent is usually the name of the callback.  Each
%   time this routine is called, the NetCDF file object
%   (class "oct_netcdf") is assigned to the command-line
%   variable "nco", and the selected NetCDF item is
%   assigned to "nci".   The "ncb" variable is the
%   current "oct_ncbrowser" object.  The "ncx" variable
%   holds the most recently extracted data.
 
% Copyright (C) 1997 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without explicit written consent from the
%    copyright owner does not constitute publication.
 
% Version of 21-Apr-1997 09:23:56.
% Updated    27-Jul-2000 14:44:40.

if nargin < 1, help(mfilename), return, end
if nargin < 2, theEvent = 'Callback'; end

bluish = [0.25 1 1];
light_blue = [0.75 1 1];
yellow = [1 1 0];
yellowish = [1 1 0.5];
greenish = (bluish + yellow) ./ 2;
purplish = [0.75 0.75 1];

theFigure = self_id.itSelf;

busy(theFigure)

assignin('base', 'ncb', self_id)

% Get the current selections.

theGCBO = gcbo;
if isempty(theGCBO)
	theGCBO = findobj(theFigure, 'Type', 'uicontrol', ...
					'Style', 'pushbutton', 'Tag', 'Catalog');
end
theDimname = '';
theVarname = '';
theAttname = '';
theConceptname = '';
theTypename = '';
theNCItem_id = [];
theNCDim = [];
theNCVar = [];
theNCAtt = [];

theNetCDF = super(self_id);

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Dimensions');
theDimnames = get(f, 'String');
if ~iscell(theDimnames), theDimnames = {theDimnames}; end
theDimvalue = get(f, 'Value');
if any(theDimvalue)
   theDimname = theDimnames{theDimvalue};
   theDimPrefix = theDimname(1);
   if theDimPrefix == '*', theDimname(1) = ''; end   % Trouble with '*...'.
   if ~strcmp(theDimname, '-')
%		theNCDim = self(theDimname);
		theNCDim = ncsubsref(self_id, '()', {theDimname});
	end
end
theDimensions = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Variables');
theVarnames = get(f, 'String');
if ~iscell(theVarnames), theVarnames = {theVarnames}; end
theVarvalue = get(f, 'Value');
if any(theVarvalue)
   theVarname = theVarnames{theVarvalue};
   theVarPrefix = theVarname(1);
   if theVarPrefix == '*', theVarname(1) = ''; end
   if ~strcmp(theVarname, '-')
%		theNCVar = self{theVarname};   % <== Release 11 Trouble.
		theNCVar = ncsubsref(self_id, '{}', {theVarname});
	end
end
theVariables = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Attributes');
theAttnames = get(f, 'String');
if ~iscell(theAttnames), theAttnames = {theAttnames}; end
theAttvalue = get(f, 'Value');
if any(theAttvalue)
   theAttname = theAttnames{theAttvalue};
   theAttPrefix = theAttname(1);
   if theAttPrefix == '*', theAttname(1) = ''; end
   if strcmp(theVarname, '-') | isempty(theNCVar)
      theNCAtt = ncatt(theAttname, self_id);
     else
      theNCAtt = ncatt(theAttname, theNCVar);
   end
end
theAttributes = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Properties');
theProps = get(f, 'String');
if theGCBO ~= f, set(f, 'String', '-'), end
theProperties = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Concepts');
theNames = get(f, 'String');
if ~iscell(theNames), theNames = {theNames}; end
theValue = get(f, 'Value');
if any(theValue), theConceptname = theNames{theValue}; end
theConcepts = f;

f = findobj(theFigure, 'Type', 'uicontrol', 'Tag', 'Types');
theNames = get(f, 'String');
if ~iscell(theNames), theNames = {theNames}; end
theValue = get(f, 'Value');
if any(theValue), theTypename = theNames{theValue}; end
theTypes = f;

if ~isempty(theNCDim), theNCItem_id = theNCDim; end
if ~isempty(theNCVar), theNCItem_id = theNCVar; end
if ~isempty(theNCAtt), theNCItem_id = theNCAtt; end

if any(theGCBO == [theDimensions theVariables theAttributes])
   set([theDimensions theVariables theAttributes], ...
         'BackgroundColor', light_blue)
end

theValue = [];
if strcmp(get(theGCBO, 'Type'), 'uicontrol')
   theValue = get(theGCBO, 'Value');
   theOldValue = get(theGCBO, 'UserData');
end
theOldGCBO = self_id.itsGCBO;
theTag = get(theGCBO, 'Tag');

% Process the event.

switch lower(theEvent)
case 'buttondownfcn'
   disp([' ## Not yet operational: ' theEvent])
case 'callback'
   switch lower(theTag)
   case 'dimensions'
      netcdf.putAtt(self_id, netcdf.getConstant('NC_GLOBAL'), 'itsGCBO', theDimensions);
      set(theFigure, 'UserData', self_id)
      if strcmp(theDimname, '-')
         set(theDimensions, 'Value', theOldValue)
         idle(theFigure), return
      end
      set(theDimensions, 'UserData', theValue)
%		d = self(theDimname);   % Trouble with '*...' names.
		d = ncsubsref(self_id, '()', {theDimname});
      theProps = mat2str(ncsize(d));
      v = var(d);
      a = att(self_id);
      if theDimPrefix == '*', theDimPrefix = ''; else, theDimPrefix = '*'; end
      theDimnames{theDimvalue} = [theDimPrefix theDimname];
      theVarnames = [{'-'} ncnames(v)];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'BackgroundColor', yellowish);
      set(theDimensions, 'String', theDimnames, 'Value', theDimvalue);
      set(theVariables, 'String', theVarnames, 'Value', 1);
      set(theAttributes, 'String', theAttnames, 'Value', 1);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(d);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'dimension';
      theRecdim = recdim(self_id);
      if ~isempty(theRecdim) & dimid(theRecdim) == dimid(d)
         theName = 'record dimension';
      end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'variables'
      netcdf.putAtt(self_id, netcdf.getConstant('NC_GLOBAL'), 'itsGCBO', theVariables);
      set(theFigure, 'UserData', self_id)
      if strcmp(theVarname, '-')
         set(theVariables, 'Value', theOldValue)
         idle(theFigure), return
      end
      set(theVariables, 'UserData', theValue)
%		v = self{theVarname};   % <== Release 11 Trouble.
		v = ncsubsref(self_id, '{}', {theVarname});
      theProps = mat2str(ncsize(v));
      d = dim(v);
      a = att(v);
      theDimnames = [{'-'} ncnames(d)];
      if theVarPrefix == '*', theVarPrefix = ''; else, theVarPrefix = '*'; end
      theVarnames{theVarvalue} = [theVarPrefix theVarname];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'String', theDimnames, 'Value', 1);
      set(theVariables, 'String', theVarnames, 'Value', theVarvalue);
      set(theVariables, 'BackgroundColor', yellowish);
      set(theAttributes, 'String', theAttnames, 'Value', 1);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(v);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'variable';
      if iscoord(v), theName = 'coordinate variable'; end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'attributes'
      netcdf.putAtt(self_id, netcdf.getConstant('NC_GLOBAL'), 'itsGCBO', theAttributes);
      set(theFigure, 'UserData', self_id)
      if strcmp(theAttname, '-')
         set(theAttributes, 'Value', theOldValue)
         idle(theFigure), return
      end
      if theAttPrefix == '*', theAttPrefix = ''; else, theAttPrefix = '*'; end
      theAttnames{theAttvalue} = [theAttPrefix theAttname];
      set(theAttributes, 'String', theAttnames, 'Value', theAttvalue)
      set(theAttributes, 'UserData', theValue)
      if strcmp(theVarname, '-')
         v = [];
         a = ncatt(theAttname, self_id);
      else
%			v = self{theVarname};   % <== Release 11 Trouble.
			v = ncsubsref(self_id, '{}', {theVarname});
         a = ncatt(theAttname, v);
      end
      theProps = mat2str(a(:));
      set(theAttributes, 'BackgroundColor', yellowish);
      set(theProperties, 'String', theProps)
      theTypenames = get(theTypes, 'String');
      theType = datatype(a);
      for i = 1:length(theTypenames)
         set(theTypes, 'Value', i)
         if strcmp(lower(theTypenames{i}), theType)
            set(theTypes, 'UserData', i)
            break
         end
      end
      theConceptnames = get(theConcepts, 'String');
      theName = 'attribute';
      if isempty(v), theName = 'global attribute'; end
      for i = 1:length(theConceptnames)
         set(theConcepts, 'Value', i);
         if strcmp(lower(theConceptnames{i}), theName)
            set(theConcepts, 'UserData', i)
            break
         end
      end
   case 'concepts'
      if strcmp(theConceptname, '-')
         set(theConcepts, 'Value', get(theConcepts, 'UserData'))
         idle(theFigure), return
      end
      set(theConcepts, 'UserData', theValue)
   case 'types'
      if strcmp(theTypename, '-')
         set(theTypes, 'Value', get(theTypes, 'UserData'))
         idle(theFigure), return
      end
      set(theTypes, 'UserData', theValue)
   case 'properties'
      ncb = self_id;
      nco = theNetCDF;
      nci = theNCItem_id;
      ans = theNCItem_id;
      theStatement = strrep(theProps, '>> ', '');
      f = findstr(theStatement, ' <==');
      if any(f)
         theStatement(f(1):length(theStatement)) = '';
      end
      if ~any(theStatement == '=')
         result = eval(theStatement, '''## ERROR ##''');
      else
         result = [];
         evalin('base', [theStatement ';'], '''## ERROR ##''');
      end
      if isequal(result, '## ERROR ##')
         result = [theStatement ' <== Unable to evaluate.'];
      end
      switch class(result)
      case {'double', 'char'}
         result = ['>> ' mat2str(result)];
      otherwise
         disp(result)
         result = [theStatement ' <== See command window.'];
      end
      set(theProperties, 'String', result)
      idle(theFigure)
      return
   case 'catalog'
      d = dim(self_id);
      v = var(self_id);
      a = att(self_id);
      theDimnames = [{'-'} ncnames(d)];
      theVarnames = [{'-'} ncnames(v)];
      theAttnames = [{'-'} ncnames(a)];
      set(theDimensions, 'String', theDimnames, 'Value', 1, 'UserData', 1);
      set(theVariables, 'String', theVarnames, 'Value', 1, 'UserData', 1);
      set(theAttributes, 'String', theAttnames, 'Value', 1, 'UserData', 1);
      theSize = ncsize(super(self_id));
      set(theProperties, 'String', mat2str(theSize(1:3)))
      set(theConcepts, 'Value', 1, 'UserData', 1);
      set(theTypes, 'Value', 1, 'UserData', 1);
      netcdf.putAtt(self_id, netcdf.getConstant('NC_GLOBAL'), 'itsGCBO', []);
      set(theFigure, 'UserData', self_id)
      theNCItem_id = theNetCDF;
      assignin('base', 'nci', theNCItem_id)
      assignin('base', 'ans', theNCItem_id)
   case {'listing', 'plot'}
      ncbgraph(self_id, theNCItem_id, lower(theTag))
      set(theProperties, 'String', theProps)
   case 'info'
      if isempty(theNCItem_id), theNCItem_id = theNetCDF; end
      disp(theNCItem_id)
      set(theProperties, 'String', theProps)
   case 'extract'
      if ~isempty(theNCItem_id), ncextract(theNCItem_id, 'ncx'), end
   otherwise
   end
case 'createfcn'
   disp([' ## Not yet operational: ' theEvent])
case 'deletefcn'
   assignin('base', 'nco', [])
   assignin('base', 'nci', [])
   assignin('base', 'ans', [])
   netcdf.close(self_id);
case 'menucallback'
   theTag = get(gcbo, 'Tag');
   s = abs(lower(theTag));
   f = find((s >= abs('0') & s <= abs('9')) | ...
            (s >= abs('a') & s <= abs('z')));
   theTag = theTag(f);
   set(gcbo, 'Tag', theTag);
   switch lower(theTag)
	case 'aboutncbrowser'
		help oct_ncbrowser
   case 'oct_netcdf'
      theFile = 0;
      [theFile, thePath] = uiputfile('unnamed.nc', 'Save New NetCDF As:');
      if any(theFile)
         theNCItem_id = netcdf.create([thePath theFile], 'NC_CLOBBER');
         if ~isempty(theNCItem_id), theNCItem_id = close(theNCItem_id); end
      end
   case 'dimension'
      thePrompts = {'Dimension Name', 'Dimension Size'};
      theName = 'unnamedDimension';
      theSize = '0';
      theInfo = inputdlg(thePrompts, ...
                         'New NetCDF Dimension', [1], {theName, theSize});
      if length(theInfo) > 1
         theDimname = theInfo{1};
         theDimsize = eval(theInfo{2});
         if ~isempty(theDimname) & ~isempty(theDimsize)
%				self(theDimname) = theDimsize;
% Note "self1" below.  Why not "self"?
%				self1 = ncsubsasgn(self, '()', theDimname, theDimsize);
				self_id = ncsubsasgn(self_id, '()', theDimname, theDimsize);
            ncbrefresh(self_id, super(self_id))
         end
      end
      set(theProperties, 'String', theProps)
   case 'variable'
      if any(exist('listpick') == [2 3 6])   % M-, MEX-, or P-file.
         thePrompt = {'Enter New Variable Name'};
         theVarname = 'unnamedVariable';
         theInfo = inputdlg(thePrompt, ...
               'New NetCDF Variable', [1], {theVarname});
         if length(theInfo) > 0 & ~isempty(theInfo{1})
            theVarname = theInfo{1};
            thePrompt = {['Select Dimensions For Variable "' theVarname '"']};
            theDimnames = [];
            theDimnames = feval('listpick', ncnames(dim(theNetCDF)), ...
                  thePrompt, 'New NetCDF Variable', 'multiple');
            if iscell(theDimnames)
               if strcmp(theTypename, '-'), theTypename = 'double'; end
               theNetCDF{theVarname} = eval(['nc' lower(theTypename) '(theDimnames)']);
               ncbrefresh(self_id, super(self_id));
            end
         end
         set(theProperties, 'String', theProps)
      end
   case 'attribute'
      theNCParent = theNCItem_id;
		if isempty(theNCParent)
			theNCParent = super(self_id);
			theNCItem_id = theNCParent;
		end
      switch class(theNCParent)
      case {'ncdim', 'ncatt'}
         theNCParent = oct_parent(theNCParent);
			theNCItem_id = theNCParent;
      end
      switch class(theNCParent)
		case {'oct_ncbrowser'}
			theNCParent = super(self_id);
			theNCItem_id = theNCParent;
      end
      thePrompts = {'Attribute Name', 'Attribute Data'};
      theName = '';
      theData = '''''';
      theInfo = inputdlg(thePrompts, ...
                         'New NetCDF Attribute', [1], {theName, theData});
      if length(theInfo) > 1 & ~isempty(theInfo{1})
         theName = theInfo{1};
         theData = eval(theInfo{2});
         if strcmp(theTypename, '-') | isstr(theData)
            eval(['theNCParent.' theName ' = theData;'])
           else
            eval(['theNCParent.' theName ' = nc' lower(theTypename) '(theData);'])
         end
         ncbrefresh(self_id, theNCItem_id)
      end
      set(theProperties, 'String', theProps)
   case 'open'
      theNCItem_id = oct_ncbrowser;
   case 'save'
      sync(theNetCDF)
   case 'saveas'   % Save-As, but do not open new file.
      sync(theNetCDF)
      theFile = 0;
      [theFile, thePath] = uiputfile('unnamed.nc', 'Save NetCDF As');
      if any(theFile)
         theNewNetCDF_id = netcdf.create([thePath theFile], 'NC_CLOBBER');
         if ~isempty(theNewNetCDF_id)
            theNewNetCDF_id < super(self_id);
            theNewNetCDF_id = close(theNewNetCDF_id);
            if isempty(theNewNetCDF_id) & 0
               theOldBrowser = self_id.itSelf;
               theNewBrowser = oct_ncbrowser([thePath theFile], 'write');
               if ~isempty(theNewBrowser)
                  oct_delete(theOldBrowser)
                  theNCItem_id = theNewBrowser;
               end
            end
         end
      end
   case 'done'
      oct_delete(theFigure)
		return
   case 'undo'
      disp([' ## Not yet operational: ' theEvent])
   case 'cut'
      disp([' ## Not yet operational: ' theEvent])
   case 'copy'
      if ~self_id.itIsClipboard
         theClipboard_id = netcdf.create(ncbclipboard(self), 'NC_CLOBBER');
         if ~isempty(theClipboard_id)
            for i = 2:length(theDimnames)
               d = theDimnames{i};
               if d(1) == '*'
                  d(1) = '';
                  d = ncdim(d, theNetCDF);
                  theClipboard_id < d;
               end
            end
            for i = 2:length(theVarnames)
               v = theVarnames{i};
               if v(1) == '*'
                  v(1) = '';
                  v = oct_ncvar(v, theNetCDF);
                  d = dim(v);
                  for j = 1:length(d)
                     theClipboard_id < d{j};
                  end
                  theClipboard_id < v;
                  a = att(v);
                  for j = 1:length(a)
                     theClipboard_id < a{j};
                  end
%                 copy(oct_ncvar(v, theNetCDF), theClipboard)
               end
            end
            for i = 2:length(theAttnames)
               a = theAttnames{i};
               if a(1) == '*'
                  a(1) = '';
                  if theVarname(1) ~= '-'
                     theClipboard_id < ncatt(a, theNCVar);
                    else
                     theClipboard_id < ncatt(a, theNetCDF);
                  end
               end
            end
            netcdf.close(theClipboard_id);
         end
      end
   case 'paste'   % This copies structure, but not data.
      if ~self_id.itIsClipboard
         theClipboard_id = netcdf.open(ncbclipboard(self), 'NC_NOWRITE');
         if ~isempty(theClipboard_id)
            theNetCDF < theClipboard_id;
            ncbrefresh(self_id, super(self_id))
            netcdf.close(theClipboard_id);
         end
      end
   case 'oct_delete'
      disp([' ## Not yet operational: ' theEvent])
   case 'showclipboard'
      isClipboard = self_id.itIsClipboard;
      if ~self_id.itIsClipboard
         theNCItem_id = oct_ncbrowser(ncbclipboard(self_id), 'nowrite');
      end
   case 'selectall'
      switch lower(class(theNCItem_id))
      case 'ncdim'
         theCount = 0;
         for i = 2:length(theDimnames)
            theCount = theCount + (theDimnames{i}(1) == '*');
         end
         for i = 2:length(theDimnames)
            theDimPrefix = theDimnames{i}(1);
            if theDimPrefix ~= '*' & theCount < length(theDimnames)-1
               theDimnames{i} = ['*' theDimnames{i}];
              elseif theDimPrefix == '*' & theCount == length(theDimnames)-1
               theDimnames{i}(1) = '';
            end
         end
         set(theDimensions, 'String', theDimnames, 'Value', theDimvalue)
      case 'oct_ncvar'
         theCount = 0;
         for i = 2:length(theVarnames)
            theCount = theCount + (theVarnames{i}(1) == '*');
         end
         for i = 2:length(theVarnames)
            theVarPrefix = theVarnames{i}(1);
            if theVarPrefix ~= '*' & theCount < length(theVarnames)-1
               theVarnames{i} = ['*' theVarnames{i}];
              elseif theVarPrefix == '*' & theCount == length(theVarnames)-1
               theVarnames{i}(1) = '';
            end
         end
         set(theVariables, 'String', theVarnames, 'Value', theVarvalue)
      case 'ncatt'
         theCount = 0;
         for i = 2:length(theAttnames)
            theCount = theCount + (theAttnames{i}(1) == '*');
         end
         for i = 2:length(theAttnames)
            theAttPrefix = theAttnames{i}(1);
            if theAttPrefix ~= '*' & theCount < length(theAttnames)-1
               theAttnames{i} = ['*' theAttnames{i}];
              elseif theAttPrefix == '*' & theCount == length(theAttnames)-1
               theAttnames{i}(1) = '';
            end
         end
         set(theAttributes, 'String', theAttnames, 'Value', theAttvalue)
      otherwise
      end
   case {'fillvalue', 'missingvalue', ...
         'addoffset', 'scalefactor', ...
         'units', ...
         'fortranformat', 'cformat', ...
         'epiccode', 'comment', ...
         'genericname', 'longname', 'shortname'}
      if isa(theNCItem_id, 'ncatt')
         a = theNCItem_id;
         theLabel = get(gcbo, 'Label');
         result = name(a, theLabel);
         if strcmp(theVarname, '-')
            a = att(self_id);
         else
%				v = self{theVarname};   % <== Release 11 Trouble.
				v = ncsubsref(self_id, '{}', {theVarname});
            a = att(v);
         end
         theAttnames = [{'-'} ncnames(a)];
         set(theAttributes, 'String', theAttnames);
      end
   case 'rename'
      thePrompt = ['Rename NetCDF ' theConceptname ' "' ...
            name(theNCItem_id) '" To:'];
      theName = {name(theNCItem_id)};
      theNewname = inputdlg(thePrompt, ...
                            'NetCDF Rename', 1, theName);
      theNewname = theNewname{1};
      if ~isempty(theNewname) & ~strcmp(theNewname, theName)
         name(theNCItem_id, theNewname)
         ncbrefresh(self_id, theNCItem_id)
      end
      set(theProperties, 'String', theProps)
   case 'oct_resize'
		if isa(theNCItem_id, 'oct_ncvar') | isa(theNCItem_id, 'ncdim')
	      theName = name(theNCItem_id);
			theSize = ncsize(theNCItem_id);
			sz = mat2str(theSize);
	      thePrompt = ['Resize NetCDF ' theConceptname ' "' ...
	            theName '" From ' mat2str(theSize) ' To:'];
	      theNewSize = inputdlg(thePrompt, ...
						'NetCDF Resize', 1, {mat2str(theSize)});
			if ~isempty(theNewSize)
		      theNewSize = eval(['[' theNewSize{1} ']'], '[]');
		      if isequal(size(theSize), size(theNewSize))
					busy
					result = oct_resize(theNCItem_id, theNewSize);
					idle
					if ~isempty(result)
						theNCItem_id = result;
						netcdf.putAtt(self_id, netcdf.getConstant('NC_GLOBAL'), 'oct_netcdf', oct_parent(theNCItem));  % Very important.
		         	oct_ncbevent(self_id)   % Re-catalog.
					end
				else
					warndlg('Requested size is incompatible.', ...
								'NCBrowser Warning')
		      end
	      end
		end
	   set(theProperties, 'String', theProps)
   case 'lowercase'
      name(theNCItem_id, lower(name(theNCItem_id)))
      ncbrefresh(self_id, theNCItem_id)
   case 'uppercase'
      name(theNCItem_id, upper(name(theNCItem_id)))
      ncbrefresh(self_id, theNCItem_id)
   case {'line', 'circles', 'dots', 'degrees', ...
         'contour', 'image', 'listing', ...
         'mesh', 'surf', 'pxline'}
      switch ncclass(theNCItem_id)
      case 'ncatt'
         theNCItem_id = oct_parent(theNCItem_id);
      otherwise
      end
      switch ncclass(theNCItem_id)
      case 'oct_ncvar'
         ncbgraph(self_id, theNCItem_id, lower(theTag))
      otherwise
      end
      set(theProperties, 'String', theProps)
   case 'showgraph'
      ncbgraph(self_id)
   otherwise
      disp([theEvent ':' theTag])
   end
   idle(theFigure)
case 'refresh'
   ncbrefresh(self_id, theNCItem_id)
   set(theProperties, 'String', theProps)
otherwise
   disp([' ## Unknown event: ' theEvent ':' theTag])
end

assignin('base', 'ncb', self_id)
assignin('base', 'nco', theNetCDF)
assignin('base', 'nci', theNCItem_id)
assignin('base', 'ans', theNCItem_id)

idle(theFigure)

if nargout > 0, theResult = theNCItem_id; end
