function Main_FFC

% This function is the main function of Fragments-Expert software.
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
% Revisions:
%   2020-Mar-01   function was created
%   2020-Oct-19   A waiting message is shown when a menu button is pushed, so the user knows that the process is not finished yet
%   2021-Jan-03   Feature_Transfrom_FFC and DM_Feature_Transfrom_FFC were defined and included

%% Initialization
global Main_FFC_fig

if ~isempty(Main_FFC_fig)
    figure(Main_FFC_fig);
    return;
end

global AllPaths_FFC
global TextBox_FFC TextBox_FFC_String
global Dataset_FFC_Name_TextBox Dataset_FFC_Classes_TextBox Dataset_FFC_Features_TextBox View_Classes_PushButton_FFC View_Features_PushButton_FFC
global DecisionMachine_FFC_Name_TextBox DecisionMachine_FFC_Validation_TextBox View_Decision_Machine_PushButton_FFC
global TestResults_FFC_Name_TextBox View_TestResults_PushButton_FFC
global CrossValidationResults_FFC_Name_TextBox View_CrossValidationResults_PushButton_FFC

ver = '1.2';

currentFolder = which('Main_FFC.m');
currentFolder(strfind(currentFolder,'Main_FFC.m')-1:end) = [];
AllPaths_FFC = genpath(currentFolder);
addpath(AllPaths_FFC);

Main_FFC_fig = figure;
set(Main_FFC_fig,'Name',sprintf('Fragments-Expert v%s',ver),'NumberTitle','off',...
    'Toolbar','None','MenuBar','None','DeleteFcn',@Close_Main_FFC);

%% Define Text Box for Dataset Information
% Dataset Name
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0 0.95 .5 0.05],...
    'HorizontalAlignment','Center','String','Generated/Loaded Dataset');

Dataset_FFC_Name_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0 0.9 .5 0.05],...
    'HorizontalAlignment','Center');

% Class Labels
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[24/256 103/256 182/256],'Units','normalized','Position', [0 0.85 1/6 0.05],...
    'HorizontalAlignment','Center','String','Classes');

Dataset_FFC_Classes_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [1/6 0.85 1/6 0.05],...
    'HorizontalAlignment','Center');

View_Classes_PushButton_FFC = uicontrol(Main_FFC_fig,'Style', 'pushbutton', 'String', 'View Classes',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [2/6 0.85 1/6 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_FFC);

% Feature Labels
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[24/256 103/256 182/256],'Units','normalized','Position', [0 0.8 1/6 0.05],...
    'HorizontalAlignment','Center','String','Features');

Dataset_FFC_Features_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [1/6 0.8 1/6 0.05],...
    'HorizontalAlignment','Center');

View_Features_PushButton_FFC = uicontrol(Main_FFC_fig,'Style', 'pushbutton', 'String', 'View Features',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [2/6 0.8 1/6 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_FFC);

%% Define Text Box for Decision Machine Information
% Decision Machine Name
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.5 0.95 .5 0.05],...
    'HorizontalAlignment','Center','String','Trained/Loaded Decision Machine');

DecisionMachine_FFC_Name_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.5 0.9 .5 0.05],...
    'HorizontalAlignment','Center');

% Validation Accuracy
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[24/256 103/256 182/256],'Units','normalized','Position', [0.5 0.85 0.25 0.05],...
    'HorizontalAlignment','Center','String','Validation Accuracy');

DecisionMachine_FFC_Validation_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.75 0.85 0.25 0.05],...
    'HorizontalAlignment','Center');

% View Decision Machine
View_Decision_Machine_PushButton_FFC = uicontrol(Main_FFC_fig,'Style', 'pushbutton', 'String', 'View Decision Machine',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.5 0.8 0.5 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_FFC);

%% Define Text Box for Test Results Information
% Test Results Name
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0.5 0.75 .5 0.05],...
    'HorizontalAlignment','Center','String','Generated/Loaded Test Results');

