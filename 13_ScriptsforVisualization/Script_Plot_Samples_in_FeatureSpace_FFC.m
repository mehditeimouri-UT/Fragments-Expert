function ErrorMsg = Script_Plot_Samples_in_FeatureSpace_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - The samples of two or more different sets of classes are plotted in 2-D or 3-D feature space. 
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
[ErrorMsg,FeatureIdx,~] = Select_from_List_FFC(FeatureLabels,1,'Select up two or three feature to be included');
if ~isempty(ErrorMsg)
    return;
end
FeatureSel = FeatureIdx{1};

[Err,ErrMsg] = Check_Variable_Value_FFC(length(FeatureSel),'Number of selected features','type','scalar','class','real','class','integer','min',2,'max',3);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

XYZ_Labels = SetVariableNames_FFC(FeatureLabels(FeatureSel),false);

%% Select Classes
[ErrorMsg,ClassIdx,~] = Select_from_List_FFC(ClassLabels,inf,'Select class labels');
if ~isempty(ErrorMsg)
    return;
end

CategoriesLabels = SetVariableNames_FFC(Select_CellContents_FFC(ClassLabels,ClassIdx),false);

%% Collect Feature Values
F = cell(1,length(ClassIdx));
for j=1:length(ClassIdx)
    
    % Find rows for class j
    fun = @(x) ismember(x,ClassIdx{j});
    idx = arrayfun(fun,Dataset(:,end-1));
    
    % The value of the features for class j
    F{j} = Dataset(idx,FeatureSel);
    
end
    
%% Plot Samples in Feature Space
figure('Name','Samples in FeatureSpace','NumberTitle','off');
switch length(FeatureSel)
        
    case 2
        
        for j=1:length(ClassIdx)            
            plot(F{j}(:,1),F{j}(:,2),'.')
            hold on
        end        
        xlabel(XYZ_Labels{1},'FontSize',12,'FontWeight','normal','FontName','Times')
        ylabel(XYZ_Labels{2},'FontSize',12,'FontWeight','normal','FontName','Times')
        
    case 3
        
        for j=1:length(ClassIdx)
            plot3(F{j}(:,1),F{j}(:,2),F{j}(:,3),'.')
            hold on
        end
        xlabel(XYZ_Labels{1},'FontSize',12,'FontWeight','normal','FontName','Times')
        ylabel(XYZ_Labels{2},'FontSize',12,'FontWeight','normal','FontName','Times')
        zlabel(XYZ_Labels{3},'FontSize',12,'FontWeight','normal','FontName','Times')
        
end

set(gca,'FontSize',12,'FontWeight','normal','FontName','Times')
legend(CategoriesLabels)

%% Update GUI
GUI_MainEditBox_Update_FFC(false,'Visualization is completed.');