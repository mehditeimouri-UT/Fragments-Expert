function [output] = BFD_FFC(fragment,Range)

% This function employs the ByteHistogram_FFC function to calculate the
% distribution of the byte frequencies. Depending on the "Range" contents, the
% output would be different. 
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir> and Zahra
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
%   [output] = BFD_FFC(fragment,Range);
%
%   % example two
%   Range = num2cell(0:255)
%   [output] = BFD_FFC(fragment,Range);
%
% Inputs:
%   fragment: row vector of byte values
%   Range: "Range" is a cell array. If the ith element is a 1x2 vector, the corresponding output 
%       is the sum of the byte frequencies between the first element and the second element. If the ith
%       element is a scalar, the corresponding output is the byte frequency for that scalar value. 
%
% Outputs:
%   output: A row value containing frequencies of indexes in Range or a
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
% 2020-Mar-01   function was created

freq = ByteHistogram_FFC(fragment);
freq = freq*256;

if isequal(Range,num2cell(0:255))
    output = zeros(1,length(Range)+4);
else
    output = zeros(1,length(Range));
end

for i = 1:length(Range)
    range = Range{i};
    if length(range) == 1
        output(i)= freq(range+1);
    else
        from = range(1);
        to = range(end);
        output(i) = sum(freq(from+1:to+1));
    end
end

if isequal(Range,num2cell(0:255))
    % SdFreq: Standard deviation of the byte frequencies
    output(length(Range)+1) = StandardDeviation_FFC(freq);
    
    % ModesFreq: The sum of the four highest byte frequencies
    Modes = sort(freq,'descend');
    output(length(Range)+2) = sum(Modes(1:4));
    
    % CorNextFreq: Correlation of the frequencies of byte values m and m+1
    output(length(Range)+3) = Autocorrelation_FFC(freq,1);
    
    % ChiSq: P-value, for chi-square test of uniform distribution
    freq = freq/256*length(fragment);
    k = length(freq);
    observed = freq;
    expected = ones(1,k)*(length(fragment)/k);
    T = sum(((observed-expected).^2)./expected);
    output(length(Range)+4) = chi2cdf(T,k-1,'upper');
    
end