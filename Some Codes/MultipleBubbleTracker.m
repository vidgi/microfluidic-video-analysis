%% MULTIPLE BUBBLE TRACKING AND MEASUREMENT

% Analyzes high speed video files of narrow channel bubbles

%     Features:
%
%     - Measures bubble length, width, and spacing
%     - Tracks objects of a selected size and identifies when they 
%       enter or leave the frame 
%     - Saves array of all the frame data to computer with file name 
%       based on condition, frames analyzed, and luminance value
%     - Creates organized data tables for easy transfer to spreadsheet
%           > [ SEE dataTEXT, dataOVERALL, dataTRACK ]
%     - Option to switch images ON or OFF to allow for faster computations

% Developed JULY 2017 to analyze 176 x 80 videos
% Version 1.1 (comments and other options to be added if needed)
% Written by Vidya Giri

%% SECTION 1: READING VIDEO
tic
close all % close open figure windows
clear all % clear workspace variables
clc % clear command window

%Load Video
filePath = '/';
%filePath = '/3-22-17 Size Groupings/100-109 Diameter/176x80/';
fileName = '10 mlhr 875 mbar 30000 pps 176 x 80 First 2600 Frames';

fileExt = '.avi';
vidFile = VideoReader([filePath,fileName, fileExt]);
frameMax = vidFile.NumberOfFrames; 
 
%Parameters
frameStart = 4;
frameEnd=1000;%frameMax;%1000;%1000;
level = 0.55; % luminance value, change to make bubble segmented
imageon=1 % Turn off images to save time
          % 0/1 = images off/images on 

%More Parameters
frameStep = 1;
frameTot = floor(length(frameStart:frameStep:frameEnd)); %total processed 
bubbleAreaTol=20; % +/- px areaSelected --> areaSelectedMin/areaSelectedMax
spacingtol=0.7; % * bubbleSpacing
HeightTol=3;%px
areaMin = 5; % px of smallest bubble area (definitely > 5)
areaMax = 300; % px of biggest bubble area
BBleftedge = 2;
BBrightedge = 105;

centroidcontrol=0; %0 = no centroid control, 1 = centroid control
CYMin = 28;%35;
CYMax = 35;%45;

%Create Video and Read Data. Load the video file, pre-allocate space
disp(['Reading video file data... ',num2str(frameTot),' frames selected']);
mov(1:frameMax) = struct('cdata', zeros(vidFile.Height,vidFile.Width,3,'uint8'));

tic 
for k = frameStart:frameStep:frameEnd
    vidFrames = read(vidFile,k);
    mov(k).cdata = vidFrames(:,:,:);
end
toc

%% SECTION 2: SIZE SELECTION

disp(' '); disp('    ======== SIZE SELECTIONS ========'); disp(' ');
tic 

