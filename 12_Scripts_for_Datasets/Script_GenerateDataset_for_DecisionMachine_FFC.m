function ErrorMsg = Script_GenerateDataset_for_DecisionMachine_FFC

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
%           Dataset: Dataset with L rows (L samples corresponding to L fragments)
%               and C columns. The first C-2 columns correspond to features.
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
% 2020-May-20   function was created
% 2020-Oct-18   filename for saving the dataset is prompted before the process of feature extraction begins  
% 2021-Jan-03   DM_Feature_Transfrom_FFC was included

%% Global Variables
global DecisionMachine_FFC DecisionMachine_CL_FFC DM_FeatureLabels_FFC
global DM_Function_Handles_FFC DM_Function_Labels_FFC DM_Function_Select_FFC
global DM_Feature_Transfrom_FFC

%% Check that Decision Machine is generated/loaded
if isempty(DecisionMachine_FFC) && isempty(DecisionMachine_CL_FFC)
    ErrorMsg = 'No decision machine is loaded. Please train or load a decision machine.';
    return;
end

if isempty(DM_Function_Handles_FFC)
    ErrorMsg = 'The process is not possible: The decision machine does not include any function handle.';
    return;
end

%% Initialization
global C_MEX_64_Available
ErrorMsg = '';
try
    C_MEX_64_Available = true;
    LCSSeq2_FFC(randi([0 255],[1 1024]),{randi([0 255],[1 1024])});
catch
    C_MEX_64_Available = false;
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
ClassLabels = FrgDataset(1,:);

%% Set valid variable names for class labels
ClassLabels = SetVariableNames_FFC(ClassLabels);

%% Generate Dataset

% The last-1 and the last columns are class label and FileID, respectively
NumberofFeatures = sum(cell2mat(DM_Function_Select_FFC));
FeatureLabels = DM_FeatureLabels_FFC;
Function_Handles = DM_Function_Handles_FFC;
Function_Labels = DM_Function_Labels_FFC;
Function_Select = DM_Function_Select_FFC;
Feature_Transfrom = DM_Feature_Transfrom_FFC;

Dataset = zeros(TotalFragments,NumberofFeatures+2);

count = 0;
progressbar_FFC('Step 2: Calculating features, please wait ...');
for j=1:length(ClassLabels) % Loop over different labels
    
    for i=1:length(FrgDataset{2,j}) % Loop over different file identifiers
        for k=1:length(FrgDataset{2,j}(i).Fragments) % Loop over different fragments of a single file
            
            % Take fragment
            count = count+1;
            x = FrgDataset{2,j}(i).Fragments{k};            

            % Calculate feature
            f_cnt = 0;
            for cnt=1:length(Function_Handles)
                if any(Function_Select{cnt})
                    tmp = Function_Handles{cnt}(x);
                    f_sum = sum(Function_Select{cnt});
                    Dataset(count,f_cnt+(1:f_sum)) = tmp(Function_Select{cnt});
                    f_cnt = f_cnt+f_sum;
                end
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

%% Transform Dataset if needed
if ~isempty(Feature_Transfrom)
    Dataset = [Dataset(:,1:end-2)*Feature_Transfrom.Coef Dataset(:,end-1:end)];
end

%% Save Dataset
save([path filename],'Dataset','FeatureLabels','ClassLabels','Function_Handles','Function_Labels','Function_Select','Feature_Transfrom','-v7.3');

%% Update GUI
GUI_Dataset_Update_FFC(filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom);
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');