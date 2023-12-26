function ErrorMsg = Script_Parallel_GenerateDataset_from_FragmentDataset_FFC

% This function takes some data set files in generic binary data format and does the following using parallel processing capability:
%   (1) Reads the fragments
%
%   Note: The employed binary file format is a generic binary data format with *.dat extension.
%   The information about fragments are written consecutively as folows:
%       8 bytes for file ID written in ieee big-endian uint64 format
%       8 bytes for fragment ID written in ieee big-endian uint64 format
%       8 bytes for fragment length L (in bytes) written in ieee big-endian uint64 format
%       L bytes for fragment contents fileID written in ieee big-endian uint8 format
%
%   (2) Generates CSV Dataset of extracted features that includes
%           Dataset: Dataset with TotalFragments rows (TotalFragments samples corresponding to TotalFragments fragments)
%               and C columns. The first F = C-2 columns correspond to features.
%               The last two columns correspond to the integer-valued class labels
%               and the FileID of the fragments, respectively.
%           Note: Dataset rows are sorted as follows: First, the samples of
%           class 1 appear. Second, the the samples of class 2 appear, and
%           so on. Also for the samples of each class, the fragments
%           of a signle multimedia file appear consecutively.
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
% 2023-Dec-23   function was created

%% Initialization
global C_MEX_64_Available
try
    C_MEX_64_Available = true;
    LCSSeq2_FFC(randi([0 255],[1 1024]),{randi([0 255],[1 1024])});
catch
    ErrorMsg = '64-bit C-MEX functions does not work. So, parallel processing cannot be used';
    return;
end

%% Define Mode
button = questdlg('Do you want to use previously saved features extraction functions?',...
    'Determine Dataset Generation Mode','Yes','No','No');
switch button
    
    case 'Yes'
        ReadyFunctions = true;
        
    case 'No'
        ReadyFunctions = false;
        
    otherwise
        ErrorMsg = 'Dataset generation mode was not selected by user. The process is aborted.';
        return;
        
end

