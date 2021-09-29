#!/usr/bin/env bash

function confirm_action {
  local message="${1:-"Confirm?"}"
  local response=$(echo -e "No\nYes" | rofi -dmenu -i -p "$message ")

  if [ "$response" = "Yes" ]; then
    true;
  else
    false;
  fi
}

# Use ~/.config/myrmidon/tasks.json as default, otherwise use incoming path
config_file="${1:-"$HOME/.config/myrmidon/tasks.json"}"
tasks=$(cat $config_file)

# Pass tasks to rofi, and get the output as the selected option
selected=$(echo $tasks | jq -j 'map(.name) | join("\n")' | rofi -dmenu -matching fuzzy -i -p "Search tasks")
task=$(echo $tasks | jq ".[] | select(.name == \"$selected\")")

# Exit if no task was found
if [[ $task == "" ]]; then
  echo "No task defined as '$selected' within config file."
  exit 1
fi

task_command=$(echo $task | jq ".command")
confirm=$(echo $task | jq ".confirm")

# Check whether we need confirmation to run this task
if [[ $confirm == "true" ]]; then
  if ! confirm_action 'Confirm $selected?'; then
    exit
  fi
fi

# Run the task
eval "\"$task_command\" > /dev/null &"

notification=$(echo $task | jq ".notification")
if [ ! "$notification" == 'null' ]
then
    eval "notify-send $notification > /dev/null &"
fi
