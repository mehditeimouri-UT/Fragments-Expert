function F = FrequencyDomainStatistics_FFC(fragment,N)

% This function calculates mean, standard deviation, and skewness statistics in frequency domain.
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
%   N: Number of subbands
%
% Outputs:
%   F: [mu_1,mu_2,...,mu_N,sd_1,sd_2,...,sd_N,s_1,s_2,...,s_N]
%       mu_i: Mean in subband i, i=1,2,...,N
%       sd_i: Standard deviation in subband i, i=1,2,...,N
%       s_i: Skewness in subband i, i=1,2,...,N
%
% Revisions:
% 2020-May-14   function was created

%% Initialization and Preparing
L = length(fragment);
X = abs(fft(fragment))/sqrt(L);
M = max(ceil(L/N),1);
Y = vec2mat(X,M)';
if size(Y,2)<N
    Y = [Y zeros(size(Y,1),N-size(Y,2))];
end

%% Calculate Statistics
mu = mean(Y,1);
sd = std(Y,0,1);
s = skewness(Y,0,1);
s(isnan(s)) = 0;
F = [mu sd s];