TestResults_FFC_Name_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0.5 0.70 .5 0.05],...
    'HorizontalAlignment','Center');

% View Test/Results
View_TestResults_PushButton_FFC = uicontrol(Main_FFC_fig,'Style', 'pushbutton', 'String', 'View Test Results',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0.5 0.65 0.5 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_FFC);

%% Define Text Box for Cross-Validation Results Information
% Cross-Validation Results Name
uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[193/256 193/256 193/256],'Units','normalized','Position', [0 0.75 .5 0.05],...
    'HorizontalAlignment','Center','String','Generated/Loaded Cross-Validation Results');

CrossValidationResults_FFC_Name_TextBox = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0 0.70 .5 0.05],...
    'HorizontalAlignment','Center');

% View Cross-Validation Results
View_CrossValidationResults_PushButton_FFC = uicontrol(Main_FFC_fig,'Style', 'pushbutton', 'String', 'View Cross-Validation Results',...
    'BackgroundColor',[149/256 178/256 207/256],'Units','normalized','Position', [0 0.65 0.5 0.05],...
    'Enable','off','Callback',@RunMethodsforMainGUIPushButtons_FFC);

%% Define Text Box for Information
TextBox_FFC = uicontrol(Main_FFC_fig,'Style', 'edit','Enable','inactive','Max',1000,...
    'BackgroundColor',[240/256 240/256 240/256],'Units','normalized','Position', [0 0 1 0.65],...
    'HorizontalAlignment','Left');
TextBox_FFC_String = {};

%% Define File Menu and Submenus
File_Menu = uimenu('Label','File');
uimenu(File_Menu,'Label','Load Dataset','Callback',@RunMethodsforMenus_FFC);
uimenu(File_Menu,'Label','Load Decision Machine','Callback',@RunMethodsforMenus_FFC);
uimenu(File_Menu,'Label','Load Test Results','Callback',@RunMethodsforMenus_FFC);
uimenu(File_Menu,'Label','Load Cross-Validation Results','Callback',@RunMethodsforMenus_FFC);
uimenu(File_Menu,'Label','Exit','Callback','closereq','Separator','on');

%% Define Dataset Menu and Submenus
Dataset_Menu = uimenu('Label','Dataset');
uimenu(Dataset_Menu,'Label','Random Permutation of Dataset','Callback',@RunMethodsforMenus_FFC);
uimenu(Dataset_Menu,'Label','Expand Dataset','Callback',@RunMethodsforMenus_FFC);
uimenu(Dataset_Menu,'Label','Merge Labels in Dataset','Callback',@RunMethodsforMenus_FFC);
uimenu(Dataset_Menu,'Label','Select Sub-Dataset','Callback',@RunMethodsforMenus_FFC);
uimenu(Dataset_Menu,'Label','Generate Dataset from Generic Binary Files of Fragments','Callback',@RunMethodsforMenus_FFC,'Separator','on');
uimenu(Dataset_Menu,'Label','Generate Dataset (for Decision Machine) from Generic Binary Files of Fragments','Callback',@RunMethodsforMenus_FFC,'Separator','on');
uimenu(Dataset_Menu,'Label','Convert Raw Multimedia to Fragments Dataset','Callback',@RunMethodsforMenus_FFC,'Separator','on');

%% Define Feature Selection Menu and Submenus
FeatureSelection_Menu = uimenu('Label','Feature Selection');
uimenu(FeatureSelection_Menu,'Label','Embedded: Decision Tree','Callback',@RunMethodsforMenus_FFC);
uimenu(FeatureSelection_Menu,'Label','Filter: Pearson Correlation Coefficient','Callback',@RunMethodsforMenus_FFC);
uimenu(FeatureSelection_Menu,'Label','Wrapper: Sequential Forward Selection with LDA','Callback',@RunMethodsforMenus_FFC);
uimenu(FeatureSelection_Menu,'Label','Feature Transformation: Principal Component Analysis (PCA)','Callback',@RunMethodsforMenus_FFC);

