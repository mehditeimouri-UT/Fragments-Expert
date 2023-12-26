function ByteRoCHistogramMatrix = ByteRoCHistogram_Parallel_FFC(fragments)

% This function returns a matrix, each row of it containing the frequencies of the absolute 
% values of the differences between consecutive byte values in corresponding data fragment.
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
%   fragment: Cell array with length M consisting of row vectors of byte values
%
% Outputs:
%   ByteRoCHistogram: A matrix, where each row shows the absolute value of the differences between two
%       consecutive byte values in the corresponding data fragment.
%
% Revisions:
% 2023-Dec-25   function was created

M = length(fragments);
ByteRoCHistogramMatrix = zeros(M,256);
parfor j=1:M
    
    ByteRoCHistogram = histcounts(abs(diff(fragments{j})),(0:256));
    ByteRoCHistogram = ByteRoCHistogram/(length(fragments{j})-1);
    ByteRoCHistogramMatrix(j,:) = ByteRoCHistogram;
    
end