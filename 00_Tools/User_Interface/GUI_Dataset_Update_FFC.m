function GUI_Dataset_Update_FFC(Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select)

% This function updates the Fragments-Expert GUI according to Generated/Loaded Dataset. 
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
%   Filename: File name corresponding to loaded/generated Dataset.
%   Dataset: Dataset with L rows (L samples corresponding to L fragments)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%     
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the fragments
%   of a signle multimedia file appear consecutively.
%
%   Function_Handles: cell array of function handles used for generating
%       dataset.
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%
% Revisions:
% 2020-Mar-03   function was created

%% Initialization
global Dataset_FFC_Name_TextBox Dataset_FFC_Classes_TextBox Dataset_FFC_Features_TextBox View_Classes_PushButton_FFC View_Features_PushButton_FFC
global Dataset_FFC ClassLabels_FFC FeatureLabels_FFC
global ClassLabelsandNumbers_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC

%% Update GUI
set(Dataset_FFC_Name_TextBox,'String',Filename);
set(Dataset_FFC_Classes_TextBox,'String',num2str(length(ClassLabels)));
set(Dataset_FFC_Features_TextBox,'String',num2str(length(FeatureLabels)));
set(View_Classes_PushButton_FFC,'Enable','on');
set(View_Features_PushButton_FFC,'Enable','on');

%% Update Dataset
Dataset_FFC  = Dataset;
ClassLabels_FFC = ClassLabels;
FeatureLabels_FFC = FeatureLabels;
Function_Handles_FFC = Function_Handles;
Function_Labels_FFC = Function_Labels;
Function_Select_FFC = Function_Select;
ClassLabelsandNumbers_FFC = cell(size(ClassLabels_FFC));
for j=1:length(ClassLabels_FFC)
    ClassLabelsandNumbers_FFC{j} = sprintf('%s: %s samples',ClassLabels_FFC{j},num2str(sum(Dataset_FFC(:,end-1)==j)));
end