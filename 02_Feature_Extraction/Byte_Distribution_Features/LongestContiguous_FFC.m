function Lmax = LongestContiguous_FFC(fragment)

% This function returns size of the longest contiguous streak of repeating
% bytes in input fragment
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Narges Sadeghi
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
%   Lmax: The size of the longest contiguous streak of repeating bytes in
%   fragment.
%
% Revisions:
% 2020-May-30   function was created
% 2023-Dec-25   function core was written in C-MEX

Lmax = LongestContiguous_Core_FFC(fragment);
% L = 1;
% Lmax = 1;
% val = fragment(1);
% for i=2:length(fragment)
%     newval = fragment(i);
%     if newval==val
%         L = L+1;
%     else
%         if L>Lmax
%             Lmax = L;
%         end
%         L = 1;
%     end
%     val = newval;
% end
% 
% if L>Lmax
%     Lmax = L;
% end