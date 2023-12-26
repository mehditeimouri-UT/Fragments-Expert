function Outputs = Entropy_Parallel_FFC(fragments)

% This function returns the entropy value of a given fragment. It also
% calculates the difference between n-truncated entropy of uniform distribution
% and the value of obrained entropy.
%
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
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
% Inputs:
%   fragments: Cell array with length M consisting of row vectors of byte values
%
% Outputs:
%   Outputs: Mx2 vector that contains
%       Entropy: The entropy value of the input fragment
%       dE: The difference between n-truncated entropy of uniform distribution
%           and the value of obtained entropy is added to outputs.
%
% Revisions:
% 2023-Dec-24   function was created

%% Initialization
persistent Ls HNu

all_Ls = cellfun(@length,fragments);
L_values = unique(all_Ls);

for i=1:length(L_values)
    
    L = L_values(i);
    aux = nnz((Ls==L));
    if (aux~=0)
        continue;
    end
    c = L/256;
    j = (1:171);
    HNu(end+1) = log2(c)+log2(256)-exp(-c)*sum(c.^(j-1)./factorial(j-1).*log2(j));
    Ls(end+1) = L;
end

[~,idx] = ismember(all_Ls,Ls);

%% Calculate Entropy and dE
probs = ByteHistogram_Parallel_FFC(fragments);
probs(probs==0)=1;
Entropy = sum(-1*probs.*log2(probs),2);
dE = reshape(HNu(idx),[],1)-Entropy;
Outputs = [Entropy,dE];