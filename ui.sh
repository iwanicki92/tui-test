#!/bin/bash

config=config.yml
width=$(yq .settings.width $config)
border_char=$(yq .settings.border_char $config)
command_section_counter=1
declare -A commands

print_wrapped_lines() {
  fold -s -w "${width}"
}

print_section_name() {
  local name="$1"
  name="$(trim_string "$name" "$((width - 4))")"
  local length="${#name}"
  local left_chars=$(((width - length)/2))
  local right_chars=$((width - length - left_chars))
  for ((i=1; i<= left_chars; ++i)); do
    printf '%c' "${border_char}"
  done
  printf '%s' "${name}"
  for ((i=1; i<= right_chars; ++i)); do
    printf '%c' "${border_char}"
  done
  printf '\n'
}

print_section_line() {
  local line="$1"
  line="$(trim_string "$line" "$((width - 4))")"
  local length="${#line}"
  local right_chars=$((width - length - 2))
  printf '%c %s' "${border_char}" "${line}"
  for ((i=1; i< right_chars; ++i)); do
    printf '%c' " "
  done
  printf '%c\n' "${border_char}"
}

trim_string() {
  local string="$1"
  local length=${2:-width}
  local trimmed
  trimmed=$(head -1 <<<"${string}" | tr '\t' ' ')
  if [ "${#trimmed}" -gt "${length}" ]; then
    trimmed="$(head -c "$((length-3))" <<<"${trimmed}")"
    echo "${trimmed}..."
  else
    echo "${trimmed}"
  fi
}

draw_borderless_section() {
  local section="$1"
  command="$(yq .command <<<"${section}")"
  echo "$(eval "${command}" 2>&1 </dev/null)" | print_wrapped_lines
}

draw_static_section() {
  local section="$1"
  local element
  local element_name
  name="$(yq .name <<<"$section")"
  print_section_name "${name}"
  while IFS= read -r -d '' element; do
    element_name="$(yq .name <<<"${element}")"
    command="$(yq .command <<<"${element}")"
    line="${element_name}: $(eval "${command}" 2>&1 </dev/null)"
    print_section_line "${line}"
  done < <(yq --nul-output '.elements[]' <<<"${section}")
}

draw_command_section() {
  local section="$1"
  local element
  local element_name
  name="$(yq .name <<<"$section")"
  print_section_name "${name}"
  while IFS= read -r -d '' element; do
    element_name="$(yq .name <<<"${element}")"
    command="$(yq .command <<<"${element}")"
    line="${command_section_counter}) ${element_name}"
    visible_defined="$(yq 'has("visible") // false' <<<"${element}")"
    visible="true"
    if [ "${visible_defined}" = "true" ]; then
      visible_command="$(yq '.visible' <<<"${element}")"
      if ! _=$(eval "${visible_command}" &>/dev/null </dev/null); then
        visible="false"
      fi
    fi
    if [ "${visible}" = "true" ]; then
      commands["${command_section_counter}"]="${command}"
      print_section_line "${line}"
    fi
    command_section_counter=$((command_section_counter + 1))
  done < <(yq --nul-output '.elements[]' <<<"${section}")
}

draw_section() {
  local section="$1"
  section_type="$(yq '.type' <<<"${section}")"
  if [[ $(type -t "draw_${section_type}_section") == function ]]; then
    "draw_${section_type}_section" "${section}"
  fi
}

draw_ui() {
  local section
  command_section_counter=1
  while IFS= read -r -d '' section; do
    draw_section "$section"
  done < <(yq --nul-output '.sections[]' ${config})
  print_section_name ""
}

while true; do
  clear
  draw_ui
  read -n1 choice
  if [ "${commands["${choice}"]+isset}" ]; then
    clear
    # stdbuf -i0 -oL -eL ${commands["${choice}"]} | print_wrapped_lines
    stdbuf -i0 -oL -eL ${commands["${choice}"]}
    read -p "Press Enter to continue"
  fi
done
