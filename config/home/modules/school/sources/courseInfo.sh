#!/usr/bin/env bash

echoHelpMessage () {
  echo "courseInfo - get information about the currently active course"
  echo
  echo "Using both the info.json file in each course directory as well as the"
  echo "file structure of the quarter directory, courseInfo can be used"
  echo "to get information such as the title or directory or the current course"
  echo
  echo "Usage: courseInfo [DIRECTORY] [options]"
  echo "  Specifying the directory of the course is optional, and if no directory"
  echo "  is specified, the program will work with the current course information."
  echo "  Specified directories should be the direct parent of the info.json file."
  echo
  echo "  Each option will output the corresponding informationa about the"
  echo "  current course. Passing multiple options will output each value in"
  echo "  consecutive lines in order. No native formatting is supported."
  echo
  echo "Available Options:"
  echo "  -t, --title         Title of the course. From info.json"
  echo "  -s, --short         Short title of the course. From info.json"
  echo "  -c, --code          Four letter code of the course. From info.json"
  echo "  -n, --number        Number code of the course. From info.json"
  echo "  -r, --start         Start time in 24 hour format. From info.json"
  echo "  -e, --end           End time in 24 hour format. From info.json"
  echo "  -d, --days          Days of the week the course meets. Formatted as a"
  echo "                      string of three letter days, eg. \"Mon Wed Fri\"."
  echo "                      From info.json"
  echo "  -x, --has-lab       Returns true if a lab section exists, and false"
  echo "                      otherwise. From info.json"
  echo "  -R, --lab-start     Start time of lab in 24 hour format. Returns -1 if"
  echo "                      no lab section exists. From info.json"
  echo "  -R, --lab-start     End time of lab in 24 hour format. Returns -1 if no"
  echo "                      lab section exists. From info.json"
  echo "  -D, --lab-days      Days of the week the lab meets. Formatted as a string"
  echo "                      of three letter days, eg. \"Mon Wed Fri\". Returns -1"
  echo "                      no lab section exists. From info.json"
  echo "  -p, --path          Absolute path to the course. From file structure"
  echo "  -f, --last-figure   Absolute path to the most recent figure file in the"
  echo "                      course. Figure files are any file in the notes/figures/"
  echo "                      subdirectory named in the \"fig_XXX_?.tex\" format."
  echo "  -F, --next-figure   Absolute path to the next figure file in the course."
  echo "                      Note that this file does not exist, and is only the"
  echo "                      name of what would be the next figure file."
  echo "                      subdirectory named in the \"lec_XXX.tex\" format."
  echo "  -l, --last-lecture  Absolute path to the most recent lecture file in the"
  echo "                      course. Lecture files are any file in the notes/"
  echo "                      subdirectory named in the \"lec_XXX.tex\" format."
  echo "  -L, --next-lecture  Absolute path to the next lecture file in the course."
  echo "                      Note that this file does not exist, and is only the"
  echo "                      name of what would be the next lecture file."
  echo "                      subdirectory named in the \"lec_XXX.tex\" format."
  echo "      --list-active   List the full paths of each course in the current"    
  echo "                      quarter."
  echo "  -h, --help          Displays this help message"
}

if [[ -d "$1" ]]; then
  if [[ $(find "$1" -maxdepth 1 -mindepth 1 -type f -name info.json | wc -l) = 1 ]]; then
    coursePath="$1"
    shift
  else
    echo "Invalid directory: Specified directory must be direct parent to info.json file"
    exit 1
  fi
else
  coursePath="$(readlink -n "$CURRENTCOURSE")"
fi

if ! VALID_ARGS=$(getopt -o tscnredxREDpfFlLh --long title,short,code,number,start,end,days,has-lab,lab-start,lab-end,lab-days,path,last-figure,next-figure,last-lecture,next-lecture,list-active,help -- "$@")
then
  exit 1;
fi

