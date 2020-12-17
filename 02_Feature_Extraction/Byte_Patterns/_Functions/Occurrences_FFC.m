function occurrences = Occurrences_FFC( fragment, pattern )

% This function calculates repeatation of a byte pattern in the fragment
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
%   pattern: vector of byte values
%
% Outputs:
%   occurrences: occurrences of pattern in fragment
%
% Revisions:
% 2020-Mar-01   function was created

occurrences = strfind(fragment, pattern);
occurrs = length(occurrences);
occurrences = (occurrs/(length(fragment)-length(pattern)+1)) * (2^(length(pattern)*8));
