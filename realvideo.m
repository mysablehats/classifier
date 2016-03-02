function realvideo()
% persistent vid
% if exist('vid','var')
%     closepreview(vid)
% end
% Define frame rate
NumberFrameDisplayPerSecond=10;
 
% Open figure
hFigure=figure(1);
 
% Set-up webcam video input
try
   % For windows
    vid = videoinput('kinect',2,'Depth_640x480');
catch
   try
      % For macs.
      vid = videoinput('macvideo', 1);
   catch
      errordlg('No webcam available');
   end
end
 
% Set parameters for video
% Acquire only one frame each time
set(vid,'FramesPerTrigger',1);
% Go on forever until stopped
set(vid,'TriggerRepeat',Inf);
% Get a grayscale image
set(vid,'ReturnedColorSpace','grayscale');
triggerconfig(vid, 'Manual');

%set(vid,'TrackingMode','Skeleton')
src = getselectedsource(vid);
src.TrackingMode = 'Skeleton';


% set up timer object
TimerData=timer('TimerFcn', {@FrameRateDisplay,vid},'Period',1/NumberFrameDisplayPerSecond,'ExecutionMode','fixedRate','BusyMode','drop');
 
% Start video and timer object
start(vid);
start(TimerData);
 
% We go on until the figure is closed
uiwait(hFigure);
 
% Clean up everything
stop(TimerData);
delete(TimerData);
stop(vid);
delete(vid);
% clear persistent variables
clear functions;
 
% This function is called by the timer to display one frame of the figure
 
function FrameRateDisplay(obj, event,vid)
persistent IM;
persistent handlesRaw;
persistent handlesPlot;
persistent handlesmyskel;
persistent myaxes;
trigger(vid);
[IM,~,metaData]=getdata(vid,1,'uint8');

try
    if any(metaData.IsSkeletonTracked)==1
        disp(strcat('Tracked: ',num2str(sum(metaData.IsSkeletonTracked)),' skeletons.'))
        for i = 1:length(metaData.IsSkeletonTracked)
            if metaData.IsSkeletonTracked(i)==1
                %disp(metaData.JointWorldCoordinates(:,:,i))
                try
                    skelskel = skeldraw(metaData.JointWorldCoordinates(:,:,i),false);
                catch
                    disp('something fishy')
                    disp(metaData.JointWorldCoordinates(:,:,i))
                end
            end
        end
    end
catch
    disp('Can''t draw! :/')
end

if isempty(handlesRaw)
   % if first execution, we create the figure objects
   subplot(2,1,1);
   handlesRaw=imagesc(IM);
   title('CurrentImage');
 
   % Plot first value
   %Values=mean(IM(:));
   %subplot(2,2,2);
   %handlesPlot=plot(Values);
   %title('Average of Frame');
   %xlabel('Frame number');
   %ylabel('Average value (au)');
   
   %my skeleton 
   sampleskel = [0.0697    0.1773    1.6761;
    0.0756    0.2420    1.6839;
    0.0678    0.5732    1.6773;
    0.0010    0.7354    1.5891;
   -0.0791    0.4813    1.7441;
   -0.1515    0.3129    1.4867;
   -0.1649    0.2954    1.2563;
   -0.1067    0.2954    1.2395;
    0.2255    0.4464    1.5866;
    0.2237    0.2958    1.4024;
   -0.0567    0.2926    1.2936;
   -0.1113    0.3175    1.2855;
    0.0002    0.1035    1.7097;
    0.0094   -0.3763    1.6717;
   -0.1009   -0.6928    1.6735;
   -0.1548   -0.7310    1.5964;
    0.1391    0.0965    1.6379;
    0.1254   -0.3289    1.6740;
    0.1750   -0.4106    1.2409;
    0.2620   -0.3947    1.1648];

   subplot(2,1,2);
   handlesmyskel=plot([]);
%    try
%        [~ , handlesmyskel] = skeldraw(sampleskel,true);
%    catch
%        disp('cant initialize axes handle')
%    end
   myaxes = gca; %get(handlesmyskel,'Parent');
else
   % We only update what is needed
   set(handlesRaw,'CData',IM);
   %Value=mean(IM(:));
   %OldValues=get(handlesPlot,'YData');
   %set(handlesPlot,'YData',[OldValues Value]);
   %%%
   if exist('skelskel','var')
       plot3(skelskel(1,:),skelskel(2,:), skelskel(3,:))
       %disp('reachedplot')
       %set(handlesmyskel, 'XData',skelskel(1,:),'YData',skelskel(2,:),'ZData', skelskel(3,:))
       %set(handlesmyskel,'CData',skelskel)
       set(myaxes,'XLim', [-1 1]);
       set(myaxes,'YLim', [-1 1]);
       set(myaxes,'ZLim', [-0 5]);
       view(0,90);
   end
end