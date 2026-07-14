function mostrarFigura(~,~,handles)
global data general
 if general.updatedEnv
  general.updatedEnv = false;
  set(groot,'CurrentFigure',handles.Main);
  hfigure = get(groot,'CurrentFigure');
  for numFigure=1:2
   if numFigure==1, set(hfigure,'CurrentAxes',handles.figura);
   else, set(hfigure,'CurrentAxes',handles.figuraZoom);
   end
   EntornoRepresentar(data.entorno,pink(1000),numFigure);
   hold on;
  end
  general.updated = true;
 end
 if general.updated
  general.updated = false;
  set(groot,'CurrentFigure',handles.Main);
  hfigure = get(groot,'CurrentFigure');
  for numFigure=1:2
   if numFigure==1, set(hfigure,'CurrentAxes',handles.figura);
   else, set(hfigure,'CurrentAxes',handles.figuraZoom);
   end
   %tic
   numPrevTrayectorias = 0;
   if numFigure == 1 && isfield(general,'trajectory'), numPrevTrayectorias = numel(general.trajectory); end
   if numFigure == 2 && isfield(general,'trajectoryZoom'), numPrevTrayectorias = numel(general.trajectoryZoom); end
   numTrayectorias = 0;
   if isfield(data,'planner') && isfield(data.planner,'optima') && isfield(data.planner.optima,'sA') && isfield(data.planner.optima,'sV') && isfield(data.planner.ini,'Ak')
    numTrayectorias = numel(data.planner.optima.sV);
   end
   for i = 1:max(numPrevTrayectorias,numTrayectorias)
    TrayectoriaRepresentar(handles,i,numTrayectorias,numFigure);
   end
   numPrevAgentes = 0;
   if numFigure == 1 && isfield(general,'agent'), numPrevAgentes = numel(general.agent); end
   if numFigure == 2 && isfield(general,'agentZoom'), numPrevAgentes = numel(general.agentZoom); end
   numAgentes = get(handles.numAgentes,'Value');
   for i = 1:max(numPrevAgentes,numAgentes)
    if i <= numAgentes, datoAgente = data.agentes(i).config; else, datoAgente = []; end
    AgenteRepresentar(handles,data.entorno,datoAgente,i,numAgentes,data,numFigure);
   end
   numPrevObjetivos = 0;
   if numFigure == 1 && isfield(general,'target'), numPrevObjetivos = numel(general.target); end
   if numFigure == 2 && isfield(general,'targetZoom'), numPrevObjetivos = numel(general.targetZoom); end
   numObjetivos = get(handles.numObjetivos,'Value');
   for i = 1:max(numPrevObjetivos,numObjetivos)
    ObjetivoRepresentar(handles,data.entorno,data.sensorNodes(i),i,numObjetivos,numFigure);
   end
   numPrevPOIs = 0;
   if numFigure == 1 && isfield(general,'POI'), numPrevPOIs = numel(general.POI); end
   if numFigure == 2 && isfield(general,'POIZoom'), numPrevPOIs = numel(general.POIZoom); end
   numPOIs = get(handles.numPOIs,'Value');
   for i = 1:max(numPrevPOIs,numPOIs)
    if i <= numPOIs, datoPOI = data.points(i); else, datoPOI = []; end
    POIRepresentar(handles,data.entorno,datoPOI,i,numPOIs,numFigure);
   end
   %drawnow limitrate
   %%%% drawnow
   %toc
   %disp(' ');
  end
 end
end