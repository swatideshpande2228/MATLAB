%Initializing counter
count = 0;

%Reading images from directory
Faultimages ='D:\MSc-Artificial Intelligence\Semester 2\Embedded Image Processing\Assignment 1\Images\6-CapMissing';
a=dir([Faultimages '/*.jpg']);
out=size(a,1);  %Gives the size of the directory

%%Predictions for noise images
%Underfilled
PredUnderfilled_noise1 = 0;
PredUnderfilled_noise2 = 0;
PredUnderfilled_noise3 = 0;
PredUnderfilled_noise4 = 0;

%%Predictions for noise images
%Missing Label
PredNoLabel_noise1 = 0;
PredNoLabel_noise2 = 0;
PredNoLabel_noise3 = 0;
PredNoLabel_noise4 = 0;

%%Predictions for noise images
%Cap Missing
PredCapMissing_noise1 = 0;
PredCapMissing_noise2 = 0;
PredCapMissing_noise3 = 0;
PredCapMissing_noise4 = 0;

%%Predictions for filter(Spatial) images for singel noise level
%Underfilled
PredUnderfilled_Gaussain_filter = 0;
PredUnderfilled_Mean_filter = 0;
PredUnderfilled_Median_filter = 0;

%%Predictions for filter(Frequency) images for singel noise level
%Underfilled
PredUnderfilled_Frequency_filter = 0;

%Predictons for filter for all noise variance
PredGausFilter_noise1 = 0;
PredGausFilter_noise2 = 0;
PredGausFilter_noise3 = 0;
PredGausFilter_noise4 = 0;

%Reading images in a loop
%SOURCE:https://in.mathworks.com/matlabcentral/answers/120073-how-to-read-multiple-jpg-images-in-a-loop
for s = 1:out
jpgfiles1=dir(fullfile(Faultimages,'\*.jpg*'));
m = numel(jpgfiles1(s));
Name=jpgfiles1(s).name;
ReadImageFault=imread(fullfile(Faultimages,Name));
count = count + 1;

%Adding noise to the images in increasing noise variance levels (0, 0.05, 0.1, 0.5)
for noise = 1:4
    if noise == 1
        noisyImage1 = imnoise(ReadImageFault, 'Gaussian', 0, 0.02);    %Adding  noise 1
        image1 = rgb2gray(noisyImage1);          %Converts rgb image to gray scale
    elseif noise == 2
        noisyImage2 = imnoise(ReadImageFault, 'Gaussian', 0, 0.05);    %Adding  noise 2
        image1 = rgb2gray(noisyImage2);          %Converts rgb image to gray scale
    elseif noise == 3
        noisyImage3 = imnoise(ReadImageFault, 'Gaussian', 0, 0.1);     %Adding  noise 3
        image1 = rgb2gray(noisyImage3);          %Converts rgb image to gray scale
    elseif noise == 4
        noisyImage4 = imnoise(ReadImageFault, 'Gaussian', 0, 0.5);     %Adding  noise 4
        image1 = rgb2gray(noisyImage4);          %Converts rgb image to gray scale
    end
   
%Displys the noise image
imshow(image1)

%%Predicting Noisy Images

%%Classifiying images that are Underfilled
%
rect = [120 100 130 100];                  %Underfilled region
Crop_noise = imcrop(image1, rect);         %Crops ROI for noise image
Binary_noise = imbinarize(Crop_noise, 0.5);
numWhitePixelsUnderfilled_noise = sum(Binary_noise(:));
numBlackPixelsUnderfilled_noise = sum(~Binary_noise(:));

if (numWhitePixelsUnderfilled_noise > 9700) && (numBlackPixelsUnderfilled_noise > 2300)   %To classify error rate for noise image
    if noise == 1
        PredUnderfilled_noise1 = PredUnderfilled_noise1 + 1;              %noise variance 1
    elseif noise == 2
        PredUnderfilled_noise2 = PredUnderfilled_noise2 + 1;              %noise variance 2
    elseif noise == 3
        PredUnderfilled_noise3 = PredUnderfilled_noise3 + 1;              %noise variance 3
    elseif noise == 4
        PredUnderfilled_noise4 = PredUnderfilled_noise4 + 1;              %noise variance 4
    end
end

%%Classifying images that have Missing Label
%
rect2 = [120 182 130 184];                   %Missing Label region
Crop2_noise = imcrop(image1, rect2);         %Crops ROI for noise image
Binary2_noise = imbinarize(Crop2_noise, 0.5);
numWhitePixelsLabelmissing_noise = sum(Binary2_noise(:));
numBlackPixelsLabelmissing_noise = sum(~Binary2_noise(:));

