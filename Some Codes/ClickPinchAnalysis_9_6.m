%% Click Pinch Analysis
%10/9/2017

% Code for 9/6 Analysis
 
close all %close open figure windows
clear all %clear workspace variables
clc %clear command window
 
%Load Video
filePath = '/For Vidya Asymmetry/7-31-17/800 x 304 BB/';%/Volumes/VIDYA/avis/'; %'D:\Research\Expansion Pinch-Off\3-22-17 Wafer 5\Far Right\400 x 304\'; %'C:\Users\Daniel\Desktop\Rice\Research\1-17-15 AOS Air\';
fileName = '14 mlhr 1000 mbar 2000 pps 800 x 304 BB.avi';

% 14 mlhr 1025 mbar 2000 pps 800 x 304 BB.avi
% 14 mlhr 1050 mbar 2000 pps 800 x 304 BB.avi
% 14 mlhr 1075 mbar 2000 pps 800 x 304 BB.avi
% 14 mlhr 1100 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 950 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 975 mbar 2000 pps 800 x 304 BB.avi

%part 3
% 15 mlhr 1000 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 1025 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 1050 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 1075 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 1100 mbar 2000 pps 800 x 304 BB.avi
% 15 mlhr 1125 mbar 2000 pps 800 x 304 BB.avi
% 15.5 mlhr 1000 mbar 2000 pps 800 x 304 BB.avi

%part 4
% 16 mlhr 1000 mbar 2000 pps 800 x 304 BB.avi
% 16 mlhr 1025 mbar 2000 pps 800 x 304 BB.avi
% 16 mlhr 1050 mbar 2000 pps 800 x 304 BB.avi
% 16 mlhr 1100 mbar 2000 pps 800 x 304 BB.avi
% 16 mlhr 1125 mbar 2000 pps 800 x 304 BB.avi

%fileExt = '.avi';
vidFile = VideoReader([filePath,fileName]);
 
%Parameters
clickon=1% 1 is if you want to click through program
          % 0 is if you want to run output code parameters
runAreascode=1; % 1 is if you want to run with normal correlations
               % 0 is otherwise (nothing put in rn)
 
if clickon==1 % dont change this
else
  code_rect=[ 


];%paste in data  
  codenum=[


];%paste in data 
  codeaddedbub=[

  ];%paste in data  
 
  centroidY_top_1=code_rect(1);
  centroidY_bot_1=code_rect(2);
  centroidY_top_2=code_rect(3);
  centroidY_bot_2=code_rect(4); 
end
 
choosewisely=0.38 % increase for more large (pink) to become small (blue)
 
frameStart =200; %!!!!!!<<<<

frameStep = 100;
frameMax = vidFile.NumberOfFrames;
frameTot = floor(1+(frameMax-frameStart)/frameStep); %total processed 
frameReport = 100; % Specifies how often MATLAB reports processing progress
%Create Video and Read Data. Load the video file, pre-allocate space
disp(['Reading video file data... ',num2str(frameTot),' frames']);
mov(1:frameMax) = struct('cdata',...
    zeros(vidFile.Height,vidFile.Width,3,'uint8'));
tic
 
for k = frameStart%:frameStep:frameMax
    vidFrames = read(vidFile,k);
    mov(k).cdata = vidFrames(:,:,:); % read data from each frame
end
 
toc
 
disp(' ');
disp('    ======== STARTING DATA PROCESSING ========');
disp(' ');
 
screen_size = get(0,'ScreenSize'); %1920 x 1080 pixels
MasterDataLarge = struct('Frame',zeros([1, frameTot]),...
                  'Areas', {cell(1, frameTot)},...
                  'Volumes', {cell(1, frameTot)});
MasterDataSmall = MasterDataLarge;
MasterDataUpperSmall = MasterDataLarge;
MasterDataLowerSmall = MasterDataLarge;
 
%imshow(mov(frameStart).cdata)

% MasterData holds all of the important bubble properties for every 
% processed frame. A cell array is an array of arrays which can have
% variable lengths. {} gives cell contents instead of cell itself
         
%areaMinEdge = 75;
areaMinEdge = 10;
areaMin = 2; % px of smallest bubble area (definitely > 5)
areaMax = 300; % px of biggest bubble area
%centroidX_left = 20; %smallest x-coordinate of bubble centroid position 
%centroidX_right = 380; %largest x-coordinate of bubble centroid position
centroidX_leftEdge = 10; %smallest x-coordinate of bubble centroid position 
centroidX_rightEdge = 390;
%centroidY_top = 20; %20, 220
%centroidY_bot = 80; %80, 290
level = 0.28; %0.25; %luminance where 0.5 is midway between black (0) & white (1) 
 
tic
 
