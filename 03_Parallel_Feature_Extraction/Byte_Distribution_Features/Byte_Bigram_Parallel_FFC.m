function freqs = Byte_Bigram_Parallel_FFC(fragments)

% This function calculates the distribution of the bigram byte frequencies. D
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%
% Outputs:
%   freq: Matrix with row size 65536 that contains the normalized bigrams
%
% Revisions:
% 2023-Dec-24   function was created


M = length(fragments);
freqs = zeros(M,2^16);
parfor j=1:M
    
    y = filter([1 256],1,fragments{j});
    y = y(2:end);
    freq = histcounts(y,(0:2^16));
    freq = freq/length(y)*2^16;
    freqs(j,:) = freq;
    
end