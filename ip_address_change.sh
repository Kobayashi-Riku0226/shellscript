#!/bin/bash

#インバウンドルールに該当のIPアドレスが設定されてるセキュリティグループのIDを取得
sg_ids=`aws ec2 describe-security-groups --filters Name=ip-permission.cidr,Values=$1 --query SecurityGroups[].GroupId`
echo -e "対象のセキュリティグループ\n$sg_ids\n"

while :
do

#yesもしくはnoを入力する
  read -p "IPアドレスを変更しますか？(yes/no): " answer

#yesの場合変更を開始する
  if [ "yes" = $answer ] ; then

#セキュリティグループIDの数だけ処理を行うためfor文でループさせる
    for sg_id in $(echo $sg_ids | jq '.[]' | sed -E 's/[\"]//g')
    do
      
      echo -e "\n$sg_id を変更中"
#セキュリティグループに設定されているルールを取得
      sg_rules=`aws ec2 describe-security-group-rules --filters Name=group-id,Values=$sg_id --query SecurityGroupRules`

#セキュリティグループに設定されているルールの数だけ処理を行うためfor文でループさせる
      for sg_rule_id in $(echo $sg_rules | jq '.[].SecurityGroupRuleId')
      do

#セキュリティグループルールに設定されているIPアドレスを取得
        CidrIpv4=`aws ec2 describe-security-group-rules --filters Name=security-group-rule-id,Values=$sg_rule_id | jq '.SecurityGroupRules[].CidrIpv4' | sed -E 's/[\"]//g'`

#インバウンドルール、アウトバウンドルールか確認するために実行
        sg_rule_type=`aws ec2 describe-security-group-rules --filters Name=security-group-rule-id,Values=$sg_rule_id | jq '.SecurityGroupRules[].IsEgress'`

#該当のIPアドレスであること、インバウンドルールであることをチェックする
        if [ $1 = $CidrIpv4 ] && [ false = $sg_rule_type ] ; then

#セキュリティグループルールに設定するプロトコル、ポート番号を取得
          IpProtocol=`aws ec2 describe-security-group-rules --filters Name=security-group-rule-id,Values=$sg_rule_id | jq '.SecurityGroupRules[].IpProtocol' | sed -E 's/[\"]//g'`
          FromPort=`aws ec2 describe-security-group-rules --filters Name=security-group-rule-id,Values=$sg_rule_id | jq '.SecurityGroupRules[].FromPort'`
          ToPort=`aws ec2 describe-security-group-rules --filters Name=security-group-rule-id,Values=$sg_rule_id | jq '.SecurityGroupRules[].ToPort'`

#IPアドレスの変更を実行
          aws ec2 modify-security-group-rules --group-id $sg_id --security-group-rules SecurityGroupRuleId=$sg_rule_id,SecurityGroupRule={"IpProtocol=$IpProtocol,FromPort=$FromPort,ToPort=$ToPort,CidrIpv4=$2"}
        fi
      done
    done
    echo -e "\nIPアドレスの変更が完了しました"
    break
#noの場合変更しない
  elif [ "no" = $answer ] ; then
    echo -e "\nIPアドレスを変更しませんでした"
    break

#yesもしくはno以外の文字列が入力されたときの処理
  else 
    echo -e "\nyes もしくは no を入力してください\n"
  fi
done
