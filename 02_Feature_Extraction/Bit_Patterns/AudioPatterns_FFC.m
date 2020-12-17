function patterns = AudioPatterns_FFC(fragment)

% This function counts the number of specific audio patterns in an audio file fragment. 
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
%   fragment: Row vector of byte values
%
% Outputs:
%   patterns: [mp3_sync flac_sync]
%       MP3_Sync [1]: bit pattern 1111 1111 1111 
%       FLAC_Sync [1]: bit pattern 1111 1111 1111 10 
%
% Refs:
%   [1] X. Jin and J. Kim, "Audio Fragment Identification System," 
%       International Journal of Multimedia and Ubiquitous Engineering, vol. 9, pp. 307-320, 2014.
%
% Revisions:
% 2020-May-31   function was created

%% Initialization
persistent pattern_12_1 pattern_14_1
if isempty(pattern_14_1)
    pattern_12_1 = [1 1 1 1 1 1 1 1 1 1 1 1];
    pattern_14_1 = [1 1 1 1 1 1 1 1 1 1 1 1 1 0];
end

%% Convert Bytes to Bits
Bitstream = Byte2Bit_FFC(fragment);
N = length(Bitstream);

%% Patterns with length 12
n = 12; 
x = filter(fliplr(2.^(n-1:-1:0)),1,Bitstream); 
x(1:n-1) = [];

% MP3_Sync
F1 = sum(x==bi2de(pattern_12_1,'left-msb'));
F1 = F1/(N-n+1)*(2^n);

%% Patterns with length 14
n = 14; 
x = filter(fliplr(2.^(n-1:-1:0)),1,Bitstream); 
x(1:n-1) = [];

% FLAC_Sync
F2 = sum(x==bi2de(pattern_14_1,'left-msb'));
F2 = F2/(N-n+1)*(2^n);

%% Output
patterns = [F1 F2];