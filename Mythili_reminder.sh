#!/bin/bash
#same creating a Remind_1 file
echo "1. Call to my mom" > Remind_1


subject="Reminder as per your request"
declare -a note_list
#############################################################
#               Configure your mail Id                      #
#############################################################
mail_config=1
echo "#############################################################"
echo "#                Configure your mail id                     #"
echo "#############################################################"

while [ $mail_config -eq 1 ]
do
    read -p "Enter your mail ID?" mail_id
    read -p "Confirm your mail Id $mail_id ?(y/n)" mail
    case $mail in
        [Yy]* ) mail_config=0; break;;
        [Nn]* ) mail_config=1;;
        * ) echo "Please answer yes or no.";;
    esac
done


#############################################################
#                  list the reminders                       #
#############################################################
notes () {
  note_list=($(ls Remind_*))
  i=1
  echo ""
  for file in ${note_list[*]}; do
    echo "$i $file"
    i=$((i + 1))
  done
  echo ""
}
#############################################################
#   Set the reminder and will list files start wil Remind_  #
#############################################################
rem_create () {
  notes;
  if [ ${#note_list[@]} -eq 0 ]; then
     echo "No notes are available."
  else
  select=0
  while true ; do
     if [ $select -eq 0 ]
     then
        read -p "Select the note to set for reminder?" Opt
        if [ $Opt -le 0 -o $Opt -gt ${#note_list[*]} ]
        then
           continue;
        else
           select=1;
        fi
     fi
     #set the date time to send the mail
     echo "Enter the Date & Time(24Hr) format as YYYY-MM-DD_hh:mm"
     read -p "Enter the reminder date:" Date
     #Set the mail reminder
     DD=`date '+%d'`
     YY=`date '+%Y'`
     MM=`date '+%m'`
     hh=`date '+%H'`
     mm=`date '+%M'`
     while IFS="-_:" read year month date hour minute
     do
          set_time=""
          if [[ -z $year || -z $month || -z $date || -z $hour || -z $minute ]]; then
            set_time=""
            break;
          fi
          if [ $year -ge $YY ]; then
             if [ $year -eq $YY -a $month -ge $MM -o $year -gt $YY ]; then
                if [ $month -eq $MM -a $date -ge $DD -o $month -gt $MM ]; then
                   if [ $date -eq $DD -a $hour -ge $hh -o $date -gt $DD ]; then
                      if [ $hour -eq $hh -a $minute -ge $mm -o $hour -gt $hh ]; then
                         set_time="$hour:$minute $date/$month/$year"
                      fi
                   fi
                fi
             fi
          fi
          if [ "$set_time" != "" ]; then
            break;
          fi
     done <<< "$Date"
     if [ "$set_time" != "" ]; then
       echo "mailx -s $subject $mail_id < ${note_list[$Opt - 1]} | at $set_time"
       mailx -s  "$subject" "$body" $mail_id  < ${note_list[$Opt - 1]} | at $set_time
	   echo "Your reminder is successfully added !!!"
	   echo "Make note of your job id. Incase u plan to cancel the reminder."
       break;
     else
        dat=`date`
        echo "Entered past time/ it is invalid. Current Time:$dat"
     fi
  done
  fi
  echo ""
}

#############################################################
#                  list the reminders                       #
#############################################################
list_reminder () {
  echo ""
  list=`atq`;
  if [ -z "$list" ]; then
     echo "No reminder is set";
  else
     echo "Id       Date          Time"
     atq
  fi
  echo ""
}

#############################################################
#                  list the reminders                       #
#############################################################
rem_delete () {
  echo ""
    list=`atq`;
    if [ -z "$list" ]; then
       echo "No reminder is set";
    else
        echo "Id       Date          Time"
       atq
       read -p "Select the Id:" del_rem
       cmd=`atrm $del_rem 2>&1 | grep "Cannot find"`
       validate="Cannot find jobid $del_rem"
       if [ "$cmd" = "$validate" ]; then
          echo "Cannot find the reminder"
       else
          echo "Successfully removed the reminder."
       fi
    fi
  echo ""
}
#Enter your option create a reminder/ delete a reminder/ quit


while true; do
echo "#############################################################"
echo "#       Select the following to assist you                   #"
echo "#############################################################"
    echo "1. List of reminder notes to select"
    echo "2. Select a reminder note to set"
    echo "3. List the reminders"
    echo "4. Delete a reminder"
    echo "5. Exit"
    read -p "Select any option?" Option
    case $Option in
        1) notes;;
        2) rem_create;;
        3) list_reminder;;
        4) rem_delete;;
        5) exit 0;;
        *) echo "";;
    esac
done