for f = frameStart
    
    BW = im2bw(mov(f).cdata, level); 
    figure %0/1
    imshow(BW) 
    set(gcf, 'Units','normalized','position',[0 0 0.4 0.4]); %[x y L W] where (0,0) is bottom left
    keyboard
    
    L = bwlabel(BW,8); 
    Stats = regionprops(L, 'Centroid', 'BoundingBox', 'Area'); 
    Areas = [Stats.Area]; 
    Centroids = [Stats.Centroid]; 
    CX = Centroids(1:2:end); 
    CY = Centroids(2:2:end); 
    
    BoundingBox = [Stats.BoundingBox];                        
    BBX = BoundingBox(1:4:end); 
    BBY = BoundingBox(2:4:end); 
    BBW = BoundingBox(3:4:end); 
    BBH = BoundingBox(4:4:end); 

    minThresh = (Areas >= areaMin); 
    maxThresh = (Areas < areaMax);
    BBLThresh = (BBX > BBleftedge);
    BBRThresh = (BBX+BBW < BBrightedge);  
 
    targetBubbles = minThresh.*maxThresh.*BBRThresh.*BBLThresh;
    BW1 = ismember(L,find(targetBubbles));
    L = bwlabel(BW1,8); 
    Stats = regionprops(L, 'Centroid', 'BoundingBox', 'Area'); 
    Areas = [Stats.Area]; 
    Centroids = [Stats.Centroid];
    CX = Centroids(1:2:end); 
    CY = Centroids(2:2:end);
    
    BoundingBox = [Stats.BoundingBox];                        
    BBX = BoundingBox(1:4:end); 
    BBY = BoundingBox(2:4:end); 
    BBW = BoundingBox(3:4:end); 
    BBH = BoundingBox(4:4:end); 
    
    figure%1/2                                 
    imshow(mov(f).cdata)
    set(gcf, 'Units','normalized','position',[0 1 0.8 0.8]); %[x y L W] where (0,0) is bottom left
   
    [B,L,~,~] = bwboundaries(BW1);
    hold on;
    colors=['b' 'g' 'r' 'c' 'm' 'y'];
    for k=1:length(B),
      boundary = B{k};
      cidx = mod(k,length(colors))+1;
      plot(boundary(:,2), boundary(:,1),...
           colors(cidx),'LineWidth',1);
      rndRow = ceil(length(boundary)/(mod(rand*k,7)+1)); %randomize text position for better visibility
      col = boundary(rndRow,2); row = boundary(rndRow,1);
      h = text(col+1, row-1, num2str(L(row,col)));
      set(h,'Color',colors(cidx),'FontSize',10,'FontWeight','bold');
    end

% Finding BBrightedge
    h = text(80, 10,'right edge:');
    set(h,'Color','w','FontSize',16,'FontWeight','bold');  
    rect = getrect;
    BBrightedge=rect(1)+rect(3);
    h = text(115, 10,num2str(BBrightedge));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    pause(0.1)    
  
% Measuring BUBBLE HEIGHT
    h = text(10, 10,'bubble height:');
    set(h,'Color','w','FontSize',16,'FontWeight','bold');
    rect = getrect;
    bubbleHeight=rect(4);
    h = text(60, 10,num2str(bubbleHeight));
    set(h,'Color','w','FontSize',16,'FontWeight','bold');
    pause(0.1)
    
% Measuring BUBBLE LENGTH
    h = text(10, 17, 'bubble length:');
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    rect = getrect;
    bubbleLength=rect(3);
    h = text(60, 17,num2str(bubbleLength));
    set(h,'Color','w','FontSize',16,'FontWeight','bold');
    pause(0.1)
    
 % Measuring BUBBLE Spacing
    h = text(10, 24, 'bubble spacing:');
    set(h,'Color','w','FontSize',16,'FontWeight','bold');  
    rect = getrect;
    bubbleSpacing=rect(3); 
    h = text(60, 24,num2str(bubbleSpacing));
    set(h,'Color','w','FontSize',16,'FontWeight','bold');
    pause(0.1)   
    
% SELECTING BUBBLE WITH BOUNDING BOX 
    CYrect = CY; %  y positions
    CXrect = CX; %  x positions    
    
    h = text(10, 70, 'bubble selection:');
    set(h,'Color','w','FontSize',16,'FontWeight','bold');   
    rect = getrect;
    centroidY_top=rect(2); 
    centroidY_bot=rect(2)+rect(4); 
    centroidY_left=rect(1); 
    centroidY_right=rect(1)+rect(3); 
        
    centTThresh1New = (CYrect > centroidY_top);
    centBThresh1New = (CYrect < centroidY_bot);
    centLThresh1New = (CXrect > centroidY_left);
    centRThresh1New = (CXrect < centroidY_right);

    targetRect = centTThresh1New.*centBThresh1New.*centLThresh1New.*centRThresh1New;
    BWRectSelect = ismember(L,find(targetRect));

    white = cat(3,ones(size(BWRectSelect)), ones(size(BWRectSelect)), ones(size(BWRectSelect)));
    h_white = imshow(white);
    set(h_white, 'AlphaData', BWRectSelect)
    
   % find centroid and area and BB of rectangle selected bubble
   L = bwlabel(BWRectSelect); %
   Stats = regionprops(L,'Centroid','Area','BoundingBox'); 
   Centroids = [Stats.Centroid];
   CYselected = Centroids(2:2:end); %  y positions
   CXselected = Centroids(1:2:end); %  x positions
   
   BoundingBox = [Stats.BoundingBox];                        
    BBX = BoundingBox(1:4:end); 
    BBY = BoundingBox(2:4:end); 
    BBW = BoundingBox(3:4:end); 
    BBH = BoundingBox(4:4:end); 
   
   plot(CXselected,CYselected,'b*','MarkerSize',2)
   areaSelected=[Stats.Area];
   BBheightMax=BBH+HeightTol;
   
   % makes a suitable range of bubble sizes (+/- bubbleAreaTol px)
   areaSelectedMin=areaSelected-bubbleAreaTol;
   areaSelectedMax=areaSelected+bubbleAreaTol;
   
   h = text(65, 70,num2str(areaSelected));
   set(h,'Color','w','FontSize',16,'FontWeight','bold');
   pause(0.1)   
   
   set(gcf, 'Units','normalized','position',[0 1 0.4 0.4]); %[x y L W] where (0,0) is bottom left

