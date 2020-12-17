function Mad = Mad_FFC(fragment)

% This function returns median absolute deviation of input vector
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
%   vector: row vector of byte values
%
% Outputs:
%   Mad: median absolute deviation value of the input fragment which 
%       calculates as median(abs(vector - median(vector)))
%
% Revisions:
% 2020-Mar-01   function was created

Mad = mad(fragment, 1);