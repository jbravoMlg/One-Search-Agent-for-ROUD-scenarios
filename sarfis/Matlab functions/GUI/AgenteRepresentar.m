function [] = AgenteRepresentar( handles,entorno,datoAgente,ID,numAgentes,data,numFigure )
global LoRa general

%% Check whether the agent position is inside the displayed environment limits.
minimoX = entorno.minX; maximoX = entorno.minX+entorno.dimX*entorno.deltaXY;
minimoY = entorno.minY; maximoY = entorno.minY+entorno.dimY*entorno.deltaXY;
if ID > numAgentes
 warnPos = true;
else
 valX = datoAgente.posicion(1); valY = datoAgente.posicion(2);
 warnPos = (valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY);
end

%% Render the agent in the environment.
graficos = 1; % if environment.ejemplo == 0, graficos = 2; end
while graficos ~= 0
 if graficos == 2
  subplot 121;
% else
%  if environment.ejemplo == 0, subplot 122; end
 end
 prompt = '';
 if ~warnPos
  % Render a fixed-size outer box proportional to zoom.
 % vertices = [-0.50 -0.50 +0.50 +0.50 -0.50
 %             -0.50 +0.50 +0.50 -0.50 -0.50]';
 %%% vertices = [-0.20 -0.50 -0.50 -0.20 +0.20 +0.50 +0.50 +0.20 -0.20
 %%%             -0.50 -0.20 +0.20 +0.50 +0.50 +0.20 -0.20 -0.50 -0.50]';
 %%% Optional zoom-scaled safety-boundary code omitted.
 %  escala = 0.9*diag([1 1])*environment.deltaXY;
 %%% scale = diag([1 1])*.035*(axesLimits(2)-axesLimits(1));
 %%% else
 %%%  escala = diag([datoAgent.tipoAgent.distSeg datoAgent.tipoAgent.distSeg]);
 %%% end
 %%% vertices = (2*escala*vertices');
 %%% vertices = vertices + repmat(datoAgent.posicion', 1, size(vertices, 2));
 %  patch('Faces',1:size(vertices,2),'Vertices',vertices',...
 %        'EdgeColor','k','LineWidth',1,...
 %        'FaceColor',[0 1 1]);
  % Render agent occupancy in the environment.
 % for x = datoAgent.grid.xMin:datoAgent.grid.xMax
 %  for y = datoAgent.grid.yMin:datoAgent.grid.yMax
 %   if datoAgent.grid.ocupacion(x,y) == 1
 %    DibujarCeldaRejilla(environment,[x y],...
 %                        datoAgent.tipoAgent.color,1);
 %   end
 %  end
 % end
  % Render the agent safety boundary.
 %  vertices = (datoAgent.tipoAgent.contornoSeguridad'*[cosd(datoAgent.theta-90) sind(datoAgent.theta-90)
 %                                                   -sind(datoAgent.theta-90) cosd(datoAgent.theta-90)])';
 %  vertices = vertices + repmat(datoAgent.posicion', 1, size(vertices, 2));
 %  patch('Faces',1:size(vertices,2),'Vertices',vertices',...
 %        'FaceColor','none','LineStyle',':');
 % t=0:pi/30:2*pi;
 % x = (datoAgent.tipoAgent.distSeg)*cos(t)+datoAgent.posicion(1);
 % y = (datoAgent.tipoAgent.distSeg)*sin(t)+datoAgent.posicion(2);
 % plot(x,y,'Color',datoAgent.tipoAgent.color,'LineStyle',':','LineWidth',1.25);
  % plot(x,y,'k:');
  % Render the agent boundary.
 % vertices = (datoAgent.tipoAgent.contorno'*[cosd(datoAgent.theta-90) sind(datoAgent.theta-90)
 %                                         -sind(datoAgent.theta-90) cosd(datoAgent.theta-90)])';
 % vertices = vertices + repmat(datoAgent.posicion', 1, size(vertices, 2));
 % patch('Faces',1:size(vertices,2),'Vertices',vertices',...
 %       'FaceColor',datoAgent.tipoAgent.color);
  %% Render the agent identifier in the environment.
  % Check whether a known agent altitude value is identified.
  if isfield(datoAgente.ROS,'valueSub1') && ~isnan(datoAgente.ROS.valueSub1(3))
    prompt = {['{\color{black}',char(sprintf("%.2f",datoAgent.ROS.valueSub1(3))),'}']};  % Formerly subtracted 99.5 m (PCA altitude).
  else
   prompt = {''};
  end
  if datoAgente.visible
   if isempty(datoAgente.idFull)
    prompt{length(prompt)+1} = ['{\color[rgb]{',num2str(datoAgente.color(1)),',',num2str(datoAgente.color(2)),',',num2str(datoAgente.color(3)),'}\fontsize{14}',char(9726),'}'];
    % prompt{length(prompt)+1} = ['{\color[rgb]{',num2str(datoAgent.color(1)),',',num2str(datoAgent.color(2)),',',num2str(datoAgent.color(3)),'}\fontsize{14}',char(9726),'} ',num2str(ID)];
    prompt{length(prompt)+1} = '';
   else
    prompt{length(prompt)+1} = ['{\color[rgb]{',num2str(datoAgente.color(1)),',',num2str(datoAgente.color(2)),',',num2str(datoAgente.color(3)),'}\fontsize{14}',char(9726),'}'];
    % prompt{length(prompt)+1} = ['{\color[rgb]{',num2str(datoAgent.color(1)),',',num2str(datoAgent.color(2)),',',num2str(datoAgent.color(3)),'}\fontsize{14}',char(9726),'} ',num2str(ID)];
    prompt{length(prompt)+1} = datoAgente.idFull;
   end
   for j = 1:length(LoRa.keys)
    if isfield(datoAgente.sensorNodes.automatic,'enableMap') && datoAgente.sensorNodes.automatic.enableMap(j)
     key = char(LoRa.keys{j}(4));
     prompt{length(prompt)+1} = ['{\color{gray}',key,'=',char(sprintf("%.1f",datoAgent.sensorNodes.automatic.valor(j))),char(LoRa.keys{j}(6)),'}'];
    end
   end
   if ( numFigure == 1 && ( ~isfield(general,'agent') || ( isfield(general,'agent') && ( ID > numel(general.agent) ) ) ) ) || ...
      ( numFigure == 2 && ( ~isfield(general,'agentZoom') || ( isfield(general,'agentZoom') && ( ID > numel(general.agentZoom) ) ) ) )
    if numFigure == 1
     general.agent(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
          'Background','none',... % 'w',...
          'Color','k',... % 'FontWeight','bold',...
          'HorizontalAlignment','center',...
          'Visible','on');
    else
     general.agentZoom(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
          'Background','none',... % 'w',...
          'Color','k',... % 'FontWeight','bold',...
          'HorizontalAlignment','center',...
          'Visible','on');
    end
   else
    if ID <= numAgentes
     if numFigure == 1, set(general.agent(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String',prompt,'Visible','on'); end
     if numFigure == 2, set(general.agentZoom(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String',prompt,'Visible','on'); end
    else
     if numFigure == 1, general.agent(end) = []; end
     if numFigure == 2, general.agentZoom(end) = []; end
    end
   end
  else
    prompt{length(prompt)+1} = ['{\color[rgb]{',num2str(datoAgente.color(1)),',',num2str(datoAgente.color(2)),',',num2str(datoAgente.color(3)),'}\fontsize{10}',char(9726),'}'];
    %if isfield(datoAgent.ROS,'valueSub1') && ~isnan(datoAgent.ROS.valueSub1(3))
     prompt{length(prompt)+1} = '';
    %end
    if ( numFigure == 1 && ( ~isfield(general,'agent') || ( isfield(general,'agent') && ID > numel(general.agent) ) ) ) || ...
       ( numFigure == 2 && ( ~isfield(general,'agentZoom') || ( isfield(general,'agentZoom') && ID > numel(general.agentZoom) ) ) )
     if numFigure == 1
      general.agent(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
           'Background','none',... % 'w',...
           'Color','k',... % 'FontWeight','bold',...
           'HorizontalAlignment','center',...
           'Visible','on');
     else
      general.agentZoom(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
           'Background','none',... % 'w',...
           'Color','k',... % 'FontWeight','bold',...
           'HorizontalAlignment','center',...
           'Visible','on');
     end         
    else
     if ID <= numAgentes
      if numFigure == 1, set(general.agent(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String',prompt,'Visible','on'); end
      if numFigure == 2, set(general.agentZoom(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String',prompt,'Visible','on'); end
     else
      if numFigure == 1, set(general.agent(end).text,'Visible','off'); end
      if numFigure == 2, set(general.agentZoom(end).text,'Visible','off'); end
      if numFigure == 1, general.agent(end) = []; end
      if numFigure == 2, general.agentZoom(end) = []; end
     end
    end
   %plot(datoAgent.posicion(1),datoAgent.posicion(2),'s',...
   %     'MarkerSize',10,...
   %     'MarkerEdgeColor','w',...
   %     'MarkerFaceColor',datoAgent.color);
  end
  if isfield(datoAgente.ROS,'unknownDevices')
   numCircles = 0; 
   for i=1:length(data.unknownDevices)
    if i<=length(datoAgente.ROS.unknownDevices) && ~isempty(datoAgente.ROS.unknownDevices(i).dist) && ~isnan(datoAgente.ROS.unknownDevices(i).dist), numCircles = numCircles+1; end
    if ( numFigure == 1 && ( isfield(general.agent(ID),'circle') && i<=numel(general.agent(ID).circle) ) ) || ...
       ( numFigure == 2 && ( isfield(general.agentZoom(ID),'circle') && i<=numel(general.agentZoom(ID).circle) ) )
     if numFigure == 1, set(general.agent(ID).circle{i},'Visible','off'); end
     if numFigure == 2, set(general.agentZoom(ID).circle{i},'Visible','off'); end
    end
    if ( numFigure == 1 && ( isfield(general,'agent') && ID <= numel(general.agent) && isfield(general.agent(ID),'textCircle') && i <= numel(general.agent(ID).textCircle) ) ) || ...
       ( numFigure == 2 && ( isfield(general,'agentZoom') && ID <= numel(general.agentZoom) && isfield(general.agentZoom(ID),'textCircle') && i <= numel(general.agentZoom(ID).textCircle) ) )
     if numFigure == 1, set(general.agent(ID).textCircle{i},'Visible','off'); end
     if numFigure == 2, set(general.agentZoom(ID).textCircle{i},'Visible','off'); end
    end
   end
   timeNow = datetime('now','InputFormat','uuuu-MM-dd''T''HH:mm:ss.SX','TimeZone','UTC');
   timeNow.Format = 'dd-MM-uuuu HH:mm:ss.SSS';
   for i=1:length(data.unknownDevices)
    if i<=length(datoAgente.ROS.unknownDevices), radius = datoAgente.ROS.unknownDevices(i).dist; else radius = NaN; end
    if ~isempty(radius) && ~isnan(radius) && seconds(timeNow-datoAgente.ROS.histTimeSub2(:,end))<2
     pos = circle(datoAgente.posicion(1),datoAgente.posicion(2),radius,ID,i,numCircles);
     if radius > 8 || numFigure == 2     % > 5
      if radius > 20 || numFigure == 2   % > 20
       label = strcat(data.unknownDevices(i).idDevice,' (',num2str(datoAgente.ROS.unknownDevices(i).RSSI),')');
      else
       label = strcat(data.unknownDevices(i).idDevice);
      end
     else
      label = '';
     end
     if ( numFigure == 1 && ( isfield(general,'agent') && ID <= numel(general.agent) && isfield(general.agent(ID),'textCircle') && i <= numel(general.agent(ID).textCircle) ) ) || ...
        ( numFigure == 2 && ( isfield(general,'agentZoom') && ID <= numel(general.agentZoom) && isfield(general.agentZoom(ID),'textCircle') && i <= numel(general.agentZoom(ID).textCircle) ) )
      if numFigure == 1, set(general.agent(ID).textCircle{i},'Position',[pos(1) pos(2) 0],'String',label,'Visible','on'); end
      if numFigure == 2, set(general.agentZoom(ID).textCircle{i},'Position',[pos(1) pos(2) 0],'String',label,'Visible','on'); end
     else
      if numFigure == 1
       general.agent(ID).textCircle{i} = text(pos(1),pos(2),label,...
            'Background', (1 - 0.1*(1-datoAgente.color)) ,... %  datoAgent.color,... % 'w'
            'Color','k',...
            'HorizontalAlignment','center',...
            'Visible','on');
      else
       general.agentZoom(ID).textCircle{i} = text(pos(1),pos(2),label,...
            'Background', (1 - 0.1*(1-datoAgente.color)) ,... %  datoAgent.color,... % 'w'
            'Color','k',...
            'HorizontalAlignment','center',...
            'Visible','on');
      end
     end
    end
   end
  end
 else
  if ( numFigure == 1 && ( ~isfield(general,'agent') || ( isfield(general,'agent') && ( ID > numel(general.agent) ) ) ) ) || ...
     ( numFigure == 2 && ( ~isfield(general,'agentZoom') || ( isfield(general,'agentZoom') && ( ID > numel(general.agentZoom) ) ) ) )
   if numFigure == 1
    general.agent(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
         'Background','none',... % 'w',...
         'Color','k',...%'FontWeight','bold',...
         'HorizontalAlignment','center',...
         'Visible','off');
   else
    general.agentZoom(ID).text = text(datoAgente.posicion(1),datoAgente.posicion(2),prompt,...
         'Background','none',... % 'w',...
         'Color','k',...%'FontWeight','bold',...
         'HorizontalAlignment','center',...
         'Visible','off');
   end
  else
   if ID <= numAgentes
    if numFigure == 1, set(general.agent(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String','','Visible','off'); end
    if numFigure == 2, set(general.agentZoom(ID).text,'Position',[datoAgente.posicion(1) datoAgente.posicion(2) 0],'String','','Visible','off'); end
   else
    if numFigure == 1, set(general.agent(end).text,'Visible','off'); end
    if numFigure == 2, set(general.agentZoom(end).text,'Visible','off'); end
    if numFigure == 1, general.agent(end) = []; end
    if numFigure == 2, general.agentZoom(end) = []; end
   end
  end
 end
 graficos = graficos-1;
 end

 function xmed = circle(x,y,r,ID,i,numCircles)
  step_th = (2*pi)/50;
  th = [pi/2:step_th:2*pi 0:step_th:pi/2];
  xunit = r * cos(th) + x;
  yunit = r * sin(th) + y;
  X = xunit(xunit > minimoX & xunit < maximoX & yunit > minimoY & yunit < maximoY);
  Y = yunit(xunit > minimoX & xunit < maximoX & yunit > minimoY & yunit < maximoY);
  valMin = inf;
  for jj=2:length(X)
   if sqrt((X(jj)-X(jj-1))^2+(Y(jj)-Y(jj-1))^2) < valMin
    valMin = jj-1;
   end
  end
  X = [X(valMin:end) X(1:valMin)];
  Y = [Y(valMin:end) Y(1:valMin)];
  if ( numFigure == 1 && ( ~isfield(general.agent(ID),'circle') || ( isfield(general.agent(ID),'circle') && i > numel(general.agent(ID).circle) ) ) ) || ...
     ( numFigure == 2 && ( ~isfield(general.agentZoom(ID),'circle') || ( isfield(general.agentZoom(ID),'circle') && i > numel(general.agentZoom(ID).circle) ) ) )
   if numFigure == 1, general.agent(ID).circle{i} = plot(X,Y,"LineWidth",1.5,"Color",datoAgente.color,'Visible','on'); end
   if numFigure == 2, general.agentZoom(ID).circle{i} = plot(X,Y,"LineWidth",1.5,"Color",datoAgente.color,'Visible','on'); end
  else
   if numFigure == 1, set(general.agent(ID).circle{i},'XData',X,'YData',Y,"Color",datoAgente.color,'Visible','on'); end
   if numFigure == 2, set(general.agentZoom(ID).circle{i},'XData',X,'YData',Y,"Color",datoAgente.color,'Visible','on'); end
  end
  % cpyY = unique(Y);
  % k = find(X<=(cpyY(1)+cpyY(end))/2,1,'last');
  % xmed = [X(k) Y(k)];
  xmed = [r * cos(th(6*(i-1)+1)) + x r * sin(th(6*(i-1)+1)) + y];
 end

end
