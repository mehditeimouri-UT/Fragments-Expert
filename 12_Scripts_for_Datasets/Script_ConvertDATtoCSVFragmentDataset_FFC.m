function ErrorMsg = Script_ConvertDATtoCSVFragmentDataset_FFC

% This function takes some data set files in generic binary data format (*.dat) and
% converts them to CSV format (*.csv) where each row is a fragments. 
%
%   Note: Depending on user choice, file identifier for each fragment can be
%       written as the first elements of each row.
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

%% Determmine Format of CSV
button = questdlg('Do you want to add the file identifier for each fragment at the beginning of each?',...
    'Determmine Format of CSV','Yes','No','Yes');
switch button
    
    case 'Yes'
        IncludeFileIdentifier = true;
        
    case 'No'
        IncludeFileIdentifier = false;
        
    otherwise
        ErrorMsg = 'CSV Dataset generation format was not selected by user. The process is aborted.';
        return;
        
end

%% Get the name of the binary files of fragments
[FileName,PathName] = uigetfile('*.dat','Select Datasets in Generic Binary File Format','MultiSelect', 'on');
if isequal(FileName,0)
    ErrorMsg = 'Process is aborted. No Datasets in Generic Binary File Format was selected.';
    return;
end
if ischar(FileName)
    FileName = {FileName};
end

%% Specifiy the target folder for converted CSV files
NewPathName = uigetdir('','Please specifiy the target folder for converted CSV files.');
if isequal(NewPathName,0)
    ErrorMsg = 'Process is aborted. No target folder for converted CSV files was selected.';
    return;    
end

%% Read Fragments and Write the to CSV Format
NumFiles = length(FileName);
NewFileName = FileName;
for j=1:NumFiles
    NewFileName{j}(end-2:end) = 'csv';
end

progressbar_FFC('Converting files ....','Progress for the current file');
for j=1:NumFiles
    
    % Open dat file for reading
    fileID_Read = fopen([PathName FileName{j}],'r');
    
    % Open csv file for writing
    CSV_File = [NewPathName '\' NewFileName{j}];
    fileID_Write = fopen(CSV_File,'w');
    fclose(fileID_Write);
    
    % Length of file
    FileLength = GetFileSize_FFC(fileID_Read);
    
    % Read file fragments
    cnt = 0;
    while ~feof(fileID_Read) && FileLength>0
        
        Curr_File = fread(fileID_Read,1,'uint64=>double',0,'b'); % Read File ID
        fseek(fileID_Read,1*8,'cof');
        L0 = fread(fileID_Read,1,'uint64=>double',0,'b');
        Fragment = fread(fileID_Read,L0,'uint8=>double',0,'b')';
        
        % Write to CSV File
        if IncludeFileIdentifier
            dlmwrite(CSV_File,[Curr_File Fragment],'-append');
        else
            dlmwrite(CSV_File,Fragment,'-append');
        end
        
        cnt = cnt+3*8+L0;
        
        stopbar = progressbar_FFC(2,cnt/FileLength);
        if stopbar
            ErrorMsg = sprintf('Process is aborted by user.');
            return;
        end
        
        % Break loop
        if cnt>=FileLength
            break;
        end
    end
    
    % Close file
    fclose(fileID_Read);
    
    stopbar = progressbar_FFC(1,j/NumFiles);
    if stopbar
        ErrorMsg = sprintf('Process is aborted by user.');
        return;
    end
    
end


%% Update GUI
GUI_MainEditBox_Update_FFC(false,'The process is completed successfully.');