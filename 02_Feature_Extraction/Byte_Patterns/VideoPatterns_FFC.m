function Features = VideoPatterns_FFC(fragment)

% This function calculate occurrances of video format patterns in a vector of byte values.
%   Note: The values of fragment are byte values in range [0,255] in double precision.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Narges
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
%   fragment: row vector of byte values
%
% Outputs:
%   Features:
%       First pattern of MKV (A3)
%       Second pattern of MKV (A0)
%       First pattern Of AVI ({'30','30','64','63'})
%       Second pattern of AVI {'30','31','77','62'};
%       First pattern of RMVB {'00','00'}
%       Second pattern of RMVB {'00','01'}
%       OGV pattern 'OggS'
%       MP4 patterns {10 patterns}
%
% Revisions:
% 2020-Mar-01   function was created

%% Error Checking
if size(fragment,1)>1
    error('Input signal should be a row vector.');
end

%% Patterns
% First pattern of MKV (A3)
pattern = 163;
MKV1 = Occurrences_FFC(fragment, pattern);

% Second pattern of MKV (A0)
pattern = 160;
MKV2 = Occurrences_FFC(fragment, pattern);

% First pattern Of AVI ({'30','30','64','63'})
pattern = [48 48 100 99];
AVI1 = Occurrences_FFC(fragment, pattern);

% Second pattern of AVI {'30','31','77','62'};
pattern = [48 49 119 98];
AVI2 = Occurrences_FFC(fragment, pattern);

% First pattern of RMVB {'00','00'}
pattern = [0 0];
RMVB1 = Occurrences_FFC(fragment, pattern);

% Second pattern of RMVB {'00','01'}
pattern = [0 1] ;
RMVB2 = Occurrences_FFC(fragment, pattern);

%OGV pattern 'OggS'
pattern = [79 103 103 83];
OGV = Occurrences_FFC(fragment, pattern);

%MP4 patterns
pattern = [65 154];
MP41 = Occurrences_FFC(fragment, pattern);
pattern = [1 158];
MP42 = Occurrences_FFC(fragment, pattern);
pattern = [1 159];
MP43 = Occurrences_FFC(fragment, pattern);
pattern = [65 155];
MP44 = Occurrences_FFC(fragment, pattern);
pattern = [103 66];
MP45 = Occurrences_FFC(fragment, pattern);
pattern = [65 158];
MP46 = Occurrences_FFC(fragment, pattern);
pattern = [65 159];
MP47 = Occurrences_FFC(fragment, pattern);
pattern = [101 136];
MP48 = Occurrences_FFC(fragment, pattern);
pattern = [104 206];
MP49 = Occurrences_FFC(fragment, pattern);
pattern = [101 136];
MP410 = Occurrences_FFC(fragment, pattern);

%% Output
Features = [MKV1, MKV2, AVI1, AVI2, RMVB1, RMVB2, OGV, MP41, MP42, MP43, ...
    MP44, MP45, MP46, MP47, MP48, MP49, MP410];