%% Define Learning Menu and Submenus
Learning_Menu = uimenu('Label','Learning');
uimenu(Learning_Menu,'Label','Train Decision Machine','Callback',@RunMethodsforMenus_FFC);
uimenu(Learning_Menu,'Label','Test Decision Machine','Callback',@RunMethodsforMenus_FFC);
uimenu(Learning_Menu,'Label','Cross-Validation of Decision Machine','Callback',@RunMethodsforMenus_FFC);

%% Define Visualization Menu and Submenus
Visualization_Menu = uimenu('Label','Visualization');
uimenu(Visualization_Menu,'Label','t-Distributed Stochastic Neighbor Embedding (t-SNE)','Callback',@RunMethodsforMenus_FFC);
uimenu(Visualization_Menu,'Label','Box Plot of Features','Callback',@RunMethodsforMenus_FFC);
uimenu(Visualization_Menu,'Label','Plot Feature Histogram','Callback',@RunMethodsforMenus_FFC);
uimenu(Visualization_Menu,'Label','Display Samples in Feature Space','Callback',@RunMethodsforMenus_FFC);

%% Define Help Menu and Submenus
Help_Menu = uimenu('Label','Help');
uimenu(Help_Menu,'Label','About Fragments-Expert','Callback',@About_Callback);

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% ------------------------------------- GUI Subfunctions -------------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Define Callback Functions for Menus and Submenus
function RunMethodsforMenus_FFC(source,~)

% Clear the multi-line edit ui in Fragments-Expert GUI.
GUI_MainEditBox_Update_FFC(true);
GUI_MainEditBox_Update_FFC(false,'Please wait ...');

% Run callback function
switch get(source,'Label')
    
    case 'Load Dataset'
        ErrorMsg = Script_Load_Dataset_FFC;
        
    case 'Load Decision Machine'
        ErrorMsg = Script_Load_DecisionMachine_FFC;

    case 'Load Test Results'
        ErrorMsg = Script_Load_DecisionMachine_Test_Results_FFC;
        
    case 'Load Cross-Validation Results'
        ErrorMsg = Script_Load_CrossValidation_Results_FFC;

    case 'Random Permutation of Dataset'
        ErrorMsg = Script_RandomPermute_Dataset_FFC;
        
    case 'Expand Dataset'
        ErrorMsg = Script_Expand_Dataset_FFC;

    case 'Merge Labels in Dataset'
        ErrorMsg = Script_MergeLabels_Dataset_FFC;
        
    case 'Select Sub-Dataset'
        ErrorMsg = Script_Select_SubDataset_FFC;
        
    case 'Generate Dataset from Generic Binary Files of Fragments'
        ErrorMsg = Script_GenerateDataset_from_FragmentDataset_FFC;
        
    case 'Convert Raw Multimedia to Fragments Dataset'
        ErrorMsg = Script_RawData_to_Fragments_FFC;

    case 'Embedded: Decision Tree'
        ErrorMsg = Script_FeatureSelection_with_DecisionTree_FFC;
    
    case 'Wrapper: Sequential Forward Selection with LDA'
        ErrorMsg = Script_SequentialForward_FeatureSelection_FFC;
    
    case 'Train Decision Machine'
        ErrorMsg = Script_DecisionMachine_Train_FFC;

    case 'Test Decision Machine'
        ErrorMsg = Script_DecisionMacine_Test_FFC;
        
    case 'Cross-Validation of Decision Machine'
        ErrorMsg = Script_DecisionMachine_CrossValidation_FFC;
        
    case 'Generate Dataset (for Decision Machine) from Generic Binary Files of Fragments'
        ErrorMsg = Script_GenerateDataset_for_DecisionMachine_FFC;
        
    case 'Plot Feature Histogram'
        ErrorMsg = Script_Plot_FeatureHistogram_FFC;
        
    case 'Display Samples in Feature Space'
        ErrorMsg = Script_Plot_Samples_in_FeatureSpace_FFC;
        
    case 't-Distributed Stochastic Neighbor Embedding (t-SNE)'
        ErrorMsg = Script_t_SNE_Visualization_FFC;
        
    case 'Box Plot of Features'
        ErrorMsg = Script_Box_Plot_of_Features_FFC;
        
    case 'Filter: Pearson Correlation Coefficient'
        ErrorMsg = Script_FeatureSelection_with_PearsonCorrelationCoefficient_FFC;
        
    case 'Feature Transformation: Principal Component Analysis (PCA)'
        ErrorMsg = Script_FeatureSelection_with_PCA_FFC;

    otherwise
