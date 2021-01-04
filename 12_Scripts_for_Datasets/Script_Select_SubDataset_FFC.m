function ErrorMsg = Script_Select_SubDataset_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Select a sub-dataset (in terms of both feature and classes) by user choice
%
% Copyright (C) 2021 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
% 2020-Oct-20   redundant function handles are removed at the end of the process

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

%% Select Sub-Dataset
[ErrorMsg,Dataset,FeatureLabels,ClassLabels,Function_Select,Feature_Transfrom] = Select_SubDataset_FFC(Dataset_FFC,FeatureLabels_FFC,ClassLabels_FFC,Function_Select_FFC,Feature_Transfrom_FFC);
if ~isempty(ErrorMsg)
    return;
end

%% Save Selected Sub-Dataset
[Filename,path] = uiputfile('my_subdataset.mat','Save Selected Sub-Dataset Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving sub-dataset.';
    return;
end

Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;
if isempty(Feature_Transfrom)
    F_Sel = true(1,length(Function_Select));
    for j=1:length(Function_Select)
        if ~any(Function_Select{j})
            F_Sel(j) = false;
        end
    end
    Function_Handles = Function_Handles(F_Sel);
    Function_Labels = Function_Labels(F_Sel);
    Function_Select = Function_Select(F_Sel);
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');