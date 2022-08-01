function [data, info] = readFLSRequest
%ReadFLS gives an empty data for flyinglightspeck/ReadFLSRequest
% Copyright 2019-2020 The MathWorks, Inc.
%#codegen
data = struct();
data.MessageType = 'flyinglightspeck/ReadFLSRequest';
[data.Str, info.Str] = ros.internal.ros.messages.ros.char('string',0);
info.MessageType = 'flyinglightspeck/ReadFLSRequest';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,1);
info.MatPath{1} = 'str';
