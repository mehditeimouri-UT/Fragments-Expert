function patterns = AudioPatterns_Parallel_FFC(fragments)

% This function counts the number of specific audio patterns in a series of audio file fragments. 
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
%   patterns: [mp3_sync flac_sync] with size 2xM
%       MP3_Sync [1]: bit pattern 1111 1111 1111 
%       FLAC_Sync [1]: bit pattern 1111 1111 1111 10 
%
% Refs:
%   [1] X. Jin and J. Kim, "Audio Fragment Identification System," 
%       International Journal of Multimedia and Ubiquitous Engineering, vol. 9, pp. 307-320, 2014.
%
% Revisions:
% 2023-Dec-24   function was created

%% Initialization
persistent pattern_12_1 pattern_14_1
if isempty(pattern_14_1)
    pattern_12_1 = [1 1 1 1 1 1 1 1 1 1 1 1];
    pattern_14_1 = [1 1 1 1 1 1 1 1 1 1 1 1 1 0];
end

M = length(fragments);
patterns = zeros(M,2);
parfor i=1:M
    
    %% Convert Bytes to Bits
    Bitstream = Byte2Bit_FFC(fragments{i});
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
    patterns(i,:) = [F1 F2];
    
end