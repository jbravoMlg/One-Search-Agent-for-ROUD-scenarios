function [ x,y,z ] = XYZread( filename,varargin )
% Simply imports the x,y,z columns of a .xyz file.
%% Syntax
% 
% [x,y,z] = xyzread(filename)
% [x,y,z] = xyzread(filename,Name,Value) 
% 
%% Description
% 
% [x,y,z] = xyzread(filename) imports the columns of a plain .xyz file. 
% 
% [x,y,z] = xyzread(filename,Name,Value) accepts any textscan arguments 
% such as 'headerlines' etc. 
% 
%% Author Info 
% This script was written by Chad A. Greene of the University of Texas 
% at Austin's Institute for Geophysics (UTIG), April 2016. 
% http://www.chadagreene.com 
% 
% See also xyz2grid and textscan. 
%% Error checks: 
narginchk(1,inf) 
nargoutchk(3,3)
assert(isnumeric(filename)==0,'Input error: filename must be a string.') 
assert(exist(filename,'file')==2,['Cannot find file ',filename,'.'])
%% Open file: 
fid = fopen(filename); 
T = textscan(fid,'%f %f %f',varargin{:}); 
fclose(fid);
%% Get scattered data: 
x = T{1}; 
y = T{2}; 
z = T{3}; 
end