%%%%%%%%%%%%%%%%%
%  eof_code_run_annual_seasonal_DE20_c17.m
%  EOFs SH
%  Daniel Emanuelsson, 2020
%  Matlab 2018a
%  Github version 2
%%%%%%%%%
% subfunctions
% * keep_var.m        UoW online archive Atmospheric Science
% * annave.m          UoW online archive Atmospheric Science
% * eof_j.m           James R
% * annual_mean_DE.m  DE
% * HadISST_load_lat_lon.m DE
% * plus other eof alt and rotate functions (from Github)
%%%%%%%%%%%%%%%%%
tic
clear all
close all
addpath C:\PHD\matlab_lib\James_Renwick_code\multivar

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
geo_lev=1; % (1) z500 (7) 2mT (8) SIC 

if geo_lev==1
    geo_str='z500';
elseif geo_lev==2
    geo_str='z200';
elseif geo_lev==7 % 2mT SAT  
    geo_str='2mT';
elseif geo_lev==8 % SIC  
    geo_str='SIC';       
end

%%%%%%%%%%%%%%%%%%%%
sea_nr=1;   %(1) Annual (4) JJA all values are used here (6) MAMJJA
%%%%%%%%%%%%%%%%%%%%%%
reanalysis_nr=1; % (1) * ERA-interim (3) * HadISST SIC

    if reanalysis_nr==1
        reanalysis_str='ERA-Interim';
    elseif reanalysis_nr==3
        reanalysis_str='HadISST';
    end
yr_s=1979;
%yr_e=2001;%%%%%%%%%%%%%%%
% yr_e=2012;%%%%%%%%%%%%%%% same extent as RICE record (ends in 2011)
yr_e=2012;  
%yr_e=2011;  
    if sea_nr==1
    season='annual';
    
    elseif sea_nr==2
    season='DJF';
    
    elseif sea_nr==3
    season='MAM';
    
    elseif sea_nr==4
    season='JJA';
    
    elseif sea_nr==5
    season='SON';
    
    elseif sea_nr==6
    season='MAMJJA';    
    end
    
%%%%% ERA-Interim %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 addpath C:\PHD\ERA_interim
 
if reanalysis_nr==1 
    if geo_lev==1 || geo_lev==7
    era_time=ncread('ERA_int_monthly_z500_2.nc','time');
    era_long=ncread('ERA_int_monthly_z500_2.nc','longitude');
    era_lat=ncread('ERA_int_monthly_z500_2.nc','latitude');
    elseif geo_lev==2
    era_time=ncread('ERA_int_monthly_z200_2.nc','time');
    era_long=ncread('ERA_int_monthly_z200_2.nc','longitude');
    era_lat=ncread('ERA_int_monthly_z200_2.nc','latitude');    
    end
    
    
    
    dayssince111=era_time/24;
    datevalue=dayssince111+datenum(1900,1,1);
    date_vec=datevec(double(datevalue)); 
    yyyy=date_vec(:,1); 
    mm=date_vec(:,2);
    era_year_num=yyyy+(mm/12-1/12);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif reanalysis_nr==3 % HadISST
    % edit HadISST_load_lat_lon
    % nameoffile='HadISST_ice_c.nc';
    nameoffile='HadISST_ice_c2.nc';
    [HadISST_lon, HadISST_lat, HadISST_time, HadISST_year_num, mm]=HadISST_load_lat_lon(nameoffile);
   % use excisting names
    era_long=HadISST_lon;
    era_lat=HadISST_lat;
    era_time=HadISST_time; 
    era_year_num=HadISST_year_num;  
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

era_count=find(era_year_num==yr_e)+11;  % data in months
era_start=find(era_year_num==yr_s); 

mm_in=mm(era_start:era_count);  % seasonal index
mm_in_c=[era_start:era_count]';


% mm_in=mm(era_start:era_count);  % seasonal index

 if sea_nr==1
    mm_in_c=[era_start:era_count]';
 elseif sea_nr==2  % DJF
     mm_in_c=[find(mm_in==12);  find(mm_in==1); find(mm_in==2)];
     mm_in_c=sort( mm_in_c);
     %mm_in_c=mm_in_c(3:end-1); % dont use JF for first year as there is no D 
     mm_in_c=mm_in_c(1:end);
     % and skip D for last year (-1)
     
     
