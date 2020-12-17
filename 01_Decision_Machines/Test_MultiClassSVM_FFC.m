function [ErrorMsg,Pc,ConfusionMatrix,Scores,PredictedLabel] = Test_MultiClassSVM_FFC(SVMModel,Dataset,TestIndex,DataClassLabels,SVMClassLabels,DataFeartureLabels,SVMFeartureLabels,Weights)

% This function takes a multi-class SVM model and evaluates the performace
% of this model on a test set. 
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
%   SVMModel: A cell array; each element is jth binary SVM
%   Dataset: Dataset with L rows (L samples corresponding to L fragments)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%     
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the fragments
%   of a signle multimedia file appear consecutively.
%
%   TestIndex: L0*1 vector denoting the index of Test samples.
%   DataClassLabels: 1xM0 cell that contains string labels corresponding to classes in Dataset.
%   SVMClassLabels: 1xM cell that contains string labels corresponding to classes in SVMModel.
%   DataFeartureLabels: 1xF0 cell. Cell contents are strings denoting the name of features in Dataset.
%   SVMFeartureLabels: 1xF cell. Cell contents are strings denoting the name of features in SVMModel.
%   Weights: Lx1 vector of sample weights. 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty.
%   Pc: Average of accuracies for SVMModel on test set.
%   ConfusionMatrix: M0xM confusion matrix 
%   Scores: L0xlength(SVMClassLabels) matrix. i-th row shows the scores
%       given to sample i by all length(SVMClassLabels) binary SVM models.
%   PredictedLabel: L0*1 vector indicating predicted labels.
%
% Revisions:
% 2020-Mar-11   function was created

%% Initialization
ErrorMsg= '';
Pc = [];
ConfusionMatrix = [];
Scores = [];
PredictedLabel = [];

%% Check Features Compatibility
if ~isequal(DataFeartureLabels,SVMFeartureLabels)
    ErrorMsg = 'Features in Dataset and SVMModel are incompatible.';
    return;
end

%% Test Set
Test = Dataset(TestIndex,:);
Test_Weights = Weights(TestIndex);

%% Evaluate the performance of the SVMModel on the test set
M = length(SVMClassLabels);
Scores = zeros(size(Test,1),M);
for j=1:length(SVMModel)
    [~,score] = predict(SVMModel{j},Test(:,1:end-2));
    Scores(:,j) = score(:,2);
end
[~,PredictedLabel] = max(Scores,[],2);

[ConfusionMatrix,Pc] = ConfusionMatrix_FFC(Test(:,end-1),PredictedLabel,DataClassLabels,SVMClassLabels,Test_Weights);