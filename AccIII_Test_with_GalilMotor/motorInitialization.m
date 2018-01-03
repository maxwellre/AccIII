%% UGrip Motor Initialization
% RE TOUCH LAB, UC Santa Barbara (re-touch-lab.com).
% Updated code based on prior work by Hengjun Cui from 2014 to 2015 and
% Keerthi Adithya Duraikkannan from 2013 to 2014.
% The UGrip related experiments are advised by Dr. Yon Visell, PI.
% Code modified on 08/24/2016 by Yitian Shao.
%
% Version: 1.0
% This code is used during the initial setup of the UGrip device.
% -------------------------------------------------------------------------
% Device information:
%   Motors: H2W Technologies, Inc. Model #: VCS15-050-LB-01-MC-2
%   Controller: Galil Motion Control. Model #: DMC-40x0
% -------------------------------------------------------------------------
% Setup instructions (eithernet connection):
% Please ensure Galil Tool and Galil Suite are downloaded and installed
% (www.galilmc.com/downloads/software).
%
% Open Network and Sharing Center from Control panel ->
% LAN-Properties-Internet Protocol Version4(TCP/IPv4) ->
% Use the following IP address 168.192.1.n ( by default n = 2 )
%
% Open Galil Tools software -> Connections -> Go to No IP Address tab ->
% Select Device and assign IP address -> Go to Available tab ->
% Select device -> Connect
% On Galil Tool terminal type "IA?" (no quote) -> confirm IP address ->
% Use BN command to burn it into the controller ( will prevent to do above
% process again)
%
% Note:
% 1. Galil Tool is used for 1st time connection with the controller.
%    Galil Suite software is used for all other tasks
% 2. On RetouchLab-PC, TCP/IPv4 address is set to be 168.192.1.2 but Galil
%    detect the controller at 168.192.1.3 for unknown reason
%
% (After 1st time connection) Open Galil Suite software -> connect ->
% select DMC4020*** in Device List -> connect
% 
% DMC command reference (www.galilmc.com/downloads/manuals-and-data-sheets)
%
% AC/DC - Acceleration/Deceleration [Range: 1024 - 1073740800]
%      Linear AC/DC rate of motors for moves such as PR, PA, and JG moves.
% AM - After Move
%      "AM XY" hold up execution of the following commands until the
%      current move on the X and Y axis is completed.
% BG - Begin
%      "BG XY" start a motion on the both X and Y axis.
% CE - Configure Encoder
%      "CE 2,2" set axis X and Y encoder:
%      Main = 2: Reversed quadrature, Auxiliary = 0: Normal quadrature.
% CN - Configure
%      "CN -1,-1" set 'Limit switches active low' and set 'HM drive motor
%      backward when home input is high'. (See reference)
% DP - Define Position
%      "DPX=0" set current motor (and command) position of axis X to 0.
% ER - Error Limit
%      "ER m,n" set error limit for axis X and Y
% JG - Jog [Speed range for servos: -22000000 - 22000000 counts/sec]
% KP/KI/KD - PID Constant
% MG - Message
%      "MG str" print the string str
% MT - Motor Type
%      "MT 1,1" set axis X and Y both servo motor (default)
% MO - Motor Off
%      Turn off the motor command line and toggles the amplifier enable
%      signal
% OE - Off-on-Error
%      "OE m,n" set axis X and Y Off-on-Error function:
%      0: Disabled, 3: Motor shut off by position error, etc.
% OF - Offset [Range: -9.9 - 9.9]
%      Set a bias voltage in the command. Can be used to generate noise.
% PA/PR - Position Absolute/Position Relative
%      "PA m,n" move axis X to m counts and Y to n counts.
% SH - Servo Here
%      Controller uses the current motor position and enable servo control.
% SP - (Slew) Speed [Range for servos: 0 - 22000000]
% ST - Stop
%      Stop program execution
% TE - Tell Error
%      "-TEX" return the current error in the control loop of X axis.
% TL - Torque Limit [Range: 0 - 5]
% TM - Update Time [Range: 62.5 - 5000]
%      "TM n" set the sampling period of the control loop (unit: us).
% TP - Tell Position
%      "x=_TPX" assign the current position of motor X to variable x. 
% WT - Wait
%      "WT t" command the controller to wait for t milliseconds before
%      executing the next command.
% XQ - Execute Program
%      Begin execution of a program residing in the program memory of the
%      controller.
% =========================================================================
% Configuration
function [galil_obj] = motorInitialization(DMC_path)
ip_address = '168.192.1.3'; % Type "IA?" in Galil Tool terminal to acquire
% (Note: On RetouchLab-PC, TCP/IPv4 address is set to be 168.192.1.2 but 
% Galil detect the controller at 168.192.1.3 for unknown reason)

% Initialization and Calibration
if ~exist('galil_obj', 'var')
    galil_obj = actxserver('galil'); % Obejct of the GalilTools COM wrapper
                             % for communication with the controller
    galil_obj.address = ip_address; % Open connections
    galil_obj.programDownloadFile( [DMC_path,'calibration.dmc'] ); % Load .dmc file
    galil_obj.command('XQ');% Run the Program
    
    disp('Calibrating...')
    
    % Wait for the device to be ready
    tic
    % While loop reads for the READY value from dmc program
    while str2double(galil_obj.command('MG READY')) == 0
        pause(0.1);
    end
    fprintf('Calibration completed in %.0f sec \nDevice Ready.\n', toc);
    beep;beep;
end
end