elseif sea_nr==3  % MAM
     mm_in_c=[find(mm_in==3);  find(mm_in==4); find(mm_in==5)];
     mm_in_c=sort( mm_in_c);
     mm_in_c=mm_in_c(1:end);
elseif sea_nr==4  % JJA
     mm_in_c=[find(mm_in==6);  find(mm_in==7); find(mm_in==8)];
     mm_in_c=sort( mm_in_c);
     mm_in_c=mm_in_c(1:end);
 elseif sea_nr==5  % SON
     mm_in_c=[find(mm_in==9);  find(mm_in==10); find(mm_in==11)];
     mm_in_c=sort( mm_in_c);
     mm_in_c=mm_in_c(1:end);
 elseif sea_nr==6  % MAMJJA    
     mm_in_c=[find(mm_in==3);  find(mm_in==4); find(mm_in==5); find(mm_in==6); find(mm_in==7); find(mm_in==8)];
     mm_in_c=sort( mm_in_c);
     mm_in_c=mm_in_c(1:end); 
 end


name=geo_str;
 
if  geo_lev<=4 && reanalysis_nr==1    
        era_z500=ncread(strcat('ERA_int_monthly_',geo_str,'_2.nc'),'z'); 
      
elseif geo_lev==7
        era_z500=ncread(strcat('ERA_int_monthly_',geo_str,'_2.nc'),'t2m'); % added 2017
           
elseif geo_lev==8 % SIC
        era_z500=ncread('HadISST_ice_c2.nc','sic'); % added 2017
        
        X=era_z500;
        
        [A B C]=size(X);
            for i=1:A
                for j=1:B
        %%%%%%%%%%%%%%%%%%
        %%% Replace NaNs
                    if  isnan(X(i,j,:))==1
                        X(i,j,:)=0;
                        %X(i,j,:)=1000;
                    end
        %%%%%%%%%%%%%%%%%%%%
                end
            end
        
    era_z500=X;    
        
end
 
    if geo_lev==1 &&  reanalysis_nr==1    
        era_z500=era_z500/9.80665;
    end
   
 era_z500=era_z500(:,:,(era_start:era_count));
 era_year_num_c2=era_year_num(era_start:era_count);
 toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%
tic
%     [xkeep, ykeep] = keep_var(lim, x, y);
%    where lim = [minx maxx miny maxy] to be kept.
if geo_lev==1 || geo_lev==2
  lims = [0 360 -90 -20]; % z500
% lims = [0 360 -90 -30]; % z500
elseif geo_lev==7
  lims = [0 360 -90 -30]; % Yu et al 2015 2mt

elseif geo_lev==8
   lims = [-150 -30 -75 -64]; % sic---in use
end

[xk, yk] = keep_var(lims, era_long, era_lat);
era_z500 = era_z500(xk, yk, :);
era_lat = era_lat(yk); 
era_long =era_long(xk);

