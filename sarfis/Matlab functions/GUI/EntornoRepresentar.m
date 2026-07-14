function [] = EntornoRepresentar( entorno,colorEntorno,numFigure )
global general
%% Render the environment.
 imgx = [entorno.minX, entorno.minX + entorno.deltaXY*(size(entorno.elevacion,1)-1)];
 imgy = [entorno.minY, entorno.minY + entorno.deltaXY*(size(entorno.elevacion,2)-1)];
 if ( numFigure == 1 && isfield(general,'monitor') ) || ( numFigure == 2 && isfield(general,'monitorZoom') )
  if entorno.tipo == 0 && ~entorno.foto_DEM
   if numFigure == 1, set(general.monitor,'CData',flipud(entorno.imagen),'AlphaData',0.85); end
   if numFigure == 2, set(general.monitorZoom,'CData',flipud(entorno.imagen),'AlphaData',0.85); end
   colorbar('off');
  else
   if numFigure == 1, set(general.monitor,'CData',entorno.elevacion','AlphaData',.75); end
   if numFigure == 2, set(general.monitorZoom,'CData',entorno.elevacion','AlphaData',.75); end
   colormap(flipud(colorEntorno));
   h = colorbar;
   xlabel('X axis (meters)'); ylabel('Y axis (meters)');
   h.Label.String = 'Elevation (meters)';
  end
 else
  ax = gca; cla
  ax.YDir = 'normal'; ax.FontSize = 10;  %9
  ax.XAxis.Exponent = 0; ax.XAxis.TickLabelFormat = '%.f';
  ax.YAxis.Exponent = 0; ax.YAxis.TickLabelFormat = '%.f';
  hold on; axis image;
  if entorno.tipo == 0 && ~entorno.foto_DEM
   % image('CData',flipud(environment.imagen),'XData',imgx,'YData',imgy);
   if numFigure == 1, general.monitor = imagesc(imgx, imgy, flipud(entorno.imagen),'AlphaData',0.85); end
   if numFigure == 2, general.monitorZoom = imagesc(imgx, imgy, flipud(entorno.imagen),'AlphaData',0.85); end
   colorbar('off');
   % title('Aerial image of natural environment');
   xlabel('UTM Coordinate: longitude (meters)'); ylabel('UTM Coordinate: latitude (meters)','Rotation',90);
  else
   % image('CData',environment.elevacion','XData',imgx,'YData',imgy);
   if numFigure == 1, general.monitor = imagesc(imgx, imgy, entorno.elevacion','AlphaData',0.75); end
   if numFigure == 2, general.monitorZoom = imagesc(imgx, imgy, entorno.elevacion','AlphaData',0.75); end
   colormap(flipud(colorEntorno));
   h = colorbar;
   % title('Elevation map of environment');
   xlabel('X axis (meters)'); ylabel('Y axis (meters)','Rotation',90);
   h.Label.String = 'Elevation (meters)';
  end
 end
end