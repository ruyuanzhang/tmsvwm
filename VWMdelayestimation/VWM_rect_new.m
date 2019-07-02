%%2014/10/11%%%
%%%ref_answer������е�colored index��˳��Ϊ[target,distractors,not-targets]%%%
Screen('Preference', 'SkipSyncTests', 1); 
clear all;
colorinfo=zeros(100,8,3);  %����colorinfo����
%% read configurations
frominput.ncolor=input('plz input number of shapes:     ');
frominput.nrect=input('plz input number of rects:     ');
frominput.shapebold=input('plz input which shape to bold: [1]cirle;[2]rect     ');
frominput.ntrial=input('plz input number of trials:     ');
subjname=input('plz subj_name:     ','s');

if ~ismember(frominput.shapebold,[1 2])
    finish;
elseif frominput.shapebold==1, frominput.shapebold='circle'; 
else
    frominput.shapebold='rect';
end

if strcmp(frominput.shapebold,'circle')
    target='circle';
    distractor='rect';
    tar_num=frominput.ncolor-frominput.nrect;
    dis_num=frominput.nrect;
elseif strcmp(frominput.shapebold,'rect')
    target='rect';
    distractor='circle';
    tar_num=frominput.nrect;
    dis_num=frominput.ncolor-frominput.nrect;
end

%% open window
Screens = Screen('Screens');
ScreenNum = max(Screens); %����ȫ���ֱ���
scr.width = 1680; scr.height = 1050;  %������Ļ�ֱ��ʣ�����ʾ��ʱҪ�޸ģ�������������������
% FontWidth = 40; FontHeight = 40;
[w, wRect] = Screen('OpenWindow', ScreenNum, [192 192 192], [], [], [], [], 4);  %����Ļ�Ĳ���
%��set sizeʱ��Ҫ��������x�Լ�color_list�������ý�Բ���ֳ�6�ݵ��㷨����set size���Ϊ6
%�ɵ��������ݣ���scr.width/scr.height����ע�ӵ��λ�á���set size��//��Բ����ɫƽ�֡���Բ���뾶����ɫ��λ�á�

HideCursor;



%% instruction

a = imread('instruction.jpg');
GratingIndex = Screen('MakeTexture',w,a);  %��M������ͼƬ����GratingIndex��ָ��
GRect = Screen('Rect',GratingIndex);   %��ǰM��λ��
cGRect = CenterRect(GRect,wRect);    %��λ�õ���Ϊ��Ļw�����룬wRect����w��Ļ��λ�þ���
Screen('DrawTexture',w,GratingIndex,GRect,cGRect);  %��GratingIndex������Ļ�����ϣ�GRect��ͼƬԭʼλ�ã�cGRect��Ŀ��λ��
Screen('Flip',w);  %�����ҪFlip�Ż���ֳ�����

KbName('UnifyKeyNames');   %���尴��ǰ��ö�������һ��
key_continue = KbName('space');   %����ո��
reaction = 0;
while (reaction == 0);   %���ո������
[KeyIsDown, secs, KeyCode] = KbCheck; 
% reaction = 0;
    if KeyCode(key_continue);
%         reaction = 1;
        break;
    end;
end
KbWait;    %�����������


positionscale=get_position(8,220,[98 98],[scr.width/2 scr.height/2]);

%% start

ncolor=frominput.ncolor;   %ɫ��ĸ���   
nrect=frominput.nrect; %ɫ���з��ĸ��� 
shapebold=frominput.shapebold;  %�Ӵֵ���״ 

sub_answer=zeros(1,frominput.ntrial);
ref_answer=zeros(frominput.ntrial,ncolor);


