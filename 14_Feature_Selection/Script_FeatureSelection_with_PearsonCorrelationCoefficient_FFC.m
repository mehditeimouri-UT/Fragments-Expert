function ErrorMsg = Script_FeatureSelection_with_PearsonCorrelationCoefficient_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Use Pearson correlation coefficient to sort and select the features.
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

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC

%% Check that Dataset is generated/loaded
if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

%% Check that Dataset has at least two classes
if length(ClassLabels_FFC)<2
    ErrorMsg = 'At least two classes should be presented.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Assignments
Dataset = Dataset_FFC;
FeatureLabels = FeatureLabels_FFC;
ClassLabels = ClassLabels_FFC;

%% Calculating Pearson Correlation Coefficients
progressbar_FFC('Calculating Pearson Correlation Coefficients ...');
RHO = zeros(1,size(Dataset,2)-2);
for j=1:size(Dataset,2)-2
    
    RHO(j) = corr(Dataset(:,j),Dataset(:,end-1));
    
    stopbar = progressbar_FFC(1,j/(size(Dataset,2)-2));
    if stopbar
        ErrorMsg = 'Process is aborted by user.';
        return;
    end
    
end

RHO = abs(RHO);

%% Prompt User for Selecting Features
[RHO,idx] = sort(RHO,'descend');
UsedFeatures_Str = cell(1,length(idx));
for j=1:length(idx)
    UsedFeatures_Str{j} = sprintf('Feature #%d: %s (Correlation %0.2f)',j,FeatureLabels{idx(j)},RHO(j));
end

[ErrorMsg,FeatureSel,~] = Select_from_List_FFC(UsedFeatures_Str,1,'Select features to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureSel{1};
UsedFeatures = FeatureLabels(idx(FeatureSel));

%% Find index of selected features in dataset and remove other features
[~,FeatSel,~] = intersect(FeatureLabels,UsedFeatures);
FeatSel = sort(FeatSel,'ascend');
FeatSel = FeatSel(:)';

Dataset = Dataset(:,[FeatSel end-1:end]);
FeatureLabels = FeatureLabels(FeatSel);

cnt = 0;
Function_Select = Function_Select_FFC;
if ~isempty(Function_Select)
    for i=1:length(Function_Select)
        for j=1:length(Function_Select{i})
            if Function_Select{i}(j)
                cnt = cnt+1;
                if all(FeatSel~=cnt)
                    Function_Select{i}(j) = false;
                end
            end
        end
    end
end

%% Save Dataset
Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;

[Filename,path] = uiputfile('feature_selected_dataset.mat','Save Feature-Selected Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');