if ~ReadyFunctions
    
    %% Select Feature Types
    FeatureTypes = {'Byte Frequency Distribution (BFD)',...
        'Rate of Change',...
        'Longest Contiguous Streak of Repeating Bytes',...
        'n-grams',...
        'Byte Concentration Features: Low, Ascii, and High',...
        'Basic Lower-Order Statistics: Mean, STD, Mode, Median, and Mad',...
        'Higher-Order Statistics: Kurtosis and Skewness',...
        'Bicoherence',...
        'Window-Based Statistics',...
        'Auto-Correlation',...
        'Frequency Domain Statistics (Mean, STD, Skewness)',...
        'Binary Ratio',...
        'Entropy',...
        'Video Patterns',...
        'Audio Patterns',...
        'Longest Common Subsequence',...
        'Longest Common Substring',...
        'Centroid Models',...
        'Kolmogorov Complexity',...
        'GIST Features',...
        'False Nearest Neighbors',...
        'Lyapunov Exponents',...
        };
    
    [FeatureTypesSelect,ok] = listdlg('Name','Feature Types','PromptString','Select feature types to be included:',...
        'ListSize',[350 330],'SelectionMode','multiple','ListString',FeatureTypes);
    
    if ~ok
        ErrorMsg = 'Process is aborted. No feature was selected.';
        return;
    end
    
    FeatureTypes = FeatureTypes(FeatureTypesSelect);
    
    
    %% Get Necessary Parameters for Feature Calculation
    Param_Names = {};
    Param_Description = {};
    Default_Value = {};
    
    % Define default parameter for n-gram
    if any(strcmp(FeatureTypes,'n-grams'))
        Param_Names = [Param_Names 'ns'];
        Param_Description = [Param_Description 'n values for n-gram (<=13)'];
        Default_Value = [Default_Value '[10]'];
    end
    
    % Define default parameter for Window-Based Statistics
    if any(strcmp(FeatureTypes,'Window-Based Statistics'))
        Param_Names = [Param_Names 'windowSize'];
        Param_Description = [Param_Description 'Window size for window-based statistics (<=256)'];
        Default_Value = [Default_Value '256'];
    end
    
    % Define default parameter for Frequency Domain Statistics (Mean, STD, Skewness)
    if any(strcmp(FeatureTypes,'Frequency Domain Statistics (Mean, STD, Skewness)'))
        Param_Names = [Param_Names 'N_Subbands'];
        Param_Description = [Param_Description 'Number of sub-bands for frequency domain statistics (<=8)'];
        Default_Value = [Default_Value '4'];
    end
    
    % Define default parameter for Auto-Correlation
    if any(strcmp(FeatureTypes,'Auto-Correlation'))
        Param_Names = [Param_Names 'lag'];
        Param_Description = [Param_Description 'Maximum lag value for auto-correlation (<=50)'];
        Default_Value = [Default_Value '5'];
    end
    
    % Define default parameters for False Nearest Neighbors
    if any(strcmp(FeatureTypes,'False Nearest Neighbors'))
        Param_Names = [Param_Names 'rt_minemb_maxemb'];
        Param_Description = [Param_Description 'False Nearest Neighbors Parameters: Ratio Factor (>=0.1), and minimum (>=1) and maximum (<=50) embedding dimensions'];
        Default_Value = [Default_Value '[2.0 3 7]'];
    end
    
    % Define default parameters for Lyapunov Exponents
    if any(strcmp(FeatureTypes,'Lyapunov Exponents'))
        Param_Names = [Param_Names 'mindim_maxdim'];
        Param_Description = [Param_Description 'Lyapunov Exponents Parameters: Minimum (>=2) and maximum (<=50) embedding dimensions'];
        Default_Value = [Default_Value '[2 5]'];
    end
    
    % Define default parameters for GIST Features
    if any(strcmp(FeatureTypes,'GIST Features'))
        Param_Names = [Param_Names 'GIST_Prms'];
        Param_Description = [Param_Description 'GIST Parameters: Image row size (>=16 and <=256), non-overlapping windows in each dimension(>=2 and <=32), and Number of orientations at each scale (a vector of integers with >=2 and <=8 values)'];
        Default_Value = [Default_Value '[32 4 4 4 4 4]'];
    end
    
    % Write specific command using PromptforParameters_FFC to get parameters
    if ~isempty(Param_Names)
        dlg_title = 'Parameters for feature extraction functions';
        str_cmd = PromptforParameters_text_for_eval_FFC(Param_Names,Param_Description,Default_Value,dlg_title);
        eval(str_cmd);
    end
    
    %% Check Parameters for Feature Calculation
    % Check parameter for n-gram
    if any(strcmp(FeatureTypes,'n-grams'))
        [Err,ErrMsg] = Check_Variable_Value_FFC(ns,'n value for n-gram','type','vector','class','real','class','integer','min',1,'max',13);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    % Check parameter for Window-Based Statistics
    if any(strcmp(FeatureTypes,'Window-Based Statistics'))
        [Err,ErrMsg] = Check_Variable_Value_FFC(windowSize,'Window size for window-based statistics','type','scalar','class','real','class','integer','min',2,'max',256);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    % Check parameter for for Frequency Domain Statistics (Mean, STD, Skewness)
    if any(strcmp(FeatureTypes,'Frequency Domain Statistics (Mean, STD, Skewness)'))
        [Err,ErrMsg] = Check_Variable_Value_FFC(N_Subbands,'Number of sub-bands for frequency domain statistics','type','scalar','class','real','class','integer','min',1,'max',8);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    % Check parameter for Auto-Correlation
    if any(strcmp(FeatureTypes,'Auto-Correlation'))
        [Err,ErrMsg] = Check_Variable_Value_FFC(lag,'Maximum lag value for auto-correlation','type','scalar','class','real','class','integer','min',1,'max',50);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    % Check parameters for False Nearest Neighbors
    if any(strcmp(FeatureTypes,'False Nearest Neighbors'))
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(rt_minemb_maxemb,'False Nearest Neighbors parameters','size',[1 3]);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        rt = rt_minemb_maxemb(1);
        minemb = rt_minemb_maxemb(2);
        maxemb = rt_minemb_maxemb(3);
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(rt,'Ratio Factor for False Nearest Neighbors','type','scalar','class','real','min',0.1);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(minemb,'Minimum embedding dimension for False Nearest Neighbors','type','scalar','class','real','class','integer','min',1,'max',50);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(maxemb,'Maximum embedding dimension for False Nearest Neighbors','type','scalar','class','real','class','integer','min',minemb,'max',50);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    % Check parameters for Lyapunov Exponents
    if any(strcmp(FeatureTypes,'Lyapunov Exponents'))
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(mindim_maxdim,'Lyapunov Exponents parameters','size',[1 2]);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        mindim = mindim_maxdim(1);
        maxdim = mindim_maxdim(2);
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(mindim,'Minimum embedding dimension for Lyapunov Exponents','type','scalar','class','real','class','integer','min',2,'max',50);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(maxdim,'Maximum embedding dimension for Lyapunov Exponents','type','scalar','class','real','class','integer','min',mindim,'max',50);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
    end
    
    % Check parameters for GIST Features
    if any(strcmp(FeatureTypes,'GIST Features'))
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(GIST_Prms,'GIST Features parameters','minsize',[1 3]);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        rowsize = GIST_Prms(1);
        numBlks = GIST_Prms(2);
        orientPerScale = GIST_Prms(3:end);
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(rowsize,'Image row size for GIST Features','type','scalar','class','real','class','integer','min',16,'max',256);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(numBlks,'Non-overlapping windows in each dimension for GIST Features','type','scalar','class','real','class','integer','min',2,'max',32);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(orientPerScale,'Number of orientations at each scale for GIST Features','class','real','class','integer','min',2,'max',8);
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
    end
    
    %% Define Features Extraction Functions
    NumFeatExtFunc = 0; % Number of features extraction functions
    
    % Initialization
    f_handles = cell(1,NumFeatExtFunc);
    f_OutputLabels = cell(1,NumFeatExtFunc);
    pointer = 0;
    
    % Define functions and their outputs
    if any(strcmp(FeatureTypes,'Byte Frequency Distribution (BFD)'))
        pointer = pointer+1;
        Range = num2cell(0:255);
        f_handles{pointer} = @(x) BFD_Parallel_FFC(x,Range); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,256+4); % Lables for Features
        for i=0:255
            f_OutputLabels{pointer}{i+1} = sprintf('BFD_%d',i);
        end
        f_OutputLabels{pointer}{256+1} = 'SdFreq';
        f_OutputLabels{pointer}{256+2} = 'ModesFreq';
        f_OutputLabels{pointer}{256+3} = 'CorNextFreq';
        f_OutputLabels{pointer}{256+4} = 'ChiSq';
    end
    
    if any(strcmp(FeatureTypes,'Byte Bigrams'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Byte_Bigram_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,65536); % Lables for Features
        for i=0:65535
            f_OutputLabels{pointer}{i+1} = sprintf('ByteBigram_%d',i);
        end
    end
    
    if any(strcmp(FeatureTypes,'Rate of Change'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) RoC_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,257); % Lables for Features
        for i=0:255
            f_OutputLabels{pointer}{i+1} = sprintf('RoC_%d',i);
        end
        f_OutputLabels{pointer}{257} = 'MeanRoC';
    end
    
    if any(strcmp(FeatureTypes,'Longest Contiguous Streak of Repeating Bytes'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) LongestContiguous_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'LongestContiguous'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'n-grams'))
        for j=1:length(ns)
            pointer = pointer+1;
            n = ns(j);
            f_handles{pointer} = @(x)  BitNgram_Parallel_FFC(x,n); % Function of feature extraction
            f_OutputLabels{pointer} = cell(1,2^n); % Lables for Features
            for i=0:(2^n-1)
                f_OutputLabels{pointer}{i+1} = sprintf('Ngram%d_%d',n,i);
            end
        end
    end
    
    if any(strcmp(FeatureTypes,'Byte Concentration Features: Low, Ascii, and High'))
        pointer = pointer+1;
        Range = {[0 31] , [32 127] , [192 255]};
        f_handles{pointer} = @(x) BFD_Parallel_FFC(x,Range); % Function of feature extraction
        f_OutputLabels{pointer} = {'Low' , 'Ascii' , 'High'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Basic Lower-Order Statistics: Mean, STD, Mode, Median, and Mad'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Mean_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'ArithmeticMean','GeometricMean','HarmonicMean'}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) StandardDeviation_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'STD'}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) Mode_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Mode'}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) Median_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Median'}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) Mad_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Mad'}; % Lables for Features
        
    end
    
    if any(strcmp(FeatureTypes,'Higher-Order Statistics: Kurtosis and Skewness'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Kurtosis_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Kurtosis'}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) Skewness_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Skewness'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Bicoherence'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Bicoherence_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Bicoh'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Frequency Domain Statistics (Mean, STD, Skewness)'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) FrequencyDomainStatistics_Parallel_FFC(x,N_Subbands); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,N_Subbands*3); % Lables for Features
        tmp_feature_names = {'Mean','STD','Skewness'};
        tmp_cnt = 0;
        for j=1:3
            for i=1:N_Subbands
                tmp_cnt = tmp_cnt+1;
                f_OutputLabels{pointer}{tmp_cnt} = sprintf('%s_f_%d_%d',tmp_feature_names{j},N_Subbands,i);
            end
        end
    end
    
    if any(strcmp(FeatureTypes,'Auto-Correlation'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Autocorrelation_Parallel_FFC(x,lag); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,lag); % Lables for Features
        for i=1:lag
            f_OutputLabels{pointer}{i} = sprintf('R%d',i);
        end
    end
    
    if any(strcmp(FeatureTypes,'Window-Based Statistics'))
        pointer = pointer+1;
        windowSize = 256;
        f_handles{pointer} = @(x) DeviationFromSTD_Parallel_FFC(x,windowSize); % Function of feature extraction
        f_OutputLabels{pointer} = {sprintf('DeviationFromSTD_%d',windowSize)}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) MovingAverage_Parallel_FFC(x,windowSize); % Function of feature extraction
        f_OutputLabels{pointer} = {sprintf('DeltaMovingAverage_%d',windowSize),sprintf('Delta2MovingAverage_%d',windowSize)}; % Lables for Features
        
        pointer = pointer+1;
        f_handles{pointer} = @(x) DeltaSTD_Parallel_FFC(x,windowSize); % Function of feature extraction
        f_OutputLabels{pointer} = {sprintf('DeltaSTD_%d',windowSize),sprintf('Delta2STD_%d',windowSize)}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Binary Ratio'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) BinaryRatio_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'BinaryRatio'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Entropy'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Entropy_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'Entropy','d_Entropy'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Video Patterns'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) VideoPatterns_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'MKV1_Pattern', 'MKV2_Pattern', 'AVI1_Pattern', 'AVI2_Pattern', 'RMVB1_Pattern', 'RMVB2_Pattern', 'OGV_Pattern', ...
            'MP4_1_Pattern', 'MP4_2_Pattern', 'MP4_3_Pattern', 'MP4_4_Pattern', 'MP4_5_Pattern', 'MP4_6_Pattern', 'MP4_7_Pattern', 'MP4_8_Pattern',...
            'MP4_9_Pattern', 'MP4_10_Pattern'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Audio Patterns'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) AudioPatterns_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'MP3_Sync','FLAC_Sync'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'Kolmogorov Complexity'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) kolmogorov_Parallel_FFC(x); % Function of feature extraction
        f_OutputLabels{pointer} = {'KolmogrovComplexity'}; % Lables for Features
    end
    
    if any(strcmp(FeatureTypes,'False Nearest Neighbors'))
        rt_str = sprintf('%g',rt);
        rt_str(rt_str=='.') = '_';
        %false_nearest_caller_FFC(randi([0 255],[1 1024]),minemb,maxemb,rt);
        pointer = pointer+1;
        f_handles{pointer} = @(x) false_nearest_caller_Parallel_FFC(x,minemb,maxemb,rt); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,3*(maxemb-minemb+1)); % Lables for Features
        ij = 0;
        for i=minemb:maxemb
            for j=1:3
                ij = ij+1;
                switch j
                    case 1
                        f_OutputLabels{pointer}{ij} = sprintf('FNF_%s_%d',rt_str,i);
                    case 2
                        f_OutputLabels{pointer}{ij} = sprintf('av_eps_%s_%d',rt_str,i);
                    case 3
                        f_OutputLabels{pointer}{ij} = sprintf('rms_eps_%s_%d',rt_str,i);
                end
            end
        end
    end
    
    if any(strcmp(FeatureTypes,'Lyapunov Exponents'))
        %lyap_exp_k_FFC(randi([0 255],[1 1024]),mindim,maxdim);
        pointer = pointer+1;
        f_handles{pointer} = @(x) lyap_exp_k_Parallel_FFC(x,mindim,maxdim); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,maxdim-mindim+1); % Lables for Features
        j = 0;
        for i=mindim:maxdim
            j = j+1;
            f_OutputLabels{pointer}{j} = sprintf('Lambda_%d',i);
        end
    end
    
    if any(strcmp(FeatureTypes,'GIST Features'))
        pointer = pointer+1;
        f_handles{pointer} = @(x) Grayscale_GIST_Parallel_FFC(x,rowsize,orientPerScale,numBlks); % Function of feature extraction
        f_OutputLabels{pointer} = cell(1,sum(orientPerScale)*numBlks^2); % Lables for Features
        GIST_str = num2str(orientPerScale);
        GIST_str(GIST_str==' ') = '_';
        ijk=0;
        for i = 1:length(orientPerScale)
            for j=1:orientPerScale(i)
                for k=1:numBlks^2
                    ijk = ijk+1;
                    f_OutputLabels{pointer}{ijk} = sprintf('GIST_%d_%d_%s_Scale_%d_Orient_%d_%d',rowsize,numBlks,GIST_str,i,j,k);
                end
            end
        end
    end
    
    NumFeatExtFunc = pointer;
    
