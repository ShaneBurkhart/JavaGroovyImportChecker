RED_BOLD="\033[1;31m"
RED="\033[0;31m"
YELLOW_BOLD="\033[1;33m"
YELLOW="\033[0;33m"
NO_COLOR="\033[0m"

find_imports() {
    FILES=( $(find . -name *.${1}) )

    unused_imports=()
    star_imports=()

    if [ ${1} == "groovy" ]; then
        semi_colon=""
    else
        semi_colon=";"
    fi

    for i in "${FILES[@]}"; do
	used_star=false
	import_grep_regex="[ \t]*import[ \t](.*[ \t])?.+${semi_colon}$"
	import_sed_regex="s/[ \t]*import[ \t](.*[ \t])?(.+)${semi_colon}$/\2/p"

	import_paths=( $(grep -E "${import_grep_regex}" ${i} | sed -rn "${import_sed_regex}") )

	for p in ${import_paths[@]}; do
	    # Windows.... Puts new carriage returns on files so regex doesn't recognize.
	    tp=$(echo ${p} | tr -d '\r' | tr -d '\n')
	    if [[ ${tp} =~ \*\s*$ ]]; then
		used_star=true
		break
	    fi
	    class=$(echo ${tp} | gawk 'BEGIN { FS = "." }; { print $NF }')
	    import_use=$(grep ${class} ${i} | grep -v "import")
	    if [ -z "${import_use}" ]; then
		unused_imports+=("${RED_BOLD}${i}:${RED} class ${RED_BOLD}${class}${RED} not used. Remove it!${NO_COLOR}")
	    fi
	done

	if $used_star; then
	    star_imports+=("${YELLOW_BOLD}${i}:${YELLOW} contains a star import. Please don't use a star...${NO_COLOR}")
	fi
    done

    for i in "${star_imports[@]}"; do
	echo -e "${i}"
    done
    for i in "${unused_imports[@]}"; do
	echo -e "${i}"
    done
}

find_imports groovy
find_imports java
