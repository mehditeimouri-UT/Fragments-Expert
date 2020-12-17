function RoC = RoC_FFC(fragment)

% This function employs the ByteRoCHistogram_FFC to calculate the rate of change in byte values. 
% It also returns the mean of the RoC values.
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
% Fragments-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program. 
% If not, see <http://www.gnu.org/licenses/>.
%
% Inputs:
%   fragment: row vector of byte values
%
% Outputs:
%   RoC: the normalized values of Rate of Change and the mean
%       of the RoC values (i.e. a vector with length 257)
%
% Revisions:
% 2020-Mar-01   function was created

RoC = ByteRoCHistogram_FFC(fragment);
RoC = RoC./[1/256 (256-(1:255))/(256*128)];
RoC = [RoC mean(RoC)];
