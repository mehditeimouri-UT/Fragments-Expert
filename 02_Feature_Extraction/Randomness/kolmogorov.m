function complexity = kolmogorov(s)

% This function estimates the algorithmic complexity of S using the method proposed in [1].
%   [1] Kaspar, F., and H. G. Schuster. "Easily calculable measure for the complexity of spatiotemporal patterns." 
%       Physical Review A 36.2 (1987): 842.
%
% Copyright (C) 2005 Stephen Faul <stephenf@rennes.ucc.ie>
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
% Input:
%   s: A fragments of bytes
%
% Outputs:
%   complexity: Normalized algorithmic complexity of s
%
% Revisions:
% 2005-Feb-09   The first version was written by Stephen Faul. 
% 2020-Mar-17   In order to normalize complexity, it is divided by fragment length.
%               For file fragment classification, it seems to be a better
%               normalization.

%% Algorithm
n=length(s);
complexity=1;
l=1;
i=0;
k=1;
k_max=1;
stop=0;
while stop==0
	if s(i+k)~=s(l+k)
        if k>k_max
            k_max=k;
        end
        i=i+1;
        
        if i==l
            complexity=complexity+1;
            l=l+k_max;
            if l+1>n
                stop=1;
            else
                i=0;
                k=1;
                k_max=1;
            end
        else
            k=1;
        end
	else
        k=k+1;
        if l+k>n
            complexity=complexity+1;
            stop=1;
        end
	end
end

%% Output
complexity=complexity/n;