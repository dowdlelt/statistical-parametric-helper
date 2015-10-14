function [] = batch_template()

%This function has been modified to automate the import of the ART
%Detection Tool box. The assumption has been made that the files are
%labeled artifact outliers and movement_wae.*mat
%This is a safe assumption, assuming that they were slice timed, and then
%the artifacts were calculated from those files. A variety of different
%methods could be used here, so it would be best to edit that area if this
%script is used in different areas. 

%The contrasts are generated using the function that finds the number of
%regressors

%This is all kind of specialized for that very specific purpose. 



% This function is an example of how to set up a batch script for running
% SPM8 routines across multiple subjects. It loops across subjects, 
% defining subject-specific variables (according to default variables + 
% subject-specific exceptions). These variables are then substituted into a
% subfunction containing the output from the SPM8 batch editor. In this 
% way, the script is very flexible- any routine from the SPM8 batch system 
% can be generalized to fit into this framework. The below batch_job
% subfunction is a basic fMRI pre-processing routine.
%
% Author: Maureen Ritchey, updated 03/2013

%
%Logan
% Data directory is here 
%/data/cairhive0/studies_large/hanlon_share/Test-retest/subjects/controls/001_xl/convert/anat

%9/17/2015 - change it so that it wouldn't mask out dark areas of the brain
%- hope this works correctly. 
clear all;
curdir = pwd;
clear all;
curdir = pwd;

%Specify variables
outLabel = 'spec_est_con_crave_scrub'; %output label
subjects = {'403' '405' '409' '411' '415' '417' '421' '424' '427' '430' '433' '436' '438' '404' '408' '410' '412' '416' '419' '422' '426' '429' '432' '435' '437'};
dataDir = '/data/cairhive0/studies_large/hanlon_share/Thetaburst/subjects/Cocaine/';
runs = {'real/run1_craving_preTBS' 'real/run6_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run6_craving_postTBS'};

numSubjs = length(subjects);
fprintf('Performing first level analysis for %d subjects. \n',numSubjs);
%fprintf('Results will be saved to %s .\n',modelDir);


for i=1:length(subjects)
    %Define variables for individual subjects
    b.curSubj = subjects{i};
    b.dataDir = strcat(dataDir, b.curSubj,'/');
    b.runs = runs;
    
    %Run exceptions for subject-specific naming conventions
    b = run_exceptions(b); 
    
    %building contrast onsets with variable number of regressors
    %change to furst run directory
    cd(strcat(b.dataDir, b.runs{1}, '/'));
    %need to load the art_outlier_and_movement_ matfile  
    b.run1RegressorList = dir('art*t_wae*.mat'); %this is specific to the output of ART and should be made a variable
    %/\ generate the filename, which a bunch extra
    b.outlier_mat1 = load(b.run1RegressorList.name);
    %/\load, just using the file itself
    b.numRegress1 = size(b.outlier_mat1.R,2);
    
    cd(strcat(b.dataDir, b.runs{2}, '/'));
    %need to load the art_outlier_and_movement_ matfile  
    b.run2RegressorList = dir('art*t_wae*.mat');
    %/\ generate the filename, which a bunch extra
    b.outlier_mat2 = load(b.run2RegressorList.name);
    %/\load, just using the file itself
    b.numRegress2 = size(b.outlier_mat2.R,2);
    
   cd(strcat(b.dataDir, b.runs{3}, '/'));
    %need to load the art_outlier_and_movement_ matfile  
    b.run3RegressorList = dir('art*t_wae*.mat');
    %/\ generate the filename, which a bunch extra
    b.outlier_mat3 = load(b.run3RegressorList.name);
    %/\load, just using the file itself
    b.numRegress3 = size(b.outlier_mat3.R,2);
    
    cd(strcat(b.dataDir, b.runs{4}, '/'));
    %need to load the art_outlier_and_movement_ matfile  
    b.run4RegressorList = dir('art*t_wae*.mat');
    %/\ generate the filename, which a bunch extra
    b.outlier_mat4 = load(b.run4RegressorList.name);
    %/\load, just using the file itself
    b.numRegress4 = size(b.outlier_mat4.R,2)
    
       
    
    
    %specify matlabbatch variable with subject-specific inputs
    %this is created prior to running the batch
    
    matlabbatch = batch_job(b);
    
    %save matlabbatch variable for posterity
    outName = strcat(b.dataDir,outLabel,'_',date, '_',b.curSubj);
    save(outName, 'matlabbatch');
    
    % comment out the section below to generate a janky list of # of
    % outliers
    %run matlabbatch job
    cd(b.dataDir);
    try
        spm_jobman('initcfg')
        spm('defaults', 'FMRI');
        spm_jobman('serial', matlabbatch);
    catch
        cd(curdir);
        continue;
    end
    
    % coment out above 10 lines or so for list of outliers
    cd(curdir);
    
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [b] = run_exceptions(b)
%This takes care of the subjects that had multiple TMS runs, thereby
%changing the naming conventions for their craving runs. 


