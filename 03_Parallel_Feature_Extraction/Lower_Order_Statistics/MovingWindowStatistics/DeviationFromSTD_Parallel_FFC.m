function DeviationFromSTD = DeviationFromSTD_Parallel_FFC(fragments,windowSize)

% This function calculates the deviation from the standard deviation by first
% finding the average standard deviation for the entire fragment and then taking the
% absolute value of the difference between this average value and the standard deviation for
% non-overlapping consecutive windows.
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
% Seyedghorban
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
%   fragments: Cell array with length M consisting of row vectors of byte values
%   windowSize: scalar of window size
%
% Outputs:
%   DevivationFromSTD: Mx1 vector of deviations from the standard deviation
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
DeviationFromSTD = zeros(M,1);
parfor j=1:M
    
    fragment = fragments{j};
    matrix = vec2mat(fragment,windowSize);
    if mod(length(fragment),windowSize) ~= 0
        matrix(end,:) = [];
    end
    STDs =  std(matrix,1,2);
    DeviationFromSTD(j) = mean(abs(STDs - StandardDeviation_FFC(fragment)));
    
    % Return -1 if DeviationFromSTD cannot be calculated
    if isnan(DeviationFromSTD(j))
        DeviationFromSTD(j) = -1;
    end
    
end