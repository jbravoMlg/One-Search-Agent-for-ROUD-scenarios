function [celda] = Punto2Celda(entorno,punto)
%% Determine the grid cell corresponding to an environment position.
x = punto(1); y = punto(2);
celda(1) = round((x-entorno.minX)/entorno.deltaXY)+1;
celda(2) = round((y-entorno.minY)/entorno.deltaXY)+1;
end