if strcmp(b.curSubj,'408')
    b.runs = {'real/run1_craving_preTBS' 'real/run8_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run6_craving_postTBS'};
end

if strcmp(b.curSubj,'409')
    b.runs = {'real/run1_craving_preTBS' 'real/run8_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run8_craving_postTBS'};
end

if strcmp(b.curSubj,'410')
    b.runs = {'real/run1_craving_preTBS' 'real/run8_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run8_craving_postTBS'};
end

if strcmp(b.curSubj,'419')
    b.runs = {'real/run1_craving_preTBS' 'real/run8_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run8_craving_postTBS'};
end
if strcmp(b.curSubj,'421')
    b.runs = {'real/run1_craving_preTBS' 'real/run8_craving_postTBS' 'sham/run1_craving_preTBS' 'sham/run8_craving_postTBS'};
end

end


function [matlabbatch]=batch_job(b)
%This function generates the matlabbatch variable: can be copied in
%directly from the batch job output, then modify lines as necessary to
%generalize the paths, etc, using b variables

%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------

matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'/data/cairhive0/studies_large/hanlon_share/Thetaburst/crave/Cocaine/ignore_me'};
matlabbatch{1}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = b.curSubj;
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.parent = {'/studies_large/hanlon_share/Thetaburst/crave/Cocaine/first_level_scrubbed'};
matlabbatch{2}.cfg_basicio.file_dir.dir_ops.cfg_mkdir.name = b.curSubj;
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.name = 'Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -';
matlabbatch{3}.cfg_basicio.file_dir.dir_ops.cfg_named_dir.dirs = {
                                                                  {[b.dataDir b.runs{1} '/']}
                                                                  {[b.dataDir b.runs{2} '/']}
                                                                  {[b.dataDir b.runs{3} '/']}
                                                                  {[b.dataDir b.runs{4} '/']}
                                                                  }';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^swaep.*_brain.nii';
