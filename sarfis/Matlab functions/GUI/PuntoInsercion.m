function [puntoCentrado] = PuntoInsercion(entorno, punto)
%% Compute the environment position corresponding to a cell geometric center.
x = punto(1); y = punto(2);
puntoCentrado = Celda2Punto(entorno,Punto2Celda(entorno,[x y]));
end