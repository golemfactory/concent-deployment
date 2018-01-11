#! /bin/bash -e

DEFAULT_FILE_SIZE=1000000000
DEFAULT_FILE_COUNT=5

server_address="$1"
file_size="${2:-$DEFAULT_FILE_SIZE}"
file_count="${3:-$DEFAULT_FILE_COUNT}"


function file_generator {
    length="$1"

    # The number should be big enough to generate the file size we want. Can be higher but not smaller.
    seq 1000000000000000000000000000000000000000000000000000 | head --bytes "$length"
}


i=1
total_upload_time=0
while ((i <= "$file_count")); do
    echo ====================== UPLOAD $i ======================

    upload_start_time="$(date +%s)"
    file_generator "$file_size" |                              \
        curl                                                   \
            --request POST                                     \
            --connect-timeout 10                               \
            --fail                                             \
            --include                                          \
            --header "Concent-Upload-Path: a/b/c/test-file-$i" \
            --data-binary @-                                   \
            "http://$server_address/upload/"
    upload_end_time=$(date +%s)
    total_upload_time=$(("$total_upload_time" + "$upload_end_time" - "$upload_start_time"))
    echo "Uploaded file: 'a/b/c/test-file-$i' time: $(("$upload_end_time" - "$upload_start_time"))s"
    ((i++))
done

printf "\n\n%s\n\n\n\n" "Total upload time: ${total_upload_time}s"

i=1
total_download_time=0
while ((i <= "$file_count")); do
    http_status="$(
        curl                                                     \
            --head                                               \
            --silent                                             \
            --output    /dev/null                                \
            --write-out "%{http_code}\n"                         \
            "http://$server_address/download/a/b/c/test-file-$i" \
    )"
    if [[ "$http_status" == "404" ]]; then
        echo "File a/b/c/test-file-$i does not exist."
        exit 1
    fi

    echo ===================== DOWNLOAD $i =====================

    download_start_time="$(date +%s)"
    content="$(
        curl                                                       \
            --connect-timeout 10                                   \
            --fail                                                 \
            "http://$server_address/download/a/b/c/test-file-$i" | \
        md5sum                                                     \
    )"
    if [[ $(file_generator "$file_size" | md5sum) == "$content" ]]; then
        echo "File a/b/c/test-file-$i matches downloaded content."
    else
        echo "File a/b/c/test-file-$i does not match downloaded content."
        exit 1
    fi
    download_end_time=$(date +%s)
    total_download_time=$(("$total_download_time" + "$download_end_time" - "$download_start_time"))

    echo "Downloaded file: 'a/b/c/test-file-$i' time: $(("$download_end_time" - "$download_start_time"))s"
    ((i++))
done

printf "\n\n%s\n" "Total download time: "$total_download_time"s"
