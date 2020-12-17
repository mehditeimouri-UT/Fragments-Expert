function [ErrorMsg,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select] = Expand_Dataset_FFC(...
    Dataset_New,FeatureLabels_New,ClassLabels_New,Function_Handles_New,Function_Labels_New,Function_Select_New,...
    Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old)

% This function adds the features of Dataset_New to Dataset_Old (i.e. it expands Dataset_Old)
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
% Inputs:
%   Dataset_New: Dataset with L rows (L samples corresponding to L fragments)
%       and Cn columns. The first Cn-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   FeatureLabels_New: 1xFn cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels_New: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles_New: cell array of function handles used for generating
%       dataset. 
%   Function_Labels_New: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select_New: Cell array of selected features after feature calculation. 
%   Dataset_Old: Dataset with L rows (L samples corresponding to L fragments)
%       and Co columns. The first Co-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   FeatureLabels_Old: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels_Old: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles_Old: cell array of function handles used for generating
%       dataset. 
%   Function_Labels_Old: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select_Old: Cell array of selected features after feature calculation. 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty.
%   Dataset: Dataset with L rows (L samples corresponding to L fragments)
%       and C columns. The first C columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   FeatureLabels: 1xF cell (F <= Fo+Fn). Cell contents are strings denoting
%       the name of features corresponding to the columns of Dataset.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%
%   Note 1: In Dataset_New, Dataset_Old, and Dataset, First, the samples of class 1 appear.
%   Second, the the samples of class 2 appear, and so on. Also, for the samples
%   of each class, the fragments of a signle multimedia file appear consecutively.
%
%   Note 2: Repetitive feature are omitted.
%
% Revisions:
% 2020-Mar-07   function was created

%% Initialization
ErrorMsg = '';
Dataset = [];
FeatureLabels = [];
ClassLabels = [];
Function_Handles = [];
Function_Labels = [];
Function_Select = [];

%% Check Datasets
if ~isequal(Dataset_Old(:,end-1:end),Dataset_New(:,end-1:end)) || ~isequal(ClassLabels_Old,ClassLabels_New)
    ErrorMsg = 'Datasets sizes, output labels, or fileIDs do not match. Expanding is aborted.';
    return;
else
    Dataset = [Dataset_Old(:,1:end-2) Dataset_New(:,1:end)];
    FeatureLabels = [FeatureLabels_Old FeatureLabels_New];
    ClassLabels = ClassLabels_Old;
    
    Function_Handles = [Function_Handles_Old Function_Handles_New];
    Function_Labels = [Function_Labels_Old Function_Labels_New];
    Function_Select = [Function_Select_Old Function_Select_New];
    
    % Repetitive feature are omitted
    UniqueFeatLabels = unique(FeatureLabels);
    IncludedFeatLabels = false(size(UniqueFeatLabels));    
    cnt = 0;
    DelFeatIdx = false(1,length(FeatureLabels));
    for i=1:length(Function_Select)
        for j=1:length(Function_Select{i})
            if Function_Select{i}(j)
                cnt = cnt+1;
                idx = find(strcmp(UniqueFeatLabels,Function_Labels{i}{j}));
                if ~IncludedFeatLabels(idx)
                    IncludedFeatLabels(idx) = true;
                else
                    DelFeatIdx(cnt) = true;
                    Function_Select{i}(j) = false;
                end
            end
        end
    end
    FeatureLabels(DelFeatIdx) = [];
    Dataset(:,[DelFeatIdx false false]) = [];
end