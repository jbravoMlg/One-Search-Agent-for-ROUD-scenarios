function [ entorno ] = EntornoDefinir(tipo, fichero)
%% Define the environment.
% Determine environment characteristics.
% Define the environment using an elevation map.
%  NaN value means outside the environment
%  Values may be integer or real, positive or negative.
%global timerUpdate general
%stop(timerUpdate);
%general.updated = false;
%if isfield(general,'monitor'), general = rmfield(general,'monitor'); end
%if isfield(general,'monitorZoom'), general = rmfield(general,'monitorZoom'); end
%if isfield(general,'trajectory'), general = rmfield(general,'trajectory'); end
%if isfield(general,'trajectoryZoom'), general = rmfield(general,'trajectoryZoom'); end
%if isfield(general,'agent'), general = rmfield(general,'agent'); end
%if isfield(general,'agentZoom'), general = rmfield(general,'agentZoom'); end
%if isfield(general,'POI'), general = rmfield(general,'POI'); end
%if isfield(general,'POIZoom'), general = rmfield(general,'POIZoom'); end
if tipo == 0
 if (exist(strcat(fichero,'.mat'),'file') == 2), load(strcat(fichero,'.mat'));
 else
    % Read an XYZ file produced by UAV image processing.
  [X,Y,Z] = XYZread(strcat(fichero,'.xyz'));
  % extract RGB values included in the Pix4Dmapper XYZ file
  ImR = X(2:2:end,:); ImG = Y(2:2:end,:); ImB = Z(2:2:end,:);
  % extract XYZ values from the Pix4Dmapper XYZ file
  X = X(1:2:end,:); Y = Y(1:2:end,:); Z = Z(1:2:end,:);
  rejilla = flip(XYZ2grid(X,Y,Z))';
    % Build the RGB image and elevation map from the Pix4Dmapper XYZ file.
  imagen(:,:,1) = XYZ2grid(X,Y,ImR);
  imagen(:,:,2) = XYZ2grid(X,Y,ImG);
  imagen(:,:,3) = XYZ2grid(X,Y,ImB);
  imagen(isnan(imagen)) = 0;
  imagen = uint8(imagen);
  minX = min(X); maxX = max(X); minY = min(Y);
  save(strcat(fichero,'.mat'),'minX','maxX','minY','rejilla','imagen');
 end
else
 if (exist(strcat(fichero,'.mat'),'file') == 2), load(strcat(fichero,'.mat'));
 else
  % read XYZ file
  [X,Y,Z] = XYZread(strcat(fichero,'.xyz'));
  rejilla = flip(XYZ2grid(X,Y,Z))';
  minX = min(X); maxX = max(X); minY = min(Y);
  save(strcat(fichero,'.mat'),'minX','maxX','minY','rejilla');
 end
end

%% Assign the elevation grid to the environment.
entorno.minX = minX; entorno.minY = minY;
entorno.dimX = size(rejilla,1); entorno.dimY = size(rejilla,2);
entorno.deltaXY = (maxX-minX)/(entorno.dimX-1);
entorno.elevacion = rejilla;

%% Compute the maximum and minimum elevation-map values.
entorno.vMin = min(min(entorno.elevacion));
entorno.elevacion(isnan(entorno.elevacion)) = Inf;
entorno.vMax = max(entorno.elevacion(isfinite(entorno.elevacion)));

%% determine whether the environment is an example model or a UAV image
entorno.tipo = tipo;
if entorno.tipo == 0
 entorno.imagen = imagen;
 entorno.foto_DEM = 0;
else
 fichero = split(fichero,'\');
 entorno.fichero = fichero{end};
end
%start(timerUpdate);
end