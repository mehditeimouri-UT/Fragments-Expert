function freq = Byte_Bigram_FFC(fragment)

% This function calculates the distribution of the bigram byte frequencies. D
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%
% Outputs:
%   freq: Row vector with length 65536 that contains the normalized bigrams
%
% Revisions:
% 2020-Oct-31   function was created

y = filter([1 256],1,fragment); 
y = y(2:end);
freq = histcounts(y,(0:2^16));
freq = freq/length(y)*2^16;