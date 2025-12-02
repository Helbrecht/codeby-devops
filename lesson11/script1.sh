#!/bin/bash

# Получение домашней директории текущего пользователя
HOME_DIR=$HOME
FOLDER="$HOME_DIR/myfolder"

# Создание папки myfolder (опция -p не выводит предупреждение, если папка уже создана)
mkdir -p "$FOLDER"

# Вывод приветствия и текущего времени в файл 1
echo "HELLO" > "$FOLDER/file1.txt"
echo "Текущее время: $(date)" >> "$FOLDER/file1.txt"

# Создание пустого файла 2 с правами 777
touch "$FOLDER/file2.txt"
chmod 777 "$FOLDER/file2.txt"

# Создание файла 3 с 1 строкой из 20 рандомных символов
head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20 > "$FOLDER/file3.txt"

# Создание пустых файлов 4 и 5
touch "$FOLDER/file4.txt"
touch "$FOLDER/file5.txt"
