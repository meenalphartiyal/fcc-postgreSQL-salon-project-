#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $SERVICES ]]
  then
    echo -e "\nSorry We don't have any service available at the moment"
  
  else
    echo "$SERVICES" | while read SERVICE_ID_SELECTED BAR SERVICE_NAME_SELECTED
    do
      echo "$SERVICE_ID_SELECTED) $SERVICE_NAME_SELECTED"
    done

    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Please enter a valid option"
    
    else
      SERVICE_AVAILABLE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_ID_SELECTED ]]
      then
        MAIN_MENU "I could not find that service. What would you like today?"
      
      else
        SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
        echo -e "\nWhat's your phone number?"
        read CUSTOMER_PHONE
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nI don't have a record for that phone number, what's your name?"
          read CUSTOMER_NAME
          INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
          
        fi 
        SERVICE_INFO_FORMATTED=$(echo $SERVICE_NAME_SELECTED | sed 's/ |/"/')
        echo -e "\nWhat time would you like your $SERVICE_INFO_FORMATTED, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
        read SERVICE_TIME

        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

        if [[ $SERVICE_TIME ]]
        then
          INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          if [[ $INSERT_APPOINTMENT ]]
          then
            echo -e "\nI have put you down for a $SERVICE_INFO_FORMATTED at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
          fi
        fi
      fi
    fi
  fi
}


MAIN_MENU