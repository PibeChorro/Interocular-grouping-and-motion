%% GENERAL FUNCTION AND MONITOR SETUP:

% Function creation for the experimental code.
function IOGMotionMain(setUp)

% Setup input for the monitor being used.

if nargin < 1
    setUp = 'Sarah Laptop';
end

%% OPEN PSYCHTOOLBOX FUNCTION:

% Opening psychtoolbox function ptb.

try
    ptb = PTBSettingsIOGMotion(setUp);
catch PTBERROR
    sca;
    rethrow(PTBERROR);
end
%% DESIGN-RELATED:

% Different design-related information.

design = getInstructions();
% the scenario determines the type(s) of low level cues for interocular
% grouping:
% 1: only orientation - no motion, no color
% 2: orientation and color - no motion
% 3: orientation and motion - no color
% 4: orientation, color and motion

design.scenario = 4;

design.stimulusPresentationTime = 90 - ptb.ifi/2;
design.ITI                      = 10 - ptb.ifi/2;
design.stimSizeInDegrees        = 1.7;
design.fixCrossInDegrees        = 0.25;
design.mondreanInDegrees        = 5;
design.whiteBackgroundInDegrees = 2.5;

design.stimSizeInPixelsX        = round(ptb.PixPerDegWidth*design.stimSizeInDegrees);
design.stimSizeInPixelsY        = round(ptb.PixPerDegHeight*design.stimSizeInDegrees);

design.fixCrossInPixelsX        = round(ptb.PixPerDegWidth*design.fixCrossInDegrees);
design.fixCrossInPixelsY        = round(ptb.PixPerDegHeight*design.fixCrossInDegrees);

design.mondreanInPixelsX        = int16(round(ptb.PixPerDegWidth*design.mondreanInDegrees));
design.mondreanInPixelsY        = int16(round(ptb.PixPerDegHeight*design.mondreanInDegrees));
mondreanMasks = make_mondrian_masks(double(design.mondreanInPixelsX), ...
    double(design.mondreanInPixelsY),1,1,1);
design.thisMask = rgb2gray(mondreanMasks{1});
backGroundTexture = Screen('MakeTexture', ptb.window, design.thisMask);

% resize stimuli
% define a rectangle where the stimulus is drawn
design.destinationRect = [...
    ptb.screenXpixels/2-design.stimSizeInPixelsX/2 ...
    ptb.screenYpixels/2-design.stimSizeInPixelsY/2 ...
    ptb.screenXpixels/2+design.stimSizeInPixelsX/2 ...
    ptb.screenYpixels/2+design.stimSizeInPixelsY/2];

% fixation cross
design.fixCrossCoords = [
    -design.fixCrossInPixelsX/2 design.fixCrossInPixelsX/2 0 0; ...
    0 0 -design.fixCrossInPixelsY/2 design.fixCrossInPixelsY/2
    ];
%% PARTICIPANT INFORMATION

% Collect participant information
participantInfo.age = input('Enter your age: ');
participantInfo.gender = input('Enter your gender: ', 's');

% Get subject number from user input
subjectNumber = input('Enter subject number: ');

% Generate filename based on subject number
filename = sprintf('Subject%d_ParticipantInfo.xlsx', subjectNumber);

%% INSTRUCTIONS:

% Experimental instructions with texts (using experimental function from another mat script).

try
    Experiment_Instructions(ptb);
catch instructionsError
    sca;
    rethrow(instructionsError);
end


%% FUSION TEST:

% Fusion test implementation before the experiment starts (Using the function of the other fusion script that was created).

try
    alignFusion(ptb, design);
catch alignFusionError
    sca;
    rethrow(alignFusionError);
end

%% DATA READING:

% Reading the different “Run” Excel files to be used later and being assigned to specific variable names.

