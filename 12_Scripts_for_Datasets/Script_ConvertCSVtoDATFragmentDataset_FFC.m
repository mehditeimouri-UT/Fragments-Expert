function ErrorMsg = Script_ConvertCSVtoDATFragmentDataset_FFC

% This function takes some data set files in CSV format (*.csv), where each row is a fragments, and
% converts them to generic binary data format (*.dat).
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
% 2023-Dec-25   function was created

%% Default Output
ErrorMsg = '';


%% Get the name of the csv files of fragments
[FileName,PathName] = uigetfile('*.csv','Select Frsgments Datasets in CSV File Format','MultiSelect', 'on');
if isequal(FileName,0)
    ErrorMsg = 'Process is aborted. No Datasets in Generic Binary File Format was selected.';
    return;
end
if ischar(FileName)
    FileName = {FileName};
end

%% Determmine Format of CSV
button = questdlg('Is the file identifier for each fragment present at the beginning of each?',...
    'Specifiy Format of CSV','Yes','No','Yes');
switch button
    
    case 'Yes'
        IncludedFileIdentifier = true;
        
    case 'No'
        IncludedFileIdentifier = false;
        
    otherwise
        ErrorMsg = 'CSV Dataset format was not specified by user. The process is aborted.';
        return;
        
end

%% Specifiy the target folder for converted CSV files
NewPathName = uigetdir('','Please specifiy the target folder for converted DAT files.');
if isequal(NewPathName,0)
    ErrorMsg = 'Process is aborted. No target folder for converted DAT files was selected.';
    return;
end

%% Read Fragments and Write the to CSV Format
NumFiles = length(FileName);
NewFileName = FileName;
for j=1:NumFiles
    NewFileName{j}(end-2:end) = 'dat';
end

progressbar_FFC('Converting files ....','Progress for the current file');
for j=1:NumFiles
    
    % Open dat file for reading
    fileID_Read = fopen([PathName FileName{j}],'r');
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID_Read);

    % Open dat file for writing
    DAT_File = [NewPathName '\' NewFileName{j}];
    fileID_Write = fopen(DAT_File,'w');
        
    % Read file fragments
    curr_file_id = -1;
    file_id = 0;
    frg_id = 0;
    while ~feof(fileID_Read)
        
        line = fgets(fileID_Read);        
        
        stopbar = progressbar_FFC(2,ftell(fileID_Read)/FileLength);
        if stopbar
            ErrorMsg = sprintf('Process is aborted by user.');
            return;
        end
    
        if isequal(line,-1)
            break; % Exit the loop at the end of the file
        end
        Fragment = str2num(line);
        
        if IncludedFileIdentifier
            file_id = Fragment(1);
            if curr_file_id~=file_id
                curr_file_id = file_id;
                frg_id = 0;
            end
            frg_id = frg_id+1;
            Fragment(1) = [];
        else
            file_id = file_id+1;
            frg_id = 1;
        end
        
        fwrite(fileID_Write,file_id,'uint64',0,'b');
        fwrite(fileID_Write,frg_id,'uint64',0,'b');
        fwrite(fileID_Write,length(Fragment),'uint64',0,'b');
        fwrite(fileID_Write,Fragment,'uint8',0,'b');

    end
    
    % Close files
    fclose(fileID_Write);
    fclose(fileID_Read);
    
    stopbar = progressbar_FFC(1,j/NumFiles);
    if stopbar
        ErrorMsg = sprintf('Process is aborted by user.');
        return;
    end
    
end


%% Update GUI
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');