function F = false_nearest_caller_FFC(series,minemb,maxemb,rt)

% This program calls false_nearest_FFC.mexw64 in order to look for the nearest neighbors of 
% all data points in m dimensions and iterates these neighbors one step (more precisely delay steps)
% into the future. If the ratio of the distance of the iteration and that of the nearest neighbor 
% exceeds a given threshold the point is marked as a wrong neighbor. The output is the fraction of 
% false neighbors for the specified embedding dimensions (see [1]).
% 
% [1] M. B. Kennel, R. Brown, and H. D. I. Abarbanel, Determining embedding dimension for phase-space
% reconstruction using a geometrical construction, Phys. Rev. A 45, 3403 (1992).
% 
% Copyright (C) 2005 Rainer Hegger <hegger@theochem.uni-frankfurt.de>
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
% 
% This file is a part of Fragments-Expert software, a software package for
% feature extraction from file fragments and classification among various file formats.
% 
% Fragments-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
% 
% Fragments-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License along with this program.
% If not, see <http://www.gnu.org/licenses/>.
% 
% Input:
%   series: A fragment of bytes
%   minemb: Minimum embedding dimension of the vectors
%   maxemb: Maximum embedding dimension of the vectors
%   rt: ratio factor
% 
% Outputs:
%   F: The result of calling false_nearest_FFC.mexw64 is matrix with
%       four columns as below. The sub-matrix consisting of the last three
%       columns is converted to a row vector by reading row by row. If the result
%       of calling false_nearest_FFC.mexw64 has less than maxemb-minemb+1 rows,
%       additional rows having values equal to -1 are included at the end.  
%           1st column: The dimension
%           2nd column: The fraction of false nearest neighbors
%           3rd column: The average size of the neighborhood
%           4th column: The square root of the average of the squared size of the neighborhood
% 
% Revisions:
% 2005-Dec-16   The first c version of the core function was written by Rainer Hegger.
% 2020-Mar-17   The core function in c-mex format was written by Mehdi Teimouri.

F = -ones(maxemb-minemb+1,4);
results = false_nearest_FFC(series,minemb,maxemb,rt);
L0 = size(results,1);
F(1:L0,:) = results(1:L0,:);
F = reshape(F(:,2:4)',1,[]);