try

    %     data = readtable('Run_1.xlsx');
    %     colorColumn1 = data.Color1;
    %     colorColumn2 = data.Color2;


    % Randomly select motion directions for each trial in cases 3 and 4
    if design.scenario == 3 || design.scenario == 4
        motionColumn1Options = {'no motion', 'upward motion', 'downward motion'};
        randomIndices1 = randperm(length(motionColumn1Options));
        motionColumn1 = motionColumn1Options{randomIndices1(1)};

        motionColumn2Options = {'rightward motion', 'leftward motion', 'no motion'};
        randomIndices2 = randperm(length(motionColumn2Options));
        motionColumn2 = motionColumn2Options{randomIndices2(1)};
    else
        motionColumn1 = 'no motion';
        motionColumn2 = 'no motion';
    end

    % Randomly select colors
    colorOptions = {'red', 'green', 'black'};
    randomIndicesColor1 = randperm(length(colorOptions));

    colorColumn1 = colorOptions{randomIndicesColor1(1)};

    % Ensure that colorColumn2 is complementary to colorColumn1
    switch colorColumn1
        case 'red'
            complementaryColor2 = 'green';
        case 'green'
            complementaryColor2 = 'red';
        case 'black'
            complementaryColor2 = 'black';
    end

    colorColumn2 = complementaryColor2;


    % Initialize isMotion to 'no motion'
    isMotion = 'no motion';

    % Check motionColumn1
    if strcmp(motionColumn1, 'upward motion')
        isMotion = 'upward motion';
    elseif strcmp(motionColumn1, 'downward motion')
        isMotion = 'downward motion';
    end

    % Check motionColumn2
    if strcmp(motionColumn2, 'rightward motion')
        isMotion = 'rightward motion';
    elseif strcmp(motionColumn2, 'leftward motion')
        isMotion = 'leftward motion';
    end

    % Initialize isColor to 'no color'
    isColor = 'no color';

    % Check color conditions
    if strcmp(colorColumn1, 'green') && strcmp(colorColumn2, 'red')
        isColor = 'green-red';
    elseif strcmp(colorColumn1, 'red') && strcmp(colorColumn2, 'green')
        isColor = 'red-green';
    end

    trialString = ['We are in a ' isMotion isColor ' trial'];
    fprintf(trialString);

catch readDataError
    sca;
    rethrow(readDataError);
end

%% REPETITION MATRIX FOR MOTION SIMULATION

x = repmat(1:314,314,1);

%% ALPHA MASKS -- MONDREAN MASKS

alphaMask1  = zeros(size(x));
alphaMask2 = alphaMask1;
alphaMask1(:,1:157) = 1;
alphaMask2(:,158:end) = 1;

%%  INTRODUCTION OF THE CASES/CONDITIONS:

% Introducing the different conditions of the experiment along with assigned variables.

