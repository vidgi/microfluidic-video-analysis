%% LUMINANCE VIEWER
%
%     [ luminanceViewer.m ]
%     This tool can be used to find a luminance value for an inputted image
%
%     Input: [ 'image.png', 'test.jpg' ]
%            (string of image file location)
%
%     Ouput: [ global LUMINAN ]
%
%     Features:
%
%     - Allows user to view inputted image at various luminance levels
%       through a slider interface
%     - When user clicks the push button, the selected luminance value
%       is outputted to a global variable that can be used in other scripts
%           > [ SEE LUMINAN ]
%     - Function uses MATLAB's user-interface features (uicontrol)
%
% Developed JULY 2017 by Vidya Giri

function []=luminanceViewer(image)
    global LUMINAN;
    LUMINAN=[];
    lumstart=0.2;
    
    I = imread(image);
    hFig = figure('menu','none');
    set(gcf, 'Units','normalized','position',[0 0 0.9 0.9]); %[x y L W] where (0,0) is bottom left
    hAx = axes('Parent',hFig);
    SLIDER1= uicontrol('Parent',hFig, 'Style','slider', 'Value',lumstart, 'Min',0,...
        'Max',1,'SliderStep',[0.01 0.01], ...
        'Position',[130 20 260 20], 'Callback',@slider_callback);
    hTxt = uicontrol('Style','text', 'Position',[250 50 45 20], 'String',num2str(lumstart));

    imshow(im2bw(I,lumstart));    % show image

    % Callback function
    function slider_callback(hObj, ~)
        lum = round(get(hObj,'Value'),2); 
        %disp(strcat('Current Luminance Value:',num2str(lum),''));
        imshow(im2bw(I,lum), 'Parent',hAx)  
        set(hTxt, 'String',num2str(lum,3)) % update text
    end

    % Create push button to output value
    btn = uicontrol('Style', 'pushbutton', 'String', 'Done',...
        'Position', [420 25 50 20],...
        'Callback', @push_callback);
    
    % Callback for pushbutton.
    function push_callback(varargin)
        N = get(SLIDER1,{'value'});
        N = double(round(N{1},2));
        LUMINAN=N;
        disp(strcat(' ==== Luminance Value Saved:',num2str(N),' ===='))
        close all
    end
end