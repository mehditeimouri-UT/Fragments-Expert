function ErrorMsg = Script_DecisionMacine_Test_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Test DecisionMachine_FFC with a part of Dataset_FFC and displays the results.
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
% 2020-Mar-10   function was created
% 2020-Oct-19   filename for saving the results is prompted before the process begins  
% 2021-Jan-15   The Nodes output in decision tree was removed for 
%               compatibility with other MATLAB releases.

%% Initialization 
global Dataset_FFC DecisionMachine_FFC DecisionMachine_CL_FFC
global ClassLabels_FFC DM_ClassLabels_FFC 
global FeatureLabels_FFC DM_FeatureLabels_FFC
global DM_TrainingParameters_FFC
global Dataset_FFC_Name_TextBox DecisionMachine_FFC_Name_TextBox

%% Check that Dataset is generated/loaded
if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

%% Check that Decision Machine is trained/loaded
if isempty(DecisionMachine_FFC) && isempty(DecisionMachine_CL_FFC)
    ErrorMsg = 'No decision machine is loaded. Please train or load a decision machine.';
    return;
end

%% Parameters
TestIdx = [0 1]; % 1x2 vector that shows the start and end of the test in range (0,1)
Weighting_Method = 'balanced'; % balanced/uniform

[success,TestIdx,Weighting_Method] = PromptforParameters_FFC(...
    {'Start and End of the Test in Dataset (1x2 vector with elements 0~1)',...
    'Weighting Method (balanced or uniform)'},...
    {['[' num2str(TestIdx) ']'],Weighting_Method},'Parameters for testing decision machine');

if ~success
    ErrorMsg = 'Process is aborted. Parameters are not specified for testing decision machine.';
    return;
end

%% Check Parameters
[Err,ErrMsg] = Check_Variable_Value_FFC(Weighting_Method,'Weighting Method','possiblevalues',{'balanced','uniform'});
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(TestIdx,'Start and End of the Test in Dataset','type','vector','class','real','size',[1 2],'min',0,'max',1,'issorted','ascend');
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% Get filename for saving the results
FullFileName = ['Test_' matlab.lang.makeValidName(DM_TrainingParameters_FFC.Type) '.mat'];
if FullFileName(end-4)=='_'
    FullFileName(end-4) = [];
end
[Filename,path] = uiputfile('*.mat','Save Test Results As',FullFileName);
FullFileName = [path Filename];
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving the test results.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Select Test Samples
[ErrorMsg,TestIndex] = Partition_Dataset_FFC(Dataset_FFC(:,end-1:end),ClassLabels_FFC,{[TestIdx(1) TestIdx(2)]});
if ~isempty(ErrorMsg)
    return;
end

%% Scaling Features
switch DM_TrainingParameters_FFC.Type
    case {'SVM','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'}
        Dataset = Scale_Features_FFC(Dataset_FFC,DM_TrainingParameters_FFC.Scaling_Parameters);
        
    case {'Decision Tree','Random Forest'}
        Dataset = Dataset_FFC;

end

%% Assign Weights
Weights = Assign_Weights_FFC(Dataset_FFC(:,end-1),ClassLabels_FFC,Weighting_Method);

%% Evaluate the performance of the decision machine on the test set
switch DM_TrainingParameters_FFC.Type
    case 'Decision Tree'
        
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = ...
            Test_DecisionTree_FFC(DecisionMachine_FFC,Dataset,TestIndex,ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'SVM'
        
        [ErrorMsg,Pc,ConfusionMatrix,Scores,PredictedLabel] = ...
            Test_MultiClassSVM_FFC(DecisionMachine_FFC,Dataset,TestIndex,ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'Random Forest'
        
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_RandomForest_FFC(DecisionMachine_CL_FFC,Dataset,TestIndex,...
            ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'Ensemble kNN'
        
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_EnsemblekNN_FFC(DecisionMachine_CL_FFC,Dataset,TestIndex,...
            ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'Naive Bayes'
        
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_NaiveBayes_FFC(DecisionMachine_FFC,Dataset,TestIndex,...
            ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'Linear Discriminant Analysis (LDA)'
        
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_LDA_FFC(DecisionMachine_CL_FFC,Dataset,TestIndex,...
            ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,DM_FeatureLabels_FFC,Weights);
        
    case 'Neural Network'
        [ErrorMsg,Pc,ConfusionMatrix,PredictedLabel,Scores] = Test_PatternRecognitionNeuralNetwork_FFC(DecisionMachine_FFC,Dataset,TestIndex,...
            ClassLabels_FFC,DM_ClassLabels_FFC,FeatureLabels_FFC,FeatureLabels_FFC,Weights);
        
end

if ~isempty(ErrorMsg)
    return;
end

%% Set Variables for Test Parameters Results
TestParameters.DM_FileName = get(DecisionMachine_FFC_Name_TextBox,'String'); % The name of the employed Decision Mchine
TestParameters.DM_Type = DM_TrainingParameters_FFC.Type;
TestParameters.DM_ClassLabels = DM_ClassLabels_FFC;

TestParameters.Dataset_FileName = get(Dataset_FFC_Name_TextBox,'String'); % The name of the employed Dataset
TestParameters.Dataset_ClassLabels = ClassLabels_FFC;

TestParameters.TestIdx = TestIdx;
TestParameters.Weighting_Method = Weighting_Method;

TestResults.Pc = Pc;
TestResults.ConfusionMatrix = ConfusionMatrix;
TestResults.TrueLabels = Dataset_FFC(TestIndex,end-1);
TestResults.PredictedLabels = PredictedLabel;
TestResults.Scores = Scores;

%% Show Test Results
Display_TestResults_FFC(TestParameters,TestResults);

%% Save Decision Machine
save(FullFileName,'TestParameters','TestResults','-v7.3');

%% Update GUI
GUI_TestResults_Update_FFC(Filename,TestParameters,TestResults);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');