while true
    switch design.scenario
        case 1 % 1: only orientation - no motion, no color
            rightGratingFreq1 = sin(x*0.3); % creates a sine-wave grating of spatial frequency 0.3
            scaledOrientationGrating = ((rightGratingFreq1+1)/2); % normalizes value range from 0 to 1 instead of -1 to 1

            rightGratingFreq2 = zeros(size(scaledOrientationGrating));
            rightGratingFreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

            leftGratingFreq1 = scaledOrientationGrating;
            leftGratingFreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

            scaledOrientationGrating(:,:,2)  = alphaMask1;
            rightGratingFreq2(:,:,2) = alphaMask2;

            leftGratingFreq1(:,:,2) = alphaMask2;
            leftGratingFreq2(:,:,2) = alphaMask1;

        case 2 % 2: orientation and color - no motion
            rightGratingFreq1 = sin(x*0.2);
            scaledOrientationGrating = ((rightGratingFreq1+1)/2);

            scaledOrientationGrating(:,:,2) = zeros(size(x));
            scaledOrientationGrating(:,:,3) = zeros(size(x));
            rightGratingFreq2 = zeros(size(scaledOrientationGrating));
            rightGratingFreq2(:,:,2) = scaledOrientationGrating(:,:,1)';

            leftGratingFreq1 = scaledOrientationGrating;
            leftGratingFreq2 = rightGratingFreq2;
            scaledOrientationGrating(:,:,4) = alphaMask1;
            rightGratingFreq2(:,:,4) = alphaMask2;

            leftGratingFreq1(:,:,4) = alphaMask2;
            leftGratingFreq2(:,:,4) = alphaMask1;
        case 3 % 3: orientation and motion - no color
            if strcmp(motionColumn1, 'upward motion')
                x = x + 1;
            elseif strcmp(motionColumn1, 'downward motion')
                x = x - 1;
            end
            if strcmp(motionColumn2, 'rightward motion')
                x = x + 1;
            elseif strcmp(motionColumn2, 'leftward motion')
                x = x - 1;
            end
            rightGratingFreq1 = sin(x*0.3);
            scaledOrientationGrating = ((rightGratingFreq1+1)/2);

            rightGratingFreq2 = zeros(size(scaledOrientationGrating));
            rightGratingFreq2(:,:,1) = scaledOrientationGrating(:,:,1)';

            leftGratingFreq1 = scaledOrientationGrating;
            leftGratingFreq2 = rightGratingFreq2;

            scaledOrientationGrating(:,:,2) = alphaMask1;
            rightGratingFreq2(:,:,2) = alphaMask2;

            leftGratingFreq1(:,:,2) = alphaMask2;
            leftGratingFreq2(:,:,2) = alphaMask1;

        case 4 % 4: orientation, color and motion
            if strcmp(motionColumn1, 'upward motion')
                x = x + 1;
            elseif strcmp(motionColumn1, 'downward motion')
                x = x - 1;
            end
            if strcmp(motionColumn2, 'rightward motion')
                x = x + 1;
            elseif strcmp(motionColumn2, 'leftward motion')
                x = x - 1;
            end
            rightGratingFreq1 = sin(x*0.2);
            scaledOrientationGrating = ((rightGratingFreq1+1)/2);

            scaledOrientationGrating(:,:,2) = zeros(size(x));
            scaledOrientationGrating(:,:,3) = zeros(size(x));
            rightGratingFreq2 = zeros(size(scaledOrientationGrating));
            rightGratingFreq2(:,:,2) = scaledOrientationGrating(:,:,1)';

            leftGratingFreq1 = scaledOrientationGrating;
            leftGratingFreq2 = rightGratingFreq2;
            scaledOrientationGrating(:,:,4) = alphaMask1;
            rightGratingFreq2(:,:,4) = alphaMask2;

            leftGratingFreq1(:,:,4) = alphaMask2;
            leftGratingFreq2(:,:,4) = alphaMask1;

            WaitSecs(0.01);

        otherwise
            error('You selected an undefined scenario!');
    end


    %% CREATION OF STIMULI AND CLOSING SCREENS
    % Creation of experimental stimuli with different features (textures, colors…)

    % Select image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 0);
    Screen('DrawTexture', ptb.window, backGroundTexture);

    tex1 = Screen('MakeTexture', ptb.window, scaledOrientationGrating);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex1, [], design.destinationRect);

    tex2 = Screen('MakeTexture', ptb.window, rightGratingFreq2);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex2, [], design.destinationRect);

    Screen('DrawLines', ptb.window, design.fixCrossCoords, ...
        ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

    % Select image buffer for true color image:
    Screen('SelectStereoDrawBuffer', ptb.window, 1);
    Screen('DrawTexture', ptb.window, backGroundTexture);

    tex1Other = Screen('MakeTexture', ptb.window, leftGratingFreq1);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex1Other, [], design.destinationRect);

    tex2Other = Screen('MakeTexture', ptb.window, leftGratingFreq2);     % create texture for stimulus
    Screen('DrawTexture', ptb.window, tex2Other, [], design.destinationRect);

    Screen('DrawLines', ptb.window, design.fixCrossCoords, ptb.lineWidthInPix, ptb.white, [ptb.xCenter ptb.yCenter]);

    Screen('DrawingFinished', ptb.window);
    Screen('Flip', ptb.window);

    Screen('Close', tex1);
    Screen('Close', tex2);
    Screen('Close', tex1Other);
    Screen('Close', tex2Other);
    break;
end


%% SAVING PARTICIPANT FILES ACCORDING TO THE RUN NUMBER:

% Saving participant’s mat files

if ~isfile(filename)
    headers = {'SubjectNumber', 'Age', 'Gender'};
    xlswrite(filename, headers, 'Sheet1', 'A1');
end

% Append participant information to the Excel file
xlswrite(filename, [subjectNumber, participantInfo.age, participantInfo.gender], 'Sheet1', 'A2');

end
