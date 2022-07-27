#!/bin/bash
# Linux Server Status script

echo '============= SYSTEM INFO ===================' >> /var/log/security-check-log
cat /dev/null > /var/log/security-check-log
date >> /var/log/security-check-log
httpd -v >> /var/log/security-check-log
cat /proc/cpuinfo | grep "model name" >> /var/log/security-check-log
cat /proc/cpuinfo | grep "cores" >> /var/log/security-check-log
cat /proc/meminfo | grep "MemTotal" >> /var/log/security-check-log
cat /proc/meminfo | grep "MemFree" >> /var/log/security-check-log
ls -sl --block-size=K /var/log | sort -n >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= CURRENT USERS ================' >> /var/log/security-check-log
w >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= USER HISTORY ================' >> /var/log/security-check-log
last >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= SSH ================' >> /var/log/security-check-log
journalctl | grep "ssh" >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= FAILS ================' >> /var/log/security-check-log
journalctl | grep "fail" >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log




ls -sl --block-size=K /var/log/httpd | sort -n >> /var/log/security-check-log
echo '============= [ERROR_LOG] HTTPD ================' >> /var/log/security-check-log
cat /var/log/httpd/error_log >> /var/log/security-check-log
cat /dev/null > /var/log/httpd/error_log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [ACCESS_LOG] HTTPD ================' >> /var/log/security-check-log
cat /var/log/httpd/access_log >> /var/log/security-check-log
cat /dev/null > /var/log/httpd/access_log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


ls -sl --block-size=K /var/log/exim | sort -n >> /var/log/security-check-log
echo '============= [REJECTLOG] EXIM ================' >> /var/log/security-check-log
cat /var/log/exim/rejectlog >> /var/log/security-check-log
cat /dev/null > /var/log/exim/rejectlog
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [PANICLOG] EXIM ================' >> /var/log/security-check-log
cat /var/log/exim/paniclog >> /var/log/security-check-log
cat /dev/null > /var/log/exim/paniclog
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [PROCESSLOG] EXIM ================' >> /var/log/security-check-log
cat /var/log/exim/processlog >> /var/log/security-check-log
cat /dev/null > /var/log/exim/processlog
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [MAINLOG] EXIM ================' >> /var/log/security-check-log
cat /var/log/exim/mainlog >> /var/log/security-check-log
cat /dev/null > /var/log/exim/mainlog
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


ls -sl --block-size=K /var/log/proftpd | sort -n >> /var/log/security-check-log
echo '============= [AUTH.LOG] PROFTPD ================' >> /var/log/security-check-log
cat /var/log/proftpd/auth.log >> /var/log/security-check-log
cat /dev/null > /var/log/proftpd/auth.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [PROFTPD.TLS.LOG] PROFTPD ================' >> /var/log/security-check-log
cat /var/log/proftpd/proftpd.tls.log >> /var/log/security-check-log
cat /dev/null > /var/log/proftpd/proftpd.tls.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [ACCESS.LOG] PROFTPD ================' >> /var/log/security-check-log
cat /var/log/proftpd/access.log >> /var/log/security-check-log
cat /dev/null > /var/log/proftpd/access.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


ls -sl --block-size=K /var/log/directadmin | sort -n >> /var/log/security-check-log
echo '============= [SECURITY.LOG] DIRECTADMIN ================' >> /var/log/security-check-log
cat /var/log/directadmin/security.log >> /var/log/security-check-log
cat /dev/null > /var/log/directadmin/security.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [LOGIN.LOG] DIRECTADMIN ================' >> /var/log/security-check-log
cat /var/log/directadmin/login.log >> /var/log/security-check-log
cat /dev/null > /var/log/directadmin/login.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [ERROR.LOG] DIRECTADMIN ================' >> /var/log/security-check-log
cat /var/log/directadmin/error.log >> /var/log/security-check-log
cat /dev/null > /var/log/directadmin/error.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [ERRORTASKQ.LOG] DIRECTADMIN ================' >> /var/log/security-check-log
cat /var/log/directadmin/errortaskq.log >> /var/log/security-check-log
cat /dev/null > /var/log/directadmin/errortaskq.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [SYSTEM.LOG] DIRECTADMIN ================' >> /var/log/security-check-log
cat /var/log/directadmin/system.log >> /var/log/security-check-log
cat /dev/null > /var/log/directadmin/system.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log



echo '======================================' >> /var/log/security-check-log
echo '============= [SECURE] LOGIN FAILURES ================' >> /var/log/security-check-log
cat /var/log/secure >> /var/log/security-check-log
cat /dev/null > /var/log/secure
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= [MESSAGES] SYSTEM MESSAGES ================' >> /var/log/security-check-log
cat /var/log/messages >> /var/log/security-check-log
cat /dev/null > /var/log/messages
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============= YUM LOG ================' >> /var/log/security-check-log
cat /var/log/yum.log >> /var/log/security-check-log
cat /dev/null > /var/log/yum.log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log


echo '============================================================================' >> /var/log/security-check-log
echo '============= RUNNING PROCESSES ================' >> /var/log/security-check-log
ps -A >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log
echo '.' >> /var/log/security-check-log

echo '================================= END OF FILE ==============================' >> /var/log/security-check-log
echo '============================================================================' >> /var/log/security-check-log
echo '============================================================================' >> /var/log/security-check-log



echo SECURITY STATUS SHORT > security-status-short
date >> security-status-short
echo 'Aantal regels:' >> security-status-short
wc -l security-status-log >> security-status-short
echo ======================= >> security-status-short
echo ======================= >> security-status-short
echo 'HTTPD-error:'  >> security-status-short
grep -o -c 'error' security-check-log >> security-status-short
echo ======================= >> security-status-short
echo 'EXIM-incorrect-authentication-data:' >> security-status-short
grep -o -c 'Incorrect authentication data' security-check-log >> security-status-short
echo 'EXIM-tls-error-on-connection:' >> security-status-short
grep -o -c 'TLS error on connection' security-check-log >> security-status-short
echo ======================= >> security-status-short
echo 'PROFTPD:' >> security-status-short
grep -o -c 'ProFTPd' security-check-log >> security-status-short
echo ======================= >> security-status-short
echo 'DIRECTADMIN:' >> security-status-short
echo ======================= >> security-status-short
echo 'FIREWALL-tcp-in-blocked:' >> security-status-short
grep -o -c 'TCP_IN Blocked' security-check-log >> security-status-short
echo 'FIREWALL-udp-in-blocked:' >> security-status-short
grep -o -c 'UDP_IN Blocked' security-check-log >> security-status-short
echo ======================= >> security-status-short
echo ======================= >> security-status-short


sendmail info@pagesathome.eu < /var/log/security-status-short
cp /var/log/security-check-log /home/admin/reps/security-check-log.$(date +%F_%R)
