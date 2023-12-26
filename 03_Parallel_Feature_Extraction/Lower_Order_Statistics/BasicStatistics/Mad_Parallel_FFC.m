function Mad = Mad_Parallel_FFC(fragments)

% This function returns median absolute deviation of input fragments
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Narges
% Sadeghi
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
%   vector: Cell array with length M consisting of row vectors of byte values
%
% Outputs:
%   Mad: Mx1 median absolute deviation value of the input fragments which
%       calculates as median(abs(vector - median(vector)))
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
Mad = zeros(M,1);
parfor j=1:M
    fragment = fragments{j};
    Mad(j) = mad(fragment, 1);
end