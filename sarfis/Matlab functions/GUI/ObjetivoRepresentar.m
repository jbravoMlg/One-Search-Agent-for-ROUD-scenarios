function [] = ObjetivoRepresentar( handles,entorno,objetivo,ID,numObjetivos,numFigure )
global LoRa

%%%%% Note: the final arguments are not implemented because they are unused in this workflow.

%% Check whether the target position is inside the displayed environment limits.
minimoX = entorno.minX; maximoX = entorno.minX+entorno.dimX*entorno.deltaXY;
minimoY = entorno.minY; maximoY = entorno.minY+entorno.dimY*entorno.deltaXY;
if isfield(objetivo.user,'posicion')
 valX = objetivo.user.posicion(1); valY = objetivo.user.posicion(2);
end
warnPos = isfield(objetivo.user,'posicion') && (valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY);
%warnPos = (valX < minimoX || valX > maximoX || valY < minimoY || valY > maximoY);

%% Render the target in the environment.
graficos = 1; % if environment.ejemplo == 0 graficos = 2; end
while graficos ~= 0
 if graficos == 2
  subplot 121;
% else
%  if environment.ejemplo == 0 subplot 122; end
 end
 %% Select color according to target priority.
 switch objetivo.user.prioridad
  case 1
  color = [  1   0   0];        % red - highest priority, immediate attention
  case 2
  color = [255 165   0]./255;	 % orange - emergency (~10-15 minutes)
  case 3
  color = [  1   1   0];        % yellow - urgent (~60 minutes)
  case 4
  color = [  0 128   0]./255;	 % green - minor urgency (~2 hours)
  case 5
  color = [  0   0   1];        % blue - non-urgent (~4 hours)
  otherwise
  color = [  0   0   0];        % black - no attention required
 end
 %% Render victim occupancy in the environment.
 % for x = victim.grid.xMin:victim.grid.xMax
 %  for y = victim.grid.yMin:victim.grid.yMax
 %   if victim.grid.ocupacion(x,y) == 1
 %    DibujarCeldaRejilla(environment,[x y],...
 %                        color,1);
 %   end
 % end
 % end
 %% Render a fixed-size outer box proportional to zoom.
 if isfield(objetivo.user,'posicion') && ~isempty(objetivo.user.posicion)
  vertices = [-0.50 -0.50 +0.50 +0.50 -0.50
              -0.50 +0.50 +0.50 -0.50 -0.50]';
  if objetivo.user.aproximacion < .035*(handles.figura.XLim(2)-handles.figura.XLim(1))
   escala = diag([1 1])*.035*(handles.figura.XLim(2)-handles.figura.XLim(1));
  else
   escala = diag([objetivo.user.aproximacion objetivo.user.aproximacion]);
  end
  vertices = (escala*vertices');
  vertices = vertices + repmat(objetivo.user.posicion', 1, size(vertices, 2));
%   patch('Faces',1:size(vertices,2),'Vertices',vertices',...
%         'EdgeColor','k','LineWidth',1,...
%         'FaceColor',color);
  % Render the victim position-uncertainty area.
%  vertices = victim.contornoIncertidumbre;
%  vertices = vertices + repmat(victim.posicion', 1, size(vertices, 2));
%  patch('Faces',1:size(vertices,2),'Vertices',vertices',...
%        'FaceColor','none','LineStyle',':');
  %% Render the victim position in the environment.
%  vertices = victim.contornoVictima;
%  vertices = vertices + repmat(victim.posicion', 1, size(vertices, 2));
%  patch('Faces',1:3,'Vertices',vertices','FaceColor',color);
  %% Render the victim identifier in the environment.
  if ~warnPos
   % if target.user.prioridad > 3, color = 'white'; else, color = 'black'; end
   % prompt = {['{\color{red}\fontsize{16}',char(9708),char(10304),char(10308),char(10310),char(10311),'} ',num2str(ID)]
   %           target.user.idFull};
   if objetivo.user.visible
    nivelRSSI = ['\color{black}',char(9601)];
    if     min(objetivo.automatic.rssi{1}(:)) < objetivo.user.minUmbral, nivelRSSI = ['\color{black}',char(9601)];
    elseif min(objetivo.automatic.rssi{1}(:)) < (objetivo.user.minUmbral+objetivo.user.maxUmbral)/2, nivelRSSI = ['\color{orange}',char(9603)];
    elseif min(objetivo.automatic.rssi{1}(:)) < objetivo.user.maxUmbral, nivelRSSI = ['\color{orange}',char(9605)];
    elseif min(objetivo.automatic.rssi{1}(:)) >= objetivo.user.maxUmbral, nivelRSSI = ['\color[rgb]{0 .5 .5}',char(9608)];
    end
    % prompt = {['{\color{red}\fontsize{16}',char(9650),char(9709),char(11044),'\fontsize{9}',nivelRSSI,'} ',num2str(ID)]
    %           target.user.idFull};
    if isempty(objetivo.user.idFull)
     prompt = {['{\color[rgb]{',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),'}\fontsize{16}',char(9650),'\color{black}\fontsize{9}',nivelRSSI,'} ',num2str(ID)]};
    else
     prompt = {['{\color[rgb]{',num2str(color(1)),',',num2str(color(2)),',',num2str(color(3)),'}\fontsize{16}',char(9650),'\color{black}\fontsize{9}',nivelRSSI,'} ',num2str(ID)]
               objetivo.user.idFull};
    end
    for j = 1:length(LoRa.keys)
     if objetivo.automatic.enableMap(j)
      key = char(LoRa.keys{j}(4));
      prompt{length(prompt)+1} = ['{\color{gray}',key,'=',char(sprintf("%.1f",target.automatic.valor(j))),char(LoRa.keys{j}(6)),'}'];
     end
    end
    text(objetivo.user.posicion(1),objetivo.user.posicion(2),prompt,...
         'Background','w',...
         'Color','k',...%'FontWeight','bold',...
         'HorizontalAlignment','center');
   else
    plot(objetivo.user.posicion(1),objetivo.user.posicion(2),'o',...
         'MarkerSize',10,...
         'MarkerEdgeColor','w',...
         'MarkerFaceColor',color);
   end
  end
 end
 graficos = graficos-1;
end
end