function start_sarfis
%START_SARFIS Configure paths and launch the SARFIS MATLAB GUI.

sarfisRoot = fileparts(mfilename('fullpath'));
matlabRoot = fullfile(sarfisRoot, 'Matlab functions');

addpath( ...
    fullfile(matlabRoot, 'GUI'), ...
    fullfile(matlabRoot, 'DEM'), ...
    fullfile(matlabRoot, 'GPX'), ...
    '-end');

sessionDir = fullfile(sarfisRoot, 'MAT files');
if ~isfolder(sessionDir)
    mkdir(sessionDir);
end

defaultDem = fullfile(sarfisRoot, 'DEM files', 'UMA_SEG_24_dsm_200cm');
if ~isfile([defaultDem, '.mat']) && ~isfile([defaultDem, '.xyz'])
    error('SARFIS:MissingDEM', [ ...
        'The default SARFIS DEM is not distributed with this repository. ', ...
        'See "sarfis/DEM files/README.md" to request the experiment DEM files.']);
end

previousDirectory = pwd;
restoreDirectory = onCleanup(@() cd(previousDirectory)); %#ok<NASGU>
cd(sarfisRoot);
GUI;
end
