function ErrorMsg = Script_Plot_FeatureHistogram_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Plots histogram of a feature for two or more different sets of classes. 
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
% 2020-Jun-01   function was created

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
X_Labels = SetVariableNames_FFC(FeatureLabels(FeatureSel),false);

%% Select Classses
[ErrorMsg,ClassIdx,~] = Select_from_List_FFC(ClassLabels,inf,'Select class labels');
if ~isempty(ErrorMsg)
    return;
end

CategoriesLabels = SetVariableNames_FFC(Select_CellContents_FFC(ClassLabels,ClassIdx),false);

%% Get Parameters
B = 40*ones(1,length(FeatureSel)); % Vector that determines number of bins for histograms
[success,B,spl] = PromptforParameters_FFC(...
    {'number of bins for histograms (each element should be >=2)','Subplot organization (1x2 vector)'},...
    {['[' num2str(B) ']'],['[' num2str(length(FeatureSel)) ' 1]']},'Parameters for displaying feature histogram');

if ~success
    ErrorMsg = 'Process is aborted. Parameters for displaying feature histogram are not specified.';
    return;
end

%% Check Parameters
[Err,ErrMsg] = Check_Variable_Value_FFC(B,'Number of bins','type','vector','class','real','class','integer','size',[1 length(FeatureSel)],'min',2);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(spl,'Subplot organization','type','vector','class','real','class','integer','size',[1 2],'min-prod',length(FeatureSel));
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end


%% Plot Histogram for Each Feature
figure('Name','Features Histogram','NumberTitle','off');
fun = cell(1,length(ClassIdx));
for f = FeatureSel
    
    % Initialization
    F = cell(1,length(FeatureSel));

    % Counter 
    cnt = find(FeatureSel==f);
    
    % Determine Bins
    Min = inf;
    Max = -inf;
    for j=1:length(ClassIdx)
        
        % Find rows for class j
        if cnt==1
            fun{j} = @(x) ismember(x,ClassIdx{j});
        end
        idx = arrayfun(fun{j},Dataset(:,end-1));
        
        % The value of the feature for class j
        F{j} = Dataset(idx,f);
        
        % Minimum and Maximum Range
        Min = min(min(F{j}),Min);
        Max = max(max(F{j}),Max);
    end
    bins_center = (0:1/B(cnt):1)*(Max-Min)+Min;
    bins = (1/(2*B(cnt)):1/B(cnt):1)*(Max-Min)+Min;
    
    % Histogram Calculation
    count = [];
    for j=1:length(ClassIdx)
        
        countj = histcounts(F{j},bins_center,'Normalization','probability');
        count = [count ; countj];
    end
    
    % Plot Histogrm
    subplot(spl(1),spl(2),cnt);
    bar(bins',count','stacked','LineStyle','-');
    xlabel(X_Labels{cnt},'FontSize',12,'FontWeight','normal','FontName','Times')
    ylabel('Frequency','FontSize',12,'FontWeight','normal','FontName','Times')
    set(gca,'FontSize',12,'FontWeight','normal','FontName','Times')    
    legend(CategoriesLabels)
end

%% Update GUI
GUI_MainEditBox_Update_FFC(false,'Visualization is completed.');
