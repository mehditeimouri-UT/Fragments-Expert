function ErrorMsg = Script_DecisionMachine_Train_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Train a decision machine using train/validation data
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
% 2020-Mar-03   function was created
% 2020-Oct-19   filename for saving the results is prompted before the process begins  
% 2021-Jan-03   DM_Feature_Transfrom_FFC was included

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC
global Function_Handles_FFC Function_Labels_FFC Function_Select_FFC
global Dataset_FFC_Name_TextBox
global Feature_Transfrom_FFC

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

%% Determine Decision Machine Type
DecisionModels = {'Decision Tree','SVM','Random Forest','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'};
[Selection,ok] = listdlg('Name','Decision Machines','PromptString','Select Decision Model',...
    'SelectionMode','single','ListSize',[200 300],'ListString',DecisionModels);
if ~ok
    ErrorMsg = 'Process is aborted. No decision model is selected.';
    return;
end
DecisionModel = DecisionModels{Selection};

%% Parameters
Param_Names = {'Weighting_Method','TVIndex','TV'};
Param_Description = {'Weighting Method (balanced or uniform)',...
    'Start and End of the Train/Validation in Dataset (1x2 vector with elements 0~1)',...
    'Train and Validation Percentages Taken from Dataset (1x2 vector with sum ==100, Train>=70, and for Decision Tree and Neural Network, Validation>=15)'};
Default_Value = {'balanced','[0 1]','[80 20]'};

switch DecisionModel
    case 'Decision Tree'
        Param_Names = [Param_Names 'MinLeafSize'];
        Param_Description = [Param_Description 'Minimum relative number of leaf node observations to total samples (1e-5~0.1)'];
        Default_Value = [Default_Value '0.001'];
        
    case 'SVM'
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'BoxConstraint'];
        Param_Description = [Param_Description 'Value for box constraint in SVM (>0)'];
        Default_Value = [Default_Value '1'];

        Param_Names = [Param_Names 'KernelFunction'];
        Param_Description = [Param_Description 'Kernel Function for SVM: rbf, linear, polynomial'];
        Default_Value = [Default_Value 'rbf'];

        Param_Names = [Param_Names 'PolynomialOrder'];
        Param_Description = [Param_Description 'Polynomial order for polynomial kernel function (1~7)'];
        Default_Value = [Default_Value '3'];
        
        Param_Names = [Param_Names 'KernelScale'];
        Param_Description = [Param_Description 'Value for scaling kernel of SVM (>0)'];
        Default_Value = [Default_Value '1'];
        
    case 'Random Forest'
        Param_Names = [Param_Names 'NumTrees'];
        Param_Description = [Param_Description 'Value for number of trees in random forest (2~1e4)'];
        Default_Value = [Default_Value '100'];
        
        Param_Names = [Param_Names 'MinLeafSize'];
        Param_Description = [Param_Description 'Value for minimum relative number of leaf node observations to total samples (1e-5~0.1)'];
        Default_Value = [Default_Value '0.0001'];
        
    case 'Ensemble kNN'        
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'NumFeatures'];
        Param_Description = [Param_Description sprintf('Number of random selected features for each kNN learner (<=%d)',length(FeatureLabels_FFC))];
        Default_Value = [Default_Value num2str(min(length(FeatureLabels_FFC),6))];
        
        Param_Names = [Param_Names 'NumLearners'];
        Param_Description = [Param_Description 'Number of kNN learners in ensemble (1~1e4)'];
        Default_Value = [Default_Value '50'];
        
        Param_Names = [Param_Names 'NumNeighbors'];
        Param_Description = [Param_Description 'Number of nearest neighbors for classifying each point (1~50)'];
        Default_Value = [Default_Value '5'];
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
    case 'Neural Network'
        Param_Names = [Param_Names 'feature_scaling_method'];
        Param_Description = [Param_Description 'The method of feature scaling: z-score, min-max, or no scaling'];
        Default_Value = [Default_Value 'z-score'];
        
        Param_Names = [Param_Names 'hiddenSize'];
        Param_Description = [Param_Description sprintf('Dimension of hidden layer (<=%d)',length(FeatureLabels_FFC))];
        Default_Value = [Default_Value num2str(length(FeatureLabels_FFC))];
        
end
dlg_title = sprintf('Parameters for Training %s',DecisionModel);
str_cmd = PromptforParameters_text_for_eval_FFC(Param_Names,Param_Description,Default_Value,dlg_title);
eval(str_cmd);

if ~success
    ErrorMsg = sprintf('Process is aborted. Parameters are not specified for training %s.',DecisionModel);
    return;
end

%% Check Parameters
[Err,ErrMsg] = Check_Variable_Value_FFC(Weighting_Method,'Weighting Method','possiblevalues',{'balanced','uniform'});
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(TV,'Train and Validation Percentages','type','vector','class','real','size',[1 2],'sum',100,'min',0);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(TV(1),'Train Percentage','type','scalar','class','real','min',70);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