matlabbatch{4}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(2)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{2}));
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^swaep.*_brain.nii';
matlabbatch{5}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(1)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{1}));
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^art.*t_wae.*mat';
matlabbatch{6}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{7}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(2)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{2}));
matlabbatch{7}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^art.*t_wae.*mat';
matlabbatch{7}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{8}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^swaep.*_brain.nii)', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{8}.spm.util.exp_frames.frames = Inf;
matlabbatch{9}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^swaep.*_brain.nii)', substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{9}.spm.util.exp_frames.frames = Inf;
matlabbatch{10}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(3)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{3}));
matlabbatch{10}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^swaep.*_brain.nii';
matlabbatch{10}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{11}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(4)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{4}));
matlabbatch{11}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^swaep.*_brain.nii';
matlabbatch{11}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{12}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(3)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{3}));
matlabbatch{12}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^art.*t_wae.*mat';
matlabbatch{12}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{13}.cfg_basicio.file_dir.file_ops.file_fplist.dir(1) = cfg_dep('Named Directory Selector: Crave; Real Pre (1), Post (2), Sham Pre (3), Post (4) -(4)', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dirs', '{}',{4}));
matlabbatch{13}.cfg_basicio.file_dir.file_ops.file_fplist.filter = '^art.*t_wae.*mat';
matlabbatch{13}.cfg_basicio.file_dir.file_ops.file_fplist.rec = 'FPList';
matlabbatch{14}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^swaep.*_brain.nii)', substruct('.','val', '{}',{10}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{14}.spm.util.exp_frames.frames = Inf;
matlabbatch{15}.spm.util.exp_frames.files(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^swaep.*_brain.nii)', substruct('.','val', '{}',{11}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{15}.spm.util.exp_frames.frames = Inf;
matlabbatch{16}.spm.stats.fmri_spec.dir(1) = cfg_dep('Make Directory: Make Directory ''subj_number''', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','dir'));
matlabbatch{16}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{16}.spm.stats.fmri_spec.timing.RT = 2.2;
matlabbatch{16}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{16}.spm.stats.fmri_spec.timing.fmri_t0 = 8;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{8}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).name = 'real pre cocaine';
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).onset = [60
                                                             210
                                                             300
                                                             360
                                                             570
                                                             660];
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(1).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).name = 'real pre object';
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).onset = [0
                                                             150
                                                             270
                                                             420
                                                             480
                                                             630];
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(2).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).name = 'real pre blur';
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).onset = [30
                                                             120
                                                             240
                                                             390
                                                             540
                                                             690];
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(3).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).name = 'real pre rest';
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).onset = [90
                                                             180
                                                             330
                                                             450
                                                             510
                                                             600];
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(4).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).name = 'real pre Rate Craving';
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).onset = [24
                                                             54
                                                             84
                                                             114
                                                             144
                                                             174
                                                             204
                                                             234
                                                             264
                                                             294
                                                             324
                                                             354
                                                             384
                                                             414
                                                             444
                                                             474
                                                             504
                                                             534
                                                             564
                                                             594
                                                             624
                                                             654
                                                             684
                                                             714];
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).duration = 6;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).cond(5).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(1).multi = {''};
matlabbatch{16}.spm.stats.fmri_spec.sess(1).regress = struct('name', {}, 'val', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(1).multi_reg(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^art.*t_wae.*mat)', substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(1).hpf = 128;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{9}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).name = 'real post cocaine';
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).onset = [60
                                                             210
                                                             300
                                                             360
                                                             570
                                                             660];
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(1).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).name = 'real post object';
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).onset = [0
                                                             150
                                                             270
                                                             420
                                                             480
                                                             630];
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(2).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).name = 'real post blur';
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).onset = [30
                                                             120
                                                             240
                                                             390
                                                             540
                                                             690];
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(3).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).name = 'real post rest';
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).onset = [90
                                                             180
                                                             330
                                                             450
                                                             510
                                                             600];
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(4).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).name = 'real post Rate Craving';
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).onset = [24
                                                             54
                                                             84
                                                             114
                                                             144
                                                             174
                                                             204
                                                             234
                                                             264
                                                             294
                                                             324
                                                             354
                                                             384
                                                             414
                                                             444
                                                             474
                                                             504
                                                             534
                                                             564
                                                             594
                                                             624
                                                             654
                                                             684
                                                             714];
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).duration = 6;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).cond(5).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(2).multi = {''};
matlabbatch{16}.spm.stats.fmri_spec.sess(2).regress = struct('name', {}, 'val', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(2).multi_reg(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^art.*t_wae.*mat)', substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(2).hpf = 128;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{14}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).name = 'sham pre cocaine';
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).onset = [60
                                                             210
                                                             300
                                                             360
                                                             570
                                                             660];
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(1).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).name = 'sham pre object';
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).onset = [0
                                                             150
                                                             270
                                                             420
                                                             480
                                                             630];
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(2).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).name = 'sham pre blur';
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).onset = [30
                                                             120
                                                             240
                                                             390
                                                             540
                                                             690];
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(3).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).name = 'sham pre rest';
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).onset = [90
                                                             180
                                                             330
                                                             450
                                                             510
                                                             600];
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(4).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).name = 'sham pre Rate Craving';
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).onset = [24
                                                             54
                                                             84
                                                             114
                                                             144
                                                             174
                                                             204
                                                             234
                                                             264
                                                             294
                                                             324
                                                             354
                                                             384
                                                             414
                                                             444
                                                             474
                                                             504
                                                             534
                                                             564
                                                             594
                                                             624
                                                             654
                                                             684
                                                             714];
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).duration = 6;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).cond(5).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(3).multi = {''};
matlabbatch{16}.spm.stats.fmri_spec.sess(3).regress = struct('name', {}, 'val', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(3).multi_reg(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^art.*t_wae.*mat)', substruct('.','val', '{}',{12}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(3).hpf = 128;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{15}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).name = 'sham post cocaine';
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).onset = [60
                                                             210
                                                             300
                                                             360
                                                             570
                                                             660];
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(1).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).name = 'sham post object';
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).onset = [0
                                                             150
                                                             270
                                                             420
                                                             480
                                                             630];
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(2).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).name = 'sham post blur';
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).onset = [30
                                                             120
                                                             240
                                                             390
                                                             540
                                                             690];
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(3).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).name = 'sham post rest';
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).onset = [90
                                                             180
                                                             330
                                                             450
                                                             510
                                                             600];
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).duration = 24;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(4).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).name = 'sham post Rate Craving';
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).onset = [24
                                                             54
                                                             84
                                                             114
                                                             144
                                                             174
                                                             204
                                                             234
                                                             264
                                                             294
                                                             324
                                                             354
                                                             384
                                                             414
                                                             444
                                                             474
                                                             504
                                                             534
                                                             564
                                                             594
                                                             624
                                                             654
                                                             684
                                                             714];
