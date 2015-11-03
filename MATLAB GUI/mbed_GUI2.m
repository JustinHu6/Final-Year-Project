function varargout = mbed_GUI2(varargin)
%mbed_GUI2 M-file for mbed_GUI2.fig
%      mbed_GUI2, by itself, creates a new mbed_GUI2 or raises the existing
%      singleton*.
%
%      H = mbed_GUI2 returns the handle to a new mbed_GUI2 or the handle to
%      the existing singleton*.
%
%      mbed_GUI2('Property','Value',...) creates a new mbed_GUI2 using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to mbed_GUI2_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      mbed_GUI2('CALLBACK') and mbed_GUI2('CALLBACK',hObject,...) call the
%      local function named CALLBACK in mbed_GUI2.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help mbed_GUI2

% Last Modified by GUIDE v2.5 08-Jul-2015 16:14:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mbed_GUI2_OpeningFcn, ...
                   'gui_OutputFcn',  @mbed_GUI2_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

% --- Executes just before mbed_GUI2 is made visible.
function mbed_GUI2_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for mbed_GUI2
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes mbed_GUI2 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = mbed_GUI2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in run_pot.
function run_pot_Callback(hObject, eventdata, handles)
% hObject    handle to run_pot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of run_pot

global vdd; % supply voltage
global HL;
global hlc;

HL = 0;
% sync signals
mbed_ready = 0;
pc_ready = uint8(1);

vdac = str2double(get(handles.vdac_val,'String'));   % initialize in case user directly presses button
vdac_frac = vdac/vdd;

multi_pot = get(handles.pot_multi,'Value'); % potentiostat: multi if 1; single if 0
if multi_pot == 1
    elect_total = 16;   % total number of electrodes per channel
else
    elect_total = 8;
end

earray = zeros(5,16);

% update GUI settings
set(hObject,'Enable','off');
set(handles.vdac_val,'Enable','off');
set(handles.vred_val,'Enable','off');
set(handles.frame_val,'Enable','off');
set(handles.dac_slider,'Enable','off');
set(handles.stopclear,'Enable','on');
set(handles.loaddata,'Enable','off');
set(handles.pot_multi,'Enable','off');
set(handles.pot_single,'Enable','off');

base_gain = 16000;  % base feedback gain

% delays in real-time sampling increase with number of samples plotted
% set maximum number of samples displayed in figure to prevent large delays
frame = str2double(get(handles.frame_val,'String'));
frame_index = -frame + 2;   % frame index
start = 1;  % initial starting index of data to be plotted

% establish serial port interface
mbed = serial('COM3'); % COM3 for new laptop, COM60 for PC
set(mbed, 'Timeout', 10);
fopen(mbed);

% initialize electrode plots
index = 1;  % data sample count
elect = 1;  % selected electrode

