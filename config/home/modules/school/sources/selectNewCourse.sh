#!/usr/bin/env bash

# get all valid course directories in the current quarter
# as well as a corresponding message for each in wofi
directories=()
messages=()
while IFS= read -r dir; do
  directories+=("$dir")
  messages+=("$(courseInfo.sh "$dir" --title) <span weight='light' style='italic'>($(basename "$dir"))</span>")
done < <(courseInfo.sh --list-active)

# ask wofi to select one of them, and return the number of the selection
selection=$(printf "%s\n" "${messages[@]}" | wofi --define=dmenu-print_line_num=true --define=lines=7 --prompt="set current course" -d)

# verify that the user made a selection ($selection must be an integer)
if ! [[ "$selection" =~ ^[0-9]+$ ]]
then
  echo "Error: No selection was made"
  exit 1
fi

# get the new current course based on the number of the selection made
tmpVar="${directories[$selection]}"
newCurrentCourse=${tmpVar//"$HOME/"/}

# link the new current course to the CURRENTCOURSE symlink directory
courseTools.sh --set-course "$(echo -n "$newCurrentCourse")"
