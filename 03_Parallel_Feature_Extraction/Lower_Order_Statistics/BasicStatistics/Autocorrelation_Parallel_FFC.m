function AutoCorrs = Autocorrelation_Parallel_FFC(fragments,lag)

% This function returns the autocorrelation sequence of the input
% fragments up to a specific lag value.
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
% Examples;
%   lag = 2;
%   AutoCorr = Autocorrelation_FFC(fragment,lag)
%
% Inputs:
%   fragmentss: Cell array with length M consisting of row vectors of byte values
%   lag: lag value
%
% Outputs:
%   AutoCorrs: Each row is the autocorrelation sequence of fragments with length lag
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
AutoCorrs = zeros(M,lag);
parfor j=1:M
    
    AutoCorr = autocorr(fragments{j},lag);
    AutoCorr = AutoCorr(2:end);
    AutoCorr(isnan(AutoCorr)) = 1; % NaN is obtained when the variance is equal to zero
    AutoCorrs(j,:) = AutoCorr;
    
end