%% quicklengthcode
clear; clc; close all
%mod dec 2nd
global FRAMEVA

filePath = '/For Vidya Asymmetry/9-6-17 - To Do First/20% Glycerol/';%/Volumes/VIDYA/avis/'; %'D:\Research\Expansion Pinch-Off\3-22-17 Wafer 5\Far Right\400 x 304\'; %'C:\Users\Daniel\Desktop\Rice\Research\1-17-15 AOS Air\';
fileName = '20 mlhr 1100 mbar 80 x 64 54054 fps Channel';

fileExt = '.avi';
dirfilename= [filePath,fileName, fileExt];
dataTEXT  = {dirfilename};

cont=1;
counter=0;
while cont==1
    counter=counter+1;
    disp('ROUND#:');     
    disp(num2str(counter));
    
    videoFrameViewer(dirfilename) % GUI function (videoFrameViewer.m)
    waitfor(1);
    frameval=FRAMEVA;
    
    % Read Selected Frame:
    vidFile = VideoReader(dirfilename);
    frameMax = vidFile.NumberOfFrames;% frames in video file
    frameStart = frameval;
    
    mov(1:frameMax) = struct('cdata', zeros(vidFile.Height,vidFile.Width,3,'uint8'));%Create Video and Read Data. Load the video file, pre-allocate space
    for k = frameStart;
        vidFrames = read(vidFile,k);
        mov(k).cdata = vidFrames(:,:,:); % read data from each frame
    end
    
    f = frameStart;
        I=mov(f).cdata;
        hFig=figure;
        imshow(I,'InitialMagnification', 1000)
        set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]);
        rect = getrect;
        %bubbleLength=rect(3)
        bubbleHeight=rect(4)

   %MasterBubbleLength(:,counter)=bubbleLength;
   MasterBubbleHeight(:,counter)=bubbleHeight;
end
