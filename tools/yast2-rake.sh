#
# rake tab completetion.
#
# Developed for yast project, however tries to be as generic as possible.
#
# Glossary:
# When rake command has format of sequence of words delimited by colon such as
# word1:word2:word3:... or word1 then
# - top level command is word1 from the above examples
# - sub command is any other word than word1
# - command is top level command together with zero or more sub commands
#
# TODO:
# - turn rake cache into an array, get rid of greping in _rake* functions
#   do array filtering instead and put result directly into COMPREPLY
# - do not cache "rake " prefix at the begining of each line produced by 'rake -T'
# - disable completetion when command is complete (currently it sometimes repeats
# - last completed word)
#

#
# Finds top level commands without subcommands
#
_rake_top_level_commands_simple()
{
  echo $(echo "${rake_cache}" | fgrep -v ":" | cut -d ' ' -f2)
}

#
# Finds complex top level commands (those which have at least one subcommand)
#
_rake_top_level_commands_complex()
{
  echo $(echo "${rake_cache}" | cut -d ' ' -f2 | cut -d ":" -f1 -s | uniq)
}

#
# Finds all available top level commands
#
_rake_top_level_commands()
{
  local simple=$(_rake_top_level_commands_simple)
  local complex=$(_rake_top_level_commands_complex)

  echo "${simple} ${complex}"
}

#
# tries to find subcommands for given command
#
_rake_subcommands()
{
  local cmd=${1%${1##*:}}
  echo $(echo "${rake_cache}" | fgrep "${1}" | cut -d ' ' -f2 | sed "s/${cmd}//" | cut -d ':' -f1)
}

#
# checks if given command has subcommands
#
# e.g. when rake -T is:
#   rake oneliner
#   rake faked:four:level:command
# then result is
#   true for faked:, faked:four, etc
#   false for oneliner
#
_rake_has_subcommands()
{
  echo "${rake_cache}" | fgrep -q "$1:"
}

#
# Feeds bash with completition proposal
#
_rake()
{
  local rake_cmd="${COMP_LINE#rake}"
  local commands_available=""

  case ${rake_cmd} in
    *:* | *:)
      commands_available=$(_rake_subcommands ${rake_cmd})
      COMPREPLY=( $(compgen -W "${commands_available}") )
      ;;

    * | "")
      commands_available=$(_rake_top_level_commands)
      COMPREPLY=( $(compgen -W "${commands_available}" -- ${rake_cmd}) )
      ;;
  esac

  if [[ ${#COMPREPLY[*]} -eq 1 ]]; then
    if _rake_has_subcommands "${COMPREPLY[0]}"; then
      COMPREPLY=( "${COMPREPLY[0]}:" )
    else
      COMPREPLY=( "${COMPREPLY[0]} " )
    fi
  fi

  return 0
}

rake_cache=$(rake -T 2> /dev/null | sed "s/\[[^]]*]//") && complete -F _rake -o nospace rake
#rake_cache=$(echo -e "rake onelevel\nrake faked:four:level:command") && complete -F _rake -o nospace rake