% find bubbles of this size in frame
    L = bwlabel(BW1,8); 
    Stats = regionprops(L,'Area','BoundingBox'); 
    Areas = [Stats.Area]; 
    BoundingBox = [Stats.BoundingBox];                        
    BBH = BoundingBox(4:4:end); 

    minThresh = (Areas >= areaSelectedMin); 
    maxThresh = (Areas < areaSelectedMax);
    HeightThresh = (BBH < BBheightMax);
    
    targetBubbles = minThresh.*maxThresh.*HeightThresh;
    
    bwBubbles = ismember(L,find(targetBubbles));  
    LBubbles = bwlabel(bwBubbles,8); 
    Stats = regionprops(LBubbles, 'Centroid', 'BoundingBox', 'Area'); 
    Areas = [Stats.Area]; 
    Centroids = [Stats.Centroid]; 
    CX = Centroids(1:2:end);
    CY = Centroids(2:2:end);
     
    BoundingBox = [Stats.BoundingBox];                        
    BBX = BoundingBox(1:4:end); 
    BBY = BoundingBox(2:4:end); 
    BBW = BoundingBox(3:4:end); 
    BBH = BoundingBox(4:4:end); 
    
    figure%2/3                                
    imshow(mov(f).cdata)
    set(gcf, 'Units','normalized','position',[0 0 0.4 0.4]); %[x y L W] where (0,0) is bottom left
    
    [B,L,N,~] = bwboundaries(bwBubbles);
    hold on;
    colors=['b' 'g' 'r' 'c' 'm' 'y'];
    for k=1:length(B),
      boundary = B{k};
      cidx = mod(k,length(colors))+1;
      plot(boundary(:,2), boundary(:,1),...
           colors(cidx),'LineWidth',1);
      rndRow = ceil(length(boundary)/(mod(rand*k,7)+1)); %randomize text position for better visibility
      col = boundary(rndRow,2); row = boundary(rndRow,1);
      h = text(col+1, row-1, num2str(L(row,col)));
      set(h,'Color',colors(cidx),'FontSize',10,'FontWeight','bold');
    end    
  h = text(10, 70, 'bubble range:');
  set(h,'Color','w','FontSize',16,'FontWeight','bold');
  h = text(55, 70,strcat(num2str(areaSelectedMin),'-',num2str(areaSelectedMax)));
    set(h,'Color','w','FontSize',16,'FontWeight','bold');
end

% up to here the code just finds the appropriate bubbles to analyze using
% the first frame and will continue to use these values for the next frames

%% SECTION 3: ANALYZE THE WHOLE VIDEO SECTION

disp(' '); disp('    ======== ANALYZING FRAMES ========'); disp(' ');
 % initialize data matrix
 AllData = struct('FrameNumber',zeros([1,frameTot]), ...
                  'Areas',{cell([1,frameTot])}, ...
                  'CentroidX',{cell([1,frameTot])}, ...
                  'CentroidY',{cell([1,frameTot])}, ...
                  'NumberOfBubbles', zeros([1,frameTot]));
