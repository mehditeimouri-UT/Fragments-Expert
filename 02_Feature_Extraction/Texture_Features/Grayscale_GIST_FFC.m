function F = Grayscale_GIST_FFC(fragment,rowsize,orientPerScale,numBlks)

% This function computes the gist features for the equaivalent gray scale image 
% corresponding to a fragment. The function works based on the method proposed in [1] 
% and the codes available at https://people.csail.mit.edu/torralba/code/spatialenvelope.
%
%   [1] Aude Oliva and Antonio Torralba, "Modeling the shape of the scene: a holistic representation of the
%   spatial envelope", International Journal of Computer Vision, Vol. 42(3): 145-175, 2001.
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
% Inputs:
%   fragment: Row vector of byte values
%   rowsize: The number of elements when converting fragments into image
%   orientPerScale: Number of orientations at each scale (a vector of integers)
%   numBlks: Number of non-overlapping windows in each dimension
%
% Outputs:
%   F: vector of Gist features with length sum(orientPerScale)*numBlks^2;
%
% Revisions:
% 2020-Mar-29   function was created

%% Initialization
imageSize = [256 256];
boundaryExtension = 32;
fc_prefilt = 4;
img = vec2mat(fragment,rowsize);

%% Persistent Variables: Create Gabor Filters
persistent G orientationsPerScale numberBlocks

if ~(isequal(orientPerScale,orientationsPerScale) && isequal(numBlks,numberBlocks))
    orientationsPerScale = orientPerScale;
    numberBlocks = numBlks;
    G = createGabor(orientationsPerScale,imageSize+2*boundaryExtension);
end

%% Resize and crop image to make it square
img = imresizecrop(img, imageSize);

%% Scale intensities to be in the range [0 255]
img = img-min(img(:));
img = 255*img/max(img(:));

%% Prefiltering: local contrast scaling
output = prefilt(img, fc_prefilt);

%% Get GIST
F = gistGabor(output,numberBlocks,G,boundaryExtension)';
F(isnan(F)) = -1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function output = prefilt(img, fc)

% ima = prefilt(img, fc);
%
% Input images are double in the range [0, 255];

w = 5;
s1 = fc/sqrt(log(2));

% Pad images to reduce boundary artifacts
img = log(img+1);
img = padarray(img, [w w], 'symmetric');
[sn, sm] = size(img);
n = max([sn sm]);
n = n + mod(n,2);
img = padarray(img, [n-sn n-sm], 'symmetric','post');

% Filter
[fx, fy] = meshgrid(-n/2:n/2-1);
gf = fftshift(exp(-(fx.^2+fy.^2)/(s1^2)));

% Whitening
output = img - real(ifft2(fft2(img).*gf));

% Local contrast normalization
localstd = sqrt(abs(ifft2(fft2(mean(output,3).^2).*gf(:,:,1,:)))); 
output = output./(.2+localstd);

% Crop output to have same size than the input
output = output(w+1:sn-w, w+1:sm-w);

function g = gistGabor(img,numberBlocks,G,boundaryExtension)
% 
% Input:
%   img: input image
%   numberBlocks: number of windows (w*w)
%   G: precomputed transfer functions
%
% Output:
%   g: are the global features = [Nfeatures 1], 
%                    Nfeatures = numberBlocks*Nfilters

[ny,nx,Nfilters] = size(G);
W = numberBlocks*numberBlocks;
g = zeros([W*Nfilters 1]);

% pad image
img = padarray(img, [boundaryExtension boundaryExtension], 'symmetric');

img = single(fft2(img)); 
k=0;
for n = 1:Nfilters
    ig = abs(ifft2(img.*G(:,:,n))); 
    ig = ig(boundaryExtension+1:ny-boundaryExtension, boundaryExtension+1:nx-boundaryExtension, :);
    
    v = downN(ig, numberBlocks);
    g(k+1:k+W,:) = reshape(v, [W 1]);
    k = k + W;
end

function y=downN(x, N)

% averaging over non-overlapping square image blocks
%
% Input
%   x = [nrows ncols]
% Output
%   y = [N N]

nx = fix(linspace(0,size(x,1),N+1));
ny = fix(linspace(0,size(x,2),N+1));
y  = zeros(N,N);
for xx=1:N
  for yy=1:N
    y(xx,yy) = mean(mean(x(nx(xx)+1:nx(xx+1), ny(yy)+1:ny(yy+1)),1),2);
  end
end


function G = createGabor(numberOfOrientationsPerScale, n)

% G = createGabor(numberOfOrientationsPerScale, n);
%
% Precomputes filter transfer functions. All computations are done on the
% Fourier domain.
%
% Input
%     numberOfOrientationsPerScale = vector that contains the number of orientations at each scale (from HF to BF)
%     n = imagesize = [nrows ncols]
%
% output
%     G = transfer functions for a jet of gabor filters

Nscales = length(numberOfOrientationsPerScale);
Nfilters = sum(numberOfOrientationsPerScale);

if length(n) == 1
    n = [n(1) n(1)];
end

param = zeros(sum(numberOfOrientationsPerScale),4);
l=0;
for i=1:Nscales
    for j=1:numberOfOrientationsPerScale(i)
        l=l+1;
        param(l,:)=[.35 .3/(1.85^(i-1)) 16*numberOfOrientationsPerScale(i)^2/32^2 pi/(numberOfOrientationsPerScale(i))*(j-1)];
    end
end

% Frequencies:
[fx, fy] = meshgrid(-n(2)/2:n(2)/2-1, -n(1)/2:n(1)/2-1);
fr = fftshift(sqrt(fx.^2+fy.^2));
t = fftshift(angle(fx+sqrt(-1)*fy));

% Transfer functions:
G=zeros([n(1) n(2) Nfilters]);
for i=1:Nfilters
    tr=t+param(i,4);
    tr=tr+2*pi*(tr<-pi)-2*pi*(tr>pi);
    
    G(:,:,i)=exp(-10*param(i,1)*(fr/n(2)/param(i,2)-1).^2-2*param(i,3)*pi*tr.^2);
end

function img = imresizecrop(img,M)

scaling = max([M(1)/size(img,1) M(2)/size(img,2)]);

newsize = round([size(img,1) size(img,2)]*scaling);
img = imresize(img, newsize, 'bilinear');

[nr,nc,~] = size(img);

sr = floor((nr-M(1))/2);
sc = floor((nc-M(2))/2);

img = img(sr+1:sr+M(1), sc+1:sc+M(2),:);