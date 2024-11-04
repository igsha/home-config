#!/usr/bin/env bash
set -euo pipefail

PACKAGESLISTFILE="@packagesList@"
readarray -t USAGE << EOM
$0 dotfilesdir [-n] [-D] [-p package-list-file] | -h
package file: $PACKAGESLISTFILE
EOM
DOTFILESDIR=
DRYRUN=0
NODOT=0
VERBOSE=0

ARGS=$(getopt -u -o nhDp:v -l dry-run,help,no-dotfiles,package-list:,verbose -- "$@")
eval "set -- $ARGS"
while [[ $# -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRYRUN=1;;
        -h|--help) printf "%s\n" "${USAGE[@]}" && exit 0;;
        -D|--no-dotfiles) NODOT=1;;
        -p|--package-list) PACKAGESLISTFILE="$2"; shift;;
        -v|--verbose) VERBOSE=1;;
        --) ;;
        *)
            [[ -z "$DOTFILESDIR" ]] || { echo "Too many dotfilesdir: $1"; exit 1; }
            DOTFILESDIR=${1%/};;
    esac
    shift
done

[[ -n "$DOTFILESDIR" ]] || { echo "No dotfilesdir supplied"; exit 2; }

runorskip() {
    if [[ "$DRYRUN" -eq 0 ]]; then "$@"; fi
}

logverbose() {
    if [[ "$VERBOSE" -eq 1 ]]; then echo "$@"; fi
}

readarray -t DIRS < "$PACKAGESLISTFILE"
for dir in "${DIRS[@]}"; do
    SEARCHDIR="$DOTFILESDIR/$dir"
    readarray -t FILES < <(find $SEARCHDIR \( -type f -o -type l \) -printf '%P\n')
    for file in "${FILES[@]}"; do
        TARGET="$HOME/$file"
        if [[ "$NODOT" -eq 0 ]]; then
            TARGET="$(sed 's/dot-/\./g' <<< "$TARGET")"
        fi

        TARGETDIR="$(dirname "$TARGET")"
        SOURCE="$DOTFILESDIR/$dir/$file"
        if [[ ! -d "$TARGETDIR" ]]; then
            echo Creating dir $TARGETDIR ...
            runorskip mkdir -p "$TARGETDIR"
        fi

        if [[ -e "$TARGET" ]]; then
            if [[ "$(realpath "$SOURCE")" != "$(realpath "$TARGET")" ]]; then
                echo "Remove $TARGET cause it is not $SOURCE" && exit 3
            else
                logverbose "Check $TARGET => $SOURCE"
            fi
        else
            echo "Creating link $SOURCE => $TARGET ..."
            runorskip ln -s "$SOURCE" "$TARGET"
        fi
    done
done
