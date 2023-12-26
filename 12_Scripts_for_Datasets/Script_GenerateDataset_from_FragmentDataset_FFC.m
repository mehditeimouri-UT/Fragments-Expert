function ErrorMsg = Script_GenerateDataset_from_FragmentDataset_FFC

% This function takes some data set files in generic binary data format and does the following:
%   (1) Reads the fragments into structured Dataset of fragments (i.e. FrgDataset)
%
%   Note: The employed binary file format is a generic binary data format with *.dat extension.
%   The information about fragments are written consecutively as folows:
%       8 bytes for file ID written in ieee big-endian uint64 format
%       8 bytes for fragment ID written in ieee big-endian uint64 format
%       8 bytes for fragment length L (in bytes) written in ieee big-endian uint64 format
%       L bytes for fragment contents fileID written in ieee big-endian uint8 format
%
%   (2) Generates Dataset of extracted features that includes
%           Dataset: Dataset with TotalFragments rows (TotalFragments samples corresponding to TotalFragments fragments)
%               and C columns. The first F = C-2 columns correspond to features.
%               The last two columns correspond to the integer-valued class labels
%               and the FileID of the fragments, respectively.
%           FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%               features corresponding to the columns of Dataset.
%           ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%               classes corresponding to integer-valued class labels 1,2,....
%
%           Note: Dataset rows are sorted as follows: First, the samples of
%           class 1 appear. Second, the the samples of class 2 appear, and
%           so on. Also for the samples of each class, the fragments
%           of a signle multimedia file appear consecutively.
%
%   (3) Saves Dataset and assigns the corresponding value to global
%   variable Dataset_FFC, ClassLabels_FFC, FeatureLabels_FFC.
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
% 2020-Mar-02   function was created
% 2020-Oct-18   - filename for saving the dataset is prompted before the process of feature extraction begins  
%               - function handles for Longest Common Subsequence and Longest Common Substring are modified
%                   for preventing large file size of the saved dataset 

%% Initialization
global C_MEX_64_Available
ErrorMsg = '';
try
    C_MEX_64_Available = true;
    LCSSeq2_FFC(randi([0 255],[1 1024]),{randi([0 255],[1 1024])});
catch
    C_MEX_64_Available = false;
    h = warndlg('64-bit C-MEX functions does not work. MATLAB m-File Functions that are slower are used instead of them if MATLAB versions exist.','Incompatible Platform','modal');
    waitfor(h);
end

%% Select Feature Types
FeatureTypes = {'Byte Frequency Distribution (BFD)',...
    'Byte Bigrams',...
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
    'Kolmogorov Complexity',...
    'False Nearest Neighbors',...
    'Lyapunov Exponents',...
    'GIST Features',...
    'Longest Common Subsequence',...
    'Longest Common Substring',...
    'Centroid Models',...
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
    Default_Value = [Default_Value '[2 3]'];
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
cnt = 0;

% Define functions and their outputs
if any(strcmp(FeatureTypes,'Byte Frequency Distribution (BFD)'))
    cnt = cnt+1;
    Range = num2cell(0:255);
    f_handles{cnt} = @(x) BFD_FFC(x,Range); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,256+4); % Lables for Features
    for i=0:255
        f_OutputLabels{cnt}{i+1} = sprintf('BFD_%d',i);
    end
    f_OutputLabels{cnt}{256+1} = 'SdFreq';
    f_OutputLabels{cnt}{256+2} = 'ModesFreq';
    f_OutputLabels{cnt}{256+3} = 'CorNextFreq';
    f_OutputLabels{cnt}{256+4} = 'ChiSq';
end

if any(strcmp(FeatureTypes,'Byte Bigrams'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Byte_Bigram_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,65536); % Lables for Features
    for i=0:65535
        f_OutputLabels{cnt}{i+1} = sprintf('ByteBigram_%d',i);
    end
end

if any(strcmp(FeatureTypes,'Rate of Change'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) RoC_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,257); % Lables for Features
    for i=0:255
        f_OutputLabels{cnt}{i+1} = sprintf('RoC_%d',i);
    end
    f_OutputLabels{cnt}{257} = 'MeanRoC';
end

if any(strcmp(FeatureTypes,'Longest Contiguous Streak of Repeating Bytes'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) LongestContiguous_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'LongestContiguous'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'n-grams'))
    for j=1:length(ns)
        cnt = cnt+1;
        n = ns(j);
        f_handles{cnt} = @(x)  BitNgram_FFC(x,n); % Function of feature extraction
        f_OutputLabels{cnt} = cell(1,2^n); % Lables for Features
        for i=0:(2^n-1)
            f_OutputLabels{cnt}{i+1} = sprintf('Ngram%d_%d',n,i);
        end
    end
