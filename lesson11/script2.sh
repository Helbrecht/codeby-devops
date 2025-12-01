#!/bin/bash

# Получение домашней директории текущего пользователя
HOME_DIR=$HOME
FOLDER="$HOME_DIR/myfolder"

# Подсчет количества файлов в папке myfolder
FILE_COUNT=$(find "$FOLDER" | wc -l)
echo "Количество файлов в папке myfolder: $FILE_COUNT"

# Исправление прав файла 2 с 777 на 664
test -f "$FOLDER/file2.txt" && chmod 664 "$FOLDER/file2.txt" && echo "Права файла file2.txt исправлены на 664"

# Определение пустых файлы и их удаление
for file in "$FOLDER"/*; do
  if [ ! -s "$file" ]; then
    rm "$file"
    echo "Удален пустой файл: $file"
  fi
done

# Удаление всех строк, кроме первой, в остальных файлах
for file in "$FOLDER"/*; do
  if [ -s "$file" ] && [ "$file" != "$FOLDER/file2.txt" ]; then
    sed -i '2,$d' "$file"
    echo "Оставлена только первая строка в файле: $file"
  fi
done
