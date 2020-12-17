function BitStream = Byte2Bit_FFC(fragment)

% This function returns the bit stream representing the decimal byte values
% in the vector, each decimal value will be represented by 8 bits.
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
% Input:
%   fragment: Row vector of byte values
%
% Output: 
%   Bitstream: The bit stream 
%
% Revisions:
% 2020-Mar-01   function was created

BitStream = de2bi(fragment,8,'left-msb')';
BitStream = reshape(BitStream , 1 , []);
