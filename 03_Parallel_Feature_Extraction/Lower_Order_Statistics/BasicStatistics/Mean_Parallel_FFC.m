function Means = Mean_Parallel_FFC(fragments)

% This function returns mean of the elements of the input fragments.
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>, Narges
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
%   fragment: Cell array with length M consisting of row vectors of byte values
%
% Outputs:
%   Means: A Mx3 matrix that each row of it contains:
%       Arithmetic mean value of the input fragment
%       Geometric mean value of the input fragment
%       Harmonic mean value of the input fragment
%
% Revisions:
% 2023-Dec-24   function was created
M = length(fragments);
Means = zeros(M,3);
parfor j=1:M
    
    fragment = fragments{j};
    
    Arithmetic_Mean = mean(fragment);
    Geometric_Mean = geomean(fragment);
    Harmonic_Mean = harmmean(fragment);
    Means(j,:) = [Arithmetic_Mean,Geometric_Mean,Harmonic_Mean];
    
end