end

if any(strcmp(FeatureTypes,'Byte Concentration Features: Low, Ascii, and High'))
    cnt = cnt+1;
    Range = {[0 31] , [32 127] , [192 255]};
    f_handles{cnt} = @(x) BFD_FFC(x,Range); % Function of feature extraction
    f_OutputLabels{cnt} = {'Low' , 'Ascii' , 'High'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Basic Lower-Order Statistics: Mean, STD, Mode, Median, and Mad'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Mean_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'ArithmeticMean','GeometricMean','HarmonicMean'}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) StandardDeviation_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'STD'}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) Mode_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Mode'}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) Median_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Median'}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) Mad_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Mad'}; % Lables for Features
    
end

if any(strcmp(FeatureTypes,'Higher-Order Statistics: Kurtosis and Skewness'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Kurtosis_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Kurtosis'}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) Skewness_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Skewness'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Bicoherence'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Bicoherence_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Bicoh'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Frequency Domain Statistics (Mean, STD, Skewness)'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) FrequencyDomainStatistics_FFC(x,N_Subbands); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,N_Subbands*3); % Lables for Features
    tmp_feature_names = {'Mean','STD','Skewness'};
    tmp_cnt = 0;
    for j=1:3
        for i=1:N_Subbands
            tmp_cnt = tmp_cnt+1;
            f_OutputLabels{cnt}{tmp_cnt} = sprintf('%s_f_%d_%d',tmp_feature_names{j},N_Subbands,i);
        end
    end
end

if any(strcmp(FeatureTypes,'Auto-Correlation'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Autocorrelation_FFC(x,lag); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,lag); % Lables for Features
    for i=1:lag
        f_OutputLabels{cnt}{i} = sprintf('R%d',i);
    end
end

if any(strcmp(FeatureTypes,'Window-Based Statistics'))
    cnt = cnt+1;
    windowSize = 256;
    f_handles{cnt} = @(x) DeviationFromSTD_FFC(x,windowSize); % Function of feature extraction
    f_OutputLabels{cnt} = {sprintf('DeviationFromSTD_%d',windowSize)}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) MovingAverage_FFC(x,windowSize); % Function of feature extraction
    f_OutputLabels{cnt} = {sprintf('DeltaMovingAverage_%d',windowSize),sprintf('Delta2MovingAverage_%d',windowSize)}; % Lables for Features
    
    cnt = cnt+1;
    f_handles{cnt} = @(x) DeltaSTD_FFC(x,windowSize); % Function of feature extraction
    f_OutputLabels{cnt} = {sprintf('DeltaSTD_%d',windowSize),sprintf('Delta2STD_%d',windowSize)}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Binary Ratio'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) BinaryRatio_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'BinaryRatio'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Entropy'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Entropy_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'Entropy','d_Entropy'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Video Patterns'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) VideoPatterns_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'MKV1_Pattern', 'MKV2_Pattern', 'AVI1_Pattern', 'AVI2_Pattern', 'RMVB1_Pattern', 'RMVB2_Pattern', 'OGV_Pattern', ...
        'MP4_1_Pattern', 'MP4_2_Pattern', 'MP4_3_Pattern', 'MP4_4_Pattern', 'MP4_5_Pattern', 'MP4_6_Pattern', 'MP4_7_Pattern', 'MP4_8_Pattern',...
        'MP4_9_Pattern', 'MP4_10_Pattern'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Audio Patterns'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) AudioPatterns_FFC(x); % Function of feature extraction
    f_OutputLabels{cnt} = {'MP3_Sync','FLAC_Sync'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'Kolmogorov Complexity'))
    cnt = cnt+1;
    if C_MEX_64_Available
        f_handles{cnt} = @(x) kolmogorov_FFC(x); % Function of feature extraction
    else
        f_handles{cnt} = @(x) kolmogorov(x); % Function of feature extraction
    end
    f_OutputLabels{cnt} = {'KolmogrovComplexity'}; % Lables for Features
end

if any(strcmp(FeatureTypes,'False Nearest Neighbors'))
    if C_MEX_64_Available
        rt_str = sprintf('%g',rt);
        rt_str(rt_str=='.') = '_';
        false_nearest_caller_FFC(randi([0 255],[1 1024]),minemb,maxemb,rt);
        cnt = cnt+1;
        f_handles{cnt} = @(x) false_nearest_caller_FFC(x,minemb,maxemb,rt); % Function of feature extraction
        f_OutputLabels{cnt} = cell(1,3*(maxemb-minemb+1)); % Lables for Features
        ij = 0;
        for i=minemb:maxemb
            for j=1:3
                ij = ij+1;
                switch j
                    case 1
                        f_OutputLabels{cnt}{ij} = sprintf('FNF_%s_%d',rt_str,i);
                    case 2
                        f_OutputLabels{cnt}{ij} = sprintf('av_eps_%s_%d',rt_str,i);
                    case 3
                        f_OutputLabels{cnt}{ij} = sprintf('rms_eps_%s_%d',rt_str,i);
                end
            end
        end
    else
        h = warndlg('C-MEX function false_nearest_FFC does not work. So, the features of false nearest neighbors are not included in feature sets.',...
            'Incompatible Platform','modal');
        waitfor(h);
    end
end

if any(strcmp(FeatureTypes,'Lyapunov Exponents'))
    if C_MEX_64_Available
        lyap_exp_k_FFC(randi([0 255],[1 1024]),mindim,maxdim);
        cnt = cnt+1;
        f_handles{cnt} = @(x) sort(lyap_exp_k_FFC(x,mindim,maxdim),'descend'); % Function of feature extraction
        f_OutputLabels{cnt} = cell(1,maxdim-mindim+1); % Lables for Features
        j = 0;
        for i=mindim:maxdim
            j = j+1;
            f_OutputLabels{cnt}{j} = sprintf('Lambda_%d',i);
        end
    else
        h = warndlg('C-MEX function lyap_exp_k_FFC does not work. So, the features of Lyapunov Exponents are not included in feature sets.',...
            'Incompatible Platform','modal');
        waitfor(h);
    end
end

if any(strcmp(FeatureTypes,'GIST Features'))
    cnt = cnt+1;
    f_handles{cnt} = @(x) Grayscale_GIST_FFC(x,rowsize,orientPerScale,numBlks); % Function of feature extraction
    f_OutputLabels{cnt} = cell(1,sum(orientPerScale)*numBlks^2); % Lables for Features
    GIST_str = num2str(orientPerScale);
    GIST_str(GIST_str==' ') = '_';
    ijk=0;
    for i = 1:length(orientPerScale)
        for j=1:orientPerScale(i)
            for k=1:numBlks^2
                ijk = ijk+1;
                f_OutputLabels{cnt}{ijk} = sprintf('GIST_%d_%d_%s_Scale_%d_Orient_%d_%d',rowsize,numBlks,GIST_str,i,j,k);
            end
        end
    end
end

NumFeatExtFunc = cnt;

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

%% Get the name of the file for saving dataset
[filename,path] = uiputfile('mydataset.mat','Save Generated Dataset');
if isequal(filename,0)
    ErrorMsg = 'Process is aborted. No file was selected by user for saving dataset.';
    return;
end

%% Read fragments into FrgDataset
%   FrgDataset is a 2xN cell array.
%       FrgDataset{1,i}: Corresponding filename
%       FrgDataset{2,i}: A structure with the following field:
%           Fragments: A cell vector; The content of each individual cell is a fragment
%               All fragments of FrgDataset{2,i} are taken from a single file

N = length(FileName);
FrgDataset = cell(2,N);
TotalFragments = 0;
FileEmpty = false(1,N);
ClassMembersNumber = zeros(1,N);
progressbar_FFC('Step 1: Read fragments from binary files, please wait ...');
for j=1:N
    
    % Open file
    fileID = fopen([PathName FileName{j}],'r');
    str = FileName{j};
    str(strfind(lower(str), '.dat'):end) = [];
    FrgDataset{1,j} = str;
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID);
    
    % Read file fragments
    cnt = 0;
    L = 0;
    if FileLength==0
        FileEmpty(j) = true;
    end
    
    while ~feof(fileID) && FileLength>0
        
        % Read fields
        FileID = fread(fileID,1,'uint64=>double',0,'b');
        FragmentID = fread(fileID,1,'uint64=>double',0,'b');
        L0 = fread(fileID,1,'uint64=>double',0,'b');
        Frg = fread(fileID,L0,'uint8=>double',0,'b');
        if isempty(FileID) ||  isempty(FragmentID) || isempty(L0) || (~isempty(L0) && length(Frg)~=L0)
            ErrorMsg = sprintf('Process is aborted. File %s is not a valid Generic Binary File.',FileName{j});
            fclose(fileID);
            progressbar_FFC(1,1);
            return;
        end
        cnt = cnt+3*8+L0;
        
        % Fill Dataset
        FrgDataset{2,j}(FileID).Fragments{FragmentID} = Frg';
        L = L+1;
        ClassMembersNumber(j) = ClassMembersNumber(j)+1;
        
        % Break loop
        if cnt>=FileLength
            break;
        end
    end
    
    % Close file
    fclose(fileID);
    
    stopbar = progressbar_FFC(1,j/N);
    if stopbar
        ErrorMsg = sprintf('Process is aborted by user.');
        return;
    end
    
    GUI_MainEditBox_Update_FFC(false,sprintf('File %d from %d is completed. Total number of fragments is %d',j,N,L));
    TotalFragments = TotalFragments+L;
