%% PINCH LOCATION ANALYZER
%
%     Analyzes alternating pinch phenomena from high speed video files.

%     Features:
%
%     - Calls on GUI to find videoframes to analyze narrow channel end,
%       pre-pinch, and post-pinch images 
%           > [ SEE videoFrameViewer.m ]
%     - Calls on GUI to find luminance values for a selected image
%           > [ SEE luminanceViewer.m ]
%     - Creates organized data tables for easy transfer to spreadsheet
%           > [ SEE dataTEXT, dataTABLE ]
%
% Developed JULY 2017 to analyze 80 x 64 videos
% Version 1.1 (comments and other options to be added if needed)
% Fixed errors in data output, added extra coordinates in prepinch

%% INITIALIZE VIDEO + VARIABLES
clear
clc
close all

global FRAMEVA
global LUMINAN

filePath = '/';%/Volumes/VIDYA/avis/'; %'D:\Research\Expansion Pinch-Off\3-22-17 Wafer 5\Far Right\400 x 304\'; %'C:\Users\Daniel\Desktop\Rice\Research\1-17-15 AOS Air\';
fileName = '14 mlhr 1100 mbar 50000 pps 80 x 64 First 300 Frames';

fileExt = '.avi';
dirfilename= [filePath,fileName, fileExt];

%% CHOOSES VIDEO FRAMES AND SAVES AS I0/I1/I2
videoFrameViewer(dirfilename) % GUI function (videoFrameViewer.m)
waitfor(1);
frame0=FRAMEVA; 

videoFrameViewer(dirfilename) % GUI function (videoFrameViewer.m)
waitfor(1);
frame1=FRAMEVA; 
frame2=frame1+1;

% Read Selected Frames:
vidFile = VideoReader(dirfilename);
frameMax = vidFile.NumberOfFrames;% frames in video file
frameStart = frame0;
frameStep = 1;
frameEnd=frame2;
frameTot = floor(length(frameStart:frameStep:frameEnd)); %total processed 

mov(1:frameMax) = struct('cdata', zeros(vidFile.Height,vidFile.Width,3,'uint8'));%Create Video and Read Data. Load the video file, pre-allocate space
for k = frameStart:frameStep:frameEnd
    vidFrames = read(vidFile,k);
    mov(k).cdata = vidFrames(:,:,:); % read data from each frame
end

% Saves Frames as I1.png and I2.png
I0 = mov(frame0).cdata;
imwrite(I0,'I0.png')
I1 = mov(frame1).cdata;
imwrite(I1,'I1.png')
I2 = mov(frame2).cdata;
imwrite(I2,'I2.png')

%% CHOOSES LUMINANCE FOR I0/I1/I2

luminanceViewer('I0.png') % GUI function (luminanceViewer.m)
waitfor(1);
lum0=LUMINAN;

luminanceViewer('I1.png') % GUI function (luminanceViewer.m)
waitfor(1);
lum1=LUMINAN;

luminanceViewer('I2.png')
waitfor(1);
lum2=LUMINAN;

%% ANALYSIS of I0/I1/I2

