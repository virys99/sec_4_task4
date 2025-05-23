#! /usr/bin/bash


function create_users(){

LOG_FILE=created_users1.log

MY_INPUT=$1

declare -a A_FIRST_NAME
declare -a A_LAST_NAME
declare -a A_USERNAME
declare -a A_PASS
declare -a A_GROUP
while IFS=, read -r FirstName LastName UserName Password Group; do
    A_FIRST_NAME+=("$FirstName")
    A_LAST_NAME+=("$LastName")
    A_USERNAME+=("$UserName")
    A_PASS+=("$Password")
    A_GROUP+=("$Group")
done <"$MY_INPUT"

for index in "${!A_USERNAME[@]}"; do
    if [[ "${A_USERNAME[$index]}" == "UserName" ]]; then
        continue
    fi
    useradd -c "${A_FIRST_NAME[$index]} ${A_LAST_NAME[$index]}" -m "${A_USERNAME[$index]}" -G "${A_GROUP[$index]}" -s /bin/bash  >> "$LOG_
FILE" 2>&1
    echo "${A_USERNAME[$index]}:${A_PASS[$index]}" | chpasswd >> "$LOG_FILE" 2>&1
    su - "${A_USERNAME[$index]}" -c "rm -rf ~/.ssh/id_rsa"
    su - "${A_USERNAME[$index]}" -c "ssh-keygen -N "${A_PASS[$index]}" -f "~/.ssh/id_rsa"" >> "$LOG_FILE" 2>&1
    echo "User ${A_USERNAME[$index]} created." | tee -a "$LOG_FILE"

done
}

function delete_users(){
LOG_FILE=deleted_users.log

MY_INPUT=$1

declare -a A_FIRST_NAME
declare -a A_LAST_NAME
declare -a A_USERNAME
declare -a A_PASS
declare -a A_GROUP
declare -a A_DEL_HOME
while IFS=, read -r FirstName LastName UserName Password Group DelHome; do
    A_FIRST_NAME+=("$FirstName")
    A_LAST_NAME+=("$LastName")
    A_USERNAME+=("$UserName")
    A_PASS+=("$Password")
    A_GROUP+=("$Group")
    A_DEL_HOME+=("$DelHome")
done <"$MY_INPUT"
for index in "${!A_USERNAME[@]}"; do
    if [[ "${A_USERNAME[$index]}" == "UserName" ]]; then
        continue
    fi

    if [[ "${A_DEL_HOME[$index]}" == "Y" ]]; then
        deluser --remove-home "${A_USERNAME[$index]}" >> "$LOG_FILE" 2>&1
    else
        deluser  "${A_USERNAME[$index]}" >> "$LOG_FILE" 2>&1
    fi
    echo "User ${A_USERNAME[$index]} deleted." | tee -a "$LOG_FILE"

done

}

get_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--create)
                #local name="$2"
                create_users "$2"
                shift 2
                ;;
            -d|--delete)
                delete_users "$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
}

get_args "$@"
