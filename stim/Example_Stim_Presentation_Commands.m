%% Sample one-line commands for stimulus presentation.
% Modify, copy, paste, and run each line in the MATLAB command window
% during imaging sessions and optical data acquisition to present stimuli
% to the subject.

dostimretinotopy_131212('DOT',10,'CCW','stim_wedge','test'); % Phase-Encoded Retinotopy (CW or CCW wedges)
dostimretinotopy_131212('DOT',10,'OUT','stim_ring','test'); % Phase-Encoded Retinotopy (OUT or IN rings)
dostimAC_new('DOT',8,'Block','stim_ACbig',8,'test'); % Retinotopy AC big ("AC" = alternating checkerboard)
dostim_fcDOT('DOT',0.5,'test'); % Simple fixation cross ("resting state")


%% Example CW-1: Display 1 block of flickering, clockwise-rotating checkerboard wedges.
% 1 block = 1 full sweep of 360 degrees for wedge checkerboards.

dostimretinotopy_131212('DOT',1,'CW','stim_wedge','test_CW-1');


%% Example IN-1: Display 1 block of flickering, inwardly-contracting checkerboard rings.

dostimretinotopy_131212('DOT',1,'IN','stim_ring','test_IN-1');


%% Example ACbig-8Hz-Block-2: Display 2 repetitions (4 checkerboards) of big alternating checkerboard wedges, flickering at 8 Hz, timed for block design.

dostimAC_new('DOT',2,'Block','stim_ACbig',8,'test_ACbig-8Hz-Block-2');


%% Example Rest-1: Display fixation cross for 0.5 minutes.

dostim_fcDOT('DOT',0.5,'test_Rest-1');


%% General information about these stimulus presentation functions.

% These stimuli follow a standard organization:
%   1   Command line code that sets parameters, steps, calls dostim2.m
%   2   dostim2.m code initializes hardware, steps through stim
%       presentation. Each stimulus type is a case in a switch in the step
%       loop. This also saves any input sent to the keyboard by the subject
%       and other timing/stim/etc information.
%   3   Individual stimulus presentation codes the are specialized to take
%       a few parameters, deliver stimuli, and deliver synch pulses. These
%       should ideally be as stripped down and simple as possible.
%
% The stimulus code utilizes harware synchronization for optimal
% performance. These synch pulses are used to synchronize multiple
% acquisition computers and the DOT data stream with the stimuli and other
% potential data streams. These synch pulses are also
% standardized:
%   1   synchF  20 Hz   These pulses are used at the very beginning and the
%                       very end of the run, as well as all fixation or
%                       rest or 'null' stimuli trials. The initial and
%                       final pulses are used to combine data from multiple
%                       acquisition computers. 
%   2   synchA  25 Hz   This is for stimulus trial type 1, whatever that
%                       may be.
%   3   synchB  30 Hz   Same, but now a 2nd stimulus type is supported.
%   4   synchC  35 Hz   As above.
%
% Only four synch pulse frequencies are currently supported. If a paradigm
% requires more than 4 trial types, we can address that need at that time.
% The pulses must be separated by 5 Hz because of noise in the decoding of
% the pulse frequencies. Also, the frequencies must all exist within an
% octave to avoid cross-talk.
%
% The timing of all paradigms should reflect the following:
% synchF || synchA | synchB | ... {synchF/A/B/C}... || synchF || synchF
% The inital synchF epoch (time length before ||) should usually be set to
% 30 sec to allow for full initialization and subject preparation. The
% second phase is the stimulus presentation. That timing is dictated by the
% paradigm of interest. The 2nd-to-last synchF should be set to 5sec or
% longer to allow for slop in the responses and stimuli presentation. the
% final synchF can be set to 2sec. Thus, the minimal synch pulse schedule,
% used for resting state (r.s.), or movie presentation is this:
%  synchF(30sec) | synchA(movie/r.s. length) | synchF(5sec) | synchF(2sec)