#!/bin/bash
#

sleep 30

# 处理1: 获取当前主机的外部 IP 地址
current_ip=$(curl -s ifconfig.me)

# 处理2: 获取特定域名解析的 IP 地址
# 替换 YOUR_DOMAIN 和 YOUR_RR 为您的实际域名和主机记录
domain="YOUR_DOMAIN"
rr="YOUR_RR"

# 获取记录列表的 JSON 输出
json_output=$(aliyun alidns DescribeDomainRecords --DomainName $domain --RRKeyWord $rr --Type A)

# 使用 jq 处理 JSON，提取 record_id 和 resolved_ip
record_id=$(echo $json_output | jq -r '.DomainRecords.Record[0].RecordId')
resolved_ip=$(echo $json_output | jq -r '.DomainRecords.Record[0].Value')

# 输出结果
echo "Record ID: $record_id"
echo "Resolved IP: $resolved_ip"

# 判断两个 IP 地址是否相同
if [ "$current_ip" != "$resolved_ip" ]; then
    # 处理3: 更新域名解析的 IP 地址
    echo "外部 IP 地址已变更，更新域名解析..."
    aliyun alidns UpdateDomainRecord --RecordId $record_id --RR $rr --Type A --Value $current_ip
    echo "域名解析已更新为 $current_ip"
else
    echo "外部 IP 地址未变更，无需更新域名解析。"
fi


# 定义 CloudFlare 的 API 密钥和邮箱
API_KEY=YOUR_API_KEY
ZONE_ID=YOUR_ZONE_ID
RECORD_ID=YOUR_RECORD_ID
DOMAIN_NAME=YOU_DOMAIN_NAME


# 调用 CloudFlare API 更新 DNS 记录
response=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
     -H "Authorization: Bearer $API_KEY" \
     -H "Content-Type: application/json" \
     --data '{
         "type":"A",
         "name":"$DOMAIN_NAME",
         "content":"'$current_ip'",
	 "proxied": true,
         "ttl":120,
         "proxied":false
     }')

# 打印 API 返回的响应
echo $response
