function ShowConfusionMatrix_FFC(ConfusionMatrix,RowNames,ColumnNames,title)

% This function gets a confusion matrix and display it in a table format. 
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
% Inputs:
%   ConfusionMatrix: M0xM confusion matrix
%   RowNames: Cell array vector with length M0 that shows the names of rows
%   RowNames: Cell array vector with length M that shows the names of columns
%   title: A string which specifies a title for confusion matrix (default: 'Confusion Matrix')
%
% Revisions:
% 2020-Mar-05   function was created

if nargin<4
    title = sprintf('--- %s ---','Confusion Matrix');
else
    title = sprintf('--- %s ---',title);
end

ScaledConfusionMatrix = Scale_ConfusionMatrix_FFC(ConfusionMatrix);
ScaledConfusionMatrix = round(ScaledConfusionMatrix*100)/100;
M = size(ConfusionMatrix,2);
STRTABLE = 'T = table(';
for i=1:M
    STRTABLE = [STRTABLE 'ScaledConfusionMatrix(:,' num2str(i) '),'];
end
STRTABLE = [STRTABLE '''RowNames'',RowNames,''VariableNames'',ColumnNames);'];
eval(STRTABLE);
disp(title);
disp(T)


