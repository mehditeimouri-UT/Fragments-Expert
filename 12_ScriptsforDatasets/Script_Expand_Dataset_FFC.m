function ErrorMsg = Script_Expand_Dataset_FFC

% This function expands Dataset_FFC using an aready-saved Dataset from a mat file
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
% ErrorMsg = 'Under Construction Function.';
% return;
if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

if isempty(Function_Handles_FFC)
    ErrorMsg = 'The process is not possible: The dataset does not include any function handle.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Load the Old Dataset
[~,Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old,ErrorMsg] = Load_Dataset_FFC('Load the Old Dataset');
if ~isempty(ErrorMsg)
    return;
end
if isempty(Function_Handles_Old)
    ErrorMsg = 'The process is not possible: The dataset does not include any function handle.';
    return;
end


%% Expand the Old Dataset
[ErrorMsg,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select] = ...
    Expand_Dataset_FFC(Dataset_FFC,FeatureLabels_FFC,ClassLabels_FFC,Function_Handles_FFC,Function_Labels_FFC,Function_Select_FFC,...
    Dataset_Old,FeatureLabels_Old,ClassLabels_Old,Function_Handles_Old,Function_Labels_Old,Function_Select_Old);
if ~isempty(ErrorMsg)
    return;
end

%% Save Expanded Dataset
[Filename,path] = uiputfile('mydataset_expanded.mat','Save Expanded Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving expanded dataset.';
    return;
end
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','-v7.3');


%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');