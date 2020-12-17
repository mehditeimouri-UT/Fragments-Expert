function DeviationFromSTD = DeviationFromSTD_FFC(fragment,windowSize)

% This function calculates the deviation from the standard deviation by first
% finding the average standard deviation for the entire fragment and then taking the
% absolute value of the difference between this average value and the standard deviation for
% non-overlapping consecutive windows.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
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
%   fragment: row vector of byte values
%   windowSize: scalar of window size
%
% Outputs:
%   DevivationFromSTD: deviation from the standard deviation
%
% Revisions:
% 2020-Mar-01   function was created

matrix = vec2mat(fragment,windowSize);
if mod(length(fragment),windowSize) ~= 0
    matrix(end,:) = [];
end
STDs =  std(matrix,1,2);
DeviationFromSTD = mean(abs(STDs - StandardDeviation_FFC(fragment)));

% Return -1 if DeviationFromSTD cannot be calculated
if isnan(DeviationFromSTD)
    DeviationFromSTD = -1;
end