#!/bin/bash
if pidof ffmpeg
  then
    killall ffmpeg

    # get most recent video and copy it to the clipboard
    most_recent_video=$(ls ~/Videos -Art | tail -n 1)
    most_recent_video_full_path=~/Videos/$most_recent_video
    echo "file://$most_recent_video_full_path" | xclip -sel clip -t text/uri-list -i

    # this doesn't work because sadness
    # most_recent_video_mime_type=$(file -b --mime-type ~/Videos/"$most_recent_video")
    # xclip -selection primary/clipboard -t $most_recent_video_mime_type -i ~/Videos/"$most_recent_video"

    notify-send "Stopped Recording (saved to clipboard)!" --icon=dialog-information
  else
    slop=$(slop -f "%x %y %w %h")

    read -r X Y W H < <(echo $slop)

    time=$(date +%d-%m-%Y_%H-%M-%S)

    # only start recording if we give a width (e.g we press escape to get out of slop - don't record)
    width=${#W}

    if [ $width -gt 0 ];
     then
      notify-send 'Started Recording!' --icon=dialog-information

      # records without audio input
      # for audio add "-f alsa -i pulse" to the line below (at the end before \, without "")
      # -vcodec libx264 -qp 18 -preset ultrafast -f alsa -i pulse \
      ffmpeg -f x11grab -s "$W"x"$H" -framerate 60 -thread_queue_size 512 -i :0.0+$X,$Y \
       -f alsa -ac 2 -i default -strict experimental -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" \
       -vcodec libx264 -qp 18 -preset ultrafast -pix_fmt yuv420p \
       -movflags +faststart \
       ~/Videos/recording-$time.mp4
    fi
fi
