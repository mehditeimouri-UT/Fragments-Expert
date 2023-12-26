function output = Compare_with_Centroid_Parallel_FFC(fragments,centroid_mu,centroid_sigma)

% This function calculates Mahalanobis distance and cosine similarity
% between a list of fragments of byte values and a centroid model. 
%
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
%   centroid_mu: 1x256 centroid model mean 
%   centroid_sigma: 1x256 centroid model standard deviation 
%
% Output:
%   output: Mx2 vector, including
%       CosineSimilarity: The value of cosine similarity [1].
%       MahalanobisDistance: Mahalanobis distance [2].
%
%   Refs:
%       [1] I. Ahmed, K.-s. Lhee, H. Shin, and M. Hong, "On improving the accuracy and performance of content-based file type identification," 
%           in Information Security and Privacy, 2009, pp. 44-59.
%       [2] W.-J. Li, K. Wang, S. J. Stolfo, and B. Herzog, "Fileprints: Identifying file types by n-gram analysis," 
%           in 6th Annu. IEEE SMC Information Assurance Workshop, 2005, pp. 64-71.
%
% Revisions:
% 2023-Dec-24   function was created

%% Calculate BFD
BFD = ByteHistogram_Parallel_FFC(fragments)*256;

%% Cosine Similarity
CosineSimilarity = (BFD*centroid_mu')./(sqrt(sum(BFD.^2,2))*sqrt(sum(centroid_mu.^2)));

%% Mahalanobis Distance
MahalanobisDistance = sqrt(sum((BFD-repmat(centroid_mu,length(fragments),1)).^2./(0.01+repmat(centroid_sigma.^2,length(fragments),1)),2)); % Smoothing factor 0.01

%% Output
output = [CosineSimilarity MahalanobisDistance];