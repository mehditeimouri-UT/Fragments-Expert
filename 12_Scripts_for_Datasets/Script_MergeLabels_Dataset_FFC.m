function ErrorMsg = Script_MergeLabels_Dataset_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Merge class labels by user choice 
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
% 2020-Mar-05   function was created

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC

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

%% Merge Labels
[ErrorMsg,Dataset,ClassLabels] = MergeLabels_Dataset_FFC(Dataset_FFC,ClassLabels_FFC);
if ~isempty(ErrorMsg)
    return;
end

%% Save Merged-Labels Dataset
[Filename,path] = uiputfile('mydataset_mergedclasses.mat','Save Merged-Labels Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving merged-classes dataset.';
    return;
end

FeatureLabels = FeatureLabels_FFC;
Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;
Function_Select = Function_Select_FFC;
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');
