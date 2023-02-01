#!/bin/bash

# создает файл с настройками по умолчанию, если его нет
create(){
    if ! [ -f $settings_path ]; then
        echo -e "$def_config" > $settings_path
    fi

   # создает файл с настройками по умолчанию, если его нет
}

def_config="extension_temp_files=.log
extensions_work_files=.py
command=\"grep def* program.py >last.log\"
work_d=$(pwd)"
settings_path=$(realpath ./.myconfig)

is_silence="false"
create
. $settings_path
eval cd "$work_d"


# Вывод меню
menu(){
    echo "--------------------------------------------------------------------------------------"
    echo "\nсписок расширений временных файлов: $extension_temp_files\n"
    echo "список расширений рабочих файлов: $extensions_work_files\n"
    echo "рабочая папка скрипта: $work_d\n"
    echo "записанная команда: $command\n"

    echo """1)  Посмотреть список расширений временных файлов
2)  Задать заново список расширений временных файлов
3)  Добавить расширение в список расширений временных файлов
4)  Удалить расширение из списка временных файлов
5)  Посмотреть список расширений рабочих файлов
6)  Задать заново список расширений рабочих файлов
7)  Добавить расширение в список расширений рабочих файлов
8)  Удалить расширение из списка рабочих файлов
9)  Посмотреть рабочую папку скрипта
10) Задать заново рабочую папку скрипта
11) Удалить все временные файлы
12) Посмотреть записанную команду
13) Выполнить записанную команду
14) Изменить записанную команду
15) просмотреть все строки, ограниченные апострофами, во всех рабочих файлах
16) Посмотреть объем каждого временного файла
0)  Выход\n"""
    echo "--------------------------------------------------------------------------------------"
}


# функция для обновления переменных в файле, в котором хранится конфиг
update_config(){

        settings="extension_temp_files=\"$extension_temp_files\"
extensions_work_files=\"$extensions_work_files\"
command=\"$command\"
work_d=$work_d"
        echo -e "$settings" > $settings_path

}

# 1, 5
# Функция для просмотра списка расширний
print_list_files(){
    for el in $1; do
        echo $el
    done
}

# 2, 6
# Функция для обновления списка расширений
update_list_files(){

    read -p "Введите новый список расширений: " new_extensions
    echo "$new_extensions"
}

# 3, 7
# Функция для добавления расширения в список расширений
add_extension_files(){
    read -p "Введите расширение, которое вы хотите добавить: " extension
    new_extensions="$1 $extension"
    echo "$new_extensions"
}

# 4, 8
# Функция для удаления расширения из списка расширений
delete_extension_files(){
    read -p "Введите номер расширения, которое вы хотите удалить: " number

    count=1
    new_extensions=""
    for extension in $1; do
        if [ $number -ne $count ]; then
            new_extensions="$new_extensions $extension"
        fi
        count=$(($count+1))
    done
    echo $new_extensions

}

# 9
# Функция для просмотра рабочей папки скрипта
print_work_dir_script(){
    echo $work_d
}

# 10
# Функция для изменения рабочей папки скрипта
change_work_dir_script(){
    read -p "Введите новый абсолютный путь до рабочей папки: " way
    eval cd $way
    echo $(pwd)
}


# 11
# Функция удаления всех временных файлов в рабочей папке
delete_temp_files() {
    echo

    for i in $extension_temp_files; do
        find "$work_d" -name "*$i" -type f -delete
    done

    echo -e 'Все временные файлы в рабочей папке успешно удалены.'
}

# 12
# Функция для просмотра команды

print_command(){
    echo $command
}

# 13
# Функция для выполнения записанной команды
complete_command(){
    eval cd $work_d
    if eval $command 2>/dev/null; then
        echo "Команда успешно выполнена!"
    else
        echo "Невозможно выполнить команду. Во время выполнения возникли ошибки."
    fi
}

# 14
# Функция для изменения записанной команды
change_command(){
    read -p "Введите новую команду: " command
    echo $command

}

# 15
# Возможность просмотреть все строки,
# ограниченные апострофами, во всех рабочих файлах.

view_lines() {
    for i in $extensions_work_files; do
        files="$work_d/*$i"
        for file in $files; do
            line=$(grep -o "'[^']*'" $file 2> /dev/null)
            OLD_IFS=$IFS
            IFS=$'\n'
            for s in $line; do
                if [ -n "$s" ]; then
                    echo "$file" "$s"
                fi
            IFS=$OLD_IFS
            done
        done
    done

}

