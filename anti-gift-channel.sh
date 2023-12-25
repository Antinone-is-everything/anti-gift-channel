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

Response=$(Key_Gen)
echo -e "Generated Key is : "
echo -e "${Response}" | jq '.'
Rename_Key ${Response}
Set_Data_Limit ${Response}
KEY=$(Get_Key ${Response})
echo -e "Finaly Key is : "
echo -e "${KEY}" | jq -r '.'

AccessUrl=$(echo $KEY | jq -r '.accessUrl')

MSG="📯📯📯\n\n
💫<b>کانفیگ تست رایگان</b>💫\n\n
🌐 📣 @anti_none\n\n
🇩🇪 Frankfurt\n\n
📆 ${DATE}\n\n
<code>${AccessUrl}#AntinoneVPN🌐${KeyId:-000}_freedome_${DATE:-2020-10-20}_${DataLimit:-10}G</code>\n\n
🗝 اپراتور : تمامی اپراتورها\n\n
📌نرم افزار های قابل نصب و استفاده\n\n
✳️OUTLINE\n
📱 <a href='https://play.google.com/store/apps/details?id=org.outline.android.client' >Android </a>\n
📱 <a href='https://apps.apple.com/us/app/outline-app/id1356177741' >IOS </a>\n
💻 <a href='https://itunes.apple.com/us/app/outline-app/id1356178125' >MacOS </a>\n
💻 <a href='https://s3.amazonaws.com/outline-releases/client/windows/stable/Outline-Client.exe' >Windows </a>\n
💻 <a href='https://s3.amazonaws.com/outline-releases/client/linux/stable/Outline-Client.AppImage' >Linux </a>\n\n
✳️ShadowSocks\n
📱 <a href='https://play.google.com/store/apps/details?id=com.github.shadowsocks' >Android </a> | <a href='https://t.me/anti_none/7' >Android </a>\n
📱 <a href='https://apps.apple.com/us/app/foxray/id6448898396' >IOS 16+ </a> | <a href='https://apps.apple.com/us/app/v2box-v2ray-client/id6446814690' >Older IOS </a>\n
📺 <a href='https://play.google.com/store/apps/details?id=com.github.shadowsocks.tv' >AndroidTV </a>\n
💻 <a href='https://github.com/shadowsocks/ShadowsocksX-NG/releases/download/v1.10.2/ShadowsocksX-NG.dmg' >MacOS </a>\n
💻 <a href='https://github.com/shadowsocks/shadowsocks-windows/releases/download/4.4.1.0/Shadowsocks-4.4.1.0.zip' >Windows </a>\n
💻 <a href='https://cloudflare-ipfs.com/ipfs/Qma38UCuXzFFvsPJYn1zA82Nb9yUrUn2mdpmQahw5SvHDB/v2ray-plugin-linux-amd64-v1.3.1.tar.gz' >Linux </a>\n
🌐 <a href='https://cloudflare-ipfs.com/ipfs/Qma38UCuXzFFvsPJYn1zA82Nb9yUrUn2mdpmQahw5SvHDB/' >Source </a>\n\n
✳️FoXray\n
📱 <a href='https://apps.apple.com/us/app/foxray/id6448898396?platform=iphone' >IOS </a>\n\n
📌 حجم : <b> 10 </b> گیگابایت🔋 \n\n
⚡️سرعت سوپر فست🔥\n\n
ایرانسل<tg-emoji emoji-id='5368324170671202286'>✔️</tg-emoji><tg-emoji emoji-id='5368324170671202286'>❌</tg-emoji>\n\n
همراه اول <tg-emoji emoji-id='5368324170671202286'>👍</tg-emoji><tg-emoji emoji-id='5368324170671202286'>👎</tg-emoji>\n\n
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
