# shellscript
## スクリプトファイル
### ip_address_change.sh
セキュリティグループに設定された該当のIPアドレスを変更するシェルスクリプト  
使用方法は以下の通りとなる
``` bash
chmod 755 ip_address_change.sh
./ip_address_change.sh △△.△△.△△.△△/32 □□.□□.□□.□□/32
```
1. 一つ目の引数は変更前のIPアドレスを記載する  
2. 二つ目の引数は変更後のIPアドレスを記載する  
