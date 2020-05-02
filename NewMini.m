%% TESTING ON DEVELOPMENT DATASET
InputDir = 'C:\Swati\image processing\Images\Development dataset\20Kph\100Kph';  %Development Dataset
DetectDigits(InputDir)           %Calling DetectDigit Function

%% TESTING ON STRESS DATASET
%StressDir = 'C:\Swati\image processing\Images\Development dataset\20Kph\stress dataset';  %Development Dataset
%StressData(StressDir)           %Calling DetectDigit Function


function Classification(TestImage)
   goldDigitsDir = 'C:\Swati\image processing\Images\GoldStandards V2(1)';   %GoldStandard Dataset
   %Reading images from directory
   Stdimages = goldDigitsDir;
   b=dir([goldDigitsDir '/*.jpg']);
   out1=size(b,1);  %Gives the size of the directory
   %Reading images in a loop
   %SOURCE:https://in.mathworks.com/matlabcentral/answers/120073-how-to-read-multiple-jpg-images-in-a-loop
   for r = 1:out1
       jpgfiles1=dir(fullfile(Stdimages,'\*.jpg*'));
       Name=jpgfiles1(r).name;
       ReadStdImage=imread(fullfile(Stdimages,Name));
       % Resize image
       ReadStdImage = imresize(ReadStdImage, [500, 500]); %resizes the image
       ImageCbCr = rgb2ycbcr(ReadStdImage);               %converts image to ycbcr
       max = 75.0;
       min = 0.0;
       img = (ImageCbCr(:, :, 1) >= min) & (ImageCbCr(:, :, 1) <= max);    %gets the black digits
       bw1 = bwlabel(img);                                                 %labels each object
       statsgold = regionprops(bw1, 'BoundingBox');                        %BoundingBox
       for j = 1 : length(statsgold)
        box = statsgold(j).BoundingBox;
        GoldROIimg = imcrop(img, box);
        WP = sum(GoldROIimg(:));
        %Storing Templates
        if WP == 5347
            Temp_100 = GoldROIimg;         %Template for speed 100
        elseif WP == 15146
            Temp_40 = GoldROIimg;          %Template for speed 40
        elseif WP == 15006
            Temp_20 = GoldROIimg;          %Template for speed 20
        elseif WP == 14962
            Temp_30 = GoldROIimg;          %Template for speed 30
        elseif WP == 15599
            Temp_50 = GoldROIimg;          %Template for speed 50
        elseif WP == 6194
            Temp_80 = GoldROIimg;          %Template for speed 80
        Classifier(TestImage, Temp_100, Temp_40, Temp_20, Temp_30, Temp_50, Temp_80)   %Calls the classifier
        end
        end
       end
end
   
function Classifier(TestImage, img_100, img_40, img_20, img_30, img_50, img_80)
% Digit Percentage
AreaWhitePixels = sum(TestImage(:));

% Making same shapes for both test and train images
Test = imhist(TestImage);
True_100 = imhist(img_100);
True_30 = imhist(img_30);
True_50 = imhist(img_50);
True_80 = imhist(img_80);
True_20 = imhist(img_20);

%Eucleadin Distances
Distance_100 = sqrt(sum((Test - True_100).^2));

Distance_80 = sqrt(sum((Test - True_80).^2));

Distance_50 = sqrt(sum((Test - True_50).^2));

Distance_30 = sqrt(sum((Test - True_30).^2));

Distance_20 = sqrt(sum((Test - True_20).^2));

%Classifying conditions
if (Distance_100 < 4.0257e+03) && (Distance_100 > 1.1832e+03) && (AreaWhitePixels > 2000) && (AreaWhitePixels < 4614)
    fprintf('\nSpeed Detected is 100');
end

if (Distance_30 > 8.379e+03) && (AreaWhitePixels > 5000) && (AreaWhitePixels < 7000)
   fprintf('\nSpeed Detected is 30');
end

if (Distance_50 < 8.1106e+03) && (Distance_50 > 1.2422e+03) && (AreaWhitePixels > 2830) && (AreaWhitePixels < 12000)
   fprintf('\nSpeed Detected is 50');
end

