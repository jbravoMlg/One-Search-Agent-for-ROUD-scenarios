%% --- GUI MATLAB code for GUI.fig
% --- Begin initialization code.
function varargout = GUI(varargin)
 %%% Note: path setup is handled by the MATLAB project or launcher.
 %%% Add paths to Matlab functions and scripts
 %%% addpath('Scripts&Functions\','-end');
 %%% addpath('Scripts&Functions\AddOns\','-end');
 %%% addpath('Scripts&Functions\Otros\','-end');
 %%% Note: executable generation had MQTT function-recognition issues in protected files.
 %%% Try alternative functions included in mqtt.jar.
 %%% javaaddpath('C:\Users\mToscano\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\MQTT in MATLAB\mqttasync.jar');
 %%% javaaddpath('C:\Users\mToscano\AppData\Roaming\MathWorks\MATLAB Add-Ons\Toolboxes\MQTT in MATLAB\jar\org.eclipse.paho.client.mqttv3-1.1.0.jar');
 % Settings
 gui_Singleton = 1;
 gui_State = struct('gui_Name',       mfilename, ...
                    'gui_Singleton',  gui_Singleton, ...
                    'gui_OpeningFcn', @GUI_OpeningFcn, ...
                    'gui_OutputFcn',  @GUI_OutputFcn, ...
                    'gui_LayoutFcn',  [] , ...
                    'gui_Callback',   []);
 if nargin && ischar(varargin{1}), gui_State.gui_Callback = str2func(varargin{1}); end
 if nargout, [varargout{1:nargout}] = gui_mainfcn(gui_State,varargin{:});
 else, gui_mainfcn(gui_State,varargin{:});
 end
end

% --- Executes just before the GUIDE is made visible.
function GUI_OpeningFcn(hObject, ~, handles, varargin)
global data handleZoom TTS LoRa MQTT %%% Zigbee
data = []; handleZoom = []; TTS = []; LoRa = []; MQTT = [];
global ROS general
ROS = []; general = [];
global timerUpdate

 fecha = datestr(datetime('now')); fecha = replace(fecha,{':','-'},''); fecha = replace(fecha,' ','-');
 filename = strcat(fecha,'.txt');
 general.jornadas      =  false;    % true: automatically save dataset when SARFIS exits
 if general.jornadas, diary(filename); end
 general.showLabelLogo =  true;    % true: show particular label and UMA logo
 set(handles.logo_label,'String','');   % define the content of label, e.g. "live from Mlaga"
 imLogo = imread(fullfile(fileparts(mfilename('fullpath')), 'UMA.jpg'));
 %%%%imshow(imLogo,'Parent',handles.logo);
 handles.logo.XTick = [];  handles.logo.YTick = []; handles.logo.Box = 'off';
 set(handles.logo,'Units','pixels');
 resizePos = get(handles.logo,'Position');
 set(handles.logo,'Units','normalized');
 if general.showLabelLogo
  set(handles.logo_label,'Visible','off');
  set(handles.logo,'Visible','off');
 else
  set(handles.logo_label,'Visible','off');
  set(handles.logo,'Visible','off');
 end
 % opengl hardware; opengl('save','hardware');
 format longG; %%% format compact;
 %%%%delete(gcp('nocreate'));
 %%% parpool('local');
 %%%%parpool('threads');
 % triggering the timer for updating graphical representation (GUI left side)
 timerUpdate = timer; timerUpdate.TimerFcn = {@mostrarFigura,handles};
 timerUpdate.Period = 0.2; timerUpdate.TasksToExecute = inf;
 timerUpdate.ExecutionMode = 'fixedRate';
 %%%%% timerUpdate.ExecutionMode = 'singleShot';
 % ---
 handles.output = hObject;
 handles.TabsNumber = 7;  % --- introduce the number of TabPanels
 TabFontName = get(handles.Tab1Text,'FontName');
 TabFontSize = get(handles.Tab1Text,'FontSize');
 TabNames = strings(handles.TabsNumber,1);
 for i = 1:handles.TabsNumber
  if (i==3 || i==5 || i==7) i;
  else TabNames(i) = get(handles.(['Tab',num2str(i),'Text']),'String'); end
 end
 handles = TabsFun(handles,TabFontName,TabFontSize,TabNames);

 handles.AuxTabsNumber = 3;  % --- number of auxiliar TabPanels en choice 2
 AuxTabNames = strings(handles.AuxTabsNumber,1);
 for i = 1:handles.AuxTabsNumber
  AuxTabNames(i) = get(handles.(['Tab2',num2str(i),'Text']),'String');
 end
 handles = Aux2TabsFun(handles,TabFontName,TabFontSize,AuxTabNames);

 handles.AuxTabsNumber = 2;  % --- number of auxiliar TabPanels en choice 3
 AuxTabNames = strings(handles.AuxTabsNumber,1);
 for i = 1:handles.AuxTabsNumber
  AuxTabNames(i) = get(handles.(['Tab3',num2str(i),'Text']),'String');
 end
 handles = Aux3TabsFun(handles,TabFontName,TabFontSize,AuxTabNames);

 handles.AuxTabsNumber = 2;  % --- number of auxiliar TabPanels en choice 4
 AuxTabNames = strings(handles.AuxTabsNumber,1);
 for i = 1:handles.AuxTabsNumber
  AuxTabNames(i) = get(handles.(['Tab4',num2str(i),'Text']),'String');
 end
 handles = Aux4TabsFun(handles,TabFontName,TabFontSize,AuxTabNames);

 handles.AuxTabsNumber = 2;  % --- number of auxiliar TabPanels en choice 6
 AuxTabNames = strings(handles.AuxTabsNumber,1);
 for i = 1:handles.AuxTabsNumber
  AuxTabNames(i) = get(handles.(['Tab6',num2str(i),'Text']),'String');
 end
 handles = Aux6TabsFun(handles,TabFontName,TabFontSize,AuxTabNames);

 % Axes like static text with latex strings
 axes(handles.latex_text1); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text2); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text11); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text3); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text4); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text5); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text6); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text7); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text8); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text71); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text9); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);
 axes(handles.latex_text10); axis off;
 text('Interpreter','LaTex','string','','FontSize',12);

 % Settings: default
 ROS.hostname = 'SARFIS';
 TTS.propertyNodes = {'"dev_eui":','"received_at":','"frm_payload":','"spreading_factor":','"consumed_airtime":'};
 TTS.propertyGateways = {'"rssi":','"snr":','"channel_index":','"timestamp":','"time":'};
 LoRa.propertyNodes = {'"deveui":','"timestamp":','"data":','"datr":','"airtime":'};
 LoRa.propertyGateways = {'"rssi":','"lsnr":','"chan":','"tmst":','"timestamp":'};
 LoRa.typePlot = '.-';
 MQTT.propertyNodes = {'"timestamp":','"data":'};
 MQTT.propertyGateways = {};
 LoRa.indexBAT = 7;  % BAT field order in decoded payloadsa (BAT)
 %             type  bytes  data
 LoRa.keys = {{ 0,   4,     'single',    'CO',   'Carbon Monoxide',           'ppm'},...
              { 1,   4,     'single',    'CO2',  'Carbon Dioxide',            'ppm'},...
              { 2,   4,     'single',    'O2',   'Oxygen',                    'ppm'},...
              { 4,   4,     'single',    'O3',   'Ozone',                     'ppm'},...
              { 6,   4,     'single',    'NO2',  'Nitrogen Dioxide',          'ppm'},...
              {12,   4,     'single',    'NO',   'Nitrogen Monoxide',         'ppm'},...
              {52,   1,     'uint8',     'BAT',  'Battery Level',             '%'},...
              {54,   2,     'int16',     'RSSI', 'Received Signal Strength Indicator', ''},...
              {55,   2,     'uint16',    'MAC',  'MAC Address',               ''},...
              {62,   4,     'single',    'ITC',  'Internal Temperature',      [char(176),'C']},...
              {74,   4,     'single',    'TC',   'Temperature Celsius',       [char(176),'C']},...
              {76,   4,     'single',    'HUM',  'Humidity',                  '%RH'},...
              {77,   4,     'single',    'PRES', 'Atmospheric Pressure',      'atm'},...  % 1 atm = 101325 Pa
              {78,   4,     'single',    'LUM',  'Luminosity',                'Lum'},...
              {91,   4,     'single',    'ALT',  'GPS Altitude',              'm'},...
              {129,  4,     'single',    'RAD',  'Geiger tube, radiation',    'cpm'},...  % 'micro Sv/h'
              {172,  4,     'single',    'LUX',  'Luminosity',                'Lux'},...
              {63,   6,     'int16',     'ACC',  'Accelerometer',             ''},...
              {0xFF, 2,     'int16',     'ACCx', 'Accelerometer X-axis',      'm/s2'},...   % desdoble de 63-Accelerometer
              {0xFF, 2,     'int16',     'ACCy', 'Accelerometer Y-axis',      'm/s2'},...   % 1 g = 9.80665 m/s2 
              {0xFF, 2,     'int16',     'ACCz', 'Accelerometer Z-axis',      'm/s2'},...
              {53,   8,     'single',    'GPS',  'Global Positioning System', [char(176),'N/',char(176),'E']},...
              {0xFF, 4,     'single',    'LAT',  'GPS Latitude',              [char(176),'N']},...   % desdoble de 53-GPS
              {0xFF, 4,     'single',    'LON',  'GPS Longitude',             [char(176),'E']}};
 data = [];
 opc = 'No';
 %%%%prompt = 'Do you want to restore previous experimental data?';
 %%%%opc = questdlg([prompt,repmat(' ',1,74-length(prompt)),char(127)],...
 %%%%               'SAR-FIS v4.0a','Yes','No','No');
 data.folderSessions = 'MAT files/';
 if strcmp(opc,'Yes')
  [fileName,pathName] = uigetfile({'*.mat;','All Sessions Files'},...
                                   'Pick a file','MultiSelect','off',...
                                   data.folderSessions);
  if fileName
   load(strcat(pathName,fileName),'data');
   data.folderSessions = pathName;
   data.restoredSession = fileName(1:strfind(fileName,'.')-1);
   if isfield(data,'agentes')
    set(handles.numAgentes,'Value',length(data.agentes));
    set(handles.idAgente,'Enable','on');
   else
    set(handles.numAgentes,'Value',0);
   end
   set(handles.numAgentes,'String',num2str(get(handles.numAgentes,'Value')));
   if isfield(data,'sensorNodes')
    set(handles.numObjetivos,'Value',length(data.sensorNodes));
    set(handles.idObjetivo,'Enable','on');
   else
    set(handles.numObjetivos,'Value',0);
   end
   set(handles.numObjetivos,'String',num2str(get(handles.numObjetivos,'Value')));
   if isfield(data,'points')
    set(handles.numPOIs,'Value',length(data.points));
    set(handles.idPOI,'Enable','on');
   else
    set(handles.numPOIs,'Value',0);
   end
   set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
   set(handles.entorno,'Value',data.entorno.tipo+1);
   set(handles.elevacion,'String','Imported data from restored session');
   set(handles.imagen,'String','Imported data from restored session');
   set(handles.elevacion_button,'Enable','inactive');
   set(handles.imagen_button,'Enable','inactive');
   set(handles.radioDEM,'Value',0);
   set(handles.radioDEM,'Enable','off');
   set(handles.radioPhoto,'Value',0);
   set(handles.radioPhoto,'Enable','off');
   set(handles.radioAlternative,'Value',0);
   set(handles.radioAlternative,'Enable','off');
  end
 end
 if ~isfield(data,'restoredSession')
  set(handles.numAgentes,'Value',0);
  set(handles.numAgentes,'String',num2str(get(handles.numAgentes,'Value')));
  set(handles.numObjetivos,'Value',0);
  set(handles.numObjetivos,'String',num2str(get(handles.numObjetivos,'Value')));
  set(handles.numPOIs,'Value',0);
  set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
  data.options.UGVconstraints = 1;
  data.options.reexpansions = 0;
  data.options.heuristic = 1;
  data.options.slopeComputing = 0;
  data.options.verbose = 0;
  data.options.mapasTiempo = 1;
  data.options.optTmw = 1;
  data.options.TAU = 0;
  data.options.rutaContinua = 0;

  set(handles.entorno,'Value',1);
  tipoEntorno = get(handles.entorno,'Value')-1;
  if ~tipoEntorno
   fileName = 'DEM files/UMA_SEG_24_dsm_200cm';
   [data.pathName,fileName] = fileparts(fileName);
   data.pathName = strcat(data.pathName,'/');
   data.pathAltName = data.pathName;
   set(handles.elevacion,'String',fileName);
   set(handles.elevacion,'Enable','inactive');
   set(handles.radioAlternative,'Value',1);
   nombreFichero = strcat(data.pathName,fileName);
   data.entorno = EntornoDefinir(tipoEntorno,nombreFichero);
   %---
   fileName = strcat(fileName(1:strfind(fileName,'_dsm')+3),'_5cm');
   set(handles.imagen,'String',fileName);
   nombreFichero = strcat(data.pathAltName,fileName);
   if get(handles.radioAlternative,'Value')==1 && ...
      (exist(strcat(nombreFichero,'.xyz'),'file') == 2 ...
      || exist(strcat(nombreFichero,'.mat'),'file') == 2)
    alternativo = EntornoDefinir(tipoEntorno,nombreFichero);
    data.entorno.imagen = alternativo.imagen;
   end
  else
   % fileName = 'DEM files/Artificial/Simulated environment with uneven terrain';
   fileName = 'DEM files/Artificial/Binary environment based on a maze';
   [data.pathName,fileName] = fileparts(fileName);
   data.pathName = strcat(data.pathName,'/');
   data.pathAltName = data.pathName;
   set(handles.elevacion,'String',fileName);
   set(handles.elevacion,'Enable','inactive');
   set(handles.radioDEM,'value',1);
   set(handles.radioPhoto,'enable','off');
   set(handles.radioAlternative,'enable','off');
   set(handles.imagen,'String','Not applied');
   set(handles.imagen,'Enable','off');
   set(handles.imagen_button,'Enable','off');
   nombreFichero = strcat(data.pathName,fileName);
   data.entorno = EntornoDefinir(tipoEntorno,nombreFichero);
  end
 end
 set(handles.enabledRemove,'Value',0);

 data.agentesUpdated = 1;
 data.objetivosAutUpdated = 1; data.objetivosUpdated = 1;
 data.POIsUpdated = 1;
 set(handles.defaultAgentes,'Value',1);
 set(handles.defaultPOIs,'Value',0);

 if ~isfield(data,'gateways'), data.gateways = {}; end
 tmp = get(handles.gatewaysIDs,'String'); tmp = [tmp; data.gateways'];
 set(handles.gatewaysIDsAgente,'String',tmp);
 set(handles.gatewaysIDs,'String',tmp);

 set(handles.restriccionUGV,'Value',data.options.UGVconstraints+1);
 set(handles.reexpansion,'Value',data.options.reexpansions+1);
 set(handles.funcionHeuristica,'Value',data.options.heuristic+1);
 set(handles.slopeComputing,'Value',data.options.slopeComputing+1);
 set(handles.visualizacion,'Value',data.options.verbose+1);
 set(handles.generacionMapas,'Value',data.options.mapasTiempo+1);
 set(handles.criterioOptimizacion,'Value',data.options.optTmw+1);
 set(handles.criterioTemporal,'Value',data.options.TAU+1);

 if exist('Graficas Experimento.ps','file'), delete('Graficas Experimento.ps'); end
 if exist('Graficas Experimento.log','file'), delete('Graficas Experimento.log'); end
%%% Note:
%  BDMySQL = 'RedLoRa'; BDIDsensor = 'F';
%  if ~tipoEnvironment
%   % set(handles.MySQL_label,'Visible','on');
%   % set(handles.MySQL_label2,'Visible','on');
%   % set(handles.MySQL_label3,'Visible','on');
%   % set(handles.MySQL,'Visible','on');
%   % set(handles.MySQL,'String',BDMySQL);
%   % set(handles.IDsensor,'Visible','on');
%   % set(handles.IDsensor,'String',BDIDsensor);
%  else
%   % set(handles.MySQL_label,'Visible','off');
%   % set(handles.MySQL_label2,'Visible','off');
%   % set(handles.MySQL_label3,'Visible','off');
%   % set(handles.MySQL,'Visible','off');
%   % set(handles.IDsensor,'Visible','off');
%  end
%  % if tipoEnvironment, set(handles.enabledGPX,'Visible','off'); end
%  % set(handles.enableMySQL,'Value',0);
%  % if tipoEnvironment, set(handles.enableMySQL,'Visible','off'); end

 handles.figura.Toolbar.Visible = 'on';
 handles.figuraZoom.Toolbar.Visible = 'on';
 set(handles.camera_button,'UserData',get(handles.camara,'Position'));
 handles.graficoAgente.Toolbar.Visible = 'on';
 handles.grafico.Toolbar.Visible = 'on';
 data.default.PositionGraficoAgente = get(handles.graficoAgente,'Position');
 data.default.PositionGraficoObjetivo = get(handles.grafico,'Position');
 data.default.PositionIconoPrioridadObjetivo = get(handles.Prior6Objetivo,'Position');
 data.default.PositionIconoPrioridadPOI = get(handles.Prior6POI,'Position');
 set(handles.AutomaticPlanning,'Value',0);
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 handleZoom = zoom;
 setAllowAxesZoom(handleZoom,handles.figura,true);
 handleZoom2 = zoom;
 setAllowAxesZoom(handleZoom2,handles.figuraZoom,true);
 
 general.updatedEnv = true;
 general.updated = true;
 start(timerUpdate);
 
 % Update handles structure
 guidata(hObject,handles);
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(~,~, handles) 
 % Get default command line output from handles structure
 varargout{1} = handles.output;
end

% --- Executes on button press in button_Salir.
function button_Salir_Callback(~,~, handles)
global data general
 prompt = 'Do you want to exit of the Graphical User Interface?';
 opc = questdlg([prompt,repmat(' ',1,74-length(prompt)),char(127)],...
                'SAR-FIS v4.0a','Yes','No','No');
 if strcmp(opc,'No'), return; end
 % warning saving experiment data ...
 if ~general.jornadas
 opc = 'No';
 %%%%prompt = 'Do you want to save the current experimental data?';
 %%%%opc = questdlg([prompt,repmat(' ',1,74-length(prompt)),char(127)],...
 %%%%               'SAR-FIS v4.0a','Yes','No','Yes');
 end
 if strcmp(opc,'Yes')
  fecha = datestr(datetime('now')); fecha = replace(fecha,{':','-'},''); fecha = replace(fecha,' ','-');
  filename = strcat(data.folderSessions,fecha,'.mat');
  save(filename,'data');
 end
 close(handles.output);
end

% --- Executes when user attempts to close Main.
function Main_CloseRequestFcn(hObject, ~,~)
global ROS
 stop(timerfindall);
 delete(gcp('nocreate'));
 if exist('ROS.SARFISnode'), delete(ROS.SARFISnode); end
 delete(hObject);
 delete(timerfindall);
 clear all
 diary off
end

% --- TabsFun creates axes and text objects for tabs.
function handles = TabsFun(handles, TabFontName, TabFontSize, TabNames)
 % Set the colors indicating a selected/unselected tab
 handles.selectedTabColor = get(handles.Tab1Text,'BackgroundColor');
 handles.unselectedTabColor = [.94 .94 .94];
 % Create Tabs
 TabColor = handles.selectedTabColor;
 for i = 1:length(TabNames)
  if (i==3 || i==5 || i==7) i;
  else
  n = num2str(i);
  % Get text objects position
  set(handles.(['Tab',n,'Text']),'Units','pixels')
  pos = get(handles.(['Tab',n,'Text']),'Position');
  % Create axes with callback function
  handles.(['a',n]) = axes('Units','pixels','Box','on','XTick',[],'YTick',[],'Color',TabColor,'Position',pos,...
                      'Tag',n,'ButtonDownFcn',[mfilename,'(''ClickOnTab'',gcbo,[],guidata(gcbo))']);
  % Create text with callback function
  handles.(['t',n]) = text('String',TabNames{i},'Units','pixels','Position',[3,17],...
                      'HorizontalAlignment','left','VerticalAlignment','middle','Margin',eps,...
                      'FontName',TabFontName,'FontSize',TabFontSize,'Backgroundcolor',TabColor,...
                      'Tag',n,'FontName','MS Sans Serif','ButtonDownFcn',[mfilename,'(''ClickOnTab'',gcbo,[],guidata(gcbo))']);
  TabColor = handles.unselectedTabColor;
  handles.(['a',n]).Toolbar.Visible = 'off';
  end
 end
 % Manage panels (place them in the correct position and manage visibilities)
 pos = get(handles.Tab1Panel,'Position');
 set(handles.Tab1Text,'Visible','off')
 for i = 2:length(TabNames)
  if (i==3 || i==5 || i==7) i;
  else
  set(handles.(['Tab',num2str(i),'Panel']),'Position',pos)
  set(handles.(['Tab',num2str(i),'Panel']),'Visible','off')
  set(handles.(['Tab',num2str(i),'Text']),'Visible','off')
  end
 end
end

% --- Callback function for clicking on tab.
function ClickOnTab(hObject, ~, handles)
 m = str2double(get(hObject,'Tag'));
 for i = 1:handles.TabsNumber
  if (i==3 || i==5 || i==7) i;
  else
  if i == m
   set(handles.(['a',num2str(i)]),'Color',handles.selectedTabColor);
   set(handles.(['t',num2str(i)]),'BackgroundColor',handles.selectedTabColor);
   set(handles.(['Tab',num2str(i),'Panel']),'Visible','on');
  else
   set(handles.(['a',num2str(i)]),'Color',handles.unselectedTabColor);
   set(handles.(['t',num2str(i)]),'BackgroundColor',handles.unselectedTabColor);
   set(handles.(['Tab',num2str(i),'Panel']),'Visible','off');
  end
  end
 end
 switch m
  case 2
   if strcmp(get(handles.AgenteOK_button,'Visible'),'off'), ClickOnAux2Tab(handles.a21,[],handles);
   else, ClickOnAux2Tab(handles.a22,[],handles); end
  case 3
   if strcmp(get(handles.ObjetivoOK_button,'Visible'),'off'), ClickOnAux3Tab(handles.a31,[],handles);
   else, ClickOnAux3Tab(handles.a32,[],handles); end
  case 4
   if strcmp(get(handles.POIOK_button,'Visible'),'off'), ClickOnAux4Tab(handles.a41,[],handles);
   else, ClickOnAux4Tab(handles.a42,[],handles); end
  case 6
   ClickOnAux6Tab(handles.a62,[],handles);
 end
end

% --- TabsFun creates axes and text objects for tabs.
function handles = Aux2TabsFun(handles, TabFontName, TabFontSize, TabNames)
 % Create Tabs
 TabColor = handles.selectedTabColor;
 for i = 1:handles.AuxTabsNumber
  % Get text objects position
  set(handles.(['Tab2',num2str(i),'Text']),'Units','pixels')
  pos = get(handles.(['Tab2',num2str(i),'Text']),'Position');
  % Create axes with callback function
  handles.(['a2',num2str(i)]) = axes('Units','pixels','Box','on','XTick',[],'YTick',[],'Color',TabColor,'Position',pos,...
                      'Tag',num2str(i),'Parent',handles.Tab2Panel,...
                      'ButtonDownFcn',[mfilename,'(''ClickOnAux2Tab'',gcbo,[],guidata(gcbo))']);
  % Create text with callback function
  handles.(['t2',num2str(i)]) = text('String',TabNames{i},'Units','pixels','Position',[3,17],...
                      'HorizontalAlignment','left','VerticalAlignment','middle','Margin',eps,...
                      'FontName',TabFontName,'FontSize',TabFontSize,'Backgroundcolor',TabColor,...
                      'Tag',num2str(i),'FontName','MS Sans Serif','ButtonDownFcn',[mfilename,'(''ClickOnAux2Tab'',gcbo,[],guidata(gcbo))']);
  TabColor = handles.unselectedTabColor;
  handles.(['a2',num2str(i)]).Toolbar.Visible = 'off';
 end
 % Manage panels (place them in the correct position and manage visibilities)
 pos = get(handles.Tab22Panel,'Position');
 set(handles.Tab21Text,'Visible','off')
 for j = [2]
  for i = 2:handles.AuxTabsNumber
   set(handles.(['Tab2',num2str(i),'Panel']),'Position',pos)
   set(handles.(['Tab2',num2str(i),'Panel']),'Visible','off')
   set(handles.(['Tab2',num2str(i),'Text']),'Visible','off')
  end
 end
end

% --- Callback function for clicking on tab.
function ClickOnAux2Tab(hObject, ~, handles)
 m = str2double(get(hObject,'Tag'));
  for i = 1:handles.AuxTabsNumber+1
   if i == m
    set(handles.(['a2',num2str(i)]),'Color',handles.selectedTabColor);
    set(handles.(['t2',num2str(i)]),'BackgroundColor',handles.selectedTabColor);
    set(handles.(['Tab2',num2str(i),'Panel']),'Visible','on');
   else
    set(handles.(['a2',num2str(i)]),'Color',handles.unselectedTabColor);
    set(handles.(['t2',num2str(i)]),'BackgroundColor',handles.unselectedTabColor);
    set(handles.(['Tab2',num2str(i),'Panel']),'Visible','off');
   end
  end
end

% --- TabsFun creates axes and text objects for tabs.
function handles = Aux3TabsFun(handles, TabFontName, TabFontSize, TabNames)
 % Create Tabs
 TabColor = handles.selectedTabColor;
 for i = 1:handles.AuxTabsNumber
  % Get text objects position
  set(handles.(['Tab3',num2str(i),'Text']),'Units','pixels')
  pos = get(handles.(['Tab3',num2str(i),'Text']),'Position');
  % Create axes with callback function
  handles.(['a3',num2str(i)]) = axes('Units','pixels','Box','on','XTick',[],'YTick',[],'Color',TabColor,'Position',pos,...
                      'Tag',num2str(i),'Parent',handles.Tab3Panel,...
                      'ButtonDownFcn',[mfilename,'(''ClickOnAux3Tab'',gcbo,[],guidata(gcbo))']);
  % Create text with callback function
  handles.(['t3',num2str(i)]) = text('String',TabNames{i},'Units','pixels','Position',[3,17],...
                      'HorizontalAlignment','left','VerticalAlignment','middle','Margin',eps,...
                      'FontName',TabFontName,'FontSize',TabFontSize,'Backgroundcolor',TabColor,...
                      'Tag',num2str(i),'FontName','MS Sans Serif','ButtonDownFcn',[mfilename,'(''ClickOnAux3Tab'',gcbo,[],guidata(gcbo))']);
  TabColor = handles.unselectedTabColor;
  handles.(['a3',num2str(i)]).Toolbar.Visible = 'off';
 end
 % Manage panels (place them in the correct position and manage visibilities)
 pos = get(handles.Tab32Panel,'Position');
 set(handles.Tab31Text,'Visible','off')
 for j = [2]
  for i = 2:handles.AuxTabsNumber
   set(handles.(['Tab3',num2str(i),'Panel']),'Position',pos)
   set(handles.(['Tab3',num2str(i),'Panel']),'Visible','off')
   set(handles.(['Tab3',num2str(i),'Text']),'Visible','off')
  end
 end
end

% --- Callback function for clicking on tab.
function ClickOnAux3Tab(hObject, ~, handles)
 m = str2double(get(hObject,'Tag'));
  for i = 1:handles.AuxTabsNumber
   if i == m
    set(handles.(['a3',num2str(i)]),'Color',handles.selectedTabColor);
    set(handles.(['t3',num2str(i)]),'BackgroundColor',handles.selectedTabColor);
    set(handles.(['Tab3',num2str(i),'Panel']),'Visible','on');
   else
    set(handles.(['a3',num2str(i)]),'Color',handles.unselectedTabColor);
    set(handles.(['t3',num2str(i)]),'BackgroundColor',handles.unselectedTabColor);
    set(handles.(['Tab3',num2str(i),'Panel']),'Visible','off');
   end
  end
end

% --- TabsFun creates axes and text objects for tabs.
function handles = Aux4TabsFun(handles, TabFontName, TabFontSize, TabNames)
 % Create Tabs
 TabColor = handles.selectedTabColor;
 for i = 1:handles.AuxTabsNumber
  % Get text objects position
  set(handles.(['Tab4',num2str(i),'Text']),'Units','pixels')
  pos = get(handles.(['Tab4',num2str(i),'Text']),'Position');
  % Create axes with callback function
  handles.(['a4',num2str(i)]) = axes('Units','pixels','Box','on','XTick',[],'YTick',[],'Color',TabColor,'Position',pos,...
                      'Tag',num2str(i),'Parent',handles.Tab4Panel,...
                      'ButtonDownFcn',[mfilename,'(''ClickOnAux4Tab'',gcbo,[],guidata(gcbo))']);
  % Create text with callback function
  handles.(['t4',num2str(i)]) = text('String',TabNames{i},'Units','pixels','Position',[3,17],...
                      'HorizontalAlignment','left','VerticalAlignment','middle','Margin',eps,...
                      'FontName',TabFontName,'FontSize',TabFontSize,'Backgroundcolor',TabColor,...
                      'Tag',num2str(i),'FontName','MS Sans Serif','ButtonDownFcn',[mfilename,'(''ClickOnAux4Tab'',gcbo,[],guidata(gcbo))']);
  TabColor = handles.unselectedTabColor;
  handles.(['a4',num2str(i)]).Toolbar.Visible = 'off';
 end
 % Manage panels (place them in the correct position and manage visibilities)
 pos = get(handles.Tab42Panel,'Position');
 set(handles.Tab41Text,'Visible','off')
 for j = [2]
  for i = 2:handles.AuxTabsNumber
   set(handles.(['Tab4',num2str(i),'Panel']),'Position',pos)
   set(handles.(['Tab4',num2str(i),'Panel']),'Visible','off')
   set(handles.(['Tab4',num2str(i),'Text']),'Visible','off')
  end
 end
end

% --- Callback function for clicking on tab.
function ClickOnAux4Tab(hObject, ~, handles)
 m = str2double(get(hObject,'Tag'));
  for i = 1:handles.AuxTabsNumber
   if i == m
    set(handles.(['a4',num2str(i)]),'Color',handles.selectedTabColor);
    set(handles.(['t4',num2str(i)]),'BackgroundColor',handles.selectedTabColor);
    set(handles.(['Tab4',num2str(i),'Panel']),'Visible','on');
   else
    set(handles.(['a4',num2str(i)]),'Color',handles.unselectedTabColor);
    set(handles.(['t4',num2str(i)]),'BackgroundColor',handles.unselectedTabColor);
    set(handles.(['Tab4',num2str(i),'Panel']),'Visible','off');
   end
  end
end

% --- TabsFun creates axes and text objects for tabs.
function handles = Aux6TabsFun(handles, TabFontName, TabFontSize, TabNames)
 % Create Tabs
 TabColor = handles.selectedTabColor;
 for i = 1:handles.AuxTabsNumber
  % Get text objects position
  set(handles.(['Tab6',num2str(i),'Text']),'Units','pixels')
  pos = get(handles.(['Tab6',num2str(i),'Text']),'Position');
  % Create axes with callback function
  handles.(['a6',num2str(i)]) = axes('Units','pixels','Box','on','XTick',[],'YTick',[],'Color',TabColor,'Position',pos,...
                      'Tag',num2str(i),'Parent',handles.Tab6Panel,...
                      'ButtonDownFcn',[mfilename,'(''ClickOnAux6Tab'',gcbo,[],guidata(gcbo))']);
  % Create text with callback function
  handles.(['t6',num2str(i)]) = text('String',TabNames{i},'Units','pixels','Position',[3,17],...
                      'HorizontalAlignment','left','VerticalAlignment','middle','Margin',eps,...
                      'FontName',TabFontName,'FontSize',TabFontSize,'Backgroundcolor',TabColor,...
                      'Tag',num2str(i),'FontName','MS Sans Serif','ButtonDownFcn',[mfilename,'(''ClickOnAux6Tab'',gcbo,[],guidata(gcbo))']);
  TabColor = handles.unselectedTabColor;
  handles.(['a6',num2str(i)]).Toolbar.Visible = 'off';
 end
 % Manage panels (place them in the correct position and manage visibilities)
 pos = get(handles.Tab62Panel,'Position');
 set(handles.Tab61Text,'Visible','off')
 for j = [2]
  for i = 2:handles.AuxTabsNumber
   set(handles.(['Tab6',num2str(i),'Panel']),'Position',pos)
   set(handles.(['Tab6',num2str(i),'Panel']),'Visible','off')
   set(handles.(['Tab6',num2str(i),'Text']),'Visible','off')
  end
 end
 set(handles.a61,'Visible','off');
 set(handles.t61,'Visible','off');
end

% --- Callback function for clicking on tab.
function ClickOnAux6Tab(hObject, ~, handles)
 m = str2double(get(hObject,'Tag'));
  for i = 1:handles.AuxTabsNumber
   if i == m
    set(handles.(['a6',num2str(i)]),'Color',handles.selectedTabColor);
    set(handles.(['t6',num2str(i)]),'BackgroundColor',handles.selectedTabColor);
    set(handles.(['Tab6',num2str(i),'Panel']),'Visible','on');
   else
    set(handles.(['a6',num2str(i)]),'Color',handles.unselectedTabColor);
    set(handles.(['t6',num2str(i)]),'BackgroundColor',handles.unselectedTabColor);
    set(handles.(['Tab6',num2str(i),'Panel']),'Visible','off');
    % if (i==1) set(handles.Tab61Panel,'Enable','off'); end
   end
  end
end

% --- Executes on button press in zoom_button.
function zoom_button_Callback(~,~, handles)
global handleZoom TTS
if false
 topic = 'v3/data-house@ttn/devices/spot/up';
 msg = {'"{"end_device_ids":{"device_id":"spot","application_ids":{"application_id":"data-house"},"dev_eui":"A3FF0A30B001E007","dev_addr":"2607244F"},"correlation_ids":["as:up:01G2D7702MCBRJB6D15KBDRXH6","ns:uplink:01G2D76ZW5RSFF3DKB6054SFGM","pba:conn:up:01G225HQD4RC4G4067FX5CX9SD","pba:uplink:01G2D76ZVZV5B2SRRMG92D569M","rpc:/ttn.lorawan.v3.GsNs/HandleUplink:01G2D76ZW5SA2NE51BWD6ZT2Z2","rpc:/ttn.lorawan.v3.NsAs/HandleUplink:01G2D7702MKBXD459EES3MBG8X"],"received_at":"2022-05-06T17:38:22.421078355Z","uplink_message":{"f_port":42,"f_cnt":315,"frm_payload":"ewlKAAB6xDRi","rx_metadata":[{"gateway_ids":{"gateway_id":"packetbroker"},"packet_broker":{"message_id":"01G2D76ZVZV5B2SRRMG92D569M","forwarder_net_id":"000013","forwarder_tenant_id":"ttnv2","forwarder_cluster_id":"ttn-v2-legacy-eu","forwarder_gateway_id":"rincontech","home_network_net_id":"000013","home_network_tenant_id":"ttn","home_network_cluster_id":"eu1.cloud.thethings.network"},"time":"2022-05-06T17:39:22Z","rssi":-25,"channel_rssi":-25,"snr":8.75,"location":{"latitude":36.72023064,"longitude":-4.29748577,"altitude":115},"uplink_token":"eyJnIjoiWlhsS2FHSkhZMmxQYVVwQ1RWUkpORkl3VGs1VE1XTnBURU5LYkdKdFRXbFBhVXBDVFZSSk5GSXdUazVKYVhkcFlWaFphVTlwU2t4VFIzUnBWMFUxY2t4VVdsQlVSbTh4V2xoQ1YwbHBkMmxrUjBadVNXcHZhV1ZzVWtWUldFSjNZMnRhVDA5VlNraE1XR2hDVjFWYVprMHpXbHBhZVVvNUxrcG5WVFV4ZW1OcFN6UlRaazU0VjFreWFqQjFlbEV1UkRsMmNWWlBNbE13ZG1ZdFVUaGZOeTVzYm05NFVqSkJXVGRmVFhsS1pFRkNWWE5ZYm1sWllqbHRXa1Z4WjNCbVowNVRia2hQT1ZkQlpGWjJNVEZaUWxCWWFTMTVVV2xoT0VFeVNHOU1URmRtVTBwSVMyMTVjRXBHTFRneFdUTktlRkEwV0UxMlVWZHBXREl3WVVFelZVMTJWMnhaUnpWeWJteHJZV3c0WjBZMk5sSnNWbWswV0RSMlNrWnFMbWhtWmxCa0xWRTVOaTFaZFhod2RHNVVYMmRoY1djPSIsImEiOnsiZm5pZCI6IjAwMDAxMyIsImZ0aWQiOiJ0dG52MiIsImZjaWQiOiJ0dG4tdjItbGVnYWN5LWV1In19"},{"gateway_ids":{"gateway_id":"etsiit-rak","eui":"AC1F09FFFE014321"},"time":"2022-05-06T17:39:22.149Z","timestamp":1884410900,"rssi":-113,"channel_rssi":-113,"snr":-0.8,"location":{"latitude":36.71460012615546,"longitude":-4.477698504924775,"altitude":30,"source":"SOURCE_REGISTRY"},"uplink_token":"ChgKFgoKZXRzaWl0LXJhaxIIrB8J//4BQyEQlKjHggcaCwiOutWTBhDexJhuIKDckf3rzSIqCwiOutWTBhDAnoZH","channel_index":7},{"gateway_ids":{"gateway_id":"eii-kona","eui":"647FDAFFFE00809D"},"timestamp":2489810804,"rssi":-109,"channel_rssi":-109,"snr":10.2,"location":{"latitude":36.715735381827486,"longitude":-4.492338001728059,"altitude":30,"source":"SOURCE_REGISTRY"},"uplink_token":"ChYKFAoIZWlpLWtvbmESCGR/2v/+AICdEPT+naMJGgwIjrrVkwYQuOODjAEgoLqnorunCw==","channel_index":2},{"gateway_ids":{"gateway_id":"pisco-kerlink","eui":"7276FF002E060D95"},"time":"2022-05-06T17:38:22.149Z","timestamp":671294396,"encrypted_fine_timestamp":"YwIEW2/Z7h0UXKKZGPd/GQ==","encrypted_fine_timestamp_key_id":"0","rssi":-112,"signal_rssi":-116,"channel_rssi":-112,"snr":-2,"frequency_offset":"2703","location":{"latitude":36.71601059279736,"longitude":-4.468729197978974,"altitude":30,"source":"SOURCE_REGISTRY"},"uplink_token":"ChsKGQoNcGlzY28ta2VybGluaxIIcnb/AC4GDZUQvMeMwAIaDAiOutWTBhDc+tGeASDgrI7ixKcjKgsIjrrVkwYQwJ6GRw==","channel_index":7},{"gateway_ids":{"gateway_id":"fest-kerlink","eui":"7276FF002E06299B"},"time":"2022-05-06T17:38:22.149Z","timestamp":1115216236,"encrypted_fine_timestamp":"1nC/MoDPD+2ithN4E1C+OA==","encrypted_fine_timestamp_key_id":"0","rssi":-113,"signal_rssi":-123,"channel_rssi":-113,"snr":-8,"frequency_offset":"2919","location":{"latitude":36.71525376025787,"longitude":-4.495701491832734,"altitude":35,"source":"SOURCE_REGISTRY"},"uplink_token":"ChoKGAoMZmVzdC1rZXJsaW5rEghydv8ALgYpmxDssuOTBBoMCI661ZMGEP26o6YBIOCbxcC6tyIqCwiOutWTBhDAnoZH","channel_index":7}],"settings":{"data_rate":{"lora":{"bandwidth":125000,"spreading_factor":9}},"coding_rate":"4/5","frequency":"868500000"},"received_at":"2022-05-06T17:38:22.213532301Z","confirmed":true,"consumed_airtime":"0.205824s","network_ids":{"net_id":"000013","tenant_id":"ttn","cluster_id":"eu1","cluster_address":"eu1.cloud.thethings.network"}}}"'};
 %msg = {'"{"end_device_ids":{"device_id":"spot-rad01","application_ids":{"application_id":"sar-jba1"},"dev_eui":"E1112ABCFFAAEF01","dev_addr":"260BE618"},"correlation_ids":["as:up:01G49XH9MX1VWEVW1FRDDB8KXF","gs:conn:01G3R43NQ8Z1549Z7GYMRVP4B0","gs:up:host:01G3R43P2V598H9GRRTRZBZSJP","gs:uplink:01G49XH9EDPJN3J4X9YTSR008S","ns:uplink:01G49XH9EE4WR6245RCS7E7VBC","rpc:/ttn.lorawan.v3.GsNs/HandleUplink:01G49XH9EEHPAT30W5MGET9A6M","rpc:/ttn.lorawan.v3.NsAs/HandleUplink:01G49XH9MW328STYPRSEX0PGHW"],"received_at":"2022-05-30T07:22:54.493261234Z","uplink_message":{"f_port":87,"f_cnt":576,"frm_payload":"AgmBAAAQQjRh","rx_metadata":[{"gateway_ids":{"gateway_id":"fest-kerlink","eui":"7276FF002E06299B"},"time":"2022-05-30T07:22:54.092Z","timestamp":1971380532,"encrypted_fine_timestamp":"7xGy8sQp/QeJuKO/1QYafw==","encrypted_fine_timestamp_key_id":"0","rssi":-110,"signal_rssi":-119,"channel_rssi":-110,"snr":-8,"frequency_offset":"5174","location":{"latitudee":36.71525376025787,"longitudee":-4.495701491832734,"altitudee":35,"source":"SOURCE_REGISTRY"},"uplink_token":"ChoKGAoMZmVzdC1rZXJsaW5rEghydv8ALgYpmxC0woOsBxoMCM7h0ZQGEPGJ/ocBIKDmvvuvmIgBKgsIzuHRlAYQgJ7vKw==","channel_index":6}],"settings":{"data_rate":{"lora":{"bandwidth":125000,"spreading_factor":10}},"coding_rate":"4/5","frequency":"868300000","timestamp":1971380532,"time":"2022-05-30T07:22:54.092Z"},"received_at":"2022-05-30T07:22:54.286091576Z","confirmed":true,"consumed_airtime":"0.370688s","network_ids":{"net_id":"000013","tenant_id":"ttn","cluster_id":"eu1","cluster_address":"eu1.cloud.thethings.network"}}}"'};
 idBroker = 0;
 receiveMessage(topic,msg,handles,TTS,idBroker);
else
 if ~strcmp(handleZoom.Enable,'on'), handleZoom.Enable = 'on';
 else
  % zoom out;
  handleZoom.Enable = 'off';
 end
 set(handles.zoom_label,'Visible',handleZoom.Enable);
end
end

function warning(msg,hObject,handles)
 set(handles.warning,'String',['<html>',msg{1},'<br />',msg{2},'</html>']);
 set(handles.warning,'Visible','on');
 set(handles.warning,'UserData',hObject);
 uicontrol(handles.warning);
end

% --- Executes on button press in warning.
function warning_Callback(~,~, handles)
 set(handles.warning,'Visible','off');
 if isa(class(get(handles.warning,'UserData')),'matlab.ui.control.Table')
  uitable(get(handles.warning,'UserData'));
 else
  uicontrol(get(handles.warning,'UserData'));
 end
end

% --- Executes on button press in enabledRemove.
function enabledRemove_Callback(hObject, ~, handles)
 if strcmp(get(handles.removeAgente_button,'Visible'),'on') && get(hObject,'Value'), str = 'on'; else, str = 'off'; end
 set(handles.removeAgente_button,'Enable',str);
 if strcmp(get(handles.removeObjetivo_button,'Visible'),'on') && get(hObject,'Value'), str = 'on'; else, str = 'off'; end
 set(handles.removeObjetivo_button,'Enable',str);
 if strcmp(get(handles.removePOI_button,'Visible'),'on') && get(hObject,'Value'), str = 'on'; else, str = 'off'; end
 set(handles.removePOI_button,'Enable',str);
end

% --- Executes on button press in DATASET_button.
function DATASET_button_Callback(~,~,~)
global data
  fecha = datestr(datetime('now')); fecha = replace(fecha,{':','-'},''); fecha = replace(fecha,' ','-');
  filename = strcat(data.folderSessions,fecha,'.mat');
  save(filename,'data');
end


%% ==========================================================================================================================
% --- Tab1Panel: ENVIRONMENT
% ----------------------------

% --- Executes on selection change in environment.
function entorno_Callback(hObject, ~, handles)
global data
 tipo = get(hObject,'Value')-1;
 if ~tipo
  data.pathName = 'DEM files/Natural';
  set(handles.elevacion,'String','Press the next button');
  set(handles.elevacion,'Enable','inactive');
  set(handles.elevacion_button,'Enable','on');
  set(handles.radioDEM,'enable','on');
  set(handles.radioPhoto,'enable','on');
  set(handles.radioPhoto,'value',1);
  set(handles.radioAlternative,'enable','on');
  set(handles.imagen,'String','Press the next button');
  set(handles.imagen,'Enable','on');
  set(handles.imagen_button,'Enable','on');
  set(handles.a3,'Visible','on');
  set(handles.t3,'String','Targets');
 else
  data.pathName = 'DEM files/Artificial';
  set(handles.elevacion,'String','Press the next button');
  set(handles.elevacion,'Enable','inactive');
  set(handles.elevacion_button,'Enable','on');
  set(handles.radioDEM,'enable','on');
  set(handles.radioDEM,'value',1);
  set(handles.radioPhoto,'enable','off');
  set(handles.radioAlternative,'enable','off');
  set(handles.imagen,'String','Not applied');
  set(handles.imagen,'Enable','off');
  set(handles.imagen_button,'Enable','off');
  set(handles.a3,'Visible','off');
  set(handles.t3,'String','');
 end
 elevacion_button_Callback(hObject,[],handles)
end

% --- Executes on button press in elevacion_button.
function elevacion_button_Callback(~,~, handles)
global data general
 tipo = get(handles.entorno,'Value')-1;
 oldPathName = data.pathName;
 [fileName,data.pathName] = uigetfile({'*.xyz;*.mat','All Elevation Map Files'},...
                                 'Pick a file','MultiSelect', 'off',...
                                 data.pathName);
 if fileName
  fileName = fileName(1:strfind(fileName,'.')-1);
  set(handles.elevacion,'String',fileName);
  nombreFichero = strcat(data.pathName,fileName);
  data.entorno = EntornoDefinir(tipo,nombreFichero);
 else
  data.pathName = oldPathName;
 end
 if ~tipo
  set(handles.radioPhoto,'value',1);
  set(handles.imagen,'String',get(handles.elevacion,'String'));
end
 % eliminarDatos(handles);  % evita eliminar datos de la estructura por cambio de DEM
 general.updatedEnv = true;
 %general.updated = true;
end

function eliminarDatos(handles)
global data
 %%% set(handles.enableMySQL,'Value',0);
 %%% enableMySQL_Callback([],[],handles);
 set(handles.numAgentes,'Value',0);
 set(handles.numAgentes,'String',num2str(get(handles.numAgentes,'Value')));
 if isfield(data,'agentes'), data = rmfield(data,'agentes'); end
 set(handles.idAgente,'Value',0);
 set(handles.idAgente,'String','');
 set(handles.idAgente,'Enable','inactive');
 set(handles.removeAgente_button,'Visible','off');
 set(handles.editAgente_button,'Visible','off');
 editAgente(handles);
 set(handles.numObjetivos,'Value',0);
 set(handles.numObjetivos,'String',num2str(get(handles.numObjetivos,'Value')));
 if isfield(data,'sensorNodes'), data = rmfield(data,'sensorNodes'); end
 set(handles.idObjetivo,'Value',0);
 set(handles.idObjetivo,'String','');
 set(handles.idObjetivo,'Enable','inactive');
 set(handles.removeObjetivo_button,'Visible','off');
 set(handles.editObjetivo_button,'Visible','off');
 editObjetivo(handles);
 set(handles.numPOIs,'Value',0);
 set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
 if isfield(data,'points'), data = rmfield(data,'points'); end
 set(handles.idPOI,'Value',0);
 set(handles.idPOI,'String','');
 set(handles.idPOI,'Enable','inactive');
 set(handles.removePOI_button,'Visible','off');
 set(handles.editPOI_button,'Visible','off');
 editPOI(handles);
 set(handles.PLANNER_button,'Enable','off');
 if isfield(data,'planner'), data = rmfield(data,'planner'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
end

% --- Executes on button press in imagen_button.
function imagen_button_Callback(~,~, handles)
global data general
 tipo = get(handles.entorno,'Value')-1;
 Entorno_fileName = get(handles.elevacion,'String');
 Entorno_fileName = Entorno_fileName(1:strfind(Entorno_fileName,'_dsm_')-1);
 [fileName,pathAltName] = uigetfile({strcat(Entorno_fileName,'*.xyz;',Entorno_fileName,'*.mat'),'All Elevation Map Files'},...
                                    'Pick a file','MultiSelect', 'off',...
                                    data.pathAltName);
 if fileName
  data.pathAltName = pathAltName;
  fileName = fileName(1:strfind(fileName,'.')-1);
  set(handles.imagen,'String',fileName);
  nombreFichero = strcat(data.pathAltName,fileName);
  set(handles.radioAlternative,'Value',1);
  alternativo = EntornoDefinir(tipo,nombreFichero);
  data.entorno.imagen = alternativo.imagen;
 end
 general.updatedEnv = true;
 % general.updated = true;
end

% --- Executes when selected object is changed in radioVisualization.
function radioVisualization_SelectionChangedFcn(hObject, ~, handles)
global data general
 tipo = get(handles.entorno,'Value')-1;
 selected = get(hObject,'String');
 switch selected
  case get(handles.radioDEM,'String')
   nombreFichero = strcat(data.pathName,get(handles.elevacion,'String'));
   data.entorno = EntornoDefinir(tipo,nombreFichero);
   data.entorno.foto_DEM = 1;
  case get(handles.radioPhoto,'String')
   nombreFichero = strcat(data.pathName,get(handles.elevacion,'String'));
   data.entorno = EntornoDefinir(tipo,nombreFichero);
   data.entorno.foto_DEM = 0;
  case get(handles.radioAlternative,'String')
   nombreFichero = strcat(data.pathAltName,get(handles.imagen,'String'));
   alternativo = EntornoDefinir(tipo,nombreFichero);
   data.entorno.imagen = alternativo.imagen;
   data.entorno.foto_DEM = 0;
 end
 general.updatedEnv = true;
 % general.updated = true;
end


%% ==========================================================================================================================
% --- Tab2Panel: AGENTS
% -----------------------

% --- Executes on selection change in idAgent.
function idAgente_Callback(hObject, ~, handles)
% to control the correct number of agent identification and (indirectly) view the asociated values of the requested agent
 set(hObject,'Enable','off');
 idAgente = str2double(get(hObject,'String'));
 set(hObject,'Value',idAgente);
 ok = ~( isnan(idAgente) || idAgente <= 0 || idAgente > get(handles.numAgentes,'Value') );
 if ok, okStr = 'on';
 else
  okStr = 'off';
  set(hObject,'String','');
  set(hObject,'Value',str2double(get(hObject,'String')));
 end
 set(handles.defaultAgentes,'Visible',okStr);
 set(handles.addAgente_button,'Visible',okStr);
 set(handles.removeAgente_button,'Visible',okStr);
 set(handles.editAgente_button,'Visible',okStr);
 editAgente(handles);
 if ~ok
  warning({'Error: Agent identification number.';...
           'The value must be between one and the number of agents.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
 end
 set(handles.defaultAgentes,'Visible','on');
 set(handles.addAgente_button,'Visible','on');
 set(hObject,'Enable','on'); uicontrol(hObject);
end

% --- Auxiliary function for previuos one and other functions.
function editAgente(handles)
% to view the asociated values and (indirectly) the graphs and the video of the requested agent by a given identification number or null
% can be called from eliminarDatos, idAgent_Callback, addAgent_button_Callback, removeAgent_button_Callback, AgentCANCEL_button_Callback functions
global data
 idAgente = get(handles.idAgente,'String');
 if isempty(idAgente) || ~get(handles.idAgente,'Value') || get(handles.idAgente,'Value') > get(handles.numAgentes,'Value')
  set(handles.idFullAgente,'String','');
  set(handles.visibleAgente,'Value',0);
  set(handles.longitudX,'Value',0);
  set(handles.longitudX,'String','');
  set(handles.longitudY,'Value',0);
  set(handles.longitudY,'String','');
  set(handles.seguridadAgente,'Value',0);
  set(handles.seguridadAgente,'String','');
  set(handles.COGx,'Value',0);
  set(handles.COGx,'String','');
  set(handles.COGy,'Value',0);
  set(handles.COGy,'String','');
  set(handles.COGz,'Value',0);
  set(handles.COGz,'String','');
  set(handles.rhoTol,'Value',0);
  set(handles.rhoTol,'String','');
  set(handles.velocidad,'Value',0);
  set(handles.velocidad,'String','');
  set(handles.coefVelocidadPositiva,'Value',0);
  set(handles.coefVelocidadPositiva,'String','');
  set(handles.coefVelocidadNegativa,'Value',0);
  set(handles.coefVelocidadNegativa,'String','');
  set(handles.coefVelocidadLateral,'Value',0);
  set(handles.coefVelocidadLateral,'String','');
  set(handles.pendienteMax,'Value',0);
  set(handles.pendienteMax,'String','');
  set(handles.pendienteMin,'Value',0);
  set(handles.pendienteMin,'String','');
  set(handles.vuelcoMax,'Value',0);
  set(handles.vuelcoMax,'String','');
  set(handles.vuelcoMin,'Value',0);
  set(handles.vuelcoMin,'String','');
  set(handles.modoPosicionAgente,'Value',1);
  set(handles.radioUTMAgente,'Value',1);
  set(handles.posXAgente,'Value',NaN);
  set(handles.posXAgente,'String','');
  set(handles.posYAgente,'Value',NaN);
  set(handles.posYAgente,'String','');
  set(handles.warnPosAgente,'Visible','off');
  set(handles.orientacion,'Value',0);
  set(handles.orientacion,'String','');
  set(handles.radioGiro,'Value',0);
  set(handles.radioGiro,'String','');
  set(handles.colorAgente,'Data',['' '' '']);
  set(handles.IPcameraAgente,'String','');
  set(handles.enableIPcameraAgente,'Value',0);
  set(handles.statusIPcameraAgente,'Background',[1 1 1]);
  set(handles.statusIPcameraAgente_status,'Visible','off');
  set(handles.userIPcameraAgente,'String','');
  set(handles.pwdIPcameraAgente,'String','');
  set(handles.topicCameraAgente,'String','');
  set(handles.typeCameraAgente,'String','');
  set(handles.enabledCameraAgente,'Value',0);
  set(handles.rosCameraAgente,'Value',0);
  set(handles.nodeSubnetworkAgente,'Value',1);
  set(handles.sensorGroupIDAgente,'String','');
  set(handles.minUmbralAgente,'Value',0);
  set(handles.minUmbralAgente,'String','');
  set(handles.maxUmbralAgente,'Value',0);
  set(handles.maxUmbralAgente,'String','');
  set(handles.ipMQTTAgente,'String','');
  set(handles.portMQTTAgente,'String','');
  set(handles.statusMQTTAgente,'Value',0);
  set(handles.statusMQTTAgente,'Background',[1 1 1]);
  set(handles.topicGPSAgente,'String','');
  set(handles.topicCommandAgente,'String','');
  set(handles.topicStatusAgente,'String','');
  set(handles.QoSMQTTAgente,'Value',1);
  set(handles.enabledMQTTAgente,'Value',0);
  set(handles.GPXfolderAgente,'String','');
  set(handles.enabledGPXAgente,'Value',0);
  % ----
  set(handles.idFullAgente_ROS,'String','');
  set(handles.topic1SubsAgente,'String','');
  set(handles.type1SubsAgente,'String','');
  set(handles.enabledSubs1Agente,'Value',0);
  set(handles.ros1SubsAgente,'Value',0);
  set(handles.nameSpaceAgente,'String','');
  set(handles.topic3aSubsAgente,'String','');
  set(handles.topic3bSubsAgente,'String','');
  set(handles.topic3cSubsAgente,'String','');
  set(handles.type3SubsAgente,'String','');
  set(handles.enabledSubs3Agente,'Value',0);
  set(handles.ros3SubsAgente,'Value',0);
  set(handles.freq4SubsAgente,'String','');
  set(handles.topic4SubsAgente,'String','');
  set(handles.type4SubsAgente,'String','');
  set(handles.enabledSubs4Agente,'Value',0);
  set(handles.ros4SubsAgente,'Value',0);
  set(handles.topic2SubsAgente,'String','');
  set(handles.type2SubsAgente,'String','');
  set(handles.enabledSubs2Agente,'Value',0);
  set(handles.ros2SubsAgente,'Value',0);
  set(handles.topic1PubAgente,'String','');
  set(handles.type1PubAgente,'String','');
  set(handles.enabledPub1Agente,'Value',0);
  set(handles.ros1PubAgente,'Value',0);
  set(handles.granularity,'String','');
  % ----
  set(handles.idFullAgente_status,'String','');
  set(handles.enableAgente,'Value',0);
  set(handles.enableAgente,'Enable','inactive');
  set(handles.radioUTMAgente_status,'Enable','inactive');
  set(handles.radioGEOAgente_status,'Enable','inactive');
  set(handles.radioUTMAgente_status,'Value',1);
  set(handles.posXAgente_status,'Value',NaN);
  set(handles.posXAgente_status,'String','');
  set(handles.posYAgente_status,'Value',NaN);
  set(handles.posYAgente_status,'String','');
  set(handles.warnPosAgente_status,'Visible','off');
  set(handles.orientacion_status,'Value',0);
  set(handles.orientacion_status,'String','');
  set(handles.gatewaysIDsAgente_label,'Visible','off');
  set(handles.gatewaysIDsAgente,'Visible','off');
  set(handles.packetsAgente,'Visible','off');
  set(handles.packetsAgente,'String','');
  set(handles.sensorIDsAgente_label,'Visible','off');
  set(handles.sensorIDsAgente,'Visible','off');
  set(handles.sensorIDsAgente,'Data',[]);
  set(handles.valueSensorsAgente_label,'Visible','off');
  set(handles.valueSensorsAgente,'Visible','off');
  set(handles.valueSensorsAgente,'Data',[]);
  set(handles.enableFreezeAgente,'Visible','off');
  set(handles.FechaAgente_label,'Visible','off');
  set(handles.FechaAgente,'Visible','off');
  set(handles.FechaAgente,'String','');
  cla(handles.camara);
  set(handles.graficoAgente,'Visible','off');
  legend(handles.graficoAgente,'off');
  handles.graficoAgente.XAxis.Visible = 'off';
  cla(handles.graficoAgente);
  set(handles.graficoAuxAgente,'Visible','off');
  legend(handles.graficoAuxAgente,'off');
  cla(handles.graficoAuxAgente);
  % ----
  set(handles.Fisiologic_chart1,'Visible','off');
  legend(handles.Fisiologic_chart1,'off');
  handles.Fisiologic_chart1.XAxis.Visible = 'off';
  cla(handles.Fisiologic_chart1);
  set(handles.Fisiologic_chart2,'Visible','off');
  legend(handles.Fisiologic_chart2,'off');
  handles.Fisiologic_chart2.XAxis.Visible = 'off';
  cla(handles.Fisiologic_chart2);
  set(handles.Fisiologic_chart3,'Visible','off');
  legend(handles.Fisiologic_chart3,'off');
  handles.Fisiologic_chart3.XAxis.Visible = 'off';
  cla(handles.Fisiologic_chart3);
  set(handles.Fisiologic_chart4,'Visible','off');
  legend(handles.Fisiologic_chart4,'off');
  cla(handles.Fisiologic_chart4);
 else
  idAgente = get(handles.idAgente,'Value');
  set(handles.idFullAgente,'String',data.agentes(idAgente).config.idFull);
  set(handles.visibleAgente,'Value',data.agentes(idAgente).config.visible);
  set(handles.longitudX,'Value',data.agentes(idAgente).config.tipoAgente.dimension(1));
  set(handles.longitudX,'String',num2str(get(handles.longitudX,'value')));
  set(handles.longitudY,'Value',data.agentes(idAgente).config.tipoAgente.dimension(2));
  set(handles.longitudY,'String',num2str(get(handles.longitudY,'value')));
  set(handles.seguridadAgente,'Value',data.agentes(idAgente).config.tipoAgente.distSeg);
  set(handles.seguridadAgente,'String',num2str(get(handles.seguridadAgente,'value')));
  set(handles.COGx,'Value',data.agentes(idAgente).config.tipoAgente.COG(1));
  set(handles.COGx,'String',num2str(get(handles.COGx,'value')));
  set(handles.COGy,'Value',data.agentes(idAgente).config.tipoAgente.COG(2));
  set(handles.COGy,'String',num2str(get(handles.COGy,'value')));
  set(handles.COGz,'Value',data.agentes(idAgente).config.tipoAgente.COG(3));
  set(handles.COGz,'String',num2str(get(handles.COGz,'value')));
  set(handles.rhoTol,'Value',data.agentes(idAgente).config.tipoAgente.rhoTol);
  set(handles.rhoTol,'String',num2str(get(handles.rhoTol,'value')));
  set(handles.velocidad,'Value',data.agentes(idAgente).config.tipoAgente.velocidad);
  set(handles.velocidad,'String',num2str(get(handles.velocidad,'value')));
  set(handles.coefVelocidadPositiva,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadPositiva);
  set(handles.coefVelocidadPositiva,'String',num2str(get(handles.coefVelocidadPositiva,'value')));
  set(handles.coefVelocidadNegativa,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadNegativa);
  set(handles.coefVelocidadNegativa,'String',num2str(get(handles.coefVelocidadNegativa,'value')));
  set(handles.coefVelocidadLateral,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadLateral);
  set(handles.coefVelocidadLateral,'String',num2str(get(handles.coefVelocidadLateral,'value')));
  set(handles.pendienteMax,'Value',data.agentes(idAgente).config.tipoAgente.vRef_LUT.theta_threshold(2)*180/pi);
  set(handles.pendienteMax,'String',num2str(get(handles.pendienteMax,'value')));
  set(handles.pendienteMin,'Value',data.agentes(idAgente).config.tipoAgente.vRef_LUT.theta_threshold(1)*180/pi);
  set(handles.pendienteMin,'String',num2str(get(handles.pendienteMin,'value')));
  set(handles.vuelcoMax,'Value',data.agentes(idAgente).config.tipoAgente.vRef_LUT.phi_threshold(2)*180/pi);
  set(handles.vuelcoMax,'String',num2str(get(handles.vuelcoMax,'value')));
  set(handles.vuelcoMin,'Value',data.agentes(idAgente).config.tipoAgente.vRef_LUT.phi_threshold(1)*180/pi);
  set(handles.vuelcoMin,'String',num2str(get(handles.vuelcoMin,'value')));
  set(handles.modoPosicionAgente,'Value',data.agentes(idAgente).config.modoPosicion);
  set(handles.radioUTMAgente,'Value',data.agentes(idAgente).config.unidadPosicion);
  set(handles.radioGEOAgente,'Value',~data.agentes(idAgente).config.unidadPosicion);
  set(handles.posXAgente,'Value',data.agentes(idAgente).config.posicion(1));
  set(handles.posYAgente,'Value',data.agentes(idAgente).config.posicion(2));
  radioUnitAgente(handles,false);
  set(handles.orientacion,'Value',data.agentes(idAgente).config.theta*180/pi);
  if isnan(data.agentes(idAgente).config.theta), set(handles.orientacion,'String','');
  else, set(handles.orientacion,'String',num2str(get(handles.orientacion,'value'))); end
  set(handles.radioGiro,'Value',data.agentes(idAgente).config.radioGiro);
  if isnan(data.agentes(idAgente).config.radioGiro), set(handles.radioGiro,'String','');
  else, set(handles.radioGiro,'String',num2str(get(handles.radioGiro,'value'))); end
  set(handles.colorAgente,'Data',data.agentes(idAgente).config.color);
  set(handles.IPcameraAgente,'String',data.agentes(idAgente).config.IPcamera);
  set(handles.enableIPcameraAgente,'Value',data.agentes(idAgente).config.enableIPcamera);
  set(handles.userIPcameraAgente,'String',data.agentes(idAgente).config.userIPcamera);
  set(handles.pwdIPcameraAgente,'String',data.agentes(idAgente).config.pwdIPcamera);
  set(handles.topicCameraAgente,'String',data.agentes(idAgente).config.topicCamera);
  set(handles.typeCameraAgente,'String',data.agentes(idAgente).config.typeCamera);
  set(handles.enabledCameraAgente,'Value',data.agentes(idAgente).config.enabledCamera);
  set(handles.rosCameraAgente,'Value',data.agentes(idAgente).config.rosCamera);
  set(handles.nodeSubnetworkAgente,'Value',find(ismember(get(handles.nodeSubnetworkAgente,'String'),data.agentes(idAgente).config.sensorNodes.automatic.subnetwork)));
  set(handles.sensorGroupIDAgente,'String',data.agentes(idAgente).config.sensorNodes.automatic.group);
  set(handles.minUmbralAgente,'Value',data.agentes(idAgente).config.sensorNodes.user.minUmbral);
  if isnan(get(handles.minUmbralAgente,'Value')), set(handles.minUmbralAgente,'String','');
  else, set(handles.minUmbralAgente,'String',num2str(get(handles.minUmbralAgente,'value'))); end
  set(handles.maxUmbralAgente,'Value',data.agentes(idAgente).config.sensorNodes.user.maxUmbral);
  if isnan(get(handles.maxUmbralAgente,'Value')), set(handles.maxUmbralAgente,'String','');
  else, set(handles.maxUmbralAgente,'String',num2str(get(handles.maxUmbralAgente,'value'))); end
  set(handles.ipMQTTAgente,'String',data.agentes(idAgente).config.ipMQTT);
  set(handles.portMQTTAgente,'Value',data.agentes(idAgente).config.portMQTT);
  if ~get(handles.portMQTTAgente,'value'), set(handles.portMQTTAgente,'String','');
  else, set(handles.portMQTTAgente,'String',num2str(get(handles.portMQTTAgente,'value'))); end
  set(handles.statusMQTTAgente,'Value',data.agentes(idAgente).config.statusMQTT);
  switch get(handles.statusMQTTAgente,'value')
   case 1, set(handles.statusMQTTAgente,'Background',[1 1 0]);
   case 2, set(handles.statusMQTTAgente,'Background',[1 0 0]);
   case 3, set(handles.statusMQTTAgente,'Background',[0 .9 0]);
   otherwise, set(handles.statusMQTTAgente,'Background',[1 1 1]);
  end
  set(handles.topicGPSAgente,'String',data.agentes(idAgente).config.topicGPS);
  set(handles.topicCommandAgente,'String',data.agentes(idAgente).config.topicCommand);
  set(handles.topicStatusAgente,'String',data.agentes(idAgente).config.topicStatus);
  set(handles.QoSMQTTAgente,'Value',data.agentes(idAgente).config.QoSMQTT);
  set(handles.enabledMQTTAgente,'Value',data.agentes(idAgente).config.enableMQTT);
  set(handles.GPXfolderAgente,'String',data.agentes(idAgente).config.GPXfolder);
  %%%% set(handles.buttonGPXAgent,'String','');
  set(handles.enabledGPXAgente,'Value',data.agentes(idAgente).config.enableGPX);
  % ----
  set(handles.idFullAgente_ROS,'String',data.agentes(idAgente).config.idFull);
  set(handles.topic1SubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs1);
  set(handles.type1SubsAgente,'String',data.agentes(idAgente).config.ROStypeSubs1);
  set(handles.enabledSubs1Agente,'Value',data.agentes(idAgente).config.enableROSSubs1);
  set(handles.ros1SubsAgente,'Value',data.agentes(idAgente).config.nonROS2Subs1);
  set(handles.nameSpaceAgente,'String',data.agentes(idAgente).config.ROSnameSpace);
  set(handles.topic3aSubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs3a);
  set(handles.topic3bSubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs3b);
  set(handles.topic3cSubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs3c);
  set(handles.type3SubsAgente,'String',data.agentes(idAgente).config.ROStypeSubs3);
  set(handles.enabledSubs3Agente,'Value',data.agentes(idAgente).config.enableROSSubs3);
  set(handles.ros3SubsAgente,'Value',data.agentes(idAgente).config.nonROS2Subs3);
  if isnan(data.agentes(idAgente).config.ROSfreqSubs4)
   set(handles.freq4SubsAgente,'String','');
  else 
   set(handles.freq4SubsAgente,'String',num2str(data.agentes(idAgente).config.ROSfreqSubs4));
  end
  set(handles.topic4SubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs4);
  set(handles.type4SubsAgente,'String',data.agentes(idAgente).config.ROStypeSubs4);
  set(handles.enabledSubs4Agente,'Value',data.agentes(idAgente).config.enableROSSubs4);
  set(handles.ros4SubsAgente,'Value',data.agentes(idAgente).config.nonROS2Subs4);
  set(handles.topic2SubsAgente,'String',data.agentes(idAgente).config.ROStopicSubs2);
  set(handles.type2SubsAgente,'String',data.agentes(idAgente).config.ROStypeSubs2);
  set(handles.enabledSubs2Agente,'Value',data.agentes(idAgente).config.enableROSSubs2);
  set(handles.ros2SubsAgente,'Value',data.agentes(idAgente).config.nonROS2Subs2);
  set(handles.topic1PubAgente,'String',data.agentes(idAgente).config.ROStopicPub1);
  set(handles.type1PubAgente,'String',data.agentes(idAgente).config.ROStypePub1);
  set(handles.enabledPub1Agente,'Value',data.agentes(idAgente).config.enableROSPub1);
  set(handles.ros1PubAgente,'Value',data.agentes(idAgente).config.nonROS2Pub1);
  if isnan(data.agentes(idAgente).config.granularity)
   set(handles.granularity,'String','');
  else
   set(handles.granularity,'String',data.agentes(idAgente).config.granularity);
  end
  % ----
  set(handles.idFullAgente_status,'String',data.agentes(idAgente).config.idFull);
  set(handles.enableAgente,'Value',data.agentes(idAgente).config.enable);
  set(handles.radioUTMAgente_status,'Enable','on');
  set(handles.radioUTMAgente_status,'Value',data.agentes(idAgente).config.unidadPosicion);
  set(handles.radioGEOAgente_status,'Enable','on');
  set(handles.radioGEOAgente_status,'Value',~data.agentes(idAgente).config.unidadPosicion);
  set(handles.posXAgente_status,'Value',data.agentes(idAgente).config.posicion(1));
  set(handles.posYAgente_status,'Value',data.agentes(idAgente).config.posicion(2));
  radioUnitAgente(handles,true);
  set(handles.orientacion_status,'Value',data.agentes(idAgente).config.theta*180/pi);
  if ~isempty(data.agentes(idAgente).config.sensorNodes.automatic.subnetwork) && ...
       isfield(data.agentes(idAgente).config.sensorNodes.automatic,'deveui')
   set(handles.gatewaysIDsAgente_label,'Visible','on');
   set(handles.gatewaysIDsAgente,'Visible','on');
   set(handles.gatewaysIDsAgente,'Value',1);
   set(handles.packetsAgente,'Visible','on');
   set(handles.sensorIDsAgente_label,'Visible','on');
   set(handles.sensorIDsAgente,'Visible','on');
   set(handles.sensorIDsAgente,'Enable','on');
   set(handles.valueSensorsAgente_label,'Visible','on');
   set(handles.valueSensorsAgente,'Visible','on');
   set(handles.enableFreezeAgente,'Visible','on');
   set(handles.enableFreezeAgente,'Enable','on');
   set(handles.valueSensorsAgente,'Enable','on');
   set(handles.FechaAgente_label,'Visible','on');
   set(handles.FechaAgente,'Visible','on');
  else
   set(handles.gatewaysIDsAgente_label,'Visible','off');
   set(handles.gatewaysIDsAgente,'Visible','off');
   set(handles.packetsAgente,'Visible','off');
   set(handles.sensorIDsAgente_label,'Visible','off');
   set(handles.sensorIDsAgente,'Visible','off');
   set(handles.valueSensorsAgente_label,'Visible','off');
   set(handles.valueSensorsAgente,'Visible','off');
   set(handles.enableFreezeAgente,'Visible','off');
   set(handles.FechaAgente_label,'Visible','off');
   set(handles.FechaAgente,'Visible','off');
  end
  updateTableAgente(handles);
  if isnan(data.agentes(idAgente).config.theta), set(handles.orientacion_status,'String','');
  else, set(handles.orientacion_status,'String',num2str(get(handles.orientacion_status,'value'))); end
  set(handles.enableFreezeAgente,'Value',data.agentes(idAgente).config.enableFreeze);
  updateTable(handles,'Agent',false);
 end
 modoPosicionAgente_Callback([],[],handles);  % calling from editAgent auxiliary function
 runCameraAgente(handles);
 runGrafica(handles,'Agent',false);
end

% --- Auxiliary function for previuos one and other functions.
function updateTableAgente(handles)
 updateTable(handles,'Agent',get(handles.enableFreezeAgente,'Value'));
end

% --- Executes on button press in editAgent_button.
function editAgente_button_Callback(~,~, handles)
% can be called from addAgent_button_Callback function
global data
 ClickOnAux2Tab(handles.a22,[],handles);
 set(handles.defaultAgentes,'Enable','inactive');
 set(handles.idAgente,'Enable','inactive');
 set(handles.addAgente_button,'Visible','off');
 set(handles.removeAgente_button,'Visible','off');
 set(handles.editAgente_button,'Visible','off');
 set(handles.idFullAgente,'Enable','on');
 set(handles.visibleAgente,'Enable','on');
 set(handles.longitudX,'Enable','on');
 set(handles.longitudY,'Enable','on');
 set(handles.seguridadAgente,'Enable','on');
 set(handles.COGx,'Enable','on');
 set(handles.COGy,'Enable','on');
 set(handles.COGz,'Enable','on');
 set(handles.rhoTol,'Enable','on');
 set(handles.velocidad,'Enable','on');
 set(handles.coefVelocidadPositiva,'Enable','on');
 set(handles.coefVelocidadNegativa,'Enable','on');
 set(handles.coefVelocidadLateral,'Enable','on');
 %%% set(handles.pendienteMax,'Enable','off');
 %%% set(handles.pendienteMin,'Enable','off');
 %%% set(handles.vuelcoMax,'Enable','off');
 %%% set(handles.vuelcoMin,'Enable','off');
 set(handles.modoPosicionAgente,'Enable','on');
 set(handles.radioUTMAgente,'Enable','on');
 if ~data.entorno.tipo, set(handles.radioGEOAgente,'Enable','on'); end
 radioUnitAgente(handles,false);
 modoPosicionAgente_Callback([],[],handles);  % calling from editAgent_button_Callback function
 set(handles.orientacion,'Enable','on');
 set(handles.radioGiro,'Enable','on');
 set(handles.colorAgente,'Enable','on');
 set(handles.IPcameraAgente,'Enable','on');
 set(handles.enableIPcameraAgente,'Enable','on');
 set(handles.userIPcameraAgente,'Enable','on');
 set(handles.pwdIPcameraAgente,'Enable','on');
 set(handles.topicCameraAgente,'Enable','on');
 set(handles.typeCameraAgente,'Enable','on');
 set(handles.enabledCameraAgente,'Enable','on');
 set(handles.rosCameraAgente,'Enable','on');
 set(handles.nodeSubnetworkAgente,'Enable','on');
 set(handles.sensorGroupIDAgente,'Enable','on');
 set(handles.minUmbralAgente,'Enable','on');
 set(handles.maxUmbralAgente,'Enable','on');
 set(handles.ipMQTTAgente,'Enable','on');
 set(handles.portMQTTAgente,'Enable','on');
 set(handles.topicGPSAgente,'Enable','on');
 set(handles.topicCommandAgente,'Enable','on');
 set(handles.topicStatusAgente,'Enable','on');
 set(handles.QoSMQTTAgente,'Enable','on');
 set(handles.enabledMQTTAgente,'Enable','on');
 set(handles.GPXfolderAgente,'Enable','on');
 set(handles.buttonGPXAgente,'Enable','on');
 set(handles.enabledGPXAgente,'Enable','on');
 %---
 set(handles.topic1SubsAgente,'Enable','on');
 set(handles.type1SubsAgente,'Enable','on');
 set(handles.enabledSubs1Agente,'Enable','on');
 set(handles.ros1SubsAgente,'Enable','on');
 set(handles.nameSpaceAgente,'Enable','on');
 set(handles.topic3aSubsAgente,'Enable','on');
 set(handles.topic3bSubsAgente,'Enable','on');
 set(handles.topic3cSubsAgente,'Enable','on');
 set(handles.type3SubsAgente,'Enable','on');
 set(handles.enabledSubs3Agente,'Enable','on');
 set(handles.ros3SubsAgente,'Enable','on');
 set(handles.freq4SubsAgente,'Enable','on');
 set(handles.topic4SubsAgente,'Enable','on');
 set(handles.type4SubsAgente,'Enable','on');
 set(handles.enabledSubs4Agente,'Enable','on');
 set(handles.ros4SubsAgente,'Enable','on');
 set(handles.topic2SubsAgente,'Enable','on');
 set(handles.type2SubsAgente,'Enable','on');
 set(handles.enabledSubs2Agente,'Enable','on');
 set(handles.ros2SubsAgente,'Enable','on');
 set(handles.topic1PubAgente,'Enable','on');
 set(handles.type1PubAgente,'Enable','on');
 set(handles.enabledPub1Agente,'Enable','on');
 set(handles.ros1PubAgente,'Enable','on');
 set(handles.granularity,'Enable','on');
 %---
 set(handles.enableAgente,'Enable','on');
 set(handles.radioUTMAgente_status,'Enable','on');
 set(handles.radioGEOAgente_status,'Enable','on');
 set(handles.AgenteOK_button,'Visible','on');
 set(handles.AgenteOK_button2,'Visible','on');
 set(handles.AgenteCANCEL_button,'Visible','on');
 set(handles.AgenteCANCEL_button2,'Visible','on');
end

% --- Executes on button press in addAgent_button.
function addAgente_button_Callback(~,~, handles)
global data
 idAgente = get(handles.numAgentes,'Value') + 1;
 set(handles.idAgente,'Value',idAgente);
 set(handles.idAgente,'String',num2str(get(handles.idAgente,'Value')));
 editAgente_button_Callback([],[],handles); editAgente(handles);
 porDefecto = ValoresAgentesPorDefecto(data.entorno);
 if idAgente <= size(porDefecto,1)-1 && get(handles.defaultAgentes,'Value')
  k = idAgente+1;
 else, k = 1;
 end
 if get(handles.defaultAgentes,'Value')
  set(handles.idFullAgente,'String',char(porDefecto(k,1)));
  set(handles.visibleAgente,'Value',0);
  set(handles.sensorGroupIDAgente,'String',char(porDefecto(k,23)));
  set(handles.IPcameraAgente,'String',char(porDefecto(k,24)));
  set(handles.userIPcameraAgente,'String',char(porDefecto(k,25)));
  set(handles.pwdIPcameraAgente,'String',char(porDefecto(k,26)));
  set(handles.topicCameraAgente,'String',char(porDefecto(k,27)));
  set(handles.typeCameraAgente,'String',char(porDefecto(k,28)));
  set(handles.ipMQTTAgente,'String',char(porDefecto(k,29)));
  set(handles.portMQTTAgente,'Value',cell2mat(porDefecto(k,30)));
  if ~cell2mat(porDefecto(k,30)), set(handles.portMQTTAgente,'String','');
  else, set(handles.portMQTTAgente,'String',num2str(get(handles.portMQTTAgente,'value')));
  end
  set(handles.statusMQTTAgente,'Background',[1 1 1]);
  set(handles.topicGPSAgente,'String',char(porDefecto(k,31)));
  set(handles.topicCommandAgente,'String',char(porDefecto(k,32)));
  set(handles.topicStatusAgente,'String',char(porDefecto(k,33)));
  set(handles.QoSMQTTAgente,'Value',cell2mat(porDefecto(k,34)));
  set(handles.enabledMQTTAgente,'Value',0);
  set(handles.GPXfolderAgente,'String',char(porDefecto(k,35)));
  set(handles.enabledGPXAgente,'Value',0);
  porDefectoNum = cell2mat(porDefecto(k,2:22));
  set(handles.longitudX,'Value',porDefectoNum(1));
  set(handles.longitudX,'String',num2str(get(handles.longitudX,'Value')));
  set(handles.longitudY,'Value',porDefectoNum(2));
  set(handles.longitudY,'String',num2str(get(handles.longitudY,'Value')));
  set(handles.seguridadAgente,'Value',porDefectoNum(3));
  set(handles.seguridadAgente,'String',num2str(get(handles.seguridadAgente,'Value')));
  set(handles.COGx,'Value',porDefectoNum(4));
  set(handles.COGx,'String',num2str(get(handles.COGx,'Value')));
  set(handles.COGy,'Value',porDefectoNum(5));
  set(handles.COGy,'String',num2str(get(handles.COGy,'Value')));
  set(handles.COGz,'Value',porDefectoNum(6));
  set(handles.COGz,'String',num2str(get(handles.COGz,'Value')));
  set(handles.rhoTol,'Value',porDefectoNum(7));
  set(handles.rhoTol,'String',num2str(get(handles.rhoTol,'Value')));
  set(handles.velocidad,'Value',porDefectoNum(8));
  set(handles.velocidad,'String',num2str(get(handles.velocidad,'Value')));
  set(handles.coefVelocidadPositiva,'Value',porDefectoNum(9));
  set(handles.coefVelocidadPositiva,'String',num2str(get(handles.coefVelocidadPositiva,'Value')));
  set(handles.coefVelocidadNegativa,'Value',porDefectoNum(10));
  set(handles.coefVelocidadNegativa,'String',num2str(get(handles.coefVelocidadNegativa,'Value')));
  set(handles.coefVelocidadLateral,'Value',porDefectoNum(11));
  set(handles.coefVelocidadLateral,'String',num2str(get(handles.coefVelocidadLateral,'Value')));
  %set(handles.pendienteMax,'Value',porDefectoNum(9));
  %set(handles.pendienteMax,'String',num2str(get(handles.pendienteMax,'Value')));
  %set(handles.pendienteMin,'Value',porDefectoNum(10));
  %set(handles.pendienteMin,'String',num2str(get(handles.pendienteMin,'Value')));
  %set(handles.vuelcoMax,'Value',porDefectoNum(11));
  %set(handles.vuelcoMax,'String',num2str(get(handles.vuelcoMax,'Value')));
  set(handles.posXAgente,'Value',porDefectoNum(14));
  set(handles.posXAgente,'String',num2str(get(handles.posXAgente,'Value')));
  set(handles.posYAgente,'Value',porDefectoNum(15));
  set(handles.posYAgente,'String',num2str(get(handles.posYAgente,'Value')));
  set(handles.orientacion,'Value',porDefectoNum(12));
  if isnan(porDefectoNum(12)), set(handles.orientacion,'String','');
  else, set(handles.orientacion,'String',num2str(get(handles.orientacion,'Value'))); end
  set(handles.radioGiro,'Value',porDefectoNum(13));
  if isnan(porDefectoNum(13)), set(handles.radioGiro,'String','');
  else, set(handles.radioGiro,'String',num2str(get(handles.radioGiro,'Value'))); end
  set(handles.colorAgente,'Data',porDefectoNum(16:18));
  set(handles.nodeSubnetworkAgente,'Value',porDefectoNum(21));
  set(handles.minUmbralAgente,'Value',porDefectoNum(19));
  set(handles.minUmbralAgente,'String',num2str(get(handles.minUmbralAgente,'Value')));
  set(handles.maxUmbralAgente,'Value',porDefectoNum(20));
  set(handles.maxUmbralAgente,'String',num2str(get(handles.maxUmbralAgente,'Value')));
 else
  set(handles.colorAgente,'Data',[0 0 0]);
 end
 %%% set(handles.orientacion_status,'Value',get(handles.orientacion,'Value'));
 %%% set(handles.orientacion_status,'String',get(handles.orientacion,'String'));
 radioUnitAgente(handles,false);
 %---
 set(handles.idFullAgente_ROS,'String',get(handles.idFullAgente,'String'));
 set(handles.topic1SubsAgente,'String',char(porDefecto(k,36)));
 set(handles.type1SubsAgente,'String',char(porDefecto(k,37)));
 if (k==1) set(handles.enabledSubs1Agente,'Value',0);
 else set(handles.enabledSubs1Agente,'Value',1); end
 set(handles.ros1SubsAgente,'Value',0);
 set(handles.nameSpaceAgente,'String',char(porDefecto(k,38)));
 set(handles.topic3aSubsAgente,'String',char(porDefecto(k,40)));
 set(handles.topic3bSubsAgente,'String',char(porDefecto(k,41)));
 set(handles.topic3cSubsAgente,'String',char(porDefecto(k,42)));
 set(handles.type3SubsAgente,'String',char(porDefecto(k,39)));
 set(handles.enabledSubs3Agente,'Value',0);
 set(handles.ros3SubsAgente,'Value',0);
 set(handles.freq4SubsAgente,'Value',cell2mat(porDefecto(k,43)));
 set(handles.freq4SubsAgente,'String',num2str(get(handles.freq4SubsAgente,'Value')));
 set(handles.topic4SubsAgente,'String',char(porDefecto(k,44)));
 set(handles.type4SubsAgente,'String',char(porDefecto(k,45)));
 set(handles.enabledSubs4Agente,'Value',0);
 set(handles.ros4SubsAgente,'Value',0);
 set(handles.topic2SubsAgente,'String',char(porDefecto(k,46)));
 set(handles.type2SubsAgente,'String',char(porDefecto(k,47)));
 if (k==1) set(handles.enabledSubs2Agente,'Value',0);
 else set(handles.enabledSubs2Agente,'Value',1); end
 set(handles.ros2SubsAgente,'Value',0);
 set(handles.topic1PubAgente,'String',char(porDefecto(k,48)));
 set(handles.type1PubAgente,'String',char(porDefecto(k,49)));
 set(handles.enabledPub1Agente,'Value',0);
 set(handles.ros1PubAgente,'Value',0);
 set(handles.granularity,'Value',cell2mat(porDefecto(k,50)));
 if isnan(cell2mat(porDefecto(k,46))), set(handles.granularity,'String','');
 else, set(handles.granularity,'String',num2str(get(handles.granularity,'Value'))); end
 %---
 set(handles.idFullAgente_status,'String',get(handles.idFullAgente,'String'));
 set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
 set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
 radioUnitAgente(handles,true);
 set(handles.enableFreezeAgente,'Value',0);
 data.agentesUpdated = 0;
end

% --- Executes on button press in removeAgent_button.
function removeAgente_button_Callback(~,~, handles)
global data general
 set(handles.enabledRemove,'Value',0);
 enabledRemove_Callback(handles.enabledRemove,[],handles);
 idAgente = get(handles.idAgente,'Value');
 numAgentes = get(handles.numAgentes,'Value')-1;
 set(handles.numAgentes,'Value',numAgentes);
 set(handles.numAgentes,'String',num2str(get(handles.numAgentes,'Value')));
 if ~numAgentes
  set(handles.idAgente,'String','');
  data = rmfield(data,'agentes');
  set(handles.idAgente,'Enable','inactive');
  set(handles.removeAgente_button,'Visible','off');
  set(handles.editAgente_button,'Visible','off');
  set(handles.PLANNER_button,'Enable','off');
  if ~isfield(data,'SensorNodes')
   data.gateways = {};
   aux = get(handles.gatewaysIDsAgente,'String');
   set(handles.gatewaysIDsAgente,'String',aux);
   set(handles.gatewaysIDs,'String',aux);
  end
 else
  data.agentes(idAgente) = [];
 end
 if idAgente > numAgentes && numAgentes
  set(handles.idAgente,'Value',numAgentes);
  set(handles.idAgente,'String',num2str(get(handles.idAgente,'Value')));
 end
 editAgente(handles);
 data.agentesUpdated = 0;
 %if isfield(data,'planner') && isfield(data.planner,'optima'), data.planner = rmfield(data.planner,'optima'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 ClickOnAux2Tab(handles.a21,[],handles);
end

function [porDefecto] = ValoresAgentesPorDefecto(entorno)
 %%% Note: review default values for the 2023 field exercise.
 porDefecto = [];
 if entorno.tipo
  switch entorno.fichero
   %%% Note: review default values for artificial environments.
   case 'Binary environment based on a maze'
    %              fullID     dimX dimY seg  vlim   vn alfa+ alfa- beta   k+  k-  kl  theta  rGiro    lon(utm)    lat(utm)   R   G   B    minRSSI  maxRSSI  subnet   groupID     camaraIP  userIPCamera    pwdIpCamera     topicCamera    typeCamera    ipMQTT               portMQTT  topicGPS        topicCommand        topicStatus        QoS    GPXfolder
    porDefecto = [{''          .4   .5  .45   .5    .5   20   -20    20    0   0   0    180    NaN     2           2         0 .55 .55    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5  .45   .5    .5   20   -20    20    0   0   0    180    NaN     2           2         0 .55 .55    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5  .33   .5    .5   10   -20    10    0   0   0    180    NaN     3          16       .30   0 .51    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5  .33  .65   .65   10   -10    10    0   0   0    180    NaN     8          10       .48 .31 .31    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' }];
   case 'Binary environment with large accesible areas'
    porDefecto = [{''          .4   .5  .7    1     1   15   -12    12    0   0   0      0    NaN     5           5       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5  .7    1     1   15   -12    12    0   0   0      0    NaN     5           5       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 1.4    2     2   15   -12    12    0   0   0    -90    NaN    46          47        .3   0 .51    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' }];
   case {'Environment with large accesible areas and slopes'}
    porDefecto = [{''          .4   .6 .45    2     2   10    -4    15  500 500   0      0    NaN     5          47       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .6 .45    2     2   10    -4    15  500 500   0      0    NaN     5          47       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .6 .55    1     1   15   -15    15    0   0   0    180    NaN    46          36       .30   0 .51    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' }];
   case 'Simulated environment with uneven terrain'
    porDefecto = [{''          .4   .5 .45   .5    .5   20   -20    20    0   0   0     90    NaN     3           2         0 .55 .55    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 .45   .5    .5   20   -20    20    0   0   0     90    NaN     3           2         0 .55 .55    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 .33   .1    .1   10   -10    10    0   0   0     90    NaN     2           1       .30   0 .51    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 .33   .1    .1   10   -10    10    0   0   0     90    NaN     4           1       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' }];
   case 'Very small environment with uneven terrain'
    porDefecto = [{''          .4   .5 .45    1     1   34   -34    17    0   0   0      0    NaN     3           2       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 .45    1     1   34   -34    17    0   0   0      0    NaN     3           2       .65 .18 .18    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' };
                  {''          .4   .5 .45    2     2   34   -34    17    0   0   0    180    NaN     2           1        .3   0 .51    NaN      NaN         1       ''        ''        ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      '' }];
  end
 else
   %              fullID             dimX dimY seg  COGx COGy COGz  rho   vn   k+  k-  kl  theta  rGiro    lon(utm)    lat(utm)   R   G   B    minRSSI  maxRSSI  subnet   groupID     camaraIP                                        userIPCamera    pwdIpCamera     topicCamera    typeCamera   ipMQTT               portMQTT  topicGPS        topicCommand        topicStatus        QoS    GPXfolder        ROSTopic1                                                        nameSpace      ROSTopic3abc      ROSTopic4        ROSTopic2                                            ROSTopicPub      Granularity       X
   porDefecto = [{''       0.62 0.68 0.5  0.00 0.02 0.60  .29  .30    0   0   0    NaN    NaN     NaN         NaN      .0  .0  .0   -110      -70         1       ''        ''                                              ''              ''              ''             ''            ''                   0         ''              ''                  ''                 1      ''               '' ''                                                            '' ''          '' '' ''          NaN '' ''        '' ''                                                '' ''            NaN };
                 {'FV8'    2.00 1.20 2.5  0.00 0.10 0.50  .29  .50  200 200   0    NaN    NaN  367071.298 4064509.890   0   0   1   -110      -70         1       ''        ''               ''              ''              '/FX8/compressed'             'sensor_msgs/CompressedImage'            ''                   0         ''              ''                  ''                 1      ''               '/FX8/fix'  'sensor_msgs/NavSatFix'                   '' ''          '' '' ''          NaN '' ''        '/Anchor1F/wifi_rtt_estimation'  'std_msgs/String'   '' ''     NaN};
                 ];
 end
end

% --- Executes on selection change in idFullAgent.
function idFullAgente_Callback(hObject, ~, handles)
 set(handles.idFullAgente_status,'String',get(hObject,'String'));
 set(handles.idFullAgente_ROS,'String',get(hObject,'String'));
end

% --- Executes on button press in visibleAgent.
function visibleAgente_Callback(~,~,~)
global data
 data.agentesUpdated = 0;
end

% --- Executes on selection change in LongitudeX.
function longitudX_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') <= 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Length of vehicle.';...
           'The value must be greater than zero.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.dimension(1));
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,2)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
end

% --- Executes on selection change in LongitudeY.
function longitudY_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') <= 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Length of vehicle.';...
           'The value must be greater than zero.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.dimension(2));
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,3)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
end

% --- Executes on selection change in Radio.
function seguridadAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 dim = sqrt(get(handles.longitudX,'Value')^2+get(handles.longitudY,'Value')^2)/2;
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < dim
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  prompt = strcat(' (',num2str(dim),' m)');
  warning({'Error: Safety radius.';...
           strcat('The value must be greater than the agent dimensions',prompt,'.')},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.distSeg);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,4)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in cogx.
function COGx_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if abs(get(hObject,'Value')) > get(handles.longitudY,'Value')
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: COG X-coordinate.';...
           'The value must be lower than 2nd supporting polygon dimension.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.COG(1));
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,5)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

function COGy_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if abs(get(hObject,'Value')) > get(handles.longitudX,'Value')
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: COG Y-coordinate.';...
           'The value must be lower than 1st supporting polygon dimension.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.COG(2));
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,6)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

function COGz_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: COG Z-coordinate.';...
           'The value must be greater or equal than zero.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.COG(3));
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,7)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

function rhoTol_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') <= 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Coefficient of tolerance.';...
           'The value must be greater than zero.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.rhoTol);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,8)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in Velocidad.
function velocidad_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') <= 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Reference speed.';...
           'The value must be greater than zero.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.velocidad);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,9)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in coefVelocidadPositiva.
function coefVelocidadPositiva_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -50000 || get(hObject,'Value') > 50000
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Rates of variation speed vs slope.';...
           'The value must be between minus fifty and fifty thousands.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if get(handles.idAgente,'Value') <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadPositiva);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,10)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in coefVelocidadNegativa.
function coefVelocidadNegativa_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -50000 || get(hObject,'Value') > 50000
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Rates of variation speed vs slope.';...
           'The value must be between minus fifty and fifty thousands.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadNegativa);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,11)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end


function coefVelocidadLateral_Callback(hObject, eventdata, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -50000 || get(hObject,'Value') > 50000
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Rates of variation speed vs slope.';...
           'The value must be between minus fifty and fifty thousands.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.tipoAgente.coefVelocidadLateral);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,12)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end


% --- Executes on selection change in modoPosicionAgent.
function modoPosicionAgente_Callback(~,~, handles)
% to manage the button and functionality of changing agent's position mode
% can be called from editAgent, editAgent_button_Callback, addAgent_button_Callback functions
 set(handles.posXAgente,'Enable','inactive');
 set(handles.posYAgente,'Enable','inactive');
 switch get(handles.modoPosicionAgente,'Value')
  case 1 %% Manual
   set(handles.pickAgente_button,'Visible','off');
   if isempty(get(handles.idAgente,'String')), state = 'inactive'; else, state = 'on'; end
   set(handles.posXAgente,'Enable',state);
   set(handles.posYAgente,'Enable',state);
  case 2 %% Pick up
   set(handles.pickAgente_button,'String','Pick');
   set(handles.pickAgente_button,'Visible','on');
   if strcmp(get(handles.editAgente_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickAgente_button,'Enable',state);
  case 3 %% by GPS-RTK topic MQTT
   set(handles.pickAgente_button,'Visible','off');
  case 4 %% by GPS sensor
   set(handles.pickAgente_button,'Visible','off');
  case 5 %% by GPX file
  %%% Note:
   set(handles.pickAgente_button,'String','Update');
   set(handles.pickAgente_button,'Visible','on');
   if strcmp(get(handles.editAgente_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickAgente_button,'Enable',state);
 end
end

% --- Executes on button press in pickAgent_button.
function [punto] = pickAgente_button_Callback(~,~, handles)
% to manage the button for position select by picking in map
%%% Note:
global data
 punto = [];
 switch get(handles.modoPosicionAgente,'Value')
  case 2
   set(handles.radioUTMAgente,'Value',1);
   radioUnitAgente(handles,false);
   axes(handles.figura);
   punto = PuntoInsercion(data.entorno,ginput(1));
   set(handles.posXAgente,'Value',punto(1));
   set(handles.posXAgente,'String',num2str(get(handles.posXAgente,'Value')));
   set(handles.posYAgente,'Value',punto(2));
   set(handles.posYAgente,'String',num2str(get(handles.posYAgente,'Value')));
   posXAgente_Callback(handles.posXAgente,[],handles);
   posYAgente_Callback(handles.posYAgente,[],handles);
   radioUnitAgente(handles,false);
 end  
 data.agentesUpdated = 0;
end

% --- Executes when selected object is changed in radioUnitAgent.
function radioUnitAgente_SelectionChangedFcn(~,~, handles)
 radioUnitAgente(handles,false);
end

% --- Executes when selected object is changed in radioUnitAgent.
function radioUnitAgente_status_SelectionChangedFcn(~,~, handles)
 radioUnitAgente(handles,true);
end

% --- Auxiliary function for two previous ones --- *
function radioUnitAgente(handles,status)
% to manage the change of physical unit for positions coordinates
% status  - boolean: indicating use of status (true) or settings (false) tag
global data
 if ~status
  radioUTM = handles.radioUTMAgente; radioGEO = handles.radioGEOAgente;
  posX = handles.posXAgente; unitX = handles.unitX_agente;
  posY = handles.posYAgente; unitY = handles.unitY_agente;
  warnPos = handles.warnPosAgente;
 else
  radioUTM = handles.radioUTMAgente_status; radioGEO = handles.radioGEOAgente_status;
  posX = handles.posXAgente_status; unitX = handles.unitX_agente_status;
  posY = handles.posYAgente_status; unitY = handles.unitY_agente_status;
  warnPos = handles.warnPosAgente_status;
 end
 if get(radioUTM,'Value')
  pos = get(posX,'Position'); pos(3)=130;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 408; pos(3)=10;
  set(unitX,'Position',pos);
  set(unitX,'String',',');
  pos = get(posY,'Position'); pos(1) = 421; pos(3)=130;
  set(posY,'Position',pos);
  set(unitY,'String','meter');
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%16.3f",get(posX,'Value')));
   set(posY,'String',sprintf("%16.3f",get(posY,'Value')));
  else
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 if get(radioGEO,'Value')
  pos = get(posX,'Position'); pos(3)=105;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 381; pos(3)=50;
  set(unitX,'Position',pos);
  set(unitX,'String',[char(176),'North']);
  pos = get(posY,'Position'); pos(1) = 446; pos(3)=105;
  set(posY,'Position',pos);
  set(unitY,'String',[char(176),'East']);
  X = get(posX,'Value'); Y = get(posY,'Value');
  punto = round(GPSutm2ll(X,Y,30),8);
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%10.8f",point(1)));
   set(posY,'String',sprintf("%10.8f",point(2)));
  else
   set(warnPos,'Visible','on');
   set(handles.enableAgente,'Value',0);
   set(handles.enableAgente,'Enable','off');
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
 minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
 valX = get(posX,'Value'); valY = get(posY,'Value');
 if isempty(get(posX,'String')) && isempty(get(posY,'String'))
  set(warnPos,'Visible','on');
  set(handles.enableAgente,'Value',0);
  set(handles.enableAgente,'Enable','off');
 elseif valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
  set(warnPos,'Visible','on');
  set(handles.enableAgente,'Value',0);
  set(handles.enableAgente,'Enable','off');
 else
  set(warnPos,'Visible','off');
  set(handles.enableAgente,'Enable','on');
 end
end

% --- Executes on selection change in posXAgent.
function posXAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 if get(handles.radioUTMAgente,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(hObject,'String')),...
                          str2double(get(handles.posYAgente,'String')),30),...
                8);
  set(hObject,'Value',punto(1));
  set(handles.posYAgente,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN);
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(hObject,'Value'); valY = get(handles.posYAgente,'Value');
  if valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
   set(hObject,'Enable','off');
   set(handles.AgenteOK_button,'Visible','off');
   set(handles.AgenteOK_button2,'Visible','off');
   set(handles.AgenteCANCEL_button,'Visible','off');
   set(handles.AgenteCANCEL_button2,'Visible','off');
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates.';...
            'The value must belong to the environmental dimensions';prompt},...
            hObject,handles);
   waitfor(handles.warning,'Visible','off');
   if idAgente <= get(handles.numAgentes,'Value')
    set(hObject,'Value',data.agentes(idAgente).config.posicion(1));
    set(handles.posYAgente,'Value',data.agentes(idAgente).config.posicion(2));
   else
    k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
    set(hObject,'Value',cell2mat(porDefecto(k,15)));
    set(handles.posYAgente,'Value',cell2mat(porDefecto(k,16)));
   end
   radioUnitAgente(handles,false);
   set(handles.AgenteOK_button,'Visible','on');
   set(handles.AgenteOK_button2,'Visible','on');
   set(handles.AgenteCANCEL_button,'Visible','on');
   set(handles.AgenteCANCEL_button2,'Visible','on');
   set(hObject,'Enable','on'); uicontrol(hObject);
  end
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in posYAgent.
function posYAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 if get(handles.radioUTMAgente,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(handles.posXAgente,'String')),...
                          str2double(get(hObject,'String')),30),...
                8);
  set(handles.posXAgente,'Value',punto(1));
  set(hObject,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN);
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(handles.posXAgente,'Value'); valY = get(hObject,'Value');
  if valY < minimoY || valY > maximoY || valX < minimoX || valX > maximoX
   set(hObject,'Enable','off');
   set(handles.AgenteOK_button,'Visible','off');
   set(handles.AgenteOK_button2,'Visible','off');
   set(handles.AgenteCANCEL_button,'Visible','off');
   set(handles.AgenteCANCEL_button2,'Visible','off');
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates.';...
            'The value must belong to the environmental dimensions';prompt},...
            hObject,handles);
   waitfor(handles.warning,'Visible','off');
   if idAgente <= get(handles.numAgentes,'Value')
    set(handles.posXAgente,'Value',data.agentes(idAgente).config.posicion(1));
    set(hObject,'Value',data.agentes(idAgente).config.posicion(2));
   else
    k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
    set(handles.posXAgente,'Value',cell2mat(porDefecto(k,15)));
    set(hObject,'Value',cell2mat(porDefecto(k,16)));
   end
   radioUnitAgente(handles,false);
   set(handles.AgenteOK_button,'Visible','on');
   set(handles.AgenteOK_button2,'Visible','on');
   set(handles.AgenteCANCEL_button,'Visible','on');
   set(handles.AgenteCANCEL_button2,'Visible','on');
   set(hObject,'Enable','on'); uicontrol(hObject);
  end
 end
 data.agentesUpdated = 0;
end

% --- Executes on selection change in Orientacion.
function orientacion_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -180 || get(hObject,'Value') > 180
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Agent orientation.';...
           'The value must be between menus and plus a hundred and eighty grades.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.theta);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,13)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 set(handles.orientacion_status,'Value',get(hObject,'Value'));
 set(handles.orientacion_status,'String',num2str(get(handles.orientacion_status,'Value')));
 data.agentesUpdated = 0;
end

% --- Executes on selection change in RadioGiro.
function radioGiro_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 if isempty(get(hObject,'String')), set(hObject,'Value',NaN);
 else, set(hObject,'Value',str2double(get(hObject,'String'))); end
 if get(hObject,'Value') < 0
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Agent minimum turn radius.';...
           'The value must be greater than zero meters.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.radioGiro);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,14)));
  end
  if isnan(get(hObject,'Value')), set(hObject,'String','');
  else, set(hObject,'String',num2str(get(hObject,'Value'))); end
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.agentesUpdated = 0;
end

% --- Executes during object creation, after setting all properties in colorAgent.
function colorAgente_CreateFcn(hObject, ~, handles)
%%% Note:
% jtable = findjobj(hObject);
% policy = javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_NEVER;
% set(jtable,'VerticalScrollBarPolicy',policy);
end

% --- Executes when entered data in editable cell(s) in colorAgent.
function colorAgente_CellEditCallback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 RGB = get(hObject,'Data');
 if sum(RGB<[0 0 0]) || sum(RGB>[1 1 1])
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Visualization RGB color.';...
           strcat('The value must be between zero and one.')},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Data',data.agentes(idAgente).config.tipoAgente.color);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Data',cell2mat(porDefecto(k,17:19)));
  end
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uitable(hObject);
 end
 uitable(hObject);
 hObject.Data = [hObject.Data; [0 0 0]]; hObject.Data(end,:) = [];
 data.agentesUpdated = 0;
 %%% Note: the last consulted table cell remains selected.
 % aux = get(handles.colorAgent,'Data');
 % set(handles.colorAgent,'Data',[aux,0]); set(handles.colorAgent,'Data',aux);
end

function IPcameraAgente_Callback(~,~, handles)
 set(handles.enableIPcameraAgente,'Value',0);
 if isempty(get(handles.IPcameraAgente,'String'))
  set(handles.enableIPcameraAgente,'Enable','inactive');
 else
  set(handles.enableIPcameraAgente,'Enable','on');
 end
end

% --- Executes on button press in enableIPcameraAgent.
function runCameraAgente(handles)
% to view the video and (indirectly) the graphs of the requested agent with a given identification number or null
% can be called from editAgent function
global data cam pv
 cla(handles.camara);
 if isgraphics(pv), set(pv.Parent,'Position',zeros(1,4)); end
 set(handles.camera_button,'Visible','off');
 set(handles.camera_status,'Visible','off');
 cla(handles.graficoAgente); legend(handles.graficoAgente,'off');
 set(handles.graficoAgente,'Visible','off');
 cla(handles.graficoAuxAgente); legend(handles.graficoAuxAgente,'off');
 set(handles.graficoAuxAgente,'Visible','off');
 % ----
 set(handles.Fisiologic_chart1,'Visible','off');
 legend(handles.Fisiologic_chart1,'off');
 handles.Fisiologic_chart1.XAxis.Visible = 'off';
 cla(handles.Fisiologic_chart1);
 set(handles.Fisiologic_chart2,'Visible','off');
 legend(handles.Fisiologic_chart2,'off');
 handles.Fisiologic_chart2.XAxis.Visible = 'off';
 cla(handles.Fisiologic_chart2);
 set(handles.Fisiologic_chart3,'Visible','off');
 legend(handles.Fisiologic_chart3,'off');
 handles.Fisiologic_chart3.XAxis.Visible = 'off';
 cla(handles.Fisiologic_chart3);
 set(handles.Fisiologic_chart4,'Visible','off');
 legend(handles.Fisiologic_chart4,'off');
 handles.Fisiologic_chart4.XAxis.Visible = 'off';
 cla(handles.Fisiologic_chart4);
 % ----
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enableIPcameraAgente,'Value') && ~isfield(data.agentes(idAgente).config.ROS,'Camera')
  set(handles.camera_button,'String','    IP Camera');
  url = get(handles.IPcameraAgente,'String');
  userName = get(handles.userIPcameraAgente,'String');
  password = get(handles.pwdIPcameraAgente,'String');
  try
   set(handles.statusIPcameraAgente,'Background',[1 1 0]);
   set(handles.statusIPcameraAgente_status,'Visible','on');
   set(handles.statusIPcameraAgente_status,'Background',[1 1 0]);
   set(handles.statusIPcameraAgente_status,'Foreground',[0 0 0]);
   set(handles.statusIPcameraAgente_status,'String','  connecting to IP camera...');
   if ~isempty(userName), cam = ipcam(url,userName,password);
   else, cam = ipcam(url);
   end
   pv = preview(cam);
   set(handles.statusIPcameraAgente,'Background',[0 .9 0]);
   set(handles.statusIPcameraAgente_status,'Visible','off');
   pvparent = get(pv,'Parent');
   pvfig = ancestor(pvparent,'figure');
   set(pvfig,'Visible','off');
   axes(handles.camara); imshow(pv.CData);
   set(pv,'Parent',handles.camara,'Visible','on');
   set(handles.camera_button,'Visible','on');
   set(handles.camera_button,'Enable','on');
   set(handles.camera_status,'Visible','on');
  catch
   set(handles.statusIPcameraAgente,'Background',[1 0 0]);
   set(handles.statusIPcameraAgente_status,'Background',[1 0 0]);
   set(handles.statusIPcameraAgente_status,'Foreground',[1 1 1]);
   set(handles.statusIPcameraAgente_status,'String','  IP camera connection error');
   if isfield(data.agentes(idAgente).config.sensorNodes.automatic,'enablePlot') && ...
      ( sum(data.agentes(idAgente).config.sensorNodes.automatic.enableRSSIPlot) || ...
        sum(data.agentes(idAgente).config.sensorNodes.automatic.enablePlot) )
    set(handles.graficoAgente,'Visible','on');
    set(handles.graficoAgente.Children,'Visible','on');
    legend(handles.graficoAgente,'Location','best');
   end
  end
 else
  set(handles.statusIPcameraAgente,'Background',[1 1 1]);
  set(handles.statusIPcameraAgente_status,'Visible','off');
  clear -global cam pv
 end
 camera_button_Callback([],[],handles);
 if isfield(data,'agentes') && idAgente > 0 && idAgente <= length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Camera')
  set(handles.camera_button,'String','    ROS Camera');
  cla(handles.camara);
  set(handles.camera_button,'Visible','on');
  set(handles.camera_button,'Enable','on');
 end
end

% --- Auxiliary function for previous one and another funtions.
function runGraficaAgente(handles)
 runGrafica(handles,'Agent',get(handles.enableFreezeAgente,'Value'));
end

% --- Executes on button press in camera_button.
function camera_button_Callback(~,~, handles)
% to change between camera image and graphs (this button is only visible with an IP camera has been enabled)
global data pv
 if strcmp(get(handles.camera_button,'Visible'),'on')
  if strcmp(get(handles.camera_status,'Visible'),'on')
   idAgente = get(handles.idAgente,'Value');
   set(handles.camera_status,'Visible','off');
   if isgraphics(pv), set(pv.Parent,'Position',zeros(1,4));
   else, set(handles.camara,'Position',zeros(1,4)); end
   % if isfield(data,'agents') && idAgent > 0 && isfield(data.agents(idAgent).config.sensorNodes.automatic,'enablePlot') && ...
   if isfield(data.agentes(idAgente).config,'sensorNodes') && ...
      ( sum(data.agentes(idAgente).config.sensorNodes.automatic.enableRSSIPlot) || ...
        sum(data.agentes(idAgente).config.sensorNodes.automatic.enableBatteryPlot) || ...
        sum(data.agentes(idAgente).config.sensorNodes.automatic.enablePlot) )
    runGraficaAgente(handles);
   end
  else
   grafico = handles.graficoAgente;
   graficoAux = handles.graficoAuxAgente;
   set(grafico,'Visible','off');
   legend(grafico,'off');
   grafico.XAxis.Visible = 'off';
   set(grafico.Children,'Visible','off');
   set(graficoAux,'Visible','off');
   legend(graficoAux,'off');
   set(graficoAux.Children,'Visible','off');
   set(handles.camera_status,'Visible','on');
   if isgraphics(pv), set(pv.Parent,'Position',get(handles.camera_button,'UserData'));
   else, set(handles.camara,'Position',get(handles.camera_button,'UserData')); end
  end
 end
end

% --- Executes on selection change in gatewaysIDsAgent.
function gatewaysIDsAgente_Callback(~,~, handles)
 updateTable(handles,'Agent',false);
 runGrafica(handles,'Agent',false);
end

% --- Executes when entered data in editable cell(s) in sensorIDsAgent.
function sensorIDsAgente_CellEditCallback(~,~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 TABLA = get(handles.sensorIDsAgente,'Data');
 for i = 1:size(TABLA,1)
  data.agentes(idAgente).config.sensorNodes.automatic.enableFilter(i) = TABLA{i,2};    
  data.agentes(idAgente).config.sensorNodes.automatic.enableRSSIPlot(i) = TABLA{i,6};
  data.agentes(idAgente).config.sensorNodes.automatic.enableBatteryPlot(i) = TABLA{i,8};
 end
 updateTable(handles,'Agent',false);
 runGrafica(handles,'Agent',false);
end

% --- Executes when entered data in editable cell(s) in valueSensorsAgent.
function valueSensorsAgente_CellEditCallback(~,~, handles)
global data general LoRa %%% Zigbee
 idAgente = get(handles.idAgente,'Value');
 TABLA = get(handles.valueSensorsAgente,'Data');
 for i = 1:size(TABLA,1)
  for j = 1:length(LoRa.keys)
   if strcmp(LoRa.keys{j}(5),TABLA{i,1})
    data.agentes(idAgente).config.sensorNodes.automatic.enablePlot(j) = TABLA{i,4};
    data.agentes(idAgente).config.sensorNodes.automatic.enableMap(j) = TABLA{i,5};
   end
  end
 end
 runGrafica(handles,'Agent',false);
 general.updated = true;
end

% --- Executes on button press in enableFreezeAgent.
function enableFreezeAgente_Callback(~,~, handles)
global data
 if isfield(data,'agentes')
  idAgente = get(handles.idAgente,'Value');
  if idAgente <= length(data.agentes)
   if isfield(data.agentes(idAgente).config,'sensorNodes')
    data.agentes(idAgente).config.enableFreeze = get(handles.enableFreezeAgente,'Value');
    % data.agentsUpdated = 1;
   end
  end
 end
end

function sensorGroupIDAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 groupID = get(hObject,'String');
 if ~isempty(groupID) && ~(groupID(1)=='E' && length(groupID) == 4)
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Sensor sub-network Group ID.';...
           'The value must begin with "E" and format "EXXX".'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'String',data.agentes(idAgente).config.sensorNodes.automatic.group);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'String',char(porDefecto(k,23)));
  end
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 % data.agentsUpdated = 0;
end

function minUmbralAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') > get(handles.maxUmbralAgente,'Value')
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Wireless signal strength threshold.';...
           'The minimum threshold must be lower or equal than the maximum one.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.sensorNodes.user.minUmbral);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,20)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 % data.agentsUpdated = 0;
end

function maxUmbralAgente_Callback(hObject, ~, handles)
global data
 idAgente = get(handles.idAgente,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') < get(handles.minUmbralAgente,'Value')
  set(hObject,'Enable','off');
  set(handles.AgenteOK_button,'Visible','off');
  set(handles.AgenteOK_button2,'Visible','off');
  set(handles.AgenteCANCEL_button,'Visible','off');
  set(handles.AgenteCANCEL_button2,'Visible','off');
  warning({'Error: Wireless signal strength threshold.';...
           'The minimum threshold must be lower or equal than the maximum one.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  if idAgente <= get(handles.numAgentes,'Value')
   set(hObject,'Value',data.agentes(idAgente).config.sensorNodes.user.minUmbral);
  else
   k = 1; porDefecto = ValoresAgentesPorDefecto(data.entorno.tipo);
   set(hObject,'Value',cell2mat(porDefecto(k,21)));
  end
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.AgenteOK_button,'Visible','on');
  set(handles.AgenteOK_button2,'Visible','on');
  set(handles.AgenteCANCEL_button,'Visible','on');
  set(handles.AgenteCANCEL_button2,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 % data.agentsUpdated = 0;
end

% --- Executes on button press in enabledTTS.
function enabledMQTTAgente(handles)
global data
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledMQTTAgente,'Value') == 1 && ~isempty(get(handles.ipMQTTAgente,'String'))
  set(handles.modoPosicionAgente,'Value',3);
  set(handles.ipMQTTAgente,'Enable','inactive');
  set(handles.portMQTTAgente,'Enable','inactive');
  set(handles.topicGPSAgente,'Enable','inactive');
  set(handles.topicCommandAgente,'Enable','inactive');
  set(handles.topicStatusAgente,'Enable','inactive');
  set(handles.QoSMQTTAgente,'Enable','inactive');
  host = ['tcp://',get(handles.ipMQTTAgente,'String')];
  if isnan(str2double(get(handles.portMQTTAgente,'String'))), port = 1883;
  else, port = str2double(get(handles.portMQTTAgente,'String'));
  end
  if ~isempty(get(handles.ipMQTTAgente,'String'))
   try
    set(handles.statusMQTTAgente,'Background',[1 1 0]); drawnow
    data.agentes(idAgente).MQTT.broker = mqttClient(host,'Port',port);
    set(handles.statusMQTTAgente,'Background',[0 .9 0]);
    try
     if get(handles.QoSMQTTAgente,'Value')==1, QoS = 0;
     else QoS = get(handles.QoSMQTTAgente,'Value')-2;
     end
     topic = get(handles.topicGPSAgente,'String');
     if ~isempty(topic)
      data.agentes(idAgente).MQTT.subs1 = subscribe(data.agentes(idAgente).MQTT.broker,char(topic),'QualityOfService',QoS);
      data.agentes(idAgente).MQTT.subs1.Callback = @(topic,msg)receiveMQTT(topic,msg,handles);
     end
     topic = get(handles.topicStatusAgente,'String');
     if ~isempty(topic)
      data.agentes(idAgente).MQTT.subs2 = subscribe(data.agentes(idAgente).MQTT.broker,char(topic),'QualityOfService',QoS);
      data.agentes(idAgente).MQTT.subs1.Callback = @(topic,msg)receiveMQTT(topic,msg,handles);
     end
    catch
     set(handles.enabledMQTTAgente,'Value',0)
     set(handles.modoPosicionAgente,'Value',1);
     set(handles.statusMQTTAgente,'Background',[1 0 0]);
    end
   catch
    set(handles.enabledMQTTAgente,'Value',0)
    set(handles.modoPosicionAgente,'Value',1);
    set(handles.statusMQTTAgente,'Background',[1 0 0]);
   end
  end
 else
  if get(handles.modoPosicionAgente,'Value')==3, set(handles.modoPosicionAgente,'Value',1); end
  set(handles.enabledMQTTAgente,'Value',0)
  set(handles.ipMQTTAgente,'Enable','on');
  set(handles.portMQTTAgente,'Enable','on');
  set(handles.topicGPSAgente,'Enable','on');
  set(handles.topicCommandAgente,'Enable','on');
  set(handles.topicStatusAgente,'Enable','on');
  set(handles.QoSMQTTAgente,'Enable','on');
  if ~isempty(get(handles.ipMQTTAgente,'String'))
   try
    if isfield(data.agentes(idAgente).MQTT,'subs1'), unsubscribe(data.agentes(idAgente).MQTT.subs1); end
    if isfield(data.agentes(idAgente).MQTT,'subs2'), unsubscribe(data.agentes(idAgente).MQTT.subs2); end
    data.agentes(idAgente).MQTT.broker.disconnect
    if isfield(data.agentes(idAgente).MQTT,'subs1'), data.agentes(idAgente).MQTT.subs1.delete; end
    if isfield(data.agentes(idAgente).MQTT,'subs2'), data.agentes(idAgente).MQTT.subs2.delete; end
    data.agentes(idAgente).MQTT.broker.delete
   catch
   end
  end
  set(handles.statusMQTTAgente,'Background',[1 1 1]);
  if isfield(data.agentes(idAgente),'MQTT') && isfield(data.agentes(idAgente).MQTT,'broker'), data.agentes(idAgente).MQTT = rmfield(data.agentes(idAgente).MQTT,'broker'); end
  if isfield(data.agentes(idAgente),'MQTT') && isfield(data.agentes(idAgente).MQTT,'subs1'), data.agentes(idAgente).MQTT = rmfield(data.agentes(idAgente).MQTT,'subs1'); end
 end
end

% --- Executes on button press in buttonGPXAgent.
function buttonGPXAgente_Callback(~,~, handles)
 %%% Note:
 GPXfolder = get(handles.GPXfolderAgente,'String');
 GPXfolder = uigetdir(GPXfolder,'Pick a folder');
 if GPXfolder
  i = strfind(GPXfolder,'SAR-FIS v4.0a');
  if i
   j = strfind(GPXfolder(i:end),'/');
   GPXfolder = strcat('./',GPXfolder(i+j:end));
  end
 else
  GPXfolder = './GPX files';
 end
 set(handles.GPXfolderAgente,'String',GPXfolder);
end

% --- Executes on button press in enabledGPXAgent.
function enabledGPXAgente_Callback(~,~, handles)
global data
 data.agentesUpdated = 0;
end

% --- Executes on button press in enabledSubs4Agent.
function enabledCameraAgente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 topic = get(handles.topicCameraAgente,'String');
 typeMsg = get(handles.typeCameraAgente,'String');
 if ~isempty(topic) && ~isempty(typeMsg) && ...
     (get(handles.enabledCameraAgente,'Value') && (get(handles.rosCameraAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.rosCameraAgente,'Value') && get(handles.enabledROS2,'Value')))
  if get(handles.rosCameraAgente,'Value')
   data.agentes(idAgente).config.ROS.Camera = rossubscriber(topic,typeMsg);
   data.agentes(idAgente).config.ROS.Camera.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
  else
   data.agentes(idAgente).config.ROS.Camera = ros2subscriber(ROS.SARFISnode,topic,typeMsg,'Reliability','besteffort');
   data.agentes(idAgente).config.ROS.Camera.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
  end
 else
  set(handles.enabledCameraAgente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Camera')
   %data.agents(idAgent).config.ROS.Camera.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Camera;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Camera');
  end
  set(handles.camera_button,'Visible','off');
  set(handles.camera_button,'Enable','off');
  set(handles.camera_status,'Visible','off');
  axes(handles.camara); cla;
 end
end

% --- Executes on button press in enabledSubs1Agent.
function enabledSubs1Agente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledSubs1Agente,'Value') && (get(handles.ros1SubsAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.ros1SubsAgente,'Value') && get(handles.enabledROS2,'Value'))
  topic = get(handles.topic1SubsAgente,'String');
  typeMsg = get(handles.type1SubsAgente,'String');
  if get(handles.ros1SubsAgente,'Value')
   data.agentes(idAgente).config.ROS.Sub1 = rossubscriber(topic,typeMsg);
   data.agentes(idAgente).config.ROS.Sub1.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
  else
   data.agentes(idAgente).config.ROS.Sub1 = ros2subscriber(ROS.SARFISnode,topic,typeMsg,'Reliability','besteffort');
   data.agentes(idAgente).config.ROS.Sub1.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
  end
 else
  set(handles.enabledSubs1Agente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub1')
   %data.agents(idAgent).config.ROS.Sub1.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub1;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub1');
  end
 end
end

% --- Executes on button press in enabledSubs2Agent.
function enabledSubs2Agente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledSubs2Agente,'Value') && (get(handles.ros2SubsAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.ros2SubsAgente,'Value') && get(handles.enabledROS2,'Value'))
  topic = get(handles.topic2SubsAgente,'String');
  typeMsg = get(handles.type2SubsAgente,'String');
  if get(handles.ros2SubsAgente,'Value')
   data.agentes(idAgente).config.ROS.Sub2 = rossubscriber(topic,typeMsg);
   data.agentes(idAgente).config.ROS.Sub2.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
  else
   data.agentes(idAgente).config.ROS.Sub2 = ros2subscriber(ROS.SARFISnode,topic,typeMsg,'Reliability','besteffort');
   data.agentes(idAgente).config.ROS.Sub2.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
  end
 else
  set(handles.enabledSubs2Agente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub2')
   %data.agents(idAgent).config.ROS.Sub2.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub2;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub2');
  end
 end
end

% --- Executes on button press in enabledSubs3Agent.
function enabledSubs3Agente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledSubs3Agente,'Value') && (get(handles.ros3SubsAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.ros3SubsAgente,'Value') && get(handles.enabledROS2,'Value'))
  nameSpace = get(handles.nameSpaceAgente,'String');
  if ~isempty(nameSpace) 
   if ~isempty(get(handles.topic3aSubsAgente,'String')), topicA = [nameSpace,get(handles.topic3aSubsAgente,'String')]; end
   if ~isempty(get(handles.topic3bSubsAgente,'String')), topicB = [nameSpace,get(handles.topic3bSubsAgente,'String')]; end
   if ~isempty(get(handles.topic3cSubsAgente,'String')), topicC = [nameSpace,get(handles.topic3cSubsAgente,'String')]; end
   typeMsg = get(handles.type3SubsAgente,'String');
   if get(handles.ros2SubsAgente,'Value')
    if ~isempty(topicA)
     data.agentes(idAgente).config.ROS.Sub3a = rossubscriber(topicA,typeMsg);
     data.agentes(idAgente).config.ROS.Sub3a.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
    end
    if ~isempty(topicB)
     data.agentes(idAgente).config.ROS.Sub3b = rossubscriber(topicB,typeMsg);
     data.agentes(idAgente).config.ROS.Sub3b.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
    end
    if ~isempty(topicC)
     data.agentes(idAgente).config.ROS.Sub3c = rossubscriber(topicC,typeMsg);
     data.agentes(idAgente).config.ROS.Sub3c.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
    end
   else
    if ~isempty(topicA)
     data.agentes(idAgente).config.ROS.Sub3a = ros2subscriber(ROS.SARFISnode,topicA,typeMsg,'Reliability','besteffort');
     data.agentes(idAgente).config.ROS.Sub3a.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
    end
    if ~isempty(topicB)
     data.agentes(idAgente).config.ROS.Sub3b = ros2subscriber(ROS.SARFISnode,topicB,typeMsg,'Reliability','besteffort');
     data.agentes(idAgente).config.ROS.Sub3b.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
    end
    if ~isempty(topicC)
     data.agentes(idAgente).config.ROS.Sub3c = ros2subscriber(ROS.SARFISnode,topicC,typeMsg,'Reliability','besteffort');
     data.agentes(idAgente).config.ROS.Sub3c.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
    end
   end
  end
 else
  set(handles.enabledSubs3Agente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub3a')
   %data.agents(idAgent).config.ROS.Sub3.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub3a;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub3a');
  end
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub3b')
   %data.agents(idAgent).config.ROS.Sub3.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub3b;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub3b');
  end
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub3c')
   %data.agents(idAgent).config.ROS.Sub3.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub3c;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub3c');
  end
 end
end

% --- Executes on button press in enabledSubs4Agent.
function enabledSubs4Agente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledSubs4Agente,'Value') && (get(handles.ros4SubsAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.ros4SubsAgente,'Value') && get(handles.enabledROS2,'Value'))
  topic = get(handles.topic4SubsAgente,'String');
  typeMsg = get(handles.type4SubsAgente,'String');
  if get(handles.ros4SubsAgente,'Value')
   data.agentes(idAgente).config.ROS.Sub4 = rossubscriber(topic,typeMsg);
   data.agentes(idAgente).config.ROS.Sub4.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,idAgente,handles);
  else
   data.agentes(idAgente).config.ROS.Sub4 = ros2subscriber(ROS.SARFISnode,topic,typeMsg,'Reliability','besteffort');
   data.agentes(idAgente).config.ROS.Sub4.NewMessageFcn = @(msg)receiveROS2(topic,msg,idAgente,handles);
  end
 else
  set(handles.enabledSubs4Agente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Sub4')
   %data.agents(idAgent).config.ROS.Sub4.NewMessageFcn = '';
   clear data.agentes(idAgente).config.ROS.Sub4;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Sub4');
  end
 end
end

% --- Executes on button press in enabledPub1Agent.
function enabledPub1Agente(handles)
global data ROS
 idAgente = get(handles.idAgente,'Value');
 if get(handles.enabledPub1Agente,'Value') && (get(handles.ros1PubAgente,'Value') && get(handles.statusROS,'Value') || ~get(handles.ros1PubAgente,'Value') && get(handles.enabledROS2,'Value'))
  topic = get(handles.topic1PubAgente,'String');
  typeMsg = get(handles.type1PubAgente,'String');
  if get(handles.ros1PubAgente,'Value')
   data.agentes(idAgente).config.ROS.Pub1 = rospublisher(topic,typeMsg,'IsLatching',false);
  else
   data.agentes(idAgente).config.ROS.Pub1 = ros2publisher(ROS.SARFISnode,topic,typeMsg);
  end
 else
  set(handles.enabledPub1Agente,'Value',0);
  if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config.ROS,'Pub1')
   clear data.agentes(idAgente).config.ROS.Pub1;
   data.agentes(idAgente).config.ROS = rmfield(data.agentes(idAgente).config.ROS,'Pub1');
  end
 end 
end

% --- Executes on button press in AgentOK_button.
function AgenteOK_button_Callback(~,~, handles)
global data general LoRa
 set(handles.defaultAgentes,'Enable','on');
 set(handles.AgenteOK_button,'Visible','off');
 set(handles.AgenteOK_button2,'Visible','off');
 set(handles.AgenteCANCEL_button,'Visible','off');
 set(handles.AgenteCANCEL_button2,'Visible','off');
 drawnow
 dimX                   = get(handles.longitudX,'Value');
 dimY                   = get(handles.longitudY,'Value');
 distSeg                = get(handles.seguridadAgente,'Value');
 COGx                   = get(handles.COGx,'Value');
 COGy                   = get(handles.COGy,'Value');
 COGz                   = get(handles.COGz,'Value');
 rhoTol                 = get(handles.rhoTol,'Value');
 velocidad              = get(handles.velocidad,'Value');
 coefVelocidadPositiva  = get(handles.coefVelocidadPositiva,'Value');
 coefVelocidadNegativa  = get(handles.coefVelocidadNegativa,'Value');
 coefVelocidadLateral   = get(handles.coefVelocidadLateral,'Value');
 %pendienteMax           = get(handles.pendienteMax,'Value');
 %pendienteMin           = get(handles.pendienteMin,'Value');
 %vuelcoMax              = get(handles.vuelcoMax,'Value');
 %vuelcoMin              = get(handles.vuelcoMin,'Value');
 tipoAgente             = AgenteDefinir(dimX,dimY,distSeg,...
                                        COGx,COGy,COGz,rhoTol,...
                                        velocidad,coefVelocidadPositiva,coefVelocidadNegativa,coefVelocidadLateral);
 set(handles.pendienteMax,'String',num2str(tipoAgente.vRef_LUT.theta_threshold(2)*180/pi));
 set(handles.pendienteMin,'String',num2str(tipoAgente.vRef_LUT.theta_threshold(1)*180/pi));
 set(handles.vuelcoMax,'String',num2str(tipoAgente.vRef_LUT.phi_threshold(2)*180/pi));
 set(handles.vuelcoMin,'String',num2str(tipoAgente.vRef_LUT.phi_threshold(1)*180/pi));
 idAgente               = get(handles.idAgente,'Value');
 idFullAgente           = get(handles.idFullAgente,'String');
 visible                = get(handles.visibleAgente,'Value');
 modoPosicion           = get(handles.modoPosicionAgente,'Value');
 punto(1)               = get(handles.posXAgente,'Value');
 punto(2)               = get(handles.posYAgente,'Value');
 unidad                 = get(handles.radioUTMAgente,'Value');
 orientacion            = get(handles.orientacion,'Value');
 radioGiro              = get(handles.radioGiro,'Value');
 RGB                    = get(handles.colorAgente,'Data');
 IPcamera               = get(handles.IPcameraAgente,'String');
 enableIPcamera         = get(handles.enableIPcameraAgente,'Value');
 userIPcamera           = get(handles.userIPcameraAgente,'String');
 pwdIPcamera            = get(handles.pwdIPcameraAgente,'String');
 topicCamera            = get(handles.topicCameraAgente,'String');
 typeCamera             = get(handles.typeCameraAgente,'String');
 enabledCamera          = get(handles.enabledCameraAgente,'Value');
 rosCamera              = get(handles.rosCameraAgente,'Value');
 enabledCameraAgente(handles);
 ipMQTT                 = get(handles.ipMQTTAgente,'String');
 set(handles.portMQTTAgente,'Value',str2num(get(handles.portMQTTAgente,'String')));
 portMQTT               = get(handles.portMQTTAgente,'Value');
 topicGPS               = get(handles.topicGPSAgente,'String');
 topicCommand           = get(handles.topicCommandAgente,'String');
 topicStatus            = get(handles.topicStatusAgente,'String');
 QoSMQTT                = get(handles.QoSMQTTAgente,'Value');
 enableMQTT             = get(handles.enabledMQTTAgente,'Value');
 GPXfolder              = get(handles.GPXfolderAgente,'String');
 enableGPX              = get(handles.enabledGPXAgente,'Value');
 ROStopicSubs1          = get(handles.topic1SubsAgente,'String');
 ROStypeSubs1           = get(handles.type1SubsAgente,'String');
 enableROSSubs1         = get(handles.enabledSubs1Agente,'Value');
 nonROS2Subs1           = get(handles.ros1SubsAgente,'Value');
 enabledSubs1Agente(handles);
 ROSnameSpace           = get(handles.nameSpaceAgente,'String');
 ROStopicSubs3a         = get(handles.topic3aSubsAgente,'String');
 ROStopicSubs3b         = get(handles.topic3bSubsAgente,'String');
 ROStopicSubs3c         = get(handles.topic3cSubsAgente,'String');
 ROStypeSubs3           = get(handles.type3SubsAgente,'String');
 enableROSSubs3         = get(handles.enabledSubs3Agente,'Value');
 nonROS2Subs3           = get(handles.ros3SubsAgente,'Value');
 if idAgente<=get(handles.numAgentes,'Value'), calling_status = data.agentes(idAgente).config.calling_status; else, calling_status = false(1,3); end
 enabledSubs3Agente(handles);
 if strcmp(get(handles.freq4SubsAgente,'String'),'')
  set(handles.freq4SubsAgente,'Value',NaN);
 else    
  set(handles.freq4SubsAgente,'Value',str2double(get(handles.freq4SubsAgente,'String')));
 end
 ROSfreqSubs4           = get(handles.freq4SubsAgente,'Value');
 ROStopicSubs4          = get(handles.topic4SubsAgente,'String');
 ROStypeSubs4           = get(handles.type4SubsAgente,'String');
 enableROSSubs4         = get(handles.enabledSubs4Agente,'Value');
 nonROS2Subs4           = get(handles.ros4SubsAgente,'Value');
 enabledSubs4Agente(handles);
 ROStopicSubs2          = get(handles.topic2SubsAgente,'String');
 ROStypeSubs2           = get(handles.type2SubsAgente,'String');
 enableROSSubs2         = get(handles.enabledSubs2Agente,'Value');
 nonROS2Subs2           = get(handles.ros2SubsAgente,'Value');
 enabledSubs2Agente(handles);
 ROStopicPub1           = get(handles.topic1PubAgente,'String');
 ROStypePub1            = get(handles.type1PubAgente,'String');
 enableROSPub1          = get(handles.enabledPub1Agente,'Value');
 nonROS2Pub1            = get(handles.ros1PubAgente,'Value');
 enabledPub1Agente(handles);
 if strcmp(get(handles.granularity,'String'),'')
  set(handles.granularity,'Value',NaN);
 else
  set(handles.granularity,'Value',str2double(get(handles.granularity,'String')));
 end
 granularity            = get(handles.granularity,'Value');
 if isfield(data,'agentes') && idAgente<=length(data.agentes) && isfield(data.agentes(idAgente).config,'ROS')
  ROS = data.agentes(idAgente).config.ROS;
 else, ROS = [];
 end
 enablePlanning         = get(handles.enableAgente,'Value');
 enableFreeze           = get(handles.enableFreezeAgente,'Value');
 subnets = get(handles.nodeSubnetworkAgente,'String');
 if isfield(data,'agentes') && idAgente <= length(data.agentes) && isfield(data.agentes(idAgente).config,'sensorNodes') && ...
    strcmp(data.agentes(idAgente).config.sensorNodes.automatic.subnetwork,subnets{get(handles.nodeSubnetworkAgente,'Value')}) && ...
    strcmp(data.agentes(idAgente).config.sensorNodes.automatic.group,get(handles.sensorGroupIDAgente,'String'))
  sensorNodes = data.agentes(idAgente).config.sensorNodes;
 else
  aux.automatic.valor = NaN*ones(1,length(LoRa.keys));
  aux.automatic.enableFilter = false;
  aux.automatic.enableRSSIPlot = false;
  aux.automatic.enableBatteryPlot = false;
  aux.automatic.enablePlot = false(length(LoRa.keys),1);
  aux.automatic.enableMap = false(length(LoRa.keys),1);
  aux.automatic.histRSSI = {};
  aux.automatic.histSNR = {};
  aux.automatic.histChannel = {};
  aux.automatic.histBroker = NaN;
  aux.automatic.histDevEUI = NaN;
  aux.automatic.histValor = NaN*ones(length(LoRa.keys),1);
  aux.automatic.histTimestamp = {};
  aux.automatic.histTiempo = datetime('now','InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC');
  aux.automatic.subnetwork = subnets{get(handles.nodeSubnetworkAgente,'Value')};
  aux.automatic.group = get(handles.sensorGroupIDAgente,'String');
  sensorNodes = aux;
 end
 sensorNodes.user.modoPosicion = modoPosicion;
 sensorNodes.user.unidadPosicion = unidad;
 sensorNodes.user.posicion = punto;
 sensorNodes.user.minUmbral = get(handles.minUmbralAgente,'Value');
 sensorNodes.user.maxUmbral = get(handles.maxUmbralAgente,'Value');
 data.agentes(idAgente).config = AgenteInsertar(tipoAgente,idAgente,idFullAgente,visible,...
                                                modoPosicion,punto,unidad,orientacion,radioGiro,...
                                                RGB,IPcamera,enableIPcamera,userIPcamera,pwdIPcamera,...
                                                topicCamera,typeCamera,enabledCamera,rosCamera,...
                                                ipMQTT,portMQTT,topicGPS,topicCommand,topicStatus,QoSMQTT,enableMQTT,...
                                                GPXfolder,enableGPX,...
                                                ROStopicSubs1,ROStypeSubs1,enableROSSubs1,nonROS2Subs1,...
                                                ROSnameSpace,ROStopicSubs3a,ROStopicSubs3b,ROStopicSubs3c,ROStypeSubs3,enableROSSubs3,nonROS2Subs3,calling_status,...
                                                ROSfreqSubs4,ROStopicSubs4,ROStypeSubs4,enableROSSubs4,nonROS2Subs4,...
                                                ROStopicSubs2,ROStypeSubs2,enableROSSubs2,nonROS2Subs2,...
                                                ROStopicPub1,ROStypePub1,enableROSPub1,nonROS2Pub1,granularity,ROS,...
                                                enablePlanning,enableFreeze,...
                                                sensorNodes);
 enabledMQTTAgente(handles);
 modoPosicion = get(handles.modoPosicionAgente,'Value');
 enableMQTT   = get(handles.enabledMQTTAgente,'Value');
 sensorNodes.user.modoPosicion = modoPosicion;
 data.agentes(idAgente).config = AgenteInsertar(tipoAgente,idAgente,idFullAgente,visible,...
                                                modoPosicion,punto,unidad,orientacion,radioGiro,...
                                                RGB,IPcamera,enableIPcamera,userIPcamera,pwdIPcamera,...
                                                topicCamera,typeCamera,enabledCamera,rosCamera,...
                                                ipMQTT,portMQTT,topicGPS,topicCommand,topicStatus,QoSMQTT,enableMQTT,...
                                                GPXfolder,enableGPX,...
                                                ROStopicSubs1,ROStypeSubs1,enableROSSubs1,nonROS2Subs1,...
                                                ROSnameSpace,ROStopicSubs3a,ROStopicSubs3b,ROStopicSubs3c,ROStypeSubs3,enableROSSubs3,nonROS2Subs3,calling_status,...
                                                ROSfreqSubs4,ROStopicSubs4,ROStypeSubs4,enableROSSubs4,nonROS2Subs4,...
                                                ROStopicSubs2,ROStypeSubs2,enableROSSubs2,nonROS2Subs2,...
                                                ROStopicPub1,ROStypePub1,enableROSPub1,nonROS2Pub1,granularity,ROS,...
                                                enablePlanning,enableFreeze,...
                                                sensorNodes);
 switch sum(get(handles.statusMQTTAgente,'Background'))
   case  2  , data.agentes(idAgente).config.statusMQTT = 1;
   case  1  , data.agentes(idAgente).config.statusMQTT = 2;
   case 0.9 , data.agentes(idAgente).config.statusMQTT = 3;
   otherwise, data.agentes(idAgente).config.statusMQTT = 0;
  end
 numAgentes = get(handles.numAgentes,'Value');
 if numAgentes < idAgente
  set(handles.numAgentes,'Value',numAgentes + 1);
  set(handles.numAgentes,'String',num2str(get(handles.numAgentes,'Value')));
 end
 set(handles.idAgente,'Enable','on');
 set(handles.addAgente_button,'Visible','on');
 set(handles.removeAgente_button,'Visible','on');
 set(handles.editAgente_button,'Visible','on');
 set(handles.idFullAgente,'Enable','inactive');
 set(handles.visibleAgente,'Enable','inactive');
 set(handles.longitudX,'Enable','inactive');
 set(handles.longitudY,'Enable','inactive');
 set(handles.seguridadAgente,'Enable','inactive');
 set(handles.COGx,'Enable','inactive');
 set(handles.COGy,'Enable','inactive');
 set(handles.COGz,'Enable','inactive');
 set(handles.rhoTol,'Enable','inactive');
 set(handles.velocidad,'Enable','inactive');
 set(handles.coefVelocidadPositiva,'Enable','inactive');
 set(handles.coefVelocidadNegativa,'Enable','inactive');
 set(handles.coefVelocidadLateral,'Enable','inactive');
 %%% set(handles.pendienteMax,'Enable','inactive');
 %%% set(handles.pendienteMin,'Enable','inactive');
 %%% set(handles.vuelcoMax,'Enable','inactive');
 %%% set(handles.vuelcoMin,'Enable','inactive');
 aux = get(handles.colorAgente,'Data');
 set(handles.colorAgente,'Data',[aux,0]); set(handles.colorAgente,'Data',aux);
 set(handles.modoPosicionAgente,'Enable','inactive');
 set(handles.pickAgente_button,'Visible','off');
 set(handles.radioUTMAgente,'Enable','inactive');
 set(handles.radioGEOAgente,'Enable','inactive');
 set(handles.posXAgente,'Enable','inactive');
 set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
 set(handles.posYAgente,'Enable','inactive');
 set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
 radioUnitAgente(handles,false);
 set(handles.orientacion,'Enable','inactive');
 set(handles.radioGiro,'Enable','inactive');
 set(handles.colorAgente,'Enable','inactive');
 set(handles.IPcameraAgente,'Enable','inactive');
 set(handles.enableIPcameraAgente,'Enable','inactive');
 set(handles.userIPcameraAgente,'Enable','inactive');
 set(handles.pwdIPcameraAgente,'Enable','inactive');
 set(handles.topicCameraAgente,'Enable','inactive');
 set(handles.typeCameraAgente,'Enable','inactive');
 set(handles.enabledCameraAgente,'Enable','inactive');
 set(handles.rosCameraAgente,'Enable','inactive');
 set(handles.nodeSubnetworkAgente,'Enable','inactive');
 set(handles.sensorGroupIDAgente,'Enable','inactive');
 set(handles.minUmbralAgente,'Enable','inactive');
 set(handles.maxUmbralAgente,'Enable','inactive');
 set(handles.ipMQTTAgente,'Enable','inactive');
 set(handles.portMQTTAgente,'Enable','inactive');
 set(handles.topicGPSAgente,'Enable','inactive');
 set(handles.topicCommandAgente,'Enable','inactive');
 set(handles.topicStatusAgente,'Enable','inactive');
 set(handles.QoSMQTTAgente,'Enable','inactive');
 set(handles.enabledMQTTAgente,'Enable','inactive');
 set(handles.GPXfolderAgente,'Enable','inactive');
 set(handles.buttonGPXAgente,'Enable','inactive');
 set(handles.enabledGPXAgente,'Enable','inactive');
 %---
 set(handles.topic1SubsAgente,'Enable','inactive');
 set(handles.type1SubsAgente,'Enable','inactive');
 set(handles.enabledSubs1Agente,'Enable','inactive');
 set(handles.ros1SubsAgente,'Enable','inactive');
 set(handles.nameSpaceAgente,'Enable','inactive');
 set(handles.topic3aSubsAgente,'Enable','inactive');
 set(handles.topic3bSubsAgente,'Enable','inactive');
 set(handles.topic3cSubsAgente,'Enable','inactive');
 set(handles.type3SubsAgente,'Enable','inactive');
 set(handles.enabledSubs3Agente,'Enable','inactive');
 set(handles.ros3SubsAgente,'Enable','inactive');
 set(handles.freq4SubsAgente,'Enable','inactive');
 set(handles.topic4SubsAgente,'Enable','inactive');
 set(handles.type4SubsAgente,'Enable','inactive');
 set(handles.enabledSubs4Agente,'Enable','inactive');
 set(handles.ros4SubsAgente,'Enable','inactive');
 set(handles.topic2SubsAgente,'Enable','inactive');
 set(handles.type2SubsAgente,'Enable','inactive');
 set(handles.enabledSubs2Agente,'Enable','inactive');
 set(handles.ros2SubsAgente,'Enable','inactive');
 set(handles.topic1PubAgente,'Enable','inactive');
 set(handles.type1PubAgente,'Enable','inactive');
 set(handles.enabledPub1Agente,'Enable','inactive');
 set(handles.ros1PubAgente,'Enable','inactive');
 set(handles.granularity,'Enable','inactive');
 %---
 set(handles.radioUTMAgente_status,'Value',get(handles.radioUTMAgente,'Value'));
 set(handles.radioGEOAgente_status,'Value',~get(handles.radioUTMAgente,'Value'));
 radioUnitAgente(handles,true);
 if ~isempty(data.agentes(idAgente).config.sensorNodes.automatic.subnetwork) && ...
      isfield(data.agentes(idAgente).config.sensorNodes.automatic,'deveui')
  set(handles.packetsAgente,'Visible','on');
  set(handles.sensorIDsAgente_label,'Visible','on');
  set(handles.sensorIDsAgente,'Visible','on');
  set(handles.sensorIDsAgente,'Enable','on');
  set(handles.valueSensorsAgente_label,'Visible','on');
  set(handles.valueSensorsAgente,'Visible','on');
  set(handles.enableFreezeAgente,'Visible','on');
  set(handles.enableFreezeAgente,'Enable','on');
  set(handles.valueSensorsAgente,'Enable','on');
  set(handles.FechaAgente_label,'Visible','on');
  set(handles.FechaAgente,'Visible','on');
 else
  set(handles.packetsAgente,'Visible','off');
  set(handles.sensorIDsAgente_label,'Visible','off');
  set(handles.sensorIDsAgente,'Visible','off');
  set(handles.valueSensorsAgente_label,'Visible','off');
  set(handles.valueSensorsAgente,'Visible','off');
  set(handles.enableFreezeAgente,'Visible','off');
  set(handles.FechaAgente_label,'Visible','off');
  set(handles.FechaAgente,'Visible','off');
 end
 updateTableAgente(handles);
 runCameraAgente(handles);
 runGraficaAgente(handles);
 if isfield(data,'sensorNodes') || isfield(data,'points'), set(handles.PLANNER_button,'Enable','on');
 else, if isfield(data,'planner') && isfield(data.planner,'optima'), data.planner = rmfield(data.planner,'optima'); end;
 end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 % -----
 % Clculo de la matriz de velocidades (etapa 1)
 if get(handles.AutomaticPlanning,'Value') && ~data.agentesUpdated
  tini = tic;
  %%% Note: progress bar hidden.
  % set(handles.progresoBorde,'Visible','on'); set(handles.progresoFondo,'Visible','on');
  % set(handles.progreso,'Visible','on');
  % pTotal = get(handles.progresoFondo,'Position'); pTotal = pTotal(3);
  % pos = get(handles.progreso,'Position');
  % p = 0; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
  %%%%if ~isfield(data,'sensorNodes') && isfield(data,'points')
  %%%% data.planner.ini = Inicializar(data.environment,data.agents,[],data.points,data.options);
  %%%%elseif isfield(data,'sensorNodes') && ~isfield(data,'points')
  %%%% data.planner.ini = Inicializar(data.environment,data.agents,data.sensorNodes,[],data.options);
  %%%%elseif ~isfield(data,'sensorNodes') && ~isfield(data,'points')
  %%%% data.planner.ini = Inicializar(data.environment,data.agents,[],[],data.options);
  %%%%else
  %%%% data.planner.ini = Inicializar(data.environment,data.agents,data.sensorNodes,data.points,data.options);
  %%%%end
  if isempty(data.planner.ini.Ak)
   data.planner.Vadimtk = []; data.planner.Vtk = [];
  else
%    if ~data.agentsUpdated
%     % p = 0.10; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
%     [data.planner.Vadimtk] = CalcularVadimtk(data.planner.ini,data.environment,data.options);
%     % p = 0.20; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
%     [data.planner.Vtk] = CalcularVtk(data.planner.ini,data.planner.Vadimtk,data.environment,data.options);
%     % p = 1.00; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
%    end
  end
  t = toc(tini);
  % set(handles.progresoBorde,'Visible','off'); set(handles.progresoFondo,'Visible','off');
  % set(handles.progreso,'Visible','off');
  % fprintf('Tiempo de preprocesamiento del planificador estratgico: %g s\n',t);
 end
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 data.agentesUpdated = 1;
 ClickOnAux2Tab(handles.a21,[],handles);
end

% --- Executes on button press in AgentOK_button2.
function AgenteOK_button2_Callback(~,~, handles)
 AgenteOK_button_Callback([],[],handles);
end


% --- Executes on button press in AgentCANCEL_button.
function AgenteCANCEL_button_Callback(~,~, handles)
global data
 set(handles.defaultAgentes,'Enable','on');
 set(handles.AgenteOK_button,'Visible','off');
 set(handles.AgenteOK_button2,'Visible','off');
 set(handles.AgenteCANCEL_button,'Visible','off');
 set(handles.AgenteCANCEL_button2,'Visible','off');
 idAgente   = get(handles.idAgente,'Value');
 numAgentes = get(handles.numAgentes,'Value');
 if numAgentes < idAgente
  set(handles.idAgente,'String','');
  set(handles.idAgente,'Value',0);
 elseif numAgentes
  set(handles.removeAgente_button,'Visible','on');
 end
 set(handles.addAgente_button,'Visible','on');
 set(handles.idAgente,'Enable','on');
 if idAgente <= numAgentes, set(handles.editAgente_button,'Visible','on'); end
 editAgente(handles);
 set(handles.idFullAgente,'Enable','inactive');
 set(handles.visibleAgente,'Enable','inactive');
 set(handles.longitudX,'Enable','inactive');
 set(handles.longitudY,'Enable','inactive');
 set(handles.seguridadAgente,'Enable','inactive');
 set(handles.COGx,'Enable','inactive');
 set(handles.COGy,'Enable','inactive');
 set(handles.COGz,'Enable','inactive');
 set(handles.rhoTol,'Enable','inactive');
 set(handles.velocidad,'Enable','inactive');
 set(handles.coefVelocidadPositiva,'Enable','inactive');
 set(handles.coefVelocidadNegativa,'Enable','inactive');
 set(handles.coefVelocidadLateral,'Enable','inactive');
 set(handles.pendienteMax,'Enable','off');
 set(handles.pendienteMin,'Enable','off');
 set(handles.vuelcoMax,'Enable','off');
 set(handles.vuelcoMin,'Enable','off');
 set(handles.modoPosicionAgente,'Enable','inactive');
 set(handles.pickAgente_button,'Visible','off');
 set(handles.radioUTMAgente,'Enable','inactive');
 set(handles.radioGEOAgente,'Enable','inactive');
 set(handles.posXAgente,'Enable','inactive');
 set(handles.posYAgente,'Enable','inactive');
 set(handles.orientacion,'Enable','inactive');
 set(handles.radioGiro,'Enable','inactive');
 set(handles.colorAgente,'Enable','inactive');
 set(handles.IPcameraAgente,'Enable','inactive');
 set(handles.statusIPcameraAgente,'Background',[1 1 1]);
 set(handles.statusIPcameraAgente_status,'Visible','off');
 set(handles.enableIPcameraAgente,'Enable','inactive');
 set(handles.userIPcameraAgente,'Enable','inactive');
 set(handles.pwdIPcameraAgente,'Enable','inactive');
 set(handles.topicCameraAgente,'Enable','inactive');
 set(handles.typeCameraAgente,'Enable','inactive');
 set(handles.enabledCameraAgente,'Enable','inactive');
 set(handles.rosCameraAgente,'Enable','inactive');
 set(handles.nodeSubnetworkAgente,'Enable','inactive');
 set(handles.sensorGroupIDAgente,'Enable','inactive');
 set(handles.minUmbralAgente,'Enable','inactive');
 set(handles.maxUmbralAgente,'Enable','inactive');
 set(handles.ipMQTTAgente,'Enable','inactive');
 set(handles.portMQTTAgente,'Enable','inactive');
 set(handles.statusMQTTAgente,'Background',[1 1 1]);
 set(handles.topicGPSAgente,'Enable','inactive');
 set(handles.topicCommandAgente,'Enable','inactive');
 set(handles.topicStatusAgente,'Enable','inactive');
 set(handles.QoSMQTTAgente,'Enable','inactive');
 set(handles.enabledMQTTAgente,'Enable','inactive');
 set(handles.GPXfolderAgente,'Enable','inactive');
 set(handles.buttonGPXAgente,'Enable','inactive');
 set(handles.enabledGPXAgente,'Enable','inactive');
 set(handles.topic1SubsAgente,'Enable','inactive');
 set(handles.type1SubsAgente,'Enable','inactive');
 set(handles.enabledSubs1Agente,'Enable','inactive');
 set(handles.ros1SubsAgente,'Enable','inactive');
 set(handles.nameSpaceAgente,'Enable','inactive');
 set(handles.topic3aSubsAgente,'Enable','inactive');
 set(handles.type3SubsAgente,'Enable','inactive');
 set(handles.enabledSubs3Agente,'Enable','inactive');
 set(handles.ros3SubsAgente,'Enable','inactive');
 set(handles.freq4SubsAgente,'Enable','inactive');
 set(handles.topic4SubsAgente,'Enable','inactive');
 set(handles.type4SubsAgente,'Enable','inactive');
 set(handles.enabledSubs4Agente,'Enable','inactive');
 set(handles.ros4SubsAgente,'Enable','inactive');
 set(handles.topic2SubsAgente,'Enable','inactive');
 set(handles.type2SubsAgente,'Enable','inactive');
 set(handles.enabledSubs2Agente,'Enable','inactive');
 set(handles.ros2SubsAgente,'Enable','inactive');
 set(handles.topic1PubAgente,'Enable','inactive');
 set(handles.type1PubAgente,'Enable','inactive');
 set(handles.enabledPub1Agente,'Enable','inactive');
 set(handles.ros1PubAgente,'Enable','inactive');
 set(handles.granularity,'Enable','inactive');
 data.agentesUpdated = 1;
 ClickOnAux2Tab(handles.a21,[],handles);
end

% --- Executes on button press in AgentCANCEL_button2.
function AgenteCANCEL_button2_Callback(~,~, handles)
 AgenteCANCEL_button_Callback([],[],handles)
end

% --- Executes on button press in enableAgent.
function enableAgente_Callback(~,~, handles)
% can be called from radioUnitAgent auxiliary function
global data
 if isfield(data,'agentes')
  idAgente = get(handles.idAgente,'Value');
  if idAgente <= length(data.agentes)
   data.agentes(idAgente).config.enable = get(handles.enableAgente,'Value');
   data.agentesUpdated = 0;
   if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
      && get(handles.AutomaticPlanning,'Value')
    PLANNER_function(handles);
   end
  end
 end
end


%% ==========================================================================================================================
% --- Tab3Panel: TARGETS
% ------------------------

% --- Executes on selection change in idTarget.
function idObjetivo_Callback(hObject, ~, handles)
% to control the correct number of target identification and (indirectly) view the asociated values of the requested target
 set(hObject,'Enable','off');
 idObjetivo = str2double(get(hObject,'String'));
 set(hObject,'Value',idObjetivo);
 ok = ~( isnan(idObjetivo) || idObjetivo <= 0 || idObjetivo > get(handles.numObjetivos,'Value') );
 if ok, okStr = 'on';
 else
  okStr = 'off';
  set(hObject,'String','');
  set(hObject,'Value',str2double(get(hObject,'String')));
 end
 % set(handles.defaultTargets,'Visible',okStr);
 % set(handles.addTarget_button,'Visible',okStr);
 set(handles.removeObjetivo_button,'Visible',okStr);
 set(handles.editObjetivo_button,'Visible',okStr);
 editObjetivo(handles);
 if ~ok
  warning({'Error: Target identification number.';...
           'The value must be between one and the number of targets.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
 end
 % set(handles.defaultTargets,'Visible','on');
 % set(handles.addTarget_button,'Visible','on');
 set(hObject,'Enable','on'); uicontrol(hObject);
end

% --- Auxiliary function for previuos one and other functions.
function editObjetivo(handles)
% to view the asociated values and (indirectly) the graphs of the requested target by a given identification number or null
% can be called from eliminarDatos, idTarget_Callback, addTarget_button_Callback, removeTarget_button_Callback, TargetCANCEL_button_Callback functions
global data
 idObjetivo = get(handles.idObjetivo,'String');
 auxModo = get(handles.modoPosicionAgente,'String');
 if isempty(idObjetivo) || ~get(handles.idObjetivo,'Value') || get(handles.idObjetivo,'Value') > get(handles.numObjetivos,'Value')
  set(handles.idFullObjetivo,'String','');
  set(handles.visibleObjetivo,'Value',0);
  set(handles.modoPosicionObjetivo,'String',auxModo(1:3));
  set(handles.modoPosicionObjetivo,'Value',3);
  set(handles.radioGEOObjetivo,'Value',1);
  set(handles.posXObjetivo,'Value',NaN);
  set(handles.posXObjetivo,'String','');
  set(handles.posYObjetivo,'Value',NaN);
  set(handles.posYObjetivo,'String','');
  set(handles.warnPosObjetivo,'Visible','off');
  set(handles.minUmbralObjetivo,'Value',0);
  set(handles.minUmbralObjetivo,'String','');
  set(handles.maxUmbralObjetivo,'Value',0);
  set(handles.maxUmbralObjetivo,'String','');
  set(handles.aproximacionObjetivo,'Value',0);
  set(handles.aproximacionObjetivo,'String','');
  set(handles.orientacionObjetivo,'Value',NaN);
  set(handles.orientacionObjetivo,'String','');
  set(handles.enableAproxObjetivo,'Value',1);
  set(handles.actividadObjetivo,'Value',0);
  set(handles.actividadObjetivo,'String','');
  set(handles.radioCoeficientObjetivo,'Value',1);
  set(handles.coefPotencialPos_Objetivo,'Value',0);
  set(handles.coefPotencialPos_Objetivo,'String','');
  set(handles.coefPotencialNeg_Objetivo,'Value',0);
  set(handles.coefPotencialNeg_Objetivo,'String','');
  set(handles.prioridadObjetivo,'Value',6);
  set(handles.temperatureEvent,'String','');
  set(handles.temperatureEvent,'Value',NaN);
  set(handles.timeEvent,'String','');
  set(handles.timeEvent,'Value',NaN);
  set(handles.patternObjetivo,'String','');
  set(handles.triggeredEventObjetivo,'Value',0);
  set(handles.statusEventObjetivo,'Visible',0);
  % ----
  for i=1:6, set(handles.(['Prior',num2str(i),'Target']),'Visible','off'); end
  set(handles.idFullObjetivo_status,'String','');
  set(handles.enableObjetivo,'Value',0);
  set(handles.enableObjetivo,'Enable','inactive');
  set(handles.radioUTMObjetivo_status,'Enable','inactive');
  set(handles.radioGEOObjetivo_status,'Enable','inactive');
  set(handles.radioGEOObjetivo_status,'Value',1);
  set(handles.posXObjetivo_status,'Value',NaN);
  set(handles.posXObjetivo_status,'String','');
  set(handles.posYObjetivo_status,'Value',NaN);
  set(handles.posYObjetivo_status,'String','');
  set(handles.warnPosObjetivo_status,'Visible','off');
  set(handles.nodeSubnetwork,'String','');
  set(handles.gatewaysIDs,'Value',1);
  set(handles.gatewaysIDs,'Enable','inactive');
  set(handles.packets,'String','');
  set(handles.packets,'Enable','inactive');
  set(handles.sensorIDs,'Enable','inactive');
  set(handles.sensorIDs,'Data',[]);
  set(handles.valueSensors,'Enable','inactive');
  set(handles.valueSensors,'Data',[]);
  set(handles.enableFreezeObjetivo,'Visible','off');
  set(handles.Fecha,'String','');
  set(handles.grafico,'Visible','off');
  legend(handles.grafico,'off');
  handles.grafico.XAxis.Visible = 'off';
  cla(handles.grafico);
  set(handles.graficoAux,'Visible','off');
  legend(handles.graficoAux,'off');
  cla(handles.graficoAux);
 else
  idObjetivo = get(handles.idObjetivo,'Value');
  set(handles.idFullObjetivo,'String',data.sensorNodes(idObjetivo).user.idFull);
  set(handles.visibleObjetivo,'Value',data.sensorNodes(idObjetivo).user.visible);
  set(handles.modoPosicionObjetivo,'String',auxModo(1:3));
  set(handles.modoPosicionObjetivo,'Value',data.sensorNodes(idObjetivo).user.modoPosicion);
  set(handles.radioUTMObjetivo,'Value',data.sensorNodes(idObjetivo).user.unidadPosicion);
  set(handles.radioGEOObjetivo,'Value',~data.sensorNodes(idObjetivo).user.unidadPosicion);
  if isfield(data.sensorNodes(idObjetivo).user,'posicion') && ...
     ~( isnan(data.sensorNodes(idObjetivo).user.posicion(1)) || isnan(data.sensorNodes(idObjetivo).user.posicion(2)) )
   set(handles.posXObjetivo,'Value',data.sensorNodes(idObjetivo).user.posicion(1));
   set(handles.posXObjetivo,'String',num2str(get(handles.posXObjetivo,'value')));
   set(handles.posYObjetivo,'Value',data.sensorNodes(idObjetivo).user.posicion(2));
   set(handles.posYObjetivo,'String',num2str(get(handles.posYObjetivo,'value')));
  else
   set(handles.posXObjetivo,'Value',NaN);
   set(handles.posXObjetivo,'String','');
   set(handles.posYObjetivo,'Value',NaN);
   set(handles.posYObjetivo,'String','');
  end
  radioUnitObjetivo(handles,false);
  set(handles.minUmbralObjetivo,'Value',data.sensorNodes(idObjetivo).user.minUmbral);
  set(handles.minUmbralObjetivo,'String',num2str(get(handles.minUmbralObjetivo,'value')));
  set(handles.maxUmbralObjetivo,'Value',data.sensorNodes(idObjetivo).user.maxUmbral);
  set(handles.maxUmbralObjetivo,'String',num2str(get(handles.maxUmbralObjetivo,'value')));
  set(handles.aproximacionObjetivo,'Value',data.sensorNodes(idObjetivo).user.aproximacion);
  set(handles.aproximacionObjetivo,'String',num2str(get(handles.aproximacionObjetivo,'value')));
  set(handles.orientacionObjetivo,'Value',data.sensorNodes(idObjetivo).user.orientacion*180/pi);
  set(handles.enableAproxObjetivo,'Value',data.sensorNodes(idObjetivo).user.enableAprox);
  if isnan(get(handles.orientacionObjetivo,'value')), set(handles.orientacionObjetivo,'String','');
  else, set(handles.orientacionObjetivo,'String',num2str(get(handles.orientacionObjetivo,'value'))); end
  set(handles.enableAproxObjetivo,'Value',data.sensorNodes(idObjetivo).user.enableAprox);
  set(handles.actividadObjetivo,'Value',data.sensorNodes(idObjetivo).user.actividad);
  set(handles.actividadObjetivo,'String',num2str(get(handles.actividadObjetivo,'value')));
  %%% Note:
  switch data.sensorNodes(idObjetivo).user.coeficiente
   case 1, set(handles.radioCoeficientObjetivo,'Value',1);
   case 2, set(handles.radioPercentualObjetivo,'Value',1);
   case 3, set(handles.radioTimeObjetivo,'Value',1);
   case 4, set(handles.radioHybridObjetivo,'Value',1);
  end
  set(handles.coefPotencialPos_Objetivo,'Value',data.sensorNodes(idObjetivo).user.coefPos);
  set(handles.coefPotencialPos_Objetivo,'String',num2str(get(handles.coefPotencialPos_Objetivo,'value')));
  set(handles.coefPotencialNeg_Objetivo,'Value',data.sensorNodes(idObjetivo).user.coefNeg);
  set(handles.coefPotencialNeg_Objetivo,'String',num2str(get(handles.coefPotencialNeg_Objetivo,'value')));
  set(handles.prioridadObjetivo,'Value',data.sensorNodes(idObjetivo).user.prioridad);
  set(handles.temperatureEvent,'Value',data.sensorNodes(idObjetivo).user.temperatureEvent);
  if isnan(data.sensorNodes(idObjetivo).user.temperatureEvent), set(handles.temperatureEvent,'String','');
  else, set(handles.temperatureEvent,'String',num2str(get(handles.temperatureEvent,'value'))); end
  set(handles.timeEvent,'Value',data.sensorNodes(idObjetivo).user.timeEvent);
  if isnan(data.sensorNodes(idObjetivo).user.timeEvent), set(handles.timeEvent,'String','');
  else, set(handles.timeEvent,'String',num2str(get(handles.timeEvent,'value'))); end
  set(handles.patternObjetivo,'String',data.sensorNodes(idObjetivo).user.pattern);
  set(handles.triggeredEventObjetivo,'Value',data.sensorNodes(idObjetivo).user.event);
  set(handles.statusEventObjetivo,'Visible',data.sensorNodes(idObjetivo).user.event);
  % ----
  for i=1:6, set(handles.(['Prior',num2str(i),'Target']),'Visible','off'); end
  set(handles.(['Prior',num2str(data.sensorNodes(idObjetivo).user.prioridad),'Target']),'Position',data.default.PositionIconoPrioridadObjetivo);
  set(handles.(['Prior',num2str(data.sensorNodes(idObjetivo).user.prioridad),'Target']),'Visible','on');
  set(handles.idFullObjetivo_status,'String',data.sensorNodes(idObjetivo).user.idFull);
  set(handles.enableObjetivo,'Value',data.sensorNodes(idObjetivo).user.enable);
  set(handles.enableObjetivo,'Enable','on');
  set(handles.radioUTMObjetivo_status,'Enable','on');
  set(handles.radioUTMObjetivo_status,'Value',data.sensorNodes(idObjetivo).user.unidadPosicion);
  set(handles.radioGEOObjetivo_status,'Enable','on');
  set(handles.radioGEOObjetivo_status,'Value',~data.sensorNodes(idObjetivo).user.unidadPosicion);
  if isfield(data.sensorNodes(idObjetivo).user,'posicion') && ~isempty(data.sensorNodes(idObjetivo).user.posicion)
   set(handles.posXObjetivo_status,'Value',data.sensorNodes(idObjetivo).user.posicion(1));
   set(handles.posYObjetivo_status,'Value',data.sensorNodes(idObjetivo).user.posicion(2));
  else
   set(handles.posXObjetivo_status,'Value',NaN);
   set(handles.posXObjetivo_status,'String','');
   set(handles.posYObjetivo_status,'Value',NaN);
   set(handles.posYObjetivo_status,'String','');
  end
  radioUnitObjetivo(handles,true);
  set(handles.gatewaysIDs,'Value',1);
  set(handles.gatewaysIDs,'Enable','on');
  set(handles.enableFreezeObjetivo,'Value',data.sensorNodes(idObjetivo).user.enableFreeze);
  updateTable(handles,'Target',false);
 end
 modoPosicionObjetivo_Callback([],[],handles);
 runGrafica(handles,'Target',false);
end

% --- Auxiliary function for previuos one and other functions.
function updateTableObjetivo(handles)
 updateTable(handles,'Target',get(handles.enableFreezeObjetivo,'Value'));
end

% --- Auxiliary function for previuos one and other functions.
function updateTable(handles, entidad, freeze)
% to update the asociated values and (indirectly) the graphs of the requested agent with a given identification number
% can be called from editAgent,  functions
global data LoRa %%% Zigbee
 % initialize common variables for using with agent or target datatables
 switch entidad
  case 'Agent'
   id = get(handles.idAgente,'Value');
   sensorNodes = data.agentes(id).config.sensorNodes;
   gatewaysIDs_label = handles.gatewaysIDsAgente_label;
   gatewaysIDs = handles.gatewaysIDsAgente;
   packets = handles.packetsAgente;
   sensorIDs_label = handles.sensorIDsAgente_label;
   sensorIDs = handles.sensorIDsAgente;
   valueSensors_label = handles.valueSensorsAgente_label;
   valueSensors = handles.valueSensorsAgente;
   enableFreeze = handles.enableFreezeAgente;
   Fecha_label = handles.FechaAgente_label;
   Fecha = handles.FechaAgente;
  case 'Target'
   id = get(handles.idObjetivo,'Value');
   gatewaysIDs = handles.gatewaysIDs;
   sensorNodes = data.sensorNodes(id);
   packets = handles.packets;
   sensorIDs = handles.sensorIDs;
   valueSensors = handles.valueSensors;
   enableFreeze = handles.enableFreezeObjetivo;
   Fecha = handles.Fecha;
   nodeSubnetwork = handles.nodeSubnetwork;
 end
 % -----
 if ~freeze
  if ~isempty(sensorNodes.automatic.subnetwork) && isfield(sensorNodes.automatic,'deveui')
   if strcmp(entidad,'Agent')
    set(sensorIDs_label,'Visible','on');
    set(sensorIDs,'Visible','on');
    set(gatewaysIDs_label,'Visible','on');
    set(gatewaysIDs,'Visible','on');
    set(valueSensors_label,'Visible','on');
    set(valueSensors,'Visible','on');
    set(Fecha_label,'Visible','on');
    set(Fecha,'Visible','on');
   elseif strcmp(entidad,'Target')
    set(nodeSubnetwork,'String',sensorNodes.automatic.subnetwork);
   end
   set(gatewaysIDs,'Enable','on');
   set(sensorIDs,'Enable','on');
   set(valueSensors,'Enable','on');
   set(enableFreeze,'Visible','on');
   set(enableFreeze,'Enable','on');
   TABLA = cell(length(sensorNodes.automatic.deveui),8);
   for k=1:length(sensorNodes.automatic.deveui)
    idx = (sensorNodes.automatic.histDevEUI==k);
    if gatewaysIDs.Value==1, idxGtw = NaN; % all concetrator-nodes
    else
     idxGtw = gatewaysIDs.Value-1;
     for i=1:length(sensorNodes.automatic.histRSSI)
      idx(i) = idx(i) && size(sensorNodes.automatic.histRSSI{i},2)>=idxGtw && ...
               ~isnan(sensorNodes.automatic.histRSSI{i}(idxGtw));
     end
    end
    idx = find(idx==true,1,'last');
    if isnan(idxGtw), [~,idxGtw] = max(sensorNodes.automatic.histRSSI{idx}); end
    if isempty(idx), TABLA(k,:) = [];
    else
    TABLA(k,:) = {char(sensorNodes.automatic.deveui(k))
                  sensorNodes.automatic.enableFilter(k)
                  pad(sensorNodes.automatic.datr{k}(3:strfind(char(sensorNodes.automatic.datr(k)),'BW')-1),5,'left')
                  pad(strcat(char(sprintf("%6.0f",sensorNodes.automatic.histRSSI{idx}(idxGtw))),'/',char(sprintf("%3.2f",sensorNodes.automatic.histSNR{idx}(idxGtw)))),10,'left')
                  char(sprintf("%5.0f",sensorNodes.automatic.histChannel{idx}(idxGtw)))
                  sensorNodes.automatic.enableRSSIPlot(k)
                  char(sprintf("%6.0f",sensorNodes.automatic.histValor(7,idx)))
                  sensorNodes.automatic.enableBatteryPlot(k)};
    end
   end
   set(sensorIDs,'Data',TABLA);
   idx = false(1,size(sensorNodes.automatic.histDevEUI,2));
   if gatewaysIDs.Value==1  % all concentrator-nodes
    if isempty(find(sensorNodes.automatic.enableFilter,1))
     idx = true(1,size(sensorNodes.automatic.histDevEUI,2));
    else
     for i=find(sensorNodes.automatic.enableFilter)
      idx = idx | sensorNodes.automatic.histDevEUI==i;
     end
    end
   else
    idxGtw = gatewaysIDs.Value-1;
    for k=1:length(sensorNodes.automatic.enableFilter)
     if sensorNodes.automatic.enableFilter(k) || isempty(find(sensorNodes.automatic.enableFilter,1))
      for i=1:length(sensorNodes.automatic.histRSSI)
       idx(i) = idx(i) || size(sensorNodes.automatic.histRSSI{i},2)>=idxGtw && ...
                ~isnan(sensorNodes.automatic.histRSSI{i}(idxGtw));
      end
     end
    end
   end
   valores = sensorNodes.automatic.histValor(:,idx);
   set(packets,'String',num2str(size(valores,2)));
   k = 1; TABLA = {}; valueSensors.UserData = [];
   for i=1:length(LoRa.keys)
    valorNonNaN = find(~isnan(valores(i,:)),1,'last');
    if ~isempty(valorNonNaN) && ~strcmp(LoRa.keys{i}(4),"GPS") && i~=LoRa.indexBAT
     if ~strcmp(LoRa.keys{i}(4),"LON") && ~strcmp(LoRa.keys{i}(4),"LAT") 
      aux = strjust(char(sprintf("%18.4f",valores(i,valorNonNaN))));
     else
      if valores(i,valorNonNaN)>0, aux = strjust(char(sprintf("%15.8f",valores(i,valorNonNaN))));
      else, aux = strjust(char(sprintf("%16.8f",valores(i,valorNonNaN)))); end
     end
     TABLA(k,:) = {char(LoRa.keys{i}(5))
                   aux
                   char(LoRa.keys{i}(6))
                   sensorNodes.automatic.enablePlot(i)
                   sensorNodes.automatic.enableMap(i)};
     k = k+1; valueSensors.UserData = [valueSensors.UserData i];
    end
   end
   set(valueSensors,'Data',TABLA);
   set(Fecha,'String',char(sensorNodes.automatic.histTiempo(find(idx,1,'last'))));
  else
   if strcmp(entidad,'Agent')
    set(sensorIDs_label,'Visible','off');
    set(sensorIDs,'Visible','off');
    set(valueSensors_label,'Visible','off');
    set(valueSensors,'Visible','off');
    set(Fecha_label,'Visible','off');
    set(Fecha,'Visible','off');
   elseif strcmp(entidad,'Target')
    set(sensorIDs,'Enable','inactive');
    set(valueSensors,'Enable','inactive');
   end
   set(handles.packets,'String','');
   set(enableFreeze,'Visible','off');
   set(sensorIDs,'Data',{});
   set(valueSensors,'Data',{});
   set(valueSensors,'UserData',[]);
   set(Fecha,'String','');
  end
 end
end

% --- Auxiliary function for previous one and another funtions.
function runGraficaObjetivo(handles)
 runGrafica(handles,'Target',get(handles.enableFreezeObjetivo,'Value'));
end

% --- Auxiliary function for previous one and another funtions.
function runGrafica(handles, entidad, freeze)
global data LoRa
 % initialize common variables for using with agent or target graphics
 switch entidad
  case 'Agent'
   defaultPosition_grafico = data.default.PositionGraficoAgente;
   id = get(handles.idAgente,'Value');
   existsID = isfield(data,'agentes') && id > 0 && id <= get(handles.numAgentes,'Value');
   existsPhysiologic = existsID && isfield(data.agentes(id).config,'ROS') && isfield(data.agentes(id).config.ROS,'histValueSub4');
   gatewaysIDs = handles.gatewaysIDsAgente;
   valueSensors = handles.valueSensorsAgente;
   if existsID, sensorNodes = data.agentes(id).config.sensorNodes; end
   if existsPhysiologic, valuesPhysiologic.value = data.agentes(id).config.ROS.histValueSub4; valuesPhysiologic.time = data.agentes(id).config.ROS.histTimeSub4; end
   grafico = handles.graficoAgente;
   graficoAux = handles.graficoAuxAgente;
   graficoPhysiologic1 = handles.Fisiologic_chart1;
   graficoPhysiologic2 = handles.Fisiologic_chart2;
   graficoPhysiologic3 = handles.Fisiologic_chart3;
   graficoPhysiologic4 = handles.Fisiologic_chart4;
  case 'Target'
   defaultPosition_grafico = data.default.PositionGraficoObjetivo;
   id = get(handles.idObjetivo,'Value');
   existsID = isfield(data,'sensorNodes') && id > 0 && id <= get(handles.numObjetivos,'Value');
   gatewaysIDs = handles.gatewaysIDs;
   valueSensors = handles.valueSensors;
   if existsID, sensorNodes = data.sensorNodes(id); end
   grafico = handles.grafico;
   graficoAux = handles.graficoAux;
 end
 % -----
 %set(grafico,'Visible','off');
 %set(graficoAux,'Visible','off');
 grafico.XAxis.Visible = 'off';
 % to update the graphs of the requested agent with a given identification number or null
 if ( ~freeze && ...
      strcmp(entidad,'Target') || ( strcmp(entidad,'Agent') && ~strcmp(get(handles.camera_status,'Visible'),'on') ) )
  if existsID
   TABLA = get(valueSensors,'Data');
   % if RSSI plot is requested
   if isfield(sensorNodes.automatic,'enableRSSIPlot') && sum(sensorNodes.automatic.enableRSSIPlot)
    % initialize the graphical area for the RSSI plot
    set(grafico,'Visible','on');
    set(grafico.Children,'Visible','on');
    axis(grafico,'auto');
    cla(grafico);
    legend(grafico,'off');
    % draw the color background of a RSSI plot
    reducedWidth = 60;
    grafico.Position    = defaultPosition_grafico.* [1 1 1 1/2] + [0 -(reducedWidth+5)+defaultPosition_grafico(4)*1/2 0 reducedWidth];
    graficoAux.Position = defaultPosition_grafico.* [1 1 1 1/2] + [0 -5 0 -reducedWidth];
    ejeYsup  = sensorNodes.user.maxUmbral * ones(1,size(sensorNodes.automatic.histTiempo,2));
    ejeYinf  = sensorNodes.user.minUmbral * ones(1,size(sensorNodes.automatic.histTiempo,2));
    extLevelSup = (sensorNodes.user.maxUmbral + sensorNodes.user.minUmbral) / 2;
    extLevelInf = extLevelSup;
    for i=1:length(sensorNodes.automatic.deveui)
     idx{i} = (sensorNodes.automatic.histDevEUI==i);
     if gatewaysIDs.Value==1, idxGtw = NaN; % all concetrator-nodes
     else
      idxGtw = gatewaysIDs.Value-1;
      for k=1:length(sensorNodes.automatic.histRSSI)
       idx{i}(k) = idx{i}(k) && size(sensorNodes.automatic.histRSSI{k},2)>=idxGtw && ...
                   ~isnan(sensorNodes.automatic.histRSSI{k}(idxGtw));
      end
     end
     histTiempo{i} = sensorNodes.automatic.histTiempo(idx{i});
     tmpRSSI{i}    = sensorNodes.automatic.histRSSI(idx{i});
     tmpSNR{i}     = sensorNodes.automatic.histSNR(idx{i});
     tmpChannel{i} = sensorNodes.automatic.histChannel(idx{i});
     for k=1:length(tmpRSSI{i})
      if isnan(idxGtw)
       [histRSSI{i}(k),idxRSSI] = max(cell2mat(tmpRSSI{i}(k)));
       tmp = cell2mat(tmpSNR{i}(k));     histSNR{i}(k) = tmp(idxRSSI);
       tmp = cell2mat(tmpChannel{i}(k)); histChannel{i}(k) = tmp(idxRSSI);
      else
       tmp = cell2mat(tmpRSSI{i}(k));    histRSSI{i}(k)    = tmp(idxGtw);
       tmp = cell2mat(tmpSNR{i}(k));     histSNR{i}(k)     = tmp(idxGtw);
       tmp = cell2mat(tmpChannel{i}(k)); histChannel{i}(k) = tmp(idxGtw);
      end
     end
     if sensorNodes.automatic.enableRSSIPlot(i) && sum(~isnan(sensorNodes.automatic.histRSSI{i}))
      extSupLevel = max(histRSSI{i});
      extInfLevel = min(histRSSI{i});
      if extSupLevel > extLevelSup, extLevelSup = extSupLevel; end
      if extInfLevel < extLevelInf, extLevelInf = extInfLevel; end
     end
    end
    ejeYlevel = extLevelInf * ones(1,size(sensorNodes.automatic.histTiempo,2));
    ejeYlevel(1) = extLevelSup;
    ejeX = sensorNodes.automatic.histTiempo;
    plot(grafico,ejeX,ejeYsup,':');
    hold(grafico,'on');
    plot(grafico,ejeX,ejeYinf,':');
    plot(grafico,ejeX,ejeYlevel,':');
    yLimites = ylim(grafico); cla(grafico);
    grafico.YLim = yLimites + [-3 3];
    xp = [ejeX,fliplr(ejeX)]; faceAlpha = .10;
    cotaSup = max(ylim(grafico)); % define top of polygon as top of y axis
    ypMax = [ejeYsup, repmat(cotaSup,size(ejeX))];
    fill(grafico,xp,ypMax,'g','facealpha',faceAlpha,'LineStyle','none');
    cotaInf = min(ylim(grafico));  % define bottom of polygon as bottom of y axis
    ypMin = [ejeYinf, repmat(cotaInf,size(ejeX))];
    fill(grafico,xp,ypMin,'r','facealpha',faceAlpha,'LineStyle','none');
    ypMed = [ejeYinf, ejeYsup];
    fill(grafico,xp,ypMed,[1 0.65 0],'facealpha',faceAlpha,'LineStyle','none');
    % draw the lines of the RSSI plot
    clear hFig; k = 1; colores = colororder; xLim = [ejeX(end) ejeX(1)];
    for i=1:length(sensorNodes.automatic.deveui)
     if sensorNodes.automatic.enableRSSIPlot(i) && sum(~isnan(histRSSI{i}))
      ejeY = histRSSI{i};
      ejeX = histTiempo{i};
      auxLim = ejeX; if auxLim(1) < xLim(1), xLim(1) = auxLim(1); end; if auxLim(end) > xLim(2), xLim(2) = auxLim(end); end
%      hFig(k) = plot(grafico,ejeX,ejeY,'-','Color',colores(k,:),...
%                     'DisplayName',char(strcat(sensorNodes.automatic.deveui(i)," [ ",sensorNodes.automatic.label(i,:)," ]")));
      hFig(k) = plot(grafico,ejeX,ejeY,'-','Color',colores(k,:),...
                     'DisplayName',char(sensorNodes.automatic.deveui(i)));
      hold(grafico,'on'); k = k+1;
     end
    end
    legend(grafico,hFig,'Location','best');
    if xLim(1)==xLim(2), grafico.XLim = xLim + [-1/24/60/60 1/24/60/60]; else, grafico.XLim = xLim; end
    grafico.YLabel.String = 'rssi';
    grafico.XAxis.Visible = 'off';
    % initialize the graphical area for the channel plot
    set(graficoAux,'Visible','on');
    set(graficoAux.Children,'Visible','on');
    axis(graficoAux,'auto');
    cla(graficoAux);
    legend(graficoAux,'off');
    % draw the lines of the channel plot
    ejeY = histChannel;
    ejeX = histTiempo;
    % draw the lines of the requested channels plot
    clear hFig; k = 1; colores = colororder;
    for i=1:length(sensorNodes.automatic.deveui)
     if sensorNodes.automatic.enableRSSIPlot(i)
      %idx = sensorNodes.automatic.histDevEUI==i;
      %auxEjeY = NaN * ones(size(ejeY)); auxEjeY(idx) = ejeY(idx);
      %[auxEjeX,~,idx] = unique(ejeX); auxEjeY = accumarray(idx(:),auxEjeY(:));
      auxEjeY = ejeY{i}; auxEjeX = ejeX{i};
%      hFig(k) = bar(graficoAux,auxEjeX,auxEjeY,.5,'EdgeColor',colores(k,:),'FaceColor',colores(k,:),'LineWidth',4,'BaseValue',-.9,'ShowBaseLine','off',...
%                    'DisplayName',char(strcat("Channel ID of ",sensorNodes.automatic.deveui{i},' [ ',sensorNodes.automatic.label(i,:),' ]')));
%      hFig(k) = bar(graficoAux,auxEjeX,auxEjeY,.5,'EdgeColor',colores(k,:),'FaceColor',colores(k,:),'BaseValue',-.9,'ShowBaseLine','off',...
%                    'DisplayName',char(strcat("Channel ID of ",sensorNodes.automatic.deveui{i},' [ ',sensorNodes.automatic.label(i,:),' ]')));
      hFig(k) = bar(graficoAux,auxEjeX,auxEjeY,.5,'EdgeColor',colores(k,:),'FaceColor',colores(k,:),'BaseValue',-.9,'ShowBaseLine','off',...
                    'DisplayName',char(strcat("Channel ID of ",sensorNodes.automatic.deveui{i})));
      % linkaxes([graficoAux, grafico], "x");
      % text(hFig(k).XEndPoints,hFig(k).YEndPoints,string(hFig(k).YData),'HorizontalAlignment','center','VerticalAlignment','bottom');
      hold(graficoAux,'on'); k = k+1;
     end
    end
    % legend(graficoAux,hFig,'Location','best');
    % if xLim(2)>xLim(1), graficoAux.XLim = xLim; end
    graficoAux.YTick = 1:7;
    graficoAux.YLim = [-.1 graficoAux.YTick(end)+.9];
    graficoAux.YGrid = 'on';
    graficoAux.XLim = grafico.XLim;
    graficoAux.YLabel.String = 'channel';
   % if RSSI plot is not requested and a battery plot is requested
   elseif isfield(sensorNodes.automatic,'enableRSSIPlot') && ...
          sum(sensorNodes.automatic.enableBatteryPlot) && ...
          ~sum(sensorNodes.automatic.enableRSSIPlot)
    set(grafico,'Visible','on');
    set(grafico.Children,'Visible','on');
    axis(grafico,'auto');
    cla(grafico);
    legend(grafico,'off');
    grafico.Position = defaultPosition_grafico;
    set(graficoAux,'Visible','off');
    legend(graficoAux,'off');
    cla(graficoAux);
    % extract the battery values
    ejeY = sensorNodes.automatic.histValor(LoRa.indexBAT,:);
    ejeX = sensorNodes.automatic.histTiempo;
    % draw the lines of the requested battery plot
    clear hFig; k = 1; colores = colororder; xLim = [ejeX(end) ejeX(1)];
    for i=1:length(sensorNodes.automatic.deveui)
     if sensorNodes.automatic.enableBatteryPlot(i)
      idx = sensorNodes.automatic.histDevEUI==i;
      auxEjeY = ejeY(idx);
      auxEjeX = ejeX(idx);
      idx = ~any(isnan(auxEjeY),1);
      if sum(idx)
       auxLim = auxEjeX(idx); if auxLim(1) < xLim(1), xLim(1) = auxLim(1); end; if auxLim(end) > xLim(2), xLim(2) = auxLim(end); end
      end
      if sum(idx)<length(idx)
       plot(grafico,auxEjeX(idx),auxEjeY(idx),':','Color',colores(k,:));
       hold(grafico,'on');
      end
%     hFig(k) = plot(grafico,auxEjeX,auxEjeY,'-','Color',colores(k,:),...
%                    'DisplayName',char(strcat(LoRa.keys{10}(2)," (",char(LoRa.keys{10}(3)),") of ",sensorNodes.automatic.deveui{i},' [ ',sensorNodes.automatic.label(i,:),' ]')));
      hFig(k) = plot(grafico,auxEjeX,auxEjeY,'-','Color',colores(k,:),...
                    'DisplayName',char(strcat(LoRa.keys{LoRa.indexBAT}(5)," (",char(LoRa.keys{LoRa.indexBAT}(6)),") of ",sensorNodes.automatic.deveui{i})));
      hold(grafico,'on'); k = k+1;
     end
    end
    legend(grafico,hFig,'Location','best');
    if xLim(2)>xLim(1), grafico.XLim = xLim; end
    grafico.YLim = grafico.YLim + [-.1 .1];
    grafico.YLabel.String = '';
    grafico.XAxis.Visible = 'on';
   % if RSSI neither battery plot are not requested and the adquired values sensor are requested
   elseif isfield(sensorNodes.automatic,'enablePlot') && ...
          ~isempty(TABLA) && ...
          sum(cell2mat(TABLA(:,4))) && ...
          ~sum(sensorNodes.automatic.enableRSSIPlot)
    set(grafico,'Visible','on');
    set(grafico.Children,'Visible','on');
    axis(grafico,'auto');
    cla(grafico);
    legend(grafico,'off');
    grafico.Position = defaultPosition_grafico;
    set(graficoAux,'Visible','off');
    legend(graficoAux,'off');
    cla(graficoAux);
    % extract the values related to enabled DevEUI's filter
    if isempty(find(sensorNodes.automatic.enableFilter,1))
     idx = true(1,size(sensorNodes.automatic.histDevEUI,2));
    else
     idx = false(1,size(sensorNodes.automatic.histDevEUI,2));
     for i=find(sensorNodes.automatic.enableFilter)
      idx = idx | sensorNodes.automatic.histDevEUI==i;
     end
    end
    ejeY = sensorNodes.automatic.histValor(:,idx);
    ejeX = sensorNodes.automatic.histTiempo(:,idx);
    % draw the lines of the requested graph
    clear hFig; k = 1; colores = colororder; xLim = [ejeX(1) ejeX(end)];
    for i=1:size(TABLA,1)
     if cell2mat(TABLA(i,4))
      auxEjeY = ejeY(valueSensors.UserData(i),:);
      auxEjeX = ejeX;
      idx = ~any(isnan(auxEjeY),1);
      auxLim = auxEjeX(idx); if ~isempty(auxLim) && auxLim(1) < xLim(1), xLim(1) = auxLim(1); end; if ~isempty(auxLim) && auxLim(end) > xLim(2), xLim(2) = auxLim(end); end
      if sum(idx)<length(idx)
       plot(grafico,auxEjeX(idx),auxEjeY(idx),':','Color',colores(k,:));
       hold(grafico,'on');
      end
      hFig(k) = plot(grafico,auxEjeX,auxEjeY,LoRa.typePlot,'Color',colores(k,:),...
                     'DisplayName',char(strcat(TABLA{i,1}," (",char(TABLA{i,3}),")")));
      hold(grafico,'on'); k = k+1;
     end
    end
    legend(grafico,hFig,'Location','best');
    if xLim(1)==xLim(2), grafico.XLim = xLim + [-1/24/60/60 1/24/60/60]; else, grafico.XLim = xLim; end
    grafico.YLabel.String = '';
    grafico.XAxis.Visible = 'on';
   % to update the physiologic charts of the requested agent, if values exist in data structure
   elseif strcmp(entidad,'Agent') && existsPhysiologic
    ejeY = valuesPhysiologic.value;
    ejeX = valuesPhysiologic.time;
    plot(graficoPhysiologic1,ejeX,ejeY(:,1));
    plot(graficoPhysiologic2,ejeX,ejeY(:,2));
    plot(graficoPhysiologic3,ejeX,ejeY(:,3));
    area(graficoPhysiologic4,ejeX,ejeY(:,4),'LineStyle','none','FaceColor','r','FaceAlpha',0.5);
    intervalSize = 30; % timeIntervalCharts;
    if isnan(intervalSize), xLim = [ejeX(1) ejeX(end)];
    else
     i=1; limTime = ejeX(end)-intervalSize*(10/60/4/60/60);
     while ejeX(i)<limTime, i=i+1; end
     xLim = [ejeX(i) ejeX(end)];
     %xLim = [ejeX(end-(intervalSize*100)) ejeX(end)];
    end
    graficoPhysiologic1.XLim = xLim;
    graficoPhysiologic1.YLim = [-2 2];
    graficoPhysiologic2.XLim = graficoPhysiologic1.XLim;
    graficoPhysiologic2.YLim = [0 25];
    graficoPhysiologic3.XLim = graficoPhysiologic1.XLim;
    graficoPhysiologic3.YLim = [-50 50];
    graficoPhysiologic4.XLim = graficoPhysiologic1.XLim;
    graficoPhysiologic1.YLabel.String = 'ECG (mV)';
    graficoPhysiologic2.YLabel.String = 'EDA (\muS)';
    graficoPhysiologic3.YLabel.String = 'PZT (%)';
    set(graficoPhysiologic1,'Visible','on');
    set(graficoPhysiologic2,'Visible','on');
    set(graficoPhysiologic3,'Visible','on');
    graficoPhysiologic4.XAxis.Visible = 'off';
    graficoPhysiologic4.YAxis.Visible = 'off';
    set(graficoPhysiologic4,'Visible','on');
   else
    set(grafico,'Visible','off');
    legend(grafico,'off');
    grafico.XAxis.Visible = 'off';
    cla(grafico);
    set(graficoAux,'Visible','off');
    legend(graficoAux,'off');
    cla(graficoAux);
    %graficoPhysiologic1.XAxis.Visible = 'off';
    %graficoPhysiologic2.XAxis.Visible = 'off';
    %graficoPhysiologic3.XAxis.Visible = 'off';
    if strcmp(entidad,'Agent')
     set(graficoPhysiologic1,'Visible','off');
     cla(graficoPhysiologic1);
     set(graficoPhysiologic2,'Visible','off');
     cla(graficoPhysiologic2);
     set(graficoPhysiologic3,'Visible','off');
     cla(graficoPhysiologic3);
     set(graficoPhysiologic4,'Visible','off');
     cla(graficoPhysiologic4);
    end
   end
  end
  grafico.Toolbar.Visible = 'on';
  graficoAux.Toolbar.Visible = 'on';
 end
end

% --- Executes on button press in editTarget_button.
function editObjetivo_button_Callback(hObject, ~, handles)
% can be called from addTarget_button_Callback function
global data
 ClickOnAux3Tab(handles.a32,[],handles);
 % solo est habilitado el registro automtico de sensores, no por el usuario
 % set(handles.addTarget_button,'Visible','off');
 set(handles.idObjetivo,'Enable','inactive');
 set(handles.removeObjetivo_button,'Visible','off');
 set(handles.editObjetivo_button,'Visible','off');
 set(handles.idFullObjetivo,'Enable','on');
 set(handles.visibleObjetivo,'Enable','on');
 set(handles.modoPosicionObjetivo,'Enable','on');
 set(handles.radioUTMObjetivo,'Enable','on');
 if ~data.entorno.tipo, set(handles.radioGEOObjetivo,'Enable','on'); end
 radioUnitObjetivo(handles,false);
 modoPosicionObjetivo_Callback([],[],handles);
 set(handles.minUmbralObjetivo,'Enable','on');
 set(handles.maxUmbralObjetivo,'Enable','on');
 set(handles.aproximacionObjetivo,'Enable','on');
 set(handles.enableAproxObjetivo,'Enable','on');
 set(handles.actividadObjetivo,'Enable','on');
 set(handles.radioCoeficientObjetivo,'Enable','on');
 set(handles.radioPercentObjetivo,'Enable','on');
 set(handles.radioTimeObjetivo,'Enable','on');
 set(handles.radioHybridObjetivo,'Enable','on');
 set(handles.coefPotencialPos_Objetivo,'Enable','on');
 set(handles.coefPotencialNeg_Objetivo,'Enable','on');
 set(handles.prioridadObjetivo,'Enable','on');
 set(handles.temperatureEvent,'Enable','on');
 set(handles.timeEvent,'Enable','on');
 set(handles.patternObjetivo,'Enable','on');
 set(handles.triggeredEventObjetivo,'Enable','on');
 set(handles.enableObjetivo,'Enable','on');
 set(handles.radioUTMObjetivo_status,'Enable','on');
 if ~data.entorno.tipo, set(handles.radioGEOObjetivo_status,'Enable','on'); end
 set(handles.ObjetivoOK_button,'Visible','on');
 set(handles.ObjetivoCANCEL_button,'Visible','on');
end

% --- Executes on button press in addTarget_button.
function addObjetivo_button_Callback(~,~, handles)
  % no se permite aadir targets por el usuario
  % solo registro automtico por deteccin de grupos sensoriales
end

% --- Executes on button press in removeTarget_button.
function removeObjetivo_button_Callback(~,~, handles)
global data general
 set(handles.enabledRemove,'Value',0);
 enabledRemove_Callback(handles.enabledRemove,[],handles);
 idObjetivo = get(handles.idObjetivo,'Value');
 numObjetivos = get(handles.numObjetivos,'Value')-1;
 set(handles.numObjetivos,'Value',numObjetivos);
 set(handles.numObjetivos,'String',num2str(get(handles.numObjetivos,'Value')));
 if ~numObjetivos
  set(handles.idObjetivo,'String','');
  data = rmfield(data,'sensorNodes');
  set(handles.idObjetivo,'Enable','inactive');
  set(handles.removeObjetivo_button,'Visible','off');
  set(handles.editObjetivo_button,'Visible','off');
  set(handles.PLANNER_button,'Enable','off');
 else
  data.sensorNodes(idObjetivo) = [];
 end
 if idObjetivo > numObjetivos && numObjetivos
  set(handles.idObjetivo,'Value',numObjetivos);
  set(handles.idObjetivo,'String',num2str(get(handles.idObjetivo,'Value')));
 end
 editObjetivo(handles);
 data.objetivosUpdated = 0;
 %if isfield(data,'planner') && isfield(data.planner,'optima'), data.planner = rmfield(data.planner,'optima'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 ClickOnAux3Tab(handles.a31,[],handles);
end

% --- Executes on selection change in idFullTarget.
function idFullObjetivo_Callback(hObject, ~, handles)
 set(handles.idFullObjetivo_status,'String',get(hObject,'String'));
end

% --- Executes on button press in visibleTarget.
function visibleObjetivo_Callback(~,~, handles)
global data
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in modoPosicionTarget.
function modoPosicionObjetivo_Callback(~,~, handles)
% to manage the button and functionality of changing target's position mode
% can be called from editTarget, editTarget_button_Callback, addTarget_button_Callback functions
 set(handles.posXObjetivo,'Enable','inactive');
 set(handles.posYObjetivo,'Enable','inactive');
 switch get(handles.modoPosicionObjetivo,'Value')
  case 2
   set(handles.pickObjetivo_button,'String','Pick');
   set(handles.pickObjetivo_button,'Visible','on');
   if strcmp(get(handles.editObjetivo_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickObjetivo_button,'Enable',state);
  case 3
   set(handles.pickObjetivo_button,'Visible','off');
  case 4
   %%% Note:
   set(handles.pickObjetivo_button,'String','N/D');
   set(handles.pickObjetivo_button,'Visible','off');
   if strcmp(get(handles.editObjetivo_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickObjetivo_button,'Enable',state);
  case 1
   set(handles.pickObjetivo_button,'Visible','off');
   if isempty(get(handles.idObjetivo,'String')), state = 'inactive'; else, state = 'on'; end
   set(handles.posXObjetivo,'Enable',state);
   set(handles.posYObjetivo,'Enable',state);
 end
end

% --- Executes on button press in pickTarget_button.
function [punto] = pickObjetivo_button_Callback(~,~, handles)
% to manage the button for position select by picking in map
%%% Note:
global data
 punto = [];
 switch get(handles.modoPosicionObjetivo,'Value')
  case 2
   set(handles.radioUTMObjetivo,'Value',1);
   radioUnitObjetivo(handles,false);
   axes(handles.figura);
   punto = PuntoInsercion(data.entorno,ginput(1));
   set(handles.posXObjetivo,'Value',punto(1));
   set(handles.posXObjetivo,'String',num2str(get(handles.posXObjetivo,'Value')));
   set(handles.posYObjetivo,'Value',punto(2));
   set(handles.posYObjetivo,'String',num2str(get(handles.posYObjetivo,'Value')));
   posXObjetivo_Callback(handles.posXObjetivo,[],handles);
   posYObjetivo_Callback(handles.posYObjetivo,[],handles);
   radioUnitObjetivo(handles,false);
  %%% Note:
  case 4
 end
 data.objetivosUpdated = 0;
end

% --- Executes when selected object is changed in radioUnitAgent.
function radioUnitObjetivo_SelectionChangedFcn(~,~, handles)
 radioUnitObjetivo(handles,false);
end

% --- Executes when selected object is changed in radioUnitAgent.
function radioUnitObjetivo_status_SelectionChangedFcn(~,~, handles)
 radioUnitObjetivo(handles,true);
end

% --- Auxiliary function for two previous ones --- *
function radioUnitObjetivo(handles,status)
% to manage the change of physical unit for positions coordinates
% status  - boolean: indicating use of status (true) or settings (false) tag
global data
 if ~status
  radioUTM = handles.radioUTMObjetivo; radioGEO = handles.radioGEOObjetivo;
  posX = handles.posXObjetivo; unitX = handles.unitX_objetivo;
  posY = handles.posYObjetivo; unitY = handles.unitY_objetivo;
  warnPos = handles.warnPosObjetivo;
 else
  radioUTM = handles.radioUTMObjetivo_status; radioGEO = handles.radioGEOObjetivo_status;
  posX = handles.posXObjetivo_status; unitX = handles.unitX_objetivo_status;
  posY = handles.posYObjetivo_status; unitY = handles.unitY_objetivo_status;
  warnPos = handles.warnPosObjetivo_status;
 end
 if get(radioUTM,'Value')
  pos = get(posX,'Position'); pos(3)=130;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 408; pos(3)=10;
  set(unitX,'Position',pos);
  set(unitX,'String',',');
  pos = get(posY,'Position'); pos(1) = 421; pos(3)=130;
  set(posY,'Position',pos);
  set(unitY,'String','meter');
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%16.3f",get(posX,'Value')));
   set(posY,'String',sprintf("%16.3f",get(posY,'Value')));
  else
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 if get(radioGEO,'Value')
  pos = get(posX,'Position'); pos(3)=105;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 381; pos(3)=50;
  set(unitX,'Position',pos);
  set(unitX,'String',[char(176),'North']);
  pos = get(posY,'Position'); pos(1) = 446; pos(3)=105;
  set(posY,'Position',pos);
  set(unitY,'String',[char(176),'East']);
  X = get(posX,'Value'); Y = get(posY,'Value');
  punto = round(GPSutm2ll(X,Y,30),8);
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%10.8f",point(1)));
   set(posY,'String',sprintf("%10.8f",point(2)));
  else
   set(warnPos,'Visible','on');
   set(handles.enableObjetivo,'Value',0);
   set(handles.enableObjetivo,'Enable','off');
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
 minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
 valX = get(posX,'Value'); valY = get(posY,'Value');
 if isempty(get(posX,'String')) && isempty(get(posY,'String'))
  set(warnPos,'Visible','on');
  set(handles.enableObjetivo,'Value',0);
  %set(handles.enableTarget,'Enable','off');
 elseif valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
  set(warnPos,'Visible','on');
  set(handles.enableObjetivo,'Value',0);
  %set(handles.enableTarget,'Enable','off');
 else
  set(warnPos,'Visible','off');
  set(handles.enableObjetivo,'Enable','on');
 end
end

% --- Executes on selection change in posXTarget.
function posXObjetivo_Callback(hObject,~, handles)
global data
 if get(handles.radioUTMObjetivo,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(hObject,'String')),...
                          str2double(get(handles.posYObjetivo,'String')),30),...
                8);
  set(hObject,'Value',punto(1));
  set(handles.posYObjetivo,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN)
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(hObject,'Value'); valY = get(handles.posYObjetivo,'Value');
  if valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
   idObjetivo = get(handles.idObjetivo,'Value');
   set(hObject,'Value',data.sensorNodes(idObjetivo).user.posicion(1));
   set(handles.posYObjetivo,'Value',data.sensorNodes(idObjetivo).user.posicion(2));
   radioUnitObjetivo_SelectionChangedFcn(hObject,[],handles);
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates';'The value must belong to the environmental dimensions';prompt},hObject,handles);
  end
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in posYTarget.
function posYObjetivo_Callback(hObject, ~, handles)
global data
 if get(handles.radioUTMObjetivo,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(handles.posXObjetivo,'String')),...
                          str2double(get(hObject,'String')),30),...
                8);
  set(handles.posXObjetivo,'Value',punto(1));
  set(hObject,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN);
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(handles.posXObjetivo,'Value'); valY = get(hObject,'Value');
  if valY < minimoY || valY > maximoY || valX < minimoX || valX > maximoX
   idObjetivo = get(handles.idObjetivo,'Value');
   set(handles.posXObjetivo,'Value',data.sensorNodes(idObjetivo).user.posicion(1));
   set(hObject,'Value',data.sensorNodes(idObjetivo).user.posicion(2));
   radioUnitObjetivo_SelectionChangedFcn(hObject,[],handles);
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates';'The value must belong to the environmental dimensions';prompt},hObject,handles);
  end
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in minUmbralTarget.
function minUmbralObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') > get(handles.maxUmbralObjetivo,'Value')
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Wireless signal strength threshold.';...
           'The minimum threshold must be lower or equal than the maximum one.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.minUmbral);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in maxUmbralTarget.
function maxUmbralObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') < get(handles.minUmbralObjetivo,'Value')
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Wireless signal strength threshold.';...
           'The minimum threshold must be lower or equal than the maximum one.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.maxUmbral);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in aproximacionTarget.
function aproximacionObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < 0
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Aproach distance.';...
           'The value must be positive.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.aproximacion);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in orientacionTarget.
function orientacionObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 if isempty(get(hObject,'String')), set(hObject,'Value',NaN);
 else, set(hObject,'Value',str2double(get(hObject,'String'))); end
 if get(hObject,'Value')<-180 || get(hObject,'Value')>180
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Approach orientation.';...
           'The value must be between -180 and 180 degrees.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.orientacion*180/pi());
  if isnan(data.sensorNodes(idObjetivo).user.orientacion), set(hObject,'String','');
  else, set(hObject,'String',num2str(get(hObject,'Value'))); end
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in actividadTarget.
function actividadObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < 0
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Activity time.';...
           'The value must be positive.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.actividad);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

%%% Note:
% conjunto de opciones disponibles: coeficiente, porcentual, tiempo e hbrido

% --- Executes on selection change in coefPotencialPos_Target.
function coefPotencialPos_Objetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -100000 || get(hObject,'Value') > 100000
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Penalty slope rate.';...
           'The values must be between minus fifty and a hundred thousand.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.coefPos);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in coefPotencialNeg_Target.
function coefPotencialNeg_Objetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -100000 || get(hObject,'Value') > 100000
  set(hObject,'Enable','off');
  set(handles.ObjetivoOK_button,'Visible','off');
  set(handles.ObjetivoCANCEL_button,'Visible','off');
  warning({'Error: Penalty slope rate.';...
           'The values must be between minus fifty and a hundred thousand.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
  set(hObject,'Value',data.sensorNodes(idObjetivo).user.coefNeg);
  set(hObject,'String',num2str(get(hObject,'Value')));
  set(handles.ObjetivoOK_button,'Visible','on');
  set(handles.ObjetivoCANCEL_button,'Visible','on');
  set(hObject,'Enable','on'); uicontrol(hObject);
 end
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in prioridadTarget.
function prioridadObjetivo_Callback(~,~, handles)
global data
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in temperatureEvent.
function temperatureEvent_Callback(hObject, ~, handles)
%global data
 %idTarget = get(handles.idTarget,'Value');
 if isempty(get(hObject,'String')), set(hObject,'Value',NaN);
 else, set(hObject,'Value',str2double(get(hObject,'String'))); end
end

% --- Executes on selection change in timeEvent.
function timeEvent_Callback(hObject, ~, handles)
%global data
 %idTarget = get(handles.idTarget,'Value');
 if isempty(get(hObject,'String')), set(hObject,'Value',NaN);
 else, set(hObject,'Value',str2double(get(hObject,'String'))); end
end

% --- Executes on selection change in patternTarget.
function patternObjetivo_Callback(~,~, handles)
global data
 data.objetivosUpdated = 0;
end

% --- Executes on button press in triggeredEventTarget.
function triggeredEventObjetivo_Callback(hObject, ~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 data.sensorNodes(idObjetivo).user.event = get(hObject,'Value');
 set(handles.statusEventObjetivo,'Visible',data.sensorNodes(idObjetivo).user.event)
 data.objetivosUpdated = 0;
end

% --- Executes on selection change in gatewaysIDs.
function gatewaysIDs_Callback(~,~, handles)
 updateTable(handles,'Target',false);
 runGrafica(handles,'Target',false);
end

% --- Executes when entered data in editable cell(s) in sensorIDs.
function sensorIDs_CellEditCallback(~,~, handles)
global data
 idObjetivo = get(handles.idObjetivo,'Value');
 TABLA = get(handles.sensorIDs,'Data');
 for i = 1:size(TABLA,1)
  data.sensorNodes(idObjetivo).automatic.enableFilter(i) = TABLA{i,2};    
  data.sensorNodes(idObjetivo).automatic.enableRSSIPlot(i) = TABLA{i,6};
  data.sensorNodes(idObjetivo).automatic.enableBatteryPlot(i) = TABLA{i,8};
 end
 updateTable(handles,'Target',false);
 runGrafica(handles,'Target',false);
end

% --- Executes on button press in enableFreezeTarget.
function enableFreezeObjetivo_Callback(~,~, handles)
global data
 if isfield(data,'sensorNodes')
  idObjetivo = get(handles.idObjetivo,'Value');
  if idObjetivo <= length(data.sensorNodes)
   data.sensorNodes(idObjetivo).user.enableFreeze = get(handles.enableFreezeObjetivo,'Value');
   % data.targetsUpdated = 1;
  end
 end
end

% --- Executes when entered data in editable cell(s) in valueSensors.
function valueSensors_CellEditCallback(~,~, handles)
global data general LoRa %%% Zigbee
 idObjetivo = get(handles.idObjetivo,'Value');
 TABLA = get(handles.valueSensors,'Data');
 for i = 1:size(TABLA,1)
  for j = 1:length(LoRa.keys)
   if strcmp(LoRa.keys{j}(5),TABLA{i,1})
    data.sensorNodes(idObjetivo).automatic.enablePlot(j) = TABLA{i,4};
    data.sensorNodes(idObjetivo).automatic.enableMap(j) = TABLA{i,5};
   end
  end
 end
 runGrafica(handles,'Target',false);
 general.updated = true;
end

% --- Executes on button press in TargetOK_button.
function ObjetivoOK_button_Callback(~,~, handles)
global data general
 % set(handles.defaultTargets,'Enable','on');
 set(handles.ObjetivoOK_button,'Visible','off');
 set(handles.ObjetivoCANCEL_button,'Visible','off');
 idObjetivo             = get(handles.idObjetivo,'Value');
 idFullObjetivo         = get(handles.idFullObjetivo,'String');
 visibleObjetivo        = get(handles.visibleObjetivo,'Value');
 modoPosicion           = get(handles.modoPosicionObjetivo,'Value');
 unidad                 = get(handles.radioUTMObjetivo,'Value');
 punto(1)               = get(handles.posXObjetivo,'Value');
 punto(2)               = get(handles.posYObjetivo,'Value');
 minUmbral              = get(handles.minUmbralObjetivo,'Value');
 maxUmbral              = get(handles.maxUmbralObjetivo,'Value');
 aproximacion           = get(handles.aproximacionObjetivo,'Value');
 orientacion            = get(handles.orientacionObjetivo,'Value');
 enableAproximacion     = get(handles.enableAproxObjetivo,'Value');
 tiempoActividad        = get(handles.actividadObjetivo,'Value');
 modoCoeficiente        = get(handles.radioCoeficientObjetivo,'Value');
 coefPositivo           = get(handles.coefPotencialPos_Objetivo,'Value');
 coefNegativo           = get(handles.coefPotencialNeg_Objetivo,'Value');
 prioridad              = get(handles.prioridadObjetivo,'Value');
 temperatureEvent       = get(handles.temperatureEvent,'Value');
 timeEvent              = get(handles.timeEvent,'Value');
 pattern                = get(handles.patternObjetivo,'String');
 event                  = get(handles.triggeredEventObjetivo,'Value');
 enablePlanning         = get(handles.enableObjetivo,'Value');
 enableFreeze           = get(handles.enableFreezeObjetivo,'Value');
 data.sensorNodes(idObjetivo).user = ObjetivoInsertar( data.entorno,idFullObjetivo,visibleObjetivo,modoPosicion,unidad,punto,minUmbral,maxUmbral,...
                                                       aproximacion,orientacion,enableAproximacion,...
                                                       tiempoActividad,modoCoeficiente,coefPositivo,coefNegativo,...
                                                       prioridad,temperatureEvent,timeEvent,pattern,event,enablePlanning,enableFreeze);
 set(handles.idObjetivo,'Enable','on');
 % set(handles.addTarget_button,'Visible','on');
 set(handles.removeObjetivo_button,'Visible','on');
 set(handles.editObjetivo_button,'Visible','on');
 set(handles.idFullObjetivo,'Enable','inactive');
 set(handles.visibleObjetivo,'Enable','inactive');
 set(handles.modoPosicionObjetivo,'Enable','inactive');
 set(handles.pickObjetivo_button,'Visible','off');
 set(handles.radioUTMObjetivo,'Enable','inactive');
 set(handles.radioGEOObjetivo,'Enable','inactive');
 set(handles.posXObjetivo,'Enable','inactive');
 set(handles.posXObjetivo_status,'Value',get(handles.posXObjetivo,'Value'));
 set(handles.posYObjetivo,'Enable','inactive');
 set(handles.posYObjetivo_status,'Value',get(handles.posYObjetivo,'Value'));
 radioUnitObjetivo(handles,false);
 set(handles.minUmbralObjetivo,'Enable','inactive');
 set(handles.maxUmbralObjetivo,'Enable','inactive');
 set(handles.aproximacionObjetivo,'Enable','inactive');
 set(handles.orientacionObjetivo,'Enable','inactive');
 set(handles.enableAproxObjetivo,'Enable','inactive');
 set(handles.actividadObjetivo,'Enable','inactive');
 set(handles.radioCoeficientObjetivo,'Enable','inactive');
 set(handles.radioPercentObjetivo,'Enable','inactive');
 set(handles.radioTimeObjetivo,'Enable','inactive');
 set(handles.radioHybridObjetivo,'Enable','inactive');
 set(handles.coefPotencialPos_Objetivo,'Enable','inactive');
 set(handles.coefPotencialNeg_Objetivo,'Enable','inactive');
 set(handles.prioridadObjetivo,'Enable','inactive');
 set(handles.temperatureEvent,'Enable','inactive');
 set(handles.timeEvent,'Enable','inactive');
 set(handles.patternObjetivo,'Enable','inactive');
 set(handles.triggeredEventObjetivo,'Enable','inactive');
 set(handles.radioUTMObjetivo_status,'Value',get(handles.radioUTMObjetivo,'Value'));
 set(handles.radioGEOObjetivo_status,'Value',~get(handles.radioUTMObjetivo,'Value'));
 radioUnitObjetivo(handles,true);
 runGraficaObjetivo(handles);
 if isfield(data,'planner'), data = rmfield(data,'planner'); end
 if isfield(data,'agentes'), set(handles.PLANNER_button,'Enable','on'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 ClickOnAux3Tab(handles.a31,[],handles);
end

% --- Executes on button press in TargetCANCEL_button.
function ObjetivoCANCEL_button_Callback(~,~, handles)
global data
 % set(handles.defaultTargets,'Enable','on');
 set(handles.ObjetivoOK_button,'Visible','off');
 set(handles.ObjetivoCANCEL_button,'Visible','off');
 idObjetivo    = get(handles.idObjetivo,'Value');
 numObjetivos  = get(handles.numObjetivos,'Value');
 if numObjetivos < idObjetivo
  set(handles.idObjetivo,'String','');
  set(handles.idObjetivo,'Value',0);
  % set(handles.valueSensors,'Enable','inactive');
 elseif numObjetivos
  set(handles.removeObjetivo_button,'Visible','on');
 end
 % set(handles.addTarget_button,'Visible','on');
 set(handles.idObjetivo,'Enable','on');
 if idObjetivo <= numObjetivos, set(handles.editObjetivo_button,'Visible','on'); end
 editObjetivo(handles);
 set(handles.idFullObjetivo,'Enable','inactive');
 set(handles.visibleObjetivo,'Enable','inactive');
 set(handles.modoPosicionObjetivo,'Enable','inactive');
 set(handles.pickObjetivo_button,'Visible','off');
 set(handles.radioUTMObjetivo,'Enable','inactive');
 set(handles.radioGEOObjetivo,'Enable','inactive');
 set(handles.posXObjetivo,'Enable','inactive');
 set(handles.posYObjetivo,'Enable','inactive');
 set(handles.minUmbralObjetivo,'Enable','inactive');
 set(handles.maxUmbralObjetivo,'Enable','inactive');
 set(handles.aproximacionObjetivo,'Enable','inactive');
 set(handles.orientacionObjetivo,'Enable','inactive');
 set(handles.enableAproxObjetivo,'Enable','inactive');
 set(handles.actividadObjetivo,'Enable','inactive');
 set(handles.radioCoeficientObjetivo,'Enable','inactive');
 set(handles.radioPercentObjetivo,'Enable','inactive');
 set(handles.radioTimeObjetivo,'Enable','inactive');
 set(handles.radioHybridObjetivo,'Enable','inactive');
 set(handles.coefPotencialPos_Objetivo,'Enable','inactive');
 set(handles.coefPotencialNeg_Objetivo,'Enable','inactive');
 set(handles.prioridadObjetivo,'Enable','inactive');
 set(handles.temperatureEvent,'Enable','inactive');
 set(handles.timeEvent,'Enable','inactive');
 set(handles.patternObjetivo,'Enable','inactive');
 set(handles.triggeredEventObjetivo,'Enable','inactive');
 data.objetivosUpdated = 1;
 ClickOnAux3Tab(handles.a31,[],handles);
end

% --- Executes on button press in enableTarget.
function enableObjetivo_Callback(~,~, handles)
% can be called from radioUnitTarget auxiliary function
global data
 if isfield(data,'sensorNodes')
  idObjetivo = get(handles.idObjetivo,'Value');
  aux = get(handles.enableObjetivo,'Value') && strcmp(get(handles.warnPosObjetivo,'Visible'),'off');
  if idObjetivo <= length(data.sensorNodes)
   data.sensorNodes(idObjetivo).user.enable = aux;
   set(handles.enableObjetivo,'Value',aux);
   data.objetivosUpdated = 0;
   if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
      && get(handles.AutomaticPlanning,'Value')
    PLANNER_function(handles);
   end
  end
 end
end


%% ==========================================================================================================================
% --- Tab4Panel: POINTS OF INTEREST (POIs)
% ------------------------------------------

% --- Executes on selection change in idPOI.
function idPOI_Callback(hObject, ~, handles)
% to control the correct number of target identification and (indirectly) view the asociated values of the requested target
 set(hObject,'Enable','off');
 idPOI = str2double(get(hObject,'String'));
 set(hObject,'Value',idPOI);
 ok = ~( isnan(idPOI) || idPOI <= 0 || idPOI > get(handles.numPOIs,'Value') );
 if ok, okStr = 'on';
 else
  okStr = 'off';
  set(hObject,'String','');
  set(hObject,'Value',str2double(get(hObject,'String')));
 end
 set(handles.defaultPOIs,'Visible',okStr);
 set(handles.addPOI_button,'Visible',okStr);
 set(handles.removePOI_button,'Visible',okStr);
 set(handles.editPOI_button,'Visible',okStr);
 editPOI(handles);
 if ~ok
  warning({'Error: Point identification number.';...
           'The value must be between one and the number of points of interest.'},...
           hObject,handles);
  waitfor(handles.warning,'Visible','off');
 end
 set(handles.defaultPOIs,'Visible','on');
 set(handles.addPOI_button,'Visible','on');
 set(hObject,'Enable','on'); uicontrol(hObject);
end

% --- Auxiliary function for previuos one and other functions.
function editPOI(handles)
% to view the asociated values of the requested POI by a given identification number or null
% can be called from eliminarDatos, idPOI_Callback, addPOI_button_Callback, removePOI_button_Callback, POICANCEL_button_Callback functions
global data
 idPOI = get(handles.idPOI,'String');
 auxModo = get(handles.modoPosicionPOI,'String');
 if isempty(idPOI) || ~get(handles.idPOI,'Value') || get(handles.idPOI,'Value') > get(handles.numPOIs,'Value')
  set(handles.idFullPOI,'String','');
  set(handles.visiblePOI,'Value',0);
  set(handles.modoPosicionPOI,'String',auxModo(1:2));
  set(handles.modoPosicionPOI,'Value',1);
  set(handles.radioUTMPOI,'Value',1);
  set(handles.posXPOI,'Value',NaN);
  set(handles.posXPOI,'String','');
  set(handles.posYPOI,'Value',NaN);
  set(handles.posYPOI,'String','');
  set(handles.warnPosPOI,'Visible','off');
  set(handles.minUmbralPOI,'Value',0);
  set(handles.minUmbralPOI,'String','');
  set(handles.maxUmbralPOI,'Value',0);
  set(handles.maxUmbralPOI,'String','');
  set(handles.aproximacionPOI,'Value',0);
  set(handles.aproximacionPOI,'String','');
  set(handles.orientacionPOI,'Value',NaN);
  set(handles.orientacionPOI,'String','');
  set(handles.enableAproxPOI,'Value',0);
  set(handles.actividadPOI,'Value',0);
  set(handles.actividadPOI,'String','');
  set(handles.radioCoeficientPOI,'Value',1);
  set(handles.coefPotencialPos_POI,'Value',0);
  set(handles.coefPotencialPos_POI,'String','');
  set(handles.coefPotencialNeg_POI,'Value',0);
  set(handles.coefPotencialNeg_POI,'String','');
  set(handles.coefPotencialLat_POI,'Value',0);
  set(handles.coefPotencialLat_POI,'String','');
  set(handles.prioridadPOI,'Value',6);
  set(handles.patternPOI,'String','');
  set(handles.triggeredEventPOI,'Value',0);
  set(handles.statusEventPOI,'Visible',0);
  % ----
  for i=1:6, set(handles.(['Prior',num2str(i),'POI']),'Visible','off'); end
  set(handles.idFullPOI_status,'String','');
  set(handles.enablePOI,'Enable','inactive');
  set(handles.enablePOI,'Value',0);
  set(handles.radioUTMPOI_status,'Enable','inactive');
  set(handles.radioGEOPOI_status,'Enable','inactive');
  set(handles.radioGEOPOI_status,'Value',1);
  set(handles.posXPOI_status,'Value',NaN);
  set(handles.posXPOI_status,'String','');
  set(handles.posYPOI_status,'Value',NaN);
  set(handles.posYPOI_status,'String','');
  set(handles.warnPosPOI_status,'Visible','off');
 else
  idPOI = get(handles.idPOI,'Value');
  set(handles.idFullPOI,'String',data.points(idPOI).idFull);
  set(handles.visiblePOI,'Value',data.points(idPOI).visible);
  set(handles.modoPosicionPOI,'String',auxModo(1:2));
  set(handles.modoPosicionPOI,'Value',data.points(idPOI).modoPosicion);
  set(handles.radioUTMPOI,'Value',data.points(idPOI).unidadPosicion);
  set(handles.radioGEOPOI,'Value',~data.points(idPOI).unidadPosicion);
  if isfield(data.points(idPOI),'posicion') && ...
     ~( isnan(data.points(idPOI).posicion(1)) || isnan(data.points(idPOI).posicion(2)) )
   set(handles.posXPOI,'Value',data.points(idPOI).posicion(1));
   set(handles.posXPOI,'String',num2str(get(handles.posXPOI,'value')));
   set(handles.posYPOI,'Value',data.points(idPOI).posicion(2));
   set(handles.posYPOI,'String',num2str(get(handles.posYPOI,'value')));
  else
   set(handles.posXObjetivo,'Value',NaN);
   set(handles.posXObjetivo,'String','');
   set(handles.posYObjetivo,'Value',NaN);
   set(handles.posYObjetivo,'String','');
  end
  radioUnitPOI(handles,false);
  set(handles.minUmbralPOI,'Value',data.points(idPOI).minUmbral);
  set(handles.minUmbralPOI,'String',num2str(get(handles.minUmbralPOI,'value')));
  set(handles.maxUmbralPOI,'Value',data.points(idPOI).maxUmbral);
  set(handles.maxUmbralPOI,'String',num2str(get(handles.maxUmbralPOI,'value')));
  set(handles.aproximacionPOI,'Value',data.points(idPOI).aproximacion);
  if isnan(data.points(idPOI).aproximacion), set(handles.aproximacionPOI,'String','');
  else, set(handles.aproximacionPOI,'String',num2str(get(handles.aproximacionPOI,'value'))); end
  set(handles.orientacionPOI,'Value',data.points(idPOI).orientacion*180/pi());
  if isnan(data.points(idPOI).orientacion), set(handles.orientacionPOI,'String','');
  else, set(handles.orientacionPOI,'String',num2str(get(handles.orientacionPOI,'value'))); end
  set(handles.enableAproxPOI,'Value',data.points(idPOI).enableAprox);
  set(handles.actividadPOI,'Value',data.points(idPOI).actividad);
  set(handles.actividadPOI,'String',num2str(get(handles.actividadPOI,'value')));
  %%% Note:
  switch data.points(idPOI).coeficiente
   case 1, set(handles.radioCoeficientPOI,'Value',1);
   case 2, set(handles.radioPercentualPOI,'Value',1);
   case 3, set(handles.radioTimePOI,'Value',1);
   case 4, set(handles.radioHybridPOI,'Value',1);
  end
  set(handles.coefPotencialPos_POI,'Value',data.points(idPOI).coefPos);
  set(handles.coefPotencialPos_POI,'String',num2str(get(handles.coefPotencialPos_POI,'value')));
  set(handles.coefPotencialNeg_POI,'Value',data.points(idPOI).coefNeg);
  set(handles.coefPotencialNeg_POI,'String',num2str(get(handles.coefPotencialNeg_POI,'value')));
  set(handles.coefPotencialLat_POI,'Value',data.points(idPOI).coefNeg);
  set(handles.coefPotencialLat_POI,'String',num2str(get(handles.coefPotencialLat_POI,'value')));
  %%% Note:
  set(handles.prioridadPOI,'Value',data.points(idPOI).prioridad);
  set(handles.patternPOI,'String',data.points(idPOI).pattern);
  set(handles.triggeredEventPOI,'Value',data.points(idPOI).event);
  % ----
  for i=1:6, set(handles.(['Prior',num2str(i),'POI']),'Visible','off'); end
  set(handles.(['Prior',num2str(data.points(idPOI).prioridad),'POI']),'Position',data.default.PositionIconoPrioridadPOI);
  set(handles.(['Prior',num2str(data.points(idPOI).prioridad),'POI']),'Visible','off');
  set(handles.idFullPOI_status,'String',data.points(idPOI).idFull);
  % Note:
  set(handles.radioUTMPOI_status,'Enable','on');
  set(handles.radioUTMPOI_status,'Value',data.points(idPOI).unidadPosicion);
  set(handles.radioGEOPOI_status,'Enable','on');
  set(handles.radioGEOPOI_status,'Value',~data.points(idPOI).unidadPosicion);
  set(handles.posXPOI_status,'Value',data.points(idPOI).posicion(1));
  set(handles.posYPOI_status,'Value',data.points(idPOI).posicion(2));
  radioUnitPOI(handles,true);
 end
 modoPosicionPOI_Callback([],[],handles);
end

% --- Executes on button press in editPOI_button.
function editPOI_button_Callback(~,~, handles)
global data
 ClickOnAux4Tab(handles.a42,[],handles);
 set(handles.defaultPOIs,'Enable','inactive');
 set(handles.idPOI,'Enable','inactive');
 set(handles.addPOI_button,'Visible','off');
 set(handles.removePOI_button,'Visible','off');
 set(handles.editPOI_button,'Visible','off');
 set(handles.idFullPOI,'Enable','on');
 set(handles.visiblePOI,'Enable','on');
 set(handles.modoPosicionPOI,'Enable','on');
 set(handles.radioUTMPOI,'Enable','on');
 if ~data.entorno.tipo, set(handles.radioGEOPOI,'Enable','on'); end
 radioUnitPOI(handles,false);
 modoPosicionPOI_Callback([],[],handles);
 set(handles.minUmbralPOI,'Enable','on');
 set(handles.maxUmbralPOI,'Enable','on');
 set(handles.aproximacionPOI,'Enable','on');
 set(handles.orientacionPOI,'Enable','on');
 set(handles.enableAproxPOI,'Enable','on');
 set(handles.actividadPOI,'Enable','on');
 set(handles.radioCoeficientPOI,'Enable','on');
 set(handles.radioPercentPOI,'Enable','on');
 set(handles.radioTimePOI,'Enable','on');
 set(handles.radioHybridPOI,'Enable','on');
 set(handles.coefPotencialPos_POI,'Enable','on');
 set(handles.coefPotencialNeg_POI,'Enable','on');
 set(handles.coefPotencialLat_POI,'Enable','on');
 set(handles.prioridadPOI,'Enable','on');
 set(handles.patternPOI,'Enable','on');
 set(handles.triggeredEventPOI,'Enable','on');
 set(handles.enablePOI,'Enable','on');
 set(handles.radioUTMPOI_status,'Enable','on');
 if ~data.entorno.tipo, set(handles.radioGEOPOI_status,'Enable','on'); end
 set(handles.POIOK_button,'Visible','on');
 set(handles.POICANCEL_button,'Visible','on');
end

% --- Executes on button press in addPOI_button.
function addPOI_button_Callback(~,~, handles)
global data
 numPOIs = get(handles.numPOIs,'Value');
 idPOI = numPOIs + 1;
 set(handles.idPOI,'Value',idPOI);
 set(handles.idPOI,'String',num2str(get(handles.idPOI,'Value')));
 editPOI_button_Callback([],[],handles);
 porDefecto = ValoresPOIsPorDefecto(data.entorno);
 if idPOI <= size(porDefecto,1)-1 && get(handles.defaultPOIs,'Value')
  k = idPOI+1; extra = false;
 else
  k = 1; extra = ~get(handles.defaultPOIs,'Value');
 end
 if ~extra
  set(handles.idFullPOI,'String',char(porDefecto(k,1)));
  set(handles.visiblePOI,'Value',0);
  set(handles.patternPOI,'String',char(porDefecto(k,end)));
  porDefecto = cell2mat(porDefecto(k,2:end-1));
  set(handles.posXPOI,'Value',porDefecto(12));
  set(handles.posXPOI,'String',num2str(get(handles.posXPOI,'Value')));
  set(handles.posYPOI,'Value',porDefecto(13));
  set(handles.posYPOI,'String',num2str(get(handles.posYPOI,'Value')));
  set(handles.minUmbralPOI,'Value',porDefecto(1));
  set(handles.minUmbralPOI,'String',num2str(get(handles.minUmbralPOI,'Value')));
  set(handles.maxUmbralPOI,'Value',porDefecto(2));
  set(handles.maxUmbralPOI,'String',num2str(get(handles.maxUmbralPOI,'Value')));
  set(handles.aproximacionPOI,'Value',porDefecto(3));
  set(handles.aproximacionPOI,'String',num2str(get(handles.aproximacionPOI,'Value')));
  set(handles.orientacionPOI,'Value',porDefecto(4));
  if isnan(porDefecto(4)), set(handles.orientacionPOI,'String','');
  else, set(handles.orientacionPOI,'String',num2str(get(handles.orientacionPOI,'Value'))); end
  set(handles.enableAproxPOI,'Value',porDefecto(5));
  set(handles.actividadPOI,'Value',porDefecto(6));
  set(handles.actividadPOI,'String',num2str(get(handles.actividadPOI,'Value')));
  switch porDefecto(7)
   case 1
    set(handles.radioCoeficientPOI,'Value',1);
   case 2
    set(handles.radioPercentPOI,'Value',1);
   case 3
    set(handles.radioTimePOI,'Value',1);
   case 4
    set(handles.radioHybridPOI,'Value',1);
  end
  set(handles.coefPotencialPos_POI,'Value',porDefecto(8));
  set(handles.coefPotencialPos_POI,'String',num2str(get(handles.coefPotencialPos_POI,'Value')));
  set(handles.coefPotencialNeg_POI,'Value',porDefecto(9));
  set(handles.coefPotencialNeg_POI,'String',num2str(get(handles.coefPotencialNeg_POI,'Value')));
  set(handles.coefPotencialLat_POI,'Value',porDefecto(10));
  set(handles.coefPotencialLat_POI,'String',num2str(get(handles.coefPotencialLat_POI,'Value')));
  set(handles.prioridadPOI,'Value',porDefecto(11));
 else
  set(handles.idFullPOI,'String','');
  set(handles.posXPOI,'Value',NaN);
  set(handles.posYPOI,'Value',NaN);
  set(handles.minUmbralPOI,'Value',0);
  set(handles.minUmbralPOI,'String','');
  set(handles.maxUmbralPOI,'Value',0);
  set(handles.maxUmbralPOI,'String','');
  set(handles.aproximacionPOI,'Value',0);
  set(handles.aproximacionPOI,'String','');
  set(handles.orientacionPOI,'Value',NaN);
  set(handles.orientacionPOI,'String','');
  set(handles.enableAproxPOI,'Value',0);
  set(handles.actividadPOI,'Value',0);
  set(handles.actividadPOI,'String','');
  set(handles.radioCoeficientPOI,'Value',1);
  set(handles.coefPotencialPos_POI,'Value',0);
  set(handles.coefPotencialPos_POI,'String','');
  set(handles.coefPotencialNeg_POI,'Value',0);
  set(handles.coefPotencialNeg_POI,'String','');
  set(handles.coefPotencialLat_POI,'Value',0);
  set(handles.coefPotencialLat_POI,'String','');
  set(handles.prioridadPOI,'Value',6);
  set(handles.patternPOI,'String','');
  set(handles.triggeredEventPOI,'Value',0);
 end
 set(handles.modoPosicionPOI,'Value',1);
 radioUnitPOI(handles,false);
 modoPosicionPOI_Callback([],[],handles);
 if ~data.entorno.tipo, set(handles.radioGEOPOI,'Enable','on');
 else, set(handles.radioGEOPOI,'Enable','inactive'); end
 set(handles.idFullPOI_status,'String',get(handles.idFullPOI,'String'));
 set(handles.enablePOI,'Value',0);
 set(handles.posXPOI_status,'Value',get(handles.posXPOI,'Value'));
 set(handles.posYPOI_status,'Value',get(handles.posYPOI,'Value'));
 data.POIsUpdated = 0;
end

% --- Executes on button press in removePOI_button.
function removePOI_button_Callback(~,~, handles)
global data general
 set(handles.enabledRemove,'Value',0);
 enabledRemove_Callback(handles.enabledRemove,[],handles);
 idPOI = get(handles.idPOI,'Value');
 numPOIs = get(handles.numPOIs,'Value')-1;
 set(handles.numPOIs,'Value',numPOIs);
 set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
 if ~numPOIs
  set(handles.idPOI,'String','');
  set(handles.idPOI,'Value',str2double(get(handles.idPOI,'String')));
  data = rmfield(data,'points');
  set(handles.idPOI,'Enable','inactive');
  set(handles.removePOI_button,'Visible','off');
  set(handles.editPOI_button,'Visible','off');
  set(handles.PLANNER_button,'Enable','off');
 else
  data.points(idPOI) = [];
 end
 if idPOI > numPOIs && numPOIs
  set(handles.idPOI,'Value',numPOIs);
  set(handles.idPOI,'String',num2str(get(handles.idPOI,'Value')));
 end
 editPOI(handles);
 data.POIsUpdated = 0;
 %if isfield(data,'planner') && isfield(data.planner,'optima'), data.planner = rmfield(data.planner,'optima'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 ClickOnAux4Tab(handles.a41,[],handles);
end

function [porDefecto] = ValoresPOIsPorDefecto(entorno)
 %%% Note: review default values for the 2023 field exercise.
 if entorno.tipo
  switch entorno.fichero
   %%%% Note: review default values for artificial environments.
   case 'Binary environment based on a maze'
    %              fullID     RSSImin RSSImax  distAprox  Orient   Enable  tActiv  tipoPenaliz k3 k4 kl prioridad     lon(utm)    lat(utm)
    porDefecto = [{''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         13          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         13          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      3         13           2  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      1         13           7  }];
   case 'Binary environment with large accesible areas'
    porDefecto = [{''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         11          47  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         11          47  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      6         29          36  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         45          21  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         47           6  }];
   case {'Environment with large accesible areas and slopes'}
    porDefecto = [{''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2          8          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2          8          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      6          8           4  }];
   case 'Simulated environment with uneven terrain'
    porDefecto = [{''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         16           8  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         16           8  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      3          3          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      1          7          13  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      4         16           3  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2         11          10  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      5         15          16  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      4         11          17  }];
   case 'Very small environment with uneven terrain'
    porDefecto = [{''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2          1           3  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      2          1           3  };...
                  {''          NaN     NaN        0        NaN       0       NaN       1        0  0  0      1          1           2  }];
  end
 else
  %              fullID                 RSSImin RSSImax  distAprox Orient  Enable   tActiv  tipoPenaliz  k3  k4  kl   prioridad      lon(utm)   lat(utm)   pattern
  porDefecto = [{''                       -110    -70       10        NaN     0       60        1        -5   5   0      1           NaN         NaN      '' };
                ];
 end
end

% --- Executes on selection change in idFullPOI.
function idFullPOI_Callback(~,~, handles)
 set(handles.idFullPOI_status,'String',get(handles.idFullPOI,'String'));
end

% --- Executes on button press in visiblePOI.
function visiblePOI_Callback(~,~, handles)
global data
 data.POIsUpdated = 0;
end

% --- Executes on selection change in modoPosicionPOI.
function modoPosicionPOI_Callback(~,~, handles)
% to manage the button and functionality of changing POI's position mode
% can be called from editPOI, editPOI_button_Callback, addPOI_button_Callback functions
 set(handles.posXPOI,'Enable','inactive');
 set(handles.posYPOI,'Enable','inactive');
 switch get(handles.modoPosicionPOI,'Value')
  case 2
   set(handles.pickPOI_button,'String','Pick');
   set(handles.pickPOI_button,'Visible','on');
   if strcmp(get(handles.editPOI_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickPOI_button,'Enable',state);
  case 3
   set(handles.pickPOI_button,'Visible','off');
  case 4
  %%% Note:
   set(handles.pickPOI_button,'String','Update');
   set(handles.pickPOI_button,'Visible','on');
   if strcmp(get(handles.editPOI_button,'Visible'),'on'), state = 'off'; else, state = 'on'; end
   set(handles.pickPOI_button,'Enable',state);
  case 1
   set(handles.pickPOI_button,'Visible','off');
   if isempty(get(handles.idPOI,'String')), state = 'inactive'; else, state = 'on'; end
   set(handles.posXPOI,'Enable',state);
   set(handles.posYPOI,'Enable',state);
 end
end

% --- Executes on button press in pickPOI_button.
function [punto] = pickPOI_button_Callback(~,~, handles)
%%% Note:
global data
 punto = [];
 switch get(handles.modoPosicionPOI,'Value')
  case 2
   set(handles.radioUTMPOI,'Value',1);
   radioUnitPOI(handles,false);
   axes(handles.figura);
   punto = PuntoInsercion(data.entorno,ginput(1));
   set(handles.posXPOI,'Value',punto(1));
   set(handles.posXPOI,'String',num2str(get(handles.posXPOI,'Value')));
   set(handles.posYPOI,'Value',punto(2));
   set(handles.posYPOI,'String',num2str(get(handles.posYPOI,'Value')));
   posXPOI_Callback(handles.posXPOI,[],handles);
   posYPOI_Callback(handles.posYPOI,[],handles);
   radioUnitPOI(handles,false);
  %%% Note:
  case 4
 end
 data.POIsUpdated = 0;
end

% --- Executes when selected object is changed in radioUnitPOI.
function radioUnitPOI_SelectionChangedFcn(~,~, handles)
 radioUnitPOI(handles,false);
end

% --- Executes when selected object is changed in radioUnitPOI.
function radioUnitPOI_status_SelectionChangedFcn(~,~, handles)
 radioUnitPOI(handles,true);
end

% --- Executes when selected object is changed in radioUnitPOI.
function radioUnitPOI(handles,status)
% to manage the change of physical unit for positions coordinates
% status  - boolean: indicating use of status (true) or settings (false) tag
global data
 if ~status
  radioUTM = handles.radioUTMPOI; radioGEO = handles.radioGEOPOI;
  posX = handles.posXPOI; unitX = handles.unitX_POI;
  posY = handles.posYPOI; unitY = handles.unitY_POI;
  warnPos = handles.warnPosPOI;
 else
  radioUTM = handles.radioUTMPOI_status; radioGEO = handles.radioGEOPOI_status;
  posX = handles.posXPOI_status; unitX = handles.unitX_POI_status;
  posY = handles.posYPOI_status; unitY = handles.unitY_POI_status;
  warnPos = handles.warnPosPOI_status;
 end
 if get(radioUTM,'Value')
  pos = get(posX,'Position'); pos(3)=130;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 408; pos(3)=10;
  set(unitX,'Position',pos);
  set(unitX,'String',',');
  pos = get(posY,'Position'); pos(1) = 421; pos(3)=130;
  set(posY,'Position',pos);
  set(unitY,'String','meter');
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%16.3f",get(posX,'Value')));
   set(posY,'String',sprintf("%16.3f",get(posY,'Value')));
  else
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 if get(radioGEO,'Value')
  pos = get(posX,'Position'); pos(3)=105;
  set(posX,'Position',pos);
  pos = get(unitX,'Position'); pos(1) = 381; pos(3)=50;
  set(unitX,'Position',pos);
  set(unitX,'String',[char(176),'North']);
  pos = get(posY,'Position'); pos(1) = 446; pos(3)=105;
  set(posY,'Position',pos);
  set(unitY,'String',[char(176),'East']);
  X = get(posX,'Value'); Y = get(posY,'Value');
  punto = round(GPSutm2ll(X,Y,30),8);
  if ~( isnan(get(posX,'Value')) || isnan(get(posY,'Value')) )
   set(posX,'String',sprintf("%10.8f",point(1)));
   set(posY,'String',sprintf("%10.8f",point(2)));
  else
   set(warnPos,'Visible','on');
   set(handles.enablePOI,'Value',0);
   set(handles.enablePOI,'Enable','off');
   set(posX,'String','');
   set(posY,'String','');
  end
 end
 minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
 minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
 valX = get(posX,'Value'); valY = get(posY,'Value');
 if isempty(get(posX,'String')) && isempty(get(posY,'String'))
  set(warnPos,'Visible','on');
  set(handles.enablePOI,'Value',0);
  set(handles.enablePOI,'Enable','off');
 elseif valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
  set(warnPos,'Visible','on');
  set(handles.enablePOI,'Value',0);
  set(handles.enablePOI,'Enable','off');
 else
  set(warnPos,'Visible','off');
  set(handles.enablePOI,'Enable','on');
 end
end

% --- Executes on selection change in posXPOI.
function posXPOI_Callback(hObject, ~, handles)
global data
 if get(handles.radioUTMPOI,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(hObject,'String')),...
                          str2double(get(handles.posYPOI,'String')),30),...
                8);
  set(hObject,'Value',punto(1));
  set(handles.posYPOI,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN)
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(hObject,'Value'); valY = get(handles.posYPOI,'Value');
  if valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
   idPOI = get(handles.idPOI,'Value');
   if idPOI <= get(handles.numPOIs,'Value')
    set(hObject,'Value',data.points(idPOI).posicion(1));
    set(handles.posYPOI,'Value',data.points(idPOI).posicion(2));
   else
    k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
    porDefecto = cell2mat(porDefecto(k,2:end));
    set(hObject,'Value',porDefecto(k,11));
    set(handles.posYPOI,'Value',porDefecto(k,12));
   end
   radioUnitPOI(handles,false);
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates';'The value must belong to the environmental dimensions';prompt},hObject,handles);
  end
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in posYPOI.
function posYPOI_Callback(hObject, ~, handles)
global data
 if get(handles.radioUTMPOI,'Value')
  set(hObject,'Value',str2double(get(hObject,'String')));
 else
  punto = round(GPSll2utm(str2double(get(handles.posXPOI,'String')),...
                          str2double(get(hObject,'String')),30),...
                8);
  set(handles.posXPOI,'Value',punto(1));
  set(hObject,'Value',punto(2));
 end
 if isempty(get(hObject,'String'))
  set(hObject,'Value',NaN);
 else
  minimoX = data.entorno.minX; maximoX = data.entorno.minX+data.entorno.dimX*data.entorno.deltaXY;
  minimoY = data.entorno.minY; maximoY = data.entorno.minY+data.entorno.dimY*data.entorno.deltaXY;
  valX = get(handles.posXPOI,'Value'); valY = get(hObject,'Value');
  if valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY
   idPOI = get(handles.idPOI,'Value');
   if idPOI <= get(handles.numPOIs,'Value')
    set(handles.posXPOI,'Value',data.points(idPOI).posicion(1));
    set(hObject,'Value',data.points(idPOI).posicion(2));
   else
    k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
    porDefecto = cell2mat(porDefecto(k,2:end));
    set(handles.posXPOI,'Value',porDefecto(k,11));
    set(hObject,'Value',porDefecto(k,12));
   end
   radioUnitPOI(handles,false);
   prompt = strcat(' (',num2str(minimoX),'m ,',num2str(maximoX),' m) y ',...
                   ' (',num2str(minimoY),'m ,',num2str(maximoY),' m)');
   warning({'Error: Position''s coordinates';'The value must belong to the environmental dimensions';prompt},hObject,handles);
  end
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in minUmbralPOI.
function minUmbralPOI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') > get(handles.maxUmbralPOI,'Value')
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).minUmbral);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,1));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Wireless signal strength threshold';'The minimum threshold must be lower or equal than the maximum one (both negative)'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in maxUmbralPOI.
function maxUmbralPOI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') > 0 || get(hObject,'Value') < get(handles.minUmbralPOI,'Value')
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).maxUmbral);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,2));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Wireless signal strength threshold';'The minimum threshold must be lower or equal than the maximum one (both negative)'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in aproximacionPOI.
function aproximacionPOI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < 0
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).aproximacion);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,3));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Aproach distance';'The value must be positive'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in actividadPOI.
function orientacionPOI_Callback(hObject, ~, handles)
global data
 if isempty(get(hObject,'String')), set(hObject,'Value',NaN);
 else, set(hObject,'Value',str2double(get(hObject,'String'))); end
 if get(hObject,'Value') < -180 || get(hObject,'Value') > 180
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).orientacion*180/pi());
   if isnan(data.points(idPOI).orientacion), set(hObject,'String','');
   else, set(hObject,'String',num2str(get(hObject,'Value'))); end
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,4));
   if isnan(porDefecto(k,4)), set(hObject,'String','');
   else, set(hObject,'String',num2str(get(hObject,'Value'))); end
  end
  warning({'Error: Approach orientation';'The value must be between menus and plus a hundred and eighty degrees.'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in actividadPOI.
function actividadPOI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < 0
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).actividad);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,6));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Activity time';'The value must be positive'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

%%% Note:
% conjunto de opciones disponibles: coeficiente, porcentual, tiempo e hbrido

% --- Executes on selection change in coefPotencialPos_POI.
function coefPotencialPos_POI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -100000 || get(hObject,'Value') > 100000
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).coefPos);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,7));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Penalty slope rate';'The values must be between a minus hundred thousand and a hundred thousand.'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in coefPotencialNeg_POI.
function coefPotencialNeg_POI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -100000 || get(hObject,'Value') > 100000
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).coefNeg);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,8));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Penalty slope rate';'The values must be between a minus hundred thousand and a hundred thousand.'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in coefPotencialLat_POI.
function coefPotencialLat_POI_Callback(hObject, ~, handles)
global data
 set(hObject,'Value',str2double(get(hObject,'String')));
 if get(hObject,'Value') < -100000 || get(hObject,'Value') > 100000
  idPOI = get(handles.idPOI,'Value');
  if idPOI <= get(handles.numPOIs,'Value')
   set(hObject,'Value',data.points(idPOI).coefNeg);
   set(hObject,'String',num2str(get(hObject,'Value')));
  else
   k = 1; porDefecto = ValoresPOIsPorDefecto(data.entorno.tipo);
   porDefecto = cell2mat(porDefecto(k,2:end));
   set(hObject,'Value',porDefecto(k,9));
   set(hObject,'String',num2str(get(hObject,'Value')));
  end
  warning({'Error: Penalty slope rate';'The values must be between a minus hundred thousand and a hundred thousand.'},hObject,handles);
 end
 data.POIsUpdated = 0;
end

% --- Executes on selection change in prioridadPOI.
function prioridadPOI_Callback(~,~, handles)
global data
 data.POIsUpdated = 0;
end

% --- Executes on button press in patternPOI.
function patternPOI_Callback(~,~, handles)
global data
 data.POIsUpdated = 0;
end

% --- Executes on button press in triggeredEventPOI.
function triggeredEventPOI_Callback(hObject, ~, handles)
global data
 idPOI = get(handles.idPOI,'Value');
 data.points(idPOI).event = get(hObject,'Value');
 set(handles.statusEventPOI,'Visible',data.points(idPOI).event);
 data.POIsUpdated = 0;
end

% --- Executes on button press in AgentOK_button.
function POIOK_button_Callback(~,~, handles)
global data general
 set(handles.defaultPOIs,'Enable','on');
 idPOI                  = get(handles.idPOI,'Value');
 idFullPOI              = get(handles.idFullPOI,'String');
 visiblePOI             = get(handles.visiblePOI,'Value');
 modoPosicion           = get(handles.modoPosicionPOI,'Value');
 unidad                 = get(handles.radioUTMPOI,'Value');
 punto(1)               = get(handles.posXPOI,'Value');
 punto(2)               = get(handles.posYPOI,'Value');
 minUmbral              = get(handles.minUmbralPOI,'Value');
 maxUmbral              = get(handles.maxUmbralPOI,'Value');
 aproximacion           = get(handles.aproximacionPOI,'Value');
 orientacion            = get(handles.orientacion,'Value');
 enableAproximacion     = get(handles.enableAproxPOI,'Value');
 tiempoActividad        = get(handles.actividadPOI,'Value');
 modoCoeficiente        = get(handles.radioCoeficientPOI,'Value');
 coefPositivo           = get(handles.coefPotencialPos_POI,'Value');
 coefNegativo           = get(handles.coefPotencialNeg_POI,'Value');
 coefLateral            = get(handles.coefPotencialLat_POI,'Value');
 prioridad              = get(handles.prioridadPOI,'Value');
 pattern                = get(handles.patternPOI,'String');
 event                  = get(handles.triggeredEventPOI,'Value');
 enablePlanning         = get(handles.enablePOI,'Value');
 if ~exist('idPOI')
  dataROS  = {};
 else
  if isfield(data,'points') && size(data.points,2)>=idPOI && ~isfield(data.points(idPOI),'ROS')
   dataROS = data.points(idPOI);
  else
   dataROS  = {};
  end
 end
 data.points(idPOI) = POIInsertar( data.entorno,idFullPOI,visiblePOI,modoPosicion,unidad,punto,minUmbral,maxUmbral,...
                                   aproximacion,orientacion,enableAproximacion,...
                                   tiempoActividad,modoCoeficiente,coefPositivo,coefNegativo,coefLateral,...
                                   prioridad,event,pattern,enablePlanning,dataROS);
 numPOIs                 = get(handles.numPOIs,'Value');
 if numPOIs < idPOI
  set(handles.numPOIs,'Value',numPOIs + 1);
  set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
 end
 set(handles.idPOI,'Enable','on');
 set(handles.addPOI_button,'Visible','on');
 set(handles.removePOI_button,'Visible','on');
 set(handles.editPOI_button,'Visible','on');
 set(handles.idFullPOI,'Enable','inactive');
 set(handles.visiblePOI,'Enable','inactive');
 set(handles.modoPosicionPOI,'Enable','inactive');
 set(handles.pickPOI_button,'Visible','off');
 set(handles.radioUTMPOI,'Enable','inactive');
 set(handles.radioGEOPOI,'Enable','inactive');
 set(handles.posXPOI,'Enable','inactive');
 set(handles.posXPOI_status,'Value',get(handles.posXPOI,'Value'));
 set(handles.posYPOI,'Enable','inactive');
 set(handles.posYPOI_status,'Value',get(handles.posYPOI,'Value'));
 radioUnitPOI(handles,false);
 set(handles.minUmbralPOI,'Enable','inactive');
 set(handles.maxUmbralPOI,'Enable','inactive');
 set(handles.aproximacionPOI,'Enable','inactive');
 set(handles.orientacionPOI,'Enable','inactive');
 set(handles.enableAproxPOI,'Enable','inactive');
 set(handles.actividadPOI,'Enable','inactive');
 set(handles.radioCoeficientPOI,'Enable','inactive');
 set(handles.radioPercentPOI,'Enable','inactive');
 set(handles.radioTimePOI,'Enable','inactive');
 set(handles.radioHybridPOI,'Enable','inactive');
 set(handles.coefPotencialPos_POI,'Enable','inactive');
 set(handles.coefPotencialNeg_POI,'Enable','inactive');
 set(handles.coefPotencialLat_POI,'Enable','inactive');
 set(handles.prioridadPOI,'Enable','inactive');
 set(handles.patternPOI,'Enable','inactive');
 set(handles.triggeredEventPOI,'Enable','inactive');
 for i=1:6, set(handles.(['Prior',num2str(i),'POI']),'Visible','off'); end
 set(handles.(['Prior',num2str(data.points(idPOI).prioridad),'POI']),'Position',data.default.PositionIconoPrioridadPOI);
 set(handles.(['Prior',num2str(data.points(idPOI).prioridad),'POI']),'Visible','off');
 set(handles.radioUTMPOI_status,'Value',get(handles.radioUTMPOI,'Value'));
 set(handles.radioGEOPOI_status,'Value',~get(handles.radioUTMPOI,'Value'));
 radioUnitPOI(handles,true);
 set(handles.POIOK_button,'Visible','off');
 set(handles.POICANCEL_button,'Visible','off');
 %if isfield(data,'planner') && isfield(data.planner,'optima'), data.planner = rmfield(data.planner,'optima'); end
 if isfield(data,'agentes'), set(handles.PLANNER_button,'Enable','on'); end
 set(handles.rutas,'Data',{});
 set(handles.aisladas,'String',{});
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 else
  general.updated = true;
 end
 data.POIsUpdated = 1;
 ClickOnAux4Tab(handles.a41,[],handles);
end

% --- Executes on button press in POICANCEL_button.
function POICANCEL_button_Callback(~,~, handles)
global data
 set(handles.defaultPOIs,'Enable','on');
 idPOI    = get(handles.idPOI,'Value');
 numPOIs  = get(handles.numPOIs,'Value');
 %%% Note: optional MySQL enable-state toggle.
 if numPOIs < idPOI
  set(handles.idPOI,'String','');
  set(handles.idPOI,'Value',0);
 elseif numPOIs
  set(handles.removePOI_button,'Visible','on');
 end
 set(handles.addPOI_button,'Visible','on');
 set(handles.idPOI,'Enable','on');
 if idPOI <= numPOIs, set(handles.editPOI_button,'Visible','on'); end
 editPOI(handles);
 set(handles.idFullPOI,'Enable','inactive');
 set(handles.visiblePOI,'Enable','inactive');
 set(handles.modoPosicionPOI,'Enable','inactive');
 set(handles.pickPOI_button,'Visible','off');
 set(handles.radioUTMPOI,'Enable','inactive');
 set(handles.radioGEOPOI,'Enable','inactive');
 set(handles.posXPOI,'Enable','inactive');
 set(handles.posYPOI,'Enable','inactive');
 set(handles.minUmbralPOI,'Enable','inactive');
 set(handles.maxUmbralPOI,'Enable','inactive');
 set(handles.aproximacionPOI,'Enable','inactive');
 set(handles.orientacionPOI,'Enable','inactive');
 set(handles.enableAproxPOI,'Enable','inactive');
 set(handles.actividadPOI,'Enable','inactive');
 set(handles.radioCoeficientPOI,'Enable','inactive');
 set(handles.radioPercentPOI,'Enable','inactive');
 set(handles.radioTimePOI,'Enable','inactive');
 set(handles.radioHybridPOI,'Enable','inactive');
 set(handles.coefPotencialPos_POI,'Enable','inactive');
 set(handles.coefPotencialNeg_POI,'Enable','inactive');
 set(handles.coefPotencialLat_POI,'Enable','inactive');
 set(handles.prioridadPOI,'Enable','inactive');
 set(handles.patternPOI,'Enable','inactive');
 set(handles.triggeredEventPOI,'Enable','inactive');
 set(handles.POIOK_button,'Visible','off');
 set(handles.POICANCEL_button,'Visible','off');
 data.POIsUpdated = 1;
 ClickOnAux4Tab(handles.a41,[],handles);
end

% --- Executes on button press in enableAgent.
function enablePOI_Callback(~,~, handles)
global data
 if isfield(data,'points')
  idPOI = get(handles.idPOI,'Value');
  aux = get(handles.enablePOI,'Value') && strcmp(get(handles.warnPosPOI,'Visible'),'off');
  if idPOI <= length(data.points)
   data.points(idPOI).enable = aux;
   set(handles.enablePOI,'Value',aux);
   data.POIsUpdated = 0;
   if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
      && get(handles.AutomaticPlanning,'Value')
    PLANNER_function(handles);
   end
  end
 end
end


%% ==========================================================================================================================
% --- Tab5Panel: PLANNER
% ------------------------

% --- Executes on selection change in restriccionUGV.
function restriccionUGV_Callback(hObject, ~, handles)
global data
 data.options.UGVconstraints = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in reexpansion.
function reexpansion_Callback(hObject, ~, handles)
global data
 data.options.reexpansions = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in functiononHeuristica.
function funcionHeuristica_Callback(hObject, ~, handles)
global data
 data.options.heuristic = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in slopeComputing.
function slopeComputing_Callback(hObject, ~, handles)
global data
 data.options.slopeComputing = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in visualizacion.
function visualizacion_Callback(hObject, ~, handles)
global data
 data.options.verbose = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in generacionMapas.
function generacionMapas_Callback(hObject, ~, handles)
global data
 data.options.mapasTiempo = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in criterioOptimizacion.
function criterioOptimizacion_Callback(hObject, ~, handles)
global data
 data.options.optTmw = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

% --- Executes on selection change in criterioTemporal.
function criterioTemporal_Callback(hObject, ~, handles)
global data
 data.options.TAU = get(hObject,'Value')-1;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
    && get(handles.AutomaticPlanning,'Value')
  PLANNER_function(handles);
 end
end

function mostrarSecuencia(handles)
global data
 ruta = {}; seqAisladas = {};
 if isfield(data.planner,'optima') && isfield(data.planner.optima,'nA')
  % numAgents = numel(data.planner.ini.Ak);
  % numVictimas = numel(data.planner.ini.Vn);
  na = numel(data.planner.optima.nA); seqAisladas = []; i = na;
  while i >= 1, seqAisladas = strcat(seqAisladas,num2str(data.planner.optima.nA(i)),','); i = i-1; end
  if numel(seqAisladas), seqAisladas = seqAisladas(1:end-1); end
  ruta = {};
  for k = 1:numel(unique(data.planner.optima.sA))
   seq = []; i = 1;
   while i <= numel(data.planner.optima.sV), if data.planner.optima.sA(i) == k, seq = strcat(seq,num2str(data.planner.optima.sV(i)),','); end; i=i+1; end
   if numel(seq), seq = seq(1:end-1); end
   ruta{k,1} = num2str(k);
   ruta{k,2} = seq;
  end
 end
 set(handles.rutas,'Data',ruta);
 set(handles.aisladas,'String',seqAisladas);
end

% --- Executes on button press in carpetaGPX_button.
function carpetaGPX_button_Callback(hObject, ~, handles)
% Note:
% carpetaGPX = get(handles.carpetaGPX,'String');
% carpetaGPX = uigetdir(carpetaGPX,'Pick a folder');
% if carpetaGPX
%  set(handles.carpetaGPX,'String',carpetaGPX);
% else
%  carpetaGPX = 'C:\Users\ATICA1\Documents\TwoNavData\Data';
%  if ~exist(carpetaGPX,'dir')
%   carpetaGPX = 'C:\Users\Carlos\Documents\TwoNavData\Data';
%   if ~exist(carpetaGPX,'dir')
%    carpetaGPX = 'GPX files';
%   end
%  end
%  set(handles.carpetaGPX,'String',carpetaGPX);
% end
end

% --- Executes on button press in enableMySQL.
function enableMySQL_Callback(hObject, ~, handles)
% global timerSensores conn connFirst
%  if get(handles.enableMySQL,'Value'), start(timerSensores);
%  else, stop(timerSensores);
%  end
end

% --- Executes on button press in PLANNER_button.
function PLANNER_button_Callback(~,~, handles)
global data
 data.agentesUpdated = 0;
 data.objetivosUpdated = 0; data.POIsUpdated = 0;
 PLANNER_function(handles);
end

% --- Executes on button press in PLANNER_button.
%%% Note: pending implementation checkpoint.
function PLANNER_function(handles)
global data general
 % Note: progress bar.
 % set(handles.progresoBorde,'Visible','on');
 % set(handles.progresoFondo,'Visible','on');
 % set(handles.progreso,'Visible','on');
 % pTotal = get(handles.progresoFondo,'Position'); pTotal = pTotal(3);
 % pos = get(handles.progreso,'Position');
 % p = 0; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
 tini = tic;
 %%% Note: pending implementation checkpoint.
 %%% =========================================================================================================
 % Etapa 1. Inicializacin
 %%%%if ~isfield(data,'sensorNodes') && isfield(data,'points')
 %%%% data.planner.ini = Inicializar(data.environment,data.agents,[],data.points,data.options);
 %%%%elseif isfield(data,'sensorNodes') && ~isfield(data,'points')
 %%%% data.planner.ini = Inicializar(data.environment,data.agents,data.sensorNodes,[],data.options);
 %%%%elseif ~isfield(data,'sensorNodes') && ~isfield(data,'points')
 %%%% data.planner.ini = Inicializar(data.environment,data.agents,[],[],data.options);
 %%%%else
 %%%% data.planner.ini = Inicializar(data.environment,data.agents,data.sensorNodes,data.points,data.options);
 %%%%end
 % p = 0.05; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
 data.planner.TOk = []; data.planner.Tk = []; data.planner.Wpk = []; data.planner.optima = [];
 if ~isempty(data.planner.ini.Ak) && ( ~data.agentesUpdated || ~data.objetivosUpdated || ~data.POIsUpdated )
  % Etapa 2. Tiempos intermedios de operacin
  %%%%[data.planner.TOk,data.planner.Tk,data.planner.Wpk,data.planner.Ppk,data.planner.Spk] = CalcularTOk(data.planner.ini,data.environment,data.options);
  % p = 0.50; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
  % Etapa 3. Optimizacion de secuencia de vctimas
  %%%%data.planner.optima = CalcularSecuenciaOptima(data.planner.ini,data.planner.TOk,data.options);
  % p = 0.70; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
  % Etapa 4. Determininacin de rutas
  %%%%[data.planner.optima.R] = GenerarPath(data.planner,data.environment,data.options);
  % p = 0.90; set(handles.progreso,'Position',[pos(1:2) p*pTotal pos(4)]); drawnow
  % Etapa 5. Generacin de waypoints con coordinates GPS para agents robticos, archivo GPX
  if ~data.entorno.tipo, puntosROS = GPXGenerar(); end
  for i=1:length(puntosROS)
   if ~isempty(puntosROS{i}.points)
    step = data.agentes(puntosROS{i}.numAgente).config.granularity;
    msg = puntosROS{i}.points(step:step:length(puntosROS{i}.points),:);
    if ~isequal(msg(end,:),puntosROS{i}.points(end,:)), msg(end+1,:) = puntosROS{i}.points(end,:); end
    formatedMSG = [];
    formatedMSG(1:2:2*length(msg),1) = msg(:,1);
    formatedMSG(2:2:2*length(msg),1) = msg(:,2);
    % length(formatedMSG)
    if data.agentes(puntosROS{i}.numAgente).config.nonROS2Pub1
     MSG = rosmessage(data.agentes(puntosROS{i}.numAgente).config.ROS.Pub1);
     if isempty(strfind(MSG.MessageType,'Float64')), formatedMSG = float(formatedMSG); end
     MSG.Data = formatedMSG;
    else
     MSG = ros2message(data.agentes(puntosROS{i}.numAgente).config.ROS.Pub1);
     if isempty(strfind(MSG.MessageType,'Float64')), formatedMSG = single(formatedMSG); end
     MSG.data = formatedMSG;
    end
    send(data.agentes(puntosROS{i}.numAgente).config.ROS.Pub1,MSG);
   end
  end
  % set(handles.progresoBorde,'Visible','off');
  % set(handles.progresoFondo,'Visible','off');
  % set(handles.progreso,'Visible','off');
  data.agentesUpdated = 1;
  data.objetivosUpdated = 1; data.POIsUpdated = 1;
 end
 t = toc(tini);
 fprintf('Tiempo de procesamiento del planificador estratgico: %g s\n',t);
 disp(' ');
 general.updated = true;
 mostrarSecuencia(handles);

 if true && ~data.entorno.tipo && get(handles.visualizacion,'Value')>1
  old_verbose = data.options.verbose;
  % data.options.verbose = -1; % para imprimir grficas especiales (solo para artculos)
  % Ortomosaico(data.environment,true,data.options.verbose,handles);
  % generar archivo PS con todas las grficas del experimento
  figs = findobj(0, 'type', 'figure');
  conjunto = length(figs):-1:1; if figs(1).Number == 2, conjunto = [length(figs):-1:3,1]; end
  for k = conjunto
   % print each figure in figs to a .eps file  
   set(figs(k),'PaperOrientation','landscape');
   if figs(k).Number > 3 && figs(k).Number <= 12
    % print(figs(k),'-dpsc','-append','-painters','Experimentos');
   else
    % print(figs(k),'-dpsc','-append','-painters','-bestfit','Experimentos');
   end
  end
  figure(2); close(2);
  if data.options.verbose == -1
   % for i = [3,5:12], figure(i); close(i); end
  end
  data.options.verbose = old_verbose;
 end
 % Note:
 % ARTICULO_Robot2019;
 % PostprocesarGPX();
end


%% ==========================================================================================================================
% --- Tab6Panel: GLOBAL SETTINGS
% ---------------------------------

% --- Executes on button press in enabledTTS.
function enabledTTS_Callback(~,~, handles)
global TTS
 if get(handles.enabledTTS,'Value') == 1 && ~isempty(get(handles.UrlTTS,'String'))
  set(handles.UrlTTS,'Enable','inactive');
  set(handles.portTTS,'Enable','inactive');
  set(handles.topicTTS,'Enable','inactive');
  set(handles.QoSTTS,'Enable','inactive');
  host = ['tcp://',get(handles.UrlTTS,'String')];
  if isnan(str2double(get(handles.portTTS,'String'))), port = 1883;
  else, port = str2double(get(handles.portTTS,'String'));
  end
  User_ID = get(handles.appID,'String');
  % MQTT_Client_ID = User_ID;
  MQTT_API_Key = get(handles.APIkey,'String');
  if ~isempty(get(handles.UrlTTS,'String'))
   try
    set(handles.statusTTS,'Background',[1 1 0]); drawnow
    % TTS.broker = mqttClient(host,'Port',port,'ClientID',MQTT_Client_ID,'Username',User_ID,'Password',MQTT_API_Key);
    TTS.broker = mqttClient(host,'Port',port,'Username',User_ID,'Password',MQTT_API_Key);
    set(handles.statusTTS,'Background',[0 .9 0]);
    try
     if get(handles.QoSTTS,'Value')==1, QoS = 0;
     else, QoS = get(handles.QoSTTS,'Value')-2;
     end
     topic = get(handles.topicTTS,'String');
     TTS.subs = subscribe(TTS.broker,char(topic),'QualityOfService',QoS);
     TTS.subs.Callback = @(topic,msg)receiveTTS(topic,msg,handles,0);
    catch
     set(handles.statusTTS,'Background',[1 0 0]);
    end
   catch
    set(handles.statusTTS,'Background',[1 0 0]);
   end
  end
 else
  set(handles.enabledTTS,'Value',0)
  set(handles.UrlTTS,'Enable','on');
  set(handles.portTTS,'Enable','on');
  set(handles.topicTTS,'Enable','on');
  set(handles.QoSTTS,'Enable','on');
  if ~isempty(get(handles.UrlTTS,'String'))
   try
    unsubscribe(TTS.subs)
    TTS.broker.disconnect
    TTS.subs.delete
    TTS.broker.delete
   catch
   end
  end
  set(handles.statusTTS,'Background',[1 1 1]);
  if isfield(TTS,'broker'), TTS = rmfield(TTS,'broker'); end
  if isfield(TTS,'subs'), TTS = rmfield(TTS,'subs'); end
 end
end

% --- Executes on button press in enabledLoRa.
function enabledLoRa_Callback(~,~, handles)
global LoRa
 if get(handles.enabledLoRa,'Value') == 1 && ...
    ( ~isempty(get(handles.ipLoRa1,'String')) || ~isempty(get(handles.ipLoRa2,'String')) || ...
      ~isempty(get(handles.ipLoRa3,'String')) || ~isempty(get(handles.ipLoRa4,'String')) )
  set(handles.ipLoRa1,'Enable','inactive');
  set(handles.portLoRa1,'Enable','inactive');
  set(handles.ipLoRa2,'Enable','inactive');
  set(handles.portLoRa2,'Enable','inactive');
  set(handles.ipLoRa3,'Enable','inactive');
  set(handles.portLoRa3,'Enable','inactive');
  set(handles.ipLoRa4,'Enable','inactive');
  set(handles.portLoRa4,'Enable','inactive');
  set(handles.topicLoRa,'Enable','inactive');
  set(handles.QoSLoRa,'Enable','inactive');
  host1 = ['tcp://',get(handles.ipLoRa1,'String')];
  if isnan(str2double(get(handles.portLoRa1,'String'))), port1 = 1883;
  else, port1 = str2double(get(handles.portLoRa1,'String'));
  end
  host2 = ['tcp://',get(handles.ipLoRa2,'String')];
  if isnan(str2double(get(handles.portLoRa2,'String'))), port2 = 1883;
  else, port2 = str2double(get(handles.portLoRa2,'String'));
  end
  host3 = ['tcp://',get(handles.ipLoRa3,'String')];
  if isnan(str2double(get(handles.portLoRa3,'String'))), port3 = 1883;
  else, port3 = str2double(get(handles.portLoRa3,'String'));
  end
  host4 = ['tcp://',get(handles.ipLoRa4,'String')];
  if isnan(str2double(get(handles.portLoRa4,'String'))), port4 = 1883;
  else, port4 = str2double(get(handles.portLoRa4,'String'));
  end
  if get(handles.QoSLoRa,'Value')==1, QoS = 0;
  else, QoS = get(handles.QoSLoRa,'Value')-2;
  end
  topic = get(handles.topicLoRa,'String');
  if ~isempty(get(handles.ipLoRa1,'String'))
   try
    set(handles.statusLoRa1,'Background',[1 1 0]); drawnow
    LoRa.broker1 = mqttClient(host1,'Port',port1);
    set(handles.statusLoRa1,'Background',[0 .9 0]);
    try
     LoRa.subs1 = subscribe(LoRa.broker1,char(topic),'QualityOfService',QoS);
     LoRa.subs1.Callback = @(topic,msg)receiveLoRa(topic,msg,handles,1);
    catch
     set(handles.statusLoRa1,'Background',[1 0 0]);
    end
   catch
    set(handles.statusLoRa1,'Background',[1 0 0]);
   end
  end
  if ~isempty(get(handles.ipLoRa2,'String'))
   try
    set(handles.statusLoRa2,'Background',[1 1 0]); drawnow
    LoRa.broker2 = mqttClient(host2,'Port',port2);
    set(handles.statusLoRa2,'Background',[0 .9 0]);
    try
     LoRa.subs2 = subscribe(LoRa.broker2,char(topic),'QualityOfService',QoS);
     LoRa.subs2.Callback = @(topic,msg)receiveLoRa(topic,msg,handles,2);
    catch
     set(handles.statusLoRa2,'Background',[1 0 0]);
    end
   catch
    set(handles.statusLoRa2,'Background',[1 0 0]);
   end
  end
  if ~isempty(get(handles.ipLoRa3,'String'))
   try
    set(handles.statusLoRa3,'Background',[1 1 0]); drawnow
    LoRa.broker3 = mqttClient(host3,'Port',port3);
    set(handles.statusLoRa3,'Background',[0 .9 0]);
    try
     LoRa.subs3 = subscribe(LoRa.broker3,char(topic),'QualityOfService',QoS);
     LoRa.subs3.Callback = @(topic,msg)receiveLoRa(topic,msg,handles,3);
    catch
     set(handles.statusLoRa3,'Background',[1 0 0]);
    end
   catch
    set(handles.statusLoRa3,'Background',[1 0 0]);
   end
  end
  if ~isempty(get(handles.ipLoRa4,'String'))
   try
    set(handles.statusLoRa4,'Background',[1 1 0]); drawnow
    LoRa.broker4 = mqttClient(host4,'Port',port4);
    set(handles.statusLoRa4,'Background',[0 .9 0]);
    try
     LoRa.subs4 = subscribe(LoRa.broker4,char(topic),'QualityOfService',QoS);
     LoRa.subs4.Callback = @(topic,msg)receiveLoRa(topic,msg,handles,4);
    catch
     set(handles.statusLoRa4,'Background',[1 0 0]);
    end
   catch
    set(handles.statusLoRa4,'Background',[1 0 0]);
   end
  end
 else
  set(handles.enabledLoRa,'Value',0)
  set(handles.ipLoRa1,'Enable','on');
  set(handles.portLoRa1,'Enable','on');
  set(handles.ipLoRa2,'Enable','on');
  set(handles.portLoRa2,'Enable','on');
  set(handles.ipLoRa3,'Enable','on');
  set(handles.portLoRa3,'Enable','on');
  set(handles.ipLoRa4,'Enable','on');
  set(handles.portLoRa4,'Enable','on');
  set(handles.topicLoRa,'Enable','on');
  set(handles.QoSLoRa,'Enable','on');
  if ~isempty(get(handles.ipLoRa1,'String'))
   try
    unsubscribe(LoRa.subs1)
    LoRa.broker1.disconnect
    LoRa.subs1.delete
    LoRa.broker1.delete
   catch
   end
   if ~isempty(get(handles.ipLoRa2,'String'))
    try
     unsubscribe(LoRa.subs2)
     LoRa.broker2.disconnect
     LoRa.subs2.delete
     LoRa.broker2.delete
    catch
    end
   end
   if ~isempty(get(handles.ipLoRa3,'String'))
    try
     unsubscribe(LoRa.subs3)
     LoRa.broker3.disconnect
     LoRa.subs3.delete
     LoRa.broker3.delete
    catch
    end
   end
   if ~isempty(get(handles.ipLoRa4,'String'))
    try
     unsubscribe(LoRa.subs4)
     LoRa.broker4.disconnect
     LoRa.subs4.delete
     LoRa.broker4.delete
    catch
    end
   end
  end
  set(handles.statusLoRa1,'Background',[1 1 1]);
  set(handles.statusLoRa2,'Background',[1 1 1]);
  set(handles.statusLoRa3,'Background',[1 1 1]);
  set(handles.statusLoRa4,'Background',[1 1 1]);
  if isfield(LoRa,'broker1'), LoRa = rmfield(LoRa,'broker1'); end
  if isfield(LoRa,'broker2'), LoRa = rmfield(LoRa,'broker2'); end
  if isfield(LoRa,'broker3'), LoRa = rmfield(LoRa,'broker3'); end
  if isfield(LoRa,'broker4'), LoRa = rmfield(LoRa,'broker4'); end
  if isfield(LoRa,'subs1'), LoRa = rmfield(LoRa,'subs1'); end
  if isfield(LoRa,'subs2'), LoRa = rmfield(LoRa,'subs2'); end
  if isfield(LoRa,'subs3'), LoRa = rmfield(LoRa,'subs3'); end
  if isfield(LoRa,'subs4'), LoRa = rmfield(LoRa,'subs4'); end
 end
end

function receiveTTS(topic, msg, handles, idBroker)
global TTS
 receiveMessage(topic,msg,handles,TTS,idBroker);
end

function receiveLoRa(topic, msg, handles, idBroker)
global LoRa
 receiveMessage(topic,msg,handles,LoRa,idBroker);
end

function receiveMQTT(topic, msg, handles)
global data general MQTT LoRa
 propiedad = @(patron,x) extractAfter(x,patron);
 extraer = @(x) char(x(~ismissing(x)));
 message = msg{1}(2:strlength(msg)-1);
 value = cell(length(MQTT.propertyNodes),1);
 for i = 1:length(MQTT.propertyNodes)
  value{i} = extraer(propiedad(MQTT.propertyNodes{i},split(message,',')));
  if ~isempty(value{i}) && value{i}(1)=='"', value{i} = value{i}(2:end-1); end
 end
 t = datetime(value{1},'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC'); %-datenum("00-00-0000 1:00:00");
 k = 1;
 % if the detected node is an embedded sensor group, the application looks it up into registered nodes
 while isfield(data,'agentes') && k <= length(data.agentes) && ~strcmp(data.agentes(k).config.topicGPS,topic)
  k = k+1;
 end
 if k <= length(data.agentes), aux = data.agentes(k).config.sensorNodes; end
 payload = value{2};
 if ~isempty(payload)
  decodedValue = matlab.net.base64decode(payload);
  decodedValue = char(decodedValue);
  % ... the application computes the last recorded values for obtaining the index to register the new values
  if size(aux.automatic.histValor,2) == 1 && ~sum(~isnan(aux.automatic.histValor))
   lastItem = 0;
  else
   lastItem = size(aux.automatic.histValor,2);
   aux.automatic.histValor(:,lastItem+1) = NaN*ones(length(LoRa.keys),1);
  end
  % ... the application registers the new detected values from MQTT communication
  dataValue = str2num(cell2mat(split(extraer(propiedad('#GPS:',decodedValue)),';')));
  j = 1; while ~strcmp(cell2mat(LoRa.keys{j}(4)),'GPS'), j = j+1; end
  aux.automatic.valor(j+1) = double(dataValue(1));
  aux.automatic.valor(j+2) = double(dataValue(2));
  aux.automatic.histValor(j+1,lastItem+1) = aux.automatic.valor(j+1);
  aux.automatic.histValor(j+2,lastItem+1) = aux.automatic.valor(j+2);
  if aux.user.modoPosicion == 3
   % aux.user.unidadPosicion = 0;
   punto = round(GPSll2utm(double(dataValue'),30),8);
   aux.user.posicion(1) = punto(1);
   aux.user.posicion(2) = punto(2);
  end
  if isfield(aux.automatic,'deveui')
   aux.automatic.histRSSI{lastItem+1} = NaN*ones(length(aux.automatic.deveui),1);
   aux.automatic.histSNR{lastItem+1} = NaN*ones(length(aux.automatic.deveui),1);
  else
   aux.automatic.histRSSI{lastItem+1} = NaN;
   aux.automatic.histSNR{lastItem+1} = NaN;
  end
  aux.automatic.histTimestamp{lastItem+1} = NaN;
  aux.automatic.histTiempo(lastItem+1) = t;
  aux.automatic.histChannel{lastItem+1} = NaN;
  aux.automatic.histBroker(lastItem+1) = NaN;
  aux.automatic.histDevEUI(lastItem+1) = NaN;
  % ... the application saves updated values into the data structure
  data.agentes(k).config.sensorNodes =  aux;
  if isfield(data.agentes(k).config.sensorNodes,'user') && isfield(data.agentes(k).config.sensorNodes.user,'modoPosicion') && data.agentes(k).config.sensorNodes.user.modoPosicion == 3
   % automatically changing the position mode in agents by detecting GPS signal
   data.agentes(k).config.modoPosicion = data.agentes(k).config.sensorNodes.user.modoPosicion;
   data.agentes(k).config.unidadPosicion = data.agentes(k).config.sensorNodes.user.unidadPosicion;
   data.agentes(k).config.posicion = data.agentes(k).config.sensorNodes.user.posicion;
  end
  % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
  if k == get(handles.idAgente,'Value')
   if aux.user.modoPosicion == 3
    set(handles.posXAgente,'Value',aux.user.posicion(1));
    set(handles.posYAgente,'Value',aux.user.posicion(2));
    set(handles.radioUTMAgente,'Value',aux.user.unidadPosicion);
    set(handles.radioGEOAgente,'Value',~aux.user.unidadPosicion);
    radioUnitAgente(handles,false);
    set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
    set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
    % set(handles.radioUTMAgent_status,'Value',aux.user.unidadPosicion);
    % set(handles.radioGEOAgent_status,'Value',~aux.user.unidadPosicion);
    radioUnitAgente(handles,true);
   end
   updateTableAgente(handles);
   runGraficaAgente(handles);
  end
  % if the detected node includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
  if isfield(data.agentes(k).config.sensorNodes,'user') && isfield(data.agentes(k).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(k).config.sensorNodes.user.posicion)
   general.updated = true;
  end
 end
end

function receiveMessage(topic, msg, handles, SUBNET, idBroker)
global data general LoRa
 propiedad = @(patron,x) extractAfter(x,patron);
 extraer = @(x) char(x(~ismissing(x)));
 if ~strcmp(topic(end-2:end),"/up"), return; end
 message = split(msg{1}(2:strlength(msg)-1),'"gateway_id":"');
 message_tmp = split(message{end},'"settings":{');
 message{end} = message_tmp{1}; message{end+1} = message_tmp{2};

 if strcmp(SUBNET.propertyNodes{3},'"data":'), minIdx = 1; else, minIdx = 2; end
 value = cell(length(LoRa.propertyNodes),1);
 for i = 1:length(SUBNET.propertyNodes)-2
  value{i} = extraer(propiedad(SUBNET.propertyNodes{i},split(message{1},',')));
  if ~isempty(value{i}) && value{i}(1)=='"', value{i} = value{i}(2:end-1); end
  if strcmp(SUBNET.propertyNodes{i},'"airtime":'), value{i} = str2double(value{i}); end
 end
 for i = length(SUBNET.propertyNodes)-1:length(SUBNET.propertyNodes)
  value{i} = extraer(propiedad(SUBNET.propertyNodes{i},split(message{end},',')));
  if ~isempty(value{i}) && value{i}(1)=='"', value{i} = value{i}(2:end-1); end
  if strcmp(SUBNET.propertyNodes{i},'"spreading_factor":'), value{i} = ['SF',value{i}(1:end-2)]; end
  if strcmp(SUBNET.propertyNodes{i},'"consumed_airtime":'), value{i} = str2double(value{i}(1:end-1)); end
 end
 k = 1;
 value{length(LoRa.propertyNodes)+1} = cell(length(message)-minIdx,1);
 value{length(LoRa.propertyNodes)+2} = zeros(length(message)-minIdx,length(LoRa.propertyGateways));
 for j=minIdx:length(message)-1
  %%%% Note:
  %%%% Note:
  %%%% Note: test a temperature node with event management for automatic planning.
  %%%% Note: test planned Rambler operation in the field.
  switch idBroker
   case 1
    tmp = get(handles.ipLoRa1,'String');
   case 2
    tmp = get(handles.ipLoRa2,'String');
   case 3
    tmp = get(handles.ipLoRa3,'String');
   case 4
    tmp = get(handles.ipLoRa4,'String');
   otherwise
    tmp = split(message{j},'"'); tmp = char(tmp(1,:));
  end
  idx = 1;
  if isfield(data,'gateways')
   while idx<=length(data.gateways) && ~strcmp(data.gateways{idx},tmp), idx = idx+1; end
  else
   data.gateways = {};
  end
  if idx>length(data.gateways)
   data.gateways{idx} = tmp; tmp2 = get(handles.gatewaysIDs,'String');
   tmp2{end+1} = tmp;
   set(handles.gatewaysIDsAgente,'String',tmp2);
   set(handles.gatewaysIDs,'String',tmp2);
  end
  value{length(LoRa.propertyNodes)+2}(k,1) = idx;
  for i=1:length(SUBNET.propertyGateways)-1
   item = extraer(propiedad(SUBNET.propertyGateways{i},split(message{j},',')));
   if ~isempty(item) && item(1)=='"', item = item(2:end-1); end
   if strcmp(SUBNET.propertyGateways{i},'"channel_index":'), item = item(1:end-1); end
   value{length(SUBNET.propertyNodes)+2}(k,i+1) = str2double(item);
  end
  item = extraer(propiedad(SUBNET.propertyGateways{i+1},split(message{j},',')));
  value{length(SUBNET.propertyNodes)+1}{k} = item(2:end-1);
  k = k+1;
 end
 value{1} = replace(value{1},'-','');
 value{1} = upper(value{1});
 if ~isempty(value{1})
  %%% Note:
  t = datetime(value{2},'InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC')+datenum("00-00-0000 2:00:00");
  k = 1; n = 1;
  % if the detected node is an embedded sensor group, the application looks it up into registered nodes
  if strcmp(value{1}(1),'E')
   subnetwork = get(handles.nodeSubnetworkAgente,'String'); subnetwork = subnetwork{2};
   while isfield(data,'agentes') && k <= length(data.agentes) && isfield(data.agentes(k).config,'sensorNodes') && ~( strcmp(data.agentes(k).config.sensorNodes.automatic.subnetwork,subnetwork) && strcmp(data.agentes(k).config.sensorNodes.automatic.group,value{1}(1:4)) )
    k = k+1;
   end
   while isfield(data,'agentes') && k <= length(data.agentes) && isfield(data.agentes(k).config,'sensorNodes') && isfield(data.agentes(k).config.sensorNodes.automatic,'deveui') && n <= length(data.agentes(k).config.sensorNodes.automatic.deveui) && ~strcmp(data.agentes(k).config.sensorNodes.automatic.deveui(n),value{1})
    n = n+1;
   end
  % if the detected node can be an sensor group, the application looks it up into registered nodes
  elseif ~strcmp(value{1}(1:4),'0000')
   while isfield(data,'sensorNodes') && k <= length(data.sensorNodes) && ~strcmp(data.sensorNodes(k).automatic.group,value{1}(1:4))
    k = k+1;
   end
   while isfield(data,'sensorNodes') && k <= length(data.sensorNodes) && isfield(data.sensorNodes(k).automatic,'deveui') && n <= length(data.sensorNodes(k).automatic.deveui) && ~strcmp(data.sensorNodes(k).automatic.deveui(n),value{1})
    n = n+1;
   end
  % if the detected node can only be an individual sensor node, the application looks it up into registered nodes
  else
   while isfield(data,'sensorNodes') && k <= length(data.sensorNodes) && ~strcmp(data.sensorNodes(k).automatic.deveui(1),value{1})
    k = k+1;
   end
  end
  % if the detected node is not an embedded sensor group and it is not a previously ...
  % ... registered associated sensor group or individual node, the application automatically registers it
  if ~strcmp(value{1}(1),'E') && ( ~isfield(data,'sensorNodes') || k > length(data.sensorNodes) )
   aux.user.idFull = '';
   aux.user.visible = 0;
   aux.user.modoPosicion = 3;
   aux.user.unidadPosicion = 0;
   aux.user.minUmbral = -110;
   aux.user.maxUmbral = -90;
   aux.user.aproximacion = 10;
   aux.user.orientacion = NaN;
   aux.user.enableAprox = 0;
   aux.user.actividad = 60;
   aux.user.coeficiente = 1;
   aux.user.coefPos = 0;
   aux.user.coefNeg = 0;
   aux.user.prioridad = 1;
   aux.user.temperatureEvent = NaN;
   aux.user.timeEvent = NaN;
   aux.user.pattern = '';
   aux.user.event = 0;
   aux.user.enable = 0;
   aux.user.enableFreeze = 1;
   aux.automatic.valor = NaN*ones(1,length(LoRa.keys));
   aux.automatic.enableFilter = false;
   aux.automatic.enableRSSIPlot = false;
   aux.automatic.enableBatteryPlot = false;
   aux.automatic.enablePlot = false(length(LoRa.keys),1);
   aux.automatic.enableMap = false(length(LoRa.keys),1);
   aux.automatic.histRSSI = {};
   aux.automatic.histSNR = {};
   aux.automatic.histChannel = {};
   aux.automatic.histBroker = NaN;
   aux.automatic.histDevEUI = NaN;
   aux.automatic.histValor = NaN*ones(length(LoRa.keys),1);
   aux.automatic.histTimestamp = {};
   aux.automatic.histTiempo = datetime('now','InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC');
   aux.automatic.subnetwork = 'LoRa';
   aux.automatic.group = value{1}(1:4);
   aux.automatic.event = 0;
  end
  % if the detected node is a previously registered node, embedded (depended-agent) or not (sensor node)
  % the application restores saved parameters and data
  if ~strcmp(value{1}(1),'E') && isfield(data,'sensorNodes') && k <= length(data.sensorNodes)
   aux = data.sensorNodes(k);
  elseif strcmp(value{1}(1),'E') && isfield(data,'agentes') && k <= length(data.agentes) && isfield(data.agentes(k).config,'sensorNodes')
   aux = data.agentes(k).config.sensorNodes;
  end
  % if the detected node is not an embedded sensor group or it is an embedded sensor group with a previously associated registered agent
  if ~strcmp(value{1}(1),'E') || ( strcmp(value{1}(1),'E') && isfield(data,'agentes') && k <= length(data.agentes) )
   % ... the application registers or updates it
   if ~(isfield(aux.automatic,'deveui') && n <= length(aux.automatic.deveui))
    aux.automatic.enableRSSIPlot(n) = false;
    aux.automatic.enableBatteryPlot(n) = false;
    aux.automatic.enableFilter(n) = false;
   end
   aux.automatic.deveui{n}      = char(value{1});
   aux.automatic.datr{n}        = char(value{4});
   aux.automatic.airtime{n}     = value{5};
   aux.automatic.time           = t;
   if ~isfield(aux.automatic,'rssi') || n > length(aux.automatic.rssi)
    aux.automatic.rssi{n}       = nan(1,length(data.gateways));
    aux.automatic.snr{n}        = nan(1,length(data.gateways));
    aux.automatic.channel{n}    = nan(1,length(data.gateways));
    aux.automatic.timestamp{n}  = nan(1,length(data.gateways));
    aux.automatic.timeGtw{n}    = cell(1,length(data.gateways));
   end
   for i=1:length(value{7}(:,1))
    aux.automatic.rssi{n}(value{7}(i,1))       = value{7}(i,2);
    aux.automatic.snr{n}(value{7}(i,1))        = value{7}(i,3);
    aux.automatic.channel{n}(value{7}(i,1))    = value{7}(i,4);
    aux.automatic.timestamp{n}(value{7}(i,1))  = value{7}(i,5);
    aux.automatic.timeGtw{n}(value{7}(i,1))    = value{6}(i);
   end
   payload = value{3};
   if ~isempty(payload)
    decodedValue = matlab.net.base64decode(payload);
    length_payload = int8(decodedValue(2)); numByte = 3;
    % ... the application computes the last recorded values for obtaining the index to register the new values
    if size(aux.automatic.histValor,2) == 1 && ~sum(~isnan(aux.automatic.histValor))
     lastItem = 0;
    else
     lastItem = size(aux.automatic.histValor,2);
     aux.automatic.histValor(:,lastItem+1) = NaN*ones(length(LoRa.keys),1);
    end
    % ... the application registers the new detected values from the sensor node
    aux.automatic.battery(n) = NaN;
    while numByte <= length_payload
     typeValue = uint8(decodedValue(numByte)); j = 1;
     while cell2mat(LoRa.keys{j}(1)) ~= typeValue
      j = j+1;
     end
     lengthValue = cell2mat(LoRa.keys{j}(2));
     typeData = cell2mat(LoRa.keys{j}(3));
     dataValue = typecast(uint8(decodedValue(numByte+1:numByte+lengthValue)),typeData);
     if strcmp(cell2mat(LoRa.keys{j}(4)),'GPS')
      aux.automatic.valor(j+1) = double(dataValue(1));
      aux.automatic.valor(j+2) = double(dataValue(2));
      aux.automatic.histValor(j+1,lastItem+1) = aux.automatic.valor(j+1);
      aux.automatic.histValor(j+2,lastItem+1) = aux.automatic.valor(j+2);
      if aux.user.modoPosicion == 3 || aux.user.modoPosicion == 4
       aux.user.unidadPosicion = 0;
       punto = round(GPSll2utm(double(dataValue),30),8);
       aux.user.posicion(1) = punto(1);
       aux.user.posicion(2) = punto(2);
      end
     elseif strcmp(cell2mat(LoRa.keys{j}(4)),'ACC')
      aux.automatic.valor(j+1) = double(dataValue(1))*0.00980665; % converting mili-g to meter per square second
      aux.automatic.valor(j+2) = double(dataValue(2))*0.00980665; % 1 g = 9.80665 m/s
      aux.automatic.valor(j+3) = double(dataValue(3))*0.00980665;
      aux.automatic.histValor(j+1,lastItem+1) = aux.automatic.valor(j+1);
      aux.automatic.histValor(j+2,lastItem+1) = aux.automatic.valor(j+2);
      aux.automatic.histValor(j+3,lastItem+1) = aux.automatic.valor(j+3);
     elseif strcmp(cell2mat(LoRa.keys{j}(4)),'PRES')
      aux.automatic.valor(j) = double(dataValue)/101325; % converting Pascal to atmosphere
      aux.automatic.histValor(j,lastItem+1) = aux.automatic.valor(j);
     elseif strcmp(cell2mat(LoRa.keys{j}(4)),'BAT')
      aux.automatic.valor(j) = double(dataValue);
      aux.automatic.histValor(j,lastItem+1) = aux.automatic.valor(j);
      aux.automatic.battery(n) = double(dataValue);
     else
      aux.automatic.valor(j) = double(dataValue);
      aux.automatic.histValor(j,lastItem+1) = aux.automatic.valor(j);
      if ~strcmp(value{1}(1),'E') && strcmp(cell2mat(LoRa.keys{j}(4)),'TC') && ~isnan(aux.user.temperatureEvent) && ~isnan(aux.user.timeEvent)
       if ~aux.automatic.event && aux.automatic.valor(j) >= aux.user.temperatureEvent
        if ~isfield(aux.automatic,'triggerEvent'), aux.automatic.triggerEvent = tic;
        elseif tic-aux.automatic.trigerEvent >= aux.user.timeEvent*1e6
         aux.automatic = rmfield(aux.automatic,'triggerEvent');
         aux.automatic.event = true; aux.user.enable = true;
         if get(handles.idObjetivo,'Value')==k
          set(handles.statusEventObjetivo,'Visible','on');
          set(handles.enableObjetivo,'Value',1);
          enableObjetivo_Callback(handles.enableObjetivo,[],handles);
         end
        end
       elseif aux.automatic.event && aux.automatic.valor(j) < aux.user.temperatureEvent
        if ~isfield(aux.automatic,'triggerEvent'), aux.automatic.triggerEvent = tic;
        elseif tic-aux.automatic.trigerEvent >= aux.user.timeEvent*1e6
         aux.automatic.event = false; aux.automatic = rmfield(aux.automatic,'triggerEvent');
         if get(handles.idObjetivo,'Value')==k
          set(handles.statusEventObjetivo,'Visible','off');
         end
        end
       end
      end
     end
     numByte = numByte+lengthValue+1;
    end
    % if size(aux.automatic.histRSSI,1)+1 == length(aux.automatic.deveui)
    %  aux.automatic.histRSSI = [aux.automatic.histRSSI;NaN*ones(1,size(aux.automatic.histRSSI,2))];
    %  aux.automatic.histSNR  = [aux.automatic.histSNR; NaN*ones(1,size(aux.automatic.histSNR,2))];
    % end
    % aux.automatic.histRSSI(:,lastItem+1) = NaN*ones(length(aux.automatic.deveui),1);
    aux.automatic.histRSSI{lastItem+1} = aux.automatic.rssi{n};
    % aux.automatic.histSNR(:,lastItem+1) = NaN*ones(length(aux.automatic.deveui),1);
    aux.automatic.histSNR{lastItem+1} = aux.automatic.snr{n};
    aux.automatic.histTimestamp{lastItem+1} = aux.automatic.timestamp{n};
    aux.automatic.histTiempo(lastItem+1) = t;
    aux.automatic.histChannel{lastItem+1} = aux.automatic.channel{n};
    aux.automatic.histBroker(lastItem+1) = idBroker;
    aux.automatic.histDevEUI(lastItem+1) = n;
   end
   % if a detected node has been registered, embedded (depended-agent) or not (sensor node)
   if exist('aux','var')
    % ... the application saves updated values into the data structure
    if ~strcmp(aux.automatic.group(1),'E')
     data.sensorNodes(k) = aux;
    else
     % ... in case of embedded sensor group with detected GPS antenna, the application also updates positions mode and current agent position
     data.agentes(k).config.sensorNodes =  aux;
     if isfield(data.agentes(k).config.sensorNodes,'user') && isfield(data.agentes(k).config.sensorNodes.user,'modoPosicion') && data.agentes(k).config.sensorNodes.user.modoPosicion == 4
      % automatically changing the position mode in agents by detecting GPS signal
      data.agentes(k).config.modoPosicion = data.agentes(k).config.sensorNodes.user.modoPosicion;
      data.agentes(k).config.unidadPosicion = data.agentes(k).config.sensorNodes.user.unidadPosicion;
      data.agentes(k).config.posicion = data.agentes(k).config.sensorNodes.user.posicion;
     end
    end
    % the application updates the total number of targets
    if isfield(data,'sensorNodes'), set(handles.numObjetivos,'Value',length(data.sensorNodes)); end
    set(handles.numObjetivos,'String',num2str(get(handles.numObjetivos,'Value')));
    if get(handles.numObjetivos,'Value'), set(handles.idObjetivo,'Enable','on'); end
    % if the detected node belongs to the current monitored target, the application updates values into tables and graphs
    if ~strcmp(aux.automatic.group(1),'E') && k == get(handles.idObjetivo,'Value')
     if aux.user.modoPosicion == 3 && isfield(aux.user,'posicion')
      set(handles.posXObjetivo,'Value',aux.user.posicion(1));
      set(handles.posYObjetivo,'Value',aux.user.posicion(2));
      set(handles.radioUTMObjetivo,'Value',aux.user.unidadPosicion);
      set(handles.radioGEOObjetivo,'Value',~aux.user.unidadPosicion);
      radioUnitObjetivo(handles,false);
      set(handles.posXObjetivo_status,'Value',get(handles.posXObjetivo,'Value'));
      set(handles.posYObjetivo_status,'Value',get(handles.posYObjetivo,'Value'));
      set(handles.radioUTMObjetivo_status,'Value',aux.user.unidadPosicion);
      set(handles.radioGEOObjetivo_status,'Value',~aux.user.unidadPosicion);
      radioUnitObjetivo(handles,true);
     end
     updateTableObjetivo(handles);
     runGraficaObjetivo(handles);
    % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
    elseif strcmp(aux.automatic.group(1),'E') && k == get(handles.idAgente,'Value')
     if aux.user.modoPosicion == 4
      set(handles.posXAgente,'Value',aux.user.posicion(1));
      set(handles.posYAgente,'Value',aux.user.posicion(2));
      set(handles.radioUTMAgente,'Value',aux.user.unidadPosicion);
      set(handles.radioGEOAgente,'Value',~aux.user.unidadPosicion);
      radioUnitAgente(handles,false);
      set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
      set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
      set(handles.radioUTMAgente_status,'Value',aux.user.unidadPosicion);
      set(handles.radioGEOAgente_status,'Value',~aux.user.unidadPosicion);
      radioUnitAgente(handles,true);
     end
     updateTableAgente(handles);
     runGraficaAgente(handles);
    end
    % if the detected node includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
    if ( ~strcmp(aux.automatic.group(1),'E') && isfield(data.sensorNodes(k).user,'posicion') && ~isempty(data.sensorNodes(k).user.posicion) ) || ...
       (  strcmp(aux.automatic.group(1),'E') && isfield(data.agentes(k).config.sensorNodes,'user') && isfield(data.agentes(k).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(k).config.sensorNodes.user.posicion) )
     general.updated = true;
    end
   end
  end
 end
end

function enabledZigbee_Callback(hObject, ~, handles)
%%% Note:
end


% --- Executes on button press in enabledROS.
function enabledROS_Callback(~,~, handles)
global ROS
 if get(handles.enabledROS,'Value') == 1 && ~isempty(get(handles.UrlROS,'String'))
  set(handles.UrlROS,'Enable','inactive');
  set(handles.portROS,'Enable','inactive');
  host = get(handles.UrlROS,'String');
  if isnan(str2double(get(handles.portROS,'String'))), port = 11311;
  else, port = str2double(get(handles.portROS,'String'));
  end
  if ~isempty(get(handles.UrlROS,'String'))
   try
    set(handles.statusROS,'Background',[1 1 0]); drawnow
    %- setenv('ROS_MASTER_URI',['http://','a',':','11311']);
    setenv('ROS_HOSTNAME',ROS.hostname);
    rosinit(host,port);
    set(handles.statusROS,'Background',[0 .9 0]);
    set(handles.statusROS,'Value',1);
   catch
    set(handles.statusROS,'Background',[1 0 0]);
    set(handles.statusROS,'Value',0);
   end
  end
 else
  set(handles.enabledROS,'Value',0)
  set(handles.UrlROS,'Enable','on');
  set(handles.portROS,'Enable','on');
  if ~isempty(get(handles.UrlROS,'String'))
   try
    rosshutdown
   catch
   end
  end
  set(handles.statusROS,'Background',[1 1 1]);
  set(handles.statusROS,'Value',0);
  % if isfield(ROS,'broker'), ROS = rmfield(ROS,'broker'); end
  % if isfield(ROS,'subs'), ROS = rmfield(ROS,'subs'); end
 end
end


% --- Executes on button press in enabledROS2.
function enabledROS2_Callback(~,~, handles)
global ROS
 if get(handles.enabledROS2,'Value') == 1 && ~isempty(get(handles.ROS2id,'String'))
  set(handles.ROS2id,'Enable','inactive');
  if isnan(str2double(get(handles.ROS2id,'String')))
   set(handles.ROS2id,'String','0');
  end
  ROS.rosDomainID = str2double(get(handles.ROS2id,'String'));
   setenv('ROS_DOMAIN_ID',num2str(ROS.rosDomainID));
   ROS.SARFISnode = ros2node('/SARFIS',ROS.rosDomainID);
 else
  set(handles.enabledROS2,'Value',0)
  set(handles.ROS2id,'Enable','on');
  delete(ROS.SARFISnode);
 end
end



% --- Executes on button press in enabledPositionUnknown.
function enabledPositionUnknown_Callback(~,~, handles)
global data ROS
 if get(handles.enabledPositionUnknown,'Value') && (get(handles.rosPositionUnknown,'Value') && get(handles.statusROS,'Value') || ~get(handles.rosPositionUnknown,'Value') && get(handles.enabledROS2,'Value'))
  topic = get(handles.topicPositionUnknown,'String');
  typeMsg = get(handles.typePositionUnknown,'String');
  if get(handles.rosPositionUnknown,'Value')
   data.ROS.SubMultilateration = rossubscriber(topic,typeMsg);
   data.ROS.SubMultilateration.NewMessageFcn = @(topic,msg)receiveROS(topic,msg,[],handles);
  else
   data.ROS.SubMultilateration = ros2subscriber(ROS.SARFISnode,topic,typeMsg,'Reliability','besteffort');
   data.ROS.SubMultilateration.NewMessageFcn = @(msg)receiveROS2(topic,msg,[],handles);
  end
  set(handles.topicPositionUnknown,'Enable','inactive');
  set(handles.typePositionUnknown,'Enable','inactive');
 else
  set(handles.enabledPositionUnknown,'Value',0);
  if isfield(data,'ROS') && isfield(data.ROS,'SubMultilateration')
   clear data.ROS.SubMultilateration;
   data.ROS = rmfield(data.ROS,'SubMultilateration');
  end
  set(handles.topicPositionUnknown,'Enable','on');
  set(handles.typePositionUnknown,'Enable','on');
 end
end

function receiveROS(topic, msg, idAgente, handles)
global data general
time = datetime('now','InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC');
time.Format = 'dd-MM-uuuu HH:mm:ss.SSS';
switch msg.MessageType
 case 'sensor_msgs/NavSatFix'
  if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub1')
   data.agentes(idAgente).config.ROS.histValueSub1(:,1) = [msg.Latitude msg.Longitude msg.Altitude];
   data.agentes(idAgente).config.ROS.histTimeSub1(:,1)  = time;
  else
   data.agentes(idAgente).config.ROS.histValueSub1(:,end+1) = [msg.Latitude msg.Longitude msg.Altitude];
   data.agentes(idAgente).config.ROS.histTimeSub1(:,end+1)  = time;
  end
  data.agentes(idAgente).config.ROS.valueSub1 = [msg.Latitude msg.Longitude msg.Altitude];
  % automatically changing the position mode in agents by receiving GPS ROStopic
  data.agentes(idAgente).config.modoPosicion = 6;
  % data.agents(idAgent).config.unidadPosicion = 0;
  data.agentes(idAgente).config.posicion = round(GPSll2utm([msg.Latitude msg.Longitude],30),8);
  % data.agents(idAgent).config.altitude = msg.Altitudee;
  % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
  if idAgente == get(handles.idAgente,'Value')
   %editAgent(handles);
   set(handles.posXAgente,'Value',data.agentes(idAgente).config.posicion(1));
   set(handles.posYAgente,'Value',data.agentes(idAgente).config.posicion(2));
   set(handles.radioUTMAgente,'Value',data.agentes(idAgente).config.sensorNodes.user.unidadPosicion);
   set(handles.radioGEOAgente,'Value',~data.agentes(idAgente).config.sensorNodes.user.unidadPosicion);
   radioUnitAgente(handles,false);
   set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
   set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
   % set(handles.radioUTMAgent_status,'Value',data.agents(idAgent).config.sensorNodes.user.unidadPosicion);
   % set(handles.radioGEOAgent_status,'Value',~data.agents(idAgent).config.sensorNodes.user.unidadPosicion);
   radioUnitAgente(handles,true);
   updateTableAgente(handles);
   runGraficaAgente(handles);
  end
  % if the detected node includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
  if isfield(data.agentes(idAgente).config.sensorNodes,'user') && isfield(data.agentes(idAgente).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(idAgente).config.sensorNodes.user.posicion) && ~mod(length(data.agentes(idAgente).config.ROS.histTimeSub1),1)
   general.updated = true;
  end
 case 'std_msgs/String'
  msg_item = strsplit(msg.Data,',');
  valor = {str2double(msg_item(1:end-1)) char(msg_item(end))};
  i=1; newItem = false; 
  if ~isfield(data,'unknownDevices')
   newItem = true;
  else
   while i<=length(data.unknownDevices) && ~strcmp(data.unknownDevices(i).idDevice,valor{2}), i = i+1; end
   if i>length(data.unknownDevices), newItem = true; end
  end
  if newItem
   data.unknownDevices(i).idDevice = valor{2};
   data.unknownDevices(i).long = NaN;
   data.unknownDevices(i).lat  = NaN;
   data.unknownDevices(i).alt  = NaN;
  end
  if strfind(topic.TopicName,'multilateration')
   %%%%% ================================================
   data.unknownDevices(i).long = valor{1}(1);
   data.unknownDevices(i).lat  = valor{1}(2);
   data.unknownDevices(i).alt  = valor{1}(3);
   posicion = round(GPSll2utm([data.unknownDevices(i).long data.unknownDevices(i).lat],30),8);
   %%% update POI or create a new one
   i=1; while isfield(data,'points') && i<=length(data.points) && ~strcmp(data.points(i).idFull,valor{2}), i = i+1; end
   if ~isfield(data,'points') || ( isfield(data,'points') && i>length(data.points) )
    numPOIs            = get(handles.numPOIs,'Value');
    idPOI              = numPOIs+1;
    data.points(idPOI) = POIInsertar( data.entorno,valor{2},1,1,1,posicion,NaN,NaN,...
                                      NaN,NaN,0,...
                                      0,1,0,0,0,...
                                      5,0,'',0,[]);
    if numPOIs < idPOI
     set(handles.numPOIs,'Value',numPOIs + 1);
     set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
    end
    set(handles.idPOI,'Enable','on');
    set(handles.addPOI_button,'Visible','on');
    % set(handles.removePOI_button,'Visible','on');
    set(handles.editPOI_button,'Visible','on');
    data.points(i).ROS.histValueSub2(:,1) = valor{1}(1:3);
    data.points(i).ROS.histTimeSub2(:,1)  = time;
   else
    data.points(i).ROS.histValueSub2(:,end+1) = valor{1}(1:3);
    data.points(i).ROS.histTimeSub2(:,end+1)  = time;
    data.points(i).modoPosicion   = 1;
    data.points(i).unidadPosicion = 1;
    data.points(i).posicion       = posicion;
   end
   % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
   idPOI = i;
   if idPOI == get(handles.idPOI,'Value')
    %editPOI(handles);
    set(handles.posXPOI,'Value',data.points(idPOI).posicion(1));
    set(handles.posYPOI,'Value',data.points(idPOI).posicion(2));
    set(handles.radioUTMPOI,'Value',data.points(idPOI).unidadPosicion);
    set(handles.radioGEOPOI,'Value',~data.points(idPOI).unidadPosicion);
    radioUnitPOI(handles,false);
    set(handles.posXPOI_status,'Value',get(handles.posXPOI,'Value'));
    set(handles.posYPOI_status,'Value',get(handles.posYPOI,'Value'));
    % set(handles.radioUTMPOI_status,'Value',data.points(idPOI).unidadPosicion);
    % set(handles.radioGEOPOI_status,'Value',~data.points(idPOI).unidadPosicion);
    radioUnitPOI(handles,true);
   end
   general.updated = true;
   %%%%% ================================================
  else
   data.agentes(idAgente).config.ROS.unknownDevices(i).dist    = valor{1}(1);
   data.agentes(idAgente).config.ROS.unknownDevices(i).desvTip = valor{1}(2);
   data.agentes(idAgente).config.ROS.unknownDevices(i).RSSI    = valor{1}(3);
   if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub2')
    data.agentes(idAgente).config.ROS.histValueSub2(:,1) = valor{1}(1:3);
    data.agentes(idAgente).config.ROS.histLabelSub2{:,1} = valor{2};
    data.agentes(idAgente).config.ROS.histTimeSub2(:,1)  = time;
   else
    data.agentes(idAgente).config.ROS.histValueSub2(:,end+1) = valor{1}(1:3);
    data.agentes(idAgente).config.ROS.histLabelSub2{:,end+1} = valor{2};
    data.agentes(idAgente).config.ROS.histTimeSub2(:,end+1)  = time;
   end
   % if the detected node that includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
   if isfield(data.agentes(idAgente).config.sensorNodes,'user') && isfield(data.agentes(idAgente).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(idAgente).config.sensorNodes.user.posicion)
    general.updated = true;
   end
  end
 case 'std_msgs/Float64MultiArray'
  %- frequency = data.agents(idAgent).config.ROSfreqSubs4;
  numValores = length(msg.Data)/5;
  valor = [msg.Data(1:numValores) msg.Data(numValores+[1:numValores]) msg.Data(2*numValores+[1:numValores]) msg.Data(3*numValores+[1:numValores]) msg.Data(4*numValores+[1:numValores])];
  times = datetime(datenum(valor(:,5)),'ConvertFrom','datenum');
  times.Format = 'dd-MM-uuuu HH:mm:ss.SSS';
  %- times = time-[numValores-1:-1:0]'*milliseconds(1000/frequency);
  if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub4')
   data.agentes(idAgente).config.ROS.histValueSub4 = valor;
   data.agentes(idAgente).config.ROS.histTimeSub4  = times;
  else
   data.agentes(idAgente).config.ROS.histValueSub4 = [data.agentes(idAgente).config.ROS.histValueSub4; valor];
   data.agentes(idAgente).config.ROS.histTimeSub4  = [data.agentes(idAgente).config.ROS.histTimeSub4; times];
  end
  if idAgente == get(handles.idAgente,'Value')
   runGraficaAgente(handles);
  end
 case 'std_msgs/Bool'
  UGV = topic.TopicName(length(data.agentes(idAgente).config.ROSnameSpace)+1:end);
  if strcmp(data.agentes(idAgente).config.ROStopicSubs3a,UGV), k = 1;
  elseif strcmp(data.agentes(idAgente).config.ROStopicSubs3b,UGV), k = 2;
  else, k = 3;
  end
  if data.agentes(idAgente).config.calling_status(k)~=msg.Data
   data.agentes(idAgente).config.calling_status(k) = msg.Data;
   i=1; while i<=length(data.agentes) && ~strcmp(data.agentes(i).config.idFull,UGV), i = i+1; end
   data.agentes(i).config.enable = msg.Data;
   if i == get(handles.idAgente,'Value')
    set(handles.enableAgente,'Value',msg.Data);
   end
   if msg.Data && i<=length(data.agentes)
    posicion = data.agentes(idAgente).config.posicion;
    %%% create a temporal POI to run a path planning
    numPOIs            = get(handles.numPOIs,'Value');
    idPOI              = numPOIs+1;
    data.points(idPOI) = POIInsertar( data.entorno,'Temporal POI',0,1,1,posicion,NaN,NaN,...
                                      NaN,NaN,0,...
                                      0,1,0,0,0,...
                                      5,0,'',1,data.points(idPOI).ROS);
    if numPOIs < idPOI
     set(handles.numPOIs,'Value',numPOIs + 1);
     set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
    end
    set(handles.idPOI,'Enable','on');
    set(handles.addPOI_button,'Visible','on');
    % set(handles.removePOI_button,'Visible','on');
    set(handles.editPOI_button,'Visible','on');
    if isfield(data,'agentes'), set(handles.PLANNER_button,'Enable','on'); end
    set(handles.rutas,'Data',{});
    set(handles.aisladas,'String',{});
    if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
       && get(handles.AutomaticPlanning,'Value')
     PLANNER_function(handles);
    else
     general.updated = true;
    end
   end
  end
end
end

function receiveROS2(topic, msg, idAgente, handles)
global data general
time = datetime('now','InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC');
time.Format = 'dd-MM-uuuu HH:mm:ss.SSS';
switch msg.MessageType
 case 'sensor_msgs/NavSatFix'
  if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub1')
   data.agentes(idAgente).config.ROS.histValueSub1(:,1) = [msg.latitude msg.longitude msg.altitude];
   data.agentes(idAgente).config.ROS.histTimeSub1(:,1)  = time;
  else
   data.agentes(idAgente).config.ROS.histValueSub1(:,end+1) = [msg.latitude msg.longitude msg.altitude];
   data.agentes(idAgente).config.ROS.histTimeSub1(:,end+1)  = time;
  end
  data.agentes(idAgente).config.ROS.valueSub1 = [msg.latitude msg.longitude msg.altitude];
  % automatically changing the position mode in agents by receiving GPS ROStopic
  data.agentes(idAgente).config.modoPosicion = 6;
  % data.agents(idAgent).config.unidadPosicion = 0;
  data.agentes(idAgente).config.posicion = round(GPSll2utm([msg.latitude msg.longitude],30),8);
  % data.agents(idAgent).config.altitude = msg.altitudee;
  % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
  if idAgente == get(handles.idAgente,'Value')
   %editAgent(handles);
   set(handles.posXAgente,'Value',data.agentes(idAgente).config.posicion(1));
   set(handles.posYAgente,'Value',data.agentes(idAgente).config.posicion(2));
   set(handles.radioUTMAgente,'Value',data.agentes(idAgente).config.sensorNodes.user.unidadPosicion);
   set(handles.radioGEOAgente,'Value',~data.agentes(idAgente).config.sensorNodes.user.unidadPosicion);
   radioUnitAgente(handles,false);
   set(handles.posXAgente_status,'Value',get(handles.posXAgente,'Value'));
   set(handles.posYAgente_status,'Value',get(handles.posYAgente,'Value'));
   % set(handles.radioUTMAgent_status,'Value',data.agents(idAgent).config.sensorNodes.user.unidadPosicion);
   % set(handles.radioGEOAgent_status,'Value',~data.agents(idAgent).config.sensorNodes.user.unidadPosicion);
   radioUnitAgente(handles,true);
   updateTableAgente(handles);
   runGraficaAgente(handles);
  end
  % if the detected node includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
  if isfield(data.agentes(idAgente).config.sensorNodes,'user') && isfield(data.agentes(idAgente).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(idAgente).config.sensorNodes.user.posicion) && ~mod(length(data.agentes(idAgente).config.ROS.histTimeSub1),1)
   general.updated = true;
  end
 case 'std_msgs/String'
  msg_item = strsplit(msg.data,',');
  valor = {str2double(msg_item(1:end-1)) char(msg_item(end))};
  i=1; newItem = false; 
  if ~isfield(data,'unknownDevices')
   newItem = true;
  else
   while i<=length(data.unknownDevices) && ~strcmp(data.unknownDevices(i).idDevice,valor{2}), i = i+1; end
   if i>length(data.unknownDevices), newItem = true; end
  end
  if newItem
   data.unknownDevices(i).idDevice = valor{2};
   data.unknownDevices(i).long = NaN;
   data.unknownDevices(i).lat  = NaN;
   data.unknownDevices(i).alt  = NaN;
  end
  if strfind(topic,'multilateration')
   %%%%% ================================================
   data.unknownDevices(i).long = valor{1}(1);
   data.unknownDevices(i).lat  = valor{1}(2);
   data.unknownDevices(i).alt  = valor{1}(3);
   posicion = round(GPSll2utm([data.unknownDevices(i).long data.unknownDevices(i).lat],30),8);
   %%% update POI or create a new one
   i=1; while isfield(data,'points') && i<=length(data.points) && ~strcmp(data.points(i).idFull,valor{2}), i = i+1; end
   if ~isfield(data,'points') || ( isfield(data,'points') && i>length(data.points) )
    numPOIs            = get(handles.numPOIs,'Value');
    idPOI              = numPOIs+1;
    data.points(idPOI) = POIInsertar( data.entorno,valor{2},1,1,1,posicion,NaN,NaN,...
                                      NaN,NaN,0,...
                                      0,1,0,0,0,...
                                      5,0,'',0,[]);
    if numPOIs < idPOI
     set(handles.numPOIs,'Value',numPOIs + 1);
     set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
    end
    set(handles.idPOI,'Enable','on');
    set(handles.addPOI_button,'Visible','on');
    % set(handles.removePOI_button,'Visible','on');
    set(handles.editPOI_button,'Visible','on');
    data.points(i).ROS.histValueSub2(:,1) = valor{1}(1:3);
    data.points(i).ROS.histTimeSub2(:,1)  = time;
   else
    data.points(i).ROS.histValueSub2(:,end+1) = valor{1}(1:3);
    data.points(i).ROS.histTimeSub2(:,end+1)  = time;
    data.points(i).modoPosicion   = 1;
    data.points(i).unidadPosicion = 1;
    data.points(i).posicion       = posicion;
   end
   % if the detected node belongs to the current monitored agent, the application updates values into tables and graphs
   idPOI = i;
   if idPOI == get(handles.idPOI,'Value')
    %editPOI(handles);
    set(handles.posXPOI,'Value',data.points(idPOI).posicion(1));
    set(handles.posYPOI,'Value',data.points(idPOI).posicion(2));
    set(handles.radioUTMPOI,'Value',data.points(idPOI).unidadPosicion);
    set(handles.radioGEOPOI,'Value',~data.points(idPOI).unidadPosicion);
    radioUnitPOI(handles,false);
    set(handles.posXPOI_status,'Value',get(handles.posXPOI,'Value'));
    set(handles.posYPOI_status,'Value',get(handles.posYPOI,'Value'));
    % set(handles.radioUTMPOI_status,'Value',data.points(idPOI).unidadPosicion);
    % set(handles.radioGEOPOI_status,'Value',~data.points(idPOI).unidadPosicion);
    radioUnitPOI(handles,true);
   end
   general.updated = true;
   %%%%% ================================================
  else
   data.agentes(idAgente).config.ROS.unknownDevices(i).dist    = valor{1}(1);
   data.agentes(idAgente).config.ROS.unknownDevices(i).desvTip = valor{1}(2);
   data.agentes(idAgente).config.ROS.unknownDevices(i).RSSI    = valor{1}(3);
   if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub2')
    data.agentes(idAgente).config.ROS.histValueSub2(:,1) = valor{1}(1:3);
    data.agentes(idAgente).config.ROS.histLabelSub2{:,1} = valor{2};
    data.agentes(idAgente).config.ROS.histTimeSub2(:,1)  = time;
   else
    data.agentes(idAgente).config.ROS.histValueSub2(:,end+1) = valor{1}(1:3);
    data.agentes(idAgente).config.ROS.histLabelSub2{:,end+1} = valor{2};
    data.agentes(idAgente).config.ROS.histTimeSub2(:,end+1)  = time;
   end
   % if the detected node that includes GPS location with coordinates belong to environmental dimension, the application refreshes the map
   if isfield(data.agentes(idAgente).config.sensorNodes,'user') && isfield(data.agentes(idAgente).config.sensorNodes.user,'posicion') && ~isempty(data.agentes(idAgente).config.sensorNodes.user.posicion)
    general.updated = true;
   end
  end
 case 'std_msgs/Float64MultiArray'
  %- frequency = data.agents(idAgent).config.ROSfreqSubs4;
  numValores = length(msg.Data)/5;
  valor = [msg.Data(1:numValores) msg.Data(numValores+[1:numValores]) msg.Data(2*numValores+[1:numValores]) msg.Data(3*numValores+[1:numValores]) msg.Data(4*numValores+[1:numValores])];
  times = datetime(datenum(valor(:,5)),'ConvertFrom','datenum');
  times.Format = 'dd-MM-uuuu HH:mm:ss.SSS';
  %- times = time-[numValores-1:-1:0]'*milliseconds(1000/frequency);
  if ~isfield(data.agentes(idAgente).config.ROS,'histValueSub4')
   data.agentes(idAgente).config.ROS.histValueSub4 = valor;
   data.agentes(idAgente).config.ROS.histTimeSub4  = times;
  else
   data.agentes(idAgente).config.ROS.histValueSub4 = [data.agentes(idAgente).config.ROS.histValueSub4; valor];
   data.agentes(idAgente).config.ROS.histTimeSub4  = [data.agentes(idAgente).config.ROS.histTimeSub4; times];
  end
  if idAgente == get(handles.idAgente,'Value')
   runGraficaAgente(handles);
  end
 case 'std_msgs/Bool'
  UGV = topic.TopicName(length(data.agentes(idAgente).config.ROSnameSpace)+1:end);
  if strcmp(data.agentes(idAgente).config.ROStopicSubs3a,UGV), k = 1;
  elseif strcmp(data.agentes(idAgente).config.ROStopicSubs3b,UGV), k = 2;
  else, k = 3;
  end
  if data.agentes(idAgente).config.calling_status(k)~=msg.Data
   data.agentes(idAgente).config.calling_status(k) = msg.Data;
   i=1; while i<=length(data.agentes) && ~strcmp(data.agentes(i).config.idFull,UGV), i = i+1; end
   data.agentes(i).config.enable = msg.Data;
   if i == get(handles.idAgente,'Value')
    set(handles.enableAgente,'Value',msg.Data);
   end
   if msg.Data && i<=length(data.agentes)
    posicion = data.agentes(idAgente).config.posicion;
    %%% create a temporal POI to run a path planning
    numPOIs            = get(handles.numPOIs,'Value');
    idPOI              = numPOIs+1;
    data.points(idPOI) = POIInsertar( data.entorno,'Temporal POI',0,1,1,posicion,NaN,NaN,...
                                      NaN,NaN,0,...
                                      0,1,0,0,0,...
                                      5,0,'',1,data.points(idPOI).ROS);
    if numPOIs < idPOI
     set(handles.numPOIs,'Value',numPOIs + 1);
     set(handles.numPOIs,'String',num2str(get(handles.numPOIs,'Value')));
    end
    set(handles.idPOI,'Enable','on');
    set(handles.addPOI_button,'Visible','on');
    % set(handles.removePOI_button,'Visible','on');
    set(handles.editPOI_button,'Visible','on');
    if isfield(data,'agentes'), set(handles.PLANNER_button,'Enable','on'); end
    set(handles.rutas,'Data',{});
    set(handles.aisladas,'String',{});
    if strcmp(get(handles.PLANNER_button,'Enable'),'on') ...
       && get(handles.AutomaticPlanning,'Value')
     PLANNER_function(handles);
    else
     general.updated = true;
    end
   end
  end
 case {'sensor_msgs/Image','sensor_msgs/CompressedImage'}
  if idAgente == get(handles.idAgente,'Value')
   if isfield(data.agentes(idAgente).config.ROS,'Camera') && data.agentes(idAgente).config.enabledCamera && strcmp(data.agentes(idAgente).config.ROS.Camera.TopicName, topic) && strcmp(get(handles.camera_status,'Visible'),'on')
    img = rosReadImage(msg);
    if isempty(handles.camara.Children)
     axes(handles.camara);
     imshow(img);
    else
     set(handles.camara.Children,'CData',img);
    end
   end
  end
 end
end
