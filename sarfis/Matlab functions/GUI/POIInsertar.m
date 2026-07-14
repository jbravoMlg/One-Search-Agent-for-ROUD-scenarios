function [ POI ] = POIInsertar( entorno,idFullPOI,visiblePOI,...
                                modoPosicion,unidad,punto,minUmbral,maxUmbral,...
                                aproximacion,orientacion,enableAproximacion,tiempoActividad,...
                                modoCoeficiente,coefPositivo,coefNegativo,coefLateral,...
                                prioridad,event,pattern,enablePlanning,...
                                ROS)
 %% Inserta los parmetros definidos por el usuario para un point de inters en el environment.
 % asignacin de especificaciones del point de inters
 POI.idFull            = idFullPOI;
 POI.visible           = visiblePOI;
 POI.modoPosicion      = modoPosicion;
 POI.unidadPosicion    = unidad;
 POI.posicion          = punto;
 POI.minUmbral         = minUmbral;
 POI.maxUmbral         = maxUmbral;
 POI.aproximacion      = aproximacion;
 POI.orientacion       = orientacion;
 POI.enableAprox       = enableAproximacion;
 POI.actividad         = tiempoActividad;
 POI.coeficiente       = modoCoeficiente;
 POI.coefPos           = coefPositivo;
 POI.coefNeg           = coefNegativo;
 POI.coefLat           = coefLateral;
 if prioridad <= 0 || prioridad > 6,  POI.prioridad = 6; else, POI.prioridad = prioridad; end
 POI.event             = event;
 POI.pattern           = pattern;
 POI.enable            = enablePlanning;
 POI.ROS               = ROS;
%  %%
%  grid.xMin = Inf; grid.xMax = -Inf; grid.yMin = Inf; grid.yMax = -Inf;
%  grid.ocupacion = zeros(size(environment.elevacion));
%  % polgono con forma triangular de tamao total 1x1
%  vertices = [-0.50 +0.00 +0.50 -0.50;
%              -0.50 +0.50 -0.50 -0.50]';
%  % determinacin de los vrtices del polgono representativo de la vctima
%  vertices = (vertices*[environment.deltaXY*.9 0;0 environment.deltaXY*.9])';
%  victim.contornoVictima = vertices;
%  
%  % polgono con forma cuadrada de tamao 1x1
%  vertices = [-0.50 -0.50 +0.50 +0.50 -0.50
%              -0.50 +0.50 +0.50 -0.50 -0.50]';
%  % determinacin de los vrtices del polgono representativo del contorno de incertidumbre
%  victim.contornoIncertidumbre = (vertices*[0 0
%                                             0 0])';
%  % victim.contornoIncertidumbre = (vertices*[victim.dimension(1) 0
%  %                                            0 victim.dimension(2)])';
%  
%  %% determinacin de la ocupacin del rea de incertidumbre de posicin de la vctima
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
%  %% Actualiza la matriz representativa de la ocupacin de la vctima en el environment
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
%  %% determinacin de las cells de grid correspondientes a un point en el environment
%  coord = Point2Celda(environment, point);
%  % determinacin de las coordinates X e Y mnimas en la ocupacin del environment
%  if grid.xMin > coord(1)
%   grid.xMin = coord(1);
%  end
%  if grid.yMin > coord(2)
%   grid.yMin = coord(2);
%  end
%  grid.ocupacion(coord(1),coord(2)) = 1;
%  %% modificacin para que un mismo point pueda pertenecer a 1, 2 o 4 cells
%  if point(1)/environment.deltaXY + 0.5 == coord(1)-1
%   if coord(1) > 1, coord(1) = coord(1)-1; end
%   grid.ocupacion(coord(1),coord(2)) = 1;
%  end
%  if point(2)/environment.deltaXY + 0.5 == coord(2)-1
%   if coord(2) > 1, coord(2) = coord(2)-1; end
%   grid.ocupacion(coord(1),coord(2)) = 1;
%  end
%  % determinacin de las coordinates X e Y mximas en la ocupacin del environment
%  if grid.xMax < coord(1)
%   grid.xMax = coord(1);
%  end
%  if grid.yMax < coord(2)
%   grid.yMax = coord(2);
%  end
%  end

end