function [Features] = MovingAverage_FFC(fragment,windowSize)

% This function calculates the moving average by taking the average of the mean of byte values in non-overlapping consecutive windows.
% By differentiating mean of byte values in non-overlapping consecutive windows and then averaging over the absolute of these values 
% the delta moving average is computed.
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
%   Features = [DeltaMovingAverage Delta2DeltaMovingAverage]
%       DeltaMovingAverage: The average of the absolute values of the
%           difference between the average of consecutive windows.
%       Delta2DeltaMovingAverage: The average of the differences between consecutive
%           moving averages.
%
% Revisions:
% 2020-Mar-01   function was created

matrix = vec2mat(fragment, windowSize);
if mod(length(fragment),windowSize) ~= 0
    matrix(end,:)=[];
end
avgs = mean(matrix,2);
diffs = abs(diff(avgs));
DeltaMovingAverage = mean(diffs);
Delta2DeltaMovingAverage = mean(abs(diff(diffs)));

% Return -1 if DeltaMovingAverage cannot be calculated
if isnan(DeltaMovingAverage)
    DeltaMovingAverage = -1;
end

% Return -1 if Delta2DeltaMovingAverage cannot be calculated
if isnan(Delta2DeltaMovingAverage)
    Delta2DeltaMovingAverage = -1;
end
Features = [DeltaMovingAverage Delta2DeltaMovingAverage];
