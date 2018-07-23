%% Script for typical retinotopy scan


%% Define subject ID number and date string first.
% Run these 2 lines of code after replacing these items with this scan's
% subject ID and today's date, but before presenting stimuli.  This block
% of code must be re-run if you had to restart MATLAB in the middle of the
% scan.

subj_ID='0000';  % Replace with subject's ID number as a string.
date_ID='180618';  % Replace with today's scan date as a string.  Recommended format: 'yymmdd'


%% CCW wedges.
% Place screen at distance 90 cm from subject's forehead.
% Then run these 2 lines of code.
repnum=10;
dostimretinotopy_131212('DOT',repnum,'CCW','stim_wedge',[subj_ID '_' date_ID '_CCW']);

%% CW wedges.
% Place screen at distance 90 cm from subject's forehead.
% Then run these 2 lines of code.
repnum=10;
dostimretinotopy_131212('DOT',repnum,'CW','stim_wedge',[subj_ID '_' date_ID '_CW']);

%% IN rings.
% Place screen at distance 90 cm from subject's forehead.
% Then run these 2 lines of code.
repnum=10;
dostimretinotopy_131212('DOT',repnum,'IN','stim_ring',[subj_ID '_' date_ID '_IN']);

%% OUT rings.
% Place screen at distance 90 cm from subject's forehead.
% Then run these 2 lines of code.
repnum=10;
dostimretinotopy_131212('DOT',repnum,'OUT','stim_ring',[subj_ID '_' date_ID '_OUT']);


%% AC wedges.
% Place screen at distance 75 cm from subject's forehead.
% Then run these 2 lines of code.
repnum=8;
dostimAC_new('DOT',repnum,'Block','stim_ACbig',8,[subj_ID '_' date_ID '_AC']);