end

% Display Error Message
if ~isempty(ErrorMsg)
    GUI_MainEditBox_Update_FFC(false,'-----------------------------------------------------------');
    GUI_MainEditBox_Update_FFC(false,ErrorMsg);
    GUI_MainEditBox_Update_FFC(false,'-----------------------------------------------------------','red');
end


%% Define Callback Functions for Main GUI PushButtons
function RunMethodsforMainGUIPushButtons_FFC(source,~)

global ClassLabelsandNumbers_FFC FeatureLabels_FFC
global DM_TrainingParameters_FFC DM_TrainingResults_FFC DecisionMachine_FFC DecisionMachine_CL_FFC DM_ClassLabels_FFC
global TestParameters_FFC TestResults_FFC
global CV_Parameters_FFC CV_Results_FFC

% Clear the multi-line edit ui in Fragments-Expert GUI.
GUI_MainEditBox_Update_FFC(true);

% Run callback function
switch get(source,'String')
    case 'View Classes'
        Display_StringCell_FFC(ClassLabelsandNumbers_FFC,'List of classes and number of samples for each class in Dataset');
        
    case 'View Features'
        Display_StringCell_FFC(FeatureLabels_FFC,'List of Features in Dataset');
        
    case 'View Decision Machine'
        Display_DecisionMachine_FFC(DM_TrainingParameters_FFC,DM_TrainingResults_FFC,DecisionMachine_FFC,DecisionMachine_CL_FFC,DM_ClassLabels_FFC);

    case 'View Test Results'
        Display_TestResults_FFC(TestParameters_FFC,TestResults_FFC);
        
    case 'View Cross-Validation Results'
        Display_CrossValidationResults_FFC(CV_Parameters_FFC,CV_Results_FFC);

    otherwise
end

%% Menus: Callback Functions
function About_Callback(~,~)

% display GPL License
str0 = 'Fragments-Expert is a software package for feature extraction from file fragments and classification among various file formats.';
str1 = 'To run Fragments-Expert you need MATLAB R2015b or newer releases.';
str2 = 'Fragments-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.';
str3 = 'Fragments-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.';
str4 = 'You should have received a copy of the GNU General Public License along with this program. If not, see <http://www.gnu.org/licenses/>.';
str5 = 'For any question, please contact via e-mail to mehditeimouri@ut.ac.ir.';

about = sprintf('%s\n\n%s\n\n%s\n\n%s\n\n%s\n\n%s',str0,str1,str2,str3,str4,str5);
[cdata,map] = imread('gplv3-88x31.png');
h = msgbox(about,'About Fragments-Expert','custom',cdata,map,'modal');

% Set Position of GPL logo
txt_handle = findall(h, 'Type', 'Text');
h.Children(2).Position(2) = txt_handle.Position(2);

%% Close GUI: Callback function
function Close_Main_FFC(~,~)

global AllPaths_FFC Main_FFC_fig Dataset_FFC Function_Handles_FFC
global DecisionMachine_FFC DecisionMachine_CL_FFC
global Feature_Transfrom_FFC DM_Feature_Transfrom_FFC

rmpath(AllPaths_FFC);
Main_FFC_fig = [];
Dataset_FFC = [];
Function_Handles_FFC = [];
DecisionMachine_FFC = [];
DecisionMachine_CL_FFC = [];
Feature_Transfrom_FFC = [];
DM_Feature_Transfrom_FFC = [];
