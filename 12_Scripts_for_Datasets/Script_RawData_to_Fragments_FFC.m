function ErrorMsg = Script_RawData_to_Fragments_FFC

% This function generates file fragments from raw multimedia files.
%   - The main folder is selected by user and all files in the the folder 
%       and all subfolders are considered for fragment generation. 
%   - All fragments of the files in each folder are written into a binary
%       file with the same name as the containing folder
%
% The employed binary file format is a generic binary data format with *.dat extension. 
% The information about fragments is written consecutively as folows:
%   8 bytes for file ID written in ieee big-endian uint64 format
%   8 bytes for fragment ID written in ieee big-endian uint64 format
%   8 bytes for fragment length L (in bytes) written in ieee big-endian uint64 format
%   L bytes for fragment contents fileID written in ieee big-endian uint8 format
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
% 
% This file is a part of Modulations-Expert software, a software package for
% feature extraction from modulated signals and classification among various modulations.
%
% Modulations-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% Modulations-Expert software is distributed in the hope that it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
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
% 2020-Mar-01   function was created

%% Initialization
ErrorMsg = '';

%% Parameters
PossiblePacketSizes = 1024; % Possible Packet Sizes (>=128 and <=4096 in bytes)
DisregardBOF = 1/8; % Percent of fragments from begining of file which are discarded
DisregardEOF = 1/8; % Percent of fragments from end of file which are discarded
MaxFragment = 1; % Maximum Number of fragments taken from each file

[success,PossiblePacketSizes,DisregardBOF,DisregardEOF,MaxFragment] = PromptforParameters_FFC(...
    {'Possible Packet Sizes (in bytes); It can be a vector',...
    'Percent of fragments from begining of file which are discarded (0~0.25)',...
    'Percent of fragments from end of file which are discarded (0~0.25)',...
    'Maximum Number of fragments taken from each file (<=1000)'},...
    {num2str(PossiblePacketSizes),num2str(DisregardBOF),num2str(DisregardEOF),num2str(MaxFragment)},'Parameters for generating the fragments');

if ~success
    ErrorMsg = 'Process is aborted. Fragmentation parameters are not specified.';
    return;
end

%% Check Parameters
[Err,ErrMsg] = Check_Variable_Value_FFC(PossiblePacketSizes,'Possible Packet Sizes','type','vector','class','real','class','integer','min',128,'max',4096);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(DisregardBOF,'Percent of fragments from begining of file which are discarded','type','scalar','class','real','min',0,'max',0.25);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(DisregardEOF,'Percent of fragments from end of file which are discarded','type','scalar','class','real','min',0,'max',0.25);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end


[Err,ErrMsg] = Check_Variable_Value_FFC(MaxFragment,'Maximum Number of fragments taken from each file','type','scalar','class','real','class','integer','min',1,'max',1000);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% Get input folder address
mainfoldername = uigetdir(pwd,'Select the main folder that contains the multimedia files');
if isequal(mainfoldername,0)
    ErrorMsg = 'Process is aborted. No multimedia folder is selected.';
    return;
end

%% Get name of the input folders that contain at least one file
Foldernames = GetNameofFolders_FFC(mainfoldername);
if isempty(Foldernames)
    ErrorMsg = 'Process is aborted. The selected multimedia folder is empty.';
    return;
end

%% Get output folder address
outputfoldername = uigetdir(pwd,'Select the output folder where you want the fragments to be stored on');
if isequal(outputfoldername,0)
    ErrorMsg = 'Process is aborted. No output folder is selected for storing fragments.';
    return;
end

%% Check that output folder is not an input folder
if any(cellfun(@(x)strcmpi(x,outputfoldername),Foldernames))
    ErrorMsg = 'Process is aborted. The selected output folder is one of the input folders.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Get the fragments in each folder
GUI_MainEditBox_Update_FFC(false,sprintf('File fragments generation is started ...'));
progressbar_FFC('Taking fragments, please wait ...');
for j=1:length(Foldernames)
    
    % Folder name
    foldername = Foldernames{j};
    
    % Count the number of files in the folder
    N = GetNumberofFiles_FFC(false,foldername);
    
    % Get the filename of all files in the folder
    Filenames = GetNameofFiles_FFC(false,foldername,N);
    
    % Set the name of the binary file and open it for writing fragments
    str = foldername(length(mainfoldername)+2:end);
    str(str=='\') = '-';
    if isempty(str)
        str = mainfoldername;
        str(1:find(str=='\',1,'last')) = [];
        if isempty(str)
            str = mainfoldername;
            str(str==':') = [];
            str(str=='\') = '-';
        end
    end
    
    fileID = fopen([outputfoldername '\' str '.dat'],'w');
    
    % For all files take fragments
    L = 0;
    for i=1:N
        
        % Open read file
        fid = fopen(Filenames{i});
        
        % Get file size
        FileLength = GetFileSize_FFC(fid);
        
        % Take fragments
        [Frgs,Packet_Pos] = TakeRandomFragments_FFC(fid,FileLength,PossiblePacketSizes,DisregardBOF,DisregardEOF,MaxFragment);
        L0 = length(Packet_Pos);
        L = L+L0;
        
        for k=1:L0
            fwrite(fileID,i,'uint64',0,'b');
            fwrite(fileID,k,'uint64',0,'b');
            fwrite(fileID,length(Frgs{k}),'uint64',0,'b');
            fwrite(fileID,Frgs{k},'uint8',0,'b');
        end
        
        % Close read file
        fclose(fid);
        
        % Progress bar
        stopbar = progressbar_FFC(1,(j-1+i/N)/length(Foldernames));
        if stopbar
            ErrorMsg = 'Process is aborted by user.';
            fclose(fileID);
            return;
        end
    end
    
    fclose(fileID);
    
    GUI_MainEditBox_Update_FFC(false,sprintf('Total number of fragments in %s: %d',str,L));
end

progressbar_FFC(1,1);

GUI_MainEditBox_Update_FFC(false,'-----------------------------------------------------------');
GUI_MainEditBox_Update_FFC(false,sprintf('Total number of classes: %d',length(Foldernames)));
GUI_MainEditBox_Update_FFC(false,'-----------------------------------------------------------');
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');