% Draw test frames
function [bold] = draw_frames(wnd,positionscale,color_list)

colored=find(color_list(:,1)>1); % find which color to draw

rng(GetSecs);
bold = Shuffle(colored); % randomize bold stimuli position
bold = bold(1);

pWidth = ones(1,8) * 4; % thin 4 pixels 
pWidth(bold) = 8; % bold 8 pixel;
for i=1:length(colored)
    Screen('FrameRect',wnd,[0 0 0], positionscale(colored(i),:), pWidth(colored(i))); % draw stimuli
end