% Channel 1
t_ch1(1:elect_total) = 0;
vdata_ch1(1:elect_total) = 0;
cdata_ch1(1:elect_total) = 0;
fb_sel_ch1(1:elect_total) = 0;
hold(handles.axes_ch1,'on');
title(handles.axes_ch1,'Channel 1');
ylabel(handles.axes_ch1,'Current (A)');
ch1_fig(1) = plot(handles.axes_ch1, t_ch1(1,1), cdata_ch1(1,1), 'r-x');
ch1_fig(2) = plot(handles.axes_ch1, t_ch1(1,2), cdata_ch1(1,2), 'g-x');
ch1_fig(3) = plot(handles.axes_ch1, t_ch1(1,3), cdata_ch1(1,3), 'b-x');
ch1_fig(4) = plot(handles.axes_ch1, t_ch1(1,4), cdata_ch1(1,4), 'c-x');
ch1_fig(5) = plot(handles.axes_ch1, t_ch1(1,5), cdata_ch1(1,5), 'm-x');
ch1_fig(6) = plot(handles.axes_ch1, t_ch1(1,6), cdata_ch1(1,6), 'y-x');
ch1_fig(7) = plot(handles.axes_ch1, t_ch1(1,7), cdata_ch1(1,7), 'k-x');
ch1_fig(8) = plot(handles.axes_ch1, t_ch1(1,8), cdata_ch1(1,8), '-x', 'Color', [0.5,0.5,0.5]);
if multi_pot == 1
    ch1_fig(9) = plot(handles.axes_ch1, t_ch1(1,9), cdata_ch1(1,9), 'r-s');
    ch1_fig(10) = plot(handles.axes_ch1, t_ch1(1,10), cdata_ch1(1,10), 'g-s');
    ch1_fig(11) = plot(handles.axes_ch1, t_ch1(1,11), cdata_ch1(1,11), 'b-s');
    ch1_fig(12) = plot(handles.axes_ch1, t_ch1(1,12), cdata_ch1(1,12), 'c-s');
    ch1_fig(13) = plot(handles.axes_ch1, t_ch1(1,13), cdata_ch1(1,13), 'm-s');
    ch1_fig(14) = plot(handles.axes_ch1, t_ch1(1,14), cdata_ch1(1,14), 'y-s');
    ch1_fig(15) = plot(handles.axes_ch1, t_ch1(1,15), cdata_ch1(1,15), 'k-s');
    ch1_fig(16) = plot(handles.axes_ch1, t_ch1(1,16), cdata_ch1(1,16), '-s', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch1,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

    % Channel 2
    t_ch2(1:elect_total) = 0;
    vdata_ch2(1:elect_total) = 0;
    cdata_ch2(1:elect_total) = 0;
    fb_sel_ch2(1:elect_total) = 0;
    hold(handles.axes_ch2,'on');
    title(handles.axes_ch2,'Channel 2');
    ch2_fig(1) = plot(handles.axes_ch2, t_ch2(1,1), cdata_ch2(1,1), 'r-x');
    ch2_fig(2) = plot(handles.axes_ch2, t_ch2(1,2), cdata_ch2(1,2), 'g-x');
    ch2_fig(3) = plot(handles.axes_ch2, t_ch2(1,3), cdata_ch2(1,3), 'b-x');
    ch2_fig(4) = plot(handles.axes_ch2, t_ch2(1,4), cdata_ch2(1,4), 'c-x');
    ch2_fig(5) = plot(handles.axes_ch2, t_ch2(1,5), cdata_ch2(1,5), 'm-x');
    ch2_fig(6) = plot(handles.axes_ch2, t_ch2(1,6), cdata_ch2(1,6), 'y-x');
    ch2_fig(7) = plot(handles.axes_ch2, t_ch2(1,7), cdata_ch2(1,7), 'k-x');
    ch2_fig(8) = plot(handles.axes_ch2, t_ch2(1,8), cdata_ch2(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch2_fig(9) = plot(handles.axes_ch2, t_ch2(1,9), cdata_ch1(1,9), 'r-s');
    ch2_fig(10) = plot(handles.axes_ch2, t_ch2(1,10), cdata_ch2(1,10), 'g-s');
    ch2_fig(11) = plot(handles.axes_ch2, t_ch2(1,11), cdata_ch2(1,11), 'b-s');
    ch2_fig(12) = plot(handles.axes_ch2, t_ch2(1,12), cdata_ch2(1,12), 'c-s');
    ch2_fig(13) = plot(handles.axes_ch2, t_ch2(1,13), cdata_ch2(1,13), 'm-s');
    ch2_fig(14) = plot(handles.axes_ch2, t_ch2(1,14), cdata_ch2(1,14), 'y-s');
    ch2_fig(15) = plot(handles.axes_ch2, t_ch2(1,15), cdata_ch2(1,15), 'k-s');
    ch2_fig(16) = plot(handles.axes_ch2, t_ch2(1,16), cdata_ch2(1,16), '-s', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch2,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

    % Channel 3
    t_ch3(1:elect_total) = 0;
    vdata_ch3(1:elect_total) = 0;
    cdata_ch3(1:elect_total) = 0;
    fb_sel_ch3(1:elect_total) = 0;
    hold(handles.axes_ch3,'on');
    title(handles.axes_ch3,'Channel 3');
    ch3_fig(1) = plot(handles.axes_ch3, t_ch3(1,1), cdata_ch3(1,1), 'r-x');
    ch3_fig(2) = plot(handles.axes_ch3, t_ch3(1,2), cdata_ch3(1,2), 'g-x');
    ch3_fig(3) = plot(handles.axes_ch3, t_ch3(1,3), cdata_ch3(1,3), 'b-x');
    ch3_fig(4) = plot(handles.axes_ch3, t_ch3(1,4), cdata_ch3(1,4), 'c-x');
    ch3_fig(5) = plot(handles.axes_ch3, t_ch3(1,5), cdata_ch3(1,5), 'm-x');
    ch3_fig(6) = plot(handles.axes_ch3, t_ch3(1,6), cdata_ch3(1,6), 'y-x');
    ch3_fig(7) = plot(handles.axes_ch3, t_ch3(1,7), cdata_ch3(1,7), 'k-x');
    ch3_fig(8) = plot(handles.axes_ch3, t_ch3(1,8), cdata_ch3(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch3_fig(9) = plot(handles.axes_ch3, t_ch3(1,9), cdata_ch3(1,9), 'r-s');
    ch3_fig(10) = plot(handles.axes_ch3, t_ch3(1,10), cdata_ch3(1,10), 'g-s');
    ch3_fig(11) = plot(handles.axes_ch3, t_ch3(1,11), cdata_ch3(1,11), 'b-s');
    ch3_fig(12) = plot(handles.axes_ch3, t_ch3(1,12), cdata_ch3(1,12), 'c-s');
    ch3_fig(13) = plot(handles.axes_ch3, t_ch3(1,13), cdata_ch3(1,13), 'm-s');
    ch3_fig(14) = plot(handles.axes_ch3, t_ch3(1,14), cdata_ch3(1,14), 'y-s');
    ch3_fig(15) = plot(handles.axes_ch3, t_ch3(1,15), cdata_ch3(1,15), 'k-s');
    ch3_fig(16) = plot(handles.axes_ch3, t_ch3(1,16), cdata_ch3(1,16), '-s', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch3,'E1','E2','E3','E4','E5','E6','E7','E8','E9','E10','E11','E12','E13','E14','E15','E16','Location','eastoutside');

    % Channel 4
    t_ch4(1:elect_total) = 0;
    vdata_ch4(1:elect_total) = 0;
    cdata_ch4(1:elect_total) = 0;
    fb_sel_ch4(1:elect_total) = 0;
    hold(handles.axes_ch4,'on');
    title(handles.axes_ch4,'Channel 4');
    ylabel(handles.axes_ch4,'Current (A)');
    ch4_fig(1) = plot(handles.axes_ch4, t_ch4(1,1), cdata_ch4(1,1), 'r-x');
    ch4_fig(2) = plot(handles.axes_ch4, t_ch4(1,2), cdata_ch4(1,2), 'g-x');
    ch4_fig(3) = plot(handles.axes_ch4, t_ch4(1,3), cdata_ch4(1,3), 'b-x');
    ch4_fig(4) = plot(handles.axes_ch4, t_ch4(1,4), cdata_ch4(1,4), 'c-x');
    ch4_fig(5) = plot(handles.axes_ch4, t_ch4(1,5), cdata_ch4(1,5), 'm-x');
    ch4_fig(6) = plot(handles.axes_ch4, t_ch4(1,6), cdata_ch4(1,6), 'y-x');
    ch4_fig(7) = plot(handles.axes_ch4, t_ch4(1,7), cdata_ch4(1,7), 'k-x');
    ch4_fig(8) = plot(handles.axes_ch4, t_ch4(1,8), cdata_ch4(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch4_fig(9) = plot(handles.axes_ch4, t_ch4(1,9), cdata_ch4(1,9), 'r-s');
    ch4_fig(10) = plot(handles.axes_ch4, t_ch4(1,10), cdata_ch4(1,10), 'g-s');
    ch4_fig(11) = plot(handles.axes_ch4, t_ch4(1,11), cdata_ch4(1,11), 'b-s');
    ch4_fig(12) = plot(handles.axes_ch4, t_ch4(1,12), cdata_ch4(1,12), 'c-s');
    ch4_fig(13) = plot(handles.axes_ch4, t_ch4(1,13), cdata_ch4(1,13), 'm-s');
    ch4_fig(14) = plot(handles.axes_ch4, t_ch4(1,14), cdata_ch4(1,14), 'y-s');
    ch4_fig(15) = plot(handles.axes_ch4, t_ch4(1,15), cdata_ch4(1,15), 'k-s');
    ch4_fig(16) = plot(handles.axes_ch4, t_ch4(1,16), cdata_ch4(1,16), '-s', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch4,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

    % Channel 5
    t_ch5(1:elect_total) = 0;
    vdata_ch5(1:elect_total) = 0;
    cdata_ch5(1:elect_total) = 0;
    fb_sel_ch5(1:elect_total) = 0;
    hold(handles.axes_ch5,'on');
    title(handles.axes_ch5,'Channel 5');
    ch5_fig(1) = plot(handles.axes_ch5, t_ch5(1,1), cdata_ch5(1,1), 'r-x');
    ch5_fig(2) = plot(handles.axes_ch5, t_ch5(1,2), cdata_ch5(1,2), 'g-x');
    ch5_fig(3) = plot(handles.axes_ch5, t_ch5(1,3), cdata_ch5(1,3), 'b-x');
    ch5_fig(4) = plot(handles.axes_ch5, t_ch5(1,4), cdata_ch5(1,4), 'c-x');
    ch5_fig(5) = plot(handles.axes_ch5, t_ch5(1,5), cdata_ch5(1,5), 'm-x');
    ch5_fig(6) = plot(handles.axes_ch5, t_ch5(1,6), cdata_ch5(1,6), 'y-x');
    ch5_fig(7) = plot(handles.axes_ch5, t_ch5(1,7), cdata_ch5(1,7), 'k-x');
    ch5_fig(8) = plot(handles.axes_ch5, t_ch5(1,8), cdata_ch5(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch5_fig(9) = plot(handles.axes_ch5, t_ch5(1,9), cdata_ch5(1,9), 'r-s');
    ch5_fig(10) = plot(handles.axes_ch5, t_ch5(1,10), cdata_ch5(1,10), 'g-s');
    ch5_fig(11) = plot(handles.axes_ch5, t_ch5(1,11), cdata_ch5(1,11), 'b-s');
    ch5_fig(12) = plot(handles.axes_ch5, t_ch5(1,12), cdata_ch5(1,12), 'c-s');
    ch5_fig(13) = plot(handles.axes_ch5, t_ch5(1,13), cdata_ch5(1,13), 'm-s');
    ch5_fig(14) = plot(handles.axes_ch5, t_ch5(1,14), cdata_ch5(1,14), 'y-s');
    ch5_fig(15) = plot(handles.axes_ch5, t_ch5(1,15), cdata_ch5(1,15), 'k-s');
    ch5_fig(16) = plot(handles.axes_ch5, t_ch5(1,16), cdata_ch5(1,16), '-s', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch5,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
end

% initialize hexagonal 2D plot
if multi_pot == 1
    hex_rad = 2;   % hexagon radius/side length
    [hex_patch, hex_clr, hex_fill, hex_ind] = hexgrid2D(hex_rad);   % prepare grid and patches
end

% send DAC voltage value to mbed across serial port
try % Must have try-catch for fprintf otherwise will result in serial/fprintf error that terminates the code after (the write operation still successfully delivers the data)
    fprintf(mbed,'%f\n', vdac_frac); % Syntax: fprintf(obj,'format'.'cmd'). 'cmd' can be a variable without quotation, but the data type must be the same as the specifier in 'format'. Terminator \n is mandatory.
catch
    display('DAC value sent');
end

run = get(hObject,'Value'); % get run command
display('Potentiostat has started running');

timer = tic;    % start stopwatch

% sample data
while run == 1

    % synchronous data transfer
    while mbed_ready == 0   % loop if mbed is not ready
        mbed_ready = fscanf(mbed, '%hu');  % Timeout should be long enough to avoid error
    end

    mbed_ready = 0; % reset ready signal from mbed

    try 
        fwrite(mbed,pc_ready);  % send ready signal to mbed
    catch
        display(['PC Ready ',num2str(elect)]);
    end

    vdata_ch1(index, elect) = vdd*(fscanf(mbed, '%f') - 0.5);   % read ADC value from mbed and convert to voltage
    fb_sel_ch1(index, elect) = fscanf(mbed, '%hu'); % read selected feedback path from mbed
    t_ch1(index, elect) = toc(timer); % store time elapsed for each sample
    if multi_pot == 1
        vdata_ch2(index, elect) = vdd*(fscanf(mbed, '%f') - 0.5);
        fb_sel_ch2(index, elect) = fscanf(mbed, '%hu');
        t_ch2(index, elect) = toc(timer);       
        vdata_ch3(index, elect) = vdd*(fscanf(mbed, '%f') - 0.5);
        fb_sel_ch3(index, elect) = fscanf(mbed, '%hu');
        t_ch3(index, elect) = toc(timer);
        vdata_ch4(index, elect) = vdd*(fscanf(mbed, '%f') - 0.5);
        fb_sel_ch4(index, elect) = fscanf(mbed, '%hu');
        t_ch4(index, elect) = toc(timer);
        vdata_ch5(index, elect) = vdd*(fscanf(mbed, '%f') - 0.5);
        fb_sel_ch5(index, elect) = fscanf(mbed, '%hu');
        t_ch5(index, elect) = toc(timer);
    end
    
    % calculate current
    cdata_ch1(index, elect) = vdata_ch1(index, elect)/(base_gain*10^(fb_sel_ch1(index, elect)));    
    if multi_pot == 1
        cdata_ch2(index, elect) = vdata_ch2(index, elect)/(base_gain*10^(fb_sel_ch2(index, elect)));
        cdata_ch3(index, elect) = vdata_ch3(index, elect)/(base_gain*10^(fb_sel_ch3(index, elect)));
        cdata_ch4(index, elect) = vdata_ch4(index, elect)/(base_gain*10^(fb_sel_ch4(index, elect)));
        cdata_ch5(index, elect) = vdata_ch5(index, elect)/(base_gain*10^(fb_sel_ch5(index, elect)));
    end
    
    % interactive hexagonal grid (show selected electrodes' responses)
    if HL == 1
        HL = 0;
        earray(hlc(1),hlc(2)) = hlc(3);
        switch hlc(1)
            case 1
                hl_ch = ch1_fig;
            case 2
                hl_ch = ch2_fig;
            case 3
                hl_ch = ch3_fig;
            case 4
                hl_ch = ch4_fig;
            case 5
                hl_ch = ch5_fig;
        end
        if any(earray(hlc(1),:)) == 1
            % turn off all except selected electrode
            if length(find(earray(hlc(1),:) == 1)) == 1
                set(hl_ch(find(earray(hlc(1),:) == 0)),'Visible','off');
            else
                state = 'off';
                if hlc(3) == 1
                    state = 'on';
                end
                set(hl_ch(hlc(2)),'Visible',state);
            end
        else
            % if no electrodes selected, turn on all
            set(hl_ch(1:elect_total),'Visible','on');
        end
    end
    
    % update new x- and y-axis values
    set(ch1_fig(elect), 'XData', t_ch1(start:end, elect), 'YData', cdata_ch1(start:end, elect));
    if multi_pot == 1
        set(ch2_fig(elect), 'XData', t_ch2(start:end, elect), 'YData', cdata_ch2(start:end, elect));
        set(ch3_fig(elect), 'XData', t_ch3(start:end, elect), 'YData', cdata_ch3(start:end, elect));
        set(ch4_fig(elect), 'XData', t_ch4(start:end, elect), 'YData', cdata_ch4(start:end, elect));
        set(ch5_fig(elect), 'XData', t_ch5(start:end, elect), 'YData', cdata_ch5(start:end, elect));
    end
    
    % update data values for colored hexagonal grid
    if multi_pot == 1
        hex_clr(hex_ind(:,elect)) = [cdata_ch1(index, elect);...
                                     cdata_ch2(index, elect);...
                                     cdata_ch3(index, elect);...
                                     cdata_ch4(index, elect);...
                                     cdata_ch5(index, elect)];
        set(hex_patch,'FaceVertexCData',hex_clr(hex_fill));
    end
    
    drawnow;    % updates figure
    
    elect = elect + 1;  % increment electrode

    % when "Stop" button is pressed
    if get(handles.stopclear,'Value') == 1
        set(handles.stopclear,'String','Clear');
        set(handles.stopclear,'TooltipString','Clear all figures and data');
        set(handles.savedata,'Enable','on');
        break;  % break out of while loop
    end   

    if elect > elect_total
        elect = 1;  % return to first electrode
        index = index + 1;  % increment data sample count
        frame_index = frame_index + 1;  % increment frame index
        start = max(1,frame_index);   % starting index of data to be plotted
    end     
end

% display complete data on figures
for i = 1:elect_total
    if i < elect
        set(ch1_fig(i), 'XData', t_ch1(:, i), 'YData', cdata_ch1(:, i));
        if multi_pot == 1
            set(ch2_fig(i), 'XData', t_ch2(:, i), 'YData', cdata_ch2(:, i));
            set(ch3_fig(i), 'XData', t_ch3(:, i), 'YData', cdata_ch3(:, i));
            set(ch4_fig(i), 'XData', t_ch4(:, i), 'YData', cdata_ch4(:, i));
            set(ch5_fig(i), 'XData', t_ch5(:, i), 'YData', cdata_ch5(:, i));   
        end
    else
        set(ch1_fig(i), 'XData', t_ch1(1:end-1, i), 'YData', cdata_ch1(1:end-1, i));
        if multi_pot == 1
            set(ch2_fig(i), 'XData', t_ch2(1:end-1, i), 'YData', cdata_ch2(1:end-1, i));
            set(ch3_fig(i), 'XData', t_ch3(1:end-1, i), 'YData', cdata_ch3(1:end-1, i));
            set(ch4_fig(i), 'XData', t_ch4(1:end-1, i), 'YData', cdata_ch4(1:end-1, i));
            set(ch5_fig(i), 'XData', t_ch5(1:end-1, i), 'YData', cdata_ch5(1:end-1, i));
        end
    end
end

hold(handles.axes_ch1,'off');
if multi_pot == 1
    hold(handles.axes_ch2,'off');
    hold(handles.axes_ch3,'off');
    hold(handles.axes_ch4,'off');
    hold(handles.axes_ch5,'off');
end

display('Potentiostat has stopped running');

% save data variables in handles
handles.t_ch1_save = t_ch1;
handles.vdata_ch1_save = vdata_ch1;
handles.cdata_ch1_save = cdata_ch1;
handles.fb_sel_ch1_save = fb_sel_ch1;

if multi_pot == 1
    handles.t_ch2_save = t_ch2;
    handles.vdata_ch2_save = vdata_ch2;
    handles.cdata_ch2_save = cdata_ch2;
    handles.fb_sel_ch2_save = fb_sel_ch2;

    handles.t_ch3_save = t_ch3;
    handles.vdata_ch3_save = vdata_ch3;
    handles.cdata_ch3_save = cdata_ch3;
    handles.fb_sel_ch3_save = fb_sel_ch3;

    handles.t_ch4_save = t_ch4;
    handles.vdata_ch4_save = vdata_ch4;
    handles.cdata_ch4_save = cdata_ch4;
    handles.fb_sel_ch4_save = fb_sel_ch4;

    handles.t_ch5_save = t_ch5;
    handles.vdata_ch5_save = vdata_ch5;
    handles.cdata_ch5_save = cdata_ch5;
    handles.fb_sel_ch5_save = fb_sel_ch5;
end

guidata(hObject, handles);  % save handles

% Close mbed
fclose(mbed);
delete(mbed);

end

% --- Executes on slider movement.
function dac_slider_Callback(hObject, eventdata, handles)
% hObject    handle to dac_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global vdd; % supply voltage (could vary depending on the device connected)
vdd = 3.3;    % Laptop: 3.125; PC: 3.350

handles.slider = get(hObject,'Value');  % get dac_slider value
vdac = handles.slider*vdd/1023; % DAC voltage (resolution set to 10 bits)
display(handles.slider);
display(vdac/vdd);
vred = vdac - vdd/2;   % redox voltage
set(handles.vdac_val, 'String', num2str(vdac)); % display vdac value
set(handles.vred_val, 'String', num2str(vred)); % display vred value
guidata(hObject, handles);  % save handles
end
% --- Executes during object creation, after setting all properties.
function dac_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
end
% --- Executes on button press in exp_img.
function exp_img_Callback(hObject, eventdata, handles)
% hObject    handle to exp_img (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of exp_img

[filename, pathname] = uiputfile('*.fig', 'Save Figure');  % open dialog for saving files
if isequal(filename,0) || isequal(pathname,0)
    disp('User selected Cancel');
else
    file = fullfile(pathname,filename); % build full file name
    warning('off','MATLAB:print:CustomResizeFcnInPrint');   % suppress warning
    if isfield(handles,'exp_sel')
        if strcmp(handles.exp_sel,'exp_gui');
            savefig(gcf,file);   % save entire gui figure window
        else
            fig = figure;   % create new figure
            set(fig,'Visible','off');   % prevent figure from popping up
            switch handles.exp_sel  % only exists if selected object changes
                case 'exp_fig1'
                    copyobj(handles.axes_ch1, fig); % copies axes to figure
                case 'exp_fig2'
                    copyobj(handles.axes_ch2, fig); % copies axes to figure
                case 'exp_fig3'
                    copyobj(handles.axes_ch3, fig); % copies axes to figure
                case 'exp_fig4'
                    copyobj(handles.axes_ch4, fig); % copies axes to figure
                case 'exp_fig5'
                    copyobj(handles.axes_ch5, fig); % copies axes to figure
            end
            set(gca,'Units','normalized','Position',[0.1300 0.1100 0.7750 0.8150]); % set axes position in figure
            set(fig,'ResizeFcn','set(gcf,''visible'',''on'')'); % enable figure visibility property (otherwise double-clicking file will not display)
            savefig(fig,file);  % save figure
        end
    else
        savefig(gcf,file);  % default action
    end
    
    %{
    if isempty(img.colormap)
        imwrite(img.cdata,file); % RGB images
    else
        imwrite(img.cdata,img.colormap,file); % indexed images
    end
    %}
    
    disp(['User saved file: ',file]);
end
end

% --- Executes when selected object is changed in exp_buttons.
function exp_buttons_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in exp_buttons 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles.exp_sel = get(hObject,'Tag');
display(handles.exp_sel);
guidata(hObject,handles);
end

% --- Executes on button press in loaddata.
function loaddata_Callback(hObject, eventdata, handles)
% hObject    handle to loaddata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loaddata

[filename, pathname] = uigetfile('*.mat', 'Load Data File');  % open dialog for saving files
if isequal(filename,0) || isequal(pathname,0)
    disp('User selected Cancel');
else
    file = fullfile(pathname,filename); % build full file name
    handles.loadfile = file;
    load(file,'t_ch*','cdata_ch*'); % load variables to be plotted from data file
    disp(['User opened file: ',file]);
    
    % display error message if invalid file was loaded
    try
        nodata = find(any(t_ch1 == 0)); % returns column numbers of zero elements in last row
        elect_total = size(t_ch1,2);
        if isempty(nodata)
            nodata = elect_total + 1;
        else
            nodata = nodata(1);
        end

        multi_datafile = exist('t_ch2','var');   % datafile: multi if 1; single if 0
        % set pop-up content based on loaded file
        if multi_datafile == 1
            set(handles.ch_popup,'String',{'CH1';'CH2';'CH3';'CH4';'CH5'});
            set(handles.elect_popup,'String',{'E1';'E2';'E3';'E4';'E5';'E6';'E7';'E8';'E9';'E10';'E11';'E12';'E13';'E14';'E15';'E16'});
        else
            set(handles.ch_popup,'String',{'CH1'});
            set(handles.elect_popup,'String',{'E1';'E2';'E3';'E4';'E5';'E6';'E7';'E8'});
        end

        % initialize plots
        % Channel 1
        hold(handles.axes_ch1,'on');
        title(handles.axes_ch1,'Channel 1');
        ylabel(handles.axes_ch1,'Current (A)');
        ch1_fig(1) = plot(handles.axes_ch1, t_ch1(1,1), cdata_ch1(1,1), 'r-x');
        ch1_fig(2) = plot(handles.axes_ch1, t_ch1(1,2), cdata_ch1(1,2), 'g-x');
        ch1_fig(3) = plot(handles.axes_ch1, t_ch1(1,3), cdata_ch1(1,3), 'b-x');
        ch1_fig(4) = plot(handles.axes_ch1, t_ch1(1,4), cdata_ch1(1,4), 'c-x');
        ch1_fig(5) = plot(handles.axes_ch1, t_ch1(1,5), cdata_ch1(1,5), 'm-x');
        ch1_fig(6) = plot(handles.axes_ch1, t_ch1(1,6), cdata_ch1(1,6), 'y-x');
        ch1_fig(7) = plot(handles.axes_ch1, t_ch1(1,7), cdata_ch1(1,7), 'k-x');
        ch1_fig(8) = plot(handles.axes_ch1, t_ch1(1,8), cdata_ch1(1,8), '-x', 'Color', [0.5,0.5,0.5]);
        if multi_datafile == 1
            ch1_fig(9) = plot(handles.axes_ch1, t_ch1(1,9), cdata_ch1(1,9), 'r-s');
            ch1_fig(10) = plot(handles.axes_ch1, t_ch1(1,10), cdata_ch1(1,10), 'g-s');
            ch1_fig(11) = plot(handles.axes_ch1, t_ch1(1,11), cdata_ch1(1,11), 'b-s');
            ch1_fig(12) = plot(handles.axes_ch1, t_ch1(1,12), cdata_ch1(1,12), 'c-s');
            ch1_fig(13) = plot(handles.axes_ch1, t_ch1(1,13), cdata_ch1(1,13), 'm-s');
            ch1_fig(14) = plot(handles.axes_ch1, t_ch1(1,14), cdata_ch1(1,14), 'y-s');
            ch1_fig(15) = plot(handles.axes_ch1, t_ch1(1,15), cdata_ch1(1,15), 'k-s');
            ch1_fig(16) = plot(handles.axes_ch1, t_ch1(1,16), cdata_ch1(1,16), '-s', 'Color', [0.5,0.5,0.5]);
            %legend(handles.axes_ch1,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');    

            % Channel 2
            hold(handles.axes_ch2,'on');
            title(handles.axes_ch2,'Channel 2');
            ch2_fig(1) = plot(handles.axes_ch2, t_ch2(1,1), cdata_ch2(1,1), 'r-x');
            ch2_fig(2) = plot(handles.axes_ch2, t_ch2(1,2), cdata_ch2(1,2), 'g-x');
            ch2_fig(3) = plot(handles.axes_ch2, t_ch2(1,3), cdata_ch2(1,3), 'b-x');
            ch2_fig(4) = plot(handles.axes_ch2, t_ch2(1,4), cdata_ch2(1,4), 'c-x');
            ch2_fig(5) = plot(handles.axes_ch2, t_ch2(1,5), cdata_ch2(1,5), 'm-x');
            ch2_fig(6) = plot(handles.axes_ch2, t_ch2(1,6), cdata_ch2(1,6), 'y-x');
            ch2_fig(7) = plot(handles.axes_ch2, t_ch2(1,7), cdata_ch2(1,7), 'k-x');
            ch2_fig(8) = plot(handles.axes_ch2, t_ch2(1,8), cdata_ch2(1,8), '-x', 'Color', [0.5,0.5,0.5]);
            ch2_fig(9) = plot(handles.axes_ch2, t_ch2(1,9), cdata_ch1(1,9), 'r-s');
            ch2_fig(10) = plot(handles.axes_ch2, t_ch2(1,10), cdata_ch2(1,10), 'g-s');
            ch2_fig(11) = plot(handles.axes_ch2, t_ch2(1,11), cdata_ch2(1,11), 'b-s');
            ch2_fig(12) = plot(handles.axes_ch2, t_ch2(1,12), cdata_ch2(1,12), 'c-s');
            ch2_fig(13) = plot(handles.axes_ch2, t_ch2(1,13), cdata_ch2(1,13), 'm-s');
            ch2_fig(14) = plot(handles.axes_ch2, t_ch2(1,14), cdata_ch2(1,14), 'y-s');
            ch2_fig(15) = plot(handles.axes_ch2, t_ch2(1,15), cdata_ch2(1,15), 'k-s');
            ch2_fig(16) = plot(handles.axes_ch2, t_ch2(1,16), cdata_ch2(1,16), '-s', 'Color', [0.5,0.5,0.5]);
            %legend(handles.axes_ch2,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

            % Channel 3
            hold(handles.axes_ch3,'on');
            title(handles.axes_ch3,'Channel 3');
            ch3_fig(1) = plot(handles.axes_ch3, t_ch3(1,1), cdata_ch3(1,1), 'r-x');
            ch3_fig(2) = plot(handles.axes_ch3, t_ch3(1,2), cdata_ch3(1,2), 'g-x');
            ch3_fig(3) = plot(handles.axes_ch3, t_ch3(1,3), cdata_ch3(1,3), 'b-x');
            ch3_fig(4) = plot(handles.axes_ch3, t_ch3(1,4), cdata_ch3(1,4), 'c-x');
            ch3_fig(5) = plot(handles.axes_ch3, t_ch3(1,5), cdata_ch3(1,5), 'm-x');
            ch3_fig(6) = plot(handles.axes_ch3, t_ch3(1,6), cdata_ch3(1,6), 'y-x');
            ch3_fig(7) = plot(handles.axes_ch3, t_ch3(1,7), cdata_ch3(1,7), 'k-x');
            ch3_fig(8) = plot(handles.axes_ch3, t_ch3(1,8), cdata_ch3(1,8), '-x', 'Color', [0.5,0.5,0.5]);
            ch3_fig(9) = plot(handles.axes_ch3, t_ch3(1,9), cdata_ch3(1,9), 'r-s');
            ch3_fig(10) = plot(handles.axes_ch3, t_ch3(1,10), cdata_ch3(1,10), 'g-s');
            ch3_fig(11) = plot(handles.axes_ch3, t_ch3(1,11), cdata_ch3(1,11), 'b-s');
            ch3_fig(12) = plot(handles.axes_ch3, t_ch3(1,12), cdata_ch3(1,12), 'c-s');
            ch3_fig(13) = plot(handles.axes_ch3, t_ch3(1,13), cdata_ch3(1,13), 'm-s');
            ch3_fig(14) = plot(handles.axes_ch3, t_ch3(1,14), cdata_ch3(1,14), 'y-s');
            ch3_fig(15) = plot(handles.axes_ch3, t_ch3(1,15), cdata_ch3(1,15), 'k-s');
            ch3_fig(16) = plot(handles.axes_ch3, t_ch3(1,16), cdata_ch3(1,16), '-s', 'Color', [0.5,0.5,0.5]);
            %legend(handles.axes_ch3,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

            % Channel 4
            hold(handles.axes_ch4,'on');
            title(handles.axes_ch4,'Channel 4');
            ylabel(handles.axes_ch4,'Current (A)');
            ch4_fig(1) = plot(handles.axes_ch4, t_ch4(1,1), cdata_ch4(1,1), 'r-x');
            ch4_fig(2) = plot(handles.axes_ch4, t_ch4(1,2), cdata_ch4(1,2), 'g-x');
            ch4_fig(3) = plot(handles.axes_ch4, t_ch4(1,3), cdata_ch4(1,3), 'b-x');
            ch4_fig(4) = plot(handles.axes_ch4, t_ch4(1,4), cdata_ch4(1,4), 'c-x');
            ch4_fig(5) = plot(handles.axes_ch4, t_ch4(1,5), cdata_ch4(1,5), 'm-x');
            ch4_fig(6) = plot(handles.axes_ch4, t_ch4(1,6), cdata_ch4(1,6), 'y-x');
            ch4_fig(7) = plot(handles.axes_ch4, t_ch4(1,7), cdata_ch4(1,7), 'k-x');
            ch4_fig(8) = plot(handles.axes_ch4, t_ch4(1,8), cdata_ch4(1,8), '-x', 'Color', [0.5,0.5,0.5]);
            ch4_fig(9) = plot(handles.axes_ch4, t_ch4(1,9), cdata_ch4(1,9), 'r-s');
            ch4_fig(10) = plot(handles.axes_ch4, t_ch4(1,10), cdata_ch4(1,10), 'g-s');
            ch4_fig(11) = plot(handles.axes_ch4, t_ch4(1,11), cdata_ch4(1,11), 'b-s');
            ch4_fig(12) = plot(handles.axes_ch4, t_ch4(1,12), cdata_ch4(1,12), 'c-s');
            ch4_fig(13) = plot(handles.axes_ch4, t_ch4(1,13), cdata_ch4(1,13), 'm-s');
            ch4_fig(14) = plot(handles.axes_ch4, t_ch4(1,14), cdata_ch4(1,14), 'y-s');
            ch4_fig(15) = plot(handles.axes_ch4, t_ch4(1,15), cdata_ch4(1,15), 'k-s');
            ch4_fig(16) = plot(handles.axes_ch4, t_ch4(1,16), cdata_ch4(1,16), '-s', 'Color', [0.5,0.5,0.5]);
            %legend(handles.axes_ch4,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');

            % Channel 5
            hold(handles.axes_ch5,'on');
            title(handles.axes_ch5,'Channel 5');
            ch5_fig(1) = plot(handles.axes_ch5, t_ch5(1,1), cdata_ch5(1,1), 'r-x');
            ch5_fig(2) = plot(handles.axes_ch5, t_ch5(1,2), cdata_ch5(1,2), 'g-x');
            ch5_fig(3) = plot(handles.axes_ch5, t_ch5(1,3), cdata_ch5(1,3), 'b-x');
            ch5_fig(4) = plot(handles.axes_ch5, t_ch5(1,4), cdata_ch5(1,4), 'c-x');
            ch5_fig(5) = plot(handles.axes_ch5, t_ch5(1,5), cdata_ch5(1,5), 'm-x');
            ch5_fig(6) = plot(handles.axes_ch5, t_ch5(1,6), cdata_ch5(1,6), 'y-x');
            ch5_fig(7) = plot(handles.axes_ch5, t_ch5(1,7), cdata_ch5(1,7), 'k-x');
            ch5_fig(8) = plot(handles.axes_ch5, t_ch5(1,8), cdata_ch5(1,8), '-x', 'Color', [0.5,0.5,0.5]);
            ch5_fig(9) = plot(handles.axes_ch5, t_ch5(1,9), cdata_ch5(1,9), 'r-s');
            ch5_fig(10) = plot(handles.axes_ch5, t_ch5(1,10), cdata_ch5(1,10), 'g-s');
            ch5_fig(11) = plot(handles.axes_ch5, t_ch5(1,11), cdata_ch5(1,11), 'b-s');
            ch5_fig(12) = plot(handles.axes_ch5, t_ch5(1,12), cdata_ch5(1,12), 'c-s');
            ch5_fig(13) = plot(handles.axes_ch5, t_ch5(1,13), cdata_ch5(1,13), 'm-s');
            ch5_fig(14) = plot(handles.axes_ch5, t_ch5(1,14), cdata_ch5(1,14), 'y-s');
            ch5_fig(15) = plot(handles.axes_ch5, t_ch5(1,15), cdata_ch5(1,15), 'k-s');
            ch5_fig(16) = plot(handles.axes_ch5, t_ch5(1,16), cdata_ch5(1,16), '-s', 'Color', [0.5,0.5,0.5]);
            %legend(handles.axes_ch5,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
        end

        % display complete data on figures
        for i = 1:size(t_ch1,2)
            if i < nodata
                set(ch1_fig(i), 'XData', t_ch1(:, i), 'YData', cdata_ch1(:, i));
                if multi_datafile == 1
                    set(ch2_fig(i), 'XData', t_ch2(:, i), 'YData', cdata_ch2(:, i));
                    set(ch3_fig(i), 'XData', t_ch3(:, i), 'YData', cdata_ch3(:, i));
                    set(ch4_fig(i), 'XData', t_ch4(:, i), 'YData', cdata_ch4(:, i));
                    set(ch5_fig(i), 'XData', t_ch5(:, i), 'YData', cdata_ch5(:, i));
                end
            else
                set(ch1_fig(i), 'XData', t_ch1(1:end-1, i), 'YData', cdata_ch1(1:end-1, i));
                if multi_datafile == 1
                    set(ch2_fig(i), 'XData', t_ch2(1:end-1, i), 'YData', cdata_ch2(1:end-1, i));
                    set(ch3_fig(i), 'XData', t_ch3(1:end-1, i), 'YData', cdata_ch3(1:end-1, i));
                    set(ch4_fig(i), 'XData', t_ch4(1:end-1, i), 'YData', cdata_ch4(1:end-1, i));
                    set(ch5_fig(i), 'XData', t_ch5(1:end-1, i), 'YData', cdata_ch5(1:end-1, i));          
                end
            end
        end

        hold(handles.axes_ch1,'off');
        if multi_datafile == 1
            hold(handles.axes_ch2,'off');
            hold(handles.axes_ch3,'off');
            hold(handles.axes_ch4,'off');
            hold(handles.axes_ch5,'off');
        end
        
        % initialize hexagonal 2D plot
        if multi_datafile == 1
            hex_rad = 2;   % hexagon radius/side length
            [hex_patch, hex_clr, hex_fill, hex_ind] = hexgrid2D(hex_rad);   % prepare grid and patches
            
            index = size(t_ch1,1);
            hex_clr(hex_ind) = [cdata_ch1(index, 1:nodata-1) cdata_ch1(index-1, nodata:elect_total);...
                                         cdata_ch2(index, 1:nodata-1) cdata_ch2(index-1, nodata:elect_total);...
                                         cdata_ch3(index, 1:nodata-1) cdata_ch3(index-1, nodata:elect_total);...
                                         cdata_ch4(index, 1:nodata-1) cdata_ch4(index-1, nodata:elect_total);...
                                         cdata_ch5(index, 1:nodata-1) cdata_ch5(index-1, nodata:elect_total)];
            set(hex_patch,'FaceVertexCData',hex_clr(hex_fill));
        end
        
%         set(ch1_fig(1:16),'Visible','off');
%         set(ch2_fig(1:16),'Visible','off');
%         set(ch3_fig(1:16),'Visible','off');
%         set(ch4_fig(1:16),'Visible','off');
%         set(ch5_fig(1:16),'Visible','off');
%         
%         set(ch1_fig([11 16]),'Visible','on');
%         set(ch2_fig([3 10]),'Visible','on');
%         set(ch3_fig(4),'Visible','on');
%         set(ch4_fig([12 15]),'Visible','on');
%         set(ch5_fig([2 5 6]),'Visible','on');

        % update GUI settings
        set(hObject,'Enable','off');
        set(handles.run_pot,'Enable','off');
        set(handles.stopclear,'Enable','on');
        set(handles.stopclear,'Value',1);
        set(handles.stopclear,'String','Clear');
        set(handles.stopclear,'TooltipString','Clear all figures and data');
        set(handles.vdac_val,'Enable','off');
        set(handles.vred_val,'Enable','off');
        set(handles.frame_val,'Enable','off');
        set(handles.dac_slider,'Enable','off');
        set(handles.ch_popup,'Enable','on');
        set(handles.elect_popup,'Enable','on');
        set(handles.plot_1E,'Enable','on');

        guidata(hObject,handles);
    catch
        display('Invalid file: cannot load data');
    end
end
end

function vdac_val_Callback(hObject, eventdata, handles)
% hObject    handle to vdac_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vdac_val as text
%        str2double(get(hObject,'String')) returns contents of vdac_val as a double

global vdd;

handles.slider = round(str2double(get(hObject,'String'))*1023/vdd); % get dac_slider value (round to nearest integer)
set(handles.dac_slider,'Value',handles.slider); % set dac_slider value and position
guidata(hObject, handles);  % save handles
dac_slider_Callback(handles.dac_slider, eventdata, handles); % call dac_slider_Callback to update vdac and vred
end
% --- Executes during object creation, after setting all properties.
function vdac_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vdac_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function vred_val_Callback(hObject, eventdata, handles)
% hObject    handle to vred_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vred_val as text
%        str2double(get(hObject,'String')) returns contents of vred_val as a double

global vdd;

handles.slider = round((str2double(get(hObject,'String')) + vdd/2)*1023/vdd);  % get dac_slider value (round to nearest integer)
set(handles.dac_slider,'Value',handles.slider); % set dac_slider value and position
guidata(hObject, handles);  % save handles
dac_slider_Callback(handles.dac_slider, eventdata, handles); % call dac_slider_Callback to update vdac and vred
end
% --- Executes during object creation, after setting all properties.
function vred_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vred_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of close
close all;
end

% --- Executes on button press in stopclear.
function stopclear_Callback(hObject, eventdata, handles)
% hObject    handle to stopclear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stopclear

if get(hObject,'Value') == 0
    
    % clear figures and workspace variables
    cla(handles.axes_ch1);
    cla(handles.axes_ch2);
    cla(handles.axes_ch3);
    cla(handles.axes_ch4);
    cla(handles.axes_ch5);
    evalin('base', 'clear');
    evalin('base', 'clc');
    
    % remove data fields
    if isfield(handles,'t_ch1_save')
        if isfield(handles,'t_ch2_save')
            handles = rmfield(handles,{'t_ch1_save','t_ch2_save','t_ch3_save','t_ch4_save','t_ch5_save', ... 
                'vdata_ch1_save','vdata_ch2_save','vdata_ch3_save','vdata_ch4_save','vdata_ch5_save', ...
                'cdata_ch1_save','cdata_ch2_save','cdata_ch3_save','cdata_ch4_save','cdata_ch5_save', ...
                'fb_sel_ch1_save','fb_sel_ch2_save','fb_sel_ch3_save','fb_sel_ch4_save','fb_sel_ch5_save'});
        else
            handles = rmfield(handles,{'t_ch1_save','vdata_ch1_save','cdata_ch1_save','fb_sel_ch1_save'});
        end
    end
    
    display('Data has been cleared');
    
    % reset GUI settings
    set(hObject,'String','Stop');
    set(hObject,'Enable','off');
    set(hObject,'TooltipString','Stop the potentiostat');
    set(handles.savedata,'Enable','off');
    set(handles.run_pot,'Enable','on');
    set(handles.vdac_val,'Enable','on');
    set(handles.vred_val,'Enable','on');
    set(handles.frame_val,'Enable','on');
    set(handles.dac_slider,'Enable','on');
    set(handles.loaddata,'Enable','on');
    set(handles.ch_popup,'Enable','off');
    set(handles.elect_popup,'Enable','off');
    set(handles.plot_1E,'Enable','off');
    set(handles.pot_multi,'Enable','on');
    set(handles.pot_single,'Enable','on');
    
    guidata(hObject, handles);  % save handles
end
end
% --- Executes on button press in savedata.
function savedata_Callback(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t_ch1 = handles.t_ch1_save;
vdata_ch1 = handles.vdata_ch1_save;
cdata_ch1 = handles.cdata_ch1_save;
fb_sel_ch1 = handles.fb_sel_ch1_save;

if get(handles.pot_multi,'Value') == 1
    t_ch2 = handles.t_ch2_save;
    vdata_ch2 = handles.vdata_ch2_save;
    cdata_ch2 = handles.cdata_ch2_save;
    fb_sel_ch2 = handles.fb_sel_ch2_save;

    t_ch3 = handles.t_ch3_save;
    vdata_ch3 = handles.vdata_ch3_save;
    cdata_ch3 = handles.cdata_ch3_save;
    fb_sel_ch3 = handles.fb_sel_ch3_save;

    t_ch4 = handles.t_ch4_save;
    vdata_ch4 = handles.vdata_ch4_save;
    cdata_ch4 = handles.cdata_ch4_save;
    fb_sel_ch4 = handles.fb_sel_ch4_save;

    t_ch5 = handles.t_ch5_save;
    vdata_ch5 = handles.vdata_ch5_save;
    cdata_ch5 = handles.cdata_ch5_save;
    fb_sel_ch5 = handles.fb_sel_ch5_save;
    
    uisave({'t_ch1','t_ch2','t_ch3','t_ch4','t_ch5', ... 
        'vdata_ch1','vdata_ch2','vdata_ch3','vdata_ch4','vdata_ch5', ...
        'cdata_ch1','cdata_ch2','cdata_ch3','cdata_ch4','cdata_ch5', ...
        'fb_sel_ch1','fb_sel_ch2','fb_sel_ch3','fb_sel_ch4','fb_sel_ch5'}, ... 
        'datafile_multi');    % save variables (cannot directly call structure fields)
else
    uisave({'t_ch1','vdata_ch1','cdata_ch1','fb_sel_ch1'},'datafile_single');
end
    
display('Data has been saved');
end

function frame_val_Callback(hObject, eventdata, handles)
% hObject    handle to frame_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_val as text
%        str2double(get(hObject,'String')) returns contents of frame_val as a double
end

% --- Executes during object creation, after setting all properties.
function frame_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
% --- Executes on button press in elect_map.
function elect_map_Callback(hObject, eventdata, handles)
% hObject    handle to elect_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure; % open new figure window
warning('off','images:initSize:adjustingMag');  % suppress image too big warning
if get(handles.pot_multi,'Value') == 1
    imshow('MEA-layout-multi.JPG'); % display electrode map for multi-channel potentiostat
else
    imshow('MEA-layout-single.JPG');    % display electrode map for single-channel potentiostat
end
end
% --- Executes on selection change in ch_popup.
function ch_popup_Callback(hObject, eventdata, handles)
% hObject    handle to ch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ch_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ch_popup
end

% --- Executes during object creation, after setting all properties.
function ch_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on selection change in elect_popup.
function elect_popup_Callback(hObject, eventdata, handles)
% hObject    handle to elect_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elect_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elect_popup
end

% --- Executes during object creation, after setting all properties.
function elect_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elect_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on button press in plot_1E.
function plot_1E_Callback(hObject, eventdata, handles)
% hObject    handle to plot_1E (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = handles.loadfile;
load(file,'t_ch*','cdata_ch*'); % load variables to be plotted from data file
ch_num = get(handles.ch_popup,'Value'); % get selected channel number
elect_num = get(handles.elect_popup,'Value');   % get selected electrode number

% set plot style
switch elect_num
    case 1
        plot_style = 'r-x';
    case 2
        plot_style = 'g-x';
    case 3
        plot_style = 'b-x';
    case 4
        plot_style = 'c-x';
    case 5
        plot_style = 'm-x';
    case 6
        plot_style = 'y-x';
    case 7
        plot_style = 'k-x';
    case 8
        plot_style = 'k-d'; % black diamond instead of grey-x
    case 9
        plot_style = 'r-s';
    case 10
        plot_style = 'g-s';
    case 11
        plot_style = 'b-s';
    case 12
        plot_style = 'c-s';
    case 13
        plot_style = 'm-s';
    case 14
        plot_style = 'y-s';
    case 15
        plot_style = 'k-s';
    case 16
        plot_style = 'k-o'; % black circle instead of grey-s
end

nodata = find(any(t_ch1(:,elect_num) == 0));    % if empty array, all data valid; else last row is 0

figure('Color',[1 1 1]); % open new figure window
% plot selected electrode
switch ch_num
    case 1
        if isempty(nodata)
            plot(t_ch1(:,elect_num), cdata_ch1(:,elect_num), plot_style);
        else
            plot(t_ch1(1:end-1,elect_num), cdata_ch1(1:end-1,elect_num), plot_style);
        end
    case 2
        if isempty(nodata)
            plot(t_ch2(:,elect_num), cdata_ch2(:,elect_num), plot_style);
        else
            plot(t_ch2(1:end-1,elect_num), cdata_ch2(1:end-1,elect_num), plot_style);
        end
    case 3
        if isempty(nodata)
            plot(t_ch3(:,elect_num), cdata_ch3(:,elect_num), plot_style);
        else
            plot(t_ch3(1:end-1,elect_num), cdata_ch3(1:end-1,elect_num), plot_style);
        end
    case 4
        if isempty(nodata)
            plot(t_ch4(:,elect_num), cdata_ch4(:,elect_num), plot_style);
        else
            plot(t_ch4(1:end-1,elect_num), cdata_ch4(1:end-1,elect_num), plot_style);
        end
    case 5
        if isempty(nodata)
            plot(t_ch5(:,elect_num), cdata_ch5(:,elect_num), plot_style);
        else
            plot(t_ch5(1:end-1,elect_num), cdata_ch5(1:end-1,elect_num), plot_style);
        end
end

title_str = ['Channel ', num2str(ch_num), ' Electrode ', num2str(elect_num)];
title(title_str, 'FontSize', 20);   % add title
xlabel('Time (s)', 'FontSize', 20);
ylabel('Current (A)', 'FontSize', 20);  % add axis labels
set(gca, 'FontSize', 20);
end
% --- Executes when selected object is changed in pot_sel.
function pot_sel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in pot_sel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
end

% Hexagonal grid of biosensor for 2D amperometry visualization
function [patchHndl,cHex,cHexFill,indHex] = hexgrid2D(rHex)
% ------------------------ prepare hexagonal grid ------------------------

% define grid boundaries
xLim = [0 12*rHex*sqrt(3)];
yLim = [-0.5*rHex 17*rHex];

xrow1 = xLim(1)+sqrt(3)/2*rHex:sqrt(3)*rHex:xLim(2)+sqrt(3)/2*rHex;	% 1st row of hexagon center x-values
xrow2 = xLim(1):sqrt(3)*rHex:xLim(2);   % 2nd row of hexagon center x-values

% make sure lengths are equal
if length(xrow1) > length(xrow2)
    xrow1 = xrow1(1:end-1);
elseif length(xrow2) > length(xrow1)
    xrow2 = xrow2(1:end-1);
end

yrow1 = yLim(1):3/2*rHex:yLim(2);   % hexagon center y-values

xgrid = repmat([xrow2;xrow1],floor(length(yrow1)/2),1); % create grid of hexagon center x-values

% odd yrow1 index corresponds to xrow1; even index to xrow2
if mod(length(yrow1),2) == 1
    xgrid = [xrow1; xgrid];	% add xrow1 to xgrid if yrow1 index is odd
end

ygrid = repmat(yrow1(1:size(xgrid,1))',1,length(xrow1));    % create grid of hexagon center y-values

% convert grid to single column vector
xHex = xgrid(:);
yHex = ygrid(:);

% set electrode locations
cHex = NaN(size(xHex));
eind = [18:20 28:34 38:48 50:60 62:72 74:84 86:96 98:108 111:119 125:129 139];  % electrode indices
cHex(eind,1) = 0;

% distinguish empty and filled hexagons
cHexEmpt = isnan(cHex);
cHexFill = ~isnan(cHex);

cHex([18:20 38 48 96 98 108 126 128 139]) = NaN;    % disable unconnected electrodes

% ---------------------------- prepare patches ----------------------------

% counter-clockwise from bottom-left vertex (last = 1st to close hexagon)
vertHexX=[-sqrt(3)/2*rHex   0       +sqrt(3)/2*rHex +sqrt(3)/2*rHex     0       -sqrt(3)/2*rHex     -sqrt(3)/2*rHex ];
vertHexY=[-rHex/2           -rHex   -rHex/2         +rHex/2             +rHex   +rHex/2             -rHex/2         ];
vertHexX = repmat(vertHexX,length(xHex),1); vertHexX = vertHexX(:);
vertHexY = repmat(vertHexY,length(yHex),1); vertHexY = vertHexY(:);

% create all vertices on grid
vertX = repmat(xHex,7,1) + vertHexX;
vertY = repmat(yHex,7,1) + vertHexY;

% create all faces on grid
faces = 0:length(xHex):length(xHex)*(7-1);
faces = repmat(faces,length(xHex),1);
faces = repmat((1:length(xHex))',1,7) + faces;

faces(cHexEmpt,:) = []; % eliminate empty faces

figure;
colormap parula;   % set colormap (default is parula)
box on; axis equal;
% set axis limits
xlim([xLim(1)+sqrt(3)/2*rHex xLim(2)-sqrt(3)/2*rHex]);
ylim([yLim(1)+0.5*rHex yLim(2)]);
patchHndl = patch('Faces',faces,'Vertices',[vertX vertY]);

% create electrode text labels
etext = cellstr(['NC   ';'NC   ';'NC   ';...    % 18-20
                 'C3E1 ';'C3E8 ';'C3E7 ';'C3E5 ';'C3E10';'C3E9 ';'C3E11';...    % 28-34
                 'NC   ';'C2E12';'C2E16';'C3E2 ';'C3E3 ';'C3E6 ';'C3E16';'C3E12';'C3E14';'C3E15';'NC   ';...    % 38-48
                 'C2E4 ';'C2E5 ';'C2E9 ';'C2E15';'C2E14';'C3E4 ';'C4E1 ';'C3E13';'C4E3 ';'C4E2 ';'C4E7 ';...    % 50-60
                 'C2E1 ';'C2E8 ';'C2E7 ';'C2E10';'C2E11';'C2E13';'C4E8 ';'C4E4 ';'C4E11';'C4E5 ';'C4E6 ';...    % 62-72
                 'C1E14';'C2E2 ';'C2E3 ';'C2E6 ';'C1E16';'C5E3 ';'C5E2 ';'C4E15';'C4E16';'C4E10';'C4E9 ';...    % 74-84
                 'C1E15';'C1E13';'C1E11';'C1E12';'C1E9 ';'C5E5 ';'C5E6 ';'C5E1 ';'C4E13';'C4E12';'NC   ';...    % 86-96
                 'NC   ';'C1E10';'C1E6 ';'C1E5 ';'C1E8 ';'C5E12';'C5E11';'C5E7 ';'C5E8 ';'C4E14';'NC   ';...    % 98-108
                 'C1E7 ';'C1E3 ';'C1E4 ';'C1E2 ';'C5E14';'C5E15';'C5E10';'C5E9 ';'C5E4 ';...    % 111-119
                 'C1E1 ';'NC   ';'C5E13';'NC   ';'C5E16';...    % 125-129
                 'NC   ';]);    % 139
% add text labels
tlab = text(xHex(eind),...
       yHex(eind),...
       etext);
set(tlab,...
    'HorizontalAlignment','center',...
    'FontWeight','bold',...
    'FontSize',9);
set(tlab,'SelectionHighlight','off');
set(tlab,'ButtonDownFcn',@highlightcurve);

% hexagonal grid indices for all electrodes
indHex = [125 114 112 113 101 100 111 102 90 99 88 89 87 74 86 78;...  % channel 1
       62 75 76 50 51 77 64 63 52 65 66 39 67 54 53 40;...  % channel 2
       28 41 42 55 31 43 30 29 33 32 34 45 57 46 47 44;...  % channel 3
       56 59 58 69 71 72 60 68 84 83 70 95 94 107 81 82;... % channel 4
       93 80 79 119 91 92 105 106 118 117 104 103 127 115 116 129]; % channel 5
   
text(xHex(23),yHex(23),'BiAP',...
     'Rotation',90,...
     'FontWeight','bold',...
     'FontSize',14);
 
xlabel('Position (mm)');
ylabel('Current (A)');
title('Hexagonal Grid of MEA Sensor');
                 
set(patchHndl,'FaceColor','flat','FaceVertexCData',cHex(cHexFill),'CDataMapping','scaled');
colorbar; % displays bar showing color scale
end

function highlightcurve(thdl,~)
    global HL;
    global hlc;
    HL = 1;
    txt = get(thdl,'String');
    hlc = [str2double(txt(2));...   % highlighted channel
           str2double(txt(4:end))]; % highlighted electrode
    if strcmp(txt,'NC') == 0
        clr = get(thdl,'Color');
        if clr(1) == 0
            set(thdl,'Color','r');
            hlc(3) = 1;
        else
            set(thdl,'Color','k');
            hlc(3) = 0;
        end
%{
        switch hlc(1)
            case 1
                set(ch1_fig(hlc(2)),'LineWidth',line_w,'MarkerSize',mark_s);
            case 2
                set(ch2_fig(hlc(2)),'LineWidth',line_w,'MarkerSize',mark_s);
            case 3
                set(ch3_fig(hlc(2)),'LineWidth',line_w,'MarkerSize',mark_s);
            case 4
                set(ch4_fig(hlc(2)),'LineWidth',line_w,'MarkerSize',mark_s);
            case 5
                set(ch5_fig(hlc(2)),'LineWidth',line_w,'MarkerSize',mark_s);
        end
        %}
    end
end