if (numBlackPixelsLabelmissing_noise > 13500)
     if noise == 1
        PredNoLabel_noise1 = PredNoLabel_noise1 + 1;
    elseif noise == 2
        PredNoLabel_noise2 = PredNoLabel_noise2 + 1;
    elseif noise == 3
        PredNoLabel_noise3 = PredNoLabel_noise3 + 1;
    elseif noise == 4
        PredNoLabel_noise4 = PredNoLabel_noise4 + 1;
     end
end

%%Classifying images that have Cap Missing
% 
rect5 = [90 5 120 50];                           %Cap Missing region
Crop5_noise = imcrop(image1, rect5);             %Crops ROI for noise image
Binary5_noise = imbinarize(Crop5_noise, 0.5);
numBlackPixelsCapMissing_noise = sum(~Binary5_noise(:));

if (numBlackPixelsCapMissing_noise < 100)
    if noise == 1
        PredCapMissing_noise1 = PredCapMissing_noise1 + 1;
    elseif noise == 2
        PredCapMissing_noise2 = PredCapMissing_noise2 + 1;
    elseif noise == 3
        PredCapMissing_noise3 = PredCapMissing_noise3 + 1;
    elseif noise == 4
        PredCapMissing_noise4 = PredCapMissing_noise4 + 1;
    end
end

%%Predicting Filtered Images
%Applying spatial domain filtering
for filter = 1:4
    if filter == 1
        image = imgaussfilt(image1,2);              %Gaussian filter of size 2
    elseif filter == 2
        k = ones(3,3)/9;
        image = imfilter(image1,k);                 %Mean filter
    elseif filter == 3
        image = medfilt2(image1);                   %Median filter
    elseif filter == 4
        %Taken from BlackBoard                      %Applying frequency domain filtering
        B=fft2(image1);
        B=fftshift(B);
        [rows, cols] = size(image1); 
        dim=5;
        mask=zeros(rows,cols); 
        mask(rows./2-dim:rows./2+dim,cols./2-dim:cols./2+dim)=1;
        % apply the filter (simple multiplication of the mask by the spectrum of
        % the image)
        B2 = B.*mask;
        image=abs(ifft2(B2));
    end
        
Crop = imcrop(image, rect);                %Crops the Region of Interest
Binary = imbinarize(Crop, 0.5);            %Converts image to binary
numWhitePixelsUnderfilled = sum(Binary(:)); 
numBlackPixelsUnderfilled = sum(~Binary(:));

%Classification of filtered images
if (numWhitePixelsUnderfilled > 9700) && (numBlackPixelsUnderfilled > 2300)    
    if (filter == 1) && (noise == 1)
        PredGausFilter_noise1 = PredGausFilter_noise1 + 1;
    elseif (filter == 1) && (noise == 2)
        PredGausFilter_noise2 = PredGausFilter_noise2 + 1;
    elseif (filter == 1) && (noise == 3)
        PredGausFilter_noise3 = PredGausFilter_noise3 + 1;
    elseif (filter == 1) && (noise == 4)
        PredUnderfilled_Gaussain_filter = PredUnderfilled_Gaussain_filter + 1;
        PredGausFilter_noise4 = PredGausFilter_noise4 + 1;
    elseif (filter == 2) && (noise == 4)
        PredUnderfilled_Mean_filter = PredUnderfilled_Mean_filter + 1;
    elseif (filter == 3) && (noise == 4)
        PredUnderfilled_Median_filter = PredUnderfilled_Median_filter + 1;
    elseif (filter == 4) && (noise == 1)
        PredUnderfilled_Frequency_filter = PredUnderfilled_Frequency_filter + 1;
    end
end

end

end
end

%Accuracy for noise images - Underfilled
AccuracyUnderfilled_noise1 = PredUnderfilled_noise1 / count * 100;
AccuracyUnderfilled_noise2 = PredUnderfilled_noise2 / count * 100;
AccuracyUnderfilled_noise3 = PredUnderfilled_noise3 / count * 100;
AccuracyUnderfilled_noise4 = PredUnderfilled_noise4 / count * 100;

%Accuracy for noise images - NoLabel
AccuracyNoLabel_noise1 = PredNoLabel_noise1 / count * 100;
AccuracyNoLabel_noise2 = PredNoLabel_noise2 / count * 100;
AccuracyNoLabel_noise3 = PredNoLabel_noise3 / count * 100;
AccuracyNoLabel_noise4 = PredNoLabel_noise4 / count * 100;

%Accuracy for noise images - CapMissing
AccuracyCapMissing_noise1 = PredCapMissing_noise1 / count * 100;
AccuracyCapMissing_noise2 = PredCapMissing_noise2 / count * 100;
AccuracyCapMissing_noise3 = PredCapMissing_noise3 / count * 100;
AccuracyCapMissing_noise4 = PredCapMissing_noise4 / count * 100;

