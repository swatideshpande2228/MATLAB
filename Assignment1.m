%Initializing counter
count = 0;
PredUnderfilled = 0;
PredOverfilled = 0;
PredNolabel = 0;
PredNolabelPrint = 0;
PredCapMissing = 0;
PredDeformed = 0;
PredLabelNotStraightOverfilled = 0;

%Reading images from directory
Faultimages ='D:\MSc-Artificial Intelligence\Semester 2\Embedded Image Processing\Assignment 1\Images\Combinations of faults';
a=dir([Faultimages '/*.jpg']);
out=size(a,1);  %Gives the size of the directory

%Reading images in a loop
%SOURCE:https://in.mathworks.com/matlabcentral/answers/120073-how-to-read-multiple-jpg-images-in-a-loop
for s = 1:out
jpgfiles1=dir(fullfile(Faultimages,'\*.jpg*'));
m = numel(jpgfiles1(s));
Name=jpgfiles1(s).name;
ReadImageFault=imread(fullfile(Faultimages,Name));
count = count + 1;

%Displays the fault image
imshow(ReadImageFault)

%Classifiying images that are Underfilled
%
image = rgb2gray(ReadImageFault);          %Converts rgb image to gray scale
rect = [120 100 130 100];                  %Underfilled region
Crop = imcrop(image, rect);                %Crops the Region of Interest
Binary = imbinarize(Crop, 0.5);          %Converts image to binary
numWhitePixelsUnderfilled = sum(Binary(:));
numBlackPixelsUnderfilled = sum(~Binary(:));

if (numWhitePixelsUnderfilled > 9700) && (numBlackPixelsUnderfilled > 2300)
    PredUnderfilled = PredUnderfilled + 1;
end

%%Classifying images that are Overfilled
%
rect1 = [120 76 130 76];                                %Overfilled region
Crop1 = imcrop(image, rect1);               %Crops the Region of Interest
Binary1 = imbinarize(Crop1, 0.5);              %Converts image to binary
numWhitePixelsOverfilled = sum(Binary1(:)); 
numBlackPixelsOverfilled = sum(~Binary1(:));

if (numBlackPixelsOverfilled > 5000) && (numBlackPixelsOverfilled < 7000)
    PredOverfilled = PredOverfilled + 1;
end

%%Classifying images that have Missing Label
%
rect2 = [120 182 130 184];
Crop2 = imcrop(image, rect2);
Binary2 = imbinarize(Crop2, 0.5);
numWhitePixelsLabelmissing = sum(Binary2(:));
numBlackPixelsLabelmissing = sum(~Binary2(:));

if (numBlackPixelsLabelmissing > 13500)
   PredNolabel = PredNolabel + 1;
end

%%Classifying images that have No Label Print
%
rect3 = [120 182 130 184];
Crop3 = imcrop(image, rect3);
Binary3 = imbinarize(Crop3, 0.5);
numWhitePixelsNoLabelPrint = sum(Binary3(:));
numBlackPixelsNoLabelPrint = sum(~Binary3(:));

if (numWhitePixelsNoLabelPrint > 11000) && (numBlackPixelsNoLabelPrint > 2000)
   PredNolabelPrint = PredNolabelPrint + 1;
end

%%Classifying images that have Label Not Straight
%
rect4Fault = [120 180 110 30];
rectOver = [120 96 100 30];
Crop4Fault = imcrop(image, rect4Fault);
CropOver = imcrop(image, rectOver);
Binary4Fault = imbinarize(Crop4Fault, 0.5);
BinaryOver = imbinarize(CropOver, 0.5);

numWhitePixelsFault = sum(Binary4Fault(:));
numBlackPixelsFault = sum(~Binary4Fault(:));
numBlackPixelsOver = sum(~BinaryOver(:));

if (numWhitePixelsFault ~= 0) && (numBlackPixelsOver ~= 0) && (numWhitePixelsFault < 810) && (numBlackPixelsOver < 1000) && (numBlackPixelsFault > 2600)
   PredLabelNotStraightOverfilled = PredLabelNotStraightOverfilled + 1;
end

%%Classifying images that have Cap Missing
%
rect5 = [90 5 120 50];
Crop5 = imcrop(image, rect5);
Binary5 = imbinarize(Crop5, 0.5);
numBlackPixelsCapMissing = sum(~Binary5(:));

