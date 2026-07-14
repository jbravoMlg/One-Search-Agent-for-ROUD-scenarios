function [ objetivo ] = ObjetivoInsertar( entorno,idFullObjetivo,visibleObjetivo,...
                                          modoPosicion,unidad,punto,minUmbral,maxUmbral,...
                                          aproximacion,orientacion,enableAproximacion,tiempoActividad,...
                                          modoCoeficiente,coefPositivo,coefNegativo,...
                                          prioridad,temperatureEvent,timeEvent,pattern,event,enablePlanning,enableFreeze)
%% Insert user-defined parameters for a point of interest in the environment.
global LoRa %Zigbee
 % Assign target specifications.
 objetivo.idFull            = idFullObjetivo;
 objetivo.visible           = visibleObjetivo;
 objetivo.modoPosicion      = modoPosicion;
 objetivo.unidadPosicion    = unidad;
 objetivo.posicion          = punto;
 objetivo.minUmbral         = minUmbral;
 objetivo.maxUmbral         = maxUmbral;
 objetivo.aproximacion      = aproximacion;
 objetivo.orientacion       = orientacion;
 objetivo.enableAprox       = enableAproximacion;
 objetivo.actividad         = tiempoActividad;
 objetivo.coeficiente       = modoCoeficiente;
 objetivo.coefPos           = coefPositivo;
 objetivo.coefNeg           = coefNegativo;
 if prioridad <= 0 || prioridad > 6,  objetivo.prioridad = 6; else, objetivo.prioridad = prioridad; end
 objetivo.temperatureEvent  = temperatureEvent;
 objetivo.timeEvent         = timeEvent;
 objetivo.pattern           = pattern;
 objetivo.event             = event;
 objetivo.enable            = enablePlanning;
 objetivo.enableFreeze      = enableFreeze;
%  %%
%  grid.xMin = Inf; grid.xMax = -Inf; grid.yMin = Inf; grid.yMax = -Inf;
%  grid.ocupacion = zeros(size(environment.elevacion));
%  % Triangular polygon with total size 1x1.
%  vertices = [-0.50 +0.00 +0.50 -0.50;
%              -0.50 +0.50 -0.50 -0.50]';
%  % Determine vertices for the polygon representing the victim.
%  vertices = (vertices*[environment.deltaXY*.9 0;0 environment.deltaXY*.9])';
%  victim.contornoVictima = vertices;
%  
%  % Square polygon with size 1x1.
%  vertices = [-0.50 -0.50 +0.50 +0.50 -0.50
%              -0.50 +0.50 +0.50 -0.50 -0.50]';
%  % Determine vertices for the uncertainty-boundary polygon.
%  victim.contornoIncertidumbre = (vertices*[0 0
%                                             0 0])';
%  % victim.contornoIncertidumbre = (vertices*[victim.dimension(1) 0
%  %                                            0 victim.dimension(2)])';
%  
%  %% Determine occupancy for the victim position-uncertainty area.
%  vertices = victim.contornoIncertidumbre;
%  vertices = vertices + repmat(target.posicion', 1, size(vertices, 2));
%  for i = 1:size(vertices,2)-1
%   p1 = vertices(:,i); p2 = vertices(:,i+1);
%   dx = p2(1)-p1(1); dy = p2(2)-p1(2); theta = atan2d(dy,dx);
%   dxy = PointInsercion(environment,p1)+...
%         [(sign(dx))*environment.deltaXY/2 (sign(dy))*environment.deltaXY/2];
%   dj = abs(Point2Celda(environment,p2)-Point2Celda(environment,p1));
%   GenerarRejillaOcupacion(environment,p1);
%   for j = 0:dj(1)-1
%    p = [dxy(1) p1(2)+sign(dy)*abs((dxy(1)-p1(1))*tand(theta))]+...
%        j*[sign(dx)*environment.deltaXY sign(dy)*environment.deltaXY*abs(tand(theta))];
%    GenerarRejillaOcupacion(environment,p);
%   end
%   for j = 0:dj(2)-1
%    p = [p1(1)+sign(dx)*abs((dxy(2)-p1(2))*cotd(theta)) dxy(2)]+...
%        j*[sign(dx)*environment.deltaXY*abs(cotd(theta)) sign(dy)*environment.deltaXY];
%    GenerarRejillaOcupacion(environment,p);
%   end
%   GenerarRejillaOcupacion(environment,p2);
%  end
%  
%  %% Update the matrix representing victim occupancy in the environment
%  for x = grid.xMin:grid.xMax-1
%   cambio = 0;
%   for y = grid.yMin:grid.yMax-1
%    if cambio == 1 && grid.ocupacion(x,y) == 0 && grid.ocupacion(x,y+1) == 1
%     cambio = 2; yyMax = y;
%    end
%    if cambio == 0 && grid.ocupacion(x,y) == 1 && grid.ocupacion(x,y+1) == 0
%     cambio = 1; yyMin = y;
%    end
%   end
%   if cambio == 2
%    for y = yyMin:yyMax
%     grid.ocupacion(x,y) = 1;
%    end
%   end
%  end
%  victim.grid = grid;

%  function [ ] = GenerarRejillaOcupacion( environment,point )
%  %% determine the grid cells corresponding to a point in the environment
%  coord = Point2Celda(environment, point);
%  % determine the minimum X/Y coordinates in the environment occupancy
%  if grid.xMin > coord(1)
%   grid.xMin = coord(1);
%  end
%  if grid.yMin > coord(2)
%   grid.yMin = coord(2);
%  end
%  grid.ocupacion(coord(1),coord(2)) = 1;
%  %% allow the same point to belong to 1, 2, or 4 cells
%  if point(1)/environment.deltaXY + 0.5 == coord(1)-1
%   if coord(1) > 1, coord(1) = coord(1)-1; end
%   grid.ocupacion(coord(1),coord(2)) = 1;
%  end
%  if point(2)/environment.deltaXY + 0.5 == coord(2)-1
%   if coord(2) > 1, coord(2) = coord(2)-1; end
%   grid.ocupacion(coord(1),coord(2)) = 1;
%  end
%  % determine the maximum X/Y coordinates in the environment occupancy
%  if grid.xMax < coord(1)
%   grid.xMax = coord(1);
%  end
%  if grid.yMax < coord(2)
%   grid.yMax = coord(2);
%  end
%  end

end