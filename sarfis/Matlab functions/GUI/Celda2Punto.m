function [ punto ] = Celda2Punto( entorno,celda )
%% Determine the environment point corresponding to a grid cell.
x = celda(1); y = celda(2);
punto(1) = entorno.minX + (x-1)*entorno.deltaXY;
punto(2) = entorno.minY + (y-1)*entorno.deltaXY;
end