for trial = 1:frominput.ntrial  %trial��
    HideCursor;

    %% fixation
    
    Screen('FillRect',w,[192 192 192]); %����ĻwͿ�ɻ�ɫ
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
%     Text1 = ('+');
%     oldTextSize = Screen('TextSize',w,35); %�������ֵĴ�СΪ35��
%     Screen('DrawText', w, Text1,scr.width/2,scr.height/2,[0 0 0]); %������������Ļ�ϵĺ���,***ע��ע�ӵ�λ�õ���,��������ı������Ͻ�
    Screen('Flip',w);
    a = randsample(300:50:500,1)/1000;
    WaitSecs(a);
    
    %% sample array
    
    Screen('FillRect',w,[192 192 192]); %����ĻwͿ�ɻ�ɫ
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
    
    load colorscale    
    rng(GetSecs);
    start = floor(rand()*180)+1;    
    if start > 1 && start < 180
        color_index = [start:180 1:start-1];
    elseif start==1
        color_index=1:180;
    elseif start==180
        color_index = [180 1:179];
    end
    rng(GetSecs);
    div=1:8; 
    rd_index=zeros(1,div(end));
    deg_div=floor(360/div(end));
    rd_index(div) =(div-1)*deg_div+round(deg_div*0.125)+randsample(round(deg_div*0.75),1);
    rd_index(:) = floor(rd_index(:)/2)+1;    
    rng(GetSecs);
    x = randsample(color_index(rd_index(:)),ncolor);   

    y = randperm(8);       
    
    color_list = zeros(8,3);
    for ind = 1:ncolor    %set size
        color_list(y(ind),:) = colorscale(x(ind),:);
    end
    colorinfo(trial,:,:) = color_list(:,:);   
    
    shape_list=draw_colorlist(w,positionscale,color_list,nrect); 

    Screen('Flip',w);
    WaitSecs(0.2);       %sample����ʱ��
    
    %% delay
    
    Screen('FillRect',w,[192 192 192]); %����ĻwͿ�ɻ�ɫ
    Screen('Flip',w);
    WaitSecs(0.9);
    
    %% test array
    
    load colorscale;
    
    radin = 400; radout = 508;         %��Բ�����������������ò���
    cpoint = [round(scr.width/2) round(scr.height/2)];
    % cpoint=[round(winwidth/2) round(winheight/2)];
    colorwheel = draw_colorscale(w,cpoint,radin,radout) ;       
    
    Screen('TextSize',w,35);        
    DrawFormattedText(w,('+'),'center','center',[0 0 0],[],[],[],[]);
    boldlist=draw_frames(w,positionscale,color_list,shape_list,shapebold); 

    Screen('Flip',w);
    
    %% response
    
    time1 = GetSecs;   %��¼��Ӧʱ
    
    ShowCursor(0);   %��ʾ���   0����ͷ��1��ʮ�֣�2���֣�3��ѡ�з��ţ�4����ֱ������ţ�5��ˮƽ������ţ�6:��ȡ���ţ�7:ֹͣ����
    while 1       %��¼�������λ��
        [x,y,buttons] = GetMouse(w);
        if sum(buttons) > 0
            X = x; Y = y;
            d = sqrt((X-scr.width/2).^2+(Y-scr.height/2).^2);    
            if d>radin && d<radout, break; end  
        end
    end
    
    time2 = GetSecs;   %��¼��Ӧʱ
    RT(trial) = time2 - time1;

    dis_y = scr.height/2-Y;
    if X-scr.width/2 >= 0
        Arc = acosd(dis_y/d);
    else
        Arc = 180+acosd(-dis_y/d);
    end
    
    %Convert 2 colorindex
    sub_answer(trial) = colorwheel(floor(Arc/2)+1);  %�����жϽ��
    for ind = 1:180
        for j=1:length(boldlist)
            if sum(colorscale(ind,:)==color_list(boldlist(j),:))==3
                ref_answer(trial,j)=ind;     %�Ӵַ���Ľ��
                break;
            end
        end
    end
    
    Screen('FillRect',w,[192 192 192]); %����ĻwͿ�ɻ�ɫ
    Screen('Flip',w);
    b = randsample(200:50:400,1)/1000;
    WaitSecs(b);
    % save sub_answer;
    % save ref_answer;
    
end

save (fullfile (['sub' subjname '_' shapebold '_' 'target' num2str(tar_num) '_' 'distractor' num2str(dis_num)]));
Screen('CloseAll');








