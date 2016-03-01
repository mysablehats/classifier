function realVideo()
persistent vid
if exist('vid','var')
    closepreview(vid)
end
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
 
if any(metaData.IsSkeletonTracked)==1
    disp('Tracked')
    
    whichskeltodraw = sum(metaData.IsSkeletonTracked.*(1:6)); %if there is more than one this will overflow
    try
        skelskel = skeldraw(metaData.JointWorldCoordinates(:,:,whichskeltodraw),true);
    catch
        disp('something fishy')
        disp(metaData.JointWorldCoordinates(:,:,whichskeltodraw))
    end
end

if isempty(handlesRaw)
   % if first execution, we create the figure objects
   %subplot(2,2,1);
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
   %subplot(2,2,[3 4]);
   handlesmyskel=plot([]);
   %myaxes = gca; %get(handlesmyskel,'Parent');
else
   % We only update what is needed
   set(handlesRaw,'CData',IM);
   Value=mean(IM(:));
   %OldValues=get(handlesPlot,'YData');
   %set(handlesPlot,'YData',[OldValues Value]);
   %%%
   if exist('skelskel','var')
       set(handlesmyskel,'CData',skelskel)
       set(myaxes,'XLim', [-1 1]);
       set(myaxes,'YLim', [-1 1]);
       set(myaxes,'ZLim', [0 1]);
       
   end
end