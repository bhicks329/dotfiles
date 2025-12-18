#!/usr/bin/env bash

# Dotfiles Pre-Check Script
# Run this BEFORE setup.sh to see what will change
# and optionally create machine-specific overrides

set -e

dotfilesdir="$(pwd)"
source ./setup/lib.sh

# Machine detection
MACHINE_NAME=${DOTFILES_MACHINE:-$(hostname -s)}
MACHINE_DIR="$dotfilesdir/machines/$MACHINE_NAME"

# Use colors from lib.sh but add BOLD and RESET for compatibility
BOLD="\033[1m"
RESET="\033[0m"

get_config_path() {
  local config_dir=$1
  local machine_override="$MACHINE_DIR/$config_dir"
  local base_path="$dotfilesdir/base/$config_dir"

  if [ -d "$machine_override" ]; then
    echo "$machine_override"
  else
    echo "$base_path"
  fi
}

awesome_header
botintro "Dotfiles Pre-Check"
printf "Hostname: %b%s%b\n" "$BOLD" "$(hostname -s)" "$RESET"
if [ -n "${DOTFILES_MACHINE:-}" ]; then
  printf "Machine profile override (DOTFILES_MACHINE): %b%s%b\n\n" "$BOLD" "$MACHINE_NAME" "$RESET"
else
  printf "Machine profile: %b%s%b\n\n" "$BOLD" "$MACHINE_NAME" "$RESET"
fi

# Source files to check
source ./setup/files.sh

# Track changes
declare -a actions_needed=()
declare -a correct_links=()
declare -a using_base=()
declare -a using_machine=()

bot "Checking current dotfiles status...\n"

# Check directory symlinks
action "Checking directory symlinks"
for dir in "${dotfilesdirarray[@]}"; do
  target_dir="${dir/$dotfilesdir\/base/$HOME}"
  target_dir="${target_dir/$MACHINE_DIR/$HOME}"
  dir_name=$(basename "$dir")

  # Determine if this is a machine override or base
  is_machine_override=false
  if [[ "$dir" == *"/machines/$MACHINE_NAME/"* ]]; then
    is_machine_override=true
  fi

  if [ -e "$target_dir" ] && [ ! -L "$target_dir" ]; then
    # Exists but not a symlink
    warn "  ⚠ $dir_name exists as a regular directory (not symlink)"
    actions_needed+=("DIR:$target_dir:$dir:REPLACE")
  elif [ -L "$target_dir" ]; then
    current_target=$(readlink "$target_dir")
    if [ "$current_target" = "$dir" ]; then
      # Correctly linked
      if $is_machine_override; then
        printf "  ✓ %s → machine override\n" "$dir_name"
        using_machine+=("DIR:$dir_name")
      else
        printf "  ✓ %s → base\n" "$dir_name"
        using_base+=("DIR:$dir_name")
      fi
      correct_links+=("DIR:$target_dir")
    else
      # Linked to wrong location
      warn "  ⚠ $dir_name links to wrong location"
      actions_needed+=("DIR:$target_dir:$dir:RELINK:$current_target")
    fi
  else
    # Doesn't exist yet
    printf "  + %s will be newly created\n" "$dir_name"
    actions_needed+=("DIR:$target_dir:$dir:CREATE")
  fi
done

# Check file symlinks
action "Checking file symlinks"
for config_dir in "${dotfilesfilearray[@]}"; do
  declare -a tmparr=()

  # Find files to symlink
  while IFS= read -r -d $'\0'; do
    tmparr+=("$REPLY")
  done < <(find "$config_dir" -maxdepth 1 -type f \( -name ".*" -o -name "*.cfg" -o -name "*.conf" \) -a -not -name .DS_Store -not -name .git -not -name .osx -not -name .macos -not -name "*.sh" -print0 2>/dev/null)

  for file in "${tmparr[@]}"; do
    filename=$(basename "$file")
    target_file="$HOME/$filename"

    # Determine if this is a machine override or base
    is_machine_override=false
    base_file="$dotfilesdir/base/${file#$dotfilesdir/base/}"
    base_file="${base_file#$MACHINE_DIR/}"

    if [[ "$file" == *"/machines/$MACHINE_NAME/"* ]]; then
      is_machine_override=true
    fi

    if [ -e "$target_file" ] && [ ! -L "$target_file" ]; then
      # File exists and is not a symlink
      if diff -q "$file" "$target_file" &>/dev/null; then
        printf "  ✓ %s (identical content, not symlinked)\n" "$filename"
        actions_needed+=("FILE:$target_file:$file:CONVERT")
      else
        warn "  ⚠ $filename exists with different content"
        actions_needed+=("FILE:$target_file:$file:CONFLICT")
      fi
    elif [ -L "$target_file" ]; then
      current_target=$(readlink "$target_file")
      if [ "$current_target" = "$file" ]; then
        # Correctly linked
        if $is_machine_override; then
          printf "  ✓ %s → machine override\n" "$filename"
          using_machine+=("FILE:$filename")
        else
          printf "  ✓ %s → base\n" "$filename"
          using_base+=("FILE:$filename")
        fi
        correct_links+=("FILE:$target_file")
      else
        # Check if linked to base but machine override exists
        machine_version="$MACHINE_DIR/${file#$dotfilesdir/base/}"
        if [ -f "$machine_version" ] && [ "$current_target" != "$machine_version" ]; then
          warn "  ⚠ $filename linked to base, but machine override available"
          actions_needed+=("FILE:$target_file:$machine_version:UPGRADE:$current_target")
        else
          warn "  ⚠ $filename links to different location"
          actions_needed+=("FILE:$target_file:$file:RELINK:$current_target")
        fi
      fi
    else
      # Doesn't exist yet
      printf "  + %s will be newly created\n" "$filename"
      actions_needed+=("FILE:$target_file:$file:CREATE")
    fi
  done
