function Experiment_Instructions(ptb)

instructionsArray_1 = {
    ['Thank you for choosing to participate in this study involving interocular grouping\n' ...
    'By pressing any key button, you will be re-directed to a series of instructions \n' ...
    'informing you about what you are required to do in this experiment'];
    ['You will first have a fusion test, in which you will be presented with \n' ...
    'two rectangular frames which you should fuse together using the left or right' ...
    'arrows. Once this is done, click space to continue'];
    ['You will now have a task with four different conditions: \n' ...
    'Condition 1: You will have two sine-wave gratings with different orientations (orthogonal to each other)\n' ...
    'Condition 2: You will have both orthogonal orientations\n and different colors in each grating - green and red\n' ...
    'Condition 3: You will have orthogonal orientations of the gratings and motion\n' ...
    'Condition 4: You will have all three: Orientations, motion, and colors\n' ...
    'Press any key to continue to the Fusion test '];
};

instructionsArray_2 = {
    'Now you will be redirected to the actual experiment. \n' ...
    'If the images presented to both eyes merge together to form a coherent pattern\n'...
    'press key number 4. If the images remain monocularly perceived, press key number 7.'
};

for inst1 = 1:length(instructionsArray_1)
    TextDisplay = instructionsArray_1{inst1};

%   framesize = max([ptb.screenXpixels, ptb.screenYpixels])/3;
    %         Screen('FillRect', ptb.window, [0.5 0.5 0.5], ptb.windowRect);
    Screen('TextSize', ptb.window, 15);
    %         Screen('TextFont', ptb.window, 'Times');
    Screen('TextStyle', ptb.window, 0);
    
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);
    
    Screen('Flip', ptb.window);
    
    % Wait for any key press
    KbWait();
    WaitSecs(0.5);
end

% try
%     alignFusion(ptb, design)
% catch alignFusionError
%     sca;
%     close all;
%     rethrow(alignFusionError);
% end

for inst2 = 1:length(instructionsArray_2)
    TextDisplay = instructionsArray_2{inst2};

%   framesize = max([ptb.screenXpixels, ptb.screenYpixels])/3;
    %         Screen('FillRect', ptb.window, [0.5 0.5 0.5], ptb.windowRect);
    Screen('TextSize', ptb.window, 15);
    %         Screen('TextFont', ptb.window, 'Times');
    Screen('TextStyle', ptb.window, 0);
    
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    
    DrawFormattedText(ptb.window, TextDisplay,'center', 'center');
    
    % Tell PTB drawing is finished for this frame:
    Screen('DrawingFinished', ptb.window);
    
    Screen('Flip', ptb.window);
    
    % Wait for any key press
    KbWait();
    WaitSecs(0.5);
end


end