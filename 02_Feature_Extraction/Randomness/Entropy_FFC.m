function Outputs = Entropy_FFC(fragment)

% This function returns the entropy value of a given fragment. It also
% calculates the difference between n-truncated entropy [1] of uniform distribution
% and the value of obrained entropy. 
%   [1] 
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
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
%   fragment: Row vector of byte values
%
% Outputs:
%   Outputs: 1x2 vector that contains
%       Entropy: The entropy value of the input fragment
%       dE: The difference between n-truncated entropy of uniform distribution
%           and the value of obtained entropy is added to outputs. 
%
% Revisions:
% 2020-Mar-01   function was created

%% Initialization
persistent c HNu

c0 = length(fragment)/256;
if ~isequal(c,c0)
    c = c0;
    j = (1:171); 
    HNu = log2(c)+log2(256)-exp(-c)*sum(c.^(j-1)./factorial(j-1).*log2(j));
end

%% Calculate Entropy and dE
probs = ByteHistogram_FFC(fragment);
probs(probs==0)=1;
Entropy = sum(-1*probs.*log2(probs));
dE = HNu-Entropy;
Outputs = [Entropy,dE];
