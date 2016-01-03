function varargout = MatVideo(varargin)% See also: GUIDE, GUIDATA, GUIHANDLES
%% MatVideo
% Copy right (c) yukinak
% Edit the above text to modify the response to help MatVideo
% Last Modified by GUIDE v2.5 29-Dec-2015 19:06:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',	   mfilename, ...
				   'gui_Singleton',  gui_Singleton, ...
				   'gui_OpeningFcn', @MatVideo_OpeningFcn, ...
				   'gui_OutputFcn',  @MatVideo_OutputFcn, ...
				   'gui_LayoutFcn',  [] , ...
				   'gui_Callback',   []);
if nargin && ischar(varargin{1})
	gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
	[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
	gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function MatVideo_OpeningFcn(hObject, eventdata, handles, varargin)
%% Opening function

	handles.output = hObject;
	guidata(hObject, handles);
	
	global ud;
	ud.wndName = 'MatVideo';
	ud.handles = handles;
	ud.gVideo = [];
	ud.glbFrm = 1;
	ud.frmStp = 3;
	
	
function varargout = MatVideo_OutputFcn(hObject, eventdata, handles) 
%% Output function
	varargout{1} = handles.output;


function MatVideo_KeyPressFcn(hObject, eventdata, handles)
%% Callback: KeyPressFcn

	global ud;
	hfig = gcbf;
	key = get( hfig, 'CurrentChar' );
	
	if isempty( ud.gVideo )
		return;
	end;

	if ~isempty( key )
		switch lower( key )

			% key LeftArrow(frm--)
			case char(28)
				if ud.glbFrm > 1
					ud.glbFrm = ud.glbFrm - ud.frmStp * 10;
					ret = OnDraw;
				end;

			% key RightArrow(frm++)
			case char(29)
				if ud.glbFrm < (ud.vMaxFrm - ud.frmStp * 10)
					ud.glbFrm = ud.glbFrm + ud.frmStp * 10;
					ret = OnDraw;
				end;

			otherwise
				return;
		end;

	end;


function hPlayBtn_Callback(hObject, eventdata, handles)
%% Callback: Play Button

	global ud;

	if isempty( ud.gVideo )
		return;
	end;
	
 	playFlg = get( ud.handles.hPlayBtn, 'UserData' );
	
	% Play
	if playFlg == 0
		set( ud.handles.hPlayBtn, 'UserData', ~playFlg );
		set( ud.handles.hPlayBtn, 'String', 'Stop' );
		
		while hasFrame( ud.gVideo )

			% Playing Loop
			if isequal( get( ud.handles.hPlayBtn, 'UserData'), 0 )
				break;
			end;
			ud.glbFrm = ud.glbFrm + ud.frmStp;
			ret = OnDraw;
			if ret == 0
				break;
			end;
			pause(1/ud.gVideo.FrameRate);

		end;
	
	% Stop
	elseif playFlg == 1

		set( ud.handles.hPlayBtn, 'UserData', ~playFlg );
		set( ud.handles.hPlayBtn, 'String', 'Play' );
		return;

	end;
	

function hSlider_Callback(hObject, eventdata, handles)
%% Callback: Time-slider

	global ud;

	if isempty( ud.gVideo )
		return;
	end;
	
	cFrm = get( ud.handles.hSlider, 'Value' );
	ud.glbFrm = round(cFrm);
	
	ret = OnDraw;


function hFrmEdit_Callback(hObject, eventdata, handles)
%% Callback: Frame Edit

	global ud;

	if isempty( ud.gVideo )
		return;
	end;
	
	cSec = str2num( get( ud.handles.hFrmEdit, 'String' ));
	ud.glbFrm = round( cSec*ud.gVideo.FrameRate );
	
	ret = OnDraw;

function Open_Callback(hObject, eventdata, handles)
%% UImenu: Open video

	global ud;
	[fname, fpath] = uigetfile( ...
		{   '*.mp4;*.m4v;*.m2p;*.mpg', 'MPEG Files (*.mp4,*.m4v,*.m2p,*.mpg)';
			'*.mov', 'QuickTime movie (*.mov)'; ...
			'*.avi', 'AVI File (*.avi)'; ...
			'*.wmv', 'Windows Media Video (*.wmv)'; ...
			'*.mts', 'MTS File (*.mts)'; ...
			'*.vob', 'VOB File (*.vob)'; ...
			'*.*', 'All Files (*.*)'}, ...
			'Pick a file');
	if isequal(fname,0) || isequal(fpath,0)
		return;
	else
		fpVid = strcat(fpath,fname);
	end;
	
	ud.gVideo = VideoReader( fpVid );
	ud.vMaxFrm = floor( ud.gVideo.Duration / (1/ud.gVideo.FrameRate) );
	
 	ret = OnDraw;

function ret = OnDraw
%% Updating UI Main function

	global ud;

	set( gcf, 'CurrentAxes', ud.handles.hVideo ); cla; 
	if ~isempty(ud.gVideo)

		curTime = (ud.glbFrm) * (1/ud.gVideo.FrameRate);
		try 
			ud.gVideo.CurrentTime = curTime;
		catch
			fprintf('End of the frame\n');
			ret = 0;
			return;
		end;

		vidFrm = readFrame( ud.gVideo );
		set( gcf, 'CurrentAxes', ud.handles.hVideo );
		imagesc( vidFrm );
		axis image;
	end;

	% GUI update
	SetMainWnd;

	ret = 1;

function SetMainWnd
%% Updating UI

	global ud;

	set( 0, 'CurrentFigure', ud.handles.MatVideo );
	set( ud.handles.MatVideo, 'Name', 'MatVideo' );

	% Video
	set( ud.handles.hVideo,....
			'Units', 'normalized',...
			'Color', [0 0 0],...
			'XTick', [],...
			'YTick', [] );

	% Udpating Information
	glbFrm = ud.glbFrm;
	maxFrm = ud.vMaxFrm;
	tStr = sprintf( '%05d', glbFrm );
	set( ud.handles.hFrmEdit, 'String', tStr );
	set( ud.handles.hFrmEdit, 'String', num2str(glbFrm) );
	set( ud.handles.hSlider, 'Value', glbFrm );
	set( ud.handles.hSlider, 'Min', 1, 'Max', maxFrm, 'Value', glbFrm );