% era_z500(:,(1:147),:)=[];  % Only use the SH <20S
% era_lat(1:147)=[]; 
% 
% %%%%%
% era_z500(:,(69:94),:)=[];  % Remove 70 to 90S   %%%% Boundaries from Marshall 2016
% era_lat(69:94)=[];
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %% resize grid
 
 if reanalysis_nr==1  % Only for ERA-Interim (high resolution data)
 
    [a b c]=size(era_z500);
 
    scale=0.5;
    % scale=0.75;% use to match HadISST grid, very slow, no big difference
    % in vari explained
    %scale=1;
 
        for i=1:c
        
            era_z500_v(:,:,i)=resizem(era_z500(:,:,i),scale);
    
        end 
 
    [av, bv, cv]=size(era_z500_v);
    xq = (1:bv)*1/scale; % Lat
    yq = (1:av)*1/scale; % Lon

    % resize lat long
    x=[1:length(era_lat)]';  % Lat
    [p,s]=polyfit(x,era_lat,1);

    era_lat_v=polyval(p,xq');
    clear x p s

    x=[1:length(era_long)]';
    [p,s]=polyfit(x,era_long,1);

    era_lon_v=polyval(p,yq');    
%     clear a b
    
    era_z500=era_z500_v;
    era_lat=era_lat_v;
    era_long=era_lon_v;  
 end
 
%%
tic
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
era_lat_c=era_lat;
[nlon, nlat, ntim]= size(era_z500);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Order of these three steps doesn't matter
%%% -=(1)=-
%  z = cosweight(z, lat);
% weighted to account for the decrease in area towards the pole.

%  era_z500_c = reshape(era_z500, ntim, nlat, nlon);  %  z500_eof

era_z500_c = permute(era_z500, [3 2 1]);  %  z500_eof

%%%%%%%%%%%%%%%
%     B = permute(A,ORDER) rearranges the dimensions of A so that they
%     are in the order specified by the vector ORDER.  The array produced
%     has the same values as A but the order of the subscripts needed to 
%     access any particular element are rearranged as specified by ORDER.
%%%%%%%%%%%%%%%%%

era_z500_c2=cosweight(era_z500_c,era_lat_c); % Original UoW function    (time x lat x lon) 
%edit cosweight_c


%%%%%%%%%%%era_z500_c2=cosweight_c(era_z500,era_lat_c);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
 %%% -=(2)=-
% Remove monthly climatology for all cells 

 era_z500_c3 = double(reshape(era_z500_c2, ntim, nlat*nlon));  % One time series (column) for each grid point
 

 %  lat 1, 2, 3, 4,..........33...lat 1, 2, 3, 4.....33       until 33X240=7920
 %  
 %1
 %time
 %
 %444
 
 [era_z500_c4,clim_z500] = annave(era_z500_c3);   % checked, Removes
%  remove seasonal cycle

%%%%%%%%%% SAVE used in regression -= do not downscale above =-%%%%%%%%%%%%%%%%%% 
%  filedir ='C:\PHD\matlab_storage_of_output_files\';
%  name_c=['clim_',name,'_',num2str(yr_s),'_',num2str(yr_e)];
%  name_c=['clim_',name,'_',reanalysis_str,'_',num2str(yr_s),'_',num2str(yr_e)];

% savefilename =[filedir, name_c, '.mat'];
% save(savefilename,'era_z500_c4','clim_z500'); 

% stop here for regression save
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% seasonal indexing
seasonaly_nr=0; %average three values then move on to next three
seasonal_str='';

if sea_nr>=2
era_z500_c4= era_z500_c4(mm_in_c,:);
era_year_num_c3=era_year_num_c2(mm_in_c);



    if seasonaly_nr==1 && sea_nr>2
        
        seasonal_str='seasonaly';
       
        [ac1 ac2 ]=size(era_z500_c4);
        
        Ma_save_season=NaN(ac1/3,ac2);
        Ma_save_season_t=NaN(ac1/3,1);
        kc=1;
        
        for ib=1:3:ac1
        
           dummy_c1 =mean(era_z500_c4((ib:ib+2),:));
           
           dummy_t=mean(era_year_num_c3(ib:ib+2));
           
           Ma_save_season(kc,:)=dummy_c1;
           Ma_save_season_t(kc,:)=dummy_t;
           
           kc=kc+1;
           
           
        end
        
      era_z500_c4=Ma_save_season;
    end

end

clear dummy_c1 dummy_t
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%  Don't detrend if you want to keep trend.....
 
 
 detrend_nr=1; % (1) detrend (0) keep trend
 
 if  detrend_nr==0
    if sea_nr==1 
    era_z500_c8=   era_z500_c4;
    elseif sea_nr>=2 
    era_z500_c8=   era_z500_c4;  
    end
    
 elseif detrend_nr==1
 %%% -=(3)=-                   *    Order of 2 and 3 doesn't seem to matter
    if sea_nr==1
    era_z500_c8= detrend(era_z500_c4); % Linear detrend
    else % seasonal
    era_z500_c8= detrend(era_z500_c4); % Linear detrend   
    end
 end

% clear era_z500_c i ib era_z500 era_z500_c1 era_z500_c2 era_z500_c3 
% clear Ma_save_season era_z500_v era_z500_c4 
toc 


%%  
%seasonal indexing 
% % era_z500_c5=era_z500_c8;
%  
% era_z500_c6= reshape(era_z500_c5,  ntim, nlat, nlon );
% 
% era_z500_c7 = permute(era_z500_c6, [3 2 1]);  %  z500_eof
% 
% 
% era_z500_c7= era_z500_c7(:,:,mm_in_c); % pick out season   %%% checked in mapcheck
% % return back to eof format
% era_z500_c8 = reshape(era_z500_c7, length(mm_in_c), nlat*nlon);  % One time series (column) for each grid point
%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Annual means anomaly fields for EOF, used
annual_fields=1;

if annual_fields==1
    
    seasonal_str='_annual_mean';
 
     [ac1 ac2 ]=size(era_z500_c8);
     
     save_annual_c=NaN(ac1/12,ac2);
    
   for i=1:12:ac1
       
       dummy_c1=nanmean(era_z500_c8((i:i+11),:));
       
       if i==1
       kb=1;
       end
       save_annual_c(kb,:)= dummy_c1;
       kb=kb+1;
       
   end
  era_z500_c8=save_annual_c; 
end

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
%%
%%%%%%  James EOF function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
eof_alt_nr=3; % (1) James (2) Green [same result for both] (3) rotate King (used) (4) several methods for regular eof
if eof_alt_nr==1 
    
    % edit eof_j
% out = eof(ldata,nsave,scaling,atype)
%
% Get eigenvectors/values by eig or SVD method
% Input:
%	ldata	-	n by p data array
%	nsave	-	How many vectors (etc) to save/return - 0 => all
%	scaling -	if true (1), scale columns of ldata by std(ldata) first
%	atype	-	analysis type: 'eig' or 'svd' (default depends on n/p)
%
% Output:
%  Structure with components
%	vect	-	Eigenvectors (Most important "nsave")
%	val		-	Eigenvalues (  ..     ..       ..   )
%	series	-	Principal components (loadings, time series)
%	regmap	-	Regression map version of vectors
%	totvar	-	Total variance of input data
%	expv		-	Percent explained variance
%	rank		-	Rank info: [sum(val>1e-7) spatial d.o.f]
%	std		-	standard deviations of columns of ldata (=1 if scaling)
   
    
    eof_out=eof_j(era_z500_c8, 10);% ,[],'svd');
    % edit eof_j
     eof_str='';
     
     reof_nr=0; % (0/1)
     varimax_alt=1; %(1,2)
     
     if reof_nr==0
      varimax_alt=1;   
     end
     
     
     if reof_nr==1  % rotate eof (use)
         
      
         
         if varimax_alt==1
    %     [x_reof_pcs,r]=varimax_github(eof_out.series,1); % varimax PCs
        [x_reof,rotMatrix]=varimax_github(eof_out.vect,1);% varimax in space EOFs
      %   [x_reof,r, exp_v]=varimax_github_c(eof_out.vect,1);% varimax in space EOFs
         % edit varimax_github_c
         
        % help make_series
        % edit make_series
        % x_reof_c=x_reof';

          
          PCr_series= make_series(era_z500_c8,x_reof); % very similar to alt # 3
        %  [PCr_series_c2,r2]=varimax_github(PCr_series,1); % rotate series
          
          eof_str='varimax';
          %%%%%%%%%%%%%
          % from regular eof
           L=10;
           
           var_total=sum(eof_out.val(1:L)/sum(eof_out.val));
           
           
           eigvals=eof_out.val(1:10);
           % Get the rotated eigenvalues
            rotEigvals = diag( diag(eigvals) * rotMatrix );
           
           
           % Get the explained variance of each rotated mode  % king
          %    rotExpVar = (rotEigvals / sum(rotEigvals)) * sum(expVar);
           rotExpVar = ((rotEigvals / sum(rotEigvals)) *  var_total)*100
          
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% james
         elseif varimax_alt==2  % for annual more similar
         %to non rotated than alt 1
 % alt2 varimax        
         E=eof_out.vect;
%         E=eof_out.series;
         lamda=eof_out.val;
         %L=10; % separable with 10 but not 4
         L=4;
         %A1=2; % area weight : non seprable eofs,
         %A1=0.5; % separable
         A1=1; % separable
         reof_out2=varimax(E,lamda,L,A1,1);%
         % edit varimax
         reof_out2.rexpv(1:L)
         x_reof2=reof_out2.rload;
         PCr_series= make_series(era_z500_c8,x_reof2);
         eof_str='varimax_c2';
         %%%%%%%%%%%%%%%
%  out = varimax(E,Lamda,L,A,norm)
%  edit varimax
%   Varimax rotation of factor loadings.
%  
%   Input:
%        E = eigenvectors of unit length.
%    lamda = eigenvalues of the corresponding eigenvectors.
%        L  = number of EOFs to use in rotation (the program uses the L
%             largest PCs assuming the input loadings (eigenvectors)
%             are arranged in descending order).
%        A  = area weights (fractional weight of each "gridbox").
%     norm  = true (1) if loadings are to be normalized. In case of 
%             rotating loading vectors based upon correlation matrix.
%  
%   Output structure with elements:
%     rload	= rotated factor loadings.  
%     rexpv	= fractional variance explained by each loading vector.
%  	 cscore	= score-coefficient matrix
%  	 h			= communalities
% %  	 rownorm	= normalising factors for vectors - empty if norm false         
%          PCs=eof_out.series;
%          RE=reof_out2.rload;
%          E=eof_out.vect;
%          lamda2=eof_out.val;
%          
%          out = varimax2(PCs, RE,E ,lamda2,1);


%  out = varimax2(PC,RE,E,LAMDA,rownorm)
%  
%   Return auxiliary stuff involved with Varimax rotation,
%   after application of routine VARIMAX.  Kushnir's code,
%   adapted by Xinhua Cheng and modified by Jim Renwick.
%   See Xinhua's 1993 PhD thesis, pages 12-13.
%  
%   Inputs:
%  	PC	= unrotated pcs, PC'*PC = (N-1) * LAMDA
%  	RE	= rotated loading vectors, RE'*RE ~= I
%  	E	= unrotated eigenvectors, E'*E = I
%  	LAMDA	= eigenvalues
%  	rownorm = normalisation factors used in VARIMAX - may be []
%   Output structure with elements:
%  	rpc			= rotated PCs, RPC'*RPC = (N-1) * I
%  	reof			= rotated EOFs, REOF = RE*inv(RE'*RE),
%  		  			  so that RPC = X*REOF
%  	transform	= orthogonal transformation matrix,
%  		  			  RE = E*sqrt(diag(lamda))*transform

        elseif varimax_alt==3 % not working or slow
            
            
         [V_r, rotdata]=varimax_github2(eof_out.vect);   
               % help varimax_github2
               % edit varimax_github2
         eof_str='varimax_c3';
         PCr_series= make_series(era_z500_c8,V_r);
                
         elseif varimax_alt==4 % King, not working or very slow
            eof_str='varimax_c4';
             Ac=era_z500_c8;
             rotType='varimax';
             eigvals=eof_out.val';
             modes=eof_out.vect';
           
[rotModes, rotEigvals, rotExpVar, rotSignals, scaledRotSignals] = eofrotation(modes, eigvals, Ac, rotType);             
%  [rotModes, rotEigvals, rotExpVar, rotSignals, scaledRotSignals] = eofrotation(modes, eigvals, A, rotType)
 % edit eofrotation
 
%   ----- Inputs -----
%  
%   modes: The modes from an eof analysis that should be rotated.
%  
%   eigvals: The eigenvalues corresponding to the rotating modes.
%  
%   A: The analysis matrix used to generate the rotating modes.
%  
%   rotType: A string flag for the type of rotation
%     'varimax': Varimax Rotation
%     'equamax': Equamax Rotation
%  
%  
%   ----- Outputs -----
%  
%   rotModes: The rotated eof modes.
%  
%   rotEigvals: The eigenvalues for the rotated modes.
%  
%   rotExpVar: The variance explained by the rotated modes.
%  
%   rotSignals: The signals corresponding to the rotated modes.
%  
%   scaledRotSignals: The signals corresponding to the rotated modes scaled
%       to the analysis matrix.
             
           elseif varimax_alt==5    
 
               vect_j=eof_out.vect;
               value_j=eof_out.val;
               pc_j=eof_out.series;
               nrot=10;
%                wt=[]; 
%                norm=1;
% edit varimax_j

% out_rot = varimax_all(vect_j,value_j,pc_j,nrot,1,1); % ,wt,norm    
% edit varimax_all
%     Full varimax rotation, returning rotated EOFs, PCs, loading vectors.
%   Written by Jim Renwick, April 1995, updated March 1999.
%  
%   Inputs:
%  	vect	- unrotated EOFs, unit length
%  	value	- eigenvalues associated with vect (good to supply all of them)
%  	pc		- unrotated PCs, variance = eigenvalue
%  	** pc may be empty, in which case only rotated loadings are returned **
%  	nrot	- number of PCs to rotate
%  	wt		- optional weight vector (fractional weight of each "gridbox")
%  			  Default is ones(size(vect(:,1)))
%  	norm	- optional normalization code: 1=normalise loadings, for EOFs
%  			  based on a correlation matrix.  Default is 0 - no normalization
%   Output structure with elements:
%  	rload			- rotated loading vectors (reof=rload*inv(rload'*rload))
%  	rexpv			- fraction of variance explained by RPCs
%  	cscore		- score-coefficient matrix
%  	comm			- communalities
%  	rownorm		- normalising factors for vectors (if norm)
%  	rpc			- optional rotated PCs
%  	reof			- rotated EOFs (scaled to unit length)
%  	transform	- optional rotation matrix for loading vectors
%  
%  	See routines VARIMAX and VARIMAX2         
         end

% other functions
% help varimax_all
% help varimax_eof
% help varimax_svda
% help varimax2
% help vrotate
     
     end
     
     
elseif eof_alt_nr==2 % same as james
    
    era_z500_c9 = reshape(era_z500_c8, ntim, nlat, nlon );
    
%     era_z500_c10=permute(era_z500_c9,[3 2 1]);
    
    
    % help eof_vGreen
     [eof_maps,pc,expvar]=eof_vGreen(era_z500_c10,10);
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%     
elseif eof_alt_nr==3  
    
    addpath C:\PHD\matlab_lib\Library\rotated_eof
    
    % Data: A 2D data matrix. Each column corresponds to a particular data
%       series. Data may only contain numeric entries.
    
%     era_z500_c9 = reshape(era_z500_c8, ntim, nlat, nlon );
    
      era_z500_c10=permute(era_z500_c8,[2 1]); % get the data in the right format for the function
% 11280(latxlon)x408(time)
%    Data=era_z500_c8;
%    Data=era_z500_c10;    
    % edit ruleN
    % Jonathan King, 2017, University of Arizona
    %type_r='equamax';
    n_rot=5;
   % n_rot=3;
   %n_rot=10; 
   %n_rot=2;  
   
    type_r='Varimax';
     [sc]=EOF_Analysis(era_z500_c8,'MC', 100,'Matrix','corr','nRotate',n_rot,'rotType',type_r,'showProgress','noSigTest');  
     % edit EOF_Analysis
     % get error in ruleN if i run sigtest
     pc=sc.signals(:,(1:10));
     sc.expVar(1:5)
     pc_rot=sc.rotSignals;
     sc.rotExpVar
     eof_str='rotate';
     
     reof_nr=1;
     varimax_alt=0;
     
     
elseif eof_alt_nr==4
    
    [eofs,PCs, expvar]=caleof(era_z500_c8,10,2);
    
%       [EOFs,PC,EXPVAR] = caleof(M,N,METHOD) Compute EOF
%  
%   => Compute the Nth first EOFs of matrix M(TIME,MAP).
%   EOFs is a matrix of the form EOFs(N,MAP), PC is the principal
%   components matrix ie it has the form PC(N,TIME) and EXPVAR is
%   the fraction of total variance "explained" by each EOF ie it has
%   the form EXPVAR(N).
%   Differents method can be used:
%   1 - The "classic" one, ie we compute eigenvectors of the 
%       temporal covariance matrix with the eig Matlab function.
%   2 - A faster "classic" one, same as method 1 but we use the
%       eigs Matlab function.
%   3 - We compute eigenvectors by the singular value decomposition,
%       by used of the svd Matlab function.
%   4 - Same as method 3 but faster by used of the svds Matlab function
%  
%   See also eig, eigs, svd, svds
%  
%   Ref: L. Hartmann: "Objective Analysis" 2002
%   Ref: H. Bjornson and S.A. Venegas: "A manual for EOF and SVD - 
%        Analyses of climatic Data" 1997
elseif eof_alt_nr==5   
[EOFs,lambda1,contri1,PCs]=EOF_analysis_Zhou(era_z500_c8); % Contains North et al. 1982 test
 % edit EOF_analysis_Zhou
 % the programe contaims eof decompositon and significance test
% 1)the data must be anomaly without 'NaN', not actual value
% 2)mXn,expressing m grids and n times
% 3)[anomalies should be area-weightedsqrt(cos(lat)),not cos(lat)]
% Syntax:
% 1)[EOFs,lambda,contribution,PCs]=EOF_analysis(anomaly); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to compare eofs check compare_eofs_c2.m

toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%% North's rule of thumb test from north_test.m
anomaly=era_z500_c8;
[m,n]=size(anomaly);

% 1.0 calculate covariance matrix
% llcov=cov(era_z500_c8,1);
llcov=anomaly*anomaly'/n;

[v,D]=eig(llcov);% help eig

D=fliplr(flipud(D));

eig_alt_nr=3; % (1) anomaly field (code above) (2) King eof (3) King eof rotated


if eig_alt_nr==1

    lambda=diag(D);

elseif eig_alt_nr==2

    lambda=sc.eigvals;

elseif eig_alt_nr==3

    lambda=sc.rotEigvals;

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 4.0 North et al., (1982) significant test at 95% confidence
% 1) effective freedoms:
for j=1:m
    alpha(j,:)=autocorr(anomaly(j,:),1);
end
ralph=(mean(abs(alpha(:,2)))+max(alpha(:,2)))/2.;
tau=-1.0/log(ralph);
Nstar=n/(2*tau);
factor=sqrt(2./Nstar);


% 3Plot Eigenvalues
% Scree plot
L=lambda;
L_error=L*factor;
contribution=[100*L/sum(L),cumsum(100*L/sum(L))];
% figure
 h=fig('units','inches','width',6,'height',6,'font','Helvetica','fontsize',16,'border','on');  
   box on
   hold on

