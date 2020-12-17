function ScaledConfusionMatrix = Scale_ConfusionMatrix_FFC(ConfusionMatrix)

% This function takes a confusion matrix and scales the row in order to
% obtain percent values. After scaling the sum of the values in each row is
% equal to 100. 
%
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
% Inputs:
%   ConfusionMatrix: M0xM input confusion matrix
%
% Outputs:
%   ScaledConfusionMatrix: M0xM input confusion matrix
%
% Revisions:
% 2020-Mar-03   function was created

%% Scale Confusion Matrix
M0 = size(ConfusionMatrix,1);
ScaledConfusionMatrix = ConfusionMatrix;
for i=1:M0
    S = sum(ScaledConfusionMatrix(i,:));
    if S==0
        continue;
    end
    ScaledConfusionMatrix(i,:) = ScaledConfusionMatrix(i,:)/S*100;
end