end
progressbar_FFC(1,1);

%% Determine Number of Classes
FrgDataset(:,FileEmpty) = [];
ClassMembersNumber(FileEmpty) = [];
ClassLabels = FrgDataset(1,:);

%% Set valid variable names for class labels
ClassLabels = SetVariableNames_FFC(ClassLabels);

%% Select Representatives
PossibleClassofReps = {'Longest Common Subsequence','Longest Common Substring','Centroid Models'};
ClassofReps = intersect(FeatureTypes,PossibleClassofReps);

% Define Dataset_Index and Dataset_Index_RP
% Each row of Dataset_Index: row counter (1,2,...), fragment number in file identifier, selection flag, integer-valued class label, and file identifier
Dataset_Index = zeros(TotalFragments,5);
if ~isempty(ClassofReps)
    
    count = 0;
    for j=1:length(ClassLabels) % Loop over different labels
        
        for i=1:length(FrgDataset{2,j}) % Loop over different file identifiers
            for k=1:length(FrgDataset{2,j}(i).Fragments) % Loop over different fragments of a single file
                
                count = count+1;
                Dataset_Index(count,1) = count;
                Dataset_Index(count,2) = k;
                Dataset_Index(count,4) = j;
                Dataset_Index(count,5) = i;
                
            end
            
        end
    end
    Dataset_Index_RP = RandomPermute_Dataset_FFC(Dataset_Index,ClassLabels);
    
