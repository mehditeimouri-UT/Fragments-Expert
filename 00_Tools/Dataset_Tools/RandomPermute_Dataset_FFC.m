function Dataset_p = RandomPermute_Dataset_FFC(Dataset,ClassLabels)

% This function does random permutation on the samples of a Dataset.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
% Input:
%   Dataset: Dataset with L rows (L samples corresponding to L fragments)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%
% Output:
%   Dataset_p: Permuted Dataset
%
%   Note: In Dataset and Dataset_p, First, the samples of class 1 appear. 
%   Second, the the samples of class 2 appear, and so on. Also, for the samples 
%   of each class, the fragments of a signle multimedia file appear consecutively.
%
% Revisions:
% 2020-Mar-05   function was created

%% Initialization
M = length(ClassLabels); % Number of classes in Dataset

%% Find indices of different classes in Dataset
Indices = cell(1,M); % Indices of samples of each class in Dataset
P = cell(1,M); % Index for start of different File IDs in each class
for i=1:length(ClassLabels)
    
    Indices{i} = find(Dataset(:,end-1)==i);
    FrgIndices = Dataset(Indices{i},end);
    P{i} = [0 find(diff(FrgIndices)~=0)' length(FrgIndices)];
    
end

%% Random Permutation
Dataset_p = zeros(size(Dataset));
cnt = 0;
for i=1:M % Loop over different classes
    
    rndprm = randperm(length(P{i})-1);
    for j=1:length(P{i})-1 % Loop over various files; The fragments of a signle multimedia file appear consecutively
        
        idx_s = P{i}(rndprm(j))+1;
        idx_e = P{i}(rndprm(j)+1);
        lji = idx_e-idx_s+1;
        Dataset_p(cnt+(1:lji),:) = Dataset(Indices{i}(idx_s:idx_e),:);
        cnt = cnt+lji;
    end
    
end