else
        
    [FileName,PathName] = uigetfile('*.mat','Select Saved Function Handles','MultiSelect', 'off');
    if isequal(FileName,0)
        ErrorMsg = 'Process is aborted. No Saved Function Handles was selected.';
        return;
    end
    
    
    try
        matObj = matfile([PathName FileName]);
        f_handles = matObj.Function_Handles;
        NumFeatExtFunc = length(f_handles);
        f_OutputLabels = matObj.Function_Labels;
    catch
        ErrorMsg = 'Process is aborted. The selected file does not contain proper Function Handles.';
        return;
    end
    TotalReps = 0;
    
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Get the name of the binary files for reading fragments
[FileName,PathName] = uigetfile('*.dat','Select Datasets in Generic Binary File Format','MultiSelect', 'on');
if isequal(FileName,0)
    ErrorMsg = 'Process is aborted. No Datasets in Generic Binary File Format was selected.';
    return;
end

if ischar(FileName)
    FileName = {FileName};
end

%% Obtain the total number of fragments
[ClassLabels,ClassMembersNumber,ClassFilesNumber,FileEmpty,ErrorMsg] = Count_Fragments_Per_Class(PathName,FileName,'Initial processing ...');
if ~isempty(ErrorMsg)
    return;
end
TotalFragments = sum(ClassMembersNumber);
[FileID_FragmentsNo,ErrorMsg] = Count_Fragments_Per_FileID(PathName,FileName,ClassFilesNumber,'Counting Fragments in Each File ID ...');
if ~isempty(ErrorMsg)
    return;
