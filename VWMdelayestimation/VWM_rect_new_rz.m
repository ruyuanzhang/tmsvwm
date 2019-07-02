% 2014/10/11
% VWM color-delayed estimation task
%
% 
%
% History
%   20190629 RZ modified original code


clear all;

%% Parameter you want to change
subj = 'RZ';
nStim = input('Please input number of stimuli: ', '%d');

nTrials = 160;
scrSize = []; % [width, height] cm
scale_factor = 2; % important factor
%% stimuli parameters
ovalr = 5; % pixels, radius of fixation oval
radin = 7.8; % deg,
radout = 9.8; % deg,
bg = 192; % background color intensity
nPosi = 8; % How many possible positions that stimuli can occur  
posiRadius = 4; % deg, radius of stimulus presentation distance from center of screen
shapeSize = 1.5; % deg, diameter (circle) or edge length of an object

%% Experimental parameters
delayDur = 1; % seconds;
sampleDur = 0.11; % sample duration

%% calculate some parameters
radin = radin * 60 / scale_factor;
radout = radout * 60 / scale_factor; 
posiRadius = posiRadius * 60 / scale_factor; 
shapeSize = shapeSize * 60 / scale_factor;

colorinfo=zeros(100, 8, 3);  %

%% Open window
Screen('Preference', 'SkipSyncTests', 1);
Screens = Screen('Screens');
ScreenNum = max(Screens); 
[w, wRect] = Screen('OpenWindow', ScreenNum, [bg bg bg], [], [], [], [], 4); 
scr.width = wRect(3);
scr.height = wRect(4);

%% instruction
a = imread('instruction.jpg');
GratingIndex = Screen('MakeTexture',w,a);  
GRect = Screen('Rect',GratingIndex);   
cGRect = CenterRect(GRect,wRect);    
Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  
Screen('Flip',w);  %
getkeyresp('space'); % wait for space to start the experiment


positionscale = get_position(nPosi, posiRadius, [shapeSize shapeSize], [scr.width/2 scr.height/2]); % get the possible positions of stimuli
% load RGB values of standard color space
colorscale = load('colorscale','colorscale');
colorscale = colorscale.colorscale;
%% Start
results.resp=zeros(1, nTrials);
results.stimuli=zeros(nTrials, nStim);
results.RT = zeros(1, nTrials);
results.testPosi = zeros(1,nTrials); % probe position, 1-8
results.probe = zeros(1,nTrials);

for trial = 1:nTrials  
    HideCursor;

    %% Fixation
    Screen('FillRect', w, [bg bg bg]); 
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    Screen('Flip',w);
    a = randsample(300:50:500,1)/1000; % randomly sample a fixation period
    WaitSecs(a);
    
    %% Sample array
    Screen('FillRect',w,[bg bg bg]); 
    Screen('TextSize',w,35);        
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    
    % We randomly start the color wheel
    rng(GetSecs);
    start = floor(rand()*180)+1;     
    if start > 1 && start < 180
        color_index = [start:180 1:start-1];
    elseif start==1
        color_index=1:180;
    elseif start==180
        color_index = [180 1:179];
    end
    
    % We do not want stimuli colors are too closed, so we set candidate
    % colors apart
    rng(GetSecs);
    deg_div=floor(360/nPosi);
    rd_index =(1:nPosi-1) * deg_div + round(deg_div*0.125) + randsample(round(deg_div * 0.75), 1);
    rd_index = floor(rd_index/2)+1;  % color is 180 so we divided by 2  
    
    rng(GetSecs);
    x = randsample(color_index(rd_index), nStim); % sample color index
    posi = randperm(nPosi);  % random positions, correponding to positionscale     
    color_list = zeros(nPosi,3);
    color_list(posi(1:length(x)),:) = colorscale(x,:);
    results.stimuli(trial,:) = x; % save results
    results.probe(trial) = x(1); % the 1st one is always the target
    results.probe(trial)
    % draw stimuli
    colored = find(color_list(:,1)>1); % how many stimuli
    for ind = 1:length(colored)
        Screen('FillRect', w, color_list(colored(ind),:), positionscale(colored(ind),:));
    end
    
    Screen('Flip',w);
    WaitSecs(sampleDur);       
    
    %% delay
    Screen('FillRect', w, [bg bg bg]); %delay period
    Screen('Flip',w);
    WaitSecs(delayDur);
    
    %% test array
    cpoint = [round(scr.width/2) round(scr.height/2)]; % center point
    % cpoint=[round(winwidth/2) round(winheight/2)];
    colorwheel = draw_colorscale(w, cpoint, radin, radout, colorscale);       
    % fixation point
    Screen('FrameOval', w, 0,[scr.width/2-ovalr, scr.height/2-ovalr, scr.width/2+ovalr, scr.height/2+ovalr],2,2)
    results.testPosi(trial)=draw_frames(w, positionscale, color_list); % output bold is the row index in color_list, which is the bolded color
    Screen('Flip',w);
    
    %% response
    time1 = GetSecs;   %
    ShowCursor(0, w); % not sure why we need to call this twice
    ShowCursor(0, w);
    while 1       
        [x,y,buttons] = GetMouse(w);
        if sum(buttons) > 0
            X = x; Y = y;
            d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2);    
            if d > radin && d < radout, break; end  
        end
    end
    results.RT(trial) = GetSecs - time1;
    
    %% Calculate response 
    % Convert to degree between [1:180]
    dis_y = scr.height/2-Y;
    if X-scr.width/2 >= 0
        Arc = acosd(dis_y/d);
    else
        Arc = 180+acosd(-dis_y/d);
    end
    
    % Convert 2 colorindex
    results.resp(trial) = colorwheel(floor(Arc/2)+1);
%     for ind = 1:180
%         for j=1:length(boldlist)
%             if sum(colorscale(ind,:)==color_list(boldlist(j),:))==3
%                 ref_answer(trial,j)=ind; %
%                 break;
%             end
%         end
%     end

    Screen('FillRect',w,[bg bg bg]);
    Screen('Flip',w);
    b = randsample(200:50:400,1)/1000; % random delay
    WaitSecs(b);
    
end

% Save the data
filename = strcat(subj,sprintf('_set%d_',nStim),datestr(now,'yymmddHHMM'),'.mat');
if exist(filename,'file')
    error('data file name exists')
end
save(filename);
Screen('CloseAll');








