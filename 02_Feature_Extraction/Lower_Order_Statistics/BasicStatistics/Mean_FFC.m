function Means = Mean_FFC(fragment)

% This function returns mean of the elements of the input fragment.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>, Narges
% Sadeghi, and Zahra Seyed Ghorban
% 
% This file is a part of Fragments-Expert software, a software package for
% feature extraction from file fragments and classification among various file formats.
% 
% Fragments-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License 
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% Fragments-Expert software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <http://www.gnu.org/licenses/>.
%
% Inputs:
%   fragment: row vector of byte values
%
% Outputs:
%   Means: A 1x3 vector that contains:
%       Arithmetic mean value of the input fragment
%       Geometric mean value of the input fragment
%       Harmonic mean value of the input fragment
%
% Revisions:
% 2020-Mar-01   function was created

Arithmetic_Mean = mean(fragment);
Geometric_Mean = geomean(fragment);
Harmonic_Mean = harmmean(fragment);
Means = [Arithmetic_Mean,Geometric_Mean,Harmonic_Mean];
