find_imports() {
    FILES=( $(find . -name *.${1}) )

    if [ ${1} == "groovy" ]; then
        semi_colon=""
    else
        semi_colon=";"
    fi

    for i in ${FILES[@]}; do
        import_regex="s/import\s.+\.(.+)${semi_colon}$/\1/g"
        imported_classes=( $(cat ${i} | grep "import" | sed -E ${import_regex}) )
        echo $i
        for class in ${imported_classes[@]}; do
            echo $class
            class_use=$(cat ${i} | grep ${class} | grep -v "import")
            #if [ -z "${class_use}" ]; then
                #echo "Imported class $class not used in file ${i}. Remove it!"
            #fi
        done
    done
}

#find_imports groovy
find_imports java
