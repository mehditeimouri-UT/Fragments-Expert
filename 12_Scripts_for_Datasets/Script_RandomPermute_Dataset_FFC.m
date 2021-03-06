function ErrorMsg = Script_RandomPermute_Dataset_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Random Permutation of Samples
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
% 2021-Jan-03   Feature_Transfrom_FFC was included

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC
global Feature_Transfrom_FFC
ErrorMsg = '';

%% Check that Dataset is generated/loaded
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

%% Random Permutation
Dataset = RandomPermute_Dataset_FFC(Dataset_FFC,ClassLabels_FFC);

%% Save Permutated Dataset
[Filename,path] = uiputfile('mydataset_permutated.mat','Save Permutated Dataset');
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving permutated dataset.';
    return;
end

FeatureLabels = FeatureLabels_FFC;
ClassLabels = ClassLabels_FFC;
Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;
Function_Select = Function_Select_FFC;
Feature_Transfrom = Feature_Transfrom_FFC;
save([path Filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');
