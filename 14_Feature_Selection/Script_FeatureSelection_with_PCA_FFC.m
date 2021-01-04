function ErrorMsg = Script_FeatureSelection_with_PCA_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Use feature transformation method of principal component analysis (PCA) to obtain the new set of features.
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
% Output:
%   ErrorMsg: Possible error message. If there is no error, this output is
%   empty. 
%
% Revisions:
% 2020-Oct-29   function was created
% 2021-Jan-03   Feature_Transfrom_FFC was defined and included

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC
global Feature_Transfrom_FFC

%% Check that Dataset is generated/loaded
if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Assignments
ClassLabels = ClassLabels_FFC;
FeatureLabels = cell(1,length(FeatureLabels_FFC));
for j=1:length(FeatureLabels_FFC)
    FeatureLabels{j} = sprintf('PCA_%d',j);
end

%% Applying PCA
Dataset = zeros(size(Dataset_FFC));
[Coef,~,feat_eigs] = pca(Dataset_FFC(:,1:end-2));
Dataset(:,1:end-2) = Dataset_FFC(:,1:end-2)*Coef;
Dataset(:,end-1:end) = Dataset_FFC(:,end-1:end);

%% Prompt User for Selecting Features
UsedFeatures_Str = cell(1,length(FeatureLabels_FFC));
for j=1:length(FeatureLabels_FFC)
    UsedFeatures_Str{j} = sprintf('Feature #%d: %s (Eigen-Value  %g)',j,FeatureLabels{j},feat_eigs(j));
end

[ErrorMsg,FeatureSel,~] = Select_from_List_FFC(UsedFeatures_Str,1,'Select features to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureSel{1};
UsedFeatures = FeatureLabels(FeatureSel);

%% Find index of selected features in dataset and remove other features
[~,FeatSel,~] = intersect(FeatureLabels,UsedFeatures);
FeatSel = sort(FeatSel,'ascend');
FeatSel = FeatSel(:)';

Dataset = Dataset(:,[FeatSel end-1:end]);
FeatureLabels = FeatureLabels(FeatSel);

%% Modify Feature_Transfrom
Feature_Transfrom = Feature_Transfrom_FFC;
if isempty(Feature_Transfrom)
    Feature_Transfrom.Coef = Coef(:,FeatSel);
else
    Feature_Transfrom.Coef = Feature_Transfrom.Coef*Coef(:,FeatSel);
end

%% Save Dataset
Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;
Function_Select = Function_Select_FFC;

[Filename,path] = uiputfile('feature_selected_dataset.mat','Save Feature-Selected Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');
