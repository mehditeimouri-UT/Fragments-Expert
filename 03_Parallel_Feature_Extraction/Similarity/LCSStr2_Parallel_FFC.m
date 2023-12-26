function L = LCSStr2_Parallel_FFC(X,Y)

% This function employs LCSStr_FFC in order to calculates the average of longest
% common substring (LCSStr) between a vector and a set of vectors.
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%   X: Cell array of vectors with length M
%   Y: Cell array of vectors with length N (Representators)
%
% Output:
%   L: The average length of the longest common substring between each X and all elements of Y
%
% Revisions:
% 2023-Dec-24   function was created

M = length(X);
N = length(Y);
L = zeros(M,N);
for j=1:N
    Rep = Y{j};
    parfor i=1:M
        L(i,j) = LCSStr_FFC(X{i},Rep)/min(length(X{i}),length(Rep));
    end
end
L = mean(L,2);