eval set -- "$VALID_ARGS"
while [ "$#" -gt 0 ]; do
  case "$1" in
    -t | --title)
      jq -r .name.title "$coursePath/info.json"
      shift
      ;;

    -s | --short)
      jq -r .name.short "$coursePath/info.json"
      shift
      ;;

    -c | --code)
      jq -r .name.code "$coursePath/info.json"
      shift
      ;;

    -n | --number)
      jq -r .name.number "$coursePath/info.json"
      shift
      ;;

    -r | --start)
      jq -r .schedule.start "$coursePath/info.json"
      shift
      ;;

    -e | --end)
      jq -r .schedule.end "$coursePath/info.json"
      shift
      ;;

    -d | --days)
      jq -r .schedule.days "$coursePath/info.json"
      shift
      ;;

    -x | --has-lab)
      jq -r .hasLab "$coursePath/info.json"
      shift
      ;;

    -R | --lab-start)
      if [[ $(jq -r .hasLab "$coursePath/info.json") = true ]]; then
        jq -r .schedule.labStart "$coursePath/info.json"
      else
        echo -1
      fi
      shift
      ;;

    -E | --lab-end)
      if [[ $(jq -r .hasLab "$coursePath/info.json") = true ]]; then
        jq -r .schedule.labEnd "$coursePath/info.json"
      else
        echo -1
      fi
      shift
      ;;

    -D | --lab-days)
      if [[ $(jq -r .hasLab "$coursePath/info.json") = true ]]; then
        jq -r .schedule.labDays "$coursePath/info.json"
      else
        echo -1
      fi
      shift
      ;;

    -p | --path)
      echo "$coursePath"
      shift
      ;;

    -f | --last-figure)
      mapfile -t figures < <(find "$coursePath"/notes -regextype posix-extended -regex '.*fig_[0-9]{3}\.tex.*' | sort)
      if [[ ${#figures[@]} -gt 0 ]]; then
        echo "${figures[${#figures[@]} - 1]}"
      else
        echo -1
      fi
      shift
      ;;

    -F | --next-figure)
      mapfile -t figures < <(find "$coursePath"/notes -regextype posix-extended -regex '.*fig_[0-9]{3}\.tex.*' | sort)
      if [[ ${#figures[@]} -gt 0 ]]; then
        lastNumber="$(echo "${figures[${#figures[@]} - 1]}" | sed 's/.*\/fig_\([0-9]\{3\}\).tex/\1/' | sed 's/[0]*\([1-9]*\)/\1/')"
        nextNumber=$(printf "%03d" $((lastNumber + 1)))
        echo "$(readlink -n "$CURRENTCOURSE")/notes/figures/fig_$nextNumber.tex"
      else
        echo "$(readlink -n "$CURRENTCOURSE")/notes/figures/fig_001.tex"
      fi
      shift
      ;;

    -l | --last-lecture)
      mapfile -t lectures < <(find "$coursePath"/notes -regextype posix-extended -regex '.*lec_[0-9]{3}\.tex.*' | sort)
      if [[ ${#lectures[@]} -gt 0 ]]; then
        echo "${lectures[${#lectures[@]} - 1]}"
      else
        echo -1
      fi
      shift
      ;;

    -L | --next-lecture)
      mapfile -t lectures < <(find "$coursePath"/notes -regextype posix-extended -regex '.*lec_[0-9]{3}\.tex.*' | sort)
      if [[ ${#lectures[@]} -gt 0 ]]; then
        lastNumber="$(echo "${lectures[${#lectures[@]} - 1]}" | sed 's/.*\/lec_\([0-9]\{3\}\).tex/\1/' | sed 's/[0]*\([1-9]*\)/\1/')"
        nextNumber=$(printf "%03d" $((lastNumber + 1)))
        echo "$(readlink -n "$CURRENTCOURSE")/notes/lec_$nextNumber.tex"
      else
        echo "$(readlink -n "$CURRENTCOURSE")/notes/lec_001.tex"
      fi
      shift
      ;;

    --list-active)
      find "$(readlink "$CURRENTQUARTER")" -mindepth 1 -maxdepth 1 -type d | while read -r dir; do
      # Check if the directory contains the file info.json
        if [ -f "$dir/info.json" ]; then
          echo "$dir"
        fi
      done
      shift
      ;;

    -h | --help)
      echoHelpMessage
      shift
      ;;

    --) shift;
      break 
      ;;
  esac
done