%Accuracy for filtered(Spatial) images - Underfilled
AccuracyUnderfilled_Gaussian = PredUnderfilled_Gaussain_filter / count * 100;
AccuracyUnderfilled_Mean = PredUnderfilled_Mean_filter / count * 100;
AccuracyUnderfilled_Median = PredUnderfilled_Median_filter / count * 100;

%Accuracy for filtered(Frequency) images - Underfilled
AccuracyUnderfilled_Frequency = PredUnderfilled_Frequency_filter / count * 100;

%Accuracy for images all noise variance
Accuracy_GaussFilter_noise1 = PredGausFilter_noise1 / count * 100;
Accuracy_GaussFilter_noise2 = PredGausFilter_noise2 / count * 100;
Accuracy_GaussFilter_noise3 = PredGausFilter_noise3 / count * 100;
Accuracy_GaussFilter_noise4 = PredGausFilter_noise4 / count * 100;

%Print statements
fprintf('Total number of images processed : %i\n', count);

%Underfilled Noise images
if (PredUnderfilled_noise1 ~= 0)
fprintf('\n ****EVALUATION ON NOISE VARIANCE UNDERFILLED****\n');
fprintf('\nClassified as UnderFilled noise variance level 1 : %i\n', PredUnderfilled_noise1);
fprintf('Accuracy for Underfilled noise variance level 1: %i\n', AccuracyUnderfilled_noise1);
end
if (PredUnderfilled_noise2 ~= 0)
fprintf('\nClassified as UnderFilled noise variance level 2 : %i\n', PredUnderfilled_noise2);
fprintf('Accuracy for Underfilled noise variance level 2: %i\n', AccuracyUnderfilled_noise2);
end
if (PredUnderfilled_noise3 ~= 0)
fprintf('\nClassified as UnderFilled noise variance level 3 : %i\n', PredUnderfilled_noise3);
fprintf('Accuracy for Underfilled noise variance level 3: %i\n', AccuracyUnderfilled_noise3);
end
if (PredUnderfilled_noise3 ~= 0)
fprintf('\nClassified as UnderFilled noise variance level 4 : %i\n', PredUnderfilled_noise4);
fprintf('Accuracy for Underfilled noise variance level 4: %i\n', AccuracyUnderfilled_noise4);
end

%NoLabel Noise images
if (PredNoLabel_noise1 ~= 0)
fprintf('\n ****EVALUATION ON NOISE VARIANCE NO LABEL****\n');
fprintf('\nClassified as NoLabel noise variance level 1 : %i\n', PredNoLabel_noise1);
fprintf('Accuracy for NoLabel noise variance level 1: %i\n', AccuracyNoLabel_noise1);
end
if (PredNoLabel_noise2 ~= 0)
fprintf('\nClassified as NoLabel noise variance level 2 : %i\n', PredNoLabel_noise2);
fprintf('Accuracy for NoLabel noise variance level 2: %i\n', AccuracyNoLabel_noise2);
end
if (PredNoLabel_noise3 ~= 0)
fprintf('\nClassified as NoLabel noise variance level 3 : %i\n', PredNoLabel_noise3);
fprintf('Accuracy for NoLabel noise variance level 3: %i\n', AccuracyNoLabel_noise3);
end
if (PredNoLabel_noise3 ~= 0)
fprintf('\nClassified as NoLabel noise variance level 4 : %i\n', PredNoLabel_noise4);
fprintf('Accuracy for NoLabel noise variance level 4: %i\n', AccuracyNoLabel_noise4);
end

%CapMissing Noise images
if (PredCapMissing_noise1 ~= 0)
fprintf('\n ****EVALUATION ON NOISE VARIANCE CAP MISSING****\n');
fprintf('\nClassified as CapMissing noise variance level 1 : %i\n', PredCapMissing_noise1);
fprintf('Accuracy for CapMissing noise variance level 1: %i\n', AccuracyCapMissing_noise1);
end
if (PredCapMissing_noise1 ~= 0)
fprintf('\nClassified as CapMissing noise variance level 2 : %i\n', PredCapMissing_noise2);
fprintf('Accuracy for CapMissing noise variance level 2: %i\n', AccuracyCapMissing_noise2);
end
if (PredCapMissing_noise1 ~= 0)
fprintf('\nClassified as CapMissing noise variance level 3 : %i\n', PredCapMissing_noise3);
fprintf('Accuracy for CapMissing noise variance level 3: %i\n', AccuracyCapMissing_noise3);
end
if (PredCapMissing_noise1 ~= 0)
fprintf('\nClassified as CapMissing noise variance level 4 : %i\n', PredCapMissing_noise4);
fprintf('Accuracy for CapMissing noise variance level 4: %i\n', AccuracyCapMissing_noise4);
end

