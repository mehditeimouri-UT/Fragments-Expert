function [Filename,Dataset,FeatureLabels,ClassLabels,Function_Handles,Function_Labels,Function_Select,Feature_Transfrom,ErrorMsg] = Load_Dataset_FFC(dlg_title)

% This function loads a Dataset.
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
% Input:
%   dlg_title: The title for load file dialog box
%       Note: If this input is not provided, the default title is used. 
%
% Outputs:
%   Filename: File name corresponding to loaded Dataset.
%   Dataset: Dataset with L rows (L samples corresponding to L fragments)
%       and C columns. The first C-2 columns correspond to features.
%       The last two columns correspond to the integer-valued class labels
%       and the FileID of the fragments, respectively.
%   FeatureLabels: 1xF cell. Cell contents are strings denoting the name of
%       features corresponding to the columns of Dataset.
%   ClassLabels: 1xM cell. Cell contents are strings denoting the name of
%       classes corresponding to integer-valued class labels 1,2,....
%     
%   Note: Dataset rows are sorted as follows: First, the samples of
%   class 1 appear. Second, the the samples of class 2 appear, and
%   so on. Also for the samples of each class, the fragments
%   of a signle multimedia file appear consecutively.
%
%   Function_Handles: cell array of function handles used for generating
%       dataset. 
%   Function_Labels: Cell array of feature labels used for generating
%       dataset. 
%   Function_Select: Cell array of selected features after feature calculation. 
%   Feature_Transfrom: A structure which determines the feature tranform if it is non-empty. 
%   ErrorMsg: Possible error message. If there is no error, this output is
%       empty.
%
% Revisions:
% 2020-Mar-03   function was created
% 2021-Jan-03   Feature_Transfrom output was added

%% Initialization
Dataset = [];
FeatureLabels = [];
ClassLabels = [];
Function_Handles = [];
Function_Labels = [];
Function_Select = [];
Feature_Transfrom = [];
ErrorMsg = [];

if nargin==0
    dlg_title = 'Load Dataset';
end

%% Get file from user
[Filename,path] = uigetfile('*.mat',dlg_title);
FullFileName = [path Filename];
if isequal(FullFileName,[0 0])
    Filename = [];
    ErrorMsg = 'No dataset file is selected!';
    return;
end

%% Read file
try
    matObj = matfile(FullFileName);
    Dataset = matObj.Dataset;
    FeatureLabels = matObj.FeatureLabels;
    ClassLabels = matObj.ClassLabels;    
    Function_Handles = matObj.Function_Handles;
    Function_Labels = matObj.Function_Labels;
    Function_Select = matObj.Function_Select;
    try
        Feature_Transfrom = matObj.Feature_Transfrom;
    catch
        Feature_Transfrom = [];
    end
catch
    ErrorMsg = 'Selected file is not a suported dataset!';
    return;
end

%% Error Checking
% Error Checking 1
M = length(ClassLabels);
M_set = unique(Dataset(:,end-1));
if length(M_set)~=M || min(M_set)~=1 || max(M_set)~=M
    ErrorMsg = 'Invalid Dataset: Integer-valued class labels should be in {1,2,...,M}!';
    return;
end

% Error Checking 2
NumberofFeatures = length(FeatureLabels); % Number of Features
if (size(Dataset,2)-2)~=NumberofFeatures
    ErrorMsg = 'Invalid Dataset: Number of features should be equal to the length of FeatureLabels';
    return;
end