%errorbar(1:10,mean(L(:,(1:10))),mean(L_error(:,(1:10))));
% errorbar(1:10,L(1:10),L_error(1:10),'.','MarkerSize',15,...
%     'MarkerEdgeColor','red','MarkerFaceColor','red');

errorbar(1:5,L(1:5),L_error(1:5),'.','MarkerSize',15,...
    'MarkerEdgeColor','red','MarkerFaceColor','red');


if eig_alt_nr<=2
    title(['Eigenvalue: 1-10']);
    set(gca,'XLim',[0.5 10.1])
elseif eig_alt_nr==3
    title(['Eigenvalue: 1-5']);
    set(gca,'XLim',[0.5 5.1])
end

xlabel('x mode');

           set(gca,...
          'linewidth',2,...
          'FontWeight','bold' );

%%%%%%%%%%%%%%%%%%%%
% save figure
 filedir ='C:\PHD\matlab_storage_of_output_files\figures\'; 

                filename=strcat(filedir,'North_etal_test_',name,'_c2');
savefilename_c=filename;
orient landscape
export_fig('-pdf','-painters', '-depsc','-nocrop','-opengl', '-r190',savefilename_c); % PNG  110

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% prep PC data for save   
if eof_alt_nr==1 && seasonaly_nr==0

    
    if reof_nr==0 
        MA_PC_time_series=eof_out.series;
    elseif reof_nr==1 
    
  %  MA_PC_time_series=eof_out2.rload;
    
 %   MA_PC_time_series=x_reof_pcs;
   MA_PC_time_series= PCr_series; 
 %  MA_PC_time_series= PCr_series_c2;
    
    end
    
    
