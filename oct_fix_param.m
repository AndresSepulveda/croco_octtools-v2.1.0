function nchanges = oct_fix_param(fname)
%
%  oct_fix_param(fname)
%  oct_fix_param                 % fname = 'crocotools_param.m'
%
%  Update a configuration file of the Matlab croco_tools (typically the
%  crocotools_param.m copied in a Run directory) so that it runs in
%  Octave:
%
%   - isoctave=exist('octave_config_info')  ->
%     isoctave=(exist('OCTAVE_VERSION','builtin')~=0)
%     (octave_config_info does not exist anymore in Octave >= 7, so
%     isoctave was 0 and the Matlab branches were executed),
%   - eval(['!mkdir ',dir]) / system(['mkdir ',dir]) / !mkdir dir  ->
%     if ~exist(dir,'dir'), mkdir(dir); end
%     ("!" shell escapes are syntax errors in Octave: "!" is the "not"
%     operator),
%   - other eval(['!cmd ...']) and lines "!cmd ..."  ->  system(...),
%   - unix(...) -> system(...).
%
%  A copy of the original file is kept as <fname>.bak (then .bak1,
%  .bak2...). The changed lines are printed. Returns the number of
%  changed lines.
%
%  Octave version (Oct-2026). This file is part of CROCOTOOLS (GNU GPL).
%
if nargin<1 || isempty(fname)
  fname = 'crocotools_param.m';
end
if ~exist(fname,'file')
  error(['oct_fix_param: file not found: ',fname])
end
txt = fileread(fname);
eol = "\n";
if any(txt==char(13)), eol = "\r\n"; end
lines = strsplit(txt, eol);
nchanges = 0;
for k = 1:numel(lines)
  old = lines{k};
  new = fix_line(old);
  if ~strcmp(old,new)
    nchanges = nchanges+1;
    lines{k} = new;
    printf('%s:%d\n   - %s\n   + %s\n',fname,k,strtrim(old),strtrim(new));
  end
end
if nchanges==0
  disp([fname,': nothing to change'])
  return
end
%
% Backup and write
%
bak = [fname,'.bak'];
n = 0;
while exist(bak,'file')
  n = n+1;
  bak = sprintf('%s.bak%d',fname,n);
end
copyfile(fname,bak);
fid = fopen(fname,'w');
fprintf(fid,'%s',strjoin(lines,eol));
fclose(fid);
disp([num2str(nchanges),' line(s) changed in ',fname,' (original saved in ',bak,')'])
return
%
%----------------------------------------------------------------------
%
function s = fix_line(s)
%
% Code part of the line (comments are not changed)
%
if isempty(regexp(s,'^\s*%','once')) == 0
  return
end
ind = regexp(s,'^\s*','end');
if isempty(ind), ind = 0; end
pre = s(1:ind);
%
% Octave detection
%
s = regexprep(s,'isoctave\s*=\s*exist\(\s*''octave_config_info''\s*\)\s*;?',...
              'isoctave=(exist(''OCTAVE_VERSION'',''builtin'')~=0);');
%
% mkdir through the shell -> mkdir built-in
%
mk = 'if ~exist($1,''dir''), mkdir($1); end';
s = regexprep(s,'eval\(\s*\[\s*''!\s*mkdir\s+(?:-p\s+)?''\s*,\s*([^\]]+?)\s*\]\s*\)\s*;?',mk);
s = regexprep(s,'system\(\s*\[\s*''mkdir\s+(?:-p\s+)?''\s*,\s*([^\]]+?)\s*\]\s*\)\s*;?',mk);
tok = regexp(s,'^\s*!\s*mkdir\s+(?:-p\s+)?(\S+)\s*$','tokens','once');
if ~isempty(tok)
  s = [pre,'if ~exist(''',tok{1},''',''dir''), mkdir(''',tok{1},'''); end'];
end
%
% Other shell escapes
%
s = regexprep(s,'eval\(\s*\[\s*''!\s*','system([''');
s = regexprep(s,'eval\(\s*''!\s*([^'']*)''\s*\)','system(''$1'')');
if ~isempty(regexp(s,'^\s*![A-Za-z]','once'))
  cmd = regexprep(s,'^\s*!\s*','');
  s = [pre,'system(''',strrep(cmd,'''',''''''),''');'];
end
s = regexprep(s,'(?<![\w.])unix\(','system(');
return