if (numBlackPixelsCapMissing < 100) && (numBlackPixelsOver > 950)
   PredCapMissing = PredCapMissing + 1;
end

%%Classifying images that are Deformed
%
% SOURCE: https://uk.mathworks.com/matlabcentral/answers/398610-how-to-evaluate-the-height-and-width-of-an-object-in-bw-image
rect6Fault = [130 10 120 300];
Rect = [200 100 60 100];
Crop6Fault = imcrop(image, rect6Fault);
Crop88 = imcrop(image, Rect);
Binary = imbinarize(Crop6Fault, 0.5);
Binary88 = imbinarize(Crop88, 0.5);
BW = edge(Crop6Fault);
[r1,c1] = find(BW);
y2 = max(c1);
y1 = min(c1);
Y = y2 - y1;   %Calculates the width

x2 = max(r1);
x1 = min(r1);
X = x2 - x1;     %Calculates the length

numBlackPixelsDeformed = sum(~Binary(:));
numWhitePixelsDeformed = sum(Binary(:));

BlackPixels = sum(~Crop6Fault(:));
WhitePixels = sum(Crop6Fault(:));

numBlackPixels = sum(~Binary88(:));
numWhitePixels = sum(Binary88(:));

if (Y <= 120) && (X >= 276) && (X <= 277) && (numBlackPixelsDeformed > 13000) && (numWhitePixelsDeformed < 20000) && (BlackPixels < 30) && (WhitePixels < 5050000) && (WhitePixels > 4600000) && (numBlackPixels > 2280) && (numWhitePixels > 2450)
   PredDeformed = PredDeformed + 1;
end

end
TotalCount = count - (PredLabelNotStraightOverfilled + PredDeformed + PredCapMissing + PredNolabelPrint + PredNolabel + PredOverfilled + PredUnderfilled);

%Accuracy
AccuracyUnderfilled = PredUnderfilled / count * 100;
AccuracyOverfilled = PredOverfilled / count * 100;
AccuracyNolabel = PredNolabel / count * 100; 
AccuracyNolabelPrint = PredNolabelPrint / count * 100;
AccuracyCapMissing = PredCapMissing / count * 100;
AccuracyDeformed = PredDeformed / count * 100;
AccuracyLabelNotStraightOverfilled = PredLabelNotStraightOverfilled / count * 100;
AccuracyTotalCount = TotalCount / count * 100;

%Print statements
fprintf('Total number of images processed : %i\n', count);

if (PredUnderfilled ~= 0)
fprintf('\nClassified as UnderFilled : %i\n', PredUnderfilled);
fprintf('Accuracy for Underfilled : %i\n', AccuracyUnderfilled);
end

if (PredOverfilled ~= 0)
fprintf('\nClassified as OverFilled : %i\n', PredOverfilled);
fprintf('Accuracy for Overfilled : %i\n', AccuracyOverfilled);
end

if (PredNolabel ~= 0)
fprintf('\nClassified as NoLabel : %i\n', PredNolabel);
fprintf('Accuracy for NoLabel : %i\n', AccuracyNolabel);
end

if (PredNolabelPrint ~= 0)
fprintf('\nClassified as NoLabelPrint : %i\n', PredNolabelPrint);
fprintf('Accuracy for NoLabelPrint : %i\n', AccuracyNolabelPrint);
end

if (PredCapMissing ~= 0)
fprintf('\nClassified as Cap Missing and Overfilled : %i\n', PredCapMissing);
fprintf('Accuracy for CapMissing : %i\n', AccuracyCapMissing);
end

if (PredDeformed ~= 0)
fprintf('\nClassified as Deformed : %i\n', PredDeformed);
fprintf('Accuracy for Deformed : %i\n', AccuracyDeformed);
end

if (PredLabelNotStraightOverfilled ~= 0)
fprintf('\nClassified as LabelNotStraight and Overfilled : %i\n', PredLabelNotStraightOverfilled);
fprintf('Accuracy for LabelNotStraight : %i\n', AccuracyLabelNotStraightOverfilled);
end

if (TotalCount ~= 0)
fprintf('\nClassified as Normal : %i\n', TotalCount);
fprintf('Accuracy for Normal : %i\n', AccuracyTotalCount);
end
