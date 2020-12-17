function [Err,ErrMsg] = Check_Variable_Value_FFC(var,varname,varargin)

% This function gets a variable and check that the assigned value(s) are
% correct according to some predefined rules.
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
%   var: The value assigned to variable
%   varname: The string which specifies the variable name
%   varargin: Some pairs of name and value that specify certain aspects of the error checking.
%       Possible name:value pair are:
%           'type': 'scalar', 'vector'
%           'class': 'integer', 'real'
%           'size': [m n] that specifies the size
%           'minsize': [m n] that specifies the minimum acceptable size
%           'min': Minimum acceptable value
%           'max': Maximum acceptable value
%           'sum': Sum of the values of a vector
%           'min-prod': Minimum of the product of values in a vector
%           'issorted': 'ascend' , 'descend'
%
% Ourputs:
%   Err: if true, it means that the assigned value is not consistent with
%       some predefined rule.
%   ErrMsg: Error message.
%
% Revisions:
% 2020-Mar-31   function was created

%% Initialization
Err = false;
ErrMsg = '';

%% Check for Errors
N = nargin;
N = (N-2)/2;
for j=1:N
    name = varargin{2*j-1};
    value = varargin{2*j};
    switch lower(name)
        case 'type'
            
            switch lower(value)
                case 'scalar'
                    if ~isscalar(var)
                        Err = true;
                        ErrMsg = sprintf('%s should be scalar.',varname);
                        return;
                    end
                    
                case 'vector'
                    if ~isvector(var)
                        Err = true;
                        ErrMsg = sprintf('%s should be a vector.',varname);
                        return;
                    end
                    
                otherwise
                    error('Unpredicted Error: The value input for name=''type'' in Check_Variable_Value_FFC is not valid');
                    
            end
            
        case 'class'
            
            switch lower(value)
                case 'real'
                    if ~isreal(var)
                        Err = true;
                        ErrMsg = sprintf('%s should have real values.',varname);
                        return;
                    end
                    
                case 'integer'
                    if any(mod(var,1)~=0)
                        Err = true;
                        ErrMsg = sprintf('%s should have integer values.',varname);
                        return;
                    end
                    
                otherwise
                    error('Unpredicted Error: The value input for name=''class'' in Check_Variable_Value_FFC is not valid');
                    
            end
            
        case 'size'
            
            if ~isequal(size(var),value)
                Err = true;
                ErrMsg = sprintf('The size of %s should be %dx%d.',varname,value(1),value(2));
                return;
            end
            
        case 'minsize'
            
            [m,n] = size(var);
            if m<value(1) || n<value(2)
                Err = true;
                ErrMsg = sprintf('The size of %s should be at least %dx%d.',varname,value(1),value(2));
                return;
            end
            
        case 'min'
            
            if any(min(var)<value)
                Err = true;
                ErrMsg = sprintf('The values of %s should be at least equal to %g.',varname,value);
                return;
            end
            
        case 'max'
            
            if any(max(var)>value)
                Err = true;
                ErrMsg = sprintf('The values of %s should be at most equal to %g.',varname,value);
                return;
            end
            
        case 'sum'
            
            if ~isequal(sum(var),value)
                Err = true;
                ErrMsg = sprintf('The sum of the values of %s should be equal to %g.',varname,value);
                return;
            end

        case 'min-prod'
            
            if prod(var)<value
                Err = true;
                ErrMsg = sprintf('The minimum of the products of values in %s should be at least to %g.',varname,value);
                return;
            end
            
        case 'possiblevalues'
            
            if ~any(cellfun(@(x)isequal(x,var),value))
                Err = true;
                ErrMsg = sprintf('The value of %s should be one of the pre-defined values.',varname);
                return;
            end
            
        case 'issorted'
            if ~isequal(var,sort(var,value))
                Err = true;
                ErrMsg = sprintf('Vector %s should be sorted with %sing order.',varname,value);
                return;
            end
            
        otherwise
            error('Unpredicted Error: The name input for Check_Variable_Value_FFC is not valid');
            
            
    end
end
