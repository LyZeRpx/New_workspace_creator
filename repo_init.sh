#!/bin/bash
#First step : initialize the repo
export REPO=${HOME}/new_workspace_creator
mkdir -p src
mkdir -p headers

cp ${REPO}/Makefile .
echo Please enter project_name :
read project_name
echo "Please enter the project binary name (Located on your beautiful PDF)" :
read binary_name
sed -i "16iNAME = $binary_name" Makefile
cp ${REPO}/headers/project.h headers/$project_name.h
sed -i "8i#ifndef ${project_name^^}_H" headers/$project_name.h
sed -i "9i \ \ \ \ #define ${project_name^^}_H" headers/$project_name.h
mkdir -p main
cp ${REPO}/main/main.c main/main.c
mkdir -p libraries
cp ${REPO}/.gitignore .
sed -i "1i${binary_name}" .gitignore
status=0
YES="Y"
NO="n"
LDFLAGS="LDFLAGS = -L./libraries"
lib_flag=" -l"

#auto lib lmport
import_lib() {
    echo "Which one ? (enter libray name without lib prefix)"
    echo List of Avaliable Libraries : ; ls --color=auto ${REPO}/custom_libs
    read lib_name
    cp -r ${REPO}/custom_libs/lib$lib_name ./libraries/lib$lib_name 2> /dev/null
    if [ "$?" == 1 ]; then
        echo "Library does not exist (Error:1)"
        echo "Does your library exists but has an unformatted name ? (Y or n)"
        read input
        if [ "$input" == "$YES" ]; then
            echo "Enter non-formatted library name"
            read lib_name
            cp -r ${REPO}/custom_libs/$lib_name ./libraries/$lib_name 2> /dev/null
            if [ "$?" == 1 ]; then
                echo "Library does not exist (Error:2)"
            else
                echo $lib_name sucessfully imported !
                echo "Enter compilation flag (if name = libname.a, write name)"
                read lib_name
                STOCK=$LDFLAGS
                LDFLAGS=$LDFLAGS$lib_flag$lib_name
            sed -i "s|$STOCK|$LDFLAGS|g" Makefile
            fi
        elif [ "$input" == "$NO" ]; then
            echo "Do you want to import another library ? (Y or n)"
            read input
            if [ "$input" == "$YES" ]; then
                import_lib
            elif [ "$input" == "$NO" ]; then
                echo Workspace has been sucessfully initialized
                exit
            else
                echo "Please type either Y (Yes) or n (no)."
                import_lib
            fi
            echo Workspace has been sucessfully initialized
            exit
        else
            echo "Please type either Y (Yes) or n (no)."
            import_lib
        fi
    else
        STOCK=$LDFLAGS
        LDFLAGS=$LDFLAGS$lib_flag$lib_name
        sed -i "s|$STOCK|$LDFLAGS|g" Makefile
        echo lib$lib_name sucessfully imported !
    fi
    echo "Do you want to import another library ? (Y or n)"
    read input
    if [ "$input" == "$YES" ]; then
        import_lib
    elif [ "$input" == "$NO" ]; then
        echo Workspace has been sucessfully initialized
        exit
    else
        echo "Please type either Y (Yes) or n (no)."
        import_lib
    fi
}

while true; do
    echo "Do you want to import some custom librairies ? (Y or n)"
    read input
    if [ "$input" == "$YES" ]; then
        sed -i "22i$LDFLAGS" Makefile
        import_lib
    elif [ "$input" == "$NO" ]; then
        echo Workspace has been sucessfully initialized
        exit
    else
        echo "Please type either Y (Yes) or n (no)."
        continue
    fi
    break
done
