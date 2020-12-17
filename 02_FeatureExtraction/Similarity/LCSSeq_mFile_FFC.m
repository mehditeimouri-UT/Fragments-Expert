function L = LCSSeq_mFile_FFC(X,Y,m,n)

% This function calculates the longest common subsequence (LCSSeq) between two
% vectors using a dynamic programming approach.
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
%   Y: The second vector
%   m: The length of the first vector (optional)
%   n: The length of the second vector (optional)
%
% Output:
%   L: The length of the longest common subsequence between X and Y 
%
% Revisions:
% 2020-Apr-26   function was created

%% Initialization
if nargin<3
    m = length(X);
    n = length(Y);
end

Z = zeros(m+1,n+1);

%% Function Main Body
for i=1:m+1
    for j=1:n+1
        if (i==1 || j==1)
            Z(i,j) = 0;
            
        elseif (X(i-1)==Y(j-1))
            Z(i,j) = Z(i-1,j-1)+1;
            
        else
            Z(i,j) = max(Z(i-1,j),Z(i,j-1));
        end
    end
end
L = Z(m+1,n+1);