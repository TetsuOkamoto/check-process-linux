#!/bin/bash

################
# Scripts name : check-process.sh ver 1.0
# Usage        : ./check-process.sh
#                ����f�B���N�g����check-process.conf��z�u���Acron�Œ�����s����B
# Description  : Linux�v���Z�X�`�F�b�N�X�N���v�g
# Create       : 2017/12/14 Tetsu Okamoto (https://tech-mmmm.blogspot.jp/)
# Modify       : 
################

currentdir=`dirname $0`
conffile="${currentdir}/check-process.conf"    # �ݒ�t�@�C��
tmpfile="${currentdir}/check-process.tmp"      # �v���Z�X���ۑ��p�ꎞ�t�@�C��
rc=0    # Retuan Code�m�F�p

# ���ł�Down���Ă���v���Z�X�����擾
if [ -f ${tmpfile} ]; then
    down_process=`paste -d "|" -s ${tmpfile}`
fi
echo -n > ${tmpfile}

# �ݒ�t�@�C���ǂݍ���
cat ${conffile} | while read line
do
    # �󔒋�؂�ŕ���
    set -- ${line}
    [ $rc -lt $? ] && rc=$?
    
    # �R�����g�s�Ƌ�s���������Ȃ�
    if [ `echo $1 | grep -v -e '^ *#' -e '^$' | wc -c` -gt 0 ]; then
        [ $rc -lt $? ] && rc=$?
        
        # ���݂̃v���Z�X�����擾
        count=`ps ahxo args | grep $1 | grep -v -e "^grep" | wc -l`
        [ $rc -lt $? ] && rc=$?
        
        # �v���Z�X���`�F�b�N
        if [ ${count} -lt $2 ]; then
            # Down���̏���
            # ���ł�Down���Ă���v���Z�X���m�F
            if [ -n "${down_process}" ] && [ `echo $1 | egrep "${down_process}" | wc -c` -gt 0 ]; then
                # ���ł�Down
                [ $rc -lt $? ] && rc=$?
                message="[INFO] Process \"$1\" still down"
            else
                # ����Down
                [ $rc -lt $? ] && rc=$?                
                message="[ERROR] Process \"$1\" down"
            fi
            # ���O�֏o��
            logger $message
            [ $rc -lt $? ] && rc=$?
            
            # Donw���Ă���v���Z�X�����o��
            echo $1 >> ${tmpfile}
        else
            # Up���̏���
            # Down���Ă����v���Z�X���m�F
            if [ -n "${down_process}" ] && [ `echo $1 | egrep "${down_process}" | wc -c` -gt 0 ]; then
                # Down������
                [ $rc -lt $? ] && rc=$?
                message="[INFO] Process \"$1\" up"
                
                # ���O�֏o��
                logger $message
                [ $rc -lt $? ] && rc=$?
            fi
        fi
    fi
done

# �G���[����
if [ $rc -gt 0 ]; then
    logger "[ERROR] Process check script error (Max Return Code : ${rc})"
fi

exit $?

