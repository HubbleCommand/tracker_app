"""
Converts to GPX format to upload through https://www.strava.com/upload/select

"""
import os
import json
from datetime import datetime
import tzlocal
import polyline
import gpxpy
import gpxpy.gpx

local_timezone = tzlocal.get_localzone()

upload = os.listdir('./uploading')

f = open("results.txt", "w")

for item in upload:
    file = open('./uploading/' + item)

    plyline = []
    start_time = -1
    time = -1

    gpx = gpxpy.gpx.GPX()
    gpx_track = gpxpy.gpx.GPXTrack()
    gpx.tracks.append(gpx_track)
    gpx_segment = gpxpy.gpx.GPXTrackSegment()
    gpx_track.segments.append(gpx_segment)

    while True:
        

        line = file.readline()

        if not line:
            break
        
        #parse only position elements
        if "position" in line:
            parsed = json.loads(line)
            plyline.append((parsed["position"]["longitude"], parsed["position"]["latitude"]))
            time = parsed["position"]["timestamp"]

            gpx_segment.points.append(gpxpy.gpx.GPXTrackPoint(
                latitude=parsed["position"]["latitude"],
                longitude=parsed["position"]["longitude"],
                elevation=parsed["position"]["altitude"],
                time=datetime.fromtimestamp(float(time / 1000), local_timezone)
            ))

            if start_time < 0:
                start_time = time

    file.close()
    
    dt = datetime.fromtimestamp(float(start_time / 1000), local_timezone)

    f.write("Start date: " + dt.isoformat() + "\n")
    f.write("Elapsed: " + str((time - start_time) / 1000) + "\n")
    f.write(polyline.encode(plyline, 7) + '\n')
    f.write('\n')

    gpx.refresh_bounds()
    a = open('./results/' + item.split(".")[0] + ".gpx", "w")
    a.write(gpx.to_xml())
    a.close()

f.close()
