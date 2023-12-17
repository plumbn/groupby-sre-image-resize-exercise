for img in fileserver/images/*; do
  magick "${img}" \
    -pointsize 50 \
    -draw "gravity south \
      fill black text 0,12 'Nate' \
      fill white text 1,11 'Nate' " \
    "${img}.watermarked"
done
