function ROS = GPXGenerar()
%% Genera el file GPX correspondiente a las paths de la operacin de rescate para cada agent.
global data
entorno = data.entorno;
optima = data.planner.optima;
agents = []; i = 1; j = 1; ROS = {};
while isfield(data,'agentes') && j <= length(data.agentes) % && i <= length(unique(data.planner.optima.sA))
 while j <= length(data.agentes) && ~data.agentes(j).config.enable
  j = j+1;
 end
 if j <= length(data.agentes)
  agents(i).idFull = char(data.agentes(j).config.idFull);
  agents(i).enableGPX = data.agentes(j).config.enableGPX;
  agents(i).GPXfolder = char(data.agentes(j).config.GPXfolder);
  agents(i).enableROS = data.agentes(j).config.enableROSPub1;
  agents(i).numAgente = j;
  j = j+1; i = i+1;
 end
end
labels = {}; i = 1; j = 1;
while isfield(data,'sensorNodes') && i <= length(data.planner.optima.sV) && j <= length(data.sensorNodes)
 while j <= length(data.sensorNodes) && ~data.sensorNodes(j).user.enable
  j = j+1;
 end
 if j <= length(data.sensorNodes), labels{i} = char(data.sensorNodes(j).user.idFull); j = j+1; i = i+1; end
end
j = 1;
while isfield(data,'points') && i <= length(data.planner.optima.sV) && j <= length(data.points)
 while j <= length(data.points) && ~data.points(j).enable
  j = j+1;
 end
 if j <= length(data.points), labels{i} = data.points(j).idFull; j = j+1; i = i+1; end
end
fecha = datestr(datetime('now')); fecha = replace(fecha,{':','-'},''); fecha = replace(fecha,' ','-');
Aid = 0; fileID = [];
for n = 1:numel(optima.R)
 Aid = optima.sA(n);
 if agents(Aid).enableROS
  ROS{n}.numAgente = agents(Aid).numAgente;
 end
 if Aid ~= optima.sA(n) || n == 1
  if fileID
   fprintf(fileID,'</trkseg>\n');
   fprintf(fileID,'</trk>\n');
   fprintf(fileID,'</gpx>\n');
   fclose(fileID); fileID = [];
  end
  if agents(Aid).enableGPX
   folder = agents(Aid).GPXfolder;
   fileID = fopen(strcat(folder,'\',[fecha,'_',agents(Aid).idFull,'.gpx']),'a');
   fprintf(fileID,'<?xml version="1.0" encoding="UTF-8" standalone="no" ?>\r\n');
   fprintf(fileID,'<gpx ');
   fprintf(fileID,'version="1.1" ');
   fprintf(fileID,'creator="SAR-FIS">\r\n');
   % fprintf(fileID,' <metadata>\n');
   % fprintf(fileID,'  <name></name>\n');
   % fprintf(fileID,'  <desc></desc>\n');
   % fprintf(fileID,'  <author>\n');
   % fprintf(fileID,'   <name></name>\n');
   % fprintf(fileID,'   <email></email>\n');
   % fprintf(fileID,'   <link></link>\n');
   % fprintf(fileID,'  </author>\n');
   % fprintf(fileID,'  <copyright></copyright>\n');
   % fprintf(fileID,'  <link></link>\n');
   % fprintf(fileID,' </metadata>\n');
   fprintf(fileID,'  <trk>\r\n');
   fprintf(fileID,'    <name>%s</name>\r\n',[fecha,'_',agents(Aid).idFull]);
   % fprintf(fileID,' <cmt></cmt>\n');
   % fprintf(fileID,' <desc></desc>\n');
   % fprintf(fileID,' <src></src>\n');
   % fprintf(fileID,' <link></link>\n');
   % fprintf(fileID,' <number></number>\n');
   % fprintf(fileID,' <type></type>\n');
   fprintf(fileID,'    <trkseg>\r\n');
  end
 end
 if agents(Aid).enableGPX || agents(Aid).enableROS
  for i = 1:size(optima.R{n},2)
   posGPS = GPSutm2ll(optima.R{n}(1,i),optima.R{n}(2,i),30);
   if agents(Aid).enableGPX
    fprintf(fileID,'      <trkpt lat="%.12f" lon="%.12f">\r\n',posGPS(1),posGPS(2));
    celda = Punto2Celda(entorno,optima.R{n}(:,i));
    %- changed for compatibility with tracking algorithm by MSM (UMA)
    %- Optional elevation export can be added here.
    fprintf(fileID,'        <ele>%.2f</ele>\r\n',0);
    if i == size(optima.R{n},2)
     %j = 0; while j < optima.sV(n), if , j = j+1; end, end
     target = labels{n};
     %- changed for compatibility with tracking algorithm by MSM (UMA)
     %- fprintf(fileID,'    <name>%s</name>\r\n',target);
    end
    % fprintf(fileID,'    <time>22-11-17T12:00:00,000Z</time>\r\n');
    %- change for compatibility with tracking algorithm by MSM (UMA)
    %- fprintf(fileID,'  <extensions><speed>%.2f</speed></extensions>\r\n',optima.R{n}(4,i));
    % fprintf(fileID,'  <extensions><smjr>1</smjr></extensions>\r\n');
    fprintf(fileID,'      </trkpt>\r\n');
    if n == numel(optima.R) && i == size(optima.R{n},2)
     fprintf(fileID,'    </trkseg>\r\n');
     fprintf(fileID,'  </trk>\r\n');
     fprintf(fileID,'</gpx>\r\n');
    end
   end
   if agents(Aid).enableROS
    ROS{n}.points(i,:) = posGPS;
   end
  end
 end
end
if fileID, fclose(fileID); end
end