close all    
count=0; % for-loop counter
figure %1

for g = frameStart:frameStep:frameEnd
    count=count+1;
    %disp(['Analyzing frame ',num2str(g),' of ',num2str(frameEnd)]);
    image1=mov(g).cdata;
    
    if imageon==1
        %clf(1)
        imshow(image1)
        set(gcf, 'Units','normalized','position',[0 1 0.4 0.4]); %[x y L W] where (0,0) is bottom left
        hold on
    else
    end
    
    BWg = im2bw(image1, level); 
    L = bwlabel(BWg,8); 
    Stats = regionprops(L, 'Centroid', 'BoundingBox', 'Area');
    Areas = [Stats.Area]; 
    Centroids = [Stats.Centroid]; 
    CX = Centroids(1:2:end); 
    CY = Centroids(2:2:end);
    
    BoundingBox = [Stats.BoundingBox];
    BBX = BoundingBox(1:4:end);
    BBY = BoundingBox(2:4:end);
    BBW = BoundingBox(3:4:end);
    BBH = BoundingBox(4:4:end);
    
    minThresh = (Areas >= areaSelectedMin); 
    maxThresh = (Areas < areaSelectedMax);
    BBLThresh = (BBX > BBleftedge);
    BBRThresh = (BBX+BBW < BBrightedge);
    HeightThresh = (BBH < BBheightMax);
    
    if centroidcontrol==1
    CentroidTThresh = (CY<CYMax);
    CentroidBThresh = (CY>CYMin);
    targetBubbles = minThresh.*maxThresh.*BBRThresh.*BBLThresh.*HeightThresh.*CentroidTThresh.*CentroidBThresh;

    else
    targetBubbles = minThresh.*maxThresh.*BBRThresh.*BBLThresh.*HeightThresh;

    end
    

    BWg = ismember(L,find(targetBubbles)); 
    
    if imageon==1
        pink = cat(3,ones(size(BWg)), zeros(size(BWg)), ones(size(BWg)));
        h_pink = imshow(pink); 
        set(h_pink, 'AlphaData', BWg)
        hold off
  
        h = text(10, 10, strcat('frame',num2str(g)));
        set(h,'Color','w','FontSize',16,'FontWeight','bold');
        pause(0.1)
    else
    end
    
    Lg = bwlabel(BWg);
    Stats = regionprops(Lg,'Area','Centroid','BoundingBox');
    Centroidsg = [Stats.Centroid]; 
    CXg = Centroidsg(1:2:end); 
    CYg = Centroidsg(2:2:end);
    Areasg = [Stats.Area];
    
    %     BoundingBoxg = [Stats.BoundingBox];
    %     BBXg = BoundingBoxg(1:4:end);
    %     BBYg = BoundingBoxg(2:4:end);
    %     BBWg = BoundingBoxg(3:4:end);
    %     BBHg = BoundingBoxg(4:4:end);
      
    AllData.FrameNumber(count) = g;
    AllData.NumberOfBubbles(count) = length(CXg);
    AllData.CentroidX(count)={(CXg)};
    AllData.CentroidY(count)={(CYg)};
    AllData.Areas(count)={(Areasg)};
%keyboard
%pause(0.1)
    
end
%keyboard
disp('OPERATION COMPLETED: ALL FRAMES READ!')
 
%% SECTION 4: MATCH UP SECTION

disp(' '); disp('    ======== MATCHING FRAME DATA TO GET TRACKS  ========'); disp(' ');
FN=AllData.FrameNumber;
X=AllData.CentroidX;
Y=AllData.CentroidY;
A=AllData.Areas;
matcombine=cell(1); % initialize
counta=0;

