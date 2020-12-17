function [Frgs,Packet_Pos] = TakeRandomFragments_FFC(fid,FileLength,PossiblePacketSizes,DisregardBOF,DisregardEOF,MaxFragment)

% This function takes some random fragments from a file. 
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
% Inputs
%   fid: File identifier
%   FileLength: Length of file in bytes
%   PossiblePacketSizes: 1xn vector that contains the possible values for  packet size
%   DisregardBOF: A number in interval (0,1) that specifies the percent of fragments from begining of file which should be discarded
%   DisregardEOF: A number in interval (0,1) that specifies the percent of fragments from end of file which should be discarded
%   MaxFragment: Maximum number of fragments taken from a file
%
% Outputs
%   Frgs: 1xMaxFragment cell, each element is a randomly taken fragment
%   Packet_Pos: 1xL vector that contains the start position of fragments in the file (L<=1xMaxFragment)
%
% Revisions:
% 2020-Feb-29   function was created

%% Generate random packet sizes
idx = randi([1 length(PossiblePacketSizes)],1,ceil(FileLength/min(PossiblePacketSizes)));
PacketSizes = PossiblePacketSizes(idx);

%% Discard all-empty packets
Packet_Pos = cumsum([0 PacketSizes]);
j0 = find(Packet_Pos>=FileLength,1,'first');
Packet_Pos = Packet_Pos(1:j0);

%% Disregard BOF and EOF
Disregard_Length_BOF = FileLength*DisregardBOF;
Disregard_Length_EOF = FileLength*DisregardEOF;
Packet_Pos = Packet_Pos(Packet_Pos>Disregard_Length_BOF & Packet_Pos<=(Packet_Pos(end)-Disregard_Length_EOF));

%% No fragments can be taken
Frgs = cell(1,MaxFragment);
NumCandidates = length(Packet_Pos)-1;
if NumCandidates<=0
    Packet_Pos = [];
    return;
end

%% Select randomly at most MaxFragment fragments
RndPacketIDX = randperm(NumCandidates);
RndPacketIDX = RndPacketIDX(1:min(length(RndPacketIDX),MaxFragment));

%% Take fragments
for j=1:length(RndPacketIDX)
    
    % Position of fragment in byte-stream
    pos = Packet_Pos(RndPacketIDX(j));
    L = Packet_Pos(RndPacketIDX(j)+1)-Packet_Pos(RndPacketIDX(j));    
    fseek(fid, pos, 'bof');
    
    % read fragment
    Frgs{j} = zeros(1,L);
    A = fread(fid,[1 L],'uint8=>double');
    Frgs{j}(1:length(A)) = A;
    
end
Packet_Pos = Packet_Pos(RndPacketIDX);
