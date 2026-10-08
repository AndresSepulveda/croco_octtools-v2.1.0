function varargout = oct_savefig(varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  OCT_SAVEFIG  "Save figure" dialog for Octave (used by oct_croco_gui)
%
%  oct_savefig                  % dialog for the current figure
%  oct_savefig(hf)              % dialog for figure hf
%  oct_savefig(hf,'basename')   % suggested file name (without extension)
%  oct_savefig('install',hf)    % File > Save and File > Save As... of
%                               % figure hf open this dialog
%  oct_savefig('install',hf,'basename')
%
%  The standard Octave dialog (File > Save As) keeps the suggested name
%  "untitled.ofig" when the file type is changed, and saves e.g. a PNG
%  image in a file named *.ofig. In this dialog the extension of the
%  file name follows the selected format, and the format follows the
%  extension typed in the file name.
%
%  Formats: PNG, PDF, EPS (colour), SVG, JPEG, TIFF, GIF, PostScript and
%  Octave figure (.ofig). The resolution is used for the raster formats.
%  The last folder, format and resolution are remembered during the
%  Octave session (root appdata 'oct_savefig_last').
%
%  Octave version (Sep-2026). This file is part of CROCOTOOLS (GNU GPL).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>=1 && ischar(varargin{1}) && strcmp(varargin{1},'install')
  hf=gcf; base='';
  if nargin>=2 && ~isempty(varargin{2}), hf=varargin{2}; end
  if nargin>=3, base=varargin{3}; end
  install_menus(hf,base);
  return
end
hf=[]; base='';
if nargin>=1, hf=varargin{1}; end
if nargin>=2, base=varargin{2}; end
if isempty(hf)
  hf=gcf;
end
dlg=open_dialog(hf,base);
if nargout>0, varargout{1}=dlg; end
return
%
%======================================================================
%
function F=formats()
% label, extension, print device ('' : Octave figure), raster
F={'PNG image (*.png)',                    'png', '-dpng',   1;
   'PDF document (*.pdf)',                 'pdf', '-dpdf',   0;
   'Encapsulated PostScript (*.eps)',      'eps', '-depsc',  0;
   'Scalable Vector Graphics (*.svg)',     'svg', '-dsvg',   0;
   'JPEG image (*.jpg)',                   'jpg', '-djpg',   1;
   'TIFF image (*.tif)',                   'tif', '-dtiff',  1;
   'GIF image (*.gif)',                    'gif', '-dgif',   1;
   'PostScript (*.ps)',                    'ps',  '-dpsc',   0;
   'Octave figure (*.ofig)',               'ofig','',        0};
return
%
function k=format_of_ext(ext)
% index of the format of an extension (0 if unknown)
ext=lower(strrep(ext,'.',''));
alias={'jpeg','jpg';'tiff','tif';'epsc','eps'};
for n=1:size(alias,1)
  if strcmp(ext,alias{n,1}), ext=alias{n,2}; end
end
F=formats();
k=find(strcmp(ext,F(:,2)),1);
if isempty(k), k=0; end
return
%
function name=set_ext(name,ext)
% replace a known extension of name (or append) by ext
[p,b,e]=fileparts(name);
if isempty(e) || format_of_ext(e)==0
  b=[b,e];                     % unknown "extension": part of the name
end
name=[b,'.',ext];
if ~isempty(p), name=fullfile(p,name); end
return
%
function s=clean_name(s)
% file name from a title: no blanks nor special characters
s=strtrim(s);
s=regexprep(s,'\s*-\s*','_');
s=regexprep(s,'\s+','');
s=regexprep(s,'[^\w\-\.]','');
s=regexprep(s,'_+','_');
if isempty(s), s='figure'; end
return
%
function base=default_base(hf,base)
if ~isempty(base), base=clean_name(base); return, end
try
  base=getappdata(hf,'oct_savefig_name');
end
if ~isempty(base), base=clean_name(base); return, end
%
% From the title of the (first) axes with a title
%
ax=findobj(hf,'type','axes');
for k=numel(ax):-1:1
  try
    t=get(get(ax(k),'title'),'string');
    if iscell(t), t=strjoin(t,' '); end
    if ~isempty(strtrim(t)), base=clean_name(t); return, end
  end
end
base='figure';
return
%
%----------------------------------------------------------------------
%
function install_menus(hf,base)
if ~isempty(base)
  setappdata(hf,'oct_savefig_name',base);
end
m=findall(hf,'type','uimenu');
for k=1:numel(m)
  lab=strrep(get(m(k),'label'),'&','');
  if any(strcmp(lab,{'Save','Save As...'}))
    set(m(k),'menuselectedfcn',@(h,e) oct_savefig(hf));
  end
end
return
%
%----------------------------------------------------------------------
%
function dlg=open_dialog(hf,base)
last=getappdata(0,'oct_savefig_last');      % last folder/format/dpi
if isempty(last)
  last=struct('dir',pwd,'fmt',1,'dpi',2);
end
if ~isdir(last.dir), last.dir=pwd; end
F=formats();
base=default_base(hf,base);
dpis={'100','150','300','600'};
bg=[0.94 0.94 0.94];
dlg=figure('Name','Save figure','NumberTitle','off','MenuBar','none',...
           'ToolBar','none','Color',bg,'IntegerHandle','off',...
           'Units','pixels','Position',[300 300 520 190],'Resize','off',...
           'HandleVisibility','callback','Tag','oct_savefig');
S.hf=hf;
uicontrol(dlg,'Style','text','Units','pixels','Position',[10 150 80 22],...
          'String','Folder:','HorizontalAlignment','left','BackgroundColor',bg);
S.dir=uicontrol(dlg,'Style','edit','Units','pixels','Position',[90 150 330 24],...
          'String',last.dir,'HorizontalAlignment','left','BackgroundColor',[1 1 1]);
uicontrol(dlg,'Style','pushbutton','Units','pixels','Position',[425 150 85 24],...
          'String','Browse...','Callback',@browse_cb);
uicontrol(dlg,'Style','text','Units','pixels','Position',[10 115 80 22],...
          'String','File name:','HorizontalAlignment','left','BackgroundColor',bg);
S.name=uicontrol(dlg,'Style','edit','Units','pixels','Position',[90 115 420 24],...
          'String',[base,'.',F{last.fmt,2}],'HorizontalAlignment','left',...
          'BackgroundColor',[1 1 1],'Callback',@name_cb);
uicontrol(dlg,'Style','text','Units','pixels','Position',[10 80 80 22],...
          'String','Format:','HorizontalAlignment','left','BackgroundColor',bg);
S.fmt=uicontrol(dlg,'Style','popupmenu','Units','pixels','Position',[90 80 240 24],...
          'String',F(:,1),'Value',last.fmt,'Callback',@format_cb);
S.dpitxt=uicontrol(dlg,'Style','text','Units','pixels','Position',[338 80 84 22],...
          'String','Resolution:','HorizontalAlignment','left','BackgroundColor',bg);
S.dpi=uicontrol(dlg,'Style','popupmenu','Units','pixels','Position',[425 80 85 24],...
          'String',strcat(dpis,' dpi'),'Value',last.dpi);
S.dpis=dpis;
uicontrol(dlg,'Style','pushbutton','Units','pixels','Position',[330 15 85 30],...
          'String','Save','Callback',@save_cb);
uicontrol(dlg,'Style','pushbutton','Units','pixels','Position',[425 15 85 30],...
          'String','Cancel','Callback',@(h,e) delete(dlg));
guidata(dlg,S);
update_dpi(dlg);
return
%
function update_dpi(dlg)
S=guidata(dlg); F=formats();
if F{get(S.fmt,'Value'),4}, st='on'; else, st='off'; end
set([S.dpi S.dpitxt],'Enable',st);
return
%
% Format changed: change the extension of the file name
%
function format_cb(h,~)
dlg=ancestor(h,'figure'); S=guidata(dlg); F=formats();
set(S.name,'String',set_ext(get(S.name,'String'),F{get(S.fmt,'Value'),2}));
update_dpi(dlg);
return
%
% File name changed: select the format of a known extension
%
function name_cb(h,~)
dlg=ancestor(h,'figure'); S=guidata(dlg);
[~,~,e]=fileparts(get(S.name,'String'));
k=format_of_ext(e);
if k>0 && k~=get(S.fmt,'Value')
  set(S.fmt,'Value',k);
  update_dpi(dlg);
end
return
%
function browse_cb(h,~)
dlg=ancestor(h,'figure'); S=guidata(dlg);
d=uigetdir(get(S.dir,'String'),'Select the folder');
if ischar(d)
  set(S.dir,'String',d);
end
return
%
function save_cb(h,~)
dlg=ancestor(h,'figure'); S=guidata(dlg); F=formats();
k=get(S.fmt,'Value');
name=strtrim(get(S.name,'String'));
if isempty(name)
  errordlg('Give a file name','Save figure'); return
end
[p,~,e]=fileparts(name);
if format_of_ext(e)~=k
  name=set_ext(name,F{k,2});        % the file extension follows the format
end
d=strtrim(get(S.dir,'String'));
if isempty(p) && ~isempty(d)
  fname=fullfile(d,name);
else
  fname=name;
end
[pd,~,~]=fileparts(fname);
if ~isempty(pd) && ~isdir(pd)
  errordlg(['Folder not found: ',pd],'Save figure'); return
end
if exist(fname,'file')
  a=questdlg([fname,' already exists. Overwrite it?'],'Save figure','Yes','No','No');
  if ~strcmp(a,'Yes'), return, end
end
if ~ishghandle(S.hf)
  errordlg('The figure has been closed','Save figure'); delete(dlg); return
end
try
  if isempty(F{k,3})
    hgsave(S.hf,fname);                              % Octave figure
  elseif F{k,4}
    print(S.hf,F{k,3},['-r',S.dpis{get(S.dpi,'Value')}],fname);
  else
    print(S.hf,F{k,3},fname);
  end
catch err
  errordlg(err.message,'Save figure'); return
end
disp(['Figure saved: ',fname])
set(S.hf,'FileName',fname);
setappdata(0,'oct_savefig_last',struct('dir',d,'fmt',k,'dpi',get(S.dpi,'Value')));
delete(dlg);
return
