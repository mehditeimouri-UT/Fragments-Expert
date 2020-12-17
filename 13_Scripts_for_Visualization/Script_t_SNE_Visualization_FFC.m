function ErrorMsg = Script_t_SNE_Visualization_FFC

% This function takes Dataset_FFC with L rows (L samples) and C columns (C-2 features) and does the following process:
%   - Visualize data samples in 2-D or 3-D feature space using t-SNE. 
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
global ClassLabels_FFC Dataset_FFC

if isempty(Dataset_FFC)
    ErrorMsg = 'No dataset is loaded. Please generate or load a dataset.';
    return;
end

if (size(Dataset_FFC,2)-2)<4
    ErrorMsg = 'The dataset should contain at least 4 features.';
    return;
end

%% ###################################################################################################
%% --------------------------------------------------------------------------------------------------#
%% -------------------------------------- Function Main Body ----------------------------------------#
%% --------------------------------------------------------------------------------------------------#
%% ###################################################################################################

%% Select Classses
[ErrorMsg,ClassIdx,~] = Select_from_List_FFC(ClassLabels_FFC,inf,'Select class labels');
if ~isempty(ErrorMsg)
    return;
end

CategoriesLabels = SetVariableNames_FFC(Select_CellContents_FFC(ClassLabels_FFC,ClassIdx),false);

%% Get Parameters
no_dims = 2; % Final Reduced Dimensionality (2 or 3)
initial_dims = min(size(Dataset_FFC,2)-2,50); % Initial Reduced Dimensionality 
perplexity = 15; % The perplexity of the Gaussian kernel (2~50)
max_iter = 1000; % Maximum number of iterations (100~1000)

[success,no_dims,initial_dims,perplexity,max_iter] = PromptforParameters_FFC(...
    {'Final Reduced Dimensionality (2 or 3)',...
    sprintf('Initial Reduced Dimensionality (4~%d)',size(Dataset_FFC,2)-2),...
    'The perplexity of the Gaussian kernel (2~50)',...
    'Maximum number of iterations (100~1000)'},...
    {num2str(no_dims),num2str(initial_dims),num2str(perplexity),num2str(max_iter)},'Parameters for t-SNE');

if ~success
    ErrorMsg = 'Process is aborted. Parameters for t-SNE are not specified.';
    return;
end

%% Check Parameters
[Err,ErrMsg] = Check_Variable_Value_FFC(no_dims,'Final Reduced Dimensionality','type','scalar','class','real','class','integer','min',2,'max',3);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(initial_dims,'Initial Reduced Dimensionality','type','scalar','class','real','class','integer','min',4,'max',size(Dataset_FFC,2)-2);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(perplexity,'The perplexity of the Gaussian kernel','type','scalar','class','real','class','integer','min',2,'max',50);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

[Err,ErrMsg] = Check_Variable_Value_FFC(max_iter,'Maximum number of iterations','type','scalar','class','real','class','integer','min',100,'max',1000);
if Err
    ErrorMsg = sprintf('Process is aborted. %s',ErrMsg);
    return;
end

%% Select Classes in Dataset
Dataset = Dataset_FFC;
fun = cell(1,length(ClassIdx));
Dataset(:,end) = 0;
for j=1:length(ClassIdx)
    
    % Find rows for class j
    fun{j} = @(x) ismember(x,ClassIdx{j});
    idx = arrayfun(fun{j},Dataset(:,end-1));
    Dataset(idx,end) = j;
    
end
Dataset(Dataset(:,end)==0,:) = [];
Dataset(:,end-1) = Dataset(:,end);

%% Run t-SNE
ydata = tsne_FFC(Dataset(:,1:end-2),CategoriesLabels(Dataset(:,end-1))',no_dims,initial_dims,perplexity,max_iter);
if isequal(ydata,-1)
    ErrorMsg = 'Process is aborted by user.';
    return;
end
%% Update GUI
GUI_MainEditBox_Update_FFC(false,'Visualization is completed.');