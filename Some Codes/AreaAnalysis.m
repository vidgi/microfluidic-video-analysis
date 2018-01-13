% Original version created by Charles Conn in 2014.
% Modified by Daniel Vecchiolla. Current version as of May 2015.
% Loads a video. Allows the user to specify which frames to process. Allows 
% the user to specify properties to determine what objects are bubbles and  
% even exclude bubbles if they do not meet a certain criteria of area and 
% position. Stores the bubble properties for every processed frame in a 
% master structure. Tracks a bubble and highlights the starting and ending
% position on the first and last image respectively. Plots the centroid
% positions of every bubble of every processed frame on the first image
% where the markers changed color based on the frame number. Plots the
% centroid positions on a blank x-y space for specified frames 

close all %close open figure windows
clear all %clear workspace variables
clc %clear command window

%Load Video
filePath = '/'; %'C:\Users\Daniel\Desktop\Rice\Research\1-17-15 AOS Air\';

fileName = '30 mlhr 1125 mbar 800 x 304 2000 fps.avi';
fileExt = '.avi';
vidFile = VideoReader([filePath,fileName]);
%vidFile = VideoReader([filePath,fileName, fileExt]);
%Parameters
frameStart = 601;

frameStep = 2;
frameMax = vidFile.NumberOfFrames
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

%imshow(mov(frameStart).cdata)
%keyboard
% MasterData holds all of the important bubble properties for every 
% processed frame. A cell array is an array of arrays which can have
% variable lengths. {} gives cell contents instead of cell itself
         
%areaMinEdge = 75;
%areaMinEdge = 10;
areaMin = 3; % px of smallest bubble area (definitely > 5)
areaMax = 500; % px of biggest bubble area
%centroidX_left = 20; %smallest x-coordinate of bubble centroid position 
%centroidX_right = 380; %largest x-coordinate of bubble centroid position
%centroidX_leftEdge = 140; %smallest x-coordinate of bubble centroid position 
%centroidX_rightEdge = 793;
centroidY_top = 20; %20, 220, 80
centroidY_bot = 290; %80, 290
level = 0.4; %0.25; %luminance where 0.5 is midway between black (0) & white (1) 
tic

for f = frameStart:frameStep:frameMax
    frameNum = ((1+(f-frameStart)/frameStep)); %frame # of frameTot
    if  f==1 || rem(f,frameReport) < frameStep 
        disp(['Processing frame ',num2str(f),' of ',num2str(frameMax)]);
    end
    Image1=mov(f).cdata;
    BW = im2bw(mov(f).cdata, level); % Convert the image to a logical array 
                                % using luminance threshold, white = object 
    InnerAreaBW=BW;
    OuterAreaBW = 1 - BW;
    LInnerArea = bwlabel(InnerAreaBW);
    LOuterArea = bwlabel(OuterAreaBW);
    
    % showing inner bubbles
    InnerAreaStats = regionprops(LInnerArea,'Centroid', 'Area');
    InnerAreas = [InnerAreaStats.Area];
    InnerCentroids = [InnerAreaStats.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    InnerCX = InnerCentroids(1:2:end); % only interested in x positions
    InnerCY = InnerCentroids(2:2:end);  
    
    minThresh = (InnerAreas > areaMin); %returns logical vector
    maxThresh = (InnerAreas < areaMax);
    %centLThresh = (CX > centroidX_left);
    %centRThresh = (CX < centroidX_right);
    centTThresh = (InnerCY > centroidY_top);
    centBThresh = (InnerCY < centroidY_bot);
    %EccMaxThresh = (Eccentricities < 0.7); %0.7
    %EccMinThresh = (Eccentricities > 0.6);
    targetBubbles = centTThresh.*centBThresh.*minThresh.*maxThresh;%*EccMaxThresh;
                    % want all of the conditions to be true
    BW1 = ismember(LInnerArea,find(targetBubbles)); %find returns vector of indices 
                                        % of nonzero elements. ismember for 
                                        % data in L found in targetBubbles                                                                
    
    figure('Units', 'normalized','Position',[0 1 0 0]) %1                                  
    imshow(Image1)
    hold on
    red = cat(3,ones(size(BW1)), zeros(size(BW1)), zeros(size(BW1)));
    h_red = imshow(red); %handle to yellow image
    set(h_red, 'AlphaData', BW1)


 % showing outer bubbles
    OuterAreaStats = regionprops(LOuterArea,'Centroid', 'Area');
    OuterAreas = [OuterAreaStats.Area];
    OuterCentroids = [OuterAreaStats.Centroid]; %vector of centroid positions where odd 
                                  % indices are x & even are y positions 
    OuterCX = OuterCentroids(1:2:end); % only interested in x positions
    OuterCY = OuterCentroids(2:2:end);  
    
    minThresh = (OuterAreas > areaMin); %returns logical vector
    maxThresh = (OuterAreas < areaMax);
    %centLThresh = (CX > centroidX_left);
    %centRThresh = (CX < centroidX_right);
    centTThresh = (OuterCY > centroidY_top);
    centBThresh = (OuterCY < centroidY_bot);
    %EccMaxThresh = (Eccentricities < 0.7); %0.7
    %EccMinThresh = (Eccentricities > 0.6);
    targetBubbles = centTThresh.*centBThresh.*minThresh.*maxThresh;%*EccMaxThresh;
                    % want all of the conditions to be true
    BW2 = ismember(LOuterArea,find(targetBubbles)); %find returns vector of indices 
                                        % of nonzero elements. ismember for 
                                        % data in L found in targetBubbles                                                                
    
  %display outer areas as blue
    blue = cat(3,zeros(size(BW2)), zeros(size(BW2)), ones(size(BW2)));
    h_blue = imshow(blue); %handle to blue image
    set(h_blue, 'AlphaData', BW2)
    
cont=1;
loopcount=0    
while cont==1
loopcount=loopcount+1;    
    disp('round 1: click on innerbubbles then press enter:')
    L3 = bwlabel(BW1);
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
    
    green = cat(3,zeros(size(L3)), ones(size(L3)), zeros(size(L3)));
    h_green = imshow(green); %handle to green image
    set(h_green, 'AlphaData', L3)% displays selected bubbles as green
   
    L3 = bwlabel(L3);
    Stats = regionprops(L3, 'Area', 'Eccentricity', 'Centroid'); 
    InnerArea = [Stats.Area];
    
    %end of round 1
 
   %(ROUND 2 to add more red)
 
    L3 = bwlabel(BW2);
    disp('round 2: click on outerbubbles then press enter:')
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
  
  
    Stats3 = regionprops(L3, 'Eccentricity', 'Orientation', 'Extent', 'Centroid', 'Area', 'Perimeter');
    for i = 1:length(Stats3)
        if(i~=[num])
            j = find(L3==i);
            L3(j) = 0;              
        end
    end   
 L3(find(L3))=1;
%  
    L3 = bwlabel(L3);
    Stats = regionprops(L3, 'Area', 'Eccentricity', 'Centroid'); 
    OuterArea = [Stats.Area]   

    %imshow(L3) %17 
    green = cat(3,zeros(size(L3)), ones(size(L3)), zeros(size(L3)));
    h_green = imshow(green); %handle to red image
    set(h_green, 'AlphaData', L3)% displays selected defects as red
   %end of round 2
MasterInnerAreas(loopcount,:)=InnerArea 
MasterOuterAreas(loopcount,:)=OuterArea   
MasterTotalAreas=[MasterInnerAreas+MasterOuterAreas]'

keyboard
end
          
end