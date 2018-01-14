%% VIDEO FRAME VIEWER
%
%     [ videoFrameViewer.m ]
%     This tool can be used to view + select frames from an inputted video
%
%     Input: [ 'video.avi', 'test.mp4' ]
%            (string of video file location)
%
%     Ouput: [ global FRAMEVA ]
%
%     Features:
%
%     - Allows user to view frames in a video through a slider interface
%     - When user clicks the push button, the selected frame
%       is outputted to a global variable that can be used in other scripts
%           > [ SEE FRAMEVA ]
%     - Function uses MATLAB's user-interface features (uicontrol)
%
% Developed JULY 2017 by Vidya Giri

function []=videoFrameViewer(dirfilename)
    global FRAMEVA;
    FRAMEVA=[];
    vidFile = VideoReader(dirfilename);
    frameMax = vidFile.NumberOfFrames;% frames in video file
    frameStart = 1;
    frameEnd=frameMax;
    frameTot = floor(length(frameStart:frameEnd)); %total processed 

    disp(['Reading video file data... ',num2str(frameTot),' frames']);    %Create Video and Read Data. Load the video file, pre-allocate space
    mov(1:frameMax) = struct('cdata', zeros(vidFile.Height,vidFile.Width,3,'uint8'));

    for k = frameStart:frameEnd
        vidFrames = read(vidFile,k);
        mov(k).cdata = vidFrames(:,:,:); % read data from each frame
    end

    disp('    ======== VIDEO READ ========');

    I = mov(frameStart).cdata;
    hFig = figure('menu','none');
    set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]); %[x y L W] where (0,0) is bottom left
    hAx = axes('Parent',hFig);
    SLIDER1= uicontrol('Parent',hFig, 'Style','slider', 'Value',frameStart, 'Min',frameStart,...
        'Max',frameEnd,'SliderStep',[1 1]./(frameEnd-frameStart), ...
        'Position',[130 20 260 20], 'Callback',@slider_callback); 
    hTxt = uicontrol('Style','text', 'Position',[250 50 45 20], 'String',num2str(frameStart));

    imshow(I); %show image

    % Callback function
    function slider_callback(hObj, ~)
        frame = round(get(hObj,'Value'));
        %disp(strcat('Current Frame:',num2str(frame),''));
        imshow(mov(frame).cdata, 'Parent',hAx)  
        set(hTxt, 'String',num2str(frame)) % update text
    end

    % Create push button when clicked saves value
    btn = uicontrol('Style', 'pushbutton', 'String', 'Done',...
        'Position', [420 25 50 20],...
        'Callback', @push_callback);   

    % Callback for pushbutton.
    function push_callback(varargin)
        N = get(SLIDER1,{'value'});
        N = double(round(N{1}));
        FRAMEVA=N;
        disp(strcat(' ==== Frame Value Saved:',num2str(N),' ===='))
        close all
    end
end