if isequal(DecisionModel,'Decision Tree') || isequal(DecisionModel,'Neural Network')
    PartitionGenerateError = [true true];
    [Err,ErrMsg] = Check_Variable_Value_FFC(TV(2),sprintf('Validation Percentage for %s',DecisionModel),'type','scalar','class','real','min',15);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
else
    PartitionGenerateError = [true false];
end

[Err,ErrMsg] = Check_Variable_Value_FFC(TVIndex,'Start and End of the Train/Validation in Dataset','type','vector','class','real','size',[1 2],'min',0,'max',1,'issorted','ascend');
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

if isequal(exist('MinLeafSize','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(MinLeafSize,'Minimum relative number of leaf node observations to total samples','type','scalar','class','real','min',1e-5,'max',0.1);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('feature_scaling_method','var'),1)    
    [Err,ErrMsg] = Check_Variable_Value_FFC(feature_scaling_method,'The method of feature scaling','possiblevalues',{'z-score','min-max','no scaling'});
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('BoxConstraint','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(BoxConstraint,'Box constraint in SVM','type','scalar','class','real','min',eps);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('KernelFunction','var'),1)    
    [Err,ErrMsg] = Check_Variable_Value_FFC(KernelFunction,'The kernel function','possiblevalues',{'rbf','linear','polynomial'});
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('PolynomialOrder','var'),1)   
    [Err,ErrMsg] = Check_Variable_Value_FFC(PolynomialOrder,'The polynomial order for polynomial kernel function','type','scalar','class','real','class','integer','min',1,'max',7);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('KernelScale','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(KernelScale,'Kernel scale factor of SVM','type','scalar','class','real','min',eps);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('NumTrees','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(NumTrees,'Number of trees in random forest','type','scalar','class','real','class','integer','min',2,'max',1e4);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('NumFeatures','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(NumFeatures,'Number of random selected features for each kNN learner','type','scalar','class','real','class','integer','min',1,'max',length(FeatureLabels_FFC));
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('NumLearners','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(NumLearners,'Number of kNN learners in ensemble','type','scalar','class','real','class','integer','min',1,'max',1e4);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('NumNeighbors','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(NumNeighbors,'Number of nearest neighbors for classifying each point','type','scalar','class','real','class','integer','min',1,'max',50);
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

if isequal(exist('hiddenSize','var'),1)
    [Err,ErrMsg] = Check_Variable_Value_FFC(hiddenSize,'Dimension of hidden layer','type','scalar','class','real','class','integer','min',1,'max',length(FeatureLabels_FFC));
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
end

%% Get filename for saving the results
FullFileName = matlab.lang.makeValidName(DecisionModel);
if FullFileName(end)=='_'
    FullFileName(end) = [];
end
[Filename,path] = uiputfile('*.mat','Save Trained Decision Machine As',FullFileName);
FullFileName = [path Filename];
if isequal(Filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving the trained decision machine.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Select training and validation samples
% Note: First, training samples are taken and then, validation samples are taken.  
TV = TV/sum(TV);
[ErrorMsg,TIndex,VIndex] = Partition_Dataset_FFC(Dataset_FFC(:,end-1:end),ClassLabels_FFC,...
    {[TVIndex(1) TVIndex(1)+(TVIndex(2)-TVIndex(1))*TV(1)],...
    [TVIndex(1)+(TVIndex(2)-TVIndex(1))*TV(1) TVIndex(2)]},PartitionGenerateError);
if ~isempty(ErrorMsg)
    return;
end

%% Scaling Features
Dataset = Dataset_FFC;
switch DecisionModel
    case {'SVM','Ensemble kNN','Naive Bayes','Linear Discriminant Analysis (LDA)','Neural Network'}
        [Dataset([TIndex ; VIndex],:),Scaling_Parameters] = Scale_Features_FFC(Dataset_FFC([TIndex ; VIndex],:),feature_scaling_method);
        
    case {'Decision Tree','Random Forest'}
        

end

%% Assign Weights to Samples
Weights = Assign_Weights_FFC(Dataset_FFC(:,end-1),ClassLabels_FFC,Weighting_Method);

%% Build Decision Machine
switch DecisionModel
    case 'Decision Tree'
        
        progressbar_FFC('Training Decision Tree');
        [DM,DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train,stopbar] = Build_DecisionTree_FFC(Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex,VIndex,MinLeafSize,1);
        if stopbar
            ErrorMsg = 'Process is aborted by user.';
            return;
        end
        
    case 'SVM'
        
        progressbar_FFC('Training Multi-Class SVM');
        [DM,DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train,Pc_j,ConfusionMatrix_j,Pc_Train_j,ConfusionMatrix_Train_j,stopbar] = ...
            Build_MultiClassSVM_FFC(Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,Weighting_Method,TIndex,VIndex,KernelFunction,PolynomialOrder,BoxConstraint,KernelScale,1);
        if stopbar
            ErrorMsg = 'Process is aborted by user.';
            return;
        end
        
    case 'Random Forest'
        
        progressbar_FFC('Training Random Forest');
        MinPrg = 10; % Minimum steps (number of added trees) in progess indication
        CntPrg = 0;
        DM_CL = [];
        DM = [];
        for i=1:ceil(NumTrees/MinPrg)
            
            NumTrees_i = min(MinPrg,NumTrees-CntPrg);
            [DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = ...
                Build_RandomForest_FFC(DM_CL,Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex,VIndex,NumTrees_i,MinLeafSize);
            
            % progress indication
            CntPrg = CntPrg+MinPrg;
            stopbar = progressbar_FFC(1,min(CntPrg/NumTrees,1));
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
        end
    case 'Ensemble kNN'
        
        progressbar_FFC('Training Ensemble kNN');
        MinPrg = 10; % Minimum steps (number of added kNNs) in progess indication
        CntPrg = 0;
        DM_CL = [];
        DM = [];
        for i=1:ceil(NumLearners/MinPrg)
            
            NumLearners_i = min(MinPrg,NumLearners-CntPrg);
            [DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_EnsemblekNN_FFC(DM_CL,Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex,VIndex,...
                NumLearners_i,NumFeatures,NumNeighbors);            
            
            % progress indication
            CntPrg = CntPrg+MinPrg;
            stopbar = progressbar_FFC(1,min(CntPrg/NumLearners,1));
            if stopbar
                ErrorMsg = 'Process is aborted by user.';
                return;
            end
        end
        
    case 'Naive Bayes'
        
        [DM,DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_NaiveBayes_FFC(Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex,VIndex);
        
    case 'Linear Discriminant Analysis (LDA)'
        
        DM = [];
        [DM_CL,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_LDA_FFC(Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex,VIndex);
        
    case 'Neural Network'
        DM_CL = [];
        [DM,Pc,ConfusionMatrix,Pc_Train,ConfusionMatrix_Train] = Build_PatternRecognitionNeuralNetwork_FFC(Dataset,ClassLabels_FFC,FeatureLabels_FFC,Weights,TIndex',VIndex',hiddenSize);
        
end

%% Set Variables for Training Parameters and Results
DecisionMachine = DM;
DecisionMachine_CL = DM_CL;
FeatureLabels = FeatureLabels_FFC;
ClassLabels = ClassLabels_FFC;

TrainingParameters.Type = DecisionModel;
TrainingParameters.DatasetName = get(Dataset_FFC_Name_TextBox,'String'); % The name of the employed Dataset
TrainingParameters.Weighting_Method = Weighting_Method;
TrainingParameters.TVIndex = TVIndex;
TrainingParameters.TV = TV;

TrainingResults.Pc_Train = Pc_Train;
TrainingResults.ConfusionMatrix_Train = ConfusionMatrix_Train;
TrainingResults.Pc = Pc;
TrainingResults.ConfusionMatrix = ConfusionMatrix;

switch DecisionModel
    case 'Decision Tree'
        TrainingParameters.MinLeafSize = MinLeafSize;
        
    case 'SVM'
        TrainingParameters.Scaling_Parameters = Scaling_Parameters;
        TrainingParameters.KernelFunction = KernelFunction;
        TrainingParameters.PolynomialOrder = PolynomialOrder;
        TrainingParameters.feature_scaling_method = feature_scaling_method;
        TrainingParameters.BoxConstraint = BoxConstraint;
        TrainingParameters.KernelScale = KernelScale;

        TrainingResults.Pc_j = Pc_j;
        TrainingResults.ConfusionMatrix_j = ConfusionMatrix_j;
        
        TrainingResults.Pc_Train_j = Pc_Train_j;
        TrainingResults.ConfusionMatrix_Train_j = ConfusionMatrix_Train_j;

    case 'Random Forest'
        TrainingParameters.MinLeafSize = MinLeafSize;
        TrainingParameters.NumTrees = NumTrees;
        
    case 'Ensemble kNN'
        TrainingParameters.Scaling_Parameters = Scaling_Parameters;
        TrainingParameters.feature_scaling_method = feature_scaling_method;
        TrainingParameters.NumFeatures = NumFeatures;
        TrainingParameters.NumLearners = NumLearners;
        TrainingParameters.NumNeighbors = NumNeighbors;
        
    case {'Naive Bayes','Linear Discriminant Analysis (LDA)'}
        TrainingParameters.feature_scaling_method = feature_scaling_method;
        TrainingParameters.Scaling_Parameters = Scaling_Parameters;
        
    case 'Neural Network'
        TrainingParameters.Scaling_Parameters = Scaling_Parameters;
        TrainingParameters.feature_scaling_method = feature_scaling_method;
        TrainingParameters.hiddenSize = hiddenSize;
        
end

%% Show Decision Machine Results
Display_DecisionMachine_FFC(TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,ClassLabels)

%% Save Decision Machine
Function_Handles = Function_Handles_FFC;
Function_Labels = Function_Labels_FFC;
Function_Select = Function_Select_FFC;
Feature_Transfrom = Feature_Transfrom_FFC;
save(FullFileName,'TrainingParameters','TrainingResults','DecisionMachine','DecisionMachine_CL','ClassLabels','FeatureLabels',...
    'Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_DecisionMachine_Update_FFC(Filename,TrainingParameters,TrainingResults,DecisionMachine,DecisionMachine_CL,FeatureLabels,ClassLabels,...
    Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');