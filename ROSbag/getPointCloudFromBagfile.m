function [ply] = getPointCloudFromBagfile(path, sid, pid)

bag = rosbag(path).select('Topic', sid);
msgs = bag.readMessages;
ply = [];

for i=1:length(msgs)
    pt = [];
    last_coord = 0;
    last_color = 0;

    wip = msgs{i}.Whatispresent;
    coords = msgs{i}.Coordinate;
    colors = msgs{i}.Color;
    durs = msgs{i}.Duration;

    for j=1:length(durs)
        if char(wip(j)) == 'B'
            last_coord = coords(j);
            last_color = colors(j);
        elseif char(wip(j)) == 'C'
            last_color = colors(j);
        else
            last_coord = coords(j);
        end

        if durs(j).Start <= pid && pid < durs(j).End
            pt = [pt [
                        last_coord.X
                        last_coord.Y
                        last_coord.Z
                        last_color.R
                        last_color.G
                        last_color.B
                        last_color.A
                      ]
                   ];
            disp(pt);
            break;
        end
    end
    ply = [ply pt];
end

end