%%
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).duration = 6;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).tmod = 0;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).cond(5).orth = 1;
matlabbatch{16}.spm.stats.fmri_spec.sess(4).multi = {''};
matlabbatch{16}.spm.stats.fmri_spec.sess(4).regress = struct('name', {}, 'val', {});
matlabbatch{16}.spm.stats.fmri_spec.sess(4).multi_reg(1) = cfg_dep('File Selector (Batch Mode): Selected Files (^art.*t_wae.*mat)', substruct('.','val', '{}',{13}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{16}.spm.stats.fmri_spec.sess(4).hpf = 128;
matlabbatch{16}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{16}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{16}.spm.stats.fmri_spec.volt = 1;
matlabbatch{16}.spm.stats.fmri_spec.global = 'None';
matlabbatch{16}.spm.stats.fmri_spec.mthresh = -Inf;
matlabbatch{16}.spm.stats.fmri_spec.mask = {''};
matlabbatch{16}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{17}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{16}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{17}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{17}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{18}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{17}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{18}.spm.stats.con.consess{1}.tcon.name = 'Real Pre Cocaine';
matlabbatch{18}.spm.stats.con.consess{1}.tcon.weights = [1	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1,b.numRegress3)	0	0	0	0	0	zeros(1,b.numRegress4)];
matlabbatch{18}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{2}.tcon.name = 'Real Pre Object';
matlabbatch{18}.spm.stats.con.consess{2}.tcon.weights = [0	1	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)	
];
matlabbatch{18}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{3}.tcon.name = 'Real Pre Blur';
matlabbatch{18}.spm.stats.con.consess{3}.tcon.weights = [0	0	1	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)	
];
matlabbatch{18}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{4}.tcon.name = 'Real Pre Rest';
matlabbatch{18}.spm.stats.con.consess{4}.tcon.weights = [0	0	0	1	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)	
];
matlabbatch{18}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{5}.tcon.name = 'Real Pre Rate';
matlabbatch{18}.spm.stats.con.consess{5}.tcon.weights = [0	0	0	0	1	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)	
];
matlabbatch{18}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{6}.tcon.name = 'Real Post Cocaine';
matlabbatch{18}.spm.stats.con.consess{6}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	1	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{7}.tcon.name = 'Real Post Object';
matlabbatch{18}.spm.stats.con.consess{7}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	1	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{8}.tcon.name = 'Real Post Blur';
matlabbatch{18}.spm.stats.con.consess{8}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	1	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{9}.tcon.name = 'Real Post Rest';
matlabbatch{18}.spm.stats.con.consess{9}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	1	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{10}.tcon.name = 'Real Post Rate';
matlabbatch{18}.spm.stats.con.consess{10}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	1	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{11}.tcon.name = 'Sham Pre Cocaine';
matlabbatch{18}.spm.stats.con.consess{11}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	1	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{12}.tcon.name = 'Sham Pre Object';
matlabbatch{18}.spm.stats.con.consess{12}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	1	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{13}.tcon.name = 'Sham Pre Blur';
matlabbatch{18}.spm.stats.con.consess{13}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	1	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{13}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{14}.tcon.name = 'Sham Pre Rest';
matlabbatch{18}.spm.stats.con.consess{14}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	1	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{14}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{15}.tcon.name = 'Sham Pre Rate';
matlabbatch{18}.spm.stats.con.consess{15}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	1	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{15}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{16}.tcon.name = 'Sham Post Cocaine';
matlabbatch{18}.spm.stats.con.consess{16}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	1	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{16}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{17}.tcon.name = 'Sham Post Object';
matlabbatch{18}.spm.stats.con.consess{17}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	1	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{17}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{18}.tcon.name = 'Sham Post Blur';
matlabbatch{18}.spm.stats.con.consess{18}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	1	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{18}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{19}.tcon.name = 'Sham Post Rest';
matlabbatch{18}.spm.stats.con.consess{19}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	1	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{19}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{20}.tcon.name = 'Sham Post Rate';
matlabbatch{18}.spm.stats.con.consess{20}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	1	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{20}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{21}.tcon.name = 'Real Pre Cocaine gr Object';
matlabbatch{18}.spm.stats.con.consess{21}.tcon.weights = [1	-1	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{21}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{22}.tcon.name = 'Real Post Cocaine gr Object';
matlabbatch{18}.spm.stats.con.consess{22}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	1	-1	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{22}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{23}.tcon.name = 'Sham Pre Cocaine gr Object';
matlabbatch{18}.spm.stats.con.consess{23}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	1	-1	0	0	0	zeros(1, b.numRegress3)	0	0	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{23}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.consess{24}.tcon.name = 'Sham Post Cocaine gr Object';
matlabbatch{18}.spm.stats.con.consess{24}.tcon.weights = [0	0	0	0	0	zeros(1, b.numRegress1)	0	0	0	0	0	zeros(1, b.numRegress2)	0	0	0	0	0	zeros(1, b.numRegress3)	1	-1	0	0	0	zeros(1, b.numRegress4)
];
matlabbatch{18}.spm.stats.con.consess{24}.tcon.sessrep = 'none';
matlabbatch{18}.spm.stats.con.delete = 0;

end