end

%% Determine Number of Classes
FileName(FileEmpty) = [];
ClassMembersNumber(FileEmpty) = [];
ClassFilesNumber(FileEmpty) = [];
ClassLabels = ClassLabels(~FileEmpty);
FileID_FragmentsNo(FileEmpty) = [];

%% Set valid variable names for class labels
ClassLabels = SetVariableNames_FFC(ClassLabels);

ReadFlg = cell(1,length(FileID_FragmentsNo));
for j=1:length(FileID_FragmentsNo)
    ReadFlg{j} = true(size(FileID_FragmentsNo{j},1),1);
end

if ~ReadyFunctions
    
    %% Random Permutation of File IDs
    prm = cell(size(FileID_FragmentsNo));
    for i=1:length(FileID_FragmentsNo)
        prm{i} = randperm(size(FileID_FragmentsNo{i},1));
    end
    
    %% Select Representatives
    PossibleClassofReps = {'Longest Common Subsequence','Longest Common Substring','Centroid Models'};
    ClassofReps = intersect(FeatureTypes,PossibleClassofReps);
    
    ClassLabelsSelect = cell(1,length(ClassofReps));
    NumReps = cell(1,length(ClassofReps));
    NumRepsFileIDs = cell(1,length(ClassofReps));
    
    % Repeat process for each class of Representatives
    TotalFrg = zeros(1,length(FileID_FragmentsNo));
    for i=1:length(ClassofReps)
        
        % Choose Classes
        [ClassLabelsSelect{i},ok] = listdlg('Name',sprintf('Representatives for %s',ClassofReps{i}),...
            'PromptString','Select Classes to be included:',...
            'ListSize',[500 400],'SelectionMode','multiple','ListString',ClassLabels);
        
        if ~ok
            ErrorMsg = 'Process is aborted. No class was selected as representative.';
            return;
        end
        
        % Get Parameters for Selecting Representatives
        NumReps{i} = 10; % Number of Representatives for Each Class
        NumRepsFileIDs{i} = 5; % Number of minimum FileIDs for Representatives of Each Class
        [success,NumReps{i},NumRepsFileIDs{i},] = PromptforParameters_FFC(...
            {'Number of Representatives for Each Class (10~100, and less than <10% of class members)',...
            'Number of FileIDs for Representatives of Each Class (5~NumberofRepresentatives)'},...
            {num2str(NumReps{i}),num2str(NumRepsFileIDs{i})},sprintf('Parameters for selecting representatives of %s',ClassofReps{i}));
        
        if ~success
            ErrorMsg = 'Process is aborted. Representatives selection parameters are not specified.';
            return;
        end
        
        % Check Parameters
        [Err,ErrMsg] = Check_Variable_Value_FFC(NumReps{i},'Number of Representatives','type','scalar','class','real','class','integer',...
            'min',10,'max',min(0.1*min(ClassMembersNumber(ClassLabelsSelect{i})),100));
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        [Err,ErrMsg] = Check_Variable_Value_FFC(NumRepsFileIDs{i},'Number of FileIDs for Representatives of Each Class','type','scalar','class','real','class','integer',...
            'min',5,'max',min(NumReps{i},min(ClassFilesNumber(ClassLabelsSelect{i}))));
        if Err
            ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
            return;
        end
        
        % Read Representatives
        Fragments = cell(1,length(ClassLabelsSelect{i}));
        for j=1:length(ClassLabelsSelect{i})
            
            j0 = ClassLabelsSelect{i}(j);
            aux = FileID_FragmentsNo{j0}(prm{j0},:);
            aux(:,1) = 1;
            idx = find(cumsum(aux(:,1))>=NumRepsFileIDs{i} & cumsum(aux(:,2))>=NumReps{i},1,'first');
            if isempty(idx) || idx>0.1*size(aux,1)
                ErrorMsg = 'Process is aborted. Number of requested representatives needs more than 10% of Total fileIDs';
                return;
            end
            readflg = prm{j0}(1:idx);
            totalfrg = sum(aux(1:idx,2));
            Fragments{j} = ReadRepresentatives(PathName,FileName{j0},readflg,totalfrg);
            Fragments{j} = Fragments{j}(randperm(length(Fragments{j})));
            TotalFrg(j0) = max(TotalFrg(j0),totalfrg);
            ReadFlg{j0}(readflg) = false;
        end
        
        % Add Representatives-Related Fature Extraction Functions
        pointer = length(f_handles);
        switch ClassofReps{i}
            case 'Longest Common Subsequence'
                
                for j=1:length(ClassLabelsSelect{i})
                    pointer = pointer+1;
                    RepsFrgs = Fragments{j}(1:NumReps{i});
                    f_handles{pointer} = @(x) LCSSeq2_Parallel_FFC(x,RepsFrgs); % Function of feature extraction
                    f_OutputLabels{pointer} = {sprintf('LCS_Seq_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features
                end
                
            case 'Longest Common Substring'
                
                for j=1:length(ClassLabelsSelect{i})
                    pointer = pointer+1;
                    RepsFrgs = Fragments{j}(1:NumReps{i});
                    f_OutputLabels{pointer} = {sprintf('LCS_Str_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features
                    f_handles{pointer} = @(x) LCSStr2_Parallel_FFC(x,RepsFrgs); % Function of feature extraction
                end
                
            case 'Centroid Models'
                
                for j=1:length(ClassLabelsSelect{i})
                    
                    % Build Centroid Model
                    RepsFrgs = Fragments{j}(1:NumReps{i});
                    Centroid = zeros(length(RepsFrgs),256);
                    for k=1:length(RepsFrgs) % Usually, it does not need parallelization
                        output = BFD_FFC(RepsFrgs{k},num2cell(0:255));
                        Centroid(k,:) = output(1:256);
                    end
                    centroid_mu = mean(Centroid,1);
                    centroid_sigma = std(Centroid,0,1);
                    
                    pointer = pointer+1;
                    f_handles{pointer} = @(x) Compare_with_Centroid_Parallel_FFC(x,centroid_mu,centroid_sigma); % Function of feature extraction
                    f_OutputLabels{pointer} = {sprintf('CosineSimilarity_%s',ClassLabels{ClassLabelsSelect{i}(j)}) ...
                        sprintf('MahalanobisDistance_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features
                end
                
        end
        NumFeatExtFunc = pointer;
    end
    TotalReps = sum(TotalFrg);
    
end

%% Get the name of the file for saving dataset
[filename,path] = uiputfile('mydataset.csv','Save Generated Dataset');
if isequal(filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end
dataset_filename = [path filename];

%% Get the name of the file for saving function handles
[filename,path] = uiputfile('myFunctionHandles.mat','Save Selected Function Handles');
if isequal(filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving function handles.';
    return;
end
FunctionHandles_filename = [path filename];


%% Determine Number of Features
F_idx = zeros(1,NumFeatExtFunc+1);
for pointer=1:NumFeatExtFunc
    F_idx(pointer+1) = F_idx(pointer)+length(f_OutputLabels{pointer});
end

FeatureLabels = cell(1,F_idx(end));
for pointer=1:NumFeatExtFunc
    FeatureLabels(F_idx(pointer)+1:F_idx(pointer+1)) = f_OutputLabels{pointer};
end

if NumFeatExtFunc==0
    ErrorMsg = 'Process is aborted. The number of features is equal to zero.';
    return;
end

%% Generate Dataset

fid = fopen(dataset_filename,'w');
fprintf(fid,'This Dataset is Generated by Fragments-Expert. \n');
fprintf(fid,'---------------------------------------------- \n');
fprintf(fid,'The values in each row are: \n');
for i=1:length(FeatureLabels)
    fprintf(fid,'%s,',FeatureLabels{i});
end
fprintf(fid,'Class Label (1,2,...), file identifier of the fragment\n');
fprintf(fid,'---------------------------------------------- \n');
fprintf(fid,'Class Label values are assigned as follows\n');
for i=1:length(ClassLabels)
    fprintf(fid,'%d: %s\n',i,ClassLabels{i});
end
fprintf(fid,'---------------------------------------------- \n');
fclose(fid);

TotalFragments = TotalFragments-TotalReps;

N = 10000; % Parfor Parameter
Fragments = cell(1,N);
parfor_buffer_counter = 0;
Dataset = zeros(N,sum(cellfun(@length,f_OutputLabels))+2);
ParforFileIdentifier = zeros(N,1);
counter = 0;

progressbar_FFC('Calculating features, this might take a while ...');
NumFiles = length(FileName);
for j=1:NumFiles
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID);
    
    % Read file fragments
    pointer = 0;
    FileNumbers = 0;
    Curr_File = -1;
    while ~feof(fileID) && FileLength>0
        
        % Read fields
        aux = fread(fileID,1,'uint64=>double',0,'b'); % Read File ID
        fseek(fileID,1*8,'cof');
        if Curr_File~=aux
            Curr_File = aux;
            FileNumbers = FileNumbers+1;
        end
        
        L0 = fread(fileID,1,'uint64=>double',0,'b');
        if ReadFlg{j}(FileNumbers)
            parfor_buffer_counter = parfor_buffer_counter+1;
            Fragments{parfor_buffer_counter} = fread(fileID,L0,'uint8=>double',0,'b')';
            ParforFileIdentifier(parfor_buffer_counter) = Curr_File;
        else
            fseek(fileID,L0,'cof');
        end
        pointer = pointer+3*8+L0;
        
        if parfor_buffer_counter<N && pointer<FileLength
            continue;
        end
        
        % Calculate feature
        F1 = 0;
        for cnt=1:NumFeatExtFunc
            F2 = F1+length(f_OutputLabels{cnt});
            Dataset_Partition = f_handles{cnt}(Fragments(1:parfor_buffer_counter));
            Dataset(1:parfor_buffer_counter,F1+1:F2) = Dataset_Partition(1:parfor_buffer_counter,:);
            F1 = F2;
        end
        Dataset(1:parfor_buffer_counter,end-1) = j;
        Dataset(1:parfor_buffer_counter,end) = ParforFileIdentifier(1:parfor_buffer_counter);
        
        % Update Dataset
        dlmwrite(dataset_filename,Dataset(1:parfor_buffer_counter,:),'-append');
        counter = counter+parfor_buffer_counter;
        parfor_buffer_counter = 0;
        
        stopbar = progressbar_FFC(1,counter/TotalFragments);
        if stopbar
            ErrorMsg = sprintf('Process is aborted by user.');
            return;
        end
        
        % Break loop
        if pointer>=FileLength
            break;
        end
    end
    
    % Close file
    fclose(fileID);
    
end

%% Save Dataset Generation Parameters
if ~ReadyFunctions
    
    Function_Handles = f_handles;
    Function_Labels = f_OutputLabels;
    save(FunctionHandles_filename,'Function_Handles','Function_Labels','-v7.3');
    
end

%% Update GUI
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');

function [ClassLabels,ClassMembersNumber,ClassFilesNumber,FileEmpty,ErrorMsg] = Count_Fragments_Per_Class(PathName,FileName,prg_txt)

% This function gets some *.dat files and counts the number of fragments in each class.

NumFiles = length(FileName);
ClassMembersNumber = zeros(1,NumFiles);
ClassFilesNumber = zeros(1,NumFiles);
ClassLabels = cell(1,NumFiles);
ErrorMsg = '';
FileEmpty = false(1,NumFiles);
progressbar_FFC(prg_txt);
for j=1:NumFiles
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
    
    % Defualt Class Label
    str = FileName{j};
    str(strfind(lower(str), '.dat'):end) = [];
    ClassLabels{j} = str;
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID);
    if FileLength==0
        FileEmpty(j) = true;
    end
    
    % Read file fragments
    cnt = 0;
    NumFrgs = 0;
    FileNumbers = 0;
    Curr_File = -1;
    while ~feof(fileID) && FileLength>0
        
        % Read fields
        aux = fread(fileID,1,'uint64=>double',0,'b'); % Read File ID
        fseek(fileID,1*8,'cof');
        if Curr_File~=aux
            Curr_File = aux;
            FileNumbers = FileNumbers+1;
        end
        
        L0 = fread(fileID,1,'uint64=>double',0,'b');
        fseek(fileID,L0,'cof');
        cnt = cnt+3*8+L0;
        NumFrgs = NumFrgs+1;
        
        % Break loop
        if cnt>=FileLength
            break;
        end
    end
    
    % Close file
    fclose(fileID);
    
    ClassMembersNumber(j) = NumFrgs;
    ClassFilesNumber(j) = FileNumbers;
    
    stopbar = progressbar_FFC(1,j/NumFiles);
    if stopbar
        ErrorMsg = sprintf('Process is aborted by user.');
        return;
    end
    
end

function [FileID_FragmentsNo,ErrorMsg] = Count_Fragments_Per_FileID(PathName,FileName,ClassFilesNumber,prg_txt)

% This function gets some *.dat files and counts the number of fragments file identifiers in each class.
ErrorMsg = '';
NumFiles = length(FileName);
FileID_FragmentsNo = cell(1,NumFiles);
for j=1:NumFiles
    FileID_FragmentsNo{j} = zeros(ClassFilesNumber(j),2);
end
progressbar_FFC(prg_txt);
for j=1:NumFiles
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID);
    
    % Read file fragments
    cnt = 0;
    FileNumbers = 0;
    Curr_File = -1;
    while ~feof(fileID) && FileLength>0
        
        % Read fields
        aux = fread(fileID,1,'uint64=>double',0,'b'); % Read File ID
        fseek(fileID,1*8,'cof');
        if Curr_File~=aux
            Curr_File = aux;
            FileNumbers = FileNumbers+1;
            FileID_FragmentsNo{j}(FileNumbers,1) = Curr_File;
        end
        
        L0 = fread(fileID,1,'uint64=>double',0,'b');
        fseek(fileID,L0,'cof');
        cnt = cnt+3*8+L0;
        FileID_FragmentsNo{j}(FileNumbers,2) = FileID_FragmentsNo{j}(FileNumbers,2)+1;
        
        % Break loop
        if cnt>=FileLength
            break;
        end
    end
    
    % Close file
    fclose(fileID);
    
    stopbar = progressbar_FFC(1,j/NumFiles);
    if stopbar
        ErrorMsg = sprintf('Process is aborted by user.');
        return;
    end
    
end


function Fragments = ReadRepresentatives(PathName,FileName,readflg,totalfrg)

% This function gets a *.dat file and reads totalfrg representatives
% selected by readflg positions of file ID


% Open file
fileID = fopen([PathName FileName],'r');

% Length of file
FileLength = GetFileSize_FFC(fileID);

% Read file fragments
Fragments = cell(1,totalfrg);
cnt = 0;
FileNumbers = 0;
Curr_File = -1;
FrgCount = 0;
while ~feof(fileID) && FileLength>0
    
    % Read fields
    aux = fread(fileID,1,'uint64=>double',0,'b'); % Read File ID
    fseek(fileID,1*8,'cof');
    if Curr_File~=aux
        Curr_File = aux;
        FileNumbers = FileNumbers+1;
    end
    
    L0 = fread(fileID,1,'uint64=>double',0,'b');
    if ~isempty(find(readflg==FileNumbers,1))
        FrgCount = FrgCount+1;
        Fragments{FrgCount} = fread(fileID,L0,'uint8=>double',0,'b')';
    else
        fseek(fileID,L0,'cof');
    end
    cnt = cnt+3*8+L0;
    
    % Break loop
    if cnt>=FileLength
        break;
    end
end

% Close file
fclose(fileID);