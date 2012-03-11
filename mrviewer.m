function mrviewer(inDir)
%MYVIEWER simple viewer of images
%
%   author: Konrad Werys (konradwerys@gmail.com)

% add needed functions to the path
addpath('mrplot_fncs')
addpath(fullfile('..','mrtoolbox'))

% get inDir if not specified
if ~exist('inDir','var')
    % inDir = uigetdir;
    
    % inDir='/Users/Rezonans1/Desktop/Perfuzja/badania_matlab/';
    inDir='D:\Data\perfusia nowy2 matrix\';
    % inDir = '/Users/Rezonans1/Desktop/TAG/tag_results_matlab/SPIEWAK MATEUSZ';
end

[mrListDirs,mrListFiles]=mrlist(inDir);

if isempty(mrListDirs)
    disp('Input directory is not correct!')
    return
end

hFigure = figure(...        % the main GUI figure
    'Name','RV LV viewer',...
    'MenuBar','none',...
    'ToolBar','none',...
    'KeyPressFcn',@mrKeyPressFcn,...
    'CloseRequestFcn',@mrCloseRequestFcn);


%%% to handla playing movies. Period is timer's period + time necesary to
%%% refresh the figure
mrTimer=timer('ExecutionMode','fixedSpacing','BusyMode','drop','Period',0.1);
mrTimer.TimerFcn = @mrplay;
isRunning=0;

cDir=1; % current Directory
cFile=1; % current File
mr = mrload(fullfile(mrListDirs{cDir},[mrListFiles{cDir,cFile},'.mat']));
%mrText1={mrListDirs{cDir}};


mrplot()

    function mrKeyPressFcn(~,evnt)
        keyPressed = evnt.Key;
        stop(mrTimer);
        switch keyPressed
            case 'rightarrow'
                mr.cTime=mr.cTime+1;
                mr.cTime=mod(mr.cTime-1,mr.nTimes)+1;
            case 'leftarrow'
                mr.cTime=mr.cTime-1;
                mr.cTime=mod(mr.cTime-1,mr.nTimes)+1;
            case 'uparrow'
                cDir=cDir-1;
                cDir=mod(cDir-1,size(mrListDirs,2))+1;
                if isempty(mrListFiles{cDir,cFile})
                    cFile=1;
                end
                mr = mrload(fullfile(mrListDirs{cDir},[mrListFiles{cDir,cFile},'.mat']));
                
            case 'downarrow'
                cDir=cDir-1;
                cDir=mod(cDir-1,size(mrListDirs,2))+1;
                if isempty(mrListFiles{cDir,cFile})
                    cFile=1;
                end
                mr = mrload(fullfile(mrListDirs{cDir},[mrListFiles{cDir,cFile},'.mat']));

            case 'return'
                cFile=cFile+1;
                % chech how many .mat files are in current directopry
                sss=sum(~cellfun('isempty',{mrListFiles{cDir,:}}));
                cFile=mod(cFile-1,sss)+1;
                mr = mrload(fullfile(mrListDirs{cDir},[mrListFiles{cDir,cFile},'.mat']));
            case 'r'
                [mrListDirs,mrListFiles]=mrlist(inDir);
                cDir=1; % current Directory
                cFile=1; % current File
                mr = mrload(fullfile(mrListDirs{cDir},[mrListFiles{cDir,cFile},'.mat']));
            case 'space'
                % set flag to start timer
                isRunning=~isRunning;
            case 'comma'
                % change playing speed
                set(mrTimer,'Period',get(mrTimer,'Period')+0.01)
                disp(['Play next after: ',num2str(get(mrTimer,'Period'))])
            case 'period'
                % change playing speed
                if get(mrTimer,'Period')>=0.02
                    set(mrTimer,'Period',get(mrTimer,'Period')-0.01)
                end
                disp(['Play next after: ',num2str(get(mrTimer,'Period'))])
            otherwise
                clipboard('copy',fullfile(inDir,mrListDirs{cDir}))
                disp(['To clipboard: ',fullfile(inDir,mrListDirs{cDir})])
        end
                
        mrplot()
        if isRunning
            start(mrTimer)
        end
    end

    function mrplot()
        try
            if ~isempty(mrListFiles{cDir,cFile})
                funName=['mrplot_',mrListFiles{cDir,cFile}];
                if exist(funName)==2 %#ok
                    eval([funName,'(mr)'])
                    %text(0,-20,mrText,'VerticalAlignment','top','color','green','Interpreter','none','BackgroundColor','black')
                    next=cDir+1;
                    next=mod(next-1,size(mrListDirs,2))+1;
                    prev=cDir-1;
                    prev=mod(prev-1,size(mrListDirs,2))+1;
                    mrText1={['    ',mrListDirs{prev}],['-> ',mrListDirs{cDir}],['    ',mrListDirs{next}]};
                    mrText2 = {mrListFiles{cDir,:}}; mrText2(cFile)={['-> ',cell2mat(mrText2(cFile))]};
                    
                    text(1,1,mrText1,'VerticalAlignment','top','color','green','Interpreter','none','BackgroundColor','black','Units','normalized','FontSize',8)
                    text(1,0,mrText2,'VerticalAlignment','top','color','green','Interpreter','none','BackgroundColor','black','Units','normalized','FontSize',8)
                else
                    disp(['Error: no function ',funName])
                    disp(mrListDirs{cDir})
                end
            end
        catch ex
            disp(['Error: ',ex.message])
        end
    end

    function [mrListDirs,mrListFiles]=mrlist(inDir)
        % creates lists: of all directores that have mat files and all mat
        % files in input directory
        
        mrListDirs=[];
        mrListFiles=[];
        dirs=get_all_dirs(inDir);
        
        nDataDirs=0;
        
        for iDir=1:size(dirs,1)
            nDataFiles=0;
            ddd=dir(dirs{iDir});
            for iFile=1:size(ddd,1)
                [dirName, fileName, ext] = fileparts(fullfile(dirs{iDir},ddd(iFile).name));
                if ~isempty(strfind(ext,'.mat'))
                    if nDataFiles==0
                        nDataDirs=nDataDirs+1;
                    end
                    nDataFiles=nDataFiles+1;
                    mrListDirs{nDataDirs}=strrep(dirName,inDir,''); %#ok
                    mrListFiles{nDataDirs,nDataFiles}=fileName; %#ok
                end
            end
        end
    end

    function mr = mrload(inFilePath)
        mr=[];
        disp('Loading')
        inFilePath=fullfile(inDir,inFilePath);
        if exist(inFilePath,'file')
            try
                mr=load(inFilePath);
                %%% UGLY WAY TO GET nTimes:
                %%% sets nTimes as the largers 3rd or 4tth dimension of the
                %%% matrix in mr structure
                fff=fieldnames(mr);
                for f=1:size(fff)
                    sss(f)=max(size(getfield(mr,fff{f}),3),size(getfield(mr,fff{f}),4)); %#ok
                end
                mr.nTimes=max(sss);
                %%%
                mr.cTime=1;
            catch ex
                disp(['Error: ',ex.message])
                keyboard
            end
        end
    end

    function mrplay(~,~)
        mr.cTime=mr.cTime+1;
        mr.cTime=mod(mr.cTime-1,mr.nTimes)+1;
        mrplot()
    end

    function mrCloseRequestFcn(~,~)
        delete(mrTimer)
        disp('Bye!')
        delete(hFigure)
    end
end

