#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CUSTOMER_NAME=""
CUSTOMER_PHONE=""

MAKE_APPOINTMENT() {
    SERVICE_NAME=$($PSQL "SELECT service_name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    CUSTOMERS=$($PSQL "SELECT customer_name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/ //g')
    CUSTOMERS_FORMATTED=$(echo $CUSTOMERS | sed 's/ //g')
    echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMERS_FORMATTED?"
    read SERVICE_TIME
    INSERTED_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMERS_FORMATTED."
}

MAIN_MENU(){
  if [[ $1 ]]
  then
      echo -e "\n$1"
  fi

  SERVICES=$($PSQL "SELECT service_id, service_name FROM services")

  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME Service"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      AVAILABLE_SERVICE=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      if [[ -z $AVAILABLE_SERVICE ]]
      then
          MAIN_MENU "I could not find that service. What would you like today?"
      else
          echo -e "\nWhat's your phone number?"
          read CUSTOMER_PHONE

          REGULAR_CUSTOMER=$($PSQL "SELECT customer_id, customer_name FROM customers WHERE phone='$CUSTOMER_PHONE'")

          if [[ -z $REGULAR_CUSTOMER ]]
          then
            echo -e "\nI don't have a record for that phone number, what's your name?"
            read CUSTOMER_NAME
            INSERTED_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(customer_name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            MAKE_APPOINTMENT
            else
            MAKE_APPOINTMENT
          fi
        fi
      fi
}
MAIN_MENU