for a = 1:frameTot % frame number
    maxobj=length(X{a});
    for objectnum=1:maxobj % object number in frame
        counta=counta+1;
        matA=[FN(a) a objectnum X{a}(objectnum) Y{a}(objectnum) A{a}(objectnum)];
        
        % check if matA matches other in cell array
        if a~=1 % don't check the first frame
            elemen=numel(matcombine);% number of matrices in matcombine
            breakval=0; % resets breakval
            for IDNUM=1:elemen % for all elements in the matcombine
                identcheck=isequal(matA,matcombine{IDNUM});
                if identcheck==1
                    breakval=1 ;
                else
                end
            end
            
            if breakval==1 % break loop
                counta=counta-1;
                break % goes to next object
            else
            end
       
        else % doesn't check first frame
        end
        
        % (if it does not match then do the below)
        matcombine{counta,1}=matA; % new row matcombine
        matprev=matA;
        countb=1;
        
        for b=a+1:frameTot% next frames
            countb=countb+1  ;
            [diffe,objectnum2] = min(abs(X{b}-matprev(1,4)));
            matB=[FN(b) b objectnum2 X{b}(objectnum2) Y{b}(objectnum2) A{b}(objectnum2)];
            
            if diffe<spacingtol*(bubbleSpacing)
                matcombine{counta,countb}=matB;
                matprev=matB;
            else
                break% goes on to next a value
            end
        end
    end   
end

[tracks,arrsize]=size(matcombine);
avavspeed=[];
for tr=1:tracks
    ALLDATAFINAL=[];
    
    for ar=1:arrsize
        ALLDATAFINAL=[ALLDATAFINAL matcombine{tr,ar}'];
    end
    
    differences=diff(ALLDATAFINAL(4,:)');
    mean(differences);
    
    lastframefortrack(tr)=max(ALLDATAFINAL(1,:));
    firstframefortrack(tr)=min(ALLDATAFINAL(1,:));
    avavspeed(tr)=mean(differences);
end

frametimetrack=lastframefortrack-firstframefortrack;
TRACKNUM=1:tracks;
tabledata=[TRACKNUM'  firstframefortrack' lastframefortrack' avavspeed' frametimetrack'];
[tablerows,~]=size(tabledata);
delrow=[];
for rowcheck=1:tablerows
    if isnan(tabledata(rowcheck,4))
        delrow=[delrow ;rowcheck];
        %tabledata(rowcheck,:)=[]
    else
    end
    
    if tabledata(rowcheck,2)==frameStart
        delrow=[delrow ;rowcheck];
        %tabledata(rowcheck,:)=[]
    else
    end
    
    if tabledata(rowcheck,3)==frameEnd
        delrow=[delrow ;rowcheck];
    else
    end
end

close all

    tabledataold=tabledata;
    [totaloldtracks,~]=size(tabledataold);
    tabledata(delrow,:)=[];

    tabledata(:,5)=[];
    [totaltracks,~]=size(tabledata);
    deletedtracks=totaloldtracks-totaltracks;

    AVERAGESpeed=mean(tabledata(:,4));
    STDSpeed=std(tabledata(:,4));

    
    aframes=max(tabledata(:,3)) - min(tabledata(:,2));
    bubblesPerFrame=totaltracks/aframes;

    
% FINAL OUTPUT STUFF BELOW

    dataARRAY=matcombine;
    dataArrayName=strcat('dataARRAY/',fileName,'-Frame',num2str(frameStart),'-',...
                  num2str(frameEnd),'-Lum',num2str(level),'-dataARRAY.mat');     
    saveMatlabNAME = matlab.lang.makeValidName(dataArrayName);          
    eval([saveMatlabNAME '= dataARRAY;']);                  
    save(dataArrayName,saveMatlabNAME);
    disp('ARRAY SAVED AS:');
    disp(dataArrayName);

    dataTEXT = {fileName dataArrayName}; % 1 x 2
    dataOVERALL=[ frameStart frameEnd level totaltracks ...
                 AVERAGESpeed STDSpeed bubblesPerFrame BBrightedge ...
                  bubbleSpacing bubbleLength bubbleHeight]; % 1 x 11
    dataTRACK=tabledata;%[ ? x 4]

disp(' ');
disp('code finished!');
disp(' ');

toc