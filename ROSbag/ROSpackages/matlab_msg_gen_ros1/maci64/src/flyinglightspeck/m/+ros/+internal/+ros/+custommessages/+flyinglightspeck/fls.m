function [data, info] = fls
%fls gives an empty data for flyinglightspeck/fls
% Copyright 2019-2020 The MathWorks, Inc.
%#codegen
data = struct();
data.MessageType = 'flyinglightspeck/fls';
[data.Header, info.Header] = ros.internal.ros.messages.std_msgs.header;
info.Header.MLdataType = 'struct';
[data.Whatispresent, info.Whatispresent] = ros.internal.ros.messages.ros.default_type('int8',NaN);
[data.Coordinate, info.Coordinate] = ros.internal.ros.messages.ros.default_type('single',NaN);
[data.Color, info.Color] = ros.internal.ros.messages.ros.default_type('int8',NaN);
[data.Duration, info.Duration] = ros.internal.ros.messages.ros.time;
info.Duration.MLdataType = 'struct';
info.Duration.MaxLen = NaN;
info.Duration.MinLen = 0;
data.Duration = data.Duration([],1);
info.MessageType = 'flyinglightspeck/fls';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,12);
info.MatPath{1} = 'header';
info.MatPath{2} = 'header.seq';
info.MatPath{3} = 'header.stamp';
info.MatPath{4} = 'header.stamp.sec';
info.MatPath{5} = 'header.stamp.nsec';
info.MatPath{6} = 'header.frame_id';
info.MatPath{7} = 'whatispresent';
info.MatPath{8} = 'coordinate';
info.MatPath{9} = 'color';
info.MatPath{10} = 'duration';
info.MatPath{11} = 'duration.sec';
info.MatPath{12} = 'duration.nsec';
