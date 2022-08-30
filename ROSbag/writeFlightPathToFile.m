function [msgs] = writeFlightPathToFile(FLSArray, filename, topic)
% write FLSArray to a bag file

msgs = [];

for i=1:length(FLSArray)
    flsElt = FLSArray{i};

    msg = rosmessage('flyinglightspeck/fls');
   
    Whatispresent = [];
    Coordinate = [];
    Color = [];
    Duration = [];

    for j=1:length(flsElt)
        coordElt = flsElt(j).coordElt;
        colorsElt = flsElt(j).colorsElt;
        dursElt = flsElt(j).dursElt;

        CoordinateMsg = rosmessage('flyinglightspeck/FLSXYZ');
        CoordinateMsg.X = coordElt.length;
        CoordinateMsg.Y = coordElt.height;
        CoordinateMsg.Z = coordElt.depth;

        ColorMsg = rosmessage('flyinglightspeck/FLSRGBA');
        ColorMsg.R = colorsElt.red;
        ColorMsg.G = colorsElt.green;
        ColorMsg.B = colorsElt.blue;
        ColorMsg.A = colorsElt.transparency;

        DurationMsg = rosmessage('flyinglightspeck/FLSDuration');
        DurationMsg.Start = dursElt.startTS;
        DurationMsg.End = dursElt.endTS;

        Whatispresent = [Whatispresent cast(flsElt(j).whatispresent,"uint8")];
        Coordinate = [Coordinate CoordinateMsg];
        Color = [Color ColorMsg];
        Duration = [Duration DurationMsg];

    end

    msg.Whatispresent = Whatispresent;
    msg.Coordinate = Coordinate;
    msg.Color = Color;
    msg.Duration = Duration;

    msgs = [msgs msg];
end

timeStamps = repelem([rostime("now")], length(msgs));
bagwriter = rosbagwriter(filename);
write(bagwriter,topic,timeStamps,msgs);

end

