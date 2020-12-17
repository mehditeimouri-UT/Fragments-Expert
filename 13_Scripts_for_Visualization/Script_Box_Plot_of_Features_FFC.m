function ErrorMsg = Script_Box_Plot_of_Features_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - produces box plots for one or more fetures
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
% 2020-Oct-29   function was created

%% Initialization
global ClassLabels_FFC FeatureLabels_FFC Dataset_FFC

if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end


%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Initial Assignment
FeatureLabels = FeatureLabels_FFC;
ClassLabels = ClassLabels_FFC;
Dataset = Dataset_FFC;

%% Select Features
[ErrorMsg,FeatureIdx,~] = Select_from_List_FFC(FeatureLabels,1,'Select feature labels');
if ~isempty(ErrorMsg)
    return;
end

FeatureSel = FeatureIdx{1};
Y_Labels = SetVariableNames_FFC(FeatureLabels(FeatureSel),false);

%% Select Classses
[ErrorMsg,ClassIdx,~] = Select_from_List_FFC(ClassLabels,inf,'Select class labels');
if ~isempty(ErrorMsg)
    return;
end

CategoriesLabels = SetVariableNames_FFC(Select_CellContents_FFC(ClassLabels,ClassIdx),false);

%% Get and Check Parameters
if length(FeatureSel)>1
    [success,spl] = PromptforParameters_FFC(...
        {'Subplot organization (1x2 vector)'},...
        {['[' num2str(length(FeatureSel)) ' 1]']},'Parameters for displaying feature histogram');
    
    if ~success
        ErrorMsg = 'Process is aborted. Parameters for producing box plots are not specified.';
        return;
    end
    
    [Err,ErrMsg] = Check_Variable_Value_FFC(spl,'Subplot organization','type','vector','class','real','class','integer','size',[1 2],'min-prod',length(FeatureSel));
    if Err
        ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
        return;
    end
else
    spl = [1 1];
end

%% Plot Box Plot for Each Feature
figure('Name','Box Plot of Features','NumberTitle','off');
fun = cell(1,length(ClassIdx));
Dataset(:,end) = 0;
for j=1:length(ClassIdx)
    
    % Find rows for class j
    fun{j} = @(x) ismember(x,ClassIdx{j});
    idx = arrayfun(fun{j},Dataset(:,end-1));
    Dataset(idx,end) = j;
    
end
    
for f = FeatureSel
    
    % Counter 
    cnt = find(FeatureSel==f);
    
    % Box Plot
    subplot(spl(1),spl(2),cnt);
    boxplot(Dataset(Dataset(:,end)~=0,f),CategoriesLabels(Dataset(Dataset(:,end)~=0,end))','notch','on');
    ylabel(Y_Labels{cnt},'FontSize',12,'FontWeight','normal','FontName','Times')
    set(gca,'FontSize',12,'FontWeight','normal','FontName','Times')    
end

%% Update GUI
GUI_MainEditBox_Update_FFC(false,'Visualization is completed.');
