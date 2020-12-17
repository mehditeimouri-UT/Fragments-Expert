function L = LCSSeq2_FFC(X,Y2)

% This function employs LCSSeq_FFC in order to calculates the average of longest 
% common subsequence (LCSSeq) between a vector and a set of vectors.
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
%   X: The first vector
%   Y: A cell array of vectors
%
% Output:
%   L: The average length of the longest common subsequence between X and the elements of Y 
%
% Revisions:
% 2020-Apr-28   function was created

%% Global Flag
global C_MEX_64_Available

%% Function Main Body
if C_MEX_64_Available
    N = length(Y2);
    L = 0;
    for j=1:N
        L = L+LCSSeq_FFC(X,Y2{j})/min(length(X),length(Y2{j}));
    end
    L = L/N;
else
    N = length(Y2);
    L = 0;
    for j=1:N
        L = L+LCSSeq_mFile_FFC(X,Y2{j})/min(length(X),length(Y2{j}));
    end
    L = L/N;
end