end

ClassLabelsSelect = cell(1,length(ClassofReps));
NumReps = cell(1,length(ClassofReps));
RepPosition = cell(1,length(ClassofReps));
Representatives_Rows = cell(1,length(ClassofReps));
Representatives_Fragments = cell(1,length(ClassofReps));
    
% Repeat process for each class of Representatives
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
    RepPosition{i} = 'random'; % Position in Dataset for Selecting Representatives: random, first, last
    [success,NumReps{i},RepPosition{i}] = PromptforParameters_FFC(...
        {'Number of Representatives for Each Class (10~100, and less than <10% of class members)',...
        'Position in Dataset for Selecting Representatives: random, first, last'},...
        {num2str(NumReps{i}),RepPosition{i}},sprintf('Parameters for selecting representatives of %s',ClassofReps{i}));
    
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
    
    [Err,ErrMsg] = Check_Variable_Value_FFC(RepPosition{i},'Position in Dataset for Selecting Representatives','possiblevalues',{'random','first','last'});
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
    
    % Initialize Vectors
    Representatives_Rows{i} = zeros(NumReps{i}*length(ClassLabelsSelect{i}),1);
    Representatives_Fragments{i} = cell(1,length(ClassLabels));
    
    % Select and Write Representatives in Representatives_Fragments
    cnt = 0;
    for j=1:length(ClassLabelsSelect{i})
        
        switch RepPosition{i}
            case 'random'
                idx = find(Dataset_Index_RP(:,4)==ClassLabelsSelect{i}(j),NumReps{i},'first');
                idx = Dataset_Index_RP(idx,1);
            otherwise
                idx = find(Dataset_Index(:,4)==ClassLabelsSelect{i}(j),NumReps{i},RepPosition{i});
                idx = Dataset_Index(idx,1);
        end
        A = Dataset_Index(idx,:);
        Dataset_Index(idx,3) = 1;
        
        Representatives_Rows{i}(cnt+(1:length(idx))) = A(:,1);
        cnt = cnt+length(idx);
        
        Representatives_Fragments{i}{j} = cell(1,NumReps{i});
        for k=1:NumReps{i}
            Representatives_Fragments{i}{j}{k} = FrgDataset{2,j}(A(k,4)).Fragments{A(k,2)};
        end
        
    end
    
    % Add Representatives-Related Fature Extraction Functions
    cnt = length(f_handles);
    switch ClassofReps{i}
        case 'Longest Common Subsequence'
            
            for j=1:length(ClassLabelsSelect{i})
                cnt = cnt+1;
                RepsFrgs = Representatives_Fragments{i}{j};
                f_handles{cnt} = @(x) LCSSeq2_FFC(x,RepsFrgs); % Function of feature extraction
                f_OutputLabels{cnt} = {sprintf('LCS_Seq_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features
            end
            
        case 'Longest Common Substring'
            
            for j=1:length(ClassLabelsSelect{i})                
                cnt = cnt+1;
                RepsFrgs = Representatives_Fragments{i}{j};
                f_OutputLabels{cnt} = {sprintf('LCS_Str_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features                
                f_handles{cnt} = @(x) LCSStr2_FFC(x,RepsFrgs); % Function of feature extraction
            end            
            
        case 'Centroid Models'
            
            for j=1:length(ClassLabelsSelect{i})                
                
                % Build Centroid Model
                Centroid = zeros(length(Representatives_Fragments{i}{j}),256);
                for k=1:length(Representatives_Fragments{i}{j})
                    output = BFD_FFC(Representatives_Fragments{i}{j}{k},num2cell(0:255));
                    Centroid(k,:) = output(1:256);
                end
                centroid_mu = mean(Centroid,1);
                centroid_sigma = std(Centroid,0,1);
                
                cnt = cnt+1;
                f_handles{cnt} = @(x) Compare_with_Centroid_FFC(x,centroid_mu,centroid_sigma); % Function of feature extraction
                f_OutputLabels{cnt} = {sprintf('CosineSimilarity_%s',ClassLabels{ClassLabelsSelect{i}(j)}) ...
                    sprintf('MahalanobisDistance_%s',ClassLabels{ClassLabelsSelect{i}(j)})}; % Lables for Features
            end
            
    end
    NumFeatExtFunc = cnt;
end
TotalReps = sum(Dataset_Index(:,3));

%% Determine Number of Features
F_idx = zeros(1,NumFeatExtFunc+1);
for cnt=1:NumFeatExtFunc
    F_idx(cnt+1) = F_idx(cnt)+length(f_OutputLabels{cnt});
end

FeatureLabels = cell(1,F_idx(end));
for cnt=1:NumFeatExtFunc
    FeatureLabels(F_idx(cnt)+1:F_idx(cnt+1)) = f_OutputLabels{cnt};
end
NumberofFeatures = length(FeatureLabels); % Number of Features

if NumFeatExtFunc==0
    ErrorMsg = 'Process is aborted. The number of features is equal to zero.';
    return;
end

%% Generate Dataset

% The last-1 and the last columns are class label and FileID, respectively
TotalFragments = TotalFragments-TotalReps;
Dataset = zeros(TotalFragments,NumberofFeatures+2);

count = 0;
counter = 0;
progressbar_FFC('Step 2: Calculating features, please wait ...');
for j=1:length(ClassLabels) % Loop over different labels
    
    for i=1:length(FrgDataset{2,j}) % Loop over different file identifiers
        for k=1:length(FrgDataset{2,j}(i).Fragments) % Loop over different fragments of a single file
            
            % Take fragment
            counter = counter+1;
            if Dataset_Index(counter,3)==1
                continue;
            end
            
            count = count+1;
            x = FrgDataset{2,j}(i).Fragments{k};            

            % Calculate feature
            for cnt=1:NumFeatExtFunc
                Dataset(count,F_idx(cnt)+1:F_idx(cnt+1)) = f_handles{cnt}(x);
            end
            Dataset(count,end-1) = j;
            Dataset(count,end) = i;
            
            if any(isnan(Dataset(count,:)))
                ErrorMsg = sprintf('Process is aborted. The feature set for Class-%s:File-%d-Fragment-%d contains NaN.',j,i,k);
                return;
            end
            
            % Progress bar
            stopbar = progressbar_FFC(1,(j-1+(i-1+k/length(FrgDataset{2,j}(i).Fragments))/length(FrgDataset{2,j}))/length(ClassLabels));
            if stopbar
                ErrorMsg = sprintf('Process is aborted by user.');
                return;
            end
            
        end
        
    end
end
progressbar_FFC(1,1);

%% Save Dataset
Function_Handles = f_handles;
Function_Labels = f_OutputLabels;
Function_Select = cell(1,length(Function_Labels));
for j=1:length(Function_Labels)
    Function_Select{j} = true(1,length(Function_Labels{j}));
end
save([path filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');