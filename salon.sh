#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

#main menu
MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  # display services of the salon
  echo "Here are the services we provide:" 
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done 
 
  echo -e "\nWhat would you like to do?"
  read SERVICE_ID_SELECTED

  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    echo -e "\nSorry, the service you selected does not exist.\n"
    MAIN_MENU
  else
    SELECTED_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id='$SERVICE_ID_SELECTED'")
    if [[ -z $SELECTED_SERVICE_NAME ]]
    then 
      echo -e "\nSorry, the service you selected does not exist.\n"
      MAIN_MENU
    else
      echo -e "\nGreat, let's make an appointment for$SELECTED_SERVICE_NAME.\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo "What's your name?"
        read CUSTOMER_NAME
        ADD_NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      fi

      echo "At what time would you like to have your$SELECTED_SERVICE_NAME appointment, $CUSTOMER_NAME?"
      read SERVICE_TIME

      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      NEW_APPOINMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

      echo -e "\nI have put you down for a$SELECTED_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    fi
  fi
}

MAIN_MENU
