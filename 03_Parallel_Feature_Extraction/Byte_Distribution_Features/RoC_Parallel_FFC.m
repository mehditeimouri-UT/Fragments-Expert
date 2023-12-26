function RoC = RoC_Parallel_FFC(fragments)

% This function employs the ByteRoCHistogram_FFC to calculate the rate of change in byte values. 
% It also returns the mean of the RoC values.
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
%   RoC: the normalized values of Rate of Change and the mean
%       of the RoC values (i.e. a a matrix with row size 257)
%
% Revisions:
% 2023-Dec-24   function was created

M = length(fragments);
RoC = ByteRoCHistogram_Parallel_FFC(fragments);
RoC = RoC./repmat([1/256 (256-(1:255))/(256*128)],M,1);
RoC = [RoC mean(RoC,2)];
