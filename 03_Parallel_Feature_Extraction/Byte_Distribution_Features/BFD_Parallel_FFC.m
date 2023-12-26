function [outputs] = BFD_Parallel_FFC(fragments,Range)

% This function employs the ByteHistogram_FFC function to calculate the
% distribution of the byte frequencies. Depending on the "Range" contents, the
% output would be different.
%
% Copyright (C) 2023 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
% Seyedghorban
%
% This file is a part of Fragments-Expert software, a software package for
% feature extraction from file fragments and classification among various file formats.
%
% Fragments-Expert software is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
%
% Fragments-Expert software is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program.
% If not, see <http://www.gnu.org/licenses/>.
%
% Examples:
%   % example one
%   Range = {[0 31] , [32 192] , [193 255]}; %Labels = {'LowAscii' , 'MeduimAscii' , 'HighAscii'};
%   [output] = BFD_Parallel_FFC(fragments,Range);
%
%   % example two
%   Range = num2cell(0:255)
%   [output] = BFD_Parallel_FFC(fragments,Range);
%
% Inputs:
%   fragments: Cell array with length M consisting of row vectors of byte values
%   Range: "Range" is a cell array. If the ith element is a 1x2 vector, the corresponding output
%       is the sum of the byte frequencies between the first element and the second element. If the ith
%       element is a scalar, the corresponding output is the byte frequency for that scalar value.
%
% Outputs:
%   output: A matrix, whose rows contain frequencies of indexes in Range or a
%       scalar representing the number of bytes values within the desired
%       Range.
%
%   Note: If range is equal to num2cell(0:255), four more features are
%   appended to the end of the output.
%       SdFreq: Standard deviation of the byte frequencies [1].
%       ModesFreq: The sum of the four highest byte frequencies [1].
%       CorNextFreq: Correlation of the frequencies of byte values m and m+1 [1].
%       ChiSq: P-value, for chi-square test of uniform distribution [2].
%   Reference:
%       [1]	W. C. Calhoun and D. Coles, "Predicting the types of file fragments," Digital Investigation, vol. 5, pp. S14-S20, 2008.
%       [2] G. Conti, S. Bratus, A. Shubina, B. Sangster, R. Ragsdale, M. Supan, et al., "Automated mapping of large binary objects
%           using primitive fragment type classification," digital investigation, vol. 7, pp. S3-S12, 2010.
%
% Revisions:
% 2023-Dec-24   function was created

freq = ByteHistogram_Parallel_FFC(fragments);
freq = freq*256;
M = length(fragments);

if isequal(Range,num2cell(0:255))
    outputs = zeros(M,length(Range)+4);
else
    outputs = zeros(M,length(Range));
end

if isequal(Range,num2cell(0:255))
    outputs(:,1:length(Range)) = freq;
else
    for i = 1:length(Range)
        range = Range{i};
        if length(range) == 1
            outputs(:,i)= freq(:,range+1);
        else
            from = range(1);
            to = range(end);
            outputs(:,i) = sum(freq(:,from+1:to+1),2);
        end
    end
end

if isequal(Range,num2cell(0:255))
    
    % SdFreq: Standard deviation of the byte frequencies
    outputs(:,length(Range)+1) = std(freq,0,2);
    
    % ModesFreq: The sum of the four highest byte frequencies
    Modes = sort(freq,2,'descend');
    outputs(:,length(Range)+2) = sum(Modes(:,1:4),2);
    
    % CorNextFreq: Correlation of the frequencies of byte values m and m+1
    AutoCorrs = zeros(M,1);
    parfor j=1:M
        
        AutoCorr = autocorr(freq(j,:),1);
        AutoCorr = AutoCorr(2);
        AutoCorr(isnan(AutoCorr)) = 1; % NaN is obtained when the variance is equal to zero
        AutoCorrs(j,:) = AutoCorr;
        
    end
    outputs(:,length(Range)+3) = AutoCorrs;
    
    % ChiSq: P-value, for chi-square test of uniform distribution
    parfor j=1:M
        
        fr = freq(j,:);
        L_frg = length(fragments{j});
        fr = fr/256*L_frg;
        k = 256;
        expected = ones(1,k)*(L_frg/k);
        T = sum(((fr-expected).^2)./expected);
        outputs(j,end) = chi2cdf(T,k-1,'upper');
    end
    
end