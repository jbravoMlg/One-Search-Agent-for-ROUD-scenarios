function [ tipoAgente ] = AgenteDefinir( dimX,dimY,distSeg,...
                                         COGx,COGy,COGz,rhoTol,...
                                         velocidad,coefVelocidadPositiva,coefVelocidadNegativa,coefVelocidadLateral)
%% Define las especificaciones de un tipo de agent.
tipoAgente.dimension             = [dimX dimY];
tipoAgente.distSeg               = distSeg;
tipoAgente.COG                   = [COGx,COGy,COGz];
tipoAgente.rhoTol                = rhoTol;
tipoAgente.velocidad             = velocidad;
tipoAgente.coefVelocidadPositiva = coefVelocidadPositiva;
tipoAgente.coefVelocidadNegativa = coefVelocidadNegativa;
tipoAgente.coefVelocidadLateral  = coefVelocidadLateral;
resolucion = 0.001;
%%%%if ~(exist('computeLUT_mex','file')==3)
%%%% disp('Compiling source file...');
%%%% codegen computeLUT -args {resolucion,[velocidad coefVelocidadNegativa coefVelocidadPositiva coefVelocidadLateral COGx COGy COGz dimX dimY rhoTol],false} -d works/mex/
%%%% movefile computeLUT_mex.* 'Matlab functions'/'DEMAIA planner' f
%%%%end
%%%%tipoAgent.vRef_LUT = computeLUT_mex(resolucion,[velocidad coefVelocidadNegativa coefVelocidadPositiva coefVelocidadLateral COGx COGy COGz dimX dimY rhoTol],false);
table = zeros(2,2); valor = zeros(1,2);
tipoAgente.vRef_LUT = struct('symmetric',zeros(1,1),'theta_threshold',valor,'phi_threshold',valor,'symmetric_threshold',valor,'resolution',zeros(1,1),'vMax',max(table(:)),'table',table);
% polgono con forma cuadrada y flecha, de tamao total 1x1 (orientacin de 90)
vertices = [-0.50 -0.50 -0.20 -0.20 -0.30 +0.00 +0.30 +0.20 +0.20 +0.50 +0.50 -0.50
            -0.50 +0.20 +0.20 +0.35 +0.35 +0.50 +0.35 +0.35 +0.20 +0.20 -0.50 -0.50]';
% determinacin de los vrtices del polgono representativo del agent (tras escalado)
tipoAgente.contorno = (vertices*[tipoAgente.dimension(1) 0
                       0 tipoAgente.dimension(2)])';
% polgono con forma cuadrada de tamao 1x1
vertices = [-0.50 -0.50 +0.50 +0.50 -0.50
            -0.50 +0.50 +0.50 -0.50 -0.50]';
% determinacin de los vrtices del polgono representativo del contorno de seguridad (tras escalado)
tipoAgente.contornoSeguridad = (vertices*[tipoAgente.dimension(1)+tipoAgente.distSeg 0
                                0 tipoAgente.dimension(2)+tipoAgente.distSeg])';
% tipoAgent.coefPotencialPositiva = coefPotencialPositiva;
% tipoAgent.coefPotencialNegativa = coefPotencialNegativa;
end