function [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Nodes,Scores] = Test_DecisionTree_FFC(tree,Dataset,TestIndex,DataClassLabels,TreeClassLabels,DataFeartureLabels,TreeFeartureLabels,Weights)

% This function takes a decision tree and evaluates the performace of the
% tree on a test set. 
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
%   tree: Trained tree
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
%   TreeClassLabels: 1xM cell that contains string labels corresponding to classes in tree.
%   DataFeartureLabels: 1xF0 cell. Cell contents are strings denoting the name of features in Dataset.
%   TreeFeartureLabels: 1xF cell. Cell contents are strings denoting the name of features in Tree.
%   Weights: Lx1 vector of sample weights. 
%
% Outputs:
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty.
%   Pc: Average of accuracies for final pruned tree on test set.
%   ConfusionMatrix: M0xM confusion matrix 
%       M0 is the number of integer-valued class labels in Dataset, and
%       M is the number of class lables in tree. 
%       Usually M0=M.
%   PredictedLabel: L0*1 vector indicating predicted labels.
%   Nodes: L0x1 vector that indicates the node number in that each samples falls into. 
%   Scores: L0xlength(TreeClassLabels) matrix. Each row with length M shows the probability for each label. 
%
% Revisions:
% 2020-Mar-03   function was created

%% Initialization
ErrorMsg= '';
Pc = [];
ConfusionMatrix = [];
Nodes = [];
Scores = [];
PredictedLabel = [];

%% Check Features Compatibility
if ~isequal(DataFeartureLabels,TreeFeartureLabels)
    ErrorMsg = 'Features in Dataset and Decision Tree are incompatible.';
    return;
end

%% Test Set
Test = Dataset(TestIndex,:);
Test_Weights = Weights(TestIndex);

%% Evaluate the performance of the final tree on the test set
PredictedLabel = predict(tree,Test(:,1:end-2));
Nodes = findNode(tree.Impl,Test(:,1:end-2),[],0);
%Scores = round(repmat(tree.NodeSize(Nodes,:),1,size(tree.ClassProbability,2)).*tree.ClassProbability(Nodes,:));
Scores = tree.ClassProbability(Nodes,:);
[ConfusionMatrix,Pc] = ConfusionMatrix_FFC(Test(:,end-1),PredictedLabel,DataClassLabels,TreeClassLabels,Test_Weights);