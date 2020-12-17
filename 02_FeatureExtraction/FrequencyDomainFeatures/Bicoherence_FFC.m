function b = Bicoherence_FFC(y)

% This function returns the average of bicoherence calculated according to [1].
%
%   [1] Swami A, Mendel JM, Nikias CL. Higher-order spectral analysis toolbox. The Mathworks Inc. 1998;3:22-6.
%
% Copyright (C) 2020 Mehdi Teimouri <mehditeimouri [at] ut.ac.ir>
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
%
% Inputs:
%   fragment: row vector of byte values
%
% Outputs:
%   b: Average of Bicoherence
%
% Revisions:
% 2020-May-14   function was created

%% Persistent Variable
persistent h H

%% Default Parameters
nfft = 128;
overlap = nfft/2;
if isempty(h)
    h = hanning(nfft);
    H = hankel((1:nfft),[nfft (1:nfft-1)]);
end

%% Initialize
y = reshape(y,[],1);
rep = floor((length(y)-nfft)/(nfft-overlap))+1;
if rep<1 % No FFT Can be calculated
    b = 0;
    return;
end

%% Calculate Bicoherence
S  = zeros(nfft,nfft);
Pyy  = zeros(nfft,1);
Y0f12 = zeros(nfft,nfft);
idx  = (1:nfft);
for j = 1:rep
    y0 = y(idx);
    y0 = (y0-mean(y0)).*h;
    Y0f = fft(y0,nfft)/nfft;    
    CY0f = conj(Y0f);
    
    Pyy = Pyy+Y0f.*CY0f;
    Y0f12(:) = CY0f(H);
    S = S+(Y0f*Y0f.').*Y0f12;
    idx = idx+(nfft-overlap);
end

S = S/rep;
Pyy = Pyy/rep;
S = abs(S).^2./((Pyy*Pyy.').*Pyy(H));
b = mean(S(:));
if isnan(b)
    b = -1;
end