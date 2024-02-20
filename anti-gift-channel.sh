#!/bin/bash 

if [[ ! -e /usr/bin/jq ]] ; then 
    echo "Command Jq not found!!!"
    echo "sudo apt install net-tools jq -y"
    exit 0 ;
fi

#Application API
API_URL='https://example.com:8080/API-KEY'

#Telegram Bot 
TOKEN="12344567890:AAgsdlgjdgklsghdlsgdhgls" # Telegram Bot Token
ChannelIDs=("-2020202020") # Telegram ID Channel
AdminIDs=("20202020202" "101010101010") # Telegram ID Admin


DATE=`TZ="Asia/Tehran" date +%F` 
TIME=`TZ="Asia/Tehran" date +%T_%F`

call_request_get="curl -s -k --max-time 2 -X GET"
call_request_put="curl -s -k --max-time 2 -X PUT"
call_request_post="curl -s -k --max-time 2 -X POST"

AccessUrl="ss:/noting:10901/"

function Send_Msg_Tlg() {
        Message="$@"
        for ID in ${IDs[@]} ; do
                #-o /dev/null
                echo -e "Message: ${Message}\nID: ${ID}"
                curl -s -o /dev/null --write-out "HTTPSTATUS:%{http_code}\n" -X POST 'https://api.telegram.org/bot'${TOKEN}'/sendMessage' \
                --header 'Content-Type: application/json' \
                --data '
                {
                    "chat_id": "'${ID}'",
                    "text": "'"${Message}"'",
                    "parse_mode": "HTML",
                    "disable_web_page_preview": false,
                    "disable_notification": false,
                }
                '
        done
}

function Key_Gen() {

    # store the whole response with the status at the and
    HTTP_RESPONSE=`$call_request_post --write-out "HTTPSTATUS:%{http_code}" $API_URL/access-keys --header 'Content-Type: application/json' --data '{"method":"chacha20-ietf-poly1305"}'`

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    # extract the status
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # print the body
    echo "$HTTP_BODY"

    # example using the status
    if [ ! $HTTP_STATUS -eq 201  ]; then
    echo "Error Generate Token [HTTP status: $HTTP_STATUS]"
    exit 0
    fi


}

function Rename_Key(){

    KeyId=`echo $@ | jq -r '.id'`
    KeyName=`echo "$KeyId-vahiddsy-${DATE}"`
     # store the whole response with the status at the and
    HTTP_RESPONSE=`$call_request_put --write-out "HTTPSTATUS:%{http_code}" $API_URL/access-keys/${KeyId}/name --header 'Content-Type: application/json' --data '{"name":"'"${KeyName}"'"}'`

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    # extract the status
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # example using the status
    if [ ! $HTTP_STATUS -eq 204  ]; then
    echo "Error Rename Key [HTTP status: $HTTP_STATUS]"
    exit 1
    fi

    # print the body
    echo "$HTTP_BODY"

}

function Set_Data_Limit() {

    DataLimit='10737418240' # Data limit bytes =~ 10G ----- 1Gbytes = 1073741824 Bytes
    KeyId=`echo $@ | jq -r '.id'`
    
    # store the whole response with the status at the and
    HTTP_RESPONSE=`$call_request_put --write-out "HTTPSTATUS:%{http_code}" $API_URL/access-keys/${KeyId}/data-limit --header 'Content-Type: application/json' --data '{"limit": {"bytes": '${DataLimit}'}}'`

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    # extract the status
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # print the body
    echo "$HTTP_BODY"

    # example using the status
    if [ ! $HTTP_STATUS -eq 204  ]; then
    echo "Error Data Limit Key [HTTP status: $HTTP_STATUS]"
    exit 1
    fi

}

function Get_Key() {

    KeyId=`echo $@ | jq -r '.id'`
    
    # store the whole response with the status at the and
    HTTP_RESPONSE=`$call_request_get --write-out "HTTPSTATUS:%{http_code}" $API_URL/access-keys/${KeyId} --header 'Content-Type: application/json'`

    # extract the body
    HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')

    # extract the status
    HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

    # print the body
    echo "$HTTP_BODY"

    # example using the status
    if [ ! $HTTP_STATUS -eq 200  ]; then
    echo "Error Data Limit Key [HTTP status: $HTTP_STATUS]"
    exit 0
    fi

}

Get_Poetry(){
    API_POETRY_CALL=$(curl -s https://c.ganjoor.net/beyt.php | grep -E 'ganjoor-m1|ganjoor-m2|ganjoor-poet')
    ganjoor_m1=$(echo "$API_POETRY_CALL" | sed -n 's/.*ganjoor-m1">\([^<]*\)<\/div>.*/\1/p')
    ganjoor_m2=$(echo "$API_POETRY_CALL" | sed -n 's/.*ganjoor-m2">\([^<]*\)<\/div>.*/\1/p')
    ganjoor_poet=$(echo "$API_POETRY_CALL" | sed -n 's/.*ganjoor-poet"><a href="[^"]*">\([^<]*\)<\/a>.*/\1/p')
    ganjoor_link_poetry=$(echo "$API_POETRY_CALL" | sed -n 's/.*ganjoor-poet"><a href="\([^"]*\)">[^<]*<\/a>.*/\1/p')
    
}


Response=$(Key_Gen)
echo -e "Generated Key is : "
echo -e "${Response}" | jq '.'
Rename_Key ${Response}
Set_Data_Limit ${Response}
KEY=$(Get_Key ${Response})
echo -e "Finaly Key is : "
echo -e "${KEY}" | jq -r '.'

AccessUrl=$(echo $KEY | jq -r '.accessUrl')

Get_Poetry

echo "ganjoor-m1: $ganjoor_m1"
echo "ganjoor-m2: $ganjoor_m2"
echo "ganjoor-poet: $ganjoor_poet"

MSG="📯📯📯\n
💫<b>کانفیگ تست رایگان</b>💫\n\n
🌐 📣 @anti_none\n
🇩🇪 Frankfurt\n
📆 ${DATE}\n
<code>${AccessUrl}#AntinoneVPN🌐${KeyId:-000}_freedome_${DATE:-2020-10-20}_${DataLimit:-10}G</code>\n\n
🗝 اپراتور : تمامی اپراتورها\n
📌 حجم : <b> 10 </b> گیگابایت🔋 \n
⚡️سرعت سوپر فست🔥\n
ایرانسل<tg-emoji emoji-id='5368324170671202286'>✔️</tg-emoji><tg-emoji emoji-id='5368324170671202286'>❌</tg-emoji>\n
همراه اول <tg-emoji emoji-id='5368324170671202286'>👍</tg-emoji><tg-emoji emoji-id='5368324170671202286'>👎</tg-emoji>\n\n

<b>شعر روز</b>📜\n\n
${ganjoor_m1}\n
${ganjoor_m2}\n
👤✒️<a href='${ganjoor_link_poetry}'><b>${ganjoor_poet}</b></a>\n\n

♻️با اشتراک گذاری این پست از ما حمایت کنید\n\n
📣 @anti_none\n
🤖 @Antinone_Bot\n
🆘 @antinone_support
"
KEY=$(echo "${KEY//\"/\\\"}")
IDs=${ChannelIDs[@]}
Send_Msg_Tlg $MSG
IDs=${AdminIDs[@]}
Send_Msg_Tlg "<pre>${KEY}</pre>\n⏰ Time: ${TIME}"