for f = frameStart%:frameStep:frameMax
    frameNum = ((1+(f-frameStart)/frameStep)); %frame # of frameTot
    if  f==1 || rem(f,frameReport) < frameStep 
        disp(['Processing frame ',num2str(f),' of ',num2str(frameMax)]);
    end
  figure('Units', 'normalized','Position',[0 1 0 0]) %1                                    
    croppedImage1 = imcrop(mov(f).cdata, [200 0 400 304]);%[xmin ymin width height]
    %croppedImage1 = mov(f).cdata;
    imshow(croppedImage1)
    BW = im2bw(croppedImage1, level); % Convert the image to a logical array
                                % using luminance threshold, white = object                     
    L = bwlabel(BW,8); %Matrix containing labels of connected objects. 
                       % 8-connected is default & can be omitted
    Stats = regionprops(L, 'Centroid', 'Eccentricity', 'Area'); 
                       % Measure the properties of the image's regions
    Areas = [Stats.Area]; %vector of bubble areas
    Centroids = [Stats.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    CX = Centroids(1:2:end); % only interested in x positions
    CY = Centroids(2:2:end); 
    Eccentricities = [Stats.Eccentricity];
    minThresh = (Areas >= areaMin); %returns logical vector
    maxThresh = (Areas < areaMax);
    %centLThresh = (CX > centroidX_left);
    %centRThresh = (CX < centroidX_right);
    %centTThresh = (CY > centroidY_top);
    %centBThresh = (CY < centroidY_bot);
    EccMaxThresh = (Eccentricities < 0.8); %0.7
    %EccMinThresh = (Eccentricities > 0.6);
    targetBubbles = minThresh.*maxThresh.*EccMaxThresh;%centTThresh.*centBThresh.*centRThresh;%.*centTThresh.*centBThresh.*EccMaxThresh;%.*EccMinThresh;
                    % want all of the conditions to be true
    BW1 = ismember(L,find(targetBubbles)); %find returns vector of indices 
                                        % of nonzero elements. ismember for 
   
%     figure('Units', 'normalized','Position',[0 1 0 0]) %1                                    
%     %set(gcf, 'Units', 'normalized','Position', [0 0 0 0]);
%     %set(gcf, 'Units', 'normalized','Position', [0 0.4 0.4 0.8]);
%     imshow(croppedImage1)  
    
    figure('Units', 'normalized','Position',[0 0 0 0]) %2                                  
    % data in L found in targetBubbles                                                                
    imshow(BW1)
    %keyboard;
    
    L = bwlabel(BW1,8); %Matrix containing labels of connected objects. 
    Stats = regionprops(L, 'Area','Centroid'); 
    Areas1 = [Stats.Area]; %vector of bubble areas
    Centroids = [Stats.Centroid];
    CX = Centroids(1:2:end); % only interested in x positions
    CY = Centroids(2:2:end); 
    %keyboard;
    minThreshEdge = (Areas1 > areaMinEdge); %returns logical vector
    centLThreshEdge = (CX < centroidX_leftEdge);
    centRThreshEdge = (CX > centroidX_rightEdge);
    
    targetBubblesEdgeLeft = minThreshEdge.*centLThreshEdge;%.*centTThreshEdge.*centBThreshEdge.*EccMaxThreshEdge;
                    % want all of the conditions to be true
    targetBubblesEdgeRight = minThreshEdge.*centRThreshEdge;%.*centTThreshEdge.*centBThreshEdge.*EccMaxThreshEdge;
                    % want all of the conditions to be true
    targetBubblesEdge = targetBubblesEdgeLeft + targetBubblesEdgeRight;
    BW1New = BW1 - ismember(L,find(targetBubblesEdge)); %find returns vector of indices 
                                        % of nonzero elements. ismember for 
                                        % data in L found in targetBubbles     
    
    L = bwlabel(BW1New); %replace L with only objects that meet criteria
    figure('Units', 'normalized','Position',[0 1 0 0]) %3                                  
    imshow(BW1New)
    %keyboard;
    %imwrite(mat2gray(BW2), ['BW2_', num2str(frameStart+(frameNum-1)*frameStep),'.png']);
    L = bwlabel(BW1New); %replace L with only objects that meet criteria
    Stats = regionprops(L, 'Centroid', 'Area');
    Centroids1New = [Stats.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    CY1New = Centroids1New(2:2:end); 
    Areas1New = [Stats.Area];
    centroidY_top = 92; %135, 92
    centroidY_bot = 220.5; %1  95 216
    centTThresh1New = (CY1New > centroidY_top);
    centBThresh1New = (CY1New < centroidY_bot);
    AreaThresh = (Areas1New < areaMin); %*2
    %AreaThresh = (Areas1New < areaMin*5); %*2
    %EccMaxThresh2 = (Eccentricities2 < 0.68); Change line before to Min
    targetTinyDefects = AreaThresh.*centTThresh1New.*centBThresh1New;
    BW2 = BW1New-ismember(L,find(targetTinyDefects));
    figure('Units', 'normalized','Position',[0 0 0 0]) %4                                  
    imshow(croppedImage1)
    hold on
    white = cat(3,ones(size(BW2)), ones(size(BW2)), ones(size(BW2)));
    h_white = imshow(white); %handle to yellow image
    set(h_white, 'AlphaData', BW2)
    hold off
 
     if clickon==1; % if using click
        keyboard
    else % if running values from output code
    end
    
    L = bwlabel(BW2);
    Stats2 = regionprops(L, 'Area');
    Areas2 = [Stats2.Area];
    AreaThresh2 = (Areas2 < areaMin+20);
    targetTinyObjects = AreaThresh2;
    
    BW3 = ismember(L,find(targetTinyObjects));
    figure('Units', 'normalized','Position',[0 1 0 0]) %5                                 
    imshow(BW3)
    %keyboard
    L3 = bwlabel(BW3);
    Stats3 = regionprops(L3, 'Eccentricity', 'Orientation', 'Extent');
    Eccentricities3 = [Stats3.Eccentricity];
    EccMaxThresh3 = (Eccentricities3 < 0.6);
    Orient = [Stats3.Orientation];
    OrientMin = 30;
    OrientMax = 60;
    OrientMinNeg = -60;
    OrientMaxNeg = -30;
    OrientMinThresh = ((Orient) > OrientMin);
    OrientMaxThresh = ((Orient) < OrientMax);
    OrientMinNegThresh = ((Orient) > OrientMinNeg);
    OrientMaxNegThresh = ((Orient) < OrientMaxNeg);
    Extents3 = [Stats3.Extent];
    ExtentsThresh = Extents3 < (mean(Extents3)+0.01*std(Extents3));
    targetTinyDefects4 = (ExtentsThresh); 
    %targetTinyDefects = OrientMinThresh.*OrientMaxThresh;%.*BBoxThresh;%.*OrientMinThresh.*OrientMaxThresh;%.*BBoxThresh;
    targetTinyDefects2 = OrientMinNegThresh.*OrientMaxNegThresh;
    targetTinyDefects3= not(EccMaxThresh3);
    BW3New = BW3;%-ismember(L3,find(targetTinyDefects4));%-ismember(L3,find(targetTinyDefects4));%-ismember(L3,find(targetTinyDefects))-ismember(L3,find(targetTinyDefects2));
    %BW3New = BW3-ismember(L3,find(targetTinyBubbles));%BW2New-ismember(L,find(targetTinyBubbles));
    figure('Units', 'normalized','Position',[0 0 0 0]) %6                                  
    imshow(BW3New)
    %keyboard
    
    L3New = bwlabel(BW3New);
    Stats3New = regionprops(L3New, 'Perimeter');
    Perm = [Stats3New.Perimeter];
    PermThresh = (Perm > mean(Perm)+ 2.1*std(Perm)); %1.2
    targetTinyDefects5 = PermThresh;
    BW3Newest = BW3New-ismember(L3New,find(targetTinyDefects5));%BW2New-ismember(L,find(targetTinyBubbles));
    
    figure('Units', 'normalized','Position',[0 1 0 0]) %7                                  
    imshow(BW3Newest)
    %keyboard
 
    BW2New = BW2;%-(BW3-BW3Newest); %BW2-(BW3-BW3Newest);
    figure('Units', 'normalized','Position',[0 0 0 0]) %8                                  
    imshow(BW2New)
    
    %
    L2Newest = bwlabel(BW2New);
    Stats5Newest = regionprops(L2Newest, 'Area');
    Areas5Newest = [Stats5Newest.Area];
    Areas5MinThresh = (Areas5Newest > areaMin+40);
    Areas5MaxThresh = (Areas5Newest <= areaMin+70); %80, 100
    targetMedObjects = Areas5MinThresh.*Areas5MaxThresh;
    BW4New = ismember(L2Newest,find(targetMedObjects));
    figure('Units', 'normalized','Position',[0 1 0 0]) %9                                  
    imshow(BW4New)
 
     if clickon==1; % if using click
        keyboard
    else % if running values from output code
    end
    
    L4New = bwlabel(BW4New); %replace L with only objects that meet criteria
    Stats4New = regionprops(L4New, 'Area', 'Perimeter');
    Perm2New = [Stats4New.Perimeter];
    PermThresh2New = (Perm2New > mean(Perm2New)+1.2*std(Perm2New)); %1.35
    %PermThresh2New2 = (Perm2New < mean(Perm2New)-0.8*std(Perm2New)); %1.35
    targetMedDefects2 = PermThresh2New;%.*PermThresh2New2;%.*minThresh.*maxThresh;
               % want all of the conditions to be true
    BW5Newest = ismember(L4New,find(targetMedDefects2));
    figure('Units', 'normalized','Position',[0 0 0 0]) %10                                  
    imshow(BW5Newest)
    if clickon==1; % if using click
        keyboard
    else % if running values from output code
    end
    
    L5New = bwlabel(BW5Newest);
    Stats5Newest = regionprops(L5New, 'Area'); 
    Areas5Newest = [Stats5Newest.Area];
    
    BW2New = BW2New-BW5Newest;%-BW5Newest;%+BW4New;
    figure('Units', 'normalized','Position',[0 1 0 0]) %11                                  
    imshow(BW2New)
    %}
    
    
    %keyboard
    L = bwlabel(BW2New);
    Stats2New = regionprops(L, 'Area');
    Areas2New = [Stats2New.Area];
    Areas2NewMinThresh = (Areas2New >= areaMin);
    Areas2NewMaxThresh = (Areas2New <= areaMin+10);
    targetMedObjects = Areas2NewMinThresh.*Areas2NewMaxThresh;
    BW4 = ismember(L,find(targetMedObjects));
    
    
    figure('Units', 'normalized','Position',[0 0 0 0]) %12                                 
    imshow(BW4)
    
    figure('Units', 'normalized','Position',[0 1 0 0]) %13                                  
    imshow(croppedImage1)
    hold on
    yellow = cat(3,ones(size(BW4)), ones(size(BW4)), zeros(size(BW4)));
    h_yellow = imshow(yellow); %handle to yellow image
    set(h_yellow, 'AlphaData', BW4)
 
    %limit by Y
    L2New = bwlabel(BW4); %
    Stats = regionprops(L2New,'Centroid'); 
    Centroids = [Stats.Centroid];
    %CX = Centroids(1:2:end); % only interested in x positions
    CY1New = Centroids(2:2:end); % only interested in y positions
   
    if clickon==1; % if using click
        disp('round 1: drag rectangle to select band of defects:')
        %% 
        rect = getrect;
        %% 
        centroidY_top=rect(2); 
        centroidY_bot=rect(2)+rect(4); 
        centroidY_top_1= centroidY_top;
        centroidY_bot_1= centroidY_bot;
    
    else % if running values from output code
         disp('round 1: deleted defects with rectangle')
         centroidY_top = centroidY_top_1; % can test here with same coordinates if needed
         centroidY_bot = centroidY_bot_1; %
    end
    
    centTThresh1New = (CY1New > centroidY_top);
    centBThresh1New = (CY1New < centroidY_bot);
    targetDefects1 = centTThresh1New.*centBThresh1New;
    BW4 = ismember(L2New,find(targetDefects1));
 
    red = cat(3,ones(size(BW4)), zeros(size(BW4)), zeros(size(BW4)));
    h_red = imshow(red); %handle to red image
    set(h_red, 'AlphaData', BW4)% displays selected defects as red
    hold off 
    %imshow(BW4) %9
   
%     keyboard
%     L4 = bwlabel(BW4); %replace L with only objects that meet criteria
%     Stats4 = regionprops(L4, 'Area', 'Perimeter');
%     Perm2 = [Stats4.Perimeter];
%     PermThresh2 = (Perm2 > mean(Perm2)+0*std(Perm2)); %1.2
%     targetMedDefects = PermThresh2;%.*minThresh.*maxThresh;
%                     % want all of the conditions to be true
%     keyboard
%     BW5 = ismember(L4,find(targetMedDefects));%+ismember(L4,find(targetMedDefects2));
%     figure('Units', 'normalized','Position',[0 0 0 0]) %10                                  
%     imshow(BW5)
%     keyboard
    
    BW2Newest = BW2New-BW4;
    figure('Units', 'normalized','Position',[0 0 0 0]) %14                                 
    imshow(BW2Newest)
 if clickon==1; % if using click
        keyboard
    else % if running values from output code
    end
    L2New = bwlabel(BW2Newest);
    Stats5 = regionprops(L2New, 'Area');
    Areas5 = [Stats5.Area];
    Areas5MinThresh = (Areas5 > areaMin+10);
    Areas5MaxThresh = (Areas5 <= areaMin+20);
    targetMedObjects2 = Areas5MinThresh.*Areas5MaxThresh;
    BW5New = ismember(L2New,find(targetMedObjects2));
    figure('Units', 'normalized','Position',[0 1 0 0]) %15                                 
    imshow(BW5New) 
 
    figure('Units', 'normalized','Position',[0 0 0 0]) %16                                
    imshow(croppedImage1)
    hold on
    yellow = cat(3,ones(size(BW5New)), ones(size(BW5New)), zeros(size(BW5New)));
    h_yellow = imshow(yellow); %handle to yellow image
    set(h_yellow, 'AlphaData', BW5New)
    
    %limit by Y
    L2New = bwlabel(BW5New); %
    Stats = regionprops(L2New,'Centroid'); 
    Centroids = [Stats.Centroid];
    %CX = Centroids(1:2:end); % only interested in x positions
    CY1New = Centroids(2:2:end); 
    
    if clickon==1; % if using click    
        disp('round 2: drag rectangle to select band of defects:')
        rect = getrect;
        centroidY_top=rect(2); %output
        centroidY_bot=rect(2)+rect(4); % output
        centroidY_top_2= centroidY_top;
        centroidY_bot_2= centroidY_bot;
    else% if running values from output code
         disp('round 2: deleted defects with rectangle')
         centroidY_top = centroidY_top_2; % can test here with same coordinates if needed
         centroidY_bot = centroidY_bot_2; %
    end
    
    centTThresh1New = (CY1New > centroidY_top);
    centBThresh1New = (CY1New < centroidY_bot);
    targetDefects1 = centTThresh1New.*centBThresh1New;
    BW5New = ismember(L2New,find(targetDefects1));
    
    red = cat(3,ones(size(BW5New)), zeros(size(BW5New)), zeros(size(BW5New)));
    h_red = imshow(red); %handle to red image
    set(h_red, 'AlphaData', BW5New)% displays selected defects as red
    hold off 
 
%     L5 = bwlabel(BW5New); %replace L with only objects that meet criteria
%     Stats5 = regionprops(L5, 'Area', 'Perimeter');
%     Perm5 = [Stats5.Perimeter];
%     PermThresh5 = (Perm5 > mean(Perm5)+1.2*std(Perm5)); %1.35
%     targetMedDefects2 = PermThresh5;%.*minThresh.*maxThresh;
%                     % want all of the conditions to be true
%     BW5Newest = ismember(L5,find(targetMedDefects2));%+ismember(L4,find(targetMedDefects2));
%     figure('Units', 'normalized','Position',[0 1 0 0]) %13                                  
%     imshow(BW5Newest)
%     keyboard
    
    BW2Newest = BW2Newest-BW5New;
    figure('Units', 'normalized','Position',[0 1 0 0]) %17                                 
    %imshow(BW2Newest)
    imshow(croppedImage1)
    hold on
    green = cat(3,zeros(size(BW2Newest)), ones(size(BW2Newest)), zeros(size(BW2Newest)));
    h_green = imshow(green); %handle to green image
    set(h_green, 'AlphaData', BW2Newest)
    
    L3 = bwlabel(BW2Newest);
    
  if clickon==1
    disp('round 1: click on defects then press enter:')
    [x, y] = getpts;
    coord_round1 = [x y];
    x=floor(x);
    y=floor(y);
    numberofclicks=length(x)
    num=zeros(numberofclicks,1);
        for i = 1:numberofclicks
          xi=x(i);
          yi=y(i);
          num(i)= L3(yi,xi);
        end
    num = nonzeros(num);% gets rid of zeros
    num = unique(num,'sorted'); % gets rid of duplicates and puts in order
    %disp('defect numbers found:')
    round1num=num;
    num=num';
        emptcheck = isempty(num);
        if emptcheck==1;
            num=0;
        else
        end
  else %input defect num manually
      disp('round 1: deleted selected defects')
      num=[codenum]; 
      num= unique(num,'sorted')
      emptcheck = isempty(num);
        if emptcheck==1;
            num=0;
        else
        end
  end
  
  if num==0
      defectsfound=0
  else
  defectsfound=length(num)
  end
  
    Stats3 = regionprops(L3, 'Eccentricity', 'Orientation', 'Extent', 'Centroid', 'Area', 'Perimeter');
    for i = 1:length(Stats3)
        if(i~=[num])
            j = find(L3==i);
            L3(j) = 0;              
        end
    end   
    L3(find(L3))=1;
    L4=L3;
    %imshow(L3) %17 
    red = cat(3,ones(size(L3)), zeros(size(L3)), zeros(size(L3)));
    h_red = imshow(red); %handle to red image
    set(h_red, 'AlphaData', L3)% displays selected defects as red
    %end of round 1
    
    %(ROUND 2 to add more red)
  if clickon==1
    L3 = bwlabel(BW2Newest);
    disp('round 2: click on defects then press enter:')
    [x, y] = getpts;
    coord_round2 = [x y];
    x=floor(x);
    y=floor(y);
    numberofclicks=length(x)
    num=zeros(numberofclicks,1);
    for i = 1:numberofclicks
      xi=x(i);
      yi=y(i);
      num(i)= L3(yi,xi);
    end
    num = nonzeros(num);% gets rid of zeros
    num = unique(num,'sorted'); % gets rid of duplicates and puts in order   
    defectsfound=length(num)
    %disp('defect numbers found:')
    round2num=num;
    num=num';
    emptcheck = isempty(num);
    if emptcheck==1;
        num=0;
    else
    end
  else
    disp('round 2: zero defects entered')
    num=0;
    defectsfound=num
  end
  
    Stats3 = regionprops(L3, 'Eccentricity', 'Orientation', 'Extent', 'Centroid', 'Area', 'Perimeter');
    for i = 1:length(Stats3)
        if(i~=[num])
            j = find(L3==i);
            L3(j) = 0;              
        end
    end   
 L3(find(L3))=1;
%  
    %imshow(L3) %17 
    red = cat(3,ones(size(L3)), zeros(size(L3)), zeros(size(L3)));
    h_red = imshow(red); %handle to red image
    set(h_red, 'AlphaData', L3)% displays selected defects as red
   %end of round 2
    
   if clickon==1
       combnum=[round1num;round2num]
       codenum = unique(combnum,'sorted'); % gets rid of duplicates and puts in order   
   else
       codenum=codenum; 
   end
    hold off 
   
   
    figure('Units', 'normalized','Position',[0 0 0 0]) %18                                 
    BW2Newest = BW2Newest-(L4)-L3;
    imshow(BW2Newest)
 if clickon==1; % if using click
     keyboard
    else % if running values from output code
    end
    L2Newest = bwlabel(BW2Newest);
    Stats2Newest = regionprops(L2Newest, 'Area', 'Eccentricity', 'Centroid'); 
    Areas2Newest = [Stats2Newest.Area];
    Area2NewestMax = mean(Areas2Newest)+choosewisely*mean(Areas2Newest); %NEED TO CHOSE WISELY!!!!!!!!!!!!!!!!!!!! SMALL vs BiG
    Ecc2Newest = [Stats2Newest.Eccentricity];
    Area2NewestThresh = Areas2Newest < Area2NewestMax;
    %Area2NewestThresh2 = Areas2Newest > 35;
    Ecc2NewestMax = Ecc2Newest < 0.8;%0.65; %TO KILL MYSTERIOUS HANG AROUND DEAD SPACE
    centroidX_left = 90;
    centroidY_bot = 150;
    Centroids2 = [Stats2Newest.Centroid];
    CX2 = Centroids2(1:2:end); % only interested in x positions
    CY2 = Centroids2(2:2:end);
    centLThresh2 = (CX2 > centroidX_left);
    centBThresh2 = (CY2 < centroidY_bot);
    targetSmallBubbles = Area2NewestThresh.*Ecc2NewestMax;%.*centBThresh2;%.*Area2NewestThresh2;%.*centLThresh2;
    BWSmall = ismember(L2Newest,find(targetSmallBubbles));
    figure('Units', 'normalized','Position',[0 1 0 0]) %19
    imshow(BWSmall) % https://nf.nci.org.au/facilities/software/Matlab/toolbox/
                % images/im2bw.html
 if clickon==1; % if using click

     keyboard
    else % if running values from output code
 end
 LSmall = bwlabel(BWSmall); %replace L with only objects that meet criteria
    StatsSmall = regionprops(LSmall, 'Centroid', 'Eccentricity', 'Area'); 
                       % Measure the properties of the image's regions
    AreasSmall = [StatsSmall.Area]; %vector of bubble areas
    CentroidsSmall = [StatsSmall.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    CXSmall = CentroidsSmall(1:2:end); % only interested in x positions
    CYSmall = CentroidsSmall(2:2:end); 
    EccentricitiesSmall = [StatsSmall.Eccentricity];    
  
    figure('Units', 'normalized','Position',[0 0 0 0]) %20  
   
    imshow(croppedImage1)
    hold on
    %targetupper
    YUpperSmall = (CYSmall < 146);
    targetUpperSmall = YUpperSmall;
    BWUpperSmall = ismember(LSmall,find(targetUpperSmall));
    yellow = cat(3,ones(size(BWUpperSmall)), ones(size(BWUpperSmall)), zeros(size(BWUpperSmall)));
    h_yellow = imshow(yellow); %handle to green image
    set(h_yellow, 'AlphaData', BWUpperSmall)
    
    %targetlower
    YLowerSmall = (CYSmall >= 146);
    targetLowerSmall = YLowerSmall;
    BWLowerSmall = ismember(LSmall,find(targetLowerSmall));
    blue = cat(3,zeros(size(BWLowerSmall)), zeros(size(BWLowerSmall)), ones(size(BWLowerSmall)));
    h_blue = imshow(blue); %handle to green image
    set(h_blue, 'AlphaData', BWLowerSmall)
   
    LUpperSmall = bwlabel(BWUpperSmall); %replace L with only objects that meet criteria
    StatsUpperSmall = regionprops(LUpperSmall, 'Centroid', 'Eccentricity', 'Area'); 
                       % Measure the properties of the image's regions
    AreasUpperSmall = [StatsUpperSmall.Area]; %vector of bubble areas
    CentroidsUpperSmall = [StatsUpperSmall.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
 
    LLowerSmall = bwlabel(BWLowerSmall); %replace L with only objects that meet criteria
    StatsLowerSmall = regionprops(LLowerSmall, 'Centroid', 'Eccentricity', 'Area'); 
                       % Measure the properties of the image's regions
    AreasLowerSmall = [StatsLowerSmall.Area]; %vector of bubble areas
    CentroidsLowerSmall = [StatsLowerSmall.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
      
    
    %assume all missing in upper small
    
   if clickon==1
     disp('click to add in missing bubbles')
     [x, y] = getpts;
    coord_added_bubbles=[x y];
    codeaddedbub=[coord_added_bubbles];
     plot(x,y,'g*','MarkerSize',5)
     bubblesadded=length(x)
      missingbub=zeros(1,bubblesadded);
        AreasSmall = [AreasSmall,[missingbub]]; %add missing bubble
        AreasUpperSmall = [AreasUpperSmall,[missingbub]];%add missing bubble
 
   else
    emptcheck = isempty(codeaddedbub);
    if emptcheck==1;
         disp('there are 0 missing bubbles')
         bubblesadded=0;
    else
        disp('missing bubbles have been added')
        coord_added_bubbles =[codeaddedbub];
        x=coord_added_bubbles(:,1);
        y=coord_added_bubbles(:,2);
        plot(x,y,'g*','MarkerSize',5)
        bubblesadded=length(x)
        missingbub=zeros(1,bubblesadded);
        AreasSmall = [AreasSmall,[missingbub]]; %add missing bubble
        AreasUpperSmall = [AreasUpperSmall,[missingbub]];%add missing bubble
   end   
   end
    
    
    hold off
    
     %end of small
    % large!!!!!!!!!
    
    BWLarge = ismember(L2Newest,find(not(Area2NewestThresh)));
    figure('Units', 'normalized','Position',[0 1 0 0]) %21                                  
    imshow(BWLarge)
    
 if clickon==1; % if using click
        keyboard
    else % if running values from output code
    end
        
    LLarge = bwlabel(BWLarge); %replace L with only objects that meet criteria
    StatsLarge = regionprops(LLarge, 'Centroid', 'Eccentricity', 'Area'); 
                       % Measure the properties of the image's regions
    AreasLarge = [StatsLarge.Area]; %vector of bubble areas
 
if runAreascode==1 % run with other correlations
 
   for i = 1:length(AreasSmall)
         if AreasSmall(i) < 25
             AreasSmall(i) = (4.23* AreasSmall(i)+123)*5.4348^2;
         elseif AreasSmall(i) < 126
             AreasSmall(i) = (2.08*AreasSmall(i)+177)*5.4348^2;
         else
             AreasSmall(i) = (1.55*AreasSmall(i)+244)*5.4348^2;
         end
   end 
   
    for i = 1:length(AreasUpperSmall)
         if AreasUpperSmall(i) < 25
             AreasUpperSmall(i) = (4.23* AreasUpperSmall(i)+123)*5.4348^2;
         elseif AreasUpperSmall(i) < 126
             AreasUpperSmall(i) = (2.08*AreasUpperSmall(i)+177)*5.4348^2;
         else
             AreasUpperSmall(i) = (1.55*AreasUpperSmall(i)+244)*5.4348^2;
         end
    end 
  
   
      for i = 1:length(AreasLowerSmall)
         if AreasLowerSmall(i) < 25
             AreasLowerSmall(i) = (4.23* AreasLowerSmall(i)+123)*5.4348^2;
         elseif AreasLowerSmall(i) < 126
             AreasLowerSmall(i) = (2.08*AreasLowerSmall(i)+177)*5.4348^2;
         else
             AreasLowerSmall(i) = (1.55*AreasLowerSmall(i)+244)*5.4348^2;
         end
   end 
   
    
   for i = 1:length(AreasLarge)
         if AreasLarge (i) < 126
             AreasLarge(i) = (2.08*AreasLarge(i)+177)*5.4348^2;
         else
             AreasLarge(i) = (1.55*AreasLarge(i)+244)*5.4348^2;
         end
   end
   
  
   % ADDED VOLUME CODE 
   channelHeight = 80;
pi32 = vpa(pi);
VolumesUpperSmall = AreasUpperSmall;
for i = 1:length(VolumesUpperSmall)
    if VolumesUpperSmall(i) < (channelHeight/2)^2*pi32 %if diameter is less than channel height
        VolumesUpperSmall(i) = 4/3*pi32*(sqrt(VolumesUpperSmall(i)/pi32))^3; %assume spherical
    else
        VolumesUpperSmall(i) = (pi32*channelHeight^3)/6+((pi32*channelHeight)/4*(2*(sqrt(VolumesUpperSmall(i)/pi32))-channelHeight)*((pi32*channelHeight)/2+2*(sqrt(VolumesUpperSmall(i)/pi32))-channelHeight)); %assume pancake
    end
end

VolumesLowerSmall = AreasLowerSmall;
for i = 1:length(VolumesLowerSmall)
    if VolumesLowerSmall(i) < (channelHeight/2)^2*pi32 %if diameter is less than channel height
        VolumesLowerSmall(i) = 4/3*pi32*(sqrt(VolumesLowerSmall(i)/pi32))^3; %assume spherical
    else
        VolumesLowerSmall(i) = (pi32*channelHeight^3)/6+((pi32*channelHeight)/4*(2*(sqrt(VolumesLowerSmall(i)/pi32))-channelHeight)*((pi32*channelHeight)/2+2*(sqrt(VolumesLowerSmall(i)/pi32))-channelHeight)); %assume pancake
    end
end
   
   % END OF ADDED VOLUME CODE  
   
else 
% nothing here rn
end
  
    
    CentroidsLarge = [StatsLarge.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    CXLarge = CentroidsLarge(1:2:end); % only interested in x positions
    CYLarge = CentroidsLarge(2:2:end); 
    EccentricitiesLarge = [StatsLarge.Eccentricity];   
    % end of large
    
    %make final fig 22   
    figure('Units', 'normalized','Position',[0 0 0 0]) %22                                
    
    % original image from video
    imshow(croppedImage1) 
    hold on
    
%     % All Small Bubbles in blue
%     blue = cat(3,zeros(size(BWSmall)), zeros(size(BWSmall)), ones(size(BWSmall)));
%     h_blue = imshow(blue); %handle to blue image
%     set(h_blue, 'AlphaData', BWSmall)
   
     %Upper Small Bubbles in yellow
    yellow = cat(3,ones(size(BWUpperSmall)), ones(size(BWUpperSmall)), zeros(size(BWUpperSmall)));
    h_yellow = imshow(yellow); %handle to green image
    set(h_yellow, 'AlphaData', BWUpperSmall)
    
    %Lower Small Bubbles in blue
    blue = cat(3,zeros(size(BWLowerSmall)), zeros(size(BWLowerSmall)), ones(size(BWLowerSmall)));
    h_blue = imshow(blue); %handle to green image
    set(h_blue, 'AlphaData', BWLowerSmall)
   
    %Large Bubbles in pink
    pink = cat(3,ones(size(BWLarge)), zeros(size(BWLarge)), ones(size(BWLarge)));
    h_pink = imshow(pink); %handle to blue image
    set(h_pink, 'AlphaData', BWLarge)
  
    %plot missing bubbles
    emptcheck = isempty(codeaddedbub);
    if emptcheck==1;
    else
      plot(x,y,'g*','MarkerSize',5)
    end   
    
    hold off
 
disp('    ======== PROCEED TO DISPLAY DATA AND SAVE IMAGE? ========');
 
 if clickon==1; % if using click
     keyboard
    else % if running values from output code
    end
 
% save final fig 22
imagefilename = strcat('images/','LA',fileName,' Frame',num2str(f));
set(gcf,'PaperPositionMode','auto');
print(imagefilename,'-dpng','-r0');
disp(' IMAGE SAVED AS:');
disp(imagefilename);
% close fig 1-18 and fig 20
close(1:18); close(20);
% (keeping these images to review)
%fig 19 is small bubbles
%fig 21 is large bubbles
%fig 22 is colored image
 
    MasterDataLarge.Frame(frameNum) = f;
    MasterDataLarge.Areas(frameNum) = {cat(2,AreasLarge)};
    MasterDataLarge.NumberOfBubbles(frameNum) = length(AreasLarge);
    MasterDataSmall.Frame(frameNum) = f;
    MasterDataSmall.Areas(frameNum) = {cat(2,AreasSmall)}; %combine horizontally
    MasterDataSmall.NumberOfBubbles(frameNum) = length(AreasSmall);
    
    MasterDataLowerSmall.Frame(frameNum) = f;
    MasterDataLowerSmall.Areas(frameNum) = {cat(2,AreasLowerSmall)}; %combine horizontally
    MasterDataLowerSmall.NumberOfBubbles(frameNum) = length(AreasLowerSmall);
   
    MasterDataUpperSmall.Frame(frameNum) = f;
    MasterDataUpperSmall.Areas(frameNum) = {cat(2,AreasUpperSmall)}; %combine horizontally
    MasterDataUpperSmall.NumberOfBubbles(frameNum) = length(AreasUpperSmall);
 
    code_rect=[
    centroidY_top_1;
    centroidY_bot_1;
    centroidY_top_2;
    centroidY_bot_2]
    codenum
    codeaddedbub
 
    BubbleNumberRatio =  MasterDataSmall.NumberOfBubbles(frameNum)/MasterDataLarge.NumberOfBubbles(frameNum)
    BadAreaRatio = sum([StatsLarge.Area]/sum([StatsSmall.Area]))
    EstAreaRatio = sum(MasterDataLarge.Areas{frameNum})/(sum(MasterDataSmall.Areas{frameNum})*2/BubbleNumberRatio)                                 
   
    PDILarge = std(MasterDataLarge.Areas{1})/mean(MasterDataLarge.Areas{1})
    PDISmall = std(MasterDataSmall.Areas{1})/mean(MasterDataSmall.Areas{1})
    PDILowerSmall = std(MasterDataLowerSmall.Areas{1})/mean(MasterDataLowerSmall.Areas{1})
    PDIUpperSmall = std(MasterDataUpperSmall.Areas{1})/mean(MasterDataUpperSmall.Areas{1})
    NumberSmallBubbles = length(MasterDataSmall.Areas{1,1})
    NumberBigBubbles = length(MasterDataLarge.Areas{1,1})
    bubblesadded
 
    
    %to make it easier to open in workspace, all matrices rewritten to
    %start with data:
    
    datalowersmall=MasterDataLowerSmall.Areas{1,1};
    datauppersmall=MasterDataUpperSmall.Areas{1,1};
    datalarge=MasterDataLarge.Areas{1,1};
    datalowersmallVOLUME=VolumesLowerSmall;
    datauppersmallVOLUME=VolumesUpperSmall;
   
    datareq = [BadAreaRatio;
               EstAreaRatio;
               PDILarge;
               PDISmall;
               PDILowerSmall; 
               PDIUpperSmall;
               NumberSmallBubbles;
               NumberBigBubbles
               %bubblesadded
               ];
           max(AreasSmall)
           min(AreasLarge)
           min(AreasLarge)/max(AreasSmall)
          
end
toc
%close(writerObj);
 
 