% I0
    I=imread('I0.png');
    BW = im2bw(I,lum0); % Convert the image to a logical array
    BWLam = 1 - BW;
    
    hFig=figure;
    imshow(I,'InitialMagnification', 1000)
    set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]);

    hold on
    h = text(5, 5, '[narrow channel end // 2 pts]');
    set(h,'Color','r','FontSize',16,'FontWeight','bold'); 
    
    white = cat(3,ones(size(BWLam)), ones(size(BWLam)), ones(size(BWLam)));
    h_white = imshow(white); %handle to white image
    set(h_white, 'AlphaData', BWLam)

    [I0coord(:,1),I0coord(:,2)]=getpts;
    I0coord = round(I0coord,1);
    I0coord = sortrows(I0coord,2);
    plot(I0coord(:,1),I0coord(:,2),'rs','MarkerSize',7,'MarkerFaceColor','r')
    
    narrowEndTopX=I0coord(1,1);
    narrowEndTopY=I0coord(1,2);
    
    narrowEndBottomX=I0coord(2,1);
    narrowEndBottomY=I0coord(2,2);
    
    h = text(5, 8, strcat('top: (',num2str(narrowEndTopX),',',num2str(narrowEndTopY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 11, strcat('bottom: (',num2str(narrowEndBottomX),',',num2str(narrowEndBottomY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 

    hold off

% I1
    I=imread('I1.png');
    BW = im2bw(I,lum1); % Convert the image to a logical array
    BWLam = 1 - BW;
    
    figure
    imshow(I,'InitialMagnification', 1000)
    set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]);
    
    hold on
    h = text(5, 5, '[pre-pinch middle // 3 pts]');
    set(h,'Color','y','FontSize',16,'FontWeight','bold'); 
    
    white = cat(3,ones(size(BWLam)), ones(size(BWLam)), ones(size(BWLam)));
    h_white = imshow(white); %handle to white image
    set(h_white, 'AlphaData', BWLam)
    
    plot(I0coord(:,1),I0coord(:,2),'rs','MarkerSize',7,'MarkerFaceColor','r')

    [I1coord(:,1),I1coord(:,2)]=getpts;
    I1coord = round(I1coord,1);
    plot(I1coord(:,1),I1coord(:,2),'ys','MarkerSize',7,'MarkerFaceColor','y')
    
    prepinchUpperTopX=I1coord(1,1);
    prepinchUpperTopY=I1coord(1,2);
    
    prePinchMiddleX=I1coord(2,1);
    prePinchMiddleY=I1coord(2,2);
    
    prepinchLowerBottomX=I1coord(3,1);
    prepinchLowerBottomY=I1coord(3,2);
    
    h = text(5, 8, strcat('middle: (',num2str(prePinchMiddleX),',',num2str(prePinchMiddleY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 11, strcat('upper bubble top: (',num2str(prepinchUpperTopX),',',num2str(prepinchUpperTopY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 14, strcat('lower bubble bottom: (',num2str(prepinchLowerBottomX),',',num2str(prepinchLowerBottomY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 

    
% I2
    I=imread('I2.png');
    BW = im2bw(I,lum2); % Convert the image to a logical array
    BWLam = 1 - BW;
    
    figure
    imshow(I,'InitialMagnification', 1000)
    set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]);
    hold on
    h = text(5, 5, '[post-pinch bubbles // 4 pts]');
    set(h,'Color','b','FontSize',16,'FontWeight','bold'); 
    
    white = cat(3,ones(size(BWLam)), ones(size(BWLam)), ones(size(BWLam)));
    h_white = imshow(white); %handle to white image
    set(h_white, 'AlphaData', BWLam)

    plot(I0coord(:,1),I0coord(:,2),'rs','MarkerSize',7,'MarkerFaceColor','r')
    plot(I1coord(:,1),I1coord(:,2),'ys','MarkerSize',7,'MarkerFaceColor','y')

    [I2coord(:,1),I2coord(:,2)]=getpts;
    I2coord = round(I2coord,1);
    I2coord = sortrows(I2coord,2);
    plot(I2coord(:,1),I2coord(:,2),'bs','MarkerSize',7,'MarkerFaceColor','b')
    
    UpperBubbleTopX=I2coord(1,1);
    UpperBubbleTopY=I2coord(1,2);
    
    UpperBubbleBottomX=I2coord(2,1);
    UpperBubbleBottomY=I2coord(2,2);
    
    LowerBubbleTopX=I2coord(3,1);
    LowerBubbleTopY=I2coord(3,2);

    LowerBubbleBottomX=I2coord(4,1);
    LowerBubbleBottomY=I2coord(4,2);
    
    h = text(5, 8, strcat('upper bubble top: (',num2str(UpperBubbleTopX),',',num2str(UpperBubbleTopY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 11, strcat('upper bubble bottom: (',num2str(UpperBubbleBottomX),',',num2str(UpperBubbleBottomY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 14, strcat('lower bubble top: (',num2str(LowerBubbleTopX),',',num2str(LowerBubbleTopY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    h = text(5, 17, strcat('lower bubble bottom: (',num2str(LowerBubbleBottomX),',',num2str(LowerBubbleBottomY),')'));
    set(h,'Color','w','FontSize',16,'FontWeight','bold'); 
    hold off
    
%% OUTPUT FINAL DATA
    
dataTEXT  = {dirfilename};
dataTABLE = [frame0	              lum0	                ...
             narrowEndTopX	      narrowEndTopY         ...
             narrowEndBottomX	  narrowEndBottomY      ...
             frame1               lum1                  ...
             prePinchMiddleX      prePinchMiddleY       ...
             prepinchUpperTopX    prepinchUpperTopY     ...
             prepinchLowerBottomX prepinchLowerBottomY  ...
             frame2               lum2                  ...
             UpperBubbleTopX	  UpperBubbleTopY       ...
             UpperBubbleBottomX   UpperBubbleBottomY    ...
             LowerBubbleTopX	  LowerBubbleTopY       ...          
             LowerBubbleBottomX	  LowerBubbleBottomY      ];
 
  %dataTABLE2 = [ narrowEndBottomX prepinchLowerBottomX UpperBubbleBottomX ];        
         

    disp('    ============= code finished! =============')

