function AutoCorr = Autocorrelation_FFC(fragment,lag)

% This function returns the autocorrelation sequence of the input 
% fragment up to a specific lag value.
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
% Examples;
%   lag = 2;
%   AutoCorr = Autocorrelation_FFC(fragment,lag)
%
% Inputs:
%   fragment: row vector of byte values
%   lag: lag value
%
% Outputs:
%   AutoCorr: the autocorrelation sequence of fragment with length lag
%
% Revisions:
% 2020-Mar-01   function was created

AutoCorr = autocorr(fragment,lag);
AutoCorr = AutoCorr(2:end);
AutoCorr(isnan(AutoCorr)) = 1; % NaN is obtained when the variance is equal to zero