done

# Summary
printf "\n"
botintro "Summary"
printf "  ✓ Correct links:      %b%d%b\n" "$COL_GREEN" "${#correct_links[@]}" "$COL_RESET"
printf "  📦 Using base:        %b%d%b\n" "$COL_BLUE" "${#using_base[@]}" "$COL_RESET"
printf "  🎯 Machine override:  %b%d%b\n" "$COL_GREEN" "${#using_machine[@]}" "$COL_RESET"
printf "  ⚠ Actions needed:    %b%d%b\n" "$COL_YELLOW" "${#actions_needed[@]}" "$COL_RESET"

# Handle actions needed
if [ ${#actions_needed[@]} -gt 0 ]; then
  printf "\n"
  botintro "Actions Needed"

  for action in "${actions_needed[@]}"; do
    IFS=':' read -r type target_path source_path action_type extra <<< "$action"
    filename=$(basename "$target_path")

    printf "\n%b━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%b\n" "$COL_YELLOW" "$COL_RESET"
    printf "%bFile:%b %s\n" "$BOLD" "$RESET" "$filename"

    case $action_type in
      CREATE)
        printf "%bStatus:%b Will be newly created\n" "$BOLD" "$RESET"
        printf "%bWill link to:%b %s\n" "$BOLD" "$RESET" "$source_path"
        continue
        ;;
      CONVERT)
        printf "%bStatus:%b File exists with identical content (not symlinked)\n" "$BOLD" "$RESET"
        printf "%bCurrent:%b %s (regular file)\n" "$BOLD" "$RESET" "$target_path"
        printf "%bWill link to:%b %s\n" "$BOLD" "$RESET" "$source_path"

        printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
        printf "  [%br%b] Replace file with symlink\n" "$COL_GREEN" "$COL_RESET"
        printf "  [%bs%b] Skip (leave as regular file)\n" "$COL_YELLOW" "$COL_RESET"
        printf "  [%bq%b] Quit precheck\n" "$COL_RED" "$COL_RESET"
        ;;
      REPLACE)
        printf "%bStatus:%b Exists as regular directory (not symlink)\n" "$BOLD" "$RESET"
        printf "%bCurrent:%b %s\n" "$BOLD" "$RESET" "$target_path"
        printf "%bShould link to:%b %s\n" "$BOLD" "$RESET" "$source_path"

        printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
        printf "  [%br%b] Replace with symlink (current will be backed up)\n" "$COL_BLUE" "$COL_RESET"
        printf "  [%bs%b] Skip for now\n" "$COL_YELLOW" "$COL_RESET"
        printf "  [%bq%b] Quit precheck\n" "$COL_RED" "$COL_RESET"
        ;;
      CONFLICT)
        printf "%bStatus:%b File exists with DIFFERENT content\n" "$BOLD" "$RESET"
        printf "%bCurrent:%b %s\n" "$BOLD" "$RESET" "$target_path"
        printf "%bDotfiles version:%b %s\n" "$BOLD" "$RESET" "$source_path"

        if [ "$type" = "FILE" ] && [ -f "$target_path" ]; then
          printf "\n%bDiff:%b\n" "$BOLD" "$RESET"
          diff -u "$target_path" "$source_path" 2>/dev/null || true
        fi

        printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
        printf "  [%bm%b] Create machine override (save current file)\n" "$COL_GREEN" "$COL_RESET"
        printf "  [%br%b] Replace with dotfiles version (discard current)\n" "$COL_BLUE" "$COL_RESET"
        printf "  [%bs%b] Skip for now\n" "$COL_YELLOW" "$COL_RESET"
        printf "  [%bq%b] Quit precheck\n" "$COL_RED" "$COL_RESET"
        ;;
      UPGRADE)
        printf "%bStatus:%b Currently using base, machine override available\n" "$BOLD" "$RESET"
        printf "%bCurrent link:%b %s\n" "$BOLD" "$RESET" "$extra"
        printf "%bMachine override:%b %s\n" "$BOLD" "$RESET" "$source_path"

        printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
        printf "  [%bu%b] Upgrade to machine override\n" "$COL_GREEN" "$COL_RESET"
        printf "  [%bk%b] Keep using base version\n" "$COL_BLUE" "$COL_RESET"
        printf "  [%bs%b] Skip for now\n" "$COL_YELLOW" "$COL_RESET"
        printf "  [%bq%b] Quit precheck\n" "$COL_RED" "$COL_RESET"
        ;;
      RELINK)
        printf "%bStatus:%b Symlink points to wrong location\n" "$BOLD" "$RESET"
        printf "%bCurrent link:%b %s\n" "$BOLD" "$RESET" "$extra"
        printf "%bShould link to:%b %s\n" "$BOLD" "$RESET" "$source_path"

        printf "\n%bOptions:%b\n" "$BOLD" "$RESET"
        printf "  [%br%b] Fix symlink\n" "$COL_GREEN" "$COL_RESET"
        printf "  [%bs%b] Skip for now\n" "$COL_YELLOW" "$COL_RESET"
        printf "  [%bq%b] Quit precheck\n" "$COL_RED" "$COL_RESET"
        ;;
    esac

    read -n 1 -p "Choice: " choice
    printf "\n"

    case $action_type in
      CONVERT)
        case $choice in
          r|R)
            # Convert file to symlink
            rm -f "$target_path"
            ln -s "$source_path" "$target_path"
            success "Converted: $filename is now symlinked"
            ;;
          s|S)
            warn "Skipped - leaving as regular file"
            ;;
          q|Q)
            cancelled "Exiting precheck"
            exit 0
            ;;
          *)
            warn "Invalid choice, skipping"
            ;;
        esac
        ;;
      REPLACE)
        case $choice in
          r|R)
            ok "Will be fixed during setup.sh"
            ;;
          s|S)
            warn "Skipped - will be prompted during setup.sh"
            ;;
          q|Q)
            cancelled "Exiting precheck"
            exit 0
            ;;
          *)
            warn "Invalid choice, skipping"
            ;;
        esac
        ;;
      RELINK)
        case $choice in
          r|R)
            # Fix the symlink now
            if [ -L "$target_path" ]; then
              unlink "$target_path"
            fi
            ln -s "$source_path" "$target_path"
            success "Fixed: $filename now links to $source_path"
            ;;
          s|S)
            warn "Skipped - will be prompted during setup.sh"
            ;;
          q|Q)
            cancelled "Exiting precheck"
            exit 0
            ;;
          *)
            warn "Invalid choice, skipping"
            ;;
        esac
        ;;
      CONFLICT)
        case $choice in
          m|M)
            # Create machine override
            relative_path="${source_path/$dotfilesdir\/base\//}"
            machine_path="$MACHINE_DIR/$relative_path"
            machine_dir=$(dirname "$machine_path")

            mkdir -p "$machine_dir"
            cp "$target_path" "$machine_path"
            success "Created machine override: $machine_path"

            # Now symlink to the machine override
            rm -f "$target_path"
            ln -s "$machine_path" "$target_path"
            success "Symlinked $filename to machine override"
            ;;
          r|R)
            # Replace with base version and create symlink
            rm -f "$target_path"
            ln -s "$source_path" "$target_path"
            success "Replaced: $filename now links to base version"
            ;;
          s|S)
            warn "Skipped - will be prompted during setup.sh"
            ;;
          q|Q)
            cancelled "Exiting precheck"
            exit 0
            ;;
          *)
            warn "Invalid choice, skipping"
            ;;
        esac
        ;;
      UPGRADE)
        case $choice in
          u|U)
            # Upgrade to machine override now
            if [ -L "$target_path" ]; then
              unlink "$target_path"
            fi
            ln -s "$source_path" "$target_path"
            success "Upgraded: $filename now uses machine override"
            ;;
          k|K)
            ok "Keeping base version"
            ;;
          s|S)
            warn "Skipped - will be prompted during setup.sh"
            ;;
          q|Q)
            cancelled "Exiting precheck"
            exit 0
            ;;
          *)
            warn "Invalid choice, skipping"
            ;;
        esac
        ;;
    esac
  done