elseif eof_alt_nr==3 && seasonaly_nr==1 || seasonaly_nr==1
% MA_PC_time_series=pc_rot;
    

        if reof_nr==0
        MA_PC_time_series=zscore(eof_out.series);
        
        elseif  eof_alt_nr==3
        MA_PC_time_series    =zscore(pc_rot);      
        
        elseif varimax_alt<=3 && eof_alt_nr==1
        MA_PC_time_series    =zscore(PCr_series);

        end

        
        
    [a, b, c]=size(MA_PC_time_series);
    if seasonaly_nr==1
        MA_PCs_save_seasonaly=zeros(a,b+1);
        MA_PCs_save_seasonaly(:,1)=Ma_save_season_t;
    
        if varimax_alt==2
        MA_PCs_save_seasonaly(:,(2:5))=MA_PC_time_series;
        else
        MA_PCs_save_seasonaly(:,(2:11))=MA_PC_time_series;    
        end
    end
    
elseif seasonaly_nr==0 && annual_fields==1
%      MA_PC_time_series    =zscore(pc_rot(:,(1:10)));    
     MA_PC_time_series    =zscore(pc_rot(:,(1:n_rot))); 
     
    
    
end


if seasonaly_nr==0 

% if sea_nr==1
era_year_num_c=era_year_num(mm_in_c); %%% start from the beginning if you need to run it again  
% end

