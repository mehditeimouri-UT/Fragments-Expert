function F = lyap_exp_k_Parallel_FFC(fragments,mindim,maxdim)

% This program calls lyap_exp_k_FFC.mexw64 to estimates the Lyapunov exponents of a given time series using the algorithm of Kantz [1].
%
% [1] H. Kantz, A robust method to estimate the maximal Lyapunov exponent of a time series, Phys. Lett. A 185, 77 (1994).
%
% Copyright (C) 1999 Rainer Hegger <hegger@theochem.uni-frankfurt.de>
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
%   mindim: Minimum embedding dimension of the vectors
%   maxdim: Maximum embedding dimension of the vectors
% Outputs:
%   Outputs: Mx(maxdim-mindim+1) matrix that each row is a vector with length maxdim-mindim+1 containing Lyapunov exponents
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
F = zeros(M,maxdim-mindim+1);
parfor j=1:M
    fragment = fragments{j};
    F(j,:) = sort(lyap_exp_k_FFC(fragment,mindim,maxdim),'descend')';    
end