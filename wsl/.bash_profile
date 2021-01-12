if [ -f ~/.bashrc ]; then
	    . ~/.bashrc
fi

otp2 ()
{

    local fqdn_accounts=''

    for item in "$@"; do
        if [[ $item == *@* ]]; then
            if [ -z ${fqdn_accounts} ]; then
                fqdn_accounts="$item"
            else
                fqdn_accounts+=",$item"
            fi
        fi
    done

    if [ -z ${fqdn_accounts} ]; then
        (>&2 echo "otp error: Delimiter(@) not found")
        return 1
    fi

    local ID=''
    local PASSWORD=''
    local TOKEN=''

    echo -n "LDAP ID: "
    read ID
    echo -n "password: "
    read -s PASSWORD
    echo ""

    if [ -z $ID ] || [ -z $PASSWORD ]; then
        return 1
    fi



    local api_base="https://api-infrasec.daumkakao.io/v2"
    local http_response=`curl -X POST -H "Accept: text/plain" -d "id=$ID&password=$PASSWORD&type=helloMis" "$api_base/auth/token" -s --write-out '\nHTTPSTATUS:%{http_code}'`
    local http_status=$(echo "$http_response"| tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    TOKEN=$(echo "$http_response"| sed -e 's/HTTPSTATUS\:.*//g')
    if [ $http_status -ne 200 ] || [ -z "$TOKEN" ]; then
        (>&2 echo "otp error: $http_response")
        return 1
    fi

    http_response=`curl "$api_base/ssh/otp" -H "Authorization: Bearer $TOKEN" -s --write-out '\nHTTPSTATUS:%{http_code}'`
    local http_body=$(echo "$http_response"| sed -e 's/HTTPSTATUS\:.*//g')
    http_status=$(echo "$http_response"| tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
    if [ $http_status -ne 200 ] || [ -z "$http_body" ]; then
        (>&2 echo "otp error: $http_response")
        return 1
    fi



    local OTP=''
    echo -n "OTP: "
    read OTP



    http_response=`curl -X POST -d "otp=$OTP&data=$fqdn_accounts" "$api_base/approvals/authorization/otp" -s --write-out '\nHTTPSTATUS:%{http_code}'`
    http_body=$(echo "$http_response"| sed -e 's/HTTPSTATUS\:.*//g')
    http_status=$(echo "$http_response"| tr -d '\n' | sed -e 's/.*HTTPSTATUS://')



    if [ $http_status -ne 200 ] && [ ! -z "$http_body" ]; then
        (>&2 echo "otp error: $http_body")
        return 1
    else
        echo "Authorization Complete."
    fi

    if [ $# -eq 1 ]; then
        `which ssh` "$@"
    else
        echo "$@"
        #`which csshX` "$@"
    fi
    return 0
}
