    function o_class(obj,   q, x, z) {
  q = CONVFMT
  CONVFMT = "% g"
    split(" " obj "\1" obj, x, "\1")
    x[1] = obj == x[1]
    x[2] = obj == x[2]
    x[3] = obj == 0
    x[4] = obj "" == +obj
  CONVFMT = q
  z["0001"] = z["1101"] = z["1111"] = "number"
  z["0100"] = z["0101"] = z["0111"] = "string"
  z["1100"] = z["1110"] = "strnum"
  z["0110"] = "undefined"
  return z[x[1] x[2] x[3] x[4]]
}
BEGIN {
    # The name for search the date in file.
    # Index means priority, the lower the index is, the higher the priority is
    dateName[0] = "Date/Time Original";
    dateName[1] = "Create Date";
    dateName[2] = "Creation Date";
    dateName[3] = "Content Create Date";
    dateName[4] = "Modify Date";
    dateName[5] = "Media Create Date";
    dateName[6] = "Media Modify Date";
    dateName[7] = "Track Create Date";
    dateName[8] = "Track Modify Date";
    dateName[9] = "File Inode Change Date/Time";
    matchIndex = 10;
}
{
    print("----------", $0)
    for (n in dateName) {
        # If find the "date" in exif info and its priority higher than before match
        if (int(n) < matchIndex && match($0, dateName[n]) != 0) {
            # Remove the leading part
            gsub(/^[^:]+: */, "", $0);
            date = $0;
            matchIndex = n;
        }
    }
}
END {
    if (length(date) != 0)
    {
        year  = substr(date, 1, 4);
        month = substr(date, 6, 2);
        day   = substr(date, 9, 2);
        print "/"year"/"year"-"month"/"year"-"month"-"day;
    }
}
