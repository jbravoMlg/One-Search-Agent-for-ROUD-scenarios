function [ agente ] = AgenteInsertar( tipoAgente,idAgente,idFullAgente,visible,...
                                      modoPosicion,punto,unidad,orientacion,radioGiro,...
                                      RGB,IPcamera,enableIPcamera,userIPcamera,pwdIPcamera,...
                                      topicCamera,typeCamera,enabledCamera,rosCamera,...
                                      ipMQTT,portMQTT,topicGPS,topicCommand,topicStatus,QoSMQTT,enableMQTT,...
                                      GPXfolder,enableGPX,...
                                      ROStopicSubs1,ROStypeSubs1,enableROSSubs1,nonROS2Subs1,...
                                      ROSnameSpace,ROStopicSubs3a,ROStopicSubs3b,ROStopicSubs3c,ROStypeSubs3,enableROSSubs3,nonROS2Subs3,calling_status,...
                                      ROSfreqSubs4,ROStopicSubs4,ROStypeSubs4,enableROSSubs4,nonROS2Subs4,...
                                      ROStopicSubs2,ROStypeSubs2,enableROSSubs2,nonROS2Subs2,...
                                      ROStopicPub1,ROStypePub1,enableROSPub1,nonROS2Pub1,granularity,ROS,...
                                      enablePlanning,enableFreeze,...
                                      sensorNodes)
%% Inserta un agent en el environment.
agente.tipoAgente               = tipoAgente;
agente.id                       = idAgente;
agente.idFull                   = idFullAgente;
agente.visible                  = visible;
agente.modoPosicion             = modoPosicion;
agente.posicion                 = punto;
agente.unidadPosicion           = unidad;
agente.theta                    = orientacion;
agente.radioGiro                = radioGiro;
agente.color                    = RGB;
agente.IPcamera                 = IPcamera;
agente.enableIPcamera           = enableIPcamera;
agente.userIPcamera             = userIPcamera;
agente.pwdIPcamera              = pwdIPcamera;
agente.topicCamera              = topicCamera;
agente.typeCamera               = typeCamera;
agente.enabledCamera            = enabledCamera;
agente.rosCamera                = rosCamera;
agente.ipMQTT                   = ipMQTT;
agente.portMQTT                 = portMQTT;
agente.topicGPS                 = topicGPS;
agente.topicCommand             = topicCommand;
agente.topicStatus              = topicStatus;
agente.QoSMQTT                  = QoSMQTT;
agente.enableMQTT               = enableMQTT;
agente.GPXfolder                = GPXfolder;
agente.enableGPX                = enableGPX;
agente.ROStopicSubs1            = ROStopicSubs1;
agente.ROStypeSubs1             = ROStypeSubs1;
agente.enableROSSubs1           = enableROSSubs1;
agente.nonROS2Subs1             = nonROS2Subs1;
agente.ROSnameSpace             = ROSnameSpace;
agente.ROStopicSubs3a           = ROStopicSubs3a;
agente.ROStopicSubs3b           = ROStopicSubs3b;
agente.ROStopicSubs3c           = ROStopicSubs3c;
agente.calling_status           = calling_status;
agente.ROStypeSubs3             = ROStypeSubs3;
agente.enableROSSubs3           = enableROSSubs3;
agente.nonROS2Subs3             = nonROS2Subs3;
agente.ROSfreqSubs4             = ROSfreqSubs4;
agente.ROStopicSubs4            = ROStopicSubs4;
agente.ROStypeSubs4             = ROStypeSubs4;
agente.enableROSSubs4           = enableROSSubs4;
agente.nonROS2Subs4             = nonROS2Subs4;
agente.ROStopicSubs2            = ROStopicSubs2;
agente.ROStypeSubs2             = ROStypeSubs2;
agente.enableROSSubs2           = enableROSSubs2;
agente.nonROS2Subs2             = nonROS2Subs2;
agente.ROStopicPub1             = ROStopicPub1;
agente.ROStypePub1              = ROStypePub1;
agente.enableROSPub1            = enableROSPub1;
agente.nonROS2Pub1              = nonROS2Pub1;
agente.granularity              = granularity;
agente.ROS                      = ROS;
agente.enable                   = enablePlanning;
agente.enableFreeze             = enableFreeze;
agente.sensorNodes              = sensorNodes;
end