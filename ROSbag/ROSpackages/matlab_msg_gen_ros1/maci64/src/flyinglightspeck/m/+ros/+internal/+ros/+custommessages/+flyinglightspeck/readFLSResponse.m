function [data, info] = readFLSResponse
%ReadFLS gives an empty data for flyinglightspeck/ReadFLSResponse
% Copyright 2019-2020 The MathWorks, Inc.
%#codegen
data = struct();
data.MessageType = 'flyinglightspeck/ReadFLSResponse';
[data.Str, info.Str] = ros.internal.ros.messages.ros.char('string',0);
info.MessageType = 'flyinglightspeck/ReadFLSResponse';
info.constant = 0;
info.default = 0;
info.maxstrlen = NaN;
info.MaxLen = 1;
info.MinLen = 1;
info.MatPath = cell(1,1);
info.MatPath{1} = 'str';