fi

# Final status report
printf "\n"
botintro "Dotfiles Status Report"

printf "\n%bMachine:%b %s\n" "$BOLD" "$RESET" "$MACHINE_NAME"
printf "%bMachine directory:%b %s\n" "$BOLD" "$RESET" "$MACHINE_DIR"

if [ -d "$MACHINE_DIR" ]; then
  override_count=$(find "$MACHINE_DIR" -type f | wc -l | tr -d ' ')
  printf "%bMachine overrides:%b %s files\n" "$BOLD" "$RESET" "$override_count"
else
  warn "No machine-specific directory found"
fi

printf "\n%bConfiguration Status:%b\n" "$BOLD" "$RESET"
printf "  ✓ Correctly configured: %d\n" "${#correct_links[@]}"
printf "  📦 Using base: %d\n" "${#using_base[@]}"
printf "  🎯 Using machine overrides: %d\n" "${#using_machine[@]}"
printf "  ⚠ Need attention: %d\n" "${#actions_needed[@]}"

if [ ${#actions_needed[@]} -eq 0 ]; then
  printf "\n"
  success "Everything looks good! You're ready to run ./setup.sh"
else
  printf "\n"
  printf "Review the actions above before running %b./setup.sh%b\n" "$BOLD" "$RESET"
fi

printf "\n"
