function [data, info] = header
%Header gives an empty data for flyinglightspeck/Header
% Copyright 2019-2020 The MathWorks, Inc.
%#codegen
data = struct();
data.MessageType = 'flyinglightspeck/Header';
[data.Id, info.Id] = ros.internal.ros.messages.ros.default_type('uint32',1);
[data.Coordinate, info.Coordinate] = ros.internal.ros.messages.ros.default_type('single',3);
[data.Color, info.Color] = ros.internal.ros.messages.ros.default_type('int8',4);
[data.Duration, info.Duration] = ros.internal.ros.messages.ros.time;
info.Duration.MLdataType = 'struct';
info.Duration.MaxLen = 2;
info.Duration.MinLen = 2;
val = [];
for i = 1:2
    val = vertcat(data.Duration, val); %#ok<AGROW>
end
data.Duration = val;
info.MessageType = 'flyinglightspeck/Header';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,6);
info.MatPath{1} = 'id';
info.MatPath{2} = 'coordinate';
info.MatPath{3} = 'color';
info.MatPath{4} = 'duration';
info.MatPath{5} = 'duration.sec';
info.MatPath{6} = 'duration.nsec';
