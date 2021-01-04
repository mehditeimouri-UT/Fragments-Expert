function GUI_DecisionMachine_Update_FFC(Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom)

                                        
% This function updates the Fragments-Expert GUI according to Generated/Loaded Decision Machine. 
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
% Inputs:
%   Filename: File name corresponding to loaded/generated Decision Machine.
%   TrainingParameters: A structure that specifies the parameters for
%       training. Some of the fields are as follows. Depending on TrainingParameters.Type
%       there may be more fields.
%           TrainingParameters.Type: Type of decision machine. Type should be be of the following:
%           'Decision Tree', 'SVM', 'Random Forest, ...'.
%           TrainingParameters.DatasetName: The name of the employed Dataset
%   TrainingResults: A structure that specifies the results of training. Depending on TrainingParameters.Type
%       the number of fields for this structre can vary.
%   DecisionMachine: Decision Machine MATLAB Object
%   DecisionMachine_CL: Decision Machine MATLAB Object
%
%   Note: DecisionMachine_CL and DecisionMachine are basically the same. In
%   DecisionMachine_CL, class labels are string values. In DecisionMachine, 
%   class labels are integer values.
%
%   FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to DecisionMachine.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued DecisionMachine class labels 1,2,....
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%     
% Revisions:
% 2020-Mar-04   function was created
% 2021-Jan-03   DM_Feature_Transfrom_FFC was included

%% Initialization
global DecisionMachine_FFC_Name_TextBox DecisionMachine_FFC_Validation_TextBox View_Decision_Machine_PushButton_FFC
global DM_TrainingParameters_FFC DM_TrainingResults_FFC DecisionMachine_FFC DecisionMachine_CL_FFC DM_ClassLabels_FFC DM_FeatureLabels_FFC
global DM_Function_Handles_FFC DM_Function_Labels_FFC DM_Function_Select_FFC DM_Feature_Transfrom_FFC

%% Update GUI
set(DecisionMachine_FFC_Name_TextBox,'String',Filename);
if isempty(TrainingResults.Pc)
    set(DecisionMachine_FFC_Validation_TextBox,'String',sprintf('x%%'));
else
    set(DecisionMachine_FFC_Validation_TextBox,'String',sprintf('%0.2f%%',TrainingResults.Pc));
end
set(View_Decision_Machine_PushButton_FFC,'Enable','on');

%% Update Dataset
DM_TrainingParameters_FFC = TrainingParameters;
DM_TrainingResults_FFC = TrainingResults;
DecisionMachine_FFC  = DecisionMachine;
DecisionMachine_CL_FFC  = DecisionMachine_CL;
DM_ClassLabels_FFC = ClassLabels; 
DM_FeatureLabels_FFC = FeatureLabels;
DM_Function_Handles_FFC = Function_Handles;
DM_Function_Labels_FFC = Function_Labels;
DM_Function_Select_FFC = Function_Select;
DM_Feature_Transfrom_FFC = Feature_Transfrom;