%Underfilled Filter(Spatial) images
if (PredUnderfilled_Gaussain_filter ~= 0)
fprintf('\n ****EVALUATION USING SPATIAL FILTERS FOR OPERATING POINT****\n');
fprintf('\nClassified as UnderFilled for Gaussian Filter noise level 4: %i\n', PredUnderfilled_Gaussain_filter);
fprintf('Accuracy for Underfilled Gaussian Filter noise level 4: %i\n', AccuracyUnderfilled_Gaussian);
end

if (PredUnderfilled_Mean_filter ~= 0)
fprintf('\nClassified as UnderFilled for Mean Filter noise level 4: %i\n', PredUnderfilled_Mean_filter);
fprintf('Accuracy for Underfilled Mean Filter noise level 4: %i\n', AccuracyUnderfilled_Mean);
end

if (PredUnderfilled_Median_filter ~= 0)
fprintf('\nClassified as UnderFilled for Median Filter noise level 4: %i\n', PredUnderfilled_Median_filter);
fprintf('Accuracy for Underfilled Median Filter noise level 4: %i\n', AccuracyUnderfilled_Median);
end

%Underfilled Filter(Frequency) images
if (PredUnderfilled_Median_filter ~= 0)
fprintf('\n ****EVALUATION USING FREQUENCY FILTERS FOR OPERATING POINT****\n');
fprintf('\nClassified as UnderFilled for Frequency Filter noise level 4: %i\n', PredUnderfilled_Frequency_filter);
fprintf('Accuracy for Underfilled Frequency Filter noise level 4: %i\n', AccuracyUnderfilled_Frequency);
end

%Gaussian Filter for all noise variance
if (PredGausFilter_noise1 ~= 0)
fprintf('\n ****EVALUATION USING BEST FILTER FOR ALL NOISE VARIANCE****\n');
fprintf('\nClassified as UnderFilled for Gaussian Filter noise level 1: %i\n', PredGausFilter_noise1);
fprintf('Accuracy for Underfilled Gaussian Filter noise level 1: %i\n', Accuracy_GaussFilter_noise1);
end

if (PredGausFilter_noise2 ~= 0)
fprintf('\nClassified as UnderFilled for Gaussian Filter noise level 2: %i\n', PredGausFilter_noise2);
fprintf('Accuracy for Underfilled Gaussian Filter noise level 2: %i\n', Accuracy_GaussFilter_noise2);
end

if (PredGausFilter_noise3 ~= 0)
fprintf('\nClassified as UnderFilled for Gaussian Filter noise level 3: %i\n', PredGausFilter_noise3);
fprintf('Accuracy for Underfilled Gaussian Filter noise level 3: %i\n', Accuracy_GaussFilter_noise3);
end

if (PredGausFilter_noise4 ~= 0)
fprintf('\nClassified as UnderFilled for Gaussian Filter noise level 4: %i\n', PredGausFilter_noise4);
fprintf('Accuracy for Underfilled Gaussian Filter noise level 4: %i\n', Accuracy_GaussFilter_noise4);
end

%%Plots for noisy images
%Plotting the graph for performance against noise
Noise = [0.02, 0.05, 0.1, 0.5];

if (PredUnderfilled_noise1 ~= 0)
Underfilled = [AccuracyUnderfilled_noise1, AccuracyUnderfilled_noise2, AccuracyUnderfilled_noise3, AccuracyUnderfilled_noise4];
figure()
plot(Noise, Underfilled)
title('Performance of noise images - Underfilled')
xlabel('Noise Variance') 
ylabel('Accuracy')
end

if (PredNoLabel_noise1 ~= 0)
NoLabel = [AccuracyNoLabel_noise1, AccuracyNoLabel_noise2, AccuracyNoLabel_noise3, AccuracyNoLabel_noise4];
figure()
plot(Noise, NoLabel)
title('Performance of noise images - NoLabel')
xlabel('Noise Variance') 
ylabel('Accuracy')
end

if (PredCapMissing_noise1 ~= 0)
CapMissing = [AccuracyCapMissing_noise1, AccuracyCapMissing_noise2, AccuracyCapMissing_noise3, AccuracyCapMissing_noise4];
figure()
plot(Noise, CapMissing)
title('Performance of noise images - CapMissing')
xlabel('Noise Variance') 
ylabel('Accuracy')
end

%%Plot for filtered images
%Plotting the graph for performance against filtered images

if (PredGausFilter_noise1 ~= 0)
FilteredUnderfilled = [Accuracy_GaussFilter_noise1, Accuracy_GaussFilter_noise2, Accuracy_GaussFilter_noise3, Accuracy_GaussFilter_noise4];
figure()
plot(Noise, FilteredUnderfilled)
title('Performance of Filtered images - Gaussian Filter')
xlabel('Noise Variance') 
ylabel('Accuracy')
end