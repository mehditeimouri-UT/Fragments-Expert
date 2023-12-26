function F = kolmogorov_Parallel_FFC(fragments)

% This program calls kolmogorov_FFC.mexw64 for feature extraction using the method proposed in [1].
%   [1] Kaspar, F., and H. G. Schuster. "Easily calculable measure for the complexity of spatiotemporal patterns."
%       Physical Review A 36.2 (1987): 842.
%
% Copyright (C) 2005 Stephen Faul <stephenf@rennes.ucc.ie>
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
% Inputs:
%   fragments: Cell array with length M consisting of row vectors of byte values
%
% Outputs:
%   Outputs: Mx1 vector
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
F = zeros(M,1);
parfor j=1:M
    fragment = fragments{j};
    F(j) = kolmogorov_FFC(fragment);
end