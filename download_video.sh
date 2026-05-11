#!/bin/bash

# Скрипт для скачивания видео/аудио через yt-dlp
# Сохраняет файлы в директорию, доступную для Android плеера

TERMUX_STORAGE="$HOME/storage/shared"
DOWNLOAD_DIR="$TERMUX_STORAGE/Media"
LOG_FILE="$HOME/download.log"

if [ ! -d "$TERMUX_STORAGE" ]; then
    echo "Ошибка: хранилище Termux не настроено!"
    echo "Выполните команду: termux-setup-storage"
    exit 1
fi

mkdir -p "$DOWNLOAD_DIR"

echo "Папка для загрузок: $DOWNLOAD_DIR"

print_menu() {
    echo "========================================"
    echo "   YouTube/Audio Downloader для Termux"
    echo "========================================"
    echo "1. Скачать видео (MP4)"
    echo "2. Скачать аудио (MP3)"
    echo "3. Скачать видео в лучшем качестве"
    echo "4. Скачать только аудио (FLAC)"
    echo "5. Посмотреть загруженные файлы"
    echo "6. Удалить файл"
    echo "0. Выход"
    echo "========================================"
}

get_url() {
    read -p "Введите ссылку на видео: " url
    if [[ -z "$url" ]]; then
        echo "Ошибка: ссылка не введена!"
        return 1
    fi
    echo "$url"
}

download_video() {
    url=$(get_url)
    [[ -z "$url" ]] && return

    echo "Скачивание видео..."
    yt-dlp -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" \
           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
           "$url" 2>&1 | tee -a "$LOG_FILE"

    echo "Готово! Файл сохранён в: $DOWNLOAD_DIR"
}

download_audio_mp3() {
    url=$(get_url)
    [[ -z "$url" ]] && return

    echo "Скачивание аудио (MP3)..."
    yt-dlp -x --audio-format mp3 \
           --audio-quality 0 \
           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
           "$url" 2>&1 | tee -a "$LOG_FILE"

    echo "Готово! Аудио сохранено в: $DOWNLOAD_DIR"
}

download_best_quality() {
    url=$(get_url)
    [[ -z "$url" ]] && return

    echo "Скачивание в лучшем качестве..."
    yt-dlp \
           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
           "$url" 2>&1 | tee -a "$LOG_FILE"

    echo "Готово! Файл сохранён в: $DOWNLOAD_DIR"
}

download_audio_flac() {
    url=$(get_url)
    [[ -z "$url" ]] && return

    echo "Скачивание аудио (FLAC)..."
    yt-dlp -x --audio-format flac \
           -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
           "$url" 2>&1 | tee -a "$LOG_FILE"

    echo "Готово! Аудио сохранено в: $DOWNLOAD_DIR"
}

list_files() {
    echo "========================================"
    echo "Загруженные файлы:"
    echo "========================================"
    if [[ -d "$DOWNLOAD_DIR" ]]; then
        ls -lh "$DOWNLOAD_DIR" 2>/dev/null | tail -n +2
        echo ""
        echo "Всего файлов: $(ls -1 "$DOWNLOAD_DIR" | wc -l)"
    else
        echo "Папка не существует"
    fi
}

delete_file() {
    list_files
    read -p "Введите имя файла для удаления: " filename
    if [[ -n "$filename" && -f "$DOWNLOAD_DIR/$filename" ]]; then
        rm "$DOWNLOAD_DIR/$filename"
        echo "Файл удалён!"
    else
        echo "Файл не найден!"
    fi
}

if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp не установлен. Установка..."
    pkg update && pkg install yt-dlp
fi

while true; do
    print_menu
    read -p "Выберите пункт: " choice
    case $choice in
        1) download_video ;;
        2) download_audio_mp3 ;;
        3) download_best_quality ;;
        4) download_audio_flac ;;
        5) list_files ;;
        6) delete_file ;;
        0) echo "До свидания!"; exit 0 ;;
        *) echo "Неверный выбор!" ;;
    esac
    echo ""
    read -p "Нажмите Enter для продолжения..."
done