if (Distance_80 > 5.3979e+03) && (Distance_80 < 9.8333e+03) && (AreaWhitePixels > 7000) && (AreaWhitePixels < 10000)
   fprintf('\nSpeed Detected is 80');
end

if (Distance_20 >= 5.5849e+03) && (Distance_20 <= 9.3584e+03) && (AreaWhitePixels > 2100) && (AreaWhitePixels < 10000)
    fprintf('\nSpeed Detected is 20');   
end
end

function DetectDigits(InputDir)
   %Reading images from directory
   Devpimages = InputDir;
   a=dir([Devpimages '/*.jpg']);
   out=size(a,1);  %Gives the size of the directory
   fprintf('Reading the Images');
   %Reading images in a loop
   %SOURCE:https://in.mathworks.com/matlabcentral/answers/120073-how-to-read-multiple-jpg-images-in-a-loop
   for s = 1:out
       jpgfiles1=dir(fullfile(Devpimages,'\*.jpg*'));
       Name=jpgfiles1(s).name;
       ReadDevpImage=imread(fullfile(Devpimages,Name));
       % Resize image
       ReadImage = imresize(ReadDevpImage, [500, 500]);
       DetectCircles(ReadImage);
   end
end

function DetectCircles(Image)
     %detecting red circles
      RedCircles = imsubtract(Image(:,:,1), rgb2gray(Image));     %subtracts the red colour from gray image
      RedCircles = imbinarize(RedCircles, 0.2); 
      FullCircles = sum(RedCircles(:));
      if (FullCircles < 4000)
          DetectSpeed80(Image)
      elseif (FullCircles < 35000) && (FullCircles > 20000)
          DetectSpeed100(Image)
      elseif (FullCircles > 50000)
          DetectSpeed20_30_50(Image)
      end
end

function DetectSpeed80(Imge)
    ExtractROI(Imge)
end

function DetectSpeed100(Imge)
    ExtractROI(Imge)
end

function DetectSpeed20_30_50(Imge)
    ExtractROI(Imge)
end

function ExtractROI(InputImg)
    ImageCbCr = rgb2ycbcr(InputImg);
       max = 85.0;
       min = 0.0;
       img = (ImageCbCr(:, :, 1) >= min) & (ImageCbCr(:, :, 1) <= max);
       rect = [140 180 210 200];   %Extracting ROI
       ROI = imcrop(img, rect);
       ROI = imclearborder(ROI, 8);   %clears the border pixels
       ROI = bwareaopen(ROI,2000);    %removes pixels with area less than 2000
       bw = bwlabel(ROI);             %labels objects
       stats = regionprops(bw, 'BoundingBox');
       for i = 1 : length(stats)
         box = stats(i).BoundingBox;
         ROIimg = imcrop(ROI, box);
         Classification(ROIimg)       %calls classification function
       end
end

function StressData(Dir)
   Stressimages = Dir;
   b=dir([Dir '/*.TIF']);
   out1=size(b,1);  %Gives the size of the directory
   
   %Reading images in a loop
   %SOURCE:https://in.mathworks.com/matlabcentral/answers/120073-how-to-read-multiple-jpg-images-in-a-loop
   for r = 1:out1
       jpgfiles1=dir(fullfile(Stressimages,'\*.TIF*'));
       Name=jpgfiles1(r).name;
       ReadStressImage=imread(fullfile(Stressimages,Name));
       % Resize image
       ReadStressImage = imresize(ReadStressImage, [500, 500]);
       DetectCircles(ReadStressImage)
   end
end

function DetectStressData(Stressimg)
     ImageCbCr = rgb2ycbcr(Stressimg);
       max = 85.0;
       min = 0.0;
       img = (ImageCbCr(:, :, 1) >= min) & (ImageCbCr(:, :, 1) <= max);
       rect = [140 100 210 200];   %Extracting ROI
       StressROI = imcrop(img, rect);
       StressROI = imclearborder(StressROI, 8);
       StressROI = bwareaopen(StressROI,10);
       bw = bwlabel(StressROI);
       Stressstats = regionprops(bw, 'BoundingBox');
       for p = 1 : length(Stressstats)
         box = Stressstats(p).BoundingBox;
         StressROIimg = imcrop(StressROI, box);
         figure;
         imshow(StressROIimg)
         Classification(StressROIimg)
       end
end

