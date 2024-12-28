#!/bin/bash
firtsTimeRun() {

    [[ ! -f /usr/bin/jq ]] && {
        apt install jq
    }
    [[ ! -d /root/test ]] && mkdir -p /root/test
    [[ ! -f /root/test/api.sh ]] && {
        wget -qO- http://api.samhub.my.id/BotAPI.sh >/root/test/api.sh
    }
}
firtsTimeRun

source /root/test/api.sh
get_Token=$1
get_AdminID=$2

ShellBot.init --token $get_Token --monitor --return map --flush --log_file /root/log_bot

msg_welcome() {
    local msg
    msg="Welcome ${message_from_first_name}\n"
    msg+="These are the services provided by samsfx\n"
    ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard1" \
        --parse_mode html
}

backReq() {
    msg="Welcome ${callback_query_from_first_name}\n"
    msg+="These are the services provided by samsfx\n"
    ShellBot.sendMessage --chat_id ${callback_query_from_id[$id]} \
        --text "$msg" \
        --reply_markup "$keyboard1" \
        --parse_mode html
}

broadcast_msg() {
    if [ "${message_from_id[$id]}" == "$get_AdminID" ]; then
        for broad in $(cat /root/ottbot/all_id.txt /root/ottbot/expired.txt | awk '{print $5}' | sort | uniq); do
            ShellBot.forwardMessage --chat_id "$broad" \
                --from_chat_id "${message_reply_to_message_from_id[$id]}" \
                --message_id "${message_reply_to_message_message_id[$id]}"
        done
    fi
    exit 0
}

while :; do
    ShellBot.getUpdates --limit 100 --offset $(ShellBot.OffsetNext) --timeout 35
    for id in $(ShellBot.ListUpdates); do
        (
            ShellBot.watchHandle --callback_data ${callback_query_data[$id]}
            [[ ${message_chat_type[$id]} != 'private' ]] && {
                ShellBot.sendMessage --chat_id ${message_chat_id[$id]} \
                    --text "$(echo -e "⛔ only run this command on private chat / pm on bot")" \
                    --parse_mode html
                >$CAD_ARQ
                break
                ShellBot.sendMessage --chat_id ${callback_query_message_chat_id[$id]} \
                    --text "Func Error Do Nothing" \
                    --reply_markup "$(ShellBot.ForceReply)"
            }
            CAD_ARQ=/tmp/cad.${message_from_id[$id]}
            if [[ ${message_entities_type[$id]} == bot_command ]]; then
                case ${message_text[$id]} in
                *)
                    :
                    comando=(${message_text[$id]})
                    [[ "${comando[0]}" = "/bc" ]] && broadcast_msg
                    ;;
                esac
            fi
        ) &
    done
done
