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

% Last Modified by GUIDE v2.5 11-Jun-2015 19:30:52

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


% --- Outputs from this function are returned to the command line.
function varargout = mbed_GUI2_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in run_pot.
function run_pot_Callback(hObject, eventdata, handles)
% hObject    handle to run_pot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of run_pot

% global variable
global vdd;

mbed_ready = 0;
pc_ready = uint8(1);

vdac = str2double(get(handles.vdac_val,'String'));   % initialize in case user directly presses button
vdac_frac = vdac/vdd;

% change GUI settings
set(handles.vdac_val,'Enable','off');
set(handles.vred_val,'Enable','off');
set(handles.frame_val,'Enable','off');
set(handles.dac_slider,'Enable','off');
set(hObject,'Enable','off');
set(handles.stopclear,'Enable','on');
set(handles.loaddata,'Enable','off');

% delays in real-time sampling increase with number of samples plotted
% set maximum number of samples displayed in figure to prevent large delays
frame = str2double(get(handles.frame_val,'String'));
frame_index = -frame + 2;   % frame index
start = 1;  % initial starting index of data to be plotted

run = get(hObject,'Value'); % get run command

if run == 1
    
    display('Potentiostat has started running');
    
    % establish serial port interface
    mbed = serial('COM12'); % COM12 for laptop, COM60 for PC
    set(mbed, 'Timeout', 10);
    fopen(mbed);
    
    % initialize plots
    index = 1;  % data sample count
    elect = 1;  % selected electrode
    
    % Channel 1
    t_ch1(1,1:16) = 0;
    vdata_ch1(1,1:16) = 0;
    cdata_ch1(1,1:16) = 0;
    fb_sel_ch1(1:1:16) = 0;
    hold(handles.axes_ch1,'on');
    title(handles.axes_ch1,'Channel 1');
    ch1_fig(1) = plot(handles.axes_ch1, t_ch1(1,1), cdata_ch1(1,1), 'r-x');
    ch1_fig(2) = plot(handles.axes_ch1, t_ch1(1,2), cdata_ch1(1,2), 'g-x');
    ch1_fig(3) = plot(handles.axes_ch1, t_ch1(1,3), cdata_ch1(1,3), 'b-x');
    ch1_fig(4) = plot(handles.axes_ch1, t_ch1(1,4), cdata_ch1(1,4), 'c-x');
    ch1_fig(5) = plot(handles.axes_ch1, t_ch1(1,5), cdata_ch1(1,5), 'm-x');
    ch1_fig(6) = plot(handles.axes_ch1, t_ch1(1,6), cdata_ch1(1,6), 'y-x');
    ch1_fig(7) = plot(handles.axes_ch1, t_ch1(1,7), cdata_ch1(1,7), 'k-x');
    ch1_fig(8) = plot(handles.axes_ch1, t_ch1(1,8), cdata_ch1(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch1_fig(9) = plot(handles.axes_ch1, t_ch1(1,9), cdata_ch1(1,9), 'r-o');
    ch1_fig(10) = plot(handles.axes_ch1, t_ch1(1,10), cdata_ch1(1,10), 'g-o');
    ch1_fig(11) = plot(handles.axes_ch1, t_ch1(1,11), cdata_ch1(1,11), 'b-o');
    ch1_fig(12) = plot(handles.axes_ch1, t_ch1(1,12), cdata_ch1(1,12), 'c-o');
    ch1_fig(13) = plot(handles.axes_ch1, t_ch1(1,13), cdata_ch1(1,13), 'm-o');
    ch1_fig(14) = plot(handles.axes_ch1, t_ch1(1,14), cdata_ch1(1,14), 'y-o');
    ch1_fig(15) = plot(handles.axes_ch1, t_ch1(1,15), cdata_ch1(1,15), 'k-o');
    ch1_fig(16) = plot(handles.axes_ch1, t_ch1(1,16), cdata_ch1(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch1,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % Channel 2
    t_ch2(1,1:16) = 0;
    vdata_ch2(1,1:16) = 0;
    cdata_ch2(1,1:16) = 0;
    fb_sel_ch2(1:1:16) = 0;
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
    ch2_fig(9) = plot(handles.axes_ch2, t_ch2(1,9), cdata_ch1(1,9), 'r-o');
    ch2_fig(10) = plot(handles.axes_ch2, t_ch2(1,10), cdata_ch2(1,10), 'g-o');
    ch2_fig(11) = plot(handles.axes_ch2, t_ch2(1,11), cdata_ch2(1,11), 'b-o');
    ch2_fig(12) = plot(handles.axes_ch2, t_ch2(1,12), cdata_ch2(1,12), 'c-o');
    ch2_fig(13) = plot(handles.axes_ch2, t_ch2(1,13), cdata_ch2(1,13), 'm-o');
    ch2_fig(14) = plot(handles.axes_ch2, t_ch2(1,14), cdata_ch2(1,14), 'y-o');
    ch2_fig(15) = plot(handles.axes_ch2, t_ch2(1,15), cdata_ch2(1,15), 'k-o');
    ch2_fig(16) = plot(handles.axes_ch2, t_ch2(1,16), cdata_ch2(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch2,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % Channel 3
    t_ch3(1,1:16) = 0;
    vdata_ch3(1,1:16) = 0;
    cdata_ch3(1,1:16) = 0;
    fb_sel_ch3(1:1:16) = 0;
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
    ch3_fig(9) = plot(handles.axes_ch3, t_ch3(1,9), cdata_ch3(1,9), 'r-o');
    ch3_fig(10) = plot(handles.axes_ch3, t_ch3(1,10), cdata_ch3(1,10), 'g-o');
    ch3_fig(11) = plot(handles.axes_ch3, t_ch3(1,11), cdata_ch3(1,11), 'b-o');
    ch3_fig(12) = plot(handles.axes_ch3, t_ch3(1,12), cdata_ch3(1,12), 'c-o');
    ch3_fig(13) = plot(handles.axes_ch3, t_ch3(1,13), cdata_ch3(1,13), 'm-o');
    ch3_fig(14) = plot(handles.axes_ch3, t_ch3(1,14), cdata_ch3(1,14), 'y-o');
    ch3_fig(15) = plot(handles.axes_ch3, t_ch3(1,15), cdata_ch3(1,15), 'k-o');
    ch3_fig(16) = plot(handles.axes_ch3, t_ch3(1,16), cdata_ch3(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch3,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % Channel 4
    t_ch4(1,1:16) = 0;
    vdata_ch4(1,1:16) = 0;
    cdata_ch4(1,1:16) = 0;
    fb_sel_ch4(1:1:16) = 0;
    hold(handles.axes_ch4,'on');
    title(handles.axes_ch4,'Channel 4');
    ch4_fig(1) = plot(handles.axes_ch4, t_ch4(1,1), cdata_ch4(1,1), 'r-x');
    ch4_fig(2) = plot(handles.axes_ch4, t_ch4(1,2), cdata_ch4(1,2), 'g-x');
    ch4_fig(3) = plot(handles.axes_ch4, t_ch4(1,3), cdata_ch4(1,3), 'b-x');
    ch4_fig(4) = plot(handles.axes_ch4, t_ch4(1,4), cdata_ch4(1,4), 'c-x');
    ch4_fig(5) = plot(handles.axes_ch4, t_ch4(1,5), cdata_ch4(1,5), 'm-x');
    ch4_fig(6) = plot(handles.axes_ch4, t_ch4(1,6), cdata_ch4(1,6), 'y-x');
    ch4_fig(7) = plot(handles.axes_ch4, t_ch4(1,7), cdata_ch4(1,7), 'k-x');
    ch4_fig(8) = plot(handles.axes_ch4, t_ch4(1,8), cdata_ch4(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch4_fig(9) = plot(handles.axes_ch4, t_ch4(1,9), cdata_ch4(1,9), 'r-o');
    ch4_fig(10) = plot(handles.axes_ch4, t_ch4(1,10), cdata_ch4(1,10), 'g-o');
    ch4_fig(11) = plot(handles.axes_ch4, t_ch4(1,11), cdata_ch4(1,11), 'b-o');
    ch4_fig(12) = plot(handles.axes_ch4, t_ch4(1,12), cdata_ch4(1,12), 'c-o');
    ch4_fig(13) = plot(handles.axes_ch4, t_ch4(1,13), cdata_ch4(1,13), 'm-o');
    ch4_fig(14) = plot(handles.axes_ch4, t_ch4(1,14), cdata_ch4(1,14), 'y-o');
    ch4_fig(15) = plot(handles.axes_ch4, t_ch4(1,15), cdata_ch4(1,15), 'k-o');
    ch4_fig(16) = plot(handles.axes_ch4, t_ch4(1,16), cdata_ch4(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch4,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % Channel 5
    t_ch5(1,1:16) = 0;
    vdata_ch5(1,1:16) = 0;
    cdata_ch5(1,1:16) = 0;
    fb_sel_ch5(1:1:16) = 0;
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
    ch5_fig(9) = plot(handles.axes_ch5, t_ch5(1,9), cdata_ch5(1,9), 'r-o');
    ch5_fig(10) = plot(handles.axes_ch5, t_ch5(1,10), cdata_ch5(1,10), 'g-o');
    ch5_fig(11) = plot(handles.axes_ch5, t_ch5(1,11), cdata_ch5(1,11), 'b-o');
    ch5_fig(12) = plot(handles.axes_ch5, t_ch5(1,12), cdata_ch5(1,12), 'c-o');
    ch5_fig(13) = plot(handles.axes_ch5, t_ch5(1,13), cdata_ch5(1,13), 'm-o');
    ch5_fig(14) = plot(handles.axes_ch5, t_ch5(1,14), cdata_ch5(1,14), 'y-o');
    ch5_fig(15) = plot(handles.axes_ch5, t_ch5(1,15), cdata_ch5(1,15), 'k-o');
    ch5_fig(16) = plot(handles.axes_ch5, t_ch5(1,16), cdata_ch5(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch5,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    display(vdac_frac);
    % send DAC voltage value to mbed across serial port
    try % Must have try-catch for fprintf otherwise will result in serial/fprintf error that terminates the code after (the write operation still successfully delivers the data)
        fprintf(mbed,'%f\n', vdac_frac); % Syntax: fprintf(obj,'format'.'cmd'). 'cmd' can be a variable without quotation, but the data type must be the same as the specifier in 'format'. Terminator \n is mandatory.
    catch
    display('DAC value sent');
    end
    
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
        
        cdata_ch1(index, elect) = vdata_ch1(index, elect)/(16000*10^(fb_sel_ch1(index, elect)));    % calculate current
        cdata_ch2(index, elect) = vdata_ch2(index, elect)/(16000*10^(fb_sel_ch2(index, elect)));
        cdata_ch3(index, elect) = vdata_ch3(index, elect)/(16000*10^(fb_sel_ch3(index, elect)));
        cdata_ch4(index, elect) = vdata_ch4(index, elect)/(16000*10^(fb_sel_ch4(index, elect)));
        cdata_ch5(index, elect) = vdata_ch5(index, elect)/(16000*10^(fb_sel_ch5(index, elect)));
        
        % update new x- and y-axis values
        set(ch1_fig(elect), 'XData', t_ch1(start:end, elect), 'YData', cdata_ch1(start:end, elect));
        set(ch2_fig(elect), 'XData', t_ch2(start:end, elect), 'YData', cdata_ch2(start:end, elect));
        set(ch3_fig(elect), 'XData', t_ch3(start:end, elect), 'YData', cdata_ch3(start:end, elect));
        set(ch4_fig(elect), 'XData', t_ch4(start:end, elect), 'YData', cdata_ch4(start:end, elect));
        set(ch5_fig(elect), 'XData', t_ch5(start:end, elect), 'YData', cdata_ch5(start:end, elect));
        drawnow;    % updates figure
        
        elect = elect + 1;  % increment electrode
        
        if elect > 16
            elect = 1;  % return to first electrode
            index = index + 1;  % increment data sample count
            frame_index = frame_index + 1;  % increment frame index
            start = max(1,frame_index);   % starting index of data to be plotted
        end
        
        % when "Stop" button is pressed
        if get(handles.stopclear,'Value') == 1
            set(handles.stopclear,'String','Clear');
            set(handles.stopclear,'TooltipString','Clear all figures and data');
            set(handles.savedata,'Enable','on');
            break;  % break out of while loop
        end        

    end
    
    % display complete data on figures
    for i = 1:16
        if i < elect
            set(ch1_fig(i), 'XData', t_ch1(:, i), 'YData', cdata_ch1(:, i));
            set(ch2_fig(i), 'XData', t_ch2(:, i), 'YData', cdata_ch2(:, i));
            set(ch3_fig(i), 'XData', t_ch3(:, i), 'YData', cdata_ch3(:, i));
            set(ch4_fig(i), 'XData', t_ch4(:, i), 'YData', cdata_ch4(:, i));
            set(ch5_fig(i), 'XData', t_ch5(:, i), 'YData', cdata_ch5(:, i));   
        else
            set(ch1_fig(i), 'XData', t_ch1(1:end-1, i), 'YData', cdata_ch1(1:end-1, i));
            set(ch2_fig(i), 'XData', t_ch2(1:end-1, i), 'YData', cdata_ch2(1:end-1, i));
            set(ch3_fig(i), 'XData', t_ch3(1:end-1, i), 'YData', cdata_ch3(1:end-1, i));
            set(ch4_fig(i), 'XData', t_ch4(1:end-1, i), 'YData', cdata_ch4(1:end-1, i));
            set(ch5_fig(i), 'XData', t_ch5(1:end-1, i), 'YData', cdata_ch5(1:end-1, i));                     
        end
    end
    
    hold(handles.axes_ch1,'off');
    hold(handles.axes_ch2,'off');
    hold(handles.axes_ch3,'off');
    hold(handles.axes_ch4,'off');
    hold(handles.axes_ch5,'off');
    
    display('Potentiostat has stopped running');
    
    % save data variables in handles
    handles.t_ch1_save = t_ch1;
    handles.t_ch2_save = t_ch2;
    handles.t_ch3_save = t_ch3;
    handles.t_ch4_save = t_ch4;
    handles.t_ch5_save = t_ch5;
    
    handles.vdata_ch1_save = vdata_ch1;
    handles.vdata_ch2_save = vdata_ch2;
    handles.vdata_ch3_save = vdata_ch3;
    handles.vdata_ch4_save = vdata_ch4;
    handles.vdata_ch5_save = vdata_ch5;
    
    handles.cdata_ch1_save = cdata_ch1;
    handles.cdata_ch2_save = cdata_ch2;
    handles.cdata_ch3_save = cdata_ch3;
    handles.cdata_ch4_save = cdata_ch4;
    handles.cdata_ch5_save = cdata_ch5;
    
    handles.fb_sel_ch1_save = fb_sel_ch1;
    handles.fb_sel_ch2_save = fb_sel_ch2;
    handles.fb_sel_ch3_save = fb_sel_ch3;
    handles.fb_sel_ch4_save = fb_sel_ch4;
    handles.fb_sel_ch5_save = fb_sel_ch5;
    
    guidata(hObject, handles);  % save handles
end

% Close mbed
fclose(mbed);
delete(mbed);

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
vdac = handles.slider*vdd/1024; % DAC voltage (resolution set to 10 bits)
display(vdac);
vred = vdac - vdd/2;   % redox voltage
set(handles.vdac_val, 'String', num2str(vdac)); % display vdac value
set(handles.vred_val, 'String', num2str(vred)); % display vred value
guidata(hObject, handles);  % save handles

% --- Executes during object creation, after setting all properties.
function dac_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dac_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
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
    
    nodata = find(any(t_ch1 == 0)); % returns column numbers of zero elements in last row
    if isempty(nodata)
        nodata = 0;
    else
        nodata = nodata(1);
    end
    
    % initialize plots
    % Channel 1
    hold(handles.axes_ch1,'on');
    title(handles.axes_ch1,'Channel 1');
    ch1_fig(1) = plot(handles.axes_ch1, t_ch1(1,1), cdata_ch1(1,1), 'r-x');
    ch1_fig(2) = plot(handles.axes_ch1, t_ch1(1,2), cdata_ch1(1,2), 'g-x');
    ch1_fig(3) = plot(handles.axes_ch1, t_ch1(1,3), cdata_ch1(1,3), 'b-x');
    ch1_fig(4) = plot(handles.axes_ch1, t_ch1(1,4), cdata_ch1(1,4), 'c-x');
    ch1_fig(5) = plot(handles.axes_ch1, t_ch1(1,5), cdata_ch1(1,5), 'm-x');
    ch1_fig(6) = plot(handles.axes_ch1, t_ch1(1,6), cdata_ch1(1,6), 'y-x');
    ch1_fig(7) = plot(handles.axes_ch1, t_ch1(1,7), cdata_ch1(1,7), 'k-x');
    ch1_fig(8) = plot(handles.axes_ch1, t_ch1(1,8), cdata_ch1(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch1_fig(9) = plot(handles.axes_ch1, t_ch1(1,9), cdata_ch1(1,9), 'r-o');
    ch1_fig(10) = plot(handles.axes_ch1, t_ch1(1,10), cdata_ch1(1,10), 'g-o');
    ch1_fig(11) = plot(handles.axes_ch1, t_ch1(1,11), cdata_ch1(1,11), 'b-o');
    ch1_fig(12) = plot(handles.axes_ch1, t_ch1(1,12), cdata_ch1(1,12), 'c-o');
    ch1_fig(13) = plot(handles.axes_ch1, t_ch1(1,13), cdata_ch1(1,13), 'm-o');
    ch1_fig(14) = plot(handles.axes_ch1, t_ch1(1,14), cdata_ch1(1,14), 'y-o');
    ch1_fig(15) = plot(handles.axes_ch1, t_ch1(1,15), cdata_ch1(1,15), 'k-o');
    ch1_fig(16) = plot(handles.axes_ch1, t_ch1(1,16), cdata_ch1(1,16), '-o', 'Color', [0.5,0.5,0.5]);
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
    ch2_fig(9) = plot(handles.axes_ch2, t_ch2(1,9), cdata_ch1(1,9), 'r-o');
    ch2_fig(10) = plot(handles.axes_ch2, t_ch2(1,10), cdata_ch2(1,10), 'g-o');
    ch2_fig(11) = plot(handles.axes_ch2, t_ch2(1,11), cdata_ch2(1,11), 'b-o');
    ch2_fig(12) = plot(handles.axes_ch2, t_ch2(1,12), cdata_ch2(1,12), 'c-o');
    ch2_fig(13) = plot(handles.axes_ch2, t_ch2(1,13), cdata_ch2(1,13), 'm-o');
    ch2_fig(14) = plot(handles.axes_ch2, t_ch2(1,14), cdata_ch2(1,14), 'y-o');
    ch2_fig(15) = plot(handles.axes_ch2, t_ch2(1,15), cdata_ch2(1,15), 'k-o');
    ch2_fig(16) = plot(handles.axes_ch2, t_ch2(1,16), cdata_ch2(1,16), '-o', 'Color', [0.5,0.5,0.5]);
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
    ch3_fig(9) = plot(handles.axes_ch3, t_ch3(1,9), cdata_ch3(1,9), 'r-o');
    ch3_fig(10) = plot(handles.axes_ch3, t_ch3(1,10), cdata_ch3(1,10), 'g-o');
    ch3_fig(11) = plot(handles.axes_ch3, t_ch3(1,11), cdata_ch3(1,11), 'b-o');
    ch3_fig(12) = plot(handles.axes_ch3, t_ch3(1,12), cdata_ch3(1,12), 'c-o');
    ch3_fig(13) = plot(handles.axes_ch3, t_ch3(1,13), cdata_ch3(1,13), 'm-o');
    ch3_fig(14) = plot(handles.axes_ch3, t_ch3(1,14), cdata_ch3(1,14), 'y-o');
    ch3_fig(15) = plot(handles.axes_ch3, t_ch3(1,15), cdata_ch3(1,15), 'k-o');
    ch3_fig(16) = plot(handles.axes_ch3, t_ch3(1,16), cdata_ch3(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch3,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % Channel 4
    hold(handles.axes_ch4,'on');
    title(handles.axes_ch4,'Channel 4');
    ch4_fig(1) = plot(handles.axes_ch4, t_ch4(1,1), cdata_ch4(1,1), 'r-x');
    ch4_fig(2) = plot(handles.axes_ch4, t_ch4(1,2), cdata_ch4(1,2), 'g-x');
    ch4_fig(3) = plot(handles.axes_ch4, t_ch4(1,3), cdata_ch4(1,3), 'b-x');
    ch4_fig(4) = plot(handles.axes_ch4, t_ch4(1,4), cdata_ch4(1,4), 'c-x');
    ch4_fig(5) = plot(handles.axes_ch4, t_ch4(1,5), cdata_ch4(1,5), 'm-x');
    ch4_fig(6) = plot(handles.axes_ch4, t_ch4(1,6), cdata_ch4(1,6), 'y-x');
    ch4_fig(7) = plot(handles.axes_ch4, t_ch4(1,7), cdata_ch4(1,7), 'k-x');
    ch4_fig(8) = plot(handles.axes_ch4, t_ch4(1,8), cdata_ch4(1,8), '-x', 'Color', [0.5,0.5,0.5]);
    ch4_fig(9) = plot(handles.axes_ch4, t_ch4(1,9), cdata_ch4(1,9), 'r-o');
    ch4_fig(10) = plot(handles.axes_ch4, t_ch4(1,10), cdata_ch4(1,10), 'g-o');
    ch4_fig(11) = plot(handles.axes_ch4, t_ch4(1,11), cdata_ch4(1,11), 'b-o');
    ch4_fig(12) = plot(handles.axes_ch4, t_ch4(1,12), cdata_ch4(1,12), 'c-o');
    ch4_fig(13) = plot(handles.axes_ch4, t_ch4(1,13), cdata_ch4(1,13), 'm-o');
    ch4_fig(14) = plot(handles.axes_ch4, t_ch4(1,14), cdata_ch4(1,14), 'y-o');
    ch4_fig(15) = plot(handles.axes_ch4, t_ch4(1,15), cdata_ch4(1,15), 'k-o');
    ch4_fig(16) = plot(handles.axes_ch4, t_ch4(1,16), cdata_ch4(1,16), '-o', 'Color', [0.5,0.5,0.5]);
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
    ch5_fig(9) = plot(handles.axes_ch5, t_ch5(1,9), cdata_ch5(1,9), 'r-o');
    ch5_fig(10) = plot(handles.axes_ch5, t_ch5(1,10), cdata_ch5(1,10), 'g-o');
    ch5_fig(11) = plot(handles.axes_ch5, t_ch5(1,11), cdata_ch5(1,11), 'b-o');
    ch5_fig(12) = plot(handles.axes_ch5, t_ch5(1,12), cdata_ch5(1,12), 'c-o');
    ch5_fig(13) = plot(handles.axes_ch5, t_ch5(1,13), cdata_ch5(1,13), 'm-o');
    ch5_fig(14) = plot(handles.axes_ch5, t_ch5(1,14), cdata_ch5(1,14), 'y-o');
    ch5_fig(15) = plot(handles.axes_ch5, t_ch5(1,15), cdata_ch5(1,15), 'k-o');
    ch5_fig(16) = plot(handles.axes_ch5, t_ch5(1,16), cdata_ch5(1,16), '-o', 'Color', [0.5,0.5,0.5]);
    %legend(handles.axes_ch5,'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','Location','best');
    
    % display complete data on figures
    for i = 1:16
        if i < nodata
            set(ch1_fig(i), 'XData', t_ch1(:, i), 'YData', cdata_ch1(:, i));
            set(ch2_fig(i), 'XData', t_ch2(:, i), 'YData', cdata_ch2(:, i));
            set(ch3_fig(i), 'XData', t_ch3(:, i), 'YData', cdata_ch3(:, i));
            set(ch4_fig(i), 'XData', t_ch4(:, i), 'YData', cdata_ch4(:, i));
            set(ch5_fig(i), 'XData', t_ch5(:, i), 'YData', cdata_ch5(:, i));
        else
            set(ch1_fig(i), 'XData', t_ch1(1:end-1, i), 'YData', cdata_ch1(1:end-1, i));
            set(ch2_fig(i), 'XData', t_ch2(1:end-1, i), 'YData', cdata_ch2(1:end-1, i));
            set(ch3_fig(i), 'XData', t_ch3(1:end-1, i), 'YData', cdata_ch3(1:end-1, i));
            set(ch4_fig(i), 'XData', t_ch4(1:end-1, i), 'YData', cdata_ch4(1:end-1, i));
            set(ch5_fig(i), 'XData', t_ch5(1:end-1, i), 'YData', cdata_ch5(1:end-1, i));            
        end
    end
    
    hold(handles.axes_ch1,'off');
    hold(handles.axes_ch2,'off');
    hold(handles.axes_ch3,'off');
    hold(handles.axes_ch4,'off');
    hold(handles.axes_ch5,'off');
    
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
end

function vdac_val_Callback(hObject, eventdata, handles)
% hObject    handle to vdac_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vdac_val as text
%        str2double(get(hObject,'String')) returns contents of vdac_val as a double

global vdd;

handles.slider = round(str2double(get(hObject,'String'))*1024/vdd); % get dac_slider value (round to nearest integer)
set(handles.dac_slider,'Value',handles.slider); % set dac_slider value and position
guidata(hObject, handles);  % save handles
dac_slider_Callback(handles.dac_slider, eventdata, handles); % call dac_slider_Callback to update vdac and vred

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


function vred_val_Callback(hObject, eventdata, handles)
% hObject    handle to vred_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vred_val as text
%        str2double(get(hObject,'String')) returns contents of vred_val as a double

global vdd;

handles.slider = round((str2double(get(hObject,'String')) + vdd/2)*1024/vdd);  % get dac_slider value (round to nearest integer)
set(handles.dac_slider,'Value',handles.slider); % set dac_slider value and position
guidata(hObject, handles);  % save handles
dac_slider_Callback(handles.dac_slider, eventdata, handles); % call dac_slider_Callback to update vdac and vred

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


% --- Executes on button press in close.
function close_Callback(hObject, eventdata, handles)
% hObject    handle to close (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of close
close;


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
    legend(handles.axes_ch1,'off');
    legend(handles.axes_ch2,'off');
    legend(handles.axes_ch3,'off');
    legend(handles.axes_ch4,'off');
    legend(handles.axes_ch5,'off');
    evalin('base', 'clear');
    if isfield(handles,'t_ch1_save')
        handles = rmfield(handles,{'t_ch1_save','t_ch2_save','t_ch3_save','t_ch4_save','t_ch5_save', ... 
            'vdata_ch1_save','vdata_ch2_save','vdata_ch3_save','vdata_ch4_save','vdata_ch5_save', ...
            'cdata_ch1_save','cdata_ch2_save','cdata_ch3_save','cdata_ch4_save','cdata_ch5_save', ...
            'fb_sel_ch1_save','fb_sel_ch2_save','fb_sel_ch3_save','fb_sel_ch4_save','fb_sel_ch5_save'});
    end
    
    display('Data has been cleared');
    
    % reset GUI components
    set(hObject,'String','Stop');
    set(hObject,'Enable','off');
    set(handles.savedata,'Enable','off');
    set(handles.run_pot,'Enable','on');
    set(handles.vdac_val,'Enable','on');
    set(handles.vred_val,'Enable','on');
    set(handles.frame_val,'Enable','on');
    set(handles.dac_slider,'Enable','on');
    set(handles.stopclear,'TooltipString','Stop the potentiostat');
    set(handles.loaddata,'Enable','on');
    set(handles.ch_popup,'Enable','off');
    set(handles.elect_popup,'Enable','off');
    set(handles.plot_1E,'Enable','off');
    
    guidata(hObject, handles);  % save handles
    
end

% --- Executes on button press in savedata.
function savedata_Callback(hObject, eventdata, handles)
% hObject    handle to savedata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

t_ch1 = handles.t_ch1_save;
t_ch2 = handles.t_ch2_save;
t_ch3 = handles.t_ch3_save;
t_ch4 = handles.t_ch4_save;
t_ch5 = handles.t_ch5_save;

vdata_ch1 = handles.vdata_ch1_save;
vdata_ch2 = handles.vdata_ch2_save;
vdata_ch3 = handles.vdata_ch3_save;
vdata_ch4 = handles.vdata_ch4_save;
vdata_ch5 = handles.vdata_ch5_save;

cdata_ch1 = handles.cdata_ch1_save;
cdata_ch2 = handles.cdata_ch2_save;
cdata_ch3 = handles.cdata_ch3_save;
cdata_ch4 = handles.cdata_ch4_save;
cdata_ch5 = handles.cdata_ch5_save;

fb_sel_ch1 = handles.fb_sel_ch1_save;
fb_sel_ch2 = handles.fb_sel_ch2_save;
fb_sel_ch3 = handles.fb_sel_ch3_save;
fb_sel_ch4 = handles.fb_sel_ch4_save;
fb_sel_ch5 = handles.fb_sel_ch5_save;

uisave({'t_ch1','t_ch2','t_ch3','t_ch4','t_ch5', ... 
        'vdata_ch1','vdata_ch2','vdata_ch3','vdata_ch4','vdata_ch5', ...
        'cdata_ch1','cdata_ch2','cdata_ch3','cdata_ch4','cdata_ch5', ...
        'fb_sel_ch1','fb_sel_ch2','fb_sel_ch3','fb_sel_ch4','fb_sel_ch5'}, ... 
        'datafile');    % save variables (cannot directly call structure fields)
    
display('Data has been saved');



function frame_val_Callback(hObject, eventdata, handles)
% hObject    handle to frame_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frame_val as text
%        str2double(get(hObject,'String')) returns contents of frame_val as a double


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


% --- Executes on button press in elect_map.
function elect_map_Callback(hObject, eventdata, handles)
% hObject    handle to elect_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure; % open new figure window
warning('off','images:initSize:adjustingMag');  % suppress image too big warning
imshow('MEA-layout.JPG');   % display image


% --- Executes on selection change in ch_popup.
function ch_popup_Callback(hObject, eventdata, handles)
% hObject    handle to ch_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ch_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ch_popup


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


% --- Executes on selection change in elect_popup.
function elect_popup_Callback(hObject, eventdata, handles)
% hObject    handle to elect_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elect_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elect_popup


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
        plot_style = 'r-o';
    case 10
        plot_style = 'g-o';
    case 11
        plot_style = 'b-o';
    case 12
        plot_style = 'c-o';
    case 13
        plot_style = 'm-o';
    case 14
        plot_style = 'y-o';
    case 15
        plot_style = 'k-o';
    case 16
        plot_style = 'k-s'; % black square instead of grey-o
end

nodata = find(any(t_ch1(:,elect_num) == 0));    % if empty array, all data valid; else last row is 0

figure; % open new figure window
title_str = strcat('Channel-', num2str(ch_num), ' Electrode-', num2str(elect_num));
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

title(title_str);   % add title