%%%%%%%%%% standardize using zscore
MA_PC_time_series_standardized=zscore(MA_PC_time_series);  
% MA_PC_time_series_standardized=MA_PC_time_series_standardized(mm_in_c,:);

% edit annual_mean_DE
if annual_fields==0
    MA_PCs_save=annual_mean_DE(yr_s, yr_e, era_year_num_c, MA_PC_time_series_standardized, sea_nr );


    clear a b c
    [a, b, c]=size(MA_PC_time_series_standardized);

MA_PCs_save_monthly=zeros(a,b+1);
MA_PCs_save_monthly(:,1)=era_year_num_c;
MA_PCs_save_monthly(:,(2:11))=MA_PC_time_series_standardized; % save for 10 fist EOFs


elseif annual_fields==1 
    
 clear a b c
[a, b, c]=size(MA_PC_time_series_standardized);   
MA_PCs_save=zeros(a,b+1);
MA_PCs_save(:,1)=[yr_s:yr_e];
    if varimax_alt==1
    MA_PCs_save(:,(2:11))=MA_PC_time_series_standardized; % save for 10 fist EOFs 
    elseif eof_alt_nr==3
    MA_PCs_save(:,(2:n_rot+1))=MA_PC_time_series_standardized;
    elseif varimax_alt==2
    MA_PCs_save(:,(2:5))=MA_PC_time_series_standardized;
    end

end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%  Save Data 
save_data=1;
if save_data==1
 filedir ='C:\PHD\matlab_storage_of_output_files\';
 %name_end_str='_c2';
 %name_end_str='_c3';
  name_end_str='_c5'; % rotate 5, based on scree plot
  
 
 name_str=[reanalysis_str,'_PCs','_', geo_str,'_lim',num2str(lims(1)),...
     '-',num2str(lims(2)),'_',num2str(lims(4)),'_',num2str(lims(3)),'_',num2str(yr_s),'-',num2str(yr_e),'_',season,...
     name_end_str,seasonal_str];

    if  detrend_nr==1
        savefilename =[filedir, name_str,'_', eof_str '.mat'];
    elseif  detrend_nr==0
        savefilename =[filedir, name_str,'_', eof_str,'_trend' ,'.mat'];     
    end
    
    if seasonaly_nr==0 && annual_fields==0
        save(savefilename,'MA_PCs_save','MA_PCs_save_monthly');
    elseif seasonaly_nr==1 && annual_fields==0
        save(savefilename,'MA_PCs_save_seasonaly');% this is one for the season considered per year 
    elseif annual_fields==1    
        save(savefilename,'MA_PCs_save') % eof done on annual means  
    end
end   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

