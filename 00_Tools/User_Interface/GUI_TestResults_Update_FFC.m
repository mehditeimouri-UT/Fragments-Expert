function GUI_TestResults_Update_FFC(Filename,TestParameters,TestResults)

                                        
% This function updates the Fragments-Expert GUI according to Generated/Loaded Test Results. 
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
%   Filename: File name corresponding to loaded test results.
%   TestParameters: A structure that specifies the parameters of
%       test. Some of the fields are as follows. Depending on TestParameters.DM_Type
%       there may be more fields.
%           TestParameters.DM_FileName: The filename of the employed
%               decision machine. 
%           TestParameters.DM_Type: Type of decision machine. Type should be be of the following:
%               'Decision Tree', 'SVM', 'Random Forest, ...'.
%           TestParameters.DM_ClassLabels: 1xM cell that contains string labels corresponding to classes in decision machine.
%           TestParameters.Dataset_FileName The filename of the employed
%               dataset. 
%           TestParameters.Dataset_ClassLabels: 1xM0 cell that contains string labels corresponding to classes in dataset.
%           TestParameters.TestIdx: Start and End of the Test in Dataset (1x2 vector with elements 0~1)
%           TestParameters.Weighting_Method: Weighting Method (balanced or
%               uniform)
%
% Revisions:
% 2020-Mar-11   function was created

%% Initialization
global TestResults_FFC_Name_TextBox View_TestResults_PushButton_FFC
global TestParameters_FFC TestResults_FFC

%% Update GUI
set(TestResults_FFC_Name_TextBox,'String',Filename);
set(View_TestResults_PushButton_FFC,'Enable','on');

%% Update Dataset
TestParameters_FFC = TestParameters;
TestResults_FFC = TestResults;