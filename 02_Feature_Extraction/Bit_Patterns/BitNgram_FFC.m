function Ngram = BitNgram_FFC(fragment,n)

% This function returns the n-gram frequencies of the bit sequences with 
% length n.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Fatemeh
% Delroba
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
%   n: length of the bit patterns
%
% Outputs:
%   Ngram: frequnecies of each bit sequence with length n
%       Note: Frequencies correspond to n-bit patterns 00..0,
%       00..01, 00..10, ..., 11..1, respectively.
%
% Revisions:
% 2020-Mar-01   function was created

Bitstream = Byte2Bit_FFC(fragment);
x = filter(fliplr(2.^(n-1:-1:0)),1,Bitstream); 
x(1:n-1) = [];
Ngram = histcounts(x,(0:2^n));
Ngram = Ngram/length(x);