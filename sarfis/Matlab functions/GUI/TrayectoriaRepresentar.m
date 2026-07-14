function [] = TrayectoriaRepresentar( handles,i,numTrayectorias,numFigure )
global data general
 if ( numFigure == 1 && ( ~isfield(general,'trajectory') || ( isfield(general,'trajectory') && ( i > numel(general.trajectory) && i <= numTrayectorias ) ) ) ) || ...
    ( numFigure == 2 && ( ~isfield(general,'trajectoryZoom') || ( isfield(general,'trajectoryZoom') && ( i > numel(general.trajectoryZoom) && i <= numTrayectorias ) ) ) )
  if numFigure ==1
   general.trajectory(i) = plot(data.planner.optima.R{i}(1,:),data.planner.optima.R{i}(2,:),'.',...
                                'Color',data.planner.ini.Ak(data.planner.optima.sA(i)).RGB,'Linewidth',1);
  else
   general.trajectoryZoom(i) = plot(data.planner.optima.R{i}(1,:),data.planner.optima.R{i}(2,:),'.',...
                                'Color',data.planner.ini.Ak(data.planner.optima.sA(i)).RGB,'Linewidth',1);
  end
 else
  if i <= numTrayectorias
   if numFigure ==1
    set(general.trajectory(i),'XData',data.planner.optima.R{i}(1,:),'YData',data.planner.optima.R{i}(2,:),'Visible','on',...
        'Color',data.planner.ini.Ak(data.planner.optima.sA(i)).RGB);
   else
    set(general.trajectoryZoom(i),'XData',data.planner.optima.R{i}(1,:),'YData',data.planner.optima.R{i}(2,:),'Visible','on',...
        'Color',data.planner.ini.Ak(data.planner.optima.sA(i)).RGB);
   end
  else
   if numFigure ==1, set(general.trajectory(end),'Visible','off'); end
   if numFigure ==2, set(general.trajectoryZoom(end),'Visible','off'); end
   if numFigure ==1, general.trajectory(end) = []; end
   if numFigure ==2, general.trajectoryZoom(end) = []; end
  end
 end
end