# 16
# Посмотреть объем каждого временного файла
print_volume_temp_files() {
    echo 'Объём каждого временного файла (в байтах):'

    for i in $extension_temp_files; do
        find "$work_d" -name "*$i" -type f -exec wc -c {} \;
    done
}

# Удаление элемента из списка расширений (тихий режим)
delete_extension_files_s() {
    count=1
    new_extensions=""
    for extension in $1; do
        if [ $2 -ne $count ]; then
            new_extensions="$new_extensions $extension"
        fi
        count=$(($count+1))
    done
    echo $new_extensions


}


# Функция для изменения рабочей папки скрипта (тихий режим)
change_work_dir_script_s(){

    eval cd "$1"
    echo $(pwd)
}




# Выполнение основного скрипта
if [ "$1" = "-s" ]; then

    if [ "$2" = 1 ]; then
        print_list_files "$extension_temp_files"
    elif [ "$2" = 2 ]; then
        shift
        shift
        extension_temp_files="$@"
        update_config
    elif [ "$2" = 3 ]; then
        extension_temp_files="$extension_temp_files"" $3"
        update_config
    elif [ "$2" = 4 ]; then
        extension_temp_files=$(delete_extension_files_s "$extension_temp_files" "$3")
        update_config
    elif [ "$2" = 5 ]; then
        print_list_files "$extensions_work_files"
    elif [ "$2" = 6 ]; then
        shift
        shift
        extensions_work_files="$@"
        update_config
    elif [ "$2" = 7 ]; then
        extensions_work_files="$extensions_work_files"" $3"
        update_config
    elif [ "$2" = 8 ]; then
        extensions_work_files=$(delete_extension_files_s "$extensions_work_files" "$3")
        update_config
    elif [ "$2" = 9 ]; then
        print_work_dir_script
    elif [ "$2" = 10 ]; then
        work_d=$(change_work_dir_script_s "$3")
        update_config
    elif [ "$2" = 11 ]; then
        delete_temp_files
    elif [ "$2" = 12 ]; then
        print_command
    elif [ "$2" = 13 ]; then
        complete_command
    elif [ "$2" = 14 ]; then
        command="$3"
        update_config
    elif [ "$2" = 15 ]; then
        view_lines
    elif [ "$2" = 16 ]; then
        print_volume_temp_files
    elif [ "$2" = 0 ]; then
        exit
    else
        echo "Неверно введен второй параметр скрипта!"
    fi
else


    while true; do
        menu
        read -p 'Введите номер функции: ' choice
        if [ $choice = 1 ]; then   # Посмотреть список расширений временных файлов

            print_list_files "$extension_temp_files"
        elif [ $choice = 2 ]; then # Задать заново список расширений временных файлов
            extension_temp_files=$(update_list_files)
            update_config
        elif [ $choice = 3 ]; then # Добавить расширение в список расширений временных файлов
            extension_temp_files=$(add_extension_files "$extension_temp_files")
            update_config
        elif [ $choice = 4 ]; then # Удалить расширение из списка временных файлов
            extension_temp_files=$(delete_extension_files "$extension_temp_files")
            update_config
        elif [ $choice = 5 ]; then # Посмотреть список расширений рабочих файлов
            print_list_files "$extensions_work_files"
        elif [ $choice = 6 ]; then # Задать заново список расширений рабочих файлов
            extensions_work_files=$(update_list_files)
            update_config
        elif [ $choice = 7 ]; then # Добавить расширение в список расширений временных файлов
            extensions_work_files=$(add_extension_files "$extensions_work_files")
            update_config
        elif [ $choice = 8 ]; then # Удалить расширение из списка временных файлов
            extensions_work_files=$(delete_extension_files "$extensions_work_files")
            update_config
        elif [ $choice = 9 ]; then # Посмотреть рабочую папку скрипта
            print_work_dir_script
        elif [ $choice = 10 ]; then # Задать заново рабочую папку скрипта
            work_d=$(change_work_dir_script)
            update_config
        elif [ $choice = 11 ]; then
            delete_temp_files
        elif [ $choice = 12 ]; then
            print_command
        elif [ $choice = 13 ]; then
            complete_command
        elif [ $choice = 14 ]; then
            command=$(change_command)
            update_config
        elif [ $choice = 15 ]; then
            view_lines
        elif [ $choice = 16 ]; then
            print_volume_temp_files
        elif [ $choice = 0 ]; then
            exit 1
        else
            echo 'Некорректно введен номер функции!'
        fi
    done
fi

