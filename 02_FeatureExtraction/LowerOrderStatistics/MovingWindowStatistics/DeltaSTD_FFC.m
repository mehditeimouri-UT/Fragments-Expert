function [Features] = DeltaSTD_FFC(fragment,windowSize)

% This function calculates the delta standard deviation by taking the 
% average of the absolute values of the difference between the standard
% deviation of non-overlapping consecutive windows. The delta2 standard deviation is 
% computed by repeating the process on the previous obtained stream.
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
%   Features = [DeltaSTD Delta2STD]
%       DeltaSTD: The delta standard deviation by taking the average of the absolute values of the
%           difference between the standard deviation of consecutive windows.
%       Delta2STD: The average of the differences between consecutive delta standard deviations.
%
% Revisions:
% 2020-Mar-01   function was created

matrix = vec2mat(fragment,windowSize);
if mod(length(fragment),windowSize) ~= 0
    matrix(end,:)=[];
end
STDs =  std(matrix,1,2);
diffs = abs(diff(STDs));
DeltaSTD = mean(diffs);
Delta2STD = mean(abs(diff(diffs)));


% Return -1 if DeltaSTD cannot be calculated
if isnan(DeltaSTD)
    DeltaSTD = -1;
end

% Return -1 if Delta2STD cannot be calculated
if isnan(Delta2STD)
    Delta2STD = -1;
end

Features = [DeltaSTD Delta2STD];
